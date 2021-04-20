@IsTest (isParallel = true)
private class EUR_CRM_QuizToAccAssignControllerTest {

	@TestSetup
	private static void setupMethod() {
		insert makeAccount();
	}

	@IsTest
	private static void setupTest() {
		List<EUR_CRM_Account__c> accounts = selectAccounts();
		System.assertEquals(1, accounts.size());
	}

	@IsTest
	private static void simpleTest() {
		EUR_CRM_Quiz__c quiz = makeQuiz();
		insert quiz;

		PageReference pageRef = Page.EUR_CRM_QuizToAccAssign;
		pageRef.getParameters().put('quizId', quiz.Id);
		Test.setCurrentPage(pageRef);

		Test.startTest();
		EUR_CRM_QuizToAccAssignController contr = new EUR_CRM_QuizToAccAssignController();
		contr.getSelectionMethods();
		contr.getAccountListViews();
		contr.getCustomerTaxonomyChains();
		contr.getAccountWrappers();
		contr.showFilters();
		contr.assignToAccounts();
		contr.onClickImageLevelCheckbox();
		contr.onClickCheckbox();
		Test.stopTest();
	}

	/* ========================================================= */
	/*     Makers
	/* ========================================================= */
	private static EUR_CRM_Account__c makeAccount() {
		return new EUR_CRM_Account__c(
			Name = 'Simple Account'
			,   EUR_CRM_Postal_Code__c = '1122'
		);
	}

	private static EUR_CRM_Customer_Taxonomy__c makeCustomerTaxonomy(String chain) {
		return new EUR_CRM_Customer_Taxonomy__c(
			EUR_CRM_Chain__c = chain
		);
	}

	private static EUR_CRM_Quiz__c makeQuiz() {
		return new EUR_CRM_Quiz__c(
			Name = 'Simple Quiz'
		);
	}

	private static EUR_CRM_PRS_Group_Outlet_Type__c makeGOT(String name) {
		return new EUR_CRM_PRS_Group_Outlet_Type__c(
			EUR_CRM_PRS_Group_Outlet_Name__c = name
		);
	}

	private static EUR_CRM_PRS_Seg_Aspect__c makeSegAspect(String name) {
		return new EUR_CRM_PRS_Seg_Aspect__c(
			EUR_CRM_Segmentation_IL_Aspect_Name__c = name
		);
	}


	/* ========================================================= */
	/*     SOQL Selectors
	/* ========================================================= */
	private static List<EUR_CRM_Account__c> selectAccounts() {
		return [
			SELECT Id
			FROM EUR_CRM_Account__c
		];
	}

	private static List<EUR_CRM_QuizPartaker__c> selectQuizPartakers(Id quizId) {
		return [
			SELECT Id
				,   EUR_CRM_AccountId__c
			FROM EUR_CRM_QuizPartaker__c
			WHERE EUR_CRM_QuizId__c = :quizId
		];
	}

}