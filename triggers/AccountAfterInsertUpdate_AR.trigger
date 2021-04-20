/*************************************************************************
*   Company:Valuenet          Developers: Waldemar Mayo          Date:30/04/2013    *
*************************************************************************/

trigger AccountAfterInsertUpdate_AR on Account (after insert, after update) {
	
	//Filtrado de RecordTypes de Argentina
    set<Id> setIdRt = Global_RecordTypeCache.getRtIdSet('Account',new set<String>{'ACC_1_OffTrade_ARG', 'ACC_3_OnTrade_ARG', 'ACC_5_Events_ARG', 'ACC_2_OffTrade_URU', 'ACC_4_OnTrade_URU', 'ACC_6_Events_URU', 'LAT_AR_Prospect'});
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
		if(trigger.isUpdate && trigger.isAfter){
    		AP01_Account_AR.customerInterfase(triggerNew_AR, triggerOldMap_AR, System.isBatch());
		}
    	if(trigger.isInsert && trigger.isAfter){
    		AP01_Account_AR.LATAccount(triggerNew_AR);
    	}
	}
}