/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
*-------------------------------------------------------------------------------
*
* Provê serviço de retorno de informações da inclusão da RV
* NAME: RVManagerReturn.cls
* AUTHOR: ROGERIO ALVARENGA                         DATE: 21/08/2012
*
*-------------------------------------------------------------------------------
* MAINTENANCE
* AUTHOR: CARLOS CARVALHO                           DATE: 21/09/2012
*
* AUTHOR: CARLOS CARVALHO                           DATE: 17/01/2013
* DESC: INSERIDO FUNCIONALIDADE QUE VALIDA O ID DO TIPO DE REGISTRO DOS OBJETOS.
*******************************************************************************/

global class RVManagerReturn {
  
  WebService static Integer RVReturn( String aRVId, String aStatus, String aMessage,
      decimal aVerbaAntecipada, decimal aVerbaExtra, decimal aRVCriada, decimal aUnitValue )
  {
    Set< Id > setRecTypeId = new Set< Id >();
    setRecTypeId.add( RecordTypeForTest.getRecType( 'Investimento_Bonificacao_e_Pagamento__c', 'Bonificacao_Produtos' ) );
    setRecTypeId.add( RecordTypeForTest.getRecType( 'Investimento_Bonificacao_e_Pagamento__c', 'Dinheiro' ) );
        
    List< Investimento_Bonificacao_e_Pagamento__c > lIBPList = [ SELECT Verba_Adiantada__c, Verba_Extra__c, 
                                                    MensagemIntegracao__c, Valor_Percebido__c
                                                    FROM Investimento_Bonificacao_e_Pagamento__c
                                                    WHERE id =: aRVId AND RecordTypeId =: setRecTypeId ];
        
    if ( lIBPList.size() == 0 ) return -1;
    
    Investimento_Bonificacao_e_Pagamento__c ibp = lIBPList[ 0 ];

    if ( aStatus == '0' )
    {
      ibp.Numero_da_RV_criada__c = String.valueOf( aRVCriada );
      ibp.Verba_Adiantada__c = ( aVerbaAntecipada == 0 ) ? false : true;
      ibp.Verba_Extra__c = ( aVerbaExtra == 0 ) ? false : true;
      ibp.Valor_Percebido__c = aUnitValue;
      ibp.MensagemIntegracao__c = 'OK';
    }
    else
    {
      ibp.MensagemIntegracao__c = aMessage;
    }
    try
    {
      update ibp;
    }
    catch ( Exception e )
    {
      return -2;
    }
    return 0;
    
  }

}