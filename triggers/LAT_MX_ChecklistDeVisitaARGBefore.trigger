/*******************************************************************************************
*        Company:Valuenet      Developers:Elena Schwarzböck        Date:31/10/2013         *
********************************************************************************************/

trigger LAT_MX_ChecklistDeVisitaARGBefore on CLV_ChecklistVisita_ARG__c (before insert, before update, before delete) {

    List<RecordType> listRt = new List<RecordType>();
    
    listRt = Global_RecordTypeCache.getRtList('CLV_ChecklistVisita_ARG__c');
    
    Set<String> setRt = new Set<String>();
    
    for(RecordType rt: listRt){
        if(rt.DeveloperName.contains('LAT_MX_')){
            setRt.add(rt.DeveloperName);
        }
    }

    //Filtrado de RecordTypes
    LAT_Trigger trigger_MX = new LAT_Trigger('CLV_ChecklistVisita_ARG__c', setRt);
              
    //Ejecucion de metodos especificos para MX
    if((trigger.isInsert || trigger.isUpdate) && !trigger_MX.getNew().IsEmpty()){
        LAT_MX_AP01_ChecklistDeVisitaARG.updatesChecklistName(trigger_MX.getNew());
    }
    if(trigger.isDelete && !trigger_MX.getOld().isEmpty()){
        LAT_MX_AP01_ChecklistDeVisitaARG.deleteValidation(trigger_MX.getOld());
    }

}