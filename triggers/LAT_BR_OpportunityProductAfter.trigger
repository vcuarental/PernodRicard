/*******************************************************************************************
 *  Company:Valuenet             Developers:Nicolas Javier Romero           Date:27/11/2013*
 *******************************************************************************************/

trigger LAT_BR_OpportunityProductAfter on OpportunityLineItem (after insert, after update, after delete) {
    
    //Filtro por el RecordType de la oportunidad
    Set<Id> setOppRt = Global_RecordTypeCache.getRtIdSet('Opportunity', new set<String>{'Bloqueia_alteracao', 'Bloqueia_alteracao_do_cabecalho', 'Nova_oportunidade'});
    
    List<OpportunityLineItem> triggerNew_BR = new List<OpportunityLineItem>();
    List<OpportunityLineItem> triggerOld_BR = new List<OpportunityLineItem>();
    
    if(trigger.isDelete){
        for(OpportunityLineItem oli :trigger.old){
            if(setOppRt.contains(oli.LAT_OpportunityRecordTypeId__c)){
                triggerOld_BR.add(oli);
            }
        }
    }
    if(trigger.isUpdate || trigger.isInsert){
        for(OpportunityLineItem oli :trigger.new){
            if(setOppRt.contains(oli.LAT_OpportunityRecordTypeId__c)){
                triggerNew_BR.add(oli);
            }
        }
    }
    
    //Llamadas a los metodos 
    /*if( (!triggerNew_BR.isEmpty()) || (!triggerOld_BR.isEmpty()) ){
        LAT_BR_AP01_OpportunityLineItem.updateStatusOpportunity(triggerNew_BR, triggerOld_BR, trigger.oldMap);
    }*/
    
}