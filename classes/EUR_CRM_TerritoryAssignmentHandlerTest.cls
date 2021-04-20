@isTest
/*
* 10/20/14
* Changed Account(EU) record type from EE Indirect - On Trade to GB FS Indirect
* Baltics records are handled by different territory assignment handler, EUR_CRM_Baltics_TerritoryAssignmentClass
*/
private class EUR_CRM_TerritoryAssignmentHandlerTest {

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
        
        EUR_CRM_Account__c acct =  (EUR_CRM_TestClassUtilityHelper.createAccountsEU(1, 'GB FS Indirect')).get(0);// new EUR_CRM_Account__c(name='test acct');

        insert acct;
        
        acct.EUR_CRM_Territory__c = terri2.Id;
        update acct;
        /*
        EUR_CRM_Account__c acct2 = (EUR_CRM_TestClassUtilityHelper.createAccountsEU(1, 'GB FS Indirect')).get(0);

        acct2.EUR_CRM_Territory__c = terri.Id;
        insert acct2;*/
    }
}