@isTest
public class EUR_CRM_TestSalesRepOrderAssignManager {
	
    public static testmethod void testSalesRepOrderAssignManager() {
        RecordType salesRepOrderRecordType = [SELECT Id FROM RecordType WHERE sObjectType = 'EUR_CRM_SalesRep_Order__c' and DeveloperName = 'EUR_DK_Free_Goods_Order_to_SR_Stock'];
        RecordType salesRepOrderItemRecordType = [SELECT Id FROM RecordType WHERE sObjectType = 'EUR_CRM_SalesRep_Order_Items__c' and DeveloperName = 'EUR_DK_Free_Goods_Order_Item'];
        RecordType stockRecordType = [SELECT Id FROM RecordType WHERE sObjectType = 'EUR_CRM_Stock__c' and DeveloperName = 'EUR_DK_Stock'];
        RecordType stockItemRecordType = [SELECT Id FROM RecordType WHERE sObjectType = 'EUR_CRM_Stock_Item__c' and DeveloperName = 'EUR_DK_Stock_Item'];
        
		EUR_CRM_Apex_Configuration__c runningNumber = new EUR_CRM_Apex_Configuration__c();
        runningNumber.EUR_CRM_Prefix__c = 'Testing';
        runningNumber.EUR_CRM_Running_Number_Length__c = 5;
        runningNumber.EUR_CRM_Running_Number__c = 1;
        runningNumber.EUR_CRM_Module__c = 'EUR_CRM_SRO_Running_Number';
        runningNumber.EUR_CRM_Country_Code__c = 'DK';
        insert runningNumber;
        
        EUR_CRM_SKU__c sku = EUR_CRM_DK_TestClassHelper.createSKU('Testing', '1234', 'EUR_DK_SKU');
        
        EUR_CRM_Stock__c stock = new EUR_CRM_Stock__c();
        stock.RecordTypeId = stockRecordType.Id;
        insert stock;
        
        EUR_CRM_Stock_Item__c stockItem = new EUR_CRM_Stock_Item__c();
        stockItem.EUR_CRM_Stock__c = stock.Id;
        stockItem.EUR_CRM_SKU__c = sku.Id;
        stockItem.RecordTypeId = stockItemRecordType.Id;
        insert stockItem;
                
        EUR_CRM_SalesRep_Order__c salesRepOrder = new EUR_CRM_SalesRep_Order__c();
        salesRepOrder.RecordTypeId = salesRepOrderRecordType.Id;
        insert salesRepOrder;
        
        EUR_CRM_SalesRep_Order_Items__c salesRepOrderItem = new EUR_CRM_SalesRep_Order_Items__c();
        salesRepOrderItem.RecordTypeId = salesRepOrderItemRecordType.Id;
        salesRepOrderItem.EUR_CRM_SalesRep_Order__c = salesRepOrder.Id;
        salesRepOrderItem.EUR_CRM_Stock_Item__c = stockItem.Id;
        salesRepOrderItem.EUR_CRM_SKU__c = sku.Id;
		salesRepOrderItem.EUR_CRM_Quantity__c = 10;
        
        EUR_CRM_SalesRep_Order_Items__c salesRepOrderItem2 = new EUR_CRM_SalesRep_Order_Items__c();
        salesRepOrderItem2.RecordTypeId = salesRepOrderItemRecordType.Id;
        salesRepOrderItem2.EUR_CRM_SalesRep_Order__c = salesRepOrder.Id;
        salesRepOrderItem2.EUR_CRM_SKU__c = sku.Id;
		salesRepOrderItem2.EUR_CRM_Quantity__c = 10;
        
        List<EUR_CRM_SalesRep_Order_Items__c> salesRepOrderItemList = new List<EUR_CRM_SalesRep_Order_Items__c>();
        salesRepOrderItemList.add(salesRepOrderItem);
        salesRepOrderItemList.add(salesRepOrderItem2);
        insert salesRepOrderItemList;
        
        salesRepOrder.EUR_CRM_Order_Status__c = 'Finished';
        update salesRepOrder;
    }
    
}