/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* Classe que realiza funções DML no objeto Planejamento.
*
* NAME: PlanejamentoDAO.cls
* AUTHOR: CARLOS CARVALHO                           DATE: 09/05/2012
*
* MAINTENANCE
* AUTHOR: CARLOS CARVALHO                           DATE: 16/01/2013
* DESC: INSERIDO FUNCIONALIDADE QUE VALIDA O ID DO TIPO DE REGISTRO DOS OBJETOS.
********************************************************************************/
public with sharing class PlanejamentoDAO 
{

  private static final PlanejamentoDAO instance = new PlanejamentoDAO();
  private Id idRecTypePlan = RecordTypeForTest.getRecType( 'Planejamento__c', 'BRA_Standard' );
  
  //Construtor privado para impedir a criação de instâncias dessa classe.
  private PlanejamentoDAO()
  {
  }
  
  //Método responsável por prover a instância dessa classe.
  public static PlanejamentoDAO getInstance()
  {
    return instance;
  }
  
  
  // Description: Recupera todos os planejamentos atraves do ID dentro da lista passada como parametro. 
  // @param idsPlanejamento (IDS do Planejamento).
  public List<Planejamento__c> getListPlanejamento(List<String> idsPlanejamento)
  {
    //Declaração de variáveis.
    List<Planejamento__c> listPlanejamento = null;
    
    listPlanejamento = [Select  Id
                  From Planejamento__c 
                  Where Id =: idsPlanejamento
                  AND RecordTypeId =: idRecTypePlan
            ];
            
    return listPlanejamento;
  }
  
  
  // Description: Recupera todos os planejamentos que ainda não tiveram a ultima aprovação. 
  // @author Carlos Carvalho
  public List<Planejamento__c> getListPlanejamentoEmAndamento()
  {
    //Declaração de variáveis.
    List<Planejamento__c> listPlanejamento = null;
    
    listPlanejamento = [Select  Id, OwnerId
                  From Planejamento__c 
                  Where aprovado_semana_4__c = false
                  AND RecordTypeId =: idRecTypePlan
            ];
            
    return listPlanejamento;
  }
  
}