trigger LAT_Invoice on LAT_Invoice__c (before update, after update, before insert, after insert, before delete) {
	
	if (trigger.isUpdate) {
		
		if (trigger.isAfter) {
			List<LAT_Invoice__c> changedInvoices = new List<LAT_Invoice__c>();
			for(LAT_Invoice__c inv : Trigger.newMap.values()) {
  				if( Trigger.oldMap.get(inv.Id).LAT_ID_JDE_Invoice__c != Trigger.newMap.get( inv.Id ).LAT_ID_JDE_Invoice__c ) {
  					changedInvoices.add(inv);
  				}	
			}
			if (changedInvoices.size() > 0) {
				List<RCP_Receipt_ARG__c> toUpdate = new List<RCP_Receipt_ARG__c>();
				Set<Id> receiptIds = new Set<Id>();
				for (LAT_Invoice__c inv : changedInvoices) {
					receiptIds.add(inv.LAT_Receipt__c);
				}
				Map<Id, RCP_Receipt_ARG__c> mapReceipts = new Map<Id, RCP_Receipt_ARG__c>([SELECT id, Comercial_Discount_ID_JDE__c, Financial_Discount_ID_JDE__c, ID_JDE_Downpayments__c 
														FROM RCP_Receipt_ARG__c WHERE Id IN :receiptIds FOR UPDATE]);
				for (LAT_Invoice__c inv : changedInvoices) {
					RCP_Receipt_ARG__c rec = mapReceipts.get(inv.LAT_Receipt__c);
					if (rec != null) {
						if (inv.LAT_InvoiceType__c == 'AT') {
							rec.ID_JDE_Downpayments__c 	= inv.LAT_ID_JDE_Invoice__c;
						} 
						else if (inv.LAT_InvoiceType__c == 'DF') {
							rec.Financial_Discount_ID_JDE__c = inv.LAT_ID_JDE_Invoice__c;
						} 
						else if (inv.LAT_InvoiceType__c == 'DC') {
							rec.Comercial_Discount_ID_JDE__c = inv.LAT_ID_JDE_Invoice__c;
						}
						toUpdate.add(rec); 
					}
				}
				if (toUpdate.size() > 0) {
					update toUpdate;
				}
			}

		}

	}
}