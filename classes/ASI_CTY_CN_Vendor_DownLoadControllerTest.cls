@isTest
private class ASI_CTY_CN_Vendor_DownLoadControllerTest {
    static testMethod void testMethod1() {

    	User u = TestFactory.createUserWithProfile('admin', 'System Administrator');      
            
        System.runAs(u) { 

	        Document doc = new Document(
	            Name = 'EUR_CRM_RU_BQS_Logos.zip'
	        ,   Body = Blob.valueOf('String')
	        ,   FolderId = UserInfo.getUserId()
	        );
	        insert doc;
	        System.debug(LoggingLevel.INFO, '*** doc.FolderId: ' + doc.Folder.Name);

	        ASI_CTY_CN_Vendor_DownLoadController.getDownLoadList('');
	    }

        
    }
}