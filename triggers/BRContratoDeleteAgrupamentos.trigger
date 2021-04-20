/*******************************************************************************
*   Company:Valuenet   Developer: Elena Schwarzböck         Date:30/08/2013    *
********************************************************************************/

trigger BRContratoDeleteAgrupamentos on LAT_Contract__c (after update) {

    Id rtNaoAprovado = RecordTypeForTest.getRecType('LAT_Contract__c', 'OnTradeContratoNaoAprovado');
    set<Id> setIdContratos = new set<Id>();
    
    system.debug('ID RT: ' + rtNaoAprovado);
    
    for(LAT_Contract__c contrato: trigger.new){
    
        system.debug('ID RT CONTRATO: ' + contrato.RecordTypeId);
        system.debug('STATUS: ' + contrato.Status__c);
        
        if(contrato.RecordTypeId == rtNaoAprovado && contrato.Status__c == 'Não aprovado'){
            setIdContratos.add(contrato.id);
        }
    }
    
    system.debug('ID CONTRATOS: ' + setIdContratos);
    
    if(!setIdContratos.isEmpty()){

        list<Agrupamento_Fiscal_Year__c> listAgrup = [SELECT Id, LAT_Contract__c FROM Agrupamento_Fiscal_Year__c WHERE LAT_Contract__c IN: setIdContratos];
        
        system.debug('LISTA AGRUPAMENTOS: ' + listAgrup);
        
        if(!listAgrup.isEmpty()){
            delete listAgrup;
        }
    }
}