/*
+-----------------------+------------------------------------------------------------------------------------+
| Author                | Cécile Lartaud                                                                     |
+-----------------------+------------------------------------------------------------------------------------+
| Description           |                                                                                    |
|                       |                                                                                    |
|     - Object(s)       | External User Requests                                                             |
|     - Description     | Test Class                                                                         |
+-----------------------+------------------------------------------------------------------------------------+
| Creation Date         | 01/12/2012                                                                         |
+-----------------------+------------------------------------------------------------------------------------+
| Modifications         |                                                                                    |
+-----------------------+------------------------------------------------------------------------------------+
| Governor informations |                                                                                    |
+-----------------------+------------------------------------------------------------------------------------+
*/
@isTest(SeeAllData=true)
private class EXT_USR_RQT_AddUserGroupWS_TEST {
    
static testMethod void testConnector() {
/* Get User profile for bypassing execution by System Administrator GDT - Jef 01/10/2013 */
if((UserInfo.getProfileId()!='00eD0000001ApvPIAS') && (UserInfo.getProfileId()!= '00eL0000000DkgiIAC'))
{
        User testUser = TestFactory.createStandardUser('test1');                
        insert testUser;
        
        EXT_USR_RQT_AddUserGroupWS myClass = new EXT_USR_RQT_AddUserGroupWS();  
        EXT_USR_RQT_AddUserGroupWSConnector WSC = new EXT_USR_RQT_AddUserGroupWSConnector();    
        partnerSoapSforceCom partS = new partnerSoapSforceCom();
        
        partnerSoapSforceCom.Soap sp = new partnerSoapSforceCom.Soap();        
        partnerSoapSforceCom.getUserInfo_element uie = new partnerSoapSforceCom.getUserInfo_element();
        partnerSoapSforceCom.LoginResult lr = new partnerSoapSforceCom.LoginResult();
        partnerSoapSforceCom.GetUserInfoResult uir = new partnerSoapSforceCom.GetUserInfoResult();      
        partnerSoapSforceCom.logout_element logo_el = new partnerSoapSforceCom.logout_element(); 
        partnerSoapSforceCom.loginResponse_element  logire_el = new partnerSoapSforceCom.loginResponse_element();
        partnerSoapSforceCom.getServerTimestamp_element timest_el = new partnerSoapSforceCom.getServerTimestamp_element();  
        partnerSoapSforceCom.CallOptions_element colop = new partnerSoapSforceCom.CallOptions_element();
        partnerSoapSforceCom.MruHeader_element mru = new partnerSoapSforceCom.MruHeader_element();
        partnerSoapSforceCom.SessionHeader_element sh = new partnerSoapSforceCom.SessionHeader_element();
        partnerSoapSforceCom.AllOrNoneHeader_element aonh = new partnerSoapSforceCom.AllOrNoneHeader_element();
        partnerSoapSforceCom.AllowFieldTruncationHeader_element afth = new partnerSoapSforceCom.AllowFieldTruncationHeader_element();
        partnerSoapSforceCom.DisableFeedTrackingHeader_element dfth = new partnerSoapSforceCom.DisableFeedTrackingHeader_element();
        partnerSoapSforceCom.LoginScopeHeader_element lsh = new partnerSoapSforceCom.LoginScopeHeader_element();
        partnerSoapSforceCom.GetServerTimestampResult gstr = new partnerSoapSforceCom.GetServerTimestampResult();
        partnerSoapSforceCom.getServerTimestampResponse_element gstrs = new partnerSoapSforceCom.getServerTimestampResponse_element();
        partnerSoapSforceCom.LocaleOptions_element locops = new partnerSoapSforceCom.LocaleOptions_element();
        partnerSoapSforceCom.StreamingEnabledHeader_element seh = new partnerSoapSforceCom.StreamingEnabledHeader_element();
        partnerSoapSforceCom.AssignmentRuleHeader_element arh = new partnerSoapSforceCom.AssignmentRuleHeader_element();
        partnerSoapSforceCom.login_element logel = new partnerSoapSforceCom.login_element();
        partnerSoapSforceCom.getUserInfoResponse_element guir = new partnerSoapSforceCom.getUserInfoResponse_element();
        partnerSoapSforceCom.setPasswordResponse_element spwdrep = new partnerSoapSforceCom.setPasswordResponse_element();
        partnerSoapSforceCom.logoutResponse_element logoutresp = new partnerSoapSforceCom.logoutResponse_element();
        partnerSoapSforceCom.UserTerritoryDeleteHeader_element utdh = new partnerSoapSforceCom.UserTerritoryDeleteHeader_element();
        partnerSoapSforceCom.DebuggingInfo_element die = new partnerSoapSforceCom.DebuggingInfo_element();
        partnerSoapSforceCom.EmailHeader_element emailhead = new partnerSoapSforceCom.EmailHeader_element();
        partnerSoapSforceCom.setPassword_element setpwd = new partnerSoapSforceCom.setPassword_element();
        partnerSoapSforceCom.Error err = new partnerSoapSforceCom.Error();
        partnerSoapSforceCom.SetPasswordResult setpwdresu = new partnerSoapSforceCom.SetPasswordResult();
        partnerSoapSforceCom.DebuggingHeader_element debhead = new partnerSoapSforceCom.DebuggingHeader_element();

        faultPartnerSoapSforceCom fps = new faultPartnerSoapSforceCom();
        faultPartnerSoapSforceCom.ApiFault apif = new faultPartnerSoapSforceCom.ApiFault();
        faultPartnerSoapSforceCom.InvalidSObjectFault isobf = new faultPartnerSoapSforceCom.InvalidSObjectFault();
        faultPartnerSoapSforceCom.MalformedQueryFault mqf = new faultPartnerSoapSforceCom.MalformedQueryFault();
        faultPartnerSoapSforceCom.InvalidIdFault iidf = new faultPartnerSoapSforceCom.InvalidIdFault();
        faultPartnerSoapSforceCom.InvalidFieldFault iff = new faultPartnerSoapSforceCom.InvalidFieldFault();
        faultPartnerSoapSforceCom.MalformedSearchFault msf = new faultPartnerSoapSforceCom.MalformedSearchFault();
        faultPartnerSoapSforceCom.ApiQueryFault apiqf = new faultPartnerSoapSforceCom.ApiQueryFault();
        faultPartnerSoapSforceCom.UnexpectedErrorFault unerf = new faultPartnerSoapSforceCom.UnexpectedErrorFault();
        faultPartnerSoapSforceCom.LoginFault logif = new faultPartnerSoapSforceCom.LoginFault();
        faultPartnerSoapSforceCom.InvalidQueryLocatorFault iqlf = new faultPartnerSoapSforceCom.InvalidQueryLocatorFault();
        faultPartnerSoapSforceCom.InvalidNewPasswordFault inpf = new faultPartnerSoapSforceCom.InvalidNewPasswordFault();

        sobjectPartnerSoapSforceCom sobp = new sobjectPartnerSoapSforceCom();
        sobjectPartnerSoapSforceCom.sObject_x sox = new sobjectPartnerSoapSforceCom.sObject_x();

        EXT_USR_RQT_AddUserGroupWSConnector uupwsc = new EXT_USR_RQT_AddUserGroupWSConnector();
        EXT_USR_RQT_AddUserGroupWSConnector.LogInfo logInfo = new EXT_USR_RQT_AddUserGroupWSConnector.LogInfo();
        EXT_USR_RQT_AddUserGroupWSConnector.addUserToGroupResponse_element mupresp = new EXT_USR_RQT_AddUserGroupWSConnector.addUserToGroupResponse_element();
        EXT_USR_RQT_AddUserGroupWSConnector.AllowFieldTruncationHeader_element afthe = new EXT_USR_RQT_AddUserGroupWSConnector.AllowFieldTruncationHeader_element();
        EXT_USR_RQT_AddUserGroupWSConnector.DebuggingHeader_element debhea = new EXT_USR_RQT_AddUserGroupWSConnector.DebuggingHeader_element();
        EXT_USR_RQT_AddUserGroupWSConnector.CallOptions_element calloti = new EXT_USR_RQT_AddUserGroupWSConnector.CallOptions_element();
        EXT_USR_RQT_AddUserGroupWSConnector.SessionHeader_element seessh = new EXT_USR_RQT_AddUserGroupWSConnector.SessionHeader_element();
        EXT_USR_RQT_AddUserGroupWSConnector.addUserToGroup_element muprof = new EXT_USR_RQT_AddUserGroupWSConnector.addUserToGroup_element();
        EXT_USR_RQT_AddUserGroupWSConnector.DebuggingInfo_element debhe = new EXT_USR_RQT_AddUserGroupWSConnector.DebuggingInfo_element();
        EXT_USR_RQT_AddUserGroupWSConnector.CodeReturn cr = new EXT_USR_RQT_AddUserGroupWSConnector.CodeReturn();

        //partnerSoapSforceCom.LoginResult 
        //loginResult = sp.login('ggackiere@esn1.dev', 'yrogerg357+1');        
        //ws.SessionHeader = new EXT_USR_RQT_AddUserGroupWSConnector.SessionHeader_element();
        //ws.SessionHeader.sessionId = UserInfo.getSessionId();
        //ws.SessionHeader.sessionId = loginResult.sessionId;  
        
        /* Create a new group */
        CollaborationGroup myGroup = TestFactory.createCollaborationGroup('groupTest', 'Private');
        myGroup.CanHaveGuests = true;
        insert myGroup;  
        
        /* Create a new request */
        External_User_Request__c newRequest = new External_User_Request__c();
        newRequest.EXT_USR_RQT_First_Name__c = 'testRQT';
        newRequest.EXT_USR_RQT_Last_Name__c = 'testing';
        newRequest.EXT_USR_RQT_Company__c = 'test';
        newRequest.EXT_USR_RQT_Email__c = 'user@test.com';
        newRequest.EXT_USR_RQT_Status__c = 'Accepted';
        insert newRequest;
        
        /* Create a user  */
        User userSTD = TestFactory.createStandardUser('user');
        userSTD.email = 'user@test.com';
        insert userSTD;
        
        /* Create the wrapper object */
        EXT_USR_RQT_AddUserGroupWSConnector.EXT_USR_RQT_Wrapper myRqt = new EXT_USR_RQT_AddUserGroupWSConnector.EXT_USR_RQT_Wrapper();
        myRqt.Alias = 'test';
        myRqt.Company = newRequest.EXT_USR_RQT_Company__c;
        myRqt.Email = newRequest.EXT_USR_RQT_Email__c;
        myRqt.ExpiryDate = DateTime.now()+30;
        myRqt.FirstName = newRequest.EXT_USR_RQT_First_Name__c;
        myRqt.groupID = newRequest.EXT_USR_RQT_Group_ID__c;
        myRqt.LastName = newRequest.EXT_USR_RQT_Last_Name__c;
        myRqt.Nickname = 'test';
        myRqt.requestID = newRequest.Id;
        myRqt.Username = 'test';
        myRqt.ExtUserID = userSTD.Id;
        
        /* Webservice execution */
        List<EXT_USR_RQT_AddUserGroupWSConnector.CodeReturn> listCodeReturn = new List<EXT_USR_RQT_AddUserGroupWSConnector.CodeReturn>();       
        EXT_USR_RQT_AddUserGroupWSConnector.EXT_USR_RQT_AddUserGroupWS ws = new EXT_USR_RQT_AddUserGroupWSConnector.EXT_USR_RQT_AddUserGroupWS();
        listCodeReturn = ws.addUserToGroup(myRqt);
        
        EXT_USR_RQT_AddUserGroupWS.EXT_USR_RQT_Wrapper myRqt2 = new EXT_USR_RQT_AddUserGroupWS.EXT_USR_RQT_Wrapper();
    } }
    
static testMethod void userAlreadyExist() {
/* Get User profile for bypassing execution by System Administrator GDT - Jef 01/10/2013 */
if((UserInfo.getProfileId()!='00eD0000001ApvPIAS') && (UserInfo.getProfileId()!= '00eL0000000DkgiIAC'))
{
           /* Create a system admin user */
        User admin = TestFactory.createUserWithProfile('admin','System Administrator');
        admin.BypassVR__c = true;
        insert admin;
        
        
        /* Create a new group */
        CollaborationGroup myGroup = TestFactory.createCollaborationGroup('groupTest', 'Private');
        myGroup.CanHaveGuests = true;
        insert myGroup;  
        
        /* Create a new request */
        External_User_Request__c newRequest = new External_User_Request__c();
        newRequest.EXT_USR_RQT_First_Name__c = 'testRQT';
        newRequest.EXT_USR_RQT_Last_Name__c = 'testing';
        newRequest.EXT_USR_RQT_Company__c = 'test';
        newRequest.EXT_USR_RQT_Email__c = 'user@test.com';
        newRequest.EXT_USR_RQT_Status__c = 'Accepted';
        insert newRequest;
        
        /* Create a user  */
        User userSTD = TestFactory.createStandardUser('user');
        userSTD.email = 'user@test.com';
        insert userSTD;
        
        /* Create the wrapper object */
        EXT_USR_RQT_AddUserGroupWS.EXT_USR_RQT_Wrapper myRqt = new EXT_USR_RQT_AddUserGroupWS.EXT_USR_RQT_Wrapper();
        myRqt.Alias = 'test';
        myRqt.Company = newRequest.EXT_USR_RQT_Company__c;
        myRqt.Email = newRequest.EXT_USR_RQT_Email__c;
        myRqt.ExpiryDate = DateTime.now()+30;
        myRqt.FirstName = newRequest.EXT_USR_RQT_First_Name__c;
        myRqt.groupID = myGroup.Id;
        myRqt.LastName = newRequest.EXT_USR_RQT_Last_Name__c;
        myRqt.Nickname = 'test';
        myRqt.requestID = newRequest.Id;
        myRqt.Username = 'test';
        myRqt.ExtUserID = userSTD.Id;
        
        /* Webservice execution */
        List<EXT_USR_RQT_AddUserGroupWS.CodeReturn> listCodeReturn = new List<EXT_USR_RQT_AddUserGroupWS.CodeReturn>();     
        EXT_USR_RQT_AddUserGroupWS ws = new EXT_USR_RQT_AddUserGroupWS();

        
        System.runAs(admin){
            listCodeReturn = EXT_USR_RQT_AddUserGroupWS.addUserToGroup(myRqt);
        }        
        for(EXT_USR_RQT_AddUserGroupWS.CodeReturn cr : listCodeReturn){
            System.debug('#### code return : ['+cr.code+'] '+cr.error);
        }       
        
        System.assertEquals(listCodeReturn.get(0).code, 'OK');
    } }
    
static testMethod void userNotAlreadyExist() {
/* Get User profile for bypassing execution by System Administrator GDT - Jef 01/10/2013 */
if((UserInfo.getProfileId()!='00eD0000001ApvPIAS') && (UserInfo.getProfileId()!= '00eL0000000DkgiIAC'))
{
           /* Create a system admin user */
        User admin = TestFactory.createUserWithProfile('admin1','System Administrator');
        admin.BypassVR__c = true;
        insert admin;
        
        /* Create a new group */
        CollaborationGroup myGroup = TestFactory.createCollaborationGroup('groupTest', 'Private');
        myGroup.CanHaveGuests = true;
        insert myGroup;  
        
        /* Create a new request */
        External_User_Request__c newRequest = new External_User_Request__c();
        newRequest.EXT_USR_RQT_First_Name__c = 'testRQT';
        newRequest.EXT_USR_RQT_Last_Name__c = 'testing';
        newRequest.EXT_USR_RQT_Company__c = 'test';
        newRequest.EXT_USR_RQT_Email__c = 'user@test.com';
        newRequest.EXT_USR_RQT_Status__c = 'Accepted';
        insert newRequest;
        
        /* Create a user  */
        User userSTD = TestFactory.createUserWithProfile('admin', 'System Administrator');
        userSTD.email = 'user1@test.com';
        userSTD.BypassTriggers__c = 'Autofollow_User_InsertUpdate,AutoJoin_User_InsertUpdate';
        insert userSTD;
        
        /* Create the wrapper object */
        EXT_USR_RQT_AddUserGroupWS.EXT_USR_RQT_Wrapper myRqt = new EXT_USR_RQT_AddUserGroupWS.EXT_USR_RQT_Wrapper();
        myRqt.Alias = 'test12';
        myRqt.Company = newRequest.EXT_USR_RQT_Company__c;
        myRqt.Email = newRequest.EXT_USR_RQT_Email__c;
        myRqt.ExpiryDate = DateTime.now()+30;
        myRqt.FirstName = newRequest.EXT_USR_RQT_First_Name__c;
        myRqt.groupID = myGroup.Id;
        myRqt.LastName = newRequest.EXT_USR_RQT_Last_Name__c;
        myRqt.Nickname = 'test12';
        myRqt.requestID = newRequest.Id;
        myRqt.Username = 'test@toto.com';
        
        /* Webservice execution */
        List<EXT_USR_RQT_AddUserGroupWS.CodeReturn> listCodeReturn = new List<EXT_USR_RQT_AddUserGroupWS.CodeReturn>();     
        EXT_USR_RQT_AddUserGroupWS ws = new EXT_USR_RQT_AddUserGroupWS();
        
        System.runAs(admin){
            listCodeReturn = EXT_USR_RQT_AddUserGroupWS.addUserToGroup(myRqt);
        }
        
        for(EXT_USR_RQT_AddUserGroupWS.CodeReturn cr : listCodeReturn){
            System.debug('#### code return : ['+cr.code+'] '+cr.error);
        }
        
        System.assertEquals(listCodeReturn.get(0).code, 'OK');
    } }
    
static testMethod void testExceptions() { 
/* Get User profile for bypassing execution by System Administrator GDT - Jef 01/10/2013 */
if((UserInfo.getProfileId()!='00eD0000001ApvPIAS') && (UserInfo.getProfileId()!= '00eL0000000DkgiIAC'))
{
           
        /* Create a new request */
        External_User_Request__c newRequest = new External_User_Request__c();
        newRequest.EXT_USR_RQT_First_Name__c = 'testRQT';
        newRequest.EXT_USR_RQT_Last_Name__c = 'testing';
        newRequest.EXT_USR_RQT_Company__c = 'test';
        newRequest.EXT_USR_RQT_Email__c = 'user@test.com';
        newRequest.EXT_USR_RQT_Status__c = 'Accepted';
        insert newRequest;
        
        /* Create a user  */
        User userSTD = TestFactory.createUserWithProfile('admin', 'System Administrator');
        userSTD.email = 'user1@test.com';
        userSTD.BypassTriggers__c = 'Autofollow_User_InsertUpdate,AutoJoin_User_InsertUpdate';
        insert userSTD;
        
        /* Create the wrapper object */
        EXT_USR_RQT_AddUserGroupWS.EXT_USR_RQT_Wrapper myRqt = new EXT_USR_RQT_AddUserGroupWS.EXT_USR_RQT_Wrapper();
        myRqt.Alias = 'test12';
        myRqt.Email = newRequest.EXT_USR_RQT_Email__c;
        myRqt.ExpiryDate = DateTime.now()+30;
        myRqt.LastName = newRequest.EXT_USR_RQT_Last_Name__c;
        myRqt.Nickname = 'test12';
        myRqt.Username = 'test@toto.com';
        
        /* Webservice execution */
        List<EXT_USR_RQT_AddUserGroupWS.CodeReturn> listCodeReturn1 = new List<EXT_USR_RQT_AddUserGroupWS.CodeReturn>();  
        List<EXT_USR_RQT_AddUserGroupWS.CodeReturn> listCodeReturn2 = new List<EXT_USR_RQT_AddUserGroupWS.CodeReturn>();    
        EXT_USR_RQT_AddUserGroupWS ws = new EXT_USR_RQT_AddUserGroupWS();
        
        System.runAs(userSTD){
            listCodeReturn1 = EXT_USR_RQT_AddUserGroupWS.addUserToGroup(myRqt);
            myRqt.ExtUserID = userSTD.Id;
            myRqt.Company = newRequest.EXT_USR_RQT_Company__c;
            listCodeReturn2 = EXT_USR_RQT_AddUserGroupWS.addUserToGroup(myRqt);
        }
        
        for(EXT_USR_RQT_AddUserGroupWS.CodeReturn cr : listCodeReturn1){
            System.debug('#### code return : ['+cr.code+'] '+cr.error);
        }
        
        System.assertEquals(listCodeReturn1.get(0).code, 'KO');
        System.assertEquals(listCodeReturn2.get(0).code, 'KO');
        
    } }
}