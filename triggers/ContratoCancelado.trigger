/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
********************************************************************************
* Quando o status do contrato for diferente de 'Ativo', 'Em Aprovação' e 
* 'Em Elaboração' ou estiver com flag 'Finalizado Há mais de 61 dias', deve-se:
* 1) alterar o status dos registros do objeto 'Investimento, Bonificação e
* Pagamento' para 'Encerrado'
* 2) alterar o status dos registros do objeto 'Pagamento e Verba' para 
* 'Cancelado'
*
* NAME: ContratoCancelado.trigger
* AUTHOR: ROGERIO ALVARENGA                         DATE: 12/09/2012
*
* MAINTENANCE: INSERIDO LÓGICA PARA VALIDAÇÃO DO TIPO DE REGISTRO.
* AUTHOR: CARLOS CARVALHO                           DATE: 07/01/2013
*******************************************************************************/
trigger ContratoCancelado on LAT_Contract__c (before update) {

//    Check if this trigger is bypassed by SESAME (data migration Brazil)
if((UserInfo.getProfileId()!='00eM0000000QNYPIA4') && (UserInfo.getProfileId()!= '00eD0000001AnFlIAK')) {
    
    //Declração de variáveis
    Set< Id > setRecTypeLatCon = new Set< Id >();
    List< String > listRecTypeInv = new List< String >();
    List< String > listRecTypePV = new List< String >();
    
    //Recupera os Ids dos tipos de registro do objeto Investimento_Bonificacao_e_Pagamento__c
    listRecTypePV.add( RecordTypeForTest.getRecType( 'Pagamento_da_Verba__c', 'Bonificacao_Produtos') );
    listRecTypePV.add( RecordTypeForTest.getRecType( 'Pagamento_da_Verba__c', 'Dinheiro') );
    
    //Recupera os Ids dos tipos de registro do objeto Investimento_Bonificacao_e_Pagamento__c
    listRecTypeInv.add( RecordTypeForTest.getRecType( 'Investimento_Bonificacao_e_Pagamento__c', 'Bonificacao_Produtos') );
    listRecTypeInv.add( RecordTypeForTest.getRecType( 'Investimento_Bonificacao_e_Pagamento__c', 'Dinheiro') );
    
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
    
  List< String > lListContractID = new List< String >();
  for ( LAT_Contract__c c : Trigger.new )
  {
    if ( setRecTypeLatCon.contains( c.RecordTypeId ) && ( c.Status__c != 'Aprovado' 
        && c.Status__c != 'Ativo' && c.Status__c != 'Em Aprovação' && c.Status__c != 'Em Elaboração' 
        && c.Status__c != Trigger.oldMap.get( c.id ).Status__c ) 
    || ( c.finalizado_60_dias__c && !Trigger.oldMap.get( c.id ).finalizado_60_dias__c ) && c.Status__c != 'Finalizado' )
    {
      //if ( ContratoSemaphoro.hasExec( c.id ) ) continue;
      if( ContratoSemaphoro.setNewCode( c.Id, 'ContratoCancelado' ) ) continue;
      lListContractID.add( c.id );
      c.finalizado_60_dias__c = false;
    }
  }
  if ( lListContractID.size() == 0 ) return;
  
  List< String > lListIBPID = new List< String >();
  List< Investimento_Bonificacao_e_Pagamento__c > lListIBP = [ SELECT id, Status_da_Verba__c
     FROM Investimento_Bonificacao_e_Pagamento__c 
     WHERE LAT_contract__c =: lListContractID 
     AND RecordTypeId =: listRecTypeInv];

  for ( Investimento_Bonificacao_e_Pagamento__c lIBP : lListIBP )
  {
    lIBP.Status_da_Verba__c = 'Encerrada';
    lListIBPID.add( lIBP.id );
  }
    
  List< Pagamento_da_Verba__c > lListPagtoVerba = [ SELECT id, Status__c, 
    Investimento_Bonifica_o_e_Pagamento__r.Status_da_Verba__c
    FROM Pagamento_da_Verba__c 
    WHERE Investimento_Bonifica_o_e_Pagamento__c =: lListIBPID 
    AND Status__c != 'Integrado' AND Status__c != 'Pago' AND RecordTypeId =: listRecTypePV];
  
  for ( Pagamento_da_Verba__c lPagto : lListPagtoVerba )
  {
    lPagto.Status__c = 'Cancelado';
  }
  if ( lListPagtoVerba != null && lListPagtoVerba.size() > 0 ) update lListPagtoVerba;
  if ( lListIBP.size() > 0 ) update lListIBP;
 }
}