/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* Responsável por realizar funções DML no objeto Pagamento_da_Verba__c
* NAME: PagamentoVerbaDAO.cls
* AUTHOR: CARLOS CARVALHO                           DATE: 18/09/2012
*
* MAINTENANCE
* AUTHOR: CARLOS CARVALHO                         DATE: 15/01/2013
* DESC: INSERIDO LÓGICA DE VALIDAÇÃO DO TIPO DE REGISTRO DOS OBJETOS.
********************************************************************************/
 /********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 18/11/2016
*
********************************************************************************/
public with sharing class PagamentoVerbaDAO {
    
    private static final PagamentoVerbaDAO instance = new PagamentoVerbaDAO();
    
    private Set< Id > setRecTypePV = getIds();
    
    private Set< Id > getIds(){
    	Set< Id > lSet = new Set< Id >();
    	lSet.add( RecordTypeForTest.getRecType( 'Pagamento_da_Verba__c', 'Bonificacao_Produtos' ) );
        lSet.add( RecordTypeForTest.getRecType( 'Pagamento_da_Verba__c', 'Dinheiro' ) );
        return lSet;
    }
    
    //Construtor privado para impedir a criação de instâncias dessa classe.
    private PagamentoVerbaDAO()
    {
    }
    
    //Método responsável por prover a instância dessa classe.
    public static PagamentoVerbaDAO getInstance()
    {
        return instance;
    }
    
    //Retorna uma lista de pagaemntos de verba onde o pagamento relacionado
    //seja igual ao parametro passado ao método
    public List< Pagamento_da_Verba__c > getListPagVerbaByIdPgto( String aIdPgto ){
        if(!Utils.wasMigrationDone('1')) {  
            List< Pagamento_da_Verba__c > lList = new List< Pagamento_da_Verba__c >();
            
            lList = [SELECT Id, 
                            volume_a_pagar__c, 
                            valor_a_pagar__c, 
                            pagar_com_produto__c,
                            pagar_com_produto__r.SKU__c, 
                            Tipo_de_Registro_Pai_del__c, 
                            Status__c, 
                            Saldo_da_SV_Volume_cx__c, 
                            Sado_da_SV_R__c, 
                            RecordTypeId, 
                            Produto_da_SV__c, 
                            Pagamento__c, 
                            Numero_retorno_Pagamento__c,
                            Name, 
                            MensagemIntegracao__c, 
                            LastModifiedDate, 
                            LastModifiedById, 
                            Investimento_Bonifica_o_e_Pagamento__c, 
                            CreatedDate, 
                            CreatedById 
                            FROM Pagamento_da_Verba__c
                            WHERE Pagamento__c =: aIdPgto 
                            AND RecordTypeId =: setRecTypePV
                        ];
                        
              return lList;
        }
        //MIGRATED 18/11/2016
        else {
            List< Pagamento_da_Verba__c > lList = new List< Pagamento_da_Verba__c >();
            
            lList = [SELECT Id, 
                            volume_a_pagar__c, 
                            valor_a_pagar__c, 
                            LAT_Product__c,
                            LAT_Product__r.LAT_Sku__c,
                            Tipo_de_Registro_Pai_del__c, 
                            Status__c, 
                            Saldo_da_SV_Volume_cx__c, 
                            Sado_da_SV_R__c, 
                            RecordTypeId, 
                            Produto_da_SV__c, 
                            Pagamento__c, 
                            Numero_retorno_Pagamento__c,
                            Name, 
                            MensagemIntegracao__c, 
                            LastModifiedDate, 
                            LastModifiedById, 
                            Investimento_Bonifica_o_e_Pagamento__c, 
                            CreatedDate, 
                            CreatedById 
                            FROM Pagamento_da_Verba__c
                            WHERE Pagamento__c =: aIdPgto 
                            AND RecordTypeId =: setRecTypePV
                        ];
                        
              return lList;          
        }

  }
}