@isTest
private class ASI_HK_CRM_VisitationPlanEditTest {
    
    private static final ASI_HK_CRM_AccountGenerator acctGen;
    private static final ASI_HK_CRM_VisitationPlanGenerator visitPlanGen;
    private static final ASI_HK_CRM_VisitationPlanDetailGenerator visitPlanDetailGen;
    
    static {
        ASI_HK_CRM_CustomSettingGenerator.initAcctGradeVisitCountMapping();
        acctGen = new ASI_HK_CRM_AccountGenerator();
        visitPlanGen = new ASI_HK_CRM_VisitationPlanGenerator();
        visitPlanDetailGen = new ASI_HK_CRM_VisitationPlanDetailGenerator();
    }
    
    static testMethod void test_main() {
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
        visitPlanDetails.add(visitPlanDetailGen.generateVisitationPlanDetail(visitPlan, acctList.get(3), visitPlanFirstDate.addDays(7))); // WS3 8th
        visitPlanDetails.add(visitPlanDetailGen.generateVisitationPlanDetail(visitPlan, acctList.get(4), visitPlanFirstDate.addDays(17))); // WS4 18th
        insert visitPlanDetails;
        
        ApexPages.StandardSetController stdSetConroller = new ApexPages.StandardSetController(visitPlanDetails);
        
        Test.startTest();
        
        // Initialize page and controller
        PageReference testPage = Page.ASI_HK_CRM_VisitationPlanEditPage;
        Map<String, String> pageParams = testPage.getParameters();
        pageParams.put('id', visitPlan.Id);
        Test.setCurrentPageReference(testPage);
        ASI_HK_CRM_VisitationPlanEditController testController = new ASI_HK_CRM_VisitationPlanEditController(stdSetConroller);
        PageReference initRedirectPage = testController.initPage();
                
        // Validate initialization results
        System.assertEquals(null, initRedirectPage);
        List<ASI_HK_CRM_VisitationPlanEditController.ASI_HK_CRM_VisitationPlanEditRow> visitTableRows = testController.visitTableRows;
        Map<Date, Integer> dateToVisitCountMap = testController.dateToVisitCountMap;
        Map<String, ASI_HK_CRM_VisitationPlanEditController.ASI_HK_CRM_VisitationPlanPoint> keyToVisitPointMap = testController.keyToVisitPointMap;
        // Check visitation day strings
        for (ASI_HK_CRM_VisitationPlanEditController.ASI_HK_CRM_VisitationPlanEditRow row : visitTableRows) {
            if (row.targetSObj.Id == acctList.get(0).Id) {
                System.assertEquals(String.join(new String[] {'3', '18'}, ASI_HK_CRM_VisitationPlanEditController.VISIT_DAY_DELIM), row.visitDayStr);
            } else if (row.targetSObj.Id == acctList.get(2).Id) {
                System.assertEquals(String.join(new String[] {'18'}, ASI_HK_CRM_VisitationPlanEditController.VISIT_DAY_DELIM), row.visitDayStr);
            } else if (row.targetSObj.Id == acctList.get(3).Id) {
                System.assertEquals(String.join(new String[] {'8'}, ASI_HK_CRM_VisitationPlanEditController.VISIT_DAY_DELIM), row.visitDayStr);
            } else if (row.targetSObj.Id == acctList.get(4).Id) {
                System.assertEquals(String.join(new String[] {'18'}, ASI_HK_CRM_VisitationPlanEditController.VISIT_DAY_DELIM), row.visitDayStr);
            } else {
                System.assertEquals('', row.visitDayStr);
            }
        }
        // Check visitation counts
        System.assertEquals(1, dateToVisitCountMap.get(visitPlanFirstDate.addDays(2)));
        System.assertEquals(1, dateToVisitCountMap.get(visitPlanFirstDate.addDays(7)));
        System.assertEquals(3, dateToVisitCountMap.get(visitPlanFirstDate.addDays(17)));
        // Check summarized points
        Map<String, ASI_HK_CRM_AcctGradeVisitCountMapping__c> gradeToVisitCountMap = ASI_HK_CRM_AcctGradeVisitCountMapping__c.getAll();
        System.assertEquals(
            5
            , keyToVisitPointMap.get(ASI_HK_CRM_VisitationPlanEditController.POINT_KEY_JDE).plannedPt
        );
        System.assertEquals(
            gradeToVisitCountMap.get(ASI_HK_CRM_AccountGenerator.DEF_VALUE_GRADE).ASI_HK_CRM_No_of_Required_Visitation__c.intValue() * 5
            , keyToVisitPointMap.get(ASI_HK_CRM_VisitationPlanEditController.POINT_KEY_JDE).requiredPt
        );
        
        // Add and remove visitation plan details
        for (ASI_HK_CRM_VisitationPlanEditController.ASI_HK_CRM_VisitationPlanEditRow row : visitTableRows) {
            if (row.targetSObj.Id == acctList.get(0).Id) {
                row.visitDayStr = String.join(new String[] {'4'}, ASI_HK_CRM_VisitationPlanEditController.VISIT_DAY_DELIM);
            } else if (row.targetSObj.Id == acctList.get(3).Id) {
                row.visitDayStr = '';
            } else if (row.targetSObj.Id == acctList.get(1).Id) {
                row.visitDayStr = String.join(new String[] {'20'}, ASI_HK_CRM_VisitationPlanEditController.VISIT_DAY_DELIM);
            }
        }
        
        // Save changes
        PageReference savePage = testController.saveChanges();
        System.assertEquals('/' + visitPlan.Id, savePage.getUrl());
        
        // Validate save results
        visitPlanDetails = [SELECT Id, ASI_HK_CRM_Account__c, ASI_HK_CRM_Visit_Date__c FROM ASI_HK_CRM_Visitation_Plan_Detail__c WHERE ASI_HK_CRM_Visitation_Plan__c = :visitPlan.Id];
        Map<ID, Integer> acctToVisitCountMap = new Map<ID, Integer>();
        for (ASI_HK_CRM_Visitation_Plan_Detail__c tempVisitDetail : visitPlanDetails) {
            Integer vCount = acctToVisitCountMap.get(tempVisitDetail.ASI_HK_CRM_Account__c);
            if (vCount == null) {
                vCount = 0;
            }
            acctToVisitCountMap.put(tempVisitDetail.ASI_HK_CRM_Account__c, vCount + 1);
        }
        System.assertEquals(1, acctToVisitCountMap.get(acctList.get(0).Id));
        System.assertEquals(1, acctToVisitCountMap.get(acctList.get(1).Id));
        System.assertEquals(1, acctToVisitCountMap.get(acctList.get(2).Id));
        System.assertEquals(null, acctToVisitCountMap.get(acctList.get(3).Id));
        System.assertEquals(1, acctToVisitCountMap.get(acctList.get(4).Id));
        testController.ResetNameSearch();
        Test.stopTest();
    }
}