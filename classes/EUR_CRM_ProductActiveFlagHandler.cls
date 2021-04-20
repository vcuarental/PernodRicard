/*
"Active flag in Product Hierarchy:
Currently there is a active checkbox on each product level (except wine/spirits). 

Create a trigger on each level of the product hierarchy that will manage the value of these fields when: 

One of these flag is OFF (un-checked/FALSE) the level(s) below should all be OFF also
One of these flag is ON (checked/TRUE) the level(s) below should all be ON also."

WINE_SPIRITS
  ^
  |
 CATEGORY
  ^
  |
  BRAND
  ^
  |
  QUALITY
  ^
  |
   SIZE
  ^
  |
   SKU 

*/
public with sharing class EUR_CRM_ProductActiveFlagHandler extends EUR_CRM_TriggerAbstract {
    public final static String WINE_SPIRITS= 'EUR_CRM_Wine_Spirits__c';
    public final static String CATEGORY= 'EUR_CRM_Category__c';
    public final static String BRAND = 'EUR_CRM_Brand__c';
    public final static String QUALITY= 'EUR_CRM_Quality__c';
    public final static String SIZE = 'EUR_CRM_Size__c';
    public final static String SKU = 'EUR_CRM_SKU__c'; 
    private Map<String,Integer> objLevels = new Map<String,Integer>{
        SKU => 1,
        SIZE => 2,
        QUALITY => 3,
        BRAND => 4,
        CATEGORY => 5
    };
    
    private String sObjectString;
    private Set<String> validRecordTypes;
    public EUR_CRM_ProductActiveFlagHandler ( String sObjectString){
          super('EUR_CRM_ProductActiveFlagHandler');
 
        this.sObjectString = sObjectString;
        validRecordTypes = recordTypesMap.get(sObjectString) == null ? new Set<String>() : recordTypesMap.get(sObjectString);
     }
    private Map<String,Set<String>> recordTypesMap = new Map<String,Set<String>>();
    private String ACTIVE = 'EUR_CRM_Active__c';

    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap){
        List<Recordtype> objectRecordTypes = Global_RecordTypeCache.getRtList('sObjectString');
        Map<Id,Recordtype> objectRecordTypesMap = new Map<Id,Recordtype>();
        
        for(Recordtype rt : objectRecordTypes){
           objectRecordTypesMap.put(rt.id,rt);
        }
        Set<Id> validRecords = new Set<Id>();
        Map<Id,sObject> sObjectMap = new Map<Id,sObject>();
        List<sObject> curentOjbList = new List<sObject>();
        for(sObject obj :  sObjList){
            if(Trigger.isUpdate && obj.get(ACTIVE) != oldMap.get(obj.id).get(ACTIVE)){
                validRecords.add(obj.id);
                sObjectMap.put(obj.Id,obj);
                curentOjbList.add(obj);
            }  
        }
        if(sObjectMap.size()>0){
            String childProductsQuery = 'select id, ';  
            String parentProductsQuery = 'select id,EUR_CRM_Active__c';  
            String parentField;
            String relatedParentField;
            String childObjectAPI;
            String parentObjectAPI;
            set<Id> relatedParentId = new set<Id>();
            
            if(sObjectString == CATEGORY){
                if(TriggerCaller.size()==0)
                setTriggerCaller(CATEGORY,objLevels.get(CATEGORY));
                parentField ='EUR_CRM_Category__c';
                childObjectAPI = 'EUR_CRM_Brand__c';
                parentObjectAPI = 'EUR_CRM_Category__c';
            }else if(sObjectString == BRAND){
                if(TriggerCaller.size()==0)
                setTriggerCaller(BRAND,objLevels.get(BRAND));
                parentField ='EUR_CRM_Brand__c';
                childObjectAPI = 'EUR_CRM_Quality__c'; 
                parentObjectAPI = 'EUR_CRM_Category__c';
                relatedParentField='EUR_CRM_Category__c';
                for(sObject curentOjb: curentOjbList){
                    relatedParentId.add((Id) curentOjb.get(relatedParentField));
                }
            }else if(sObjectString == QUALITY){
                if(TriggerCaller.size()==0)
                setTriggerCaller(QUALITY,objLevels.get(QUALITY));
                parentField ='EUR_CRM_Brand_Quality__c';
                childObjectAPI = 'EUR_CRM_Size__c'; 
                relatedParentField='EUR_CRM_Brand__c';
                parentObjectAPI = 'EUR_CRM_Brand__c';
                for(sObject curentOjb: curentOjbList){
                    relatedParentId.add((Id) curentOjb.get(relatedParentField));
                }
            }else if(sObjectString == SIZE){
                if(TriggerCaller.size()==0)
                setTriggerCaller(SIZE,objLevels.get(SIZE));
                parentField ='EUR_CRM_Brand_Quality_Size__c';
                childObjectAPI = 'EUR_CRM_SKU__c'; 
                relatedParentField='EUR_CRM_Brand_Quality__c';
                parentObjectAPI = 'EUR_CRM_Quality__c';
                for(sObject curentOjb: curentOjbList){
                    relatedParentId.add((Id) curentOjb.get(relatedParentField));
                }
            }else if(sObjectString == SKU){
                if(TriggerCaller.size()==0)
                setTriggerCaller(SKU,objLevels.get(SKU));
                parentField ='EUR_CRM_SKU__c';
                childObjectAPI = 'EUR_CRM_SKU__c'; 
                relatedParentField='EUR_CRM_Brand_Quality_Size__c';
                parentObjectAPI = 'EUR_CRM_Size__c';
                for(sObject curentOjb: curentOjbList){
                    relatedParentId.add((Id) curentOjb.get(relatedParentField));
                }
            }
            List<sObject> parentObjectsForUpdate = new List<sObject>();
            parentProductsQuery += ' from '+parentObjectAPI+' where Id in :' +'relatedParentId';
            for(sObject obj: Database.query(parentProductsQuery)){
                Id parentId = (Id) obj.get('Id');
                sObject parentObj = newMap.values()[0];
                obj.put(ACTIVE, parentObj.get(ACTIVE));
                if(Boolean.valueOf(parentObj.get(ACTIVE)))
                parentObjectsForUpdate.add(obj);
 
            }
            if(parentObjectsForUpdate.size() > 0)
            update parentObjectsForUpdate;
                
            if(checkTriggerCaller(sObjectString) && sObjectString != SKU){
                childProductsQuery += parentField +' from '+childObjectAPI+' where '+ parentField +' in: validRecords';
                List<sObject> objectsForUpdate = new List<sObject>();               
                for(sObject obj: Database.query(childProductsQuery)){
                    Id parentId = (Id) obj.get(parentField);
                    sObject parentObj = newMap.get(parentId);
                    obj.put(ACTIVE, parentObj.get(ACTIVE));
                    objectsForUpdate.add(obj);
                }
                if(objectsForUpdate.size() > 0)
                  update objectsForUpdate;
            }
        }
    }
    
    private static Map<String,Integer> triggerCaller=new Map<String,Integer>();

    public void setTriggerCaller(String key, Integer value){
        if(triggerCaller.size()==0){
            triggerCaller.put(key,value);
        }
    }
    
    public Boolean checkTriggerCaller(string currentRec){
        Integer intTrigCaller;
        if(triggerCaller.size()>0)
        intTrigCaller = triggerCaller.values()[0];
        if(objLevels.get(currentRec) <= intTrigCaller)
            return true;
        return false;
    }
}