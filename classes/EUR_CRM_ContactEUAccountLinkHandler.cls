public with sharing class EUR_CRM_ContactEUAccountLinkHandler extends EUR_CRM_TriggerAbstract {
	
	public EUR_CRM_ContactEUAccountLinkHandler(){
        super('EUR_CRM_ContactEUAccountLinkHandler');
    }
    
    // trigger to auto link Account when contact is inserted or updated and EU Account is specified
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap){
    	List<Contact> contactlist = (List<Contact>) sObjList;
    	Map<Id, Contact> oldContactMap = (Map<Id, Contact>) oldMap;
    	Map<Id, Contact> newContactMap = (Map<Id, Contact>) newMap;
    	Set<Id> euAcctIdSet = new Set<Id>();
    	for(Contact c : contactlist){
    		if((c.EUR_CRM_Account__c != null && tAction == TriggerAction.BEFORE_INSERT) 
    			|| (tAction == TriggerAction.BEFORE_UPDATE && c.EUR_CRM_Account__c != null 
    			&& oldContactMap.get(c.Id).EUR_CRM_Account__c <> newContactMap.get(c.Id).EUR_CRM_Account__c))
    			euAcctIdSet.add(c.EUR_CRM_Account__c);
    	}
    	if(euAcctIdSet.size()>0){
    		Map<Id, Id> euAcct2AcctMap = new Map<Id, Id>();
    		for(EUR_CRM_Account_Link__c acctlink : [Select EUR_CRM_Standard_Account__c, EUR_CRM_EU_Account__c 
    				From EUR_CRM_Account_Link__c Where EUR_CRM_EU_Account__c in: euAcctIdSet]){
    			euAcct2AcctMap.put(acctlink.EUR_CRM_EU_Account__c, acctlink.EUR_CRM_Standard_Account__c);			
    		}
    		if(euAcct2AcctMap.size()>0){
    			for(Contact c : contactlist){
	    			if(c.EUR_CRM_Account__c != null && euAcct2AcctMap.containsKey(c.EUR_CRM_Account__c)){
	    				c.AccountId = euAcct2AcctMap.get(c.EUR_CRM_Account__c);
	    			}
    			}
    		}
    	}	
    }
}