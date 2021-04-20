/**
 * Created by osman on 23.10.2020.
 */

@IsTest
private with sharing class EUR_TR_POSMApprovalControllerTest {

    @TestSetup
    static void setup() {
        EUR_TR_POSMControllerTest.createTestData();
    }

    @IsTest
    static void testIsApprovalProcessRequiredByPOSMFields_success() {

        EUR_TR_Account__c account = getAccount();
        EUR_TR_Definition__c POSMSubTypeDefinition = getPOSMSubTypeDefinitionByPOSMTypeAndBrand('Absolut', 'Raf İçi');

        EUR_TR_POSM__c posm = new EUR_TR_POSM__c();
        posm.EUR_TR_POSMType__c = 'Raf İçi';
        posm.EUR_TR_Budget__c = 10;
        posm.EUR_TR_POSMQuantity__c = 2;
        posm.EUR_TR_RelatedAccount__c = account.Id;
        posm.EUR_TR_PlacementDate__c = Datetime.now().addDays(10);
        posm.EUR_TR_Brand__c = 'Absolut';
        posm.EUR_TR_RelatedPOSMSubType__c = POSMSubTypeDefinition.Id;


        EUR_TR_POSMApprovalController.POSMApprovalRequestModel requestModel = new EUR_TR_POSMApprovalController.POSMApprovalRequestModel();
        requestModel.EURTRPOSMRecord = posm;

        Test.startTest();
        {
            EUR_TR_MiddlewareController.PostServiceResponse serviceResponse = EUR_TR_POSMApprovalController.isApprovalProcessRequiredByPOSMFields(JSON.serialize(requestModel));
            System.debug(serviceResponse);
        }
        Test.stopTest();

    }

    @IsTest
    static void testIsApprovalProcessRequiredByPOSMFields_error() {

        EUR_TR_Account__c account = getAccount();

        EUR_TR_POSM__c posm = new EUR_TR_POSM__c();
        //posm.EUR_TR_POSMType__c = 'Raf İçi';
        posm.EUR_TR_Budget__c = 10;
        posm.EUR_TR_POSMQuantity__c = 2;
        posm.EUR_TR_RelatedAccount__c = account.Id;
        posm.EUR_TR_PlacementDate__c = Datetime.now().addDays(10);
        posm.EUR_TR_Brand__c = 'Absolut';

        EUR_TR_POSMApprovalController.POSMApprovalRequestModel requestModel = new EUR_TR_POSMApprovalController.POSMApprovalRequestModel();
        requestModel.EURTRPOSMRecord = posm;

        Test.startTest();
        {
            EUR_TR_POSMApprovalController.isApprovalProcessRequiredByPOSMFields(JSON.serialize(requestModel));
            posm.EUR_TR_POSMType__c = 'Raf İçi';
            posm.EUR_TR_RelatedAccount__c = null;
            EUR_TR_POSMApprovalController.isApprovalProcessRequiredByPOSMFields(JSON.serialize(requestModel));
            posm.EUR_TR_RelatedAccount__c = account.Id;
            posm.EUR_TR_PlacementDate__c = null;
            EUR_TR_POSMApprovalController.isApprovalProcessRequiredByPOSMFields(JSON.serialize(requestModel));
            posm.EUR_TR_PlacementDate__c = Datetime.now().addDays(10);
            posm.EUR_TR_Budget__c = null;
            EUR_TR_POSMApprovalController.isApprovalProcessRequiredByPOSMFields(JSON.serialize(requestModel));
        }
        Test.stopTest();
    }

    @IsTest
    static void testCreatePOSMRequest_error() {

        EUR_TR_POSM__c posm = new EUR_TR_POSM__c();
        posm.EUR_TR_POSMType__c = 'Stand';
        posm.EUR_TR_Budget__c = 10;
        posm.EUR_TR_POSMQuantity__c = 2;
        posm.EUR_TR_PlacementDate__c = Datetime.now().addDays(10);
        posm.EUR_TR_Brand__c = 'Absolut';

        EUR_TR_POSMApprovalController.POSMApprovalRequestModel requestModel = new EUR_TR_POSMApprovalController.POSMApprovalRequestModel();
        requestModel.EURTRPOSMRecord = posm;

        Test.startTest();
        {
            EUR_TR_POSMApprovalController.createPOSMRequest(JSON.serialize(requestModel));
        }
        Test.stopTest();
    }

    @IsTest
    static void testCreatePOSMRequest_withoutApproval() {

        EUR_TR_Account__c account = getAccount();
        EUR_TR_Definition__c POSMSubTypeDefinition = getPOSMSubTypeDefinitionByPOSMTypeAndBrand('Absolut', 'Stand');

        EUR_TR_POSMApprovalController.POSMApprovalRequestModel requestModel = new EUR_TR_POSMApprovalController.POSMApprovalRequestModel();
        RecordTypeInfo POSMRecordTypeInfo = Schema.SObjectType.EUR_TR_POSM__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_POSM');
        EUR_TR_POSM__c posm = new EUR_TR_POSM__c();
        posm.EUR_TR_POSMType__c = 'Stand';
        posm.EUR_TR_Budget__c = 10;
        posm.EUR_TR_POSMQuantity__c = 2;
        posm.EUR_TR_RelatedAccount__c = account.Id;
        posm.EUR_TR_PlacementDate__c = Datetime.now().addDays(10);
        posm.EUR_TR_Brand__c = 'Absolut';
        posm.EUR_TR_RelatedPOSMSubType__c = POSMSubTypeDefinition.Id;
        posm.RecordTypeId =POSMRecordTypeInfo.getRecordTypeId();

        requestModel.EURTRPOSMRecord = posm;

        Test.startTest();
        {
            EUR_TR_MiddlewareController.PostServiceResponse response = EUR_TR_POSMApprovalController.createPOSMRequest(JSON.serialize(requestModel));
            List<EUR_TR_POSM__c> serviceResult = (List<EUR_TR_POSM__c>) response.ExtensionData;
            EUR_TR_POSM__c createdPOSM = serviceResult.get(0);
            EUR_TR_POSMApprovalController.getActionsByPOSMRecord(createdPOSM);

        }
        Test.stopTest();

    }

    @IsTest
    static void testCreatePOSMRequest_approval_byBudgetBudgetDefinition() {

        EUR_TR_Account__c account = getAccount();
        EUR_TR_Definition__c POSMSubTypeDefinition = getPOSMSubTypeDefinitionByPOSMTypeAndBrand('Absolut', 'Stand');

        EUR_TR_POSMApprovalController.POSMApprovalRequestModel requestModel = new EUR_TR_POSMApprovalController.POSMApprovalRequestModel();

        EUR_TR_POSM__c posm = new EUR_TR_POSM__c();
        posm.EUR_TR_POSMType__c = 'Stand';
        posm.EUR_TR_Budget__c = 10;
        posm.EUR_TR_POSMQuantity__c = 2;
        posm.EUR_TR_RelatedAccount__c = account.Id;
        posm.EUR_TR_PlacementDate__c = Datetime.now().addDays(10);
        posm.EUR_TR_Brand__c = 'Absolut';
        posm.EUR_TR_RelatedPOSMSubType__c = POSMSubTypeDefinition.Id;

        requestModel.EURTRPOSMRecord = posm;

        Test.startTest();
        {
            EUR_TR_MiddlewareController.PostServiceResponse serviceResponse = EUR_TR_POSMApprovalController.createPOSMRequest(JSON.serialize(requestModel));
        }
        Test.stopTest();

    }


    @IsTest
    static void testCreatePOSMRequest_approval_byPOSMTypeDefinition() {

        EUR_TR_Account__c account = getAccount();
        EUR_TR_Definition__c POSMSubTypeDefinition = getPOSMSubTypeDefinitionByPOSMTypeAndBrand('Absolut', 'Raf İçi');

        EUR_TR_POSMApprovalController.POSMApprovalRequestModel requestModel = new EUR_TR_POSMApprovalController.POSMApprovalRequestModel();

        EUR_TR_POSM__c posm = new EUR_TR_POSM__c();
        posm.EUR_TR_POSMType__c = 'Raf İçi';
        posm.EUR_TR_Budget__c = 500;
        posm.EUR_TR_RelatedAccount__c = account.Id;
        posm.EUR_TR_PlacementDate__c = Datetime.now().addDays(10);
        posm.EUR_TR_Brand__c = 'Absolut';
        posm.EUR_TR_RelatedPOSMSubType__c = POSMSubTypeDefinition.Id;

        requestModel.EURTRPOSMRecord = posm;

        Test.startTest();
        {
            EUR_TR_MiddlewareController.PostServiceResponse serviceResponse = EUR_TR_POSMApprovalController.createPOSMRequest(JSON.serialize(requestModel));
        }
        Test.stopTest();

    }

    @IsTest
    static void testGetPOSMApprovalRecordsFromMiddleware() {

        EUR_TR_POSMApprovalController.POSMApprovalRequestModel requestModel = new EUR_TR_POSMApprovalController.POSMApprovalRequestModel();

        EUR_TR_POSMApprovalController.POSMApprovalFilterModel filterModel = new EUR_TR_POSMApprovalController.POSMApprovalFilterModel();
        filterModel.pageSize = 10;
        filterModel.pageNumber = 1;
        filterModel.minBudget = 0;
        filterModel.maxBudget = 100000;
        filterModel.brands = new List<String>{
                'Absolut'
        };
        filterModel.POSMTypes = new List<String>{
                'Stand'
        };
        filterModel.approvalStatuses = new List<String>{
                EUR_TR_POSMApprovalController.APPROVED,
                EUR_TR_POSMApprovalController.REJECTED,
                EUR_TR_POSMApprovalController.CANCELED,
                EUR_TR_POSMApprovalController.PENDING
        };
        filterModel.startDate = Date.today();
        filterModel.endDate = Date.today().addDays(10);
        filterModel.actorIds = new List<String>{
                UserInfo.getUserId()
        };


        Test.startTest();
        {

            EUR_TR_POSMApprovalController.getPOSMApprovalRecordsFromMiddleware(JSON.serialize(filterModel));


            EUR_TR_POSM__c createdPOSM = createPOSMByBudgetApproval();
            filterModel.approvalProcessTypes = new List<String>{
                    'Onay Talebi'
            };
            EUR_TR_POSMApprovalController.getPOSMApprovalRecordsFromMiddleware(JSON.serialize(filterModel));

            requestModel.EURTRPOSMRecord = createdPOSM;
            requestModel.EURTRPOSMApprovalRecord = createdPOSM.EUR_TR_POSM_Approvals__r.get(0);
            requestModel.isVendorEmailFieldsControlRequired = false;
            requestModel.vendorEmailAddress = 'test@vesium.com';
            requestModel.emailBody = 'Test body';
            requestModel.actionName = EUR_TR_POSMApprovalController.REVISE;
            requestModel.approverComment = EUR_TR_POSMApprovalController.REVISE;

            EUR_TR_POSMApprovalController.handleApprovalAction(JSON.serialize(requestModel));
            EUR_TR_POSMApprovalController.getPOSMApprovalRecordsFromMiddleware(JSON.serialize(filterModel));

            EUR_TR_POSM__c revisedPOSMRecord = createdPOSM;
            revisedPOSMRecord.EUR_TR_POSMQuantity__c = 2000;
            revisedPOSMRecord.EUR_TR_PlacementDate__c = Datetime.now().addDays(2);
            requestModel.actionName = EUR_TR_POSMApprovalController.APPROVED;
            requestModel.EURTRPOSMRecord = revisedPOSMRecord;

            EUR_TR_POSMApprovalController.handleApprovalAction(JSON.serialize(requestModel));
            EUR_TR_POSMApprovalController.getPOSMApprovalRecordsFromMiddleware(JSON.serialize(filterModel));
        }
        Test.stopTest();

    }

    @IsTest
    static void testGetApprovalRecordHistoryFromMiddleware_success() {

        EUR_TR_POSMApprovalController.POSMApprovalRequestModel requestModel = new EUR_TR_POSMApprovalController.POSMApprovalRequestModel();
        EUR_TR_POSM__c createdPOSM = createPOSMByBudgetApproval();

        requestModel.EURTRPOSMRecord = createdPOSM;
        requestModel.EURTRPOSMApprovalRecord = createdPOSM.EUR_TR_POSM_Approvals__r.get(0);
        requestModel.isVendorEmailFieldsControlRequired = false;
        requestModel.vendorEmailAddress = 'test@vesium.com';
        requestModel.emailBody = 'Test body';
        requestModel.actionName = EUR_TR_POSMApprovalController.REVISE;
        requestModel.approverComment = EUR_TR_POSMApprovalController.REVISE;

        EUR_TR_POSMApprovalController.handleApprovalAction(JSON.serialize(requestModel));

        EUR_TR_POSM__c revisedPOSMRecord = createdPOSM;
        revisedPOSMRecord.EUR_TR_POSMQuantity__c = 2000;
        revisedPOSMRecord.EUR_TR_PlacementDate__c = Datetime.now().addDays(2);
        requestModel.actionName = EUR_TR_POSMApprovalController.APPROVED;
        requestModel.EURTRPOSMRecord = revisedPOSMRecord;
        EUR_TR_POSMApprovalController.handleApprovalAction(JSON.serialize(requestModel));


        Test.startTest();
        {
            EUR_TR_POSMApprovalController.getApprovalRecordHistoryFromMiddleware(JSON.serialize(createdPOSM.EUR_TR_POSM_Approvals__r.get(0)));
        }
        Test.stopTest();
    }

    @IsTest
    static void testGetApprovalRecordHistoryFromMiddleware_error() {

        EUR_TR_POSM__c createdPOSM = createPOSMByBudgetApproval();
        EUR_TR_Approval__c approval = new EUR_TR_Approval__c();
        Test.startTest();
        {
            EUR_TR_POSMApprovalController.getApprovalRecordHistoryFromMiddleware(JSON.serialize(approval));
        }
        Test.stopTest();

    }

    @IsTest
    static void testGetPOSMDetailByApprovalIdFromMiddleware_success() {

        EUR_TR_Account__c account = getAccount();
        EUR_TR_Definition__c POSMSubTypeDefinition = getPOSMSubTypeDefinitionByPOSMTypeAndBrand('Absolut', 'Stand');

        EUR_TR_POSMApprovalController.POSMApprovalRequestModel requestModel = new EUR_TR_POSMApprovalController.POSMApprovalRequestModel();
        RecordTypeInfo POSMRecordTypeInfo = Schema.SObjectType.EUR_TR_POSM__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_POSM');
        EUR_TR_POSM__c posm = new EUR_TR_POSM__c();
        {
            posm.EUR_TR_POSMType__c = 'Stand';
            posm.EUR_TR_POSMQuantity__c = 1500;
            posm.EUR_TR_RelatedAccount__c = account.Id;
            posm.EUR_TR_PlacementDate__c = Datetime.now().addDays(10);
            posm.EUR_TR_Brand__c = 'Absolut';
            posm.EUR_TR_RelatedPOSMSubType__c = POSMSubTypeDefinition.Id;
            posm.RecordTypeId =POSMRecordTypeInfo.getRecordTypeId();
        }
        requestModel.EURTRPOSMRecord = posm;
        EUR_TR_MiddlewareController.PostServiceResponse response = EUR_TR_POSMApprovalController.createPOSMRequest(JSON.serialize(requestModel));
        List<EUR_TR_POSM__c> serviceResult = (List<EUR_TR_POSM__c>) response.ExtensionData;
        EUR_TR_POSM__c createdPOSM = serviceResult.get(0);

        Test.startTest();
        {
            EUR_TR_POSMApprovalController.getPOSMDetailByApprovalIdFromMiddleware(JSON.serialize(createdPOSM.EUR_TR_POSM_Approvals__r.get(0)));
        }
        Test.stopTest();
    }

    @IsTest
    static void testGetPOSMDetailByApprovalIdFromMiddleware_error() {

        EUR_TR_Approval__c approval = new EUR_TR_Approval__c();
        Test.startTest();
        {
            EUR_TR_POSMApprovalController.getPOSMDetailByApprovalIdFromMiddleware(JSON.serialize(approval));
        }
        Test.stopTest();

    }

    @IsTest
    static void testGetApproverByPOSMDefinition_error() {

        EUR_TR_Account__c account = [
                SELECT Id,EUR_TR_ChannelManagerName__c,EUR_TR_TopExManagerName__c,EUR_TR_AreaManagerName__c
                FROM EUR_TR_Account__c
                LIMIT 1
        ];

        List<EUR_TR_Definition__c> definitions = [
                SELECT Id,EUR_TR_ApproverTitle__c
                FROM EUR_TR_Definition__c
                WHERE RecordType.DeveloperName = 'EUR_TR_POSMType'
        ];

        Test.startTest();
        {
            for (EUR_TR_Definition__c definition : definitions) {
                getApproverByPOSMType(definition, account);
                definition.EUR_TR_ApproverTitle__c = null;
                getApproverByPOSMType(definition, account);
            }

            definitions = [
                    SELECT Id,EUR_TR_ApproverTitle__c
                    FROM EUR_TR_Definition__c
                    WHERE RecordType.DeveloperName = 'EUR_TR_POSMType'
            ];
            account.EUR_TR_ChannelManagerName__c = null;
            for (EUR_TR_Definition__c definition : definitions) {
                getApproverByPOSMType(definition, account);
            }
        }
        Test.stopTest();


    }

    @IsTest
    static void testGetApprovalActorsFromMiddleware() {

        EUR_TR_Account__c account = getAccount();
        createPOSMByBudgetApproval();
        EUR_TR_POSMApprovalController.POSMApprovalFilterModel filterModel = new EUR_TR_POSMApprovalController.POSMApprovalFilterModel();

        Test.startTest();
        {
            filterModel.relatedAccount = account;
            EUR_TR_POSMApprovalController.getApprovalActorsFromMiddleware(JSON.serializePretty(account));
            filterModel.relatedAccount = null;
            EUR_TR_POSMApprovalController.getApprovalActorsFromMiddleware(JSON.serializePretty(account));
        }
        Test.stopTest();
    }


    @IsTest
    static void testSendEmailToVendor() {
        Test.startTest();
        {
            EUR_TR_POSMApprovalController.sendEmailToVendor('vendorAddress@vesium.com', 'text message');
        }
        Test.stopTest();
    }

    @IsTest
    static void testHandleApprovalActionTest_approve_approvalRequest() {

        EUR_TR_Account__c account = getAccount();
        EUR_TR_Definition__c POSMSubTypeDefinition = getPOSMSubTypeDefinitionByPOSMTypeAndBrand('Absolut', 'Stand');

        EUR_TR_POSMApprovalController.POSMApprovalRequestModel requestModel = new EUR_TR_POSMApprovalController.POSMApprovalRequestModel();
        RecordTypeInfo POSMRecordTypeInfo = Schema.SObjectType.EUR_TR_POSM__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_POSM');
        EUR_TR_POSM__c posm = new EUR_TR_POSM__c();
        {
            posm.EUR_TR_POSMType__c = 'Stand';
            posm.EUR_TR_POSMQuantity__c = 1500;
            posm.EUR_TR_RelatedAccount__c = account.Id;
            posm.EUR_TR_PlacementDate__c = Datetime.now().addDays(10);
            posm.EUR_TR_Brand__c = 'Absolut';
            posm.EUR_TR_RelatedPOSMSubType__c = POSMSubTypeDefinition.Id;
            posm.RecordTypeId =POSMRecordTypeInfo.getRecordTypeId();
        }
        requestModel.EURTRPOSMRecord = posm;
        EUR_TR_MiddlewareController.PostServiceResponse response = EUR_TR_POSMApprovalController.createPOSMRequest(JSON.serialize(requestModel));
        List<EUR_TR_POSM__c> serviceResult = (List<EUR_TR_POSM__c>) response.ExtensionData;
        EUR_TR_POSM__c createdPOSM = serviceResult.get(0);

        requestModel.EURTRPOSMRecord = createdPOSM;
        requestModel.EURTRPOSMApprovalRecord = createdPOSM.EUR_TR_POSM_Approvals__r.get(0);
        requestModel.isVendorEmailFieldsControlRequired = false;
        requestModel.vendorEmailAddress = 'test@vesium.com';
        requestModel.emailBody = 'Test body';
        requestModel.actionName = EUR_TR_POSMApprovalController.APPROVED;
        requestModel.approverComment = EUR_TR_POSMApprovalController.APPROVED;

        Test.startTest();
        {
            EUR_TR_POSMApprovalController.handleApprovalAction(JSON.serialize(requestModel));
        }
        Test.stopTest();

    }

    @IsTest
    static void testHandleApprovalAction_reject_approvalRequest() {

        EUR_TR_POSMApprovalController.POSMApprovalRequestModel requestModel = new EUR_TR_POSMApprovalController.POSMApprovalRequestModel();
        EUR_TR_POSM__c createdPOSM = createPOSMByBudgetApproval();
        EUR_TR_Approval__c approval = createdPOSM.EUR_TR_POSM_Approvals__r.get(0);
        approval.EUR_TR_Approver__c = UserInfo.getUserId();
        update approval;

        requestModel.EURTRPOSMRecord = createdPOSM;
        requestModel.EURTRPOSMApprovalRecord = createdPOSM.EUR_TR_POSM_Approvals__r.get(0);

        requestModel.isVendorEmailFieldsControlRequired = false;
        requestModel.vendorEmailAddress = 'test@vesium.com';
        requestModel.emailBody = 'Test body';
        requestModel.actionName = EUR_TR_POSMApprovalController.REJECTED;
        requestModel.approverComment = EUR_TR_POSMApprovalController.REJECTED;

        Test.startTest();
        {
            EUR_TR_POSMApprovalController.handleApprovalAction(JSON.serialize(requestModel));
        }
        Test.stopTest();

    }

    @IsTest
    static void testHandleApprovalAction_cancel_approvalRequest() {

        EUR_TR_Account__c account = getAccount();
        EUR_TR_Definition__c POSMSubTypeDefinition = getPOSMSubTypeDefinitionByPOSMTypeAndBrand('Absolut', 'Stand');

        EUR_TR_POSMApprovalController.POSMApprovalRequestModel requestModel = new EUR_TR_POSMApprovalController.POSMApprovalRequestModel();
        RecordTypeInfo POSMRecordTypeInfo = Schema.SObjectType.EUR_TR_POSM__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_POSM');
        EUR_TR_POSM__c posm = new EUR_TR_POSM__c();
        {
            posm.EUR_TR_POSMType__c = 'Stand';
            posm.EUR_TR_POSMQuantity__c = 1500;
            posm.EUR_TR_RelatedAccount__c = account.Id;
            posm.EUR_TR_PlacementDate__c = Datetime.now().addDays(10);
            posm.EUR_TR_Brand__c = 'Absolut';
            posm.EUR_TR_RelatedPOSMSubType__c = POSMSubTypeDefinition.Id;
            posm.RecordTypeId =POSMRecordTypeInfo.getRecordTypeId();
        }
        requestModel.EURTRPOSMRecord = posm;
        EUR_TR_MiddlewareController.PostServiceResponse response = EUR_TR_POSMApprovalController.createPOSMRequest(JSON.serialize(requestModel));
        List<EUR_TR_POSM__c> serviceResult = (List<EUR_TR_POSM__c>) response.ExtensionData;
        EUR_TR_POSM__c createdPOSM = serviceResult.get(0);

        requestModel.EURTRPOSMRecord = createdPOSM;
        requestModel.EURTRPOSMApprovalRecord = createdPOSM.EUR_TR_POSM_Approvals__r.get(0);
        requestModel.isVendorEmailFieldsControlRequired = false;
        requestModel.vendorEmailAddress = 'test@vesium.com';
        requestModel.emailBody = 'Test body';
        requestModel.actionName = EUR_TR_POSMApprovalController.APPROVED;
        requestModel.approverComment = EUR_TR_POSMApprovalController.APPROVED;
        EUR_TR_POSMApprovalController.handleApprovalAction(JSON.serialize(requestModel));

        Test.startTest();
        {
            //cancel
            requestModel.actionName = EUR_TR_POSMApprovalController.CANCELED;
            requestModel.approverComment = EUR_TR_POSMApprovalController.CANCELED;
            EUR_TR_POSMApprovalController.handleApprovalAction(JSON.serialize(requestModel));
        }
        Test.stopTest();

    }

    @IsTest
    static void testHandleApprovalAction_cancel_POSMRecordIfNotExistAnyApprovalProcess() {

        EUR_TR_Account__c account = getAccount();
        EUR_TR_Definition__c POSMSubTypeDefinition = getPOSMSubTypeDefinitionByPOSMTypeAndBrand('Absolut', 'Stand');

        EUR_TR_POSMApprovalController.POSMApprovalRequestModel requestModel = new EUR_TR_POSMApprovalController.POSMApprovalRequestModel();
        RecordTypeInfo POSMRecordTypeInfo = Schema.SObjectType.EUR_TR_POSM__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_POSM');
        EUR_TR_POSM__c posm = new EUR_TR_POSM__c();
        {
            posm.EUR_TR_POSMType__c = 'Stand';
            posm.EUR_TR_POSMQuantity__c = 1;
            posm.EUR_TR_RelatedAccount__c = account.Id;
            posm.EUR_TR_PlacementDate__c = Datetime.now().addDays(10);
            posm.EUR_TR_Brand__c = 'Absolut';
            posm.EUR_TR_RelatedPOSMSubType__c = POSMSubTypeDefinition.Id;
            posm.RecordTypeId =POSMRecordTypeInfo.getRecordTypeId();
        }
        requestModel.EURTRPOSMRecord = posm;
        EUR_TR_MiddlewareController.PostServiceResponse response = EUR_TR_POSMApprovalController.createPOSMRequest(JSON.serialize(requestModel));
        List<EUR_TR_POSM__c> serviceResult = (List<EUR_TR_POSM__c>) response.ExtensionData;
        EUR_TR_POSM__c createdPOSM = serviceResult.get(0);

        requestModel.EURTRPOSMRecord = createdPOSM;
        requestModel.EURTRPOSMApprovalRecord = null;
        requestModel.isVendorEmailFieldsControlRequired = false;
        requestModel.vendorEmailAddress = 'test@vesium.com';
        requestModel.emailBody = 'Test body';
        requestModel.actionName = EUR_TR_POSMApprovalController.CANCELED;

        Test.startTest();
        {
            EUR_TR_POSMApprovalController.handleApprovalAction(JSON.serialize(requestModel));
        }
        Test.stopTest();

    }

    @IsTest
    static void testHandleApprovalAction_approve_reviseRequest_withoutApproval() {

        EUR_TR_POSMApprovalController.POSMApprovalRequestModel requestModel = new EUR_TR_POSMApprovalController.POSMApprovalRequestModel();
        EUR_TR_POSM__c createdPOSM = createPOSMByBudgetApproval();

        requestModel.EURTRPOSMRecord = createdPOSM;
        requestModel.EURTRPOSMApprovalRecord = createdPOSM.EUR_TR_POSM_Approvals__r.get(0);
        requestModel.isVendorEmailFieldsControlRequired = false;
        requestModel.vendorEmailAddress = 'test@vesium.com';
        requestModel.emailBody = 'Test body';
        requestModel.actionName = EUR_TR_POSMApprovalController.REVISE;
        requestModel.approverComment = EUR_TR_POSMApprovalController.REVISE;

        Test.startTest();
        {
            EUR_TR_POSMApprovalController.handleApprovalAction(JSON.serialize(requestModel));

            EUR_TR_POSM__c revisedPOSMRecord = createdPOSM;
            revisedPOSMRecord.EUR_TR_POSMQuantity__c = 1;
            revisedPOSMRecord.EUR_TR_PlacementDate__c = Datetime.now().addDays(2);
            revisedPOSMRecord.EUR_TR_UnitPrice__c = 4;
            requestModel.actionName = EUR_TR_POSMApprovalController.APPROVED;
            requestModel.EURTRPOSMRecord = revisedPOSMRecord;
            EUR_TR_POSMApprovalController.handleApprovalAction(JSON.serialize(requestModel));
        }
        Test.stopTest();

    }


    @IsTest
    static void testHandleApprovalAction_approve_reviseRequest() {

        EUR_TR_POSMApprovalController.POSMApprovalRequestModel requestModel = new EUR_TR_POSMApprovalController.POSMApprovalRequestModel();
        EUR_TR_Approval__c approval = [
                SELECT Id,EUR_TR_Approver__c,
                        EUR_TR_RelatedPOSM__r.EUR_TR_POSMType__c,
                        EUR_TR_RelatedPOSM__r.EUR_TR_POSMQuantity__c,
                        EUR_TR_RelatedPOSM__r.EUR_TR_RelatedAccount__c,
                        EUR_TR_RelatedPOSM__r.EUR_TR_PlacementDate__c,
                        EUR_TR_RelatedPOSM__r.EUR_TR_Brand__c,
                        EUR_TR_RelatedPOSM__r.EUR_TR_RelatedPOSMSubType__c
                FROM EUR_TR_Approval__c
                WHERE Name = 'Onaylı Revize Talebi'
                LIMIT 1
        ];

        requestModel.EURTRPOSMRecord = approval.EUR_TR_RelatedPOSM__r;
        requestModel.EURTRPOSMApprovalRecord = approval;
        requestModel.isVendorEmailFieldsControlRequired = true;
        requestModel.vendorEmailAddress = 'test@vesium.com';
        requestModel.emailBody = 'Test body';
        requestModel.actionName = EUR_TR_POSMApprovalController.APPROVED;
        requestModel.approverComment = EUR_TR_POSMApprovalController.APPROVED;

        Test.startTest();
        {
            EUR_TR_POSM__c POSMRecordToRevise = requestModel.EURTRPOSMRecord;
            POSMRecordToRevise.EUR_TR_POSMQuantity__c = 2000;
            POSMRecordToRevise.EUR_TR_PlacementDate__c = Datetime.now().addDays(2);
            requestModel.actionName = EUR_TR_POSMApprovalController.APPROVED;
            requestModel.EURTRPOSMRecord = POSMRecordToRevise;
            EUR_TR_POSMApprovalController.handleApprovalAction(JSON.serialize(requestModel));
        }
        Test.stopTest();

    }

    @IsTest
    static void testHandleApprovalAction_reject_reviseRequest() {

        EUR_TR_POSMApprovalController.POSMApprovalRequestModel requestModel = new EUR_TR_POSMApprovalController.POSMApprovalRequestModel();
        EUR_TR_Approval__c approval = [
                SELECT Id,EUR_TR_Approver__c,
                        EUR_TR_RelatedPOSM__r.EUR_TR_POSMType__c,
                        EUR_TR_RelatedPOSM__r.EUR_TR_POSMQuantity__c,
                        EUR_TR_RelatedPOSM__r.EUR_TR_RelatedAccount__c,
                        EUR_TR_RelatedPOSM__r.EUR_TR_PlacementDate__c,
                        EUR_TR_RelatedPOSM__r.EUR_TR_Brand__c,
                        EUR_TR_RelatedPOSM__r.EUR_TR_RelatedPOSMSubType__c
                FROM EUR_TR_Approval__c
                WHERE Name = 'Onaylı Revize Talebi'
                LIMIT 1
        ];

        requestModel.EURTRPOSMRecord = approval.EUR_TR_RelatedPOSM__r;
        requestModel.EURTRPOSMApprovalRecord = approval;
        requestModel.actionName = EUR_TR_POSMApprovalController.REJECTED;
        requestModel.approverComment = EUR_TR_POSMApprovalController.REJECTED;

        Test.startTest();
        {
            System.debug(JSON.serializePretty(requestModel));
            EUR_TR_POSMApprovalController.handleApprovalAction(JSON.serialize(requestModel));
        }
        Test.stopTest();

    }

    // İptal Talebi
    @IsTest
    static void testHandleApprovalAction_approve_cancelRequest() {

        EUR_TR_POSMApprovalController.POSMApprovalRequestModel requestModel = new EUR_TR_POSMApprovalController.POSMApprovalRequestModel();

        EUR_TR_Approval__c approval = [
                SELECT Id,EUR_TR_Approver__c,
                        EUR_TR_Submitter__c,
                        EUR_TR_RelatedPOSM__r.EUR_TR_POSMType__c,
                        EUR_TR_RelatedPOSM__r.EUR_TR_POSMQuantity__c,
                        EUR_TR_RelatedPOSM__r.EUR_TR_RelatedAccount__c,
                        EUR_TR_RelatedPOSM__r.EUR_TR_PlacementDate__c,
                        EUR_TR_RelatedPOSM__r.EUR_TR_Brand__c,
                        EUR_TR_RelatedPOSM__r.EUR_TR_RelatedPOSMSubType__c,
                        EUR_TR_ApprovalProcessType__c,
                        EUR_TR_ApprovalStatus__c
                FROM EUR_TR_Approval__c
                WHERE Name = 'İptal Talebi'
                LIMIT 1
        ];
        requestModel.EURTRPOSMRecord = approval.EUR_TR_RelatedPOSM__r;
        requestModel.EURTRPOSMApprovalRecord = approval;
        requestModel.isVendorEmailFieldsControlRequired = true;
        requestModel.vendorEmailAddress = 'test@vesium.com';
        requestModel.emailBody = 'Test body';

        Test.startTest();
        {
            EUR_TR_POSMApprovalController.getActionsByPOSMApprovalRecord(requestModel.EURTRPOSMApprovalRecord);
            requestModel.actionName = EUR_TR_POSMApprovalController.APPROVED;
            requestModel.approverComment = EUR_TR_POSMApprovalController.APPROVED;
            EUR_TR_POSMApprovalController.handleApprovalAction(JSON.serialize(requestModel));
            EUR_TR_POSMApprovalController.getActionsByPOSMApprovalRecord(requestModel.EURTRPOSMApprovalRecord);
        }
        Test.stopTest();

    }

    @IsTest
    static void handleApprovalActionTest_reject_cancelRequest() {

        EUR_TR_POSMApprovalController.POSMApprovalRequestModel requestModel = new EUR_TR_POSMApprovalController.POSMApprovalRequestModel();

        EUR_TR_Approval__c approval = [
                SELECT Id,EUR_TR_Approver__c,
                        EUR_TR_RelatedPOSM__r.EUR_TR_POSMType__c,
                        EUR_TR_RelatedPOSM__r.EUR_TR_POSMQuantity__c,
                        EUR_TR_RelatedPOSM__r.EUR_TR_RelatedAccount__c,
                        EUR_TR_RelatedPOSM__r.EUR_TR_PlacementDate__c,
                        EUR_TR_RelatedPOSM__r.EUR_TR_Brand__c,
                        EUR_TR_RelatedPOSM__r.EUR_TR_RelatedPOSMSubType__c
                FROM EUR_TR_Approval__c
                WHERE Name = 'İptal Talebi'
                LIMIT 1
        ];
        requestModel.EURTRPOSMRecord = approval.EUR_TR_RelatedPOSM__r;
        requestModel.EURTRPOSMApprovalRecord = approval;
        requestModel.isVendorEmailFieldsControlRequired = true;
        requestModel.vendorEmailAddress = 'test@vesium.com';
        requestModel.emailBody = 'Test body';

        Test.startTest();
        {
            requestModel.actionName = EUR_TR_POSMApprovalController.REJECTED;
            requestModel.approverComment = EUR_TR_POSMApprovalController.REJECTED;
            EUR_TR_POSMApprovalController.handleApprovalAction(JSON.serialize(requestModel));
        }
        Test.stopTest();

    }


    @IsTest
    static void handleApprovalActionTest_cancel_cancelRequest() {

        EUR_TR_Account__c account = getAccount();
        EUR_TR_Definition__c POSMSubTypeDefinition = getPOSMSubTypeDefinitionByPOSMTypeAndBrand('Absolut', 'Stand');

        RecordTypeInfo POSMRecordTypeInfo = Schema.SObjectType.EUR_TR_POSM__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_POSM');

        EUR_TR_POSMApprovalController.POSMApprovalRequestModel requestModel = new EUR_TR_POSMApprovalController.POSMApprovalRequestModel();
        EUR_TR_POSM__c posm = new EUR_TR_POSM__c();
        {
            posm.EUR_TR_POSMType__c = 'Stand';
            posm.EUR_TR_POSMQuantity__c = 1500;
            posm.EUR_TR_RelatedAccount__c = account.Id;
            posm.EUR_TR_PlacementDate__c = Datetime.now().addDays(10);
            posm.EUR_TR_Brand__c = 'Absolut';
            posm.EUR_TR_RelatedPOSMSubType__c = POSMSubTypeDefinition.Id;
            posm.RecordTypeId =POSMRecordTypeInfo.getRecordTypeId();
        }
        requestModel.EURTRPOSMRecord = posm;

        EUR_TR_MiddlewareController.PostServiceResponse response = EUR_TR_POSMApprovalController.createPOSMRequest(JSON.serialize(requestModel));
        List<EUR_TR_POSM__c> serviceResult = (List<EUR_TR_POSM__c>) response.ExtensionData;
        EUR_TR_POSM__c createdPOSM = serviceResult.get(0);

        EUR_TR_Approval__c approvalRecord = createdPOSM.EUR_TR_POSM_Approvals__r.get(0);
        approvalRecord.EUR_TR_ApprovalProcessType__c = 'İptal Talebi';
        approvalRecord.EUR_TR_ApprovalStatus__c = EUR_TR_POSMApprovalController.PENDING;
        approvalRecord.EUR_TR_Approver__c = UserInfo.getUserId();
        update approvalRecord;

        requestModel.EURTRPOSMRecord = createdPOSM;
        requestModel.EURTRPOSMApprovalRecord = createdPOSM.EUR_TR_POSM_Approvals__r.get(0);
        requestModel.isVendorEmailFieldsControlRequired = true;
        requestModel.vendorEmailAddress = 'test@vesium.com';
        requestModel.emailBody = 'Test body';

        Test.startTest();
        {
            EUR_TR_POSMApprovalController.getActorsByRelatedAccount(account);
            requestModel.actionName = EUR_TR_POSMApprovalController.CANCELED;
            requestModel.approverComment = EUR_TR_POSMApprovalController.CANCELED;
            EUR_TR_POSMApprovalController.handleApprovalAction(JSON.serialize(requestModel));
            EUR_TR_POSMApprovalController.getActorsByRelatedAccount(account);
        }
        Test.stopTest();

    }

    @IsTest
    static void testGetPOSMSubTypeFilterOptionsFromMiddleware() {

        EUR_TR_Account__c account = getAccount();
        EUR_TR_POSMApprovalController.POSMApprovalFilterModel approvalFilterModel = new EUR_TR_POSMApprovalController.POSMApprovalFilterModel();
        approvalFilterModel.relatedAccount = new EUR_TR_Account__c(Id = account.Id);
        Test.startTest();
        {
            EUR_TR_POSMApprovalController.getPOSMSubTypeFilterOptionsFromMiddleware(JSON.serialize(approvalFilterModel));
            approvalFilterModel.relatedAccount = null;
            EUR_TR_POSMApprovalController.getPOSMSubTypeFilterOptionsFromMiddleware(JSON.serialize(approvalFilterModel));
        }
        Test.stopTest();

    }


    private static void getApproverByPOSMType(EUR_TR_Definition__c POSMTypeDefinition, EUR_TR_Account__c eurtrAccount) {
        try {
            EUR_TR_POSMApprovalController.getApproverByPOSMDefinition(POSMTypeDefinition, eurtrAccount);
        } catch (Exception ex) {
            System.assert(ex.getMessage() != null);
        }
    }

    private static EUR_TR_POSM__c createPOSMByBudgetApproval() {
        EUR_TR_Account__c account = getAccount();
        EUR_TR_Definition__c POSMSubTypeDefinition = getPOSMSubTypeDefinitionByPOSMTypeAndBrand('Absolut', 'Stand');

        EUR_TR_POSMApprovalController.POSMApprovalRequestModel requestModel = new EUR_TR_POSMApprovalController.POSMApprovalRequestModel();
        RecordTypeInfo POSMRecordTypeInfo = Schema.SObjectType.EUR_TR_POSM__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_POSM');
        EUR_TR_POSM__c posm = new EUR_TR_POSM__c();
        {
            posm.EUR_TR_POSMType__c = 'Stand';
            posm.EUR_TR_POSMQuantity__c = 1500;
            posm.EUR_TR_RelatedAccount__c = account.Id;
            posm.EUR_TR_PlacementDate__c = Datetime.now().addDays(10);
            posm.EUR_TR_Brand__c = 'Absolut';
            posm.EUR_TR_RelatedPOSMSubType__c = POSMSubTypeDefinition.Id;
            posm.RecordTypeId =POSMRecordTypeInfo.getRecordTypeId();
        }
        requestModel.EURTRPOSMRecord = posm;
        EUR_TR_MiddlewareController.PostServiceResponse response = EUR_TR_POSMApprovalController.createPOSMRequest(JSON.serialize(requestModel));
        List<EUR_TR_POSM__c> serviceResult = (List<EUR_TR_POSM__c>) response.ExtensionData;
        EUR_TR_POSM__c createdPOSM = serviceResult.get(0);
        return createdPOSM;
    }

    private static EUR_TR_Account__c getAccount() {
        return [SELECT Id FROM EUR_TR_Account__c LIMIT 1];
    }

    private static EUR_TR_Definition__c getPOSMSubTypeDefinitionByPOSMTypeAndBrand(String brand, String POSMType) {
        return [SELECT Id,Name FROM EUR_TR_Definition__c WHERE RecordType.DeveloperName = 'EUR_TR_POSMType' AND EUR_TR_Brand__c = :brand AND EUR_TR_POSMType__c = :POSMType LIMIT 1];
    }

}