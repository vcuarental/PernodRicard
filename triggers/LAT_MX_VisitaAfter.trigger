/*******************************************************************************************
*        Company:Valuenet      Developers:Elena Schwarzböck        Date:17/10/2013         *
********************************************************************************************/
trigger LAT_MX_VisitaAfter on Visitas__c (after insert, after update, before update) {
    
    //Filtrado de RecordTypes
    LAT_Trigger trigger_MX = new LAT_Trigger('Visitas__c', new set<String>{'LAT_MX_VTS_ClosedVisit','LAT_MX_VTS_PlannedVisit','LAT_MX_VTS_ClosedVisitON','LAT_MX_VTS_PlannedVisitON','LAT_MX_CheckIn'});
        
    //Ejecucion de metodos especificos para MX
    if(!trigger_MX.getNew().IsEmpty()){
        if(trigger.isInsert){
            LAT_MX_AP01_Visita.createsEventForEachVisit(trigger_MX.getNew());
        }
        if(trigger.isUpdate) {
            System.debug('%%%% oldmap visitas : '  + trigger_MX.getOld());
        	LAT_BR_AP01_Visita.updateEvent(trigger_MX.getNew(),new map<Id,Visitas__c>((List<Visitas__c>)trigger_MX.getOld()));
                
        }
        if(trigger.isBefore && trigger.isUpdate){
            LAT_MX_AP01_Visita.calculateMinutes(trigger_MX.getNew(), new map<Id,Visitas__c>((List<Visitas__c>)trigger_MX.getOld()));
        }
    }
}