/***************************************************************************
*   Company:Valuenet  Developers: Elena Waldemar Mayo  Date:16/10/2013     *
****************************************************************************/

trigger VisitaBeforeInsertUpdate_AR on Visitas__c (before insert, before update) {
	
    //Filtrado de RecordTypes de Argentina
    /*Set<Id> setIdRt = Global_RecordTypeCache.getRtIdSet('Visitas__c', new Set<String>{'VTS_Standard_AR', 'VTS_Standard_UY'});
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
    */
}