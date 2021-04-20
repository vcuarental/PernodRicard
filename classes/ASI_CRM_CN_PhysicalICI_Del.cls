@RestResource(UrlMapping='/ASI_CRM_CN_PhysicalICI_Del/*')
global without sharing class ASI_CRM_CN_PhysicalICI_Del {

    global Class PhysicalInventoryLI{
        global list <PhysicalInventoryItemStructure> PhysicalInventoryItemList { set; get; }
    }
    
    /* Sample Json Format
    {"jsonString":"{\"PhysicalInventoryItemList\":[{\"recordID\":\"aCqM00000008QBb\"}]}"}
    */
    
    @HttpPost
    global static string delPhysicalInventoryItem (String jsonString ){
        
        PhysicalInventoryLI PhysicalInventoryLIList = (PhysicalInventoryLI)JSON.deserialize(jsonString,PhysicalInventoryLI.class);
        
        List<ASI_CRM_Physical_Inventory_Check_Item__c> newPhysicalInventoryItem = new List<ASI_CRM_Physical_Inventory_Check_Item__c>();
        
        for(PhysicalInventoryItemStructure obj : PhysicalInventoryLIList.PhysicalInventoryItemList) {
            
            ASI_CRM_Physical_Inventory_Check_Item__c b = New ASI_CRM_Physical_Inventory_Check_Item__c();
            
            b.id = obj.recordID;
            
            newPhysicalInventoryItem.add(b);
        }
        delete newPhysicalInventoryItem;
        
        return 'success';
    }
    
	global with sharing class PhysicalInventoryItemStructure{
        global String recordID { set; get; }
    }
}