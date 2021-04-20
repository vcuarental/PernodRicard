/*******************************************************************************************
*        Company:Valuenet      Developers:Elena Schwarzböck        Date:01/10/2013         *
********************************************************************************************/

trigger LAT_MX_CreditAnalysisBefore on CRA_CredAnalysis_ARG__c (before insert, before update) {

    //Filtrado de RecordTypes
    LAT_Trigger trigger_MX = new LAT_Trigger('CRA_CredAnalysis_ARG__c', new set<String>{'LAT_MX_CRA_Standard'});
            
    //Ejecucion de metodos especificos para MX
    if(!trigger_MX.getNew().IsEmpty()){
        if(trigger.isInsert){
            LAT_MX_AP01_CreditAnalysis.UpdatesCredAndCollectionFields(trigger_MX.getNew());
        }
        if(trigger.isUpdate){
            LAT_MX_AP01_CreditAnalysis.CreditLimitGrantedValidation(trigger_MX.getNew(), new map<Id, CRA_CredAnalysis_ARG__c>((List<CRA_CredAnalysis_ARG__c>)trigger_MX.getOld()));
        }
    }
}