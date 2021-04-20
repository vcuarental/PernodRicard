/*********************************************************************************
 * Name:        ASI_CRM_ContractSalesStaffIncentive_TriggerClass--> ASI_CRM_MY_ContractSalesStaff_TriggerCls
 * Description: N/A
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2014-01-04       Introv: Daniel WONG     Created
*********************************************************************************/

public without sharing class ASI_CRM_MY_ContractSalesStaff_TriggerCls{
    public static String className = 'ASI_CRM_MY_ContractTrigger';
    
    public static void routineBeforeInsert(list<ASI_CRM_ContractSalesStaffIncentive__c> trigger_new){
        if(!ASI_CRM_MY_Function.IsBypassTrigger(className)){
            id idRT = Global_RecordTypeCache.getRtId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_MY_MinSP');
            set<id> setSKUs = new set<id>();
            set<date> setSDate = new set<date>();
            set<id> setContractIDs = new set<id>();
            map<id, decimal> mapMinSP = new map<id, decimal>();
            map<date, map<id, decimal>> mapMinSPofDate = new map<date, map<id, decimal>>();
            map<id, date> mapDate = new map<id, date>();
            
            //Added by 2018-02-28 Linus@introv
            map<id, String> mapBranch = new map<id, String>();
            
            for(ASI_CRM_ContractSalesStaffIncentive__c i : trigger_new){
                setSKUs.add(i.ASI_CRM_SKU__c);
                setContractIDs.add(i.ASI_CRM_Contract__c);
            }
            for (ASI_TH_CRM_Contract__c c : [SELECT id, ASI_TH_CRM_Start_Date__c, ASI_CRM_Branch__c FROM ASI_TH_CRM_Contract__c WHERE id IN :setContractIDs]) {
                setSDate.add(c.ASI_TH_CRM_Start_Date__c);
                mapDate.put(c.id, c.ASI_TH_CRM_Start_Date__c);
                
                mapBranch.put(c.id, c.ASI_CRM_Branch__c);
            }
            
            for (date dteDate : setSDate) {
                mapMinSP = ASI_CRM_MY_Function.getSKUMinSP(setSKUs, dteDate, idRT);
                mapMinSPofDate.put(dteDate, mapMinSP);
            }
    
            for(ASI_CRM_ContractSalesStaffIncentive__c i : trigger_new){
                if (i.ASI_CRM_SKU__c != NULL){
                    Decimal decMinSP = 0;     
                    map<id, decimal> mapT = new map<id, decimal>();
                    date dteTemp = mapDate.get(i.ASI_CRM_Contract__c);
                    mapT = mapMinSPofDate.get(dteTemp);
                    
                    if (mapT != null) {
                        if (mapT.get(i.ASI_CRM_SKU__c) != null) {
                            decMinSP = mapT.get(i.ASI_CRM_SKU__c);
                        }
                    }
                    i.ASI_CRM_MinSPBtl__c = decMinSP;
                }
                
                i.ASI_CRM_Branch__c = mapBranch.get(i.ASI_CRM_Contract__c);
            }
            
            System.debug('Total Number of SOQL Queries allowed in this apex code context((Sales&Staff Incentive)Before Insert): ' +  Limits.getQueries());
        }
    }
    
    public static void routineBeforeUpsert(list<ASI_CRM_ContractSalesStaffIncentive__c> trigger_new){
        if(!ASI_CRM_MY_Function.IsBypassTrigger(className)){
            Map<String, map<String, String>> mapOfSetup = ASI_CRM_MY_Function.getContractSetupMapping();
            Map<ID, map<String, Decimal>> mapOfSKU = ASI_CRM_MY_Function.getContractSKUMapping();
            
            set<id> setSKUs = new set<id>();
            set<id> setContractIDs = new set<id>();
            
            List<ASI_TH_CRM_Contract__c> lstContract = new List<ASI_TH_CRM_Contract__c>();
            
            map<id, decimal> mapSKUCase = new map<id, decimal>();
            map<id, decimal> mapSKUPacking = new map<id, decimal>();
            
            //Added by 2018-02-28 Linus@introv
            map<id, String> mapBranch = new map<id, String>();
            
            for(ASI_CRM_ContractSalesStaffIncentive__c i : trigger_new){
                setSKUs.add(i.ASI_CRM_SKU__c);
                setContractIDs.add(i.ASI_CRM_Contract__c);
            }system.debug('-----------------------------------ASI_CRM_MY_ContractSalesStaff_TriggerCls.routineBeforeUpsert: setContractIDs --> ' + setContractIDs);
            for (ASI_CRM_ContractTarget__c t : [SELECT id, ASI_CRM_SKU__c, ASI_CRM_TargetCase__c FROM ASI_CRM_ContractTarget__c WHERE ASI_CRM_Contract__c IN :setContractIDs]) {
                mapSKUCase.put(t.ASI_CRM_SKU__c, t.ASI_CRM_TargetCase__c);
            }system.debug('-----------------------------------ASI_CRM_MY_ContractSalesStaff_TriggerCls.routineBeforeUpsert: mapSKUCase --> ' + mapSKUCase);
            for (ASI_MFM_SKU_Code__c s : [SELECT id, ASI_HK_CRM_Packaging_Size__c FROM ASI_MFM_SKU_Code__c WHERE id IN :setSKUs]) {
                mapSKUPacking.put(s.id, s.ASI_HK_CRM_Packaging_Size__c);
            }
            
            for(ASI_CRM_ContractSalesStaffIncentive__c i : trigger_new){
                if(Global_RecordTypeCache.getRt(i.recordTypeId).developerName.contains('ASI_CRM_MY')){
                    
                    Boolean blnRowEmpty = false;
                    
                    if ((i.ASI_CRM_SetupCode__c == NULL || i.ASI_CRM_SetupCode__c == '')
                        && (i.ASI_CRM_FOCPRM__c == NULL || i.ASI_CRM_FOCPRM__c == 0)
                        && (i.ASI_CRM_FOCWS__c == NULL || i.ASI_CRM_FOCWS__c == 0)
                        && (i.ASI_CRM_CashInc__c == NULL || i.ASI_CRM_CashInc__c == 0)
                        && (i.ASI_CRM_AchievedBtl__c == NULL || i.ASI_CRM_AchievedBtl__c == 0)
                       ) {
                           blnRowEmpty = true;
                       }
                    
                    if (blnRowEmpty == FALSE) {                    
                        if(i.ASI_CRM_SetupCode__c == NULL || i.ASI_CRM_SetupCode__c == ' ')
                            i.addError('Update Sales & Staff Incentives Fail: You must enter a value for Setup Code.');
                        else{
                            i.ASI_CRM_JDECOA__c = mapOfSetup.get(i.ASI_CRM_SetupCode__c) == null ? null : mapOfSetup.get(i.ASI_CRM_SetupCode__c).get('AC');
                        }
                        
                        Decimal temp = 0;
                        if(mapSKUCase.get(i.ASI_CRM_SKU__c) != NULL) {
                            temp = mapSKUCase.get(i.ASI_CRM_SKU__c);
                        }
                        //if(mapSKUPacking.get(i.ASI_CRM_SKU__c) != NULL && mapSKUPacking.get(i.ASI_CRM_SKU__c) != 0)
                        //    temp = temp / mapSKUPacking.get(i.ASI_CRM_SKU__c);
                        if(i.ASI_CRM_MinSPBtl__c != NULL)
                            temp = temp * (i.ASI_CRM_MinSPBtl__c * ((i.ASI_CRM_FOCPRM__c!= NULL? i.ASI_CRM_FOCPRM__c : 0) + (i.ASI_CRM_FOCWS__c!= NULL? i.ASI_CRM_FOCWS__c : 0)) + (i.ASI_CRM_CashInc__c != NULL? i.ASI_CRM_CashInc__c : 0));
                        else
                            temp = 0;
                        i.ASI_CRM_Total__c = temp.setScale(2);
                    } else {
                        i.ASI_CRM_Total__c = 0;
                    }
                }
            }
            
            lstContract = [SELECT Id, ASI_CRM_Branch__c FROM ASI_TH_CRM_Contract__c WHERE Id IN :setContractIDs];
            for(ASI_TH_CRM_Contract__c i : lstContract){
                i.ASI_CRM_Last_Revision_Date__c = system.now();
                
                mapBranch.put(i.id, i.ASI_CRM_Branch__c);
            }
            
            for(ASI_CRM_ContractSalesStaffIncentive__c i : trigger_new){
                i.ASI_CRM_Branch__c = mapBranch.get(i.ASI_CRM_Contract__c);
            }
            
            System.debug('Total Number of SOQL Queries allowed in this apex code context((Sales&Staff Incentive)Before Update): ' +  Limits.getQueries());
            
            update lstContract;
        }
    }
}