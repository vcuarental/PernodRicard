/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* Classe que realiza funções DML no objeto CustomerRSPProducts__c.
*
* NAME: CustomerRSPProductsDAO.cls
* AUTHOR: CARLOS CARVALHO                           DATE: 10/01/2013
*
* MAINTENANCE: INSERIDO LÓGICA DE VALIDAÇÃO DO TIPO DE REGISTRO DOS OBJETOS.
* AUTHOR: CARLOS CARVALHO                           DATE: 10/01/2013 
********************************************************************************/
public with sharing class CustomerRSPProductsDAO 
{
  private static final CustomerRSPProductsDAO instance = new CustomerRSPProductsDAO();
  private Id idRecTypeCP = RecordTypeForTest.getRecType( 'CustomerRSPProducts__c', 'BRA_Standard' );
  
  //Construtor privado para impedir a criação de instâncias dessa classe
  private CustomerRSPProductsDAO()
  {
  }
  
  /**
  * Método responsável por prover a instância dessa classe.
  */
  public static CustomerRSPProductsDAO getInstance()
  {
    return instance;
  }
  
  /**
   * Método responsável por recuperar uma lista de RSP Products.
   */
   
   public List<CustomerRSPProducts__c> getListCustomerRSPProducts( Decimal aProfIDs )
   {
    List<CustomerRSPProducts__c> listCustomProducts = null;
    
    listCustomProducts = [Select Id,
                  Profile2_Id__c, 
                  sku__c, 
                  price_rsp_min__c, 
                  price_rsp_max__c, 
                  price_rsp__c 
                  From CustomerRSPProducts__c where Profile2_Id__c =: aProfIDs
                  AND RecordTypeId =: idRecTypeCP
              ];
    
    return listCustomProducts;
   }
  
}