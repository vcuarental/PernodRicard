/*********************************************************************************
 * Name:        ASI_CRM_MY_Account_TriggerCls
 * Description: N/A
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2015-03-31       Introv: Daniel WONG     Created
*********************************************************************************/

public with sharing class ASI_CRM_MO_Account_TriggerCls{
    public static String className = 'ASI_CRM_MO_Account_TriggerCls';
    public static id MOAccountRT = Global_RecordTypeCache.getRTId('AccountASI_HK_CRM_Outlet');
    
    public static void routineBeforeInsert(list<Account> trigger_new){
        system.debug('-----ASI_CRM_MO_Account_TriggerCls.routineBeforeUpdate-----');
        if(!ASI_CRM_MO_Function.IsBypassTrigger(className)){
            ASI_CRM_MO_RunningNumber_TriggerCls autoNumAssign = null;
            
            for(Account acc : trigger_new){
                if(acc.recordTypeId == MOAccountRT && acc.ASI_HK_CRM_Location__c == '#_MACDPLOC'){
                    autoNumAssign = new ASI_CRM_MO_RunningNumber_TriggerCls('Account'); // to Match the Module in Running Number
                    String prefix = ''; // Default assign a value
                    system.debug('---acc.ASI_HK_CRM_Channel__c--- ' + acc.ASI_HK_CRM_Channel__c);
                    if(acc.ASI_HK_CRM_Channel__c == 'On Trade'){
                        prefix = 'ON';
                    }
                    if(acc.ASI_HK_CRM_Channel__c == 'Off Trade'){
                        prefix = 'OF';
                    }
                    
                    acc.ASI_KOR_Customer_Code__c = prefix;                   
                    if(prefix != ''){
                        acc.ASI_KOR_Customer_Code__c += autoNumAssign.nextAutoNumStr();
                        autoNumAssign.writeToDB();
                    }
                }
            }
        }
    }
    
    public static void routineBeforeUpdate(list<Account> trigger_new, map<id, Account> trigger_oldMap){
        if(!ASI_CRM_MO_Function.IsBypassTrigger(className)){
            list<ASI_CRM_Audit_Trail__c> lstAT = new list<ASI_CRM_Audit_Trail__c>();
            id MOAuditTrailRT = Global_RecordTypeCache.getRTId('ASI_CRM_Audit_Trail__cASI_CRM_MO_Audit_Trail');
            set<id> setAccount = new set<id>();
            set<id> setOwner = new set<id>();
            map<id, string> mapOwner = new map<id, string>();
        
            for(Account acc : trigger_new){
                if(acc.Ownerid != trigger_oldMap.get(acc.id).Ownerid){
                    setAccount.add(acc.id);
                    setOwner.add(acc.Ownerid);
                    setOwner.add(trigger_oldMap.get(acc.id).Ownerid);
                }
            }
            
            for(User u : [SELECT id, Name FROM User WHERE id IN : setOwner]){
                mapOwner.put(u.id, u.name);
            }
        
            for(Account acc : trigger_new){
                if(acc.recordTypeId == MOAccountRT && acc.ASI_HK_CRM_Location__c == '#_MACDPLOC'){
                    if(acc.Name != trigger_oldMap.get(acc.id).Name){
                        lstAT.add(new ASI_CRM_Audit_Trail__c(ASI_CRM_Account__c = acc.id, ASI_CRM_Field_Name__c = 'Account Name', ASI_CRM_Original__c = trigger_oldMap.get(acc.id).Name, ASI_CRM_New__c = acc.Name, RecordTypeId = MOAuditTrailRT));
                    }
                    
                    if(acc.ASI_HK_CRM_Address__c != trigger_oldMap.get(acc.id).ASI_HK_CRM_Address__c){
                        lstAT.add(new ASI_CRM_Audit_Trail__c(ASI_CRM_Account__c = acc.id, ASI_CRM_Field_Name__c = 'Address', ASI_CRM_Original__c = trigger_oldMap.get(acc.id).ASI_HK_CRM_Address__c, ASI_CRM_New__c = acc.ASI_HK_CRM_Address__c, RecordTypeId = MOAuditTrailRT));
                    }
                    
                    if(setAccount.contains(acc.id)){
                        lstAT.add(new ASI_CRM_Audit_Trail__c(ASI_CRM_Account__c = acc.id, ASI_CRM_Field_Name__c = 'Owner', ASI_CRM_Original__c = mapOwner.get(trigger_oldMap.get(acc.id).Ownerid), ASI_CRM_New__c = mapOwner.get(acc.Ownerid), RecordTypeId = MOAuditTrailRT));
                    }
                }
            }
            
            if(lstAT != NULL && lstAT.size() > 0)
                insert lstAT;
        }
    }
}