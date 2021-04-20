public with sharing class EUR_CRM_RouteTemplate_SetDefaultValues extends EUR_CRM_TriggerAbstract {

    public EUR_CRM_RouteTemplate_SetDefaultValues(){
        super('EUR_CRM_RoutleTempalte_SetDefaultValues');
    }

    private Map<String, Map<String, Integer>> validRecordTypesAndDefaultValues = EUR_CRM_RecordTypeHelper.RouteTemplate_SetDefaultValues_ValidRecordTypesAndDefaultValues;

    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap){

        List<Recordtype> routeTemplateRecordTypes = Global_RecordTypeCache.getRtList('EUR_CRM_Route_Template__c');
        Map<Id, RecordType> routeTemplateRecordTypesMap = new Map<Id, RecordType>();
        for(RecordType rType : routeTemplateRecordTypes){
            routeTemplateRecordTypesMap.put(rType.Id, rType);
        }

        List<EUR_CRM_Route_Template__c> rtList = new List<EUR_CRM_Route_Template__c>();
        for(EUR_CRM_Route_Template__c rt : (List<EUR_CRM_Route_Template__c>)sObjList){
            if(validRecordTypesAndDefaultValues.KeySet().contains(routeTemplateRecordTypesMap.get(rt.RecordtypeId).DeveloperName)){
                rtList.add(rt);
            }
        }

        if(rtList.size() > 0){
            for(EUR_CRM_Route_Template__c rt : rtList){
                Map<String, Integer> values = validRecordTypesAndDefaultValues.get(routeTemplateRecordTypesMap.get(rt.RecordtypeId).DeveloperName);
                rt.EUR_CRM_Max_Planning_Period_Week__c = values.get('EUR_CRM_Max_Planning_Period_Week__c');
                rt.EUR_CRM_Planning_Period__c = values.get('EUR_CRM_Planning_Period__c');
                rt.EUR_CRM_Reminder_Day__c = values.get('EUR_CRM_Reminder_Day__c');
            }
        }
    }
}