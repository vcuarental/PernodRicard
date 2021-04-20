/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* Classe que realiza funções DML no objeto Parametro Produto Concorrência.
*
* NAME: ParametroProdutoConcorrenciaDAO.cls
* AUTHOR: CARLOS CARVALHO                           DATE: 02/05/2012
*
* MAINTENANCE
* AUTHOR: CARLOS CARVALHO                           DATE: 10/01/2013
* DESC: ALTERADO CABEÇALHO PARA NOVO PADRÃO.
*
* AUTHOR: CARLOS CARVALHO                         DATE: 15/01/2013
* DESC: INSERIDO LÓGICA DE VALIDAÇÃO DO TIPO DE REGISTRO DOS OBJETOS.
********************************************************************************/
 /********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 17/11/2016
*
********************************************************************************/
public with sharing class ParametroProdutoConcorrenciaDAO 
{
  private static final ParametroProdutoConcorrenciaDAO instance = new ParametroProdutoConcorrenciaDAO();

  //Construtor privado para impedir a criação de instâncias dessa classe  
  private ParametroProdutoConcorrenciaDAO()
  {
  }
  
  private Set< Id > setRecTypePPC = getIds();
  
  private Set< Id > getIds(){
    Set< Id > lSet = new Set< Id >();
    lSet.add( RecordTypeForTest.getRecType('Par_metro_Produto_Concorr_ncia__c', 'Produtos_Concorr_ncia' ) );
    lSet.add( RecordTypeForTest.getRecType('Par_metro_Produto_Concorr_ncia__c', 'Sellout' ) );
    return lSet;
  }
  
  //Método responsável por prover a instância dessa classe.
  public static ParametroProdutoConcorrenciaDAO getInstance()
  {
    return instance;
  }
  
  //Método que retorna uma lista de parametros de produtos de concorrência.
  //@author Carlos Carvalho
  public List<Par_metro_Produto_Concorr_ncia__c> getListParametros()
  {
        if(!Utils.wasMigrationDone('1')) {   
            List<Par_metro_Produto_Concorr_ncia__c> listParametro = null;
            
            listParametro = [SELECT Id, 
                                    Canal__c, 
                                    Sub__c,
                                    Regional__c, 
                                    Produto_Concorrencia__c, 
                                    Produto_Pernod__c, 
                                    Marca__c, 
                                    RecordTypeId,
                                    SKU__c 
                                    FROM Par_metro_Produto_Concorr_ncia__c
                                    WHERE RecordTypeId =: setRecTypePPC
                                ];
            
            return listParametro;
        }
        //MIGRATED 17/11/2016
        else {
            List<Par_metro_Produto_Concorr_ncia__c> listParametro = null;
            
            listParametro = [SELECT Id, 
                                    Canal__c, 
                                    Sub__c,
                                    Regional__c, 
                                    Produto_Concorrencia__c, 
                                    LAT_Product__c, 
                                    Marca__c, 
                                    RecordTypeId,
                                    LAT_SKU__c 
                                    FROM Par_metro_Produto_Concorr_ncia__c
                                    WHERE RecordTypeId =: setRecTypePPC
                                ];
            
            return listParametro;          
        }
  }
}