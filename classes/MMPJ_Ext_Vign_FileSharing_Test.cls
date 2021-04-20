@isTest
private class MMPJ_Ext_Vign_FileSharing_Test {
    @TestSetup
    static void makeData() {
        // Set<Id> setCampRt = Global_RecordTypeCache.getRtIdSet('Campaign',new set<String>{'MMPJ_Ext_Vign_Campaign'});
        // Id rtId = (new List<Id>(setCampRt)[0]);
        Id rtId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('MMPJ_Ext_Vign_Campaign').getRecordTypeId();
        Campaign camp = new Campaign(RecordTypeId = rtId,//'012D00000007M8T',
                                     IsActive = true,
                                     Name = 'New Campaign');
        insert camp;

        // Id rtAcc = [select id from RecordType where SObjectType='MMPJ_Ext_Vign_Societe__c' and DeveloperName='MMPJ_Ext_Vign_Viticulteur' LIMIT 1].Id;		
        Id rtAcc = Schema.SObjectType.MMPJ_Ext_Vign_Societe__c.getRecordTypeInfosByDeveloperName().get('MMPJ_Ext_Vign_Viticulteur').getRecordTypeId();
        MMPJ_Ext_Vign_Societe__c acc1 = new MMPJ_Ext_Vign_Societe__c(Name = 'Test',MMPJ_Ext_Vign_Societe_Segmentation__c = 'Cognac', RecordTypeId = rtAcc);
        insert acc1;
        
        Id rtDoc = Schema.SObjectType.MMPJ_Ext_Vign_Documents_Fournis__c.getRecordTypeInfosByDeveloperName().get('MMPJ_XRM_Document_Salesforce').getRecordTypeId();
        MMPJ_Ext_Vign_Documents_Fournis__c doc = 
            new MMPJ_Ext_Vign_Documents_Fournis__c(MMPJ_Ext_Vign_Livreur__c = acc1.Id, MMPJ_Ext_Vign_Type__c = 'CR de prestation', RecordTypeId = rtDoc);
        insert doc;

        List<ContentVersion> documents = new List<ContentVersion>();
        documents.add(
            new ContentVersion(
                Title = 'Test Insert New Document Couverture',
                PathOnClient ='test',
                VersionData = Blob.valueOf('Test Insert New Document Blob'),
                Origin = 'H'
            )
        );
        documents.add(
            new ContentVersion(
                Title = 'Test Insert New Document Vignette',
                PathOnClient ='test',
                VersionData = Blob.valueOf('Test Insert New Document Blob'),
                Origin = 'H'
            )
        );
        documents.add(
            new ContentVersion(
                Title = 'Test Insert New Document Fourni',
                PathOnClient ='test',
                VersionData = Blob.valueOf('Test Insert New Document Blob'),
                Origin = 'H'
            )
        );
        insert documents;
    }

    @isTest
    static void test_InsertDocumentCouverture() {

        List<Campaign> campaigns = [SELECT Id FROM Campaign];
        System.assertEquals(1, campaigns.size(), 'We should have 1 campaigns');
        List<ContentVersion> documents = [SELECT id, ContentDocumentId, Title FROM ContentVersion WHERE Title = 'Test Insert New Document Couverture'];
        System.assertEquals(1, documents.size(), 'We should have 1 document named Test Insert New Document Couverture');

        Test.startTest();
        ContentDocumentLink newFileShare = new ContentDocumentLink();
        newFileShare.contentdocumentid = documents.get(0).contentdocumentid;
        newFileShare.LinkedEntityId = campaigns.get(0).Id;
        newFileShare.ShareType= 'V';
        insert newFileShare;
        Test.stopTest();

        Campaign testCampaign = [SELECT Id, MMPJ_Ext_Vign_Lien_Public__c, MMPJ_Ext_Vign_Lien_Public_Image_Vignette__c FROM Campaign WHERE Id = :campaigns.get(0).Id];
        System.assertEquals(null, testCampaign.MMPJ_Ext_Vign_Lien_Public_Image_Vignette__c, 'Public link for Vignette should be empty.');
        System.assertNotEquals(null, testCampaign.MMPJ_Ext_Vign_Lien_Public__c, 'Public link for Couverture should NOT be empty.');
    }

    @isTest
    static void test_InsertDocumentVignette() {

        List<Campaign> campaigns = [SELECT Id FROM Campaign];// WHERE Name = 'New Campaign Vignette'];
        System.assertEquals(1, campaigns.size(), 'We should have 1 campaigns');
        List<ContentVersion> documents = [SELECT id, ContentDocumentId, Title FROM ContentVersion WHERE Title = 'Test Insert New Document Vignette'];
        System.assertEquals(1, documents.size(), 'We should have 1 document named Test Insert New Document Vignette');

        Test.startTest();
        ContentDocumentLink newFileShare = new ContentDocumentLink();
        newFileShare.contentdocumentid = documents.get(0).contentdocumentid;
        newFileShare.LinkedEntityId = campaigns.get(0).Id;
        newFileShare.ShareType= 'V';
        insert newFileShare;
        Test.stopTest();

        Campaign testCampaign = [SELECT Id, MMPJ_Ext_Vign_Lien_Public__c, MMPJ_Ext_Vign_Lien_Public_Image_Vignette__c FROM Campaign WHERE Id = :campaigns.get(0).Id];
        System.assertEquals(null, testCampaign.MMPJ_Ext_Vign_Lien_Public__c, 'Public link for Couverture should be empty.');
        System.assertNotEquals(null, testCampaign.MMPJ_Ext_Vign_Lien_Public_Image_Vignette__c, 'Public link for Vignette should NOT be empty.');
    }
    
    @isTest
    static void test_InsertDocumentFourni() {

        List<MMPJ_Ext_Vign_Documents_Fournis__c> docs = [SELECT Id FROM MMPJ_Ext_Vign_Documents_Fournis__c];// WHERE Name = 'New Campaign Vignette'];
        System.assertEquals(1, docs.size(), 'We should have 1 docs');
        List<ContentVersion> documents = [SELECT id, ContentDocumentId, Title FROM ContentVersion WHERE Title = 'Test Insert New Document Fourni'];
        System.assertEquals(1, documents.size(), 'We should have 1 document named Test Insert New Document Fourni');

        Test.startTest();
        ContentDocumentLink newFileShare = new ContentDocumentLink();
        newFileShare.contentdocumentid = documents.get(0).contentdocumentid;
        newFileShare.LinkedEntityId = docs.get(0).Id;
        newFileShare.ShareType= 'V';
        insert newFileShare;
        Test.stopTest();

        MMPJ_Ext_Vign_Documents_Fournis__c testDoc = [SELECT Id, MMPJ_Ext_Vign_Lien_Public__c FROM MMPJ_Ext_Vign_Documents_Fournis__c WHERE Id = :docs.get(0).Id];
        System.assertNotEquals(null, testDoc.MMPJ_Ext_Vign_Lien_Public__c, 'Public link for Document should NOT be empty.');
    }
}