@isTest(seeAllData=true)
public class APS01_ExtUsers_Desactivate_TEST {

	static testMethod void test_OK() {
		//BEGIN: perform some setup steps...
		User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
		System.runAs ( thisUser ) {
			//create a variable for use in our query later (it's declared here because we need it populated prior to creation of test accounts)
			DateTime createdDateValue = DateTime.now(); //DateTime variable
			String createdDate_Formatted_Date = createdDateValue.format('yyyy-MM-dd'); //date portion of the createdDateValue variable formatted as Strting
			String createdDate_Formatted_Time = createdDateValue.format('HH:mm:ss'); //time portion of the createdDateValue variable formatted as Strting
			String createdDate_Formatted_Zone = createdDateValue.format('Z'); //timezone offset of the createdDateValue variable formatted as Strting
			String finalDateTimeValue = createdDate_Formatted_Date+'T'+createdDate_Formatted_Time+createdDate_Formatted_Zone.substring(0, createdDate_Formatted_Zone.length()-2)+':00';

			//create some external users
			User[] extUsers = new User[0]; //new User sObject
			String ExtProfileID = EXT_USR_Config__c.getOrgDefaults().EXT_USR_RQT_External_Profile_Id__c;
			
			for (Integer a = 0; a < 150; a++) {
				String alias = 'eu'+a;
				User us = new User(alias = alias, email=alias + '@dev.com', CompanyName = 'test',
									emailencodingkey='UTF-8', firstname=alias, lastname='Testing', languagelocalekey='en_US', 
									localesidkey='en_US', timezonesidkey='Europe/London', username=alias + '@esn.pernod-ricard.com',ProfileId = ExtProfileID);

				if(a <= 50)
					us.EXT_USR_RQT_Expiration_Date__c = DateTime.now() + 15; // not expire
				else if(a > 50 && a <= 100)
					us.EXT_USR_RQT_Expiration_Date__c = DateTime.now() + 3; // about to expire
				else
					us.EXT_USR_RQT_Expiration_Date__c = DateTime.now() - 1; // not expire
					
				extUsers.add(us);
			}


			insert extUsers; //insert the account records

			// create a group
			CollaborationGroup chatterGroup = new CollaborationGroup(Name='APS01_ExtUsers_Desactivate_TEST',CollaborationType='private',CanHaveGuests=true);
			insert chatterGroup;
			List<CollaborationGroupMember> collabs = new List<CollaborationGroupMember>();

			Set<Id> Ids = new Set<Id>(); //set for holding the Ids of all the created Account records
			for (User ext : extUsers) { //for all inserted Accounts
				CollaborationGroupMember collab = new CollaborationGroupMember(MemberId = ext.Id, CollaborationGroupId = chatterGroup.Id);
				collabs.add(collab);
				Ids.add(ext.Id); //add the Id to our set        
			}
			insert collabs;	
			//END: perform some setup steps...

			test.starttest();
			APS01_ExtUsers_Desactivate sco = new APS01_ExtUsers_Desactivate();			
			String sch = '0 0 23 * * ?';			
			system.schedule('Ext User desactives', sch, sco);			
			test.stopTest();
		}
	}

	static testMethod void test_logic_exception() {
		//BEGIN: perform some setup steps...
		User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
		
		System.runAs ( thisUser ) {
			//create a variable for use in our query later (it's declared here because we need it populated prior to creation of test accounts)
			DateTime createdDateValue = DateTime.now(); //DateTime variable
			String createdDate_Formatted_Date = createdDateValue.format('yyyy-MM-dd'); //date portion of the createdDateValue variable formatted as Strting
			String createdDate_Formatted_Time = createdDateValue.format('HH:mm:ss'); //time portion of the createdDateValue variable formatted as Strting
			String createdDate_Formatted_Zone = createdDateValue.format('Z'); //timezone offset of the createdDateValue variable formatted as Strting
			String finalDateTimeValue = createdDate_Formatted_Date+'T'+createdDate_Formatted_Time+createdDate_Formatted_Zone.substring(0, createdDate_Formatted_Zone.length()-2)+':00';

			String ExtProfileID = EXT_USR_Config__c.getOrgDefaults().EXT_USR_RQT_External_Profile_Id__c;
			// exception : no company
			String alias = 'exc';
			User us = new User(alias = alias, email=alias + '@dev.com', emailencodingkey='UTF-8', firstname=alias, lastname='Testing', languagelocalekey='en_US', 
			localesidkey='en_US', timezonesidkey='Europe/London', username=alias + '@esn.pernod-ricard.com',ProfileId = ExtProfileID, EXT_USR_RQT_Expiration_Date__c = DateTime.now() + 3);
			insert us;

			test.starttest();
			APS01_ExtUsers_Desactivate sco = new APS01_ExtUsers_Desactivate();			
			String sch = '0 0 23 * * ?';			
			system.schedule('Ext User desactives', sch, sco);			
			test.stopTest();
		}
	}
	static testMethod void test_logic() {
	}
}