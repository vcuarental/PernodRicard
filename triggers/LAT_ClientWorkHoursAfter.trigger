/*************************************************************************
*Company:Valuenet      Developers: Denis Aranda       Date:23/10/2013    *
*************************************************************************/

trigger LAT_ClientWorkHoursAfter on LAT_CWH_ClientWorkHour__c (after insert) {
    
    //Filtrado de RecordTypes
    LAT_Trigger trigger_LAT = new LAT_Trigger('LAT_CWH_ClientWorkHour__c', new set<String>{'LAT_AR_CWH_Standard', 'LAT_UY_CWH_Standard', 'LAT_BR_CWH_Standard', 'LAT_MX_CWH_Standard'});
    
    if(!trigger_LAT.getNew().IsEmpty()){
        if(trigger.isInsert){
            LAT_AP01_ClientWorkHours.relatesCWHToLATAccount(trigger_LAT.getNew());
        }
    }
}