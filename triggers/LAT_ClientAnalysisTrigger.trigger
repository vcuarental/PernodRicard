trigger LAT_ClientAnalysisTrigger on LAT_ClientAnalysis__c (before insert, before update) {
    if(Trigger.isInsert || Trigger.isUpdate){
        if(Trigger.isBefore){
            LAT_SalesAcademy.setAnalysisRecordType(Trigger.new);
        }


    }
}