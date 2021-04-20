/*********************************************************************************
 * Name:ASI_CRM_JP_ContactTgrHdlr
 * Description: Contact Trigger Handler for CRM JP
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 20/11/2014       Laputa: Hank          Created
*********************************************************************************/

public with sharing class ASI_CRM_JP_ContactTgrHdlr extends ASI_CRM_JP_TriggerAbstract {

    public ASI_CRM_JP_ContactTgrHdlr() {
        super('ASI_CRM_JP_ContactTgrHdlr');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        
        List<Contact> cList = (List<Contact>)sObjList;
        Set<Id> customerIdSet = new Set<Id>();
        
        if (oldMap == null) {
            for (Contact c: cList) {
                customerIdSet.add(c.ASI_CRM_AccountAdditionalField__c);
            }
        }else{
        	Map<Id, Contact> oldConMap = (Map<Id, Contact>)oldMap;
        	for(Contact c:cList){
        		if(c.ASI_CRM_AccountAdditionalField__c != oldConMap.get(c.Id).ASI_CRM_AccountAdditionalField__c){
        			customerIdSet.add(c.ASI_CRM_AccountAdditionalField__c);
        		}
        	}
        }
        
        Map<Id, ASI_CRM_AccountsAdditionalField__c> customerMap = new Map<Id, ASI_CRM_AccountsAdditionalField__c>([Select Id, ASI_CRM_Account__c From ASI_CRM_AccountsAdditionalField__c Where Id In :customerIdSet]);
        
        if (oldMap == null) {
            for (Contact c: cList) { 
                c.AccountId = customerMap.get(c.ASI_CRM_AccountAdditionalField__c).ASI_CRM_Account__c;
            }
        }else{
        	Map<Id, Contact> oldConMap = (Map<Id, Contact>)oldMap;
        	for(Contact c:cList){
        		if(c.ASI_CRM_AccountAdditionalField__c != oldConMap.get(c.Id).ASI_CRM_AccountAdditionalField__c){
        			c.AccountId = customerMap.get(c.ASI_CRM_AccountAdditionalField__c).ASI_CRM_Account__c;
        		}
        	}
        }
    }
    
}