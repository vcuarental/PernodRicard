/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* REALLIZA FUNÇÕES DML NO OBJETO Cota_regional__c
* NAME: CotasRegionaisDAO.cls
* AUTHOR: CARLOS CARVALHO                           DATE: 15/05/2012
*
*
* MAINTENANCE: INSERIDO LÓGICA DE VALIDAÇÃO DO TIPO DE REGISTRO DO OBJETO.
* AUTHOR: CARLOS CARVALHO                           DATE: 10/01/2013 
********************************************************************************/
public with sharing class CotasRegionaisDAO 
{

  private static final CotasRegionaisDAO instance = new CotasRegionaisDAO();
  
  private Id idRecTypeCR = RecordTypeForTest.getRecType( 'Cota_regional__c', 'BRA_Standard' );
  
  //Construtor privado para impedir a criação de instâncias dessa classe.
  private CotasRegionaisDAO()
  {
  }
  
  //Método responsável por prover a instância dessa classe.
  public static CotasRegionaisDAO getInstance()
  {
    return instance;
  }
  
  //Recupera cotas regionais por SKU, REGIONAL, EXECUTIVO, BANDEIRA, CANAL, SUB-CANAL, EXECUTIVO e CLIENTE.
  //@param aListSku    (SKU DO PRODUTO)
  public List<Cota_regional__c> getListCotasRegionais(List<String> aListSku)
  {
    List<Cota_regional__c> listCotasRegionais = null;
    
    listCotasRegionais = [SELECT  Id,
                                  SKU__c,
                                  Regional__c,
                                  Executivo__c,
                                  Sub_canal__c,
                                  Canal__c,
                                  Bandeira_referencia__c,
                                  Consumo_de_cota__c,
                                  Saldo_de_cota__c,
                                  Cliente__c,
                                  Cota_utilizada__c,
                                  Bandeira_regional__c,
                                  Cota__c,
                                  Criterio_regional_de_cota__c,
                                  Criterio_regional_de_cota__r.Cota_nacional__r.Criterio_nacional_de_cota__r.SKU__r.Nome_do_produto__c
                                  FROM Cota_regional__c
                                  WHERE SKU__c =: aListSku
                                  AND RecordTypeId =: idRecTypeCR
                        ];
                        
   return listCotasRegionais;
  }
  
}