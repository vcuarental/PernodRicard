@isTest
private class ASI_CRM_CN_EOL_Test {
    
    static testMethod void testFileAttachmentController()
    {
      User tempU = [select id from user where CompanyName = 'Pernod Ricard China' limit 1];
      
      ASI_CRM_EOL__c plan = new ASI_CRM_EOL__c(OwnerId = tempU.id, RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_EOL__cASI_CRM_CN_EOL'));
        
        insert plan;
        
      PageReference pageRef = Page.ASI_CRM_CN_EOL_ProductAttachPage;
        
      pageRef.getParameters().put('id', plan.Id);
        
      Test.setCurrentPage(pageRef);
        
      ApexPages.StandardController stdCon = new ApexPages.StandardController(plan);

      ASI_CRM_CN_EOL_FileAttachmentController fileAttachCon = new ASI_CRM_CN_EOL_FileAttachmentController();
      
      ASI_CRM_CN_EOL_FileAttachmentController fileAttachCon1 = new ASI_CRM_CN_EOL_FileAttachmentController(stdCon);
      
      Blob attachData = Blob.toPdf('Test');
      fileAttachCon.sObjParentId = plan.Id;
      fileAttachCon.attachmentObjType = 'ASI_Attachment__c';
      fileAttachCon.contentData = attachData;
      fileAttachCon.fileSize = attachData.size();
      fileAttachCon.contentFileName = 'Test.pdf';
      fileAttachCon.contentCategory = 'Others';
      fileAttachCon.isAttachInApproval  = false;
      //fileAttachCon.parentIdField = 'ASI_Product_End_of_Life_Request__c';
      //fileAttachCon.recordTypeName = 'ASI_CRM_CN_EOL';
      
      PageReference returnPage = fileAttachCon.uploadAction();

       
      String nextPage = fileAttachCon.cancel().getUrl();
      
      //Test for class properties
      Boolean hasCategoryField = fileAttachCon.hasCategoryField;
      Integer uploadStepCount = fileAttachCon.getUploadStepCount();
      List<SelectOption> categories = fileAttachCon.categories;
        
        //System.debug('Test Cancel return URL: ' + nextPage);
        //System.assertEquals(nextPage, '/' + npl.Id);        
    }

    static testMethod void testFileAttachmentControllerError()
    {
        
      ASI_MFM_Plan__c plan = ASI_MFM_CAP_TestClassHelper.createPlan();
        
      PageReference pageRef = Page.ASI_CRM_CN_EOL_ProductAttachPage;
        
      pageRef.getParameters().put('id', plan .Id);
        
      Test.setCurrentPage(pageRef);
        
      ApexPages.StandardController stdCon = new ApexPages.StandardController(plan);

      ASI_CRM_CN_EOL_FileAttachmentController fileAttachCon = new ASI_CRM_CN_EOL_FileAttachmentController();
        
      Blob attachData = Blob.toPdf('Test');
      fileAttachCon.sObjParentId = plan.Id;
      fileAttachCon.attachmentObjType = 'ASI_Attachment__c';
      fileAttachCon.contentData = attachData;
      fileAttachCon.fileSize = attachData.size();
      fileAttachCon.contentFileName = 'Test.pdf';
      fileAttachCon.contentCategory = 'Others';
      //fileAttachCon.isAttachInApproval  = false;
      
      PageReference returnPage = fileAttachCon.uploadAction();

    }
    
    static testMethod void testTriggerClassAndPDF(){
        
        User tempU = [select id from user where CompanyName = 'Pernod Ricard China' limit 1];
        
        ASI_CRM_EOL__c eol = new ASI_CRM_EOL__c(OwnerId = tempU.id
                                                , ASI_CRM_Status__c = 'Open'
                                                , recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_EOL__cASI_CRM_CN_EOL')
                                               );
        
        insert eol;
        update eol;
        
        ASI_CRM_CN_EOL_PDFController tmp = new ASI_CRM_CN_EOL_PDFController();
        tmp.strPDF = '';
        tmp.dummyVar = false;
        tmp.currentHeaderID = eol.id;
        tmp.getheader();
        tmp.init();
        
    }
}