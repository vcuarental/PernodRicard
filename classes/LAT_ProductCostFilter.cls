/**
* @author fabiosuenaga - topi
*/
public with sharing class LAT_ProductCostFilter {
    public LAT_ProductCostFilter() {}

    public static List<LAT_ProductCost__c> productCostUsingAn8AndProduct(Set<LAT_EventVolume__c> allEventVolumes, List<LAT_ProductCost__c> productCosts) {
        Set<LAT_ProductCost__c> productCostsFiltered = new Set<LAT_ProductCost__c>();

        for (LAT_EventVolume__c eventVolume : allEventVolumes) {
            Id distributorId = eventVolume.LAT_ContractEvent__r.LAT_Contract__r.LAT_Distributor__c;
            Id productGroupId = eventVolume.LAT_ProductGroup__c;

            for (LAT_ProductCost__c productCost : productCosts) {

                if (productCost.AN8__c == distributorId && productCost.Product__c == productGroupId) {
                    productCostsFiltered.add(productCost);
                    break;
                }
    
            }
        }

        return new List<LAT_ProductCost__c>(productCostsFiltered);
    }
}