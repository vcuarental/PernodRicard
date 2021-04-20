@isTest(SeeAllData=true)
private class EXT_USR_RQT_CreateNewRequestCON_TEST {

    static testMethod void myUnitTest() {   
    	 	
    	/* Create a new group */
    	CollaborationGroup myGroup = TestFactory.createCollaborationGroup('groupTest', 'Private');
    	myGroup.CanHaveGuests = true;
    	insert myGroup;  
    	
    	/* Create a user  */
    	User userSTD = TestFactory.createUserWithProfile('user', 'System Administrator');
    	insert userSTD;
    	
    	/* Search an email of existing user, to the test "user already exist" */
    	List<User> listUsers = [SELECT Email FROM User LIMIT 1];
    	
    /*	Id permId = [SELECT Id FROM PermissionSet WHERE Label = 'External User Request Permission Set'].get(0).Id;
    	PermissionSetAssignment perm = new PermissionSetAssignment(AssigneeId = userSTD.Id, PermissionSetId = permId);
    	insert perm;	*/
    	  	
    	    	    	
    	/* Create new instance of Visualforce Page */
    	Pagereference vf = Page.EXT_USR_RQT_CreateNewRequest;
    	vf.getParameters().put('groupID', myGroup.Id);
    	vf.getParameters().put('groupName', myGroup.Name);
    	Test.setCurrentPageReference(vf);
        EXT_USR_RQT_CreateNewRequestCON con = new EXT_USR_RQT_CreateNewRequestCON(new ApexPages.StandardController(new External_User_Request__c()));
        
    	System.runas(userSTD){
    		/* Check if the user is admin or not */
    		con.checkUserIsAdmin();
    		System.assertEquals(con.isAdmin,true);
    		
    		/* Add informations to the current request and check if auto-populated field are filled. */
	    	con.newRequest.EXT_USR_RQT_First_Name__c = 'testRQT';
	    	con.newRequest.EXT_USR_RQT_Last_Name__c = 'testing';
	    	con.newRequest.EXT_USR_RQT_Company__c = 'test';
	    	
	    	system.assertEquals(con.newRequest.EXT_USR_RQT_Group_Name__c, myGroup.Name);
	    	
	    	/* Test 1: User not already exist [Save] */
	    	con.newRequest.EXT_USR_RQT_Email__c = 'testRQT.testing@test.com';  
	    	Pagereference result1 = con.saveRequest();
	    	System.assertnotEquals(result1, null);
	    	
	    	/* Test 2: User already exist [Save] */
	    	con.newRequest.EXT_USR_RQT_Email__c = listUsers[0].Email;  
	    	Pagereference result2 = con.saveRequest();
	    	System.assertEquals(result2, null);
	    	
	    	/* Test 3: User not already exist [saveAndNew] */
	    	con.newRequest = new External_User_Request__c();
	    	con.newRequest.EXT_USR_RQT_First_Name__c = 'testRQT';
	    	con.newRequest.EXT_USR_RQT_Last_Name__c = 'testing';
	    	con.newRequest.EXT_USR_RQT_Company__c = 'test';
	    	con.newRequest.EXT_USR_RQT_Email__c = 'testRQT1.testing@test.com';  
	    	Pagereference result3 = con.saveAndNew();
	    	System.assertnotEquals(result3, null);
	    	
	    	/* Test 4: User already exist [saveAndNew] */
	    	con.newRequest.EXT_USR_RQT_Email__c = listUsers[0].Email;  
	    	Pagereference result4 = con.saveAndNew();
	    	System.assertEquals(result4, null);
	    	
	    	/* Test 5: Exception [Save] */
	    	con.newRequest.EXT_USR_RQT_Email__c = 'testRQT.testing@test.com';  
	    	Pagereference result5 = con.saveRequest();
	    	System.assertEquals(result5, null);
	    	
	    	/* Test 6: Exception [saveAndNew] */
	    	con.newRequest.EXT_USR_RQT_Email__c = 'testRQT.testing@test.com';  
	    	Pagereference result6 = con.saveAndNew();
	    	System.assertEquals(result6, null);	    	
    	}
    }
}