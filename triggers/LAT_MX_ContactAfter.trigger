/***************************************************************************
*   Company:Valuenet  Developers: Elena J. Schwarzböck  Date:19/02/2014    *
****************************************************************************/

trigger LAT_MX_ContactAfter on Contact (before insert, before update, after insert, after update, after delete) {

    //Filtrado de RecordTypes
    LAT_Trigger trigger_MX = new LAT_Trigger('Contact', new set<String>{'LAT_MX_CTC_Standard'});
    
    //Ejecucion de metodos especificos para MX
    if(trigger_MX.getNew() != null && !trigger_MX.getNew().IsEmpty()){
        if(trigger.isInsert){
            LAT_MX_AP01_Contact.updatesInformationUnfilled(trigger_MX.getNew(), null);
        }
        if(trigger.isUpdate){
            LAT_MX_AP01_Contact.updatesInformationUnfilled(trigger_MX.getNew(), new map<Id,Contact>((List<Contact>)trigger_MX.getOld()));
        }            
    }
    if(trigger_MX.getOld() != null && !trigger_MX.getOld().IsEmpty()){
        if(trigger.isDelete){
            LAT_MX_AP01_Contact.updatesInformationUnfilled(null, new map<Id,Contact>((List<Contact>)trigger_MX.getOld()));
        }   
    }

    if(trigger.isBefore && trigger.isInsert){

        LAT_MX_AP01_Contact.copyDescriptionToCaracteristicas(trigger_MX.getNew());
    }
    if(trigger.isBefore && trigger.isUpdate){

        LAT_MX_AP01_Contact.copyDescriptionToCaracteristicas(trigger_MX.getNew());

    }
}