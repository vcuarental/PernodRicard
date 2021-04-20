/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
*-------------------------------------------------------------------------------
*
* Trigger que dispara a trigger de atualização dos valores dos contratos
* NAME: RateioROI_RecalculaContrato.trigger
* AUTHOR: ROGERIO ALVARENGA / JOÃO LOPES              DATE: 07/ago/2012
*
*
* MAINTENANCE: INSERIDO FUNCIONALIDADE QUE VALIDA O ID DO TIPO DE REGISTRO DOS 
* OBJETOS.
* AUTHOR: CARLOS CARVALHO                             DATE: 08/01/2013
*******************************************************************************/
trigger RateioROI_RecalculaContrato on Rateio_do_Contrato__c (after insert, after update) {

//    Check if this trigger is bypassed by SESAME (data migration Brazil)
if((UserInfo.getProfileId()!='00eM0000000QNYPIA4') && (UserInfo.getProfileId()!= '00eD0000001AnFlIAK')) {
    
    //Declaração de variáveis
    List< String > lListContractIDs = new List< String >();
    Id idRecTypeRC = RecordTypeForTest.getRecType( 'Rateio_do_Contrato__c' , 'BRA_Standard' );
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
    
    for ( Rateio_do_Contrato__c rateio : trigger.new ){
        if( rateio.RecordTypeId == idRecTypeRC ) lListContractIDs.add( rateio.LAT_Contract__c );
    }
    
    if ( lListContractIDs.isempty() ) return;
  
    List< LAT_Contract__c > lListContract = [ SELECT Recalcula_Contrato__c FROM LAT_Contract__c 
        WHERE id=:lListContractIDs AND RecordTypeId =: setRecTypeLatCon];
  
    for ( LAT_Contract__c ct : lListContract ){
        ct.Recalcula_Contrato__c = true;
    }
    if ( lListContract.isempty() ) return;
    try{
        update lListContract;
    }
    catch ( Exception e ){
        for ( Rateio_do_Contrato__c rateio : trigger.new ){
            if( rateio.RecordTypeId == idRecTypeRC ) rateio.addError( 'Rateio não pode ser alterado.' + e.getMessage() );
        }
    }
 }
}