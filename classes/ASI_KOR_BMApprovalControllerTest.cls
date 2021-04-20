@isTest
public class ASI_KOR_BMApprovalControllerTest{
    private static Map<String,SObject> propObjects;
    private static User sr;
    private static User bm;
    private static User rsd;
    private static User nsd;
    private static ASI_KOR_BM_Proposal_Header__c bmHeader;
    private static ASI_KOR_Incentive_Scheme__c incentiveScheme1;
    private static ApexPages.StandardController sc;
    private static ASI_KOR_BMApprovalController bmController;
    private static ASI_KOR_SR_Proposal_Header__c srHeader;
    private static  ASI_KOR_SR_Proposal_By_Brand__c srByBrand;
    private static  ASI_KOR_Brand__c brand1;
    
    public static void init(){
    
        propObjects = ASI_KOR_TestClassHelper.generateProposalObjects();
        sr = (User) propObjects.get(ASI_KOR_TestClassHelper.SR_USER);
        bmHeader = (ASI_KOR_BM_Proposal_Header__c) propObjects.get(ASI_KOR_TestClassHelper.BM_PROP_HEADER);
        srHeader = (ASI_KOR_SR_Proposal_Header__c) propObjects.get(ASI_KOR_TestClassHelper.SR_PROP_HEADER);
        srByBrand = (ASI_KOR_SR_Proposal_By_Brand__c) propObjects.get(ASI_KOR_TestClassHelper.SR_PROP_BRAND);
        incentiveScheme1 = (ASI_KOR_Incentive_Scheme__c) propObjects.get(ASI_KOR_TestClassHelper.INCENTIVE_SCHEME_1); 
        brand1 = (ASI_KOR_Brand__c ) propObjects.get(ASI_KOR_TestClassHelper.ABSOLUT_BRAND);
       
        srHeader.ASI_KOR_Status__c ='Submitted';
        update srHeader;
       
        sc = new ApexPages.standardController(bmHeader);
        bmController = new ASI_KOR_BMApprovalController(sc);
       Account venue = (Account) propObjects.get(ASI_KOR_TestClassHelper.VENUE_1);
        
        ASI_KOR_SR_Proposal_Detail__c proposaDetail = new ASI_KOR_SR_Proposal_Detail__c();
             proposaDetail.ASI_KOR_Target_Volume__c = 100;
             proposaDetail.ASI_KOR_Cap_Unit_Cost_Basic__c = 10000;
             proposaDetail.ASI_KOR_Cap_Unit_Cost_CA__c = 1000;
             proposaDetail.ASI_KOR_Proposal_Unit_Cost_Basic_CA__c = 100000;
             proposaDetail.ASI_KOR_Unit_Cost_Cap_Actual_Volume__c = 9000;
             proposaDetail.ASI_KOR_SR_Proposal_ID__c = srHeader.id;
             proposaDetail.ASI_KOR_SR_Proposal_By_Brand__c = srByBrand.id;
             proposaDetail.ASI_KOR_Venue__c = venue.id;
             proposaDetail.ASI_KOR_Brand__c = brand1.id;
             proposaDetail.ASI_KOR_Incentive_Scheme__r = incentiveScheme1 ;
             proposaDetail.ASI_KOR_Incentive_Scheme__c = incentiveScheme1.id;
         insert proposaDetail;
    }
    
    @isTest 
    public static void testSalesRepSelect(){
        init();
        
          bmController.salesRep = sr;
          bmController.selectedSR = sr.id;
          bmController.selectSalesRep();
          bmController.handleSelection();
          bmController.getSrPendingCAAmount();
          bmController.getSrTotalCAAmount();
          bmController.getSrTotalPendingIncentiveAmount();
          bmController.getSrCAAmount();
        bmController.getGrandBudgetStatus();
		
		ASI_KOR_BMApprovalController.DetailsByVenue a = bmController.detailsByVenueList.get(0);
		a.getTotalIncentive();
		a.getTotalTargetVolume();
		a.getTotalUC();
		a.getTotalVI_lastMonth();
		a.getTotalActualVolume_lastMonth();
		a.getTotalUC_lastMonth();
		a.getTotalIncentiveCost();
		a.getVenueStatus();
		
          system.assertNotEquals(bmController.getSalesRepsOptions(),null);
                             

    }
    @isTest
    public static void testApprove(){
        init();
          bmController.salesRep = sr;
          bmController.selectedSR = sr.id;
          bmController.selectSalesRep();
          bmController.handleSelection();
          bmController.handleApprove();
          ASI_KOR_SR_Proposal_Header__c srHeaderResult =[ select id, asi_kor_status__c from ASI_KOR_SR_Proposal_Header__c 
          where id =: srHeader.id];
          
          system.assertEquals('Approved by BM', srHeaderResult.asi_kor_status__c);
    }
    @isTest
    public static void testReject(){
        init();
          bmController.salesRep = sr;
          bmController.selectedSR = sr.id;
          bmController.handleSelection();
          bmController.handleReject();
          ASI_KOR_SR_Proposal_Header__c srHeaderResult =[ select id, asi_kor_status__c from ASI_KOR_SR_Proposal_Header__c 
          where id =: srHeader.id];
          
          system.assertEquals('Rejected', srHeaderResult.asi_kor_status__c);
    }
    @isTest
    public static void testSubmitAndRecall(){
        init();
          bmController.salesRep = sr;
          bmController.selectedSR = sr.id;
          bmController.selectSalesRep();
          bmController.handleSelection();
          bmController.handleApprove();
        bmController.getReadyToSubmit();
        bmController.handleSubmit();
        
        ASI_KOR_BM_Proposal_Header__c bmHeaderResult =[ select id, asi_kor_status__c from ASI_KOR_BM_Proposal_Header__c 
          where id =: bmHeader.id];
          
        system.assertEquals('Submitted', bmHeaderResult.asi_kor_status__c);
        bmController.handleRecall();
        bmHeaderResult =[ select id, asi_kor_status__c from ASI_KOR_BM_Proposal_Header__c 
          where id =: bmHeader.id];
          
        system.assertEquals('Draft', bmHeaderResult.asi_kor_status__c);
        /*
        bmController.salesRep = sr;
        bmController.selectedSR = sr.id;
        bmController.selectSalesRep();
        bmController.handleSelection();
        bmController.handleApprove();
		*/
        bmController.handleSubmit();
    }
    @isTest
    public static void testStaticMethods(){
        init();
        bmController.getSrTotalIncentive();
        bmController.getBranchTotalStatus();
        bmController.getSrTotalCAAmount();
        bmController.getYear();
        bmController.getMonth();
        ASI_KOR_BMApprovalController.populateBrandBudget('1','2014','550');
        
        
        ASI_KOR_BMApprovalController.rollUp(bmHeader.id,true);
        ASI_KOR_BMApprovalController.rollUp(bmHeader.id,false);
        bmController.setReadyToSubmit(true);
        bmController.setBranchTotalStatus('');
    }
          
    @isTest
    public static void testGetMethod(){
 
        init();

        bmController.getGrandTotalByBrand_uc_2M();
        bmController.getGrandTotalByBrand_uc_1M();
        bmController.getGrandTotalByBrand_uc_TM();
        bmController.getGrandTotalByBrand_uc_budget();
        bmController.getGrandTotalByBrandBudgetStatus();
        bmController.getLast2Month_year();
        bmController.getLast2Month_month();
        bmController.getLast1Month_year();
        bmController.getLast1Month_month();
        bmController.getThisMonth_year();
        bmController.getThisMonth_month();
     }

}