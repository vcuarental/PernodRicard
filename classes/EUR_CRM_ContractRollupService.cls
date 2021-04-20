public without sharing class EUR_CRM_ContractRollupService {

    public static final String CONTRACT_ACTIVATED_STATUS = 'Activated';

    // Mechanic Type External Ids
    public static final String WKZ_FIX_AMOUNT = 'EUR_DE_WKZ_Fix_Amount';
    public static final String DRINKS_MENU = 'EUR_DE_Drinks_Menu';
    public static final String EUR_DE_EVENTS = 'EUR_DE_Events';
    public static final String VISIBILITY_BRANDING = 'EUR_DE_Visibility_Branding';
    public static final String POS_WKZ = 'EUR_DE_POS_WKZ';
    public static final String POS_MATERIAL = 'EUR_DE_POS_Material';
    public static final String NAPKINS = 'EUR_DE_Napkins';
    public static final String TRAINING = 'EUR_DE_Training';
    public static final String OTHERS = 'EUR_DE_Others';

    public static final Set<String> MECHANIC_TYPE_EXTERNAL_IDS = new Set<String>{
        WKZ_FIX_AMOUNT, DRINKS_MENU, EUR_DE_EVENTS, VISIBILITY_BRANDING, POS_WKZ, POS_MATERIAL, NAPKINS, TRAINING, OTHERS
    };

    public static void polulateRollupFields(List<EUR_CRM_Contract_Activity_Item__c> records) {
        Set<Id> filteredContractRecords = new Set<Id>();
        Set<Id> validMechanicTypeIds = getValidMechanicTypeIds();
        for(EUR_CRM_Contract_Activity_Item__c activityItem : records) {
            if(validMechanicTypeIds.contains(activityItem.EUR_CRM_Mechanic_Type__c) && activityItem.EUR_CRM_Amount__c != 0) {
                filteredContractRecords.add(activityItem.EUR_CRM_Contract__c);
            }
        }
        polulateContractRollupFields(filteredContractRecords);
    }

    public static void polulateRollupFields(List<EUR_CRM_Contract_Activity_Item__c> records, Map<Id, EUR_CRM_Contract_Activity_Item__c> oldRecords) {
        Set<Id> filteredContractRecords = new Set<Id>();
        Set<Id> validMechanicTypeIds = getValidMechanicTypeIds();
        for(EUR_CRM_Contract_Activity_Item__c activityItem : records) {
            EUR_CRM_Contract_Activity_Item__c oldRecord = oldRecords.get(activityItem.Id);
            if(validMechanicTypeIds.contains(activityItem.EUR_CRM_Mechanic_Type__c) || validMechanicTypeIds.contains(oldRecord.EUR_CRM_Mechanic_Type__c)) {
                if(
                    activityItem.EUR_CRM_Mechanic_Type__c != oldRecord.EUR_CRM_Mechanic_Type__c ||
                    activityItem.EUR_CRM_Amount__c != oldRecord.EUR_CRM_Amount__c ||
                    activityItem.EUR_CRM_Is_PR_Event__c != oldRecord.EUR_CRM_Is_PR_Event__c ||
                    activityItem.EUR_CRM_Exclude_Budget_Deduction__c != oldRecord.EUR_CRM_Exclude_Budget_Deduction__c ||
                    activityItem.EUR_CRM_Contract__c != oldRecord.EUR_CRM_Contract__c
                ) {
                    filteredContractRecords.add(activityItem.EUR_CRM_Contract__c);
                    filteredContractRecords.add(oldRecord.EUR_CRM_Contract__c);
                }
            }
        }
        polulateContractRollupFields(filteredContractRecords);
    }

    public static Set<Id> getValidMechanicTypeIds() {
        return new Map<Id, EUR_CRM_Mechanic_Type__c>([
            SELECT Id FROM EUR_CRM_Mechanic_Type__c WHERE EUR_CRM_External_ID__c IN :MECHANIC_TYPE_EXTERNAL_IDS
        ]).keySet();
    }

    public static void polulateContractRollupFields(Set<Id> contractIds) {
        if(contractIds.isEmpty()) return;

        Map<Id, List<EUR_CRM_Contract_Activity_Item__c>> activityItemsByContractId = new Map<Id, List<EUR_CRM_Contract_Activity_Item__c>>();
        for(EUR_CRM_Contract_Activity_Item__c activityItem : [
            SELECT Id, EUR_CRM_Amount__c, EUR_CRM_Contract__c, EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c, EUR_CRM_Is_PR_Event__c, EUR_CRM_Exclude_Budget_Deduction__c
            FROM EUR_CRM_Contract_Activity_Item__c
            WHERE EUR_CRM_Contract__c IN :contractIds AND
                EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c IN :MECHANIC_TYPE_EXTERNAL_IDS AND
                EUR_CRM_Amount__c != 0
        ]) {
            List<EUR_CRM_Contract_Activity_Item__c> activityItems = activityItemsByContractId.get(activityItem.EUR_CRM_Contract__c);
            if(activityItems == null) {
                activityItemsByContractId.put(activityItem.EUR_CRM_Contract__c, new List<EUR_CRM_Contract_Activity_Item__c>{activityItem});
            } else {
                activityItems.add(activityItem);
            }
        }

        List<EUR_CRM_Contract__c> contractsForUpdate = new List<EUR_CRM_Contract__c>();
        for(Id contractId : contractIds) {
            EUR_CRM_Contract__c contract = new EUR_CRM_Contract__c(
                Id = contractId,
                EUR_CRM_WKZ_Fix_Amount__c = 0,
                EUR_CRM_Drinks_Menu__c = 0,
                EUR_CRM_Non_PRD_Events__c = 0,
                EUR_CRM_PRD_Events__c = 0,
                EUR_CRM_Visibility_Branding__c = 0,
                EUR_CRM_POS_WKZ__c = 0,
                EUR_CRM_POS_Material__c = 0,
                EUR_CRM_Napkins__c = 0,
                EUR_CRM_Training__c = 0,
                EUR_CRM_Others_PRD__c = 0,
                EUR_CRM_Others__c = 0
            );
            contractsForUpdate.add(contract);

            List<EUR_CRM_Contract_Activity_Item__c> activityItems = activityItemsByContractId.get(contract.Id);
            if(activityItems == null) continue;

            for(EUR_CRM_Contract_Activity_Item__c activityItem : activityItems) {
                if(activityItem.EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c == WKZ_FIX_AMOUNT) {
                    contract.EUR_CRM_WKZ_Fix_Amount__c += activityItem.EUR_CRM_Amount__c;
                    continue;
                }
                if(activityItem.EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c == DRINKS_MENU) {
                    contract.EUR_CRM_Drinks_Menu__c += activityItem.EUR_CRM_Amount__c;
                    continue;
                }
                if(activityItem.EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c == EUR_DE_EVENTS && activityItem.EUR_CRM_Is_PR_Event__c == false) {
                    contract.EUR_CRM_Non_PRD_Events__c += activityItem.EUR_CRM_Amount__c;
                    continue;
                }
                if(activityItem.EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c == EUR_DE_EVENTS && activityItem.EUR_CRM_Is_PR_Event__c == true) {
                    contract.EUR_CRM_PRD_Events__c += activityItem.EUR_CRM_Amount__c;
                    continue;
                }
                if(activityItem.EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c == VISIBILITY_BRANDING) {
                    contract.EUR_CRM_Visibility_Branding__c += activityItem.EUR_CRM_Amount__c;
                    continue;
                }
                if(activityItem.EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c == POS_WKZ) {
                    contract.EUR_CRM_POS_WKZ__c += activityItem.EUR_CRM_Amount__c;
                    continue;
                }
                if(activityItem.EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c == POS_MATERIAL) {
                    contract.EUR_CRM_POS_Material__c += activityItem.EUR_CRM_Amount__c;
                    continue;
                }
                if(activityItem.EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c == NAPKINS) {
                    contract.EUR_CRM_Napkins__c += activityItem.EUR_CRM_Amount__c;
                    continue;
                }
                if(activityItem.EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c == TRAINING) {
                    contract.EUR_CRM_Training__c += activityItem.EUR_CRM_Amount__c;
                    continue;
                }
                if(activityItem.EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c == OTHERS && activityItem.EUR_CRM_Exclude_Budget_Deduction__c == true) {
                    contract.EUR_CRM_Others_PRD__c += activityItem.EUR_CRM_Amount__c;
                    continue;
                }
                if(activityItem.EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c == OTHERS && activityItem.EUR_CRM_Exclude_Budget_Deduction__c == false) {
                    contract.EUR_CRM_Others__c += activityItem.EUR_CRM_Amount__c;
                    continue;
                }
            }
        }
        update contractsForUpdate;
    }

}