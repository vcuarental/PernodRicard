/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
*-------------------------------------------------------------------------------
*
* Trigger que atualiza alguns campos em contrato para o tratamento do ROI (Return
* On Investiment)
* NAME: InvestBonifPagtoROI.trigger
* AUTHOR: ROGERIO ALVARENGA                         DATE: 17/07/2012
*
*
* MAINTENANCE 
* AUTHOR: CARLOS CARVALHO                               DATE: 08/01/2013
* DESC: INSERIDO FUNCIONALIDADE QUE VALIDA O ID DO TIPO DE REGISTRO DOS OBJETOS.
*
* AUTHOR: CARLOS CARVALHO                               DATE: 22/01/2013
* DESC: INSERIDO TIPO DE REGISTRO 'Dinheiro' PARA OBJETO 
* Investimento_Bonificacao_e_Pagamento__c e inserido lListStatus no select de 
* LAT_Contract__c
*******************************************************************************/
 /********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 16/11/2016
*
********************************************************************************/

trigger InvestBonifPagtoROI on Investimento_Bonificacao_e_Pagamento__c (before insert, before update) {
//MIGRATED 16/11/2016
//    Check if this trigger is bypassed by SESAME (data migration Brazil)
if((UserInfo.getProfileId()!='00eM0000000QNYPIA4') && (UserInfo.getProfileId()!= '00eD0000001AnFlIAK')) {

    // Recuperando tipos de registro
    Set< Id > setRecTypeIBP = new Set< Id >();
    Id recTypeDinheiro = RecordTypeForTest.getRecType( 'Investimento_Bonificacao_e_Pagamento__c', 'Dinheiro' );
    setRecTypeIBP.add( RecordTypeForTest.getRecType( 'Investimento_Bonificacao_e_Pagamento__c', 'Bonificacao_Produtos' ));
    setRecTypeIBP.add( recTypeDinheiro );
    
    Id idRecTypeInf = RecordTypeForTest.getRecType( 'Informacoes_de_Custo_do_Produto__c', 'Informacoes_de_Custo_do_Produto');
    
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
    
  // Agrupamentos de ID's para Consulta
  List< String > lListContractIDs = new List< String >();
  List< String > lListAccIDs = new List< String >();
  List< String > lListScheduleC = new List< String >();
  
  for ( Investimento_Bonificacao_e_Pagamento__c ibp : trigger.new )
  {
    if ( !setRecTypeIBP.contains( ibp.RecordTypeId) ) continue;
    lListContractIDs.add( ibp.LAT_contract__c );
    lListScheduleC.add( ibp.ScheduleC_Bonificado__c);
  }
  
  if ( lListContractIDs.size() == 0 ) return;
  //Carlos modification - 22/01/2013
  List< String > lListStatus = new List< String >();
  lListStatus.add( 'Ativo' );
  lListStatus.add( 'Aditado' );
  lListStatus.add( 'Cancelado' );
  //End modification
  
  // Buscar contas relacionadas e colocar em um mapa
  List< LAT_Contract__c > lListContract = [ SELECT Account__r.id, Account__r.Revenue_UF__c, id, 
    Recalcula_Contrato__c FROM LAT_Contract__c WHERE id =: lListContractIDs 
    AND RecordTypeId =: setRecTypeLatCon and Status__c <>: lListStatus ];
  Map< id, String > lMapFaturamento = new Map< Id, String >();
  Map< id, LAT_Contract__c > lMapContract = new Map< id, LAT_Contract__c >();
  for ( LAT_Contract__c ct : lListContract )
  {
    lMapFaturamento.put( ct.Account__r.id, ct.Account__r.Revenue_UF__c );
    ct.Recalcula_Contrato__c = true;
    lMapContract.put( ct.id, ct );
  }
  
  // Buscar Informações de custo e colocar em um mapa
  List< Informacoes_de_Custo_do_Produto__c > lListICP = [ SELECT UF__c, Scheduler_C__r.Scheduler_C__c, 
                  Scheduler_C__r.Tx_Conversao__c, Custo_LD__c, Custo_Distribuidor__c, Scheduler_C__r.SKU_de_referencia__c,
                  Scheduler_C__r.LAT_Product__c
                  FROM Informacoes_de_Custo_do_Produto__c WHERE Scheduler_C__c =: lListScheduleC 
                  AND RecordTypeId =: idRecTypeInf ];
  
  Map< String, Informacoes_de_Custo_do_Produto__c > lMapICP = new Map< String, Informacoes_de_Custo_do_Produto__c >();
  for ( Informacoes_de_Custo_do_Produto__c icp : lListICP )
  {
    lMapICP.put( icp.UF__c + '|' + icp.Scheduler_C__c, icp );
  }
  
  Map< Id, LAT_Contract__c > lListContractUpdated = new Map< Id, LAT_Contract__c >();
  
  // Loop de execução    
  for ( Investimento_Bonificacao_e_Pagamento__c ibp : trigger.new )
  {
    if ( !setRecTypeIBP.contains( ibp.RecordTypeId) ) continue;
    String lSchedCId = ibp.ScheduleC_Bonificado__c ;
    
    if ( lSchedCId == null && ibp.RecordTypeId==recTypeDinheiro ) 
    { 
            if ( !lListContractUpdated.containsKey( ibp.LAT_contract__c ) && lMapContract.containsKey( ibp.LAT_contract__c )
            && !ContratoSemaphoro.alreadyRun( ibp.LAT_contract__c ) )    
            {
                lListContractUpdated.put( ibp.LAT_contract__c, lMapContract.get( ibp.LAT_contract__c ) );
            }
            continue;
    }
    String lUF = lMapFaturamento.get( ibp.Conta__c );
    if ( lUF == null ) continue;
    Informacoes_de_Custo_do_Produto__c icp = lMapICP.get( lUF + '|' + lSchedCId );
    if ( icp == null ) continue;
    boolean wasChanged = false;
    Decimal lValor = ibp.Volume_Cx__c * icp.Custo_Distribuidor__c;
    if ( lValor != ibp.Valor_Percebido__c )
    {
      ibp.Valor_Percebido__c = lValor;
      wasChanged = true;
    }
    lValor = ibp.Volume_Cx__c * icp.Custo_LD__c;
    if ( lValor != ibp.Custo_Bonificado__c )
    {
      ibp.Custo_Bonificado__c = lValor;
      wasChanged = true;
    }

    if(!Utils.wasMigrationDone('1')){ 
      if ( ibp.Produto_Bonificado__c != icp.Scheduler_C__r.SKU_de_referencia__c )
      {
        ibp.Produto_Bonificado__c = icp.Scheduler_C__r.SKU_de_referencia__c;
        wasChanged = true;
      }
    }
    //MIGRATED 16/11/2016
    else{
      if ( ibp.LAT_Product__c != icp.Scheduler_C__r.LAT_Product__c   )
      {
        ibp.LAT_Product__c = icp.Scheduler_C__r.LAT_Product__c ;
        wasChanged = true;
      }
    }
    if ( wasChanged && !lListContractUpdated.containsKey( ibp.LAT_contract__c ) && lMapContract.containsKey( ibp.LAT_contract__c )){ lListContractUpdated.put( ibp.LAT_contract__c, lMapContract.get( ibp.LAT_contract__c ) ); }
  }
  if( lListContractUpdated.values() != null && lListContractUpdated.values().size() > 0 ) update lListContractUpdated.values();
 }
}