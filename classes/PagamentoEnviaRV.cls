/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* Classe responsavel por enviar todas as IBPs para integração RVManager.
* NAME: PagamentoEnviaRV.cls
* AUTHOR: CARLOS CARVALHO                           DATE: 17/09/2012
*
* MAINTENANCE
* AUTHOR: CARLOS CARVALHO                           DATE: 08/10/2012
*
* AUTHOR: CARLOS CARVALHO                         DATE: 15/01/2013
* DESC: INSERIDO LÓGICA DE VALIDAÇÃO DO TIPO DE REGISTRO DOS OBJETOS.
********************************************************************************/
global class PagamentoEnviaRV {
    
    webservice static String RVManagerInterfaceInvoke( String aIdPagamento )
    {
      //Declaração de variaveis
      List< Pagamento_da_Verba__c > listPagamentoVerba = new List< Pagamento_da_Verba__c >();
      List< String > listIdsIBP = new List< String >();
      
      Set< Id > setRecTypePV = new Set< Id >();
      setRecTypePV.add( RecordTypeForTest.getRecType( 'Pagamento_da_Verba__c' , 'Bonificacao_Produtos' ) );
      setRecTypePV.add( RecordTypeForTest.getRecType( 'Pagamento_da_Verba__c' , 'Dinheiro' ) );
 
	    //REcupera os IDS de IBP
	    listPagamentoVerba = [Select Id, Investimento_Bonifica_o_e_Pagamento__c 
	                          From Pagamento_da_Verba__c
	                          Where Pagamento__c =: aIdPagamento and RecordTypeId =: setRecTypePV ];
	  
	    if( listPagamentoVerba == null || listPagamentoVerba.size() == 0 ) return 'Não existem Pagamentos de Verba para este pagamento.';
	    
	    for( Pagamento_da_Verba__c pag : listPagamentoVerba ){
	      listIdsIBP.add( pag.Investimento_Bonifica_o_e_Pagamento__c );
	    }
	    
	    for( String str : listIdsIBP ){
	      RVManagerInterface.RVManagerInvoke( str, aIdPagamento );
	    }
      
      return 'Iniciada Integração.';
    }
}