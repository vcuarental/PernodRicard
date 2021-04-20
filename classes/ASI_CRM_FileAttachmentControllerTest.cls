@isTest
private class ASI_CRM_FileAttachmentControllerTest {	
    static testMethod void test_main() {
        ASI_MFM_SKU_Code__c sku = new ASI_MFM_SKU_Code__c(Name='Test', recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_SKU_Code__cASI_CRM_SG_SKU'));
        insert sku;
        
        Test.startTest();
        
        // Test file attachment
        Test.setCurrentPageReference(Page.ASI_CRM_ProductAttachPage);
        ASI_CRM_FileAttachmentController fileAttachCon = new ASI_CRM_FileAttachmentController();
        Blob attachData = Blob.toPdf('Test');
		fileAttachCon.sObjParentId = sku.Id;
		fileAttachCon.attachmentObjType = 'ASI_CRM_Product_Document__c';
		fileAttachCon.contentData = attachData;
		fileAttachCon.fileSize = ASI_CRM_FileAttachmentController.MAX_FILE_SIZE - 1;
		fileAttachCon.contentData = attachData;
		fileAttachCon.fileSize = attachData.size();
		fileAttachCon.contentFileName = 'Test.pdf';
		
		String testStr = fileAttachCon.attachmentObjLabel;
		List<SelectOption> testSelectOptions = fileAttachCon.categories;
		
		PageReference redirectPage = fileAttachCon.uploadAction();
							
		system.debug('redirectPage:' + redirectPage);
		
		redirectPage = fileAttachCon.cancel();
		
		Integer count = fileAttachCon.getUploadStepCount();
		
		//System.assertEquals(new PageReference('/' + sku.Id).getUrl(), redirectPage.getUrl());
		
		ASI_CRM_Product_Document__c skuDoc = [SELECT Id, ASI_CRM_FileId__c, (SELECT Id FROM Feeds) FROM ASI_CRM_Product_Document__c WHERE ASI_CRM_SKU__c = :sku.Id];
		System.assertEquals(1, skuDoc.Feeds.size());
		String contentVerId = skuDoc.ASI_CRM_FileId__c;
		
		List<ContentVersion> contentVerList = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :contentVerId];
		System.assertEquals(1, contentVerList.size());
		String contentDocId = contentVerList.get(0).ContentDocumentId;
		List<ContentDocument> contentDocList = [SELECT Id FROM ContentDocument WHERE Id = :contentDocId];
		System.assertEquals(1, contentVerList.size());
		
		// Test delete attachment
		delete skuDoc;
		contentDocList = [SELECT Id FROM ContentDocument WHERE Id = :contentDocId];
		System.assertEquals(1, contentDocList.size());
        
        Test.stopTest();
    }
}