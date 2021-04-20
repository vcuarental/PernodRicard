/***************************************************************************************************************************
 * Name:        ASI_CRM_CN_CoveredOutletValidationClass
 * Description: Apex class for ASI_CRM_CN_CoveredOutletValidationClass
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-10-29       Jeffrey Cheung          Created
 ****************************************************************************************************************************/

public class ASI_CRM_CN_CoveredOutletValidationClass {
    /**
     * Get covered outlets that exist in PO but not exist in Group PO.
     * @example if coveredOutlets = [outlet1, outlet2] and coveredOutletsOfGroupPo = [outlet1, outlet3],
     *          return [outlet2]
     *
     * @param coveredOutlets Covered outlets in PO
     * @param contractId PO Id
     *
     * @return List of covered outlets that exist in PO but not exist in Group PO
     */
    public static List<ASI_CRM_CN_Covered_Outlet__c> getCoveredOutletsOutsideGroupPO(List<ASI_CRM_CN_Covered_Outlet__c> coveredOutlets, Id contractId){
        List<ASI_CRM_CN_Covered_Outlet__c> coveredOutletsOutsideGroupPO = new List<ASI_CRM_CN_Covered_Outlet__c>();

        ASI_TH_CRM_Contract__c contract = getContractById(contractId);
        if (contract == null || contract.ASI_CRM_CN_Group_Contract__c == null) {
            return coveredOutletsOutsideGroupPO;
        }

        List<ASI_CRM_CN_Covered_Outlet__c> coveredOutletsFromGroupPO =[SELECT Id, ASI_CRM_CN_Outlet__c FROM ASI_CRM_CN_Covered_Outlet__c WHERE ASI_CRM_CN_Contract__c = :contract.ASI_CRM_CN_Group_Contract__c];
        Set<Id> outletIds = ASI_CRM_CN_UtilPluck.pluckIds(ASI_CRM_CN_Covered_Outlet__c.ASI_CRM_CN_Outlet__c, coveredOutletsFromGroupPO);

        for (ASI_CRM_CN_Covered_Outlet__c coveredOutlet : coveredOutlets) {
            if (!outletIds.contains(coveredOutlet.ASI_CRM_CN_Outlet__c)) {
                coveredOutletsOutsideGroupPO.add(coveredOutlet);
            }
        }
        return coveredOutletsOutsideGroupPO;
    }

    /**
     * Get covered outlets that exist in another PO with overlap period
     *
     * @param coveredOutlets
     * @param contractId
     *
     * @return A map where key is covered outlet and value is a list of contracts that contains this outlet
     */
    public static Map<ASI_CRM_CN_Covered_Outlet__c, List<ASI_TH_CRM_Contract__c>> getCoveredOutletsOverlapWithOtherContracts(List<ASI_CRM_CN_Covered_Outlet__c> coveredOutlets, Id contractId){
        Map<ASI_CRM_CN_Covered_Outlet__c, List<ASI_TH_CRM_Contract__c>> coveredOutletsOverlapWithOtherContracts = new Map<ASI_CRM_CN_Covered_Outlet__c, List<ASI_TH_CRM_Contract__c>>();

        ASI_TH_CRM_Contract__c contract = getContractById(contractId);
        if (contract == null || contract.ASI_CRM_CN_Group_Contract__c == null) {
            return coveredOutletsOverlapWithOtherContracts;
        }

        Map<Id, ASI_CRM_CN_Covered_Outlet__c> coveredOutletByOutletId = new Map<Id, ASI_CRM_CN_Covered_Outlet__c>();
        for (ASI_CRM_CN_Covered_Outlet__c coveredOutlet : coveredOutlets) {
            coveredOutletByOutletId.put(coveredOutlet.ASI_CRM_CN_Outlet__c, coveredOutlet);
        }
        Set<Id> coveredOutletIds = coveredOutletByOutletId.keySet();

        for (ASI_TH_CRM_Contract__c otherContract : [SELECT Id, Name, ASI_CRM_CN_PO_No__c, (SELECT Id, ASI_CRM_CN_Outlet__c FROM Covered_Outlet__r) FROM ASI_TH_CRM_Contract__c
        WHERE Id != :contractId
        AND Id != :contract.ASI_CRM_CN_Group_Contract__c
        AND ASI_CRM_CN_PO_No__c != :contract.ASI_CRM_CN_PO_No__c
        AND ASI_CRM_CN_PO_Start_Date__c <= :contract.ASI_CRM_CN_PO_End_Date__c
        AND ASI_CRM_CN_PO_End_Date__c >= :contract.ASI_CRM_CN_PO_Start_Date__c
        ]) {
            for (ASI_CRM_CN_Covered_Outlet__c coveredOutlet : otherContract.Covered_Outlet__r) {
                Id outletId = coveredOutlet.ASI_CRM_CN_Outlet__c;
                if (coveredOutletIds.contains(outletId)) {
                    ASI_CRM_CN_Covered_Outlet__c coveredOutlet2 = coveredOutletByOutletId.get(outletId);
                    if (coveredOutletsOverlapWithOtherContracts.containsKey(coveredOutlet2)) {
                        List<ASI_TH_CRM_Contract__c> contracts = coveredOutletsOverlapWithOtherContracts.get(coveredOutlet2);
                        contracts.add(otherContract);
                        coveredOutletsOverlapWithOtherContracts.put(coveredOutlet2, contracts);
                    } else {
                        coveredOutletsOverlapWithOtherContracts.put(coveredOutlet2, new List<ASI_TH_CRM_Contract__c>{otherContract});
                    }
                }
            }
        }

        return coveredOutletsOverlapWithOtherContracts;
//        return new Map<ASI_CRM_CN_Covered_Outlet__c, List<ASI_TH_CRM_Contract__c>>();
    }

    public static ASI_TH_CRM_Contract__c getContractById(Id contractId){
        List<ASI_TH_CRM_Contract__c> contracts = [SELECT Id, ASI_CRM_CN_Group_Contract__c,ASI_CRM_CN_PO_Start_Date__c,ASI_CRM_CN_PO_End_Date__c, ASI_CRM_CN_PO_No__c FROM ASI_TH_CRM_Contract__c WHERE Id = :contractId];
        return (contracts.size() == 1)? contracts.get(0) : null;
    }
}