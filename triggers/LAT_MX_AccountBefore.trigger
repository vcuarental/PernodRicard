/*******************************************************************************************
*      Company:Valuenet         Developers:Elena Schwarzböck          Date:05/09/2013      *
********************************************************************************************/

trigger LAT_MX_AccountBefore on Account (before insert, before update){
    
    //Filtrado de RecordTypes
    LAT_Trigger trigger_MX = new LAT_Trigger('Account', new set<String>{'LAT_MX_ACC_OffTrade'});
            
    //Ejecucion de metodos especificos para MX
    if (trigger_MX.getNew() != null && !trigger_MX.getNew().IsEmpty()) {
        LAT_MX_AP02_AccountWOS.UpdateCNPJChildAccount(trigger_MX.getNew());
        LAT_MX_AP01_Account.ValidationRFC(trigger_MX.getNew());
        LAT_MX_AP02_AccountWOS.GrandSonValidate(trigger_MX.getNew());
        LAT_MX_AP01_Account.FielsdUpdate(trigger_MX.getNew());
        LAT_MX_AP01_Account.updatesInformationUnfilled(trigger_MX.getNew());
        
        if (Trigger.isUpdate) {
            LAT_MX_AP02_AccountWOS.ValidationCNPJduplicate(trigger_MX.getNew(),'update', new map<Id, Account>((List<Account>)trigger_MX.getOld()));
            LAT_MX_AP02_AccountWOS.ApprovalProcessFlow(trigger_MX.getNew(), new map<Id, Account>((List<Account>)trigger_MX.getOld()));
            LAT_MX_AP01_Account.FieldMissingDocumentsNewAccount(trigger_MX.getNew(), new map<Id, Account>((List<Account>)trigger_MX.getOld()));
            LAT_MX_AP01_Account.AccountInactivation(trigger_MX.getNew(), new map<Id, Account>((List<Account>)trigger_MX.getOld()));
            LAT_MX_AP01_Account.FiltersValidationUDC(trigger_MX.getNew(),new map<Id, Account>((List<Account>)trigger_MX.getOld()));           
            LAT_WS_TR_CustomerAfterUpdateProcesses.updateCustomerStatusToRegisteredBR(trigger_MX.getNew());
            LAT_MX_AP01_Account.registerAccountActivateDeactivateLATAccount(trigger_MX.getNew());
        } else if (Trigger.isInsert) {
            LAT_MX_AP02_AccountWOS.ValidationCNPJduplicate(trigger_MX.getNew(),'insert',null);
            LAT_MX_AP01_Account.FieldMissingDocumentsNewAccount(trigger_MX.getNew(), null);
            LAT_MX_AP02_AccountWOS.AccountCloneFieldToNull(trigger_MX.getNew());
            LAT_MX_AP01_Account.FiltersValidationUDC(trigger_MX.getNew(),null);           
        }
    }

    // On Trade Methods
    LAT_Trigger trigger_MX_OnTrade = new LAT_Trigger('Account', new set<String>{'LAT_MX_ACC_OnTrade'});
    if (trigger_MX_OnTrade.getNew() != null && !trigger_MX_OnTrade.getNew().IsEmpty()) {
        Map <Id, Account> oldMap = (Trigger.isInsert) ? new Map <Id, Account>() : new Map<Id, Account> ((List<Account>)trigger_MX_OnTrade.getOld());
        LAT_MX_OnTrade_Account.updateCountryCodeAn8((List<Account>)trigger_MX_OnTrade.getNew(), oldMap, Trigger.isInsert);
        LAT_MX_AP02_AccountWOS.GrandSonValidate(trigger_MX_OnTrade.getNew());

        if(Trigger.isUpdate) {
            LAT_MX_OnTrade_Account.actualizarKAMUpdate(trigger_MX_OnTrade.getNew(), new map<Id, Account>((List<Account>)trigger_MX_OnTrade.getOld()));   
            LAT_MX_OnTrade_Account.updateStatus(trigger_MX_OnTrade.getNew(),new map<Id, Account>((List<Account>)trigger_MX_OnTrade.getOld()));
            LAT_MX_OnTrade_Account.actualizarVisitas(trigger_MX_OnTrade.getNew());
            LAT_MX_AP01_Account.FiltersValidationUDC(trigger_MX_OnTrade.getNew(),new map<Id, Account>((List<Account>)trigger_MX_OnTrade.getOld()));           
            LAT_MX_OnTrade_Account.inactiveAccounts(trigger_MX_OnTrade.getNew()); 
            LAT_MX_OnTrade_Account.callOnInhabilitar((new map<Id, Account>((List<Account>)trigger_MX_OnTrade.getNew())).keySet());
        }
        if(Trigger.isInsert) {
            LAT_MX_OnTrade_Account.actualizarKAMInsert(trigger_MX_OnTrade.getNew());
            LAT_MX_AP02_AccountWOS.AccountCloneFieldToNull(trigger_MX_OnTrade.getNew());
            LAT_MX_AP01_Account.FiltersValidationUDC(trigger_MX_OnTrade.getNew(),null);           
        }
    }
}