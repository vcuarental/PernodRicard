/*********
04-July-2017 Jay Chau Edited: Add Filtering for user profile
*********/

public with sharing class EUR_CRM_ZA_UpdateSOTeleSalesHandler extends EUR_CRM_TriggerAbstract {

    public EUR_CRM_ZA_UpdateSOTeleSalesHandler() {
        super('EUR_CRM_ZA_UpdateSOTeleSalesHandler');
    }

    private Set<String> validRecordTypes = new Set<String>{
            'EUR_Direct'
    };

    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {

        System.Debug('@@@EUR_CRM_ZA_UpdateSOTeleSalesHandler:Execute User:' + UserInfo.getProfileId());
        //User Checking
        Map<id, Profile> triggerProfiles = New Map<id, Profile>([
                SELECT id
                FROM Profile
                WHERE Name Like 'EUR ZA%'
                OR Name Like 'EUR SSA Admin%'
                OR Name Like 'System Administrator GDT%'
                OR Name = 'EUR System Admin'
        ]);
        If (!System.isFuture() && triggerProfiles.containsKey(UserInfo.getProfileId())) {
            System.Debug('@@@EUR_CRM_ZA_UpdateSOTeleSalesHandler:Execute');

            Map<id, Profile> zaProfiles = New Map<id, Profile>([SELECT id from Profile WHERE Name Like 'EUR ZA%']);

            Map<Id, User> userMap = new Map<Id, User>();

            for (User u : (List<User>) sObjList) {
                User oldRecord = (User) oldMap.get(u.Id);
                if (u.EUR_CRM_Telesales_Agent__c != oldRecord.EUR_CRM_Telesales_Agent__c && zaProfiles.containskey(u.ProfileId)) {
                    userMap.put(u.Id, u);
                }
            }
            if (userMap.size() > 0) {

                Map<Id, EUR_CRM_Sales_Order__c> salesOrdersToUpdate = new Map<Id, EUR_CRM_Sales_Order__c>([
                        SELECT Id
                        FROM EUR_CRM_Sales_Order__c
                        WHERE CreatedById IN :userMap.keyset()
                        AND RecordType.DeveloperName IN :validRecordTypes
                        AND EUR_CRM_Order_Status__c != 'Finished'
                    	AND EUR_CRM_Country_Code__c = 'ZA'
                ]);
                if (salesOrdersToUpdate.size() != 0) {
                    updateSalesOrders(salesOrdersToUpdate.keySet());
                }
            }
        }
    }

    @Future
    static void updateSalesOrders(Set<Id> salesOrderIds) {
        List<EUR_CRM_Sales_Order__c> salesORderToUpdate = new List<EUR_CRM_Sales_Order__c>();
        for (EUR_CRM_Sales_Order__c so : [
                SELECT id
                        ,EUR_CRM_TeleSales_Agent__c
                        ,CreatedBy.EUR_CRM_Telesales_Agent__c
                FROM EUR_CRM_Sales_Order__c
                WHERE Id IN :salesOrderIds AND EUR_CRM_Country_Code__c = 'ZA'
        ]) {
            so.EUR_CRM_TeleSales_Agent__c = so.CreatedBy.EUR_CRM_Telesales_Agent__c;
            salesORderToUpdate.add(so);
        }
        update salesORderToUpdate;
    }
}