trigger EUR_CRM_DE_Contract_BeforeDelete on EUR_CRM_Contract__c (before delete) {
    String DRAFT_CONTRACT_TRANSACTION = 'Draft Contract Transaction';
    Id draftTransactionRecordType = [SELECT Id from RecordType where developername = 'EUR_DE_On_Trade_WKZ_Draft_Transaction' and sobjecttype = 'EUR_CRM_Budget_Transaction__c'].id;
    Set<Id> contractIds = new Set<Id>();
    
    for (EUR_CRM_Contract__c  contract:  (List<EUR_CRM_Contract__c>)System.Trigger.old){
        contractIds.add(contract.Id);
    }
    
    try{
        if (contractIds.size()>0){
            List<EUR_CRM_Budget_Transaction__c> draftTransactions = new List<EUR_CRM_Budget_Transaction__c>();
            for (EUR_CRM_Budget_Transaction__c draftTxn: [SELECT Id, RecordTypeId  FROM EUR_CRM_Budget_Transaction__c
                                                        WHERE EUR_CRM_Contract__c IN: contractIds
                                                        AND EUR_CRM_Transaction_Category__c =:DRAFT_CONTRACT_TRANSACTION
                                                        AND RecordTypeId =: draftTransactionRecordType
                                                         ])
            {
                draftTransactions.add(draftTxn);
            }
            
            if (draftTransactions.size()>0){
                Database.delete(draftTransactions);
            }
        }
    }catch(Exception e){
        System.debug('EUR_CRM_DE_Contract_AfterDelete  Error:' + e);
    }

}