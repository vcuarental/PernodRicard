/*********************************************************************************
 * Name:ASI_TnE_GnH_TW_ClaimsDetailValidation
 * Description: Validation of G&H records
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2016-06-22       Laputa: Hugo Cheung     Created
*********************************************************************************/
public with sharing class ASI_TnE_GnH_TW_ClaimsDetailValidation extends ASI_TnE_TriggerAbstract {

	public ASI_TnE_GnH_TW_ClaimsDetailValidation() {
		super('ASI_TnE_GnH_TW_ClaimsDetailValidation');
	}

	public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {

		List<ASI_TnE_ClaimDetail__c> claimDetailList = (List<ASI_TnE_ClaimDetail__c>) sObjList;
		Map<Id, ASI_TnE_ClaimDetail__c> oldClaimDetailMap = (Map<Id, ASI_TnE_ClaimDetail__c>) oldMap;

		List<Id> claimIdList = new List<Id>();
		List<Id> claimHeaderIdList = new List<Id>();
		List<Id> expenseClassificationIdList = new List<Id>();
		List<Id> GnHRequestIdList = new List<Id>();

		for(ASI_TnE_ClaimDetail__c claimDetail : claimDetailList) {

			claimIdList.add(claimDetail.Id);
			claimHeaderIdList.add(claimDetail.ASI_TnE_ClaimHeader__c);

			if(String.isNotBlank(claimDetail.ASI_TnE_GnH_Request__c)) {

				GnHRequestIdList.add(claimDetail.ASI_TnE_GnH_Request__c);

			}

			if(tAction == ASI_TnE_TriggerAbstract.TriggerAction.BEFORE_UPDATE &&
			   String.isNotBlank(oldClaimDetailMap.get(claimDetail.Id).ASI_TnE_GnH_Request__c)) {

				GnHRequestIdList.add(oldClaimDetailMap.get(claimDetail.Id).ASI_TnE_GnH_Request__c);

			}

			if(String.isNotBlank(claimDetail.ASI_TnE_Expense_Classification__c)) {

				expenseClassificationIdList.add(claimDetail.ASI_TnE_Expense_Classification__c);

			}

		}

		Map<Id, ASI_TnE_ClaimHeader__c> claimHeaderMap = new Map<Id, ASI_TnE_ClaimHeader__c>([SELECT Id, ASI_TnE_Payee_Employee__c
																						     		FROM ASI_TnE_ClaimHeader__c
																						     			WHERE Id in :claimHeaderIdList
			                                                                                 ]);

		Map<Id, ASI_JP_TnE_Expense_Classification__c> expenseClassificationMap = new Map<Id, ASI_JP_TnE_Expense_Classification__c>([SELECT Id, Name, ASI_TnE_GnH_Type__c
				                                                                                  						  					FROM ASI_JP_TnE_Expense_Classification__c
				                                                                                  												WHERE Id in :expenseClassificationIdList]);

		checkPAXThreshold(claimDetailList, expenseClassificationMap);

		if(GnHRequestIdList.size() > 0) {

			Map<Id, ASI_GnH_Request__c> GnHRequestMap = new Map<Id, ASI_GnH_Request__c>([SELECT Id, Name, ASI_GnH_Applicant__c, ASI_GnH_PAX__c, ASI_GnH_Type__c, ASI_GnH_Recipient_Type__c, ASI_GnH_Amount_per_Recipient__c, ASI_GnH_Actual_Amount_per_Recipient__c
			                                           		                         		FROM ASI_GnH_Request__c
			                                           			                        		WHERE Id in :GnHRequestIdList]);

			List<ASI_TnE_ClaimDetail__c> existingClaimDetailList = [SELECT Id, Name, ASI_TnE_Total_Number_Pax__c, ASI_TnE_TW_Payment_Amount__c, ASI_TnE_GnH_Request__c
			                                                       		FROM ASI_TnE_ClaimDetail__c
			                                                       			WHERE ASI_TnE_GnH_Request__c in :GnHRequestIdList 
			                                                       				AND Id not in :claimIdList];

			Map<Id, List<ASI_TnE_ClaimDetail__c>> GnHRequestIdClaimDetailMap = processGnHRequestClaimDetailMap(claimDetailList, existingClaimDetailList);                                                       			

			for(ASI_TnE_ClaimDetail__c claimDetail : claimDetailList) {
				recalClaimAmount(tAction, claimDetail, oldClaimDetailMap, GnHRequestMap); 
				checkClaimPAXandType(claimDetail, expenseClassificationMap, GnHRequestMap);
			}

			checkClaimAmount(claimDetailList, GnHRequestMap);
			checkClaimPXAIsSame(claimDetailList, GnHRequestIdClaimDetailMap);

		}
	}

	private Map<Id, List<ASI_TnE_ClaimDetail__c>> processGnHRequestClaimDetailMap(List<ASI_TnE_ClaimDetail__c> claimDetailList, List<ASI_TnE_ClaimDetail__c> existingClaimDetailList) {

		Map<Id, List<ASI_TnE_ClaimDetail__c>> GnHRequestIdClaimDetailMap = new Map<Id, List<ASI_TnE_ClaimDetail__c>>();  

		for(ASI_TnE_ClaimDetail__c claimDetail : claimDetailList) {

			if(String.isNotBlank(claimDetail.ASI_TnE_GnH_Request__c)) { 

				List<ASI_TnE_ClaimDetail__c> tempClaimDetail;

				if(GnHRequestIdClaimDetailMap.containsKey(claimDetail.ASI_TnE_GnH_Request__c)) {

					tempClaimDetail = GnHRequestIdClaimDetailMap.get(claimDetail.ASI_TnE_GnH_Request__c);

				} else {

					tempClaimDetail = new List<ASI_TnE_ClaimDetail__c>();

				}

				tempClaimDetail.add(claimDetail);
				GnHRequestIdClaimDetailMap.put(claimDetail.ASI_TnE_GnH_Request__c, tempClaimDetail);
				
			}

		}

		for(ASI_TnE_ClaimDetail__c existingClaimDetail : existingClaimDetailList) {

			if(String.isNotBlank(existingClaimDetail.ASI_TnE_GnH_Request__c)) { 

				List<ASI_TnE_ClaimDetail__c> tempClaimDetail;

				if(GnHRequestIdClaimDetailMap.containsKey(existingClaimDetail.ASI_TnE_GnH_Request__c)) {

					tempClaimDetail = GnHRequestIdClaimDetailMap.get(existingClaimDetail.ASI_TnE_GnH_Request__c);

				} else {

					tempClaimDetail = new List<ASI_TnE_ClaimDetail__c>();

				}

				tempClaimDetail.add(existingClaimDetail);
				GnHRequestIdClaimDetailMap.put(existingClaimDetail.ASI_TnE_GnH_Request__c, tempClaimDetail);
				
			}

		}

		return GnHRequestIdClaimDetailMap;

	}

	private void checkPAXThreshold(List<ASI_TnE_ClaimDetail__c> claimDetailList, Map<Id, ASI_JP_TnE_Expense_Classification__c> expenseClassificationMap) {

		List<ASI_GnH_Threshold__c> thresholdList = [SELECT ASI_GnH_GnH_Type__c, ASI_GnH_Recipient_Type__c, ASI_GnH_Threshold_Amount__c
			                                            	FROM ASI_GnH_Threshold__c];

		Map<String, ASI_GnH_Threshold__c> thresholdTypeMap = new Map<String, ASI_GnH_Threshold__c>();
			                                           
		for(ASI_GnH_Threshold__c threshold : thresholdList) {
			thresholdTypeMap.put(threshold.ASI_GnH_GnH_Type__c + '_' + threshold.ASI_GnH_Recipient_Type__c, threshold);
		}

		for(ASI_TnE_ClaimDetail__c claimDetail : claimDetailList) {

			Decimal paymentAmountPerPAX = (claimDetail.ASI_TnE_TW_Payment_Amount__c != null ? claimDetail.ASI_TnE_TW_Payment_Amount__c : 0) 
			                              / (claimDetail.ASI_TnE_Total_Number_Pax__c != null ? claimDetail.ASI_TnE_Total_Number_Pax__c : 1);

			if(expenseClassificationMap.containsKey(claimDetail.ASI_TnE_Expense_Classification__c) && 
			   thresholdTypeMap.containsKey(expenseClassificationMap.get(claimDetail.ASI_TnE_Expense_Classification__c).ASI_TnE_GnH_Type__c + '_' + claimDetail.ASI_TnE_Recipient_Type__c)) {

				ASI_GnH_Threshold__c threshold = thresholdTypeMap.get(expenseClassificationMap.get(claimDetail.ASI_TnE_Expense_Classification__c).ASI_TnE_GnH_Type__c + '_' + claimDetail.ASI_TnE_Recipient_Type__c);

				if(paymentAmountPerPAX > threshold.ASI_GnH_Threshold_Amount__c &&
				   String.isBlank(claimDetail.ASI_TnE_GnH_Request__c)) {

					claimDetail.addError(System.Label.ASI_TnE_GnH_TW_Greater_Threshold);

				}

			}

		}

	}

	private void checkClaimPAXandType(ASI_TnE_ClaimDetail__c claimDetail, Map<Id, ASI_JP_TnE_Expense_Classification__c> expenseClassificationMap, Map<Id, ASI_GnH_Request__c> GnHRequestMap) {

		if(String.isNotBlank(claimDetail.ASI_TnE_GnH_Request__c) &&
		   GnHRequestMap.containsKey(claimDetail.ASI_TnE_GnH_Request__c)) {

			ASI_GnH_Request__c GnHRequest = GnHRequestMap.get(claimDetail.ASI_TnE_GnH_Request__c);

			if(claimDetail.ASI_TnE_Total_Number_Pax__c == null ||
			   claimDetail.ASI_TnE_Total_Number_Pax__c > GnHRequest.ASI_GnH_PAX__c) {

				claimDetail.addError(System.Label.ASI_TnE_GnH_TW_Greater_PAX);

			}

			if(expenseClassificationMap.containsKey(claimDetail.ASI_TnE_Expense_Classification__c)) {

				ASI_JP_TnE_Expense_Classification__c expenseClassification = expenseClassificationMap.get(claimDetail.ASI_TnE_Expense_Classification__c);

				if(String.isBlank(expenseClassification.ASI_TnE_GnH_Type__c) || 
				   !expenseClassification.ASI_TnE_GnH_Type__c.equalsIgnoreCase(GnHRequest.ASI_GnH_Type__c) || 
				   !claimDetail.ASI_TnE_Recipient_Type__c.equalsIgnoreCase(GnHRequest.ASI_GnH_Recipient_Type__c)) {

					claimDetail.addError(System.Label.ASI_TnE_GnH_TW_Type_Error);
							
				}

			}

		}

	}

	private void recalClaimAmount(TriggerAction tAction, ASI_TnE_ClaimDetail__c claimDetail, Map<Id, ASI_TnE_ClaimDetail__c> oldClaimDetailMap, Map<Id, ASI_GnH_Request__c> GnHRequestMap) {

		if((String.isNotBlank(claimDetail.ASI_TnE_GnH_Request__c) || 
		    String.isNotBlank(oldClaimDetailMap.get(claimDetail.Id).ASI_TnE_GnH_Request__c)) &&
		   (GnHRequestMap.containsKey(claimDetail.ASI_TnE_GnH_Request__c) || 
			GnHRequestMap.containsKey(oldClaimDetailMap.get(claimDetail.Id).ASI_TnE_GnH_Request__c))) {

			ASI_GnH_Request__c GnHRequest = GnHRequestMap.get(claimDetail.ASI_TnE_GnH_Request__c);

			if(GnHRequest.ASI_GnH_Actual_Amount_per_Recipient__c == null) {

				GnHRequest.ASI_GnH_Actual_Amount_per_Recipient__c = 0;

			}

			if (tAction == ASI_TnE_TriggerAbstract.TriggerAction.BEFORE_UPDATE && 
				oldClaimDetailMap.get(claimDetail.Id).ASI_TnE_TW_Payment_Amount__c != null) {

				if(claimDetail.ASI_TnE_GnH_Request__c != oldClaimDetailMap.get(claimDetail.Id).ASI_TnE_GnH_Request__c) {

					if(GnHRequestMap.containsKey(oldClaimDetailMap.get(claimDetail.Id).ASI_TnE_GnH_Request__c)) {

						GnHRequestMap.get(oldClaimDetailMap.get(claimDetail.Id).ASI_TnE_GnH_Request__c).ASI_GnH_Actual_Amount_per_Recipient__c -= (oldClaimDetailMap.get(claimDetail.Id).ASI_TnE_TW_Payment_Amount__c != null ? oldClaimDetailMap.get(claimDetail.Id).ASI_TnE_TW_Payment_Amount__c : 0)
                                                                                                                                                  / (oldClaimDetailMap.get(claimDetail.Id).ASI_TnE_Total_Number_Pax__c != null ? oldClaimDetailMap.get(claimDetail.Id).ASI_TnE_Total_Number_Pax__c : 1);

					}

				} else {

					GnHRequest.ASI_GnH_Actual_Amount_per_Recipient__c -= (oldClaimDetailMap.get(claimDetail.Id).ASI_TnE_TW_Payment_Amount__c != null ? oldClaimDetailMap.get(claimDetail.Id).ASI_TnE_TW_Payment_Amount__c : 0)
                                                                         / (oldClaimDetailMap.get(claimDetail.Id).ASI_TnE_Total_Number_Pax__c != null ? oldClaimDetailMap.get(claimDetail.Id).ASI_TnE_Total_Number_Pax__c : 1);

				}

			}

			if(claimDetail.ASI_TnE_TW_Payment_Amount__c != null) {
				System.debug('Debug Message : ' + GnHRequest.ASI_GnH_Actual_Amount_per_Recipient__c);
				System.debug('Debug Message : ' + claimDetail.ASI_TnE_TW_Payment_Amount__c);
				System.debug('Debug Message : ' + claimDetail.ASI_TnE_Total_Number_Pax__c);
				GnHRequest.ASI_GnH_Actual_Amount_per_Recipient__c += (claimDetail.ASI_TnE_TW_Payment_Amount__c != null ? claimDetail.ASI_TnE_TW_Payment_Amount__c : 0) 
			                                                         / (claimDetail.ASI_TnE_Total_Number_Pax__c != null ? claimDetail.ASI_TnE_Total_Number_Pax__c : 1);

			}

		}
		
	}

	private void checkClaimAmount(List<ASI_TnE_ClaimDetail__c> claimDetailList, Map<Id, ASI_GnH_Request__c> GnHRequestMap) {
		
		Set<Id> errorGnHRequestIdSet = new Set<Id>();                                             			

		for(Id key : GnHRequestMap.keySet()) {
		
			ASI_GnH_Request__c GnHRequest = GnHRequestMap.get(key);	
			System.debug('Debug Message : ' + GnHRequest.ASI_GnH_Actual_Amount_per_Recipient__c);
			System.debug('Debug Message : ' + GnHRequest.ASI_GnH_Amount_per_Recipient__c);
			if(GnHRequest.ASI_GnH_Actual_Amount_per_Recipient__c > GnHRequest.ASI_GnH_Amount_per_Recipient__c) {

				errorGnHRequestIdSet.add(GnHRequest.Id);

			}

		}

		if(errorGnHRequestIdSet.size() > 0) {

			for(ASI_TnE_ClaimDetail__c claimDetail : claimDetailList) {

				if(String.isNotBlank(claimDetail.ASI_TnE_GnH_Request__c) &&
				   errorGnHRequestIdSet.contains(claimDetail.ASI_TnE_GnH_Request__c)) {

					claimDetail.addError(System.Label.ASI_TnE_GnH_TW_Greater_Amount);

				}

			}

		}

	}

	private void checkClaimPXAIsSame(List<ASI_TnE_ClaimDetail__c> claimDetailList, Map<Id, List<ASI_TnE_ClaimDetail__c>> GnHRequestIdClaimDetailMap) {

		Set<Id> notMatchPAXGnHRequestIdSet = new Set<Id>();  

		for(Id key : GnHRequestIdClaimDetailMap.keySet()) {

			Decimal currentPAX;

			for(ASI_TnE_ClaimDetail__c claimDetail : GnHRequestIdClaimDetailMap.get(key)) {

				if(currentPAX == null) {

					currentPAX = claimDetail.ASI_TnE_Total_Number_Pax__c;
					continue;

				}

				if(currentPAX != claimDetail.ASI_TnE_Total_Number_Pax__c) {

					notMatchPAXGnHRequestIdSet.add(key);

				}

			}

		}

		if(notMatchPAXGnHRequestIdSet.size() > 0) {

			for(ASI_TnE_ClaimDetail__c claimDetail : claimDetailList) {

				if(String.isNotBlank(claimDetail.ASI_TnE_GnH_Request__c)) { 

					if(notMatchPAXGnHRequestIdSet.contains(claimDetail.ASI_TnE_GnH_Request__c)){ 

						claimDetail.addError(System.Label.ASI_TnE_GnH_TW_PAX_Not_Same);

					}

				}

			}

		}

	}

}