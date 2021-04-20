@IsTest (IsParallel = true)
private class EUR_CRM_PRS_QuestSetIsQuestUpdServiceTst {

    private static final Integer COUNT_OF_RECORDS = 5;
    private static final String NEED_UPDATE = EUR_CRM_PRS_QuestSetIsQuestUpdService.NEED_UPDATE;
    private static final String NO_NEED_UPDATE = EUR_CRM_PRS_QuestSetIsQuestUpdService.NO_NEED_UPDATE;


    /* ============================================================================================== */
    /*     Update one EUR_CRM_PRS_Question_Set__c with one EUR_CRM_PRS_Question__c
    /* ============================================================================================== */
    @IsTest
    private static void updateOneQuestionSetToFalseIsQuestionUpdateForOneQuestionWithNewActionTest() {
        EUR_CRM_PRS_Question_Set__c questionSet = makeQuestionSet();
        insert questionSet;

        EUR_CRM_PRS_Question__c question = makeQuestion(questionSet.Id, 'New');
        insert question;

        questionSet = selectQuestionSets()[0];
        System.assertEquals(true, questionSet.EUR_CRM_IsQuestionsUpdated__c);

        questionSet.EUR_CRM_IsQuestionsUpdated__c = false;

        Test.startTest();
        update questionSet;
        Test.stopTest();

        questionSet = selectQuestionSets()[0];
        System.assertEquals(false, questionSet.EUR_CRM_IsQuestionsUpdated__c);

        question = selectQuestions()[0];
        System.assertEquals('New', question.EUR_CRM_ActionPROS__c);
    }

    @IsTest
    private static void updateOneQuestionSetToFalseIsQuestionUpdateForOneQuestionWithNeedUpdateActionTest() {
        EUR_CRM_PRS_Question_Set__c questionSet = makeQuestionSet();
        insert questionSet;

        EUR_CRM_PRS_Question__c question = makeQuestion(questionSet.Id, NEED_UPDATE);
        insert question;

        questionSet = selectQuestionSets()[0];
        System.assertEquals(true, questionSet.EUR_CRM_IsQuestionsUpdated__c);

        questionSet.EUR_CRM_IsQuestionsUpdated__c = false;

        Test.startTest();
        update questionSet;
        Test.stopTest();

        questionSet = selectQuestionSets()[0];
        System.assertEquals(false, questionSet.EUR_CRM_IsQuestionsUpdated__c);

        question = selectQuestions()[0];
        System.assertEquals(NO_NEED_UPDATE, question.EUR_CRM_ActionPROS__c);
    }


    /* ============================================================================================== */
    /*     Update one EUR_CRM_PRS_Question_Set__c with many EUR_CRM_PRS_Question__c
    /* ============================================================================================== */
    @IsTest
    private static void updateOneQuestionSetToFalseIsQuestionUpdateForManyQuestionsWithNewActionTest() {
        EUR_CRM_PRS_Question_Set__c questionSet = makeQuestionSet();
        insert questionSet;

        List<EUR_CRM_PRS_Question__c> questions = makeQuestions(questionSet.Id, 'New');
        insert questions;

        questionSet = selectQuestionSets()[0];
        System.assertEquals(true, questionSet.EUR_CRM_IsQuestionsUpdated__c);

        questionSet.EUR_CRM_IsQuestionsUpdated__c = false;

        Test.startTest();
        update questionSet;
        Test.stopTest();

        questionSet = selectQuestionSets()[0];
        System.assertEquals(false, questionSet.EUR_CRM_IsQuestionsUpdated__c);

        questions = selectQuestions();
        for (EUR_CRM_PRS_Question__c question : questions) {
            System.assertEquals('New', question.EUR_CRM_ActionPROS__c);
        }
    }

    @IsTest
    private static void updateOneQuestionSetToFalseIsQuestionUpdateForManyQuestionsWithNeedUpdateActionTest() {
        EUR_CRM_PRS_Question_Set__c questionSet = makeQuestionSet();
        insert questionSet;

        List<EUR_CRM_PRS_Question__c> questions = makeQuestions(questionSet.Id, NEED_UPDATE);
        insert questions;

        questionSet = selectQuestionSets()[0];
        System.assertEquals(true, questionSet.EUR_CRM_IsQuestionsUpdated__c);

        questionSet.EUR_CRM_IsQuestionsUpdated__c = false;

        Test.startTest();
        update questionSet;
        Test.stopTest();

        questionSet = selectQuestionSets()[0];
        System.assertEquals(false, questionSet.EUR_CRM_IsQuestionsUpdated__c);

        questions = selectQuestions();
        for (EUR_CRM_PRS_Question__c question : questions) {
            System.assertEquals(NO_NEED_UPDATE, question.EUR_CRM_ActionPROS__c);
        }
    }


    /* ============================================================================================== */
    /*     Update many EUR_CRM_PRS_Question_Set__c with many EUR_CRM_PRS_Question__c
    /* ============================================================================================== */
    @IsTest
    private static void updateManyQuestionSetToFalseIsQuestionUpdateForManyQuestionsWithNewActionTest() {
        List<EUR_CRM_PRS_Question_Set__c> questionSets = makeQuestionSets();
        insert questionSets;

        List<EUR_CRM_PRS_Question__c> questions = new List<EUR_CRM_PRS_Question__c>();
        for (EUR_CRM_PRS_Question_Set__c questionSet : questionSets) {
            questions.addAll(makeQuestions(questionSet.Id, 'New'));
        }
        insert questions;

        questionSets = selectQuestionSets();
        for (EUR_CRM_PRS_Question_Set__c questionSet : questionSets) {
            System.assertEquals(true, questionSet.EUR_CRM_IsQuestionsUpdated__c);
        }

        for (EUR_CRM_PRS_Question_Set__c questionSet : questionSets) {
            questionSet.EUR_CRM_IsQuestionsUpdated__c = false;
        }

        Test.startTest();
        update questionSets;
        Test.stopTest();

        questionSets = selectQuestionSets();
        for (EUR_CRM_PRS_Question_Set__c questionSet : questionSets) {
            System.assertEquals(false, questionSet.EUR_CRM_IsQuestionsUpdated__c);
        }

        questions = selectQuestions();
        for (EUR_CRM_PRS_Question__c question : questions) {
            System.assertEquals('New', question.EUR_CRM_ActionPROS__c);
        }
    }

    @IsTest
    private static void updateManyQuestionSetToFalseIsQuestionUpdateForManyQuestionsWithNeedUpdateActionTest() {
        List<EUR_CRM_PRS_Question_Set__c> questionSets = makeQuestionSets();
        insert questionSets;

        List<EUR_CRM_PRS_Question__c> questions = new List<EUR_CRM_PRS_Question__c>();
        for (EUR_CRM_PRS_Question_Set__c questionSet : questionSets) {
            questions.addAll(makeQuestions(questionSet.Id, NEED_UPDATE));
        }
        insert questions;

        questionSets = selectQuestionSets();
        for (EUR_CRM_PRS_Question_Set__c questionSet : questionSets) {
            System.assertEquals(true, questionSet.EUR_CRM_IsQuestionsUpdated__c);
        }

        for (EUR_CRM_PRS_Question_Set__c questionSet : questionSets) {
            questionSet.EUR_CRM_IsQuestionsUpdated__c = false;
        }

        Test.startTest();
        update questionSets;
        Test.stopTest();

        questionSets = selectQuestionSets();
        for (EUR_CRM_PRS_Question_Set__c questionSet : questionSets) {
            System.assertEquals(false, questionSet.EUR_CRM_IsQuestionsUpdated__c);
        }

        questions = selectQuestions();
        for (EUR_CRM_PRS_Question__c question : questions) {
            System.assertEquals(NO_NEED_UPDATE, question.EUR_CRM_ActionPROS__c);
        }
    }

    @IsTest
    private static void updateManyQuestionSetToFalseIsQuestionUpdateForManyQuestionsWithNewAndNeedUpdateActionsTest() {
        List<EUR_CRM_PRS_Question_Set__c> questionSets = makeQuestionSets();
        insert questionSets;

        List<EUR_CRM_PRS_Question__c> questions = new List<EUR_CRM_PRS_Question__c>();
        for (EUR_CRM_PRS_Question_Set__c questionSet : questionSets) {
            questions.addAll(makeQuestions(questionSet.Id, 'New'));
            questions.addAll(makeQuestions(questionSet.Id, NEED_UPDATE));
        }
        insert questions;

        questionSets = selectQuestionSets();
        for (EUR_CRM_PRS_Question_Set__c questionSet : questionSets) {
            System.assertEquals(true, questionSet.EUR_CRM_IsQuestionsUpdated__c);
        }

        for (EUR_CRM_PRS_Question_Set__c questionSet : questionSets) {
            questionSet.EUR_CRM_IsQuestionsUpdated__c = false;
        }

        Test.startTest();
        update questionSets;
        Test.stopTest();

        questionSets = selectQuestionSets();
        for (EUR_CRM_PRS_Question_Set__c questionSet : questionSets) {
            System.assertEquals(false, questionSet.EUR_CRM_IsQuestionsUpdated__c);
        }

        questions = selectQuestions();
        for (EUR_CRM_PRS_Question__c question : questions) {
            System.assertNotEquals(NEED_UPDATE, question.EUR_CRM_ActionPROS__c);
        }
    }


    /* ========================================================= */
    /*     High Level Makers
    /* ========================================================= */
    private static List<EUR_CRM_PRS_Question_Set__c> makeQuestionSets() {
        List<EUR_CRM_PRS_Question_Set__c> questionSets = new List<EUR_CRM_PRS_Question_Set__c>();
        for (Integer i = 0; i < COUNT_OF_RECORDS; i++) {
            questionSets.add(makeQuestionSet());
        }
        return questionSets;
    }

    private static List<EUR_CRM_PRS_Question__c> makeQuestions(Id questionSetId, String actionPros) {
        List<EUR_CRM_PRS_Question__c> questions = new List<EUR_CRM_PRS_Question__c>();
        for (Integer i = 0; i < COUNT_OF_RECORDS; i++) {
            questions.add(makeQuestion(questionSetId, actionPros));
        }
        return questions;
    }


    /* ========================================================= */
    /*     Low Level Makers
    /* ========================================================= */
    private static EUR_CRM_PRS_Question_Set__c makeQuestionSet() {
        return new EUR_CRM_PRS_Question_Set__c(
            EUR_CRM_IsQuestionsUpdated__c = false
        );
    }

    private static EUR_CRM_PRS_Question__c makeQuestion(Id questionSetId, String actionPros) {
        return new EUR_CRM_PRS_Question__c(
            EUR_CRM_PRS_Question_Set__c = questionSetId
        ,   EUR_CRM_ActionPROS__c = actionPros
        );
    }


    /* ========================================================= */
    /*     SOQL Selectors
    /* ========================================================= */
    private static List<EUR_CRM_PRS_Question_Set__c> selectQuestionSets() {
        return [
            SELECT Id
            ,   EUR_CRM_IsQuestionsUpdated__c
            FROM EUR_CRM_PRS_Question_Set__c
        ];
    }

    private static List<EUR_CRM_PRS_Question__c> selectQuestions() {
        return [
            SELECT Id
            ,   EUR_CRM_ActionPROS__c
            FROM EUR_CRM_PRS_Question__c
        ];
    }

}