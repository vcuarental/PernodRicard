/**
* @author fabiosuenaga - topi
*/
public with sharing class LAT_ProductCostRepository extends LAT_AbstractRepository {
    private static List<LAT_ProductCost__c> lstProductCost = null;

    public LAT_Criteria newBaseSearchCriteria() {
        return new LAT_Criteria ( 'SELECT UF__c, Product__c, Product__r.Name, CM_Case__c, RecordType.DeveloperName, DistributorCost__c,  LDCost__c, Net_Sales_Case__c, MeasureUnit__c, AN8__c, Distributor__c FROM LAT_ProductCost__c' );
    }

    public List<LAT_ProductCost__c> findNotExpiredByProductAN8AndRecordType(List<Id> productIds, List<Id> distributorOrProducerIds, List<String> developerNames) {
        List<LAT_ProductCost__c> lstFilteredProductCost = null;
        Set<Id> setProductsIds = null;
        Set<Id> setDistributorOrProducerIds = null;
        Set<String> setDeveloperNames = null;

        System.debug('LAT_ProductCostRepository.findNotExpiredByProductAN8AndRecordType [productIds : ' + productIds + ' - distributorOrProducerIds : ' + distributorOrProducerIds + ' - developerNames : ' + developerNames +  ']');

        if(lstProductCost == null || lstProductCost.IsEmpty()) {
            lstProductCost = (List<LAT_ProductCost__c>) newBaseSearchCriteria().add(LAT_Restriction.greaterThanEqualsDateLiteral('EndDate__c', 'TODAY')).searchThrowable();
            System.debug('LAT_ProductCostRepository.findNotExpiredByProductAN8AndRecordType [lstProductCost.size() : ' + lstProductCost.size()  +  ']');
        } else {
            System.debug('LAT_ProductCostRepository.findNotExpiredByProductAN8AndRecordType [lstProductCost.size() [cached] : ' + lstProductCost.size()  +  ']');
        }

        setProductsIds = new Set<Id>(productIds);
        setDistributorOrProducerIds = new Set<Id>(distributorOrProducerIds);
        setDeveloperNames = new Set<String>(developerNames);

        lstFilteredProductCost = new List<LAT_ProductCost__c>();
        for(LAT_ProductCost__c objProductCost : lstProductCost) {
            if(setProductsIds.contains(objProductCost.Product__c) && setDistributorOrProducerIds.contains(objProductCost.AN8__c)  && setDeveloperNames.contains(objProductCost.RecordType.DeveloperName) ) {
                System.debug('LAT_ProductCostRepository.findNotExpiredByProductAN8AndRecordType [adding product.... : ' + objProductCost + ']');
                lstFilteredProductCost.add(objProductCost);
            }
        }

        System.debug('LAT_ProductCostRepository.findNotExpiredByProductAN8AndRecordType [' + lstFilteredProductCost + '] <-');

        return lstFilteredProductCost;
        /*
        return (List<LAT_ProductCost__c>) newBaseSearchCriteria()
                .add ( LAT_Restriction.isIn ( 'Product__c', productIds ) )
                .add ( LAT_Restriction.isIn ( 'AN8__c', distributorOrProducerIds ) )
                .add ( LAT_Restriction.isIn ( 'RecordType.DeveloperName', developerNames ) )
                .add ( LAT_Restriction.greaterThanEqualsDateLiteral ('EndDate__c', 'TODAY') )
                .searchThrowable();
        */  
    }    
}