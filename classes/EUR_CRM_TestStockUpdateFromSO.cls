@isTest
public class EUR_CRM_TestStockUpdateFromSO {

    public static testmethod void testStockUpdateFromSO() {
        RecordType salesOrderRecordType = [SELECT Id FROM RecordType WHERE sObjectType = 'EUR_CRM_Sales_Order__c' and DeveloperName = 'EUR_DK_Free_Goods_Order_from_SR_Stock'];
        RecordType salesOrderItemRecordType = [SELECT Id FROM RecordType WHERE sObjectType = 'EUR_CRM_Sales_Order_Items__c' and DeveloperName = 'EUR_DK_Free_Goods_Order_from_SR_Stock'];
        RecordType stockRecordType = [SELECT Id FROM RecordType WHERE sObjectType = 'EUR_CRM_Stock__c' and DeveloperName = 'EUR_DK_Stock'];
        RecordType stockItemRecordType = [SELECT Id FROM RecordType WHERE sObjectType = 'EUR_CRM_Stock_Item__c' and DeveloperName = 'EUR_DK_Stock_Item'];
        RecordType accountRecordType = [SELECT Id FROM RecordType Where sObjectType = 'EUR_CRM_Account__c' and DeveloperName = 'EUR_DK_On_Trade' LIMIT 1];
        
        EUR_CRM_Apex_Configuration__c runningNumber = new EUR_CRM_Apex_Configuration__c();
        runningNumber.EUR_CRM_Prefix__c = 'Testing';
        runningNumber.EUR_CRM_Running_Number_Length__c = 5;
        runningNumber.EUR_CRM_Running_Number__c = 1;
        runningNumber.EUR_CRM_Module__c = 'EUR_CRM_Running_Number';
        runningNumber.EUR_CRM_Country_Code__c = 'DK';
        insert runningNumber;
        
        EUR_CRM_Account__c acc = new EUR_CRM_Account__c();
        acc.recordTypeId = accountRecordType.Id;
        acc.EUR_CRM_Postal_Code__c = '112233';
        insert acc;
        
        EUR_CRM_SKU__c sku = EUR_CRM_DK_TestClassHelper.createSKU('Testing', '1234', 'EUR_DK_SKU');
        
        EUR_CRM_Stock__c stock = new EUR_CRM_Stock__c();
        stock.RecordTypeId = stockRecordType.Id;
        insert stock;
        
        EUR_CRM_Stock_Item__c stockItem = new EUR_CRM_Stock_Item__c();
        stockItem.EUR_CRM_Stock__c = stock.Id;
        stockItem.EUR_CRM_SKU__c = sku.Id;
        stockItem.RecordTypeId = stockItemRecordType.Id;
        insert stockItem;
        
        EUR_CRM_Sales_Order__c salesOrder = new EUR_CRM_Sales_Order__c();
        salesOrder.RecordTypeId = salesOrderRecordType.Id;
        salesOrder.EUR_CRM_Account__c = acc.Id;
        insert salesOrder;
        
        EUR_CRM_Sales_Order_Items__c salesOrderItem = new EUR_CRM_Sales_Order_Items__c();
        salesOrderItem.RecordTypeId = salesOrderItemRecordType.Id;
        salesOrderItem.EUR_CRM_Sales_Order__c = salesOrder.Id;
        salesOrderItem.EUR_CRM_SKU__c = sku.Id;
        salesOrderItem.EUR_CRM_Stock_Item__c = stockItem.Id;
        salesOrderItem.EUR_CRM_Quantity__c = 10;
        
        EUR_CRM_Sales_Order_Items__c salesOrderItem2 = new EUR_CRM_Sales_Order_Items__c();
        salesOrderItem2.RecordTypeId = salesOrderItemRecordType.Id;
        salesOrderItem2.EUR_CRM_Sales_Order__c = salesOrder.Id;
        salesOrderItem2.EUR_CRM_SKU__c = sku.Id;
        salesOrderItem2.EUR_CRM_Quantity__c = 10;
        
        List<EUR_CRM_Sales_Order_Items__c> salesOrderItemList = new List<EUR_CRM_Sales_Order_Items__c>();
        salesOrderItemList.add(salesOrderItem);
        salesOrderItemList.add(salesOrderItem2);
        insert salesOrderItemList;
        
        salesOrder.EUR_CRM_Order_Status__c = 'Finished';
        update salesOrder;
        
    }
    
}