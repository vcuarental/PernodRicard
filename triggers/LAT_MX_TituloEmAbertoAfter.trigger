/*******************************************************************************************
*        Company:Valuenet      Developers:Elena Schwarzböck        Date:09/12/2013         *
********************************************************************************************/

trigger LAT_MX_TituloEmAbertoAfter on Titulos__c (after insert, after update, after delete){

    //Filtrado de RecordTypes
    LAT_Trigger trigger_MX = new LAT_Trigger('Titulos__c', new set<String>{'LAT_MX_TEA_Standard'});
    
    //Ejecucion de metodos especificos para MX
    if((trigger_MX.getNew() != null && !trigger_MX.getNew().IsEmpty()) || (trigger_MX.getOld() != null && !trigger_MX.getOld().IsEmpty())){
        if(trigger.isInsert){
            LAT_MX_AP02_TituloEmAbertoWOS.updatesAvailableCreditLimit(trigger_MX.getNew(),null);
        }
        if(trigger.isUpdate || trigger.isDelete){
            LAT_MX_AP02_TituloEmAbertoWOS.updatesAvailableCreditLimit(trigger_MX.getNew(),new Map<Id,Titulos__c>((List<Titulos__c>)trigger_MX.getOld()));
        }
    }

}