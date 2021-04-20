@isTest
public class ASI_CRM_VN_CusPopulateApproversTest {
    @testSetup
    public static void setupTestData(){
        //Insert common data here
        UserRole NSDRole = new UserRole(Name = Label.ASI_CRM_VN_RoleName);
        insert NSDRole;
        UserRole RSDRole = new UserRole(Name = 'ASI VN RSD Role', ParentRoleId = NSDRole.Id, DeveloperName = 'ASI_VN_RSD_Role');
        insert RSDRole;
        UserRole LMRole = new UserRole(Name = 'ASI VN LM Role', ParentRoleId = RSDRole.Id, DeveloperName = 'ASI_VN_LM_Role');
        insert LMRole;
        UserRole CDPRole = new UserRole(Name = 'ASI VN CDP Role', ParentRoleId = LMRole.Id, DeveloperName = 'ASI_VN_CDP_Role');
        insert CDPRole;
    }
    public static TestMethod void testInsert() {
		Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1]; 
        Id userRoleId = [SELECT Id FROM UserRole WHERE Name = :System.Label.ASI_CRM_VN_RoleName LIMIT 1].Id;
        Id userRoleId1 = [SELECT Id FROM UserRole WHERE Name like 'ATR - Finance Director' LIMIT 1].Id;
        Id userRoleId2 = [SELECT Id FROM UserRole WHERE DeveloperName = 'ASI_VN_CDP_Role' LIMIT 1].Id;
        Id userRoleId3 = [SELECT Id FROM UserRole WHERE DeveloperName = 'ASI_VN_LM_Role' LIMIT 1].Id;
        Id userRoleId4 = [SELECT Id FROM UserRole WHERE DeveloperName = 'ASI_VN_RSD_Role' LIMIT 1].Id;
        Id userRoleId5 = [SELECT Id FROM UserRole WHERE Name = :Label.ASI_CRM_VN_RoleName LIMIT 1].Id;

		User objExecutive = new User(Alias = 'standt', Email='standarduser@testorg.com', 
		EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
		LocaleSidKey='en_US', ProfileId = p.Id, UserRoleId = userRoleId5,
		TimeZoneSidKey='America/Los_Angeles', UserName='test.executive.user@testorg.com');
		insert objExecutive;
		System.debug('--- Director Id ----' + objExecutive.Id);
        
		User objDirector = new User(Alias = 'standt', Email='standarduser@testorg.com', 
		EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
		LocaleSidKey='en_US', ProfileId = p.Id, UserRoleId = userRoleId4, ManagerId = objExecutive.Id,
		TimeZoneSidKey='America/Los_Angeles', UserName='test.director.user@testorg.com');
		insert objDirector;
		System.debug('--- Director Id ----' + objDirector.Id);
        
		User objManager = new User(Alias = 'standt', Email='standarduser@testorg.com', 
		EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
		LocaleSidKey='en_US', ProfileId = p.Id, UserRoleId = userRoleId3, ManagerId = objDirector.Id,
		TimeZoneSidKey='America/Los_Angeles', UserName='test.manager.user@testorg.com');
		insert objManager;
		System.debug('--- Manager Id ----' + objManager.Id);

		User objUser = new User(Alias = 'standt', Email='standarduser@testorg.com', 
		EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
		LocaleSidKey='en_US', ProfileId = p.Id, ManagerId = objManager.Id, UserRoleId = userRoleId2,
		TimeZoneSidKey='America/Los_Angeles', UserName='test.standard.user@testorg.com');
		System.debug('--- Manager Id ----' + objUser.ManagerId);
		insert objUser;

		User objManager1 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
		EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
		LocaleSidKey='en_US', ProfileId = p.Id, UserRoleId = userRoleId3, ManagerId = objManager.Id,
		TimeZoneSidKey='America/Los_Angeles', UserName='test.manager.user1@testorg.com');
		insert objManager1;

		User objUser1 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
		EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
		LocaleSidKey='en_US', ProfileId = p.Id, ManagerId = objManager1.Id, UserRoleId = userRoleId2,
		TimeZoneSidKey='America/Los_Angeles', UserName='test.standard.user1@testorg.com');
        insert objUser1;

        //Create Test Account record
        Account testAccount = new Account();
        testAccount.Name = 'testAccount';
        
        String RecordTypeIdCustomer = Schema.SObjectType.ASI_CRM_AccountsAdditionalField__c.getRecordTypeInfosByName().get('Outlet (VN)').getRecordTypeId();
        String OffTradeRecordTypeIdCustomer = Schema.SObjectType.ASI_CRM_AccountsAdditionalField__c.getRecordTypeInfosByName().get('VN Off-Trade Outlet').getRecordTypeId();
                                     
		ASI_HK_CRM_Running_Number__c runningInstance = ASI_CRM_VN_TestDataFactory.getRunningNumber('ASI_CRM_VN_Customer_Code',1,'VN{000000}',1,date.today().year());
          
		ASI_CRM_AccountsAdditionalField__c customerInstance = ASI_CRM_VN_TestDataFactory.getCustomer('customerTest','Presence','HEB',OffTradeRecordTypeIdCustomer);  
		ASI_CRM_AccountsAdditionalField__c customerInstance1 = ASI_CRM_VN_TestDataFactory.getCustomer('customerTest','Presence','HEB',RecordTypeIdCustomer);  
		/*customerInstance.OwnerId = objUser.Id;
		customerInstance1.OwnerId = objUser1.Id;*/
		List<ASI_CRM_AccountsAdditionalField__c> customerList = new List<ASI_CRM_AccountsAdditionalField__c>{customerInstance,customerInstance1};
		ASI_CRM_AccountsAdditionalField__c customerInstance2 = ASI_CRM_VN_TestDataFactory.getCustomer('customerTest','Presence','HEB',RecordTypeIdCustomer);          
   
        Test.startTest();
            System.runAs(objUser) {
                insert runningInstance;
                // insert testAccount;
                insert customerList;
            }
            System.runAs(objUser1) {
                insert customerInstance2;
				 
				List<ASI_CRM_AccountsAdditionalField__c> updatedCustomerList = [SELECT Id, ASI_CRM_CN_Sys_Approver_1__c, ASI_CRM_CN_Sys_Approver_2__c FROM ASI_CRM_AccountsAdditionalField__c WHERE ASI_CRM_CN_Sys_Approver_1__c = :objManager.Id];
																		 
				//Wilken 20161212, include test scenario when owner is changed after update
				for (ASI_CRM_AccountsAdditionalField__c cus:updatedCustomerList){
					cus.OwnerId = objUser1.Id;
				}
				update updatedCustomerList;		
			}
		
		Test.stopTest();
																 
    }    
}