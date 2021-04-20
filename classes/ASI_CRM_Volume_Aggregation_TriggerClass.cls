/***************************************************************************************************************************
 * Name:        ASI_CRM_Volume_Aggregation_TriggerClass
 * Description: Apex class for ASI_CRM_Volume_Aggregation_TriggerClass
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2019-05-18       Jeffrey Cheung          Created
 ****************************************************************************************************************************/

public class ASI_CRM_Volume_Aggregation_TriggerClass {
    public static void recalculateFI(List<ASI_CRM_Volume_Aggregation_Breakdown__c> aggregationBreakdowns){
        // 1. Get all outlets from aggregationBreakdowns
        Set<Id> customerIds = ASI_CRM_CN_UtilPluck.pluckIds(ASI_CRM_Volume_Aggregation_Breakdown__c.ASI_CRM_Account__c, aggregationBreakdowns);
        // 2. Get all contracts which outlet is from customerIds.
        List<ASI_TH_CRM_Contract__c> contracts = [
            SELECT
                Id, ASI_CRM_CN_PO_No__c, ASI_CRM_CN_PO_Version__c
            FROM ASI_TH_CRM_Contract__c
            WHERE ASI_CRM_CN_Status__c IN ('Draft', 'Submitted', 'Approved', 'Final')
            AND ASI_TH_CRM_Promotion_Type__c = 'Heavy Contract On'
            AND ASI_CRM_CN_PO_Start_Date__c <= TODAY
            AND ASI_CRM_CN_PO_End_Date__c >= TODAY
            AND ASI_CRM_CN_Outlet_WS__c IN :customerIds
        ];
        
        
        // 3. Get all contracts which has covered outlet in customerIds
        List<ASI_CRM_CN_Covered_Outlet__c> coveredOutlets = [
            SELECT
                Id, ASI_CRM_CN_Contract__c
            FROM ASI_CRM_CN_Covered_Outlet__c
            WHERE ASI_CRM_CN_Contract__r.ASI_CRM_CN_Status__c IN ('Draft', 'Submitted', 'Approved', 'Final')
            AND ASI_CRM_CN_Contract__r.ASI_TH_CRM_Promotion_Type__c = 'Heavy Contract On'
            AND ASI_CRM_CN_Contract__r.ASI_CRM_CN_PO_Start_Date__c <= TODAY
            AND ASI_CRM_CN_Contract__r.ASI_CRM_CN_PO_End_Date__c >= TODAY
            AND ASI_CRM_CN_Outlet__c IN :customerIds
        ];
        // 4. Get all contract Id and recalculate FI for them
        Set<Id> contractIds = new Set<Id>();
        for (ASI_TH_CRM_Contract__c contract : contracts) {
            contractIds.add(contract.Id);
        }
        for (ASI_CRM_CN_Covered_Outlet__c coveredOutlet : coveredOutlets) {
            contractIds.add(coveredOutlet.ASI_CRM_CN_Contract__c);
        }
        System.debug('Found contracts: ' + contractIds.size());
        System.debug('Found contracts: ' + contractIds);
        // 5. Calculate all FI of these contracts
        Database.executeBatch(new ASI_CRM_HeavyContractOn_RecalFIBatch(contractIds), 3);
    }
}