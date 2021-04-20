/**
*   TriggerClass: EUR_CRM_SalesOrderAssignInfo
*
*   Assigns KD Owner's Name and Email to newly created Sales Order
*   Also assigns Sales manager (EUR_CRM_Manager__c) and Key Account Manager (EUR_CRM_Key_Account_Manager__c) on top of that
*   TriggerActions: BeforeInsert
*   
*/
public with sharing class EUR_CRM_SalesOrderAssignInfo {

    private static final String CLASS_NAME = 'EUR_CRM_SalesOrderAssignInfo';
    
    private static final Set<String> SO_RT_TO_UPDATE_KEY_DISTRIBUTOR = EUR_CRM_RecordTypeHelper_v2.getSettingsSet(CLASS_NAME, 'SO_RT_TO_UPDATE_KEY_DISTRIBUTOR');
//    private Set<String> SO_RT_TO_UPDATE_KEY_DISTRIBUTOR = new Set<String>{
//        'EUR_NG_On_Trade_Reminder',
//        'EUR_RU_On_Trade_Sales_Order'
//    };

    public void onBeforeInsert(List<EUR_CRM_Sales_Order__c> sos) {
        Map<Id, RecordTypeInfo> soRtInfoByRtId = Schema.SObjectType.EUR_CRM_Sales_Order__c.getRecordTypeInfosById();
        List<EUR_CRM_Sales_Order__c> sosToUpdate = this.getSOsToUpdate(sos, soRtInfoByRtId);
        System.debug('\n sosToUpdate.size() => ' + sosToUpdate.size() + '\n');
        System.debug('\n sosToUpdate => ' + JSON.serializePretty(sosToUpdate) + '\n');
        if (sosToUpdate.isEmpty()) { return; }

        Map<Id, EUR_CRM_Account__c> soRelatedAcc = this.getSoRelatedAccounts(sosToUpdate);
        this.updateSO(sosToUpdate, soRelatedAcc);
    }


    /* ========================================================= */
    /*      High Level Helpers
    /* ========================================================= */
    private List<EUR_CRM_Sales_Order__c> getSOsToUpdate(List<EUR_CRM_Sales_Order__c> sos, Map<Id, RecordTypeInfo> soRtInfoByRtId) {
        List<EUR_CRM_Sales_Order__c> sosToUpdate = new List<EUR_CRM_Sales_Order__c>();
        for (EUR_CRM_Sales_Order__c so : sos) {
            if ( ! SO_RT_TO_UPDATE_KEY_DISTRIBUTOR.contains(soRtInfoByRtId.get(so.RecordTypeId).getDeveloperName())) { continue; }
            sosToUpdate.add(so);
        }
        return sosToUpdate;
    }

    private Map<Id, EUR_CRM_Account__c> getSoRelatedAccounts(List<EUR_CRM_Sales_Order__c> sosToUpdate) {
        Set<Id> accIds = this.getAccIds(sosToUpdate);
        return this.selectAccountsWhereIds(accIds);
    }

    private void updateSO(List<EUR_CRM_Sales_Order__c> sosToUpdate, Map<Id, EUR_CRM_Account__c> soRelatedAcc) {
        for (EUR_CRM_Sales_Order__c so : sosToUpdate) {
            if ( ! this.isTerritoryKDOwnerExist(soRelatedAcc, so)) { continue; }
            so.EUR_CRM_Key_Distributor_Sales_Rep__c = soRelatedAcc.get(so.EUR_CRM_Account__c).EUR_CRM_Territory__r.EUR_CRM_KD_Owner__c;
            so.EUR_CRM_Key_Distributor_Sales_Rep_Email__c = soRelatedAcc.get(so.EUR_CRM_Account__c).EUR_CRM_Territory__r.EUR_CRM_KD_Owner__r.Email;
        }
    }


    /* ========================================================= */
    /*      Middle Level Helpers
    /* ========================================================= */
    private Set<Id> getAccIds(List<EUR_CRM_Sales_Order__c> sosToUpdate) {
        Set<Id> accIds = new Set<Id>();
        for (EUR_CRM_Sales_Order__c so : sosToUpdate) {
            accIds.add(so.EUR_CRM_Account__c);
        }
        return accIds;
    }


    /* ========================================================= */
    /*      Low Level Helpers
    /* ========================================================= */
    private Boolean isTerritoryKDOwnerExist(Map<Id, EUR_CRM_Account__c> soRelatedAcc, EUR_CRM_Sales_Order__c so) {
        return soRelatedAcc.containsKey(so.EUR_CRM_Account__c)
            && soRelatedAcc.get(so.EUR_CRM_Account__c).EUR_CRM_Territory__c != null
            && soRelatedAcc.get(so.EUR_CRM_Account__c).EUR_CRM_Territory__r.EUR_CRM_KD_Owner__c != null
        ;
    }


    /* ========================================================= */
    /*      SOQL Selectors
    /* ========================================================= */
    private Map<Id, EUR_CRM_Account__c> selectAccountsWhereIds(Set<Id> accIds) {
        return new Map<Id, EUR_CRM_Account__c>([
            SELECT Id
            ,   EUR_CRM_Territory__r.EUR_CRM_KD_Owner__c
            ,   EUR_CRM_Territory__r.EUR_CRM_KD_Owner__r.Email
            ,   EUR_CRM_Territory__r.EUR_CRM_KD_Owner__r.Name
            FROM EUR_CRM_Account__c
            WHERE Id IN :accIds
        ]);
    }
}