public class ASI_MFM_MKTEXP_PORelatedPaymentsCtrl {
	public class OPayment {
        public ID id { get; set; }
        public String name { get; set; }
        public Decimal invoiceAmount { get; set; }
        public String invoiceNo { get; set; }
        public Date invoiceDate { get; set; }
        public Date paymentDate { get; set; }
        public Decimal paymentAmount { get; set; }
        public String status { get; set; }
        public String curr { get; set; }
        public String owner { get; set; }
        public ID ownerID { get; set; }
        public String supplier { get; set; }
        public ID supplierID { get; set; }
        public String jdeDocType { get; set; }
        public String jdeDocCompany { get; set; }
        public String jdeDocNumber { get; set; }
        public String creditNote {get; set;}
    }
	public List<OPayment> payments {get; set;}
    
    public ASI_MFM_MKTEXP_PORelatedPaymentsCtrl(ApexPages.StandardController controller){
    
        Set<ID>paymentIDSet = new Set<ID>();
        payments = new List<OPayment>();
        
        ASI_MFM_PO__c po = (ASI_MFM_PO__c) controller.getRecord();
		List<ASI_MFM_Payment_Line_Item__c> paymentLines = new List<ASI_MFM_Payment_Line_Item__c>();
        
        for (ASI_MFM_Payment_Line_Item__c paymentLine : [
            Select ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c, ASI_MFM_Payment__r.id, ASI_MFM_Payment_Amount__c 
            from ASI_MFM_Payment_Line_Item__c where ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c = :po.Id]){
            paymentIDSet.add(paymentLine.ASI_MFM_Payment__c);
			paymentLines.add(paymentLine);
        }
        
        for (ASI_MFM_Payment__c payment : [
			select Id, Name, ASI_MFM_MKTEXP_Invoice_Amount__c, ASI_MFM_Status__c, 
            ASI_MFM_Currency__c, OwnerID, Owner.Name, ASI_MFM_Supplier_Name__c, ASI_MFM_Supplier_Name__r.Name, 
            ASI_MFM_Payment_Amount__c, ASI_MFM_Invoice_Number__c, ASI_MFM_Invoice_Date__c,
            ASI_MFM_PO_1__c, ASI_MFM_PO_2__c, ASI_MFM_PO_3__c, ASI_MFM_PO_4__c, ASI_MFM_PO_5__c,
            ASI_MFM_PaymentDate__c, ASI_MFM_JDE_Document_Type__c, ASI_MFM_JDE_Document_Company__c, ASI_MFM_JDE_Document_Number__c,
            ASI_MFM_Credit_Note__c
            from ASI_MFM_Payment__c
            where (id = :paymentIDSet 
                    or (ASI_MFM_Status__c = 'Draft' 
                        and (ASI_MFM_PO_1__c = :po.ID 
                            or ASI_MFM_PO_2__c = :po.ID
                            or ASI_MFM_PO_3__c = :po.ID
                            or ASI_MFM_PO_4__c = :po.ID
                            or ASI_MFM_PO_5__c = :po.ID)))
            and ASI_MFM_Prepayment__c = FALSE
		])
        {
            OPayment newPay = new OPayment();
            newPay.id = payment.Id;
            newPay.name = payment.Name;
            newPay.invoiceAmount = payment.ASI_MFM_MKTEXP_Invoice_Amount__c;
            newPay.invoiceDate = payment.ASI_MFM_Invoice_Date__c;
            newPay.paymentDate = payment.ASI_MFM_PaymentDate__c;
            newPay.invoiceNo = payment.ASI_MFM_Invoice_Number__c;
            newPay.paymentAmount = 0;
            newPay.status = payment.ASI_MFM_Status__c;
            newPay.curr = payment.ASI_MFM_Currency__c;
            newPay.owner = payment.Owner.Name;
            newPay.ownerID = payment.OwnerID;
            newPay.supplier = payment.ASI_MFM_Supplier_Name__r.Name;
            newPay.supplierID = payment.ASI_MFM_Supplier_Name__c;
            newPay.jdeDocType = payment.ASI_MFM_JDE_Document_Type__c;
            newPay.jdeDocCompany = payment.ASI_MFM_JDE_Document_Company__c;
            newPay.jdeDocNumber = payment.ASI_MFM_JDE_Document_Number__c;
            newPay.creditNote = payment.ASI_MFM_Credit_Note__c ? 'Y' : '';

            for (Integer i = 1; i <= 5; i++)
			{
				if (payment.get('ASI_MFM_PO_' + i + '__c') != null)
				{
					ID poID = (ID)(payment.get('ASI_MFM_PO_' + i + '__c'));

                    if (poID == po.ID)
                    {
                        for (ASI_MFM_Payment_Line_Item__c paymentLine : paymentLines)
                        {
                            if (paymentLine.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c == poID
                                && paymentLine.ASI_MFM_Payment__r.id == payment.Id
                                && paymentLine.ASI_MFM_Payment_Amount__c != null)
                            {
                                newPay.paymentAmount += paymentLine.ASI_MFM_Payment_Amount__c;
                            }
                        }

                        break;
                    }
				}
			}

            payments.add(newPay);
        }
    }
}