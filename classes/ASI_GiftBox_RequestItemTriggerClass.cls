public class ASI_GiftBox_RequestItemTriggerClass {
    public static void routineAfterUpsert(list<ASI_GiftBox_Request_Item__c> trigger_new, map<id, ASI_GiftBox_Request_Item__c> trigger_oldMap) { 
        Set<ID> gbMasterIDSet = new Set<ID>();
        Set<String> gbFiscalYearSet = new Set<String>();
        Set<String> gbRegionSet = new Set<String>();

        for (ASI_GiftBox_Request_Item__c i : trigger_new){
            gbMasterIDSet.add(i.ASI_GiftBox_Request_Item__c);
            gbFiscalYearSet.add(i.ASI_GiftBox_Fiscal_Year__c);
            gbRegionSet.add(i.ASI_GiftBox_Region__c);

            if (trigger_oldMap != null && trigger_oldMap.get(i.id) != null){
                gbMasterIDSet.add(trigger_oldMap.get(i.id).ASI_GiftBox_Request_Item__c);
                gbFiscalYearSet.add(trigger_oldMap.get(i.id).ASI_GiftBox_Fiscal_Year__c);
                gbRegionSet.add(trigger_oldMap.get(i.id).ASI_GiftBox_Region__c);
            }
        }

        if (gbMasterIDSet.size() > 0){

            List<ASI_GiftBox_Budget__c> budgetList = new List<ASI_GiftBox_Budget__c>([select ASI_GiftBox_Master__c,ASI_GiftBox_Fiscal_Year__c, ASI_GiftBox_Region__c, ASI_GiftBox_Usage__c from ASI_GiftBox_Budget__c 
                    where recordTypeID = :Global_RecordTypeCache.getRtId('ASI_GiftBox_Budget__cASI_Gift_Box_VN_Budget') and ASI_GiftBox_Master__c in :gbMasterIDSet and ASI_GiftBox_Fiscal_Year__c in :gbFiscalYearSet and ASI_GiftBox_Region__c in :gbRegionSet]);
            List<ASI_GiftBox_Request_Item__c> allRequestItemList = new List<ASI_GiftBox_Request_Item__c>([select ASI_GiftBox_Request_Item__c, ASI_GiftBox_Status__c, ASI_GiftBox_Request_Quantity__c, ASI_GiftBox_Region__c, ASI_GiftBox_Fiscal_Year__c 
                    from ASI_GiftBox_Request_Item__c where recordtypeid = :Global_RecordTypeCache.getRtId('ASI_GiftBox_Request_Item__cASI_VN_GiftBox_Request_Item') and ASI_GiftBox_Request_Item__c in :gbMasterIDSet and ASI_GiftBox_Fiscal_Year__c in :gbFiscalYearSet and ASI_GiftBox_Region__c in :gbRegionSet]);

            for (ASI_GiftBox_Budget__c budget:budgetList){
                decimal totalUsageOpen = 0;
                decimal totalUsageComplete = 0;
                for (ASI_GiftBox_Request_Item__c item:allRequestItemList){
                    if (budget.ASI_GiftBox_Master__c == item.ASI_GiftBox_Request_Item__c && budget.ASI_GiftBox_Fiscal_Year__c == item.ASI_GiftBox_Fiscal_Year__c && budget.ASI_GiftBox_Region__c == item.ASI_GiftBox_Region__c)
                        if (item.ASI_GiftBox_Status__c == 'Complete')
                            totalUsageComplete += item.ASI_GiftBox_Request_Quantity__c;
                        else 
                            totalUsageOpen += item.ASI_GiftBox_Request_Quantity__c;
                }
                budget.ASI_GiftBox_Usage__c = totalUsageOpen;
                budget.ASI_GiftBox_Usage_Complete__c = totalUsageComplete;
            }

            update budgetList;
        }
    }

    public static void routineBeforeUpsert(list<ASI_GiftBox_Request_Item__c> trigger_new) {      
        Set<ID> gbMasterIDSet = new Set<ID>();
        
        for (ASI_GiftBox_Request_Item__c i : trigger_new){
            if (i.ASI_GiftBox_Request_Item__c != null && i.ASI_GiftBox_Request_Item_Warehouse__c != null){
                List<ASI_GiftBox_Inventory_Detail__c> invList = [select id, ASI_GiftBox_Item_Available_Quantity__c from ASI_GiftBox_Inventory_Detail__c 
                    where recordtypeid = :Global_RecordTypeCache.getRtId('ASI_GiftBox_Inventory_Detail__cASI_GiftBox_VN_Item_Detail') and ASI_GiftBox_Item_Id__c = :i.ASI_GiftBox_Request_Item__c and ASI_GiftBox_Item_Warehouse__c = :i.ASI_GiftBox_Request_Item_Warehouse__c];
                
                if (invList.size() == 0){
                    i.addError('Warehouse ' + i.ASI_GiftBox_Request_Item_Warehouse__c + ' do not have inventory for Gift Box ' + i.ASI_GiftBox_Gift_Box_Name__c);
                }
            }
            
            gbMasterIDSet.add(i.ASI_GiftBox_Request_Item__c);
        }
        
        if (gbMasterIDSet.size() > 0){
            //Default GB Unit Price to Request Item
            Map<ID,ASI_GiftBox_Inventory_Master__c> gbMasterMap = new Map<ID,ASI_GiftBox_Inventory_Master__c>([select id, ASI_GiftBox_Unit_Price__c from ASI_GiftBox_Inventory_Master__c where id in :gbMasterIDSet]);
        
            for (ASI_GiftBox_Request_Item__c i : trigger_new){
                if (i.ASI_GiftBox_Request_Item__c != null && gbMasterMap.get(i.ASI_GiftBox_Request_Item__c) != null && gbMasterMap.get(i.ASI_GiftBox_Request_Item__c).ASI_GiftBox_Unit_Price__c != null)
                    i.ASI_GiftBox_Request_Item_Unit_Price__c = gbMasterMap.get(i.ASI_GiftBox_Request_Item__c).ASI_GiftBox_Unit_Price__c;
            }

        }
        
        //Neha 11/09/2015    Method call to populate Items Delivered
        //ASI_GiftBox_RequestItemHelper.populateItemDelivered(trigger_new);
    }
    
    public static void routineAfterUpdate(list<ASI_GiftBox_Request_Item__c> trigger_new, map<id, ASI_GiftBox_Request_Item__c> trigger_oldMap) {
        list<ASI_GiftBox_Request_Item__c> requestItemList = new list<ASI_GiftBox_Request_Item__c>();
        
        for (ASI_GiftBox_Request_Item__c i : trigger_new){
            if (i.ASI_GiftBox_Request_Quantity__c != trigger_oldMap.get(i.id).ASI_GiftBox_Request_Quantity__c || i.ASI_GiftBox_Request_Item_Warehouse__c != trigger_oldMap.get(i.id).ASI_GiftBox_Request_Item_Warehouse__c){
                if (i.ASI_GiftBox_Request_Item__c != null){
                    calRequestedQuantity(i.ASI_GiftBox_Request_Item__c);
                }
            }
            
            System.debug('AfterUpdate: Status: ' + i.ASI_GiftBox_Status__c + ' GiftBox Master ID: ' + i.ASI_GiftBox_Request_Item__c + ' Warehouse: ' + i.ASI_GiftBox_Request_Item_Warehouse__c);
            if (i.ASI_GiftBox_Status__c == 'Waiting for HR Review' && i.ASI_GiftBox_Request_Item__c != null && i.ASI_GiftBox_Request_Item_Warehouse__c != null){
                List<ASI_GiftBox_Inventory_Detail__c> invList = [select id, ASI_GiftBox_Item_Available_Quantity__c from ASI_GiftBox_Inventory_Detail__c 
                    where recordtypeid = :Global_RecordTypeCache.getRtId('ASI_GiftBox_Inventory_Detail__cASI_GiftBox_VN_Item_Detail') and ASI_GiftBox_Item_Id__c = :i.ASI_GiftBox_Request_Item__c and ASI_GiftBox_Item_Warehouse__c = :i.ASI_GiftBox_Request_Item_Warehouse__c];
                
                System.debug('Query GB Inventory List Size: ' + invList.size());
                if (invList.size() == 1){
                    System.debug('GiftBox Name: ' + i.ASI_GiftBox_Request_Item__r.Name + 'Warehouse: ' + i.ASI_GiftBox_Request_Item_Warehouse__c + ' Available Qty: ' + invList.get(0).ASI_GiftBox_Item_Available_Quantity__c);
                    if (invList.get(0).ASI_GiftBox_Item_Available_Quantity__c < 0){
                        i.addError('Warehouse ' + i.ASI_GiftBox_Request_Item_Warehouse__c + ' do not enough inventory for Gift Box ' + i.ASI_GiftBox_Gift_Box_Name__c);
                    }
                }
            }
        }
    }
    
    public static void routineAfterInsert(list<ASI_GiftBox_Request_Item__c> trigger_new) {
        list<ASI_GiftBox_Request_Item__c> requestItemList = new list<ASI_GiftBox_Request_Item__c>();
        
        for (ASI_GiftBox_Request_Item__c i : trigger_new){
            if (i.ASI_GiftBox_Request_Item__c != null){
                calRequestedQuantity(i.ASI_GiftBox_Request_Item__c);
            }
        }
    }
    
    public static void routineBeforeDelete(list<ASI_GiftBox_Request_Item__c> trigger_old) {
        for (ASI_GiftBox_Request_Item__c i : trigger_old){
            LIST<ASI_GiftBox_Request_Header__c>header = [select id,ASI_GiftBox_Status__c from ASI_GiftBox_Request_Header__c where id = :i.ASI_GiftBox_Request_Id__c];
            
            system.debug('header status: ' + header.get(0).ASI_GiftBox_Status__c);
            
            if (header.get(0).ASI_GiftBox_Status__c!='Open'){
                i.addError('Not allowed to delete because the Request is not in \'Open\' status');
                break;
            }
        }
    }
    
    public static void calRequestedQuantity(ID giftBoxMasterID){
        List<ASI_GiftBox_Request_Item__c> requestItemList = [select ASI_GiftBox_Request_Id__r.ASI_GiftBox_Status__c, ASI_GiftBox_Request_Quantity__c, ASI_GiftBox_Request_Item_Warehouse__c from ASI_GiftBox_Request_Item__c
            where ASI_GiftBox_Request_Item__c = :giftBoxMasterID];
        
        List<ASI_GiftBox_Inventory_Detail__c> inventoryWarehouseList = [select ASI_GiftBox_Item_Warehouse__c, ASI_GiftBox_Item_Requested_Quantity__c from ASI_GiftBox_Inventory_Detail__c 
            where ASI_GiftBox_Item_Id__c = :giftBoxMasterID];
            
        for (ASI_GiftBox_Inventory_Detail__c inv :inventoryWarehouseList){
            decimal requestQty = 0;
            
            for (ASI_GiftBox_Request_Item__c i :requestItemList){
                if (i.ASI_GiftBox_Request_Item_Warehouse__c == inv.ASI_GiftBox_Item_Warehouse__c){
                    if (i.ASI_GiftBox_Request_Id__r.ASI_GiftBox_Status__c != 'Open' && i.ASI_GiftBox_Request_Id__r.ASI_GiftBox_Status__c != 'Reject'){
                        requestQty += i.ASI_GiftBox_Request_Quantity__c;
                    }
                }
                inv.ASI_GiftBox_Item_Requested_Quantity__c = requestQty;
            }
        }
        update inventoryWarehouseList;
    }
}