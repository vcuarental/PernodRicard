@isTest
public class ASI_KOR_RSDApprovalControllerTest{
    private static Map<String,SObject> propObjects;
    private static User sr;
    private static User bm;
    private static User rsd;
    private static User nsd;
    
    private static ASI_KOR_Incentive_Scheme__c incentiveScheme1;
    private static ApexPages.StandardController sc;
    private static ASI_KOR_RSDApprovalController rsdController;
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
        bmHeader.ASI_KOR_Status__c ='Submitted';
		nsdHeader.ASI_KOR_Status__c = 'In Progress';
        update srHeader;
        update bmHeader;
		update nsdHeader;
       
        sc = new ApexPages.standardController(rsdHeader);
        rsdController = new ASI_KOR_RSDApprovalController(sc);
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
		 
		 
        // create venue depletion
        list<ASI_KOR_Venue_Depletion__c> list_vd = new list<ASI_KOR_Venue_Depletion__c>();
        ASI_KOR_Venue_Depletion__c vd1 = new ASI_KOR_Venue_Depletion__c(
        	ASI_KOR_Venue__c = venue.id,
            ASI_KOR_Year__c = '2014',
            ASI_KOR_Month__c = 'January'
        );
        list_vd.add(vd1);
        ASI_KOR_Venue_Depletion__c vd4 = new ASI_KOR_Venue_Depletion__c(
        	ASI_KOR_Venue__c = venue.id,
            ASI_KOR_Year__c = '2013',
            ASI_KOR_Month__c = 'December'
        );
        list_vd.add(vd4);
        
        insert list_vd;
        
		Map<String,Id> brandMap = new Map<String,Id>();
		brandMap.put(brand1.name, brand1.id);
        Map<String,Id> productItemMap = ASI_KOR_TestHelper.insertProductItem(brandMap);
        Map<String,Id> itemGroupMap = ASI_KOR_TestHelper.insertItemGroup(productItemMap);
        
        list<ASI_KOR_Venue_Depletion_Detail__c> list_vdd = new list<ASI_KOR_Venue_Depletion_Detail__c>();
        for (ASI_KOR_Venue_Depletion__c vd : list_vd ){
            string vdID = vd.id;
            for (string itemGroupID : itemGroupMap.values()){
                ASI_KOR_Venue_Depletion_Detail__c vdd1 = new ASI_KOR_Venue_Depletion_Detail__c(
                	ASI_KOR_Venue_Depletion__c = vd.id,
                    ASI_KOR_Item_Group_Code__c = itemGroupID,
                    ASI_KOR_Pay_Type__c = 'Normal-Pay',
                    ASI_KOR_Venue_Depl_Info_Promotion_Amount__c = 10,
                    ASI_KOR_Venue_Depl_Info_Depletion_Volume__c = 10,
                    ASI_KOR_Venue_Depl_Info_Depletion_Case__c = 10
                );
                list_vdd.add(vdd1);
                ASI_KOR_Venue_Depletion_Detail__c vdd2 = new ASI_KOR_Venue_Depletion_Detail__c(
                	ASI_KOR_Venue_Depletion__c = vd.id,
                	ASI_KOR_Item_Group_Code__c = itemGroupID,
                    ASI_KOR_Pay_Type__c = 'Pre-Pay',
                    ASI_KOR_Venue_Depl_Info_Promotion_Amount__c = 10,
                    ASI_KOR_Venue_Depl_Info_Depletion_Volume__c = 10,
                    ASI_KOR_Venue_Depl_Info_Depletion_Case__c = 10
                );
                list_vdd.add(vdd2);
            }
        }
        insert list_vdd;
        
    }
    @isTest 
    public static void testSave(){
        init();
        for(ASI_KOR_RSDApprovalController.BMByBranchCategory bByCat : rsdController.bmByBranchCategoryList){
            bByCat.bmHeader.asi_kor_status__c = 'Approved by TMKT';
        }
        rsdController.handleSave();
        for(ASI_KOR_RSDApprovalController.BMByBranchCategory bByCat : rsdController.bmByBranchCategoryList){
            bByCat.bmHeader.asi_kor_status__c = 'Approved by RSD';
        }
        rsdController.handleSave();
        List<ASI_KOR_BM_Proposal_Header__c> bmHeaderList = [select id, asi_kor_status__c from ASI_KOR_BM_Proposal_Header__c 
        where ASI_KOR_RSD_Proposal_Header__c =: rsdHeader.id];
        
        for(ASI_KOR_BM_Proposal_Header__c bmHeaderR : bmHeaderList){
            system.assertEquals('Approved by RSD', bmHeaderR.asi_kor_status__c);
        }

    }
    /*
    @isTest 
    public static void testSubmitAndRecall(){
        init();
        for(ASI_KOR_RSDApprovalController.BMByBranchCategory bByCat : rsdController.bmByBranchCategoryList){
            bByCat.bmHeader.asi_kor_status__c = 'Approved byRSD';
        }
        rsdController.handleSave();
        rsdController.handleSubmit();
        ASI_KOR_RSD_Proposal_Header__c rsdHeaderR = [select id, asi_kor_status__c from ASI_KOR_RSD_Proposal_Header__c 
        where id=: rsdHeader.id];
        system.assertEquals('Submitted', rsdHeaderR.asi_kor_status__c);
        rsdController.handleRecall();
        rsdHeaderR = [select id, asi_kor_status__c from ASI_KOR_RSD_Proposal_Header__c 
        where id=: rsdHeader.id];
        system.assertEquals('Draft', rsdHeaderR.asi_kor_status__c);
    }
	*/
    @isTest 
    public static void testSubmit(){
        init();
        for(ASI_KOR_RSDApprovalController.BMByBranchCategory bByCat : rsdController.bmByBranchCategoryList){
            bByCat.bmHeader.asi_kor_status__c = 'Approved by RSD';
        }
        rsdController.handleSave();
        rsdController.handleSubmit();
        /*
        ASI_KOR_RSD_Proposal_Header__c rsdHeaderR = [select id, asi_kor_status__c from ASI_KOR_RSD_Proposal_Header__c 
        where id=: rsdHeader.id];
        system.assertEquals('Submitted', rsdHeaderR.asi_kor_status__c);
        */
    }
    @isTest 
    public static void testRecall(){
        init();
        rsdController.handleRecall();
        /*
        ASI_KOR_RSD_Proposal_Header__c rsdHeaderR = [select id, asi_kor_status__c from ASI_KOR_RSD_Proposal_Header__c 
        where id=: rsdHeader.id];
        system.assertEquals('Draft', rsdHeaderR.asi_kor_status__c);
        */
    }
    
    @isTest 
    public static void testStaticMethods(){
        init();
        ASI_KOR_RSDApprovalController.rollUp(rsdHeader.id,true);
        ASI_KOR_RSDApprovalController.rollUp(rsdHeader.id,false);
        ASI_KOR_RSDApprovalController.rollUpCAPending(rsdHeader.id,true);
        ASI_KOR_RSDApprovalController.rollUpCAPending(rsdHeader.id,false);
    }

    @isTest
    public static void testGetMethod(){
 
        init();

        rsdController.getGrandTotalByBrand_uc_2M();
        rsdController.getGrandTotalByBrand_uc_1M();
        rsdController.getGrandTotalByBrand_uc_TM();
        rsdController.getGrandTotalByBrand_uc_budget();
        rsdController.getGrandTotalByBrandBudgetStatus();
        rsdController.getLast2Month_year();
        rsdController.getLast2Month_month();
        rsdController.getLast1Month_year();
        rsdController.getLast1Month_month();
        rsdController.getThisMonth_year();
        rsdController.getThisMonth_month();
        rsdController.getGrandBudgetStatus();
		
		ASI_KOR_RSDApprovalController.BMByBranchCategory a = rsdController.bmByBranchCategoryList.get(0);
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
		
		ASI_KOR_RSDApprovalController.RSDByBrandByCategory b = rsdController.rsdByBrandByCategoryList.get(0);
		b.getUnitCost_thisMonth();
		b.getUnitCost_1MonthAgo();
		b.getUnitCost_2MonthAgo();
		b.getUnitCost_budget();
		b.getBudgetStatus();
     }

}