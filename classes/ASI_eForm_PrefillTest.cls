@isTest
/**********************************************************************************
 * Name : ASI_eForm_PrefillTest
 * Revision History:
 * 1. 2018-02-21 - [WL 1.0] Add coverage for Pre-Trip prefill code
 **********************************************************************************/
private class ASI_eForm_PrefillTest
{
    @isTest
    public static void testPreFillITChangeRequestController()
    {
        User user = ASI_eForm_TestClassHelper.createUser();
        User userRun = ASI_eForm_TestClassHelper.createUser('abscacom');
        Map<String,User> userMap = new Map<String,User>();
        
        userMap.put('owner',user);
        
        ASI_eForm_TestClassHelper.createRunningNumbers();
        
        ASI_eForm_TestClassHelper.createPrefillCustomSetting();
        ASI_eForm_TestClassHelper.createRouteTypeDetails(userMap);
        
        ASI_eForm_IT_Change_Request__c  itChangeRequest =
            ASI_eForm_TestClassHelper.createITChangeRequest(userMap);
        System.runAs(userRun) {
            ApexPages.StandardController standardController = new ApexPages.StandardController(itChangeRequest);
        
            ASI_eForm_PreFillITChangeReqController prefillITChangeReq =
                new ASI_eForm_PreFillITChangeReqController(standardController);    
        
            prefillITChangeReq.preFill();    
        }
    }
    
    @isTest
    public static void testPreFillPreTripController()
    {
        User user = ASI_eForm_TestClassHelper.createUser();
        Map<String,User> userMap = new Map<String,User>();
        User userRun = ASI_eForm_TestClassHelper.createUser('abscacom');        
        userMap.put('owner',user);
        
        ASI_eForm_TestClassHelper.createPrefillCustomSetting();
        ASI_eForm_TestClassHelper.createRouteTypeDetails(userMap);
        
        ASI_eForm_Pre_Trip_Approval__c  preTripApproval =
            ASI_eForm_TestClassHelper.createPreTripApproval(userMap);
        System.runAs(userRun) {        
        ApexPages.StandardController standardController = new ApexPages.StandardController(preTripApproval);
        
        ASI_eForm_PreFillPreTripController preTripController =
            new ASI_eForm_PreFillPreTripController(standardController);    
        
        preTripController.preFill();   
        } 
    }
    
	/*[WL 1.0] BEGIN*/
	@isTest
	public static void test_ASI_eForm_PreFillApproversHandler(){
		User u = createUserPreTrip('Eddie Lian Wah', 'LEE', 'eddie.lee@pernod-ricard.com.asisb6conf.testclass');
		String s = ASI_eForm_PreFillApproversHandler.parseInvalidStringNames(u);
	}
	
	@isTest
	public static void test_prePopulateApprovers(){
		User u = createUserPreTrip('Eddie Lian Wah', 'LEE', 'eddie.lee@pernod-ricard.com.asisb6conf.testclass');
		
		ASI_eForm_Route_Type__c rt = new ASI_eForm_Route_Type__c(ASI_eForm_Company__c = 'Pernod Ricard Singapore', ASI_eForm_Department__c = 'Finance & Operations', ASI_eForm_Form_Type__c = 'IT Change Request', 
			recordTypeId = Global_RecordTypeCache.getRtId('ASI_eForm_Route_Type__cASI_eForm_HK_Route_Type'), ASI_eForm_Form_Record_Type__c = 'IT Service Request (HK)');
		
		insert rt;
		
		ASI_eForm_Route_Rule_Details__c rd = new ASI_eForm_Route_Rule_Details__c(ASI_eForm_Route_Type__c = rt.Id, ASI_eForm_Approver__c = u.id);
		insert rd;
		
		ASI_eForm_PreFillApproversHandler handler = new ASI_eForm_PreFillApproversHandler('IT Service Request (HK)','IT Change Request', u);
		handler.processPreTripApprovalApprovers();
		
		handler.processItProcServiceRequestApprovers();
		handler.processUserIdRequestApprovers();
		
	}	
	
	public static User createUserPreTrip(String strFirstName, String strLastName, String strUserName)
    {
                    
        Profile profile = [SELECT Id 
                         FROM profile WHERE name = 'System Administrator'];   
         
		Id currentUserID = UserInfo.getUserId();
		
        User normalUser = new User(
        username = strUserName,
        Email = 'test1234nsd@test123.com',
        lastName = strLastName,
        firstName = strFirstName,
		companyName = 'Pernod Ricard Singapore',
		ASI_MFM_Country__c = 'SG',
		Department = 'Finance & Operations',
		ManagerId = currentUserID,
        alias  = 'nrmUsr12',
        languagelocalekey = 'en_US',
        localesidkey = 'en_US',
        emailEncodingKey = 'UTF-8',
        timeZoneSidKey = 'America/Los_Angeles',        
        profileId = profile.id,
        ASI_eForm_Indicator__c = '\'CN Change Authorizer\'Project Implementer\''
        );
        
        insert normalUser;           
        
		User u = [select Name, FirstName, LastName, Department, ASI_MFM_Country__c, CompanyName, ManagerId from User where Id = :normalUser.Id limit 1];
		
        return u;        
    }
	/*[WL 1.0] BEGIN*/
	
    @isTest
    public static void testPreFillITProcSrvcReqController()
    {
        User user = ASI_eForm_TestClassHelper.createUser();
        Map<String,User> userMap = new Map<String,User>();
        User userRun = ASI_eForm_TestClassHelper.createUser('abscacom');
        userMap.put('owner',user);
        
        ASI_eForm_TestClassHelper.createPrefillCustomSetting();
        ASI_eForm_TestClassHelper.createRouteTypeDetails(userMap);
        
        ASI_eForm_IT_Procurement_Service_Request__c  itpsr =
            ASI_eForm_TestClassHelper.createITPSRServiceRequest(userMap);
        System.runAs(userRun) {    
        PageReference preFillITProcSrvcReqPage = Page.ASI_eForm_PreFillITProcSrvcReqPage;
        Map<String, String> pageParams = preFillITProcSrvcReqPage.getParameters();
        pageParams.put('RecordType', itpsr.RecordTypeId);
      
        Test.setCurrentPageReference(preFillITProcSrvcReqPage);
        
        ApexPages.StandardController standardController = new ApexPages.StandardController(itpsr);
        
        ASI_eForm_PreFillITProcSrvcReqController preFillITProcSrvcReqController =
            new ASI_eForm_PreFillITProcSrvcReqController(standardController);    
        
        preFillITProcSrvcReqController.preFill();   
        } 
    }
    
    @isTest
    public static void testPreFillUserIDReqController()
    {
        User user = ASI_eForm_TestClassHelper.createUser();
        Map<String,User> userMap = new Map<String,User>();
        User userRun = ASI_eForm_TestClassHelper.createUser('abscacom');
        userMap.put('owner',user);
        
        ASI_eForm_TestClassHelper.createPrefillCustomSetting();
        ASI_eForm_TestClassHelper.createRouteTypeDetails(userMap);
        
        ASI_eForm_User_ID_Request__c  userIDReq =
            ASI_eForm_TestClassHelper.createUserIDRequest(userMap);
            
        PageReference preFillUserReqPage = Page.ASI_eForm_PreFillUserIDRequestsPage;
        Map<String, String> pageParams = preFillUserReqPage.getParameters();
        pageParams.put('RecordType', userIDReq.RecordTypeId);
      System.runAs(userRun) {  
        Test.setCurrentPageReference(preFillUserReqPage);
        
        ApexPages.StandardController standardController = new ApexPages.StandardController(userIDReq);
        
        ASI_eForm_PreFillUserIDReqController preFillUserIDReqController =
            new ASI_eForm_PreFillUserIDReqController(standardController);    
        
        preFillUserIDReqController.preFill();   
        } 
    }
    
}