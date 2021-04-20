/**
* @author fabiosuenaga - topi
*/
@isTest
private class LAT_ProductCostFilterTest {

    @testSetup
    static void setup() { 
        Account distributor = LAT_EventFixtureFactory.createAccount();
    }

    @isTest
    static void productCostUsingAn8AndProduct() {
        Account distributor = [SELECT Id FROM Account WHERE CNPJ__c = '93536508000190' LIMIT 1];

        Test.startTest();

        LAT_Contract2__c contract = LAT_EventFixtureFactory.createContract('LAT_Eventos_Contrato_de_Parceria', distributor);
        LAT_Product__c product = [SELECT Id FROM LAT_Product__c LIMIT 1];
        LAT_UnitConversionRates__c unitConversionRate = LAT_EventFixtureFactory.createUnitConversionRate(product);

        LAT_Contract_Eventos__c contractEvent = LAT_EventFixtureFactory.createEvent(contract);

        LAT_ReferenceProductGrouping__c productGrouping = [SELECT Id FROM LAT_ReferenceProductGrouping__c LIMIT 1];

        List<LAT_ProductCost__c> productCosts = new LAT_ProductCostRepository().findNotExpiredByProductAN8AndRecordType(new List<Id>{productGrouping.Id}, new List<Id>{distributor.Id}, new List<String>{'LAT_ProductPayment'});

        LAT_EventVolume__c eventVolume = LAT_EventFixtureFactory.createEventVolume(contractEvent, productGrouping);
        List<LAT_EventVolume__c> eventVolumes = [SELECT LAT_ContractEvent__r.LAT_Contract__r.LAT_Distributor__c,LAT_ContractEvent__r.LAT_Contract__r.LAT_Distributor__r.Name, LAT_ContractEvent__r.LAT_Contract__r.Account__c, LAT_ProductGroup__r.Name, CreatedById,CreatedDate,CurrencyIsoCode,Finality__c,Id,IsDeleted,LastActivityDate,LastModifiedById,LastModifiedDate,LAT_BonusPercent__c,LAT_BonusQuantity__c,LAT_BoxesContractMonth__c,LAT_BoxesContract__c,LAT_BusinessCondition__c,LAT_ContractEvent__c,LAT_EstimatedBoxesContract__c,LAT_ProductGroup__c,LAT_Volume__c,Name FROM LAT_EventVolume__c WHERE Id =: eventVolume.Id];
        Set<LAT_EventVolume__c> allEventVolumes = new Set<LAT_EventVolume__c>(eventVolumes);

        List<LAT_ProductCost__c> productCostsFiltered = LAT_ProductCostFilter.productCostUsingAn8AndProduct(allEventVolumes, productCosts);

        Test.stopTest();

        System.assert(!productCostsFiltered.isEmpty());
    }
}