/**********************************************************************************
 * Name : ASI_CRM_VN_TestDataFactoryTest
 * Created : DC @01/22/2016 7:48 AM
 * Revision History:
 * 1. 01/22/2016 - [DC 1.0] Created
 **********************************************************************************/

@isTest
private class ASI_CRM_VN_TestDataFactoryTest {
    
    private static TestMethod void testAllMethods() {

        ASI_HK_CRM_Visitation_Plan__c testPlan = ASI_CRM_VN_TestDataFactory.getVisitationPlan(
            'Test Plan Name',
            Schema.SObjectType.ASI_HK_CRM_Visitation_Plan__c.getRecordTypeInfosByName()
                              .get('VN Visitation Plan').getRecordTypeId()
        );
        insert testPlan;

        ASI_HK_CRM_Visitation_Plan_Detail__c testPlanDetail = ASI_CRM_VN_TestDataFactory.getPlanDetail(
            'Test Customer Name',
            'Test Outlet Name',
            Schema.SObjectType.ASI_HK_CRM_Visitation_Plan_Detail__c.getRecordTypeInfosByName()
                              .get('VN Visitation Plan Detail').getRecordTypeId(),
            testPlan.Id
        );
        insert testPlanDetail;

        ASI_HK_CRM_Running_Number__c testRunningNumber = ASI_CRM_VN_TestDataFactory.getRunningNumber(
            system.Label.ASI_CRM_VN_Customer_Code,
            1,
            'VN-{YYYY}',
            date.today().month() + 2,
            Date.today().year()
        );
        insert testRunningNumber;

        ASI_CRM_AccountsAdditionalField__c testCustomer = ASI_CRM_VN_TestDataFactory.getcustomerWithRT(
            'Test CustName',
            'Test outletType',
            'Test Image',
            'Test ContractedWith',
            'Test Region',
            'Test Area',
            'Test Province',
            'Test Address',
            ASI_CRM_VN_TestDataFactory.getRecordTypeId('ASI_CRM_VN_Outlet', 'ASI_CRM_AccountsAdditionalField__c')
        )[0];

        ASI_CRM_VN_TestDataFactory.getcustomer(
            'Test CustName',
            'Test outletType',
            'Test subType',
            ASI_CRM_VN_TestDataFactory.getRecordTypeId('ASI_CRM_VN_Outlet', 'ASI_CRM_AccountsAdditionalField__c')
        );

        ASI_CRM_ServicePack__c testServicePack = ASI_CRM_VN_TestDataFactory.getServicePack(
            'Test servicePackName',
            'Test grpoutletType',
            1,
            2,
            3,
            4,
            5,
            6,
            7,
            8,
            9,
            10,
            1,
            2,
            'Test imageLevel',
            4,
            5,
            'Test damdAction'
        );
        insert testServicePack;

        ASI_CRM_VN_TestDataFactory.getServicePackItem(
            'Test actVis',
            'Test subBrand',
            testServicePack.Id
        );

        ASI_CRM_VN_TestDataFactory.getcustomer(
            'Test CustName',
            'Test outletType',
            'Test subType',
            ASI_CRM_VN_TestDataFactory.getRecordTypeId('ASI_CRM_VN_Outlet', 'ASI_CRM_AccountsAdditionalField__c'),
            testServicePack.Id
        );

        List<Account> lstTestAccounts = ASI_CRM_VN_TestDataFactory.getAccounts(
            2,
            true,
            'ASI_TH_CRM_Outlet',
            'Account'
        );

        ASI_CRM_VN_TestDataFactory.getCustomerAccount(
            'Test CustName',
            'Test outletType',
            'Test subType',
            ASI_CRM_VN_TestDataFactory.getRecordTypeId('ASI_CRM_VN_Outlet', 'ASI_CRM_AccountsAdditionalField__c'),
            testServicePack.Id,
            lstTestAccounts[0].Id
        );

        ASI_CRM_VN_TestDataFactory.getCustomerRegion(
            'Test CustName',
            lstTestAccounts[0].Id,
            'Test VN_Region',
            ASI_CRM_VN_TestDataFactory.getRecordTypeId('ASI_CRM_VN_Outlet', 'ASI_CRM_AccountsAdditionalField__c')
        );

        ASI_CRM_VN_TestDataFactory.RecordTypeId = NULL;
        ASI_MFM_Sub_brand__c testSubBrand = ASI_CRM_VN_TestDataFactory.getSubBrand(
            true,
            'Test CustName',
            ASI_CRM_VN_TestDataFactory.getRecordTypeId('ASI_MFM_CN_Sub_Brand', 'ASI_MFM_Sub_brand__c')
        );
        insert testSubBrand;

        ASI_CRM_VN_TestDataFactory.RecordTypeId = NULL;
        ASI_CRM_Promoter__c testPromoter = ASI_CRM_VN_TestDataFactory.getPromoter(
            'Test CustName',
            'Test VNID',
            'Test MobileNo',
            ASI_CRM_VN_TestDataFactory.getRecordTypeId('ASI_CRM_VN_Promoter', 'ASI_CRM_Promoter__c')
        );
        insert testPromoter;

        ASI_CRM_VN_TestDataFactory.RecordTypeId = NULL;
        ASI_CRM_VN_TestDataFactory.getRSP(
            testSubBrand.Id,
            testCustomer.Id,
            testPromoter.Id,
            UserInfo.getUserId(),
            System.now(),
            System.now().addMinutes(10),
            ASI_CRM_VN_TestDataFactory.getRecordTypeId('ASI_CRM_VN_RSP', 'ASI_TH_CRM_RSP__c')
        );

        ASI_CRM_VN_TestDataFactory.RecordTypeId = NULL;
        ASI_CRM_VN_TestDataFactory.getGiftBox(
            Date.today(),
            testCustomer.Id,
            ASI_CRM_VN_TestDataFactory.getRecordTypeId('ASI_GiftBox_VN_Request', 'ASI_GiftBox_Request_Header__c')
        );

        ASI_CRM_VN_TestDataFactory.RecordTypeId = NULL;
        ASI_CRM_VN_TestDataFactory.getUser(
            'standt',
            'standarduser@testorg.com',
            'lastname',
            'UTF-8',
            'en_US',
            'en_US',
            'America/Los_Angeles',
            'standarduser@testorg.com',
            [SELECT Id FROM Profile WHERE Name='Standard User'][0].Id
        );

        ASI_CRM_VN_TestDataFactory.RecordTypeId = NULL;
        ASI_GiftBox_Notification_User__c testNotifUser = ASI_CRM_VN_TestDataFactory.getGiftBoxNotificationUser(
            'Test NotificationUserName',
            UserInfo.getUserId(),
            UserInfo.getUserId(),
            UserInfo.getUserId()
        );
        insert testNotifUser;

        ASI_CRM_VN_TestDataFactory.getMapping(
            'Test_User_Role', 
            testNotifUser.Id
        );

        ASI_CRM_VN_TestDataFactory.generateCustomers(
            1,
            lstTestAccounts,
            NULL,
            'ASI_CRM_VN_Outlet',
            'ASI_CRM_AccountsAdditionalField__c'
        );

        ASI_CRM_VN_TestDataFactory.getPromotions(
            2,
            NULL,
            'ASI_HK_CRM_National',
            'ASI_HK_CRM_Promotion__c',
            Date.today(),
            Date.today().addDays(10)
        );

        ASI_CRM_VN_TestDataFactory.getVisitationPlan(
            1,
            NULL,
            'ASI_CRM_VN_Visitation_Plan',
            'ASI_HK_CRM_Visitation_Plan__c'
        );

        ASI_CRM_VN_TestDataFactory.RecordTypeId = NULL;
        ASI_CRM_VN_TestDataFactory.getVisitationPlanDetails(
            1,
            true,
            'ASI_CRM_VN_Visitation_Plan_Detail',
            'ASI_HK_CRM_Visitation_Plan_Detail__c',
            testCustomer.Id,
            testPlan.Id
        );

        ASI_CRM_VN_TestDataFactory.getAccount('Test Account');
        ASI_CRM_VN_TestDataFactory.getSubBrand('Test custName');

        ASI_CRM_VN_TestDataFactory.createProsSegmentList(10);
        ASI_CRM_VN_TestDataFactory.createCustomer(10);
        ASI_CRM_VN_TestDataFactory.createGroupOutlet(10);
        ASI_CRM_VN_TestDataFactory.createServicePack(10);
        ASI_CRM_VN_TestDataFactory.createVlmPtlThrshold(10);
        ASI_CRM_VN_TestDataFactory.createImgLevelThrshold(10);
        ASI_CRM_VN_TestDataFactory.createDamd(10);
    }
}