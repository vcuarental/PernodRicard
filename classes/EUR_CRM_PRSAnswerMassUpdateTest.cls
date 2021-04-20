@IsTest
private class EUR_CRM_PRSAnswerMassUpdateTest {

    private static EUR_CRM_PRS_Segmentation__c segmentation;
    private static EUR_CRM_PRS_Question__c ILquestion1;
    private static EUR_CRM_PRS_Question__c ILquestion2;
    private static EUR_CRM_PRS_Question__c VPquestion1;
    private static EUR_CRM_PRS_Answer__c ILanswer11;
    private static EUR_CRM_PRS_Answer__c ILanswer12;
    private static EUR_CRM_PRS_Answer__c ILanswer21;
    private static EUR_CRM_PRS_Answer__c ILanswer22;
    private static EUR_CRM_PRS_Answer__c VPanswer11;
    private static EUR_CRM_PRS_Answer__c VPanswer12;
    private static EUR_CRM_PRS_Answer__c VPanswer13;

    private static void insertData() {
        EUR_CRM_PRS_Question_Set__c imgLvlQuestionSet = makeQuestionSet('EUR_NL_PRS_Question_Set_Image_Level');
        EUR_CRM_PRS_Question_Set__c volPotQuestionSet = makeQuestionSet('EUR_NL_PRS_Question_Set_Volume_Potential');
        insert new List<EUR_CRM_PRS_Question_Set__c> { imgLvlQuestionSet, volPotQuestionSet} ;

        ILquestion1 = makeQuestion(imgLvlQuestionSet.Id, 'EUR_NL_PRS_Question_Boolean_Input');
        ILquestion1.EUR_CRM_Question_Weight__c = 25;
        ILquestion1.EUR_CRM_Weight_Has_Changed__c = true;
        ILquestion2 = makeQuestion(imgLvlQuestionSet.Id, 'EUR_NL_PRS_Question_Currency_Input');
        ILquestion2.EUR_CRM_Question_Weight__c = 35;
        ILquestion2.EUR_CRM_Weight_Has_Changed__c = true;
        VPquestion1 = makeQuestion(volPotQuestionSet.Id, 'EUR_NL_PRS_Question_Number_Input');
        VPquestion1.EUR_CRM_Question_Weight__c = 50;
        VPquestion1.EUR_CRM_Weight_Has_Changed__c = true;
        insert new List<EUR_CRM_PRS_Question__c>{ ILquestion1, ILquestion2, VPquestion1 };

        EUR_CRM_Account__c account = makeAccount('EUR_NL_On_Trade');
        insert account;

        segmentation = makeSegmentation('EUR_PRS_Segmentation_On_Trade');
        segmentation.EUR_CRM_Account__c = account.Id;
        insert segmentation;

        ILanswer11 = makeAnswer(segmentation.Id, ILquestion1.Id, 'EUR_PRS_Answer_Image_Level', 'true');
        ILanswer12 = makeAnswer(segmentation.Id, ILquestion1.Id, 'EUR_PRS_Answer_Image_Level', 'false');
        ILanswer21 = makeAnswer(segmentation.Id, ILquestion2.Id, 'EUR_PRS_Answer_Image_Level', '15');
        ILanswer22 = makeAnswer(segmentation.Id, ILquestion2.Id, 'EUR_PRS_Answer_Image_Level', '25');

        VPanswer11 = makeAnswer(segmentation.Id, VPquestion1.Id, 'EUR_PRS_Answer_Volume_Potential', '500');
        VPanswer12 = makeAnswer(segmentation.Id, VPquestion1.Id, 'EUR_PRS_Answer_Volume_Potential', '700');
        VPanswer13 = makeAnswer(segmentation.Id, VPquestion1.Id, 'EUR_PRS_Answer_Volume_Potential', '150');
        List<EUR_CRM_PRS_Answer__c> answers = new List<EUR_CRM_PRS_Answer__c>{ILanswer11, ILanswer12, ILanswer21, ILanswer22, VPanswer11, VPanswer12, VPanswer13};
        insert answers;

        EUR_CRM_PRS_Question_Criteria__c ILcriteria11 = makeQuestionCriteria(ILquestion1.Id, 'EUR_NL_PRS_Question_Criteria');
        ILcriteria11.EUR_CRM_Criteria_Picklist_Value__c = 'true';
        ILcriteria11.EUR_CRM_Criteria_Weight__c = 50;
        EUR_CRM_PRS_Question_Criteria__c ILcriteria12 = makeQuestionCriteria(ILquestion1.Id, 'EUR_NL_PRS_Question_Criteria');
        ILcriteria12.EUR_CRM_Criteria_Picklist_Value__c = 'false';
        ILcriteria12.EUR_CRM_Criteria_Weight__c = 0;
        EUR_CRM_PRS_Question_Criteria__c ILcriteria21 = makeQuestionCriteria(ILquestion2.Id, 'EUR_NL_PRS_Question_Criteria');
        ILcriteria21.EUR_CRM_Answer_Condition__c = 'Less than (<)';
        ILcriteria21.EUR_CRM_Criteria_Threshold_Currency__c = 10;
        ILcriteria21.EUR_CRM_Criteria_Weight__c = 0;
        EUR_CRM_PRS_Question_Criteria__c ILcriteria22 = makeQuestionCriteria(ILquestion2.Id, 'EUR_NL_PRS_Question_Criteria');
        ILcriteria22.EUR_CRM_Answer_Condition__c = 'Less than (<)';
        ILcriteria22.EUR_CRM_Criteria_Threshold_Currency__c = 20;
        ILcriteria22.EUR_CRM_Criteria_Weight__c = 10;
        EUR_CRM_PRS_Question_Criteria__c ILcriteria23 = makeQuestionCriteria(ILquestion2.Id, 'EUR_NL_PRS_Question_Criteria');
        ILcriteria23.EUR_CRM_Answer_Condition__c = 'Greater Than or Equal (>=)';
        ILcriteria23.EUR_CRM_Criteria_Threshold_Currency__c = 20;
        ILcriteria23.EUR_CRM_Criteria_Weight__c = 20;
        EUR_CRM_PRS_Question_Criteria__c ILcriteria24 = makeQuestionCriteria(ILquestion2.Id, 'EUR_NL_PRS_Question_Criteria');
        ILcriteria24.EUR_CRM_Answer_Condition__c = 'Greater Than or Equal (>=)';
        ILcriteria24.EUR_CRM_Criteria_Threshold_Currency__c = 30;
        ILcriteria24.EUR_CRM_Criteria_Weight__c = 30;
        EUR_CRM_PRS_Question_Criteria__c ILcriteria25 = makeQuestionCriteria(ILquestion2.Id, 'EUR_NL_PRS_Question_Criteria');
        ILcriteria25.EUR_CRM_Answer_Condition__c = 'Greater Than or Equal (>=)';
        ILcriteria25.EUR_CRM_Criteria_Threshold_Currency__c = 25;
        ILcriteria25.EUR_CRM_Criteria_Weight__c = 25;
        EUR_CRM_PRS_Question_Criteria__c ILcriteria26 = makeQuestionCriteria(ILquestion2.Id, 'EUR_NL_PRS_Question_Criteria');
        ILcriteria26.EUR_CRM_Answer_Condition__c = 'Greater Than or Equal (>=)';
        ILcriteria26.EUR_CRM_Criteria_Threshold_Currency__c = 40;
        ILcriteria26.EUR_CRM_Criteria_Weight__c = 40;
        EUR_CRM_PRS_Question_Criteria__c ILcriteria27 = makeQuestionCriteria(ILquestion2.Id, 'EUR_NL_PRS_Question_Criteria');
        ILcriteria27.EUR_CRM_Answer_Condition__c = 'Greater Than or Equal (>=)';
        ILcriteria27.EUR_CRM_Criteria_Threshold_Currency__c = 50;
        ILcriteria27.EUR_CRM_Criteria_Weight__c = 50;

        EUR_CRM_PRS_Question_Criteria__c VPcriteria11 = makeQuestionCriteria(VPquestion1.Id, 'EUR_NL_PRS_Question_Criteria');
        VPcriteria11.EUR_CRM_Answer_Condition__c = 'Greater Than or Equal (>=)';
        VPcriteria11.EUR_CRM_Criteria_Threshold_Number__c = 400;
        VPcriteria11.EUR_CRM_Criteria_Weight__c = 30;
        EUR_CRM_PRS_Question_Criteria__c VPcriteria12 = makeQuestionCriteria(VPquestion1.Id, 'EUR_NL_PRS_Question_Criteria');
        VPcriteria12.EUR_CRM_Answer_Condition__c = 'Greater Than or Equal (>=)';
        VPcriteria12.EUR_CRM_Criteria_Threshold_Number__c = 600;
        VPcriteria12.EUR_CRM_Criteria_Weight__c = 60;
        EUR_CRM_PRS_Question_Criteria__c VPcriteria13 = makeQuestionCriteria(VPquestion1.Id, 'EUR_NL_PRS_Question_Criteria');
        VPcriteria13.EUR_CRM_Answer_Condition__c = 'Greater Than or Equal (>=)';
        VPcriteria13.EUR_CRM_Criteria_Threshold_Number__c = 900;
        VPcriteria13.EUR_CRM_Criteria_Weight__c = 100;
        EUR_CRM_PRS_Question_Criteria__c VPcriteria14 = makeQuestionCriteria(VPquestion1.Id, 'EUR_NL_PRS_Question_Criteria');
        VPcriteria14.EUR_CRM_Answer_Condition__c = 'Less than (<)';
        VPcriteria14.EUR_CRM_Criteria_Threshold_Number__c = 400;
        VPcriteria14.EUR_CRM_Criteria_Weight__c = 20;
        EUR_CRM_PRS_Question_Criteria__c VPcriteria15 = makeQuestionCriteria(VPquestion1.Id, 'EUR_NL_PRS_Question_Criteria');
        VPcriteria15.EUR_CRM_Answer_Condition__c = 'Less than (<)';
        VPcriteria15.EUR_CRM_Criteria_Threshold_Number__c = 300;
        VPcriteria15.EUR_CRM_Criteria_Weight__c = 10;
        EUR_CRM_PRS_Question_Criteria__c VPcriteria16 = makeQuestionCriteria(VPquestion1.Id, 'EUR_NL_PRS_Question_Criteria');
        VPcriteria16.EUR_CRM_Answer_Condition__c = 'Less than (<)';
        VPcriteria16.EUR_CRM_Criteria_Threshold_Number__c = 100;
        VPcriteria16.EUR_CRM_Criteria_Weight__c = 5;
        List<EUR_CRM_PRS_Question_Criteria__c> questionCriteria = new List<EUR_CRM_PRS_Question_Criteria__c>{
            ILcriteria11, ILcriteria12, ILcriteria21, ILcriteria22, ILcriteria23, ILcriteria24, ILcriteria25, ILcriteria26, ILcriteria27,
            VPcriteria11, VPcriteria12, VPcriteria13, VPcriteria14, VPcriteria15, VPcriteria16
        };
        insert questionCriteria;
    }

    @IsTest
    private static void insertDataTest() {
        insertData();
        System.assertEquals(1, selectAccounts().size());
        System.assertEquals(2, selectSegmentations().size()); // 1 PRS Segmentation insert during trigger on account after insert worked.
        System.assertEquals(3, selectQuestions().size());
        System.assertEquals(7, selectAnswers().size());
        System.assertEquals(15, selectCriteria().size());

        System.assertEquals(true, ILquestion1.EUR_CRM_Weight_Has_Changed__c);
        System.assertEquals(true, ILquestion2.EUR_CRM_Weight_Has_Changed__c);
        System.assertEquals(true, VPquestion1.EUR_CRM_Weight_Has_Changed__c);
    }


    /*===================================================
   *   Image Level Tests
   * ===================================================*/
    @IsTest
    private static void ImageLevel_PositiveTest() {
        insertData();
        Test.startTest();
        Database.executeBatch(new EUR_CRM_PRSAnswerMassUpdate('%image%','NL'));
        Test.stopTest();

        Map<Id, EUR_CRM_PRS_Answer__c> answerById = new Map<Id, EUR_CRM_PRS_Answer__c>(selectAnswers());
        System.assertEquals(12.5, answerById.get(ILanswer11.Id).EUR_CRM_Weight__c);
        System.assertEquals(0, answerById.get(ILanswer12.Id).EUR_CRM_Weight__c);
        System.assertEquals(3.5, answerById.get(ILanswer21.Id).EUR_CRM_Weight__c);
        System.assertEquals(8.75, answerById.get(ILanswer22.Id).EUR_CRM_Weight__c);
        System.assertEquals(null, answerById.get(VPanswer11.Id).EUR_CRM_Weight__c);
        System.assertEquals(null, answerById.get(VPanswer12.Id).EUR_CRM_Weight__c);
        System.assertEquals(null, answerById.get(VPanswer13.Id).EUR_CRM_Weight__c);

        Map<Id, EUR_CRM_PRS_Question__c> questionById = new Map<Id, EUR_CRM_PRS_Question__c> (selectQuestions());
        System.assertEquals(false, questionById.get(ILquestion1.Id).EUR_CRM_Weight_Has_Changed__c);
        System.assertEquals(false, questionById.get(ILquestion2.Id).EUR_CRM_Weight_Has_Changed__c);
        System.assertEquals(true, questionById.get(VPquestion1.Id).EUR_CRM_Weight_Has_Changed__c);
    }

    @IsTest
    private static void ImageLevelQuestionWeightHasChangedIsFalse_NegativeTest() {
        insertData();
        ILquestion1.EUR_CRM_Weight_Has_Changed__c = false;
        ILquestion2.EUR_CRM_Weight_Has_Changed__c = false;
        VPquestion1.EUR_CRM_Weight_Has_Changed__c = false;
        update new List<EUR_CRM_PRS_Question__c>{ ILquestion1, ILquestion2, VPquestion1 };

        Test.startTest();
        Database.executeBatch(new EUR_CRM_PRSAnswerMassUpdate('%image%','NL'));
        Test.stopTest();

        Map<Id, EUR_CRM_PRS_Answer__c> answerById = new Map<Id, EUR_CRM_PRS_Answer__c>(selectAnswers());
        System.assertEquals(null, answerById.get(ILanswer11.Id).EUR_CRM_Weight__c);
        System.assertEquals(null, answerById.get(ILanswer12.Id).EUR_CRM_Weight__c);
        System.assertEquals(null, answerById.get(ILanswer21.Id).EUR_CRM_Weight__c);
        System.assertEquals(null, answerById.get(ILanswer22.Id).EUR_CRM_Weight__c);
        System.assertEquals(null, answerById.get(VPanswer11.Id).EUR_CRM_Weight__c);
        System.assertEquals(null, answerById.get(VPanswer12.Id).EUR_CRM_Weight__c);
        System.assertEquals(null, answerById.get(VPanswer13.Id).EUR_CRM_Weight__c);

        Map<Id, EUR_CRM_PRS_Question__c> questionById = new Map<Id, EUR_CRM_PRS_Question__c> (selectQuestions());
        System.assertEquals(false, questionById.get(ILquestion1.Id).EUR_CRM_Weight_Has_Changed__c);
        System.assertEquals(false, questionById.get(ILquestion2.Id).EUR_CRM_Weight_Has_Changed__c);
        System.assertEquals(false, questionById.get(VPquestion1.Id).EUR_CRM_Weight_Has_Changed__c);
    }

    @IsTest
    private static void ImageLevelQuestionWeightIsNull_NegativeTest() {
        insertData();
        ILquestion1.EUR_CRM_Question_Weight__c = null;
        ILquestion2.EUR_CRM_Question_Weight__c = null;
        VPquestion1.EUR_CRM_Question_Weight__c = null;
        update new List<EUR_CRM_PRS_Question__c>{ ILquestion1, ILquestion2, VPquestion1 };

        Test.startTest();
        Database.executeBatch(new EUR_CRM_PRSAnswerMassUpdate('%image%','NL'));
        Test.stopTest();

        Map<Id, EUR_CRM_PRS_Answer__c> answerById = new Map<Id, EUR_CRM_PRS_Answer__c>(selectAnswers());
        System.assertEquals(null, answerById.get(ILanswer11.Id).EUR_CRM_Weight__c);
        System.assertEquals(null, answerById.get(ILanswer12.Id).EUR_CRM_Weight__c);
        System.assertEquals(null, answerById.get(ILanswer21.Id).EUR_CRM_Weight__c);
        System.assertEquals(null, answerById.get(ILanswer22.Id).EUR_CRM_Weight__c);
        System.assertEquals(null, answerById.get(VPanswer11.Id).EUR_CRM_Weight__c);
        System.assertEquals(null, answerById.get(VPanswer12.Id).EUR_CRM_Weight__c);
        System.assertEquals(null, answerById.get(VPanswer13.Id).EUR_CRM_Weight__c);

        Map<Id, EUR_CRM_PRS_Question__c> questionById = new Map<Id, EUR_CRM_PRS_Question__c> (selectQuestions());
        System.assertEquals(true, questionById.get(ILquestion1.Id).EUR_CRM_Weight_Has_Changed__c);
        System.assertEquals(true, questionById.get(ILquestion2.Id).EUR_CRM_Weight_Has_Changed__c);
        System.assertEquals(true, questionById.get(VPquestion1.Id).EUR_CRM_Weight_Has_Changed__c);
    }


    /*===================================================
  *   Volume Potential Tests
  * ===================================================*/
    @IsTest
    private static void VolumePotential_PositiveTest() {
        insertData();
        Test.startTest();
        Database.executeBatch(new EUR_CRM_PRSAnswerMassUpdate('%volume%','NL'));
        Test.stopTest();

        Map<Id, EUR_CRM_PRS_Answer__c> answerById = new Map<Id, EUR_CRM_PRS_Answer__c>(selectAnswers());
        System.assertEquals(null, answerById.get(ILanswer11.Id).EUR_CRM_Weight__c);
        System.assertEquals(null, answerById.get(ILanswer12.Id).EUR_CRM_Weight__c);
        System.assertEquals(null, answerById.get(ILanswer21.Id).EUR_CRM_Weight__c);
        System.assertEquals(null, answerById.get(ILanswer22.Id).EUR_CRM_Weight__c);
        System.assertEquals(15, answerById.get(VPanswer11.Id).EUR_CRM_Weight__c);
        System.assertEquals(30, answerById.get(VPanswer12.Id).EUR_CRM_Weight__c);
        System.assertEquals(5, answerById.get(VPanswer13.Id).EUR_CRM_Weight__c);

        Map<Id, EUR_CRM_PRS_Question__c> questionById = new Map<Id, EUR_CRM_PRS_Question__c> (selectQuestions());
        System.assertEquals(true, questionById.get(ILquestion1.Id).EUR_CRM_Weight_Has_Changed__c);
        System.assertEquals(true, questionById.get(ILquestion2.Id).EUR_CRM_Weight_Has_Changed__c);
        System.assertEquals(false, questionById.get(VPquestion1.Id).EUR_CRM_Weight_Has_Changed__c);
    }

    @IsTest
    private static void VolumePotentialQuestionWeightHasChangedIsFalse_NegativeTest() {
        insertData();
        ILquestion1.EUR_CRM_Weight_Has_Changed__c = false;
        ILquestion2.EUR_CRM_Weight_Has_Changed__c = false;
        VPquestion1.EUR_CRM_Weight_Has_Changed__c = false;
        update new List<EUR_CRM_PRS_Question__c>{ ILquestion1, ILquestion2, VPquestion1 };

        Test.startTest();
        Database.executeBatch(new EUR_CRM_PRSAnswerMassUpdate('%volume%','NL'));
        Test.stopTest();

        Map<Id, EUR_CRM_PRS_Answer__c> answerById = new Map<Id, EUR_CRM_PRS_Answer__c>(selectAnswers());
        System.assertEquals(null, answerById.get(ILanswer11.Id).EUR_CRM_Weight__c);
        System.assertEquals(null, answerById.get(ILanswer12.Id).EUR_CRM_Weight__c);
        System.assertEquals(null, answerById.get(ILanswer21.Id).EUR_CRM_Weight__c);
        System.assertEquals(null, answerById.get(ILanswer22.Id).EUR_CRM_Weight__c);
        System.assertEquals(null, answerById.get(VPanswer11.Id).EUR_CRM_Weight__c);
        System.assertEquals(null, answerById.get(VPanswer12.Id).EUR_CRM_Weight__c);
        System.assertEquals(null, answerById.get(VPanswer13.Id).EUR_CRM_Weight__c);

        Map<Id, EUR_CRM_PRS_Question__c> questionById = new Map<Id, EUR_CRM_PRS_Question__c> (selectQuestions());
        System.assertEquals(false, questionById.get(ILquestion1.Id).EUR_CRM_Weight_Has_Changed__c);
        System.assertEquals(false, questionById.get(ILquestion2.Id).EUR_CRM_Weight_Has_Changed__c);
        System.assertEquals(false, questionById.get(VPquestion1.Id).EUR_CRM_Weight_Has_Changed__c);
    }

    @IsTest
    private static void VolumePotentialQuestionWeightIsNull_NegativeTest() {
        insertData();
        ILquestion1.EUR_CRM_Question_Weight__c = null;
        ILquestion2.EUR_CRM_Question_Weight__c = null;
        VPquestion1.EUR_CRM_Question_Weight__c = null;
        update new List<EUR_CRM_PRS_Question__c>{ ILquestion1, ILquestion2, VPquestion1 };

        Test.startTest();
        Database.executeBatch(new EUR_CRM_PRSAnswerMassUpdate('%volume%','NL'));
        Test.stopTest();

        Map<Id, EUR_CRM_PRS_Answer__c> answerById = new Map<Id, EUR_CRM_PRS_Answer__c>(selectAnswers());
        System.assertEquals(null, answerById.get(ILanswer11.Id).EUR_CRM_Weight__c);
        System.assertEquals(null, answerById.get(ILanswer12.Id).EUR_CRM_Weight__c);
        System.assertEquals(null, answerById.get(ILanswer21.Id).EUR_CRM_Weight__c);
        System.assertEquals(null, answerById.get(ILanswer22.Id).EUR_CRM_Weight__c);
        System.assertEquals(null, answerById.get(VPanswer11.Id).EUR_CRM_Weight__c);
        System.assertEquals(null, answerById.get(VPanswer12.Id).EUR_CRM_Weight__c);
        System.assertEquals(null, answerById.get(VPanswer13.Id).EUR_CRM_Weight__c);

        Map<Id, EUR_CRM_PRS_Question__c> questionById = new Map<Id, EUR_CRM_PRS_Question__c> (selectQuestions());
        System.assertEquals(true, questionById.get(ILquestion1.Id).EUR_CRM_Weight_Has_Changed__c);
        System.assertEquals(true, questionById.get(ILquestion2.Id).EUR_CRM_Weight_Has_Changed__c);
        System.assertEquals(true, questionById.get(VPquestion1.Id).EUR_CRM_Weight_Has_Changed__c);
    }


    /*===================================================
   *   Makers
   * ===================================================*/
    private static EUR_CRM_Account__c makeAccount(String rtDevName) {
        Id recTypeId = Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get(rtDevName).getRecordTypeId();
        return new EUR_CRM_Account__c(
            RecordTypeId = recTypeId
            ,   Name = 'Test Account'
            ,   EUR_CRM_Postal_Code__c = '00000'
        );
    }

    private static EUR_CRM_PRS_Segmentation__c makeSegmentation(String rtDevName) {
        Id recTypeId = Schema.SObjectType.EUR_CRM_PRS_Segmentation__c.getRecordTypeInfosByDeveloperName().get(rtDevName).getRecordTypeId();
        return new EUR_CRM_PRS_Segmentation__c(
            RecordTypeId = recTypeId
        );
    }

    private static EUR_CRM_PRS_Question_Set__c makeQuestionSet(String rtDevName) {
        Id rtId = Schema.SObjectType.EUR_CRM_PRS_Question_Set__c.getRecordTypeInfosByDeveloperName().get(rtDevName).getRecordTypeId();
        return new EUR_CRM_PRS_Question_Set__c(
            RecordTypeId = rtId
        );
    }

    private static EUR_CRM_PRS_Question__c makeQuestion(Id questionSetId, String rtDevName) {
        Id rtId = Schema.SObjectType.EUR_CRM_PRS_Question__c.getRecordTypeInfosByDeveloperName().get(rtDevName).getRecordTypeId();
        return new EUR_CRM_PRS_Question__c(
            RecordTypeId = rtId
            , EUR_CRM_PRS_Question_Set__c = questionSetId
        );
    }

    private static EUR_CRM_PRS_Answer__c makeAnswer(Id prSegmId, Id questionId, String rtDevName, String answer) {
        Id recTypeId = Schema.SObjectType.EUR_CRM_PRS_Answer__c.getRecordTypeInfosByDeveloperName().get(rtDevName).getRecordTypeId();
        return new EUR_CRM_PRS_Answer__c(
            RecordTypeId = recTypeId
            ,   EUR_CRM_PRS_Segmentation__c = prSegmId
            ,   EUR_CRM_PRS_Question__c = questionId
            ,   EUR_CRM_Answer__c = answer
        );
    }

    private static EUR_CRM_PRS_Question_Criteria__c makeQuestionCriteria(Id questionId, String rtDevName) {
        Id recTypeId = Schema.SObjectType.EUR_CRM_PRS_Question_Criteria__c.getRecordTypeInfosByDeveloperName().get(rtDevName).getRecordTypeId();
        return new EUR_CRM_PRS_Question_Criteria__c(
            RecordTypeId = recTypeId
            ,   EUR_CRM_PRS_Question__c = questionId
        );
    }

    /*===================================================
   *   SOQL Selectors
   * ===================================================*/
    private static List<EUR_CRM_PRS_Question__c> selectQuestions() {
        return [
            SELECT Id
                , EUR_CRM_PRS_Question_Set__c
                , EUR_CRM_Weight_Has_Changed__c
            FROM EUR_CRM_PRS_Question__c
        ];
    }

    private static List<EUR_CRM_PRS_Answer__c> selectAnswers() {
        return [
            SELECT Id
            , EUR_CRM_Weight__c
            FROM EUR_CRM_PRS_Answer__c
        ];
    }

    private static List<EUR_CRM_Account__c> selectAccounts() {
        return [
            SELECT Id
            FROM EUR_CRM_Account__c
        ];
    }

    private static List<EUR_CRM_PRS_Segmentation__c> selectSegmentations() {
        return [
            SELECT Id
            FROM EUR_CRM_PRS_Segmentation__c
        ];
    }

    private static List<EUR_CRM_PRS_Question_Criteria__c> selectCriteria() {
        return [
            SELECT Id
            FROM EUR_CRM_PRS_Question_Criteria__c
        ];
    }

}