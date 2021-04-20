@isTest
private class EUR_CRM_EUAccountLinkHandlerTest {

    static testMethod void myUnitTest() {
        EUR_CRM_Account__c euAcct = (EUR_CRM_TestClassUtilityHelper.createAccountsEU(1, 'EE Indirect - On Trade')).get(0);// new EUR_CRM_Account__c(name='test eu account');
        insert euAcct;
        List<EUR_CRM_Account_Link__c> acctlinklist = [Select Id, EUR_CRM_Standard_Account__c, EUR_CRM_EU_Account__c From EUR_CRM_Account_Link__c Where EUR_CRM_EU_Account__c =: euAcct.Id];
        System.assertEquals(1, acctlinklist.size());
        
        euAcct.Name = '20131230 - name change';
        update euAcct;
        Account a = [Select Name From Account where Id =: acctlinklist[0].EUR_CRM_Standard_Account__c];
        System.assertEquals(euAcct.Name, a.Name);
        
        delete euAcct;
        List<Account> acctlist = [Select Id From Account where Id =: acctlinklist[0].EUR_CRM_Standard_Account__c];
        System.assertEquals(0, acctlist.size());
    }
}