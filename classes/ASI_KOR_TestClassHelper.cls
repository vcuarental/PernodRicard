@isTest
public class ASI_KOR_TestClassHelper{

    public static String SR_USER = 'srUser';
    public static String BM_USER = 'bmUser';
    public Static String RSD_USER = 'rsdUser';
    public Static String NSD_USER = 'nsdUser';
    
    public static String SR_PROP_HEADER = 'srPropHeader';
    public static String BM_PROP_HEADER = 'bmPropHeader';
    public Static String RSD_PROP_HEADER = 'rsdPropHeader';
    public Static String NSD_PROP_HEADER = 'nsdPropHeader';
    
    public static String SR_PROP_BRAND = 'srPropBrand';
    public static String BM_PROP_BRAND = 'bmPropBrand';
    public Static String RSD_PROP_BRAND = 'rsdPropBrand';
    public Static String NSD_PROP_BRAND = 'nsdPropBrand';
    
    public static String ABSOLUT_BRAND= 'absolut1';
    public static String INCENTIVE_SCHEME_1 = 'incentiveScheme1';
    public static String INCENTIVE_SCHEME_2 = 'incentiveScheme2';
    public static String VENUE_1 = 'venue1';
    
    public static Map<String,SObject> generateProposalObjects(){
        Map<String,SObject> proposalObjectsMap = new Map<String,SObject>();
        Profile p = [SELECT Id 
                         FROM profile WHERE name = 'ASI KOR Standard Platform User'];
        
        User nsd= new User(
        username = 'testqwe12390nsd@test123.com.pernod-ricard.laputa',
        Email = 'test1234nsd@test123.com',
        lastName = 'nsd',
        firstName = 'nsd',
        alias  = 'nsd123',
        languagelocalekey = 'en_US',
        localesidkey = 'en_US',
        emailEncodingKey = 'UTF-8',
        timeZoneSidKey = 'America/Los_Angeles',
        profileId = p.id,
		ASI_KOR_User_Region_Name__c = 'test'
        );

        insert nsd;
        
        User rsd= new User(
        username = 'testqwe12390rsd@test123.com.pernod-ricard.laputa',
        Email = 'test1234rsd@test123.com',
        lastName = 'rsd',
        firstName = 'rsd',
        alias  = 'rsd123',
        languagelocalekey = 'en_US',
        localesidkey = 'en_US',
        emailEncodingKey = 'UTF-8',
        timeZoneSidKey = 'America/Los_Angeles',
        profileId = p.id,
        managerid = nsd.id,
		ASI_KOR_User_Region_Name__c = 'test'
        );

        insert rsd;
        
        User bm= new User(
        username = 'testqwe12390bm@test123.com.pernod-ricard.laputa',
        Email = 'test1234bm@test123.com',
        lastName = 'bmbm',
        firstName = 'bbm',
        alias  = 'bm123',
        languagelocalekey = 'en_US',
        localesidkey = 'en_US',
        emailEncodingKey = 'UTF-8',
        timeZoneSidKey = 'America/Los_Angeles',
        profileId = p.id,
        managerid = rsd.id,
		ASI_KOR_User_Region_Name__c = 'test'
        );

        insert bm;
        
        User sr= new User(
        username = 'testqwe12390@test123.com.pernod-ricard.laputa',
        Email = 'test1234@test123.com',
        lastName = 'youn',
        firstName = 'gohooo',
        alias  = 'yougohoo',
        languagelocalekey = 'en_US',
        localesidkey = 'en_US',
        emailEncodingKey = 'UTF-8',
        timeZoneSidKey = 'America/Los_Angeles',
        profileId = p.id,
        managerid = bm.id,
        asi_kor_user_branch_code__c = '550',
		ASI_KOR_User_Region_Name__c = 'test'
        );

        insert sr;
        /*
        List<User> tempUserList = [select id,name,managerid from user where userroleid in (select Id from UserRole where name = 'Sales Representative - Choong Chung') and asi_kor_user_branch_code__c = '550'];
        User sr = tempUserList.get(0);      
        User bm = [select id,managerid from user where id =: sr.managerid];
        User rsd = [select id,managerid from user where id =: bm.managerid];
        User nsd = [select id from user where id =: rsd.managerid];
        */
        proposalObjectsMap.put(ASI_KOR_TestClassHelper.SR_USER, sr);
        proposalObjectsMap.put(ASI_KOR_TestClassHelper.BM_USER, bm);
        proposalObjectsMap.put(ASI_KOR_TestClassHelper.RSD_USER, rsd);
        proposalObjectsMap.put(ASI_KOR_TestClassHelper.NSD_USER, nsd);
        
        RecordType  rType = [select id from RecordType  where DeveloperName = 'ASI_KOR_Venue' and SobjectType ='Account'];
        Account venue1 = new Account( ASI_KOR_Postal_Code__c='1234',recordtypeid = rType.id,ASI_KOR_Grade__c='A',ASI_KOR_Venue_Channel__c='TOT', ASI_KOR_Venue_Pillar__c='W-TOT', Name='TestVenue', ASI_KOR_Customer_Code__c='33322111', ASI_KOR_Contract_Type__c='non-Contracted',ASI_KOR_Venue_Status__c ='Active' );
        venue1.ownerid = sr.id;
        insert venue1;
        proposalObjectsMap.put(VENUE_1, venue1);
        
        ASI_HK_CRM_Product_Category__c c1 = new ASI_HK_CRM_Product_Category__c (name = 'Modern Spirits');
        insert c1;
        ASI_KOR_Brand__c brand1 = new ASI_KOR_Brand__c(NAME='Absolut', ASI_KOR_BRAND_CODE__C='ABS1', ASI_KOR_SEQUENCE__C=300,  ASI_KOR_PRODUCT_CATEGORAY__C=c1.id);
        insert brand1;
        proposalObjectsMap.put(ABSOLUT_BRAND,brand1);
        ASI_KOR_Brand__c brand2 = new ASI_KOR_Brand__c(NAME='Absolut A', ASI_KOR_BRAND_CODE__C='ABS2', ASI_KOR_SEQUENCE__C=400,  ASI_KOR_PRODUCT_CATEGORAY__C=c1.id);
        insert brand2;
		
        ASI_KOR_Incentive_Scheme__c incentiveScheme1 = new ASI_KOR_Incentive_Scheme__c(ASI_KOR_BASIC_UNIT_COST__C=9000, ASI_KOR_CA_UNIT_COST__C=7900, ASI_KOR_UOM__C='Bottle', ASI_KOR_YEAR__C='2013', ASI_KOR_EFFECTIVE_START_DATE__C=Date.valueOf('2013-11-01'), ASI_KOR_EFFECTIVE_END_DATE__C=Date.valueOf('2014-05-31'), ASI_KOR_CHANNEL__C='W-TOT', ASI_KOR_GRADE__C='A', ASI_KOR_BRANCH__C='Sales ChoongChung Branch', ASI_KOR_CONTRACT__C='non-Contracted', ASI_KOR_BRAND__C=brand1.id, ASI_KOR_SALES_BRACKET__C=20, ASI_KOR_BRANCH_CODE__C='550');
        insert incentiveScheme1;
        proposalObjectsMap.put(INCENTIVE_SCHEME_1,incentiveScheme1);
        
        ASI_KOR_Incentive_Scheme__c incentiveScheme2 = new ASI_KOR_Incentive_Scheme__c(ASI_KOR_BASIC_UNIT_COST__C=9000, ASI_KOR_CA_UNIT_COST__C=8900, ASI_KOR_UOM__C='Bottle', ASI_KOR_YEAR__C='2013', ASI_KOR_EFFECTIVE_START_DATE__C=Date.valueOf('2013-11-01'), ASI_KOR_EFFECTIVE_END_DATE__C=Date.valueOf('2014-05-31'), ASI_KOR_CHANNEL__C='W-TOT', ASI_KOR_GRADE__C='A', ASI_KOR_BRANCH__C='Sales ChoongChung Branch', ASI_KOR_CONTRACT__C='non-Contracted', ASI_KOR_BRAND__C=brand1.id, ASI_KOR_SALES_BRACKET__C=30, ASI_KOR_BRANCH_CODE__C='550');
        insert incentiveScheme2;
        proposalObjectsMap.put(INCENTIVE_SCHEME_2,incentiveScheme2);
        
        ASI_KOR_Incentive_Scheme__c incentiveScheme3 = new ASI_KOR_Incentive_Scheme__c(ASI_KOR_BASIC_UNIT_COST__C=9000, ASI_KOR_CA_UNIT_COST__C=8900, ASI_KOR_UOM__C='Bottle', ASI_KOR_YEAR__C='2013', ASI_KOR_EFFECTIVE_START_DATE__C=Date.valueOf('2013-11-01'), ASI_KOR_EFFECTIVE_END_DATE__C=Date.valueOf('2014-05-31'), ASI_KOR_CHANNEL__C='W-TOT', ASI_KOR_GRADE__C='A', ASI_KOR_BRANCH__C='Sales ChoongChung Branch', ASI_KOR_CONTRACT__C='non-Contracted', ASI_KOR_BRAND__C=brand2.id, ASI_KOR_SALES_BRACKET__C=30, ASI_KOR_BRANCH_CODE__C='550');
        insert incentiveScheme3;
        
        ASI_KOR_Prepayment_Master__c prepay1 = new ASI_KOR_Prepayment_Master__c(
			ASI_KOR_Brand__c = brand1.id,
			ASI_KOR_Promotion_Month__c = '1',
			ASI_KOR_Promotion_Year__c = '2014',
			ASI_KOR_Remarks__c = 'test',
			ASI_KOR_Target_Unit_Cost__c = 10000,
			ASI_KOR_Venue__c = venue1.id
		);
		insert prepay1;
        
        ASI_KOR_Prepayment_Master__c prepay2 = new ASI_KOR_Prepayment_Master__c(
			ASI_KOR_Brand__c = brand1.id,
			ASI_KOR_Promotion_Month__c = '2',
			ASI_KOR_Promotion_Year__c = '2014',
			ASI_KOR_Remarks__c = 'test',
			ASI_KOR_Target_Unit_Cost__c = 10000,
			ASI_KOR_Venue__c = venue1.id
		);
		insert prepay2;
        
        ASI_KOR_NSD_Proposal_Header__c nsdHeader = new ASI_KOR_NSD_Proposal_Header__c(
        ASI_KOR_Year__c = '2014',   
        ASI_KOR_Month__c = '1', 
        ASI_KOR_Status__c = 'Draft',
        ASI_KOR_No_of_Sumitted_Regions__c = 5,
        ownerid = nsd.id,
            ASI_KOR_SYS_Cut_off_Date__c = Date.valueOf('2013-01-14')
        );
        
        insert nsdHeader;
        proposalObjectsMap.put(NSD_PROP_HEADER ,nsdHeader);
        
        
        ASI_KOR_NSD_Proposal_By_Brand__c nsdByBrand = new ASI_KOR_NSD_Proposal_By_Brand__c(
            ASI_KOR_Brand__c = brand1.id,
            ASI_KOR_NSD_Proposal_Header__c = nsdHeader.id,
            ASI_KOR_UOM__c = 'Bottle'
        );
        
        insert nsdByBrand;
        proposalObjectsMap.put(NSD_PROP_BRAND ,nsdHeader);
        
       ASI_KOR_RSD_Proposal_Header__c rsdHeader = new ASI_KOR_RSD_Proposal_Header__c(
        ASI_KOR_Year__c = '2014',   
        ASI_KOR_Month__c = '1', 
        ASI_KOR_Status__c = 'Draft', 
        ASI_KOR_NSD_Proposal_Header__c = nsdHeader.id,
        ownerid = rsd.id
         
        
        );
        insert rsdHeader;
        proposalObjectsMap.put(RSD_PROP_HEADER ,rsdHeader);
        ASI_KOR_RSD_Proposal_By_Brand__c rsdByBrand = new ASI_KOR_RSD_Proposal_By_Brand__c(
            ASI_KOR_Brand__c = brand1.id,
            ASI_KOR_RSD_Proposal_Header__c= rsdHeader.id,
            ASI_KOR_UOM__c = 'Bottle',
            ASI_KOR_NSD_Proposal_By_Brand__c = nsdByBrand.id
        );
        
        insert rsdByBrand;
        proposalObjectsMap.put(RSD_PROP_BRAND ,rsdByBrand);
        
       ASI_KOR_BM_Proposal_Header__c bmHeader = new ASI_KOR_BM_Proposal_Header__c(
        ASI_KOR_Year__c = '2014',   
        ASI_KOR_Month__c = '1', 
        ASI_KOR_Status__c = 'Draft', 
        ASI_KOR_RSD_Proposal_Header__c = rsdHeader.id,
         ownerid = bm.id 
        );
        insert bmHeader;
        proposalObjectsMap.put(BM_PROP_HEADER ,bmHeader);

        
       ASI_KOR_BM_Proposal_By_Brand__c bmByBrand = new ASI_KOR_BM_Proposal_By_Brand__c(
            ASI_KOR_Brand__c = brand1.id,
            ASI_KOR_BM_Proposal_Header__c = bmHeader.id,
            ASI_KOR_UOM__c = 'Bottle',
            ASI_KOR_RSD_Proposal_By_Brand__c = rsdByBrand.id
        );
        
        insert bmByBrand;
       proposalObjectsMap.put(BM_PROP_BRAND ,bmByBrand);
       ASI_KOR_SR_Proposal_Header__c srHeader = new ASI_KOR_SR_Proposal_Header__c(
        ASI_KOR_Year__c = '2014',   
        ASI_KOR_Month__c = '1', 
        ASI_KOR_Status__c = 'Draft',
        ASI_KOR_BM_Proposal_Header__c = bmHeader.id,
        ownerid = sr.id
        );
        
        insert srHeader;
        proposalObjectsMap.put(SR_PROP_HEADER ,srHeader);
        ASI_KOR_SR_Proposal_By_Brand__c srByBrand = new ASI_KOR_SR_Proposal_By_Brand__c(
            ASI_KOR_Brand__c = brand1.id,
            ASI_KOR_SR_Proposal_Header__c = srHeader.id,
            ASI_KOR_UOM__c = 'Bottle',
            ASI_KOR_BM_Proposal_By_Brand__c = bmByBrand.id
            
        );
        
        insert srByBrand;
        proposalObjectsMap.put(SR_PROP_BRAND ,srByBrand);
		
		ASI_KOR_SR_Proposal_Detail__c srDetail = new ASI_KOR_SR_Proposal_Detail__c(
			ASI_KOR_Target_Volume__c = 25,
            ASI_KOR_SR_Proposal_ID__c = srHeader.id,
			ASI_KOR_SR_Proposal_By_Brand__c = srByBrand.id,
			ASI_KOR_Venue__c = venue1.id,
			ASI_KOR_Incentive_Scheme__c = incentiveScheme1.id,
			ASI_KOR_Brand__c = brand1.id,
			ASI_KOR_Proposal_Unit_Cost_Basic_CA__c = 1000
		);
		ASI_KOR_SR_Proposal_Detail__c srDetail1 = new ASI_KOR_SR_Proposal_Detail__c(
			ASI_KOR_Target_Volume__c = 0,
            ASI_KOR_SR_Proposal_ID__c = srHeader.id,
			ASI_KOR_SR_Proposal_By_Brand__c = srByBrand.id,
			ASI_KOR_Venue__c = venue1.id,
			ASI_KOR_Incentive_Scheme__c = incentiveScheme1.id,
			ASI_KOR_Brand__c = brand1.id,
			ASI_KOR_Proposal_Unit_Cost_Basic_CA__c = 0
		);
		insert srDetail;
		insert srDetail1;
		system.debug(srDetail);
       
        return proposalObjectsMap;    
    }

}