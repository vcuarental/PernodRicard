public with sharing class EUR_CRM_RouteTemplateTaskHandler extends EUR_CRM_TriggerAbstract{
    
    public EUR_CRM_RouteTemplateTaskHandler(){
        super('EUR_CRM_RouteTemplateTaskHandler');

    }  /*
   public final static Set<String> validContractRecordTypes = new Set<String>{'EUR_AO_Route_Template','EUR_E1_Route_Template','EUR_EE_Route_Template',
                                                                'EUR_KE_Route_Template','EUR_LT_Route_Template','EUR_LV_Route_Template','EUR_AT_Route_Template',
                                                                'EUR_DE_Route_Template','EUR_GB_Route_Template'};
 */
 public final static Set<String> validContractRecordTypes = new Set<String>{'EUR_DE_Task'};
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap)
    {
        system.debug('***: ' + tAction + ' ' + sObjList);
        Database.upsertResult[] upsertResultRT;
        System.Savepoint pSavepoint = Database.setSavepoint();
            
        List<EUR_CRM_Route_Template__c> routeTemplateForUpdate = new List<EUR_CRM_Route_Template__c>();
        Map<Id, Task> routeTemplateTaskMap = new Map<Id, Task>();

        List<Recordtype> contractRecordTypes = Global_RecordTypeCache.getRtList('Task');
        Map<Id,Recordtype> contractRecordTypeMap = new Map<Id,Recordtype>(); 

        for(Recordtype rt : contractRecordTypes ){
           contractRecordTypeMap.put(rt.id,rt);
        } 
        
        for (Task task: (List<Task>)sObjList){
            if (task.EUR_CRM_Route_Template__c != null 
               // && validContractRecordTypes.contains(contractRecordTypeMap.get(task.recordTypeId).developername)
                ){
                routeTemplateTaskMap.put(task.EUR_CRM_Route_Template__c, task);
            }
        }
        
        if (routeTemplateTaskMap.size()>0){
            //List <Id> rtIdList = new List<Id>();
            //{routeTemplateTaskMap.keySet()};
            for(EUR_CRM_Route_Template__c routeTemplate : [SELECT Id, EUR_CRM_Population_Reminder_Date_Time__c 
                                                            FROM EUR_CRM_Route_Template__c 
                                                            WHERE Id IN: routeTemplateTaskMap.keySet()
                                                            LIMIT 49999]){
                
                if(tAction == EUR_CRM_TriggerAbstract.TriggerAction.AFTER_INSERT){
                    Task task = routeTemplateTaskMap.get(routeTemplate.Id);
                    routeTemplate.EUR_CRM_Population_Reminder_Date_Time__c = task.ReminderDateTime;
                }
                else if (tAction == EUR_CRM_TriggerAbstract.TriggerAction.AFTER_DELETE){
                    routeTemplate.EUR_CRM_Population_Reminder_Date_Time__c = null;
                }
                routeTemplateForUpdate.add(routeTemplate);
            }
            system.debug('***: ' + routeTemplateForUpdate);
        }
        
        try{
            system.debug('*** upsert here ');
            Database.upsert(routeTemplateForUpdate, EUR_CRM_Route_Template__c.Id);
        }
        catch(Exception e){
            System.debug('Upsert Error: ' + e);
            Database.rollback(pSavepoint);      
        }
    }
}