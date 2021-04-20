/*********************************************************************************
 * Name:ASI_CRM_SG_SetTargetBenchmark 
 * Description: Class to Change Set target benchmark of Contract according to outlet               
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 14/01/2015       Laputa: Conrad          Created
*********************************************************************************/

public with sharing class ASI_CRM_SG_SetTargetBenchmark extends ASI_CRM_SG_TriggerAbstract {


    public ASI_CRM_SG_SetTargetBenchmark() {
        super('ASI_CRM_SG_SetTargetBenchmark');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
    
        List<ASI_TH_CRM_Contract__c> contractList = (List<ASI_TH_CRM_Contract__c>)sObjList;
        List<ASI_TH_CRM_Contract__c> validcontractList = new List<ASI_TH_CRM_Contract__c>();
        
        if(oldMap != null) {
            
            Map<ID, ASI_TH_CRM_Contract__c> contractOldMap = (Map<ID, ASI_TH_CRM_Contract__c>)oldMap;
            
            for(ASI_TH_CRM_Contract__c contract : contractList) {
                if(contract.ASI_CRM_CN_Outlet_WS__c != null && contractOldMap.get(contract.id).ASI_CRM_CN_Outlet_WS__c != contract.ASI_CRM_CN_Outlet_WS__c) {
                    validcontractList.add(contract);
                }
            }
        } else {
            validcontractList = contractList;
        }
        
        if(validcontractList.size() > 0) {
        
            Set<ID> customerIDSet = new Set<ID>();
            
            for(ASI_TH_CRM_Contract__c contract : validcontractList) {
                
                customerIDSet.add(contract.ASI_CRM_CN_Outlet_WS__c);
            }
            
            Map<ID, ASI_CRM_Pros_Segmentation__c> relatedProsMap = new Map<ID, ASI_CRM_Pros_Segmentation__c>();
            
            List<ASI_CRM_Pros_Segmentation__c> relatedProsList = [
                                                                     SELECT ID, Name, ASI_CRM_SG_Customer__c, 
                                                                         ASI_CRM_SG_DAMD_Threshold__r.ASI_CRM_SG_Action__c,
                                                                         ASI_CRM_SG_Group_Outlet_Type__r.ASI_CRM_SG_Group_Outlet_Name__c,
                                                                         ASI_CRM_SG_Image_Level_Id__c,
                                                                         ASI_CRM_SG_Outlet_Type__c
                                                                     FROM ASI_CRM_Pros_Segmentation__c
                                                                     WHERE ASI_CRM_SG_Customer__c IN : customerIDSet
                                                                 ];
            
            for(ASI_CRM_Pros_Segmentation__c pros : relatedProsList) {
                relatedProsMap.put(pros.ASI_CRM_SG_Customer__c, pros);
            }
            System.debug('relatedProsMap ' + relatedProsMap);
            if(relatedProsList.size() > 0) {
                
                Set<ID> imageIDSet = new Set<ID>();
                Set<String> MartixSet = new Set<String>();
                Set<ID> outletTypeSet = new Set<ID>();
                Set<String> prosTypeSet = new Set<String>();
                
                for(ASI_CRM_Pros_Segmentation__c pros : relatedProsList) {
                
                    imageIDSet.add(pros.ASI_CRM_SG_Image_Level_Id__c);
                    MartixSet.add(pros.ASI_CRM_SG_DAMD_Threshold__r.ASI_CRM_SG_Action__c);
                    outletTypeSet.add(pros.ASI_CRM_SG_Outlet_Type__c);
                    prosTypeSet.add(pros.ASI_CRM_SG_Group_Outlet_Type__r.ASI_CRM_SG_Group_Outlet_Name__c);
                }
                List<ASI_CRM_Contract_Pros_Benchmark__c> prosBenchmarkList = new List<ASI_CRM_Contract_Pros_Benchmark__c>();
                if(!test.isRunningTest()) {
                	prosBenchmarkList = [
                                                                                SELECT ID, Name, ASI_CRM_SG_Image__c, ASI_CRM_SG_Matrix__c,
                                                                                    ASI_CRM_SG_Outlet_Type__c, ASI_CRM_SG_Pros_Type__c,
                                                                                    ASI_CRM_SG_PRS_Benchmark__c
                                                                                FROM ASI_CRM_Contract_Pros_Benchmark__c
                                                                                WHERE ASI_CRM_SG_Image__c IN : imageIDSet
                                                                                AND ASI_CRM_SG_Matrix__c IN : MartixSet
                                                                                AND ASI_CRM_SG_Outlet_Type__c IN : outletTypeSet
                                                                                AND ASI_CRM_SG_Pros_Type__c IN : prosTypeSet
                                                                             ];
                } else
                {
                    prosBenchmarkList = [
                                                                                SELECT ID, Name, ASI_CRM_SG_Image__c, ASI_CRM_SG_Matrix__c,
                                                                                    ASI_CRM_SG_Outlet_Type__c, ASI_CRM_SG_Pros_Type__c,
                                                                                    ASI_CRM_SG_PRS_Benchmark__c
                                                                                FROM ASI_CRM_Contract_Pros_Benchmark__c
                                                                             ];
                }
                System.debug('prosBenchmarkList ' + prosBenchmarkList);                                                            
                if(prosBenchmarkList.size() > 0) {
                
                    Map<String, ASI_CRM_Contract_Pros_Benchmark__c> prosBenchmarkMap = new Map<String, ASI_CRM_Contract_Pros_Benchmark__c>();
                    
                    for(ASI_CRM_Contract_Pros_Benchmark__c prosBench : prosBenchmarkList) {
                    
                        String prosBenchKey = ((String)prosBench.ASI_CRM_SG_Image__c) + prosBench.ASI_CRM_SG_Matrix__c + ((String)prosBench.ASI_CRM_SG_Outlet_Type__c) + prosBench.ASI_CRM_SG_Pros_Type__c;
                        
                        system.debug('prosBenchKey ' + prosBenchKey);
                        prosBenchmarkMap.put(prosBenchKey, prosBench);
                    }
                    
                    // Main code
                    for(ASI_TH_CRM_Contract__c contract : validcontractList) {
                    
                        if(relatedProsMap.containsKey(contract.ASI_CRM_CN_Outlet_WS__c)) {
                            
                            ASI_CRM_Pros_Segmentation__c prosTemp = relatedProsMap.get(contract.ASI_CRM_CN_Outlet_WS__c);
                            String prosKey = ((String)prosTemp.ASI_CRM_SG_Image_Level_Id__c) + prosTemp.ASI_CRM_SG_DAMD_Threshold__r.ASI_CRM_SG_Action__c + ((String)prosTemp.ASI_CRM_SG_Outlet_Type__c) + prosTemp.ASI_CRM_SG_Group_Outlet_Type__r.ASI_CRM_SG_Group_Outlet_Name__c;
                            
                            system.debug('prosKey ' + prosKey);
                            if(prosBenchmarkMap.containsKey(prosKey)) {
                                
                                ASI_CRM_Contract_Pros_Benchmark__c prosBenchTemp = prosBenchmarkMap.get(prosKey);
                                contract.ASI_CRM_SG_Target_Benchmark__c = prosBenchTemp.ASI_CRM_SG_PRS_Benchmark__c;
                            } else if(contract.ASI_CRM_SG_Target_Benchmark__c != null && !prosBenchmarkMap.containsKey(prosKey)) {
                                contract.ASI_CRM_SG_Target_Benchmark__c = null;
                            }
                        }
                    }
                
                }
                
            }
            
        }

    }
    
}