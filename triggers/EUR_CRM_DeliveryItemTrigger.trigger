trigger EUR_CRM_DeliveryItemTrigger on EUR_CRM_DeliveryItem__c (after insert, after update, after delete) {
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            EUR_CRM_OrderMobileSyncService.verifySyncingOrders(Trigger.new, String.valueOf(Trigger.new.getSObjectType()));
        } else if(Trigger.isUpdate){
            EUR_CRM_OrderMobileSyncService.verifySyncingOrders(Trigger.new, String.valueOf(Trigger.new.getSObjectType()));
        } else if (Trigger.isDelete){
            EUR_CRM_OrderMobileSyncService.verifySyncingOrders(Trigger.old, String.valueOf(Trigger.old.getSObjectType()));
        }
    }
}