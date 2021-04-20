trigger LAT_SWOTTrigger on LAT_SWOTAnalysis__c (before insert, before update) {
    if(Trigger.isInsert || Trigger.isUpdate){
        if(Trigger.isBefore){
            LAT_SalesAcademy.setSWOTRecordType(Trigger.new);
        }


    }
}