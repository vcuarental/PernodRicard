public with sharing class ASI_HK_CRM_RunningNumberGenerator {

    public static final Integer FIRST_MONTH_FISCAL_YR_SO = 7;
    public static final String FORMAT_SO = 'SO-{YY}{000000}';
    public static final Integer FIRST_MONTH_FISCAL_YR_PAF = 7;
    public static final String FORMAT_PAF = 'PAF-{YY}{000000}';
    
    public static void initSORunningNumber() {
        ASI_HK_CRM_Running_Number__c runningNum = generateRunningNumber(
            FIRST_MONTH_FISCAL_YR_SO
            , null
            , FORMAT_SO
            , 'ASI_HK_CRM_Sales_Order__c'
            , null
        );
        insert runningNum;
    }
    
    public static void initPAFRunningNumber() {
        ASI_HK_CRM_Running_Number__c runningNum = generateRunningNumber(
            FIRST_MONTH_FISCAL_YR_PAF
            , null
            , FORMAT_PAF
            , 'ASI_HK_CRM_Pre_Approval_Form__c'
            , null
        );
        insert runningNum;
    }
    
    public ASI_HK_CRM_Running_Number__c GenerateBasicRunningNumber(integer First_Mon_of_Fiscal, Integer Fiscal_Year, String format, String Obj_Name, Integer Starting_num) {
        return GenerateBasicRunningNumber(First_Mon_of_Fiscal, Fiscal_Year, format, Obj_Name, Starting_num);
    }
    public static ASI_HK_CRM_Running_Number__c generateRunningNumber(integer First_Mon_of_Fiscal, Integer Fiscal_Year, String format, String Obj_Name, Integer Starting_num) {
        return new ASI_HK_CRM_Running_Number__c(
            ASI_HK_CRM_First_Month_of_Fiscal_Year__c = First_Mon_of_Fiscal
            , ASI_HK_CRM_Fiscal_Year__c = Fiscal_Year
            , ASI_HK_CRM_Format__c = format
            , ASI_HK_CRM_Object_Name__c = Obj_Name
            , ASI_HK_CRM_Running_Number__c = Starting_num
        );
    }   
    
    

}