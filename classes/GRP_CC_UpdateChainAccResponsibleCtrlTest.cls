@isTest(SeeAllData = false) 
public class GRP_CC_UpdateChainAccResponsibleCtrlTest {

    @testSetup static void setUpData() {
        DateTime dt = DateTime.now(); 
		String dateTimeStr = dt.format('YYMMDD_hhmmss'); 
		Profile adminp = [select id from profile where Name = 'System Administrator' limit 1];    
        System.debug('dateTimeStr : '+ dateTimeStr);
        
        // Creation of 2 users 
        Profile p = [SELECT Id FROM Profile WHERE Name='GRP_Connected_Customer']; 
        User u1 = new User(Alias = 'user1', Email='GRP_CC_testuser1'+dateTimeStr+'@grpcctestorg.com', 
            EmailEncodingKey='UTF-8', LastName='TestingUser1', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='GRP_CC_testuser1'+dateTimeStr+'@grpcctestorg.com');
        insert u1;
        
		User u2 = new User(Alias = 'user2', Email='GRP_CC_testuser2'+dateTimeStr+'@grpcctestorg.com', 
            EmailEncodingKey='UTF-8', LastName='TestingUser1', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='GRP_CC_testuser2'+dateTimeStr+'@grpcctestorg.com');
        insert u2;
		
        User ic_myUser = [SELECT Id FROM User WHERE Email LIKE 'GRP_CC_testuser1%grpcctestorg.com' LIMIT 1];
        PermissionSet adminps = [select id from PermissionSet where Name = 'GRP_CC_Admin' limit 1];  
        PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = adminps.Id, AssigneeId = ic_myUser.Id);
        insert psa;
        
        System.runAs(ic_myUser) {   
			// Creation of a Group, Chain and Chain Account
			
			GRP_CC_Group__c grp = new GRP_CC_Group__c();
            grp.GRP_CC_GroupeResponsible__c = 'GRP_CC_testuser2'+dateTimeStr+'@grpcctestorg.com';
			grp.GRP_CC_Domain__c = 'Domain';
            insert grp;
			GRP_CC_Chain__c chain = new GRP_CC_Chain__c();
            chain.Name = 'Chain1';
			GRP_CC_Group__c groupe = [SELECT Id FROM GRP_CC_Group__c WHERE GRP_CC_GroupeResponsible__c LIKE '%GRP_CC_testuser2%']; 
            chain.GRP_CC_Group__c = groupe.Id;
            insert chain;
            CORE_Region__c region = new CORE_Region__c();
			region.Name = 'Region1';
            insert region;
            CORE_Country__c country = new CORE_Country__c();
			country.Name = 'Country1';
			CORE_Region__c reg = [SELECT Id FROM CORE_Region__c WHERE Name LIKE '%Region1%']; 
            country.CORE_Region__c = reg.Id;
            insert country;
            
			CORE_Country__c ctry = [SELECT Id FROM CORE_Country__c WHERE Name LIKE '%Country1%'];
			GRP_CC_ChainAccount__c chainAcc1 = new GRP_CC_ChainAccount__c();
			chainAcc1.Name = 'ChainAcc1';
			chainAcc1.GRP_CC_Chain__c = chain.Id;
			chainAcc1.GRP_CC_Country__c = ctry.Id; 
			chainAcc1.GRP_CC_Region__c = reg.Id; 
			chainAcc1.GRP_CC_ChainAccountResponsible__c = u1.Id;
			chainAcc1.GRP_CC_PRResponsible__c = u2.Id;
			chainAcc1.GRP_CC_PR_Responsible_Manager__c = u1.Id;
			chainAcc1.GRP_CC_ChainAccountResponsible__c = 'PR-responsible@gmail.com';
			insert chainAcc1;
			
			GRP_CC_ChainAccount__c chainAcc2 = new GRP_CC_ChainAccount__c();
			chainAcc2.Name = 'chainAcc2';
			chainAcc2.GRP_CC_Chain__c = chain.Id;
			chainAcc2.GRP_CC_Country__c = country.Id; 
			chainAcc2.GRP_CC_Region__c = region.Id; 
			chainAcc2.GRP_CC_ChainAccountResponsible__c = u1.Id;
			chainAcc2.GRP_CC_PRResponsible__c = u2.Id;
			chainAcc2.GRP_CC_PR_Responsible_Manager__c = u1.Id;
			chainAcc2.GRP_CC_ChainAccountResponsible__c = 'PR-responsible@gmail.com';
			insert chainAcc2;
		}
    }
    
	@isTest static void Test_updateChainAccountsWithSave() {
        
        User ic_myUser = [SELECT Id FROM User WHERE Email LIKE 'GRP_CC_testuser1%grpcctestorg.com' LIMIT 1];
		System.debug('==> ic_myUser : '+ ic_myUser);
		
		
        System.runAs(ic_myUser) {         
			
			System.debug('==> Test_updateChainAccountsWithSave()');		
			Test.startTest(); 
            List <GRP_CC_ChainAccount__c> lstAccount = new List<GRP_CC_ChainAccount__c>{}; 
			
			GRP_CC_ChainAccount__c chainAcc1 = [SELECT Id, Name, GRP_CC_Country__c,GRP_CC_Region__c,GRP_CC_PR_Responsible_Manager__c, GRP_CC_ChainAccountResponsible__c FROM GRP_CC_ChainAccount__c WHERE Name LIKE 'chainAcc1' LIMIT 1];
			System.debug('==> chainAcc1 : '+ chainAcc1);
			
  			lstAccount.add(chainAcc1);	
            System.debug('==> lstAccount : '+ lstAccount);
			upsert lstAccount; 
  
			ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(lstAccount);
			stdSetController.setSelected(lstAccount);
			GRP_CC_UpdateChainAccountResponsibleCtrl ctrl = new GRP_CC_UpdateChainAccountResponsibleCtrl(stdSetController);
			
			ctrl.getChainAccount();
			ctrl.GRP_CC_ChainAccount_PR_Resp = 'GRP_CC_testuser1';
			ctrl.updateChainAccounts();
			ctrl.saveChainAccounts();
			
            Test.stopTest();
		}   	
    }
	
	@isTest static void Test_updateChainAccountsMassEditWithSave() {
        
        User ic_myUser = [SELECT Id FROM User WHERE Email LIKE 'GRP_CC_testuser1%grpcctestorg.com' LIMIT 1];
		System.debug('==> ic_myUser : '+ ic_myUser);
		
		
        System.runAs(ic_myUser) {         
			
			System.debug('==> Test_updateChainAccountsWithSave()');		
			Test.startTest(); 
            List <GRP_CC_ChainAccount__c> lstAccount = new List<GRP_CC_ChainAccount__c>{}; 
			
			GRP_CC_ChainAccount__c chainAcc1 = [SELECT Id, Name, GRP_CC_Country__c,GRP_CC_Region__c,GRP_CC_PR_Responsible_Manager__c, GRP_CC_ChainAccountResponsible__c FROM GRP_CC_ChainAccount__c WHERE Name LIKE 'chainAcc1' LIMIT 1];
			GRP_CC_ChainAccount__c chainAcc2 = [SELECT Id, Name, GRP_CC_Country__c,GRP_CC_Region__c,GRP_CC_PR_Responsible_Manager__c, GRP_CC_ChainAccountResponsible__c FROM GRP_CC_ChainAccount__c WHERE Name LIKE 'chainAcc2' LIMIT 1];
            System.debug('==> chainAcc1 : '+ chainAcc1);
            System.debug('==> chainAcc2 : '+ chainAcc2);
			
			
  			lstAccount.add(chainAcc1);
			lstAccount.add(chainAcc2); 		
            System.debug('==> lstAccount : '+ lstAccount);
			upsert lstAccount; 
  
			ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(lstAccount);
			stdSetController.setSelected(lstAccount);
			GRP_CC_UpdateChainAccountResponsibleCtrl ctrl = new GRP_CC_UpdateChainAccountResponsibleCtrl(stdSetController);
			
			ctrl.updateChainAccounts();
			ctrl.saveChainAccounts();
			
            Test.stopTest();
		}   	
    }
	
	
	@isTest static void Test_updateChainAccountsWithCancel() {
        
        User ic_myUser = [SELECT Id FROM User WHERE Email LIKE 'GRP_CC_testuser1%grpcctestorg.com' LIMIT 1];
		System.debug('==> ic_myUser : '+ ic_myUser);
		
		
        System.runAs(ic_myUser) {         
			
			System.debug('==> Test_updateChainAccountsWithCancel()');		
			Test.startTest(); 
            List <GRP_CC_ChainAccount__c> lstAccount = new List<GRP_CC_ChainAccount__c>{}; 
			
			GRP_CC_ChainAccount__c chainAcc1 = [SELECT Id, Name, GRP_CC_Country__c,GRP_CC_Region__c,GRP_CC_PR_Responsible_Manager__c, GRP_CC_ChainAccountResponsible__c FROM GRP_CC_ChainAccount__c WHERE Name LIKE 'chainAcc1' LIMIT 1];
			GRP_CC_ChainAccount__c chainAcc2 = [SELECT Id, Name, GRP_CC_Country__c,GRP_CC_Region__c,GRP_CC_PR_Responsible_Manager__c, GRP_CC_ChainAccountResponsible__c FROM GRP_CC_ChainAccount__c WHERE Name LIKE 'chainAcc2' LIMIT 1];
            System.debug('==> chainAcc1 : '+ chainAcc1);
            System.debug('==> chainAcc2 : '+ chainAcc2);
			
			
  			lstAccount.add(chainAcc1);
			lstAccount.add(chainAcc2); 		
            System.debug('==> lstAccount : '+ lstAccount);
			upsert lstAccount; 
  
			ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(lstAccount);
			stdSetController.setSelected(lstAccount);
			GRP_CC_UpdateChainAccountResponsibleCtrl ctrl = new GRP_CC_UpdateChainAccountResponsibleCtrl(stdSetController);
			
			ctrl.updateChainAccounts();
			ctrl.cancelUpdateChainAccounts();
			
            Test.stopTest();
		}   	
    }
	
	@isTest static void Test_updateChainAccountsWithSave_CaseNoSelection() {
        
        User ic_myUser = [SELECT Id FROM User WHERE Email LIKE 'GRP_CC_testuser1%grpcctestorg.com' LIMIT 1];
		System.debug('==> ic_myUser : '+ ic_myUser);
		
		
        System.runAs(ic_myUser) {         
			
			System.debug('==> Test_updateChainAccountsWithSave()');		
			Test.startTest(); 
            List <GRP_CC_ChainAccount__c> lstAccount = new List<GRP_CC_ChainAccount__c>{}; 
			
			GRP_CC_ChainAccount__c chainAcc1 = [SELECT Id, Name, GRP_CC_Country__c,GRP_CC_Region__c,GRP_CC_PR_Responsible_Manager__c, GRP_CC_ChainAccountResponsible__c FROM GRP_CC_ChainAccount__c WHERE Name LIKE 'chainAcc1' LIMIT 1];
			System.debug('==> chainAcc1 : '+ chainAcc1);
			
  			lstAccount.add(chainAcc1);	
            System.debug('==> lstAccount : '+ lstAccount);
			upsert lstAccount; 
  
			ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(lstAccount);
			GRP_CC_UpdateChainAccountResponsibleCtrl ctrl = new GRP_CC_UpdateChainAccountResponsibleCtrl(stdSetController);
			
			ctrl.updateChainAccounts();
			ctrl.saveChainAccounts();
			
            Test.stopTest();
		}   	
    }
}