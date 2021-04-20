public with sharing class ASI_CRM_SG_FinanceCustomer_Controller {
    
    public ASI_CRM_AccountsAdditionalField__c header {get;set;}
    
    public ASI_CRM_SG_FinanceCustomer_Controller(ApexPages.StandardController stdController) {
        
        List<ASI_CRM_AccountsAdditionalField__c> headerList = (List<ASI_CRM_AccountsAdditionalField__c>)queryAll(((ASI_CRM_AccountsAdditionalField__c)stdController.getRecord()).id, 'ASI_CRM_AccountsAdditionalField__c', 'ID', '');
        
        if(headerList.size() > 0) {   
            Header = headerList.get(0);
            setDefaultValues();
        }
    }
    
    public void setDefaultValues () {
        if(Header!= null) {
            header.ASI_CRM_SG_Customer_Price_Group__c = header.ASI_CRM_SG_Customer_Price_Group__c != null ? header.ASI_CRM_SG_Customer_Price_Group__c  : 'PRICEGRP';
            header.ASI_CRM_SG_Search_Type__c = header.ASI_CRM_SG_Search_Type__c != null ? header.ASI_CRM_SG_Search_Type__c : 'D - Delivery Address';
            header.ASI_CRM_SG_Business_Unit__c = header.ASI_CRM_SG_Business_Unit__c != null ? header.ASI_CRM_SG_Business_Unit__c : '7SGDP';
            //header.ASI_CRM_SG_AR_Account_Type__c = header.ASI_CRM_SG_AR_Account_Type__c != null ? header.ASI_CRM_SG_AR_Account_Type__c : 
            //header.ASI_CRM_SG_MKT_Responsible__c = 
            header.ASI_CRM_SG_GDF_Country__c = header.ASI_CRM_SG_GDF_Country__c != null ? header.ASI_CRM_SG_GDF_Country__c : 'DM';
            header.ASI_CRM_SG_CCC_Location__c = header.ASI_CRM_SG_CCC_Location__c != null ? header.ASI_CRM_SG_CCC_Location__c : 'SG';
            //header.ASI_CRM_SG_Base_Price_Group_Bank_Name__c = header.ASI_CRM_SG_Base_Price_Group_Bank_Name__c != null ? header.ASI_CRM_SG_Base_Price_Group_Bank_Name__c : 
            header.ASI_CRM_SG_A_B_Amount_Codes__c = header.ASI_CRM_SG_A_B_Amount_Codes__c != null ? header.ASI_CRM_SG_A_B_Amount_Codes__c : 'SGD';
            header.ASI_CRM_SG_Statement_Cycle__c = header.ASI_CRM_SG_Statement_Cycle__c != null ? header.ASI_CRM_SG_Statement_Cycle__c : 'F';
            header.ASI_CRM_SG_Payment_Terms_A_R__c = header.ASI_CRM_SG_Payment_Terms_A_R__c != null ? header.ASI_CRM_SG_Payment_Terms_A_R__c : '0';
            header.ASI_CRM_SG_Tax_Rate_Area__c = header.ASI_CRM_SG_Tax_Rate_Area__c != null ? header.ASI_CRM_SG_Tax_Rate_Area__c : 'SG3';
            header.ASI_CRM_SG_Batch_Processing_Mode__c = header.ASI_CRM_SG_Batch_Processing_Mode__c != null ? header.ASI_CRM_SG_Batch_Processing_Mode__c : '.';
            header.ASI_CRM_Adjustment_Schedule__c = header.ASI_CRM_Adjustment_Schedule__c != null ? header.ASI_CRM_Adjustment_Schedule__c : 'FOC';
            header.ASI_CRM_Currency_Code__c = header.ASI_CRM_Currency_Code__c != null ? header.ASI_CRM_Currency_Code__c : 'SGD';
            header.ASI_CRM_SG_Tax_Expl_Code__c = header.ASI_CRM_SG_Tax_Expl_Code__c != null ? header.ASI_CRM_SG_Tax_Expl_Code__c : 'V';
        }
    }
    
    public PageReference save() {
        PageReference pageRef = new PageReference('/'+header.Id);
        
        //header.ASI_CRM_ToJDE__c = true;
        update header;
        
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    private List<sObject> queryAll(ID filterID, String sObjectName, String filteringField, String extraQuery) {
    
        List<sObject> sObjectList = new List<sObject>();
        Map<String , Schema.SObjectType> globalDescription = Schema.getGlobalDescribe();  
        Schema.sObjectType sObjType = globalDescription.get(sObjectName);  
        Schema.DescribeSObjectResult r1 = sObjType.getDescribe();  
        
        Map<String, Schema.SObjectField> sObjectFieldMap = r1.fields.getMap();
        String theQuery = 'Select ';
        
        for(String fields  : sObjectFieldMap.keySet()){
            theQuery += fields + ' ,';
        }
        thequery = theQuery.subString(0,theQuery.length()-1);
        thequery +=' From '+sObjectName+' where '+filteringField+' = \''+ filterID + '\' ' + extraQuery;
                
        sObjectList = Database.query(theQuery);
        
        return sObjectList;
    }

}