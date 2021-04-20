public with sharing class EUR_CRM_EventAccountHandler extends EUR_CRM_TriggerAbstract {
    
    public EUR_CRM_EventAccountHandler() {
        super('EUR_CRM_EventAccountHandler');
    }
    
    private Set<String> validRecordTypes = new Set<String>{
        'EUR_FI_Visitation_Event',
        'EUR_SE_Visitation_Event'
    };
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<Id, sObject> newMap, Map<Id, sObject> oldMap) {
        List<Event> eventList = (List<Event>) sObjList;
        
        // List to store standard account IDs of the events
        List<Id> relatedAccountIds = new List<Id>();
        

        // Determine a set of valid record type ids
        Set<Id> validRecordTypeIds = new Set<Id>();
        for(String rt: validRecordTypes) {
            validRecordTypeIds.add(Global_RecordTypeCache.getRtId('Event' + rt));
        }
        
        for(Event ev: eventList) {
            if(!validRecordTypeIds.contains(ev.recordTypeId) || ev.whatId == null) {
                continue;
            }
            
            if((ev.whatId).getSObjectType().getDescribe().getName() == 'Account') {
                relatedAccountIds.add(ev.whatId);
            }
        }

        if(relatedAccountIds.size() > 0) {
            // Retrieve a list of Account Links and then arrange them in a map {StandardAccountId => EUAccountId}
            List<EUR_CRM_Account_Link__c> relatedAccountLinks = [SELECT EUR_CRM_EU_Account__c, EUR_CRM_Standard_Account__c
                                                                 FROM EUR_CRM_Account_Link__c 
                                                                 WHERE EUR_CRM_Standard_Account__c IN :relatedAccountIds];
            Map<Id, Id> standardAccountToEUAccountMap = new Map<Id, Id>();
            for(EUR_CRM_Account_Link__c link: relatedAccountLinks) {
                standardAccountToEUAccountMap.put(link.EUR_CRM_Standard_Account__c, link.EUR_CRM_EU_Account__c);
            }                                                     
            
            for(Event ev: eventList) {
                if(validRecordTypeIds.contains(ev.recordTypeId) && ev.whatId != null &&
                    (ev.whatId).getSObjectType().getDescribe().getName() == 'Account') {
                        
                    ev.whatId = standardAccountToEUAccountMap.get(ev.whatId);
                }
            }
        }
    }
    
}