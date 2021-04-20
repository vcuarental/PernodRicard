@isTest
public class ASI_KOR_SRProposalDetailsActualVolV2Test
{
    
    @isTest
    public static void ASI_KOR_SRProposalDetailsActualVolV2Test()
    {    
        Map<String,Id> brandMap = ASI_KOR_TestHelper.insertBrands();
        
        /* Patched by Vincent Lam 20160118 BEGIN
List<User> tempUserList = [select id,managerid from user where email !=null AND userroleid in (select Id from UserRole where name = 'Sales Representative - Choong Chung') and asi_kor_user_branch_code__c = '550'];

User sr = tempUserList.get(0);      
User bm = [select id,managerid from user where id =: sr.managerid];
User rsd = [select id,managerid from user where id =: bm.managerid];
User nsd = [select id from user where id =: rsd.managerid];
*/
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
            ASI_KOR_User_Region_Name__c = region
        );
        insert sr;
        
        /* Patched by Vincent Lam 20160119 BEGIN */
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
            ASI_KOR_User_Branch_Code__c = '550'
        );
        insert sr2;
        /* Patched by Vincent Lam 20160119 END */
        
        /* Patched by Vincent Lam 20160118 END */
        
        RecordType  rType = [select id from RecordType  where DeveloperName = 'ASI_KOR_Venue' and SobjectType ='Account'];
        
        //ASI_KOR_TestHelper.insertAccounts();
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
        Account a1 =new Account( ASI_KOR_Postal_Code__c='1234',recordtypeid = rType.id,ASI_KOR_Grade__c='A', Name='TestVenue',ASI_KOR_Venue_Business_License_Number__c='111-11-11111' , ASI_KOR_Customer_Code__c='88888888', ASI_KOR_Contract_Type__c='non-Contracted',ASI_KOR_Venue_Status__c ='Active', ASI_KOR_Venue_Pillar__c='W-TOT' );
        /* Patched by Vincent Lam 20160119 END */
        a1.ownerid = sr.id;
        insert a1;
        
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
        Account a2 =new Account( ASI_KOR_Postal_Code__c='1239',recordtypeid = rType.id,ASI_KOR_Grade__c='A', Name='TestVenue',ASI_KOR_Venue_Business_License_Number__c='111-11-11119' , ASI_KOR_Customer_Code__c='88888889', ASI_KOR_Contract_Type__c='non-Contracted',ASI_KOR_Venue_Status__c ='Active', ASI_KOR_Venue_Pillar__c='W-TOT' );
        a2.ownerid = sr2.id;
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
        
        list<ASI_KOR_Incentive_Scheme__c> list_ic = new list<ASI_KOR_Incentive_Scheme__c>();
        ASI_KOR_Incentive_Scheme__c ic1 = new ASI_KOR_Incentive_Scheme__c(ASI_KOR_BASIC_UNIT_COST__C=9000, ASI_KOR_CA_UNIT_COST__C=1310, ASI_KOR_UOM__C='Actual Case', ASI_KOR_YEAR__C='1980', ASI_KOR_EFFECTIVE_START_DATE__C=Date.valueOf('1979-11-01'), ASI_KOR_EFFECTIVE_END_DATE__C=Date.valueOf('2014-05-31'), ASI_KOR_CHANNEL__C='W-TOT', ASI_KOR_GRADE__C='A', ASI_KOR_BRANCH__C='Sales ChoongChung Branch', ASI_KOR_CONTRACT__C='non-Contracted', ASI_KOR_BRAND__C=brandMap.get('Absolut'), ASI_KOR_SALES_BRACKET__C=10, ASI_KOR_BRANCH_CODE__C='550');
        ASI_KOR_Incentive_Scheme__c ic2 = new ASI_KOR_Incentive_Scheme__c(ASI_KOR_BASIC_UNIT_COST__C=9000, ASI_KOR_CA_UNIT_COST__C=7900, ASI_KOR_UOM__C='Bottle', ASI_KOR_YEAR__C='1980', ASI_KOR_EFFECTIVE_START_DATE__C=Date.valueOf('1979-11-01'), ASI_KOR_EFFECTIVE_END_DATE__C=Date.valueOf('2014-05-31'), ASI_KOR_CHANNEL__C='W-TOT', ASI_KOR_GRADE__C='A', ASI_KOR_BRANCH__C='Sales ChoongChung Branch', ASI_KOR_CONTRACT__C='non-Contracted', ASI_KOR_BRAND__C=brandMap.get('Absolut'), ASI_KOR_SALES_BRACKET__C=20, ASI_KOR_BRANCH_CODE__C='550');
        ASI_KOR_Incentive_Scheme__c ic3 = new ASI_KOR_Incentive_Scheme__c(ASI_KOR_BASIC_UNIT_COST__C=9000, ASI_KOR_CA_UNIT_COST__C=1310, ASI_KOR_UOM__C='Actual Case', ASI_KOR_YEAR__C='1980', ASI_KOR_EFFECTIVE_START_DATE__C=Date.valueOf('1979-11-01'), ASI_KOR_EFFECTIVE_END_DATE__C=Date.valueOf('2014-05-31'), ASI_KOR_CHANNEL__C='W-TOT', ASI_KOR_GRADE__C='A', ASI_KOR_BRANCH__C='Sales ChoongChung Branch', ASI_KOR_CONTRACT__C='non-Contracted', ASI_KOR_BRAND__C=brandMap.get('Absolut Elyx'), ASI_KOR_SALES_BRACKET__C=10, ASI_KOR_BRANCH_CODE__C='550');
        ASI_KOR_Incentive_Scheme__c ic4 = new ASI_KOR_Incentive_Scheme__c(ASI_KOR_BASIC_UNIT_COST__C=9000, ASI_KOR_CA_UNIT_COST__C=7900, ASI_KOR_UOM__C='Bottle', ASI_KOR_YEAR__C='1980', ASI_KOR_EFFECTIVE_START_DATE__C=Date.valueOf('1979-11-01'), ASI_KOR_EFFECTIVE_END_DATE__C=Date.valueOf('2014-05-31'), ASI_KOR_CHANNEL__C='W-TOT', ASI_KOR_GRADE__C='A', ASI_KOR_BRANCH__C='Sales ChoongChung Branch', ASI_KOR_CONTRACT__C='non-Contracted', ASI_KOR_BRAND__C=brandMap.get('Absolut Elyx'), ASI_KOR_SALES_BRACKET__C=20, ASI_KOR_BRANCH_CODE__C='550');
        list_ic.add(ic1);
        list_ic.add(ic2);
        list_ic.add(ic3);
        list_ic.add(ic4);
        insert list_ic;
        
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
        proposalDetail.ASI_KOR_Venue__c = a1.Id;
        
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
        
        // create venue depletion
        list<ASI_KOR_Venue_Depletion__c> list_vd = new list<ASI_KOR_Venue_Depletion__c>();
        ASI_KOR_Venue_Depletion__c vd1 = new ASI_KOR_Venue_Depletion__c(
        	ASI_KOR_Venue__c = a1.id,
            ASI_KOR_Year__c = '1980',
            ASI_KOR_Month__c = 'January'
        );
        list_vd.add(vd1);
        ASI_KOR_Venue_Depletion__c vd2 = new ASI_KOR_Venue_Depletion__c(
        	ASI_KOR_Venue__c = a2.id,
            ASI_KOR_Year__c = '1980',
            ASI_KOR_Month__c = 'January'
        );
        ASI_KOR_Venue_Depletion__c vd3 = new ASI_KOR_Venue_Depletion__c(
        	ASI_KOR_Venue__c = a1.id,
            ASI_KOR_Year__c = '1979',
            ASI_KOR_Month__c = 'December'
        );
        list_vd.add(vd3);
        ASI_KOR_Venue_Depletion__c vd4 = new ASI_KOR_Venue_Depletion__c(
        	ASI_KOR_Venue__c = a2.id,
            ASI_KOR_Year__c = '1979',
            ASI_KOR_Month__c = 'December'
        );
        list_vd.add(vd4);
        
        insert list_vd;
        
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
        
        Test.StartTest();
        String srcString='01/01/80 06:00 AM';
        
        String mm=srcString.subString(0,2);
        String dd=srcString.subString(3,5);
        String yy=srcString.subString(6,8);
        
        Date myDate=Date.newInstance(2300,1, 1);
        ASI_KOR_SRProposalDetailsActualVol_V2 srProposalDetailsActualVolJob = new  ASI_KOR_SRProposalDetailsActualVol_V2('1980','1',mydate,region);
        Database.executeBatch(srProposalDetailsActualVolJob);
        Test.StopTest();
        
        
    }
    
    
}