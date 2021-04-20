@isTest
private class ASI_JP_TnE_ClaimHeaderPDFControllerTest
{
    
    @isTest
    public static void testClaimHeaderPDFController()
    {
    
        ASI_HK_CRM_Running_Number__c runnNumber = new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c = 'ASI_JP_TnE_Document_Number', 
                                                                                   ASI_HK_CRM_Format__c = '{YY}{MM}{000}', 
                                                                                   ASI_HK_CRM_Running_Number__c = 0);
        insert runnNumber;
        
        ASI_JP_TnE_TestClassHelper.createDueDateMapping();   
        ASI_TnE_ClaimHeader__c  claimHeader = ASI_JP_TnE_TestClassHelper.createClaimHeaderPaperRecordType();    
        List<ASI_TnE_ClaimDetail__c> claimDetails = ASI_JP_TnE_TestClassHelper.createClaimDetails(claimHeader);
        
        ASI_JP_TnE_ClaimHeaderPDFController claimHeaderPDFController =
            new ASI_JP_TnE_ClaimHeaderPDFController();
            
        claimHeaderPDFController.currentHeaderId = claimHeader.Id;
        claimHeaderPDFController.currentAction = 'finalPrint';
        
        System.assert(claimHeaderPDFController.getAggregatedCategoryExpenses()!=null,'Error: null result');
        System.assert(claimHeaderPDFController.getClaimDetails()!=null,'Error: null result');
        System.assert(claimHeaderPDFController.getHeader()!=null,'Error: null result');    
        System.assert(claimHeaderPDFController.getCurrentUser()!=null,'Error: null result'); 
        System.assert(claimHeaderPDFController.getIsFinalPrint()==true,'Error: not final print');    
        System.assert(claimHeaderPDFController.getIseApprovedPrint()==false,'Error: must be final print');    
    
    }
}