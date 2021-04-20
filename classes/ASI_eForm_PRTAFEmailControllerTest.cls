@isTest
private class ASI_eForm_PRTAFEmailControllerTest
{
    
    @isTest(SeeAllData=true)
    public static void testPreTripEmailController()
    {
        User currentUser = ASI_eForm_TestClassHelper.createUser();
        Map<String,User> userMap = new Map<String,User>();
        userMap.put('owner',currentUser);
        
        ASI_eForm_Pre_Trip_Approval__c preTripApproval = ASI_eForm_TestClassHelper.createPreTripApproval(userMap);
        ASI_eForm_TestClassHelper.createAttachment(preTripApproval.Id);
        ASI_eForm_TestClassHelper.createNote(preTripApproval.Id);
        
        ASI_eForm_TestClassHelper.createPreTripApprovalItems(preTripApproval);  
                
        //ASI_eForm_TestClassHelper.executeApprovalProcess(preTripApproval.Id);
        
        ASI_eForm_TestClassHelper.createAttachment(preTripApproval.Id);
        ASI_eForm_TestClassHelper.createNote(preTripApproval.Id);
        
        ASI_eForm_PRTAFEmailController preTripApprovalController = new ASI_eForm_PRTAFEmailController();
        preTripApprovalController.request_Id = preTripApproval.Id;
        
        System.assert(preTripApprovalController.getItems()!=null, 'Result Status:'+preTripApprovalController.getItems());      
        System.assert(preTripApprovalController.getRequest()!=null, 'Result Status:'+preTripApprovalController.getRequest());
        System.assert(preTripApprovalController.getApprovalHistoryList()!=null, 'Result Status:'+preTripApprovalController.getApprovalHistoryList()); 
        System.assert(preTripApprovalController.getNoteAndAttachments()!=null, 'Result Status:'+preTripApprovalController.getNoteAndAttachments());
        
        
    }




}