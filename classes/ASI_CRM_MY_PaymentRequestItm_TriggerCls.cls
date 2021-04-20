/*********************************************************************************
 * Name:        ASI_CRM_MY_PaymentRequestLineItem_TriggerClass--> ASI_CRM_MY_PaymentRequestItm_TriggerCls
 * Description: N/A
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2015-01-03       Introv: Daniel WONG     Created
*********************************************************************************/

public without sharing class ASI_CRM_MY_PaymentRequestItm_TriggerCls{
    public static String className = 'ASI_CRM_MY_PaymentRequestItm_TriggerCls';

    public static void routineBeforeUpsert(list<ASI_TH_CRM_PaymentRequestLineItem__c> trigger_new){
        if(!ASI_CRM_MY_Function.IsBypassTrigger(className)) {
            Map<String, map<String, String>> mapOfSetup = ASI_CRM_MY_Function.getContractSetupMapping();
            id idRT_PR = Global_RecordTypeCache.getRTId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_MY_Payment_Request_Detail');
            set<id> setPR = new set<id>();
            map<id, decimal> mapGSTRate = new map<id, decimal>();
    
            for(ASI_TH_CRM_PaymentRequestLineItem__c i : trigger_new){
                if(i.recordTypeId == idRT_PR) {
                    setPR.add(i.ASI_TH_CRM_Payment_Request__c);
                }
            }
            list<ASI_TH_CRM_PaymentRequest__c> lstPR = [SELECT id, ASI_CRM_GST_Rate__c, ASI_CRM_GST__c FROM ASI_TH_CRM_PaymentRequest__c WHERE id IN :setPR];
            for (ASI_TH_CRM_PaymentRequest__c i : lstPR) {
                mapGSTRate.put(i.id, i.ASI_CRM_GST__c == true ? i.ASI_CRM_GST_Rate__c / 100 : 0);
            }
            
            for(ASI_TH_CRM_PaymentRequestLineItem__c i : trigger_new){
                if(i.recordTypeId == idRT_PR) {
                    if(i.ASI_CRM_SetupCode__c != NULL){
                        if(mapOfSetup.get(i.ASI_CRM_SetupCode__c) != NULL)
                            i.ASI_CRM_CN_AC_Code__c = mapOfSetup.get(i.ASI_CRM_SetupCode__c).get('ID');
                    }
                    
                    // Calculate the tax amount
                    /*
                    if (i.ASI_TH_CRM_Amount__c != null && i.ASI_TH_CRM_Amount__c > 0) {
                        i.ASI_CRM_Net_Amount__c = i.ASI_TH_CRM_Amount__c / (1 + (mapGSTRate.get(i.ASI_TH_CRM_Payment_Request__c) == null ? 0 : mapGSTRate.get(i.ASI_TH_CRM_Payment_Request__c)));
                        i.ASI_CRM_Tax_Amount__c = i.ASI_TH_CRM_Amount__c - (i.ASI_CRM_Net_Amount__c == null ? 0 : i.ASI_CRM_Net_Amount__c);
                    }*/
                    // Calculate the tax amount, new logic from 2015-06-12
                    /*
                    if (i.ASI_CRM_Net_Amount__c != null && i.ASI_CRM_Net_Amount__c > 0) {
                        i.ASI_CRM_Tax_Amount__c = i.ASI_CRM_Net_Amount__c * (mapGSTRate.get(i.ASI_TH_CRM_Payment_Request__c) == null ? 0 : mapGSTRate.get(i.ASI_TH_CRM_Payment_Request__c));
                        i.ASI_TH_CRM_Amount__c = i.ASI_CRM_Tax_Amount__c + i.ASI_CRM_Net_Amount__c;
                    }
					*/
                    // Calculate the tax amount, new logic from 2018-05-03
                    if(i.ASI_CRM_MY_Adjusted_Amount__c  == null || i.ASI_CRM_MY_Adjusted_Amount__c  < 0){
                        i.ASI_CRM_MY_Adjusted_Amount__c = i.ASI_CRM_Net_Amount__c;
                    }
                    i.ASI_CRM_Tax_Amount__c = i.ASI_CRM_MY_Adjusted_Amount__c  * (mapGSTRate.get(i.ASI_TH_CRM_Payment_Request__c) == null ? 0 : mapGSTRate.get(i.ASI_TH_CRM_Payment_Request__c));
                    i.ASI_TH_CRM_Amount__c = i.ASI_CRM_Tax_Amount__c + i.ASI_CRM_MY_Adjusted_Amount__c ;
                    

                }
            }
        }
    }
}