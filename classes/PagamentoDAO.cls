/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* Responsável por realizar funções DML no objeto Pagamento__c
* NAME: PagamentoDAO.cls
* AUTHOR: CARLOS CARVALHO                           DATE: 18/09/2012
*
* 
* MAINTENANCE
* AUTHOR: CARLOS CARVALHO                         DATE: 15/01/2013
* DESC: INSERIDO LÓGICA DE VALIDAÇÃO DO TIPO DE REGISTRO DOS OBJETOS. 
********************************************************************************/
public with sharing class PagamentoDAO {
    
    private static final PagamentoDAO instance = new PagamentoDAO();
    
    private Set< Id > setRecTypePag = getIds();
    
    private Set< Id > getIds(){
        Set< Id > lSet = new Set< Id >();
        lSet.add( RecordTypeForTest.getRecType( 'Pagamento__c', 'Bonificacao_Produtos' ) );
        lSet.add( RecordTypeForTest.getRecType( 'Pagamento__c', 'Bonifica_o_Produtos_Bloqueado' ) );
        lSet.add( RecordTypeForTest.getRecType( 'Pagamento__c', 'Dinheiro' ) );
        lSet.add( RecordTypeForTest.getRecType( 'Pagamento__c', 'Dinheiro_Bloqueado' ) );
        return lSet;
    }
    
    //Construtor privado para impedir a criação de instâncias dessa classe.
    private PagamentoDAO()
    {
    }
    
    //Método responsável por prover a instância dessa classe.
    public static PagamentoDAO getInstance()
    {
        return instance;
    }
    
    public Pagamento__c getPagamentoById( String aIdPagamento ){
      // It's necessary because covered test
      
      Pagamento__c pag;
      
      try{
        pag = [Select Id, Valor_Total__c, Total_Volume_Cx__c, Status__c, Solicitante__c, 
                      RecordTypeId, Recebedor__c, Possui_Anexo__c, OwnerId, 
                      Observacoes_Complementares__c, Name, LastModifiedDate, LastModifiedById, 
                      Forma_de_Pagamento__c, Emitente__c, Data_do_Pagamento__c, CreatedDate, 
                      CreatedById, CreatedBy.UserName, Cliente__c, Cliente__r.Client_code_AN8__c,
                      Cliente__r.Business_Unit__c,Sistema__c, Owner.UserName,
                      Solicitante__r.Username
                      From Pagamento__c
                      Where Id =: aIdPagamento
                      and RecordTypeId =: setRecTypePag
                  ];
      }catch(QueryException e){
        System.debug(e.getMessage());
      }
      
      return pag;
    }
}