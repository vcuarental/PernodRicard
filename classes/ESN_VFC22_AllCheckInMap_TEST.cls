/*
+-----------------------+------------------------------------------------------------------------------------+
| Author                | Cécile Lartaud                                                                     |
+-----------------------+------------------------------------------------------------------------------------+
| Description           |                                                                                    |
|                       |                                                                                    |
|     - Object(s)       |                                                                                  	 |
|     - Description     | Test of class ESN_VFC22_AllCheckInMap  				                         |
+-----------------------+------------------------------------------------------------------------------------+
| Creation Date         | 23/07/2013                                                                         |
+-----------------------+------------------------------------------------------------------------------------+
| Modifications         |                                                                                    |
+-----------------------+------------------------------------------------------------------------------------+
| Governor informations |                                                                                    |
+-----------------------+------------------------------------------------------------------------------------+
*/
@isTest
private class ESN_VFC22_AllCheckInMap_TEST{
    
	static testMethod void myUnitTest() {
        /* Create a context user */
        User contextUsr = TestFactory.createUserWithProfile('ctxUsr', 'ESN SSO User');
        insert contextUsr;
        
        /* Create many users */
        List<User> newUsers = new List<User>();
        User usr1 = TestFactory.createUserWithProfile('usr1', 'ESN SSO User');
        newUsers.add(usr1);
        User usr2 = TestFactory.createUserWithProfile('usr2', 'ESN SSO User');
        newUsers.add(usr2);
        User usr3 = TestFactory.createUserWithProfile('usr3', 'ESN SSO User');
        newUsers.add(usr3);
        User usr4 = TestFactory.createUserWithProfile('usr4', 'ESN SSO User');
        newUsers.add(usr4);
        User usr5 = TestFactory.createUserWithProfile('usr5', 'ESN SSO User');
        newUsers.add(usr5);
        insert newUsers;
        
        /* Create checkin for all users */
        ESN_CheckIn__c ci1 = TestFactory.createCheckIn(usr1);
        insert ci1;
        ESN_CheckIn__c ci2 = TestFactory.createCheckIn(usr2);
        insert ci2;
        ESN_CheckIn__c ci3 = TestFactory.createCheckIn(usr3);
        insert ci3;
        ESN_CheckIn__c ci4 = TestFactory.createCheckIn(usr4);
        insert ci4;
        ESN_CheckIn__c ci5 = TestFactory.createCheckIn(usr5);
        insert ci5;
        ESN_CheckIn__c ci6 = TestFactory.createCheckIn(usr1);
        ci6.ESN_Date__c = DateTime.now().addDays(1);
        insert ci6;
        
      	System.runas(contextUsr){            
            /* Create new instance of Visualforce Page */
            Pagereference vf = Page.ESN_VFP22_AllCheckInMap;
            Test.setCurrentPageReference(vf);
            ESN_VFC22_AllCheckInMap con1 = new ESN_VFC22_AllCheckInMap();
        }
    }
}