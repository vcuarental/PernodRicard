/*****************************************************************************************
* Empresa: Valuenet
* Descripcion: Traduce el campo Status_do_Planejamento__c y nombra los Planejamentos
* Desarrollador: Nicolas Javier Romero
* Fecha: 29/05/2013
* Modo: before insert, before update
*****************************************************************************************/

trigger PlanejamentoBeforeInsertUpdate_AR on Planejamento__c (before insert, before update) {

    //El proceso translatePicklist debe correr para todos los paises
    AP01_Planejamento_AR.translatePicklist(Trigger.new);
    
    //Filtrado de RecordTypes
    LAT_Trigger trigger_AR = new LAT_Trigger('Planejamento__c', new set<String>{'PLV_Standard_AR', 'PLV_Standard_UY'});
        
    //Ejecucion de metodos especificos para AR
    if(!trigger_AR.getNew().IsEmpty()){
        if(trigger.isInsert){
	        AP01_Planejamento_AR.changeNametoPlanejamento(trigger_AR.getNew());
	    }
	    if(trigger.isUpdate){
            AP01_Planejamento_AR.verifyClosedVisits(trigger_AR.getNew(), new map<Id, Planejamento__c>((List<Planejamento__c>)trigger_AR.getOld()));
        }
    }
    
}