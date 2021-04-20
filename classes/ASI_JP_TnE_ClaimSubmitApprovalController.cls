public with sharing class ASI_JP_TnE_ClaimSubmitApprovalController {
  ASI_TnE_ClaimHeader__c claimHeader = null;
  
  public ASI_JP_TnE_ClaimSubmitApprovalController(ApexPages.StandardController sc) {
    claimHeader = (ASI_TnE_ClaimHeader__c)sc.getRecord();
  }
  
  public PageReference submitForApproval() {
   
      List<ASI_TnE_ClaimDetail__c> claimDetails = [Select Id from ASI_TnE_ClaimDetail__c
      where ASI_TnE_ClaimHeader__c = :claimHeader.Id];
      
     RecordType currentRecordType = [SELECT Id, Name, DeveloperName from RecordType Where ID = :claimHeader.RecordTypeId];
     User currentOwner = [SELECT Id, Name, UserRole.DeveloperName from User WHERE Id = :claimHeader.OwnerId];
      
     List<ASI_JP_TnE_Role_eApproval_Settings__c>  eApprovalRoles =
        [Select Id, ASI_JP_TnE_Role_API__c from ASI_JP_TnE_Role_eApproval_Settings__c];
        
        Set<String> eApprovalRoleSet = new Set<String>();
        
        for(ASI_JP_TnE_Role_eApproval_Settings__c eApprovalRole : eApprovalRoles )
        {
           eApprovalRoleSet.add(eApprovalRole.ASI_JP_TnE_Role_API__c);            
        }
              
        if (currentRecordType.DeveloperName == ASI_JP_TnE_ClaimHeaderTriggerClass.eAPPROVAL_RECORD_TYPE 
              && !eApprovalRoleSet.contains(currentOwner.UserRole.DeveloperName) || 
           currentRecordType.DeveloperName == ASI_JP_TnE_ClaimHeaderTriggerClass.PAPER_APPROVAL_RECORD_TYPE 
           && eApprovalRoleSet.contains(currentOwner.UserRole.DeveloperName))           
     {
              
       ApexPages.Message errorMessage = 
       new ApexPages.Message(ApexPages.Severity.ERROR,String.format(Label.ASI_JP_TnE_Owner_Not_Eligible_for_Record_Type,
              new String[]{currentOwner.Name,currentRecordType.Name}));
       ApexPages.addMessage(errorMessage);      
       return null;
      
      } else if (claimDetails != null && claimDetails.size() >0)
      {    
       return new pageReference('/apex/ASI_SubmitApprovalPage?id=' + claimHeader.id);    
      } else
      {
       ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR,Label.ASI_JP_TnE_Invalid_Claims_No_Claim_Details);
       ApexPages.addMessage(errorMessage);      
       return null;
      }
      
  }
}