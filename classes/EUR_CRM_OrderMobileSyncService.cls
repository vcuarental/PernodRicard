/**
    *  Service for updating order status
    *  depending on whether all delivery line
    *  items have been synced
    *
    *  @author:  Nedashkisvkyi Oleksandr - Customertimes Corp.
    *  @created: 07.07.17
    *  @version: 1.0
 */
public with sharing class EUR_CRM_OrderMobileSyncService {
    
    public static final String ORDER_SYNC_STATUS = 'Waiting for sync';
    public static final String ORDER_VALIDATE_STATUS = 'Instant validation';
    
    private static final Map<String, List<String>> objectsOrderIdFieldsMap = new Map<String, List<String>> {
        String.valueOf(EUR_CRM_Sales_Order__c.sObjectType)  => new List<String> { 'Id' },
        String.valueOf(EUR_CRM_DeliveryItem__c.sObjectType) => new List<String> { String.valueOf(EUR_CRM_DeliveryItem__c.EUR_CRM_OrderID__c) }
    };

    public static void verifySyncingOrders(List<SObject> items, String objectType) {
        checkOrderSyncingStatus(retrieveOrderIds(items, objectType));
    }

    private static Set<String> retrieveOrderIds(List<SObject> items, String objectType) {
        Set<String> orderIds = new Set<String>();
        for(SObject item : items) {
            if(objectsOrderIdFieldsMap.containsKey(objectType)) {
                List<String> fields = objectsOrderIdFieldsMap.get(objectType);
                for(String field : fields) {
                    if(item.get(field) != null){
                        orderIds.add(String.valueOf(item.get(field)));
                    }
                }
            }
        }
        return orderIds;
    }

    private static void checkOrderSyncingStatus(Set<String> orderIds) {
        List<EUR_CRM_Sales_Order__c> ordersToUpdate = new List<EUR_CRM_Sales_Order__c>();
        try {
            List<EUR_CRM_Sales_Order__c> orders = [
                SELECT Id
                     , EUR_CRM_Status__c
                     , EUR_CRM_NumberOfLines__c
                     , RecordType.DeveloperName
                     , (
                         SELECT Id
                         FROM Delivery_line_items__r
                       )
                FROM EUR_CRM_Sales_Order__c
                WHERE Id IN :orderIds
                    AND EUR_CRM_IsMobile__c = true
                    AND EUR_CRM_Status__c = :ORDER_SYNC_STATUS
            ];
            for(EUR_CRM_Sales_Order__c order: orders) {
                Integer numberOfLines = 0;
                numberOfLines = order.Delivery_line_items__r.size();
                
                if(order.EUR_CRM_NumberOfLines__c == numberOfLines && order.EUR_CRM_Status__c == ORDER_SYNC_STATUS) {
                    order.EUR_CRM_Status__c = ORDER_VALIDATE_STATUS;
                    ordersToUpdate.add(order);
                }
            }
            update ordersToUpdate;
        }
        catch (Exception e) {
            System.debug(e.getMessage());
        }
    }


}