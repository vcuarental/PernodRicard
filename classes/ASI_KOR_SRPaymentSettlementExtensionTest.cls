@isTest
public class ASI_KOR_SRPaymentSettlementExtensionTest {
    @isTest(seeAllData=false)
    public static void testSRProposalDetailController(){
        Map<String,Id> brandMap = ASI_KOR_TestHelper.insertBrands();
        
        /* Patched by Vincent Lam 20160118 BEGIN
        List<User> tempUserList = [select id,managerid from user where userroleid in (select Id from UserRole where name = 'Sales Representative - Choong Chung') and asi_kor_user_branch_code__c = '550'];
       
        User sr = tempUserList.get(0);      
        User bm = [select id,managerid from user where id =: sr.managerid];
        User rsd = [select id,managerid from user where id =: bm.managerid];
        User nsd = [select id from user where id =: rsd.managerid];
        */
		 Profile p = [SELECT Id FROM Profile WHERE Name='ASI KOR Standard Platform User'];    
		 
    
    User nsd = new User(
        FirstName = 'nsd',
        LastName = 'test',
        Email = 'testNSD@laputa-pernod-ricard.com.test',
        Username = 'testNSD@laputa-pernod-ricard.com.test',
        ProfileId = p.id,
        Alias = 'nsd',
        CommunityNickname = 'nsd',
        TimeZoneSidKey='America/Los_Angeles',
        LocaleSidKey='en_US',
        EmailEncodingKey='UTF-8',
        LanguageLocaleKey='en_US'
    );
    insert nsd;
    
    User rsdUser = new User(
        FirstName = 'rsd',
        LastName = 'test',
        managerid = nsd.id,
        Email = 'testRSD@laputa-pernod-ricard.com.test',
        Username = 'testRSD@laputa-pernod-ricard.com.test',
        ProfileId = p.id,
        Alias = 'rsd',
        CommunityNickname = 'rsd',
        TimeZoneSidKey='America/Los_Angeles',
        LocaleSidKey='en_US',
        EmailEncodingKey='UTF-8',
        LanguageLocaleKey='en_US'
    );
    insert rsdUser;
    
    User bm = new User(
        FirstName = 'bm',
        LastName = 'test',
        managerid = rsdUser.id,
        Email = 'testBM@laputa-pernod-ricard.com.test',
        Username = 'testBM@laputa-pernod-ricard.com.test',
        ProfileId = p.id,
        Alias = 'bm',
        CommunityNickname = 'bm',
        TimeZoneSidKey='America/Los_Angeles',
        LocaleSidKey='en_US',
        EmailEncodingKey='UTF-8',
        LanguageLocaleKey='en_US'
    );
    insert bm;
    
    User srUser = new User(
        FirstName = 'sr',
        LastName = 'test',
        managerid = bm.id,
        Email = 'testSR@laputa-pernod-ricard.com.test',
        Username = 'testSR@laputa-pernod-ricard.com.test',
        ProfileId = p.id,
        Alias = 'sr',
        CommunityNickname = 'sr',
        TimeZoneSidKey='America/Los_Angeles',
        LocaleSidKey='en_US',
        EmailEncodingKey='UTF-8',
        LanguageLocaleKey='en_US',
		ASI_KOR_User_Branch_Code__c='550'
    );
    insert srUser;
    /* Patched by Vincent Lam 20160118 END */

        RecordType  rType = [select id from RecordType  where DeveloperName = 'ASI_KOR_Venue' and SobjectType ='Account'];

        ASI_KOR_TestHelper.insertAccounts();
        //ASI_KOR_TestHelper.insertIncentiveSchemes();
        List<Sobject> oList = new List<SObject>();
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
        
        insert nsdByBrand;
       ASI_KOR_RSD_Proposal_Header__c rsdHeader = new ASI_KOR_RSD_Proposal_Header__c(
        ASI_KOR_Year__c = '2014',   
        ASI_KOR_Month__c = '1', 
        ASI_KOR_Status__c = 'Draft', 
        ASI_KOR_NSD_Proposal_Header__c = nsdHeader.id,
         ownerid = rsdUser.id
         
        
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
        ASI_KOR_Year__c = '2014',   
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
        Account a = new Account( ASI_KOR_Postal_Code__c='1234',recordtypeid = rType.id,ASI_KOR_Grade__c='A',ASI_KOR_Venue_Business_License_Number__c='111-11-11111',ASI_KOR_VenueChannel__c='', Name='TestVenue', ASI_KOR_Customer_Code__c='88888888', ASI_KOR_Contract_Type__c='non-Contracted',ASI_KOR_Venue_Status__c ='Active' );
        */
        Account a = new Account( 
			ASI_KOR_Postal_Code__c='1234',
			recordtypeid = rType.id,
			ASI_KOR_Grade__c='A',
			ASI_KOR_Venue_Business_License_Number__c='111-11-11111', 
			Name='TestVenue', 
			ASI_KOR_Customer_Code__c='88888888', 
			ASI_KOR_Venue_Status__c ='Active',
			ASI_KOR_Contract_Type__c='non-Contracted',
			ASI_KOR_Venue_Pillar__c='Local TOT'
		);
        /* Patched by Vincent Lam 20160119 END */
        a.ownerid = srUser.id;
        
        insert a;
        
       ASI_KOR_BM_Proposal_By_Brand__c bmByBrand = new ASI_KOR_BM_Proposal_By_Brand__c(
            ASI_KOR_Brand__c = brandMap.get('Absolut'),
            ASI_KOR_BM_Proposal_Header__c = bmHeader.id,
            ASI_KOR_UOM__c = 'Bottle',
            ASI_KOR_RSD_Proposal_By_Brand__c = rsdByBrand.id
        );
        
       insert bmByBrand;
       
       ASI_KOR_SR_Proposal_Header__c srHeader = new ASI_KOR_SR_Proposal_Header__c(
        ASI_KOR_Year__c = '2014',   
        ASI_KOR_Month__c = '1', 
        ASI_KOR_Status__c = 'Approved by BM',
        ASI_KOR_BM_Proposal_Header__c = bmHeader.id,
        ownerid = srUser.id
        );
        
        insert srHeader;
        
       ASI_KOR_SR_Proposal_By_Brand__c srByBrand = new ASI_KOR_SR_Proposal_By_Brand__c(
            ASI_KOR_Brand__c = brandMap.get('Absolut'),
            ASI_KOR_SR_Proposal_Header__c = srHeader.id,
            ASI_KOR_UOM__c = 'Bottle',
            ASI_KOR_BM_Proposal_By_Brand__c = bmByBrand.id
            
        );
        
        insert srByBrand;
        
       ASI_KOR_Incentive_Scheme__c ic1 = new ASI_KOR_Incentive_Scheme__c(ASI_KOR_BASIC_UNIT_COST__C=9000, ASI_KOR_CA_UNIT_COST__C=1310, ASI_KOR_UOM__C='Actual Case', ASI_KOR_YEAR__C='2013', ASI_KOR_EFFECTIVE_START_DATE__C=Date.valueOf('2013-11-01'), ASI_KOR_EFFECTIVE_END_DATE__C=Date.valueOf('2014-05-31'), ASI_KOR_CHANNEL__C='W-TOT', ASI_KOR_GRADE__C='A', ASI_KOR_BRANCH__C='Sales ChoongChung Branch', ASI_KOR_CONTRACT__C='non-Contracted', ASI_KOR_BRAND__C=brandMap.get('Absolut'), ASI_KOR_SALES_BRACKET__C=10, ASI_KOR_BRANCH_CODE__C='550');
       ASI_KOR_Incentive_Scheme__c ic2 = new ASI_KOR_Incentive_Scheme__c(
			ASI_KOR_BASIC_UNIT_COST__C=9000, 
			ASI_KOR_CA_UNIT_COST__C=7900, 
			ASI_KOR_UOM__C='Bottle', 
			ASI_KOR_YEAR__C='2013', 
			ASI_KOR_EFFECTIVE_START_DATE__C=Date.valueOf('2013-11-01'), 
			ASI_KOR_EFFECTIVE_END_DATE__C=Date.valueOf('2014-05-31'), 
			ASI_KOR_CHANNEL__C='Local TOT', 
			ASI_KOR_GRADE__C='A', 
			ASI_KOR_BRANCH__C='Sales ChoongChung Branch', 
			ASI_KOR_CONTRACT__C='non-Contracted', 
			ASI_KOR_BRAND__C=brandMap.get('Absolut'), 
			ASI_KOR_SALES_BRACKET__C=20, 
			ASI_KOR_BRANCH_CODE__C='550'
		);
       insert ic2;
       
       ASI_KOR_SR_Proposal_Detail__c proposalDetail = new ASI_KOR_SR_Proposal_Detail__c ();
       
        proposalDetail.ASI_KOR_Target_Volume__c = 100;
        proposalDetail.ASI_KOR_Cap_Unit_Cost_Basic__c = 10000;
        proposalDetail.ASI_KOR_Cap_Unit_Cost_CA__c = 1000;
        proposalDetail.ASI_KOR_Proposal_Unit_Cost_Basic_CA__c = 100000;
        proposalDetail.ASI_KOR_Unit_Cost_Cap_Actual_Volume__c = 9000;
        proposalDetail.ASI_KOR_Brand__c = brandMap.get('Absolut');
        proposalDetail.ASI_KOR_Incentive_Scheme__c = ic2.Id;
        proposalDetail.ASI_KOR_SR_Proposal_ID__c = srHeader.Id;
        proposalDetail.ASI_KOR_SR_Proposal_By_Brand__c = srByBrand.Id;
        proposalDetail.ASI_KOR_Venue__c = a.Id;
             
       insert proposalDetail;      
             
         ASI_KOR_NSD_Payment_Settlement_Header__c nsdPaymentSettlementHeader = new
         ASI_KOR_NSD_Payment_Settlement_Header__c();
         nsdPaymentSettlementHeader.ASI_KOR_Month__c = '1';
         nsdPaymentSettlementHeader.ASI_KOR_Year__c = '2014';
         nsdPaymentSettlementHeader.ASI_KOR_Status__c = 'Draft';
         /* Patched by Vincent Lam 20160119 BEGIN */
         nsdPaymentSettlementHeader.ASI_KOR_Sys_Cut_off_date__c = Date.newInstance(2014, 5, 31);
         /* Patched by Vincent Lam 20160119 END */
         insert nsdPaymentSettlementHeader;
         
         ASI_KOR_NSD_Payment_Settlement_By_Brand__c nsdPaymentSettlementByBrand1 
         = new ASI_KOR_NSD_Payment_Settlement_By_Brand__c();         
         nsdPaymentSettlementByBrand1.ASI_KOR_Brand__c = brandMap.get('Absolut');
         nsdPaymentSettlementByBrand1.ASI_KOR_NSD_Payment_Settlement_Header__c = nsdPaymentSettlementHeader.Id;
         nsdPaymentSettlementByBrand1.ASI_KOR_UOM__c = 'Bottle';
         insert nsdPaymentSettlementByBrand1;
         
         ASI_KOR_RSD_Payment_Settlement_Header__c rsdPaymentSettlementHeader = new
         ASI_KOR_RSD_Payment_Settlement_Header__c();
         rsdPaymentSettlementHeader.ASI_KOR_Month__c = '1';
         rsdPaymentSettlementHeader.ASI_KOR_Year__c = '2014';
         rsdPaymentSettlementHeader.ASI_KOR_Status__c = 'Draft';
         rsdPaymentSettlementHeader.ASI_KOR_NSD_Payment_Settlement__c = nsdPaymentSettlementHeader.Id;
         rsdPaymentSettlementHeader.ASI_KOR_SYS_Cut_off_Date__c =Date.newInstance(2014, 5, 31);
		 rsdPaymentSettlementHeader.ownerid = rsdUser.id;
         insert rsdPaymentSettlementHeader;
         
         ASI_KOR_RSD_Payment_Settlement_By_Brand__c rsdPaymentSettlementByBrand1 
         = new ASI_KOR_RSD_Payment_Settlement_By_Brand__c();         
         rsdPaymentSettlementByBrand1.ASI_KOR_Brand__c = brandMap.get('Absolut');
         rsdPaymentSettlementByBrand1.ASI_KOR_RSD_Payment_Settlement__c = rsdPaymentSettlementHeader.Id;
         rsdPaymentSettlementByBrand1.ASI_KOR_NSD_Payment_Settlement_By_Brand__c = nsdPaymentSettlementByBrand1.Id;
         rsdPaymentSettlementByBrand1.ASI_KOR_UOM__c = 'Bottle';
         insert rsdPaymentSettlementByBrand1;         
         
         ASI_KOR_BM_Payment_Settlement_Header__c bmPaymentSettlementHeader = new
         ASI_KOR_BM_Payment_Settlement_Header__c();
         bmPaymentSettlementHeader.ASI_KOR_Month__c = '1';
         bmPaymentSettlementHeader.ASI_KOR_Year__c = '2014';
         bmPaymentSettlementHeader.ASI_KOR_Status__c = 'Draft';
         bmPaymentSettlementHeader.ASI_KOR_RSD_Payment_Settlement__c = rsdPaymentSettlementHeader.id;
         bmPaymentSettlementHeader.ownerId = bm.Id;
         insert bmPaymentSettlementHeader;
         
         ASI_KOR_BM_Payment_Settlement_By_Brand__c bmPaymentSettlementByBrand1 
         = new ASI_KOR_BM_Payment_Settlement_By_Brand__c();         
         bmPaymentSettlementByBrand1.ASI_KOR_Brand__c = brandMap.get('Absolut');
         bmPaymentSettlementByBrand1.ASI_KOR_BM_Payment_Settlement__c = bmPaymentSettlementHeader.Id;
         bmPaymentSettlementByBrand1.ASI_KOR_RSD_Payment_Settlement_By_Brand__c = rsdPaymentSettlementByBrand1.Id;
         bmPaymentSettlementByBrand1 .ASI_KOR_UOM__c = 'Bottle';

         insert bmPaymentSettlementByBrand1;         
         
         ASI_KOR_BM_Payment_Settlement_By_Brand__c bmPaymentSettlementByBrand2 
         = new ASI_KOR_BM_Payment_Settlement_By_Brand__c();         
         bmPaymentSettlementByBrand2.ASI_KOR_Brand__c = brandMap.get('Absolut Elyx');
         bmPaymentSettlementByBrand2.ASI_KOR_BM_Payment_Settlement__c = bmPaymentSettlementHeader.Id;
         bmPaymentSettlementByBrand2.ASI_KOR_RSD_Payment_Settlement_By_Brand__c = rsdPaymentSettlementByBrand1.Id;
         bmPaymentSettlementByBrand2 .ASI_KOR_UOM__c = 'Bottle';

         insert bmPaymentSettlementByBrand2;         
         
         Account newAccount = new Account();
         newAccount.Name = 'TestName';
         newAccount.ASI_KOR_Customer_Code__c = '123456';
         insert newAccount;
         
         ASI_KOR_SR_Payment_Settlement_Header__c srPaymentSettlementHeader = new
         ASI_KOR_SR_Payment_Settlement_Header__c();
         srPaymentSettlementHeader.ASI_KOR_Month__c = '1';
         srPaymentSettlementHeader.ASI_KOR_Year__c = '2014';
         srPaymentSettlementHeader.ASI_KOR_Status__c = 'Draft';
         srPaymentSettlementHeader.ASI_KOR_BM_Payment_Settlement_Header__c = bmPaymentSettlementHeader.Id;
         srPaymentSettlementHeader.ownerId = srUser.id;
         insert srPaymentSettlementHeader;
         
         ASI_KOR_SR_Payment_Settlement_By_Brand__c srPaymentSettlementByBrand1 
         = new ASI_KOR_SR_Payment_Settlement_By_Brand__c();         
         srPaymentSettlementByBrand1.ASI_KOR_Brand__c = brandMap.get('Absolut');
         srPaymentSettlementByBrand1.ASI_KOR_SR_Payment_Settlement__c = srPaymentSettlementHeader.Id;
         srPaymentSettlementByBrand1.ASI_KOR_BM_Payment_Settlement_By_Brand__c = bmPaymentSettlementByBrand1.Id;
         srPaymentSettlementByBrand1.ASI_KOR_UOM__c = 'Bottle';
         insert srPaymentSettlementByBrand1;  
         
         /* Patched by Vincent Lam 20160119 BEGIN */
         test.startTest();
        /* Patched by Vincent Lam 20160119 END */
         
         ASI_KOR_SRPaymentSettlementExtension.createSRPaymentSettlementDetails(srPaymentSettlementHeader);
         
         /* Patched by Vincent Lam 20160119 BEGIN */
         test.stopTest();
          /* Patched by Vincent Lam 20160119 END */
        }
        
      
      
        
}