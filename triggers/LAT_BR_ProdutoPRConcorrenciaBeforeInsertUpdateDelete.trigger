/*******************************************************************************************
*        Company:Valuenet      Developers:Elena Schwarzböck        Date:06/11/2013         *
********************************************************************************************/

trigger LAT_BR_ProdutoPRConcorrenciaBeforeInsertUpdateDelete on Produto_Concorr_ncia__c (before update, before delete, after update, after insert) {
        
    //Filtrado de RecordTypes
    LAT_Trigger trigger_BR = new LAT_Trigger('Produto_Concorr_ncia__c', new set<String>{'BRA_Standard'});
    
    
    //Ejecucion de metodos especificos para BR   
    if (trigger.isBefore) {
        /*if(trigger.isDelete && !trigger_BR.getOld().IsEmpty()){
            LAT_BR_AP01_ProdutoPRConcorrencia.ValidationCreateEditDelete(trigger_BR.getOld());
        }*/ 

        if(trigger.isUpdate && !trigger_BR.getNew().IsEmpty()){
            LAT_BR_AP01_ProdutoPRConcorrencia.ValidationCreateEditDelete(trigger_BR.getNew()); 
        }   
    } else if (trigger.isAfter) {
        if(trigger.isUpdate && !trigger_BR.getNew().IsEmpty()){
            LAT_BR_AP01_ProdutoPRConcorrencia.updatesKey(trigger_BR.getNew(),new map<Id,Produto_Concorr_ncia__c>((List<Produto_Concorr_ncia__c>)trigger_BR.getOld()));
        }else if(trigger.isInsert && !trigger_BR.getNew().IsEmpty()){
            LAT_BR_AP01_ProdutoPRConcorrencia.updatesKey(trigger_BR.getNew(),null);
        }    
    }

}