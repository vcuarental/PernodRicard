/*******************************************************************************
 *  Summary         : Batch Job Class to delete Aggregated Sub-brand Volume, after deleting volume, process ASI_CRM_CN_OffVolumeAggregationJob class
 *  Refer Object    : 
 *  Author          : Zhonghui Li
 *  CreatedDate     : 2020-11-06
 *  Change Log      : 
 ******************************************************************************/
global class ASI_CRM_CN_OffVolumeDeleteJob implements Database.Batchable<sObject> {
    public String query;
    private final static List<String> RECORD_TYPE_LIST_AGGREGATION = new List<String> {
        'ASI_CRM_CN_WS_Outlet_Brand_Monthly_Volume',
        'ASI_CRM_CN_WS_Outlet_Region_Monthly_Volume',
        'ASI_CRM_CN_WS_Outlet_Category_Monthly_Volume',
        'ASI_CRM_CN_WS_Outlet_CTD_Sub_Brand_Data',
        'ASI_CRM_CN_WS_Outlet_Monthly_Sub_Brand_Data'
    };
    global Set<Id> contractIdSet  {get;set;} {contractIdSet = new Set<Id>();}
    global ASI_CRM_CN_OffVolumeDeleteJob(Set<Id> contractIdSet) {
        this.query = query;
        this.contractIdSet = contractIdSet;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        List<ASI_TH_CRM_Contract__c> updateFlagContractList = [
            SELECT Id, ASI_CRM_CN_Is_Aggregation_Batch_Run__c, ASI_CRM_CN_Aggregation_Batch_CTD_Date__c 
            FROM ASI_TH_CRM_Contract__c 
            WHERE Id IN:contractIdSet AND ASI_CRM_CN_Is_Aggregation_Batch_Run__c = FALSE
        ];
        Set<Id> runContractIdSet = new Set<Id>();
        for (ASI_TH_CRM_Contract__c contract: updateFlagContractList) {
            contract.ASI_CRM_CN_Is_Aggregation_Batch_Run__c = true;
            contract.ASI_CRM_CN_Aggregation_Batch_CTD_Date__c = ASI_CRM_CN_HeavyContractUtilitiesClass.GenerateCutOffDate();
            runContractIdSet.add(contract.Id);
        }
        contractIdSet = runContractIdSet;
        update updateFlagContractList;
        String deleteQuery = 'SELECT ID FROM ASI_CRM_Subbrand_Volume__c WHERE ASI_CRM_CN_Contract__c in :contractIdSet '
                            +'AND RecordType.DeveloperName in :RECORD_TYPE_LIST_AGGREGATION';
        return Database.getQueryLocator(deleteQuery);
    }

    global void execute(Database.BatchableContext BC, list<ASI_CRM_Subbrand_Volume__c> scope) {
        delete scope;
    }

    global void finish(Database.BatchableContext BC) {
        // process summary batch
        Database.executeBatch(new ASI_CRM_CN_OffVolumeAggregationJob(false, contractIdSet), 500);
    }
}