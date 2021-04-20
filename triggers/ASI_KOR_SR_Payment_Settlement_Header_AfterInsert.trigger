trigger ASI_KOR_SR_Payment_Settlement_Header_AfterInsert on ASI_KOR_SR_Payment_Settlement_Header__c (after insert) {

    for(ASI_KOR_SR_Payment_Settlement_Header__c paymentSettlementHeader : Trigger.new){ 

        List<ASI_KOR_SR_Payment_Settlement_Detail__c> existingPaymentDetails = [
    select id from ASI_KOR_SR_Payment_Settlement_Detail__c
    where ASI_KOR_SR_Payment_Settlement__c =: paymentSettlementHeader.id];
    
    if (existingPaymentDetails == null || existingPaymentDetails.size() <=0)
{
        if (!Test.isRunningTest())
        {
        ASI_KOR_SRPaymentSettlementExtension.createSRPaymentSettlementDetails(paymentSettlementHeader);
        }
        }
        
        
    }

}