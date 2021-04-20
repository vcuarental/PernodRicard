/*******************************************************************************************
*   Company:Valuenet             Developers:Elena Schwarzböck           Date:29/11/2013    *
********************************************************************************************/

trigger LAT_MX_OpportunityProductAfter on OpportunityLineItem (after insert, after update, after delete) {

    //Filtrado de RecordTypes. Opportunity Product no tiene Record Type y por eso se necesito hacer un Query de las Oportunidades relacionadas
    Set<Id> setOppRt = Global_RecordTypeCache.getRtIdSet('Opportunity',new set<String>{'LAT_MX_OPP_HeaderBlocked','LAT_MX_OPP_NewOrder','LAT_MX_OPP_OrderBlocked'});
    
    List<OpportunityLineItem> triggerNew_MX = new List<OpportunityLineItem>();
    Map<Id,OpportunityLineItem> OldMap_MX = new Map<Id,OpportunityLineItem>();
    
    if(trigger.isInsert || trigger.isUpdate){
        for(OpportunityLineItem oli: trigger.New){
            if(setOppRt.contains(oli.LAT_OpportunityRecordTypeId__c)){
                triggerNew_MX.add(oli);
                if(trigger.isUpdate){
                    OldMap_MX.put(oli.Id,trigger.oldMap.get(oli.Id));
                }
            }
        }
    }else{
        for(OpportunityLineItem oli: trigger.Old){
            if(setOppRt.contains(oli.LAT_OpportunityRecordTypeId__c)){
                OldMap_MX.put(oli.Id,trigger.oldMap.get(oli.Id));
            }
        }        
    }
      
    //Ejecucion de metodos especificos para MX
    if(!triggerNew_MX.isEmpty() || !OldMap_MX.isEmpty()){
        LAT_MX_AP01_OpportunityProducts.quotaCalculation(triggerNew_MX,OldMap_MX);
        LAT_MX_AP01_OpportunityProducts.blockOrder(triggerNew_MX,OldMap_MX);
    }
    if((triggerNew_MX != null && !triggerNew_MX.isEmpty()) || (OldMap_MX != null && !OldMap_MX.isEmpty())){
        LAT_MX_AP02_OpportunityProductsWOS.updatesAvailableCreditLimit(triggerNew_MX,OldMap_MX);
    }

}