/*******************************************************************************************
*        Company:Valuenet      Developers:Denis Aranda        Date:01/10/2013              *
********************************************************************************************/

trigger LAT_BR_VisitaBeforeInsertUpdate on Visitas__c(before insert, before update, after update) {
    
    //Filtrado de RecordTypes
    LAT_Trigger trigger_BR = new LAT_Trigger('Visitas__c',new set<String>{'BRA_Standard'});
    
    if(trigger.isBefore && !trigger_BR.getNew().IsEmpty()){
        LAT_BR_AP01_Visita.fieldsCreater(trigger_BR.getNew());
    }

    if(trigger.isAfter && trigger.isUpdate && !trigger_BR.getNew().IsEmpty()){
        LAT_BR_AP01_Visita.updatesPPCKey(trigger_BR.getNew(),new map<Id,Visitas__c>((List<Visitas__c>)trigger_BR.getOld()));
    	LAT_BR_AP01_Visita.updateEvent(trigger_BR.getNew(),new map<Id,Visitas__c>((List<Visitas__c>)trigger_BR.getOld()));
    	LAT_BR_AP01_Visita.sendTAAIfClosed(trigger_BR.getNew(), new map<Id,Visitas__c>((List<Visitas__c>)trigger_BR.getOld()));
    }
    
}