/*****************************************************************************************
* Empresa: Valuenet
* Descripcion: verifica semana Planejamentos
* Desarrollador: Denis Aranda
* Fecha: 23/09/2013
* Modo: before insert, before update
*****************************************************************************************/
trigger LAT_BR_PlanejamentoBeforeInsertUpdate on Planejamento__c(before insert, before update, after update){
    
    set<Id> setIdRt = Global_RecordTypeCache.getRtIdSet('Planejamento__c',new set<String>{'BRA_Standard'});
    
    List<Planejamento__c> triggerNew_BR = new List<Planejamento__c>();
    map<Id,Planejamento__c> triggerOldMap_BR = new map<Id, Planejamento__c>();
    for(Planejamento__c acc: trigger.new){
        if(setIdRt.contains(acc.RecordTypeId) ){
            triggerNew_BR.add(acc);
            if (trigger.isUpdate){
                triggerOldMap_BR.put(trigger.oldMap.get(acc.id).id,trigger.oldMap.get(acc.id));
            }
        }
    }
    
    if(!triggerNew_BR.IsEmpty() && trigger.isBefore){
        if(trigger.isInsert){
            LAT_BR_AP01_Planejamento.nameCreater(triggerNew_BR);
            LAT_BR_AP01_Planejamento.checkPlansExists(triggerNew_BR);
        }
        if(trigger.isUpdate) {
            LAT_BR_AP01_Planejamento.PlanejamentoVerificaSegunda(triggerNew_BR, triggerOldMap_BR);
        }
        
    }
    
    if(!triggerNew_BR.IsEmpty() && trigger.isAfter && trigger.isUpdate){
        LAT_BR_AP01_Planejamento.updatesPPCKey(triggerNew_BR, triggerOldMap_BR);
    }
    
}