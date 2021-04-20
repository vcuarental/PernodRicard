/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* Classe que realiza funções DML no objeto Distribui_o_de_Valores__c.
* NAME: DistribuicaoValoresDAO.cls
* AUTHOR: CARLOS CARVALHO                           DATE: 11/09/2012
*
* MAINTENANCE
* AUTHOR: CARLOS CARVALHO                           DATE: 27/09/2012
*
* MAINTENANCE: INSERIDO LÓGICA DE VALIDAÇÃO DO TIPO DE REGISTRO DOS OBJETOS.
* AUTHOR: CARLOS CARVALHO                           DATE: 10/01/2013 
********************************************************************************/
public with sharing class DistribuicaoValoresDAO {
    
    private static final DistribuicaoValoresDAO instance = new DistribuicaoValoresDAO();
    private Id idRecTypeDV = RecordTypeForTest.getRecType( 'Distribui_o_de_Valores__c', 'BRA_Standard' );
    
    //Construtor privado para impedir a criação de instâncias dessa classe.
    private DistribuicaoValoresDAO()
    {
    }
    
    //Método responsável por prover a instância dessa classe.
    public static DistribuicaoValoresDAO getInstance()
    {
        return instance;
    }

    //Recupera valores de distribuição atraves do parametro
    public List< Distribui_o_de_Valores__c > getListDistribuicaoByIdsClausula( List< String > aListIdsClausula ){
      List< Distribui_o_de_Valores__c > lList = new List< Distribui_o_de_Valores__c >();

      lList = [ SELECT Id, 
                       Ano_Fiscal_para_Apuracao__c,
		               Ano_de_Referencia_para_Apuracao__c,
		               Mes_de_Referencia_para_Apuracao__c,
		               Valor_da_Parcela_R__c,
		               Clausulas_do_Contrato__c,
		               Data_de_Referencia_para_Apuracao__c,
		               Ano_fiscal_formula__c
                       FROM Distribui_o_de_Valores__c
                       WHERE Clausulas_do_Contrato__c =: aListIdsClausula
                       AND RecordTypeId =: idRecTypeDV 
               ];
      
      return lList;
    }

}