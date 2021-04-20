/*******************************************************************************************
*   Company:Valuenet             Developers:Elena Schwarzböck           Date:12/11/2013    *
********************************************************************************************/

trigger LAT_MX_OpportunityBefore on Opportunity (before insert, before update, before delete) {

    //Filtrado de RecordTypes
    LAT_Trigger trigger_MX = new LAT_Trigger('Opportunity', new set<String>{'LAT_MX_OPP_HeaderBlocked','LAT_MX_OPP_NewOrder','LAT_MX_OPP_OrderBlocked'});
            
    //Ejecucion de metodos especificos para MX
    if(trigger_MX.getNew()!= null && !trigger_MX.getNew().IsEmpty()){
        LAT_MX_AP01_Opportunity.parentCustomerUpdate((List<Opportunity>)trigger_MX.getNew());
        if(trigger.isInsert){
            LAT_MX_AP01_Opportunity.initialStageUpdate((List<Opportunity>)trigger_MX.getNew());
        }
        if(trigger.isUpdate){
            LAT_MX_AP01_Opportunity.salesOrderHandlerInterfaceAfterAP((List<Opportunity>)trigger_MX.getNew(),new Map<Id,Opportunity>((List<Opportunity>)trigger_MX.getOld()));
            LAT_MX_AP01_Opportunity.updatesKAMPromisedDate(new Map<Id,Opportunity>((List<Opportunity>)trigger_MX.getNew()),new Map<Id,Opportunity>((List<Opportunity>)trigger_MX.getOld()));
        }
    }else if(trigger_MX.getNew() == null && !trigger_MX.getOld().IsEmpty()){
        if(trigger.isDelete){
            LAT_MX_AP01_Opportunity.ValidationOnDelete((List<Opportunity>)trigger_MX.getOld());
        }
    }
    
}