/**************************************************************************************************
 * Name: ASI_CRM_CN_TP_PaymentRequest_TriggerCls
 * Object: ASI_TH_CRM_PaymentRequest__c
 * Purpose: 
 * Author:  (Jack Yuan)
 * Create Date: 2020-04-13
 * Modify History:
 * 2020-04-13        Create this class
 **************************************************************************************************/
public without sharing class ASI_CRM_CN_TP_PaymentRequest_TriggerCls {
    
    public static void routineAfterUpsert(List<ASI_TH_CRM_PaymentRequest__c> trigger_new, Map<Id,ASI_TH_CRM_PaymentRequest__c> trigger_oldMap) {
        if (trigger_oldMap != null) {

            Set<Id> poIds = new Set<Id>();
            for (ASI_TH_CRM_PaymentRequest__c pmt : trigger_new) {
                if (pmt.ASI_CRM_CN_Last_Payment__c == true && pmt.ASI_TH_CRM_Status__c == ASI_CRM_CN_TP_Utils.PAYMENTSTATUSAPPROVED &&trigger_oldMap.get(pmt.Id).ASI_TH_CRM_Status__c != ASI_CRM_CN_TP_Utils.PAYMENTSTATUSAPPROVED) {
                    poIds.add(pmt.ASI_TH_CRM_Contract__c);
                }
            }
            System.debug(LoggingLevel.INFO, '*** poIds: ' + poIds);
            List<ASI_TH_CRM_Contract__c> poList = [SELECT Id, (SELECT ASI_MFM_Status__c 
                                                               FROM Plans__r 
                                                               WHERE ASI_MFM_Status__c != :ASI_CRM_CN_TP_Utils.TPSTATUSCOMPLETE 
                                                               AND (RecordType.DeveloperName = 'ASI_CRM_CN_TP_Trade_Plan' 
                                                                    OR RecordType.DeveloperName = 'ASI_CRM_CN_TP_Trade_Plan_Read_Only')) 
                                                    FROM ASI_TH_CRM_Contract__c 
                                                    WHERE Id IN :poIds];
            List<ASI_MFM_Plan__c> tPlans = new List<ASI_MFM_Plan__c>();
            for (ASI_TH_CRM_Contract__c po : poList) {
                for (ASI_MFM_Plan__c tp : po.Plans__r) {
                    tp.ASI_MFM_Status__c = ASI_CRM_CN_TP_Utils.TPSTATUSCOMPLETE;
                    tPlans.add(tp);
                }
            }
            System.debug(LoggingLevel.INFO, '*** tPlans: ' + tPlans);
            if (!tPlans.isEmpty()) {
                update tPlans;
            }
        }
    }
}