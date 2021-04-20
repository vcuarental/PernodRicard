@IsTest(IsParallel=true)
private class EUR_CRM_Test_PRSQuestionsExt {

    private static final String RECORD_TYPE_NAME = 'EUR_BG_PRS_Question_Text_Input';
    private static final Id QUESTION_RT_ID;

    static {
        QUESTION_RT_ID = [
                SELECT Id
                FROM RecordType
                WHERE SobjectType = 'EUR_CRM_PRS_Question__c'
                AND DeveloperName = :RECORD_TYPE_NAME
        ].Id;
    }

    private static EUR_CRM_PRS_Question__c initQuestion() {
        EUR_CRM_PRS_Question_Set__c qSet = new EUR_CRM_PRS_Question_Set__c(
                EUR_CRM_Last_Mass_Update_Date__c = Datetime.now(),
                RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'EUR_CRM_PRS_Question_Set__c' AND DeveloperName = 'EUR_BG_PRS_Question_Set_Business_Potential'].Id
        );
        insert qSet;
        EUR_CRM_PRS_Question__c q = New EUR_CRM_PRS_Question__c(
                EUR_CRM_PRS_Question_Set__c = qSet.Id,
                RecordTypeId = QUESTION_RT_ID
        );
        insert q;
        return q;
    }

    @IsTest
    private static void test1() {
        EUR_CRM_PRS_Question__c q = initQuestion();
        ApexPages.StandardController sc = new ApexPages.StandardController(q);
        EUR_CRM_PRSQuestionsExt ext = new EUR_CRM_PRSQuestionsExt(sc);

        PageReference pageRef = Page.EUR_CRM_PRSQuestionsPage;
        Test.setCurrentPage(pageRef);
    }

    @IsTest
    private static void test2() {
        EUR_CRM_PRS_Question__c q = initQuestion();
        ApexPages.StandardController sc = new ApexPages.StandardController(q);
        EUR_CRM_PRSQuestionsExt ext = new EUR_CRM_PRSQuestionsExt(sc);
        ext.addPossibleAnswer();
    }

    @IsTest
    private static void test3() {
        EUR_CRM_PRS_Question__c q = initQuestion();
        ApexPages.StandardController sc = new ApexPages.StandardController(q);
        EUR_CRM_PRSQuestionsExt ext = new EUR_CRM_PRSQuestionsExt(sc);
        ext.addPossibleAnswer('value', 'label');
    }

    @IsTest
    private static void test4() {
        EUR_CRM_PRS_Question__c q = initQuestion();
        ApexPages.StandardController sc = new ApexPages.StandardController(q);
        EUR_CRM_PRSQuestionsExt ext = new EUR_CRM_PRSQuestionsExt(sc);
        PageReference pageRef = Page.EUR_CRM_PRSQuestionsPage;
        pageRef.getParameters().put('rowIndex', '0');
        Test.setCurrentPage(pageRef);

        ext.deletePossibleAnswer();
    }

    @IsTest
    private static void test5() {
        EUR_CRM_PRS_Question__c q = initQuestion();
        ApexPages.StandardController sc = new ApexPages.StandardController(q);
        EUR_CRM_PRSQuestionsExt ext = new EUR_CRM_PRSQuestionsExt(sc);
        ext.changeAnswerType();
    }

    @IsTest
    private static void test6() {
        EUR_CRM_PRS_Question__c q = initQuestion();
        ApexPages.StandardController sc = new ApexPages.StandardController(q);
        EUR_CRM_PRSQuestionsExt ext = new EUR_CRM_PRSQuestionsExt(sc);
        ext.saveAnswer();
    }

    @IsTest
    private static void test7() {
        EUR_CRM_PRS_Question__c q = initQuestion();
        ApexPages.StandardController sc = new ApexPages.StandardController(q);
        EUR_CRM_PRSQuestionsExt ext = new EUR_CRM_PRSQuestionsExt(sc);
        ext.cancel();
    }
}