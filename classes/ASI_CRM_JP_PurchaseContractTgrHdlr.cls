/*********************************************************************************
 * Name:ASI_CRM_JP_PurchaseContractTgrHdlr
 * Description: Purchase Contract Trigger Handler for CRM JP
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 18/11/2014       Laputa: Hank          Created
*********************************************************************************/

public with sharing class ASI_CRM_JP_PurchaseContractTgrHdlr extends ASI_CRM_JP_TriggerAbstract {

    public ASI_CRM_JP_PurchaseContractTgrHdlr() {
        super('ASI_CRM_JP_PurchaseContractTgrHdlr');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        
        List<ASI_CRM_Purchase_Contract__c> conList = (List<ASI_CRM_Purchase_Contract__c>)sObjList;
        Set<Id> ownerIdSet = new Set<Id>();
        
        if (oldMap == null) {
            for (ASI_CRM_Purchase_Contract__c con : conList) {
                ownerIdSet.add(con.ownerId);
                if(con.RecordTypeId == Global_RecordTypeCache.getRtId('ASI_CRM_Purchase_Contract__cASI_CRM_JP_Direct_Rebate_Contract') || 
                        con.RecordTypeId == Global_RecordTypeCache.getRtId('ASI_CRM_Purchase_Contract__cASI_CRM_JP_Direct_Rebate_Contract_Read_Only')){
                    con.ASI_CRM_Clone_Record_Type_Id__c = Global_RecordTypeCache.getRtId('ASI_CRM_Purchase_Contract__cASI_CRM_JP_Direct_Rebate_Contract');
                }else if(con.RecordTypeId == Global_RecordTypeCache.getRtId('ASI_CRM_Purchase_Contract__cASI_CRM_JP_Indirect_Rebate_Contract') || 
                        con.RecordTypeId == Global_RecordTypeCache.getRtId('ASI_CRM_Purchase_Contract__cASI_CRM_JP_Indirect_Rebate_Contract_Read_Only')){
                    con.ASI_CRM_Clone_Record_Type_Id__c = Global_RecordTypeCache.getRtId('ASI_CRM_Purchase_Contract__cASI_CRM_JP_Indirect_Rebate_Contract');
                }else if(con.RecordTypeId == Global_RecordTypeCache.getRtId('ASI_CRM_Purchase_Contract__cASI_CRM_JP_SPTD_Contract') || 
                        con.RecordTypeId == Global_RecordTypeCache.getRtId('ASI_CRM_Purchase_Contract__cASI_CRM_JP_SPTD_Contract_Read_Only')){
                    con.ASI_CRM_Clone_Record_Type_Id__c = Global_RecordTypeCache.getRtId('ASI_CRM_Purchase_Contract__cASI_CRM_JP_SPTD_Contract');
                }
            }
        }
        else {
            Map<ID, ASI_CRM_Purchase_Contract__c> oldConMap = (Map<ID, ASI_CRM_Purchase_Contract__c>) oldMap;
            for (ASI_CRM_Purchase_Contract__c con: conList) {
                if (con.ownerId != null && (con.ownerId != oldConMap.get(con.Id).ownerId)) {
                    ownerIdSet.add(con.ownerId);
                }
                if(con.RecordTypeId != oldConMap.get(con.Id).RecordTypeId){
                    if(con.RecordTypeId == Global_RecordTypeCache.getRtId('ASI_CRM_Purchase_Contract__cASI_CRM_JP_Direct_Rebate_Contract') || 
                            con.RecordTypeId == Global_RecordTypeCache.getRtId('ASI_CRM_Purchase_Contract__cASI_CRM_JP_Direct_Rebate_Contract_Read_Only')){
                        con.ASI_CRM_Clone_Record_Type_Id__c = Global_RecordTypeCache.getRtId('ASI_CRM_Purchase_Contract__cASI_CRM_JP_Direct_Rebate_Contract');
                    }else if(con.RecordTypeId == Global_RecordTypeCache.getRtId('ASI_CRM_Purchase_Contract__cASI_CRM_JP_Indirect_Rebate_Contract') || 
                            con.RecordTypeId == Global_RecordTypeCache.getRtId('ASI_CRM_Purchase_Contract__cASI_CRM_JP_Indirect_Rebate_Contract_Read_Only')){
                        con.ASI_CRM_Clone_Record_Type_Id__c = Global_RecordTypeCache.getRtId('ASI_CRM_Purchase_Contract__cASI_CRM_JP_Indirect_Rebate_Contract');
                    }else if(con.RecordTypeId == Global_RecordTypeCache.getRtId('ASI_CRM_Purchase_Contract__cASI_CRM_JP_SPTD_Contract') || 
                            con.RecordTypeId == Global_RecordTypeCache.getRtId('ASI_CRM_Purchase_Contract__cASI_CRM_JP_SPTD_Contract_Read_Only')){
                        con.ASI_CRM_Clone_Record_Type_Id__c = Global_RecordTypeCache.getRtId('ASI_CRM_Purchase_Contract__cASI_CRM_JP_SPTD_Contract');
                    }
                }
            }
        }
        
        Map<Id, User> ownerMap = new Map<Id, User>([Select Id, ASI_KOR_User_Branch_Code__c From User Where Id In :ownerIdSet]);
        
        
        if (oldMap == null) {
            for (ASI_CRM_Purchase_Contract__c con : conList) {
                con.ASI_CRM_Sales_Group__c = ownerMap.get(con.ownerId).ASI_KOR_User_Branch_Code__c;
            }
        }
        else {
            Map<ID, ASI_CRM_Purchase_Contract__c> oldConMap = (Map<ID, ASI_CRM_Purchase_Contract__c>) oldMap;
            for (ASI_CRM_Purchase_Contract__c con: conList) {
                if (con.ownerId != null && (con.ownerId != oldConMap.get(con.Id).ownerId)) {
                    con.ASI_CRM_Sales_Group__c = ownerMap.get(con.ownerId).ASI_KOR_User_Branch_Code__c;
                }
            }
        }       
    }
    
}