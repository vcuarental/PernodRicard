/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
*-------------------------------------------------------------------------------
* Valida se o número da DA informado não é duplicado ou se foram informados 
* Números de DA diferentes para o mesmo pagamento de verba.
* NAME: PagamentoVerbaValidaDA.trigger
* AUTHOR: CARLOS CARVALHO                          DATE: 
*
*
* MAINTENANCE: INSERIDO FUNCIONALIDADE QUE VALIDA O ID DO TIPO DE REGISTRO DOS OBJETOS.
* AUTHOR: CARLOS CARVALHO                               DATE: 08/01/2013
*******************************************************************************/
trigger PagamentoVerbaValidaDA on Pagamento_da_Verba__c (before insert, before update) {

//    Check if this trigger is bypassed by SESAME (data migration Brazil)
if((UserInfo.getProfileId()!='00eM0000000QNYPIA4') && (UserInfo.getProfileId()!= '00eD0000001AnFlIAK')) {
    
    //Declaração de variáveis
    List< String > listIdsPagamento = new List< String >();
    List< String > listIdsIBP = new List< String >();
    List< String > listIdsPV = new List< String >();
    List< String > listNumDA = new List< String >();
    List< Pagamento_da_Verba__c > listPV = new List< Pagamento_da_Verba__c >();
    Map< String, List< Pagamento_da_Verba__c > > mapPV = new Map< String, List< Pagamento_da_Verba__c >>();
    Map< String, Investimento_Bonificacao_e_Pagamento__c > mapIBP = new Map< String, Investimento_Bonificacao_e_Pagamento__c >();
    Set< Id > setRecTypePV = new Set< Id >();
    Set< Id > setRecTypeInv = new Set< Id >();
    
    //Recupera os ids dos tipos de registro
    setRecTypePV.add( RecordTypeForTest.getRecType( 'Pagamento_da_Verba__c', 'Bonificacao_Produtos'));
    setRecTypePV.add( RecordTypeForTest.getRecType( 'Pagamento_da_Verba__c', 'Dinheiro'));
    setRecTypeInv.add( RecordTypeForTest.getRecType( 'Investimento_Bonificacao_e_Pagamento__c', 'Bonificacao_Produtos') );
    setRecTypeInv.add( RecordTypeForTest.getRecType( 'Investimento_Bonificacao_e_Pagamento__c', 'Dinheiro') );
    
    
    for( Pagamento_da_Verba__c pv : trigger.new ){
      if( !setRecTypePV.contains( pv.RecordTypeId ) ) continue;
      
      listIdsPagamento.add( pv.Pagamento__c );
      listIdsPV.add( pv.Id );
      listPV.add( pv );
      listIdsIBP.add( pv.Investimento_Bonifica_o_e_Pagamento__c );
      listNumDA.add( String.valueOf( pv.Numero_retorno_Pagamento__c ));
    }
    
    List< Investimento_Bonificacao_e_Pagamento__c > lListIBP = [SELECT id, Numero_da_DA__c  
            FROM Investimento_Bonificacao_e_Pagamento__c WHERE Id =: listIdsIBP
            AND RecordTypeId =: setRecTypeInv];
    
    for( Investimento_Bonificacao_e_Pagamento__c i : lListIBP ){
      Investimento_Bonificacao_e_Pagamento__c lList = mapIBP.get( i.Id );
        if( lList == null ){
            mapIBP.put( i.Id , i );
        }
    }
    
    List< Pagamento_da_Verba__c > lListPag = [ SELECT id, Investimento_Bonifica_o_e_Pagamento__r.Numero_da_DA__c, 
      Pagamento__c FROM Pagamento_da_Verba__c WHERE Pagamento__c =: listIdsPagamento 
      AND Investimento_Bonifica_o_e_Pagamento__r.Numero_da_DA__c <>: listNumDA
      AND RecordTypeId =: setRecTypePV ];
    
    if(lListPag == null) lListPag = new List< Pagamento_da_Verba__c >();
    
    for( Pagamento_da_Verba__c pv : listPV ){
      lListPag.add( pv );
    }
    
    for( Pagamento_da_Verba__c pv : lListPag ){
      List< Pagamento_da_Verba__c > lList = mapPV.get( pv.Pagamento__c );
      if( lList == null ){
        lList = new List< Pagamento_da_Verba__c >();
        mapPV.put( pv.Pagamento__c , lList );
      }
      lList.add( pv );
    }
    
    for( Pagamento_da_Verba__c pv : listPV){
      List< Pagamento_da_Verba__c > lList = mapPV.get( pv.Pagamento__c );
      Investimento_Bonificacao_e_Pagamento__c lInv = mapIBP.get( pv.Investimento_Bonifica_o_e_Pagamento__c );
      if( lList != null ){
        for(Pagamento_da_Verba__c pv2 : lList ){
          Investimento_Bonificacao_e_Pagamento__c lInv2 = mapIBP.get( pv2.Investimento_Bonifica_o_e_Pagamento__c );
          if( pv.Investimento_Bonifica_o_e_Pagamento__r.Numero_da_DA__c != null ){
            if( pv2.Investimento_Bonifica_o_e_Pagamento__r.Numero_da_DA__c != null ){
              if( pv.Investimento_Bonifica_o_e_Pagamento__r.Numero_da_DA__c != pv2.Investimento_Bonifica_o_e_Pagamento__r.Numero_da_DA__c){
                pv.addError('Não é possível pagar números de DA diferentes no mesmo pagamento.');
              }
            }else if( lInv2.Status_da_Verba__c != null 
                   && pv.Investimento_Bonifica_o_e_Pagamento__r.Numero_da_DA__c != lInv2.Status_da_Verba__c){
                                pv.addError('Não é possível pagar números de DA diferentes no mesmo pagamento.');
                        }
          }else if( pv2.Investimento_Bonifica_o_e_Pagamento__r.Numero_da_DA__c != null ){
            if( lInv.Numero_da_DA__c != null 
            && pv2.Investimento_Bonifica_o_e_Pagamento__r.Numero_da_DA__c != lInv.Numero_da_DA__c){
              pv.addError('Não é possível pagar números de DA diferentes no mesmo pagamento.');
            }
          }else if( lInv.Numero_da_DA__c != null ){
            if( lInv2.Numero_da_DA__c != null && lInv.Numero_da_DA__c != lInv2.Numero_da_DA__c){
                        pv.addError('Não é possível pagar números de DA diferentes no mesmo pagamento.');
            }
          }
        }
      }
    }
 }
}