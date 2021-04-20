/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
*-------------------------------------------------------------------------------
*
* Quando o contrato passar para 'Ativo' deve-se marcar no objeto 'Investimento,
* Bonificação e Pagamento' o primeiro pagamento e os outros pagamentos.
* NAME: ContratoMarcaPrimeiroPagamento.trigger
* AUTHOR: ROGERIO ALVARENGA                         DATE: 13/09/2012
*
*
* MAINTENANCE: INSERIDO FUNCIONALIDADE QUE VALIDA O ID DO TIPO DE REGISTRO DOS OBJETOS.
* AUTHOR: CARLOS CARVALHO                               DATE: 08/01/2013
*******************************************************************************/
trigger ContratoMarcaPrimeiroPagamento on LAT_Contract__c (after update) {

//    Check if this trigger is bypassed by SESAME (data migration Brazil)
if((UserInfo.getProfileId()!='00eM0000000QNYPIA4') && (UserInfo.getProfileId()!= '00eD0000001AnFlIAK')) {
    
    //Declaração de variáveis
    Set< Id > setRecTypeLatCon = new Set< Id >();
    List< String > lListContractID = new List< String >();
    List< String > listRecTypeInv = new List< String >();
    
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
  
  
  for ( LAT_Contract__c c : Trigger.new )
  {
    if ( setRecTypeLatCon.contains(c.RecordTypeId) && c.Status__c == 'Ativo' && Trigger.oldMap.get( c.id ).Status__c != 'Ativo' )
    {
      lListContractID.add( c.id );
    }
  }
  
  if ( lListContractID.size() == 0 ) return;
  
  List< Investimento_Bonificacao_e_Pagamento__c > lListIBP = [ SELECT LAT_contract__c, 
     Primeiro_Pagamento__c,Outros_Pagamentos__c, Data_de_Previsao_do_Pagamento__c
     FROM Investimento_Bonificacao_e_Pagamento__c 
     WHERE LAT_contract__c =: lListContractID
     AND RecordTypeId =: listRecTypeInv
     order by LAT_contract__c, Data_de_Previsao_do_Pagamento__c ];
  
  if ( lListIBP.size() == 0 ) return;
  
  boolean lFirst;
  String lLastContract = null;
  for ( Investimento_Bonificacao_e_Pagamento__c lIBP : lListIBP )
  {
    if ( lLastContract == null || lLastContract != lIBP.LAT_Contract__c )
    {
      lFirst = true;
    }
    lIBP.Primeiro_Pagamento__c = lFirst;
    lIBP.Outros_Pagamentos__c = !lFirst;
    lIBP.CasoEspecial__c = true;
    lFirst = false;
    lLastContract = lIBP.LAT_Contract__c;
  }
  
  update lListIBP;
    }
}