/**
PR DE Contact ownership re-assignemt triger - if Account owner changes, contact owner must also change

*/
public class EUR_CRM_DE_ContactAccountHandler  extends EUR_CRM_TriggerAbstract {
     
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap){
        Set<Id> validAccounts = new Set<id>();
        for(EUR_CRM_Account__c euAccount : (List<EUR_CRM_Account__c>) sObjList){
            EUR_CRM_Account__c oldAccount = oldMap != null ? (EUR_CRM_Account__c) oldMap.get(euAccount.id) : null;
            if(euAccount.EUR_CRM_Country_Code__c == 'DE' &&
                    oldAccount != null &&
                    oldAccount.ownerid != euAccount.ownerid ){
                validAccounts.add(euAccount.id);
            }
        } 
        List<Contact> contactsForUpdate = new List<Contact>();
        if(validAccounts.size() > 0)
        for(Contact c : [select id,EUR_CRM_Account__c,ownerid from Contact where EUR_CRM_Account__c in: validAccounts
        and EUR_CRM_Account__c != null]){
            EUR_CRM_Account__c euAccount = (EUR_CRM_Account__c) newMap.get(c.EUR_CRM_Account__c);
            if(c.ownerid != euAccount.ownerid ){
                c.ownerid = euAccount.ownerid ;
                contactsForUpdate.add(c);
            }
        }
        if(contactsForUpdate.size() > 0) {
            List<Database.SaveResult> srs = Database.update(contactsForUpdate, false);
            System.debug('contactsForUpdate Results: ' + srs);
        }
    }
    
    public EUR_CRM_DE_ContactAccountHandler(){
        super('EUR_CRM_DE_ContactAccountHandler');
    }  
}