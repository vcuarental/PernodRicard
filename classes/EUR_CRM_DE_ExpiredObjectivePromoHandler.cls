/**
General Trigger Handler for Objective/Promotion.
After Update
Functions:
 O/P-Account Mapping - implement trigger to mark the record as inactive, if the O/P is expired (End Date less than Today. 
    (Bypass flag for Mobile app, so it doesn't need to create Visit Actions against that Promotion for that Account)
*/

public with sharing class EUR_CRM_DE_ExpiredObjectivePromoHandler extends EUR_CRM_TriggerAbstract {
    
    public EUR_CRM_DE_ExpiredObjectivePromoHandler(){
        super('EUR_CRM_DE_ExpiredObjectivePromoHandler');
    }
    
    private final static Set<String> objectPromoRecordTypeSet = new Set<String>{
        'EUR_DE_Off_Trade_Distribution_Drive',
        'EUR_DE_Off_Trade_Leaflet_Campaign',
        'EUR_DE_Off_Trade_Sales_Drive',
        'EUR_DE_Off_Trade_Sales_Drive_SKU_Bottles',
        'EUR_DE_Off_Trade_Sales_Drive_SKU_Displays',
        'EUR_DE_Off_Trade_Secondary_Placement_Carton',
        'EUR_DE_Off_Trade_Secondary_Placement_Gondelkopf',
        'EUR_DE_Off_Trade_Secondary_Placement_Promo_Display',
        'EUR_DE_Off_Trade_Secondary_Placement_Razz_Fazz',
        'EUR_DE_Off_Trade_Secondary_Placement_Standard',
        'EUR_DE_Off_Trade_Secondary_Placement_Theme',
        'EUR_DE_Off_Trade_Tasting_Campaign',
        'EUR_DE_Off_Trade_Trade_Fair',
        'EUR_DE_OnTrade_PROS_TMKT_Promo'
        
    }; 
    private static final String ENDED = 'Ended';
    private static final String DEACTIVATED = 'Deactivated';
    private static final Integer DML_THRESHOLD = 8000;
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap){
         
        List<Recordtype> objPromoRecordTypes = Global_RecordTypeCache.getRtList('EUR_CRM_ObjPromo__c');
        Map<Id,Recordtype> objPromoRecordTypesMap = new Map<Id,Recordtype>();
        
        for(Recordtype rt : objPromoRecordTypes ){
           objPromoRecordTypesMap.put(rt.id,rt);
        }  
        
        Set<Id> objPromoIds = new Set<Id>();
        
        for(EUR_CRM_ObjPromo__c objPromo: (List<EUR_CRM_ObjPromo__c>)sObjList){         
            String recordTypeDevName = objPromoRecordTypesMap.get(objPromo.recordTypeId).developername;
            EUR_CRM_ObjPromo__c oldObjPromo = Trigger.isUpdate && oldMap.get(objPromo.id) != null ?  ((EUR_CRM_ObjPromo__c)oldMap.get(objPromo.id)): null;
             if(objectPromoRecordTypeSet.contains(recordTypeDevName) &&
                (objPromo.EUR_CRM_Status__c == ENDED || objPromo.EUR_CRM_Status__c == DEACTIVATED ) &&
                oldObjPromo.EUR_CRM_Status__c != objPromo.EUR_CRM_Status__c){
                 objPromoIds.add(objPromo.id);
             }
        }
        List<EUR_CRM_ObjPromo_Account_Mapping__c> objPromoMapList = new List<EUR_CRM_ObjPromo_Account_Mapping__c >();
        if(objPromoIds.size() > 0){
            for(EUR_CRM_ObjPromo_Account_Mapping__c objPromoMap : 
                [select id from EUR_CRM_ObjPromo_Account_Mapping__c where EUR_CRM_ObjPromo__c in:objPromoIds]){ 
                objPromoMapList.add(new EUR_CRM_ObjPromo_Account_Mapping__c ( id = objPromoMap.id, EUR_CRM_Is_Active__c = false));
            }
            if(objPromoMapList.size() > 0 && objPromoMapList.size() < DML_THRESHOLD && !Test.isRunningTest()){
                update objPromoMapList;
            }else if(objPromoMapList.size() > DML_THRESHOLD || Test.isRunningTest()){
                Database.executeBatch(new EUR_CRM_BatchDML_Utility(objPromoMapList, 'EUR_CRM_ObjPromo_Account_Mapping__c', EUR_CRM_BatchDML_Utility.Operation.UPDATE_RECORDS,false, null));
            }
        }
        
    }    
}