/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* Realiza funções DML no objeto Opportunity.
* NAME: OportunidadeDAO.cls
* AUTHOR: CARLOS CARVALHO                         DATE: 15/05/2012
*
* MAINTENANCE
* AUTHOR: CARLOS CARVALHO                         DATE: 11/01/2013
* DESC: CORRIGIDO CABEÇALHO DA CLASSE. E INSERIDO COMETÁRIO NO MÉTODO
* getListOpportunity
*
* AUTHOR: CARLOS CARVALHO                         DATE: 15/01/2013
* DESC: INSERIDO VALIDAÇÃO DE TIPOS DE REGISTRO.
********************************************************************************/
/********************************************************************************
*                       
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 07/11/2016
*
********************************************************************************/
public with sharing class OportunidadeDAO 
{
  private static final OportunidadeDAO instance = new OportunidadeDAO();
  
  private Set< Id > setRecTypeOpp = getIds();
    
  private Set< Id > getIds(){
    if(!Utils.wasMigrationDone('1'))  {
      Set< Id > lSet = new Set< Id >();
      lSet.add( RecordTypeForTest.getRecType( 'Opportunity', 'Bloqueia_alteracao' ) );
      lSet.add( RecordTypeForTest.getRecType( 'Opportunity', 'Bloqueia_alteracao_do_cabecalho' ) );
      lSet.add( RecordTypeForTest.getRecType( 'Opportunity', 'Nova_oportunidade' ) );
      return lSet;
    }
    //MIGRATED 07/11/2016
    else {
      Set< Id > lSet = new Set< Id >();
      lSet.add( RecordTypeForTest.getRecType( 'LAT_Opportunity__c', 'Bloqueia_alteracao' ) );
      lSet.add( RecordTypeForTest.getRecType( 'LAT_Opportunity__c', 'Bloqueia_alteracao_do_cabecalho' ) );
      lSet.add( RecordTypeForTest.getRecType( 'LAT_Opportunity__c', 'Nova_oportunidade' ) );
      return lSet;
    }
  }
    
  //Construtor privado para impedir a criação de instâncias dessa classe.
  private OportunidadeDAO()
  {
  }
  
  //Método responsável por prover a instância dessa classe.
  public static OportunidadeDAO getInstance()
  {
    return instance;
  }
  
  //RECUPERA UMA LISTA DE OPORTUNIDADES ATRAVÉS DE UMA LISTA DE IDS
  public List<Opportunity> getListOpportunity(List<String> aIdsOportunidades)
  {
    List<Opportunity> listOpportunity = [ SELECT Id,
					                          AccountId,
					                          Account.Channel__c,
					                          Account.Customer_Flag__r.Id,
					                          Account.Regional__r.Id,
					                          Account.Sub_Channel__c,
					                          OwnerId
					                          FROM Opportunity
					                          WHERE Id =: aIdsOportunidades
					                          AND RecordTypeId =: setRecTypeOpp
					                      ];
                      
    return listOpportunity;
  }

  public List<LAT_Opportunity__c> LAT_getListOpportunity(List<String> aIdsOportunidades)
  {
    List<LAT_Opportunity__c> listOpportunity = [ SELECT Id,
                                    LAT_Account__c,
                                    LAT_Account__r.Channel__c,
                                    LAT_Account__r.Customer_Flag__r.Id,
                                    LAT_Account__r.Regional__r.Id,
                                    LAT_Account__r.Sub_Channel__c,
                                    OwnerId
                                    FROM LAT_Opportunity__c
                                    WHERE Id =: aIdsOportunidades
                                    AND RecordTypeId =: setRecTypeOpp
                                ];
                      
    return listOpportunity;
  }
  
}