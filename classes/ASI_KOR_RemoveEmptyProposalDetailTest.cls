@isTest
public class ASI_KOR_RemoveEmptyProposalDetailTest {
    
    static testMethod void removeEmptyProposalDetail(){
        Map<String,Id> brandMap = ASI_KOR_TestHelper.insertBrands();
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
            LanguageLocaleKey='en_US');
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
            LanguageLocaleKey='en_US');
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
            LanguageLocaleKey='en_US');
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
            LanguageLocaleKey='en_US');
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
            ASI_KOR_SYS_Cut_off_Date__c = Date.valueOf('2013-01-14'));
        
        insert nsdHeader;
        
        ASI_KOR_NSD_Proposal_By_Brand__c nsdByBrand = new ASI_KOR_NSD_Proposal_By_Brand__c(
            ASI_KOR_Brand__c = brandMap.get('Absolut'),
            ASI_KOR_NSD_Proposal_Header__c = nsdHeader.id,
            ASI_KOR_UOM__c = 'Bottle');
        
        insert nsdByBrand;
        ASI_KOR_RSD_Proposal_Header__c rsdHeader = new ASI_KOR_RSD_Proposal_Header__c(
            ASI_KOR_Year__c = '2014',   
            ASI_KOR_Month__c = '1', 
            ASI_KOR_Status__c = 'Draft', 
            ASI_KOR_NSD_Proposal_Header__c = nsdHeader.id,
            ownerid = rsdUser.id);
        insert rsdHeader;
        
        ASI_KOR_RSD_Proposal_By_Brand__c rsdByBrand = new ASI_KOR_RSD_Proposal_By_Brand__c(
            ASI_KOR_Brand__c = brandMap.get('Absolut'),
            ASI_KOR_RSD_Proposal_Header__c= rsdHeader.id,
            ASI_KOR_UOM__c = 'Bottle',
            ASI_KOR_NSD_Proposal_By_Brand__c = nsdByBrand.id);        
        insert rsdByBrand;
        
        ASI_KOR_BM_Proposal_Header__c bmHeader = new ASI_KOR_BM_Proposal_Header__c(
            ASI_KOR_Year__c = '2014',   
            ASI_KOR_Month__c = '1', 
            ASI_KOR_Status__c = 'Approved by BM', 
            ASI_KOR_RSD_Proposal_Header__c = rsdHeader.id,
            ownerid = bm.id);

        List<SObject> oList1 = new List<SObject>();
        oList1.add(bmHeader);
        insert oList1;
        
        Account a = new Account( ASI_KOR_Postal_Code__c='1234',
                                recordtypeid = rType.id,
                                ASI_KOR_Grade__c='A',
                                ASI_KOR_Venue_Business_License_Number__c='111-11-11111', 
                                Name='TestVenue', 
                                ASI_KOR_Customer_Code__c='88888888', 
                                ASI_KOR_Contract_Type__c='non-Contracted',
                                ASI_KOR_Venue_Status__c ='Active');
        a.ownerid = srUser.id;        
        insert a;
        
        ASI_KOR_BM_Proposal_By_Brand__c bmByBrand = new ASI_KOR_BM_Proposal_By_Brand__c(
            ASI_KOR_Brand__c = brandMap.get('Absolut'),
            ASI_KOR_BM_Proposal_Header__c = bmHeader.id,
            ASI_KOR_UOM__c = 'Bottle',
            ASI_KOR_RSD_Proposal_By_Brand__c = rsdByBrand.id);        
        insert bmByBrand;
        
        ASI_KOR_SR_Proposal_Header__c srHeader = new ASI_KOR_SR_Proposal_Header__c(
            ASI_KOR_Year__c = '2014',   
            ASI_KOR_Month__c = '1', 
            ASI_KOR_Status__c = 'Approved by BM',
            ASI_KOR_BM_Proposal_Header__c = bmHeader.id,
            ownerid = srUser.id);        
        insert srHeader;
        
        ASI_KOR_SR_Proposal_By_Brand__c srByBrand = new ASI_KOR_SR_Proposal_By_Brand__c(
            ASI_KOR_Brand__c = brandMap.get('Absolut'),
            ASI_KOR_SR_Proposal_Header__c = srHeader.id,
            ASI_KOR_UOM__c = 'Bottle',
            ASI_KOR_BM_Proposal_By_Brand__c = bmByBrand.id);        
        insert srByBrand;
        
        ASI_KOR_Incentive_Scheme__c ic2 = new ASI_KOR_Incentive_Scheme__c(ASI_KOR_BASIC_UNIT_COST__C=9000, ASI_KOR_CA_UNIT_COST__C=7900, ASI_KOR_UOM__C='Bottle', ASI_KOR_YEAR__C='2013', ASI_KOR_EFFECTIVE_START_DATE__C=Date.valueOf('2013-11-01'), ASI_KOR_EFFECTIVE_END_DATE__C=Date.valueOf('2014-05-31'), ASI_KOR_CHANNEL__C='W-TOT', ASI_KOR_GRADE__C='A', ASI_KOR_BRANCH__C='Sales ChoongChung Branch', ASI_KOR_CONTRACT__C='non-Contracted', ASI_KOR_BRAND__C=brandMap.get('Absolut'), ASI_KOR_SALES_BRACKET__C=20, ASI_KOR_BRANCH_CODE__C='550');
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
        
        ASI_KOR_SR_Proposal_Detail__c propDetail2 = new ASI_KOR_SR_Proposal_Detail__c ();        
        propDetail2.ASI_KOR_Target_Volume__c = 0;
        propDetail2.ASI_KOR_Cap_Unit_Cost_Basic__c = 0;
        propDetail2.ASI_KOR_Cap_Unit_Cost_CA__c = 0;
        propDetail2.ASI_KOR_Proposal_Unit_Cost_Basic_CA__c = 0;
        propDetail2.ASI_KOR_Unit_Cost_Cap_Actual_Volume__c = 0;
        propDetail2.ASI_KOR_Brand__c = brandMap.get('Absolut');
        propDetail2.ASI_KOR_Incentive_Scheme__c = ic2.Id;
        propDetail2.ASI_KOR_SR_Proposal_ID__c = srHeader.Id;
        propDetail2.ASI_KOR_SR_Proposal_By_Brand__c = srByBrand.Id;
        propDetail2.ASI_KOR_Venue__c = a.Id;
        
        insert propDetail2;  
        
    }
}