@isTest
private class EUR_CRM_Baltics_TerritoryAssignmentTest {

    static testMethod void myUnitTest() {
        EUR_CRM_Region__c region = new EUR_CRM_Region__c(name='test region');
        insert region;
        EUR_CRM_Territory__c terri = new EUR_CRM_Territory__c(name='test territory');
        terri.EUR_CRM_Region__c = region.Id;
        terri.EUR_CRM_Territory_Owner__c = UserInfo.getUserId();
        insert terri;
        EUR_CRM_Territory__c terri2 = new EUR_CRM_Territory__c(name='test territory 2');
        terri2.EUR_CRM_Region__c = region.Id;
        terri2.EUR_CRM_Territory_Owner__c = UserInfo.getUserId();
        insert terri2;
        
        EUR_CRM_Account__c acct =  (EUR_CRM_TestClassUtilityHelper.createAccountsEU(1, 'EE Indirect - On Trade')).get(0);// new EUR_CRM_Account__c(name='test acct');
    	test.startTEst();
        insert acct;
        test.stoptest();
        acct.EUR_CRM_Territory__c = terri2.Id;
        update acct;
        
        EUR_CRM_Account__c acct2 = (EUR_CRM_TestClassUtilityHelper.createAccountsEU(1, 'EE Indirect - On Trade')).get(0);

        acct2.EUR_CRM_Territory__c = terri.Id;
        insert acct2;
    }
}