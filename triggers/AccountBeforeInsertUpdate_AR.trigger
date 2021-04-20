/*******************************************************************************************
*   Company:Valuenet    Developers:Elena Schwarzböck-Tomás Etchegaray    Date:21/03/2013    *
********************************************************************************************/

trigger AccountBeforeInsertUpdate_AR on Account (before insert, before update) {
    
    //Filtrado de RecordTypes de Argentina
    set<Id> setIdRt = Global_RecordTypeCache.getRtIdSet('Account',new set<String>{'ACC_1_OffTrade_ARG', 'ACC_3_OnTrade_ARG', 'ACC_5_Events_ARG', 'ACC_2_OffTrade_URU', 'ACC_4_OnTrade_URU', 'ACC_6_Events_URU'});
    List<Account> triggerNew_AR = new List<Account>();
    map<Id, Account> triggerOldMap_AR;
    for(Account acc: trigger.new){
        if(setIdRt.contains(acc.RecordTypeId) ){
            triggerNew_AR.add(acc);
            if (trigger.isUpdate){
                if(triggerOldMap_AR==null){triggerOldMap_AR = new map<Id, Account>();}
                triggerOldMap_AR.put(trigger.oldMap.get(acc.id).id,trigger.oldMap.get(acc.id));
            }
        }
    }
    
    //Llamadas a metodos unicos para AR
    if(!triggerNew_AR.isEmpty()){
        AP01_Account_AR.UpdateCNPJChildAccount(triggerNew_AR);
        AP01_Account_AR.GrandSonValidate(triggerNew_AR);
        AP01_Account_AR.moneyConvertToUSD(triggerNew_AR);
        AP01_Account_AR.updatesInformationUnfilled(triggerNew_AR);
        AP01_Account_AR.setDefaultPaymentInstrument(triggerNew_AR);
        
        if (trigger.isUpdate){
            AP01_Account_AR.ValidationCreditLine(triggerNew_AR, triggerOldMap_AR);
            AP01_Account_AR.TrueToFalse(triggerOldMap_AR, triggerNew_AR);
            AP01_Account_AR.UpdateClientCountryAN8(triggerNew_AR, triggerOldMap_AR);
            AP01_Account_AR.ValidationCNPJduplicateARG(triggerNew_AR,'update');
            LAT_WS_TR_CustomerAfterUpdateProcesses.submitCustomerForApprovalAR(triggerNew_AR);
        }
        if(trigger.isInsert){
            AP01_Account_AR.ValidationCNPJduplicateARG(triggerNew_AR,'insert');        
        }
    }
}