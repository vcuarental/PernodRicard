global class LAT_AR_UpdateOpportunityDiscountBatch implements Database.Batchable<sObject> {
	
	String query;
	Set<String> oppRecordTypes;
	Set<String> LAT_oppRecordTypes;
	
	global LAT_AR_UpdateOpportunityDiscountBatch(Set<String> oldRT, Set<String> newRT) {
		query = 'SELECT id, opportunity.NR_order_JDE__c, Sku__c, Discount_AR__c FROM Opportunitylineitem WHERE Opportunity.RecordTypeId IN :oppRecordTypes AND Discount_AR__c > 0';
		oppRecordTypes = oldRT;
		LAT_oppRecordTypes = newRT;
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		List<Opportunitylineitem> listoppli = scope;
		Map<String, Opportunitylineitem> mapoppli = new Map<String, Opportunitylineitem>();
		Set<String> numjde = new Set<String>();
		
		for (Opportunitylineitem oppli : listoppli) {
		    mapoppli.put(oppli.Opportunity.NR_order_JDE__c  + '' + oppli.Sku__c, oppli);
		    numjde.add(oppli.Opportunity.NR_order_JDE__c);
		}

		List<LAT_OpportunityLineItem__c> listlatoppli = [SELECT id, LAT_Opportunity__r.LAT_NROrderJDE__c, LAT_Sku__c, LAT_AR_Discount__c, LAT_AR_MaxDiscount__c FROM LAT_OpportunityLineItem__c WHERE 
		 LAT_Opportunity__r.LAT_CloseDate__c < 2017-02-01 AND LAT_Opportunity__r.RecordTypeId IN : LAT_oppRecordTypes AND LAT_Opportunity__r.LAT_NROrderJDE__c IN :numjde];
		Map<String, LAT_OpportunityLineItem__c> maplatoppli = new Map<String, LAT_OpportunityLineItem__c>();
		for (LAT_OpportunityLineItem__c latoppli : listlatoppli) {
		    maplatoppli.put(latoppli.LAT_Opportunity__r.LAT_NROrderJDE__c  + '' +  latoppli.LAT_Sku__c, latoppli);
		}

		List<LAT_OpportunityLineItem__c> listtoupdate = new List<LAT_OpportunityLineItem__c>();
		for (Opportunitylineitem oppli : mapoppli.values()) {
		    if (oppli.Discount_AR__c > 0 && maplatoppli.get(oppli.Opportunity.NR_order_JDE__c + '' + oppli.sku__c) != null) {
		        maplatoppli.get(oppli.Opportunity.NR_order_JDE__c + '' + oppli.sku__c).LAT_AR_Discount__c = oppli.Discount_AR__c;
		        listtoupdate.add(maplatoppli.get(oppli.Opportunity.NR_order_JDE__c + '' + oppli.sku__c));
		    
		        system.debug('opp original : ' + oppli.opportunityid + '  sku: ' + oppli.sku__c);
		        system.debug('opp lat : ' + maplatoppli.get(oppli.Opportunity.NR_order_JDE__c + '' + oppli.sku__c).id + '  sku: ' + maplatoppli.get(oppli.Opportunity.NR_order_JDE__c + '' + oppli.sku__c).LAT_sku__c);
		    }
		}
		if (listtoupdate.size() > 0) {
			update listtoupdate; 
		}
		
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}