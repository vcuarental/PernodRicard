public with sharing class ASI_HK_CRM_ARCheckHelper {
    
    private static ASI_HK_CRM_Web_Service_Setting__c wsSetting;
    private static ASI_HK_CRM_ARCreditWS.CustomBssvManagerHttpPort checkARWS;
    private static string userNameDateStr;   //Used to fill in the AR and salesOrder
    
    static {
        userNameDateStr = getUserNameAndDateStr();
        
        List<ASI_HK_CRM_Web_Service_Setting__c> wsSettings = [
            SELECT Id, ASI_HK_CRM_Base_URL__c, ASI_HK_CRM_Username__c, ASI_HK_CRM_Password__c
            FROM ASI_HK_CRM_Web_Service_Setting__c
            WHERE ASI_HK_CRM_Key__c = 'ASI_HK_CRM_ARCheck'
        ];
        if (wsSettings.size() == 1) {
            wsSetting = wsSettings[0];
            checkARWS = new ASI_HK_CRM_ARCreditWS.CustomBssvManagerHttpPort(
                wsSetting.ASI_HK_CRM_Base_URL__c
                , wsSetting.ASI_HK_CRM_Username__c
                , wsSetting.ASI_HK_CRM_Password__c
            );
            checkARWS.timeout_x = 60000;
        } else if (wsSettings.size() == 0) {
            throw new ASI_HK_CRM_CustomException('ASI HK CRM master web service setting not found');
        } else {
            throw new ASI_HK_CRM_CustomException('Duplicate ASI HK CRM master web service settings');
        }
    }
    
    public static void updateAccountByWS(Account acct, ASI_HK_CRM_Sales_Order__c so, Integer jdeAcctNum) {
        System.debug('tdk12'+jdeAcctNum);
        ASI_HK_CRM_ARCreditWSTypes.N56ARCR_Output checkARResult = checkARWS.GetARCredit(null, null, jdeAcctNum, null, null, null, null, null, null, null, null, null, null, null, null, null);
        updateAccountFromWSResult(acct, checkARResult);
        updateSalesOrderFromWSResult(so, checkARResult);
    }

    //Add by Abel Handle the concatenation of userName and String
    private static string getUserNameAndDateStr(){
        String result= UserInfo.getName();
        result += ', ';
        result += Datetime.now().format('dd/MM/yyyy hh:mm');
        return result;
    }   
    
    
    private static void updateSalesOrderFromWSResult(ASI_HK_CRM_Sales_Order__c so, ASI_HK_CRM_ARCreditWSTypes.N56ARCR_Output checkARResult) {
        
        so.ASI_HK_CRM_Credit_Limit__c = checkARResult.amountCreditLimit;
        so.ASI_HK_CRM_Payment_Term_Code__c = strToStr(checkARResult.paymentTermsCode);
        so.ASI_HK_CRM_Payment_Term_Description__c = strToStr(checkARResult.descriptionPaymentTerms);
        so.ASI_HK_CRM_Current_Amount__c = checkARResult.amountAgingCategories1;
        so.ASI_HK_CRM_X1_30__c = checkARResult.amountAgingCategories2;
        so.ASI_HK_CRM_X31_60__c = checkARResult.amountAgingCategories3;
        so.ASI_HK_CRM_X61_90__c = checkARResult.amountAgingCategories4;
        so.ASI_HK_CRM_Over_91__c = checkARResult.amountAgingCategories8;
        so.ASI_HK_CRM_Total_Exposure__c = checkARResult.amountUserDefined;
        so.ASI_HK_CRM_Overdue_30_days__c = checkARResult.amountDue;  
        so.ASI_HK_CRM_AR_Info_Last_Updated_By__c = userNameDateStr;
        
    }   
     
    
    private static void updateAccountFromWSResult(Account acct, ASI_HK_CRM_ARCreditWSTypes.N56ARCR_Output checkARResult) {

        acct.ASI_HK_CRM_Credit_Limit__c = checkARResult.amountCreditLimit;
        acct.ASI_HK_CRM_Payment_Term_Code__c = strToStr(checkARResult.paymentTermsCode);        
        acct.ASI_HK_CRM_Payment_Term_Description__c = strToStr(checkARResult.descriptionPaymentTerms);
        acct.ASI_HK_CRM_Current_Amount__c = checkARResult.amountAgingCategories1;
        acct.ASI_HK_CRM_X1_30__c = checkARResult.amountAgingCategories2;
        acct.ASI_HK_CRM_X31_60__c = checkARResult.amountAgingCategories3;
        acct.ASI_HK_CRM_X61_90__c = checkARResult.amountAgingCategories4;
        acct.ASI_HK_CRM_Over_91__c = checkARResult.amountAgingCategories8;
        acct.ASI_HK_CRM_Total_Exposure__c = checkARResult.amountUserDefined;
        acct.ASI_HK_CRM_Overdue_30_days__c = checkARResult.amountDue;   
        //Handle the updated by Concat Name and DateTime
        acct.ASI_HK_CRM_AR_Info_Last_Updated_By__c = userNameDateStr;
        
        /*
        System.debug('tdk1'+acct.ASI_HK_CRM_Credit_Limit__c);
        System.debug('tdk2'+acct.ASI_HK_CRM_Payment_Term_Code__c);
        System.debug('tdk3'+acct.ASI_HK_CRM_Payment_Term_Description__c);
        System.debug('tdk4'+acct.ASI_HK_CRM_Current_Amount__c);
        System.debug('tdk5'+acct.ASI_HK_CRM_X1_30__c);
        System.debug('tdk6'+acct.ASI_HK_CRM_X31_60__c);
        System.debug('tdk7'+acct.ASI_HK_CRM_X61_90__c);
        System.debug('tdk8'+acct.ASI_HK_CRM_Over_91__c);
        */
    }
    
    private static Decimal strToDec(String str) {
        System.debug(str);
        return String.isBlank(str) || str.trim().toLowerCase() == 'null' ? null : Decimal.valueOf(str);
    }
    private static String strToStr(String str) {
        System.debug(str);
        return String.isBlank(str) ? null : str.trim();
    }
}