/*
+-----------------------+------------------------------------------------------------------------------------+
| Author                | Cécile Lartaud                                                                     |
+-----------------------+------------------------------------------------------------------------------------+
| Description           |                                                                                    |
|                       |                                                                                    |
|     - Object(s)       | External User Request	                                                             |
|     - Description     | Test class of EXT_USR_RQT_ManageExtUsersCON  										 |
+-----------------------+------------------------------------------------------------------------------------+
| Creation Date         | 08/01/2013                                                                         |
+-----------------------+------------------------------------------------------------------------------------+
| Modifications         | 18/11/2013 Sophie DUCATEL (Changed the Chatter Group names)						                                                         |
+-----------------------+------------------------------------------------------------------------------------+
*/
@isTest(seeAllData=true)
public class EXT_USR_RQT_ManageExtUsersCON_TEST {
	
	static testMethod void test_OK() {
		
		List<CollaborationGroupMember> collabs = new List<CollaborationGroupMember>();
		List<CollaborationGroup> chatterGroups = new List<CollaborationGroup>();
		List<User> extUsers = new List<User>(); 
		
		User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
		
		System.runAs ( thisUser ) {
			
			/* create 3 group */
			CollaborationGroup chatterGroup1 = new CollaborationGroup(Name='EXT_USR_RQT_ManageExtUsersCON_Group1',CollaborationType='private',CanHaveGuests=true);
			chatterGroups.add(chatterGroup1);
			CollaborationGroup chatterGroup2 = new CollaborationGroup(Name='EXT_USR_RQT_ManageExtUsersCON_Group2',CollaborationType='private',CanHaveGuests=true);
			chatterGroups.add(chatterGroup2);
			CollaborationGroup chatterGroup3 = new CollaborationGroup(Name='EXT_USR_RQT_ManageExtUsersCON_Group3',CollaborationType='private',CanHaveGuests=true);
			chatterGroups.add(chatterGroup3);
			insert chatterGroups;
			
			/* create some external users */
			String ExtProfileID = EXT_USR_Config__c.getOrgDefaults().EXT_USR_RQT_External_Profile_Id__c;
			
			for (Integer a = 0; a < 150; a++) {
				String alias = 'eu'+a;
				User us = new User(alias = alias, email=alias + '@dev.com', CompanyName = 'test',
									emailencodingkey='UTF-8', firstname=alias, lastname='Testing', languagelocalekey='en_US', 
									localesidkey='en_US', timezonesidkey='Europe/London', username=alias + '@esn.pernod-ricard.com',ProfileId = ExtProfileID);
	
				if(a <= 50){
					us.EXT_USR_RQT_Expiration_Date__c = DateTime.now() + 15; // not expire
				}else if(a > 50 && a <= 100){
					us.EXT_USR_RQT_Expiration_Date__c = DateTime.now() + 7; // about to expire
				}else{
					us.EXT_USR_RQT_Expiration_Date__c = DateTime.now() - 1; // not expire
				}	
				extUsers.add(us);
			}
	
			insert extUsers;
		
			Set<Id> Ids = new Set<Id>(); //set for holding the Ids of all the created Account records
		
			/* Create collaborationGroupMember */
			for (Integer a = 0; a < extUsers.size(); a++) {
				CollaborationGroupMember collab;
				if(a <= 50){
					collab = new CollaborationGroupMember(MemberId = extUsers[a].Id, CollaborationGroupId = chatterGroup1.Id);
				}else if(a > 50 && a <= 100){
					collab = new CollaborationGroupMember(MemberId = extUsers[a].Id, CollaborationGroupId = chatterGroup2.Id);
				}else{
					collab = new CollaborationGroupMember(MemberId = extUsers[a].Id, CollaborationGroupId = chatterGroup3.Id);
				}
				collabs.add(collab);
				
				Ids.add(extUsers[a].Id); //add the Id to our set        
			}
	
			insert collabs;
			
			/* Create a new instance of the VF page and the Apex controller */
	        Pagereference vf = Page.EXT_USR_RQT_ManageExtUsers;
	        Test.setCurrentPageReference(vf);       
	        EXT_USR_RQT_ManageExtUsersCON con = new EXT_USR_RQT_ManageExtUsersCON();
	        
	        /* Test 1 : remove a user from a group */
	        con.extUsrSelectedID = extUsers[55].Id;
	        con.groupSelectedID = chatterGroup2.Id;
	        con.removeUser();
	        
	        Integer searchCGM = [SELECT count() FROM CollaborationGroupMember WHERE MemberId = :extUsers[55].Id AND CollaborationGroupId = :chatterGroup2.Id];
	        System.assertEquals(searchCGM, 0);   
         
	        /* Test 2 : renew a user */
	        DateTime oldExpirDate = extUsers[25].EXT_USR_RQT_Expiration_Date__c;
	        con.extUsrSelectedID = extUsers[25].Id;
	        con.groupSelectedID = chatterGroup1.Id;
	        con.renewUser();
	        
	        List<User> searchUser = [SELECT EXT_USR_RQT_Expiration_Date__c FROM User WHERE Id = :extUsers[25].Id];
	        System.assertNotEquals(oldExpirDate, searchUser[0].EXT_USR_RQT_Expiration_Date__c);
		}
	}
}