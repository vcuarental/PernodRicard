@isTest
public class ASI_KOR_SRProposalCloneExtControllerTest{

    @isTest(seeAllData=false)
    public static void testSRProposalCloneProposalController(){
    Map<String,SObject>  propObjects = ASI_KOR_TestClassHelper.generateProposalObjects();
    ASI_KOR_Brand__c brand1 = (ASI_KOR_Brand__c ) propObjects.get(ASI_KOR_TestClassHelper.ABSOLUT_BRAND);
       
        User sr = (User) propObjects.get(ASI_KOR_TestClassHelper.SR_USER);
        User bm = (User) propObjects.get(ASI_KOR_TestClassHelper.BM_USER);
        User rsd= (User) propObjects.get(ASI_KOR_TestClassHelper.RSD_USER);
        User nsd= (User) propObjects.get(ASI_KOR_TestClassHelper.NSD_USER);
       Account venue = (Account) propObjects.get(ASI_KOR_TestClassHelper.VENUE_1);
        /*
        RecordType  rType = [select id from RecordType  where DeveloperName = 'ASI_KOR_Venue' and SobjectType ='Account'];
        Account a = new Account( ASI_KOR_Postal_Code__c='1234',recordtypeid = rType.id,ASI_KOR_Grade__c='A',ASI_KOR_Venue_Channel__c='', Name='TestVenue', ASI_KOR_Customer_Code__c='43800038', ASI_KOR_Contract_Type__c='non-Contracted',ASI_KOR_Venue_Status__c ='Active' );
        a.ownerid = sr.id;
        insert a;
        ASI_KOR_TestHelper.insertAccounts();
        ASI_KOR_TestHelper.insertIncentiveSchemes();
        
        ASI_KOR_NSD_Proposal_Header__c nsdHeader = new ASI_KOR_NSD_Proposal_Header__c(
        ASI_KOR_Year__c = '2014',   
        ASI_KOR_Month__c = '1', 
        ASI_KOR_Status__c = 'Draft',
        ASI_KOR_No_of_Sumitted_Regions__c = 5,
        ownerid = nsd.id,
            ASI_KOR_SYS_Cut_off_Date__c = Date.valueOf('2013-01-14')
        );
        
        insert nsdHeader;
        
        ASI_KOR_NSD_Proposal_By_Brand__c nsdByBrand = new ASI_KOR_NSD_Proposal_By_Brand__c(
            ASI_KOR_Brand__c = brandMap.get('Absolut'),
            ASI_KOR_NSD_Proposal_Header__c = nsdHeader.id,
            ASI_KOR_UOM__c = 'Bottle'
        );
        */
         ASI_KOR_NSD_Proposal_Header__c nsdHeader2 = new ASI_KOR_NSD_Proposal_Header__c(
        ASI_KOR_Year__c = '2014',   
        ASI_KOR_Month__c = '2', 
        ASI_KOR_Status__c = 'Draft',
        ASI_KOR_No_of_Sumitted_Regions__c = 5,
        ownerid = nsd.id,
            ASI_KOR_SYS_Cut_off_Date__c = Date.valueOf('2013-01-14')
        );
        
        insert nsdHeader2;
        
        ASI_KOR_NSD_Proposal_By_Brand__c nsdByBrand2 = new ASI_KOR_NSD_Proposal_By_Brand__c(
            ASI_KOR_Brand__c = brand1.id,
            ASI_KOR_NSD_Proposal_Header__c = nsdHeader2.id,
            ASI_KOR_UOM__c = 'Bottle'
        );
        
        insert nsdByBrand2;
        /*
       ASI_KOR_RSD_Proposal_Header__c rsdHeader = new ASI_KOR_RSD_Proposal_Header__c(
        ASI_KOR_Year__c = '2014',   
        ASI_KOR_Month__c = '1', 
        ASI_KOR_Status__c = 'Draft', 
        ASI_KOR_NSD_Proposal_Header__c = nsdHeader.id,
         ownerid = rsd.id
         
        
        );
        insert rsdHeader;
        
        ASI_KOR_RSD_Proposal_By_Brand__c rsdByBrand = new ASI_KOR_RSD_Proposal_By_Brand__c(
            ASI_KOR_Brand__c = brandMap.get('Absolut'),
            ASI_KOR_RSD_Proposal_Header__c= rsdHeader.id,
            ASI_KOR_UOM__c = 'Bottle',
            ASI_KOR_NSD_Proposal_By_Brand__c = nsdByBrand.id
        );
        
        insert rsdByBrand;
        */
          ASI_KOR_RSD_Proposal_Header__c rsdHeader2 = new ASI_KOR_RSD_Proposal_Header__c(
        ASI_KOR_Year__c = '2014',   
        ASI_KOR_Month__c = '2', 
        ASI_KOR_Status__c = 'Draft', 
        ASI_KOR_NSD_Proposal_Header__c = nsdHeader2.id,
         ownerid = rsd.id
         
        
        );
        
        insert rsdHeader2;
        
        ASI_KOR_RSD_Proposal_By_Brand__c rsdByBrand2 = new ASI_KOR_RSD_Proposal_By_Brand__c(
            ASI_KOR_Brand__c = brand1.id,
            ASI_KOR_RSD_Proposal_Header__c= rsdHeader2.id,
            ASI_KOR_UOM__c = 'Bottle',
            ASI_KOR_NSD_Proposal_By_Brand__c = nsdByBrand2.id
        );
        
        insert rsdByBrand2;
        /*
       ASI_KOR_BM_Proposal_Header__c bmHeader = new ASI_KOR_BM_Proposal_Header__c(
        ASI_KOR_Year__c = '2014',   
        ASI_KOR_Month__c = '1', 
        ASI_KOR_Status__c = 'Draft', 
        ASI_KOR_RSD_Proposal_Header__c = rsdHeader.id,
         ownerid = bm.id 
        );
        
        insert bmHeader;
        
       ASI_KOR_BM_Proposal_By_Brand__c bmByBrand = new ASI_KOR_BM_Proposal_By_Brand__c(
            ASI_KOR_Brand__c = brandMap.get('Absolut'),
            ASI_KOR_BM_Proposal_Header__c = bmHeader.id,
            ASI_KOR_UOM__c = 'Bottle',
            ASI_KOR_RSD_Proposal_By_Brand__c = rsdByBrand.id
        );
        
        insert bmByBrand;
        */
        
               ASI_KOR_BM_Proposal_Header__c bmHeader2 = new ASI_KOR_BM_Proposal_Header__c(
        ASI_KOR_Year__c = '2014',   
        ASI_KOR_Month__c = '2', 
        ASI_KOR_Status__c = 'Draft', 
        ASI_KOR_RSD_Proposal_Header__c = rsdHeader2.id,
         ownerid = bm.id 
        );
        
        insert bmHeader2;
        
       ASI_KOR_BM_Proposal_By_Brand__c bmByBrand2 = new ASI_KOR_BM_Proposal_By_Brand__c(
            ASI_KOR_Brand__c = brand1.id,
            ASI_KOR_BM_Proposal_Header__c = bmHeader2.id,
            ASI_KOR_UOM__c = 'Bottle',
            ASI_KOR_RSD_Proposal_By_Brand__c = rsdByBrand2.id
        );
        
        insert bmByBrand2;
       /*
       ASI_KOR_SR_Proposal_Header__c srHeader = new ASI_KOR_SR_Proposal_Header__c(
        ASI_KOR_Year__c = '2014',   
        ASI_KOR_Month__c = '1', 
        ASI_KOR_Status__c = 'Approved by BM',
        ASI_KOR_BM_Proposal_Header__c = bmHeader.id,
        ownerid = sr.id
        );
        
        insert srHeader;
        
        ASI_KOR_SR_Proposal_By_Brand__c srByBrand = new ASI_KOR_SR_Proposal_By_Brand__c(
            ASI_KOR_Brand__c = brandMap.get('Absolut'),
            ASI_KOR_SR_Proposal_Header__c = srHeader.id,
            ASI_KOR_UOM__c = 'Bottle',
            ASI_KOR_BM_Proposal_By_Brand__c = bmByBrand.id
            
        );
        
        insert srByBrand;
        */
        
       ASI_KOR_SR_Proposal_Header__c srHeader2 = new ASI_KOR_SR_Proposal_Header__c(
        ASI_KOR_Year__c = '2014',   
        ASI_KOR_Month__c = '2', 
        ASI_KOR_Status__c = 'Draft',
        ASI_KOR_BM_Proposal_Header__c = bmHeader2.id,
        ownerid = sr.id
        );
        
        insert srHeader2;
         
       //ASI_KOR_Incentive_Scheme__c ic1 = new ASI_KOR_Incentive_Scheme__c(ASI_KOR_BASIC_UNIT_COST__C=9000, ASI_KOR_CA_UNIT_COST__C=1310, ASI_KOR_UOM__C='Actual Case', ASI_KOR_YEAR__C='2013', ASI_KOR_EFFECTIVE_START_DATE__C=Date.valueOf('2013-11-01'), ASI_KOR_EFFECTIVE_END_DATE__C=Date.valueOf('2014-05-31'), ASI_KOR_CHANNEL__C='W-TOT', ASI_KOR_GRADE__C='A', ASI_KOR_BRANCH__C='Sales ChoongChung Branch', ASI_KOR_CONTRACT__C='non-Contracted', ASI_KOR_BRAND__C=brand1 .id, ASI_KOR_SALES_BRACKET__C=10, ASI_KOR_BRANCH_CODE__C='550');
       ASI_KOR_Incentive_Scheme__c ic2 = new ASI_KOR_Incentive_Scheme__c(ASI_KOR_BASIC_UNIT_COST__C=9000, ASI_KOR_CA_UNIT_COST__C=7900, ASI_KOR_UOM__C='Bottle', ASI_KOR_YEAR__C='2013', ASI_KOR_EFFECTIVE_START_DATE__C=Date.valueOf('2013-11-01'), ASI_KOR_EFFECTIVE_END_DATE__C=Date.valueOf('2014-05-31'), ASI_KOR_CHANNEL__C='W-TOT', ASI_KOR_GRADE__C='A', ASI_KOR_BRANCH__C='Sales ChoongChung Branch', ASI_KOR_CONTRACT__C='non-Contracted', ASI_KOR_BRAND__C=brand1.id, ASI_KOR_SALES_BRACKET__C=20, ASI_KOR_BRANCH_CODE__C='550');
       insert ic2;
        ASI_KOR_SR_Proposal_Detail__c proposaDetail = new ASI_KOR_SR_Proposal_Detail__c();
             proposaDetail.ASI_KOR_Target_Volume__c = 100;
             proposaDetail.ASI_KOR_Cap_Unit_Cost_Basic__c = 10000;
             proposaDetail.ASI_KOR_Cap_Unit_Cost_CA__c = 1000;
             proposaDetail.ASI_KOR_Proposal_Unit_Cost_Basic_CA__c = 100000;
             proposaDetail.ASI_KOR_Unit_Cost_Cap_Actual_Volume__c = 9000;
             proposaDetail.ASI_KOR_SR_Proposal_ID__c = ((ASI_KOR_SR_Proposal_Header__c) propObjects.get(ASI_KOR_TestClassHelper.SR_PROP_HEADER)).id;
             proposaDetail.ASI_KOR_SR_Proposal_By_Brand__c = ((ASI_KOR_SR_Proposal_By_Brand__c ) propObjects.get(ASI_KOR_TestClassHelper.SR_PROP_BRAND)).id;
             proposaDetail.ASI_KOR_Venue__c = venue.id;
             proposaDetail.ASI_KOR_Brand__c = brand1 .id;
         insert proposaDetail;
        
        
        ApexPages.StandardController sc = new ApexPages.standardController(srHeader2);
        ASI_KOR_SRProposalCloneExtController srCloneController = new ASI_KOR_SRProposalCloneExtController(sc);
        srCloneController.save();
        }
        
}