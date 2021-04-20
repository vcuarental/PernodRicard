public with sharing class EUR_CRM_SalesRepOrderAssignManager extends EUR_CRM_TriggerAbstract  {

    public EUR_CRM_SalesRepOrderAssignManager() {
        super('EUR_CRM_SalesRepOrderAssignManager');
    }

    private Set<String> validRecordTypes = new Set<String>{
      'EUR_DK_Free_Goods_Order_to_SR_Stock'
    };

    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        List<Recordtype> salesRepOrderRecordTypes = Global_RecordTypeCache.getRtList('EUR_CRM_SalesRep_Order__c');
        Map<Id,Recordtype> salesRepOrderRecordTypesMap = new Map<Id,Recordtype>();
        
        for(Recordtype rt : salesRepOrderRecordTypes ){
           salesRepOrderRecordTypesMap.put(rt.id,rt);
        }
        
        List<EUR_CRM_SalesRep_Order__c> salesRepOrderList = (List<EUR_CRM_SalesRep_Order__c>) sObjList;
        List<EUR_CRM_SalesRep_Order__c> validSalesRepOrderList = new List<EUR_CRM_SalesRep_Order__c>();
        
        Set<ID> ownerIDSet = new Set<ID>();
        
        for(EUR_CRM_SalesRep_Order__c sro : salesRepOrderList) {
            String salesRepOrdeRTDevName = salesRepOrderRecordTypesMap.get(sro.recordtypeid).DeveloperName;
            if(validRecordTypes.contains(salesRepOrdeRTDevName)){
                ownerIDSet.add(sro.OwnerId);
                validSalesRepOrderList.add(sro);
            }
        }
        
        if(validSalesRepOrderList.size() > 0) {
            Map<ID, User> ownerMap = new Map<ID, User>([SELECT ID, ManagerID FROM User WHERE ID IN : ownerIDSet]);
            for(EUR_CRM_SalesRep_Order__c sro : validSalesRepOrderList) {
                User u = ownerMap.get(sro.OwnerId);
                sro.EUR_CRM_Manager__c = u.managerID;
            }
        }
    }
}