/*
+-----------------------+------------------------------------------------------------------------------------+
| Author                | Cécile Lartaud                                                                     |
+-----------------------+------------------------------------------------------------------------------------+
| Description           |                                                                                    |
|                       |                                                                                    |
|     - Object(s)       | ESN Policy			                                                             |
|     - Description     | Test class of VFC02_USRProfileWS            										 |
+-----------------------+------------------------------------------------------------------------------------+
| Creation Date         | 12/12/2012                                                                         |
+-----------------------+------------------------------------------------------------------------------------+
| Modifications         | 							                                                         |
+-----------------------+------------------------------------------------------------------------------------+
*/
@isTest(SeeAllData=true)
private class EXT_USR_RQT_SigningProcessCON_TEST {

    /* Test 1 : URL invalid */
    static testMethod void invalidURL() {
        
        /* Create a new group */
        CollaborationGroup myGroup = TestFactory.createCollaborationGroup('groupTest', 'Private');
        myGroup.CanHaveGuests = true;
        insert myGroup;  
        
        /* Create a new request */
        External_User_Request__c newRequest = new External_User_Request__c();
        newRequest.EXT_USR_RQT_First_Name__c = 'testRQT';
        newRequest.EXT_USR_RQT_Last_Name__c = 'testing';
        newRequest.EXT_USR_RQT_Company__c = 'test';
        newRequest.EXT_USR_RQT_Email__c = 'testRQT.testing@test.com';
        newRequest.EXT_USR_RQT_Status__c = 'Closed';
        insert newRequest;
        String requestId = newRequest.Id;
        
        /* Create a new instance of the VF page and the Apex controller */
        Pagereference vf = Page.EXT_USR_RQT_SigningProcess;
        Test.setCurrentPageReference(vf);       
        EXT_USR_RQT_SigningProcessCON con = new EXT_USR_RQT_SigningProcessCON(new ApexPages.StandardController(new External_User_Request__c()));
        
        /* Test 1 execution */
        Pagereference result1 = con.guestAccessVerification();
        System.assertEquals(result1.getUrl(), Page.EXT_USR_RQT_ExceptionInvalidURL.getUrl());   
         
        /* Test 2 execution */
        delete newRequest;
        Pagereference vf2 = Page.EXT_USR_RQT_SigningProcess;
        vf2.getParameters().put('Id',requestId);
        Test.setCurrentPageReference(vf2);
        EXT_USR_RQT_SigningProcessCON con2 = new EXT_USR_RQT_SigningProcessCON(new ApexPages.StandardController(new External_User_Request__c()));
        Pagereference result2 = con2.guestAccessVerification();
        System.assertEquals(result2.getUrl(), Page.EXT_USR_RQT_Exception.getUrl());         
        
    }
    
    /* Test 2 : Request invalid */
    static testMethod void invalidRequest() {
        /* Create a new group */
        CollaborationGroup myGroup = TestFactory.createCollaborationGroup('groupTest', 'Private');
        myGroup.CanHaveGuests = true;
        insert myGroup;  
                
        /* Create a new request */
        External_User_Request__c newRequest = new External_User_Request__c();
        newRequest.EXT_USR_RQT_First_Name__c = 'testRQT';
        newRequest.EXT_USR_RQT_Last_Name__c = 'testing';
        newRequest.EXT_USR_RQT_Company__c = 'test';
        newRequest.EXT_USR_RQT_Email__c = 'testRQT.testing@test.com';
        newRequest.EXT_USR_RQT_Status__c = 'Closed';
        insert newRequest;
        
        /* Create a new instance of the VF page and the Apex controller */
        Pagereference vf = Page.EXT_USR_RQT_SigningProcess;
        vf.getParameters().put('Id',newRequest.Id);
        Test.setCurrentPageReference(vf);
        
        EXT_USR_RQT_SigningProcessCON con = new EXT_USR_RQT_SigningProcessCON(new ApexPages.StandardController(newRequest));
        
        /* Test execution */
        Pagereference result1 = con.guestAccessVerification();
        System.assertEquals(result1.getUrl(), Page.EXT_USR_RQT_ExceptionInvalidRequest.getUrl());
        
        con.currRequest.EXT_USR_RQT_Status__c = 'Refused';
        Pagereference result2 = con.guestAccessVerification();
        System.assertEquals(result2.getUrl(), Page.EXT_USR_RQT_ExceptionInvalidRequest.getUrl());       
    }
    
    /* Test 3 : [User not already exist] sign only one document */
    static testMethod void userAlreadyExist_notSign() {
        /* Create a new group */
        CollaborationGroup myGroup = TestFactory.createCollaborationGroup('groupTest', 'Private');
        myGroup.CanHaveGuests = true;
        insert myGroup;  
        
        /* Create a user  */
        User userSTD = TestFactory.createStandardUser('user');
        userSTD.email = 'user@test.com';
        insert userSTD;
        
        /* Create a new request */
        External_User_Request__c newRequest = new External_User_Request__c();
        newRequest.EXT_USR_RQT_First_Name__c = 'testRQT';
        newRequest.EXT_USR_RQT_Last_Name__c = 'testing';
        newRequest.EXT_USR_RQT_Company__c = 'test';
        newRequest.EXT_USR_RQT_Email__c = 'user@test.com';
        newRequest.EXT_USR_RQT_Status__c = 'Accepted';
        insert newRequest;
        
        /* Create a new instance of the VF page and the Apex controller */
        Pagereference vf = Page.EXT_USR_RQT_SigningProcess;
        vf.getParameters().put('Id',newRequest.Id);
        Test.setCurrentPageReference(vf);
        
        EXT_USR_RQT_SigningProcessCON con = new EXT_USR_RQT_SigningProcessCON(new ApexPages.StandardController(newRequest));
        
        /* Test execution */
        Pagereference result1 = con.guestAccessVerification();
        System.assertEquals(result1, null);
        Pagereference result2 = con.signThenCreateExtUser();
        System.assertEquals(result2.getUrl(), Page.EXT_USR_RQT_ExceptionNotSign.getUrl());
    }
    
    /* Test 3 : [User not already exist] sign only one document */
    static testMethod void userAlreadyExist_SignOK() {
        /* Create a new group */
        CollaborationGroup myGroup = TestFactory.createCollaborationGroup('groupTest', 'Private');
        myGroup.CanHaveGuests = true;
        insert myGroup;  
        
        /* Create a user  */
        User userSTD = TestFactory.createStandardUser('user');
        userSTD.email = 'user@test.com';
        insert userSTD;
        
        /* Create a new request */
        External_User_Request__c newRequest = new External_User_Request__c();
        newRequest.EXT_USR_RQT_First_Name__c = 'testRQT';
        newRequest.EXT_USR_RQT_Last_Name__c = 'testing';
        newRequest.EXT_USR_RQT_Company__c = 'test';
        newRequest.EXT_USR_RQT_Email__c = 'user@test.com';
        newRequest.EXT_USR_RQT_Status__c = 'Accepted';
        insert newRequest;
        
        /* Create a new instance of the VF page and the Apex controller */
        Pagereference vf = Page.EXT_USR_RQT_SigningProcess;
        vf.getParameters().put('Id',newRequest.Id);
        Test.setCurrentPageReference(vf);
        
        EXT_USR_RQT_SigningProcessCON con = new EXT_USR_RQT_SigningProcessCON(new ApexPages.StandardController(newRequest));
        
        /* Test execution */
        Pagereference result1 = con.guestAccessVerification();
        System.assertEquals(result1, null);
        con.checkESNPolicySign = true;
        con.checkNDASign = true;
        con.testCase = 2;
        Pagereference result2 = con.signThenCreateExtUser();
        System.assertEquals(result2.getUrl(), Page.EXT_USR_RQT_success.getUrl());
    }
    
    /* Test 3 : [User not already exist] sign only one document */
    static testMethod void userAlreadyExist_SignKO() {
        /* Create a new group */
        CollaborationGroup myGroup = TestFactory.createCollaborationGroup('groupTest', 'Private');
        myGroup.CanHaveGuests = true;
        insert myGroup;  
        
        /* Create a user  */
        User userSTD = TestFactory.createStandardUser('user');
        userSTD.email = 'user@test.com';
        insert userSTD;
        
        /* Create a new request */
        External_User_Request__c newRequest = new External_User_Request__c();
        newRequest.EXT_USR_RQT_First_Name__c = 'testRQT';
        newRequest.EXT_USR_RQT_Last_Name__c = 'testing';
        newRequest.EXT_USR_RQT_Company__c = 'test';
        newRequest.EXT_USR_RQT_Email__c = 'user@test.com';
        newRequest.EXT_USR_RQT_Status__c = 'Accepted';
        insert newRequest;
        
        /* Create a new instance of the VF page and the Apex controller */
        Pagereference vf = Page.EXT_USR_RQT_SigningProcess;
        vf.getParameters().put('Id',newRequest.Id);
        Test.setCurrentPageReference(vf);
        
        EXT_USR_RQT_SigningProcessCON con = new EXT_USR_RQT_SigningProcessCON(new ApexPages.StandardController(newRequest));
        
        /* Test execution */
        Pagereference result1 = con.guestAccessVerification();
        System.assertEquals(result1, null);
        con.checkESNPolicySign = true;
        con.checkNDASign = true;
        con.testCase = 1;
        
        Pagereference result2 = con.signThenCreateExtUser();
        System.assertEquals(result2.getUrl(), Page.EXT_USR_RQT_Exception.getUrl());
                
        con.checkESNPolicySign = false;
        con.currRequest = new External_User_Request__c();
        Pagereference result3 = con.signThenCreateExtUser();
        System.assertEquals(result3.getUrl(), Page.EXT_USR_RQT_Exception.getUrl());
        
    }
}