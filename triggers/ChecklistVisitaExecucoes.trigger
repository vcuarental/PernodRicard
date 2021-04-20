/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
********************************************************************************
* 
* NAME: ChecklistVisitaExecucoes.trigger
* AUTHOR:                                           DATE: 11/06/2012
*
* MAINTENANCE: INSERIDO MÉTODO RecordTypeForTest.
* AUTHOR: CARLOS CARVALHO                           DATE: 07/01/2013
*******************************************************************************/
trigger ChecklistVisitaExecucoes on Checklist_de_visita__c (after insert) {

//    Check if this trigger is bypassed by SESAME (data migration Brazil)
if((UserInfo.getProfileId()!='00eM0000000QNYPIA4') && (UserInfo.getProfileId()!= '00eD0000001AnFlIAK')) {

  List< String > lCheckListID = new List< String >();
  Set< Id > setRecTypeId = Global_RecordTypeCache.getRtIdSet('Checklist_de_visita__c', new set<String>{'Indireto', 'Off_Trade', 'On_Trade'});
  
  for ( Checklist_de_visita__c lCheck: trigger.new )
  {
    if ( !lCheck.Dev_Controle_Planejamento__c && setRecTypeId.contains( lCheck.RecordTypeId ) )
      lCheckListID.add( lCheck.Id );
  }
  



  system.debug('#Size: ' + lCheckListID.size());
  if ( lCheckListID.size() == 0 ) return;
  
  List< String > lAccIdList = new List< String >();
  List< Checklist_de_visita__c > lCheckList = ChecklistVisitaDAO.getInstance().getListChecklistInfoAccount( lCheckListID );
  for ( Checklist_de_visita__c lCheck: lCheckList )
  {
    lAccIdList.add( lCheck.Visita__r.Conta__r.id );
  }
  ChecklistVisitaCria lPreencheCheckList = new ChecklistVisitaCria( lCheckListID, lAccIdList );
  
  try{
    insert lPreencheCheckList.checkListContraList;
    insert lPreencheCheckList.checkListExpList;
    //insert lPreencheCheckList.checkListConcList;
    insert lPreencheCheckList.checkListSelloutList;
  }
  catch( DMLException e ){ System.debug( e.getMessage() ); }
  }
}