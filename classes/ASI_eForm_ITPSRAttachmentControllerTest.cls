@isTest
private class ASI_eForm_ITPSRAttachmentControllerTest
{
     @isTest
    public static void testITPSRAttachmentController()
    {
       User currentUser = ASI_eForm_TestClassHelper.createUser();
       Map<String,User> mapUser = new Map<String,User>();
       mapUser.put('owner',currentUser);
       
        ASI_eForm_IT_Procurement_Service_Request__c itpsr = ASI_eForm_TestClassHelper.createITPSRServiceRequest(mapUser);  
      ASI_eForm_TestClassHelper.createITPSRServiceRequestItem(itpsr);
       
      //ASI_eForm_TestClassHelper.createAttachment(itpsr.Id);
      ASI_eForm_TestClassHelper.createFormAttachment(itpsr.Id);
      ASI_eForm_TestClassHelper.createNote(itpsr.Id);
    
       ASI_eForm_ITPSRAttachmentController itpsrAttachmentController =
            new ASI_eForm_ITPSRAttachmentController();
            
      itpsrAttachmentController.currentHeaderId = itpsr.Id;     
      
      
      System.assert(itpsrAttachmentController.getCategories()!=null, 'Result Status:'+itpsrAttachmentController.getCategories());      
      //System.assert(itpsr.getRequest()!=null, 'Result Status:'+itpsr.getRequest());
      //System.assert(itpsr.getApprovalHistoryList()!=null, 'Result Status:'+itpsr.getApprovalHistoryList()); 
        
        
    }
}