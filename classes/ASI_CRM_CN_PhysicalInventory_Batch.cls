global without sharing class ASI_CRM_CN_PhysicalInventory_Batch implements Database.Batchable<sObject> ,Database.Stateful{
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        String soqlQuery = 'SELECT ID, ASI_CRM_Confirmed__c FROM ASI_CRM_Physical_Inventory_Check__c WHERE ASI_CRM_Month__c <= LAST_MONTH AND ASI_CRM_Confirmed__c = FALSE';
        
        return Database.getQueryLocator(soqlQuery);
    }
    
    global void execute(Database.BatchableContext BC,  List<sObject> scope){
        
        if(scope.size() > 0){
            List<ASI_CRM_Physical_Inventory_Check__c> updateList = new List<ASI_CRM_Physical_Inventory_Check__c>();
            for(sObject obj : scope){
                
                ASI_CRM_Physical_Inventory_Check__c tmpPIC = (ASI_CRM_Physical_Inventory_Check__c) obj;
                tmpPIC.ASI_CRM_Confirmed__c = TRUE;
                updateList.add(tmpPIC);
            }
            
            if(updateList.size() > 0){
                try{
                    update updateList;
                }catch(dmlException dmle){
                    
                }
            }
        }
    }
    
    global void finish(Database.BatchableContext BC){
        database.executebatch(new ASI_CRM_CN_PhysicalInventoryCount_Batch());
    }
}