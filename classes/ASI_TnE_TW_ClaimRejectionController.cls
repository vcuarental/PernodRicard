public with sharing class ASI_TnE_TW_ClaimRejectionController {
 public String currentHeaderId {get;set;}
 public ProcessInstanceStep processStep {get;set;}
 private ASI_TnE_ClaimHeader__c relatedTo;
 
 public ASI_TnE_TW_ClaimRejectionController()
 {
                
 }   
 
  public String getUserName() {
        return UserInfo.getName();
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
                 relatedTo = [SELECT ASI_TnE_Date__c, Name, ASI_TnE_Document_No__c, ASI_TnE_Start_Date__c, ASI_TnE_Company__c, recordtype.developername,
                 ASI_TnE_Department_Division__c, ASI_TnE_Business_Unit__c, ASI_TnE_Payee_Employee__r.Name, ASI_TnE_Total_Amount_LCY__c, ASI_TnE_Finance_Remarks__c,
                 ASI_TnE_Remarks__c,ASI_TnE_TW_Total_Amount__c,ASI_TnE_Currency__c, CreatedBy.name, ASI_TnE_End_Date__c,
                 Owner.Name, OwnerId, ASI_TnE_Payment_Date__c,ASI_TnE_Submission_Date__c, ASI_TnE_Type__c
                 from ASI_TnE_ClaimHeader__c where Id = :currentHeaderId];  
                        
             }   
             return relatedTo;
  } 
     
}