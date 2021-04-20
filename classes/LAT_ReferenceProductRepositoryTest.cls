/**
* @author fabiosuenaga - topi
*/
@isTest
private class LAT_ReferenceProductRepositoryTest {

    @testSetup
    static void setup() { 
        Account distributor = LAT_EventFixtureFactory.createAccount();
    }

    @isTest
    static void findByReferenceGrouping() {
        Account distributor = [SELECT Id FROM Account WHERE CNPJ__c = '93536508000190' LIMIT 1];
        LAT_Contract2__c contract = LAT_EventFixtureFactory.createContract('LAT_Eventos_Contrato_de_Parceria', distributor);

        LAT_ReferenceProductGrouping__c referenceProductGrouping = [SELECT Id FROM LAT_ReferenceProductGrouping__c LIMIT 1]; 

        Test.startTest();

        List<LAT_ReferenceProduct__c> referenceProducts = new LAT_ReferenceProductRepository().findByReferenceGrouping(new List<Id>{referenceProductGrouping.Id});
        
        Test.stopTest();

        System.assert(!referenceProducts.isEmpty());      
    }
}