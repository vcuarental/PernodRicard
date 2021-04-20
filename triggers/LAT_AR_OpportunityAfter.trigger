trigger LAT_AR_OpportunityAfter on Opportunity (after insert) {

	for (Opportunity opp : trigger.new) {
    	if  (WS03_SalesOrderHandlerInterface_AR.isProcessing == null) {
    		WS03_SalesOrderHandlerInterface_AR.isProcessing = false;
    	}
        if (!WS03_SalesOrderHandlerInterface_AR.isProcessing &&
             opp.StageName == 'Mobile Order' && (opp.Pais__c == 5 || opp.Pais__c == 6)) {
            WS03_SalesOrderHandlerInterface_AR.SalesOrderInterfaceFuture(opp.Id);
            WS03_SalesOrderHandlerInterface_AR.isProcessing = true;
        }
    }

}