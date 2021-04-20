@isTest
private class EUR_CRM_ContactEUAccountLinkHandlerTest {

    static testMethod void myUnitTest() {
        EUR_CRM_Account__c euAcct =  (EUR_CRM_TestClassUtilityHelper.createAccountsEU(1, 'EE Direct - On Trade')).get(0);// new EUR_CRM_Account__c(name='test eu account');
        insert euAcct;
        Contact c = new Contact(LastName='test person');
        c.EUR_CRM_Account__c = euAcct.Id;
        insert c;
        c = [Select AccountId, EUR_CRM_Account__c From Contact Where Id =: c.Id];
        EUR_CRM_Account_Link__c acctlink = [Select Id, EUR_CRM_Standard_Account__c, EUR_CRM_EU_Account__c From EUR_CRM_Account_Link__c Where EUR_CRM_EU_Account__c =: euAcct.Id limit 1];
        system.assertNotEquals(null, c.AccountId);
        system.assertEquals(acctlink.EUR_CRM_Standard_Account__c, c.AccountId);
        Test.startTest();//Edited By Jay 20160926
        EUR_CRM_Account__c euAcct2 =  (EUR_CRM_TestClassUtilityHelper.createAccountsEU(1, 'EE Direct - On Trade')).get(0);// new EUR_CRM_Account__c(name='test eu account2');
        insert euAcct2;
        c.EUR_CRM_Account__c = euAcct2.Id;
        update c;
        c = [Select AccountId, EUR_CRM_Account__c From Contact Where Id =: c.Id];
        system.assertNotEquals(null, c.AccountId);
        system.assertNotEquals(acctlink.EUR_CRM_Standard_Account__c, c.AccountId);
        Test.StopTest();//Edited By Jay 20160926
    }
}