@isTest
private class ASI_KOR_BrandAttachTest {
	
	private static ASI_KOR_BrandGenerator brandGen = new ASI_KOR_BrandGenerator();
	
    static testMethod void test_main() {
        ASI_KOR_Brand__c brand = brandGen.generateBrand();
        insert brand;
        
        Test.startTest();
        
        // Test file attachment
        Test.setCurrentPageReference(Page.ASI_KOR_BrandAttachPage);
        ASI_KOR_FileAttachmentController fileAttachCon = new ASI_KOR_FileAttachmentController();
        Blob attachData = Blob.toPdf('Test');
		fileAttachCon.sObjParentId = brand.Id;
		fileAttachCon.attachmentObjType = 'ASI_KOR_Brand_Document__c';
		fileAttachCon.contentData = attachData;
		fileAttachCon.fileSize = ASI_KOR_FileAttachmentController.MAX_FILE_SIZE + 1;
		
		String testStr = fileAttachCon.attachmentObjLabel;
		List<SelectOption> testSelectOptions = fileAttachCon.categories;
		
		PageReference redirectPage = fileAttachCon.uploadAction();
		System.assertEquals(null, redirectPage);
		
		fileAttachCon.contentData = attachData;
		fileAttachCon.fileSize = attachData.size();
		redirectPage = fileAttachCon.uploadAction();
		System.assertEquals(null, redirectPage);
		
		fileAttachCon.contentData = attachData;
		fileAttachCon.contentFileName = 'Test.pdf';
		redirectPage = fileAttachCon.uploadAction();
		System.assertEquals(new PageReference('/' + brand.Id).getUrl(), redirectPage.getUrl());
		
		ASI_KOR_Brand_Document__c brandDoc = [SELECT Id, ASI_KOR_FileId__c, (SELECT Id FROM Feeds) FROM ASI_KOR_Brand_Document__c WHERE ASI_KOR_Parent__c = :brand.Id];
		System.assertEquals(1, brandDoc.Feeds.size());
		String contentVerId = brandDoc.ASI_KOR_FileId__c;
		
		List<ContentVersion> contentVerList = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :contentVerId];
		System.assertEquals(1, contentVerList.size());
		String contentDocId = contentVerList.get(0).ContentDocumentId;
		List<ContentDocument> contentDocList = [SELECT Id FROM ContentDocument WHERE Id = :contentDocId];
		System.assertEquals(1, contentVerList.size());
		
		// Test delete attachment
		delete brandDoc;
		contentDocList = [SELECT Id FROM ContentDocument WHERE Id = :contentDocId];
		System.assertEquals(0, contentDocList.size());
        
        Test.stopTest();
    }
}