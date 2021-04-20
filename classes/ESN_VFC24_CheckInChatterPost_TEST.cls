/*
+-----------------------+------------------------------------------------------------------------------------+
| Author                | Cécile Lartaud                                                                     |
+-----------------------+------------------------------------------------------------------------------------+
| Description           |                                                                                    |
|                       |                                                                                    |
|     - Object(s)       |                                                                                  	 |
|     - Description     | Test of class ESN_VFC24_CheckInChatterPost  				                         |
+-----------------------+------------------------------------------------------------------------------------+
| Creation Date         | 23/07/2013                                                                         |
+-----------------------+------------------------------------------------------------------------------------+
| Modifications         |                                                                                    |
+-----------------------+------------------------------------------------------------------------------------+
| Governor informations |                                                                                    |
+-----------------------+------------------------------------------------------------------------------------+
*/
@isTest
private class ESN_VFC24_CheckInChatterPost_TEST{
    
	static testMethod void myUnitTest() {
        /* Create a context user */
        User contextUsr = TestFactory.createUserWithProfile('ctxUsr', 'ESN SSO User');
        insert contextUsr;
        
        /* Query the permission set "Project Management" */
        List<PermissionSet> searchList = [SELECT Id FROM PermissionSet WHERE Name = 'ESN_CheckInPermission'];
        String permId = searchList[0].Id;
        
        /* Assign the permission set to the user */
        PermissionSetAssignment permAssign = new PermissionSetAssignment( AssigneeId = contextUsr.Id, PermissionSetId = permId );
        insert permAssign;
            
      	System.runas(contextUsr){            
            /* Create new instance of Visualforce Page */
            Pagereference vf = Page.ESN_VFP24_CheckInChatterPost;
            Test.setCurrentPageReference(vf);
            
            // Post and Location filled //
            ESN_VFC24_CheckInChatterPost con1 = new ESN_VFC24_CheckInChatterPost();
            con1.inputLocation = 'Tour Eiffel, Avenue Anatole France, Paris, France';
            con1.inputLocLat = '48.8582780';
            con1.inputLocLng = '2.2942540';
            con1.inputLocName = 'Tour Eiffel';
            con1.inputPostMsg = 'I\'m here !';
            con1.sharePostLocation();
            
            // No location filled //
            ESN_VFC24_CheckInChatterPost con2 = new ESN_VFC24_CheckInChatterPost();
            con2.inputPostMsg = 'I\'m here !';
            con2.sharePostLocation();
            
            // No post filled //
            ESN_VFC24_CheckInChatterPost con3 = new ESN_VFC24_CheckInChatterPost();
            con3.inputLocName = 'Tour Eiffel';
            con3.sharePostLocation();
            
            // Post in a group //
            CollaborationGroup cgm = TestFactory.createCollaborationGroup('groupeVFP24', 'Private');
            insert cgm;
            
            ESN_VFC24_CheckInChatterPost con4 = new ESN_VFC24_CheckInChatterPost();
            con4.inputLocation = 'Tour Eiffel, Avenue Anatole France, Paris, France';
            con4.inputLocLat = '48.8582780';
            con4.inputLocLng = '2.2942540';
            con4.inputLocName = 'Tour Eiffel';
            con4.inputPostMsg = 'I\'m here !';
            con4.inputGroup = cgm.Id;
            con4.sharePostLocation();
            
            // Exception //
            ESN_VFC24_CheckInChatterPost con5 = new ESN_VFC24_CheckInChatterPost();
            con5.inputLocation = 'Tour Eiffel, Avenue Anatole France, Paris, France';
            con5.inputLocLat = '48.8582780';
            con5.inputLocLng = '2.2942540';
            con5.inputLocName = 'Tour Eiffel';
            con5.inputPostMsg = 'I\'m here !';
            con5.inputGroup = 'wrong';
            con5.sharePostLocation();
        }
    }
}