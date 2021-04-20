public class ASI_GiftBox_GoodReceiptTriggerClass {
    public static void routineAfterInsert(list<ASI_GiftBox_Good_Receipt__c> trigger_new) {
        for (ASI_GiftBox_Good_Receipt__c r : trigger_new){
            ASI_GiftBox_Order_Item__c order_item = [select ASI_GiftBox_Order_Item_Id__c from ASI_GiftBox_Order_Item__c where id = :r.ASI_GiftBox_Order_Item_Id__c LIMIT 1];
                        
            List<ASI_GiftBox_Inventory_Detail__c> inventoryDetails = [select id, ASI_GiftBox_Item_Received_Quantity__c from ASI_GiftBox_Inventory_Detail__c 
                where ASI_GiftBox_Item_Id__c = :order_item.ASI_GiftBox_Order_Item_Id__c and ASI_GiftBox_Item_Warehouse__c = :r.ASI_GiftBox_Receipt_Warehouse__c];
                
            if(inventoryDetails.size() == 0){ // new rec
                ASI_GiftBox_Inventory_Detail__c newInventoryDetail = new ASI_GiftBox_Inventory_Detail__c(ASI_GiftBox_Item_Requested_Quantity__c= 0, 
                    ASI_GiftBox_Item_Id__c = order_item.ASI_GiftBox_Order_Item_Id__c, ASI_GiftBox_Item_Received_Quantity__c = r.ASI_GiftBox_Receipt_Quantity__c, 
                        ASI_GiftBox_Item_Warehouse__c = r.ASI_GiftBox_Receipt_Warehouse__c, recordtypeID = Global_RecordTypeCache.getRtId('ASI_GiftBox_Inventory_Detail__cASI_GiftBox_VN_Item_Detail'));
                        
                insert newInventoryDetail;                               
            } 
            else if (inventoryDetails.size() == 1) { //rec existed
                inventoryDetails[0].ASI_GiftBox_Item_Received_Quantity__c += r.ASI_GiftBox_Receipt_Quantity__c;
                update inventoryDetails[0];
            }
            else {
                r.addError('Duplicate Good Receipt records was found for the same gift box and same warehouse');
            }
        }
    }
}