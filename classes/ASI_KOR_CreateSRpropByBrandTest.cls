@isTest
public class ASI_KOR_CreateSRpropByBrandTest {    

    static testMethod void testexecution(){
		Map<String,Id> brandMap = ASI_KOR_TestHelper.insertBrands();
        string TimeZoneSidKey = 'America/Los_Angeles';
        string LocaleSidKey = 'en_US';
        string EmailEncodingKey = 'UTF-8';
        string LanguageLocaleKey = 'en_US';
        string region = 'test';
        
        User nsd = new User(
            FirstName = 'nsd',
            LastName = 'test',
            Email = 'testnsd@test.com',
            Username = 'testnsd@pernod-ricard.com.testnsd',
            ProfileId = '00eD0000001AneY',
            Alias = 'nsd',
            CommunityNickname = 'nsd',
            TimeZoneSidKey=TimeZoneSidKey,
            LocaleSidKey=LocaleSidKey,
            EmailEncodingKey=EmailEncodingKey,
            LanguageLocaleKey=LanguageLocaleKey
        );
        insert nsd;
        
        User rsd = new User(
            FirstName = 'rsd',
            LastName = 'test',
            managerid = nsd.id,
            Email = 'testrsd@test.com',
            Username = 'testrsd@pernod-ricard.com.testrsd',
            ProfileId = '00eD0000001AneY',
            Alias = 'rsd',
            CommunityNickname = 'rsd',
            TimeZoneSidKey=TimeZoneSidKey,
            LocaleSidKey=LocaleSidKey,
            EmailEncodingKey=EmailEncodingKey,
            LanguageLocaleKey=LanguageLocaleKey,
            ASI_KOR_User_Region_Name__c = region,
            ASI_KOR_User_Branch_Code__c = '550'
        );
        insert rsd;
        
        User bm = new User(
            FirstName = 'bm',
            LastName = 'test',
            managerid = rsd.id,
            Email = 'testbm@test.com',
            Username = 'testbm@pernod-ricard.com.testbm',
            ProfileId = '00eD0000001AneY',
            Alias = 'bm',
            CommunityNickname = 'bm',
            TimeZoneSidKey=TimeZoneSidKey,
            LocaleSidKey=LocaleSidKey,
            EmailEncodingKey=EmailEncodingKey,
            LanguageLocaleKey=LanguageLocaleKey,
            ASI_KOR_User_Region_Name__c = region
        );
        insert bm;
        
        User sr = new User(
            FirstName = 'sr',
            LastName = 'test',
            managerid = bm.id,
            Email = 'testsr@test.com',
            Username = 'testsr@pernod-ricard.com.testsr',
            ProfileId = '00eD0000001AneY',
            Alias = 'sr',
            CommunityNickname = 'sr',
            TimeZoneSidKey=TimeZoneSidKey,
            LocaleSidKey=LocaleSidKey,
            EmailEncodingKey=EmailEncodingKey,
            LanguageLocaleKey=LanguageLocaleKey,
            ASI_KOR_User_Region_Name__c = region,
            ASI_KOR_User_Branch_Code__c = '550'
        );
        insert sr;

        User sr2 = new User(
            FirstName = 'sr2',
            LastName = 'test',
            managerid = bm.id,
            Email = 'testsr2@test.com',
            Username = 'testsr2@pernod-ricard.com.testsr2',
            ProfileId = '00eD0000001AneY',
            Alias = 'sr2',
            CommunityNickname = 'sr2',
            TimeZoneSidKey=TimeZoneSidKey,
            LocaleSidKey=LocaleSidKey,
            EmailEncodingKey=EmailEncodingKey,
            LanguageLocaleKey=LanguageLocaleKey,
            ASI_KOR_User_Region_Name__c = region,
            ASI_KOR_User_Branch_Code__c = '600'
        );
        insert sr2;
        
        RecordType  rType = [select id from RecordType  where DeveloperName = 'ASI_KOR_Venue' and SobjectType ='Account'];
        
        List<Sobject> oList = new List<SObject>();
        
        ASI_KOR_NSD_Proposal_Header__c nsdHeader = new ASI_KOR_NSD_Proposal_Header__c(
            ASI_KOR_Year__c = '1980',   
            ASI_KOR_Month__c = '1', 
            ASI_KOR_Status__c = 'Draft',
            ASI_KOR_No_of_Sumitted_Regions__c = 5,
            ownerid = nsd.id,
            ASI_KOR_SYS_Cut_off_Date__c = Date.valueOf('1980-01-01')
        );        
        insert nsdHeader;

        ASI_KOR_RSD_Proposal_Header__c rsdHeader = new ASI_KOR_RSD_Proposal_Header__c(
            ASI_KOR_Year__c = '1980',   
            ASI_KOR_Month__c = '1', 
            ASI_KOR_Status__c = 'Draft', 
            ASI_KOR_NSD_Proposal_Header__c = nsdHeader.id,
            ownerid = rsd.id                        
        );
        insert rsdHeader;

        ASI_KOR_BM_Proposal_Header__c bmHeader = new ASI_KOR_BM_Proposal_Header__c(
            ASI_KOR_Year__c = '1980',   
            ASI_KOR_Month__c = '1', 
            ASI_KOR_Status__c = 'Approved by BM', 
            ASI_KOR_RSD_Proposal_Header__c = rsdHeader.id,
            ownerid = bm.id 
        );
        List<SObject> oList1 = new List<SObject>();
        oList1.add(bmHeader);
        insert oList1;
        
        Account a1 =new Account( 
            ASI_KOR_Postal_Code__c='1234',
            recordtypeid = rType.id,
            ASI_KOR_Grade__c='A', 
            Name='TestVenue',
            ASI_KOR_Venue_Business_License_Number__c='111-11-11111' , 
            ASI_KOR_Customer_Code__c='88888888', 
            ASI_KOR_Contract_Type__c='non-Contracted',
            ASI_KOR_Venue_Status__c ='Active', 
            ASI_KOR_Venue_Pillar__c='W-TOT' 
        );
        a1.ownerid = sr.id;
        insert a1;
        
        ASI_KOR_SR_Proposal_Header__c srHeader = new ASI_KOR_SR_Proposal_Header__c(
            ASI_KOR_Year__c = '1980',   
            ASI_KOR_Month__c = '1', 
            ASI_KOR_Status__c = 'Approved by BM',
            ASI_KOR_BM_Proposal_Header__c = bmHeader.id,
            ownerid = sr.id
        );        
        insert srHeader;
        
        Account a2 =new Account( ASI_KOR_Postal_Code__c='1239',
                                recordtypeid = rType.id,
                                ASI_KOR_Grade__c='A', 
                                Name='TestVenue',
                                ASI_KOR_Venue_Business_License_Number__c='111-11-11119' , 
                                ASI_KOR_Customer_Code__c='88888889', 
                                ASI_KOR_Contract_Type__c='non-Contracted',
                                ASI_KOR_Venue_Status__c ='Active', 
                                ASI_KOR_Venue_Pillar__c='W-TOT' 
                               );
        a2.ownerid = sr2.id;
        insert a2;
        
        ASI_KOR_SR_Proposal_Header__c srHeader2 = new ASI_KOR_SR_Proposal_Header__c(
            ASI_KOR_Year__c = '1980',   
            ASI_KOR_Month__c = '1', 
            ASI_KOR_Status__c = 'Draft',
            ASI_KOR_BM_Proposal_Header__c = bmHeader.id,
            ownerid = sr2.id
        );        
        insert srHeader2;

        list<ASI_KOR_Incentive_Scheme__c> iclist = new list<ASI_KOR_Incentive_Scheme__c>();
        ASI_KOR_Incentive_Scheme__c ic1 = new ASI_KOR_Incentive_Scheme__c(
			ASI_KOR_BASIC_UNIT_COST__C=9000, 
            ASI_KOR_CA_UNIT_COST__C=1310, 
            ASI_KOR_UOM__C='Actual Case', 
            ASI_KOR_YEAR__C='1980', 
            ASI_KOR_EFFECTIVE_START_DATE__C=Date.valueOf('1979-11-01'), 
            ASI_KOR_EFFECTIVE_END_DATE__C=Date.valueOf('2017-12-31'), 
            ASI_KOR_CHANNEL__C='W-TOT', 
            ASI_KOR_GRADE__C='A', 
            ASI_KOR_BRANCH__C='Sales ChoongChung Branch', 
            ASI_KOR_CONTRACT__C='non-Contracted', 
            ASI_KOR_BRAND__C=brandMap.get('Absolut'), 
            ASI_KOR_SALES_BRACKET__C=10, 
            ASI_KOR_BRANCH_CODE__C='550'
        );
        iclist.add(ic1);
        //list_ic.add(ic2);
        //list_ic.add(ic3);
        //list_ic.add(ic4);
        insert iclist;
        
        system.runAS(sr){
        ASI_KOR_SR_Proposal_Detail__c proposalDetail = new ASI_KOR_SR_Proposal_Detail__c();        
        proposalDetail.ASI_KOR_Target_Volume__c = 100;        
        proposalDetail.ASI_KOR_Proposal_Unit_Cost_Basic_CA__c = 100000;        
        proposalDetail.ASI_KOR_Brand__c = brandMap.get('Absolut');        
        proposalDetail.ASI_KOR_SR_Proposal_ID__c = srHeader.Id;
        proposalDetail.ASI_KOR_Venue__c = a1.Id;
       
        insert proposalDetail;  
        }
        /*
        system.runAs(sr2){
        ASI_KOR_SR_Proposal_Detail__c proposalDetail2 = new ASI_KOR_SR_Proposal_Detail__c();        
        proposalDetail2.ASI_KOR_Target_Volume__c = 500;        
        proposalDetail2.ASI_KOR_Proposal_Unit_Cost_Basic_CA__c = 10000;        
        proposalDetail2.ASI_KOR_Brand__c = brandMap.get('Absolut');        
        proposalDetail2.ASI_KOR_SR_Proposal_ID__c = srHeader.Id;
        proposalDetail2.ASI_KOR_Venue__c = a1.Id;       
		insert proposalDetail2; 
        } 
		*/
	}            
}