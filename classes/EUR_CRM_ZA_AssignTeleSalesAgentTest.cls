@isTest
public with sharing class EUR_CRM_ZA_AssignTeleSalesAgentTest {
	
	public static EUR_CRM_Account__c euaccount = new EUR_CRM_Account__c();
	public static EUR_CRM_Sales_Order__c salesOrder = new EUR_CRM_Sales_Order__c();
	
    @testSetup
    public static void testSetup() {
        
        
        Profile p = [SELECT Id FROM Profile WHERE Name ='EUR ZA Standard On Trade User']; 
        UserRole r = [select id from UserRole where Developername ='EMEA'];
        eurSysUser = new User(Alias = 'standt', Email='userEmail1234aoke@test.com', userroleid=r.id,
        EmailEncodingKey='UTF-8', LastName='userEmail1234aokelastName', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='userEmail1234aoke@test.com');
        insert eurSysUser;
        
        eurSysUser2 = new User(Alias = 'standt2', Email='userEmail1234aoke2@test.com', userroleid=r.id,
        EmailEncodingKey='UTF-8', LastName='userEmail1234aokelastName', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='userEmail1234aoke2@test.com', EUR_CRM_Telesales_Agent__c=eurSysUser.Id);
        insert eurSysUser2;
        
        eurSysUser3 = new User(Alias = 'standt3', Email='userEmail1234aoke3@test.com', userroleid=r.id,
        EmailEncodingKey='UTF-8', LastName='userEmail1234aokelastName', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='userEmail1234aoke3@test.com');
        insert eurSysUser3;
        
        
    }
    
    public static void loadUser() {
        eurSysUser = [SELECT Id FROM User where Alias = 'standt'];
        eurSysUser2 = [SELECT Id FROM User WHERE Alias = 'standt2'];
        eurSysUser3 = [SELECT Id FROM User WHERE Alias = 'standt3'];
    }
	public static User eurSysUser;
	public static User eurSysUser2;
	public static User eurSysUser3;
    
  
    public static void dataInsert1(){
    	
    	euaccount = EUR_CRM_ZA_TestClassHelper.createEUAccount(1,'Test EU ACCOUNT', 'EUR_ZA_On_Trade_Indirect').get(0);
        insert euaccount;
        system.assertNotEquals(euaccount, null);
               
    }
   	@future
    public static void dataInsert2(){
    	
    	euaccount = EUR_CRM_ZA_TestClassHelper.createEUAccount(1,'Test EU ACCOUNT', 'EUR_ZA_On_Trade_Indirect').get(0);
        insert euaccount;
        system.assertNotEquals(euaccount, null);
               
        salesOrder = EUR_CRM_ZA_TestClassHelper.createSalesOrder(1,euaccount).get(0);
    	insert salesOrder;
    	system.assertNotEquals(salesOrder, null);
    }
    
    static testMethod void test1(){
        loadUser();
        EUR_CRM_Apex_Configuration__c configApex = new EUR_CRM_Apex_Configuration__c();
	        configApex.EUR_CRM_Module__c = 'EUR_CRM_Running_Number';
	        configApex.EUR_CRM_Prefix__c = 'ZA-SO-';
	        configApex.EUR_CRM_Running_Number_Length__c = 10;
	        configApex.EUR_CRM_Running_Number__c = 0;
	        configApex.EUR_CRM_Country_Code__c = 'ZA';
	        insert configApex;
        System.runAs(eurSysUser2){
            Test.startTest();
            dataInsert1();
            
			salesOrder = EUR_CRM_ZA_TestClassHelper.createSalesOrder(1,euaccount).get(0);
        	insert salesOrder;
        	system.assertNotEquals(salesOrder, null);
           	
            Test.stopTest();

        }
    }
    
    static testMethod void test2(){
        loadUser();
        EUR_CRM_Apex_Configuration__c configApex = new EUR_CRM_Apex_Configuration__c();
	        configApex.EUR_CRM_Module__c = 'EUR_CRM_Running_Number';
	        configApex.EUR_CRM_Prefix__c = 'ZA-SO-';
	        configApex.EUR_CRM_Running_Number_Length__c = 10;
	        configApex.EUR_CRM_Running_Number__c = 0;
	        configApex.EUR_CRM_Country_Code__c = 'ZA';
	        insert configApex;
        //System.runAs(eurSysUser3){
        	
        	
        //}
       
        System.runAs(eurSysUser2){
            Test.startTest();
            dataInsert2();	
            eurSysUser2.EUR_CRM_Telesales_Agent__c = null;
        	update eurSysUser2;
            Test.stopTest();
        }
        
        
       
    }
}