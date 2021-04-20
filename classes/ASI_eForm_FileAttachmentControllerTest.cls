@isTest
private class ASI_eForm_FileAttachmentControllerTest
{
    @isTest
    public static void testFileAttachmentController()
    {
        
      User currentUser = ASI_eForm_TestClassHelper.createUser();
      Map<String,User> userMap = new Map<String,User>();
      userMap.put('owner',currentUser);
      
      ASI_eForm_IT_Procurement_Service_Request__c itpsr = 
       ASI_eForm_TestClassHelper.createITPSRServiceRequest(userMap);
        
      PageReference pageRef = Page.ASI_eForm_AttachmentPage;
        
      pageRef.getParameters().put('id', itpsr.Id);
        
      Test.setCurrentPage(pageRef);
        
      ApexPages.StandardController stdCon = new ApexPages.StandardController(itpsr);

      ASI_eForm_FileAttachmentController fileAttachCon = new ASI_eForm_FileAttachmentController();
        
      Blob attachData = Blob.toPdf('Test');
      fileAttachCon.sObjParentId = itpsr.Id;
      fileAttachCon.attachmentObjType = 'ASI_eForm_ITPSR_Attachment__c';
      fileAttachCon.contentData = attachData;
      fileAttachCon.fileSize = attachData.size();
      fileAttachCon.contentFileName = 'Test.pdf';
      fileAttachCon.contentCategory = 'Others';
      fileAttachCon.isAttachInApproval  = false;
      fileAttachCon.parentIdField = 'ASI_eForm_IT_Procurement_Service_Request__c';
      fileAttachCon.recordTypeName = 'ASI_eForm_IT_Service_Request_Attachment';
      
      PageReference returnPage = fileAttachCon.uploadAction();

       
      String nextPage = fileAttachCon.cancel().getUrl();
      
      //Test for class properties
      Boolean hasCategoryField = fileAttachCon.hasCategoryField;
      Integer uploadStepCount = fileAttachCon.getUploadStepCount();
      List<SelectOption> categories = fileAttachCon.categories;
        
        //System.debug('Test Cancel return URL: ' + nextPage);
        //System.assertEquals(nextPage, '/' + npl.Id);        
    }
    
    @isTest
    public static void testFileAttachmentControllerError()
    {
        
      User currentUser = ASI_eForm_TestClassHelper.createUser();
      Map<String,User> userMap = new Map<String,User>();
      userMap.put('owner',currentUser);
      
      ASI_eForm_IT_Procurement_Service_Request__c itpsr = 
       ASI_eForm_TestClassHelper.createITPSRServiceRequest(userMap);
        
      PageReference pageRef = Page.ASI_eForm_AttachmentPage;
        
      pageRef.getParameters().put('id', itpsr.Id);
        
      Test.setCurrentPage(pageRef);
        
      ApexPages.StandardController stdCon = new ApexPages.StandardController(itpsr);

      ASI_eForm_FileAttachmentController fileAttachCon = new ASI_eForm_FileAttachmentController();
        
      Blob attachData = Blob.toPdf('Test');
      fileAttachCon.sObjParentId = itpsr.Id;
      fileAttachCon.attachmentObjType = 'ASI_eForm_ITPSR_Attachment__c';
      fileAttachCon.contentData = attachData;
      fileAttachCon.fileSize = attachData.size();
      fileAttachCon.contentFileName = 'Test.pdf';
      fileAttachCon.contentCategory = 'Others';
      //fileAttachCon.isAttachInApproval  = false;
      
      PageReference returnPage = fileAttachCon.uploadAction();

       
    }

}