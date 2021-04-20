/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 09/11/2016
*
********************************************************************************/

@isTest
private class LAT_BR_VFC15_CotasReportControllerTest {
	
	@isTest static void test_method_one() {
		LAT_CotaMarket__c cm = BasicData();

        Test.startTest();
    		LAT_BR_VFC15_CotasReportController crc = new LAT_BR_VFC15_CotasReportController();
    		crc.refreshLists();
    		
    		crc.dummyLookup.cotaMarket__c = cm.id;
    		crc.refreshLists();
        Test.stopTest();

	}

	static LAT_CotaMarket__c BasicData() {
        Utils.setMigrationDoneTest(false);
        Product2 lProd = LAT_Cota_Test.getProduct();
        insert lProd;
        
        LAT_CotaMarket__c cota = LAT_Cota_Test.getCota(lProd.id);
        insert cota;

        LAT_DetalheCotaMarket__c detalhe = LAT_Cota_Test.getDetalheCota(cota.id);
        insert detalhe;

        //Cria novo Account.      
        Account Acc = LAT_Account_TestFactory.getAccountOffTradeBraComplete();
        acc.Sub_Channel__c = 'Atacadista';
        insert Acc;

        PricebookEntry entradaCatalogoPreco = LAT_Cota_Test.getPriceBookEntry(lprod.Id);   
        insert entradaCatalogoPreco;   
        
        Opportunity opp = LAT_Cota_Test.getOppty(acc.id);
        insert opp;
        
        //Cria um novo produto da oportunidade.      
        OpportunityLineItem Oppl = LAT_Cota_Test.getOpptyLine(entradaCatalogoPreco.Id, Opp.Id);
        Oppl.Quantity = 15;
        Oppl.Descricao_do_status__c = 'Test';
        insert Oppl;
        
        Lat_Cota.consumeReturn(new List<OpportunityLineItem>{Oppl});

        return cota;
    }


    static LAT_CotaMarket__c BasicData2() {
        Utils.setMigrationDoneTest(true);
        LAT_Product__c lProd = LAT_Cota_Test.LAT_getProduct();
        insert lProd;
        
        LAT_CotaMarket__c cota = LAT_Cota_Test.getCota(lProd.id);
        insert cota;

        LAT_DetalheCotaMarket__c detalhe = LAT_Cota_Test.getDetalheCota(cota.id);
        insert detalhe;

        //Cria novo Account.      
        Account Acc = LAT_Account_TestFactory.getAccountOffTradeBraComplete();
        acc.Sub_Channel__c = 'Atacadista';
        insert Acc;

        
        LAT_Opportunity__c opp = LAT_Cota_Test.LAT_getOppty(acc.id);
        insert opp;
        
        //Cria um novo produto da oportunidade.      
        LAT_OpportunityLineItem__c Oppl = LAT_Cota_Test.LAT_getOpptyLine(lProd.Id, Opp.Id);
        Oppl.LAT_Quantity__c = 15;
        Oppl.LAT_StatusDescription__c = 'Test';
        insert Oppl;
        
        Lat_Cota.consumeReturn(new List<LAT_OpportunityLineItem__c>{Oppl});

        return cota;
    }
	
}