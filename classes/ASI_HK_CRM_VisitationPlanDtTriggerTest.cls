@isTest
private class ASI_HK_CRM_VisitationPlanDtTriggerTest {

    static testMethod void test_ASI_HK_CRM_VisitationPlanDtValidator() {
        ASI_HK_CRM_AccountGenerator acctGen = new ASI_HK_CRM_AccountGenerator();
    	ASI_HK_CRM_VisitationPlanGenerator visitPlanGen = new ASI_HK_CRM_VisitationPlanGenerator();
    	ASI_HK_CRM_VisitationPlanDetailGenerator visitPlanDetailGen = new ASI_HK_CRM_VisitationPlanDetailGenerator();
    	
    	// Initialize Accounts
    	final Integer numOfTestWS = 5;
    	List<Account> acctList = new List<Account>();
    	for (Integer i = 0; i < numOfTestWS; i++) {
    		acctList.add(acctGen.generateAccount(ASI_HK_CRM_AccountGenerator.RT_JDE_CREDIT));
    	}
    	insert acctList;
    	
    	// Initialize Visitation Plan
    	ASI_HK_CRM_Visitation_Plan__c visitPlan = visitPlanGen.generateVisitationPlan();
    	insert visitPlan;
    	
    	// Initialize Visitation Plan Details
    	List<ASI_HK_CRM_Visitation_Plan_Detail__c> visitPlanDetails = new List<ASI_HK_CRM_Visitation_Plan_Detail__c>();
    	Date visitPlanFirstDate = Date.newInstance(
    		Integer.valueOf(ASI_HK_CRM_VisitationPlanGenerator.DEF_VALUE_YEAR)
    		, ASI_HK_CRM_VisitationPlanGenerator.convertMonthPLValueToInteger(ASI_HK_CRM_VisitationPlanGenerator.DEF_VALUE_MONTH)
    		, 1
		);
		visitPlanDetails.add(visitPlanDetailGen.generateVisitationPlanDetail(visitPlan, acctList.get(0), visitPlanFirstDate.addDays(2))); // WS0 3rd
		visitPlanDetails.add(visitPlanDetailGen.generateVisitationPlanDetail(visitPlan, acctList.get(0), visitPlanFirstDate.addDays(17))); // WS0 18th
		visitPlanDetails.add(visitPlanDetailGen.generateVisitationPlanDetail(visitPlan, acctList.get(2), visitPlanFirstDate.addDays(17))); // WS2 18th
		insert visitPlanDetails;
		
		Test.startTest();
		
		// Test creating duplicate date for same account
		ASI_HK_CRM_Visitation_Plan_Detail__c testVisitPlanDetail = visitPlanDetailGen.generateVisitationPlanDetail(visitPlan, acctList.get(0), visitPlanFirstDate.addDays(2));
		Boolean hasException = false;
		try {
			insert testVisitPlanDetail;
		} catch (DmlException dmle) {
			hasException = true;
		}
		System.assertEquals(true, hasException);
		hasException = false;
		
		// Test updating to duplicate date for same account
		testVisitPlanDetail = visitPlanDetails.get(0);
		Date origVisitDate = testVisitPlanDetail.ASI_HK_CRM_Visit_Date__c;
		testVisitPlanDetail.ASI_HK_CRM_Visit_Date__c = visitPlanFirstDate.addDays(17);
		try {
			update testVisitPlanDetail;
		} catch (DmlException dmle) {
			hasException = true;
		}
		System.assertEquals(true, hasException);
		hasException = false;
		
		// Test updating unmatched date with header
		testVisitPlanDetail.ASI_HK_CRM_Visit_Date__c = visitPlanFirstDate.addDays(-400);
		try {
			update testVisitPlanDetail;
		} catch (DmlException dmle) {
			hasException = true;
		}
		System.assertEquals(true, hasException);
		hasException = false;
		
		// Test undelete visit which has duplicate date
		delete testVisitPlanDetail;
		ASI_HK_CRM_Visitation_Plan_Detail__c deletedVisitPlanDetail = testVisitPlanDetail;
		testVisitPlanDetail = visitPlanDetails.get(1);
		testVisitPlanDetail.ASI_HK_CRM_Visit_Date__c = origVisitDate;
		update testVisitPlanDetail;
		try {
			undelete deletedVisitPlanDetail;
		} catch (DmlException dmle) {
			hasException = true;
		}
		System.assertEquals(true, hasException);
		hasException = false;
		
		Test.stopTest();
    }
}