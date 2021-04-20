/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
*-------------------------------------------------------------------------------
*
* Provê serviço de retorno de informações do status do pagamento
* NAME: PaymentManagerReturn.cls
* AUTHOR: ROGERIO ALVARENGA                         DATE: 21/08/2012
*
*-------------------------------------------------------------------------------
* MAINTENANCE
* AUTHOR: CARLOS CARVALHO                           DATE: 21/09/2012
*
* AUTHOR: CARLOS CARVALHO                         DATE: 16/01/2013
* DESC: INSERIDO LÓGICA DE VALIDAÇÃO DO TIPO DE REGISTRO DOS OBJETOS.
*******************************************************************************/

global class PaymentManagerReturn {
  
  WebService static Integer paymentReturn( String aPaymentID, String aStatus, String aMessage, 
      Integer aCodRet ){
    	
    	Set< Id > setRecTypePag = new Set< Id >();
    	setRecTypePag.add( RecordTypeForTest.getRecType( 'Pagamento__c', 'Bonificacao_Produtos' ) );
        setRecTypePag.add( RecordTypeForTest.getRecType( 'Pagamento__c', 'Bonifica_o_Produtos_Bloqueado' ) );
        setRecTypePag.add( RecordTypeForTest.getRecType( 'Pagamento__c', 'Dinheiro' ) );
        setRecTypePag.add( RecordTypeForTest.getRecType( 'Pagamento__c', 'Dinheiro_Bloqueado' ) );
        
    	
        List< Pagamento__c > lPaymentList = [ SELECT Status__c, MensagemIntegracao__c
                                                   FROM Pagamento__c WHERE id =: aPaymentID
                                                   AND RecordTypeId =: setRecTypePag ];


      if ( lPaymentList.size() == 0 ) return -1;
      Pagamento__c lPayment = lPaymentList[ 0 ];
      //**********************************************************************************************
      //Esse trecho esta errado, feito para testes solicitar para marcelo corrigir envio do parametro
      //**********************************************************************************************
      if ( aCodRet == 0 ) {
        lPayment.MensagemIntegracao__c = aMessage;
        lPayment.Status__c = ( aStatus != null && aStatus != '' ) ? aStatus : 'Aprovado Integrado';
      }
      else{
            lPayment.Status__c = ( aStatus != null && aStatus != '' ) ? aStatus : 'Erro de Integração';
          lPayment.MensagemIntegracao__c = aMessage;
      }
      try{
        update lPayment;
      }catch ( Exception e ){
        return -2;
      }
      return 0;
    }
}