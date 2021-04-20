/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* Classe que realiza funções DML no objeto produtos do catálogo de preços.
*
* NAME: PricebookEntryDAO.cls
* AUTHOR: CARLOS CARVALHO                           DATE: 15/05/2013
*
* MAINTENANCE
* AUTHOR: CARLOS CARVALHO                           DATE: 11/01/2013
* DESC: ALTERADO CABEÇALHO PARA NOVO PADRÃO.
********************************************************************************/
public with sharing class PricebookEntryDAO 
{

  private static final PricebookEntryDAO instance = new PricebookEntryDAO();
   
  //Construtor privado para impedir a criação de instâncias dessa classe.
  private PricebookEntryDAO()
  {
  }
  
  //Método responsável por prover a instância dessa classe.
  public static PricebookEntryDAO getInstance()
  {
    return instance;
  }
  
  // RECUPERA UMA LISTA DE PRICEBOOKENTRY ATRAVÉS DO ID DO REGISTRO
  // @param alistIdsPricebookEntry
  public List<PricebookEntry> getListPricebookEntry(List<String> alistIdsPricebookEntry)
  {
    List<PricebookEntry> listPBE = [Select Id, Product2.SKU__c From PricebookEntry Where Id =: alistIdsPricebookEntry];
    return listPBE;
  }
}