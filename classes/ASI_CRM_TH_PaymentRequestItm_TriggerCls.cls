/*********************************************************************************
 * Name:        ASI_CRM_TH_PaymentRequestLineItem_TriggerClass
 * Description: N/A
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2016-09-22       PRA: Vincent KWOK     Created
*********************************************************************************/

public without sharing class ASI_CRM_TH_PaymentRequestItm_TriggerCls{

    public static void routineBeforeInsert(list<ASI_TH_CRM_PaymentRequestLineItem__c> trigger_new){
		String vDefaultSubBrandId;
		try {
			//Get Default Sub Brand Id from custom setting ASI_TH_CRM_CustomSetting__c
			vDefaultSubBrandId = [SELECT ASI_TH_CRM_Payment_Line_SubBrand_Id__c FROM ASI_TH_CRM_CustomSetting__c LIMIT 1].ASI_TH_CRM_Payment_Line_SubBrand_Id__c;
			System.debug('vDefaultSubBrandId := ' + vDefaultSubBrandId);
			if (vDefaultSubBrandId != NULL) {
				for(ASI_TH_CRM_PaymentRequestLineItem__c idx : trigger_new){
					idx.ASI_TH_CRM_Subbrand__c = vDefaultSubBrandId;
				}
			}
		}catch (Exception e){
			System.debug('The following exception has occurred: ' + e.getMessage());
		}
    }
}