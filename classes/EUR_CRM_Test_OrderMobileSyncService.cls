/**
    *  Unit test for checking triggers and service
    *  for updating order status on sync operation 
    *  from mobile
	*
    *  @author:  Nedashkisvkyi Oleksandr - Customertimes Corp.
    *  @created: 07.07.17
    *  @version: 1.0
 */
@isTest
private class EUR_CRM_Test_OrderMobileSyncService {
 
    @isTest
    private static void verifySyncingOrdersInserting(){
       
        EUR_CRM_Account__c acc = (EUR_CRM_Account__c)EUR_CRM_TestDataFactory.createSObject(new EUR_CRM_Account__c(),true);
        EUR_CRM_Sales_Order__c  salesOrder = (EUR_CRM_Sales_Order__c ) EUR_CRM_TestDataFactory.createSObject(new EUR_CRM_Sales_Order__c (
            EUR_CRM_Account__c = acc.Id,
            EUR_CRM_IsMobile__c  = true,
            EUR_CRM_Status__c = EUR_CRM_OrderMobileSyncService.ORDER_SYNC_STATUS,
            EUR_CRM_NumberOfLines__c = 1
        ), true);
        
        Test.startTest();
        EUR_CRM_DeliveryItem__c  deliverylineitem = (EUR_CRM_DeliveryItem__c ) EUR_CRM_TestDataFactory.createSObject(new EUR_CRM_DeliveryItem__c (EUR_CRM_OrderID__c = salesOrder.Id), true);
        Test.stopTest();
        
        System.assertEquals(EUR_CRM_OrderMobileSyncService.ORDER_VALIDATE_STATUS, [SELECT EUR_CRM_Status__c FROM EUR_CRM_Sales_Order__c WHERE Id = :salesOrder.Id].EUR_CRM_Status__c);
       
    }

    @IsTest
    private static void EUR_CRM_DeliveryItemTriggerTest() {
        EUR_CRM_Account__c acc = (EUR_CRM_Account__c)EUR_CRM_TestDataFactory.createSObject(new EUR_CRM_Account__c(),true);
        EUR_CRM_Sales_Order__c  salesOrder = (EUR_CRM_Sales_Order__c ) EUR_CRM_TestDataFactory.createSObject(new EUR_CRM_Sales_Order__c (
            EUR_CRM_Account__c = acc.Id,
            EUR_CRM_IsMobile__c  = true,
            EUR_CRM_Status__c = EUR_CRM_OrderMobileSyncService.ORDER_SYNC_STATUS,
            EUR_CRM_NumberOfLines__c = 1
        ), true);

        Test.startTest();
        EUR_CRM_DeliveryItem__c  deliverylineitem = (EUR_CRM_DeliveryItem__c ) EUR_CRM_TestDataFactory.createSObject(new EUR_CRM_DeliveryItem__c (EUR_CRM_OrderID__c = salesOrder.Id), true);

        EUR_CRM_DeliveryItem__c deliveryItem = new EUR_CRM_DeliveryItem__c(Id = deliverylineitem.Id);
        deliveryItem.EUR_CRM_PaymentDate__c = Date.today();

        update deliveryItem;

        delete deliveryItem;
        Test.stopTest();
    }
}