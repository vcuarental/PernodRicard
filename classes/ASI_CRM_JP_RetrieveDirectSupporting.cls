/*********************************************************************************
 * Name:ASI_CRM_JP_RetrieveDirectSupporting
 * Description: Prefill the Direct Supporting Value if the rebate type is Direct Supporting
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 31/03/2015       Laputa: Conrad          Created
 * 13/09/2016		Laputa: Hugo			Updated. Add condition to check rebate type is blank or not
*********************************************************************************/

public with sharing class ASI_CRM_JP_RetrieveDirectSupporting extends ASI_CRM_JP_TriggerAbstract {


    public ASI_CRM_JP_RetrieveDirectSupporting() {
        super('ASI_CRM_JP_RetrieveDirectSupporting');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        
        List<ASI_CRM_Purchase_Contract_Line_Item__c> contractLineList = (List<ASI_CRM_Purchase_Contract_Line_Item__c>)sObjList;
        List<ASI_CRM_Purchase_Contract_Line_Item__c> validContractLineList = new List<ASI_CRM_Purchase_Contract_Line_Item__c>();
        
        if(oldMap == null) {
            for(ASI_CRM_Purchase_Contract_Line_Item__c contractLine : contractLineList) {
                if(String.isNotBlank(contractLine.ASI_CRM_Rebate_Type__c) && contractLine.ASI_CRM_Rebate_Type__c.contains('Direct Supporting')) {
                    validContractLineList.add(contractLine);
                }
            }
        } else {
            Map<ID, ASI_CRM_Purchase_Contract_Line_Item__c> contractLineOldMap = (Map<ID, ASI_CRM_Purchase_Contract_Line_Item__c>)oldMap;
            for(ASI_CRM_Purchase_Contract_Line_Item__c contractLine : contractLineList) {
                if((contractLine.ASI_CRM_Rebate_Type__c != contractLineOldMap.get(contractLine.id).ASI_CRM_Rebate_Type__c
                    || contractLine.ASI_CRM_Pay_To__c != contractLineOldMap.get(contractLine.id).ASI_CRM_Pay_To__c
                    || contractLine.ASI_CRM_Item_Group__c != contractLineOldMap.get(contractLine.id).ASI_CRM_Item_Group__c) 
                    && ((String.isNotBlank(contractLine.ASI_CRM_Rebate_Type__c) && contractLine.ASI_CRM_Rebate_Type__c.contains('Direct Supporting')) || (String.isNotBlank(contractLine.ASI_CRM_Rebate_Type__c) && contractLineOldMap.get(contractLine.id).ASI_CRM_Rebate_Type__c.contains('Direct Supporting')))) {
                    validContractLineList.add(contractLine);
                }
            }
        }
        
        if(validContractLineList.size() > 0) {
            
            Set<ID> contractIDSet = new Set<ID>();
            Set<ID> shipToIDSet = new Set<ID>();
            Set<ID> itemGroupIDSet = new Set<ID>();
            Set<ID> payToIDSet = new Set<ID>();
            
            for(ASI_CRM_Purchase_Contract_Line_Item__c contractLine : validContractLineList) {
                contractIDSet.add(contractLine.ASI_CRM_Purchase_Contract__c);
                if(contractLine.ASI_CRM_Item_Group__c != null) {
                    itemGroupIDSet.add(contractLine.ASI_CRM_Item_Group__c);
                }
                if(contractLine.ASI_CRM_Pay_To__c != null) {
                    payToIDSet.add(contractLine.ASI_CRM_Pay_To__c);
                }
                
                if(!contractLine.ASI_CRM_Rebate_Type__c.contains('Direct Supporting')) {
                    contractLine.ASI_CRM_JP_Current_Direct_Supporting__c = null;
                }
            }
            
            Map<ID, ASI_CRM_Purchase_Contract__c> contractMap = new Map<ID, ASI_CRM_Purchase_Contract__c>([SELECT ID, Name, ASI_CRM_BS_Retailer_Ship_To__c FROM ASI_CRM_Purchase_Contract__c WHERE ID IN : contractIDSet]);
            
            for(ASI_CRM_Purchase_Contract__c contract : contractMap.values()) {
                if(contract.ASI_CRM_BS_Retailer_Ship_To__c != null) {
                    shipToIDSet.add(contract.ASI_CRM_BS_Retailer_Ship_To__c);
                }
            }
            
            if(shipToIDSet.size() > 0 && itemGroupIDSet.size() > 0 && payToIDSet.size() > 0) {
                
                Map<String, List<ASI_CRM_Direct_Rebate_Data__c>> directRebateDataMap = new Map<String, List<ASI_CRM_Direct_Rebate_Data__c>>();
                List<ASI_CRM_Direct_Rebate_Data__c> directRebateDataList = [
                                                                                SELECT ID, Name, ASI_CRM_End_Date__c,
                                                                                    ASI_CRM_Item_Group__c, ASI_CRM_Pay_To__c, ASI_CRM_Rebate_Type__c,
                                                                                    ASI_CRM_Ship_To__c, ASI_CRM_Unit_Price__c
                                                                                FROM ASI_CRM_Direct_Rebate_Data__c
                                                                                WHERE ASI_CRM_End_Date__c >= : date.today()
                                                                                AND ASI_CRM_Item_Group__c IN : itemGroupIDSet
                                                                                AND ASI_CRM_Pay_To__c IN : payToIDSet
                                                                                AND ASI_CRM_Ship_To__c IN : shipToIDSet
                                                                                AND ASI_CRM_Rebate_Type__c LIKE '%Direct Supporting%'
                                                                                AND recordtype.developername = 'ASI_CRM_JP_Direct_Rebate_Data'
                                                                            ];
                
                if(directRebateDataList.size() > 0) {
                
                    for(ASI_CRM_Direct_Rebate_Data__c directRebateData : directRebateDataList) {
                        String key = (String)directRebateData.ASI_CRM_Item_Group__c + (String)directRebateData.ASI_CRM_Pay_To__c + (String)directRebateData.ASI_CRM_Ship_To__c;
                        
                        if(!directRebateDataMap.containsKey(key)) {
                        
                            List<ASI_CRM_Direct_Rebate_Data__c> directRebateDataTempList = new List<ASI_CRM_Direct_Rebate_Data__c>();
                            directRebateDataTempList.add(directRebateData);
                            directRebateDataMap.put(key, directRebateDataTempList);
                        } else {
                            List<ASI_CRM_Direct_Rebate_Data__c> directRebateDataTempList = directRebateDataMap.get(key);
                            directRebateDataTempList.add(directRebateData);
                            directRebateDataMap.put(key, directRebateDataTempList);
                        }
                    }
                    
                    for(ASI_CRM_Purchase_Contract_Line_Item__c contractLine : validContractLineList) {
                        String shipTo = (String)contractMap.get(contractLine.ASI_CRM_Purchase_Contract__c).ASI_CRM_BS_Retailer_Ship_To__c;
                        string key = (String)contractLine.ASI_CRM_Item_Group__c + (String)contractLine.ASI_CRM_Pay_To__c + shipTo;
                        
                        if(directRebateDataMap.containsKey(key)) {
                        
                            List<ASI_CRM_Direct_Rebate_Data__c> directRebateDataTempList = directRebateDataMap.get(key);
                            Decimal totalUnitPrice = 0;
                            
                            for(ASI_CRM_Direct_Rebate_Data__c directRebateData : directRebateDataTempList) {
                            
                                totalUnitPrice += directRebateData.ASI_CRM_Unit_Price__c != null ? directRebateData.ASI_CRM_Unit_Price__c : 0;
                            }
                            
                            contractLine.ASI_CRM_JP_Current_Direct_Supporting__c = totalUnitPrice;
                        } else {
                            contractLine.ASI_CRM_JP_Current_Direct_Supporting__c = null;
                        }
                    }
                } else {
                    for(ASI_CRM_Purchase_Contract_Line_Item__c contractLine : validContractLineList) {
                        contractLine.ASI_CRM_JP_Current_Direct_Supporting__c = null;
                    }
                }
                
            }
            
        }
        
    }

}