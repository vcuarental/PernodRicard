/******************************************************************************************
*   Company:Valuenet    Developers:   Tomás Etchegaray                Date:22/03/2013     *
*******************************************************************************************/

trigger AccountBeforeInsertUpdate_BR on Account (before insert, before update) {
    
    //Filtrado de RecordTypes de Brasil
    LAT_Trigger trigger_BR = new LAT_Trigger('Account', AP01_Account_BR.BR_RECORDTYPES);
    
    //Llamadas a metodos unicos para BR
    if(!trigger_BR.getNew().isEmpty()){

        // Migrated to One Trigger
        //AP01_Account_BR.updatesInformationUnfilled(trigger_BR.getNew());
        AP01_Account_BR.updateUFFieldsFromUDC(trigger_BR.getNew(), null);
        //LAT_BR_AP01_AccountWOS.completeAgencyAccount(trigger_BR.getNew());
        if(trigger.isUpdate){
            AP01_Account_BR.UpdateClientCountryAN8(trigger_BR.getNew(), new map<Id, Account>((List<Account>)trigger_BR.getOld()));
            AP01_Account_BR.UpdateRegionalSalesCodDefUsuario(trigger_BR.getNew(), new map<Id, Account>((List<Account>)trigger_BR.getOld()));
            //AP01_Account_BR.RegionalUpdate(trigger_BR.getNew(), new map<Id, Account>((List<Account>)trigger_BR.getOld()));
            LAT_BR_AP01_AccountWOS.validateDuplicatesCNPJ(trigger_BR.getNew());   
            AP01_Account_BR.updatesBillingShippingBankFields(trigger_BR.getNew(), new map<Id, Account>((List<Account>)trigger_BR.getOld()));
            LAT_WS_TR_CustomerAfterUpdateProcesses.updateCustomerStatusToRegisteredBR(trigger_BR.getNew());
        }         
        if (trigger.isInsert){
            AP01_Account_BR.InsertClientCountryAN8(trigger_BR.getNew());
            AP01_Account_BR.UpdateRegionalSalesCodDefUsuario(trigger_BR.getNew(), null);
            //AP01_Account_BR.RegionalUpdate(trigger_BR.getNew(), null);
            LAT_BR_AP01_AccountWOS.validateDuplicatesCNPJ(trigger_BR.getNew());
            AP01_Account_BR.updatesBillingShippingBankFields(trigger_BR.getNew(), null);
        }
    }
}