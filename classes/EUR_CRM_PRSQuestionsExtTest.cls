@isTest
//Cover EUR_CRM_AnswerFactory / EUR_CRM_AnswerManager / EUR_CRM_PRSQuestionsExt
public class EUR_CRM_PRSQuestionsExtTest {


    static List<EUR_CRM_PRS_Question__c> QuestionList;

    public static void createQuestions() {

        EUR_CRM_PRS_TestClassUtilityHelper.testInitBG();
        System.debug('after EUR_CRM_PRS_TestClassUtilityHelper.testInitBG()');
        System.runAs(EUR_CRM_PRS_TestClassUtilityHelper.BG_UserA) {
            System.debug('inside System.runAs(EUR_CRM_PRS_TestClassUtilityHelper.BG_UserA)');

            EUR_CRM_PRS_Question_Set__c QuestionSet = EUR_CRM_PRS_TestClassUtilityHelper.createQuestionSet('QSet_BP', EUR_CRM_PRS_TestClassUtilityHelper.RECORD_TYPE_BG_PRS_Q_BP);
            System.debug('after QuestionSet => ' + QuestionSet);
            QuestionList = EUR_CRM_PRS_TestClassUtilityHelper.CreateAllQuestionType(QuestionSet.Id, 'BP');
            System.debug('QuestionList => ' + QuestionList);
        }


        //Object  : EUR_CRM_PRS_Question_Set__c
        //RecordType: EUR_BG_PRS_Question_Set_Brand_Building_Potential
        //        EUR_BG_PRS_Question_Set_Business_Potential
        //Fields  : EUR_CRM_External_Id__c
        //        EUR_CRM_Question_Set_Name__c
        //        EUR_CRM_Last_Mass_Update_Date__c
        //        CurrencyIsoCode:          EUR
        //
        //Object  : EUR_CRM_PRS_Question__c
        //RecordType: EUR_BG_PRS_Question_Boolean_Input
        //            EUR_BG_PRS_Question_Currency_Input
        //        EUR_BG_PRS_Question_Number_Input
        //        EUR_BG_PRS_Question_Picklist_Input
        //        EUR_BG_PRS_Question_Text_Input
        //Fields  :
        //EUR_CRM_PRS_Question_Set__c     PRS Question Set (EU)
        //EUR_CRM_Question_Statement__c    Text
        //EUR_CRM_Question_Weight__c    Percent
        //EUR_CRM_Question_Sequence__c
        //EUR_CRM_External_ID__c
        //CurrencyIsoCode
        //
        //Page    :
        //EUR_CRM_PRSQuestionsPage?id=question id
        //addPossibleAnswer
    }

    static testMethod void unitTest() {
        createQuestions();
        System.debug('Limits.getQueries => ' + Limits.getQueries());

        ApexPages.Standardcontroller standardController1 = new Apexpages.Standardcontroller(QuestionList[0]);
        PageReference rf1 = new Pagereference('/apex/EUR_CRM_PRSQuestionsPage');
        rf1.getParameters().put('id', QuestionList[0].id);
        Test.setCurrentPage(rf1);

        EUR_CRM_PRSQuestionsExt Ctrl1 = new EUR_CRM_PRSQuestionsExt(standardController1);

        Ctrl1.addPossibleAnswer();
        rf1.getParameters().put('rowIndex', '1');
        Ctrl1.deletePossibleAnswer();
        Ctrl1.addPossibleAnswer();
        Ctrl1.saveAnswer();
        System.debug('Limits.getQueries => ' + Limits.getQueries());
        try {
            Ctrl1.changeAnswerType();
        } catch (Exception e) {
        }
        Ctrl1.cancel();

        ApexPages.Standardcontroller standardController2 = new Apexpages.Standardcontroller(QuestionList[1]);
        PageReference rf2 = new Pagereference('/apex/EUR_CRM_PRSQuestionsPage');
        rf2.getParameters().put('id', QuestionList[1].id);
        Test.setCurrentPage(rf2);

        EUR_CRM_PRSQuestionsExt Ctrl2 = new EUR_CRM_PRSQuestionsExt(standardController2);

        Ctrl2.addPossibleAnswer();
        rf2.getParameters().put('rowIndex', '1');
        Ctrl2.deletePossibleAnswer();
        Ctrl2.addPossibleAnswer();
        Ctrl2.saveAnswer();
        try {
            Ctrl2.changeAnswerType();
        } catch (Exception e) {
        }
        Ctrl2.cancel();

//        Test.startTest();

        ApexPages.Standardcontroller standardController3 = new Apexpages.Standardcontroller(QuestionList[2]);
        PageReference rf3 = new Pagereference('/apex/EUR_CRM_PRSQuestionsPage');
        rf3.getParameters().put('id', QuestionList[2].id);
        Test.setCurrentPage(rf3);

        EUR_CRM_PRSQuestionsExt Ctrl3 = new EUR_CRM_PRSQuestionsExt(standardController3);

        Ctrl3.addPossibleAnswer();
        rf3.getParameters().put('rowIndex', '1');
        Ctrl3.deletePossibleAnswer();
        Ctrl3.addPossibleAnswer();
        Ctrl3.saveAnswer();
        try {
            Ctrl3.changeAnswerType();
        } catch (Exception e) {
        }
        Ctrl3.cancel();

        ApexPages.Standardcontroller standardController4 = new Apexpages.Standardcontroller(QuestionList[3]);
        PageReference rf4 = new Pagereference('/apex/EUR_CRM_PRSQuestionsPage');
        rf4.getParameters().put('id', QuestionList[3].id);
        Test.setCurrentPage(rf4);

        EUR_CRM_PRSQuestionsExt Ctrl4 = new EUR_CRM_PRSQuestionsExt(standardController4);

        Ctrl4.addPossibleAnswer();
        rf4.getParameters().put('rowIndex', '1');
        Ctrl4.deletePossibleAnswer();
        Ctrl4.addPossibleAnswer();
        Ctrl4.saveAnswer();
        try {
            Ctrl4.changeAnswerType();
        } catch (Exception e) {
        }
        Ctrl4.cancel();

        ApexPages.Standardcontroller standardController5 = new Apexpages.Standardcontroller(QuestionList[4]);
        PageReference rf5 = new Pagereference('/apex/EUR_CRM_PRSQuestionsPage');
        rf5.getParameters().put('id', QuestionList[4].id);
        Test.setCurrentPage(rf5);

        EUR_CRM_PRSQuestionsExt Ctrl5 = new EUR_CRM_PRSQuestionsExt(standardController5);

        Ctrl5.addPossibleAnswer();
        rf5.getParameters().put('rowIndex', '1');
        Ctrl5.deletePossibleAnswer();
        Ctrl5.addPossibleAnswer();
        Ctrl5.saveAnswer();
        try {
            Ctrl5.changeAnswerType();
        } catch (Exception e) {
        }
        Ctrl5.cancel();

//        Test.stopTest();
    }
}