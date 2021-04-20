@isTest
public class EUR_CRM_ZA_TestUpdateContractSalesMngr {

    public static User eurSysUser;
    public static User eurSysUser2;
    public static User eurSysUser3;

    public static void dataSetup() {
        Profile p = [SELECT Id FROM Profile WHERE Name Like 'EUR SSA Admin%'];
        UserRole r = [select id from UserRole where Developername = 'EMEA'];

        eurSysUser = new User(Alias = 'standt', Email = 'EUR_CRM_ZA_TestSendEmailAttHandler@test.com', userroleid = r.id,
                EmailEncodingKey = 'UTF-8', LastName = 'userEmail1234aokelastName', LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US', ProfileId = p.Id,
                TimeZoneSidKey = 'America/Los_Angeles', UserName = 'EUR_CRM_ZA_TestSendEmailAttHandler@test.com');
        insert eurSysUser;

        eurSysUser2 = new User(Alias = 'stand2', Email = 'EUR_CRM_ZA_TestSendEmailAttHandler2@test.com', userroleid = r.id,
                EmailEncodingKey = 'UTF-8', LastName = 'userEmail1234aokelastName2', LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US', ProfileId = p.Id,
                TimeZoneSidKey = 'America/Los_Angeles', UserName = 'EUR_CRM_ZA_TestSendEmailAttHandler2@test.com');
        insert eurSysUser2;


        eurSysUser3 = new User(Alias = 'stand3', Email = 'EUR_CRM_ZA_TestSendEmailAttHandler3@test.com', userroleid = r.id,
                EmailEncodingKey = 'UTF-8', LastName = 'userEmail1234aokelastName3', LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US', ProfileId = p.Id, ManagerId = eurSysUser.Id,
                TimeZoneSidKey = 'America/Los_Angeles', UserName = 'EUR_CRM_ZA_TestSendEmailAttHandler3@test.com');
        insert eurSysUser3;
    }

    static testMethod void testexecution() {
        dataSetup();
        EUR_CRM_Contract__c contract;

        System.runAs(eurSysUser3) {

            Id ZAOnTradeAccountRecordTypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Account__c', 'EUR_ZA_On_Trade_Direct');
            Id ZAContractRecordTypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Contract__c', 'EUR_ZA_Outlet_Contract');

            EUR_CRM_Account__c account = new EUR_CRM_Account__C(
                    recordTypeId = ZAOnTradeAccountRecordTypeId,
                    Name = 'Test Account'
            );
            insert account;

            Test.startTest();
            contract = new EUR_CRM_Contract__c(
                    recordTypeId = ZAContractRecordTypeId,
                    EUR_CRM_Account__c = account.Id,
                    EUR_CRM_Start_Date__c = System.today(),
                    EUR_CRM_End_Date__c = System.today(),
                    EUR_CRM_Status__c = 'Draft'
            );
            insert contract;

            eurSysUser3.ManagerId = eurSysUser2.Id;
            update eurSysUser3;
            Test.stopTest();

        }

        System.assertEquals(eurSysUser3.ManagerId, [SELECT EUR_CRM_Sales_Manager__c FROM EUR_CRM_Contract__c WHERE Id = :contract.Id][0].EUR_CRM_Sales_Manager__c);
    }
}