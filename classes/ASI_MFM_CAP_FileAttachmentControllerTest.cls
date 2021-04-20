@isTest
private class ASI_MFM_CAP_FileAttachmentControllerTest
{
    @isTest
    public static void testFileAttachmentController()
    {
      
      ASI_MFM_Plan__c plan = ASI_MFM_CAP_TestClassHelper.createPlan();
        
      PageReference pageRef = Page.ASI_MFM_CAP_AttachmentPage;
        
      pageRef.getParameters().put('id', plan.Id);
        
      Test.setCurrentPage(pageRef);
        
      ApexPages.StandardController stdCon = new ApexPages.StandardController(plan);

      ASI_MFM_CAP_FileAttachmentController fileAttachCon = new ASI_MFM_CAP_FileAttachmentController();
      
      ASI_MFM_CAP_FileAttachmentController fileAttachCon1 = new ASI_MFM_CAP_FileAttachmentController(stdCon);
      
      Blob attachData = Blob.toPdf('Test');
      fileAttachCon.sObjParentId = plan.Id;
      fileAttachCon.attachmentObjType = 'ASI_MFM_CAP_Plan_Attachment__c';
      fileAttachCon.contentData = attachData;
      fileAttachCon.fileSize = attachData.size();
      fileAttachCon.contentFileName = 'Test.pdf';
      fileAttachCon.contentCategory = 'Others';
      fileAttachCon.isAttachInApproval  = false;
      fileAttachCon.parentIdField = 'ASI_MFM_Plan__c';
      fileAttachCon.recordTypeName = 'ASI_MFM_CAP_Plan';
      
      PageReference returnPage = fileAttachCon.uploadAction();

       
      String nextPage = fileAttachCon.cancel().getUrl();
      
      //Test for class properties
      Boolean hasCategoryField = fileAttachCon.hasCategoryField;
      Integer uploadStepCount = fileAttachCon.getUploadStepCount();
      List<SelectOption> categories = fileAttachCon.categories;
      Boolean hasPlanLineItems = fileAttachCon.hasPlanLineItems;
      List<SelectOption> planLineItemOptions = fileAttachCon.planLineItemOptions;
        
        //System.debug('Test Cancel return URL: ' + nextPage);
        //System.assertEquals(nextPage, '/' + npl.Id);        
    }
    
    @isTest
    public static void testFileAttachmentControllerError()
    {
        
      ASI_MFM_Plan__c plan = ASI_MFM_CAP_TestClassHelper.createPlan();
        
      PageReference pageRef = Page.ASI_MFM_CAP_AttachmentPage;
        
      pageRef.getParameters().put('id', plan .Id);
        
      Test.setCurrentPage(pageRef);
        
      ApexPages.StandardController stdCon = new ApexPages.StandardController(plan);

      ASI_MFM_CAP_FileAttachmentController fileAttachCon = new ASI_MFM_CAP_FileAttachmentController();
        
      Blob attachData = Blob.toPdf('Test');
      fileAttachCon.sObjParentId = plan.Id;
      fileAttachCon.attachmentObjType = 'ASI_MFM_CAP_Plan_Attachment__c';
      fileAttachCon.contentData = attachData;
      fileAttachCon.fileSize = attachData.size();
      fileAttachCon.contentFileName = 'Test.pdf';
      fileAttachCon.contentCategory = 'Others';
      //fileAttachCon.isAttachInApproval  = false;
      
      PageReference returnPage = fileAttachCon.uploadAction();

       
    }

}