/*********************************************************************************
 * Name:        ASI_CRM_Contact_TriggerClass
 * Description: N/A
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2015-02-03       Introv: Daniel WONG     Created
*********************************************************************************/


public with sharing class ASI_CRM_MY_Contact_TriggerClass{
    public static String className = 'ASI_CRM_MY_Contact_TriggerClass';
    
    public static void routineBeforeInsert(list<Contact> trigger_new){
        //Id recordTypeId =  Global_RecordTypeCache.getRTId('AccountASI_MFM_MY_Customer');
        
        map<Id, Account> mapAcc = new map<id, Account>();
        map<Id, Id> mapCustomerAcc = new map<Id, Id>();
        
        set<Id> setCustomerId = new set<Id>();
        set<Id> setAccountId = new set<Id>();
        set<Id> setMYCustomerRecordType = new set<Id>();
        set<Id> setMYAccountRecordType = new set<Id>();
        
        setMYCustomerRecordType.add(Global_RecordTypeCache.getRTId('ASI_CRM_AccountAdditionalField__cASI_CRM_MY_Outlet'));
        setMYCustomerRecordType.add(Global_RecordTypeCache.getRTId('ASI_CRM_AccountAdditionalField__cASI_CRM_MY_DummyOutletColdCall'));
        setMYCustomerRecordType.add(Global_RecordTypeCache.getRTId('ASI_CRM_AccountAdditionalField__cASI_CRM_MY_DummyOutletDepletion'));
        setMYCustomerRecordType.add(Global_RecordTypeCache.getRTId('ASI_CRM_AccountAdditionalField__cASI_ASI_CRM_MY_Potential_Outlet'));
        setMYCustomerRecordType.add(Global_RecordTypeCache.getRTId('ASI_CRM_AccountAdditionalField__cASI_ASI_CRM_MY_Wholesaler'));
        
        setMYAccountRecordType.add(Global_RecordTypeCache.getRTId('AccountASI_MFM_MY_Customer'));
        setMYAccountRecordType.add(Global_RecordTypeCache.getRTId('AccountASI_MFM_MY_Supplier'));
        
        for(Contact objCon : trigger_new){
            setCustomerId.add(objCon.ASI_CRM_AccountAdditionalField__c);
        }
        
        system.debug('setCustomerId' + setCustomerId);
        
        for(ASI_CRM_AccountsAdditionalField__c c : [SELECT id, ASI_CRM_Account__c FROM ASI_CRM_AccountsAdditionalField__c WHERE id IN :setCustomerId AND ASI_CRM_Account__c != NULL]){
            setAccountId.add(c.ASI_CRM_Account__c);
            mapCustomerAcc.put(c.id, c.ASI_CRM_Account__c);
        }
        
        system.debug('setAccountId' + setAccountId);
        system.debug('mapCustomerAcc' + mapCustomerAcc);
        
        //for(Account i : [SELECT id FROM ACCOUNT WHERE id IN :setAccountId AND recordTypeId IN :setMYAccountRecordType]){
        //    mapAcc.put(i.id, i);
        //}
        
        for(Contact objCon : trigger_new){
            system.debug('objCon.ASI_CRM_AccountAdditionalField__c' + objCon.ASI_CRM_AccountAdditionalField__c);
            
            if(mapCustomerAcc.get(objCon.ASI_CRM_AccountAdditionalField__c) != NULL )
                objCon.AccountId = mapCustomerAcc.get(objCon.ASI_CRM_AccountAdditionalField__c);
            //else
                //objCon.addError('CANNOT Match the related Account.');
        }
    }
}