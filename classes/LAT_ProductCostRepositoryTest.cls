/**
* @author fabiosuenaga - topi
*/
@isTest
private class LAT_ProductCostRepositoryTest {

	@testSetup
    static void setup() { 
        Account distributor = LAT_EventFixtureFactory.createAccount();
    }

    @isTest
    static void findNotExpiredByProductAN8AndRecordType() {
        Account distributor = [SELECT Id FROM Account WHERE CNPJ__c = '93536508000190' LIMIT 1];

        Test.startTest();

        LAT_Contract2__c contract = LAT_EventFixtureFactory.createContract('LAT_Eventos_Contrato_de_Parceria', distributor);

        LAT_ReferenceProductGrouping__c productGrouping = [SELECT Id FROM LAT_ReferenceProductGrouping__c LIMIT 1];

        List<LAT_ProductCost__c> productCosts = new LAT_ProductCostRepository().findNotExpiredByProductAN8AndRecordType(new List<Id>{productGrouping.Id}, new List<Id>{distributor.Id}, new List<String>{'LAT_ProductPayment'});

        Test.stopTest();

        System.assert(!productCosts.isEmpty());
    }
}