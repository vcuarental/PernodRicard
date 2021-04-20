/*
  @Company:     IP-Converge Data Services, Inc.
  @Description: Test Class for EUR_CRM_SurveyHeaderQuestionsClone
  @Author:      IPC
  @History:     OCT.08.2014 - Created
*/
@isTest
private class EUR_CRM_TestSurveyHeaderQuestionsClone {

    static testMethod void testSurvey_Qustions_Clone() {

        PageReference pref = Page.EUR_CRM_SurveyHeaderQuestionClone;
        Test.setCurrentPage(pref);

        //Survey Header
        EUR_CRM_Survey_Header__c sh = new EUR_CRM_Survey_Header__c();
        sh.Name = 'clone Survey';
        sh.EUR_CRM_Active__c = true;
        sh.EUR_CRM_Description__c = 'test description clone';
        sh.EUR_CRM_Survey_Completion__c = 'Mandatory';
        sh.EUR_CRM_Valid_From__c = Date.newInstance(2014,01,01);
        sh.EUR_CRM_Valid_Until__c = Date.newInstance(2014,05,05);
        insert sh;
        
        //Questions
        EUR_CRM_Question__c q = new EUR_CRM_Question__c();
        q.EUR_CRM_Description__c = 'test questions';
        q.EUR_CRM_Question_Statement__c = 'How are you?';
        insert q;

        //Survey Questions
        EUR_CRM_Survey_Question__c sq = new EUR_CRM_Survey_Question__c();
        sq.EUR_CRM_Survey_Header__c = sh.Id;
        sq.EUR_CRM_Sequence__c = 1;
        sq.EUR_CRM_Question__c = q.Id;
        insert sq;

        ApexPages.StandardController con = new ApexPages.StandardController(sh);
        EUR_CRM_SurveyHeaderQuestionsClone ext = new EUR_CRM_SurveyHeaderQuestionsClone(con);

        Test.startTest();

        PageReference ref = ext.cloneSurveyWithQuestions();

        PageReference redir = new PageReference('/'+ext.newRecordId+'/e?retURL=%2F'+ext.newRecordId);

        System.assertEquals(ref.getUrl(),redir.getUrl());

        EUR_CRM_Survey_Header__c newSH = [Select Id From EUR_CRM_Survey_Header__c Where Id = :ext.newRecordId];
        System.assertNotEquals(newSH, null);
        
        List<EUR_CRM_Survey_Question__c> newSQ = [Select Id From EUR_CRM_Survey_Question__c Where EUR_CRM_Survey_Header__c = :newSH.Id];
        System.assertEquals(newSq.size(),1);

        Test.stopTest();
    }
}