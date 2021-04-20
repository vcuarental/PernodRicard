@IsTest  (IsParallel = true)
private class EUR_CRM_PRS_QuestionActionServiceTest {

    private static final String NEED_UPDATE = EUR_CRM_PRS_QuestionActionService.NEED_UPDATE;
    private static final Integer COUNT_OF_RECORDS = 5;


    /* ======================================================================================== */
    /*     Create one EUR_CRM_PRS_Question__c to one EUR_CRM_PRS_Question_Set__c
    /* ======================================================================================== */
    @IsTest
    private static void createOneQuestionWithStatusNewPerOneQuestionSetTest() {
        EUR_CRM_PRS_Question_Set__c questionSet = makeQuestionSet();
        insert questionSet;

        EUR_CRM_PRS_Question__c question = makeQuestion(questionSet.Id, 'New');

        Test.startTest();
        insert question;
        Test.stopTest();

        questionSet = selectQuestionSets()[0];
        System.assertEquals(true, questionSet.EUR_CRM_IsQuestionsUpdated__c);
    }

    @IsTest
    private static void createOneQuestionWithStatusNeedUpdatePerOneQuestionSetTest() {
        EUR_CRM_PRS_Question_Set__c questionSet = makeQuestionSet();
        insert questionSet;

        EUR_CRM_PRS_Question__c question = makeQuestion(questionSet.Id, NEED_UPDATE);

        Test.startTest();
        insert question;
        Test.stopTest();

        questionSet = selectQuestionSets()[0];
        System.assertEquals(true, questionSet.EUR_CRM_IsQuestionsUpdated__c);
    }

    @IsTest
    private static void createOneQuestionWithStatusNoNeedUpdatePerOneQuestionSetTest() {
        EUR_CRM_PRS_Question_Set__c questionSet = makeQuestionSet();
        insert questionSet;

        EUR_CRM_PRS_Question__c question = makeQuestion(questionSet.Id, 'No Need Update');

        Test.startTest();
        insert question;
        Test.stopTest();

        questionSet = selectQuestionSets()[0];
        System.assertEquals(true, questionSet.EUR_CRM_IsQuestionsUpdated__c);
    }


    /* ======================================================================================== */
    /*     Create many EUR_CRM_PRS_Question__c to one EUR_CRM_PRS_Question_Set__c
    /* ======================================================================================== */
    @IsTest
    private static void createManyQuestionsWithStatusNewPerOneQuestionSetTest() {
        EUR_CRM_PRS_Question_Set__c questionSet = makeQuestionSet();
        insert questionSet;

        List<EUR_CRM_PRS_Question__c> questions = makeQuestions(questionSet.Id, 'New');

        Test.startTest();
        insert questions;
        Test.stopTest();

        questionSet = selectQuestionSets()[0];
        System.assertEquals(true, questionSet.EUR_CRM_IsQuestionsUpdated__c);
    }

    @IsTest
    private static void createManyQuestionsWithStatusNeedUpdatePerOneQuestionSetTest() {
        EUR_CRM_PRS_Question_Set__c questionSet = makeQuestionSet();
        insert questionSet;

        List<EUR_CRM_PRS_Question__c> questions = makeQuestions(questionSet.Id, NEED_UPDATE);

        Test.startTest();
        insert questions;
        Test.stopTest();

        questionSet = selectQuestionSets()[0];
        System.assertEquals(true, questionSet.EUR_CRM_IsQuestionsUpdated__c);
    }

    @IsTest
    private static void createManyQuestionsWithStatusNoNeedUpdatePerOneQuestionSetTest() {
        EUR_CRM_PRS_Question_Set__c questionSet = makeQuestionSet();
        insert questionSet;

        List<EUR_CRM_PRS_Question__c> questions = makeQuestions(questionSet.Id, 'No Need Update');

        Test.startTest();
        insert questions;
        Test.stopTest();

        questionSet = selectQuestionSets()[0];
        System.assertEquals(true, questionSet.EUR_CRM_IsQuestionsUpdated__c);
    }


    /* ======================================================================================== */
    /*     Create many EUR_CRM_PRS_Question__c to many EUR_CRM_PRS_Question_Set__c
    /* ======================================================================================== */
    @IsTest
    private static void createManyQuestionsWithStatusNewPerManyQuestionSetsTest() {
        List<EUR_CRM_PRS_Question_Set__c> questionSets = makeQuestionSets();
        insert questionSets;

        List<EUR_CRM_PRS_Question__c> questions = new List<EUR_CRM_PRS_Question__c>();
        for (EUR_CRM_PRS_Question_Set__c questionSet : questionSets) {
            questions.addAll(makeQuestions(questionSet.Id, 'New'));
        }

        Test.startTest();
        insert questions;
        Test.stopTest();

        questionSets = selectQuestionSets();
        System.assertEquals(COUNT_OF_RECORDS, questionSets.size());
        for (EUR_CRM_PRS_Question_Set__c questionSet : questionSets) {
            System.assertEquals(true, questionSet.EUR_CRM_IsQuestionsUpdated__c);
        }
    }

    @IsTest
    private static void createManyQuestionsWithStatusNeedUpdatePerManyQuestionSetsTest() {
        List<EUR_CRM_PRS_Question_Set__c> questionSets = makeQuestionSets();
        insert questionSets;

        List<EUR_CRM_PRS_Question__c> questions = new List<EUR_CRM_PRS_Question__c>();
        for (EUR_CRM_PRS_Question_Set__c questionSet : questionSets) {
            questions.addAll(makeQuestions(questionSet.Id, NEED_UPDATE));
        }

        Test.startTest();
        insert questions;
        Test.stopTest();

        questionSets = selectQuestionSets();
        System.assertEquals(COUNT_OF_RECORDS, questionSets.size());
        for (EUR_CRM_PRS_Question_Set__c questionSet : questionSets) {
            System.assertEquals(true, questionSet.EUR_CRM_IsQuestionsUpdated__c);
        }
    }

    @IsTest
    private static void createManyQuestionsWithStatusNoNeedUpdatePerManyQuestionSetsTest() {
        List<EUR_CRM_PRS_Question_Set__c> questionSets = makeQuestionSets();
        insert questionSets;

        List<EUR_CRM_PRS_Question__c> questions = new List<EUR_CRM_PRS_Question__c>();
        for (EUR_CRM_PRS_Question_Set__c questionSet : questionSets) {
            questions.addAll(makeQuestions(questionSet.Id, 'No Need Update'));
        }

        Test.startTest();
        insert questions;
        Test.stopTest();

        questionSets = selectQuestionSets();
        System.assertEquals(COUNT_OF_RECORDS, questionSets.size());
        for (EUR_CRM_PRS_Question_Set__c questionSet : questionSets) {
            System.assertEquals(true, questionSet.EUR_CRM_IsQuestionsUpdated__c);
        }
    }

    @IsTest
    private static void createManyQuestionsWithDifferentStatusesPerManyQuestionSetsTest() {
        List<EUR_CRM_PRS_Question_Set__c> questionSets = makeQuestionSets();
        insert questionSets;

        List<EUR_CRM_PRS_Question__c> questions = new List<EUR_CRM_PRS_Question__c>();
        for (EUR_CRM_PRS_Question_Set__c questionSet : questionSets) {
            questions.add(makeQuestion(questionSet.Id, 'New'));
            questions.add(makeQuestion(questionSet.Id, NEED_UPDATE));
            questions.add(makeQuestion(questionSet.Id, 'No Need Update'));
        }

        Test.startTest();
        insert questions;
        Test.stopTest();

        questionSets = selectQuestionSets();
        System.assertEquals(COUNT_OF_RECORDS, questionSets.size());
        for (EUR_CRM_PRS_Question_Set__c questionSet : questionSets) {
            System.assertEquals(true, questionSet.EUR_CRM_IsQuestionsUpdated__c);
        }
    }


    /* ======================================================================================== */
    /*     Update one EUR_CRM_PRS_Question__c to one EUR_CRM_PRS_Question_Set__c
    /* ======================================================================================== */
    @IsTest
    private static void updateOneQuestionToStatusNeedUpdatePerOneQuestionSetTest() {
        EUR_CRM_PRS_Question_Set__c questionSet = makeQuestionSet();
        insert questionSet;

        EUR_CRM_PRS_Question__c question = makeQuestion(questionSet.Id, 'New');
        insert question;

        questionSet = selectQuestionSets()[0];
        System.assertEquals(true, questionSet.EUR_CRM_IsQuestionsUpdated__c);

        questionSet.EUR_CRM_IsQuestionsUpdated__c = false;
        update questionSet;

        questionSet = selectQuestionSets()[0];
        System.assertEquals(false, questionSet.EUR_CRM_IsQuestionsUpdated__c);

        Test.startTest();
        question.EUR_CRM_ActionPROS__c = NEED_UPDATE;
        update question;
        Test.stopTest();

        questionSet = selectQuestionSets()[0];
        System.assertEquals(true, questionSet.EUR_CRM_IsQuestionsUpdated__c);
    }

    @IsTest
    private static void updateOneQuestionToStatusNoNeedUpdatePerOneQuestionSetTest() {
        EUR_CRM_PRS_Question_Set__c questionSet = makeQuestionSet();
        insert questionSet;

        EUR_CRM_PRS_Question__c question = makeQuestion(questionSet.Id, 'New');
        insert question;

        questionSet = selectQuestionSets()[0];
        System.assertEquals(true, questionSet.EUR_CRM_IsQuestionsUpdated__c);

        questionSet.EUR_CRM_IsQuestionsUpdated__c = false;
        update questionSet;

        questionSet = selectQuestionSets()[0];
        System.assertEquals(false, questionSet.EUR_CRM_IsQuestionsUpdated__c);

        Test.startTest();
        question.EUR_CRM_ActionPROS__c = 'No Need Update';
        update question;
        Test.stopTest();

        questionSet = selectQuestionSets()[0];
        System.assertEquals(false, questionSet.EUR_CRM_IsQuestionsUpdated__c);
    }


    /* ======================================================================================== */
    /*     Update many EUR_CRM_PRS_Question__c to one EUR_CRM_PRS_Question_Set__c
    /* ======================================================================================== */
    @IsTest
    private static void updateManyQuestionsToStatusNeedUpdatePerOneQuestionSetTest() {
        EUR_CRM_PRS_Question_Set__c questionSet = makeQuestionSet();
        insert questionSet;

        List<EUR_CRM_PRS_Question__c> questions = makeQuestions(questionSet.Id, 'New');
        insert questions;

        questionSet = selectQuestionSets()[0];
        System.assertEquals(true, questionSet.EUR_CRM_IsQuestionsUpdated__c);

        questionSet.EUR_CRM_IsQuestionsUpdated__c = false;
        update questionSet;

        questionSet = selectQuestionSets()[0];
        System.assertEquals(false, questionSet.EUR_CRM_IsQuestionsUpdated__c);

        Test.startTest();
        for (EUR_CRM_PRS_Question__c question : questions) {
            question.EUR_CRM_ActionPROS__c = NEED_UPDATE;
        }

        update questions;
        Test.stopTest();

        questionSet = selectQuestionSets()[0];
        System.assertEquals(true, questionSet.EUR_CRM_IsQuestionsUpdated__c);
    }

    @IsTest
    private static void updateManyQuestionsToStatusNoNeedUpdatePerOneQuestionSetTest() {
        EUR_CRM_PRS_Question_Set__c questionSet = makeQuestionSet();
        insert questionSet;

        List<EUR_CRM_PRS_Question__c> questions = makeQuestions(questionSet.Id, 'New');
        insert questions;

        questionSet = selectQuestionSets()[0];
        System.assertEquals(true, questionSet.EUR_CRM_IsQuestionsUpdated__c);

        questionSet.EUR_CRM_IsQuestionsUpdated__c = false;
        update questionSet;

        questionSet = selectQuestionSets()[0];
        System.assertEquals(false, questionSet.EUR_CRM_IsQuestionsUpdated__c);

        Test.startTest();
        for (EUR_CRM_PRS_Question__c question : questions) {
            question.EUR_CRM_ActionPROS__c = 'No Need Update';
        }

        update questions;
        Test.stopTest();

        questionSet = selectQuestionSets()[0];
        System.assertEquals(false, questionSet.EUR_CRM_IsQuestionsUpdated__c);
    }


    /* ======================================================================================== */
    /*     Update many EUR_CRM_PRS_Question__c to many EUR_CRM_PRS_Question_Set__c
    /* ======================================================================================== */
    @IsTest
    private static void updateManyQuestionsWithStatusNeedUpdatePerManyQuestionSetsTest() {
        List<EUR_CRM_PRS_Question_Set__c> questionSets = makeQuestionSets();
        insert questionSets;

        List<EUR_CRM_PRS_Question__c> questions = new List<EUR_CRM_PRS_Question__c>();
        for (EUR_CRM_PRS_Question_Set__c questionSet : questionSets) {
            questions.addAll(makeQuestions(questionSet.Id, 'New'));
        }
        insert questions;

        questionSets = selectQuestionSets();
        System.assertEquals(COUNT_OF_RECORDS, questionSets.size());
        for (EUR_CRM_PRS_Question_Set__c questionSet : questionSets) {
            System.assertEquals(true, questionSet.EUR_CRM_IsQuestionsUpdated__c);
        }

        for (EUR_CRM_PRS_Question_Set__c questionSet : questionSets) {
            questionSet.EUR_CRM_IsQuestionsUpdated__c = false;
        }
        update questionSets;

        questionSets = selectQuestionSets();
        for (EUR_CRM_PRS_Question_Set__c questionSet : questionSets) {
            System.assertEquals(false, questionSet.EUR_CRM_IsQuestionsUpdated__c);
        }

        Test.startTest();
        for (EUR_CRM_PRS_Question__c question : questions) {
            question.EUR_CRM_ActionPROS__c = NEED_UPDATE;
        }

        update questions;
        Test.stopTest();

        questionSets = selectQuestionSets();
        System.assertEquals(COUNT_OF_RECORDS, questionSets.size());
        for (EUR_CRM_PRS_Question_Set__c questionSet : questionSets) {
            System.assertEquals(true, questionSet.EUR_CRM_IsQuestionsUpdated__c);
        }
    }

    @IsTest
    private static void updateManyQuestionsWithStatusNoNeedUpdatePerManyQuestionSetsTest() {
        List<EUR_CRM_PRS_Question_Set__c> questionSets = makeQuestionSets();
        insert questionSets;

        List<EUR_CRM_PRS_Question__c> questions = new List<EUR_CRM_PRS_Question__c>();
        for (EUR_CRM_PRS_Question_Set__c questionSet : questionSets) {
            questions.addAll(makeQuestions(questionSet.Id, 'New'));
        }
        insert questions;

        questionSets = selectQuestionSets();
        System.assertEquals(COUNT_OF_RECORDS, questionSets.size());
        for (EUR_CRM_PRS_Question_Set__c questionSet : questionSets) {
            System.assertEquals(true, questionSet.EUR_CRM_IsQuestionsUpdated__c);
        }

        for (EUR_CRM_PRS_Question_Set__c questionSet : questionSets) {
            questionSet.EUR_CRM_IsQuestionsUpdated__c = false;
        }
        update questionSets;

        questionSets = selectQuestionSets();
        for (EUR_CRM_PRS_Question_Set__c questionSet : questionSets) {
            System.assertEquals(false, questionSet.EUR_CRM_IsQuestionsUpdated__c);
        }

        Test.startTest();
        for (EUR_CRM_PRS_Question__c question : questions) {
            question.EUR_CRM_ActionPROS__c = 'No Need Update';
        }

        update questions;
        Test.stopTest();

        questionSets = selectQuestionSets();
        System.assertEquals(COUNT_OF_RECORDS, questionSets.size());
        for (EUR_CRM_PRS_Question_Set__c questionSet : questionSets) {
            System.assertEquals(false, questionSet.EUR_CRM_IsQuestionsUpdated__c);
        }
    }

    @IsTest
    private static void updateManyQuestionsToDifferentStatusesPerManyQuestionSetsTest() {
        List<EUR_CRM_PRS_Question_Set__c> questionSets = makeQuestionSets();
        insert questionSets;

        List<EUR_CRM_PRS_Question__c> questions = new List<EUR_CRM_PRS_Question__c>();
        for (EUR_CRM_PRS_Question_Set__c questionSet : questionSets) {
            questions.addAll(makeQuestions(questionSet.Id, 'New'));
        }
        insert questions;

        questionSets = selectQuestionSets();
        System.assertEquals(COUNT_OF_RECORDS, questionSets.size());
        for (EUR_CRM_PRS_Question_Set__c questionSet : questionSets) {
            System.assertEquals(true, questionSet.EUR_CRM_IsQuestionsUpdated__c);
        }

        for (EUR_CRM_PRS_Question_Set__c questionSet : questionSets) {
            questionSet.EUR_CRM_IsQuestionsUpdated__c = false;
        }
        update questionSets;

        questionSets = selectQuestionSets();
        for (EUR_CRM_PRS_Question_Set__c questionSet : questionSets) {
            System.assertEquals(false, questionSet.EUR_CRM_IsQuestionsUpdated__c);
        }

        Test.startTest();
        for (Integer i = 0; i < questionSets.size(); i++) {
            questions[i * COUNT_OF_RECORDS].EUR_CRM_ActionPROS__c = NEED_UPDATE;
            questions[i * COUNT_OF_RECORDS + 1].EUR_CRM_ActionPROS__c = 'No Need Update';
        }

        update questions;
        Test.stopTest();

        questionSets = selectQuestionSets();
        System.assertEquals(COUNT_OF_RECORDS, questionSets.size());
        for (EUR_CRM_PRS_Question_Set__c questionSet : questionSets) {
            System.assertEquals(true, questionSet.EUR_CRM_IsQuestionsUpdated__c);
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

}