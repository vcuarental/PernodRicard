global class LAT_AR_StockCheckBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
	
	String query;
	String errores;
	Integer cant;
	
	global LAT_AR_StockCheckBatch() {
		
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		query = 'SELECT Id, LAT_Sku__c FROM LAT_Product__c WHERE LAT_IsRefactorProduct__c = \'Y\' AND LAT_IsActive__c = true AND LAT_ExternalID__c LIKE \'6-%\'';
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		errores 	= '';
   		cant 		= 0;
   		List<LAT_Product__c> prods = (List<LAT_Product__c>)scope;

   		String units = LAT_GeneralConfig__c.getInstance('AR_StockBusinessUnits').LAT_Value__c;
   		List<String> businesUnits = units.split(',');
   		List<LAT_Stock__c> toUpsert = new List<LAT_Stock__c>();
   		for(String businessUnit : businesUnits) {
   			List<LAT_Stock__c> res = LAT_StockAvailabilityInterface.getStockBatch('Argentina', businessUnit, 'BT', prods);
   			if (res != null) {
   				if (res.size() > 0) {
   					toUpsert.addAll(res);
   				}
   			} else {
   				errores += '\nError al procesar el Batch para la Business Unit ' + businessUnit + '.' ;
   				cant ++;
   			}
   		}	
		
		if (toUpsert.size() > 0) {
			upsert toUpsert LAT_ExternalID__c;
		}
	}
	
	global void finish(Database.BatchableContext BC) {
		System.debug('Terminamos de Ejecutar el check de Stock para Argentina. Hubo ' + cant + ' errores. \n' + errores);
	}
	
}