/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* Cria o checklist de produtos quando o planejamento foi aprovado.
* NAME: PlanejamentoVisitasAprovacao.trigger
* AUTHOR: ROGERIO ALVARENGA                        DATE: 09/05/2012 
*
* MAINTENANCE: 
* AUTHOR:                                          DATE:
********************************************************************************/
trigger PlanejamentoVisitasAprovacao on Planejamento__c (after update) {

//    Check if this trigger is bypassed by SESAME (data migration Brazil)
if((UserInfo.getProfileId()!='00eM0000000QNYPIA4') && (UserInfo.getProfileId()!= '00eD0000001AnFlIAK')) {
 
/*  Map< String, Planejamento__c > lPlanejamento = new Map< String, Planejamento__c >();
  List< String > lPlanejOwnerId = new List< String >();
  List< String > lPlanejId = new List< String >();

  for ( Planejamento__c p : trigger.new )
  {
    if ( !p.Aprovado_semana_1__c || trigger.oldMap.get( p.id ).Aprovado_semana_1__c ) continue;
    lPlanejOwnerId.add( p.OwnerId );
    lPlanejId.add( p.id );
    lPlanejamento.put( p.OwnerId, p );
  }
  
  if ( lPlanejOwnerId.size() == 0 ) return;
  
  Map< String, Id > lMap = new Map< String, Id >();  
  lMap.put( 'Off Trade', RecordTypeForTest.getRecType( 'Checklist_de_visita__c', 'Off_Trade' ) );
  lMap.put( 'On Trade', RecordTypeForTest.getRecType( 'Checklist_de_visita__c', 'On_Trade' ) );
  lMap.put( 'Indireto', RecordTypeForTest.getRecType( 'Checklist_de_visita__c', 'Indireto' ) );
  
  List< Checklist_de_visita__c > lCheckList = new List< Checklist_de_visita__c >();
  List< Visitas__c > lListaVisita = VisitasDAO.getInstance().getListVisitasByPlanejamento( lPlanejId );
  for ( Visitas__c lVisita : lListaVisita )
  {
    Checklist_de_visita__c check = new Checklist_de_visita__c();
    check.visita__c = lVisita.Id;
    check.Dev_Controle_Planejamento__c = true;
    if ( lVisita.Conta__r.Channel_Type__c != null && lVisita.Conta__r.Channel_Type__c.equalsIgnoreCase( 'Indireto' )
    && lVisita.Conta__r.Channel__c.equalsIgnoreCase( 'Off Trade' ) )
    {
      check.recordTypeId = lMap.get( lVisita.Conta__r.Channel_Type__c );
    }
    else
    {
      check.recordTypeId = lMap.get( lVisita.Conta__r.Channel__c );
    }
    if ( check.recordTypeId != null )
      lCheckList.add( check );
  }
  
  //Verifica se existe checklist para serem inseridas no ambiente.
  if ( lCheckList.size() == 0 ) return;
  try{
    insert lCheckList;
  }
  catch( DMLException e ){
    System.debug( e.getMessage() );
    return;
  }
  
  //Para cada iteração em listChecklist é atribuido os Ids contidos nessa lista para uma segunda lista que será o parametro para um select.
  List< String > lCheckListID = new List< String >();
  for ( Checklist_de_visita__c lCheck: lCheckList )
  {
    lCheckListID.add( lCheck.Id );
  }
  
  //Recupera todas as contas que possuem proprietarios que estão dentro da lista de proprietarios dos planejamentos.
  List< Account > lAccountList = AccountDAO.getInstance().getListAccountByIdsOwners( lPlanejOwnerId );

  List< String > lAccIdList = new List< String >();
  for ( Account lAcc : lAccountList )
  {
    lAccIdList.add( lAcc.id );
  }
  ChecklistVisitaCria lPreencheCheckList = new ChecklistVisitaCria( lCheckListID, lAccIdList );
  try{
    insert lPreencheCheckList.checkListContraList;
    insert lPreencheCheckList.checkListExpList;
    insert lPreencheCheckList.checkListConcList;
    insert lPreencheCheckList.checkListSelloutList;
  }
  catch( DMLException e ){
    System.debug( e.getMessage() );
  }
  */
}
}