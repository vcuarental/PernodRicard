/*******************************************************************************************
*        Company:Valuenet      Developers:Elena Schwarzböck        Date:28/10/2013         *
********************************************************************************************/

trigger LAT_MX_PlanejamentoBefore on Planejamento__c (after insert, before insert) {

    //Filtrado de RecordTypes
    LAT_Trigger trigger_MX = new LAT_Trigger('Planejamento__c', new set<String>{'LAT_MX_PLV_NewPlanning'});
        
    //Ejecucion de metodos especificos para MX
    if(!trigger_MX.getNew().IsEmpty()){
        if(trigger.isAfter){
            LAT_MX_AP01_Planejamento.newPlanejamentoValidations(trigger_MX.getNew());
        }
        if(trigger.isBefore){
            LAT_MX_AP01_Planejamento.changeNametoPlanejamento(trigger_MX.getNew());
        }

    }

}