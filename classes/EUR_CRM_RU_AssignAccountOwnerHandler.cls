/**
*   Name: EUR_CRM_RU_AssignAccountOwnerHandler
*   Description: Trigger Class to update the owner and sharing access of the account related to the territories
*   Field to update:
*   On Trade Owner = Owner change to All related Account on Trade Recordtypes
*   Off Trade Owner = Owner change to All related account on Trade recordtypes
*/
public with sharing class EUR_CRM_RU_AssignAccountOwnerHandler extends EUR_CRM_TriggerAbstract{
    
    public EUR_CRM_RU_AssignAccountOwnerHandler() {
        super('EUR_CRM_RU_AssignAccountOwnerHandler');
    }
    
    private static String RU_ON_TRADE = 'EUR_RU_On_Trade';
    private static String RU_DIRECT_OFF_TRADE = 'EUR_RU_Direct_Off_Trade';
    private static String RU_DIRECT_TYPE_2_OFF_TRADE = 'EUR_RU_Direct_Type_2_Off_Trade';
    private static String RU_DISTRIBUTION_CENTER = 'EUR_RU_Distribution_Center';
    private static String RU_DISTRIBUTOR = 'EUR_RU_Distributor';
    private static String RU_INDIRECT_OFF_TRADE = 'EUR_RU_Indirect_Off_Trade';
    
    private static Set<String> accountRecordTypeSet = new Set<String> {
        RU_ON_TRADE,
        RU_DIRECT_OFF_TRADE,
        RU_DIRECT_TYPE_2_OFF_TRADE,
        RU_DISTRIBUTION_CENTER,
        RU_DISTRIBUTOR,
        RU_INDIRECT_OFF_TRADE
    };

    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<Id, sObject> newMap, Map<Id, sObject> oldMap) {
        List<EUR_CRM_Account__c> accountList = (List<EUR_CRM_Account__c>) sObjList;
        Set<Id> territoryIds = new Set<Id>();
        
        List<RecordType> accountRecordTypes = Global_RecordTypeCache.getRtList('EUR_CRM_Account__c');
        Map<Id, RecordType> accountRecordTypesMap = new Map<Id, RecordType>();
        for(RecordType rt: accountRecordTypes) {
            accountRecordTypesMap.put(rt.Id, rt);
        }
        
        for(EUR_CRM_Account__c acc: accountList) {
            if(!accountRecordTypeSet.contains(accountRecordTypesMap.get(acc.recordTypeId).DeveloperName)) {
                return;
            }
            
            if(acc.EUR_CRM_Territory__c != null) {
                territoryIds.add(acc.EUR_CRM_Territory__c);
            }
        }
        
        Map<Id, EUR_CRM_Territory__c> territoryMap = new Map<Id, EUR_CRM_Territory__c>([SELECT Id, Name, EUR_CRM_Territory_Owner__c, EUR_CRM_Territory_Owner__r.Id
                                                                                        FROM EUR_CRM_Territory__c
                                                                                        WHERE Id IN :territoryIds]);
        
        for(EUR_CRM_Account__c acc: accountList) {
            if(acc.EUR_CRM_Territory__c != null && 
                territoryMap.get(acc.EUR_CRM_Territory__c).EUR_CRM_Territory_Owner__c != null) {
                
                // Else, for OFF Trade accounts, make the OFF Trade owner the owner of this account
                acc.OwnerId = territoryMap.get(acc.EUR_CRM_Territory__c).EUR_CRM_Territory_Owner__r.Id;        
            }
        }
    }
}