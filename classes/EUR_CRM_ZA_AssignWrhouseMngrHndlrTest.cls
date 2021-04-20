@isTest
public with sharing class EUR_CRM_ZA_AssignWrhouseMngrHndlrTest {

	public static EUR_CRM_Account__c euaccount = new EUR_CRM_Account__c();
	public static EUR_CRM_Account__c euaccount2 = new EUR_CRM_Account__c();
	public static EUR_CRM_POSM_Order__c posmOrder = new EUR_CRM_POSM_Order__c();
	
	public static User eurSysUser;
    public static void setUser(){
        //Profile p = [SELECT Id FROM Profile WHERE Name ='EUR System Admin'];
        Profile p = [SELECT Id FROM Profile WHERE Name ='EUR ZA Standard On Trade User'];  
        UserRole r = [select id from UserRole where Developername ='EMEA'];
        eurSysUser = new User(Alias = 'standt', Email='userEmail1234aoke@test.com', userroleid=r.id,
        EmailEncodingKey='UTF-8', LastName='userEmail1234aokelastName', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='userEmail1234aoke@test.com');
        eurSysUser.Managerid = userinfo.getUserId();
        insert eurSysUser;

    }
    
    public static void dataInsert1(){

        euaccount = EUR_CRM_ZA_TestClassHelper.createEUAccount(1,'Test EU ACCOUNT', 'EUR_ZA_On_Trade_Direct').get(0);
        //euaccount.EUR_CRM_Event_Manager__c = Userinfo.getUserId();
        euaccount.EUR_CRM_Warehouse_Manager__c = Userinfo.getUserId();
        insert euaccount;
        system.assertNotEquals(euaccount, null);
        
    }
    
    public static void dataInsert2(){

        euaccount = EUR_CRM_ZA_TestClassHelper.createEUAccount(1,'Test EU ACCOUNT', 'EUR_ZA_On_Trade_Direct').get(0);
        euaccount.EUR_CRM_Warehouse_Manager__c = Userinfo.getUserId();
        insert euaccount;
        system.assertNotEquals(euaccount, null);
        
        posmOrder = EUR_CRM_ZA_TestClassHelper.createPOSMOrder(1,euaccount).get(0);
        posmOrder.EUR_CRM_Account__c = null;
        insert posmOrder;
        system.assertNotEquals(posmOrder, null);
        
    }
    
    static testMethod void test1(){
    	setUser();
        System.runAs(eurSysUser){
        	dataInsert1();
            test.startTest();
                posmOrder = EUR_CRM_ZA_TestClassHelper.createPOSMOrder(1,euaccount).get(0);
		        insert posmOrder;
		        system.assertNotEquals(posmOrder, null);

            test.stopTest();
        }
    }
    
    static testMethod void test2(){
    	setUser();
        System.runAs(eurSysUser){
        	dataInsert2();
            test.startTest();
                posmOrder.EUR_CRM_Account__c = euaccount.Id;
		        update posmOrder;

            test.stopTest();
        }
    }
}