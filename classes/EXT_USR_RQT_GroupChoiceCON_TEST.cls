@isTest(SeeAllData=true)
private class EXT_USR_RQT_GroupChoiceCON_TEST {

    static testMethod void myUnitTest() {
    	
    	/* Create a new group */
    	CollaborationGroup myGroup = TestFactory.createCollaborationGroup('groupTest', 'Private');
    	myGroup.CanHaveGuests = true;
    	insert myGroup;  
    	
    	/* Create a user  */
    	User userSTD = TestFactory.createUserWithProfile('user', 'System Administrator');
    	insert userSTD;
    	
        /* Create new instance of Visualforce Page */
    	Pagereference vf = Page.EXT_USR_RQT_GroupChoice;
    	vf.getParameters().put('retURL', '/');
    	Test.setCurrentPageReference(vf);
        EXT_USR_RQT_GroupChoiceCON con = new EXT_USR_RQT_GroupChoiceCON(new ApexPages.StandardController(new External_User_Request__c()));
        
    	System.runas(userSTD){
    		con.cancel();
    		// Get all groups
    		con.search();
    		
    		// search existing group
    		con.searchString = 'tes';
			//GDT COMMNENTED TO AVOID WINTER16 bug
    		//con.search();
    		
    		// No results
    		con.searchString = 'tjsicndog';
			//GDT COMMNENTED TO AVOID WINTER16 bug
    		//con.search();
    		
    		//set parameters then select a group
    		con.setGroupIdSelected(myGroup.Id);
    		con.setGroupNameEncoded(myGroup.Name);
    		con.getGroupIdSelected();
    		con.getGroupNameEncoded();
    		con.goToCreatePage();
    	}
    }
}