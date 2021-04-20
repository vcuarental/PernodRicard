/*
*    Description    :    Apex test class for EUR_CRM_ZA_SalesOrderCallout
*                        Test class to check if the callout is being made 
*                        once the SalesOrderItem is created for a given SalesOrder
*
*    Version    Author    Date        Description
*    1.0        Sid       12/31/2015  Initial Draft
*/

@isTest
public with sharing class EUR_CRM_ZA_SalesOrderCalloutTest {

    static User eurZaUser;

    //Creating the context user
    static void setUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name= 'EUR ZA Standard On Trade User'];
        UserRole r = [select id from UserRole where Developername ='EMEA'];
        eurZaUser = new User(Alias = 'standt', Email='userEmail1234aoke@test.com', userroleid=r.id,
        EmailEncodingKey='UTF-8', LastName='userEmail1234aokelastName', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='userEmail1234aoke@SalesOrderCalloutTest.com');
        insert eurZaUser;
    }

    public static testMethod void testAfterUpdateSoCallout(){
        
        setUser();
        System.runAs(eurZaUser){
        
            EUR_CRM_Apex_Configuration__c configApex = new EUR_CRM_Apex_Configuration__c();
    	    configApex.EUR_CRM_Module__c = 'EUR_CRM_Running_Number';
	        configApex.EUR_CRM_Prefix__c = 'ZA-SO-';
	        configApex.EUR_CRM_Running_Number_Length__c = 10;
    	    configApex.EUR_CRM_Running_Number__c = 0;
	        configApex.EUR_CRM_Country_Code__c = 'ZA';
	        insert configApex;    
    
            //Create Test Data for Account
            List<EUR_CRM_Account__c> accountList = EUR_CRM_ZA_TestClassHelper.createEUAccount(1, 'testAccount', 'EUR_ZA_On_Trade_Direct');
            insert accountList;
    
            //Create Test data for Sales Order
            List<EUR_CRM_Sales_Order__c> salesOrderList = EUR_CRM_ZA_TestClassHelper.createSalesOrder(1, accountList[0]);
        
                for(EUR_CRM_Sales_Order__c objSo : salesOrderList){
                
                    objSo.EUR_CRM_Order_Date__c = Date.today();
                    objSo.EUR_CRM_Order_Status__c = 'testStatus';
                    objSo.EUR_CRM_Collection_Point__c = 'test';
                    objSo.EUR_CRM_No_of_Sales_Order_Items__c = 2;
                }
        
            insert salesOrderList;

            //Create SKU
            List<EUR_CRM_SKU__c> skuList = EUR_CRM_ZA_TestClassHelper.createSku(1);
            insert skuList;
        
            //Create Test data for Sales Order Item    
            List<EUR_CRM_Sales_Order_Items__c> salesOrderItemList = EUR_CRM_ZA_TestClassHelper.createSalesOrderItem(2);
            for(EUR_CRM_Sales_Order_Items__c oSoLineItem : salesOrderItemList){
                oSoLineItem.EUR_CRM_Sales_Order__c = salesOrderList[0].Id;
                oSoLineItem.EUR_CRM_SKU__c = skuList[0].Id;
            }
        
            test.startTest();
                insert salesOrderItemList;
            test.stopTest();            
        }
    }
}