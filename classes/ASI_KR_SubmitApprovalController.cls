public class ASI_KR_SubmitApprovalController {
    public ASI_KR_SubmitApprovalController(){
        
    }
    
    public PageReference submit(){
        string id = apexpages.currentpage().getparameters().get('id');
        
        if(id!=null && id!=''){
            try {
                Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                req1.setObjectId(id);
                req1.setSubmitterId(UserInfo.getUserId());
                Approval.ProcessResult result = Approval.process(req1);
                
                if (!result.isSuccess()){
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Record failed to submit for approval.');
                    ApexPages.addMessage(myMsg);
                    return null;
                }
            }
            catch (System.DmlException e){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getDmlMessage(0));
                ApexPages.addMessage(myMsg);
                return null;
            }
        }
        
        PageReference pageRef = new PageReference('/'+id);
        return pageRef;
    }
}