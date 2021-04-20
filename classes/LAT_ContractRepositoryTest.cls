/**
* @author fabiosuenaga - topi
*/
@isTest
private class LAT_ContractRepositoryTest {
    
    @testSetup
    static void setup() { 
        Account distributor = LAT_EventFixtureFactory.createAccount();
    }

    @isTest
    static void findByIds() {
        Account distributor = [SELECT Id FROM Account WHERE CNPJ__c = '93536508000190' LIMIT 1];
        LAT_Contract2__c contract = LAT_EventFixtureFactory.createContract('LAT_Eventos_Contrato_de_Parceria', distributor);

        Test.startTest();

        List<LAT_Contract2__c> contracts = new LAT_ContractRepository().findByIds(new List<Id>{contract.Id});
        contract = contracts.get(0);
        
        Test.stopTest();

        System.assert(!contracts.isEmpty());        
    }
}