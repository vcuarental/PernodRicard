/**************************************************************************
*Company:Valuenet      Developers: Elena Schwarzböck       Date:05/02/2013*
***************************************************************************/

trigger LAT_BR_ClientWorkHoursAfter on LAT_CWH_ClientWorkHour__c (after insert, after update) {
    
    //Filtrado de RecordTypes
    LAT_Trigger trigger_BR = new LAT_Trigger('LAT_CWH_ClientWorkHour__c', new set<String>{'LAT_BR_CWH_Standard'});
    
    if(!trigger_BR.getNew().IsEmpty()){
        if(trigger.isInsert){
            LAT_BR_AP01_ClientWorkHours.ClientWorkHourDaysMissingUpdate(trigger_BR.getNew(),null);
        }
        if(trigger.isUpdate){
            LAT_BR_AP01_ClientWorkHours.ClientWorkHourDaysMissingUpdate(trigger_BR.getNew(),new map<Id, LAT_CWH_ClientWorkHour__c>((List<LAT_CWH_ClientWorkHour__c>)trigger_BR.getOld()));
        }
    }
}