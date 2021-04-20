/**
* @author fabiosuenaga - topi
*/
public with sharing class LAT_DistributorAgreementController {
	private static final String CONTRATO_STATUS_APROBADO = 'Aprovado';
    public Id contractId {get; set;}
    public LAT_Contract2__c contract {get; set;}
    public List<LAT_Contract_Eventos__c> events {get; set;}
    
    public List<LAT_EventVolume__c> volumenOnInvoice {get; set;}
    public List<LAT_EventVolume__c> volumenOffInvoice {get; set;}
    public List<ProcessInstanceStep> approvalProcessSteps {get; set;}
    public Boolean isApproved  {get;set;}
    public Boolean isprestige  {get;set;}
    public Boolean needsNationalTradeManager  {get;set;}
    public Boolean needsDirectorComercial  {get;set;}
    public Boolean needsDirectorFinanciero  {get;set;}
    public Boolean needsPresidentSign  {get;set;}

    
    public LAT_DistributorAgreementController() {
        init();
    }

    @testVisible
    private void init() {

        this.contractId = Apexpages.currentPage().getParameters().get('contractId');
        List<LAT_Contract2__c> contracts = new LAT_ContractRepository().findByIds(new List<Id>{contractId});

        if(!contracts.IsEmpty()) {
            this.contract = contracts.get(0);

            this.events = new LAT_ContractEventosRepository().findByContractIds(new List<String>{contractId});

            this.approvalProcessSteps = getApprovalProcessSteps(this.contract);
            this.volumenOnInvoice = [SELECT Finality__c,LAT_BonusQuantity__c,LAT_BoxesContract__c,LAT_ContractEvent__c,LAT_ProductGroup__c,LAT_Volume__c ,LAT_ProductGroup__r.Name
                                    FROM LAT_EventVolume__c
                                    WHERE LAT_ContractEvent__r.LAT_Contract__c  =: contractId
                                    AND Finality__c = 'Condição Comercial On Invoice'];

            this.volumenOffInvoice = [SELECT Finality__c,LAT_BonusQuantity__c,LAT_BoxesContract__c,LAT_ContractEvent__c,LAT_ProductGroup__c,LAT_Volume__c ,LAT_ProductGroup__r.Name
                                    FROM LAT_EventVolume__c
                                    WHERE LAT_ContractEvent__r.LAT_Contract__c  =: contractId
                                    AND Finality__c = 'Condição Comercial Off Invoice'];

            if(contract.Status__c == CONTRATO_STATUS_APROBADO) {
                this.isApproved = true;
            } else {
                this.isApproved = false;
            }
        } else {
            throw new LAT_Rest_Contracts.RestContractException('No se encontro el contrato');
        }
    }

    @testVisible
    private List<ProcessInstanceStep> getApprovalProcessSteps(LAT_Contract2__c contract) {
        List<ProcessInstanceStep> processInstanceSteps = new List<ProcessInstanceStep>();

        processInstanceSteps = [SELECT OriginalActor.Name, OriginalActor.Title ,Comments,CreatedDate,StepStatus 
                                FROM ProcessInstanceStep 
                                WHERE ProcessInstance.TargetObjectId =: contract.id] ;

        return processInstanceSteps;
    }
}