public class ASI_MFM_GF_PORelatedPaymentsController {
    public List<ASI_MFM_Payment__c> payments {get; set;}
    
    public ASI_MFM_GF_PORelatedPaymentsController(ApexPages.StandardController controller){
    
        Set<ID>paymentIDSet = new Set<ID>();  
        
        ASI_MFM_PO__c po = (ASI_MFM_PO__c) controller.getRecord();
        
        for (ASI_MFM_Payment_Line_Item__c paymentLine : [Select ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c, ASI_MFM_Payment__r.id from ASI_MFM_Payment_Line_Item__c where ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c = :po.Id]){
            paymentIDSet.add(paymentLine.ASI_MFM_Payment__c);
        }
        
        payments = [select Name, ASI_MFM_Status__c, ASI_MFM_Currency__c, Owner.Name, ASI_MFM_Supplier_Name__r.Name, ASI_MFM_Payment_Amount__c, ASI_MFM_Invoice_Number__c, ASI_MFM_Invoice_Date__c
            from ASI_MFM_Payment__c where id = :paymentIDSet];
    }
}