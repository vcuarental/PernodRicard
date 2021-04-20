/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* Reserva as IBPs do ano fiscal atual após o status do contrato igual à ATIVO.
*
* NAME: ContractReservaIBP.trigger
* AUTHOR: CARLOS CARVALHO                           DATE: 22/10/2012
*
* MAINTENANCE
* AUTHOR: CARLOS CARVALHO                           DATE: 07/01/2013
* DESC: INSERIDO FUNCIONALIDADE QUE VALIDA O ID DO TIPO DE REGISTRO DOS OBJETOS. 
********************************************************************************/
trigger ContractReservaIBP on LAT_Contract__c (after update) {

//    Check if this trigger is bypassed by SESAME (data migration Brazil)
if((UserInfo.getProfileId()!='00eM0000000QNYPIA4') && (UserInfo.getProfileId()!= '00eD0000001AnFlIAK')) {
    
    Set< Id > setRecTypeLatCon = new Set< Id >();
    List< String > listRecTypeInv = new List< String >();
    List< String > listIdContrato = new List< String >();
    List< Investimento_Bonificacao_e_Pagamento__c > listIBP = new List< Investimento_Bonificacao_e_Pagamento__c >();
    List< Investimento_Bonificacao_e_Pagamento__c > listIBPUpdate = new List< Investimento_Bonificacao_e_Pagamento__c >();
    Decimal anoFiscalAtual;
    
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
    
    for( LAT_Contract__c c : trigger.new ){
        if( setRecTypeLatCon.contains( c.RecordTypeId ) && c.Status__c == 'Ativo' ) listIdContrato.add( c.Id );
    }
    
    if( System.today().month() >= 7 )
        anoFiscalAtual = Decimal.valueOf( System.today().year()+1);
    else
        anoFiscalAtual = Decimal.valueOf( System.today().year() );
    
    listIBP = [SELECT Id, Status_da_verba__c, Ano_fiscal__c, LAT_contract__c, CasoEspecial__c
        FROM Investimento_Bonificacao_e_Pagamento__c WHERE LAT_contract__c =: listIdContrato
        AND Ano_fiscal_calculado__c =: anoFiscalAtual AND RecordTypeId =: listRecTypeInv];
    
    if( listIBP != null && listIBP.size() > 0 ){
      for( Investimento_Bonificacao_e_Pagamento__c i : listIBP ){
        i.Status_da_Verba__c = 'Reservado';
        i.CasoEspecial__c = true;
        listIBPUpdate.add( i );
      }
        update listIBPUpdate;     
    }
 }
}