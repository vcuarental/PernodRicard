/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
*-------------------------------------------------------------------------------
*
* Trigger que dispara a trigger de atualização dos valores dos contratos
* NAME: InvestBonifPagtoROI_RecalculaContrato.trigger
* AUTHOR: ROGERIO ALVARENGA                         DATE: 06/08/2012
*
*
* MAINTENANCE: INSERIDO FUNCIONALIDADE QUE VALIDA O ID DO TIPO DE REGISTRO DOS OBJETOS.
* AUTHOR: CARLOS CARVALHO                               DATE: 14/01/2013
*******************************************************************************/
trigger InvestBonifPagtoROI_RecalculaContrato on Investimento_Bonificacao_e_Pagamento__c (after insert, after update) {

//    Check if this trigger is bypassed by SESAME (data migration Brazil)
if((UserInfo.getProfileId()!='00eM0000000QNYPIA4') && (UserInfo.getProfileId()!= '00eD0000001AnFlIAK')) {    
    List< String > lListContractIDs = new List< String >();
    
    //Recupera tipos de registro de Investimento_Bonificacao_e_Pagamento__c
    Set< Id > setRecTypeInv = new Set< Id >();
    setRecTypeInv.add( RecordTypeForTest.getRecType( 'Investimento_Bonificacao_e_Pagamento__c', 'Bonificacao_Produtos') );
    setRecTypeInv.add( RecordTypeForTest.getRecType( 'Investimento_Bonificacao_e_Pagamento__c', 'Dinheiro') );
    
    //Recupera os Ids dos tipos de registro do objeto LAT_Contract__c
    Set< Id > setRecTypeLatCon = new Set< Id >();
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
    
    for ( Investimento_Bonificacao_e_Pagamento__c ibp : trigger.new )
    {
        if ( setRecTypeInv.contains( ibp.RecordTypeId ) 
        && !ContratoSemaphoro.alreadyRun( ibp.LAT_contract__c ) )
            lListContractIDs.add( ibp.LAT_contract__c );
    }
  
    if ( lListContractIDs.size() == 0 ) return;
  
    List< LAT_Contract__c > lListContract = [ SELECT Recalcula_Contrato__c FROM LAT_Contract__c 
                                                WHERE id=:lListContractIDs 
                                                AND RecordTypeId =: setRecTypeLatCon];
  
    try
    {
        update lListContract;
    }
    catch ( Exception e )
    { 
        for ( Investimento_Bonificacao_e_Pagamento__c ibp : trigger.new ){
            if( setRecTypeInv.contains( ibp.RecordTypeId ) ){
               ibp.addError( 'Investimento, Bonificação e Pagamento não pode ser alterado.' + e.getMessage() );
            }
         }
    }
 }
}