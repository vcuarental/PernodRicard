/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* Classe que realiza funções DML no objeto CustomerRSPProfile.
*
* NAME: CustomerRSPProfileDAO.cls
* AUTHOR: CARLOS CARVALHO                           DATE: 08/05/2012
*
* MAINTENANCE: INSERIDO LÓGICA DE VALIDAÇÃO DO TIPO DE REGISTRO DOS OBJETOS.
* AUTHOR: CARLOS CARVALHO                           DATE: 10/01/2013 
********************************************************************************/
public with sharing class CustomerRSPProfileDAO 
{
  private static final CustomerRSPProfileDAO instance = new CustomerRSPProfileDAO();
  private Id idRecTypeCP = RecordTypeForTest.getRecType( 'CustomerRSPProfiles__c', 'BRA_Standard' );
   
  /*Construtor privado para impedir a criação de instâncias dessa classe.*/
  private CustomerRSPProfileDAO()
  {
  }
  
  /**
  * Método responsável por prover a instância dessa classe.
  */
  public static CustomerRSPProfileDAO getInstance()
  {
    return instance;
  }
  
  /**
   * Método responsável por recuperar uma lista de CustomerRSPProfile.
   */
   
   public List<CustomerRSPProfiles__c> getListCustomerRSPProfiles()
   {
    List<CustomerRSPProfiles__c> listCustomProfile = null;
    
    listCustomProfile = [SELECT Id, 
                  profile_id__c, 
                  canal__c,
                  AN8__c,
                  codigo_bandeira__c, 
                  codigo_organizacao__c,
                  uf_an8__c 
                  FROM CustomerRSPProfiles__c
                  WHERE RecordTypeId =: idRecTypeCP
              ];
    
    return listCustomProfile;
   }
  
}