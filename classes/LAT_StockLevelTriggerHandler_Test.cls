/*******************************************************************************
*   Company: Zimmic   Developer : Nicolás Marán    Fecha: 13/5/2016            \  
*------------------------------------------------------------------------------/
*   Clase utilizada para test de LAT_StockLevelTriggerHandler                  \
*******************************************************************************/


@isTest
private class LAT_StockLevelTriggerHandler_Test {
	
	//Test for Insert 
	@isTest static void updateLatStockLevelInsertTestOk() {
		Test.startTest();

			Lat_Stock__c s = createLatStock(60,20);
			System.assertEquals(true,checkIfExistStock());

		Test.stopTest();
	}

	@isTest static void updateLatStockLevelInsertTestLow() {
		Test.startTest();		
		
			LAT_Stock__c s = createLatStock(20,40);
			System.assertEquals(true,checkIfExistStock());

		Test.stopTest();
	}

	@isTest static void updateLatStockLevelInsertTestNoStock() {
		Test.startTest();
		
			LAT_Stock__c s = createLatStock(0,40);
			System.assertEquals(true,checkIfExistStock());

		Test.stopTest();
	}

	@isTest static void updateLatStockLevelInsertTestUnknown() {
		Test.startTest();
		
			LAT_Stock__c s = createLatStock(5,null);
			System.assertEquals(true,checkIfExistStock());

		Test.stopTest();
	}

//Test for Update 
	@isTest static void updateLatStockLevelUpdateLow() {
		Test.startTest();

			LAT_Stock__c s = createLatStock(70,40);
			updateStock(s,50,80);

			System.assertEquals(stockLevel(),'Low');

		Test.stopTest();
	}
	@isTest static void updateLatStockLevelUpdateUnknown() {
		Test.startTest();

			LAT_Stock__c s = createLatStock(60,40);
			updateStock(s,60,null);
			System.assertEquals(stockLevel(),'Unknown');

		Test.stopTest();
	}

	@isTest static void updateLatStockLevelUpdateOk() {
		Test.startTest();

			LAT_Stock__c s = createLatStock(70,40);
			updateStock(s,80,40);
			System.assertEquals(stockLevel(),'Ok');

		Test.stopTest();
	}
	@isTest static void updateLatStockLevelUpdateNoStock() {
		Test.startTest();

			LAT_Stock__c s = createLatStock(70,40);
			updateStock(s,0,40);
			System.assertEquals(stockLevel(),'No Stock');
	
		Test.stopTest();
	}

//crea un LAT_Stock__c
	private static LAT_Stock__c createLatStock(Integer stock, Integer safety) {
		LAT_Stock__c stockOld = new LAT_Stock__c();
		stockOld.name = 'Abc'; 
		stockOld.Lat_stock__c = stock;
		stockOld.LAT_Safety_Stock__c = safety;

		insert stockOld;
		return stockOld;
	}

// update de un LAT_Stock__c
	private static void updateStock(LAT_Stock__c s, Integer stock , Integer safety){
		s.LAT_Stock__c = stock;
		s.LAT_Safety_Stock__c = safety;

		update s;
	}
	
// devuelve true si existe un lat_Stock__c
	private static boolean checkIfExistStock() {
		List<Lat_stock__c> stockList = [SELECT ID from LAT_Stock__c];

		return (stockList != null && stockList.size() > 0);
	}

// pregunta el nivel de 1 lat_Stock
	private static String stockLevel() {
		List<Lat_stock__c> stockList = [SELECT ID,Lat_StockLevel__c from LAT_Stock__c];

		return stockList.get(0).Lat_StockLevel__c;
	}
	
}