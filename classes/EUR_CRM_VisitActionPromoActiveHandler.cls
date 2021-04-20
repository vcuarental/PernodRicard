public with sharing class EUR_CRM_VisitActionPromoActiveHandler extends EUR_CRM_TriggerAbstract{

    public EUR_CRM_VisitActionPromoActiveHandler() {
        super('EUR_CRM_VisitActionPromoActiveHandler');
    }

    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap){

        for(EUR_CRM_Visit_Action__c visitAction: (List<EUR_CRM_Visit_Action__c>) sObjList){
            if(visitAction.EUR_CRM_Is_Promo_Active__c != oldMap.get(visitAction.Id).get('EUR_CRM_Is_Promo_Active__c') && visitAction.EUR_CRM_Is_Promo_Active__c == true) {
                visitAction.EUR_CRM_Active__c = false;
            }
        }
    }

}