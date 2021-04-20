@RestResource(UrlMapping='/ASI_CRM_CN_PhysicalICI_Upsert/*')
global without sharing class ASI_CRM_CN_PhysicalICI_Upsert {

    global Class PhysicalInventoryLI{
        global list <PhysicalInventoryItemStructure> PhysicalInventoryItemList { set; get; }
    }
    
    /* Sample Json Format
	{"jsonString":"{\"PhysicalInventoryItemList\":[{\"recordID\":\"aCqM00000008QBg\",\"DateOfChecking\":\"2015/08/31\",\"InventoryBtl\":\"1\",\"InventoryBtlFromWS\":\"2\",\"itemGroup\":\"a7GM00000008Sj7\",\"PhysicalInventoryCheck\":\"\"},{\"recordID\":\"\",\"DateOfChecking\":\"2015/05/21\",\"InventoryBtl\":\"1\",\"InventoryBtlFromWS\":\"2\",\"itemGroup\":\"a7GM00000008Sgv\",\"PhysicalInventoryCheck\":\"aCpM00000008OO2\"}]}"}
    */
    
    @HttpPost
    global static string upsertPhysicalInventoryItem (String jsonString ){
        
        PhysicalInventoryLI PhysicalInventoryLIList = (PhysicalInventoryLI)JSON.deserialize(jsonString,PhysicalInventoryLI.class);
        
        List<ASI_CRM_Physical_Inventory_Check_Item__c> physicalInventoryItem = new List<ASI_CRM_Physical_Inventory_Check_Item__c>();
        
        for(PhysicalInventoryItemStructure obj : PhysicalInventoryLIList.PhysicalInventoryItemList) {
            
            ASI_CRM_Physical_Inventory_Check_Item__c b = New ASI_CRM_Physical_Inventory_Check_Item__c();
            
            if(obj.recordID == NULL || obj.recordID == ''){
                b.ASI_CRM_Date_of_Checking__c = date.newInstance(integer.valueOf(obj.DateOfChecking.subString(0,4)), integer.valueOf(obj.DateOfChecking.subString(5,7)), integer.valueOf(obj.DateOfChecking.subString(8)));
                b.ASI_CRM_Inventory_Btl__c = obj.InventoryBtl;
                b.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Physical_Inventory_Check_Item__cASI_CRM_CN_Physical_Inventory_Check_Item');
                b.ASI_CRM_Inventory_Btl_from_WS__c = obj.InventoryBtlFromWS;
                b.ASI_CRM_Item_Group__c = obj.itemGroup;
                b.ASI_CRM_Physical_Inventory_Check__c = obj.PhysicalInventoryCheck;
                
                physicalInventoryItem.add(b);
            }else if(obj.recordID != NULL && obj.recordID != ''){
                
                b.id = obj.recordID;
                b.ASI_CRM_Date_of_Checking__c = date.newInstance(integer.valueOf(obj.DateOfChecking.subString(0,4)), integer.valueOf(obj.DateOfChecking.subString(5,7)), integer.valueOf(obj.DateOfChecking.subString(8)));
                b.ASI_CRM_Inventory_Btl__c = obj.InventoryBtl;
                b.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Physical_Inventory_Check_Item__cASI_CRM_CN_Physical_Inventory_Check_Item');
                b.ASI_CRM_Inventory_Btl_from_WS__c = obj.InventoryBtlFromWS;
                b.ASI_CRM_Item_Group__c = obj.itemGroup;
                
                physicalInventoryItem.add(b);
            }
        }
        upsert physicalInventoryItem;
        
        return 'success';
    }
    
	global with sharing class PhysicalInventoryItemStructure{
        
        global String recordID { set; get; }
        global String DateOfChecking { set; get; }
        global Decimal InventoryBtl { set; get; }
        global Decimal InventoryBtlFromWS { set; get; }
        global String itemGroup { set; get; }
        global String PhysicalInventoryCheck { set; get; }
        
    }
}