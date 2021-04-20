global without sharing class ASI_CRM_CN_PhysicalInventoryCount_Batch implements Database.Batchable<sObject> ,Database.Stateful{
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        String soqlQuery = 'SELECT ID, ASI_CRM_Confirmed__c, ASI_CRM_Physical_Inventory_Check_Count__c, ASI_CRM_WS__c FROM ASI_CRM_Physical_Inventory_Check__c WHERE ASI_CRM_Month__c = THIS_MONTH AND ASI_CRM_Confirmed__c = FALSE';
        
        return Database.getQueryLocator(soqlQuery);
    }
    
    global void execute(Database.BatchableContext BC,  List<sObject> scope){
        
        Date fy = Date.Today().Month() >= 7 ? Date.newInstance(Date.Today().Year(), 7, 1) : Date.newInstance(Date.Today().addYears(-1).Year(), 7, 1);
        
        if(scope.size() > 0){
            
            Set<Id> customerId = new Set<Id>();
            List<ASI_CRM_Physical_Inventory_Check__c> countingPICList = new List<ASI_CRM_Physical_Inventory_Check__c>();
            List<ASI_CRM_Physical_Inventory_Check__c> updatePICList = new List<ASI_CRM_Physical_Inventory_Check__c>();
            Map<Id, Integer> countingMap = new Map<Id, Integer>();
            
            for(sObject obj : scope){
                
                ASI_CRM_Physical_Inventory_Check__c tmpPIC = (ASI_CRM_Physical_Inventory_Check__c) obj;
                customerId.add(tmpPIC.ASI_CRM_WS__c);
            }
            
            countingPICList = [SELECT ID, ASI_CRM_Confirmed__c, ASI_CRM_WS__c, ASI_CRM_Total_Inventory_Btl__c 
                               FROM ASI_CRM_Physical_Inventory_Check__c
                               WHERE ASI_CRM_WS__c IN : customerId 
                               AND Id NOT IN : scope 
                               AND ASI_CRM_Total_Inventory_Btl__c > 0 
                               AND ASI_CRM_Confirmed__c = TRUE
                               AND ASI_CRM_Month__c >= : fy
                              ];
            
            for(ASI_CRM_Physical_Inventory_Check__c obj : countingPICList){
                if(!countingMap.containsKey(obj.ASI_CRM_WS__c)){
                    countingMap.put(obj.ASI_CRM_WS__c, 1);
                }else{
                    countingMap.put(obj.ASI_CRM_WS__c, countingMap.get(obj.ASI_CRM_WS__c) + 1);
                }
            }
            
            for(sObject obj : scope){
                
                ASI_CRM_Physical_Inventory_Check__c tmpPIC = (ASI_CRM_Physical_Inventory_Check__c) obj;
                
                if(countingMap.containsKey(tmpPIC.ASI_CRM_WS__c)){
                    tmpPIC.ASI_CRM_Physical_Inventory_Check_Count__c = countingMap.get(tmpPIC.ASI_CRM_WS__c);
                    updatePICList.add(tmpPIC);
                }
            }
            if(updatePICList.size() > 0){
                try{
                    update updatePICList;
                }catch(dmlException dmle){
                    
                }
            }
        }
    }
    
    global void finish(Database.BatchableContext BC){
        //database.executebatch(new ASI_CRM_CN_OutletSellout_Batch());
    }
}