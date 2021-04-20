@isTest
private class ASI_JP_TnE_ClaimRejectionControllerTest
{
    @isTest
    public static void testClaimRejectionController()
    {
    
        ASI_HK_CRM_Running_Number__c runnNumber = new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c = 'ASI_JP_TnE_Document_Number', 
                                                                                   ASI_HK_CRM_Format__c = '{YY}{MM}{000}', 
                                                                                   ASI_HK_CRM_Running_Number__c = 0);
        insert runnNumber;
        
        ASI_JP_TnE_TestClassHelper.createDueDateMapping();   
        ASI_TnE_ClaimHeader__c  claimHeader = ASI_JP_TnE_TestClassHelper.createClaimHeaderPaperRecordType();    
        List<ASI_TnE_ClaimDetail__c> claimDetails = ASI_JP_TnE_TestClassHelper.createClaimDetails(claimHeader);
        
        ASI_JP_TnE_ClaimRejectionController claimRejectionController = new ASI_JP_TnE_ClaimRejectionController();
        claimRejectionController.currentHeaderId = claimHeader.Id;
        
        List<Approval.ProcessSubmitRequest> approvalReqList=new List<Approval.ProcessSubmitRequest>();
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();   
        req.setComments('Submitted for approval. Please approve.');
        req.setObjectId(claimHeader.Id);
        approvalReqList.add(req);     
        //List<Approval.ProcessResult> resultList = Approval.process(approvalReqList);    
        
        
        System.assert(claimRejectionController.getRelatedTo()!=null,'Not null');
        //System.assert(claimRejectionController.getApprovalSteps()!=null,'Not null');     
        
    
    }

}