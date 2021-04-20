/*********************************************************************************
 * Name:ASI_CRM_JP_AutoCloseContract 
 * Description: Autoclose Contract Header if the remaining balance is 0 AND related Payment is closed
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 30/03/2015       Laputa: Conrad          Created
*********************************************************************************/

public with sharing class ASI_CRM_JP_AutoCloseContract extends ASI_CRM_JP_TriggerAbstract {


    public ASI_CRM_JP_AutoCloseContract() {
        super('ASI_CRM_JP_AutoCloseContract');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        
        List<ASI_CRM_Payment_Invoice__c> paymentList = (List<ASI_CRM_Payment_Invoice__c>) sObjList;
        List<ASI_CRM_Payment_Invoice__c> validPaymentList = new List<ASI_CRM_Payment_Invoice__c>();
        
        Map<ID, ASI_CRM_Payment_Invoice__c> paymentOldMap = (Map<ID, ASI_CRM_Payment_Invoice__c>) oldMap;
        
        for(ASI_CRM_Payment_Invoice__c payment : paymentList) {
            if(paymentOldMap.get(payment.ID).ASI_CRM_Status__c != payment.ASI_CRM_Status__c && payment.ASI_CRM_Status__c == 'Complete') {
                validPaymentList.add(payment);
            }
        }
        
        List<ASI_CRM_Payment_Invoice_Line_Item__c> validPaymentLineItemsList = new List<ASI_CRM_Payment_Invoice_Line_Item__c>();
        
        if(validPaymentList.size() > 0) {
            Set<ID> paymentIDSet = new Set<ID>();
            
            for(ASI_CRM_Payment_Invoice__c payment : validPaymentList) {
                paymentIDSet.add(payment.id);
            }
            
            validPaymentLineItemsList = [SELECT ID, Name, ASI_CRM_Sys_is_cancelled__c, ASI_CRM_Purchase_Contract_Line_Item__c FROM ASI_CRM_Payment_Invoice_Line_Item__c WHERE ASI_CRM_Payment_Invoice__c IN : paymentIDSet];
        }
        
        if(validPaymentLineItemsList.size() > 0) {
            
            Set<ID> contractLineIdSet = new Set<ID>();
            Set<ID> contractIdSet = new Set<ID>();
            
            for(ASI_CRM_Payment_Invoice_Line_Item__c paymentLine : validPaymentLineItemsList) {
                if(!paymentLine.ASI_CRM_Sys_is_cancelled__c) {
                    contractLineIdSet.add(paymentLine.ASI_CRM_Purchase_Contract_Line_Item__c);
                }
            }
            
            if(contractLineIdSet.size() > 0) {
                Map<ID,ASI_CRM_Purchase_Contract_Line_Item__c> contractLineItemMap = new Map<ID,ASI_CRM_Purchase_Contract_Line_Item__c>(
                                                                                    [SELECT ID, Name, ASI_CRM_Purchase_Contract__c, 
                                                                                        (
                                                                                            SELECT ID, Name, ASI_CRM_Actual_Amount__c, ASI_CRM_Adjustment_Amount__c 
                                                                                            FROM Payment_Invoice_Line_Items__r
                                                                                            WHERE ASI_CRM_Sys_is_cancelled__c = false
                                                                                        )
                                                                                     FROM ASI_CRM_Purchase_Contract_Line_Item__c
                                                                                     WHERE ID IN : contractLineIdSet
                                                                                    ]
                                                                                    );
                                                                                    
                for(ASI_CRM_Purchase_Contract_Line_Item__c contractLine : contractLineItemMap.values()) {
                    contractIdSet.add(contractLine.ASI_CRM_Purchase_Contract__c);
                }
                
                
                
                Map<ID, ASI_CRM_Purchase_Contract__c> contractMap = new Map<ID, ASI_CRM_Purchase_Contract__c>([
                                                                                                                SELECT ID, Name,
                                                                                                                    (
                                                                                                                         SELECT ID, Name, ASI_CRM_Unit_Price__c,
                                                                                                                         ASI_CRM_Quantity__c
                                                                                                                         FROM Purchase_Contract_Line_Items__r
                                                                                                                    )
                                                                                                                 FROM ASI_CRM_Purchase_Contract__c
                                                                                                                 WHERE ID IN : contractIdSet
                                                                                                              ]
                                                                                                             );
                
                List<ASI_CRM_Purchase_Contract__c> contractToUpdateList = new List<ASI_CRM_Purchase_Contract__c>();
                for(ASI_CRM_Purchase_Contract__c contract : contractMap.values()) {
                    
                    Decimal totalAmountPaid = 0;
                    Decimal totalContractAmount = 0;
                    List<ASI_CRM_Purchase_Contract_Line_Item__c> contractLineList = contract.Purchase_Contract_Line_Items__r;
                    for(ASI_CRM_Purchase_Contract_Line_Item__c contractLine : contractLineList) {
                    
                        Decimal amountPaid = 0;
                        Decimal unitPrice = contractLine.ASI_CRM_Unit_Price__c != null ? contractLine.ASI_CRM_Unit_Price__c : 0;
                        Decimal qty = contractLine.ASI_CRM_Quantity__c != null ? contractLine.ASI_CRM_Quantity__c : 0;
                        
                        if(contractLineItemMap.containsKey(contractLine.id)) {
                            List<ASI_CRM_Payment_Invoice_Line_Item__c> paymentItemList = contractLineItemMap.get(contractLine.id).Payment_Invoice_Line_Items__r;
                        
                            for(ASI_CRM_Payment_Invoice_Line_Item__c paymentItem : paymentItemList) {
                        
                                Decimal actualAmount = paymentItem.ASI_CRM_Actual_Amount__c != null ? paymentItem.ASI_CRM_Actual_Amount__c : 0;
                                Decimal adjustmentAmount = paymentItem.ASI_CRM_Adjustment_Amount__c != null ? paymentItem.ASI_CRM_Adjustment_Amount__c : 0;
                            
                                amountPaid += (actualAmount + adjustmentAmount).round(System.RoundingMode.HALF_DOWN);
                            }
                        }
                        
                        totalAmountPaid += amountPaid;
                        totalContractAmount += unitPrice*qty;
                        
                    }
                    
                    Decimal remainingBalance = totalContractAmount - totalAmountPaid;
                    if(remainingBalance <= 0) {
                        contract.ASI_CRM_Status__c = 'Complete';
                        contractToUpdateList.add(contract);
                    }
                }
                
                if(contractToUpdateList.size() > 0){
                    update contractToUpdateList;
                }
            }
            
        }
        
    }
}