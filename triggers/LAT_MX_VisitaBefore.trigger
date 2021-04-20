/*******************************************************************************************
*        Company:Valuenet      Developers:Elena Schwarzböck        Date:17/10/2013         *
********************************************************************************************/

trigger LAT_MX_VisitaBefore on Visitas__c (before insert, before update, before delete) {

    //Filtrado de RecordTypes
    LAT_Trigger trigger_MX = new LAT_Trigger('Visitas__c', new set<String>{'LAT_MX_VTS_ClosedVisit','LAT_MX_VTS_PlannedVisit','LAT_MX_VTS_ClosedVisitON','LAT_MX_VTS_PlannedVisitON','LAT_MX_CheckIn'});
        
    //Ejecucion de metodos especificos para MX
    if((trigger.isInsert || trigger.isUpdate) && !trigger_MX.getNew().IsEmpty()){
        system.debug('TOKEN trigger_MX.getNew(): '+trigger_MX.getNew());
        if(trigger.isInsert){
            LAT_MX_AP01_Visita.TypeMxValidation(trigger_MX.getNew(), null);
            LAT_MX_AP01_Visita.completesVisitNameAndChannel(trigger_MX.getNew());
        }
        if(trigger.isUpdate){
            LAT_MX_AP01_Visita.TypeMxValidation(trigger_MX.getNew(), new map<Id, Visitas__c>((List<Visitas__c>)trigger_MX.getOld()));
            LAT_MX_AP01_Visita.typesAddValidation(trigger_MX.getNew(), new map<Id, Visitas__c>((List<Visitas__c>)trigger_MX.getOld()),trigger_MX.getOld());
            LAT_MX_AP01_Visita.validatesVisitEdition(trigger_MX.getNew(), new map<Id, Visitas__c>((List<Visitas__c>)trigger_MX.getOld()));
        }
    }
    if(trigger.isDelete && !trigger_MX.getOld().isEmpty()){
        LAT_MX_AP01_Visita.deleteValidation(trigger_MX.getOld());
    }

}