/**
* @author fabiosuenaga - topi
*/
public with sharing class LAT_EventPaymentRepository extends LAT_AbstractRepository {

    public LAT_Criteria newBaseSearchCriteria() {
        return new LAT_Criteria ('SELECT LAT_ContractEvent__r.Name, LAT_ContractEvent__r.LAT_Data_Evento__c, LAT_ContractEvent__r.LAT_Contract__c, CreatedById,CreatedDate,CurrencyIsoCode,Id,IsDeleted,LastModifiedById,LastModifiedDate,LAT_Ammount__c,LAT_ApprovedPayment__c,LAT_BonusPercent__c,LAT_BonusQuantity__c,LAT_CNPJ_Fornecedor__c,LAT_ContractEvent__c,LAT_Distributor__c,LAT_EventCashValue__c,LAT_EventPaymentCreatedAfterSigning__c,LAT_EventProductValue__c,LAT_EventType__c,LAT_EventValue__c,LAT_Finality__c,LAT_FY__c,LAT_GoalNotReached__c,LAT_IntegrationMessage__c,LAT_IntegrationStatus__c,LAT_IsCommCondParentPayment__c,LAT_Manager__c,LAT_ParentPayment__c,LAT_PaymentDateDone__c,LAT_PaymentDateOriginal__c,LAT_PaymentDate__c,LAT_PaymentGoals__c,LAT_Producer__c,LAT_ProductGroup__c,LAT_ProductGroup__r.Name,LAT_ProductValue__c,LAT_ReleaseReason__c,LAT_Send_to_Approval__c,LAT_SkuAtIntegration__c,LAT_Status__c,LAT_TotalProductValue__c,LAT_Type__c,LAT_UOM__c,LAT_VolumeGF__c,LAT_Volumen__c,Name,RecordTypeId,SystemModstamp, RecordType.Name FROM LAT_EventPayment__c');
    }

    public List<LAT_EventPayment__c> findByIds(List<String> Ids) {
        return (List<LAT_EventPayment__c>) newBaseSearchCriteria()
                .add ( LAT_Restriction.isIn ( 'Id', Ids ) )
                .searchThrowable();
    }  

    public List<LAT_EventPayment__c> findByContractIds(List<String> Ids) {
        return (List<LAT_EventPayment__c>) newBaseSearchCriteria()
                .add ( LAT_Restriction.isIn ( 'LAT_ContractEvent__r.LAT_Contract__c', Ids ) )
                .searchThrowable();
    }  
}