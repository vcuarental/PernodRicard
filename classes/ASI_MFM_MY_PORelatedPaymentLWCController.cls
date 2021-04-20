public with sharing class ASI_MFM_MY_PORelatedPaymentLWCController {
    public class interimData {
        @AuraEnabled
        public ASI_MFM_Payment__c py { get; set; }

        @AuraEnabled
        public Decimal amount { get; set; }
    }

    @AuraEnabled
    public static List<interimData> getPayment(String poID)
    {
        Set<ID>paymentIDSet = new Set<ID>();
        List<ASI_MFM_Payment_Line_Item__c> paymentlineItem = [Select ASI_MFM_Payment__c,ASI_MFM_Payment_Amount__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c, ASI_MFM_Payment__r.id from ASI_MFM_Payment_Line_Item__c where ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c = :poID];
            
        for (ASI_MFM_Payment_Line_Item__c paymentLine : paymentlineItem)
        {
            paymentIDSet.add(paymentLine.ASI_MFM_Payment__c);
        }
        
        List<ASI_MFM_Payment__c> payments = [select id, Name, ASI_MFM_Status__c, ASI_MFM_Currency__c, Owner.Name, ASI_MFM_Supplier_Name__r.Name, ASI_MFM_Payment_Amount__c from ASI_MFM_Payment__c where id = :paymentIDSet];
        //this will display in page
        List<interimData> result = new List<interimData>();
        
        for (ASI_MFM_Payment__c pay : payments)
        {
            interimData temp = new interimData();
            temp.py = pay;
            temp.amount = 0;
            
            for (ASI_MFM_Payment_Line_Item__c pyl : paymentlineItem)
            {
                if (pyl.ASI_MFM_Payment__c == pay.id)
                {
                    temp.amount = temp.amount + pyl.ASI_MFM_Payment_Amount__c;
                }
            }

            result.add(temp);
        }

        return result;
    }
}