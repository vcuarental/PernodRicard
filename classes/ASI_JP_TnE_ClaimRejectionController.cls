public with sharing class ASI_JP_TnE_ClaimRejectionController {

 public String currentHeaderId {get;set;}
 public ProcessInstanceStep processStep {get;set;}
 private ASI_TnE_ClaimHeader__c relatedTo;
 
 public ASI_JP_TnE_ClaimRejectionController()
 {
                
 }   
 
  public ProcessInstanceStep getApprovalSteps() {
      if (currentHeaderId != null && processStep == null) {
        List<ProcessInstanceStep>  processSteps = [Select SystemModstamp, StepStatus, ProcessInstanceId, OriginalActorId,OriginalActor.Name,
        Comments, ActorId From ProcessInstanceStep where ProcessInstance.TargetObjectId=:currentHeaderId
        order by SystemModstamp desc LIMIT 1];  
        
        if (processSteps!= null && processSteps.size() > 0)
        {
            processStep =  processSteps[0];        
        }        
      }
      return processStep ;
    }
    
 public ASI_TnE_ClaimHeader__c getRelatedTo()
 {
              if (relatedTo == null && currentHeaderId != null  ) {
                 relatedTo = [SELECT ASI_TnE_Date__c, Name, ASI_TnE_Document_No__c,
                 ASI_TnE_Cover_Period_From__c, ASI_TnE_Cover_Period_To__c,
                 ASI_TnE_Remarks__c,ASI_TnE_Total_Amount__c,ASI_TnE_Currency__c, CreatedBy.name,
                 Owner.Name, OwnerId, ASI_TnE_Payment_Date__c,ASI_TnE_Submission_Date__c
                 from ASI_TnE_ClaimHeader__c where Id = :currentHeaderId];  
                        
             }   
             return relatedTo;
  } 
     
}