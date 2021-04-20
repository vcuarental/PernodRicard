/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
*-------------------------------------------------------------------------------
*
* Quando o pagamento passar para 'Aprovado' dispara a integração de contrato 
* sistema legado 
* NAME: PagamentoIntegracao.trigger
* AUTHOR: ROGERIO ALVARENGA                         DATE: 13/09/2012
*
* MAINTENANCE: INSERIDO FUNCIONALIDADE QUE VALIDA O ID DO TIPO DE REGISTRO DOS OBJETOS.
* AUTHOR: CARLOS CARVALHO                               DATE: 08/01/2013
*******************************************************************************/
trigger PagamentoIntegracao on Pagamento__c (before update) {

//    Check if this trigger is bypassed by SESAME (data migration Brazil)
if((UserInfo.getProfileId()!='00eM0000000QNYPIA4') && (UserInfo.getProfileId()!= '00eD0000001AnFlIAK')) {
  
  //Declaração de variáveis
  Set< Id > setRecTypePag = new Set< Id >();
    
  //Recupera os ids dos tipos de registro
  setRecTypePag.add( RecordTypeForTest.getRecType( 'Pagamento__c' , 'Bonificacao_Produtos' ));
  setRecTypePag.add( RecordTypeForTest.getRecType( 'Pagamento__c' , 'Bonifica_o_Produtos_Bloqueado' ));
  setRecTypePag.add( RecordTypeForTest.getRecType( 'Pagamento__c' , 'Dinheiro' ));
  setRecTypePag.add( RecordTypeForTest.getRecType( 'Pagamento__c' , 'Dinheiro_Bloqueado' ));
  
  for ( Pagamento__c p : Trigger.new )
  {
    if ( setRecTypePag.contains( p.RecordTypeId ) && p.Status__c == 'Aprovado' && Trigger.oldMap.get( p.id ).Status__c != 'Aprovado' )
    {
      PaymentManagerInterface.PaymentManagerInvoke( p.id );
      p.Status__c = 'Enviando para SCV/ME';
    }
  }
 }
}