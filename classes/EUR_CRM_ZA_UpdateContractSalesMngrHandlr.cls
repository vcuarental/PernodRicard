/*********
04-July-2017 Jay Chau Edited: Add Filtering for user profile
*********/

public with sharing class EUR_CRM_ZA_UpdateContractSalesMngrHandlr extends EUR_CRM_TriggerAbstract {

    public EUR_CRM_ZA_UpdateContractSalesMngrHandlr() {
        super('EUR_CRM_ZA_UpdateContractSalesMngrHandlr');
    }

    private Set<String> validContractRecordTypes = new Set<String>{
            'EUR_ZA_Head_Office_Contract',
            'EUR_ZA_Outlet_Contract'
    };


    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {

        System.Debug('@@@EUR_CRM_ZA_UpdateContractSalesMngrHandlr:Execute User:' + UserInfo.getProfileId());
        //User Checking
        Map<id, Profile> triggerProfiles = New Map<id, Profile>([
                SELECT id
                FROM Profile
                WHERE Name Like 'EUR ZA%'
                OR Name Like 'EUR SSA Admin%'
                OR Name Like'System Administrator GDT%'
                OR Name = 'EUR System Admin'
        ]);
        If (!System.isFuture() && triggerProfiles.containsKey(UserInfo.getProfileId())) {
            System.Debug('@@@EUR_CRM_ZA_UpdateContractSalesMngrHandlr:Execute');
            Map<Id, User> userMap = new Map<Id, User>();

            for (User u : (List<User>) sObjList) {
                User oldRecord = (User) oldMap.get(u.Id);
                if (u.ManagerId != oldRecord.ManagerId) {
                    userMap.put(u.Id, u);
                }
            }

            if (userMap.keySet().size() > 0) {
                Map<Id, EUR_CRM_Contract__c> contractsToUpdate = new Map<Id, EUR_CRM_Contract__c>([
                        SELECT Id
                        FROM EUR_CRM_Contract__c
                        WHERE CreatedById IN :userMap.keyset()
                        AND EUR_CRM_Status__c = 'Draft'
                        AND RecordType.DeveloperName IN :validContractRecordTypes
                ]);

                if (contractsToUpdate.size() != 0) {
                    updateContracts(contractsToUpdate.keySet());
                }
            }
        }
    }

    @Future
    static void updateContracts(Set<Id> contractIds) {
        List<EUR_CRM_Contract__c> contractToUpdate = new List<EUR_CRM_Contract__c>();
        for (EUR_CRM_Contract__c contract : [
                SELECT id
                        ,EUR_CRM_Sales_Manager__c
                        ,CreatedBy.ManagerId
                FROM EUR_CRM_Contract__c
                WHERE Id IN :contractIds
        ]) {
            contract.EUR_CRM_Sales_Manager__c = contract.CreatedBy.ManagerId;
            contractToUpdate.add(contract);
        }
        update contractToUpdate;
    }
}