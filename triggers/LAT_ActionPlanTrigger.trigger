trigger LAT_ActionPlanTrigger on LAT_ActionPlan__c (before insert, before update) {
    if(Trigger.isInsert || Trigger.isUpdate){
        if(Trigger.isBefore){
            LAT_SalesAcademy.setPlanoAcaoRecordType(Trigger.new);
        }


    }
}