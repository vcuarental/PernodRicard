/*
* Created Date: March 05, 2020
* Created By : Corentin FRANCOIS - CGI
* Description: CC-4954 : Test class for 2 triggers : GRP_CC_AddNewProductToCollect and GRP_CC_AddNewCollectBQSToCollects
*/
@isTest(SeeAllData = false) 
public class GRP_CC_AddCBQandCtBQS_Triggers_Test {

    @testSetup static void setUpData() {
        DateTime dt = DateTime.now(); 
		String dateTimeStr = dt.format('YYMMDD_hhmmss'); 
		Profile adminp = [select id from profile where Name = 'System Administrator' limit 1];    
        System.debug('dateTimeStr : '+ dateTimeStr);
        
        // Creation of one user 
        Profile p = [SELECT Id FROM Profile WHERE Name='GRP_Connected_Customer']; 
        User u1 = new User(Alias = 'user1', Email='GRP_CC_testuser1'+dateTimeStr+'@grpcctestorg.com', 
            EmailEncodingKey='UTF-8', LastName='TestingUser1', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='GRP_CC_testuser1'+dateTimeStr+'@grpcctestorg.com');
        insert u1;
        
        User ic_myUser = [SELECT Id FROM User WHERE Email LIKE 'GRP_CC_testuser1%grpcctestorg.com' LIMIT 1];
		
        System.runAs(ic_myUser) {   
			// Creation of a Group, Chain and Chain Account + Contract + Collect
			
			GRP_CC_Group__c grp = new GRP_CC_Group__c();
            grp.GRP_CC_GroupeResponsible__c = 'GRP_CC_testuser2'+dateTimeStr+'@grpcctestorg.com';
            grp.GRP_CC_Domain__c = 'fake_domain';
            insert grp;
			GRP_CC_Chain__c chain = new GRP_CC_Chain__c();
            chain.Name = 'Chain1';
            chain.GRP_CC_Group__c = grp.Id;
            insert chain;
            CORE_Region__c region = new CORE_Region__c();
            insert region;
            CORE_Country__c country = new CORE_Country__c();
            country.CORE_Region__c = region.Id;
            insert country;
            
			GRP_CC_ChainAccount__c chainAcc = new GRP_CC_ChainAccount__c();
			chainAcc.Name = 'ChainAcc1';
			chainAcc.GRP_CC_Chain__c = chain.Id;
			chainAcc.GRP_CC_Country__c = country.Id; 
			chainAcc.GRP_CC_Region__c = region.Id; 
			chainAcc.GRP_CC_ChainAccountResponsible__c = u1.Id;
            insert chainAcc;

            // Creation of a Collect
			GRP_CC_ChainAccount__c chainAcct = [SELECT Id FROM GRP_CC_ChainAccount__c WHERE Name LIKE 'ChainAcc1' LIMIT 1];
            GRP_CC_Contract__c contract = new GRP_CC_Contract__c();
            contract.GRP_CC_Category__c = 'Champagnes';
            contract.GRP_CC_Cycle__c = 3;
            contract.GRP_CC_Start_Date__c = Date.today();
            contract.GRP_CC_EndCollectOneDate__c = Date.today();
            contract.Days_to_1st_Reminder_Chain_Acct_Resp__c = 1;
            contract.Days_to_2nd_Reminder_Chain_Acct_Resp__c = 20;
            insert contract;
			GRP_CC_Collect__c c = new GRP_CC_Collect__c();
			c.GRP_CC_ChainAccount__c = chainAcc.Id;
			c.GRP_CC_State__c = 'New';
			c.GRP_CC_Status__c = 'New';
            c.GRP_CC_Contract__c = contract.Id; 
            c.GRP_CC_PeriodEnd__c = Date.today(); 
            c.GRP_CC_PeriodStart__c = Date.today();
            insert c;


            //Creation of Brand
            CORE_Brand__c B = new CORE_Brand__c ();
            B.Name = 'CGI Test';
            insert B;
            
            //Creation of Brand Quality
            CORE_BrandQuality__c BQ = new CORE_BrandQuality__c ();
            BQ.Name = 'Vodka CGI Test';
            BQ.CORE_Category__c = 'Champagnes';
            BQ.CORE_Brand__c = B.Id;
            insert BQ;

            //Creation of  Size
            CORE_Size__c S = new CORE_Size__c ();
            S.Name = '1L';
            S.CORE_Value__c = 1;
            insert S;

            //Creation of Brand Quality Size
            CORE_BrandQualitySize__c BQS = new CORE_BrandQualitySize__c ();
            BQS.Name = 'Vodka CGI Test 1L';
            BQS.CORE_BrandQuality__c = BQ.Id;
            BQS.CORE_Size__c = S.Id;
            insert BQS;

        }
    }   

    @isTest static void Test_InsertCBQandCBQS(){
        User ic_myUser = [SELECT Id FROM User WHERE Email LIKE 'GRP_CC_testuser1%grpcctestorg.com' LIMIT 1];
		
        System.runAs(ic_myUser) {         
			
            Test.startTest(); 
            CORE_BrandQuality__c BQ = [SELECT Id FROM CORE_BrandQuality__c WHERE Name LIKE 'Vodka CGI Test' LIMIT 1];
            CORE_BrandQualitySize__c BQS = [SELECT Id FROM CORE_BrandQualitySize__c WHERE Name LIKE 'Vodka CGI Test 1L' LIMIT 1];
            GRP_CC_Contract__c contract = [SELECT Id FROM GRP_CC_Contract__c WHERE CreatedById =: ic_myUser.Id LIMIT 1];
                        
            GRP_CC_ContractBQ__c CBQ = new GRP_CC_ContractBQ__c();
            CBQ.GRP_CC_BrandQuality__c =  BQ.Id;
            CBQ.GRP_CC_Contract__c = contract.Id;
            CBQ.GRP_CC_OnMenu__c = true;
            CBQ.GRP_CC_Pouring__c = true;
            CBQ.GRP_CC_Rooms_Minibar__c = true;
            insert CBQ;
            
            GRP_CC_ContractBQ__c contractBQ = [SELECT Id, GRP_CC_Optional_Additions__c FROM GRP_CC_ContractBQ__c WHERE CreatedById =: ic_myUser.Id LIMIT 1];
            contractBQ.GRP_CC_Optional_Additions__c = true;
            update contractBQ;

            GRP_CC_Contract_BQS_Link__c CBQS = new GRP_CC_Contract_BQS_Link__c();
            CBQS.GRP_CC_BrandQualitySize__c =  BQS.Id;
            CBQS.GRP_CC_Contract__c = contract.Id;
            insert CBQS;

            Test.stopTest();
		} 
    }
}