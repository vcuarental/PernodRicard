/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 17/11/2016
*
********************************************************************************/

@isTest
private class LAT_BR_Cotas_Notifications_Test {
	
	@isTest 
	static void testNotifications() {
        Utils.setMigrationDoneTest(false);
		Product2 lProd = getProduct();
        insert lProd;
        
        
        //Cria novo Account.      
        Account Acc = LAT_Account_TestFactory.getAccountOffTradeBraComplete();
        insert Acc;
        
        LAT_CotaMarket__c cota = getCota(lProd.id);
        insert cota;
        
        LAT_DetalheCotaMarket__c detalheCota = getDetalheCota(cota.id);
        detalheCota.cliente__c = acc.id;
        insert detalheCota;

		SchedulableContext sc = null;
		LAT_BR_Cotas_Notifications tsc = new LAT_BR_Cotas_Notifications();
		tsc.execute(sc);
	}
    //MIGRATED 21/11/2016
    @isTest 
    static void testNotificationsB() {
        Utils.setMigrationDoneTest(true);
        LAT_Product__c lProd = LAT_getProduct();
        insert lProd;
        
        
        //Cria novo Account.      
        Account Acc = LAT_Account_TestFactory.getAccountOffTradeBraComplete();
        insert Acc;
        
        LAT_CotaMarket__c cota = LAT_getCota(lProd.id);
        insert cota;
        
        LAT_DetalheCotaMarket__c detalheCota = getDetalheCota(cota.id);
        detalheCota.cliente__c = acc.id;
        insert detalheCota;

        SchedulableContext sc = null;
        LAT_BR_Cotas_Notifications tsc = new LAT_BR_Cotas_Notifications();
        tsc.execute(sc);
    }

	@isTest 
	static void testConsumeNotifications() {
        Utils.setMigrationDoneTest(false);
		Product2 lProd = getProduct();
        insert lProd;
        
        
        //Cria novo Account.      
        Account Acc = LAT_Account_TestFactory.getAccountOffTradeBraComplete();
        insert Acc;
        
        LAT_CotaMarket__c cota = getCota(lProd.id);
        insert cota;
        
        LAT_DetalheCotaMarket__c detalheCota = getDetalheCota(cota.id);
        detalheCota.cliente__c = acc.id;
        detalheCota.consumo__c = 100;
        insert detalheCota;

        detalheCota.dateConsumida__c = Date.today()- 1;
        update detalheCota;
        
		SchedulableContext sc = null;
		LAT_BR_Cotas_Notifications tsc = new LAT_BR_Cotas_Notifications();
		tsc.execute(sc);
	}
    //MIGRATED 21/11/2016
    @isTest 
    static void testConsumeNotificationsB() {
        Utils.setMigrationDoneTest(true);
        LAT_Product__c lProd = LAT_getProduct();
        insert lProd;
        
        
        //Cria novo Account.      
        Account Acc = LAT_Account_TestFactory.getAccountOffTradeBraComplete();
        insert Acc;
        
        LAT_CotaMarket__c cota = LAT_getCota(lProd.id);
        insert cota;
        
        LAT_DetalheCotaMarket__c detalheCota = getDetalheCota(cota.id);
        detalheCota.cliente__c = acc.id;
        detalheCota.consumo__c = 100;
        insert detalheCota;

        detalheCota.dateConsumida__c = Date.today()- 1;
        update detalheCota;
        
        SchedulableContext sc = null;
        LAT_BR_Cotas_Notifications tsc = new LAT_BR_Cotas_Notifications();
        tsc.execute(sc);
    }




	public static LAT_CotaMarket__c getCota(String prodID){
        LAT_CotaMarket__c cota = new LAT_CotaMarket__c();
        cota.totalCota__c = 100;
        cota.sku__c = prodID;
        cota.startDate__c = Date.today();
        cota.endDate__c = Date.today() + 4;
        return cota;
    }
    //MIGRATED 21/11/2016
    public static LAT_CotaMarket__c LAT_getCota(String prodID){
        LAT_CotaMarket__c cota = new LAT_CotaMarket__c();
        cota.totalCota__c = 100;
        cota.LAT_Product__c = prodID;
        cota.startDate__c = Date.today();
        cota.endDate__c = Date.today() + 4;
        return cota;
    }

    public static LAT_DetalheCotaMarket__c getDetalheCota(String cotaId){
        LAT_DetalheCotaMarket__c detalheCota = new LAT_DetalheCotaMarket__c();
        detalheCota.cotaMarket__c = cotaId;
        detalheCota.cotaMarket__c = cotaId;
        detalheCota.startDate__c = Date.today();
        detalheCota.endDate__c = Date.today() + 3;
        detalheCota.cota__c = 90;
        return detalheCota;
    }

    public static Product2 getProduct(){
        Product2 lProd = new Product2();
        lProd.Name = 'Cachaca';
        lProd.Internal_id__c = '1234569';
        return lProd;
    }
    //MIGRATED 21/11/2016
   public static LAT_Product__c LAT_getProduct(){
        LAT_Product__c lProd = new LAT_Product__c();
        lProd.Name = 'Cachaca';
        lProd.LAT_ExternalId__c = '1234569';
        return lProd;
    }
	
	
	
}