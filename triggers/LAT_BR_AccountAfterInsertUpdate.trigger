trigger LAT_BR_AccountAfterInsertUpdate on Account (after insert, after update) {
    
    final Set<Id> setIdRecordType = Global_RecordTypeCache.getRtIdSet('Account', AP01_Account_BR.BR_RECORDTYPES);
    List <Account> triggerNew_BR = new List <Account>();
    Map <Id, Account> triggerOldMap_BR;
    
    // Filter by Record Type
    for (Account acc: trigger.new) {
        if (setIdRecordType.contains(acc.RecordTypeId)) {
            triggerNew_BR.add(acc);
            if (trigger.isUpdate) {
                if (triggerOldMap_BR == null) { triggerOldMap_BR = new Map <Id, Account>(); }
                triggerOldMap_BR.put(trigger.oldMap.get(acc.id).id, trigger.oldMap.get(acc.id));
            }
        }
    }
    
    // Execute methods
    if (!triggerNew_BR.isEmpty()) {
        if (trigger.isInsert) {
            AP01_Account_BR.LATAccount(triggerNew_BR);
        }
        if (trigger.isUpdate) {
            AP01_Account_BR.updatesAreaRegionalManager(triggerNew_BR,triggerOldMap_BR);
            LAT_WS_TR_CustomerAfterUpdateProcesses.updateCustomerStatusToRegisteredBR(triggerNew_BR);
        }

        // Methods that should execute after insert or update
        if(!Test.isRunningTest()){
            AP01_Account_BR.customerInterfaceCall(triggerNew_BR);
        }
    }
}