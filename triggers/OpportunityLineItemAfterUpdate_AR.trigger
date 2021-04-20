/**********************************************
 Dev: Juan Pablo Cubo       Version: 1
**********************************************/

trigger OpportunityLineItemAfterUpdate_AR on OpportunityLineItem (after insert, after update, after delete) {
    
    //Filtro por el RecordType de la oportunidad
    Set<Id> setOppRt = Global_RecordTypeCache.getRtIdSet('Opportunity',new set<String>{'OPP_1_NewOrder_ARG', 'OPP_2_NewOrder_URU', 'OPP_3_HeaderBlocked_ARG', 'OPP_4_HeaderBlocked_URU', 'OPP_5_OrderBlocked_ARG', 'OPP_6_OrderBlocked_URU'});
    
    List<OpportunityLineItem> triggerNew_AR = new List<OpportunityLineItem>();
    List<OpportunityLineItem> triggerOld_AR = new List<OpportunityLineItem>();
    
    if(trigger.isDelete){
        for(OpportunityLineItem oli :trigger.old){
            if(setOppRt.contains(oli.LAT_OpportunityRecordTypeId__c)){
                triggerOld_AR.add(oli);
            }
        }
    }
    if(trigger.isUpdate || trigger.isInsert){
        for(OpportunityLineItem oli :trigger.new){
            if(setOppRt.contains(oli.LAT_OpportunityRecordTypeId__c)){
                triggerNew_AR.add(oli);
            }
        }
    }
    
    //Llamadas a los metodos
    if(!triggerNew_AR.isEmpty()){
        if(trigger.isAfter && trigger.isUpdate){
            LAT_AR_AP01_OpportunityLineItem.validateStatus(triggerNew_AR, trigger.oldMap);
            LAT_AR_AP01_OpportunityLineItem.existeItemEmBackOrder(triggerNew_AR);
        }
    } 
    if( (!triggerNew_AR.isEmpty()) || (!triggerOld_AR.isEmpty()) ){
        LAT_AR_AP01_OpportunityLineItem.updateStatusOpportunity(triggerNew_AR, triggerOld_AR, trigger.oldMap);
    }
    
}