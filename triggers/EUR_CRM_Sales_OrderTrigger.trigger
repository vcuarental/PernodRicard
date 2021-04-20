trigger EUR_CRM_Sales_OrderTrigger on EUR_CRM_Sales_Order__c (after insert, after update) {
    if (Trigger.isAfter) {
        if(Trigger.isInsert){
            EUR_CRM_OrderConfirmationService.sendOrderConfirmations(Trigger.new, null);
            EUR_CRM_OrderMobileSyncService.verifySyncingOrders(Trigger.new, String.valueOf(Trigger.new.getSObjectType()));            
        } else if (Trigger.isUpdate){
            EUR_CRM_OrderConfirmationService.sendOrderConfirmations(Trigger.new, Trigger.oldMap);
            EUR_CRM_OrderMobileSyncService.verifySyncingOrders(Trigger.new, String.valueOf(Trigger.new.getSObjectType()));
        }
    }
}