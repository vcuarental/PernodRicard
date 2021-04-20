/*********************************************************************************
 * Name:        ASI_CRM_MO_AccountAdditional_TriggerCls
 * Description: N/A
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2015-04-08       Introv: Daniel WONG     Created
*********************************************************************************/

public with sharing class ASI_CRM_MO_AccountAdditional_TriggerCls{
    public static void routineBeforeUpdate(list<ASI_CRM_AccountsAdditionalField__c> trigger_new, map<id, ASI_CRM_AccountsAdditionalField__c> trigger_oldMap){
        list<ASI_CRM_Audit_Trail__c> lstAT = new list<ASI_CRM_Audit_Trail__c>();
        set<id> setCustomer = new set<id>();
        set<id> setOT = new set<id>();
        map<id, string> mapOT = new map<id, string>();
        id MOAuditTrailRT = Global_RecordTypeCache.getRTId('ASI_CRM_Audit_Trail__cASI_CRM_MO_Audit_Trail');
        
        for(ASI_CRM_AccountsAdditionalField__c customer : trigger_new){
            if(customer.ASI_TH_CRM_OutletType__c != trigger_oldMap.get(customer.id).ASI_TH_CRM_OutletType__c){
                setCustomer.add(customer.id);
                setOT.add(customer.ASI_TH_CRM_OutletType__c);
                setOT.add(trigger_oldMap.get(customer.id).ASI_TH_CRM_OutletType__c);
            }
        }
        
        for(ASI_TH_CRM_OutletType__c ot : [SELECT Id, Name FROM ASI_TH_CRM_OutletType__c WHERE id IN :setOT]){
            mapOT.put(ot.Id, ot.Name);
        }
        
        for(ASI_CRM_AccountsAdditionalField__c customer : trigger_new){
            if(setCustomer.contains(customer.id)){
                lstAT.add(new ASI_CRM_Audit_Trail__c(
                    ASI_CRM_Account__c = customer.ASI_CRM_Account__c, 
                    ASI_CRM_Field_Name__c = 'Outlet Type', 
                    ASI_CRM_Original__c = trigger_oldMap.get(customer.id).ASI_TH_CRM_OutletType__c != NULL? mapOT.get(trigger_oldMap.get(customer.id).ASI_TH_CRM_OutletType__c) : NULL, 
                    ASI_CRM_New__c = customer.ASI_TH_CRM_OutletType__c != NULL? mapOT.get(customer.ASI_TH_CRM_OutletType__c) : NULL, 
                    RecordTypeId = MOAuditTrailRT
                ));
            }
        }
            
        if(lstAT != NULL && lstAT.size() > 0){
            insert lstAT;
        }
    }
}