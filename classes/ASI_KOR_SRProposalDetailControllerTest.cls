@isTest
public class ASI_KOR_SRProposalDetailControllerTest{

    private static Map<String,SObject> propObjects;
    private static User sr; 
    private static ASI_KOR_SR_Proposal_Header__c srHeader;
    private static ASI_KOR_Incentive_Scheme__c incentiveScheme1;
    private static ApexPages.StandardController sc;
    private static ASI_KOR_SalesRepProposalDetailController srController;
     
    public static void init(){
    
        propObjects = ASI_KOR_TestClassHelper.generateProposalObjects();
        sr = (User) propObjects.get(ASI_KOR_TestClassHelper.SR_USER); 

        srHeader = (ASI_KOR_SR_Proposal_Header__c) propObjects.get(ASI_KOR_TestClassHelper.SR_PROP_HEADER);
        incentiveScheme1 = (ASI_KOR_Incentive_Scheme__c) propObjects.get(ASI_KOR_TestClassHelper.INCENTIVE_SCHEME_1); 
        
		 ASI_CRM_KR_Unit_Cost_Threshold__c thresholdSetting = new ASI_CRM_KR_Unit_Cost_Threshold__c(
			name = '2014-1',
			ASI_CRM_KR_Threshold__c = 1000000
		 );
		 insert thresholdSetting;
		 
        sc = new ApexPages.standardController(srHeader);
        srController = new ASI_KOR_SalesRepProposalDetailController(sc);
    }
    
    @isTest
    public static void testSave(){
 
        init();

        List<ASI_KOR_SR_Proposal_Detail__c> proposalDetails = srController.proposalDetails;
        ASI_KOR_SR_Proposal_Detail__c proposaDetail = null;
         
        if( proposalDetails.size() > 0){
             proposaDetail = proposalDetails.get(0);
             proposaDetail.ASI_KOR_Target_Volume__c = 100;
             proposaDetail.ASI_KOR_Cap_Unit_Cost_Basic__c = 10000;
             proposaDetail.ASI_KOR_Cap_Unit_Cost_CA__c = 1000;
             proposaDetail.ASI_KOR_Proposal_Unit_Cost_Basic_CA__c = 100000;
             proposaDetail.ASI_KOR_Unit_Cost_Cap_Actual_Volume__c = 9000;
             proposaDetail.ASI_KOR_Incentive_Scheme__r = incentiveScheme1 ;
             proposaDetail.ASI_KOR_Incentive_Scheme__c = incentiveScheme1.id;
         } 
         
        srController.handleSave();
        List<ASI_KOR_SR_Proposal_Detail__c> propList = [select
        id from ASI_KOR_SR_Proposal_Detail__c 
        where
        ASI_KOR_SR_Proposal_ID__c =: srHeader.id];
        //system.Assert(propList.size() > 0);
        
        //reload the page.
        sc = new ApexPages.standardController(srHeader);
        srController = new ASI_KOR_SalesRepProposalDetailController(sc);
     }
     
    @isTest
    public static void testRemoting(){
 
        init();

        List<ASI_KOR_SR_Proposal_Detail__c> proposalDetails = srController.proposalDetails;
         
        ASI_KOR_SR_Proposal_Detail__c proposaDetail = null;
         
        if( proposalDetails.size() > 0){
             proposaDetail = proposalDetails.get(0);
             proposaDetail.ASI_KOR_Target_Volume__c = 100;
             proposaDetail.ASI_KOR_Cap_Unit_Cost_Basic__c = 10000;
             proposaDetail.ASI_KOR_Cap_Unit_Cost_CA__c = 1000;
             proposaDetail.ASI_KOR_Proposal_Unit_Cost_Basic_CA__c = 100000;
             proposaDetail.ASI_KOR_Unit_Cost_Cap_Actual_Volume__c = 9000;
             proposaDetail.ASI_KOR_Incentive_Scheme__r = incentiveScheme1 ;
             proposaDetail.ASI_KOR_Incentive_Scheme__c = incentiveScheme1.id;
         }
         
             
         ASI_KOR_Brand__c brand1 = (ASI_KOR_Brand__c ) propObjects.get(ASI_KOR_TestClassHelper.ABSOLUT_BRAND);
         
		 /* before P4.2
         String param = brand1.id+'|550|25|Bottle|non-Contracted|1|2014|1|A|W-TOT';
		 */
         String param = brand1.id+'|W-TOT|25|2014|1';

         String result = ASI_KOR_SalesRepProposalDetailController.getCA(param);  
         
         //system.assertEquals('7900|9000|'+incentiveScheme1.id+'|Bottle|2013|12|12013. 12. 12013-12-31 00:00:00', result);
		 /* before P4.2
         system.assert(result.containsAny('7900|9000|'+incentiveScheme1.id+'|Bottle|2013|12'));
		 */
         system.debug('OO' + result);       
         
     }
     
    @isTest
    public static void testSelectVenue(){
 
        init();

        List<ASI_KOR_SR_Proposal_Detail__c> proposalDetails = srController.proposalDetails;
         
        ASI_KOR_SR_Proposal_Detail__c proposaDetail = null;

         Account venue = (Account) propObjects.get(ASI_KOR_TestClassHelper.VENUE_1);
         srController.selectedVenues = venue.id;
         srController.selectVenue();
         srController.filterVenues();
         srController.doNothing();
         system.assert(srController.venueSummaryList.size()>0); 
     }
     
    @isTest
    public static void testSubmitAndRecall(){
        
        init();

        List<ASI_KOR_SR_Proposal_Detail__c> proposalDetails = srController.proposalDetails;
         
        ASI_KOR_SR_Proposal_Detail__c proposaDetail = null;
         
        if( proposalDetails.size() > 0){
             proposaDetail = proposalDetails.get(0);
             proposaDetail.ASI_KOR_Target_Volume__c = 100;
             proposaDetail.ASI_KOR_Cap_Unit_Cost_Basic__c = 10000;
             proposaDetail.ASI_KOR_Cap_Unit_Cost_CA__c = 1000;
             proposaDetail.ASI_KOR_Proposal_Unit_Cost_Basic_CA__c = 100000;
             proposaDetail.ASI_KOR_Unit_Cost_Cap_Actual_Volume__c = 9000;
             proposaDetail.ASI_KOR_Incentive_Scheme__r = incentiveScheme1 ;
             proposaDetail.ASI_KOR_Incentive_Scheme__c = incentiveScheme1.id;
			 proposaDetail.ASI_KOR_Is_Pre_payment__c = true;
         }
   
         Account venue = (Account) propObjects.get(ASI_KOR_TestClassHelper.VENUE_1);
         srController.handleSubmit();
         
         ASI_KOR_SR_Proposal_Header__c header = [select id, asi_kor_status__c from ASI_KOR_SR_Proposal_Header__c
         where id =: srHeader.id];
         
         //system.assertEquals('Submitted', header.asi_kor_status__c);
         
         srController.handleRecall();
         
         header = [select id, asi_kor_status__c from ASI_KOR_SR_Proposal_Header__c
         where id =: srHeader.id];
         
         system.assertEquals('Draft', header.asi_kor_status__c);
     }
     
    @isTest
    public static void testRollUpAndGenerateByBrands(){
 
        init();

        List<ASI_KOR_SR_Proposal_Detail__c> proposalDetails = srController.proposalDetails;
         
        ASI_KOR_SR_Proposal_Detail__c proposaDetail = null;
         
        if( proposalDetails.size() > 0){
             proposaDetail = proposalDetails.get(0);
             proposaDetail.ASI_KOR_Target_Volume__c = 100;
             proposaDetail.ASI_KOR_Cap_Unit_Cost_Basic__c = 10000;
             proposaDetail.ASI_KOR_Cap_Unit_Cost_CA__c = 1000;
             proposaDetail.ASI_KOR_Proposal_Unit_Cost_Basic_CA__c = 100000;
             proposaDetail.ASI_KOR_Unit_Cost_Cap_Actual_Volume__c = 9000;
             proposaDetail.ASI_KOR_Incentive_Scheme__r = incentiveScheme1 ;
             proposaDetail.ASI_KOR_Incentive_Scheme__c = incentiveScheme1.id;
         }
         
             
         ASI_KOR_Brand__c brand1 = (ASI_KOR_Brand__c ) propObjects.get(ASI_KOR_TestClassHelper.ABSOLUT_BRAND);
         
         ASI_KOR_SalesRepProposalDetailController.rollUp(srHeader.id,true);
         ASI_KOR_SalesRepProposalDetailController.rollUp(srHeader.id,false);
         
         system.assert(srController.generateSRProposalByBrand(brand1.id,'Actual Case') != null );         
         system.assert(srController.generateBMProposalByBrand(brand1.id,'Actual Case') != null);
         system.assert(srController.generateRSDProposalByBrand(brand1.id) != null);
         system.assert(srController.generateNSDProposalByBrand(brand1.id) != null);
     }

    @isTest
    public static void testGetMethod(){
 
        init();

        srController.getGrandTotalByBrand_uc_2M();
        srController.getGrandTotalByBrand_uc_1M();
        srController.getGrandTotalByBrand_uc_TM();
        srController.getLast2Month_year();
        srController.getLast2Month_month();
        srController.getLast1Month_year();
        srController.getLast1Month_month();
        srController.getThisMonth_year();
        srController.getThisMonth_month();
        srController.getTotalVenueOwnedBySR();
        srController.getLast1Month_year();
        srController.getVenueSummaryList_split();
        srController.getVenues_split();
        srController.getYear();
        srController.getMonth();
        srController.refreshVenueSummary();
     }

        
}