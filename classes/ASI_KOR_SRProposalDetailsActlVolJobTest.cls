@isTest
public class ASI_KOR_SRProposalDetailsActlVolJobTest
{
    
    @isTest(seeAllData=true)
    public static void testSRProposalDetailsActualVolJob()
    {    
    Map<String,Id> brandMap = ASI_KOR_TestHelper.insertBrands();
    
    /* Patched by Vincent Lam 20160118 BEGIN
    List<User> tempUserList = [select id,managerid from user where email !=null AND userroleid in (select Id from UserRole where name = 'Sales Representative - Choong Chung') and asi_kor_user_branch_code__c = '550'];
       
    User sr = tempUserList.get(0);      
    User bm = [select id,managerid from user where id =: sr.managerid];
    User rsd = [select id,managerid from user where id =: bm.managerid];
    User nsd = [select id from user where id =: rsd.managerid];
    */
    User DummyUser = [select id, TimeZoneSidKey, LocaleSidKey, 
                EmailEncodingKey, ProfileId, LanguageLocaleKey
                from User limit 1];
    
    User nsd = new User(
        FirstName = 'nsd',
        LastName = 'test',
        Email = 'testnsd@test.com',
        Username = 'testnsd@test.com',
        ProfileId = '00eD0000001AneY',
        Alias = 'nsd',
        CommunityNickname = 'nsd',
        TimeZoneSidKey=DummyUser.TimeZoneSidKey,
        LocaleSidKey=DummyUser.LocaleSidKey,
        EmailEncodingKey=DummyUser.EmailEncodingKey,
        LanguageLocaleKey=DummyUser.LanguageLocaleKey
    );
    insert nsd;
    
    User rsd = new User(
        FirstName = 'rsd',
        LastName = 'test',
        managerid = nsd.id,
        Email = 'testrsd@test.com',
        Username = 'testrsd@test.com',
        ProfileId = '00eD0000001AneY',
        Alias = 'rsd',
        CommunityNickname = 'rsd',
        TimeZoneSidKey=DummyUser.TimeZoneSidKey,
        LocaleSidKey=DummyUser.LocaleSidKey,
        EmailEncodingKey=DummyUser.EmailEncodingKey,
        LanguageLocaleKey=DummyUser.LanguageLocaleKey
    );
    insert rsd;
    
    User bm = new User(
        FirstName = 'bm',
        LastName = 'test',
        managerid = rsd.id,
        Email = 'testbm@test.com',
        Username = 'testbm@test.com',
        ProfileId = '00eD0000001AneY',
        Alias = 'bm',
        CommunityNickname = 'bm',
        TimeZoneSidKey=DummyUser.TimeZoneSidKey,
        LocaleSidKey=DummyUser.LocaleSidKey,
        EmailEncodingKey=DummyUser.EmailEncodingKey,
        LanguageLocaleKey=DummyUser.LanguageLocaleKey
    );
    insert bm;
    
    User sr = new User(
        FirstName = 'sr',
        LastName = 'test',
        managerid = bm.id,
        Email = 'testsr@test.com',
        Username = 'testsr@test.com',
        ProfileId = '00eD0000001AneY',
        Alias = 'sr',
        CommunityNickname = 'sr',
        TimeZoneSidKey=DummyUser.TimeZoneSidKey,
        LocaleSidKey=DummyUser.LocaleSidKey,
        EmailEncodingKey=DummyUser.EmailEncodingKey,
        LanguageLocaleKey=DummyUser.LanguageLocaleKey
    );
    insert sr;
    
    /* Patched by Vincent Lam 20160119 BEGIN */
    User sr2 = new User(
        FirstName = 'sr2',
        LastName = 'test',
        managerid = bm.id,
        Email = 'testsr2@test.com',
        Username = 'testsr2@test.com',
        ProfileId = '00eD0000001AneY',
        Alias = 'sr2',
        CommunityNickname = 'sr2',
        TimeZoneSidKey=DummyUser.TimeZoneSidKey,
        LocaleSidKey=DummyUser.LocaleSidKey,
        EmailEncodingKey=DummyUser.EmailEncodingKey,
        LanguageLocaleKey=DummyUser.LanguageLocaleKey
    );
    insert sr2;
    /* Patched by Vincent Lam 20160119 END */

    /* Patched by Vincent Lam 20160118 END */
    
    RecordType  rType = [select id from RecordType  where DeveloperName = 'ASI_KOR_Venue' and SobjectType ='Account'];
    
    ASI_KOR_TestHelper.insertAccounts();
    //ASI_KOR_TestHelper.insertIncentiveSchemes();
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
    
    ASI_KOR_NSD_Proposal_By_Brand__c nsdByBrand = new ASI_KOR_NSD_Proposal_By_Brand__c(
        ASI_KOR_Brand__c = brandMap.get('Absolut'),
        ASI_KOR_NSD_Proposal_Header__c = nsdHeader.id,
        ASI_KOR_UOM__c = 'Bottle'
    );
    
    insert nsdByBrand;
    ASI_KOR_RSD_Proposal_Header__c rsdHeader = new ASI_KOR_RSD_Proposal_Header__c(
    ASI_KOR_Year__c = '1980',   
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
    
    /* Patched by Vincent Lam 20160119 BEGIN
     * Remove ASI_KOR_VenueChannel__c=''
    Account a =new Account( ASI_KOR_Postal_Code__c='1234',recordtypeid = rType.id,ASI_KOR_Grade__c='A',ASI_KOR_VenueChannel__c='', Name='TestVenue',ASI_KOR_Venue_Business_License_Number__c='111-11-11111' , ASI_KOR_Customer_Code__c='88888888', ASI_KOR_Contract_Type__c='non-Contracted',ASI_KOR_Venue_Status__c ='Active' );
    */
    Account a =new Account( ASI_KOR_Postal_Code__c='1234',recordtypeid = rType.id,ASI_KOR_Grade__c='A', Name='TestVenue',ASI_KOR_Venue_Business_License_Number__c='111-11-11111' , ASI_KOR_Customer_Code__c='88888888', ASI_KOR_Contract_Type__c='non-Contracted',ASI_KOR_Venue_Status__c ='Active' );
    /* Patched by Vincent Lam 20160119 END */
    a.ownerid = sr.id;
    insert a;
    
    ASI_KOR_BM_Proposal_By_Brand__c bmByBrand = new ASI_KOR_BM_Proposal_By_Brand__c(
        ASI_KOR_Brand__c = brandMap.get('Absolut'),
        ASI_KOR_BM_Proposal_Header__c = bmHeader.id,
        ASI_KOR_UOM__c = 'Bottle',
        ASI_KOR_RSD_Proposal_By_Brand__c = rsdByBrand.id
    );
    
    insert bmByBrand;
    
    ASI_KOR_SR_Proposal_Header__c srHeader = new ASI_KOR_SR_Proposal_Header__c(
    ASI_KOR_Year__c = '1980',   
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
    
    /* Patched by Vincent Lam 20160119 BEGIN */
    Account a2 =new Account( ASI_KOR_Postal_Code__c='1239',recordtypeid = rType.id,ASI_KOR_Grade__c='A', Name='TestVenue',ASI_KOR_Venue_Business_License_Number__c='111-11-11119' , ASI_KOR_Customer_Code__c='88888889', ASI_KOR_Contract_Type__c='non-Contracted',ASI_KOR_Venue_Status__c ='Active' );
    a.ownerid = sr2.id;
    insert a2;
        
    ASI_KOR_SR_Proposal_Header__c srHeader2 = new ASI_KOR_SR_Proposal_Header__c(
    ASI_KOR_Year__c = '1980',   
    ASI_KOR_Month__c = '1', 
    ASI_KOR_Status__c = 'Approved by BM',
    ASI_KOR_BM_Proposal_Header__c = bmHeader.id,
    ownerid = sr2.id
    );
    
    insert srHeader2;
    
    ASI_KOR_SR_Proposal_By_Brand__c srByBrand2 = new ASI_KOR_SR_Proposal_By_Brand__c(
        ASI_KOR_Brand__c = brandMap.get('Absolut'),
        ASI_KOR_SR_Proposal_Header__c = srHeader2.id,
        ASI_KOR_UOM__c = 'Bottle',
        ASI_KOR_BM_Proposal_By_Brand__c = bmByBrand.id
        
    );
    
    insert srByBrand2;
    /* Patched by Vincent Lam 20160119 END */
    
    ASI_KOR_Incentive_Scheme__c ic1 = new ASI_KOR_Incentive_Scheme__c(ASI_KOR_BASIC_UNIT_COST__C=9000, ASI_KOR_CA_UNIT_COST__C=1310, ASI_KOR_UOM__C='Actual Case', ASI_KOR_YEAR__C='1980', ASI_KOR_EFFECTIVE_START_DATE__C=Date.valueOf('1979-11-01'), ASI_KOR_EFFECTIVE_END_DATE__C=Date.valueOf('2014-05-31'), ASI_KOR_CHANNEL__C='W-TOT', ASI_KOR_GRADE__C='A', ASI_KOR_BRANCH__C='Sales ChoongChung Branch', ASI_KOR_CONTRACT__C='non-Contracted', ASI_KOR_BRAND__C=brandMap.get('Absolut'), ASI_KOR_SALES_BRACKET__C=10, ASI_KOR_BRANCH_CODE__C='550');
    ASI_KOR_Incentive_Scheme__c ic2 = new ASI_KOR_Incentive_Scheme__c(ASI_KOR_BASIC_UNIT_COST__C=9000, ASI_KOR_CA_UNIT_COST__C=7900, ASI_KOR_UOM__C='Bottle', ASI_KOR_YEAR__C='1980', ASI_KOR_EFFECTIVE_START_DATE__C=Date.valueOf('1979-11-01'), ASI_KOR_EFFECTIVE_END_DATE__C=Date.valueOf('2014-05-31'), ASI_KOR_CHANNEL__C='W-TOT', ASI_KOR_GRADE__C='A', ASI_KOR_BRANCH__C='Sales ChoongChung Branch', ASI_KOR_CONTRACT__C='non-Contracted', ASI_KOR_BRAND__C=brandMap.get('Absolut'), ASI_KOR_SALES_BRACKET__C=20, ASI_KOR_BRANCH_CODE__C='550');
    insert ic1;
    insert ic2;
    
    ASI_KOR_SR_Proposal_Detail__c proposalDetail = new ASI_KOR_SR_Proposal_Detail__c ();
    
    proposalDetail.ASI_KOR_Target_Volume__c = 100;
    proposalDetail.ASI_KOR_Cap_Unit_Cost_Basic__c = 10000;
    proposalDetail.ASI_KOR_Cap_Unit_Cost_CA__c = 1000;
    proposalDetail.ASI_KOR_Proposal_Unit_Cost_Basic_CA__c = 100000;
    proposalDetail.ASI_KOR_Unit_Cost_Cap_Actual_Volume__c = 9000;
    proposalDetail.ASI_KOR_Brand__c = brandMap.get('Absolut');
    proposalDetail.ASI_KOR_Incentive_Scheme__c = ic1.Id;
    proposalDetail.ASI_KOR_SR_Proposal_ID__c = srHeader.Id;
    proposalDetail.ASI_KOR_SR_Proposal_By_Brand__c = srByBrand.Id;
    proposalDetail.ASI_KOR_Venue__c = a.Id;
         
    insert proposalDetail;      
    
    /* Patched by Vincent Lam 20160119 BEGIN */
    ASI_KOR_SR_Proposal_Detail__c proposalDetail2 = new ASI_KOR_SR_Proposal_Detail__c ();
    
    proposalDetail2.ASI_KOR_Target_Volume__c = 100;
    proposalDetail2.ASI_KOR_Cap_Unit_Cost_Basic__c = 10000;
    proposalDetail2.ASI_KOR_Cap_Unit_Cost_CA__c = 1000;
    proposalDetail2.ASI_KOR_Proposal_Unit_Cost_Basic_CA__c = 100000;
    proposalDetail2.ASI_KOR_Unit_Cost_Cap_Actual_Volume__c = 9000;
    proposalDetail2.ASI_KOR_Brand__c = brandMap.get('Absolut');
    proposalDetail2.ASI_KOR_Incentive_Scheme__c = ic1.Id;
    proposalDetail2.ASI_KOR_SR_Proposal_ID__c = srHeader2.Id;
    proposalDetail2.ASI_KOR_SR_Proposal_By_Brand__c = srByBrand2.Id;
    proposalDetail2.ASI_KOR_Venue__c = a2.Id;
         
    insert proposalDetail2;   
    /* Patched by Vincent Lam 20160119 END */   
    

    Test.StartTest();
    String srcString='01/01/80 06:00 AM';

    String mm=srcString.subString(0,2);
    String dd=srcString.subString(3,5);
    String yy=srcString.subString(6,8);
    
    Date myDate=Date.newInstance(integer.valueOf(yy), 
     integer.valueOf(mm), 
     integer.valueOf(dd));
    ASI_KOR_SRProposalDetailsActualVolJob srProposalDetailsActualVolJob = new  ASI_KOR_SRProposalDetailsActualVolJob('1980','1',mydate);
    Database.executeBatch(srProposalDetailsActualVolJob);
    Test.StopTest();
    
    
    }


}