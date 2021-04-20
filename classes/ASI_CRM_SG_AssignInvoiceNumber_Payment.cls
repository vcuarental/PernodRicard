/*********************************************************************************
 * Name:ASI_CRM_SG_AssignInvoiceNumber_Payment 
 * Description: Class to Assign Custom Invoice No Payment Request SG Specific
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 13/01/2015       Laputa: Conrad          Created
*********************************************************************************/

public with sharing class ASI_CRM_SG_AssignInvoiceNumber_Payment extends ASI_CRM_SG_TriggerAbstract {
	Set<String> gstTaxRateSet = new Set<String>{'CA3', 'IC3', 'IN3', 'LA3', 'MM3', 'MY3', 'PH3', 'SG3'};

    public ASI_CRM_SG_AssignInvoiceNumber_Payment () {
        super('ASI_CRM_SG_AssignInvoiceNumber_Payment ');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        system.debug('Start ASI_CRM_SG_AssignInvoiceNumber_Payment');
        List<ASI_TH_CRM_PaymentRequest__c> validPaymentList = new List<ASI_TH_CRM_PaymentRequest__c>();
        
        if(oldMap == null) {
            
            for(ASI_TH_CRM_PaymentRequest__c payment : (List<ASI_TH_CRM_PaymentRequest__c>)sObjList) {
                System.debug('payment clk12 ' + payment);
                if(payment.ASI_CRM_CN_OutletWS__c != null && payment.ASI_CRM_Vendor__c != null) {
                    validPaymentList.add(payment);
                }
            }
            
        } else {
            Map<ID,ASI_TH_CRM_PaymentRequest__c> paymentOldMap = (Map<ID,ASI_TH_CRM_PaymentRequest__c>)oldMap;
            
            for(ASI_TH_CRM_PaymentRequest__c payment : (List<ASI_TH_CRM_PaymentRequest__c>)sObjList) {
                
                ASI_TH_CRM_PaymentRequest__c paymentOld = paymentOldMap.get(payment.id);
                
                if(payment.ASI_CRM_Vendor__c != null && payment.ASI_CRM_CN_OutletWS__c != null 
                    && (payment.ASI_CRM_CN_OutletWS__c != paymentOld.ASI_CRM_CN_OutletWS__c || payment.ASI_CRM_Vendor__c != paymentOld.ASI_CRM_Vendor__c)) {
                    validPaymentList.add(payment);
                }
                
            }
            
        }
        
        if(validPaymentList.size() > 0) {
            Set<ID> customerIDSet = new Set<ID>();
            
            for(ASI_TH_CRM_PaymentRequest__c payment : validPaymentList) {
                customerIDSet.add(payment.ASI_CRM_Vendor__c);
                customerIDSet.add(payment.ASI_CRM_CN_OutletWS__c);
            }
            
            Map<ID, ASI_CRM_AccountsAdditionalField__c> customerMap = new Map<ID, ASI_CRM_AccountsAdditionalField__c>([SELECT ID, Name, ASI_CRM_MY_CustomerCode__c, ASI_CRM_CN_CRM_Code__c, ASI_CRM_SG_Tax_Rate_Area__c 
                                                                                                                        FROM ASI_CRM_AccountsAdditionalField__c
                                                                                                                        WHERE ID IN : customerIDSet
                                                                                                                        AND ASI_CRM_MY_CustomerCode__c <> NULL
                                                                                                                      ]);
            
            system.debug('customerMap ' + customerMap);
            system.debug('validPaymentList ' + validPaymentList);                                                                                                          
            if(customerMap.size() > 0) {
                for(ASI_TH_CRM_PaymentRequest__c payment : validPaymentList) {
                    if(customerMap.containsKey(payment.ASI_CRM_Vendor__c) && customerMap.containsKey(payment.ASI_CRM_CN_OutletWS__c)) {
                        String vendorCode = customerMap.get(payment.ASI_CRM_Vendor__c).ASI_CRM_MY_CustomerCode__c;
                        String outletCode = customerMap.get(payment.ASI_CRM_CN_OutletWS__c).ASI_CRM_MY_CustomerCode__c;
                        if(payment.ASI_CRM_SG_Invoice_No__c == null) {
                            payment.ASI_CRM_SG_Invoice_No__c = outletCode + '-' + vendorCode + '-' + payment.name;
                        }
						
						system.debug('Vendor Tax Rate/Area: ' + customerMap.get(payment.ASI_CRM_Vendor__c).ASI_CRM_SG_Tax_Rate_Area__c);
						if (gstTaxRateSet.contains(customerMap.get(payment.ASI_CRM_Vendor__c).ASI_CRM_SG_Tax_Rate_Area__c))
							payment.ASI_CRM_GST__c = true;
						else 
							payment.ASI_CRM_GST__c = false;
                    }
                }
            }
            
        }
    }
}