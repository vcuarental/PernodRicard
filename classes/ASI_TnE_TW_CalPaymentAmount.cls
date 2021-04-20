/*********************************************************************************
 * Name:ASI_TnE_TW_CalPaymentAmount
 * Description: Calculate the payment amount of claim detail
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2016-06-24       Laputa: Hugo Cheung     Created
 * 2016-09-19		Laputa: Hugo Cheung		Set sys record type and default ap remarks when create record
*********************************************************************************/
public without sharing class ASI_TnE_TW_CalPaymentAmount extends ASI_TnE_TriggerAbstract {

	public ASI_TnE_TW_CalPaymentAmount() {
		super('ASI_TnE_TW_CalPaymentAmount');
	}

	public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {

		List<ASI_TnE_ClaimDetail__c> claimDetailList = (List<ASI_TnE_ClaimDetail__c>) sObjList;
        
       	List<Id> claimHeaderIdList = new List<Id>();
        
        for(ASI_TnE_ClaimDetail__c claimDetail : claimDetailList) {
            claimHeaderIdList.add(claimDetail.ASI_TnE_ClaimHeader__c);
        }

        Map<Id, ASI_TnE_ClaimHeader__c> claimHeaderList = new Map<Id, ASI_TnE_ClaimHeader__c>([SELECT Id, ASI_TnE_Currency__c 
                                                                                               FROM ASI_TnE_ClaimHeader__c
                                                                                               WHERE Id in :claimHeaderIdList]);
        
		for(ASI_TnE_ClaimDetail__c claimDetail : claimDetailList) {

			Decimal paymentAmount = (claimDetail.ASI_TnE_Receipt_Amount__c != null ? claimDetail.ASI_TnE_Receipt_Amount__c : 0) * (claimDetail.ASI_TnE_FX_Rate__c != null ? claimDetail.ASI_TnE_FX_Rate__c : 0);
			
			if(claimHeaderList.get(claimDetail.ASI_TnE_ClaimHeader__c).ASI_TnE_Currency__c == 'TWD') {
                claimDetail.ASI_TnE_TW_Payment_Amount__c = paymentAmount.setScale(0);
            } else {
                claimDetail.ASI_TnE_TW_Payment_Amount__c = paymentAmount.setScale(2);
            }

		}
		
        if(tAction == ASI_TnE_TriggerAbstract.TriggerAction.BEFORE_INSERT) {
            for(ASI_TnE_ClaimDetail__c claimDetail : claimDetailList) {
                setSysRecordType(claimDetail);
                setAPRemarks(claimDetail);
            }
        }
        //20170104, Elufa Support
        if(tAction == ASI_TnE_TriggerAbstract.TriggerAction.BEFORE_UPDATE) {
            for(ASI_TnE_ClaimDetail__c claimDetail : claimDetailList) {
                setAPRemarks(claimDetail);
            }
        }
        //20170104, Elufa Support
	}
    
    public void setSysRecordType(ASI_TnE_ClaimDetail__c claimDetail) {
    	claimDetail.ASI_TnE_Sys_Record_Type__c = Global_RecordTypeCache.getRt(claimDetail.RecordTypeId).developerName;
    }
	
    public void setAPRemarks(ASI_TnE_ClaimDetail__c claimDetail) {
        if(Global_RecordTypeCache.getRt(claimDetail.RecordTypeId).developerName == 'ASI_TnE_TW_Claim_Detail' &&
           //String.isBlank(claimDetail.ASI_TnE_AP_Remarks__c) && //20170104, Elufa Support
           String.isNotBlank(claimDetail.ASI_TnE_Details_of_Expense__c)) {
        	claimDetail.ASI_TnE_AP_Remarks__c = claimDetail.ASI_TnE_Details_of_Expense__c.left(30);
        }        
    }
    
}