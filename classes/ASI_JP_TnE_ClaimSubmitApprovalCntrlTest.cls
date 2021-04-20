@isTest
private class ASI_JP_TnE_ClaimSubmitApprovalCntrlTest   
{

    @isTest
    public static void testClaimSubmitApprovalController()
    {
        ASI_HK_CRM_Running_Number__c runnNumber = new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c = 'ASI_JP_TnE_Document_Number', 
                                                                                   ASI_HK_CRM_Format__c = '{YY}{MM}{000}', 
                                                                                   ASI_HK_CRM_Running_Number__c = 0);
        insert runnNumber;
    
        //ASI_JP_TnE_TestClassHelper.createUser(); 
        ASI_JP_TnE_TestClassHelper.createDueDateMapping();   
        ASI_TnE_ClaimHeader__c  claimHeader = ASI_JP_TnE_TestClassHelper.createClaimHeaderPaperRecordType();
        
        
           List<ASI_JP_TnE_Role_eApproval_Settings__c>  eApprovalRoles =
        [Select Id, ASI_JP_TnE_Role_API__c from ASI_JP_TnE_Role_eApproval_Settings__c];
        
        System.debug('XXXX Approval Test Class: ' + eApprovalRoles);
        
        ApexPages.StandardController standardController = new ApexPages.StandardController(claimHeader);
        ASI_JP_TnE_ClaimSubmitApprovalController claimSubmitApprovalController = 
          new ASI_JP_TnE_ClaimSubmitApprovalController(standardController);
    
       claimSubmitApprovalController.submitForApproval();   
              
       ASI_JP_TnE_TestClassHelper.createClaimDetails(claimHeader);
       
       claimSubmitApprovalController.submitForApproval();   
       
       RecordType eApprovalRecordType = [SELECT Id from RecordType where DeveloperName = 
        'ASI_JP_TnE_eApproval_Claim_Header' LIMIT 1 ];
        
       claimHeader.RecordTypeId = eApprovalRecordType.Id;
       update claimHeader;
       
       claimSubmitApprovalController.submitForApproval();   
            
    } 

}