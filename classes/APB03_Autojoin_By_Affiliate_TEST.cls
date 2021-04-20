@isTest(seeAllData=true)
public class APB03_Autojoin_By_Affiliate_TEST {

    static testMethod void myUnitTest() {     
	    User contextUser = TestFactory.createUserWithProfile('context','System Administrator');  
	    contextUser.BypassTriggers__c = 'Autofollow_User_InsertUpdate;ESN_User_AutojoinByAffiliates';
	    
	    System.runAs( contextUser ) { 
	        // Create new Chatter groups //
	        CollaborationGroup group1 = TestFactory.createCollaborationGroup('ESN_VFC19_group1', 'private');
	        insert group1;
	          
			//create a variable for use in our query later (it's declared here because we need it populated prior to creation of test accounts)
			DateTime createdDateValue = DateTime.now(); //DateTime variable
			String createdDate_Formatted_Date = createdDateValue.format('yyyy-MM-dd'); //date portion of the createdDateValue variable formatted as Strting
			String createdDate_Formatted_Time = createdDateValue.format('HH:mm:ss'); //time portion of the createdDateValue variable formatted as Strting
			String createdDate_Formatted_Zone = createdDateValue.format('Z'); //timezone offset of the createdDateValue variable formatted as Strting
			String finalDateTimeValue = createdDate_Formatted_Date+'T'+createdDate_Formatted_Time+createdDate_Formatted_Zone.substring(0, createdDate_Formatted_Zone.length()-2)+':00';
               
            // Create a list of users to insert
            List<User> newUsers = new List<User>();
            
            Boolean comp1or2 = false;
            for(Integer i=0;i<20;i++){
                User user = TestFactory.createUserWithProfile('user'+i, 'Chatter Only User');
                user.IsActive = true;
                if(i == 2 || i == 5 || i == 7 || i == 12)
                    user.IsActive = false;
                newUsers.add(user);
            }
            insert newUsers;
            
            CollaborationGroupMember newCGM = new CollaborationGroupMember(MemberId = newUsers[1].Id, CollaborationGroupId = group1.Id);
            insert newCGM;
	            
	        /* Start test */ 
			Test.startTest(); //switch to test context
			
			APB03_Autojoin_By_Affiliate batch = new APB03_Autojoin_By_Affiliate();
            batch.soql = 'SELECT Id FROM User WHERE isActive = true AND ProfileId != \''+EXT_USR_Config__c.getOrgDefaults().EXT_USR_RQT_External_Profile_Id__c+'\'';
            batch.ChatterGroupId = group1.Id;
			batch.soql += ' AND CreatedDate >= '+finalDateTimeValue; //append the string to our soql variable
			
			ID batch_processId = Database.executeBatch(batch); //execute the batch
			Test.stopTest(); //switch back to runtime context
		}
    }
}