/**
* @author fabiosuenaga - topi
*/
public with sharing class LAT_UnitConversionRatesRepository extends LAT_AbstractRepository {
    public LAT_Criteria newBaseSearchCriteria() {
        return new LAT_Criteria ( 'SELECT Id, Factor__c, LAT_KeyUnica__c FROM LAT_UnitConversionRates__c' );
    }

    public List<LAT_UnitConversionRates__c> findByKeyUnica(List<String> keyUnicas) {
        return (List<LAT_UnitConversionRates__c>) newBaseSearchCriteria()
                .add ( LAT_Restriction.isIn ( 'LAT_KeyUnica__c', keyUnicas ) )
                .searchThrowable();
    }  
}