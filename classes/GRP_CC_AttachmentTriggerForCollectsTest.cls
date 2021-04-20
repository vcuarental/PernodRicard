/*
* Created Date: November 14,2016
*
* Description: Test class for GRP_CC_AttachmentTriggerForCollects trigger
*
*/
@isTest(SeeAllData = false) 
public class GRP_CC_AttachmentTriggerForCollectsTest {

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
			// Creation of a Group, Chain and Chain Account
			
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
		}
    }
	
	@isTest static void Test_DeleteAttachmentTriggerForCollects() {
        
        User ic_myUser = [SELECT Id FROM User WHERE Email LIKE 'GRP_CC_testuser1%grpcctestorg.com' LIMIT 1];
		
        System.runAs(ic_myUser) {         
			
            Test.startTest();                 
            
			// Creation of a Collect
			GRP_CC_ChainAccount__c chainAcc = [SELECT Id FROM GRP_CC_ChainAccount__c WHERE Name LIKE 'ChainAcc1' LIMIT 1];
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
			
			// Creation of an attachment for the collect
			Attachment attach = new Attachment();

			attach.Name = 'Unit Test Attachment';
			Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
			attach.body = bodyBlob;
			attach.parentId = c.id;
			insert attach;
            update c;

			List<Attachment> attachments = [select id, name from Attachment where parent.id=:c.id];
			System.assertEquals(1, attachments.size());

			// Deletion of attachment
			attach = [SELECT Id, name from Attachment where parent.id=:c.id];
			delete attach;  
            update c;
    
			attachments = [select id, name from Attachment where parent.id=:c.id];
			System.assertEquals(0, attachments.size());
			System.assertEquals(False, c.GRP_CC_File_attached__c);
			
            Test.stopTest();
		}   	
    }
}