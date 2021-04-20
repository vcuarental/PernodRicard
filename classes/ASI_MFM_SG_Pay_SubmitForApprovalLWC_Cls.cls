public with sharing class ASI_MFM_SG_Pay_SubmitForApprovalLWC_Cls {
	//20201216:AM@introv - copy from button (Payment - ASI_MFM_PaymentSubmitController)
	
    @AuraEnabled
    public static InitParam getInitParam(Id PaymentID) {
        InitParam oParam = new InitParam();
        
        try
        {
            ASI_MFM_Payment__c p = [select id, ASI_MFM_Send_Approval_Email__c,ASI_MFM_Exchange_Rate__c,ASI_MFM_AP_Remark__c,ASI_MFM_KR_VAT_Amount__c,ASI_MFM_KR_TotalPayAmtIncludeVAT__c,ASI_MFM_Status__c,recordTypeId,RecordType.DeveloperName,ASI_MFM_Is_Direct_Payment__c,ASI_MFM_Plan__r.ASI_MFM_Project_Code__r.ASI_MFM_ByPass_Amount_Checking__c,
                                    ASI_MFM_Dummy_Payment__c,ASI_MFM_Plan__c,ASI_MFM_Plan__r.ASI_MFM_Owner_Email__c,ASI_MFM_Plan__r.ASI_MFM_KR_AnP_RollupAmount__c,ASI_MFM_Plan__r.ASI_MFM_Plan_Amount__c,ASI_MFM_Plan__r.ASI_MFM_Total_PO_Amount__c,
                                    ASI_MFM_Need_Attachment__c,ASI_MFM_Payment_Amount__c, ASI_MFM_Cash_Out_Payment__c from ASI_MFM_Payment__c where id = :PaymentID]; 
            
            if(p.RecordType.DeveloperName.contains('ASI_MFM_SG_Payment')) {
                // Check Attchment number
                Integer numAtts=0;
                //numAtts=[select count() from attachment where parentid =: p.id];
                Integer numOldAtts=0;
                Integer numNewAtts=0;
                numOldAtts=[select count() from attachment where parentid = :p.id];
                numNewAtts=[select count() from ContentDocumentLink where LinkedEntityId = :p.id];
                numAtts = numOldAtts + numNewAtts;

                if(numAtts> 0){ //Only If attchment number bigger than 0, it can submit
                    p.ASI_MFM_Send_Approval_Email__c=true;
                    update p;    //update Flag
                    //Submit for approval
                    Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                    req1.setObjectId(p.id);
                    if (!Test.isRunningTest()) { 
                    	Approval.ProcessResult result = Approval.process(req1);
                    }
                    //return new pageReference('/' + p.id);
                }else{
                    // If there is no attchment 
                    //apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'Attachment is needed before approval.'));
                    //return null;
                    oParam = new InitParam(true, 'Attachment is needed before approval.');
                }   
            }else{
                //return new pageReference('/' + p.id);
                oParam = new InitParam(true, 'Invaild record type.');
            }
            
        } catch(Exception ex)
        {
            oParam = new InitParam(true, 'Fail to initialize the parameters. Error:' + ex.getMessage());
        }
        
        return oParam;
    }
    
    public class InitParam {
        @AuraEnabled
        public boolean error {get; set;}
        
        @AuraEnabled
        public String errorMsg {get; set;}
        
        public InitParam() {
            this.error = false;
        }
        
        public InitParam(boolean error, String errorMsg) {
            this.error = error;
            this.errorMsg = errorMsg;
        }
    }
    
}