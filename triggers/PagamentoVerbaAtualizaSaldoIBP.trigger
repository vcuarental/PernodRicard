/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
*-------------------------------------------------------------------------------
* Quando um pagamento de verba é excluído, inserido ou editado o saldo da IBP
* deve ser atualizado.
*
* NAME: PagamentoVerbaAtualizaSaldoIBP.trigger
* AUTHOR: CARLOS CARVALHO                           DATE: 01/11/2012
*
*
* MAINTENANCE: INSERIDO FUNCIONALIDADE QUE VALIDA O ID DO TIPO DE REGISTRO DOS OBJETOS.
* AUTHOR: CARLOS CARVALHO                               DATE: 08/01/2013
*******************************************************************************/
trigger PagamentoVerbaAtualizaSaldoIBP on Pagamento_da_Verba__c (after insert, after update, after delete){

//    Check if this trigger is bypassed by SESAME (data migration Brazil)
if((UserInfo.getProfileId()!='00eM0000000QNYPIA4') && (UserInfo.getProfileId()!= '00eD0000001AnFlIAK')) {

    //Declaração de variáveis
    List< String > listIdsIBP = new List< String >();
    List< Pagamento_da_Verba__c > listPV = new List< Pagamento_da_Verba__c >();
    List< Pagamento_da_Verba__c > listPVOld = new List< Pagamento_da_Verba__c >();
    List< Investimento_Bonificacao_e_Pagamento__c > listIBP;
    Map< String, Investimento_Bonificacao_e_Pagamento__c > mapIBP = new Map< String, Investimento_Bonificacao_e_Pagamento__c >();
    Set< Id > setRecTypeInv = new Set< Id >();
    Set< Id > setRecTypePag = new Set< Id >();
    Set< Id > setRecTypePV = new Set< Id >();
    
    //Recupera os ids dos tipos de registro
    setRecTypeInv.add( RecordTypeForTest.getRecType( 'Investimento_Bonificacao_e_Pagamento__c', 'Bonificacao_Produtos') );
    setRecTypeInv.add( RecordTypeForTest.getRecType( 'Investimento_Bonificacao_e_Pagamento__c', 'Dinheiro') );
    setRecTypePag.add( RecordTypeForTest.getRecType( 'Pagamento__c' , 'Bonificacao_Produtos' ));
    setRecTypePag.add( RecordTypeForTest.getRecType( 'Pagamento__c' , 'Bonifica_o_Produtos_Bloqueado' ));
    setRecTypePag.add( RecordTypeForTest.getRecType( 'Pagamento__c' , 'Dinheiro' ));
    setRecTypePag.add( RecordTypeForTest.getRecType( 'Pagamento__c' , 'Dinheiro_Bloqueado' )); 
    setRecTypePV.add( RecordTypeForTest.getRecType( 'Pagamento_da_Verba__c', 'Bonificacao_Produtos'));
    setRecTypePV.add( RecordTypeForTest.getRecType( 'Pagamento_da_Verba__c', 'Dinheiro'));   
    
    if( Trigger.isInsert || Trigger.isUpdate ){
      for( Pagamento_da_Verba__c pag : trigger.new ){
        if( !setRecTypePV.contains( pag.RecordTypeId ) ) continue;
        
        listIdsIBP.add( pag.Investimento_Bonifica_o_e_Pagamento__c );
        listPV.add( pag );
      }
    }
    if( Trigger.isDelete ){
        for( Pagamento_da_Verba__c pag : trigger.old ){
            if( !setRecTypePV.contains( pag.RecordTypeId ) ) continue;
             
            listIdsIBP.add( pag.Investimento_Bonifica_o_e_Pagamento__c );
            listPVOld.add( pag );
        }
    }
    
    listIBP = [ SELECT id, Volume_Pago_Cx__c, Valor_Pago_R__c, CasoEspecial__c 
                FROM Investimento_Bonificacao_e_Pagamento__c WHERE id=: listIdsIBP 
                AND RecordTypeId =: setRecTypeInv ];
    
    if( listIBP.size() == 0 ) return;
    
    for(Investimento_Bonificacao_e_Pagamento__c i : listIBP){
      mapIBP.put( i.Id, i );
    }
    
    if( Trigger.isUpdate ){
      for( Pagamento_da_Verba__c p : listPV ){
         Investimento_Bonificacao_e_Pagamento__c lInv = mapIBP.get( p.Investimento_Bonifica_o_e_Pagamento__c );
         if( lInv == null ) continue;
           
           Decimal lValor = Trigger.oldMap.get( p.Id ).valor_a_pagar__c;
           if(lvalor != null) lInv.Valor_Pago_R__c -= lValor;
           
           Decimal lVolume = Trigger.oldMap.get( p.Id ).volume_a_pagar__c;
           if( lVolume != null ) lInv.Volume_Pago_Cx__c -= lVolume;
           
           lInv.CasoEspecial__c = true;
      }
    }
    
    if( Trigger.isDelete ){
        for( Pagamento_da_Verba__c p : listPVOld ){
           Investimento_Bonificacao_e_Pagamento__c lInv = mapIBP.get( p.Investimento_Bonifica_o_e_Pagamento__c );
           if( lInv == null ) continue;
           
           Decimal lValor = Trigger.oldMap.get( p.Id ).valor_a_pagar__c;
           if(lvalor != null) lInv.Valor_Pago_R__c -= lValor;
           
           Decimal lVolume = Trigger.oldMap.get( p.Id ).volume_a_pagar__c;
           if( lVolume != null ) lInv.Volume_Pago_Cx__c -= lVolume;
           
           lInv.CasoEspecial__c = true;
        }
    }
    
    if( Trigger.isInsert || Trigger.isUpdate ){
       for( Pagamento_da_Verba__c p : listPV ){
           Investimento_Bonificacao_e_Pagamento__c lInv = mapIBP.get( p.Investimento_Bonifica_o_e_Pagamento__c );
           if( lInv == null ) continue;
           
           Decimal lValor = p.valor_a_pagar__c;
           if( lInv.Valor_Pago_R__c == null ) lInv.Valor_Pago_R__c = 0;
           if(lvalor != null) lInv.Valor_Pago_R__c += lValor;
           
           Decimal lVolume = p.volume_a_pagar__c;
           if( lInv.Volume_Pago_Cx__c == null ) lInv.Volume_Pago_Cx__c = 0;
           if( lVolume != null ) lInv.Volume_Pago_Cx__c += lVolume;
        
            lInv.CasoEspecial__c = true;
        }
    }
    
    if( listIBP.size() > 0 ) update listIBP;
    
}
}