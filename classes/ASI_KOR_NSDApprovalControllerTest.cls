@isTest
public class ASI_KOR_NSDApprovalControllerTest{
 private static Map<String,SObject> propObjects;
    private static User sr;
    private static User bm;
    private static User rsd;
    private static User nsd;
    
    private static ASI_KOR_Incentive_Scheme__c incentiveScheme1;
    private static ApexPages.StandardController sc;
    private static ASI_KOR_NSDApprovalController nsdController;
    private static ASI_KOR_SR_Proposal_Header__c srHeader;
    private static ASI_KOR_BM_Proposal_Header__c bmHeader;
    private static ASI_KOR_RSD_Proposal_Header__c rsdHeader;
    private static ASI_KOR_NSD_Proposal_Header__c nsdHeader;
    private static  ASI_KOR_SR_Proposal_By_Brand__c srByBrand;
    private static  ASI_KOR_Brand__c brand1;
    
    public static void init(){
    
        propObjects = ASI_KOR_TestClassHelper.generateProposalObjects();
        sr = (User) propObjects.get(ASI_KOR_TestClassHelper.SR_USER);
        nsdHeader = (ASI_KOR_NSD_Proposal_Header__c) propObjects.get(ASI_KOR_TestClassHelper.NSD_PROP_HEADER);
        rsdHeader = (ASI_KOR_RSD_Proposal_Header__c) propObjects.get(ASI_KOR_TestClassHelper.RSD_PROP_HEADER);
        bmHeader = (ASI_KOR_BM_Proposal_Header__c) propObjects.get(ASI_KOR_TestClassHelper.BM_PROP_HEADER);
        srHeader = (ASI_KOR_SR_Proposal_Header__c) propObjects.get(ASI_KOR_TestClassHelper.SR_PROP_HEADER);
        srByBrand = (ASI_KOR_SR_Proposal_By_Brand__c) propObjects.get(ASI_KOR_TestClassHelper.SR_PROP_BRAND);
        incentiveScheme1 = (ASI_KOR_Incentive_Scheme__c) propObjects.get(ASI_KOR_TestClassHelper.INCENTIVE_SCHEME_1); 
        brand1 = (ASI_KOR_Brand__c ) propObjects.get(ASI_KOR_TestClassHelper.ABSOLUT_BRAND);
       
        srHeader.ASI_KOR_Status__c ='Approved by BM';
        bmHeader.ASI_KOR_Status__c ='Approved by RSD';
        rsdHeader.ASI_KOR_Status__c ='Submitted';
        update srHeader;
        update bmHeader;
        update rsdHeader;
       
        sc = new ApexPages.standardController(nsdHeader);
        nsdController = new ASI_KOR_NSDApprovalController(sc);
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
    public static void testSave(){
        init();
        for(ASI_KOR_NSDApprovalController.RSDByBranchCategory bByCat : nsdController.rsdByRegionCategoryList){
            bByCat.rsdHeader.asi_kor_status__c = 'Approved by NSD';
        }
        nsdController.handleSave();
        List<ASI_KOR_RSD_Proposal_Header__c> rsdHeaderList = [select id, asi_kor_status__c from ASI_KOR_RSD_Proposal_Header__c 
        where ASI_KOR_NSD_Proposal_Header__c =: nsdHeader.id];
        
        for(ASI_KOR_RSD_Proposal_Header__c bmHeaderR : rsdHeaderList ){
            system.assertEquals('Approved by NSD', bmHeaderR.asi_kor_status__c);
        }
    }
        @isTest 
    public static void testSubmitAndRecall(){
        init();
        for(ASI_KOR_NSDApprovalController.RSDByBranchCategory bByCat : nsdController.rsdByRegionCategoryList){
            bByCat.rsdHeader.asi_kor_status__c = 'Approved by NSD';
        }
        nsdController.handleSave();
        nsdController.handleSubmit();
        ASI_KOR_NSD_Proposal_Header__c nsdHeaderR = [select id, asi_kor_status__c from ASI_KOR_NSD_Proposal_Header__c 
        where id=: nsdHeader.id];
        system.assertEquals('Approved', nsdHeaderR.asi_kor_status__c);

    }

    @isTest
    public static void testGetMethod(){
 
        init();

        nsdController.getGrandTotalByBrand_uc_2M();
        nsdController.getGrandTotalByBrand_uc_1M();
        nsdController.getGrandTotalByBrand_uc_TM();
        nsdController.getGrandTotalByBrand_uc_budget();
        nsdController.getGrandTotalByBrandBudgetStatus();
        nsdController.getLast2Month_year();
        nsdController.getLast2Month_month();
        nsdController.getLast1Month_year();
        nsdController.getLast1Month_month();
        nsdController.getThisMonth_year();
        nsdController.getThisMonth_month();
        nsdController.getGrandBudgetStatus();
		
		ASI_KOR_NSDApprovalController.RSDByBranchCategory a = nsdController.rsdByRegionCategoryList.get(0);
		a.getTargetVolume();
		a.getTotalVI();
		a.getTotalTargetVolume();
		a.getTotalUC();
		a.getTotalVI_lastMonth();
		a.getTotalActualVolume_lastMonth();
		a.getTotalUC_lastMonth();
		a.getTotalBudgetVI();
		a.getTotalBudgetVolume();
		a.getTotalBudgetUC();
		a.getVenueStatus();
		
		ASI_KOR_NSDApprovalController.NSDByBrandByCategory b = nsdController.nsdByBrandByCategoryList.get(0);
		b.getUnitCost_thisMonth();
		b.getUnitCost_1MonthAgo();
		b.getUnitCost_2MonthAgo();
		b.getUnitCost_budget();
		b.getBudgetStatus();
     }

}