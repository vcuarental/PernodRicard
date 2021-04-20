public with sharing class EUR_CRM_TerritoryObjectiveHandler extends EUR_CRM_TriggerAbstract{
	
	public EUR_CRM_TerritoryObjectiveHandler(){
        super('EUR_CRM_TerritoryObjectiveHandler');
    }
    
    
    //before insert and update trigger to auto populate the territory or region owner as the owner of the Territory Objective owner
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap){
    	List<EUR_CRM_GB_Territory_Objective__c> objlist = (List<EUR_CRM_GB_Territory_Objective__c>) sObjList;
    	Set<Id> regionSet = new Set<Id>();
    	Set<Id> territorySet = new Set<Id>();
    	Map<Id, EUR_CRM_Territory__c> territoryMap = new Map<Id, EUR_CRM_Territory__c>();
    	Map<Id, EUR_CRM_Region__c> regionMap = new Map<Id, EUR_CRM_Region__c>();
    	if(tAction == TriggerAction.BEFORE_UPDATE || tAction == TriggerAction.BEFORE_INSERT){
    		for(EUR_CRM_GB_Territory_Objective__c obj : objlist){
    			if(obj.EUR_CRM_Territory__c != null){
    				territorySet.add(obj.EUR_CRM_Territory__c);
    			}else if(obj.EUR_CRM_Region__c != null){
    				regionSet.add(obj.EUR_CRM_Region__c);
    			}
    		}
    		if(territorySet.size()>0){
    			territoryMap = new Map<Id, EUR_CRM_Territory__c>([Select Id, EUR_CRM_Territory_Owner__c From EUR_CRM_Territory__c Where Id in: territorySet and EUR_CRM_Territory_Owner__r.IsActive = true LIMIT 5000]);
    		}
    		if(regionSet.size()>0){
    			regionMap = new Map<Id, EUR_CRM_Region__c>([Select Id, EUR_CRM_Region_Owner__c From EUR_CRM_Region__c Where Id in: regionSet and EUR_CRM_Region_Owner__r.IsActive = true LIMIT 5000]);
    		}
    		if(territorySet.size()>0 || regionSet.size()>0){
    			for(EUR_CRM_GB_Territory_Objective__c obj : objlist){
    				if(territoryMap.containsKey(obj.EUR_CRM_Territory__c)){
    					obj.OwnerId = territoryMap.get(obj.EUR_CRM_Territory__c).EUR_CRM_Territory_Owner__c;
    				}else if(regionMap.containsKey(obj.EUR_CRM_Region__c)){
    					obj.OwnerId = regionMap.get(obj.EUR_CRM_Region__c).EUR_CRM_Region_Owner__c;
    				}
    			}
    		}
    	}
    }
	
}