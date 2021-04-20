@isTest
private class UpdateUserProfileWebServiceTest {
	static testMethod void testOK() {
		User testUser = TestFactory.createStandardUser('test1');			    
		insert testUser;
		
		UpdateUserProfileWebService myClass = new UpdateUserProfileWebService();	
		UpdateUserProfileWebServiceConnector WSC = new UpdateUserProfileWebServiceConnector();	
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

		UpdateUserProfileWebServiceConnector uupwsc = new UpdateUserProfileWebServiceConnector();
		UpdateUserProfileWebServiceConnector.LogInfo logInfo = new UpdateUserProfileWebServiceConnector.LogInfo();
		UpdateUserProfileWebServiceConnector.modifyUserProfileResponse_element mupresp = new UpdateUserProfileWebServiceConnector.modifyUserProfileResponse_element();
		UpdateUserProfileWebServiceConnector.AllowFieldTruncationHeader_element afthe = new UpdateUserProfileWebServiceConnector.AllowFieldTruncationHeader_element();
		UpdateUserProfileWebServiceConnector.DebuggingHeader_element debhea = new UpdateUserProfileWebServiceConnector.DebuggingHeader_element();
		UpdateUserProfileWebServiceConnector.CallOptions_element calloti = new UpdateUserProfileWebServiceConnector.CallOptions_element();
		UpdateUserProfileWebServiceConnector.SessionHeader_element seessh = new UpdateUserProfileWebServiceConnector.SessionHeader_element();
		UpdateUserProfileWebServiceConnector.modifyUserProfile_element muprof = new UpdateUserProfileWebServiceConnector.modifyUserProfile_element();
		UpdateUserProfileWebServiceConnector.DebuggingInfo_element debhe = new UpdateUserProfileWebServiceConnector.DebuggingInfo_element();

		//partnerSoapSforceCom.LoginResult 
		//loginResult = sp.login('ggackiere@esn1.dev', 'yrogerg357+1');        
		UpdateUserProfileWebServiceConnector.UpdateUserProfileWebService ws = new UpdateUserProfileWebServiceConnector.UpdateUserProfileWebService();
		//ws.SessionHeader = new UpdateUserProfileWebServiceConnector.SessionHeader_element();
		//ws.SessionHeader.sessionId = UserInfo.getSessionId();
		//ws.SessionHeader.sessionId = loginResult.sessionId;  

		ws.modifyUserProfile(testUser.Id);

		uir = sp.getUserInfo();
		gstr = sp.getServerTimestamp();
		lr = sp.login(testUser.username, 'pwd');
		sp.logout();
	}
}