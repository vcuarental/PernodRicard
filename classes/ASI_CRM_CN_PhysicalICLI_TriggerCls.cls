public without sharing class ASI_CRM_CN_PhysicalICLI_TriggerCls {
	
    public static void beforeUpsert(List<ASI_CRM_Physical_Inventory_Check_Item__c> triggerNew, Map<id, ASI_CRM_Physical_Inventory_Check_Item__c> triggerOldMap){
        
        Set<id> headerIDSet = new Set<id>();
        Map<String, ASI_CRM_Physical_Inventory_Check_Item__c> duplicatedMap = new Map<String, ASI_CRM_Physical_Inventory_Check_Item__c>();
        
        for(ASI_CRM_Physical_Inventory_Check_Item__c obj : triggerNew){
            
            headerIDSet.add(obj.ASI_CRM_Physical_Inventory_Check__c);
        }
        
        List<ASI_CRM_Physical_Inventory_Check_Item__c> allRecords = new List<ASI_CRM_Physical_Inventory_Check_Item__c>([SELECT id
                                                                                                                        , ASI_CRM_Item_Group__r.Name
                                                                                                                        , ASI_CRM_Physical_Inventory_Check__c
                                                                                                                        , ASI_CRM_Item_Group__c
                                                                                                                        FROM ASI_CRM_Physical_Inventory_Check_Item__c
                                                                                                                        WHERE ASI_CRM_Physical_Inventory_Check__c IN : headerIDSet
                                                                                                                       ]);
        for(ASI_CRM_Physical_Inventory_Check_Item__c obj : allRecords){
            duplicatedMap.put(obj.ASI_CRM_Physical_Inventory_Check__c + '' + obj.ASI_CRM_Item_Group__c, obj);
        }
        
        for(ASI_CRM_Physical_Inventory_Check_Item__c obj : triggerNew){
            
            if(!ASI_CRM_CN_Function.IsBypassTrigger('ASI_CRM_CN_PhysicalIC_TriggerClass') && obj.ASI_CRM_Confirmed__c){
                obj.addError('You are not allowed to modify the comfirmed record');
            }
            
            if(trigger.isUpdate && triggerOldMap.get(obj.id).ASI_CRM_Item_Group__c != obj.ASI_CRM_Item_Group__c){
                if(duplicatedMap.containsKey(obj.ASI_CRM_Physical_Inventory_Check__c + '' + obj.ASI_CRM_Item_Group__c)){
                	obj.addError('You are not allowed to create Line Item for this Physical Inventory Check for this Item Group, duplication exists');
                }
            }else if(trigger.isInsert){
                if(duplicatedMap.containsKey(obj.ASI_CRM_Physical_Inventory_Check__c + '' + obj.ASI_CRM_Item_Group__c)){
                	obj.addError('You are not allowed to create Line Item for this Physical Inventory Check for this Item Group, duplication exists');
                }
            }
        }
    }
}