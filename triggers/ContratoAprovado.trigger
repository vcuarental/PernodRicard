/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
********************************************************************************
*
* Trigger que cria demanda para contrato aprovado
* NAME: ContratoAprovado.trigger
* AUTHOR: ROGERIO ALVARENGA                         DATE: 01/10/2012
*
* MAINTENANCE: INSERIDO LÓGICA PARA VALIDAÇÃO DO TIPO DE REGISTRO.
* AUTHOR: CARLOS CARVALHO                           DATE: 07/01/2013
*******************************************************************************/

trigger ContratoAprovado on LAT_Contract__c (before update) {

//    Check if this trigger is bypassed by SESAME (data migration Brazil)
if((UserInfo.getProfileId()!='00eM0000000QNYPIA4') && (UserInfo.getProfileId()!= '00eD0000001AnFlIAK')) {
  
    List< String > lListContractID = new List< String >();
    List< String > lListOwnerID = new List< String >();
    Set< Id > setRecTypeLatCon = new Set< Id >();
    String idRecTypeAgr = RecordTypeForTest.getRecType('Agrupamento_Fiscal_Year__c', 'BRA_Standard');
      
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
    
    for ( LAT_Contract__c c:Trigger.new )
    {
      if ( setRecTypeLatCon.contains( c.RecordTypeId ) && ( ( c.Fluxo01_Aprovado__c && !Trigger.oldMap.get( c.id ).Fluxo01_Aprovado__c )
      || ( c.Fluxo02_Aprovado__c && !Trigger.oldMap.get( c.id ).Fluxo02_Aprovado__c ) ) && !c.trigger_on__c 
      && !ContratoSemaphoro.setNewCode( c.id, 'ContratoAprovado' ) )
      {
        lListContractID.add( c.id );
        lListOwnerID.add( c.OwnerId );
      }
    }
  
  if ( lListContractID.size() == 0 ) return;
  
  String lRecTypeTVB = RecordTypeForTest.getRecType( 'Case', 'Inserir_o_Tipo_de_Verba' );
  String lRecTypeDA = RecordTypeForTest.getRecType( 'Case', 'Gerar_D_A_no_sistema_ME' );
  
  User lDAUser = [Select id from User where name = 'ANDRE LIMAVERDE'  And isActive = true limit 1];
  Integer lStartMonth = [select FiscalYearStartMonth from Organization where id=:Userinfo.getOrganizationId()].FiscalYearStartMonth;
  integer lAnoFiscal = system.today().year();
  if ( system.today().month() >= lStartMonth ) lAnoFiscal++;
  
  List< Case > lListCase = new List< Case >();
  
  List< Agrupamento_Fiscal_Year__c > lListAgrpFiscalYear = [ SELECT LAT_Contract__c, id 
    FROM Agrupamento_Fiscal_Year__c WHERE LAT_Contract__c =:lListContractID 
    AND Ano_fiscal_calculadoag__c =: String.valueOf( lAnoFiscal ) AND RecordTypeId =: idRecTypeAgr];
  Map< String, String > lMapAgrp = new Map< String, String >();
  for ( Agrupamento_Fiscal_Year__c lAgr : lListAgrpFiscalYear )
    lMapAgrp.put( lAgr.LAT_Contract__c, lAgr.id );
    
  List< User > lListUsers = [ select id, Gerente_de_area__c, Gerente_regional__c from User where id=: lListOwnerID ];
  Map< id, User > lMapUser = new Map< id, User >();
  for ( User u : lListUsers )
    lMapUser.put( u.id, u );
  
  for ( LAT_Contract__c c:Trigger.new )
  {
    if ( c.Fluxo01_Aprovado__c || c.Fluxo02_Aprovado__c )
    {
      c.trigger_on__c = true;
      Case lDemanda = new Case();
      lDemanda.AccountId = c.Account__c;
      lDemanda.Status = 'Análise pendente';
      lDemanda.Priority = 'Médio';
      lDemanda.Origin = 'Demanda Interna PRB';
      lDemanda.LAT_Contract__c = c.id;
      lDemanda.Purposes_Action__c = c.Finalidades_Acoes__c;
      lDemanda.Grouping_Fiscal_Year__c = lMapAgrp.get( c.id );
      lListCase.add( lDemanda );
      if ( c.Fluxo01_Aprovado__c && !Trigger.oldMap.get( c.id ).Fluxo01_Aprovado__c )
      {
        lDemanda.RecordTypeId = lRecTypeTVB;
        User lUser = lMapUser.get( c.OwnerId );
        if ( lUser.Gerente_de_area__c != null ) lDemanda.OwnerId = lUser.Gerente_de_area__c;
        else lDemanda.OwnerId = lUser.Gerente_regional__c;
        lDemanda.Subject = 'Inserir Tipo de Verba';
      }
      else
      {
        lDemanda.RecordTypeId = lRecTypeDA;
        lDemanda.OwnerId = lDAUser.id;
        lDemanda.Subject = 'Gerar D.A';
      }
      if ( lDemanda.OwnerId == null ) lDemanda.OwnerId = c.ownerId;
    }
  }
  if ( lListCase.size() > 0 ) insert lListCase;

  }

}