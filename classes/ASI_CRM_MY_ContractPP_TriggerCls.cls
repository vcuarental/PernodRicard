/*********************************************************************************
 * Name:        ASI_CRM_ContractPromoterPlacement_TriggerClass--> ASI_CRM_MY_ContractPP_TriggerCls
 * Description: N/A
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2014-01-19       Introv: Axel    Created
*********************************************************************************/

public without sharing class ASI_CRM_MY_ContractPP_TriggerCls{
    public static String className = 'ASI_CRM_MY_ContractTrigger';
    
    public static void routineBeforeInsert(list<ASI_CRM_PromoterPlacement__c> trigger_new){
        if(!ASI_CRM_MY_Function.IsBypassTrigger(className)){
            id idWSSPRT = Global_RecordTypeCache.getRtId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_MY_WS_SP');
            id idSKURT = Global_RecordTypeCache.getRtId('ASI_MFM_SKU_Code__cASI_CRM_MY_SKU');
            id idIGCRT = Global_RecordTypeCache.getRtId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_MY_IGC');
            
            set<id> setSKUs = new set<id>();
            //set<date> setSDate = new set<date>();
            set<string> setKey = new set<string>();
            set<id> setContractIDs = new set<id>();
            map<id, decimal> mapWSSP = new map<id, decimal>();
            map<date, map<id, decimal>> mapWSSPofDate = new map<date, map<id, decimal>>();
            map<id, decimal> mapIGC = new map<id, decimal>();
            map<date, map<id, decimal>> mapIGCofDate = new map<date, map<id, decimal>>();
            map<id, date> mapDate = new map<id, date>();
            
            for(ASI_CRM_PromoterPlacement__c i : trigger_new){
                setSKUs.add(i.ASI_CRM_SKU__c);
                setContractIDs.add(i.ASI_CRM_Contract__c);
            }
            for (ASI_TH_CRM_Contract__c c : [SELECT id, ASI_TH_CRM_Start_Date__c, ASI_CRM_Customer_Category_Code_2__c FROM ASI_TH_CRM_Contract__c WHERE id IN :setContractIDs]) {
                //setSDate.add(c.ASI_TH_CRM_Start_Date__c);
                setKey.add(string.valueOf(c.ASI_TH_CRM_Start_Date__c)+ '___' + c.ASI_CRM_Customer_Category_Code_2__c);
                mapDate.put(c.id, c.ASI_TH_CRM_Start_Date__c);
            }
            //for (date dteDate : setSDate) {
            for (string str : setKey) {
                date dteDate = date.valueOf(str.split('___', 2)[0]);
                string customercate =  str.split('___', 2)[1];   
                mapWSSP = ASI_CRM_MY_Function.getSKUWSSP(setSKUs, dteDate, idWSSPRT, customercate);
                mapWSSPofDate.put(dteDate, mapWSSP);
                mapIGC = ASI_CRM_MY_Function.getSKUMinSP(setSKUs, dteDate, idIGCRT);
                mapIGCofDate.put(dteDate, mapIGC);
            }
    
            for(ASI_CRM_PromoterPlacement__c i : trigger_new){
                if (i.ASI_CRM_SKU__c != NULL){
                    Decimal decWSSP = 0;
                    Decimal decIGC = 0;
                    
                    map<id, decimal> mapT = new map<id, decimal>();
                    date dteTemp = mapDate.get(i.ASI_CRM_Contract__c);
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
                }
            }
        }
    }
    
    public static void routineBeforeUpsert(list<ASI_CRM_PromoterPlacement__c> trigger_new){
        if(!ASI_CRM_MY_Function.IsBypassTrigger(className)){
            Set<Id> setContract = new Set<Id>();
            List<ASI_TH_CRM_Contract__c> lstContract = new List<ASI_TH_CRM_Contract__c>();
            
            Map<String, map<String, String>> mapOfSetup = ASI_CRM_MY_Function.getContractSetupMapping();
            Map<ID, map<String, Decimal>> mapOfSKU = ASI_CRM_MY_Function.getContractSKUMapping();
    
            for(ASI_CRM_PromoterPlacement__c i : trigger_new){
                if(Global_RecordTypeCache.getRt(i.recordTypeId).developerName.contains('ASI_CRM_MY')){
                    setContract.add(i.ASI_CRM_Contract__c);
                    if(i.ASI_CRM_SetupCode__c != NULL){
                        i.ASI_CRM_JDECOA__c = mapOfSetup.get(i.ASI_CRM_SetupCode__c).get('AC');
                    }
                }
            }
            
            for(ASI_TH_CRM_Contract__c i : lstContract){
                i.ASI_CRM_Last_Revision_Date__c = system.now();
            }
            
            update lstContract;
        }
    }
}