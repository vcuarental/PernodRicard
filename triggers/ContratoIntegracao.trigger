/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
*-------------------------------------------------------------------------------
*
* Quando o contrato passar para 'Ativo' dispara a integração de contrato com o SCV
* NAME: ContratoIntregracao.trigger
* AUTHOR: ROGERIO ALVARENGA                         DATE: 13/09/2012
*
* MAINTENANCE
* AUTHOR: CARLOS CARVVALHO                          DATE: 08/10/2012
*
* MAINTENANCE: INSERIDO FUNCIONALIDADE QUE VALIDA O ID DO TIPO DE REGISTRO DOS OBJETOS.
* AUTHOR: CARLOS CARVALHO                               DATE: 07/01/2013
*******************************************************************************/
trigger ContratoIntegracao on LAT_Contract__c (before update) {

//    Check if this trigger is bypassed by SESAME (data migration Brazil)
if((UserInfo.getProfileId()!='00eM0000000QNYPIA4') && (UserInfo.getProfileId()!= '00eD0000001AnFlIAK')) {
  
    //Declaração de variáveis
    Set< Id > setRecTypeLatCon = new Set< Id >();
    Set< Id > setRecTypeAcc = new Set< Id >();
    
    //Recupera os Ids dos tipos de registro do objeto Account
    setRecTypeAcc.add( RecordTypeForTest.getRecType( 'Account', 'Eventos'));
    setRecTypeAcc.add( RecordTypeForTest.getRecType( 'Account', 'Off_Trade'));
    setRecTypeAcc.add( RecordTypeForTest.getRecType( 'Account', 'On_Trade'));
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
    
  List< String > lListContractIDs = new List< String >();
  for ( LAT_Contract__c c : Trigger.new ){
    if( !ContratoSemaphoro.setNewCode( c.Id, 'ContratoIntegracao' ) ){
      if ( setRecTypeLatCon.contains( c.RecordTypeId) && c.Status_da_INtegra_o__c != 'Envia' 
        && c.Status__c == 'Ativo' && Trigger.oldMap.get( c.id ).status__c != 'Ativo' ) lListContractIDs.add( c.Account__c );
    }
  }
  if ( lListContractIDs.size() == 0 ) return;
  
  List< Account > lListAccount = [ SELECT id FROM Account WHERE id=:lListContractIDs 
    AND Channel__c = 'Off Trade' AND RecordTypeId =: setRecTypeAcc];
    
  Set< String > lSetAccount = new Set< String >();
  for ( Account lAcc : lListAccount )
    lSetAccount.add( lAcc.id );
  
  if ( lSetAccount.size() == 0 ) return;

  for ( LAT_Contract__c c : Trigger.new )
  {
    if ( lSetAccount.contains( c.Account__c ) )
    {
      ContractManagerInterface.ContractManagerInvoke( String.valueOf( c.id ) );
      c.Status_da_INtegra_o__c = 'Enviando para o SCV';
      c.MensagemIntegracao__c = '';
    }
  }
}
}