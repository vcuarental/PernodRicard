/**
* @author fabiosuenaga - topi
*/
public virtual class LAT_ContractRepository extends LAT_AbstractRepository {

    public LAT_Criteria newBaseSearchCriteria() {
        return new LAT_Criteria ( 'SELECT Name, Status__c,OriginalContractNumber__c, LAT_Distributor__r.Client_code_AN8__c, EndDate__c,LAT_TotalContractOffInvoice__c,LAT_OnInvoice__c,LAT_Contrapartidas__c, LAT_AditionComment__c,TotalEventContractPRBCostNetSales__c, StartDate__c, OwnerId, FreightDistributor__c, DistributorTax__c, CalculationErrors__c, TotalMoneyPerceivedValue__c,LAT_ClientRegional__c, Account__r.Name, Account__r.Revenue_UF__c, GMDC_Total__c, TotalMoneyPRBCost__c,TotalProductsPerceivedValue__c, TotalProductsPRBCost__c , RecordType.DeveloperName, LAT_Distributor__c, LAT_Distributor__r.Name, (Select Id, EventType__c, Ammount__c, ProductGroup__c, ProductGroup__r.Name, Finality__c, Volumen__c, RecordType.Name, EventPaymentCreatedAfterSigning__c, LAT_BonusPercent__c, LAT_BonusQuantity__c, LAT_Producer__c FROM LAT_Payments__r order by RecordTypeId desc ),ROIApRoiPrevisto__c FROM LAT_Contract2__c' );
    }

    public List<LAT_Contract2__c> findByIds(List<Id> contractIds) {
        return (List<LAT_Contract2__c>) newBaseSearchCriteria()
                .add ( LAT_Restriction.isIn ( 'Id', contractIds ) )
                .searchThrowable();
    } 
}