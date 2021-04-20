/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* A PARTIR DA APROVAÇÃO DE UM PLANEJAMENTO SÃO GERADOS COMPROMISSOS PARA O 
* PROPRIETÁRIO DO PLANEJAMENTO, CRIANDO UM COMPROMISSO PARA CADA VISITA
* RELACIONADA AO PLANEJAMENTO.
*
* NAME: PlanejamentoCriaCompromissos.trigger
* AUTHOR: CARLOS CARVALHO                          DATE: 21/05/2012 
*
* MAINTENANCE: CORRIGIDO IF COM CAMPOS DE APROVAÇÃO.
* AUTHOR: CARLOS CARVALHO                          DATE: 24/09/2012
*
* MAINTENANCE: INSERIDO FUNCIONALIDADE QUE VALIDA O ID DO TIPO DE REGISTRO DOS OBJETOS.
* AUTHOR: CARLOS CARVALHO                               DATE: 08/01/2013
********************************************************************************/
trigger PlanejamentoCriaCompromissos on Planejamento__c (before update) {

//    Check if this trigger is bypassed by SESAME (data migration Brazil)
if((UserInfo.getProfileId()!='00eM0000000QNYPIA4') && (UserInfo.getProfileId()!= '00eD0000001AnFlIAK')) {
    
  //Declaração de variáveis.
  Integer listVisitasLength            = 0;
  Integer listPlanLength               = 0;
  String idCompromisso                 = null;
  List<RecordType> listRecType         = null;
  List<Event> listCompromissoForDelete = null;
  List<Visitas__c> listVisitas         = null;
  List<String> listIdsVisitas          = new List<String>();
  List<Event> listEvents               = new List<Event>();
  List<String> listIdsPlanejamento     = new List<String>();
  List<String> listDeveloperName       = new List<String>();
  Map<String, String> mapRecordType    = new Map<String, String>();
  set<Id> idRecTypePlan                = new set<Id>();
  
  idCompromisso = Global_RecordTypeCache.getRtId('Event'+'Planejamentovisitas');
  
  for(RecordType rt :Global_RecordTypeCache.getRtList('Planejamento__c')){
      if(rt.DeveloperName=='BRA_Standard'){
          idRecTypePlan.add(rt.Id);
      }else if(rt.DeveloperName=='PLV_Standard_AR'){
          idRecTypePlan.add(rt.Id);  
      }else if(rt.DeveloperName=='PLV_Standard_UY'){
          idRecTypePlan.add(rt.Id);
      }

  }
  
  //Armazena os objetos de Compromisso dentro de uma lista e os IDS de compromisso em outra lista.
  for( Planejamento__c plan : trigger.new )
  {
    if(!idRecTypePlan.contains(plan.RecordTypeId)) continue;
    
    Planejamento__c planoOld = trigger.oldMap.get(plan.Id);

    if(plan.RecordType.DeveloperName=='BRA_Standard'){
        if( ( plan.Aprovado_semana_1__c && !planoOld.Aprovado_semana_1__c ) || 
            ( plan.Aprovado_semana_2__c && !planoOld.Aprovado_semana_2__c ) || 
            ( plan.Aprovado_semana_3__c && !planoOld.Aprovado_semana_3__c ) || 
            ( plan.Aprovado_semana_4__c && !planoOld.Aprovado_semana_4__c ) )
        {
          listIdsPlanejamento.add( plan.Id );
        }
    }else{
        listIdsPlanejamento.add( plan.Id );
    }
  }
  
  if( listIdsPlanejamento != null && listIdsPlanejamento.size() > 0 )
  {
    
    //Recupera as visitas atraves do ID do planejamento.
    listVisitas = VisitasDAO.getInstance().getListVisitasByPlanejamento( listIdsPlanejamento );
    if( listVisitas != null && listVisitas.size() > 0 )
    {
      for( Visitas__c v : listVisitas )
      {
        listIdsVisitas.add( v.Id );
      }
      listCompromissoForDelete = EventDAO.getInstance().getListEventByIdVisita( listIdsVisitas );
      if( listCompromissoForDelete != null && listCompromissoForDelete.size() > 0 )
      {
        try { delete listCompromissoForDelete; } catch(DMLException e){ System.debug(e.getMessage()); }
      }
      
      for( Visitas__c visita : listVisitas )
      { 
        if( !visita.Visita_n_o_realizada__c )
        {
          String ldate = String.valueOf( System.today() );
          Datetime ltime = ( visita.Data_da_Visita__c == null || visita.Hora_da_Visita__c == null) ? datetime.valueof(string.valueof(ldate+' '+ '10:00:00')) : datetime.valueof(string.valueof(visita.Data_da_Visita__c) + ' ' + visita.Hora_da_Visita__c+ ':00');
          Event comp = new Event();
          comp.RecordTypeId   = idCompromisso;
          comp.WhatId       = visita.Id;
          comp.Subject      = 'Visita a cliente - ' + visita.Conta__r.Name; 
          comp.ActivityDatetime = ltime;
          comp.Type = 'Visit';
          comp.DurationInMinutes  = 60;
          comp.Description    = visita.Resumo_da_Visita__c;
          comp.OwnerId      = visita.Planejamento__r.OwnerId;
          listEvents.add(comp);
        }
      }
      try { insert listEvents; } catch(DMLException e){ System.debug('token error: '+e.getMessage()); }
      
    }
  }
 }
}