public class ASI_MFM_CN_PaymentCashOutEmailCTRLLER {
    
    Public String headerId{Get; Set;}
    Public Boolean dummyVar{Get{ if(dummyVar != TRUE){ dummyVar = init(); } Return dummyVar; } Set;}
    
    Public List<ASI_MFM_VAT_Invoice__c> vatInvoice{Get; Set;}
    Public Boolean init(){
        
        vatInvoice = new List<ASI_MFM_VAT_Invoice__c>();
        
		vatInvoice = [SELECT Id
                      , Name
                      , ASI_MFM_Invoice_Amount__c
                      , ASI_MFM_PO_No__r.Name
                      , ASI_MFM_PO_No__r.ASI_MFM_Owner_Display__c
                      , AS_MFM_Invoice_Amount_Before_Tax__c
                      FROM ASI_MFM_VAT_Invoice__c
                      WHERE ASI_MFM_Payment_No__c = : headerId
                     ];
        
        Return TRUE;
    }
}