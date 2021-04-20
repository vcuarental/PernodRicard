/***************************************************************************************************************************
* Name:        ASI_MFM_CN_PaymentInboundAPITest
* Description: Test class for Restful API ASI_MFM_CN_PaymentInboundAPI
*
* Version History
* Date             Developer               Comments
* ---------------  --------------------    --------------------------------------------------------------------------------
* 2018-10-15        Alan Lau                Created
* 2018-10-31        Alan Lau                Add testNullPaymentId() for testing null parameter(s) case
****************************************************************************************************************************/

@IsTest
private class ASI_MFM_CN_PaymentInboundAPITest {

    private static final String apiUri = 'https://pernod-ricard--asisb5conf.cs7.my.salesforce.com/services/apexrest/ASI_MFM_CN_Payment_API/';
    private static final String param1 = 'paymentId';
    private static final String param2 = 'confirmed';

    @TestSetup
    static void setup() {
        String recordTypeId;

        List<User> userList = new List<User>();
        User user9 = new User(CompanyName = 'Pernod Ricard China', ManagerId = UserInfo.getUserId(), ASI_MFM_Team__c = 'NTMK', ASI_MFM_Country__c ='CN', Alias = 'test991',ASI_MFM_Bypass_Callouts__c = true, email='test99' + '@dev.com', emailencodingkey='UTF-8', firstname='test991', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='test991' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
        User user8 = new User(CompanyName = 'Pernod Ricard China', ManagerId = user9.Id, ASI_MFM_Team__c = 'Testing', ASI_MFM_Country__c ='CN', Alias = 'test992',ASI_MFM_Bypass_Callouts__c = true, email='test99' + '@dev.com', emailencodingkey='UTF-8', firstname='test992', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='test992' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
        userList.add(user8);
        userList.add(user9);
        insert userList;

        user8 = [SELECT Id, Name, UserRole.DeveloperName FROM User WHERE Id = :user8.Id];

        System.runAs(user8) {

            recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_CN_Prefix');
            List<ASI_MFM_Prefix__c> prefixList = new List<ASI_MFM_Prefix__c>();
            ASI_MFM_Prefix__c prefix1 = new ASI_MFM_Prefix__c(Name = 'CB', ASI_MFM_Module__c = 'Payment', RecordTypeId = recordTypeId,
                    ASI_MFM_Fiscal_year__c = 'FY1314', ASI_MFM_Next_Number__c = 99, OwnerId = user8.Id);
            ASI_MFM_Prefix__c prefix2 = new ASI_MFM_Prefix__c(Name = 'SCPayment', ASI_MFM_Module__c = 'Structure Cost Payment', RecordTypeId = recordTypeId,
                    ASI_MFM_Fiscal_year__c = 'FY1314', ASI_MFM_Next_Number__c = 99, OwnerId = user8.Id);

            prefixList.add(prefix1);
            prefixList.add(prefix2);
            insert prefixList;

            List<ASI_MFM_Role_Prefix_Relationship__c> prefixChildList = new List<ASI_MFM_Role_Prefix_Relationship__c>();
            ASI_MFM_Role_Prefix_Relationship__c prefixChild1 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefixList[0].Id,
                    ASI_MFM_Role_Name__c = user8.userRole.developerName);
            ASI_MFM_Role_Prefix_Relationship__c prefixChild2 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefixList[1].Id,
                    ASI_MFM_Role_Name__c = user8.userRole.developerName);

            prefixChildList.add(prefixChild1);
            prefixChildList.add(prefixChild2);
            insert prefixChildList;

            Account account = new Account(Name = 'TEST', RecordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_CN_Structure_Cost_Supplier'));
            insert account;

            recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_CN_Payment');
            List<ASI_MFM_Payment__c> paymentList = new List<ASI_MFM_Payment__c>();
            ASI_MFM_Payment__c paymentWithInovice = new ASI_MFM_Payment__c(OwnerId = user8.Id, ASI_MFM_Prefix__c = prefixList[0].Id, RecordTypeId = recordTypeId, ASI_MFM_Supplier_Name__c = account.Id);
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_CAP_CN_StructureCost_Payment');
            ASI_MFM_Payment__c paymentWithoutInovice = new ASI_MFM_Payment__c(OwnerId = user8.Id, ASI_MFM_Prefix__c = prefixList[1].Id, RecordTypeId = recordTypeId, ASI_MFM_Supplier_Name__c = account.Id);

            paymentList.add(paymentWithInovice);
            paymentList.add(paymentWithoutInovice);
            //insert paymentList;
			
			insert paymentWithInovice;
			insert paymentWithoutInovice;

            User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c FROM USER WHERE id = :UserInfo.getUserId()];

            list<ASI_HK_CRM_Running_Number__c> runningNumberList = new list<ASI_HK_CRM_Running_Number__c>();
            runningNumberList.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c = 'ASI_TH_CRM_Contract__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
            runningNumberList.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c = 'ASI_TH_CRM_PaymentRequest__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
            if (!String.isBlank(currentUser.ASI_CRM_CN_Prefix__c))
                runningNumberList.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c = 'ASI_CRM_CN_ContractPONo_' + currentUser.ASI_CRM_CN_Prefix__c, recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number'))); else {
                runningNumberList.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c = 'ASI_CRM_CN_ContractPONo_NULL', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
                runningNumberList.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c = 'ASI_CRM_CN_ContractPONo_', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
            }
            insert runningNumberList;

            ASI_TH_CRM_Contract__c LastContract = new ASI_TH_CRM_Contract__c(ASI_TH_CRM_Outlet__c = account.Id,
                    recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                    ASI_CRM_CN_PO_Start_Date__c = system.today().addDays(-8),
                    ASI_CRM_CN_PO_End_Date__c = system.today().addDays(8),
                    ASI_TH_CRM_Promotion_Type__c = 'New Contract ON',
                    ASI_CRM_CN_PO_Version__c = '0.0',
                    Name = 'Contract1',
                    ASI_CRM_CN_Status__c = 'Archived'
            );
            insert LastContract;

            ASI_TH_CRM_Contract__c contract = new ASI_TH_CRM_Contract__c(ASI_TH_CRM_Outlet__c = account.Id,
                    recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                    ASI_CRM_CN_PO_Start_Date__c = system.today().addDays(-8),
                    ASI_CRM_CN_PO_End_Date__c = system.today().addDays(8),
                    ASI_TH_CRM_Promotion_Type__c = 'New Contract ON',
                    ASI_CRM_CN_PO_Version__c = '0.1',
                    Name = 'Contract2',
                    ASI_CRM_CN_Status__c = 'Draft',
                    ASI_CRM_CN_Last_PO_version__c = LastContract.id,
                    ASI_CRM_CN_V0_0_PO_version__c = LastContract.id

            );
            insert contract;

            ASI_TH_CRM_PaymentRequest__c paymentRequest = new ASI_TH_CRM_PaymentRequest__c(Name = '20180101', ASI_TH_CRM_Contract__c = contract.Id,
                    ASI_CRM_New_FY_Payment__c = True, ASI_TH_CRM_Status__c = 'Approved',
                    ASI_CRM_CN_BRSF_Start_Date__c = system.today().addDays(-2),
                    ASI_CRM_CN_BRSF_End_Date__c = system.today().addDays(-1), recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request'));
            insert paymentRequest;
        }

    }

    @IsTest
    static void testRetrievePaymentAndInvoiceOnly() {
        ASI_MFM_Payment__c payment = [SELECT Id, Name FROM ASI_MFM_Payment__c WHERE Name = 'CB0099'];
        retrieveDataAndConfirmation(payment.Name, null);
    }

    @IsTest
    static void testRetrievePaymentAndInvoiceWithConfirmation() {
        ASI_MFM_Payment__c payment = [SELECT Id, Name FROM ASI_MFM_Payment__c WHERE Name = 'CB0099'];
        retrieveDataAndConfirmation(payment.Name, 'true');
    }

    @IsTest
    static void testRetrievePaymentAndInvoiceWithoutConfirmation() {
        ASI_MFM_Payment__c payment = [SELECT Id, Name FROM ASI_MFM_Payment__c WHERE Name = 'CB0099'];
        retrieveDataAndConfirmation(payment.Name, 'false');
    }

    @IsTest
    static void testRetrievePaymentOnly() {
        ASI_MFM_Payment__c payment = [SELECT Id, Name FROM ASI_MFM_Payment__c WHERE Name = 'SCPayment130099'];
        retrieveDataAndConfirmation(payment.Name, null);
    }

    @IsTest
    static void testRetrievePaymentWithConfirmation() {
        ASI_MFM_Payment__c payment = [SELECT Id, Name FROM ASI_MFM_Payment__c WHERE Name = 'SCPayment130099'];
        retrieveDataAndConfirmation(payment.Name, 'true');
    }

    @IsTest
    static void testRetrievePaymentWithoutConfirmation() {
        ASI_MFM_Payment__c payment = [SELECT Id, Name FROM ASI_MFM_Payment__c WHERE Name = 'SCPayment130099'];
        retrieveDataAndConfirmation(payment.Name, 'false');
    }

    @IsTest
    static void testRetrievePaymentRequestAndPayeeLineItemOnly() {
        retrieveDataAndConfirmation('20180101', null);
    }

    @IsTest
    static void testRetrievePaymentRequestAndPayeeLineItemWithConfirmation() {
        retrieveDataAndConfirmation('20180101', 'true');
    }

    @IsTest
    static void testRetrievePaymentRequestAndPayeeLineItemWithoutConfirmation() {
        retrieveDataAndConfirmation('20180101', 'false');
    }

    @IsTest
    static void testNullPaymentId() {
        retrieveDataAndConfirmation(null, null);
    }

    private static void retrieveDataAndConfirmation(String paymentId, String confirmation) {
        RestRequest request = new RestRequest();

        request.requestURI = apiUri;
        request.httpMethod = 'GET';
        request.addParameter(param1, paymentId);
        request.addParameter(param2, confirmation);

        RestContext.request = request;

        ASI_MFM_CN_PaymentInboundAPI.retrievePaymentIdAndConfirmation();
    }
}