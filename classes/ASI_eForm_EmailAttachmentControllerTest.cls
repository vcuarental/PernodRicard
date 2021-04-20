@isTest
private class ASI_eForm_EmailAttachmentControllerTest
{
     @isTest
    public static void testEmailAttachmentController()
    {
       User currentUser = ASI_eForm_TestClassHelper.createUser();
       Map<String,User> mapUser = new Map<String,User>();
       mapUser.put('owner',currentUser);
       
        ASI_eForm_IT_Procurement_Service_Request__c itpsr = ASI_eForm_TestClassHelper.createITPSRServiceRequest(mapUser);  
      ASI_eForm_TestClassHelper.createITPSRServiceRequestItem(itpsr);
       
      //ASI_eForm_TestClassHelper.createAttachment(itpsr.Id);
      ASI_eForm_TestClassHelper.createFormAttachment(itpsr.Id);
      ASI_eForm_TestClassHelper.createNote(itpsr.Id);
    
       ASI_eForm_EmailAttachmentController emailAttachmentController =
            new ASI_eForm_EmailAttachmentController();
            
      emailAttachmentController.currentHeaderId = itpsr.Id;     
      
      
      System.assert(emailAttachmentController.getCategories()!=null, 'Result Status:'+emailAttachmentController.getCategories());      
      //System.assert(itpsr.getRequest()!=null, 'Result Status:'+itpsr.getRequest());
      //System.assert(itpsr.getApprovalHistoryList()!=null, 'Result Status:'+itpsr.getApprovalHistoryList()); 
        
        
    }
    
     @isTest
    public static void testEmailAttachmentControllerITC()
    {
        ASI_eForm_TestClassHelper.createRunningNumbers();
       User currentUser = ASI_eForm_TestClassHelper.createUser();
       Map<String,User> mapUser = new Map<String,User>();
       mapUser.put('owner',currentUser);
       
        ASI_eForm_IT_Change_Request__c itcr = ASI_eForm_TestClassHelper.createITChangeRequest(mapUser);  
      ASI_eForm_TestClassHelper.createITChangeRequestItems(itcr , mapUser);
       
      //ASI_eForm_TestClassHelper.createAttachment(itpsr.Id);
      ASI_eForm_TestClassHelper.createFormAttachmentITCR(itcr.Id);
      ASI_eForm_TestClassHelper.createNote(itcr.Id);
    
       ASI_eForm_EmailAttachmentController emailAttachmentController =
            new ASI_eForm_EmailAttachmentController();
            
      emailAttachmentController.currentHeaderId = itcr.Id;     
      
      
      System.assert(emailAttachmentController.getCategoriesITCR()!=null, 'Result Status:'+emailAttachmentController.getCategoriesITCR());      
      //System.assert(itpsr.getRequest()!=null, 'Result Status:'+itpsr.getRequest());
      //System.assert(itpsr.getApprovalHistoryList()!=null, 'Result Status:'+itpsr.getApprovalHistoryList()); 
        
        
    }
}