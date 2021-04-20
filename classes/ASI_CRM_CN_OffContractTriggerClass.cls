/***************************************************************************************************************************
 * Name:        ASI_CRM_CN_OffContractTriggerClass
 * Description: Apex class for ASI_CRM_CN_OffContractTriggerClass
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-10-25       Jeffrey Cheung          Created
 ****************************************************************************************************************************/

public class ASI_CRM_CN_OffContractTriggerClass {
    public static void routineBeforeInsert(List<ASI_TH_CRM_Contract__c> trigger_new) {
//        assignGroupPO(trigger_new);
    }

    /**
     * Assign Group Contract Id (ASI_CRM_CN_Group_Contract__c) to Contract
     * A contract belongs to a Group PO if
     * 1. Group PO date period contains contract date period
     * 2. Group PO's covered outlets contains contract's outlet
     * 3. Group PO status is Final
     *
     * @param trigger_new A list of contracts
     */
    public static void assignGroupPO(List<ASI_TH_CRM_Contract__c> contracts){
        Map<Id, List<ASI_TH_CRM_Contract__c>> groupPOByContractIds = getAvailableGroupPO(contracts);


        for (ASI_TH_CRM_Contract__c contract : contracts) {
            if (!groupPOByContractIds.get(contract.Id).isEmpty()) {
                contract.ASI_CRM_CN_Group_Contract__c = groupPOByContractIds.get(contract.Id)[0].Id;
            }
        }


    }

    /**
     * Return a list of Group Contracts by Contract Id. A contract can have multiple suitable Group Contract candidates.
     * A contract belongs to a Group PO if
     * 1. Group PO date period contains contract date period
     * 2. Group PO's covered outlets contains contract's outlet
     * 3. Group PO status is Final
     *
     * @param contracts
     *
     * @return
     */
    public static Map<Id, List<ASI_TH_CRM_Contract__c>> getAvailableGroupPO(List<ASI_TH_CRM_Contract__c> contracts){
        String query = 'SELECT Id, Name, ASI_CRM_CN_PO_No__c, ASI_CRM_CN_PO_Start_Date__c,ASI_CRM_CN_PO_End_Date__c, (SELECT Id,ASI_CRM_CN_Outlet__c FROM Covered_Outlet__r) ' +
            'FROM ASI_TH_CRM_Contract__c ' +
            'WHERE ASI_CRM_Active_Dummy_PO__c = TRUE ' +
            'AND ASI_TH_CRM_Promotion_Type__c = \'TOT/MOT Group PO\' ' +
            'AND ASI_CRM_CN_Status__c = \'Final\' ';
        List<String> dataStrings = new List<String>();
        for (ASI_TH_CRM_Contract__c contract : contracts) {
            if (contract.ASI_CRM_CN_PO_Start_Date__c == null || contract.ASI_CRM_CN_PO_End_Date__c == null) {
                continue;
            }
            dataStrings.add('(ASI_CRM_CN_PO_Start_Date__c <= ' + String.valueOf(contract.ASI_CRM_CN_PO_Start_Date__c) + ' AND ASI_CRM_CN_PO_End_Date__c >= ' + String.valueOf(contract.ASI_CRM_CN_PO_End_Date__c) + ') ');
        }

        if (!dataStrings.isEmpty()) {
            query += 'AND (' + String.join(dataStrings, ' OR ') + ')';
        }

        List<ASI_TH_CRM_Contract__c> groupPOs = Database.query(query);
        Map<Id, List<ASI_TH_CRM_Contract__c>> groupPOByContractIds = new Map<Id, List<ASI_TH_CRM_Contract__c>>();

        for (ASI_TH_CRM_Contract__c contract : contracts) {
            groupPOByContractIds.put(contract.Id, new List<ASI_TH_CRM_Contract__c>());
            for (ASI_TH_CRM_Contract__c groupPO : groupPOs) {
                Set<Id> groupPOCoveredOutletIds = ASI_CRM_CN_UtilPluck.pluckIds(ASI_CRM_CN_Covered_Outlet__c.ASI_CRM_CN_Outlet__c, groupPO.Covered_Outlet__r);

                // If groupPo period contains contract period and covered outlets contains contract outlet, add to map
                if (groupPO.ASI_CRM_CN_PO_Start_Date__c <=  contract.ASI_CRM_CN_PO_Start_Date__c && groupPO.ASI_CRM_CN_PO_End_Date__c >=  contract.ASI_CRM_CN_PO_End_Date__c && groupPOCoveredOutletIds.contains(contract.ASI_CRM_CN_Outlet_WS__c)) {
                    List<ASI_TH_CRM_Contract__c> newList = groupPOByContractIds.get(contract.Id);
                    newList.add(groupPO);
                    groupPOByContractIds.put(contract.Id, newList);
                    continue;
                }
            }
        }

        return groupPOByContractIds;
    }

    public static List<ASI_TH_CRM_Contract__c> getAvailableGroupPO(ASI_TH_CRM_Contract__c contract){
        return getAvailableGroupPO(new List<ASI_TH_CRM_Contract__c>{contract}).get(contract.Id);
    }
}