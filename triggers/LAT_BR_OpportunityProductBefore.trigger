/*******************************************************************************************
 *  Company:Valuenet             Developers:Nicolas Javier Romero           Date:27/11/2013*
 *******************************************************************************************/

trigger LAT_BR_OpportunityProductBefore on OpportunityLineItem (before insert, before update) {
    
    //Filtro por el RecordType de la oportunidad
    Set<Id> setOppRt = Global_RecordTypeCache.getRtIdSet('Opportunity', new set<String>{'Bloqueia_alteracao', 'Bloqueia_alteracao_do_cabecalho', 'Nova_oportunidade'});
    List<OpportunityLineItem> triggerNew_BR = new List<OpportunityLineItem>();
    
    if(trigger.isUpdate || trigger.isInsert){
        for(OpportunityLineItem oli :trigger.new){
            if(oli.OpportunityId != null){
                if(setOppRt.contains(oli.LAT_OpportunityRecordTypeId__c)){
                    triggerNew_BR.add(oli);
                }
            }
        }
    }
    
    //Llamadas a los metodos 
    if(!triggerNew_BR.isEmpty()){
        LAT_BR_AP01_OpportunityLineItem.decodeCompositionPrice(triggerNew_BR);
    }
}