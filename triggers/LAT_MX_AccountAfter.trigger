/***************************************************************************
*   Company:Valuenet  Developers: Elena J. Schwarzböck  Date:07/10/2013    *
****************************************************************************/

trigger LAT_MX_AccountAfter on Account (after insert, after update, after delete) {

    //Filtrado de RecordTypes
    LAT_Trigger trigger_MX = new LAT_Trigger('Account', new set<String>{'LAT_MX_ACC_OffTrade'});
    LAT_Trigger trigger_MX_OnTrade = new LAT_Trigger('Account', new set<String>{'LAT_MX_ACC_OnTrade'});

    system.debug('Ejecucion LAT_MX_AccountAfter');

    //Ejecucion de metodos especificos para MX Off Trade
    if(trigger_MX.getNew() != null && !trigger_MX.getNew().IsEmpty()){

        if(trigger.isUpdate){
            LAT_MX_AP01_Account.copyPaymentConditionToChilds(new map<Id, Account>((List<Account>)trigger_MX.getNew()),new map<Id, Account>((List<Account>)trigger_MX.getOld()));
            LAT_MX_AP01_Account.customerInterfase(trigger_MX.getNew(), new map<Id, Account>((List<Account>)trigger_MX.getOld()));
            LAT_MX_AP02_AccountWOS.updatesAvailableCreditLimit(trigger_MX.getNew(), new map<Id, Account>((List<Account>)trigger_MX.getOld()));
            LAT_WS_TR_CustomerAfterUpdateProcesses.sendCustomerEmailMX(trigger_MX.getNew(),new map<Id, Account>((List<Account>)trigger_MX.getOld()));
        }
        if(trigger.isInsert){
            LAT_MX_AP01_Account.LATAccount(trigger_MX.getNew());
            LAT_MX_AP02_AccountWOS.updatesAvailableCreditLimit(trigger_MX.getNew(), null);
        }
    }

    //Ejecucion de metodos especificos para MX On Trade
    if (trigger_MX_OnTrade.getNew() != null && !trigger_MX_OnTrade.getNew().IsEmpty()) {
        //if(trigger.isUpdate) {
            //LAT_MX_AP01_Account.customerInterfase(trigger_MX_OnTrade.getNew(), new map<Id, Account>((List<Account>)trigger_MX_OnTrade.getOld()));
            //LAT_MX_OnTrade_Account.sendForApproval(trigger_MX_OnTrade.getNew(), new map<Id, Account>((List<Account>)trigger_MX_OnTrade.getOld()));
            //LAT_MX_OnTrade_Account.validateConvenioPRMUpdate((List<Account>)trigger_MX_OnTrade.getNew());
        //}
        if (trigger.isInsert) {
            LAT_MX_AP01_Account.LATAccount(trigger_MX_OnTrade.getNew());
           // LAT_MX_OnTrade_Account.validateConvenioPRMInsert((List<Account>)trigger_MX_OnTrade.getNew());
        }
        // Se ejecuta siempre sea insert o update

        //LAT_MX_OnTrade_Account.validateConvenioPRM((new map<Id, Account>((List<Account>)trigger_MX_OnTrade.getNew())).keyset());
        if(!System.isBatch()){
            LAT_MX_OnTrade_Account.notifyOnTradeChange(trigger_MX_OnTrade.getNew());    
        }
        
    }


    if(trigger_MX.getOld() != null && !trigger_MX.getOld().IsEmpty()){
        if(trigger.isDelete){
            LAT_MX_AP02_AccountWOS.updatesAvailableCreditLimit(trigger_MX.getNew(), new map<Id, Account>((List<Account>)trigger_MX.getOld()));
        }
    }
}