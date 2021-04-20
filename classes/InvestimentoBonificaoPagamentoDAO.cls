/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* Classe que realiza funções DML no objeto Investimento_Bonificacao_e_Pagamento__c.
* NAME: InvestimentoBonificaoPagamentoDAO.cls
* AUTHOR: CARLOS CARVALHO                           DATE: 01/08/2012
*
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
public with sharing class InvestimentoBonificaoPagamentoDAO {
    
    private static final InvestimentoBonificaoPagamentoDAO instance = new InvestimentoBonificaoPagamentoDAO();
    
    private Set< Id > setRecTypeIBP = getIds();
    
    private Set< Id > getIds(){
    	Set< Id > lSet = new Set< Id >();
    	lSet.add( RecordTypeForTest.getRecType( 'Investimento_Bonificacao_e_Pagamento__c', 'Bonificacao_Produtos' ) );
    	lSet.add( RecordTypeForTest.getRecType( 'Investimento_Bonificacao_e_Pagamento__c', 'Dinheiro' ) );
        return lSet;
    }
    
    //Construtor privado para impedir a criação de instâncias dessa classe.
    private InvestimentoBonificaoPagamentoDAO()
    {
    }
    
    //Método responsável por prover a instância dessa classe.
    public static InvestimentoBonificaoPagamentoDAO getInstance()
    {
        return instance;
    }
    
    public Investimento_Bonificacao_e_Pagamento__c getIBPById( String aIdIBP ){
        if(!Utils.wasMigrationDone('1')) { 
              Investimento_Bonificacao_e_Pagamento__c lIBP = new Investimento_Bonificacao_e_Pagamento__c();
              try{
                lIBP = [Select Volume_Cx__c, Verba_do_Sistema__c, Verba_Reservada__c, 
                Verba_Normal__c, Verba_Extra__c, Verba_Adiantada__c, Valor_R__c, Valor_Percebido__c, 
                 Tipo_de_Verba__c, SystemModstamp, Status_da_Verba__c, Sistema__c,
                ScheduleC_Bonificado__c, Saldo_R__c, Saldo_Caixas__c, RecordTypeId, Produto_Bonificado__r.SKU__c, 
                Primeiro_Pagamento__c, Perc_de_Rateio__c, OwnerId, Outros_Pagamentos__c, OldFinalidade__c, 
                Objetivo__c, Numero_da_RV_criada__c, Numero_da_DA__c, Name, Mes__c, MensagemIntegracao__c, 
                LastModifiedDate, LastModifiedById, LastActivityDate, IsDeleted, Id, Finalidade__c, 
                Descricao__c, Data_de_Previsao_do_Pagamento__c, Data_de_Encerramento__c, Custo_Bonificado__c, 
                CreatedDate, CreatedById, LAT_Contract__c, Conta__c, Cliente__c, Ano_Fiscal__c, Ano_Calendario__c,
                LAT_Contract__r.Account__r.Client_code_AN8__c, Produto_Bonificado__c, Verba_Adicional_VAD__r.Numero_da_VAD__c,
                LAT_Contract__r.Tipo_de_verba__c, Finalidade_SCV__c, CreatedBy.Username, Owner.Username, Ano_fiscal_calculado__c,
                Valor_Pago_R__c, Volume_Pago_Cx__c
                From Investimento_Bonificacao_e_Pagamento__c Where Id =: aIdIBP AND RecordTypeId =: setRecTypeIBP]; 
              }catch(QueryException e){
                System.debug(e.getMessage());
              }
              return lIBP;
        }
        //MIGRATED 18/11/2016
        else {
              Investimento_Bonificacao_e_Pagamento__c lIBP = new Investimento_Bonificacao_e_Pagamento__c();
              try{
                lIBP = [Select Volume_Cx__c, Verba_do_Sistema__c, Verba_Reservada__c, 
                Verba_Normal__c, Verba_Extra__c, Verba_Adiantada__c, Valor_R__c, Valor_Percebido__c, 
                 Tipo_de_Verba__c, SystemModstamp, Status_da_Verba__c, Sistema__c,
                ScheduleC_Bonificado__c, Saldo_R__c, Saldo_Caixas__c, RecordTypeId, LAT_Product__R.LAT_Sku__c, 
                Primeiro_Pagamento__c, Perc_de_Rateio__c, OwnerId, Outros_Pagamentos__c, OldFinalidade__c, 
                Objetivo__c, Numero_da_RV_criada__c, Numero_da_DA__c, Name, Mes__c, MensagemIntegracao__c, 
                LastModifiedDate, LastModifiedById, LastActivityDate, IsDeleted, Id, Finalidade__c, 
                Descricao__c, Data_de_Previsao_do_Pagamento__c, Data_de_Encerramento__c, Custo_Bonificado__c, 
                CreatedDate, CreatedById, LAT_Contract__c, Conta__c, Cliente__c, Ano_Fiscal__c, Ano_Calendario__c,
                LAT_Contract__r.Account__r.Client_code_AN8__c, LAT_Product__c, Verba_Adicional_VAD__r.Numero_da_VAD__c,
                LAT_Contract__r.Tipo_de_verba__c, Finalidade_SCV__c, CreatedBy.Username, Owner.Username, Ano_fiscal_calculado__c,
                Valor_Pago_R__c, Volume_Pago_Cx__c
                From Investimento_Bonificacao_e_Pagamento__c Where Id =: aIdIBP AND RecordTypeId =: setRecTypeIBP]; 
              }catch(QueryException e){
                System.debug(e.getMessage());
              }
              return lIBP;            
        }
    }
    
    
    //Recupera uma lista de objetos Investimento_Bonificacao_e_Pagamento__c atraves 
    //de uma lista de IDs de IBP.
    public List<Investimento_Bonificacao_e_Pagamento__c> getListInvestBonifPagByIdsIBP( List< String > idsIBPs ){
        if(!Utils.wasMigrationDone('1')) {            
            List<Investimento_Bonificacao_e_Pagamento__c> lList = new List<Investimento_Bonificacao_e_Pagamento__c>();
            
            lList = [Select Volume_Cx__c, Verba_do_Sistema__c, Verba_Reservada__c, 
                Verba_Normal__c, Verba_Extra__c, Verba_Adiantada__c, Valor_R__c, Valor_Percebido__c, 
                Tipo_de_Verba__c, SystemModstamp, Status_da_Verba__c, Sistema__c,
                ScheduleC_Bonificado__c, Saldo_R__c, Saldo_Caixas__c, RecordTypeId, Produto_Bonificado__r.SKU__c, 
                Primeiro_Pagamento__c, Perc_de_Rateio__c, OwnerId, Outros_Pagamentos__c, OldFinalidade__c, 
                Objetivo__c, Numero_da_RV_criada__c, Numero_da_DA__c, Name, Mes__c, MensagemIntegracao__c, 
                LastModifiedDate, LastModifiedById, LastActivityDate, IsDeleted, Id, Finalidade__c, 
                Descricao__c, Data_de_Previsao_do_Pagamento__c, Data_de_Encerramento__c, Custo_Bonificado__c, 
                CreatedDate, CreatedById, LAT_Contract__c, Conta__c, Cliente__c, Ano_Fiscal__c, Ano_Calendario__c,
                LAT_Contract__r.Account__r.Client_code_AN8__c, Produto_Bonificado__c, Verba_Adicional_VAD__r.Numero_da_VAD__c,
                LAT_Contract__r.Tipo_de_verba__c, Finalidade_SCV__c, CreatedBy.Username, Owner.Username, Ano_fiscal_calculado__c,
                Volume_Pago_Cx__c, Valor_Pago_R__c
                            From Investimento_Bonificacao_e_Pagamento__c
                            Where Id =: idsIBPs AND RecordTypeId =: setRecTypeIBP
                    ];
                                
            return lList;
        }
        //MIGRATED 18/11/2016
        else {
            List<Investimento_Bonificacao_e_Pagamento__c> lList = new List<Investimento_Bonificacao_e_Pagamento__c>();
            
            lList = [Select Volume_Cx__c, Verba_do_Sistema__c, Verba_Reservada__c, 
                Verba_Normal__c, Verba_Extra__c, Verba_Adiantada__c, Valor_R__c, Valor_Percebido__c, 
                Tipo_de_Verba__c, SystemModstamp, Status_da_Verba__c, Sistema__c,
                ScheduleC_Bonificado__c, Saldo_R__c, Saldo_Caixas__c, RecordTypeId, LAT_Product__r.LAT_Sku__c, 
                Primeiro_Pagamento__c, Perc_de_Rateio__c, OwnerId, Outros_Pagamentos__c, OldFinalidade__c, 
                Objetivo__c, Numero_da_RV_criada__c, Numero_da_DA__c, Name, Mes__c, MensagemIntegracao__c, 
                LastModifiedDate, LastModifiedById, LastActivityDate, IsDeleted, Id, Finalidade__c, 
                Descricao__c, Data_de_Previsao_do_Pagamento__c, Data_de_Encerramento__c, Custo_Bonificado__c, 
                CreatedDate, CreatedById, LAT_Contract__c, Conta__c, Cliente__c, Ano_Fiscal__c, Ano_Calendario__c,
                LAT_Contract__r.Account__r.Client_code_AN8__c, LAT_Product__c, Verba_Adicional_VAD__r.Numero_da_VAD__c,
                LAT_Contract__r.Tipo_de_verba__c, Finalidade_SCV__c, CreatedBy.Username, Owner.Username, Ano_fiscal_calculado__c,
                Volume_Pago_Cx__c, Valor_Pago_R__c
                            From Investimento_Bonificacao_e_Pagamento__c
                            Where Id =: idsIBPs AND RecordTypeId =: setRecTypeIBP
                    ];
                                
            return lList;            
        }
    }    
    
}