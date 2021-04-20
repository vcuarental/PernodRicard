/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
*-------------------------------------------------------------------------------
*
* Classe que recebe uma lista de IBP's e gera um pagamento
* NAME: PagamentoGerar.cls
* AUTHOR: ROGERIO ALVARENGA                         DATE: 30/10/2012
*
*-------------------------------------------------------------------------------
* MAINTENANCE
* AUTHOR: CARLOS CARVALHO                         DATE: 15/01/2013
* DESC: INSERIDO LÓGICA DE VALIDAÇÃO DO TIPO DE REGISTRO DOS OBJETOS.
*******************************************************************************/
 /********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 18/11/2016
*
********************************************************************************/

global class PagamentoGerar {
    
    private static boolean bonifProduto;
    
    webservice static String gerar( List< String > aIBPs, ID aContaID )
    {
      if(!Utils.wasMigrationDone('1')) {  
            //Declaração de variáveis
            Date maiorData;
          
            Set< Id > setRecTypeIBP = new Set< Id >();
    	    setRecTypeIBP.add( RecordTypeForTest.getRecType( 'Investimento_Bonificacao_e_Pagamento__c', 'Bonificacao_Produtos' ) );
    	    setRecTypeIBP.add( RecordTypeForTest.getRecType( 'Investimento_Bonificacao_e_Pagamento__c', 'Dinheiro' ) );
            
            Set< Id > setRecTypeAcc = new Set< Id >();
            setRecTypeAcc.add( RecordTypeForTest.getRecType( 'Account', 'Eventos'));
            setRecTypeAcc.add( RecordTypeForTest.getRecType( 'Account', 'Off_Trade'));
            setRecTypeAcc.add( RecordTypeForTest.getRecType( 'Account', 'On_Trade'));
            
            if ( aIBPs.size() == 0 ) return 'Pelo menos um item deve ser selecionado';
            Savepoint sp = Database.setSavepoint();
            Account lConta = [ SELECT id, OwnerId FROM Account WHERE id =: aContaID AND RecordTypeId =: setRecTypeAcc];

            List< Investimento_Bonificacao_e_Pagamento__c > lListIBPs = [ SELECT id, OwnerId, RecordTypeId,
              Sistema__c, Status_da_Verba__c, Produto_Bonificado__c, Volume_Cx__c, Valor_R__c, Data_de_Previsao_do_Pagamento__c,
              Valor_Pago_R__c, Volume_Pago_Cx__c, Saldo_Caixas__c, Saldo_R__c
              from Investimento_Bonificacao_e_Pagamento__c where id=:aIBPs and RecordTypeId =: setRecTypeIBP];
            
            for( Investimento_Bonificacao_e_Pagamento__c inv : lListIBPs ){
              if( maiorData == null || inv.Data_de_Previsao_do_Pagamento__c > maiorData )
                  maiorData = inv.Data_de_Previsao_do_Pagamento__c;
            }
            
            Pagamento__c lPagto = new Pagamento__c();
            lPagto.RecordTypeId = getRecTypeForPagto( lListIBPs[ 0 ].RecordTypeId );
            lPagto.Cliente__c = lConta.id;
            lPagto.Solicitante__c = lConta.OwnerId;
            lPagto.Data_do_Pagamento__c = maiorData;
            lPagto.Forma_de_Pagamento__c = 'Deposito em Conta';
            lPagto.Status__c = 'Em preenchimento';
            System.debug( '@@@' + lConta.OwnerId );
            insert lPagto;
            
            String lLastRecType = lListIBPs[ 0 ].RecordTypeId;
            String lLastSystem = lListIBPs[ 0 ].Sistema__c;
            Date lDataPagto = lPagto.Data_do_Pagamento__c;
            String lRectypeVerba = getRecTypeForVerba( lListIBPs[ 0 ].RecordTypeId );
            
            List< Pagamento_da_Verba__c > lListVerba = new List< Pagamento_da_Verba__c >();
            for ( Investimento_Bonificacao_e_Pagamento__c IBP : lListIBPs )
            {
                if ( lLastRecType != IBP.RecordTypeId ) 
                  return 'Não é possível criar pagamento para tipos diferentes (bonificação e dinheiro)';
                if ( lLastSystem != IBP.Sistema__c )
                  return 'Não é possível criar pagamento para sistemas diferentes';
                if ( IBP.Status_da_Verba__c != 'Reservado' )
                  return 'Não é possível criar pagamento para solicitação com status diferente de reservado';
                Pagamento_da_Verba__c lVerba = new Pagamento_da_Verba__c();
                lVerba.Investimento_Bonifica_o_e_Pagamento__c = IBP.id;
                lVerba.Pagamento__c = lPagto.id;
                lVerba.RecordTypeId = lRectypeVerba;
                lVerba.Sistema__c = IBP.Sistema__c;
                if ( bonifProduto )
                {
                    lVerba.pagar_com_produto__c = IBP.Produto_Bonificado__c;
                    lVerba.volume_a_pagar__c = IBP.Saldo_Caixas__c;
                }
                else
                {
                    lVerba.valor_a_pagar__c = IBP.Saldo_R__c;
                }
                lListVerba.add( lVerba );
                if ( lDataPagto < IBP.Data_de_Previsao_do_Pagamento__c )
                  lDataPagto = IBP.Data_de_Previsao_do_Pagamento__c;
            }
            lPagto.Data_do_Pagamento__c = lDataPagto;
            try
            {
                update lPagto;
              insert lListVerba;
            }
            catch( DmlException e )
            {
                Database.rollback( sp );
                return e.getDmlMessage( 0 );
            }
            return lPagto.id;
        }
        //MIGRATED 18/11/2016
        else {
            //Declaração de variáveis
            Date maiorData;
          
            Set< Id > setRecTypeIBP = new Set< Id >();
            setRecTypeIBP.add( RecordTypeForTest.getRecType( 'Investimento_Bonificacao_e_Pagamento__c', 'Bonificacao_Produtos' ) );
            setRecTypeIBP.add( RecordTypeForTest.getRecType( 'Investimento_Bonificacao_e_Pagamento__c', 'Dinheiro' ) );
            
            Set< Id > setRecTypeAcc = new Set< Id >();
            setRecTypeAcc.add( RecordTypeForTest.getRecType( 'Account', 'Eventos'));
            setRecTypeAcc.add( RecordTypeForTest.getRecType( 'Account', 'Off_Trade'));
            setRecTypeAcc.add( RecordTypeForTest.getRecType( 'Account', 'On_Trade'));
            
            if ( aIBPs.size() == 0 ) return 'Pelo menos um item deve ser selecionado';
            Savepoint sp = Database.setSavepoint();
            Account lConta = [ SELECT id, OwnerId FROM Account WHERE id =: aContaID AND RecordTypeId =: setRecTypeAcc];

            List< Investimento_Bonificacao_e_Pagamento__c > lListIBPs = [ SELECT id, OwnerId, RecordTypeId,
              Sistema__c, Status_da_Verba__c, LAT_Product__c, Volume_Cx__c, Valor_R__c, Data_de_Previsao_do_Pagamento__c,
              Valor_Pago_R__c, Volume_Pago_Cx__c, Saldo_Caixas__c, Saldo_R__c
              from Investimento_Bonificacao_e_Pagamento__c where id=:aIBPs and RecordTypeId =: setRecTypeIBP];
            
            for( Investimento_Bonificacao_e_Pagamento__c inv : lListIBPs ){
              if( maiorData == null || inv.Data_de_Previsao_do_Pagamento__c > maiorData )
                  maiorData = inv.Data_de_Previsao_do_Pagamento__c;
            }
            
            Pagamento__c lPagto = new Pagamento__c();
            lPagto.RecordTypeId = getRecTypeForPagto( lListIBPs[ 0 ].RecordTypeId );
            lPagto.Cliente__c = lConta.id;
            lPagto.Solicitante__c = lConta.OwnerId;
            lPagto.Data_do_Pagamento__c = maiorData;
            lPagto.Forma_de_Pagamento__c = 'Deposito em Conta';
            lPagto.Status__c = 'Em preenchimento';
            System.debug( '@@@' + lConta.OwnerId );
            insert lPagto;
            
            String lLastRecType = lListIBPs[ 0 ].RecordTypeId;
            String lLastSystem = lListIBPs[ 0 ].Sistema__c;
            Date lDataPagto = lPagto.Data_do_Pagamento__c;
            String lRectypeVerba = getRecTypeForVerba( lListIBPs[ 0 ].RecordTypeId );
            
            List< Pagamento_da_Verba__c > lListVerba = new List< Pagamento_da_Verba__c >();
            for ( Investimento_Bonificacao_e_Pagamento__c IBP : lListIBPs )
            {
                if ( lLastRecType != IBP.RecordTypeId ) 
                  return 'Não é possível criar pagamento para tipos diferentes (bonificação e dinheiro)';
                if ( lLastSystem != IBP.Sistema__c )
                  return 'Não é possível criar pagamento para sistemas diferentes';
                if ( IBP.Status_da_Verba__c != 'Reservado' )
                  return 'Não é possível criar pagamento para solicitação com status diferente de reservado';
                Pagamento_da_Verba__c lVerba = new Pagamento_da_Verba__c();
                lVerba.Investimento_Bonifica_o_e_Pagamento__c = IBP.id;
                lVerba.Pagamento__c = lPagto.id;
                lVerba.RecordTypeId = lRectypeVerba;
                lVerba.Sistema__c = IBP.Sistema__c;
                if ( bonifProduto )
                {
                    lVerba.LAT_Product__c = IBP.LAT_Product__c;
                    lVerba.volume_a_pagar__c = IBP.Saldo_Caixas__c;
                }
                else
                {
                    lVerba.valor_a_pagar__c = IBP.Saldo_R__c;
                }
                lListVerba.add( lVerba );
                if ( lDataPagto < IBP.Data_de_Previsao_do_Pagamento__c )
                  lDataPagto = IBP.Data_de_Previsao_do_Pagamento__c;
            }
            lPagto.Data_do_Pagamento__c = lDataPagto;
            try
            {
                update lPagto;
              insert lListVerba;
            }
            catch( DmlException e )
            {
                Database.rollback( sp );
                return e.getDmlMessage( 0 );
            }
            return lPagto.id;
        }
    }
    
    private static String getRecTypeForPagto( String aRecType )
    {
        bonifProduto = RecordTypeForTest.getRecType( 'Investimento_Bonificacao_e_Pagamento__c' , 'Dinheiro' ) != aRecType;
        if ( !bonifProduto )
          return RecordTypeForTest.getRecType( 'Pagamento__c' , 'Dinheiro' );
        else return RecordTypeForTest.getRecType( 'Pagamento__c' , 'Bonificacao_Produtos' );
    }
    
    private static String getRecTypeForVerba( String aRecType )
  {
    if ( !bonifProduto )
      return RecordTypeForTest.getRecType( 'Pagamento_da_Verba__c' , 'Dinheiro' );
    else return RecordTypeForTest.getRecType( 'Pagamento_da_Verba__c' , 'Bonificacao_Produtos' );
  }

}