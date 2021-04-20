/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* Responsável por realizar funções DML no objeto Agrupamento_Fiscal_Year__c
* NAME: AgrupamentoFiscalYearDAO.cls
* AUTHOR: CARLOS CARVALHO                           DATE: 18/09/2012
*
* MAINTENANCE: INSERIDO FUNCIONALIDADE QUE VALIDA O ID DO TIPO DE REGISTRO DOS 
* OBJETOS.
* AUTHOR: CARLOS CARVALHO                               DATE: 09/01/2013 
********************************************************************************/
public with sharing class AgrupamentoFiscalYearDAO {
    
    private static final AgrupamentoFiscalYearDAO instance = new AgrupamentoFiscalYearDAO();
    private static Id idRecTypeAgr = RecordTypeForTest.getRecType('Agrupamento_Fiscal_Year__c', 'BRA_Standard');
    
    //Construtor privado para impedir a criação de instâncias dessa classe.
    private AgrupamentoFiscalYearDAO()
    {
    }
    
    //Método responsável por prover a instância dessa classe.
    public static AgrupamentoFiscalYearDAO getInstance()
    {
        return instance;
    }
    
    public List< Agrupamento_Fiscal_Year__c > getListAgrupByIdContractFiscalYear( List< String> aIdsContract, List< String > aListFiscalYears ){
      List< Agrupamento_Fiscal_Year__c > lList = new List< Agrupamento_Fiscal_Year__c >();
      
      lList = [ SELECT Id, valor_total__c, Volume_Total__c, Verba_Reservada__c, Verba_Normal__c, 
                       Verba_Extra__c, Verba_Adicional_VAD__c, Verba_Adiantada__c, 
                       Tipo_de_Workflow__c, Status_da_Integra_o__c, Sistema__c, OwnerId, 
                       Numero_da_RV_criada__c, Numero_da_D_A__c, Name, LastModifiedDate, 
                       LastModifiedById, CreatedDate, CreatedById, LAT_Contract__c, Ano_Fiscal__c 
                       FROM Agrupamento_Fiscal_Year__c
                       WHERE LAT_Contract__c =: aIdsContract
                       AND Ano_Fiscal__c =: aListFiscalYears
                       AND RecordTypeId =: idRecTypeAgr
               ];
      
      return lList;
    }
    
    public Agrupamento_Fiscal_Year__c getAgrupamentoById( String aIdAgrupamento ){
        Agrupamento_Fiscal_Year__c lAgr;
        try{
          lAgr = [ SELECT Id, valor_total__c, Volume_Total__c, Verba_Reservada__c, Verba_Normal__c, 
                          Verba_Extra__c, Verba_Adicional_VAD__c, Verba_Adiantada__c, 
                          Tipo_de_Workflow__c, Status_da_Integra_o__c, Sistema__c, OwnerId, 
                          Numero_da_RV_criada__c, Numero_da_D_A__c, Name, LastModifiedDate, 
                          LastModifiedById, CreatedDate, CreatedById, LAT_Contract__c, Ano_Fiscal__c,
                          Owner.Username 
                          FROM Agrupamento_Fiscal_Year__c
                          WHERE Id =: aIdAgrupamento
                          AND RecordTypeId =: idRecTypeAgr
                   ];
        }catch(QueryException e){
          system.debug(e.getMessage());
        }
        
        return lAgr;
    }
    
}