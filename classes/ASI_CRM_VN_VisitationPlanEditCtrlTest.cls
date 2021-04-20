@isTest
public with sharing class ASI_CRM_VN_VisitationPlanEditCtrlTest {
    @testSetup
    public static void setupTestData(){
        ASI_HK_CRM_Running_Number__c runningInstance = ASI_CRM_VN_TestDataFactory.getRunningNumber('ASI_CRM_VN_Customer_Code',1,'VN{000000}',1,15);
        insert runningInstance;     
    }
    
    private static final ASI_HK_CRM_AccountGenerator acctGen;
    private static final ASI_HK_CRM_VisitationPlanGenerator visitPlanGen;
    private static final ASI_CRM_VN_VisitationPlanDetailGenerator visitPlanDetailGen;
    
    static {
        ASI_HK_CRM_CustomSettingGenerator.initAcctGradeVisitCountMapping();
        acctGen = new ASI_HK_CRM_AccountGenerator();
        visitPlanGen = new ASI_HK_CRM_VisitationPlanGenerator();
        visitPlanDetailGen = new ASI_CRM_VN_VisitationPlanDetailGenerator();
    }
    
    static testMethod void test_main() {
        // Initialize Accounts
        final Integer numOfTestWS = 5;
        List<Account> acctList = new List<Account>();
        for (Integer i = 0; i < numOfTestWS; i++) {
            acctList.add(acctGen.generateAccount(ASI_HK_CRM_AccountGenerator.RT_JDE_CREDIT));
        }
        insert acctList;

        
        
        ASI_CRM_AccountsAdditionalField__c onTradeCustomer = ASI_CRM_VN_TestClassHelper.createOnTradeCustomer();
        insert onTradeCustomer;
        
        // Initialize Visitation Plan
        ASI_HK_CRM_Visitation_Plan__c visitPlan = visitPlanGen.generateVisitationPlan();
        visitPlan.RecordTypeId =  getRecordTypeId('ASI_CRM_VN_Visitation_Plan','ASI_HK_CRM_Visitation_Plan__c');
        insert visitPlan;
        
        // Initialize Visitation Plan Details
        List<ASI_HK_CRM_Visitation_Plan_Detail__c> visitPlanDetails = new List<ASI_HK_CRM_Visitation_Plan_Detail__c>();
        Date visitPlanFirstDate = Date.newInstance(
            Integer.valueOf(ASI_HK_CRM_VisitationPlanGenerator.DEF_VALUE_YEAR)
            , ASI_HK_CRM_VisitationPlanGenerator.convertMonthPLValueToInteger(ASI_HK_CRM_VisitationPlanGenerator.DEF_VALUE_MONTH)
            , 1
        );
        visitPlanDetails.add(visitPlanDetailGen.generateVisitationPlanDetail(visitPlan, onTradeCustomer, visitPlanFirstDate.addDays(2))); // WS0 3rd
        visitPlanDetails.add(visitPlanDetailGen.generateVisitationPlanDetail(visitPlan, onTradeCustomer,visitPlanFirstDate.addDays(17))); // WS0 18th
        visitPlanDetails.add(visitPlanDetailGen.generateVisitationPlanDetail(visitPlan, onTradeCustomer, visitPlanFirstDate.addDays(17))); // WS2 18th
        visitPlanDetails.add(visitPlanDetailGen.generateVisitationPlanDetail(visitPlan, onTradeCustomer, visitPlanFirstDate.addDays(7))); // WS3 8th
        visitPlanDetails.add(visitPlanDetailGen.generateVisitationPlanDetail(visitPlan, onTradeCustomer, visitPlanFirstDate.addDays(17))); // WS4 18th
        insert visitPlanDetails;
        
        ApexPages.StandardSetController stdSetConroller = new ApexPages.StandardSetController(visitPlanDetails);
        
        Test.startTest();
        
        // Initialize page and controller
        PageReference testPage = Page.ASI_HK_CRM_VisitationPlanEditPage;
        Map<String, String> pageParams = testPage.getParameters();
        pageParams.put('id', visitPlan.Id);
        Test.setCurrentPageReference(testPage);
        ASI_CRM_VN_VisitationPlanEditController testController = new ASI_CRM_VN_VisitationPlanEditController(stdSetConroller);
        PageReference initRedirectPage = testController.initPage();
                
        // Validate initialization results
        System.assertEquals(null, initRedirectPage);
        List<ASI_CRM_VN_VisitationPlanEditController.ASI_HK_CRM_VisitationPlanEditRow> visitTableRows = testController.visitTableRows;
        Map<Date, Integer> dateToVisitCountMap = testController.dateToVisitCountMap;
        Map<String, ASI_CRM_VN_VisitationPlanEditController.ASI_HK_CRM_VisitationPlanPoint> keyToVisitPointMap = testController.keyToVisitPointMap;
       

        // Check summarized points
        Map<String, ASI_HK_CRM_AcctGradeVisitCountMapping__c> gradeToVisitCountMap = ASI_HK_CRM_AcctGradeVisitCountMapping__c.getAll();

        
        // Add and remove visitation plan details
        for (ASI_CRM_VN_VisitationPlanEditController.ASI_HK_CRM_VisitationPlanEditRow row : visitTableRows) {
            if (row.targetSObj.Id == onTradeCustomer.Id) {
                row.visitDayStr = String.join(new String[] {'4'}, ', ');
            } else if (row.targetSObj.Id == onTradeCustomer.Id) {
                row.visitDayStr = '';
            } else if (row.targetSObj.Id == onTradeCustomer.Id) {
                row.visitDayStr = String.join(new String[] {'20'}, ', ');
            }
        }
        
        // Save changes
        PageReference savePage = testController.saveChanges();
        testController.quickSaveChanges();
        testController.ResetNameSearch();

        System.assertEquals('/' + visitPlan.Id, savePage.getUrl());

        Test.stopTest();
    }


    /**
    *   Description : This method will get Record type Id's from RecordType
    *
    *   Parameters :
    *   @Developername : Recordtype DeveloperName
    **/
    private static Id RecordTypeId = null;
    public static Id getRecordTypeId(String Developername,String SobjectType){
        if(RecordTypeId==null)
            RecordTypeId = [Select Id from RecordType where Developername=:Developername and SobjectType=:SobjectType].Id;  
        return RecordTypeId;
    }
}