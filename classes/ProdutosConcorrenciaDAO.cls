/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* Classe que realiza funções DML no objeto Produtos da Concorrência.
*
* NAME: PagamentoDeletaPVTest.cls
* AUTHOR: CARLOS CARVALHO                           DATE: 07/05/2012
*
* MAINTENANCE
* AUTHOR: CARLOS CARVALHO                           DATE: 10/01/2013
* DESC: INSERIDO FUNCIONALIDADE QUE VALIDA O ID DO TIPO DE REGISTRO DOS OBJETOS.
********************************************************************************/
 /********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 18/11/2016
*
********************************************************************************/
public with sharing class ProdutosConcorrenciaDAO 
{

  private static final ProdutosConcorrenciaDAO instance = new ProdutosConcorrenciaDAO();
  private Id idRecTypePC = RecordTypeForTest.getRecType( 'Produto_Concorr_ncia__c' , 'BRA_Standard' );
  
  //Construtor privado para impedir a criação de instâncias dessa classe.
  private ProdutosConcorrenciaDAO()
  {
  }
  
  // Método responsável por prover a instância dessa classe.
  public static ProdutosConcorrenciaDAO getInstance()
  {
    return instance;
  }
  
  //Recupera um lista de Produto_Concorr_ncia__c através do id do registro
  //@param listIdsProdutosConcorrencia
  public List< Produto_Concorr_ncia__c > getListProdutoConcorrenciaById(List<String> listIdsProdutosConcorrencia)
  {
      if(!Utils.wasMigrationDone('1')) {  
        List< Produto_Concorr_ncia__c > listProdutoConcorrencia = null;
        
        listProdutoConcorrencia = [ SELECT    Id, 
    					                      Name,
    					                      Checklist_de_visita__r.Visita__r.Conta__r.Client_code_AN8__c,  
    					                      Checklist_de_visita__r.Visita__r.Conta__r.Customer_Organization__c,
    					                      Checklist_de_visita__r.Visita__r.Conta__r.Customer_Organization__r.CodDefUsuario__c,
    					                      Checklist_de_visita__r.Visita__r.Conta__r.Customer_Flag__c,
    					                      Checklist_de_visita__r.Visita__r.Conta__r.Customer_Flag__r.CodDefUsuario__c,
    					                      Checklist_de_visita__r.Visita__r.Conta__r.Sub_Channel_Rating__c,
    					                      Checklist_de_visita__r.Visita__r.Conta__r.Sub_Channel_Rating__r.CodDefUsuario__c,
    					                      Checklist_de_visita__r.Visita__r.Conta__r.Revenue_UF__c,
    					                      Checklist_de_visita__r.Visita__r.Conta__r.Channel__c,
    					                      Checklist_de_visita__r.Visita__r.Conta__c,
    					                      Produto_PERNOD__r.Sku__c,
    					                      Range_Demantra_AT__c,
    					                      Range_Demantra_DE__c
    					                      FROM Produto_Concorr_ncia__c
    					                      WHERE Id =: listIdsProdutosConcorrencia
    					                      AND RecordTypeId =: idRecTypePC
    					                    ];
                        
        return listProdutoConcorrencia;
    }
    //MIGRATED 18/11/2016
    else {
        List< Produto_Concorr_ncia__c > listProdutoConcorrencia = null;
        
        listProdutoConcorrencia = [ SELECT    Id, 
                                    Name,
                                    Checklist_de_visita__r.Visita__r.Conta__r.Client_code_AN8__c,  
                                    Checklist_de_visita__r.Visita__r.Conta__r.Customer_Organization__c,
                                    Checklist_de_visita__r.Visita__r.Conta__r.Customer_Organization__r.CodDefUsuario__c,
                                    Checklist_de_visita__r.Visita__r.Conta__r.Customer_Flag__c,
                                    Checklist_de_visita__r.Visita__r.Conta__r.Customer_Flag__r.CodDefUsuario__c,
                                    Checklist_de_visita__r.Visita__r.Conta__r.Sub_Channel_Rating__c,
                                    Checklist_de_visita__r.Visita__r.Conta__r.Sub_Channel_Rating__r.CodDefUsuario__c,
                                    Checklist_de_visita__r.Visita__r.Conta__r.Revenue_UF__c,
                                    Checklist_de_visita__r.Visita__r.Conta__r.Channel__c,
                                    Checklist_de_visita__r.Visita__r.Conta__c,
                                    LAT_Product__r.LAT_Sku__c,
                                    Range_Demantra_AT__c,
                                    Range_Demantra_DE__c
                                    FROM Produto_Concorr_ncia__c
                                    WHERE Id =: listIdsProdutosConcorrencia
                                    AND RecordTypeId =: idRecTypePC
                                  ];
                        
        return listProdutoConcorrencia;      
    }
  }
  
  
}