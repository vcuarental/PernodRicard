trigger EUR_CRM_AT_ActionTrigger on EUR_CRM_GB_Action__c (after insert, after update, after delete) {
    Map<Id,RecordType> rtMap = new Map<Id,RecordType>([select id, developername from RecordType
    where SObjectType = 'EUR_CRM_GB_Action__c']);
    
    Set<String> validRT = EUR_CRM_RecordTypeHelper.AT_Action_Trigger_validRT;
    Set<Id> objectiveIds = new Set<Id>();
    if(!Trigger.isDelete){
        for(EUR_CRM_GB_Action__c action: Trigger.new){
            if(rtMap.get(action.recordTypeid) != null &&
                validRT.contains(rtMap.get(action.recordTypeid).developername) ){
                objectiveIds.add(action.EUR_CRM_GB_Objective__c);
            }
        }
    }else{
        for(EUR_CRM_GB_Action__c action: Trigger.old){
            if(rtMap.get(action.recordTypeid) != null &&
                validRT.contains(rtMap.get(action.recordTypeid).developername) ){
                objectiveIds.add(action.EUR_CRM_GB_Objective__c);
            }
        }
    }
    Map<id,EUR_CRM_GB_Objective__c> objectivesMap = new Map<id,EUR_CRM_GB_Objective__c>();
    objectivesMap  = new Map<id,EUR_CRM_GB_Objective__c>([select id,EUR_CRM_Achieved__c,EUR_CRM_Target_Number_of_Actions__c,EUR_CRM_Achieved_Number_of_Actions__c from EUR_CRM_GB_Objective__c where id in: objectiveIds ]);
    
    if(Trigger.isInsert){
        for(EUR_CRM_GB_Action__c action: Trigger.new){
            if(rtMap.get(action.recordTypeid) != null &&
            validRT.contains(rtMap.get(action.recordTypeid).developername) &&
            action.EUR_CRM_Achieved__c){
            Decimal target = objectivesMap.get(action.EUR_CRM_GB_Objective__c).EUR_CRM_Target_Number_of_Actions__c;
            target = target == null ? 0 :target;
            Decimal num = objectivesMap.get(action.EUR_CRM_GB_Objective__c).EUR_CRM_Achieved_Number_of_Actions__c;
            num = num == null? 1 : (num + 1);
            objectivesMap.get(action.EUR_CRM_GB_Objective__c).EUR_CRM_Achieved_Number_of_Actions__c = num;
            objectivesMap.get(action.EUR_CRM_GB_Objective__c).EUR_CRM_Achieved__c = num >= target;
        }
        }
    }
    if(Trigger.isUpdate){
        for(EUR_CRM_GB_Action__c action: Trigger.new){
            if(rtMap.get(action.recordTypeid) != null &&
            validRT.contains(rtMap.get(action.recordTypeid).developername) &&
            action.EUR_CRM_Achieved__c
            && !(trigger.oldMap.get(action.id).EUR_CRM_Achieved__c)){
            Decimal num = objectivesMap.get(action.EUR_CRM_GB_Objective__c).EUR_CRM_Achieved_Number_of_Actions__c;
            num = num == null? 1 : (num + 1);
            Decimal target = objectivesMap.get(action.EUR_CRM_GB_Objective__c).EUR_CRM_Target_Number_of_Actions__c;
            target = target == null ? 0 :target;
            objectivesMap.get(action.EUR_CRM_GB_Objective__c).EUR_CRM_Achieved_Number_of_Actions__c = num;
             objectivesMap.get(action.EUR_CRM_GB_Objective__c).EUR_CRM_Achieved__c = num >= target;
            } else if(rtMap.get(action.recordTypeid) != null &&
            validRT.contains(rtMap.get(action.recordTypeid).developername) &&
            !action.EUR_CRM_Achieved__c
            && (trigger.oldMap.get(action.id).EUR_CRM_Achieved__c)){
            Decimal target = objectivesMap.get(action.EUR_CRM_GB_Objective__c).EUR_CRM_Target_Number_of_Actions__c;
            target = target == null ? 0 :target;
            Decimal num = objectivesMap.get(action.EUR_CRM_GB_Objective__c).EUR_CRM_Achieved_Number_of_Actions__c;
            num = num == null?0 : (num - 1);
            objectivesMap.get(action.EUR_CRM_GB_Objective__c).EUR_CRM_Achieved_Number_of_Actions__c = num;
            objectivesMap.get(action.EUR_CRM_GB_Objective__c).EUR_CRM_Achieved__c = num >= target;
            }
        }
    }
    if(Trigger.isDelete){
        for(EUR_CRM_GB_Action__c action: Trigger.old){
        if(rtMap.get(action.recordTypeid) != null &&
            validRT.contains(rtMap.get(action.recordTypeid).developername) &&
            action.EUR_CRM_Achieved__c
            && objectivesMap.get(action.EUR_CRM_GB_Objective__c) != null){
            Decimal target = objectivesMap.get(action.EUR_CRM_GB_Objective__c).EUR_CRM_Target_Number_of_Actions__c;
            target = target == null ? 0 :target;
            Decimal num = objectivesMap.get(action.EUR_CRM_GB_Objective__c).EUR_CRM_Achieved_Number_of_Actions__c;
            num = num == null?0:(num - 1);
            objectivesMap.get(action.EUR_CRM_GB_Objective__c).EUR_CRM_Achieved_Number_of_Actions__c = num;
            objectivesMap.get(action.EUR_CRM_GB_Objective__c).EUR_CRM_Achieved__c = num >= target;
        }
        }
    }
    if(objectivesMap.size() > 0)
        update objectivesMap.values();
}