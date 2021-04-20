/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* Classe que realiza funções DML no objeto Cl_usulas_do_Contrato__c.
* NAME: ClausulaContratoDAO.cls
* AUTHOR: CARLOS CARVALHO                           DATE: 01/08/2012
*
* MAINTENANCE
* AUTHOR:                                           DATE: 
********************************************************************************/
public with sharing class ClausulaContratoDAO {
  
  private static final ClausulaContratoDAO instance = new ClausulaContratoDAO();
  
  private Id idRecTypeCC = RecordTypeForTest.getRecType( 'Cl_usulas_do_Contrato__c', 'Clausulas_do_Contrato');
  
  private ClausulaContratoDAO()
  {
  }
  
  public static ClausulaContratoDAO getInstance()
  {
    return instance;
  }
  
  public List<Cl_usulas_do_Contrato__c> getListClausulaContratoByIdContrato( String idContrato){
    
    List<Cl_usulas_do_Contrato__c> listClausula = new List<Cl_usulas_do_Contrato__c>();
    
    listClausula = [Select  Id,
                C_digo__c,
                Tipo_de_Calculo__c,
                Codigo_Base_de_Calculo__c,
                Percentual__c,
                Valor__c,
                Conta_de_Debito__c,
                Conta_de_Credito__c,
                CreatedById,
                LastModifiedById,
                Status__c,
                Descricao__c,
                Contrato__c
                From Cl_usulas_do_Contrato__c
                Where Contrato__c =: idContrato
                AND RecordTypeID =: idRecTypeCC
            ];
            
    return listClausula;
  }
}