/*********************************************************************************
 * Name:ASI_CRM_SG_ValidateOutletDate 
 * Description: Validate Start and End date and avoid overlap with existing Contracts with the same outlet              
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 06/03/2015       Laputa: Conrad          Created
*********************************************************************************/

public with sharing class ASI_CRM_SG_ValidateOutletDate extends ASI_CRM_SG_TriggerAbstract {


    public ASI_CRM_SG_ValidateOutletDate() {
        super('ASI_CRM_SG_ValidateOutletDate');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
    
        List<ASI_TH_CRM_Contract__c> contractList = (List<ASI_TH_CRM_Contract__c>)sObjList;
        List<ASI_TH_CRM_Contract__c> validcontractList = new List<ASI_TH_CRM_Contract__c>();
        Set<id> contractStatusValidateSet = new Set<id>();
        
        if(oldMap != null) {
            
            Map<ID, ASI_TH_CRM_Contract__c> contractOldMap = (Map<ID, ASI_TH_CRM_Contract__c>)oldMap;
            
            for(ASI_TH_CRM_Contract__c contract : contractList) {
                if((contract.ASI_CRM_CN_Outlet_WS__c != null && contractOldMap.get(contract.id).ASI_CRM_CN_Outlet_WS__c != contract.ASI_CRM_CN_Outlet_WS__c)
                      || (contract.ASI_TH_CRM_Start_Date__c != null && contractOldMap.get(contract.id).ASI_TH_CRM_Start_Date__c != contract.ASI_TH_CRM_Start_Date__c)
                      || (contract.ASI_TH_CRM_End_Date__c != null && contractOldMap.get(contract.id).ASI_TH_CRM_End_Date__c != contract.ASI_TH_CRM_End_Date__c)
                  ) {
                    validcontractList.add(contract);
                }
                
                if (contract.ASI_TH_CRM_Contract_Status__c == 'Draft' && contractOldMap.get(contract.id).ASI_TH_CRM_Contract_Status__c == 'Contract Approved'){
                    contractStatusValidateSet.add(contract.id);
                }
            }
            
        } else {
            validcontractList = contractList;
        }
        
        // Core Logic
        if(validcontractList.size() > 0) {
            
            Set<ID> outletIdsSet = new Set<ID>();
            Set<ID> contractExIdsSet = new Set<ID>();
            
            for(ASI_TH_CRM_Contract__c contract : validcontractList) {
                if(contract.ASI_CRM_CN_Outlet_WS__c != null) {
                    outletIdsSet.add(contract.ASI_CRM_CN_Outlet_WS__c);
                }
                
                if(contract.id != null) {
                    contractExIdsSet.add(contract.id);
                }
            }
            
            if(outletIdsSet.size() > 0) {
                List<ASI_TH_CRM_Contract__c> contractListOthers = [SELECT ID, Name, ASI_TH_CRM_Start_Date__c,
                                                                ASI_TH_CRM_End_Date__c, ASI_CRM_CN_Outlet_WS__c
                                                                FROM ASI_TH_CRM_Contract__c
                                                                WHERE ASI_CRM_CN_Outlet_WS__c IN : outletIdsSet
                                                                AND ID NOT IN : contractExIdsSet
                                                                ORDER BY ASI_CRM_CN_Outlet_WS__c];
                                                                
                Map<ID, List<ASI_TH_CRM_Contract__c>> outletContractMap = new Map<ID, List<ASI_TH_CRM_Contract__c>> ();
                
                ID outletId = null;
                List<ASI_TH_CRM_Contract__c> contractListTemp = new List<ASI_TH_CRM_Contract__c>();
                
                for(ASI_TH_CRM_Contract__c contract : contractListOthers) {
                    
                    if(outletId == null) {
                        outletId = contract.ASI_CRM_CN_Outlet_WS__c;
                        contractListTemp.add(contract);
                    } else if(outletId != contract.ASI_CRM_CN_Outlet_WS__c) {
                        outletContractMap.put(outletId, contractListTemp);
                        outletId = contract.ASI_CRM_CN_Outlet_WS__c;
                        contractListTemp = new List<ASI_TH_CRM_Contract__c>();
                    } else if (outletId == contract.ASI_CRM_CN_Outlet_WS__c) {
                        contractListTemp.add(contract);
                    }
                }
                
                // For base case (last item) scenario:
                if(outletID != null) {
                    if(!outletContractMap.containsKey(outletID) && contractListTemp.size() > 0) {
                        outletContractMap.put(outletId, contractListTemp);
                    }
                }
                
                //Wilken 20150804 Remove contract period validation as user has multiple contracts with overlapping period
                /*for(ASI_TH_CRM_Contract__c contract : validcontractList) {
                    List<ASI_TH_CRM_Contract__c> contractOtherList = outletContractMap.get(contract.ASI_CRM_CN_Outlet_WS__c) != null ? outletContractMap.get(contract.ASI_CRM_CN_Outlet_WS__c) : new List<ASI_TH_CRM_Contract__c>();
                    for(ASI_TH_CRM_Contract__c contractOther : contractOtherList) {
                        if((contract.ASI_TH_CRM_Start_Date__c >= contractOther.ASI_TH_CRM_Start_Date__c && contract.ASI_TH_CRM_Start_Date__c <= contractOther.ASI_TH_CRM_End_Date__c)
                          ||(contract.ASI_TH_CRM_End_Date__c >= contractOther.ASI_TH_CRM_Start_Date__c && contract.ASI_TH_CRM_End_Date__c <= contractOther.ASI_TH_CRM_End_Date__c)
                          ||(contract.ASI_TH_CRM_Start_Date__c <= contractOther.ASI_TH_CRM_Start_Date__c && contract.ASI_TH_CRM_End_Date__c >= contractOther.ASI_TH_CRM_End_Date__c) 
                          ) {
                            contract.addError('Contract with the same outlet cannot have overlapping Start and End Date');
                            break;
                        }
                    }
                }*/
                
            }
            
        }

        // Vincent 20160323: Remove FOC/Payment request checking due to contract/proposal snapshot function
        /*
        if (contractStatusValidateSet.size() > 0){
            Map<ID, ASI_FOC_Free_Goods_Request__c> focMap = new Map<ID, ASI_FOC_Free_Goods_Request__c>(); 
            for (ASI_FOC_Free_Goods_Request__c foc : [Select Id, ASI_CRM_Contract__c From ASI_FOC_Free_Goods_Request__c where ASI_CRM_Contract__c = :contractStatusValidateSet])
                    focMap.put(foc.ASI_CRM_Contract__c, foc);
            
            Map<ID, ASI_TH_CRM_PaymentRequest__c> payMap = new Map<ID, ASI_TH_CRM_PaymentRequest__c>(); 
            for (ASI_TH_CRM_PaymentRequest__c pay : [Select Id, ASI_TH_CRM_Contract__c From ASI_TH_CRM_PaymentRequest__c where ASI_TH_CRM_Contract__c = :contractStatusValidateSet])
                    payMap.put(pay.ASI_TH_CRM_Contract__c, pay);            
            
            for(ASI_TH_CRM_Contract__c contract : contractList) {
                if (focMap.containsKey(contract.id) || payMap.containsKey(contract.id))
                    contract.addError('Contracts with Free Goods or Payment Request cannot be set from Approved to Draft');
            }
        }
        */
    }
}