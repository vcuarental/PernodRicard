@isTest
private class ASI_HK_CRM_SalesOrderRequestSubmitTest {

    static map<string, id> getRecordTypeId(string object_type) {
        map<string, id> rt_map = new map<string, id>();
        for (recordType rt:[select id, DeveloperName from recordType where SobjectType = :object_type]) {
            rt_map.put(rt.DeveloperName, rt.id);            
        }
        return rt_map;
    }
      
    static testMethod void test_basic() {
        Test.setMock(WebServiceMock.class, new ASI_HK_CRM_SalesOrderMock());
        ASI_HK_CRM_TestUtils.initSOEssentialSettings();
        ASI_HK_CRM_TestUtils.CommonData cmData = new ASI_HK_CRM_TestUtils.CommonData();
        ASI_HK_CRM_TestUtils.assignCreditAccountData(cmData, 3, 3);
        ASI_HK_CRM_TestUtils.assignSalesOrderData(cmData, 3, 3);
        Test.startTest();
        ASI_HK_CRM_Sales_Order__c so = cmData.so;
        so.ASI_HK_CRM_Order_Status_Name__c = ASI_HK_CRM_SalesOrderRequestSubmit.SUBMIT_STATUS;
        update so;
        Test.stopTest();
    }
    
    static testMethod void test_main() {
        ASI_HK_CRM_TestUtils.initSOEssentialSettings();
        ASI_HK_CRM_TestUtils.initSOWSSettings();
        ASI_HK_CRM_TestUtils.CommonData cmData = new ASI_HK_CRM_TestUtils.CommonData();
        ASI_HK_CRM_TestUtils.assignCreditAccountData(cmData, 3, 3);
        ASI_HK_CRM_TestUtils.assignSalesOrderData(cmData, 3, 3);
        ASI_HK_CRM_Sales_Order__c so = cmData.so;
        
        Test.startTest();
        Test.setMock(WebServiceMock.class, new ASI_HK_CRM_SalesOrderMock());
        
        ASI_HK_CRM_SalesOrderRequestSubmit.submitSO(new Set<ID> {so.Id});
        
        Test.stopTest();
    }
    
    static testMethod void test_requestSubmit() {      
        Test.setMock(WebServiceMock.class, new ASI_HK_CRM_SalesOrderMock());
        ASI_HK_CRM_TestUtils.initSOEssentialSettings();
        ASI_HK_CRM_TestUtils.CommonData cmData = new ASI_HK_CRM_TestUtils.CommonData();
        ASI_HK_CRM_TestUtils.assignCreditAccountData(cmData, 3, 3);
        ASI_HK_CRM_TestUtils.assignSalesOrderData(cmData, 3, 3);
        ASI_HK_CRM_Sales_Order__c so = cmData.so;
        Test.startTest();
        so.ASI_HK_CRM_Order_Status_Name__c = 'Draft';
        so.ASI_HK_CRM_Next_SO_Approver__c = null;
        update so;
        so.ASI_HK_CRM_Order_Status_Name__c = 'ASI_HK_CRM_SalesOrderRequestSubmit.SUBMIT_STATUS';
        update so;
        
        ASI_HK_CRM_SalesOrderRequestSubmit.sendAlertEmail(so, 'TEST', 'TEST');
        ASI_HK_CRM_SalesOrderRequestSubmit.sendHoldCodeAlertEmail(so, 'TEST');
        Test.stopTest();
    }
    

    static testMethod void test_requestSubmit2() {      
        Test.setMock(WebServiceMock.class, new ASI_HK_CRM_SalesOrderMock());
        ASI_HK_CRM_TestUtils.initSOEssentialSettings();
        ASI_HK_CRM_TestUtils.CommonData cmData = new ASI_HK_CRM_TestUtils.CommonData();
        ASI_HK_CRM_TestUtils.assignCreditAccountData(cmData, 3, 3);
        ASI_HK_CRM_TestUtils.assignSalesOrderData(cmData, 3, 3);
        ASI_HK_CRM_Sales_Order__c so = cmData.so;       
        
        //Added by Wilken to prevent Mixed DML Exception
        User DMLUser = [Select Id From User Where (Profile.Name = 'System Administrator' Or Profile.Name = 'System Administrator GDT') And IsActive = true Limit 1];
        User u = new User();    
        
        System.runAs(DMLUser) {
            u = new User(alias = 'test', email='userwithrole@roletest1.com', userroleid = UserInfo.getUserRoleId(),
                                    emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                                    localesidkey='en_US', profileid = UserInfo.getProfileId(),timezonesidkey='America/Los_Angeles',  
                                    username='userwithrole@test.int');
                                    
            insert u;
        }
        ASI_HK_CRM_AccountGenerator acctGen = new ASI_HK_CRM_AccountGenerator();
        map<string, id> rt_mapAcc = getRecordTypeId('Account');
        
        cmData.acctDAParent = acctGen.generateAccount(ASI_HK_CRM_AccountGenerator.RT_CASH);
        cmData.acctDAParent.ownerid=u.id;
        cmData.acctDAParent.ASI_KOR_Customer_Code__c='HK_0000';
        insert cmData.acctDAParent;
        
        List<ASI_HK_CRM_Running_Number__c> testRunningNumList = new List<ASI_HK_CRM_Running_Number__c>();
        
        ASI_HK_CRM_Running_Number__c runnNumTest = new ASI_HK_CRM_Running_Number__c();
        runnNumTest.ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 7;
        runnNumTest.ASI_HK_CRM_Running_Number__c = 2315;
        runnNumTest.ASI_HK_CRM_Format__c = 'SO-{YY}{000000}';
        runnNumTest.ASI_HK_CRM_Object_Name__c = 'ASI_LUX_Le_Cercle_Membership_Num';
        testRunningNumList.add(runnNumTest);
        
        ASI_HK_CRM_Running_Number__c runnNumTest2 = new ASI_HK_CRM_Running_Number__c();
        runnNumTest2.ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 2;
        runnNumTest2.ASI_HK_CRM_Object_Name__c = 'ASI_Luxury_Account_HK';
        testRunningNumList.add(runnNumTest2);
        
        Insert testRunningNumList;
        
		Test.startTest();
		
        Account testAcc = new Account();
        testAcc.recordTypeID = rt_mapAcc.get('ASI_Luxury_Account_HK_Second_Contact');
        testAcc.FirstName = 'testFirst';
        testAcc.LastName = 'testLast';
        testAcc.ASI_LUX_Gender__c = 'Male';
        testAcc.ASI_LUX_Preferred_Contact_Number__c = '12345678';
        testAcc.ASI_LUX_Preferred_Language_1__c = 'English';
        testAcc.ASI_HK_CRM_Grade__c = 'D';
        testAcc.ASI_LUX_Membership_Category__c = 'Affluent';
        testAcc.ASI_LUX_Le_Cercle_Member__c = false;
        testAcc.ownerid=u.id;
        
        Insert testAcc;
        
        
        so.ASI_HK_CRM_Order_Status_Name__c = 'Draft';
        so.ASI_HK_CRM_Customer_DA__c=testAcc.id;
        so.ASI_HK_CRM_Next_SO_Approver__c = null;
        update so;
        so.ASI_HK_CRM_Order_Status_Name__c = 'ASI_HK_CRM_SalesOrderRequestSubmit.SUBMIT_STATUS';
        update so;
        
        so.ASI_HK_CRM_Order_Status_Name__c = 'Hold Code Received';
        so.ASI_HK_CRM_Credit_Hold_Reason__c = 'M0';
        update so;
        Test.stopTest();
    }
    
}