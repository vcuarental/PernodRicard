/**
* @author fabiosuenaga - topi
*/
public with sharing class LAT_ReferenceProductRepository extends LAT_AbstractRepository {
    public LAT_Criteria newBaseSearchCriteria() {
        return new LAT_Criteria ( 'SELECT Id, Name, LAT_Product__c, LAT_Product__r.LAT_SKU__c, LAT_Product__r.LAT_BottlesPerBox__c, LAT_Product__r.LAT_BonusQuantity__c, ReferenceGrouping__c FROM LAT_ReferenceProduct__c' );
    }

    public List<LAT_ReferenceProduct__c> findByReferenceGrouping(List<Id> referenceGroupingIds) {
        return (List<LAT_ReferenceProduct__c>) newBaseSearchCriteria()
                .add ( LAT_Restriction.isIn ( 'ReferenceGrouping__c', referenceGroupingIds ) )
                .searchThrowable();
    }  
}