/*******************************************************************************
*                     Copyright (C) 2013 - Cloud2b
*-------------------------------------------------------------------------------
*
* Trigger que atribui o Owner do Parent da Conta da Visita do Planejamento como 
* KAM do planejamento.
* NAME: PlanejamentoAtribuiKam.trigger
* AUTHOR: ROGERIO ALVARENGA                         DATE: 18/02/2013
*
* AUTHOR: MARCOS DOBROWOLSKI                        DATE: 19/03/2013
* DESC: Alterações para que fosse atribuidos apenas os KAMs das contas 
*       relacionadas ao planejamento em questão.
*******************************************************************************/

trigger PlanejamentoAtribuiKam on Planejamento__c (before update) {

//    Check if this trigger is bypassed by SESAME (data migration Brazil)
if((UserInfo.getProfileId()!='00eM0000000QNYPIA4') && (UserInfo.getProfileId()!= '00eD0000001AnFlIAK')) {
  
  Id idRecTypePlan = RecordTypeForTest.getRecType( 'Planejamento__c' , 'BRA_Standard' );
  
  // Set de tipos de subchannel utilizados
// 20131202 - LF - Eliminação do processo de HV
//   Set<String> setSubChannel = new Set<String>{'KA', 'C&C Makro', 'C&C Atacadao','Varejo Regional'};
    Set<String> setSubChannel = new Set<String>{'X'};
  
  set<Id> setIdPlanejamento = new set<Id>();
  for (Planejamento__c p : Trigger.new ){
    if( p.RecordTypeId != idRecTypePlan ) continue;
    setIdPlanejamento.add( p.id );
  }

  // Lista de visitas dos planejamentos
  list< Visitas__c > lstVisitas = [SELECT Id, Conta__c, Planejamento__c FROM Visitas__c 
                                   WHERE Planejamento__c = :setIdPlanejamento];

  if ( lstVisitas.isEmpty() ) return;
  
  // Recupera as contas vinculadas ao faturamento
  set<Id> setIdContas = new set<Id>();
  for ( Visitas__c visita : lstVisitas ){
    setIdContas.add( visita.Conta__c ); // Tenho o Id de todas as contas
  }

  Map< Id, Account > mapContas = new Map< Id, Account >(
                                 [SELECT Id, ParentId, OwnerId, Sub_Channel_Rating__r.Name, Parent.OwnerId FROM Account 
                                  WHERE Id = :setIdContas] );
  
  // Para cada visita que tenho no mapa
  Map<Id, list<Account>> mapPlanConta = new map<Id, list<Account>>();

    for ( Visitas__c vis : lstVisitas ){
      List< Account > lstConta = mapPlanConta.get( vis.Planejamento__c );
      if ( lstConta == null ) {
        lstConta = new List< Account >();
        mapPlanConta.put( vis.Planejamento__c, lstConta );
      }
      Account lAcc = mapContas.get( vis.Conta__c );
      if ( lAcc != null ) lstConta.add( lAcc );
    }
  
  for (Planejamento__c p : trigger.new){
    if( p.RecordTypeId != idRecTypePlan ) continue;
    // Zera todos os KAM's
    p.KAM1__c = null;
    p.KAM2__c = null;
    p.KAM3__c = null;
    p.KAM4__c = null;
    p.KAM5__c = null;
    p.KAM6__c = null;
    p.KAM7__c = null;
    p.KAM8__c = null;
    p.KAM9__c = null;
    p.KAM10__c = null;
    
    Set< Id > setKam = new Set< Id >();
    
    // Recupera o Id do Gerente Regional do Parent de cada conta e atribui para cada KAM
    for ( Account acc : mapPlanConta.get( p.Id ) ){
      if( acc != null && acc.ParentId != null && setSubChannel.contains( acc.Sub_Channel_Rating__r.Name ) ){
        if ( setKam.contains( acc.Parent.OwnerId ) ) continue; // Caso esse Usuário já tenha sido atribuído como KAM, sai
        if ( acc.Parent.OwnerId == p.OwnerId ) continue; // Caso o proprietário do planejamento também seja proprietario do pai da conta, sai.
        setKam.add( acc.Parent.OwnerId );
        
        if (p.KAM1__c == null) p.KAM1__c = acc.Parent.OwnerId;
        else 
        if (p.KAM2__c == null) p.KAM2__c = acc.Parent.OwnerId;
        else 
        if (p.KAM3__c == null) p.KAM3__c = acc.Parent.OwnerId;
        else 
        if (p.KAM4__c == null) p.KAM4__c = acc.Parent.OwnerId;
        else
        if (p.KAM5__c == null) p.KAM5__c = acc.Parent.OwnerId;
        else
        if (p.KAM6__c == null) p.KAM6__c = acc.Parent.OwnerId;
        else
        if (p.KAM7__c == null) p.KAM7__c = acc.Parent.OwnerId;
        else
        if (p.KAM8__c == null) p.KAM8__c = acc.Parent.OwnerId;
        else
        if (p.KAM9__c == null) p.KAM9__c = acc.Parent.OwnerId;
        else
        if (p.KAM10__c == null) p.KAM10__c = acc.Parent.OwnerId;
        
        p.Customer_is_KA__c = true;
      }
    }
  }
 }

}