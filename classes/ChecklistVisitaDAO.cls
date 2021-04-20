/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* Classe que realiza funções DML no objeto Checklist Visita.
*
* NAME: ChecklistVisitaDAO.cls
* AUTHOR: CARLOS CARVALHO                          DATE: 04/05/2012 
*
* MAINTENANCE: 
* AUTHOR:                                          DATE: 
********************************************************************************/
public with sharing class ChecklistVisitaDAO 
{
  //DECLARAÇÃO DE VARIAVEIS
  private List< Id > listIdsRecType = getIds();
  
  private static final ChecklistVisitaDAO instance = new ChecklistVisitaDAO();
  
  //Construtor privado para impedir a criação de instâncias dessa classe.
  private ChecklistVisitaDAO()
  {
  }
  
  //Método responsável por prover a instância dessa classe.
  public static ChecklistVisitaDAO getInstance()
  {
    return instance;
  }
  
  //Recupera os tipos de registro do objeto
  private List< Id > getIds(){
  	  
  	  List< Id > listRecTypeId = new List< Id >();
	  listRecTypeId.add( RecordTypeForTest.getRecType( 'Checklist_de_visita__c' , 'Indireto'));
	  listRecTypeId.add( RecordTypeForTest.getRecType( 'Checklist_de_visita__c' , 'Off_Trade'));
	  listRecTypeId.add( RecordTypeForTest.getRecType( 'Checklist_de_visita__c' , 'On_Trade'));
	  
	  return listRecTypeId;
  }
  
  //Método responsável por recuperar uma lista de Checklist que retorna com valores de campos contidos na conta.
  //@param listIdsChecklist (Ids dos checklist que serão recuperados).
  public List<Checklist_de_visita__c> getListChecklistInfoAccount(List<String> listIdsChecklist){
    List<Checklist_de_visita__c> listChecklist = null;
    
    listChecklist = [SELECT Id, Name, Visita__c, Visita__r.Tipo_de_Visita__c, 
        Visita__r.Conta__r.Client_code_AN8__c, Visita__r.Conta__r.Customer_Organization__c,
        Visita__r.Conta__r.Customer_Organization__r.CodDefUsuario__c, Visita__r.Conta__r.Customer_Flag__c, 
        Visita__r.Conta__r.Customer_Flag__r.CodDefUsuario__c,Visita__r.Conta__r.Sub_Channel_Rating__c,
        Visita__r.Conta__r.Sub_Channel_Rating__r.CodDefUsuario__c, Visita__r.Conta__r.Revenue_UF__c,
        Visita__r.Conta__r.Channel__c, Visita__r.Conta__r.Sub_Channel__c,Visita__r.Conta__r.id,
        Visita__r.Conta__r.Channel_Type__c,Visita__r.Conta__r.Receive_Attach_Sellout__c,
        Visita__r.Conta__r.Regional__c, Visita__r.Conta__r.OwnerId,Visita__r.Conta__c
        FROM Checklist_de_visita__c WHERE Id =: listIdsChecklist AND RecordTypeId =: listIdsRecType];
  
    return listChecklist;
  }
}