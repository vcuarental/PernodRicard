/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
*-------------------------------------------------------------------------------
*
* Trigger que verifica se há anexo para pagamento
* NAME: AnexoContarParaPagto.trigger
* AUTHOR: ROGERIO ALVARENGA                         DATE: 13/09/2012
*
*-------------------------------------------------------------------------------
* MAINTENANCE: INSERIDO FUNÇÃO RecordTypeForTest
* AUTHOR: CARLOS CARVALHO                           DATE: 07/01/2013
*******************************************************************************/
trigger AnexoContarParaPagto on Attachment (before delete, before insert, before update) {

//    Check if this trigger is bypassed by SESAME (data migration Brazil)
if((UserInfo.getProfileId()!='00eM0000000QNYPIA4') && (UserInfo.getProfileId()!= '00eD0000001AnFlIAK')) {

    List< Id > listRecType = new List< Id >();
    listRecType.add( RecordTypeForTest.getRecType('Pagamento__c', 'Bonificacao_Produtos'));
    listRecType.add( RecordTypeForTest.getRecType('Pagamento__c', 'Bonifica_o_Produtos_Bloqueado'));
    listRecType.add( RecordTypeForTest.getRecType('Pagamento__c', 'Dinheiro'));
    listRecType.add( RecordTypeForTest.getRecType('Pagamento__c', 'Dinheiro_Bloqueado'));
    
    List< String > lListContractID = new List< String >();
  
  if ( Trigger.isDelete )
  {
    for ( Attachment lAtt : Trigger.old )
      lListContractID.add( lAtt.ParentId );
  }
  else
  {
    for ( Attachment lAtt : Trigger.new )
      lListContractID.add( lAtt.ParentId );
  }
  
  List< Pagamento__c > lListPagto = [ SELECT Possui_Anexo__c FROM Pagamento__c 
    WHERE id=:lListContractID AND RecordTypeId =: listRecType];
  
  if( lListPagto.size() == 0 ) return;
  
  for ( Pagamento__c lPg : lListPagto )
  {
    lPg.Possui_Anexo__c = !Trigger.isDelete;
  }
  
  update lListPagto;
    }
}