trigger LAT_StrategicObjectivesTrigger on LAT_StrategicObjectives__c (before insert, before update) {
    if(Trigger.isInsert || Trigger.isUpdate){
        if(Trigger.isBefore){
            LAT_SalesAcademy.setStrategicObjectivesRecordType(Trigger.new);
        }


    }
}