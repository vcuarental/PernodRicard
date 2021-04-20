/*
	Record Types can be used in test to create objects:

	private static final Set<String> ACC_RT_TO_UPDATE = new Set<String>{
		'EUR_GB_FS_Blitz'
	,	'EUR_GB_Indirect'
	,	'EUR_GB_On_Trade_RTM_Account'
	};

	private static final Set<String> SEGM_RT = new Set<String>{
		'EUR_PRS_Segmentation_Off_Trade'
	,	'EUR_PRS_Segmentation_On_Trade'
	};

	private static final Set<String> QUESTION_SET_RT = new Set<String>{
		'EUR_GB_PRS_Question_Set_Image_level'
	,	'EUR_GB_PRS_Question_Set_Volume_Potential'
	};

	private static final Set<String> QUESTION_RT = new Set<String>{
		'EUR_GB_PRS_Question_Boolean_Input'
	,	'EUR_GB_PRS_Question_Currency_Input'
	,	'EUR_GB_PRS_Question_Number_Input'
	,	'EUR_GB_PRS_Question_Picklist_Input'
	,	'EUR_GB_PRS_Question_Text_Input'
	};

	private static final Set<String> ANSWER_RT = new Set<String>{
		'EUR_PRS_Answer_Brand_Building_Potential'
	,	'EUR_PRS_Answer_Business_Potential'
	,	'EUR_PRS_Answer_Image_Level'
	,	'EUR_PRS_Answer_Volume_Potential'
	};
* */

@IsTest(IsParallel = true)
private class EUR_CRM_PrsAnswerAccUpdateServTest {

	private static final String CLASS_NAME = 'EUR_CRM_PrsAnswerAccUpdateServ';
	private static final Set<String> ANSWER_COUNTRY_CODES_TO_UPDATE_ACC = new Set<String>{
		'GB'
	};
	private static final Set<String> ANSWER_RT_TO_UPDATE_ACC = new Set<String>{
		'EUR_PRS_Answer_Volume_Potential'
	};

	private static void initCMT() {
		EUR_CRM_RecordTypeHelper_v2.rtListsForTest
			.add(EUR_CRM_RecordTypeHelper_v2.makeRtListForTest(CLASS_NAME, 'ANSWER_COUNTRY_CODES_TO_UPDATE_ACC', ANSWER_COUNTRY_CODES_TO_UPDATE_ACC));

		EUR_CRM_RecordTypeHelper_v2.rtListsForTest
			.add(EUR_CRM_RecordTypeHelper_v2.makeRtListForTest(CLASS_NAME, 'ANSWER_RT_TO_UPDATE_ACC', ANSWER_RT_TO_UPDATE_ACC));
	}

	/* ========================================================= */
	/*      After Insert Tests
	/* ========================================================= */
	@IsTest
	private static void accTotalChampaignVolumeUpdate_PositiveTest() {
		initCMT();

		EUR_CRM_Account__c acc = makeAccount('EUR_GB_FS_Indirect');
		insert acc;

		EUR_CRM_PRS_Segmentation__c segm = makeSegmentation('EUR_PRS_Segmentation_On_Trade');
		segm.EUR_CRM_Account__c = acc.Id;
		insert segm;

		EUR_CRM_PRS_Question_Set__c questionSet = makeQuestionSet('EUR_GB_PRS_Question_Set_Volume_Potential');
		insert questionSet;

		EUR_CRM_PRS_Question__c numberQuestion = makeQuestion(questionSet.Id, 'EUR_GB_PRS_Question_Number_Input');
		numberQuestion.EUR_CRM_Total_Champagne_Volume__c = true;
		insert numberQuestion;

		Test.startTest();
		EUR_CRM_PRS_Answer__c answer = makeAnswer(segm.Id, numberQuestion.Id, 'EUR_PRS_Answer_Volume_Potential', '250');
		insert answer;
		Test.stopTest();

		List<EUR_CRM_PRS_Answer__c> insertedAnswers = selectAnswers();
		List<EUR_CRM_Account__c> updatedAccs = selectAccounts();
		System.assertEquals(1, insertedAnswers.size());
		System.assertEquals('GB', insertedAnswers[0].EUR_CRM_Country_Code__c);
		System.assertEquals(1, updatedAccs.size());
		System.assertEquals(250, updatedAccs[0].EUR_CRM_Total_Champaign_Volume__c);
		System.assertEquals(null, updatedAccs[0].EUR_CRM_Total_Spirits_Volume__c);
	}

	@IsTest
	private static void accTotalSpiritsVolumeUpdate_PositiveTest() {
		initCMT();

		EUR_CRM_Account__c acc = makeAccount('EUR_GB_FS_Indirect');
		insert acc;

		EUR_CRM_PRS_Segmentation__c segm = makeSegmentation('EUR_PRS_Segmentation_On_Trade');
		segm.EUR_CRM_Account__c = acc.Id;
		insert segm;

		EUR_CRM_PRS_Question_Set__c questionSet = makeQuestionSet('EUR_GB_PRS_Question_Set_Volume_Potential');
		insert questionSet;

		EUR_CRM_PRS_Question__c numberQuestion = makeQuestion(questionSet.Id, 'EUR_GB_PRS_Question_Number_Input');
		numberQuestion.EUR_CRM_Total_Spirits_Volume__c = true;
		insert numberQuestion;

		Test.startTest();
		EUR_CRM_PRS_Answer__c answer = makeAnswer(segm.Id, numberQuestion.Id, 'EUR_PRS_Answer_Volume_Potential', '250');
		insert answer;
		Test.stopTest();

		List<EUR_CRM_PRS_Answer__c> insertedAnswers = selectAnswers();
		List<EUR_CRM_Account__c> updatedAccs = selectAccounts();
		System.assertEquals(1, insertedAnswers.size());
		System.assertEquals('GB', insertedAnswers[0].EUR_CRM_Country_Code__c);
		System.assertEquals(1, updatedAccs.size());
		System.assertEquals(null, updatedAccs[0].EUR_CRM_Total_Champaign_Volume__c);
		System.assertEquals(250, updatedAccs[0].EUR_CRM_Total_Spirits_Volume__c);
	}

	@IsTest
	private static void accTotalChampaignVolumeUpdate_twoCheckboxesOnQuestionIsTrue_PositiveTest() {
		initCMT();

		EUR_CRM_Account__c acc = makeAccount('EUR_GB_FS_Indirect');
		insert acc;

		EUR_CRM_PRS_Segmentation__c segm = makeSegmentation('EUR_PRS_Segmentation_On_Trade');
		segm.EUR_CRM_Account__c = acc.Id;
		insert segm;

		EUR_CRM_PRS_Question_Set__c questionSet = makeQuestionSet('EUR_GB_PRS_Question_Set_Volume_Potential');
		insert questionSet;

		EUR_CRM_PRS_Question__c numberQuestion = makeQuestion(questionSet.Id, 'EUR_GB_PRS_Question_Number_Input');
		numberQuestion.EUR_CRM_Total_Champagne_Volume__c = true;
		numberQuestion.EUR_CRM_Total_Spirits_Volume__c = true;
		insert numberQuestion;

		Test.startTest();
		EUR_CRM_PRS_Answer__c answer = makeAnswer(segm.Id, numberQuestion.Id, 'EUR_PRS_Answer_Volume_Potential', '250');
		insert answer;
		Test.stopTest();

		List<EUR_CRM_PRS_Answer__c> insertedAnswers = selectAnswers();
		List<EUR_CRM_Account__c> updatedAccs = selectAccounts();
		System.assertEquals(1, insertedAnswers.size());
		System.assertEquals('GB', insertedAnswers[0].EUR_CRM_Country_Code__c);
		System.assertEquals(1, updatedAccs.size());
		System.assertEquals(250, updatedAccs[0].EUR_CRM_Total_Champaign_Volume__c);
		System.assertEquals(null, updatedAccs[0].EUR_CRM_Total_Spirits_Volume__c);
	}

	@IsTest
	private static void noAccUpdate_questionCheckboxesInFalse_NegativeTest() {
		initCMT();

		EUR_CRM_Account__c acc = makeAccount('EUR_GB_FS_Indirect');
		insert acc;

		EUR_CRM_PRS_Segmentation__c segm = makeSegmentation('EUR_PRS_Segmentation_On_Trade');
		segm.EUR_CRM_Account__c = acc.Id;
		insert segm;

		EUR_CRM_PRS_Question_Set__c questionSet = makeQuestionSet('EUR_GB_PRS_Question_Set_Volume_Potential');
		insert questionSet;

		EUR_CRM_PRS_Question__c numberQuestion = makeQuestion(questionSet.Id, 'EUR_GB_PRS_Question_Number_Input');
		numberQuestion.EUR_CRM_Total_Champagne_Volume__c = false;
		numberQuestion.EUR_CRM_Total_Spirits_Volume__c = false;
		insert numberQuestion;

		Test.startTest();
		EUR_CRM_PRS_Answer__c answer = makeAnswer(segm.Id, numberQuestion.Id, 'EUR_PRS_Answer_Volume_Potential', '250');
		insert answer;
		Test.stopTest();

		List<EUR_CRM_PRS_Answer__c> insertedAnswers = selectAnswers();
		List<EUR_CRM_Account__c> updatedAccs = selectAccounts();
		System.assertEquals(1, insertedAnswers.size());
		System.assertEquals('GB', insertedAnswers[0].EUR_CRM_Country_Code__c);
		System.assertEquals(1, updatedAccs.size());
		System.assertEquals(null, updatedAccs[0].EUR_CRM_Total_Champaign_Volume__c);
		System.assertEquals(null, updatedAccs[0].EUR_CRM_Total_Spirits_Volume__c);
	}

	@IsTest
	private static void noAccUpdate_wrongAnswerRecordType_NegativeTest() {
		initCMT();

		EUR_CRM_Account__c acc = makeAccount('EUR_GB_FS_Indirect');
		insert acc;

		EUR_CRM_PRS_Segmentation__c segm = makeSegmentation('EUR_PRS_Segmentation_On_Trade');
		segm.EUR_CRM_Account__c = acc.Id;
		insert segm;

		EUR_CRM_PRS_Question_Set__c questionSet = makeQuestionSet('EUR_GB_PRS_Question_Set_Volume_Potential');
		insert questionSet;

		EUR_CRM_PRS_Question__c numberQuestion = makeQuestion(questionSet.Id, 'EUR_GB_PRS_Question_Number_Input');
		numberQuestion.EUR_CRM_Total_Champagne_Volume__c = false;
		numberQuestion.EUR_CRM_Total_Spirits_Volume__c = false;
		insert numberQuestion;

		Test.startTest();
		EUR_CRM_PRS_Answer__c answer = makeAnswer(segm.Id, numberQuestion.Id, 'EUR_PRS_Answer_Image_Level', '250');
		insert answer;
		Test.stopTest();

		List<EUR_CRM_PRS_Answer__c> insertedAnswers = selectAnswers();
		List<EUR_CRM_Account__c> updatedAccs = selectAccounts();
		System.assertEquals(1, insertedAnswers.size());
		System.assertEquals('GB', insertedAnswers[0].EUR_CRM_Country_Code__c);
		System.assertEquals(1, updatedAccs.size());
		System.assertEquals(null, updatedAccs[0].EUR_CRM_Total_Champaign_Volume__c);
		System.assertEquals(null, updatedAccs[0].EUR_CRM_Total_Spirits_Volume__c);
	}

	@IsTest
	private static void noAccUpdate_wrongAnswerCountryCode_NegativeTest() {
		initCMT();

		EUR_CRM_Account__c acc = makeAccount('EUR_NL_On_Trade');
		insert acc;

		EUR_CRM_PRS_Segmentation__c segm = makeSegmentation('EUR_PRS_Segmentation_On_Trade');
		segm.EUR_CRM_Account__c = acc.Id;
		insert segm;

		EUR_CRM_PRS_Question_Set__c questionSet = makeQuestionSet('EUR_NL_PRS_Question_Set_Volume_Potential');
		insert questionSet;

		EUR_CRM_PRS_Question__c numberQuestion = makeQuestion(questionSet.Id, 'EUR_NL_PRS_Question_Number_Input');
		numberQuestion.EUR_CRM_Total_Champagne_Volume__c = false;
		numberQuestion.EUR_CRM_Total_Spirits_Volume__c = false;
		insert numberQuestion;

		Test.startTest();
		EUR_CRM_PRS_Answer__c answer = makeAnswer(segm.Id, numberQuestion.Id, 'EUR_PRS_Answer_Volume_Potential', '250');
		insert answer;
		Test.stopTest();

		List<EUR_CRM_PRS_Answer__c> insertedAnswers = selectAnswers();
		List<EUR_CRM_Account__c> updatedAccs = selectAccounts();
		System.assertEquals(1, insertedAnswers.size());
		System.assertEquals('NL', insertedAnswers[0].EUR_CRM_Country_Code__c);
		System.assertEquals(1, updatedAccs.size());
		System.assertEquals(null, updatedAccs[0].EUR_CRM_Total_Champaign_Volume__c);
		System.assertEquals(null, updatedAccs[0].EUR_CRM_Total_Spirits_Volume__c);
	}

	@IsTest
	private static void noAccUpdate_notNumericAnswer_NegativeTest() {
		initCMT();

		EUR_CRM_Account__c acc = makeAccount('EUR_GB_FS_Indirect');
		insert acc;

		EUR_CRM_PRS_Segmentation__c segm = makeSegmentation('EUR_PRS_Segmentation_On_Trade');
		segm.EUR_CRM_Account__c = acc.Id;
		insert segm;

		EUR_CRM_PRS_Question_Set__c questionSet = makeQuestionSet('EUR_GB_PRS_Question_Set_Volume_Potential');
		insert questionSet;

		EUR_CRM_PRS_Question__c textQuestion = makeQuestion(questionSet.Id, 'EUR_GB_PRS_Question_Text_Input');
		textQuestion.EUR_CRM_Total_Champagne_Volume__c = true;
		textQuestion.EUR_CRM_Total_Spirits_Volume__c = false;
		insert textQuestion;

		Test.startTest();
		EUR_CRM_PRS_Answer__c answer = makeAnswer(segm.Id, textQuestion.Id, 'EUR_PRS_Answer_Volume_Potential', 'text answer');
		insert answer;
		Test.stopTest();

		List<EUR_CRM_PRS_Answer__c> insertedAnswers = selectAnswers();
		List<EUR_CRM_Account__c> updatedAccs = selectAccounts();
		System.assertEquals(1, insertedAnswers.size());
		System.assertEquals('GB', insertedAnswers[0].EUR_CRM_Country_Code__c);
		System.assertEquals(1, updatedAccs.size());
		System.assertEquals(null, updatedAccs[0].EUR_CRM_Total_Champaign_Volume__c, 'Field updated only from number answers');
		System.assertEquals(null, updatedAccs[0].EUR_CRM_Total_Spirits_Volume__c, 'Field updated only from number answers');
	}


	/* ========================================================= */
	/*      After Update Tests
	/* ========================================================= */
	@IsTest
	private static void accTotalChampagneVolumeUpdate_PositiveTest() {
		initCMT();

		EUR_CRM_Account__c acc = makeAccount('EUR_GB_FS_Indirect');
		insert acc;

		EUR_CRM_PRS_Segmentation__c segm = makeSegmentation('EUR_PRS_Segmentation_On_Trade');
		segm.EUR_CRM_Account__c = acc.Id;
		insert segm;

		EUR_CRM_PRS_Question_Set__c questionSet = makeQuestionSet('EUR_GB_PRS_Question_Set_Volume_Potential');
		insert questionSet;

		EUR_CRM_PRS_Question__c numberQuestion = makeQuestion(questionSet.Id, 'EUR_GB_PRS_Question_Number_Input');
		numberQuestion.EUR_CRM_Total_Champagne_Volume__c = true;
		numberQuestion.EUR_CRM_Total_Spirits_Volume__c = false;
		insert numberQuestion;

		EUR_CRM_PRS_Answer__c answer = makeAnswer(segm.Id, numberQuestion.Id, 'EUR_PRS_Answer_Volume_Potential', '250');
		insert answer;

		Test.startTest();
		List<EUR_CRM_PRS_Answer__c> insertedAnswers = selectAnswers();
		System.assertEquals(1, insertedAnswers.size());
		System.assertEquals('GB', insertedAnswers[0].EUR_CRM_Country_Code__c);

		insertedAnswers[0].EUR_CRM_Answer__c = '350';
		update insertedAnswers;
		Test.stopTest();

		List<EUR_CRM_PRS_Answer__c> updatedAnswers = selectAnswers();
		System.assertEquals('350', updatedAnswers[0].EUR_CRM_Answer__c);

		List<EUR_CRM_Account__c> updatedAccs = selectAccounts();
		System.assertEquals(1, updatedAccs.size());
		System.assertEquals(350, updatedAccs[0].EUR_CRM_Total_Champaign_Volume__c);
		System.assertEquals(null, updatedAccs[0].EUR_CRM_Total_Spirits_Volume__c);
	}

	@IsTest
	private static void noAccUpdate_notNumericUpdatedAnswer_NegativeTest() {
		initCMT();

		EUR_CRM_Account__c acc = makeAccount('EUR_GB_FS_Indirect');
		insert acc;

		EUR_CRM_PRS_Segmentation__c segm = makeSegmentation('EUR_PRS_Segmentation_On_Trade');
		segm.EUR_CRM_Account__c = acc.Id;
		insert segm;

		EUR_CRM_PRS_Question_Set__c questionSet = makeQuestionSet('EUR_GB_PRS_Question_Set_Volume_Potential');
		insert questionSet;

		EUR_CRM_PRS_Question__c numberQuestion = makeQuestion(questionSet.Id, 'EUR_GB_PRS_Question_Number_Input');
		numberQuestion.EUR_CRM_Total_Champagne_Volume__c = true;
		numberQuestion.EUR_CRM_Total_Spirits_Volume__c = false;
		insert numberQuestion;

		EUR_CRM_PRS_Answer__c answer = makeAnswer(segm.Id, numberQuestion.Id, 'EUR_PRS_Answer_Volume_Potential', '250');
		insert answer;

		Test.startTest();
		List<EUR_CRM_PRS_Answer__c> insertedAnswers = selectAnswers();
		System.assertEquals(1, insertedAnswers.size());
		System.assertEquals('GB', insertedAnswers[0].EUR_CRM_Country_Code__c);

		insertedAnswers[0].EUR_CRM_Answer__c = 'text answer';
		update insertedAnswers;
		Test.stopTest();

		List<EUR_CRM_PRS_Answer__c> updatedAnswers = selectAnswers();
		System.assertEquals('text answer', updatedAnswers[0].EUR_CRM_Answer__c);

		List<EUR_CRM_Account__c> updatedAccs = selectAccounts();
		System.assertEquals(1, updatedAccs.size());
		System.assertEquals(250, updatedAccs[0].EUR_CRM_Total_Champaign_Volume__c, 'Field updated only from number answers');
		System.assertEquals(null, updatedAccs[0].EUR_CRM_Total_Spirits_Volume__c);
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
		,	EUR_CRM_PRS_Question_Set__c = questionSetId
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


	/*===================================================
   *   SOQL Selectors
   * ===================================================*/
	private static List<EUR_CRM_PRS_Answer__c> selectAnswers() {
		return [
			SELECT Id
			,	EUR_CRM_Weight__c
			,	EUR_CRM_Country_Code__c
			,	RecordTypeId
			,	EUR_CRM_Answer__c
			FROM EUR_CRM_PRS_Answer__c
		];
	}

	private static List<EUR_CRM_Account__c> selectAccounts() {
		return [
			SELECT Id
			,	EUR_CRM_Total_Champaign_Volume__c
			,	EUR_CRM_Total_Spirits_Volume__c
			FROM EUR_CRM_Account__c
		];
	}
}