/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* Classe que realiza funções DML no objeto Rateio_do_Contrato__c.
* NAME: RateioContratoDAO.cls
* AUTHOR: CARLOS CARVALHO                           DATE: 14/09/2012
*
* MAINTENANCE
* AUTHOR: CARLOS CARVALHO                           DATE: 11/01/2013
* DESC: INSERIDO FUNCIONALIDADE QUE VALIDA O ID DO TIPO DE REGISTRO DOS OBJETOS.
********************************************************************************/
public with sharing class RateioContratoDAO {
    
    private static final RateioContratoDAO instance = new RateioContratoDAO();
    private Id idRecTypeRC = RecordTypeForTest.getRecType( 'Rateio_do_Contrato__c', 'BRA_Standard' );
    
    
    //Construtor privado para impedir a criação de instâncias dessa classe.
    private RateioContratoDAO()
    {
    }
    
    //Método responsável por prover a instância dessa classe.
    public static RateioContratoDAO getInstance()
    {
        return instance;
    }
    
    //
    public List< Rateio_do_Contrato__c > getListRateioByContractId( String aContractId )
    {
      List< Rateio_do_Contrato__c > lList = new List< Rateio_do_Contrato__c >();
      lList = [ Select Id, 
                       Perc_de_Rateio__c, 
                       Total_Contrato__c,
                       LAT_Contract__c/*, 
                       Produto__r.Scheduler_C__c*/ 
                       FROM Rateio_do_Contrato__c
                       WHERE LAT_Contract__c =: aContractId
                       AND RecordTypeId =: idRecTypeRC
               ];
               
      return lList;
    }
}