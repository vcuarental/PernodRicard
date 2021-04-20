public with sharing class EUR_CRM_SalesOrderAssignPreferredDate extends EUR_CRM_TriggerAbstract  {

	public EUR_CRM_SalesOrderAssignPreferredDate() {
    	super('EUR_CRM_SalesOrderAssignPreferredDate');
	}

	private static final String CLASS_NAME = 'EUR_CRM_SalesOrderAssignPreferredDate';
	private static final Set<String> SO_RT_TO_UPDATE_PREFERRED_DELIVERY_DATE = EUR_CRM_RecordTypeHelper_v2.getSettingsSet(CLASS_NAME, 'SO_RT_TO_UPDATE_PREFERRED_DELIVERY_DATE');
//	private static final Set<String> SO_RT_TO_UPDATE_PREFERRED_DELIVERY_DATE = new Set<String>{
//      'EUR_ZA_Direct_Sales_Order',
//      'EUR_ZA_Free_Goods_Order'
//	};
	
	public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
  		List<Recordtype> salesOrderRecordTypes = Global_RecordTypeCache.getRtList('EUR_CRM_Sales_Order__c');
		Map<Id,Recordtype> salesOrderRecordTypesMap = new Map<Id,Recordtype>();
        
        for(Recordtype rt : salesOrderRecordTypes ){
           salesOrderRecordTypesMap.put(rt.id,rt);
        }
        
        List<EUR_CRM_Sales_Order__c> salesOrderList = (List<EUR_CRM_Sales_Order__c>) sObjList;
        List<EUR_CRM_Sales_Order__c> validSalesOrderList = new List<EUR_CRM_Sales_Order__c>();
        
        Set<ID> accountIDSet = new Set<ID>();
        for(EUR_CRM_Sales_Order__c so : salesOrderList) {
        	String salesOrdeRTDevName = salesOrderRecordTypesMap.get(so.recordtypeid).developername;
        	if(SO_RT_TO_UPDATE_PREFERRED_DELIVERY_DATE.contains(salesOrdeRTDevName ) ){
        		if(oldMap != null) {
        			if(so.EUR_CRM_Account__c != (((Map<ID, EUR_CRM_Sales_Order__c>)(oldMap)).get(so.id)).EUR_CRM_Account__c) {
        				validSalesOrderList.add(so);
        				accountIDSet.add(so.EUR_CRM_Account__c);
        			}
        		} else {
        			validSalesOrderList.add(so);
        			accountIDSet.add(so.EUR_CRM_Account__c);
        		}
        	}
        }
        if(validSalesOrderList.size() > 0) {
        	Map<ID, EUR_CRM_Account__c> accMap = new Map<ID, EUR_CRM_Account__c>([SELECT ID, Name, EUR_CRM_Preferred_delivery_day__c FROM EUR_CRM_Account__c WHERE ID IN : accountIDSet]);
        	for(EUR_CRM_Sales_Order__c so : validSalesOrderList) {
        		so.EUR_CRM_Preferred_Delivery_Day__c = accMap.get(so.EUR_CRM_Account__c).EUR_CRM_Preferred_delivery_day__c;
        	}
        }
        
	}

}