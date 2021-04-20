@isTest
private class ASI_KOR_AttachDeleteTest {

	private static Account acct;
	private static Contact ct;
	private static ASI_KOR_Brand__c brand;
	private static ASI_KOR_Sub_Brand__c sb;
	private static ASI_KOR_Item_Group__c itemGroup;
	private static ASI_KOR_GMA__c gma;

    static testMethod void test_main() {
        initRecords();
        
        Test.startTest();
        
        testDeleteForDocObj(acct.Id, 'ASI_KOR_Account_Document__c');
        testDeleteForDocObj(ct.Id, 'ASI_KOR_Contact_Document__c');
        testDeleteForDocObj(brand.Id, 'ASI_KOR_Brand_Document__c');
        testDeleteForDocObj(sb.Id, 'ASI_KOR_Product_Document__c');
        testDeleteForDocObj(itemGroup.Id, 'ASI_KOR_Item_Group_Document__c');
        testDeleteForDocObj(gma.Id, 'ASI_KOR_GMA_Image__c');
        
        Test.stopTest();
    }
    
    static void testDeleteForDocObj(ID parentId, String docObjAPIName) {
    	Test.setCurrentPageReference(Page.ASI_KOR_BrandAttachPage);
        ASI_KOR_FileAttachmentController fileAttachCon = new ASI_KOR_FileAttachmentController();
        Blob attachData = Blob.toPdf('Test');
		fileAttachCon.sObjParentId = parentId;
		fileAttachCon.attachmentObjType = docObjAPIName;
		fileAttachCon.contentData = attachData;
		fileAttachCon.fileSize = attachData.size();
		fileAttachCon.contentFileName = 'Test.pdf';
		
		PageReference redirectPage = fileAttachCon.uploadAction();
		System.assertEquals(new PageReference('/' + parentId).getUrl(), redirectPage.getUrl());
		
		List<sObject> docRecords = database.query('SELECT Id, (SELECT Id FROM Feeds) FROM ' + docObjAPIName + ' WHERE ASI_KOR_Parent__c = :parentId');
		List<sObject> feeds = docRecords.get(0).getSObjects('Feeds');
		System.assertEquals(1, feeds.size());
		delete docRecords;
		List<ID> feedItemIds = new List<ID>();
		for (sObject theFeed : feeds) {
			feedItemIds.add(theFeed.Id);
		}
		List<FeedItem> feedItems = [SELECT Id FROM FeedItem WHERE Id IN :feedItemIds];
		System.assertEquals(0, feedItems.size());
    }
    
    static void initRecords() {
    	// For Account Document
    	acct = new ASI_KOR_AccountGenerator().generateAccount(ASI_KOR_AccountGenerator.RT_WS);
    	insert acct;
    	
    	// For Contact Document
    	ct = new ASI_KOR_ContactGenerator().generateContact(acct, ASI_KOR_ContactGenerator.RT_WSContact);
    	insert ct;
    	
    	// For Brand Document
    	brand = new ASI_KOR_BrandGenerator().generateBrand();
    	insert brand;
    	
    	// For Product Document
    	sb = new ASI_KOR_SubBrandGenerator().generateSubBrand(brand);
    	insert sb;
    	
    	// For Item Group Document
    	itemGroup = new ASI_KOR_ItemGroupGenerator().generateItemGroup(sb);
    	insert itemGroup;
    	
    	// For GMA Image
    	gma = new ASI_KOR_GMAGenerator().generateGMA(acct, sb);
    	insert gma;
    }
}