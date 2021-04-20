/*********************************************************************************
 * Name:ASI_CRM_SG_CheckContract
 * Description: Check the contract and proposal is different or not
  * Test Class: ASI_CRM_SG_CheckCOntract_Test, ASI_CRM_SG_UpdateContractTarByType_Test
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2016-06-29       Laputa: Hugo Cheung     Created
 * 2017-12-08		Laputa: Vincent lam		[VL 1.0] P4.1A check before downgrade from Key Account to Partner
 * 2018-01-18		Wilken Lee				[WL 2.0] Bug Fix to lock Start Date if there are transactions. Prevent invalid early termination of End Date
 * 2018-04-06		Wilken Lee				[WL 3.0] Allow extra one month period for validating FOC and Payment Date
*********************************************************************************/
public with sharing class ASI_CRM_SG_CheckContract extends ASI_CRM_SG_TriggerAbstract{

	public ASI_CRM_SG_CheckContract() {
		super('ASI_CRM_SG_CheckContract');
	}

	public override void executeTriggerAction (
		TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {

		List<ASI_TH_CRM_Contract__c> contractList = (List<ASI_TH_CRM_Contract__c>) sObjList;
		Map<Id, ASI_TH_CRM_Contract__c> oldContractMap = (Map<Id, ASI_TH_CRM_Contract__c>) oldMap;

		List<Id> convertedFormProposalIdList = new List<Id>();
		/* [VL 1.0] BEGIN */
		List<Id> list_partnerContractId = new List<Id>();
		/* [VL 1.0] END */
		
		/*[WL 2.0] BEGIN*/
		Set<String> validateStartEndDateContractNo = new Set<String>();
		/*[WL 2.0] END*/
		
		for(ASI_TH_CRM_Contract__c contract : contractList) {

			if(String.isNotBlank(contract.ASI_CRM_Converted_From__c)) {
				convertedFormProposalIdList.add(contract.ASI_CRM_Converted_From__c);
			}
			/* [VL 1.0] BEGIN */
			if(!contract.ASI_CRM_Contract_Exist_Before_RTM__c && 
				contract.ASI_CRM_Type__c != oldContractMap.get(contract.Id).ASI_CRM_Type__c && 
				contract.ASI_CRM_Type__c == 'Partner'
			) {
				list_partnerContractId.add(contract.Id);
			}
			/* [VL 1.0] END */
			
			/*[WL 2.0] BEGIN*/
			system.debug('Latest Start Date: ' + contract.ASI_TH_CRM_Start_Date__c + ' Old Start Date: ' + oldContractMap.get(contract.Id).ASI_TH_CRM_Start_Date__c + ' Latest End Date: ' + contract.ASI_TH_CRM_End_Date__c + ' Old End Date: ' + oldContractMap.get(contract.Id).ASI_TH_CRM_End_Date__c);
			if (contract.ASI_TH_CRM_Start_Date__c != oldContractMap.get(contract.Id).ASI_TH_CRM_Start_Date__c
				|| contract.ASI_TH_CRM_End_Date__c < oldContractMap.get(contract.Id).ASI_TH_CRM_End_Date__c){
				validateStartEndDateContractNo.add(contract.ASI_CRM_Base_Contract_No__c);
			}	
			/*[WL 2.0] END*/
		}		
		
		/*[WL 2.0] BEGIN*/
		system.debug('validateStartEndDateContractNo: ' + validateStartEndDateContractNo.size());
		if (validateStartEndDateContractNo.size() > 0 && !ASI_CRM_MY_Function.IsBypassTrigger('ASI_CRM_SG_CheckContract')){
			List<ASI_TH_CRM_Actual_Offtake__c> offtakeList = [select Id, ASI_TH_CRM_Offtake_G_L_Date__c, ASI_CRM_Contract__r.ASI_CRM_Base_Contract_No__c from ASI_TH_CRM_Actual_Offtake__c 
															where ASI_CRM_Contract__c != null and ASI_CRM_Contract__r.ASI_CRM_Base_Contract_No__c in :validateStartEndDateContractNo 
																and ASI_CRM_Contract__r.recordTypeId = :Global_RecordTypeCache.getRTId('ASI_TH_CRM_Contract__cASI_CRM_SG_Contract_Read_Only')																	
																and recordTypeId = :Global_RecordTypeCache.getRTId('ASI_TH_CRM_Actual_Offtake__cASI_CRM_SG_Actual_offtake')];
			//List<ASI_FOC_Free_Goods_Request__c> focList = [select Id, ASI_CRM_SG_Order_Date__c, ASI_CRM_Contract__r.ASI_CRM_Base_Contract_No__c from ASI_FOC_Free_Goods_Request__c where ASI_CRM_Contract__r.ASI_CRM_Base_Contract_No__c in :validateStartEndDateContractNo];
			//List<ASI_TH_CRM_PaymentRequest__c> paymentList = [select Id, ASI_TH_CRM_GL_Date__c, ASI_TH_CRM_Contract__r.ASI_CRM_Base_Contract_No__c from ASI_TH_CRM_PaymentRequest__c where ASI_TH_CRM_Contract__r.ASI_CRM_Base_Contract_No__c in :validateStartEndDateContractNo];
			
			for(ASI_TH_CRM_Contract__c contract : contractList) {
				if (validateStartEndDateContractNo.contains(contract.ASI_CRM_Base_Contract_No__c)){
					system.debug('offtakeList: ' + offtakeList.size());
					for (ASI_TH_CRM_Actual_Offtake__c offtake:offtakeList){
						if (contract.ASI_CRM_Base_Contract_No__c == offtake.ASI_CRM_Contract__r.ASI_CRM_Base_Contract_No__c && (contract.ASI_TH_CRM_Start_Date__c > offtake.ASI_TH_CRM_Offtake_G_L_Date__c || contract.ASI_TH_CRM_End_Date__c < offtake.ASI_TH_CRM_Offtake_G_L_Date__c))
							contract.addError('Contract Start and End Date must be within Offtake G/L Date period');
					}
					
					/*[WL 3.0 BEGIN]*/
					/*for (ASI_FOC_Free_Goods_Request__c foc:focList){
						
						if (contract.ASI_CRM_Base_Contract_No__c == foc.ASI_CRM_Contract__r.ASI_CRM_Base_Contract_No__c && (contract.ASI_TH_CRM_Start_Date__c > foc.ASI_CRM_SG_Order_Date__c || contract.ASI_TH_CRM_End_Date__c < foc.ASI_CRM_SG_Order_Date__c.addMonths(-1)))
							contract.addError('Contract Start and End Date must be within Free Goods Request Order Date period');
					}
					
					for (ASI_TH_CRM_PaymentRequest__c payment:paymentList){
						if (contract.ASI_CRM_Base_Contract_No__c == payment.ASI_TH_CRM_Contract__r.ASI_CRM_Base_Contract_No__c && (contract.ASI_TH_CRM_Start_Date__c > payment.ASI_TH_CRM_GL_Date__c || contract.ASI_TH_CRM_End_Date__c < payment.ASI_TH_CRM_GL_Date__c.addMonths(-1)))
							contract.addError('Contract Start and End Date must be within Payment Request GL Date period');
					}
					/*[WL 3.0 END]*/
				}
			}
		}
		/*[WL 2.0] END*/
		
		if (convertedFormProposalIdList.size()>0) checkDiffFromProposal(contractList, convertedFormProposalIdList);
		/* [VL 1.0] BEGIN */
		if (list_partnerContractId.size()>0) checkPartnerContract(contractList, list_partnerContractId);
		/* [VL 1.0] END */
	}
	
	private void checkDiffFromProposal(List<ASI_TH_CRM_Contract__c> contractList, List<Id> convertedFormProposalIdList){
		Map<Id, ASI_TH_CRM_Contract__c> convertedFromProposalMap = new Map<Id, ASI_TH_CRM_Contract__c>([SELECT Id,
			                                                                                                   ASI_CRM_CN_Outlet_WS__c,
			                                                                                                   ASI_TH_CRM_Start_Date__c,
			                                                                                                   ASI_TH_CRM_End_Date__c,
			                                                                                                   ASI_CRM_SG_TotalCashGoodsinkindSponsor__c,
			                                                                                                   ASI_CRM_SG_TotalInvestment_Value_for_PRS__c,
			                                                                                                   ASI_CRM_SG_Net_Sales__c,
			                                                                                                   ASI_CRM_SG_Return_on_Investment__c
			                                                                                        		FROM ASI_TH_CRM_Contract__c
			                                                                                        			WHERE Id in :convertedFormProposalIdList
			                                                                                         ]);


		List<ASI_TH_CRM_Contract__c> updateContractList = new List<ASI_TH_CRM_Contract__c>();

		for(ASI_TH_CRM_Contract__c contract : contractList) {

			if(String.isNotBlank(contract.ASI_CRM_Converted_From__c) && 
			   convertedFromProposalMap.containsKey(contract.ASI_CRM_Converted_From__c)) {

				ASI_TH_CRM_Contract__c tempProposal = convertedFromProposalMap.get(contract.ASI_CRM_Converted_From__c);

				if(contract.ASI_CRM_CN_Outlet_WS__c                     != tempProposal.ASI_CRM_CN_Outlet_WS__c ||
				   contract.ASI_TH_CRM_Start_Date__c                    != tempProposal.ASI_TH_CRM_Start_Date__c || 
				   contract.ASI_TH_CRM_End_Date__c                      != tempProposal.ASI_TH_CRM_End_Date__c ||
				   contract.ASI_CRM_SG_TotalCashGoodsinkindSponsor__c   != tempProposal.ASI_CRM_SG_TotalCashGoodsinkindSponsor__c ||
				   contract.ASI_CRM_SG_TotalInvestment_Value_for_PRS__c != tempProposal.ASI_CRM_SG_TotalInvestment_Value_for_PRS__c ||
				   contract.ASI_CRM_SG_Net_Sales__c                     != tempProposal.ASI_CRM_SG_Net_Sales__c ||
				   contract.ASI_CRM_SG_Return_on_Investment__c          != tempProposal.ASI_CRM_SG_Return_on_Investment__c) {
	
					contract.ASI_CRM_Differed_From_Proposal__c = true;

				} else {

					contract.ASI_CRM_Differed_From_Proposal__c = false;

				}

			} else if(String.isBlank(contract.ASI_CRM_Converted_From__c)){

				contract.ASI_CRM_Differed_From_Proposal__c = true;

			}

		}
	}

	/* [VL 1.0] BEGIN */
	private void checkPartnerContract(List<ASI_TH_CRM_Contract__c> contractList, List<Id> list_partnerContractId){
		set<Id> set_contractIdWithIssuedPayment = new set<Id>();
		for(ASI_CRM_Payment_Schedule__c s : [
			select id, ASI_CRM_Contract__c 
			from ASI_CRM_Payment_Schedule__c 
			where ASI_CRM_Contract__c in :list_partnerContractId
			AND RecordTypeId = :Global_RecordTypeCache.getRTId('ASI_CRM_Payment_Schedule__cASI_CRM_SG_Payment_Schedule')
			AND ASI_CRM_Payment_Issued__c = true
		]){
			set_contractIdWithIssuedPayment.add(s.ASI_CRM_Contract__c);
		}
		for(ASI_TH_CRM_Contract__c contract : contractList){
			if (set_contractIdWithIssuedPayment.contains(contract.Id)){
				contract.addError('This contract cannot be downgraded to Partner contract because it has issued payment.');
			}
		}
	}
	/* [VL 1.0] END */
}