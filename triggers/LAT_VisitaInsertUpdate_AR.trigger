trigger LAT_VisitaInsertUpdate_AR on Visitas__c (before insert, before update, after insert, after update) {
     //Filtrado de RecordTypes de Argentina  LAT_Trigger trigger_AR = new LAT_Trigger('Visitas__c', new Set<String>{'VTS_Standard_AR', 'VTS_Standard_UY'});
 if(trigger.isAfter){
    LAT_Trigger trigger_AR = new LAT_Trigger('Visitas__c', new Set<String>{'VTS_Standard_AR', 'VTS_Standard_UY'});
    
    if(trigger.isUpdate && !trigger_AR.getNew().IsEmpty()){
        LAT_BR_AP01_Visita.updateEvent(trigger_AR.getNew(),new map<Id,Visitas__c>((List<Visitas__c>)trigger_AR.getOld()));
    }

    LAT_Trigger trigger_ARToShare = new LAT_Trigger('Visitas__c', new Set<String>{'VTS_Standard_AR'});
    
    if(trigger.isInsert && !trigger_ARToShare.getNew().isEmpty()){

        AP01_Visita_AR.shareRecordsWithAccountOwner(trigger_ARToShare.getNew());
    }
 }
 if(trigger.isBefore){
    Set<Id> setIdRt = Global_RecordTypeCache.getRtIdSet('Visitas__c', new Set<String>{'VTS_Standard_AR', 'VTS_Standard_UY'});
    List<Visitas__c> triggerNew_AR = new List<Visitas__c>();
    Map<Id, Visitas__c> triggerOldMap_AR;
    for(Visitas__c acc: trigger.new){
        if(setIdRt.contains(acc.RecordTypeId) ){
            triggerNew_AR.add(acc);
            if(trigger.isUpdate){
                if(triggerOldMap_AR == null){triggerOldMap_AR = new Map<Id, Visitas__c>();}
                triggerOldMap_AR.put(trigger.oldMap.get(acc.id).id, trigger.oldMap.get(acc.id));
            }
        }
    }
    //Llamadas a metodos unicos para AR
    if(!triggerNew_AR.IsEmpty()){
        AP01_Visita_AR.generateName(triggerNew_AR);
        AP01_Visita_AR.visitaClientWorkHours(triggerNew_AR);
    }
  }
}