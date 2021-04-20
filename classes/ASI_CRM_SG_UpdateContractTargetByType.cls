/*********************************************************************************
 * Name: ASI_CRM_SG_UpdateContractTargetByType
 * Description: 
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2017-11-XX		Jeffrey Cheung			Created
 * 2017-12-05       Vincent Lam             Also remove all payment schedule if downgrade from Key Account          
*/
public with sharing class ASI_CRM_SG_UpdateContractTargetByType extends ASI_CRM_SG_TriggerAbstract {
    
    public ASI_CRM_SG_UpdateContractTargetByType() {
        super('ASI_CRM_SG_UpdateContractTargetByType');
    }

    public override void executeTriggerAction (TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        
        // Put all contract id into list
        Set<Id> contractIdList = new Set<Id>();
        Set<Id> contractIdList_removePaymentSchedule = new Set<Id>();
        for(ASI_TH_CRM_Contract__c contract : (List<ASI_TH_CRM_Contract__c>)sObjList) {
            if(contract.ASI_CRM_Contract_Exist_Before_RTM__c) {
                continue;
            }
			
            String newContractType = contract.ASI_CRM_Type__c;
            ASI_TH_CRM_Contract__c oldContract = (ASI_TH_CRM_Contract__c)oldMap.get(contract.Id);
            String oldContractType = oldContract.ASI_CRM_Type__c;
            
			if(newContractType != oldContractType && newContractType == 'Partner') {
				contractIdList.add(contract.id);
			}
			
        }
		
		if (contractIdList.size()>0){
		
			// find all contract target 
			List<ASI_CRM_ContractTarget__c> contractTargetList = getContractTargetList(contractIdList);
			
			List<ASI_CRM_ContractTarget__c> contractTargetToUpdate = new List<ASI_CRM_ContractTarget__c>();

			// for each contract, update contract target if needed
			for(ASI_TH_CRM_Contract__c contract : (List<ASI_TH_CRM_Contract__c>)sObjList) {
				if(!contractIdList.contains(contract.id)) {
					continue;
				}
				
				/*
				if(newContractType != oldContractType && newContractType == 'Open'){
					List<ASI_CRM_ContractTarget__c> filtered = filterContractTargetListByContractId(contractTargetList, contract.Id);
					for(ASI_CRM_ContractTarget__c ct : filtered){
						ct.ASI_CRM_Entitle_Back_Rebates__c = false;
						ct.ASI_CRM_Bottle_Incentive__c = null;
						ct.ASI_CRM_SG_Cash__c = null;
						ct.ASI_CRM_SG_Ad_hoc_Promotions__c = null;
						ct.ASI_CRM_SG_Anniversary_Free_Bottles__c = null;
						contractTargetToUpdate.add(ct);
						contractIdList_removePaymentSchedule.add(contract.Id);
					}
				}
				*/
				//if(newContractType != oldContractType && newContractType == 'Partner'){
					List<ASI_CRM_ContractTarget__c> filtered = filterContractTargetListByContractId(contractTargetList, contract.Id);
					for(ASI_CRM_ContractTarget__c ct : filtered){
						ct.ASI_CRM_SG_Cash__c = null;
						contractTargetToUpdate.add(ct);
						contractIdList_removePaymentSchedule.add(contract.Id);
					}
				//}
			}
				
			if(contractTargetToUpdate.size() > 0){
				update contractTargetList;
			} 
			if(contractIdList_removePaymentSchedule.size() > 0){
				removeCashSponsorshipSchedule(contractIdList_removePaymentSchedule);
			}
		}
    }

    // Without calling SOQL
    private List<ASI_CRM_ContractTarget__c> filterContractTargetListByContractId(List<ASI_CRM_ContractTarget__c> contractTargetList, Id contractId) {
        List<ASI_CRM_ContractTarget__c> filtered = new List<ASI_CRM_ContractTarget__c>();
        for(ASI_CRM_ContractTarget__c ct : contractTargetList) {
            if(ct.ASI_CRM_Contract__c == contractId){
                filtered.add(ct);
            }
        }
        return filtered;
    }

    private List<ASI_CRM_ContractTarget__c> getContractTargetList(Set<Id> contractIdList) {

        List<ASI_CRM_ContractTarget__c> contractTargetList = [SELECT Id,
                                                                     ASI_CRM_Contract__c, 
                                                                     ASI_CRM_SKU__c,
                                                                     ASI_CRM_SKU__r.ASI_CRM_SG_Selling_Price_Per_Btl_PRS_WS__c,
                                                                     ASI_CRM_SKU__r.ASI_CRM_SG_Selling_Price_Per_Btl_WS_On__c,
                                                                     ASI_CRM_SKU__r.ASI_CRM_SG_IGC_Cost_Per_case__c,
                                                                     ASI_CRM_SKU__r.ASI_CRM_SG_IGC_Cost_Per_9Lc__c,
                                                                     ASI_CRM_SG_Selling_Price_Btl_PRS_WS__c,
                                                                     ASI_CRM_SG_Selling_Price_Btl_WS_On_Trade__c,
                                                                     ASI_CRM_SG_IGC_Cost_Per_case__c,
                                                                     ASI_CRM_Duty_Per_Bottle__c,
                                                                     ASI_CRM_FOB_Per_Bottle__c,
                                                                     ASI_CRM_Handling_Cost_Per_Bottle__c,
                                                                     ASI_CRM_SG_IGC_Cost_Per_9Lc__c
                                                              FROM ASI_CRM_ContractTarget__c
                                                              WHERE ASI_CRM_Contract__c in :contractIdList
                                                                    AND RecordTypeId = :Global_RecordTypeCache.getRTId('ASI_CRM_ContractTarget__cASI_CRM_SG_Contract_Target')];

        return contractTargetList;
    }
	
	private void removeCashSponsorshipSchedule(Set<Id> contractIdList){
		delete [
			select id 
			from ASI_CRM_Payment_Schedule__c 
			where ASI_CRM_Contract__c in :contractIdList
			AND RecordTypeId = :Global_RecordTypeCache.getRTId('ASI_CRM_Payment_Schedule__cASI_CRM_SG_Payment_Schedule')
		];
	}
}