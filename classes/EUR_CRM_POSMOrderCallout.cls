public without sharing class EUR_CRM_POSMOrderCallout extends EUR_CRM_TriggerAbstract{

    public EUR_CRM_POSMOrderCallout(){
        super('EUR_CRM_POSMOrderCallout');
    }

    Set<String> validRecordTypes = new Set<String>{'EUR_ZA_POSM_Order'};

    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {

        //Get record type list for POSM Order
        List<Recordtype> posmOrderRecordTypes = Global_RecordTypeCache.getRtList('EUR_CRM_POSM_Order__c');
        Map<Id,Recordtype> posmOrderRecordTypesMap = new Map<Id,Recordtype>();
        
        for(Recordtype rt : posmOrderRecordTypes ){
           posmOrderRecordTypesMap.put(rt.id,rt);
        }
        
        List<EUR_CRM_POSM_Order__c> validposmOrderList = new List<EUR_CRM_POSM_Order__c>();

        //Get all ZA POSM Order Records
        for(EUR_CRM_POSM_Order__c posm : (List<EUR_CRM_POSM_Order__c>) sObjList) {
            String posmOrdeRTDevName = posmOrderRecordTypesMap.get(posm.RecordTypeId).developername;
            if(validRecordTypes.contains(posmOrdeRTDevName )){
                validPOSMOrderList.add(posm);
            }
        }

        System.debug(validPOSMOrderList);
        if(!validPOSMOrderList.isEmpty()) { 
            for(EUR_CRM_POSM_Order__c posm : validPOSMOrderList){
                if( posm.EUR_CRM_No_of_Order_Items_Match_Header__c == true && posm.EUR_CRM_Order_Status__c == 'In Process' && posm.EUR_CRM_Endpoint_Sync_Status__c == null) {
                    System.enqueueJob(new EUR_CRM_POSMCalloutQueueable(posm.Id));
                }
            }
        }
    }
}