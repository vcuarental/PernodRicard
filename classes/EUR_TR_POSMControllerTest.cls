/**
 * Created by osman on 25.09.2020.
 */

@IsTest
public with sharing class EUR_TR_POSMControllerTest {

    @TestSetup
    private static void setup() {
        createTestData();
    }

    @IsTest
    private static void getPOSMRecordsByAccountIdFromMiddlewareTest() {

        EUR_TR_Account__c account = [SELECT Id FROM EUR_TR_Account__c LIMIT 1];
        EUR_TR_Definition__c definition = [SELECT Id,Name FROM EUR_TR_Definition__c WHERE RecordType.DeveloperName = 'EUR_TR_POSMType' AND EUR_TR_Brand__c = 'Absolut' AND EUR_TR_POSMType__c = 'Stand' LIMIT 1];

        EUR_TR_POSMController.POSMFilterModel filterModel = new EUR_TR_POSMController.POSMFilterModel();
        filterModel.pageSize = 10;
        filterModel.pageNumber = 1;
        filterModel.approvalStatuses = new List<String>{

        };
        filterModel.minBudget = 0;
        filterModel.maxBudget = 100000;
        filterModel.brands = new List<String>{
                'Olmeca', 'Chivas', 'Absolut'
        };
        filterModel.POSMTypes = new List<String>{
                'Stand', 'Raf İçi'
        };
        filterModel.relatedAccount = account;
        filterModel.startDate = Date.today();
        filterModel.endDate = Date.today().addDays(10);
        filterModel.POSMSubTypes = new List<String>{
                definition.Name
        };
        Test.startTest();
        {
            EUR_TR_POSMController.getPOSMRecordsByAccountIdFromMiddleware(JSON.serialize(filterModel));

            EUR_TR_POSMApprovalController.POSMApprovalRequestModel requestModel = new EUR_TR_POSMApprovalController.POSMApprovalRequestModel();
            EUR_TR_POSM__c posm = new EUR_TR_POSM__c();
            {
                posm.EUR_TR_POSMType__c = 'Stand';
                posm.EUR_TR_POSMQuantity__c = 1500;
                posm.EUR_TR_RelatedAccount__c = account.Id;
                posm.EUR_TR_PlacementDate__c = Datetime.now().addDays(10);
                posm.EUR_TR_Brand__c = 'Absolut';
                posm.EUR_TR_RelatedPOSMSubType__c = definition.Id;
            }
            requestModel.EURTRPOSMRecord = posm;
            EUR_TR_POSMApprovalController.createPOSMRequest(JSON.serialize(requestModel));
            filterModel.approvalProcessTypes = new List<String>{
                    'Onay Talebi'
            };
            EUR_TR_POSMController.getPOSMRecordsByAccountIdFromMiddleware(JSON.serialize(filterModel));
        }
        Test.stopTest();

    }

    @IsTest
    private static void getPOSMRecordsByAccountIdFromMiddlewareTest_error() {

        EUR_TR_Account__c account = [
                SELECT Id
                FROM EUR_TR_Account__c
                LIMIT 1
        ];

        EUR_TR_POSMController.POSMFilterModel filterModel = new EUR_TR_POSMController.POSMFilterModel();
        filterModel.approvalStatuses = new List<String>{
                'Bekliyor', 'Onaylandı', 'iptal Edildi', 'Reddedildi'
        };
        filterModel.POSMTypes = new List<String>{
                'Stand', 'Raf İçi'
        };
        filterModel.brands = new List<String>{
                'Olmeca', 'Chivas'
        };
        filterModel.minBudget = 0;
        filterModel.maxBudget = 10000;
        filterModel.pageSize = 10;
        filterModel.pageNumber = 1;
        filterModel.relatedAccount = null;

        Test.startTest();
        {
            try {
                EUR_TR_POSMController.getPOSMRecordsByAccountIdFromMiddleware(JSON.serialize(filterModel));
            } catch (Exception ex) {
                System.assert(ex.getMessage() != null);
            }
        }
        Test.stopTest();

    }

    public static void createTestData() {

        Profile profile = [SELECT Id FROM Profile WHERE Name = 'EUR TR Trade Tool User'];

        User user = new User();
        user.FirstName = 'test first name';
        user.LastName = 'test last name';
        user.UserName = 'pernodtestuser@pernod.com';
        user.Alias = 'alias1';
        user.Email = 'pernodtestuser@pernod.com';
        user.ProfileId = profile.Id;
        user.EmailEncodingKey = 'UTF-8';
        user.LanguageLocaleKey = 'en_US';
        user.LocaleSidKey = 'tr_TR';
        user.TimeZoneSidKey = 'Europe/Istanbul';
        insert user;

        user = [SELECT Id,Name FROM User WHERE Id = :user.Id];

        EUR_TR_Account__c account = new EUR_TR_Account__c();
        account.Name = 'EUR_TR_POSMApprovalControllerTest';
        account.RecordTypeId = Schema.SObjectType.EUR_TR_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_OffTrade').getRecordTypeId();
        account.EUR_TR_ChannelManagerName__c = user.Name;
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

        EUR_TR_Definition__c POSMTypeDefinition = new EUR_TR_Definition__c();
        POSMTypeDefinition.RecordTypeId = Schema.SObjectType.EUR_TR_Definition__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_POSMType').getRecordTypeId();
        POSMTypeDefinition.Name = 'Stand Tanımı';
        POSMTypeDefinition.EUR_TR_POSMType__c = 'Stand';
        POSMTypeDefinition.EUR_TR_POSMTypeStatus__c = 'Aktif';
        POSMTypeDefinition.EUR_TR_IsApprovalProcessRequiredToCancel__c = false;
        POSMTypeDefinition.EUR_TR_IsCarpenterPOSMType__c = false;
        POSMTypeDefinition.EUR_TR_Budget__c = 1000;
        POSMTypeDefinition.EUR_TR_ApproverTitle__c = 'Kanal Müdürü';
        POSMTypeDefinition.EUR_TR_UnitPrice__c = 10;
        POSMTypeDefinition.EUR_TR_ApprovalProcessIsRequired__c = true;
        POSMTypeDefinition.EUR_TR_Brand__c = 'Absolut';
        insert POSMTypeDefinition;

        EUR_TR_Definition__c POSMTypeDefinition2 = new EUR_TR_Definition__c();
        POSMTypeDefinition2.RecordTypeId = Schema.SObjectType.EUR_TR_Definition__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_POSMType').getRecordTypeId();
        POSMTypeDefinition2.Name = 'Raf İçi Tanımı';
        POSMTypeDefinition2.EUR_TR_POSMType__c = 'Raf İçi';
        POSMTypeDefinition2.EUR_TR_POSMTypeStatus__c = 'Aktif';
        POSMTypeDefinition2.EUR_TR_IsApprovalProcessRequiredToCancel__c = true;
        POSMTypeDefinition2.EUR_TR_IsCarpenterPOSMType__c = false;
        POSMTypeDefinition2.EUR_TR_Budget__c = 1000;
        POSMTypeDefinition2.EUR_TR_ApproverTitle__c = 'Kanal Müdürü';
        POSMTypeDefinition2.EUR_TR_ApprovalProcessIsRequired__c = true;
        POSMTypeDefinition2.EUR_TR_Brand__c = 'Absolut';
        insert POSMTypeDefinition2;


        EUR_TR_Definition__c POSMTypeDefinition3 = new EUR_TR_Definition__c();
        POSMTypeDefinition3.RecordTypeId = Schema.SObjectType.EUR_TR_Definition__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_POSMType').getRecordTypeId();
        POSMTypeDefinition3.Name = 'Hot Spot Tanımı';
        POSMTypeDefinition3.EUR_TR_POSMType__c = 'Hot Spot';
        POSMTypeDefinition3.EUR_TR_POSMTypeStatus__c = 'Aktif';
        POSMTypeDefinition3.EUR_TR_IsApprovalProcessRequiredToCancel__c = true;
        POSMTypeDefinition3.EUR_TR_IsCarpenterPOSMType__c = false;
        POSMTypeDefinition3.EUR_TR_Budget__c = 1000;
        POSMTypeDefinition3.EUR_TR_ApproverTitle__c = 'TopEx Müdürü';
        POSMTypeDefinition3.EUR_TR_ApprovalProcessIsRequired__c = true;
        insert POSMTypeDefinition3;

        EUR_TR_Definition__c POSMTypeDefinition4 = new EUR_TR_Definition__c();
        POSMTypeDefinition4.RecordTypeId = Schema.SObjectType.EUR_TR_Definition__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_POSMType').getRecordTypeId();
        POSMTypeDefinition4.Name = 'Tüm Raf (Marangozluk) Tanımı';
        POSMTypeDefinition4.EUR_TR_POSMType__c = 'Tüm Raf (Marangozluk)';
        POSMTypeDefinition4.EUR_TR_POSMTypeStatus__c = 'Aktif';
        POSMTypeDefinition4.EUR_TR_IsApprovalProcessRequiredToCancel__c = true;
        POSMTypeDefinition4.EUR_TR_IsCarpenterPOSMType__c = false;
        POSMTypeDefinition4.EUR_TR_Budget__c = 1000;
        POSMTypeDefinition4.EUR_TR_ApproverTitle__c = 'Bölge Müdürü';
        POSMTypeDefinition4.EUR_TR_ApprovalProcessIsRequired__c = false;
        insert POSMTypeDefinition4;

        EUR_TR_Definition__c segmentationDefinition = new EUR_TR_Definition__c();
        segmentationDefinition.RecordTypeId = Schema.SObjectType.EUR_TR_Definition__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_POSMSegmentation').getRecordTypeId();
        segmentationDefinition.EUR_TR_ActivityPoints__c = 'All';
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
        segmentationDefinition.EUR_TR_SegmentationPOSMSubTypes__c = 'All';
        insert segmentationDefinition;


        EUR_TR_POSM__c posm = new EUR_TR_POSM__c();
        posm.EUR_TR_RelatedAccount__c = account.Id;
        posm.EUR_TR_Budget__c = 20;
        posm.EUR_TR_POSMType__c = 'Stand';
        posm.EUR_TR_Brand__c = 'Absolut';
        posm.RecordTypeId = Schema.SObjectType.EUR_TR_POSM__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_POSM').getRecordTypeId();
        posm.EUR_TR_PlacementDate__c = Date.today().addDays(1);
        posm.EUR_TR_RelatedPOSMSubType__c = POSMTypeDefinition.Id;
        posm.EUR_TR_UnitPrice__c = 10;
        posm.EUR_TR_POSMQuantity__c = 10;
        insert posm;

        EUR_TR_POSM__c posm2 = new EUR_TR_POSM__c();
        posm2.EUR_TR_RelatedAccount__c = account.Id;
        posm2.EUR_TR_Budget__c = 20;
        posm2.EUR_TR_POSMType__c = 'Raf İçi';
        posm2.EUR_TR_Brand__c = 'Olmeca';
        posm2.RecordTypeId = Schema.SObjectType.EUR_TR_POSM__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_POSM').getRecordTypeId();
        posm2.EUR_TR_PlacementDate__c = Date.today().addDays(1);
        posm2.EUR_TR_RelatedPOSMSubType__c = POSMTypeDefinition.Id;
        posm.EUR_TR_UnitPrice__c = 10;
        posm.EUR_TR_POSMQuantity__c = 10;
        insert posm2;

        EUR_TR_Employee__c employee = new EUR_TR_Employee__c();
        employee.Name = user.Name;
        employee.EUR_TR_RelatedUser__c = user.Id;
        insert employee;

        EUR_TR_Approval__c approval = new EUR_TR_Approval__c();
        approval.Name = 'Onaylı Revize Talebi';
        approval.OwnerId = UserInfo.getUserId();
        approval.EUR_TR_RelatedPOSM__c = posm.Id;
        approval.EUR_TR_Submitter__c = UserInfo.getUserId();
        approval.EUR_TR_Approver__c = UserInfo.getUserId();
        approval.RecordTypeId = Schema.SObjectType.EUR_TR_Approval__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_POSMApproval').getRecordTypeId();
        approval.EUR_TR_ApprovalProcessType__c = 'Revize Talebi';
        approval.EUR_TR_ApprovalReason__c = 'Ürün';
        approval.EUR_TR_ApprovalStatus__c = 'Bekliyor';
        approval.EUR_TR_ApprovalDescription__c = String.format('{0} {1} {2}', new List<String>{
                account.Name,
                posm.EUR_TR_POSMType__c,
                'Revize Talebi'
        });
        insert approval;

        EUR_TR_Approval__c approval2 = new EUR_TR_Approval__c();
        approval2.Name = 'İptal Talebi';
        approval2.OwnerId = UserInfo.getUserId();
        approval2.EUR_TR_RelatedPOSM__c = posm.Id;
        approval2.EUR_TR_Submitter__c = UserInfo.getUserId();
        approval2.EUR_TR_Approver__c = UserInfo.getUserId();
        approval2.RecordTypeId = Schema.SObjectType.EUR_TR_Approval__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_POSMApproval').getRecordTypeId();
        approval2.EUR_TR_ApprovalProcessType__c = 'Revize Talebi';
        approval2.EUR_TR_ApprovalReason__c = 'Ürün';
        approval2.EUR_TR_ApprovalStatus__c = 'Bekliyor';
        approval2.EUR_TR_ApprovalDescription__c = String.format('{0} {1} {2}', new List<String>{
                account.Name,
                posm.EUR_TR_POSMType__c,
                'İptal Talebi'
        });
        insert approval2;


    }


}