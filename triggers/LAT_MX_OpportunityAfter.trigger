/*******************************************************************************************
*   Company:Valuenet             Developers:Elena Schwarzböck           Date:12/12/2013    *
********************************************************************************************/

trigger LAT_MX_OpportunityAfter on Opportunity (after delete) {

    //Filtrado de RecordTypes
    LAT_Trigger trigger_MX = new LAT_Trigger('Opportunity', new set<String>{'LAT_MX_OPP_HeaderBlocked','LAT_MX_OPP_NewOrder','LAT_MX_OPP_OrderBlocked'});
            
    //Ejecucion de metodos especificos para MX
    if(!trigger_MX.getOld().IsEmpty()){
        LAT_MX_AP02_OpportunityWOS.updatesAvailableCreditLimit(new Map<Id,Opportunity>((List<Opportunity>)trigger_MX.getOld()));
    }
}