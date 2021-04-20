@isTest
private class EUR_CRM_TestSurveyControllerExt {

    static testMethod void myUnitTest() {
        EUR_CRM_Question__c question = new EUR_CRM_Question__c(EUR_CRM_Question_Statement__c='test question');
        insert question;
        EUR_CRM_Survey_Header__c sheader = new EUR_CRM_Survey_Header__c(name='test survey header');
        insert sheader;
        //List<EUR_CRM_Account__c> acctlist = EUR_CRM_FilteredMassChatterCtrllerTest.createAccts();
        Id rtId = [select id from recordtype where developername = 'EUR_GB_FS_Indirect' and sobjecttype = 'eur_crm_account__c' limit 1].id;
        List<EUR_CRM_Account__c> acctlist = [SELECT Id,Name,RecordTypeId FROM EUR_CRM_Account__c WHERE recordtypeid = :rtId Limit 10];
        Test.setCurrentPage(Page.EUR_CRM_ConfigSurveyPage);
        Apexpages.currentPage().getParameters().put('shid', sheader.Id);
        
        Apexpages.Standardsetcontroller acctSetCon = new Apexpages.Standardsetcontroller(Database.getQueryLocator([Select Id From EUR_CRM_Account__c LIMIT 10]));
        EUR_CRM_SurveyControllerExt controller = new EUR_CRM_SurveyControllerExt(acctSetCon);
        Boolean hasNext = controller.hasNext;
        Boolean hasPrev = controller.hasPrevious;
        
        test.startTest();
        controller.nextPage();
        controller.previousPage();
        controller.isAllSelected = true;
        controller.selectAllItems();
        controller.isAllSelected = false;
        controller.selectAllItems();
        controller.contextItem = question.Id;
        controller.doSelectItem();
        controller.doDeselectItem();
        controller.pageQuestionItems[0].IsSelected = true;
        controller.getSelectedItems();
        controller.addSurveyQuestions();
        test.stopTest();
        
        Apexpages.currentPage().getParameters().put('rowIndex', '0');
        controller.removeSurveyQuestion();
        
        controller.updateOutletFilter();
        controller.publishSurvey();
    }
}