public without sharing class ASI_TnE_MonthlyAllowanceController {
        public ASI_TnE_ClaimHeader__c header {get;set;}
        public ID headerID {get;set;}
        public Decimal monthlyAllowance {get;set;}
        public Decimal entainTotal{get;set;}
        public Decimal percentageUsed {get;set;}
                
        public ASI_TnE_MonthlyAllowanceController (ApexPages.StandardController stdController){
            this.headerID = stdController.getId();            
            
            header = [select ASI_TnE_Monthly_Allowance__c, ASI_TnE_Local_Ent_Meeting_Total__c, ASI_TnE_Monthly_Allowance_Used_Percent__c from ASI_TnE_ClaimHeader__c  where id = :headerID LIMIT 1];
            
            monthlyAllowance = header.ASI_TnE_Monthly_Allowance__c;
            entainTotal = header.ASI_TnE_Local_Ent_Meeting_Total__c;
            percentageUsed = header.ASI_TnE_Monthly_Allowance_Used_Percent__c;
        }
}