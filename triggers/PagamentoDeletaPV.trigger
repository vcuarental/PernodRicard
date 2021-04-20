/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
*-------------------------------------------------------------------------------
* Quando um pagamento é deletado os pagamento de verba são deletados. Pois, a 
* de Pagamento de Verba não é acionada quando o mestre (Pagamento) é excluído.
*
* NAME: PagamentoDeletaPV.trigger
* AUTHOR: CARLOS CARVALHO                           DATE: 01/11/2012
*
*
* MAINTENANCE: INSERIDO FUNCIONALIDADE QUE VALIDA O ID DO TIPO DE REGISTRO DOS OBJETOS.
* AUTHOR: CARLOS CARVALHO                               DATE: 08/01/2013
*******************************************************************************/
trigger PagamentoDeletaPV on Pagamento__c (before delete) {

//    Check if this trigger is bypassed by SESAME (data migration Brazil)
if((UserInfo.getProfileId()!='00eM0000000QNYPIA4') && (UserInfo.getProfileId()!= '00eD0000001AnFlIAK')) {
    
    //Declaração de variáveis
    List< String > listIdsPag = new List< String >();
    List< Pagamento_da_Verba__c > listPV;
    Set< Id > setRecTypePag = new Set< Id >();
    Set< Id > setRecTypePV = new Set< Id >();
    
    //Recupera os ids dos tipos de registro
    setRecTypePag.add( RecordTypeForTest.getRecType( 'Pagamento__c' , 'Bonificacao_Produtos' ));
    setRecTypePag.add( RecordTypeForTest.getRecType( 'Pagamento__c' , 'Bonifica_o_Produtos_Bloqueado' ));
    setRecTypePag.add( RecordTypeForTest.getRecType( 'Pagamento__c' , 'Dinheiro' ));
    setRecTypePag.add( RecordTypeForTest.getRecType( 'Pagamento__c' , 'Dinheiro_Bloqueado' ));
    setRecTypePV.add( RecordTypeForTest.getRecType( 'Pagamento_da_Verba__c', 'Bonificacao_Produtos'));
    setRecTypePV.add( RecordTypeForTest.getRecType( 'Pagamento_da_Verba__c', 'Dinheiro'));
    
    for( Pagamento__c p : trigger.old ){
      if( !setRecTypePag.contains( p.RecordTypeId ) ) continue;
       
      listIdsPag.add( p.Id );
    }
    
    listPV = [SELECT id FROM Pagamento_da_Verba__c WHERE Pagamento__c =: listIdsPag 
        AND RecordTypeId =: setRecTypePV ];
    
    if( listPV.size() > 0 ){
        delete listPV;
    }
 }
}