/*********************************************************************************
 * Name:ASI_TnE_GnH_TW_UpdateGnHAmount
 * Description: Update the GnH Request amount when insert/update/delete a TnE Line related records
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2016-06-23       Laputa: Hugo Cheung     Created
*********************************************************************************/
public with sharing class ASI_TnE_GnH_TW_UpdateGnHAmount extends ASI_TnE_TriggerAbstract {

	public ASI_TnE_GnH_TW_UpdateGnHAmount() {
		super('ASI_TnE_GnH_TW_UpdateGnHAmount');
	}

	public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {

		List<ASI_TnE_ClaimDetail__c> claimDetailList = (List<ASI_TnE_ClaimDetail__c>) sObjList;
		Map<Id, ASI_TnE_ClaimDetail__c> oldClaimDetailMap = (Map<Id, ASI_TnE_ClaimDetail__c>) oldMap;

		List<Id> GnHRequestIdList = new List<Id>();

		if(tAction == ASI_TnE_TriggerAbstract.TriggerAction.AFTER_INSERT) {

			for(ASI_TnE_ClaimDetail__c claimDetail : claimDetailList) {

				if(String.isNotBlank(claimDetail.ASI_TnE_GnH_Request__c)) {

					GnHRequestIdList.add(claimDetail.ASI_TnE_GnH_Request__c);

				}

			}

		} else if (tAction == ASI_TnE_TriggerAbstract.TriggerAction.AFTER_UPDATE) {

			for(ASI_TnE_ClaimDetail__c claimDetail : claimDetailList) {

				if(String.isNotBlank(claimDetail.ASI_TnE_GnH_Request__c) && 
				   claimDetail.ASI_TnE_TW_Payment_Amount__c != oldClaimDetailMap.get(claimDetail.Id).ASI_TnE_TW_Payment_Amount__c) {

					GnHRequestIdList.add(claimDetail.ASI_TnE_GnH_Request__c);

				}

				if(claimDetail.ASI_TnE_GnH_Request__c != oldClaimDetailMap.get(claimDetail.Id).ASI_TnE_GnH_Request__c) {

					if(String.isNotBlank(claimDetail.ASI_TnE_GnH_Request__c)) {

						GnHRequestIdList.add(claimDetail.ASI_TnE_GnH_Request__c);

					}

					GnHRequestIdList.add(oldClaimDetailMap.get(claimDetail.Id).ASI_TnE_GnH_Request__c);

				}

			}

		} else if (tAction == ASI_TnE_TriggerAbstract.TriggerAction.AFTER_DELETE) {

			for(ASI_TnE_ClaimDetail__c claimDetail : oldClaimDetailMap.values()) {

				if(String.isNotBlank(claimDetail.ASI_TnE_GnH_Request__c)) {

					GnHRequestIdList.add(claimDetail.ASI_TnE_GnH_Request__c);

				}

			}

		}

		if(GnHRequestIdList.size() > 0) {

			List<ASI_GnH_Request__c> GnHRequestList = [SELECT Id, Name, ASI_GnH_Amount_per_Recipient__c, ASI_GnH_Actual_Amount_per_Recipient__c, 
														(SELECT ASI_TnE_TW_Payment_Amount__c, ASI_TnE_Total_Number_Pax__c FROM Travel_Entertainment_Claims_Detail__r)
			                                           		FROM ASI_GnH_Request__c
			                                           			WHERE Id in :GnHRequestIdList];

			for(ASI_GnH_Request__c GnHRequest : GnHRequestList) {

				GnHRequest.ASI_GnH_Actual_Amount_per_Recipient__c = 0;

				for(ASI_TnE_ClaimDetail__c claimDetail : GnHRequest.Travel_Entertainment_Claims_Detail__r) {

					if(claimDetail.ASI_TnE_TW_Payment_Amount__c != null) {

						GnHRequest.ASI_GnH_Actual_Amount_per_Recipient__c += claimDetail.ASI_TnE_TW_Payment_Amount__c / claimDetail.ASI_TnE_Total_Number_Pax__c;

					}

				}

			}

			update GnHRequestList;

		}

	}

}