/**********************************************
 Dev: Juan Pablo Cubo       Version: 1
**********************************************/

trigger OpportunityBeforeInsert_AR on Opportunity (before insert) {
    
    Set<Id> setOppRt = Global_RecordTypeCache.getRtIdSet('Opportunity',new set<String>{'Nova_oportunidade','OPP_1_NewOrder_ARG','OPP_2_NewOrder_URU','LAT_MX_OPP_NewOrder'});
    
    list <Id> accIds = new list<Id>();
    for (Opportunity opp : trigger.new) {
        if(setOppRt.contains(opp.RecordTypeId)){
            accIds.add(opp.AccountId);
        }
    }
    
    if(!accIds.isEmpty()){
        map <Id, Account> mapAccounts = new map <Id, Account>([SELECT Id, Name, ParentId FROM Account WHERE Id IN: accIds]);
        for (Opportunity opp : trigger.new) {
            if(opp.AccountId != null && mapAccounts.containsKey(opp.AccountId) && opp.RecordTypeId != Global_RecordTypeCache.getRtId('Opportunity' + 'LAT_MX_OPP_NewOrder')){
                opp.ParentAccount_AR__c = mapAccounts.get(opp.AccountId).ParentId;
            }
            if(opp.RecordTypeId == Global_RecordTypeCache.getRtId('Opportunity' + 'Nova_oportunidade'))
                opp.Pais__c = 1;
            else if(opp.RecordTypeId == Global_RecordTypeCache.getRtId('Opportunity' + 'OPP_2_NewOrder_URU'))
                opp.Pais__c = 5;
            else if(opp.RecordTypeId == Global_RecordTypeCache.getRtId('Opportunity' + 'OPP_1_NewOrder_ARG'))
                opp.Pais__c = 6;
            else if(opp.RecordTypeId == Global_RecordTypeCache.getRtId('Opportunity' + 'LAT_MX_OPP_NewOrder'))  
                opp.Pais__c = 12; 

            if (opp.StageName == 'Mobile Order') {
                opp.Name = mapAccounts.get(opp.AccountId).Name;
                if (opp.RecordTypeId == Global_RecordTypeCache.getRtId('Opportunity' + 'OPP_1_NewOrder_ARG') 
                    || opp.RecordTypeId == Global_RecordTypeCache.getRtId('Opportunity' + 'OPP_3_HeaderBlocked_ARG')
                    || opp.RecordTypeId == Global_RecordTypeCache.getRtId('Opportunity' + 'OPP_5_OrderBlocked_ARG')) {
                    opp.Origem_do_pedido__c = 'APP';
                }
            }
        }
    }
    
}