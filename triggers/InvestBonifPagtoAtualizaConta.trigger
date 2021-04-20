/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
*-------------------------------------------------------------------------------
*
* Trigger que atribui a conta ao IBP, lendo a conta do contrato
* NAME: InvestBonifPagtoAtualizaConta.trigger
* AUTHOR: ROGERIO ALVARENGA                         DATE: 30/10/2012
*
*
* MAINTENANCE: INSERIDO FUNCIONALIDADE QUE VALIDA O ID DO TIPO DE REGISTRO DOS OBJETOS.
* AUTHOR: CARLOS CARVALHO                               DATE: 08/01/2013
*******************************************************************************/

trigger InvestBonifPagtoAtualizaConta on Investimento_Bonificacao_e_Pagamento__c (before insert) {

//    Check if this trigger is bypassed by SESAME (data migration Brazil)
if((UserInfo.getProfileId()!='00eM0000000QNYPIA4') && (UserInfo.getProfileId()!= '00eD0000001AnFlIAK')) {  

    //Declaração de variáveis
    Set< Id > setRecTypeInv = new Set< Id >();
    Set< Id > setRecTypeLatCon = new Set < Id >();
    
    //Recupera tipos de registro de Investimento_Bonificacao_e_Pagamento__c
    setRecTypeInv.add( RecordTypeForTest.getRecType( 'Investimento_Bonificacao_e_Pagamento__c', 'Bonificacao_Produtos') );
    setRecTypeInv.add( RecordTypeForTest.getRecType( 'Investimento_Bonificacao_e_Pagamento__c', 'Dinheiro') );
  
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
  for ( Investimento_Bonificacao_e_Pagamento__c lIBP : Trigger.new ){
    if( setRecTypeInv.contains( lIBP.RecordTypeId ) ){
        lListContractID.add( lIbp.LAT_contract__c );
    }
  }
  
  List< LAT_Contract__c > lListContract = [ SELECT Account__c, id 
                                            FROM LAT_Contract__c 
                                            WHERE id=:lListContractID 
                                            AND RecordTypeId =: setRecTypeLatCon];
                                            
  Map< String, String > lMapContract = new Map< String, String >();
  for ( LAT_Contract__c lContr : lListContract )
    lMapContract.put( lContr.id, lContr.Account__c );
    
  for ( Investimento_Bonificacao_e_Pagamento__c lIBP : Trigger.new ){
    if( setRecTypeInv.contains( lIBP.RecordTypeId ) ){
        lIBP.Conta_IBP__c = lMapContract.get( lIbp.LAT_contract__c );
    }
  }
 }
}