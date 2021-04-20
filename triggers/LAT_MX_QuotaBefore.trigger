/*******************************************************************************************
*        Company:Valuenet      Developers:Elena Schwarzböck        Date:20/11/2013         *
********************************************************************************************/

trigger LAT_MX_QuotaBefore on LAT_MX_QTA_Quota__c (before insert, before update) {

    //Filtrado de RecordTypes
    LAT_Trigger trigger_MX = new LAT_Trigger('LAT_MX_QTA_Quota__c', new set<String>{'LAT_MX_QTA_Standard'});
    
    //Ejecucion de metodos especificos para MX
    if(!trigger_MX.getNew().IsEmpty()){
        LAT_MX_AP01_Quota.validatesVigence(trigger_MX.getNew());
        if(trigger.isUpdate){
            LAT_MX_AP01_Quota.CalculateQuotaBalance(trigger_MX.getNew(),new Map<Id,LAT_MX_QTA_Quota__c>((List<LAT_MX_QTA_Quota__c>)trigger_MX.getOld()));
        }
        if(trigger.isInsert){
            LAT_MX_AP01_Quota.QuotaBalanceWhenInsert(trigger_MX.getNew());
        }
    }
}