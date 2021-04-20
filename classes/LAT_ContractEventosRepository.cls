/**
* @author fabiosuenaga - topi
*/
public with sharing class LAT_ContractEventosRepository extends LAT_AbstractRepository {

    public LAT_Criteria newBaseSearchCriteria() {
        return new LAT_Criteria ( 'SELECT Id,LAT_Contract__r.Status__c,IsDeleted,LAT_Contract__r.Name, LastModifiedById,LastModifiedDate,LAT_Ativacoes__c,LAT_Cidade__c,LAT_Classe_Social__c,LAT_Comments__c,LAT_Comunicacao__c,LAT_Contract__c,LAT_Convites_Pista__c,LAT_Convites_VIP__c,LAT_Data_Evento__c,LAT_DoneROI__c,LAT_Estado__c,LAT_Estilo_Musical__c,LAT_Faixa_Etaria__c,LAT_MarcasAtivadasSR__c,LAT_MarcasAtivadas__c,LAT_Micro_Regional__c,LAT_Motivo_Comentarios__c,LAT_Motivo__c,LAT_No_Pessoas__c,LAT_no_Posts__c,LAT_Open_Bar__c,LAT_Perfil__c,LAT_Periodo__c,LAT_PredictedROI__c,LAT_Status__c,LAT_Tipo_de_Evento__c,LAT_Tipo_de_Verba__c,LAT_Total__c,Name,SystemModstamp,Valor_Ingresso__c, (SELECT LAT_ContractEvent__r.LAT_Contract__r.LAT_Distributor__c, LAT_ContractEvent__r.LAT_Contract__r.Account__c, CreatedById,CreatedDate,CurrencyIsoCode,Finality__c,Id,IsDeleted,LastActivityDate,LastModifiedById,LastModifiedDate,LAT_BonusPercent__c,LAT_BonusQuantity__c,LAT_BoxesContractMonth__c,LAT_BoxesContract__c,LAT_BusinessCondition__c,LAT_ContractEvent__c,LAT_EstimatedBoxesContract__c,LAT_ProductGroup__c,LAT_Volume__c,Name FROM Volumen_Eventos__r), (SELECT CreatedById,CreatedDate,CurrencyIsoCode,Id,IsDeleted,LastModifiedById,LastModifiedDate,LAT_Ammount__c,LAT_ApprovedPayment__c,LAT_BonusPercent__c,LAT_BonusQuantity__c,LAT_CNPJ_Fornecedor__c,LAT_ContractEvent__c,LAT_Distributor__c,LAT_EventCashValue__c,LAT_EventPaymentCreatedAfterSigning__c,LAT_EventProductValue__c,LAT_EventType__c,LAT_EventValue__c,LAT_Finality__c,LAT_FY__c,LAT_GoalNotReached__c,LAT_IntegrationMessage__c,LAT_IntegrationStatus__c,LAT_IsCommCondParentPayment__c,LAT_Manager__c,LAT_ParentPayment__c,LAT_PaymentDateDone__c,LAT_PaymentDateOriginal__c,LAT_PaymentDate__c,LAT_PaymentGoals__c,LAT_Producer__c,LAT_ProductGroup__c,LAT_ProductValue__c,LAT_ReleaseReason__c,LAT_Send_to_Approval__c,LAT_SkuAtIntegration__c,LAT_Status__c,LAT_Type__c,LAT_UOM__c,LAT_VolumeGF__c,LAT_Volumen__c,Name,RecordTypeId,LAT_TotalProductValue__c FROM Pagamentos_Evento__r) FROM LAT_Contract_Eventos__c' );
    }

    public List<LAT_Contract_Eventos__c> findByContractIds(List<String> contractIds) {
        return (List<LAT_Contract_Eventos__c>) newBaseSearchCriteria()
                .add ( LAT_Restriction.isIn ( 'LAT_Contract__c', contractIds ) )
                .searchThrowable();
    }

    public List<LAT_Contract_Eventos__c> findByIds(List<String> ids) {
        return (List<LAT_Contract_Eventos__c>) newBaseSearchCriteria()
                .add ( LAT_Restriction.isIn ( 'Id', ids ) )
                .searchThrowable();        
    }
}