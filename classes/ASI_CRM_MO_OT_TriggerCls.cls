/*********************************************************************************
 * Name:        ASI_CRM_MO_Offtake_Stock_In_Trade_TriggerCls
 * Description: N/A
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2015-04-13       Introv: Daniel WONG     Created - Set the TriggerClass as without sharing for Seapower Trading to search for Contracts.
*********************************************************************************/

public without sharing class ASI_CRM_MO_OT_TriggerCls{
    public static id MOAccountRT = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__cASI_CRM_MO_WSOfftakeDetail');
    public static id MOContractRT = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Contract__cASI_CRM_MO_Contract'); 
    
    public static void routineBeforeInsert(list<ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c> trigger_new){
        date queryDate;
        set<id> setOutlet = new set<id>();
        set<id> setContract = new set<id>();
        map<string, ASI_CRM_ContractVolumeIncentive__c> mapContractVolume = new map<string, ASI_CRM_ContractVolumeIncentive__c>();
        map<string, id> mapContract = new map<string, id>();
        map<String, String> mapSKUItmGrp = new map<String, String>();
        set<id> setSKUs = new set<id>();
        list<ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c> lstOT = new list<ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c>();
        
        
        ASI_CRM_MO_Offtake_Stock_In_Trade_Common.generateWSOfftakeIncentive(trigger_new, false);
    }
}