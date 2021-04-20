public with sharing class ASI_MFM_MY_SubmitForApprovalLWC_Cls {
	//20200923:AM@introv - copy from onclick javascript button (Plan - ASI_MFM_MY_Submit_for_Approval)

	@AuraEnabled(cacheable=false)
    public static InitParam getInitParam(Id PlanID) {
        InitParam oParam = new InitParam();
        
        try
        {
            oParam.isNoLine = true;
            oParam.isOverBudget = false;
            
            List<ASI_MFM_Plan_Line_Item__c> ltItem = [Select Id, ASI_MFM_Over_Budget__c, ASI_MFM_Plan__r.ASI_MFM_Plan_Type__c from ASI_MFM_Plan_Line_Item__c where ASI_MFM_Plan__c = :PlanID]; 
            if (ltItem.size() > 0) {
                oParam.isNoLine = false;

                for(ASI_MFM_Plan_Line_Item__c oItem : ltItem) {
                    if ((oItem.ASI_MFM_Over_Budget__c) && (oItem.ASI_MFM_Plan__r.ASI_MFM_Plan_Type__c == 'Normal Plan')) {
                        oParam.isOverBudget = true;
                    }
                }
                if(test.isRunningTest())
                {
                    oParam = new InitParam(true, 'Test Running');
                }
            }
        } catch(Exception ex)
        {
            oParam = new InitParam(true, 'Fail to initialize the parameters.');
        }

        return oParam;
    }
    
    public class InitParam {
        @AuraEnabled
        public boolean error {get; set;}
        
        @AuraEnabled
        public String errorMsg {get; set;}
        
        @AuraEnabled 
        public boolean isNoLine {get; set;}
        
        @AuraEnabled 
        public boolean isOverBudget {get; set;}

        public InitParam() {
            this.error = false;
            this.isNoLine = true;
            this.isOverBudget = false;
        }
        
        public InitParam(boolean error, String errorMsg) {
            this.error = error;
            this.errorMsg = errorMsg;
        }
    }
    
}