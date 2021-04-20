/*
    Accrues RU achievements and update O/P targets

*/

global class EUR_CRM_RU_AccrueAchievements implements Database.Batchable<sObject> {

    global Set<String> validVisitActionRecordTypes = new Set<String>{'EUR_RU_ON_Enter_Promo_Kit_Quantity','EUR_RU_OFF_ConfParticipationLoyaltyPOSMPlacement'};
    global final Set<String> QUANTITY_BASED = new Set<String>{'EUR_RU_ON_Enter_Promo_Kit_Quantity'};
    global final Set<String> VOLUME_BASED = new Set<String>{'EUR_RU_OFF_ConfParticipationLoyaltyPOSMPlacement'};
    global String query;  

    global EUR_CRM_RU_AccrueAchievements(){
        String q    =   'SELECT Id, RecordTypeId, RecordType.DeveloperName, OwnerId, EUR_CRM_ObjPromo__c, EUR_CRM_ObjPromo_Target__c, EUR_CRM_Account__c, ' 
                    +   'EUR_CRM_Status__c, EUR_CRM_Is_Accrued__c, EUR_CRM_Promo_Kit_Quantity__c, '
                    +   'EUR_CRM_ObjPromo_Target__r.EUR_CRM_Actual_Quantity_Promo_Kits__c, EUR_CRM_ObjPromo_Target__r.EUR_CRM_Actual_Volume_Bottles__c, '
                    +   'EUR_CRM_ObjPromo_Target__r.EUR_CRM_O_P_Target__c '
                    +   'FROM EUR_CRM_Visit_Action__c '
                    +   'WHERE RecordType.DeveloperName IN: validVisitActionRecordTypes '
                    +   'AND EUR_CRM_Entitle_Achievement__c = TRUE '
                    +   'AND EUR_CRM_Is_Accrued__c = FALSE';
                    
        query = q;
    }


    global Database.QueryLocator start(Database.BatchableContext BC){
        System.debug(query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject>scope){
        System.debug(scope);
        accrue((List<EUR_CRM_Visit_Action__c>) scope);
    }
   
    global void finish(Database.BatchableContext BC){
    }

    /*
        Main logic
    */
    private void accrue(List<EUR_CRM_Visit_Action__c> visitActionList){      
        List<EUR_CRM_ObjPromo_Target__c> targetsToUpdate = new List<EUR_CRM_ObjPromo_Target__c>();
        List<EUR_CRM_Visit_Action__c> visitActionToUpdate = new List<EUR_CRM_Visit_Action__c>();
        Set<Id> targetsSetIds = new Set<Id>();
        Map<Id, EUR_CRM_ObjPromo_Target__c> targetsMap;

        for(EUR_CRM_Visit_Action__c visitAction : visitActionList){
            if(visitAction.EUR_CRM_ObjPromo_Target__c != null){
                targetsSetIds.add(visitAction.EUR_CRM_ObjPromo_Target__c);
                targetsSetIds.add(visitAction.EUR_CRM_ObjPromo_Target__r.EUR_CRM_O_P_Target__c);
            }
        }

        if(targetsSetIds.size() > 0){
            targetsMap = new Map<Id, EUR_CRM_ObjPromo_Target__c>([SELECT Id, EUR_CRM_Actual_Quantity_Promo_Kits__c, EUR_CRM_Actual_Volume_Bottles__c, EUR_CRM_O_P_Target__c FROM EUR_CRM_ObjPromo_Target__c WHERE ID IN: targetsSetIds]);
            
            if(targetsMap.KeySet().size() > 0){
            
                System.debug(visitActionList);
                System.debug(targetsMap);
                try {
                    for(EUR_CRM_Visit_Action__c visitAction : visitActionList){
                        if(visitAction.EUR_CRM_ObjPromo_Target__c != null && targetsMap.get(visitAction.EUR_CRM_ObjPromo_Target__c) != null){

                            EUR_CRM_ObjPromo_Target__c target = targetsMap.get(visitAction.EUR_CRM_ObjPromo_Target__c);

                            if(QUANTITY_BASED.contains(visitAction.RecordType.DeveloperName)){
                                if(visitAction.EUR_CRM_Promo_Kit_Quantity__c != null &&
                                   visitAction.EUR_CRM_ObjPromo_Target__c != null &&
                                   visitAction.EUR_CRM_Status__c == 'Yes')
                                {
                                    Decimal quantity = (Decimal.valueOf(visitAction.EUR_CRM_Promo_Kit_Quantity__c));
                                    target.EUR_CRM_Actual_Quantity_Promo_Kits__c += quantity;
                                    visitAction.EUR_CRM_Is_Accrued__c = true;
                                    visitActionToUpdate.add(visitAction);
                                    targetsToUpdate.add(target); 
                                    if(target.EUR_CRM_O_P_Target__c != null && targetsMap.get(target.EUR_CRM_O_P_Target__c) != null){
                                        targetsMap.get(target.EUR_CRM_O_P_Target__c).EUR_CRM_Actual_Quantity_Promo_Kits__c += quantity;
                                        targetsToUpdate.add(targetsMap.get(target.EUR_CRM_O_P_Target__c)); 
                                    }
                                }
                            }
                            else if(VOLUME_BASED.contains(visitAction.RecordType.DeveloperName)){
                                if(visitAction.EUR_CRM_ObjPromo_Target__c != null && visitAction.EUR_CRM_Status__c == 'Participating')
                                {
                                    if(target.EUR_CRM_Actual_Volume_Bottles__c == null){
                                        target.EUR_CRM_Actual_Volume_Bottles__c = 1;
                                    }
                                    else{
                                        target.EUR_CRM_Actual_Volume_Bottles__c += 1;
                                    }
                                    visitAction.EUR_CRM_Is_Accrued__c = true;
                                    visitActionToUpdate.add(visitAction);
                                    targetsToUpdate.add(target);
                                    //if(target.EUR_CRM_O_P_Target__c != null && targetsMap.get(target.EUR_CRM_O_P_Target__c) != null){
                                    //    EUR_CRM_ObjPromo_Target__c parentTarget = targetsMap.get(target.EUR_CRM_O_P_Target__c);
                                    //    if(parentTarget.EUR_CRM_Actual_Volume_Bottles__c == null){
                                    //        parentTarget.EUR_CRM_Actual_Volume_Bottles__c = 1;
                                    //    }
                                    //    else{
                                    //        parentTarget.EUR_CRM_Actual_Volume_Bottles__c += 1;
                                    //    }
                                    //    targetsToUpdate.add(parentTarget);
                                    //}
                                }
                            }
                        }
                    }
                } catch(Exception e){
                    System.debug(e);
                }

                System.debug(targetsToUpdate);
                System.debug(visitActionToUpdate);

                if(targetsToUpdate.size() > 0 && visitActionToUpdate.size() > 0){
                    try{
                        update visitActionToUpdate;
                        update targetsToUpdate;
                    }
                    catch(Exception e){
                        System.debug(e);
                    }
                }
            }
        }
    }
}