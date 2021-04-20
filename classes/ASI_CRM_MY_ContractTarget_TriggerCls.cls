/*********************************************************************************
 * Name:        ASI_CRM_ContractTarget_TriggerClass--> ASI_CRM_MY_ContractTatget_TriggerCls
 * Description: N/A
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2014-01-04       Introv: Daniel WONG     Created
*********************************************************************************/

public without sharing class ASI_CRM_MY_ContractTarget_TriggerCls{
    public static String className = 'ASI_CRM_MY_ContractTrigger';

    public static void routineBeforeInsert(list<ASI_CRM_ContractTarget__c> trigger_new){
        if(!ASI_CRM_MY_Function.IsBypassTrigger(className)){
            id idMinSPRT = Global_RecordTypeCache.getRtId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_MY_MinSP');
            id idWSSPRT = Global_RecordTypeCache.getRtId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_MY_WS_SP');
            id idIGCRT = Global_RecordTypeCache.getRtId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_MY_IGC');
            id idSKURT = Global_RecordTypeCache.getRtId('ASI_MFM_SKU_Code__cASI_CRM_MY_SKU');
            
            set<id> setSKUs = new set<id>();
            set<string> setKey = new set<string>();
            set<id> setContractIDs = new set<id>();
            map<id, decimal> mapMinSP = new map<id, decimal>();
            map<id, decimal> mapWSSP = new map<id, decimal>();
            map<id, decimal> mapIGC = new map<id, decimal>();
            map<date, map<id, decimal>> mapMinSPofDate = new map<date, map<id, decimal>>();
            map<date, map<id, decimal>> mapWSSPofDate = new map<date, map<id, decimal>>();
            map<date, map<id, decimal>> mapIGCofDate = new map<date, map<id, decimal>>();
            map<id, date> mapDate = new map<id, date>();
            
            //Added by 2018-02-28 Linus@introv
            map<id, String> mapBranch = new map<id, String>();
            
            for(ASI_CRM_ContractTarget__c i : trigger_new){
                setSKUs.add(i.ASI_CRM_SKU__c);
                setContractIDs.add(i.ASI_CRM_Contract__c);
            }
            for (ASI_TH_CRM_Contract__c c : [SELECT id, ASI_TH_CRM_Start_Date__c, ASI_CRM_Customer_Category_Code_2__c, ASI_CRM_Branch__c FROM ASI_TH_CRM_Contract__c WHERE id IN :setContractIDs]) {
                //setSDate.add(c.ASI_TH_CRM_Start_Date__c);
                setKey.add(string.valueOf(c.ASI_TH_CRM_Start_Date__c)+ '___' + c.ASI_CRM_Customer_Category_Code_2__c);
                system.debug('ASI_CRM_MY_ContractTarget_TriggerCls: routineBeforeInsert ---------------ContractID :' + c.id + ' StringKey : ' + setKey );
                mapDate.put(c.id, c.ASI_TH_CRM_Start_Date__c);
                mapBranch.put(c.id, c.ASI_CRM_Branch__c);
            }
            map<id, decimal> mapSKUPackSize = ASI_CRM_MY_Function.getSKUPackingMap(setSKUs, idSKURT);
            for (string str : setKey) {
                date dteDate = date.valueOf(str.split('___', 2)[0]);
                string customercate =  str.split('___', 2)[1];   
                system.debug('ASI_CRM_MY_ContractTarget_TriggerCls: routineBeforeInsert str-----------------------------' + str);
                system.debug('ASI_CRM_MY_ContractTarget_TriggerCls: routineBeforeInsert dteDate-----------------------------' + dteDate);
                system.debug('ASI_CRM_MY_ContractTarget_TriggerCls: routineBeforeInsert customercate-----------------------------' + customercate);
                mapMinSP = ASI_CRM_MY_Function.getSKUMinSP(setSKUs, dteDate, idMinSPRT);
                mapWSSP = ASI_CRM_MY_Function.getSKUWSSP(setSKUs, dteDate, idWSSPRT, customercate);
                mapIGC = ASI_CRM_MY_Function.getSKUIGC(setSKUs, dteDate, idIGCRT);
                system.debug('ASI_CRM_MY_ContractTarget_TriggerCls: routineBeforeInsert mapWSSP -----------------------------' + mapWSSP);
                mapMinSPofDate.put(dteDate, mapMinSP);
                mapWSSPofDate.put(dteDate, mapWSSP);
                mapIGCofDate.put(dteDate, mapIGC);
            }
            system.debug('-----mapWSSPofDate-----' + mapWSSPofDate);
            for(ASI_CRM_ContractTarget__c i : trigger_new){
                if (i.ASI_CRM_SKU__c != NULL){
                    Decimal decMinSP = 0;  
                    Decimal decWSSP = 0;
                    Decimal decIGC = 0;
                    Decimal decPackSize = 0;
                    map<id, decimal> mapT = new map<id, decimal>();
                    date dteTemp = mapDate.get(i.ASI_CRM_Contract__c);
                    mapT = mapMinSPofDate.get(dteTemp);
                    
                    if (mapT != null) {
                        if (mapT.get(i.ASI_CRM_SKU__c) != null) {
                            decMinSP = mapT.get(i.ASI_CRM_SKU__c);
                        }
                    }
                    if (mapSKUPackSize.get(i.ASI_CRM_SKU__c) != null) {
                        decPackSize = mapSKUPackSize.get(i.ASI_CRM_SKU__c);
                    }
                    i.ASI_CRM_MinSPCase__c = decMinSP * decPackSize;
                    system.debug('------------------------dteTemp------------------------' + dteTemp);
                    
                    mapT = mapWSSPofDate.get(dteTemp);
                    if (mapT != null) {
                        if (mapT.get(i.ASI_CRM_SKU__c) != null) {
                            decWSSP = mapT.get(i.ASI_CRM_SKU__c);
                        }
                    }
                    i.ASI_CRM_WSSP__c = decWSSP;
                    
                    mapT = mapIGCofDate.get(dteTemp);
                    if (mapT != null) {
                        if (mapT.get(i.ASI_CRM_SKU__c) != null) {
                            decIGC = mapT.get(i.ASI_CRM_SKU__c);
                        }
                    }
                    i.ASI_CRM_IGC__c = decIGC;
                    
                    // Added by 2018-02-28 Linus@introv
                    i.ASI_CRM_Branch__c = mapBranch.get(i.ASI_CRM_Contract__c);
                }
                
                System.debug('Total Number of SOQL Queries allowed in this apex code context((Contract Target)Before Insert): ' +  Limits.getQueries());
            }
        }
    }
    
    public static void routineBeforeUpsert(list<ASI_CRM_ContractTarget__c> trigger_new){
        if(!ASI_CRM_MY_Function.IsBypassTrigger(className)){
            Set<Id> setContract = new Set<Id>();
            List<ASI_TH_CRM_Contract__c> lstContract = new List<ASI_TH_CRM_Contract__c>();
            // Added by 2018-02-28 Linus@introv
            map<id, String> mapBranch = new map<id, String>();
            
            for(ASI_CRM_ContractTarget__c i : trigger_new){
                setContract.add(i.ASI_CRM_Contract__c);
            }
            
            lstContract = [SELECT Id, ASI_CRM_Branch__c FROM ASI_TH_CRM_Contract__c WHERE Id IN :setContract];
        
            for(ASI_TH_CRM_Contract__c i : lstContract){
                i.ASI_CRM_Last_Revision_Date__c = system.now();
                
                mapBranch.put(i.id, i.ASI_CRM_Branch__c);
            }
            
            for(ASI_CRM_ContractTarget__c i : trigger_new){
                i.ASI_CRM_Branch__c = mapBranch.get(i.ASI_CRM_Contract__c);
            }
            
            System.debug('Total Number of SOQL Queries allowed in this apex code context((Contract Target)Before Update): ' +  Limits.getQueries());
            
            update lstContract;
        }
    }
}