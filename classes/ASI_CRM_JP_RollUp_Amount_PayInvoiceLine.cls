/*********************************************************************************
 * Name:ASI_CRM_JP_RollUp_Amount_PayInvoiceLine 
 * Description: Roll up the Line Total Amount
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 18/03/2015       Laputa: Conrad          Created
 * 01/10/2019       Wilken Lee            [WL 1.0] Change security to without sharing to cater approver need to edit line item
*********************************************************************************/

public without sharing class ASI_CRM_JP_RollUp_Amount_PayInvoiceLine extends ASI_CRM_JP_TriggerAbstract {//WL 1.0


    public ASI_CRM_JP_RollUp_Amount_PayInvoiceLine() {
        super('ASI_CRM_JP_RollUp_Amount_PayInvoiceLine');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        List<ASI_CRM_Payment_Invoice_Line_Item__c> paymentLinesList = (List<ASI_CRM_Payment_Invoice_Line_Item__c>)sObjList;
        Set<ID> paymentIdSet = new Set<ID>();
        
        for(ASI_CRM_Payment_Invoice_Line_Item__c paymentLine : paymentLinesList) {
            if(Global_RecordTypeCache.getRt(paymentLine.recordTypeid).developerName.contains('ASI_CRM_JP_Indirect_Rebate_Invoice_Line_Item') || Global_RecordTypeCache.getRt(paymentLine.recordTypeid).developerName.contains('ASI_CRM_JP_SPTD_FOC_Invoice_Line_Item')){
                paymentIdSet.add(paymentLine.ASI_CRM_Payment_Invoice__c);
            }
        }
        
        if(paymentIdSet.size() > 0) {
            
            Map<ID, ASI_CRM_Payment_Invoice__c> paymentInvoiceMap = new Map<ID, ASI_CRM_Payment_Invoice__c>([SELECT ID, Name, ASI_CRM_Rebate_Invoice_Amount__c,ASI_CRM_Total_Invoice_Amount__c, ASI_CRM_No_of_A_P_Line__c, ASI_CRM_Total_Taxable_Amount__c, RecordType.DeveloperName, (SELECT ID FROM Payment_Invoice_Lines__r WHERE RecordType.DeveloperName = 'ASI_CRM_JP_SPTD_Cash_Invoice_Line_Item') FROM ASI_CRM_Payment_Invoice__c
                                                                                                                WHERE ID IN : paymentIdSet]);
            
            List<AggregateResult> resultAggregateList = [SELECT ASI_CRM_Payment_Invoice__c,
                SUM(ASI_CRM_Line_Total_Amount__c) totalLineAmount,
                SUM(ASI_CRM_Final_Amount__c) totalFinalAmount
                FROM ASI_CRM_Payment_Invoice_Line_Item__c
                WHERE ASI_CRM_Payment_Invoice__c IN: paymentIdSet
                AND (
                    RecordType.DeveloperName Like '%ASI_CRM_JP_Indirect_Rebate_Invoice_Line_Item%'
                    OR
                    RecordType.DeveloperName Like '%ASI_CRM_JP_SPTD_FOC_Invoice_Line_Item%')
                GROUP BY ASI_CRM_Payment_Invoice__c];
            
            List<ASI_CRM_Payment_Invoice__c> paymentInvoiceToUpdateList = new List<ASI_CRM_Payment_Invoice__c>();
            Set<ID> tempPaymentIdSet = paymentIdSet.clone();
            
            for(AggregateResult result : resultAggregateList){
                ASI_CRM_Payment_Invoice__c tempPayment = paymentInvoiceMap.get((ID)result.get('ASI_CRM_Payment_Invoice__c'));
                Integer apLineCount = tempPayment.Payment_Invoice_Lines__r != null ? tempPayment.Payment_Invoice_Lines__r.size() : 0;
                system.debug('Debug1 total amount: ' + (Decimal)result.get('totalLineAmount'));
                if(tempPayment.ASI_CRM_Total_Invoice_Amount__c != (Decimal)result.get('totalLineAmount') && (tempPayment.RecordType.DeveloperName.contains('ASI_CRM_JP_Indirect_Rebate_Invoice') || tempPayment.RecordType.DeveloperName.contains('ASI_CRM_JP_SPTD_FOC_Invoice'))) {
                    system.debug('Debug2 total amount: ' + (Decimal)result.get('totalLineAmount'));
                    tempPayment.ASI_CRM_Total_Invoice_Amount__c = (Decimal)result.get('totalLineAmount');
                    paymentInvoiceToUpdateList.add(tempPayment);
                }
                if(tempPayment.ASI_CRM_Rebate_Invoice_Amount__c != (Decimal)result.get('totalLineAmount') && tempPayment.RecordType.DeveloperName.contains('ASI_CRM_JP_Cash_Invoice')) {
                    tempPayment.ASI_CRM_Rebate_Invoice_Amount__c = (Decimal)result.get('totalLineAmount');
                    if(apLineCount == 0 && (Decimal)result.get('totalFinalAmount') == tempPayment.ASI_CRM_Total_Taxable_Amount__c){
                    tempPayment.ASI_CRM_Rebate_Invoice_Amount__c = tempPayment.ASI_CRM_Total_Invoice_Amount__c;    
                    }                             
                    paymentInvoiceToUpdateList.add(tempPayment);
                }
                tempPaymentIdSet.remove(tempPayment.id);
            }
            
            if(tempPaymentIdSet.size() > 0) {
                for(ID paymentID : tempPaymentIdSet) {
                    ASI_CRM_Payment_Invoice__c tempPayment = paymentInvoiceMap.get(paymentID);
                    if(tempPayment.ASI_CRM_Total_Invoice_Amount__c != null && tempPayment.RecordType.DeveloperName.contains('ASI_CRM_JP_Indirect_Rebate_Invoice') || tempPayment.RecordType.DeveloperName.contains('ASI_CRM_JP_SPTD_FOC_Invoice')) {
                        tempPayment.ASI_CRM_Total_Invoice_Amount__c = 0;
                        paymentInvoiceToUpdateList.add(tempPayment);
                    }
                    if(tempPayment.ASI_CRM_Rebate_Invoice_Amount__c != null && tempPayment.RecordType.DeveloperName.contains('ASI_CRM_JP_Cash_Invoice')) {
                        tempPayment.ASI_CRM_Rebate_Invoice_Amount__c= 0;
                        paymentInvoiceToUpdateList.add(tempPayment);
                    }
                }
            }
            
            if(paymentInvoiceToUpdateList.size() > 0) {
                update paymentInvoiceToUpdateList;
            }
            
        }
        
    }
}