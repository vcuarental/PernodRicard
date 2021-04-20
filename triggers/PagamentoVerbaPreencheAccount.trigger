/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
*-------------------------------------------------------------------------------
* Insere o cliente do pagamento em um campo oculto de pagamento de verba.
* Através dessa funcionalidade que o filtro de IBP irá funcionar.
*
* NAME: PagamentoVerbaPreencheAccount.trigger
* AUTHOR: CARLOS CARVALHO                           DATE: 19/10/2012
*
*
* MAINTENANCE: INSERIDO FUNCIONALIDADE QUE VALIDA O ID DO TIPO DE REGISTRO DOS OBJETOS.
* AUTHOR: CARLOS CARVALHO                               DATE: 08/01/2013
*******************************************************************************/
trigger PagamentoVerbaPreencheAccount on Pagamento_da_Verba__c (before insert, before update) {

//    Check if this trigger is bypassed by SESAME (data migration Brazil)
if((UserInfo.getProfileId()!='00eM0000000QNYPIA4') && (UserInfo.getProfileId()!= '00eD0000001AnFlIAK')) {

    //declaração de variáveis
    List< String > lListIdPagamento = new List< String >();
    List< Pagamento__c > listPagamento = new List< Pagamento__c >();
    List< Pagamento_da_Verba__c > listPagVerba = new List< Pagamento_da_Verba__c >();
    List< Pagamento_da_Verba__c > listPagVerbaUpdate = new List< Pagamento_da_Verba__c >();
    Map< String, Pagamento__c > mapPagamento = new Map< String, Pagamento__c >();
    Set< Id > setRecTypePV = new Set< Id >();
    Set< Id > setRecTypePag = new Set< Id >();
    
    //Recupera os ids dos tipos de registro
    setRecTypePV.add( RecordTypeForTest.getRecType( 'Pagamento_da_Verba__c', 'Bonificacao_Produtos'));
    setRecTypePV.add( RecordTypeForTest.getRecType( 'Pagamento_da_Verba__c', 'Dinheiro'));
    setRecTypePag.add( RecordTypeForTest.getRecType( 'Pagamento__c' , 'Bonificacao_Produtos' ));
    setRecTypePag.add( RecordTypeForTest.getRecType( 'Pagamento__c' , 'Bonifica_o_Produtos_Bloqueado' ));
    setRecTypePag.add( RecordTypeForTest.getRecType( 'Pagamento__c' , 'Dinheiro' ));
    setRecTypePag.add( RecordTypeForTest.getRecType( 'Pagamento__c' , 'Dinheiro_Bloqueado' ));
    
    //Percorre todos os Pagamento de verba aramazenando o ID do pagamento (MESTRE) e
    //o próprio objeto
    for( Pagamento_da_Verba__c p : trigger.new ){
      if( !setRecTypePV.contains( p.RecordTypeId ) ) continue;
      
      lListIdPagamento.add( p.Pagamento__c );
      listPagVerba.add( p ); 
    }
    
    //Recupera os pagamentos
    listPagamento = [SELECT id, Cliente__c FROM Pagamento__c 
            WHERE id =: lListIdPagamento AND RecordTypeId =: setRecTypePag];
    
    //Caso não exista pagamento ou não retorne nada a trigger sai da execução
    if( listPagamento.size() == 0 ) return;
    
    //Percorre os pagamento e cria um MAPA
    for( Pagamento__c pagamento : listPagamento ){
      mapPagamento.put( pagamento.Id, pagamento );
    }
    
    for( Pagamento_da_Verba__c pag : listPagVerba ){
      
      //recupera o pagamento através do ID
      Pagamento__c lPag = mapPagamento.get( pag.Pagamento__c );
      
      //Existe pagamento
      if( lPag != null )
      {
        pag.Conta__c = lPag.Cliente__c;
      }else{
        //Não existe pagamento
        pag.Pagamento__c.addError('Não existe um pagamento relacionado ao pagamento de verba.');
      }
    }
 }
}