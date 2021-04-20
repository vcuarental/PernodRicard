/**
 * Created by osman on 22.10.2020.
 */

@IsTest
private with sharing class EUR_TR_POSMDefinitionControllerTest {

    @TestSetup
    static void setup() {

        EUR_TR_Definition__c POSMTypeDefinition = new EUR_TR_Definition__c();
        POSMTypeDefinition.RecordTypeId = Schema.SObjectType.EUR_TR_Definition__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_POSMType').getRecordTypeId();
        POSMTypeDefinition.EUR_TR_POSMType__c = 'Stand';
        POSMTypeDefinition.Name = 'Stand Tanımı';
        POSMTypeDefinition.EUR_TR_UnitPrice__c = 10;
        POSMTypeDefinition.EUR_TR_Budget__c = 20;
        POSMTypeDefinition.EUR_TR_IsCarpenterPOSMType__c = true;
        POSMTypeDefinition.EUR_TR_POSMTypeStatus__c = 'Aktif';
        POSMTypeDefinition.EUR_TR_IsApprovalProcessRequiredToCancel__c = false;
        insert POSMTypeDefinition;

        createContentDocument('Setup Title', Blob.valueOf('Setup Mock Data'), POSMTypeDefinition.Id);

        EUR_TR_Account__c account = new EUR_TR_Account__c();
        account.Name = 'Test Account';
        account.RecordTypeId = Schema.SObjectType.EUR_TR_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_OffTrade').getRecordTypeId();
        account.EUR_TR_ActivityPoints__c = 'Absolut';
        account.EUR_TR_SubType__c = 'Pavyon';
        account.EUR_TR_Group__c = 'ACEM';
        account.EUR_TR_Channel__c = 'MOT';
        account.EUR_TR_ONTB__c = 'Boğaz';
        account.EUR_TR_OTPros__c = 'Premium';
        account.EUR_TR_OTSponsorship__c = 'Tanımsız';
        account.EUR_TR_OTType__c = 'Hotel';
        account.EUR_TR_Range__c = 'S2';
        account.EUR_TR_SponsorshipStatus__c = 'PR İskontolu';
        account.EUR_TR_Class__c = 'Tanimsiz';
        account.EUR_TR_Type__c = '2HEDEFLİ';
        insert account;

        EUR_TR_Definition__c segmentationDefinition = new EUR_TR_Definition__c();
        segmentationDefinition.RecordTypeId = Schema.SObjectType.EUR_TR_Definition__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_POSMSegmentation').getRecordTypeId();
        segmentationDefinition.EUR_TR_ActivityPoints__c = 'All';
        segmentationDefinition.EUR_TR_SegmentationPOSMSubTypes__c = 'All';
        segmentationDefinition.EUR_TR_SubType__c = 'All';
        segmentationDefinition.EUR_TR_Group__c = 'All';
        segmentationDefinition.EUR_TR_Channel__c = 'All';
        segmentationDefinition.EUR_TR_ONTB__c = 'All';
        segmentationDefinition.EUR_TR_OTPros__c = 'All';
        segmentationDefinition.EUR_TR_OTSponsorship__c = 'All';
        segmentationDefinition.EUR_TR_OTType__c = 'All';
        segmentationDefinition.EUR_TR_Range__c = 'All';
        segmentationDefinition.EUR_TR_SponsorshipStatus__c = 'All';
        segmentationDefinition.EUR_TR_Class__c = 'All';
        segmentationDefinition.EUR_TR_Type__c = 'All';
        segmentationDefinition.EUR_TR_SegmentationPOSMTypes__c = 'All';

        insert segmentationDefinition;


    }

    @IsTest
    static void testGetPOSMTypesFromMiddleware() {

        EUR_TR_Account__c account = [
                SELECT Id
                FROM EUR_TR_Account__c
                WHERE RecordType.DeveloperName = 'EUR_TR_OffTrade'
                LIMIT 1
        ];

        Test.startTest();
        {
            EUR_TR_POSMDefinitionController.getPOSMTypesFromMiddleware(JSON.serialize(account));
        }
        Test.stopTest();
    }

    @IsTest
    static void testGetPOSMTypes_error() {

        EUR_TR_Account__c account = [
                SELECT Id
                FROM EUR_TR_Account__c
                WHERE RecordType.DeveloperName = 'EUR_TR_OffTrade'
                LIMIT 1
        ];

        account.Id = null;

        Test.startTest();
        {
            try {
                EUR_TR_POSMDefinitionController.getPOSMTypesFromMiddleware(JSON.serialize(account));
            } catch (Exception ex) {
                System.assert(ex.getMessage() != null);
            }
        }
        Test.stopTest();
    }

    @IsTest
    static void testGetPOSMTypeDefinitionMap() {

        EUR_TR_Account__c account = [
                SELECT
                        Id
                FROM EUR_TR_Account__c
                LIMIT 1
        ];

        Test.startTest();
        {
            EUR_TR_POSMDefinitionController.getPOSMTypeDefinitionMap(account.Id);
        }
        Test.stopTest();

    }

    @IsTest
    static void testGetUploadedPOSMImage() {

        EUR_TR_Definition__c POSMDefinition = [
                SELECT Id
                FROM EUR_TR_Definition__c
                WHERE RecordType.DeveloperName = 'EUR_TR_POSMType'
                LIMIT 1
        ];

        Test.startTest();
        {
            EUR_TR_POSMDefinitionController.getUploadedPOSMImage(POSMDefinition.Id);
        }
        Test.stopTest();

    }

    @IsTest
    static void testHandleUploadFinished() {

        EUR_TR_Definition__c POSMDefinition = [
                SELECT Id
                FROM EUR_TR_Definition__c
                WHERE RecordType.DeveloperName = 'EUR_TR_POSMType'
                LIMIT 1
        ];


        Id contentDocumentId = createContentDocument('Test Title', Blob.valueOf('Test Data'), POSMDefinition.Id);

        Test.startTest();
        {
            EUR_TR_POSMDefinitionController.handleUploadFinished(POSMDefinition.Id, contentDocumentId);
        }
        Test.stopTest();

    }

    @IsTest
    static void testDeletePOSMImage() {

        EUR_TR_Definition__c POSMDefinition = [
                SELECT Id
                FROM EUR_TR_Definition__c
                WHERE RecordType.DeveloperName = 'EUR_TR_POSMType'
                LIMIT 1
        ];

        ContentDocumentLink contentDocumentLink = [
                SELECT Id,ContentDocumentId
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :POSMDefinition.Id
                LIMIT 1
        ];

        ContentDocument contentDocument = [
                SELECT Id,LatestPublishedVersionId
                FROM ContentDocument
                WHERE Id = :contentDocumentLink.ContentDocumentId
        ];

        Test.startTest();
        {
            EUR_TR_POSMDefinitionController.deletePOSMImage(POSMDefinition.Id, contentDocument.LatestPublishedVersionId);
        }
        Test.stopTest();
    }

    private static Id createContentDocument(String title, Blob versionData, Id linkedEntityId) {

        ContentVersion contentVersion = new ContentVersion();
        contentVersion.Title = title;
        contentVersion.PathOnClient = 'test';
        contentVersion.VersionData = versionData;
        contentVersion.EUR_TR_ImageSource__c = 'POSM Type';
        insert contentVersion;

        ContentVersion testContent = [
                SELECT Id, ContentDocumentId
                FROM
                        ContentVersion
                where Id = :contentVersion.Id AND IsLatest = TRUE
        ];

        ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
        contentDocumentLink.LinkedEntityId = linkedEntityId;
        contentDocumentLink.ShareType = 'I';
        contentDocumentLink.ContentDocumentId = testContent.ContentDocumentId;
        contentDocumentLink.Visibility = 'AllUsers';
        insert contentDocumentLink;


        return testContent.ContentDocumentId;

    }

    @IsTest
    static void testUpsertPOSMSegmentationDefinition() {

        EUR_TR_Definition__c definition = [
                SELECT Id
                FROM EUR_TR_Definition__c
                WHERE RecordType.DeveloperName = 'EUR_TR_POSMSegmentation'
        ];
        Test.startTest();
        {
            EUR_TR_POSMDefinitionController.upsertPOSMSegmentationDefinition(definition);
        }
        Test.stopTest();
    }

    @IsTest
    static void testGetPicklistValues() {

        Test.startTest();
        {
            EUR_TR_POSMDefinitionController.getPicklistValues();
        }
        Test.stopTest();

    }

    @IsTest
    static void testGetPOSMSegmentationDefinitions() {
        Test.startTest();
        {
            EUR_TR_POSMDefinitionController.getPOSMSegmentationDefinitions(10, 0, 'All', null);
        }
        Test.stopTest();
    }

    @IsTest
    static void testDownloadSegmentationDefinitions() {
        Test.startTest();
        {
            EUR_TR_POSMDefinitionController.downloadSegmentationDefinitions();
        }
        Test.stopTest();
    }

    @IsTest
    static void testGetPOSMSubTypesByPOSMTypeFromMiddleware() {
        EUR_TR_Account__c account = [SELECT Id FROM EUR_TR_Account__c LIMIT 1];
        EUR_TR_POSMDefinitionController.POSMSubTypeRequestModel requestModel = new EUR_TR_POSMDefinitionController.POSMSubTypeRequestModel();
        requestModel.POSMType = 'Stand';
        requestModel.accountId = account.Id;
        Test.startTest();
        {
            EUR_TR_POSMDefinitionController.getPOSMSubTypesByPOSMTypeFromMiddleware(JSON.serialize(requestModel));
        }
        Test.stopTest();
    }


}