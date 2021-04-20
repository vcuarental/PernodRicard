/*********************************************************************************
 * Name: ASI_CRM_VN_POSM_ReqHeaderControllerTest
 * Description: Test Class for ASI_CRM_VN_POSM_ReqHeaderController
 *
 * Version History
 * Date                Developer             Comments
 * ---------------  --------------------  --------------------------------------------------------------------------------
 * 16/11/2015       Laputa: Neha          	Created
 * 07/01/2019       Andy Zhang            	Insert setting and expenditure
 * 01/11/2019		Laputa: Calvin			Added new test for USD Currency and FOC type
*********************************************************************************/


@IsTest
public class ASI_CRM_VN_POSM_ReqHeaderControllerTest {
    @TestSetup
    public static void setupTestData() {


        Profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];

        User u = ASI_CRM_VN_TestClassHelper.createUser(systemAdminProfile.Id);
        u.ManagerId = UserInfo.getUserId();
        insert u;

        System.runAs(u) {
            ASI_CRM_VN_TestClassHelper.createCustomSettings();
            ASI_CRM_VN_TestClassHelper.createRunningNumber();
            ASI_CRM_VN_TestClassHelper.createExchangeRate();


            // Create account list for customer create input
            List<Account> accountList = ASI_CRM_VN_VisitationPlanDetailGenTest.createTestAccount(1);
            insert accountList;
            // Create outlettype list for customer create input
            List<ASI_TH_CRM_OutletType__c> outletTypeList = ASI_CRM_VN_VisitationPlanDetailGenTest.createTestOutletType(1);
            insert outletTypeList;


            ASI_CRM_ServicePack__c servicePack = ASI_CRM_VN_TestClassHelper.createServicePack();
            insert servicePack;

            // Create customer for test class
            ASI_CRM_AccountsAdditionalField__c testCustomer = new ASI_CRM_AccountsAdditionalField__c();
            testCustomer.Name = 'TestCustomer';
            testCustomer.ASI_CRM_Account__c = accountList[0].Id;
            testCustomer.ASI_TH_CRM_OutletType__c = outletTypeList[0].Id;
            testCustomer.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_VN_Outlet');
            testCustomer.ASI_CRM_Service_Pack__c = servicePack.Id;

            insert testCustomer;


            ASI_MFM_Sub_brand__c subBrand = ASI_CRM_VN_TestClassHelper.createSubBrand();
            insert subBrand;


            //Create settings
            //Andy Zhang
            //ASI_CRM_VN_TestClassHelper.createCustomSettings();
            //2019-01-07

            ASI_CRM_VN_Contract__c contract = ASI_CRM_VN_TestClassHelper.createContract(testCustomer.Id, subBrand.Id);
            contract.ASI_CRM_Area_Code__c = '123456';
            contract.ASI_CRM_Contract_Number__c = 'Testing Contract 1';
            contract.ASI_CRM_Contract_Status__c = 'Approved';
            contract.ASI_CRM_Currency__c = 'USD';
            insert contract;

            //Create expenditure
            //Andy Zhang
            test.startTest();
            ASI_CRM_VN_Contract_Expenditure__c expenditure= ASI_CRM_VN_TestClassHelper.createContractExpenditure(contract.Id);
            expenditure.ASI_CRM_VN_Item__c = 'Lump Sum';
            insert expenditure;
            //2019-01-07

            ASI_GiftBox_Request_Header__c giftBoxReq = new ASI_GiftBox_Request_Header__c();
            giftBoxReq.ASI_CRM_VN_Contract__c = contract.Id;
            giftBoxReq.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_GiftBox_Request_Header__cASI_CRM_POSM_VN_Request');
            giftBoxReq.ASI_CRM_Customer__c = testCustomer.id;
            giftBoxReq.ASI_CRM_Order_Date__c = System.today();
            insert giftBoxReq;
            
            // calvin 2019-01-11
            ASI_GiftBox_Request_Header__c giftBoxReq2 = new ASI_GiftBox_Request_Header__c();
            giftBoxReq2.ASI_CRM_VN_Contract__c = contract.Id;
            giftBoxReq2.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_GiftBox_Request_Header__cASI_CRM_VN_FOC_Request');
            giftBoxReq2.ASI_CRM_Customer__c = testCustomer.id;
            giftBoxReq2.ASI_CRM_Order_Date__c = System.today();
            insert giftBoxReq2;
            Test.stopTest();

        }

    }
    public static testMethod void posmReqHeader() {
        test.startTest();
        ASI_GiftBox_Request_Header__c giftbxReq = [SELECT Id FROM ASI_GiftBox_Request_Header__c where recordtypeId =:Global_RecordTypeCache.getRtId('ASI_GiftBox_Request_Header__cASI_CRM_POSM_VN_Request') LIMIT 1];
        ApexPages.currentPage().getParameters().put('id', giftbxReq.id);
        ApexPages.StandardController sc = new ApexPages.StandardController(giftbxReq);
        ASI_CRM_VN_POSM_ReqHeaderController crmposObj = new ASI_CRM_VN_POSM_ReqHeaderController(sc);
        crmposObj.getEditForSales();
        crmposObj.getReadForSales();
        crmposObj.checkInventory();
        crmposObj.getGiftBoxList();
        crmposObj.runSearch();
        system.assertEquals(true, crmposObj.getEditForSales());
        system.assertEquals(false, crmposObj.getReadForSales());
        system.assertEquals(false, crmposObj.isHRUser);
        test.stopTest();
    }
    
    public static testMethod void focReqHeader() {
        test.startTest();
        ASI_GiftBox_Request_Header__c giftbxReq = [SELECT Id FROM ASI_GiftBox_Request_Header__c where recordTypeId =: Global_RecordTypeCache.getRtId('ASI_GiftBox_Request_Header__cASI_CRM_VN_FOC_Request') LIMIT 1];
        ApexPages.currentPage().getParameters().put('id', giftbxReq.id);
        ApexPages.StandardController sc = new ApexPages.StandardController(giftbxReq);
        ASI_CRM_VN_POSM_ReqHeaderController crmposObj = new ASI_CRM_VN_POSM_ReqHeaderController(sc);
        crmposObj.getEditForSales();
        crmposObj.getReadForSales();
        crmposObj.checkInventory();
        crmposObj.getGiftBoxList();
        crmposObj.runSearch();
        system.assertEquals(true, crmposObj.getEditForSales());
        system.assertEquals(false, crmposObj.getReadForSales());
        system.assertEquals(false, crmposObj.isHRUser);
        test.stopTest();
    }


    public static testMethod void posmReqHeaderNew() {

        test.startTest();
        ASI_GiftBox_Request_Header__c giftbxReq = [SELECT Id FROM ASI_GiftBox_Request_Header__c where recordtypeId =:Global_RecordTypeCache.getRtId('ASI_GiftBox_Request_Header__cASI_CRM_POSM_VN_Request') LIMIT 1];
        giftbxReq.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_GiftBox_Request_Header__cASI_CRM_POSM_VN_Request_Read_Only');
        update giftbxReq;


        ApexPages.currentPage().getParameters().put('id', giftbxReq.id);
        ApexPages.StandardController sc = new ApexPages.StandardController(giftbxReq);
        ASI_CRM_VN_POSM_ReqHeaderController crmposObj = new ASI_CRM_VN_POSM_ReqHeaderController(sc);
        crmposObj.getEditForSales();
        crmposObj.getReadForSales();
        crmposObj.checkInventory();
        crmposObj.getGiftBoxList();
        crmposObj.runSearch();
        system.assertEquals(false, crmposObj.getEditForSales());
        system.assertEquals(true, crmposObj.getReadForSales());
        system.assertEquals(false, crmposObj.isHRUser);
        test.stopTest();

    }

}