/**
* @author fabiosuenaga - topi
*/
@isTest
private  class LAT_ContractEventosRepositoryTest {

    @testSetup
    static void setup() { 
        Account distributor = LAT_EventFixtureFactory.createAccount();
    }

    @isTest
    static void findByContractIds() {
        Account distributor = [SELECT Id FROM Account WHERE CNPJ__c = '93536508000190' LIMIT 1];

        Test.startTest();

        LAT_Contract2__c contract = LAT_EventFixtureFactory.createContract('LAT_Eventos_Contrato_de_Parceria', distributor);
        LAT_Contract_Eventos__c contractEvent = new LAT_Contract_Eventos__c(LAT_Contract__c = contract.Id);
        insert contractEvent;

        List<LAT_Contract_Eventos__c> contractEvents = new LAT_ContractEventosRepository().findByContractIds(new List<String>{contract.Id});

        Test.stopTest();

        System.assert(!contractEvents.isEmpty());
    }

    @isTest
    static void findByIds() {
        Account distributor = [SELECT Id FROM Account WHERE CNPJ__c = '93536508000190' LIMIT 1];

        Test.startTest();

        LAT_Contract2__c contract = LAT_EventFixtureFactory.createContract('LAT_Eventos_Contrato_de_Parceria', distributor);
        LAT_Contract_Eventos__c contractEvent = new LAT_Contract_Eventos__c(LAT_Contract__c = contract.Id);
        insert contractEvent;

        List<LAT_Contract_Eventos__c> contractEvents = new LAT_ContractEventosRepository().findByIds(new List<String>{contractEvent.Id});

        Test.stopTest();

        System.assert(!contractEvents.isEmpty());
    }
}