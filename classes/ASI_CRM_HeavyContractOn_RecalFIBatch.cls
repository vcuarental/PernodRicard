/***************************************************************************************************************************
 * Name:        ASI_CRM_HeavyContractOn_RecalFIBatch
 * Description: Apex class for ASI_CRM_HeavyContractOn_RecalFIBatch
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2019-05-21       Jeffrey Cheung          Created
 ****************************************************************************************************************************/

public class ASI_CRM_HeavyContractOn_RecalFIBatch implements Database.Batchable<SObject>{
    public Set<Id> contractIds {get;set;} {contractIds = new Set<Id>();}

    public ASI_CRM_HeavyContractOn_RecalFIBatch(Set<Id> contractIds){
        this.contractIds = contractIds;
    }

    public void execute(Database.BatchableContext BC, List<SObject> scope) {
        List<ASI_TH_CRM_Contract__c> contracts = scope;
        for (ASI_TH_CRM_Contract__c contract : contracts) {
            try {
                ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureCurrentFinancialIndicatorData(contract);
            } catch (Exception e) { System.debug('Exception:::' + e.getMessage()); }
            ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureHistoricalFinancialIndicatorData(contract);
            if (contract.ASI_CRM_CN_PO_Version__c != '0.0') {
                try {
                ASI_CRM_CN_HeavyContractUtilitiesClass.ReconstructCurrentPOModiFIData(contract);
                } catch (Exception e) { System.debug('Exception:::' + e.getMessage()); }
                ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureHistoricalPOModiFIData(contract);
            }
            if (contract.ASI_TH_CRM_PaymentRequests_Contract__r != null && contract.ASI_TH_CRM_PaymentRequests_Contract__r.size() > 0) {
                ASI_CRM_CN_HeavyPaymentUtilitiesClass.ReconstructLastPaymentFIData(contract.ASI_TH_CRM_PaymentRequests_Contract__r[0]);
            }
        }
    }

    public void finish(Database.BatchableContext param1) {
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT Id, ASI_CRM_CN_PO_Version__c, (SELECT Id FROM ASI_TH_CRM_PaymentRequests_Contract__r WHERE ASI_CRM_CN_Last_Payment__c = TRUE)  FROM ASI_TH_CRM_Contract__c WHERE Id IN :contractIds]);
    }
}