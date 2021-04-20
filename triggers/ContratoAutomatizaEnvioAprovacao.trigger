/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
********************************************************************************
* Automatiza o envio para aprovação dos registros do objeto LAT_Contract__c.
* NAME: ContratoAutomatizaEnvioAprovacao.trigger
* AUTHOR:                                           DATE:
*
* MAINTENANCE 
* AUTHOR: CARLOS CARVALHO                           DATE: 07/01/2013
* DESC: INSERIDO LÓGICA PARA VALIDAÇÃO DO TIPO DE REGISTRO. ALTERADO TRIGGER 
* PARA MELHORES PRÁTICAS.
*
* AUTHOR: CARLOS CARVALHO                           DATE: 23/01/2013
* DESC: INSERIDO LÓGICA QUE VERIFICA SE O REGISTRO LAT_Contract__c ESTA EM 
* APROVAÇÃO.
*******************************************************************************/
trigger ContratoAutomatizaEnvioAprovacao on LAT_Contract__c (after update) {

//    Check if this trigger is bypassed by SESAME (data migration Brazil)
if((UserInfo.getProfileId()!='00eM0000000QNYPIA4') && (UserInfo.getProfileId()!= '00eD0000001AnFlIAK')) {
    
    Set< Id > setRecTypeLatCon = new Set< Id >();
    //Recupera os Ids dos tipos de registro do objeto LAT_Contract__c
    setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Alteracao_de_contrato_OFF'));
    setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Alteracao_de_contrato_on'));
    setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'AlteracaoContratoAtivoOffTrade'));
    setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'AlteracaoContratoAtivoOnTrade'));
    setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Alteracao_de_contrato_aprovada_Off_Trade'));
    setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Alteracao_de_contrato_aprovada_On_Trade'));
    setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_Off_Trade'));
    setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_Off_Trade_aprovado'));
    setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_Off_Trade_ativo'));
    setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato'));
    setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_aprovada'));
    setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_com_aprovacao_Off_Trade'));
    setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_com_aprovacao'));
    setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Ativacao_de_contrato'));
    setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Cancelamento_de_contrato_Off_Trade'));
    setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Cancelamento_de_contrato_On_Trade'));
    setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Cancelamento_de_contrato_aprovado_off'));
    setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Cancelamento_de_contrato_aprovado_on'));

    List<String> idsList = new List<String>();
    for (LAT_Contract__c con : trigger.new) {
        idsList.add(con.id);
    }
    
    List< ProcessInstance > lListPI = [ Select TargetObjectId, Status 
        From ProcessInstance Where (Status = 'Pendente' OR Status = 'Pending') AND TargetObjectId IN: idsList];
        
    Set< String > setIdObj = new Set< String >();
    
    for( ProcessInstance pi : lListPI ){
        setIdObj.add( pi.TargetObjectId );
    }
    
    for ( LAT_Contract__c con : trigger.new) {
      if( setIdObj.contains( con.Id ) ) continue;
      if ( setRecTypeLatCon.contains( con.RecordTypeId ) && con.Aditamento_gerado__c 
        && ( !Trigger.oldMap.get( con.Id ).Aditamento_gerado__c ) 
        || ( con.Status_do_processo__c == 'Cancelamento aprovado pelo cliente' &&
             Trigger.oldMap.get( con.Id ).Status_do_processo__c != 'Cancelamento aprovado pelo cliente') ) 
      {
        
        // create the new approval request to submit
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        //req.setComments('Enviado para aprovação do aditamento.');
        req.setNextApproverIds( new List< Id >{ con.OwnerId});
        req.setObjectId( con.Id );
        
        // submit the approval request for processing
        Approval.ProcessResult result = Approval.process( req );
      }
    }
 }
}