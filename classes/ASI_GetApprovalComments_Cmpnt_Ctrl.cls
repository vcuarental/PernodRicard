public with sharing class ASI_GetApprovalComments_Cmpnt_Ctrl {    

    public String objIds {get;set;}
    public ProcessInstanceStep pStep{get;set;}
    
    public ProcessInstanceStep getApprovalSteps() {

      if (objIds != null) {
        pStep = [Select SystemModstamp, StepStatus, ProcessInstanceId, OriginalActorId,OriginalActor.Name,
        Comments, ActorId From ProcessInstanceStep where ProcessInstance.TargetObjectId=:objIds order by SystemModstamp desc Limit 1]; 
         
      }
      return pStep ;
    }
}