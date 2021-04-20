/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* Classe que realiza funções DML no objeto Compromissos.
*
* NAME: EventDAO.cls
* AUTHOR: CARLOS CARVALHO                          DATE: 09/05/2012 
*
* MAINTENANCE: REMOVIDO DATA E HORA DO SELECT MÉTODO getListEventByIdVisita.
* AUTHOR: CARLOS CARVALHO                          DATE: 24/09/2012
*
* MAINTENANCE: INSERIDO LÓGICA DE VALIDAÇÃO DO TIPO DE REGISTRO DOS OBJETOS.
* AUTHOR: CARLOS CARVALHO                         DATE: 14/01/2013 
********************************************************************************/
public with sharing class EventDAO 
{
  private static final EventDAO instance = new EventDAO();
  Id idRecTypeComp = RecordTypeForTest.getRecType('Event', 'Planejamentovisitas');
  
  /*Construtor privado para impedir a criação de instâncias dessa classe.*/
  private EventDAO()
  {
  }
  
  /**
  * Método responsável por prover a instância dessa classe.
  */
  public static EventDAO getInstance()
  {
    return instance;
  }
  
  /*
   * Recupera todos os compromissos referentes ao Owner do Planejamento que tenham data de visita igual ou maior que hoje.
   * @param listIdsPlanejamento
   */
  public List<Event> getListEventByIdVisita(List<String> listIdsVisitas)
  {
    List<Event> listCompromisso = null;
    
    listCompromisso = [ SELECT Id FROM Event WHERE WhatId =: listIdsVisitas 
        AND RecordTypeId =: idRecTypeComp ]; 
    
    return listCompromisso;
  }
}