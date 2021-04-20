/**
* @author fabiosuenaga - topi
*/
@isTest
private class LAT_UnitConversionRatesRepositoryTest {

	@testSetup
    static void setup() { 
        Account distributor = LAT_EventFixtureFactory.createAccount();
    }

    @isTest
    static void findByKeyUnica() {
        Account distributor = [SELECT Id FROM Account WHERE CNPJ__c = '93536508000190' LIMIT 1];

        Test.startTest();

        LAT_Contract2__c contract = LAT_EventFixtureFactory.createContract('LAT_Eventos_Contrato_de_Parceria', distributor);
        LAT_Product__c product = [SELECT Id FROM LAT_Product__c LIMIT 1];
        LAT_UnitConversionRates__c unitConversionRate = LAT_EventFixtureFactory.createUnitConversionRate(product);

        List<LAT_UnitConversionRates__c> unitConversionRates = new LAT_UnitConversionRatesRepository().findByKeyUnica(new List<String>{'1-123-CA-BT'}); 
        
        Test.stopTest();

        System.assert(!unitConversionRates.isEmpty());        
    }    
}