/*
*    Description    :    Apex test class for EUR_CRM_SO_XmlWriter
*
*    Version    Author    Date        Description
*    1.0        Sid       12/31/2015  Initial Draft
*/

@isTest
public class EUR_CRM_SO_XmlWriterTest {

    //Test method to check if the xml is being generated for the given Salesorder
    public testMethod static void testGenerateXml(){
    
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
        insert salesOrderItemList;
        
        test.startTest();
            EUR_CRM_SO_XmlWriter oEUR_CRM_SO_XmlWriter = new EUR_CRM_SO_XmlWriter();
            String strXmlString = oEUR_CRM_SO_XmlWriter.generateXmlForSalesOrder(salesOrderList[0].Id);
            System.assertNotEquals(strXmlString, NULL);
        test.stopTest();
    }
}