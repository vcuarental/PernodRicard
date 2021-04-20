@isTest
private class EUR_CRM_ListViewFilterTest {

    static testMethod void myUnitTest() {
      Id rtId = [select id from recordtype where developername = 'EUR_GB_FS_Indirect' and sobjecttype = 'eur_crm_account__c' limit 1].id;
      
        EUR_CRM_Account__c euAcct = new EUR_CRM_Account__c(name='test eu account' , recordtypeid=rtId );
        insert euAcct;
        Apexpages.Standardsetcontroller acctSetCon = new Apexpages.Standardsetcontroller(Database.getQueryLocator([Select Id From EUR_CRM_Account__c Where Id=: euAcct.Id]));
        EUR_CRM_ListViewFilter filter = new EUR_CRM_ListViewFilter(acctSetCon);
        List<EUR_CRM_Account__c> acctlist = filter.getEURAccountListByFilter();
        System.assertEquals(1, acctlist.size());
    }
}