/*
	Test Class for
	ASI_MFM_KR_PrepaymentChangeLog_PDF_Ctrl
*/
@isTest
public class ASI_MFM_KR_PrepaymentChangeLog_PDF_Test {

    static testMethod void testInit(){
    	 Account acc2 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Supplier'),Name='Name1');          
         insert acc2;
        
         ASI_MFM_Tax_Code__c TaxCode = new ASI_MFM_Tax_Code__c (Name = 'JA11',
                                                                   recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Tax_Code__cASI_MFM_KR_Tax_Code'),
                                                                   ASI_MFM_VAT_Rate__c = 100,
                                                               	   ASI_MFM_Tax_Expl_Code__c = 'E');
         insert TaxCode;  
        
		 ASI_MFM_Payment__c PaymentHeader = new ASI_MFM_Payment__c (ASI_MFM_Status__c = 'Submitted',
                                                                       recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_KR_Payment'),
                                                                       ASI_MFM_Supplier_Name__c = acc2.id,
                                                                       ASI_MFM_Company_Code__c = '222',
                                                                       ASI_MFM_Send_Approval_Email__c=true,
                                                                       ASI_MFM_Is_Direct_Payment__c = false,
                                                                       ASI_MFM_Pre_payment__c = true,
                                                                       ASI_MFM_Tax_Code__c = TaxCode.id,
                                                                       ASI_MFM_Invoice_Number__c = 'OLD INVOICE NUMBER');  
            
        insert PaymentHeader;        
        
            
        ASI_MFM_Prepayment_Proposal_Change_Log__c pcr = new ASI_MFM_Prepayment_Proposal_Change_Log__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Prepayment_Proposal_Change_Log__cASI_MFM_KR_Prepayment_Proposal_Change_Log'),
                                                           ASI_MFM_Payment__c = PaymentHeader.id);
        
        insert pcr;
        
        ASI_MFM_KR_PrepaymentChangeLog_PDF_Ctrl con = new ASI_MFM_KR_PrepaymentChangeLog_PDF_Ctrl();
        con.header = pcr;
        con.headerId = pcr.id;
        con.init();
        
    }
}