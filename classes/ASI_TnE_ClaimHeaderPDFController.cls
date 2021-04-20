public without sharing class ASI_TnE_ClaimHeaderPDFController {
        private ASI_TnE_ClaimHeader__c header;
        private ASI_TnE_ClaimHeader__c headerAllowance;
        public List<ASI_TnE_ClaimDetail__c> claimDetails {get;set;}        
        public Decimal monthlyAllowance {get;set;}
        public Decimal entainTotal{get;set;}
        public Decimal percentageUsed {get;set;}
        public Decimal aboveBelowAllowance {get;set;}
                
        public ASI_TnE_ClaimHeaderPDFController (ApexPages.StandardController stdController){
            this.header = (ASI_TnE_ClaimHeader__c)stdController.getRecord();
            claimDetails = [SELECT ASI_TnE_Date__c, ASI_TnE_Destination__c, ASI_TnE_Description__c, ASI_TnE_Details_of_Expense__c, ASI_TnE_Expense_Type__c, ASI_TnE_Total_Number_Pax__c,
                ASI_TnE_Exchange_Rate_to_VND__c, ASI_TnE_Currency__c, ASI_TnE_VAT__c, ASI_TnE_Amount__c, ASI_TnE_Total_Expense__c
                    FROM ASI_TnE_ClaimDetail__c WHERE ASI_TnE_ClaimHeader__c = :header.id];
         
             headerAllowance = [select ASI_TnE_Monthly_Allowance__c, ASI_TnE_Local_Ent_Meeting_Total__c, ASI_TnE_Monthly_Allowance_Used_Percent__c from ASI_TnE_ClaimHeader__c  where id = :header.id LIMIT 1];
             
            monthlyAllowance = headerAllowance.ASI_TnE_Monthly_Allowance__c;
            entainTotal = headerAllowance.ASI_TnE_Local_Ent_Meeting_Total__c;
            percentageUsed = headerAllowance.ASI_TnE_Monthly_Allowance_Used_Percent__c;
            aboveBelowAllowance = entainTotal - monthlyAllowance;
        }
}