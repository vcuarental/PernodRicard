public without sharing class ASI_CRM_CN_PhysicalIC_TriggerClass {
    
    public static void beforeUpsert(List<ASI_CRM_Physical_Inventory_Check__c> triggerNew, Map<id, ASI_CRM_Physical_Inventory_Check__c> triggerOldMap){
        
        Set<id> customerID = new Set<id>();
        Set<integer> yearSet = new Set<integer>();
        Set<integer> monthSet = new Set<integer>();
        
        for(ASI_CRM_Physical_Inventory_Check__c obj : triggerNew){
            
            customerID.add(obj.ASI_CRM_WS__c);
            yearSet.add(obj.ASI_CRM_Month__c.year());
            monthSet.add(obj.ASI_CRM_Month__c.month());
        }
        
        List<ASI_CRM_Physical_Inventory_Check__c> recordList = new List<ASI_CRM_Physical_Inventory_Check__c>([SELECT id
                                                                                                              , ASI_CRM_Month__c
                                                                                                              , ASI_CRM_WS__c
                                                                                                              , ASI_CRM_WS__r.Name
                                                                                                              FROM ASI_CRM_Physical_Inventory_Check__c
                                                                                                              WHERE ASI_CRM_WS__c IN : customerID
                                                                                                              AND CALENDAR_MONTH(ASI_CRM_Month__c) IN : monthSet
                                                                                                              AND CALENDAR_YEAR(ASI_CRM_Month__c) IN : yearSet
                                                                                                             ]);
        
        Map<String, ASI_CRM_Physical_Inventory_Check__c> duplicateMap = new Map<String, ASI_CRM_Physical_Inventory_Check__c>();
        
        for(ASI_CRM_Physical_Inventory_Check__c obj : recordList){
            duplicateMap.put(obj.ASI_CRM_WS__c + '' + obj.ASI_CRM_Month__c.year() + '' + obj.ASI_CRM_Month__c.month(), obj);
        }
        
        for(ASI_CRM_Physical_Inventory_Check__c obj : triggerNew){
            
            if(trigger.isUpdate){
                if(!ASI_CRM_CN_Function.IsBypassTrigger('ASI_CRM_CN_PhysicalIC_TriggerClass') && triggerOldMap.get(obj.id).ASI_CRM_Confirmed__c){
                    obj.addError('You are not allowed to modify the comfirmed record');
                }
            }
            
            if(trigger.isUpdate && ( (triggerOldMap.get(obj.id).ASI_CRM_Month__c.month() != obj.ASI_CRM_Month__c.month() || triggerOldMap.get(obj.id).ASI_CRM_Month__c.year() != obj.ASI_CRM_Month__c.year()) || triggerOldMap.get(obj.id).ASI_CRM_WS__c != obj.ASI_CRM_WS__c)){
                
                if(duplicateMap.containsKey(obj.ASI_CRM_WS__c + '' + obj.ASI_CRM_Month__c.year() + '' + obj.ASI_CRM_Month__c.month())){
                	obj.addError('You are not allowed to create physical inventory check for this customer for this period, duplication exists');
                }
            }else if(trigger.isInsert){
                
                if(duplicateMap.containsKey(obj.ASI_CRM_WS__c + '' + obj.ASI_CRM_Month__c.year() + '' + obj.ASI_CRM_Month__c.month())){
                	obj.addError('You are not allowed to create physical inventory check for this customer for this period, duplication exists');
                }
            }
        }
    }
}