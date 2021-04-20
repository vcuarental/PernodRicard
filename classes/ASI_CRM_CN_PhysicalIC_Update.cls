@RestResource(UrlMapping='/ASI_CRM_CN_PhysicalIC_Update/*')
global without sharing class ASI_CRM_CN_PhysicalIC_Update {

    global Class PhysicalInventory{
        global list <PhysicalInventoryStructure> PhysicalInventoryList { set; get; }
    }
    
    /* Sample Json Format
    {"jsonString":"{\"PhysicalInventoryList\":[{\"recordID\":\"aCpM00000008OO2\",\"confirmed\":true}]}"}
    */
    
    @HttpPost
    global static string updatePhysicalInventoryCheck (String jsonString ){
        
        PhysicalInventory PhysicalInventoryList = (PhysicalInventory)JSON.deserialize(jsonString,PhysicalInventory.class);
        
        List<ASI_CRM_Physical_Inventory_Check__c> newPhysicalInventory = new List<ASI_CRM_Physical_Inventory_Check__c>();
        
        for(PhysicalInventoryStructure obj : PhysicalInventoryList.PhysicalInventoryList) {
            
            ASI_CRM_Physical_Inventory_Check__c b = New ASI_CRM_Physical_Inventory_Check__c();
            
            b.id = obj.recordID;
            b.ASI_CRM_Confirmed__c = obj.confirmed;
            
            newPhysicalInventory.add(b);
        }
        update newPhysicalInventory;
        
        return 'success';
    }
    
	global with sharing class PhysicalInventoryStructure{
        global String recordID { set; get; }
        global Boolean confirmed { set; get; }
    }
}