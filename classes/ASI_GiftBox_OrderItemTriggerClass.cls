public class ASI_GiftBox_OrderItemTriggerClass {
    public static void routineBeforeInsert(list<ASI_GiftBox_Order_Item__c > trigger_new) {
        for (ASI_GiftBox_Order_Item__c i : trigger_new){
//Update Order Detail Name with MCF No. and Gift Box Name        
            List<ASI_GiftBox_Order_Header__c> headerList = [select Name from ASI_GiftBox_Order_Header__c where id = :i.ASI_GiftBox_Order_Id__c];
            List<ASI_GiftBox_Inventory_Master__c> masterList = [select Name from ASI_GiftBox_Inventory_Master__c where id = :i.ASI_GiftBox_Order_Item_Id__c];
            if (headerList.size() ==1 && masterList.size() == 1){
                i.Name = headerList.get(0).Name + '-' + masterList.get(0).Name;    
            }
        }
    }
}