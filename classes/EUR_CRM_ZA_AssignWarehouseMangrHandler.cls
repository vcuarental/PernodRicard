public with sharing class EUR_CRM_ZA_AssignWarehouseMangrHandler extends EUR_CRM_TriggerAbstract {

	public EUR_CRM_ZA_AssignWarehouseMangrHandler() {
	    super('EUR_CRM_ZA_AssignWarehouseMangrHandler');
	}
	
	private Set<String> validRecordTypes = new Set<String>{
		'EUR_ZA_POSM_Order'
	};
	 
	public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
		List<Recordtype> posmOrderRecordTypes = Global_RecordTypeCache.getRtList('EUR_CRM_POSM_Order__c');
        Map<Id,Recordtype> posmOrderRecordTypesMap = new Map<Id,Recordtype>();
        
        for(Recordtype rt : posmOrderRecordTypes ){
           posmOrderRecordTypesMap.put(rt.id,rt);
        }
        
        if(tAction == TriggerAction.BEFORE_INSERT){
        	Set<Id> accountIds = new Set<Id>();
	        Map<Id, EUR_CRM_Account__c> accountManagersMap = new Map<Id, EUR_CRM_Account__c>();
	        
	        for(EUR_CRM_POSM_Order__c posmOrder : (List<EUR_CRM_POSM_Order__c>) sObjList) {
	        	String posmOrderRTDevName = posmOrderRecordTypesMap.get(posmOrder.recordtypeid).developername;            
	            if(validRecordTypes.contains(posmOrderRTDevName)){
	            	accountIds.add(posmOrder.EUR_CRM_Account__c);
	            }
	        }
	        
	        for(EUR_CRM_Account__c account : [SELECT Id, EUR_CRM_Event_Manager__c, EUR_CRM_Warehouse_Manager__c FROM EUR_CRM_Account__c WHERE Id IN :accountIds]){
	        	accountManagersMap.put(account.Id, account);
	        }
	        
	        for(EUR_CRM_POSM_Order__c posmOrder : (List<EUR_CRM_POSM_Order__c>) sObjList) {
	        	String posmOrderRTDevName = posmOrderRecordTypesMap.get(posmOrder.recordtypeid).developername;            
	            if(validRecordTypes.contains(posmOrderRTDevName)){
	            	if(accountManagersMap.containskey(posmOrder.EUR_CRM_Account__c)){
	            		posmOrder.EUR_CRM_Warehouse_Manager__c = accountManagersMap.get(posmOrder.EUR_CRM_Account__c).EUR_CRM_Warehouse_Manager__c;
	            	}
	            }
	        }
        } else if(tAction == TriggerAction.BEFORE_UPDATE){
        	Set<Id> accountIds = new Set<Id>();
	        Map<Id, EUR_CRM_Account__c> accountManagersMap = new Map<Id, EUR_CRM_Account__c>();
	        
	        for(EUR_CRM_POSM_Order__c posmOrder : (List<EUR_CRM_POSM_Order__c>) sObjList) {
	        	String posmOrderRTDevName = posmOrderRecordTypesMap.get(posmOrder.recordtypeid).developername;            
	            EUR_CRM_POSM_Order__c oldRecord = (EUR_CRM_POSM_Order__c ) oldMap.get(posmOrder.id);  
	            if(validRecordTypes.contains(posmOrderRTDevName)){
	            	if(posmOrder.EUR_CRM_Account__c != oldRecord.EUR_CRM_Account__c){
	            		accountIds.add(posmOrder.EUR_CRM_Account__c);
	            	}
	            }
	        }
	        
	        for(EUR_CRM_Account__c account : [SELECT Id, EUR_CRM_Event_Manager__c, EUR_CRM_Warehouse_Manager__c FROM EUR_CRM_Account__c WHERE Id IN :accountIds]){
	        	accountManagersMap.put(account.Id, account);
	        }
	        
	        for(EUR_CRM_POSM_Order__c posmOrder : (List<EUR_CRM_POSM_Order__c>) sObjList) {
	        	String posmOrderRTDevName = posmOrderRecordTypesMap.get(posmOrder.recordtypeid).developername;            
	            EUR_CRM_POSM_Order__c oldRecord = (EUR_CRM_POSM_Order__c ) oldMap.get(posmOrder.id);  
	            if(validRecordTypes.contains(posmOrderRTDevName)){
	            	if(accountManagersMap.containskey(posmOrder.EUR_CRM_Account__c)){
	            		if(posmOrder.EUR_CRM_Account__c != oldRecord.EUR_CRM_Account__c){
	            			posmOrder.EUR_CRM_Warehouse_Manager__c = accountManagersMap.get(posmOrder.EUR_CRM_Account__c).EUR_CRM_Warehouse_Manager__c;
	            		}
	            	}
	            }
	        }
        }
        
        
	}
}