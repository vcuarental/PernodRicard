public without sharing class ASI_GiftBox_TransferLogTriggerClass {
    public static void routineAfterInsert(list<ASI_GiftBox_Transfer_Log__c> trigger_new){
    
        for (ASI_GiftBox_Transfer_Log__c log:trigger_new){
            if (log.ASI_GiftBox_Status__c == 'Confirmed'){
                List<ASI_GiftBox_Inventory_Detail__c> invList = [select ASI_GiftBox_Item_Warehouse__c, ASI_GiftBox_Item_Available_Quantity__c, ASI_GiftBox_Item_Transfer_Quantity__c from ASI_GiftBox_Inventory_Detail__c 
                    where ASI_GiftBox_Item_Id__c = :log.ASI_GiftBox_Master__c];
                
                Boolean foundTransferFromWH = false;
                Boolean foundTransferToWH = false;
                
                for (ASI_GiftBox_Inventory_Detail__c inv:invList){
                    //Deduct quantity from Source Warehouse
                    if (log.ASI_GiftBox_Transfer_From__c == inv.ASI_GiftBox_Item_Warehouse__c){
                        if (inv.ASI_GiftBox_Item_Available_Quantity__c - log.ASI_GiftBox_Quantity__c < 0)
                            log.addError('Not enough Gift Box inventory in warehouse ' + inv.ASI_GiftBox_Item_Warehouse__c);
                            
                        if (inv.ASI_GiftBox_Item_Transfer_Quantity__c == null)
                            inv.ASI_GiftBox_Item_Transfer_Quantity__c = 0;
                            
                        inv.ASI_GiftBox_Item_Transfer_Quantity__c -= log.ASI_GiftBox_Quantity__c;
                        foundTransferFromWH = true;
                    }
                    //Add quantity to Destination Warehouse
                    else if (log.ASI_GiftBox_Transfer_To__c == inv.ASI_GiftBox_Item_Warehouse__c){
                        if (inv.ASI_GiftBox_Item_Transfer_Quantity__c == null)
                            inv.ASI_GiftBox_Item_Transfer_Quantity__c = 0;
                            
                        inv.ASI_GiftBox_Item_Transfer_Quantity__c += log.ASI_GiftBox_Quantity__c;
                        foundTransferToWH = true;
                    }
                }
                
                if (!foundTransferFromWH)
                    log.addError('Cannot find the Gift Box in ' + log.ASI_GiftBox_Transfer_From__c + ' warehouse, please check again');
                
                if (!foundTransferToWH){
                    ASI_GiftBox_Inventory_Detail__c insertInv = new ASI_GiftBox_Inventory_Detail__c(RecordTypeID = Global_RecordTypeCache.getRtId('ASI_GiftBox_Inventory_Detail__cASI_GiftBox_VN_Item_Detail'), ASI_GiftBox_Item_Id__c = log.ASI_GiftBox_Master__c,
                        ASI_GiftBox_Item_Warehouse__c = log.ASI_GiftBox_Transfer_To__c, ASI_GiftBox_Item_Received_Quantity__c = 0, ASI_GiftBox_Item_Requested_Quantity__c = 0, ASI_GiftBox_Item_Transfer_Quantity__c = log.ASI_GiftBox_Quantity__c);
                    
                    insert insertInv;
                    foundTransferToWH = true;
                }
                
                if (foundTransferFromWH && foundTransferToWH)
                    update invList;
            }
        }
    }
}