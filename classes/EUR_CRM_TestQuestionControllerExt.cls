@isTest
private class EUR_CRM_TestQuestionControllerExt {

    private static final String typeNeedValues = 'Picklist';
    private static final String typeNotNeedValues = 'Text Input';
    
    static testMethod void myUnitTest() {
        EUR_CRM_Question__c myQuestion = new EUR_CRM_Question__c(EUR_CRM_Question_Value_Type__c = typeNeedValues, EUR_CRM_Question_Statement__c = 'test question');
        insert myQuestion;
        EUR_CRM_Answer_Value__c ansValue = new EUR_CRM_Answer_Value__c(EUR_CRM_Question__c=myQuestion.id, EUR_CRM_Value__c='yes');
        insert ansValue;
        
        PageReference pageRef = Page.EUR_CRM_QuestionPage;
        Test.setCurrentPage(pageRef);
        
        Apexpages.Standardcontroller stdCon = new Apexpages.Standardcontroller(myQuestion);
        EUR_CRM_QuestionControllerExt controller = new EUR_CRM_QuestionControllerExt(stdCon);
        controller.addQuestionValueItem();
        Apexpages.currentPage().getParameters().put('rowIndex', '0');
        controller.removeQuestionValueItem();
        
        controller.addQuestionValueItem();
        controller.saveQuestion();
        System.assertEquals(true, controller.questionValuesDisplay.size() > 0);
        
        //change type value to not need values
        controller.myQuestion.EUR_CRM_Question_Value_Type__c = typeNotNeedValues;
        controller.saveQuestion();
        Integer numberOfValues = [Select count() From EUR_CRM_Answer_Value__c Where EUR_CRM_Question__c =: controller.myQuestion.Id];
        System.assertEquals(false, numberOfValues > 0);
    }
}