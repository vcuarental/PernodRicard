public class ASI_CRM_JP_ApprovalRejectionController {
  public String currentHeaderId {get;set;}
    
    public ASI_CRM_JP_ApprovalRejectionController() {
        
    }
    
    public ProcessInstanceStep getApprovalStep() {
      ProcessInstanceStep approvalStep = retrieveLatestApprovalStep(currentHeaderId);
        return approvalStep;
    }
    
    //Data Retrieve Function
    private ProcessInstanceStep retrieveLatestApprovalStep(String headerId) {
        String query = 'SELECT SystemModstamp, StepStatus, ProcessInstanceId ' + 
                       ', OriginalActorId, OriginalActor.Name '  + 
                       ', Comments, ActorId ' + 
                       'FROM ProcessInstanceStep ' + 
                       'WHERE ProcessInstance.TargetObjectId = :headerId ' + 
                       'ORDER BY SystemModstamp DESC ';
        List<ProcessInstanceStep> approvalStepList = (List<ProcessInstanceStep>) Database.query(query);
        return approvalStepList.size() == 0 ? null : approvalStepList.get(0);
  }
}