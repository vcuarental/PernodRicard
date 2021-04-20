/**
General Trigger Handler for Objective/Promotion.
After Update
Functions:
 O/P-Account Mapping - implement trigger to mark the record as inactive, if the O/P is expired (End Date less than Today. 
    (Bypass flag for Mobile app, so it doesn't need to create Visit Actions against that Promotion for that Account)
*/

public with sharing class EUR_CRM_DE_DeleteOPVariations extends EUR_CRM_TriggerAbstract {

    public EUR_CRM_DE_DeleteOPVariations() {
        super('EUR_CRM_DE_DeleteOPVariations');
    }

    private final static Set<String> opVariationRecordTypes = new Set<String> {
        'EUR_DE_ObjPromo_Promo_Variation'
    };

    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        Set<Id> opVarSet = new Set<Id>();

        for(EUR_CRM_ObjPromo_OnTrade_Variation__c opVar: (List<EUR_CRM_ObjPromo_OnTrade_Variation__c >)sObjList) {
//            String recordTypeDevName = objPromoRecordVariationTypesMap.get(opVar.recordTypeId).developername;
            EUR_CRM_ObjPromo_OnTrade_Variation__c oldOPVar =  ((EUR_CRM_ObjPromo_OnTrade_Variation__c )oldMap.get(opVar.id));

            if (opVar.EUR_CRM_Is_Active__c == false && oldOPVar.EUR_CRM_Is_Active__c == true) {
                opVarSet.add(opVar.id);
            }
        }

        if (opVarSet.size() > 0) {
            List<EUR_CRM_ObjPromo_PROS_To_Var_Mapping__c> opVarMappings = [select id from EUR_CRM_ObjPromo_PROS_To_Var_Mapping__c
            where EUR_CRM_ObjPromo_OnTrade_Variation__c in: opVarSet];

            if (opVarMappings != null && opVarMappings.size() > 0)
                delete opVarMappings;
        }

    }
}