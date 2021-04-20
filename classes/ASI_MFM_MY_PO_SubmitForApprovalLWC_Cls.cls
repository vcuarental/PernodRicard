public with sharing class ASI_MFM_MY_PO_SubmitForApprovalLWC_Cls {
	//20201103:AM@introv - copy from button (PO - ASI_MFM_POSubmitController)

    @AuraEnabled
    public static InitParam getInitParam(Id POID) {
        InitParam oParam = new InitParam();
        
        try
        {
            ASI_MFM_PO__c p = [select id,ASI_MFM_Submit_for_Approval__c,recordTypeId,RecordType.DeveloperName,ASI_MFM_PO_Amount__c,ASI_MFM_Base_Currency_Amount__c from ASI_MFM_PO__c where id = :POID];
            
            if(p.RecordType.DeveloperName.contains('ASI_MFM_MY_PO')) {
                Integer numAtts=0;
                Integer numOldAtts=0;
                Integer numNewAtts=0;
                numOldAtts=[select count() from attachment where parentid = :p.id];
                numNewAtts=[select count() from ContentDocumentLink where LinkedEntityId = :p.id];
                numAtts = numOldAtts + numNewAtts;
                
                if(p.ASI_MFM_Base_Currency_Amount__c>0){  // || p.ASI_MFM_PO_Amount__c>0
                    if(p.ASI_MFM_Base_Currency_Amount__c>50000){
                        if(numAtts>3){
                            //Approvalprocess();
                            //return new pageReference('/' + p.id);
                            SubmitApprovalProcess(p);
                        }else{
                            //if(!Test.isRunningTest()){ 
                            //    apexpages.addMessage(new apexpages.Message(apexpages.severity.error, '4 Attachments are needed before approval.'));
                            //}
                            //return null;
                            oParam = new InitParam(true, '4 Attachments are needed before approval.');
                        }
                    }else if(p.ASI_MFM_Base_Currency_Amount__c>10000 && p.ASI_MFM_Base_Currency_Amount__c<50000){
                        if(numAtts>1){
                            //Approvalprocess();
                            //return new pageReference('/' + p.id);
                            SubmitApprovalProcess(p);
                        }else{
                            //if(!Test.isRunningTest()){ 
                            //    apexpages.addMessage(new apexpages.Message(apexpages.severity.error, '2 Attachments are needed before approval.'));
                            //}
                            //return null;
                            oParam = new InitParam(true, '2 Attachments are needed before approval.');
                        }
                    }else{
                        //Approvalprocess();
                        //return new pageReference('/' + p.id);
                        SubmitApprovalProcess(p);
                    }
                    
                }else{
                    //apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'PO Amount has to be larger than zero'));
                    //return null;
                    oParam = new InitParam(true, 'PO Amount has to be larger than zero.');
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
    
    private static void SubmitApprovalProcess(ASI_MFM_PO__c oPO) {
        oPO.ASI_MFM_Submit_for_Approval__c = true;
        update oPO;
        
        Approval.ProcessSubmitRequest oReq = new Approval.ProcessSubmitRequest();
        oReq.setObjectId(oPO.id);
        if (!Test.isRunningTest()) { 
            Approval.ProcessResult oResult = Approval.process(oReq);
        }
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