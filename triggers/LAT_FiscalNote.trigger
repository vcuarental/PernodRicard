trigger LAT_FiscalNote on LAT_FiscalNote__c (before insert, before update, before delete, after insert, after update) {

		if (Trigger.isBefore) {
			for(LAT_FiscalNote__c fn : trigger.new) {
				if(fn.LAT_Balance__c != null) {
					if(fn.LAT_Balance__c == 0) {
						fn.LAT_AR_B2B_Status__c = 'Paga';
					} else {
						if(fn.LAT_AR_B2B_Status__c != 'Pago Informado') {
							fn.LAT_AR_B2B_Status__c = 'A pagar';
						}
					}
				}
			}
	    	
	    
		} else if (Trigger.isAfter) {
			if(Trigger.isInsert){
				for(LAT_FiscalNote__c fn : trigger.new) {
					if(fn.LAT_B2B_Estado_Calico__c == 'EN DESPACHO'){
						LAT_CTY_B2B_OrderController.sendOpportunityDispachedEmail(fn.Id);
					}
				}
				
			}
			if(Trigger.isUpdate){
				for(LAT_FiscalNote__c fn : trigger.new) {
					if(fn.LAT_B2B_Estado_Calico__c == 'EN DESPACHO' && trigger.oldMap.get(fn.Id).LAT_B2B_Estado_Calico__c != 'EN DESPACHO'){
						LAT_CTY_B2B_OrderController.sendOpportunityDispachedEmail(fn.Id);
					}
				}
			}
	    	
	    
		}
}