public without sharing class EUR_CRM_EventCleanUpHandler extends EUR_CRM_TriggerAbstract {
    public EUR_CRM_EventCleanUpHandler (){
        super('EUR_CRM_EventCleanUpHandler ');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap){
        List<EUR_CRM_Account__c> acctList = (List<EUR_CRM_Account__c>) sObjList;
        Map<Id, EUR_CRM_Account__c> oldAcctMap = (Map<Id, EUR_CRM_Account__c>) oldMap;
        
        List<Id> deactivatedAcctlist = new List<Id>();
        
        //Get deactivated account list
        for (EUR_CRM_Account__c account: acctList){
            System.debug('ACTIVE FLAG TEST:' + account.EUR_CRM_Active_Flag__c +'--'+oldAcctMap.get(account.Id).EUR_CRM_Active_Flag__c);
            if((tAction == TriggerAction.AFTER_UPDATE)&&(account.EUR_CRM_Active_Flag__c != oldAcctMap.get(account.Id).EUR_CRM_Active_Flag__c)&&(!account.EUR_CRM_Active_Flag__c)){
                deactivatedAcctlist.add(account.Id);
            }else if (tAction == TriggerAction.AFTER_DELETE){
                deactivatedAcctlist.add(account.Id);
            }
        }
        // Find events
        if (deactivatedAcctlist.size()>0){
            List<Event> eventForDeletion = new List<Event>();
                for (List<Event> evList: [SELECT Id, StartDateTime, 
                WhatId,
                EUR_CRM_Route_Template__c, EUR_CRM_Route_Template_Item__c
                FROM Event
                WHERE WhatId IN:deactivatedAcctlist
                AND StartDateTime>TODAY
                AND EUR_CRM_Route_Template_Item__c!=null
                AND EUR_CRM_Route_Template__c!=null
                ORDER BY Id
                LIMIT :Limits.getLimitDMLRows()]){

                if (Limits.getDMLStatements() < (Limits.getLimitDMLStatements()-10)){
                    Database.delete(evList);
                }
                else{
                    break;
                }
            }
        }
    }
}