@isTest(seealldata=true)
private class EUR_CRM_MassDistrObjectiveCtrlTest {
    static testMethod void myUnitTest() {
        //List<EUR_CRM_Account__c> acctlist = EUR_CRM_FilteredMassChatterCtrllerTest.createAccts();
        Id rtId = [select id from recordtype where developername = 'EUR_GB_FS_Indirect' and sobjecttype = 'eur_crm_account__c' limit 1].id;
        List<EUR_CRM_Account__c> acctlist = [SELECT Id,Name, RecordTypeId, RecordType.DeveloperName FROM EUR_CRM_Account__c WHERE recordTypeId = :rtId Limit 10];
        
        EUR_CRM_GB_Objective__c obj = new EUR_CRM_GB_Objective__c(name='test uk central objective');
        insert obj;
        
        Test.setCurrentPage(Page.EUR_CRM_MassCreateCentralObjective);
        Apexpages.currentPage().getParameters().put('objId', obj.id);
        Apexpages.Standardsetcontroller acctSetCon = new Apexpages.Standardsetcontroller(Database.getQueryLocator([Select Id From EUR_CRM_Account__c Where Id in: acctlist LIMIT 10]));
        EUR_CRM_MassDistrObjectiveCtrller controller = new EUR_CRM_MassDistrObjectiveCtrller(acctSetCon);
        String numOfAccts = controller.NumOfRecords;
        controller.massCreateObjective();
        controller.massCreateVisitAction();
        controller.getIsPublishDisabled();
        controller.getIsMassCreateVisitAction();
        controller.getIsMassCreateObjective();
        
    }
    

}