/*********************************************************************************
 * Name:        ASI_CRM_ContractOtherIncentive_TriggerClass--> ASI_CRM_MY_ContractOther_TriggerCls
 * Description: N/A
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2014-01-04       Introv: Daniel WONG     Created
*********************************************************************************/

public without sharing class ASI_CRM_MY_ContractOther_TriggerCls{
    public static String className = 'ASI_CRM_MY_ContractTrigger';
    
    public static void routineBeforeInsert(list<ASI_CRM_ContractOtherIncentive__c> trigger_new){
        if(!ASI_CRM_MY_Function.IsBypassTrigger(className)){
            id idWSSPRT = Global_RecordTypeCache.getRtId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_MY_WS_SP');
            id idRT = Global_RecordTypeCache.getRtId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_MY_MinSP');
            id idIGCRT = Global_RecordTypeCache.getRtId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_MY_IGC');
            
            set<id> setSKUs = new set<id>();
            //set<date> setSDate = new set<date>();
            set<string> setKey = new set<string>();
            set<id> setContractIDs = new set<id>();
            map<id, decimal> mapMinSP = new map<id, decimal>();
            map<date, map<id, decimal>> mapMinSPofDate = new map<date, map<id, decimal>>();
            map<id, decimal> mapWSSP = new map<id, decimal>();
            map<date, map<id, decimal>> mapWSSPofDate = new map<date, map<id, decimal>>();
            map<id, decimal> mapIGC = new map<id, decimal>();
            map<date, map<id, decimal>> mapIGCofDate = new map<date, map<id, decimal>>();
            map<id, date> mapDate = new map<id, date>();
            
            //Added by 2018-02-28 Linus@introv
            map<id, String> mapBranch = new map<id, String>();
            
            for(ASI_CRM_ContractOtherIncentive__c i : trigger_new){
                setSKUs.add(i.ASI_CRM_SKU__c);
                setContractIDs.add(i.ASI_CRM_Contract__c);
            }
            for (ASI_TH_CRM_Contract__c c : [SELECT id, ASI_TH_CRM_Start_Date__c, ASI_CRM_Customer_Category_Code_2__c, ASI_CRM_Branch__c  FROM ASI_TH_CRM_Contract__c WHERE id IN :setContractIDs]) {
                setKey.add(string.valueOf(c.ASI_TH_CRM_Start_Date__c)+ '___' + c.ASI_CRM_Customer_Category_Code_2__c);
                //setSDate.add(c.ASI_TH_CRM_Start_Date__c);
                mapDate.put(c.id, c.ASI_TH_CRM_Start_Date__c);
                
                mapBranch.put(c.id, c.ASI_CRM_Branch__c);
            }
            
            //for (date dteDate : setSDate) {
            for (string str : setKey) {
                date dteDate = date.valueOf(str.split('___', 2)[0]);
                string customercate =  str.split('___', 2)[1];   
                
                mapMinSP = ASI_CRM_MY_Function.getSKUMinSP(setSKUs, dteDate, idRT);
                mapMinSPofDate.put(dteDate, mapMinSP);
                
                mapWSSP = ASI_CRM_MY_Function.getSKUWSSP(setSKUs, dteDate, idWSSPRT, customercate);
                mapWSSPofDate.put(dteDate, mapWSSP);
                
                mapIGC = ASI_CRM_MY_Function.getSKUMinSP(setSKUs, dteDate, idIGCRT);
                mapIGCofDate.put(dteDate, mapIGC);
            }
    
            for(ASI_CRM_ContractOtherIncentive__c i : trigger_new){
                if (i.ASI_CRM_SKU__c != NULL){
                    Decimal decMinSP = 0;
                    Decimal decIGC = 0;
                       
                    map<id, decimal> mapT = new map<id, decimal>();
                    date dteTemp = mapDate.get(i.ASI_CRM_Contract__c);
                    mapT = mapMinSPofDate.get(dteTemp);
                    
                    if (mapT != null) {
                        if (mapT.get(i.ASI_CRM_SKU__c) != null) {
                            decMinSP = mapT.get(i.ASI_CRM_SKU__c);
                        }
                    }
                    i.ASI_CRM_MinSPBtl__c = decMinSP;
                    
                    Decimal decWSSP = 0;  
                    mapT = new map<id, decimal>();
                    
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
                
                i.ASI_CRM_Branch__c = mapBranch.get(i.ASI_CRM_Contract__c);
            }
            
            System.debug('Total Number of SOQL Queries allowed in this apex code context((Other Incentive)Before Insert): ' +  Limits.getQueries());
        }
    }
    
    public static void routineBeforeUpsert(list<ASI_CRM_ContractOtherIncentive__c> trigger_new){
        if(!ASI_CRM_MY_Function.IsBypassTrigger(className)){
            Set<Id> setContract = new Set<Id>();
            List<ASI_TH_CRM_Contract__c> lstContract = new List<ASI_TH_CRM_Contract__c>();
            
            Map<String, map<String, String>> mapOfSetup = ASI_CRM_MY_Function.getContractSetupMapping();
            //Map<ID, map<String, Decimal>> mapOfSKU = ASI_CRM_MY_Function.getContractSKUMapping();
    
            //Added by 2018-02-28 Linus@introv
            map<id, String> mapBranch = new map<id, String>();
            
            for(ASI_CRM_ContractOtherIncentive__c i : trigger_new){
                if(Global_RecordTypeCache.getRt(i.recordTypeId).developerName.contains('ASI_CRM_MY')){
                    setContract.add(i.ASI_CRM_Contract__c);
                    
                    if(i.ASI_CRM_SetupCode__c == NULL || i.ASI_CRM_SetupCode__c == '' || i.ASI_CRM_SetupCode__c == ' '){
                        i.addError('Update Other Incentives Fail: You must enter a value for Setup Code.');    
                    }else{
                        i.ASI_CRM_JDECOA__c = mapOfSetup.get(i.ASI_CRM_SetupCode__c).get('AC');
                    }
                    
                    if(i.ASI_CRM_Description__c == NULL || i.ASI_CRM_Description__c == '' || i.ASI_CRM_Description__c == ' '){
                        i.addError('Update Other Incentives Fail: You must enter a value for Description.');
                    }else{
                        i.ASI_CRM_Description__c = i.ASI_CRM_Description__c.toUpperCase();
                    }
                    
                    if(i.ASI_CRM_Type__c == NULL || i.ASI_CRM_Type__c == '' || i.ASI_CRM_Type__c == ' '){
                        i.addError('Update Other Incentives Fail: You must enter a value for Type.');    
                    }
                    
                    boolean errorChk = FALSE;
                    
                    if((i.ASI_CRM_FOC__c == NULL || i.ASI_CRM_FOC__c == 0) && (i.ASI_CRM_CashInc__c == NULL || i.ASI_CRM_CashInc__c == 0) ){
                        i.addError('Update Other Incentives Fail: You must enter a value for FOC / Cash.');
                        errorChk = TRUE;
                    }else if(i.ASI_CRM_FOC__c != NULL && i.ASI_CRM_CashInc__c != NULL){
                        if(integer.valueof(i.ASI_CRM_FOC__c * 1) != 0 && integer.valueof(i.ASI_CRM_CashInc__c * 1) != 0){
                            i.addError('Update Other Incentives Fail: Either FOC or Cash canbe filled.');
                            errorChk = TRUE;
                        }
                        if(integer.valueof(i.ASI_CRM_FOC__c * 1) == 0 && integer.valueof(i.ASI_CRM_CashInc__c * 1) == 0){
                            i.addError('Update Other Incentives Fail: You must enter a value for FOC / Cash.');
                            errorChk = TRUE;
                        }
                    }
                    
                    if(errorChk == FALSE){
                        decimal temp = 0;
                        temp = i.ASI_CRM_FOC__c != NULL ? i.ASI_CRM_FOC__c * i.ASI_CRM_MinSPBtl__c : 0;
                        temp = i.ASI_CRM_CashInc__c != NULL ? temp + i.ASI_CRM_CashInc__c : temp;
                        i.ASI_CRM_Total__c = temp.setScale(2);
                    }
                }
            }
            
            for(ASI_TH_CRM_Contract__c i : [Select id, ASI_CRM_Branch__c from ASI_TH_CRM_Contract__c where id IN: setContract]){
                i.ASI_CRM_Last_Revision_Date__c = system.now();
                
                mapBranch.put(i.id, i.ASI_CRM_Branch__c);
            }
            
            for(ASI_CRM_ContractOtherIncentive__c i : trigger_new){
                i.ASI_CRM_Branch__c = mapBranch.get(i.ASI_CRM_Contract__c);
            }
            
            System.debug('Total Number of SOQL Queries allowed in this apex code context((Other Incentive)Before Update): ' +  Limits.getQueries());
            
            update lstContract;
        }
    }
}