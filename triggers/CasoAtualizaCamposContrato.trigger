/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* Atualiza o campo demanda01_Aprovado__c do contrato quando uma demanda do tipo
* Inserir_o_Tipo_de_Verba é finalizada. Essa ação inicia um fluxo de aprovação.
*
* NAME: CasoAtualizaCamposContrato.trigger
* AUTHOR: CARLOS CARVALHO                           DATE: 28/09/2012
*
* MAINTENANCE: Inserido "if( listContract.size() == 0 ) return" na linha 42. 
* AUTHOR: CARLOS CARVALHO                           DATE: 07/01/2013 
********************************************************************************/
trigger CasoAtualizaCamposContrato on Case (before insert, before update) {
  String i = '';
/*
//    Check if this trigger is bypassed by SESAME (data migration Brazil)
if((UserInfo.getProfileId()!='00eM0000000QNYPIA4') && (UserInfo.getProfileId()!= '00eD0000001AnFlIAK')) {
    
  //RecordType de Caso - Inserir tipo de verba
  Id idRecTypeITV = RecordTypeForTest.getRecType( 'Case', 'Inserir_o_Tipo_de_Verba' );
  Id idRecTypeGDA = RecordTypeForTest.getRecType( 'Case', 'Gerar_D_A_no_sistema_ME' );
  
  Map< String, String > lMapContract = new Map< String, String >();
  List< String > listIdsContracts = new List< String >();
  
  for( Case c : trigger.new ){
    if(c.Status == 'Fechado e resolvido' && ( Trigger.isInsert || c.Status != trigger.oldmap.get( c.id ).status )
    && c.recordTypeId == idRecTypeGDA )
    {
      lMapContract.put( c.LAT_Contract__c, 'DA' );
      listIdsContracts.add( c.LAT_Contract__c );
    }
    
    if(c.recordTypeId == idRecTypeITV && c.Status == 'Aprovado' && 
    ( Trigger.isInsert || c.Status != trigger.oldmap.get( c.id ).status ) )
    {
      lMapContract.put( c.LAT_Contract__c, 'TPVerba' );
      listIdsContracts.add( c.LAT_Contract__c );
    }
  }
   
  if ( lMapContract.size() == 0 ) return;
  
  List< LAT_Contract__c > listContract = ContractDAO.getInstance().getListContractByIds( listIdsContracts );
  
  if( listContract.size() == 0 ) return;
  
  for( LAT_Contract__c contrato : listContract ){
    String lType = lMapContract.get( contrato.id );
    if ( lType == 'DA' ) contrato.demanda02_Aprovado__c = true;
    else if ( lType == 'TPVerba' ) contrato.demanda01_Aprovado__c = true;
  }
  
  if( listContract.size() > 0)
  {
    try{
      update listContract;
    }catch(DMLException e){
      System.debug(e.getMessage());
    }
    for( LAT_Contract__c contrato : listContract )
    {
        if ( contrato.Status__c == 'Ativo' ) continue;
      Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
      req.setComments( 'Aprovação de Contrato' );
      req.setNextApproverIds( new List< Id >{ contrato.ownerId } );
      req.setObjectId( contrato.Id );
      
      // submit the approval request for processing
      try{
        Approval.ProcessResult result = Approval.process( req );
      }catch(Exception e){
        System.debug(e.getMessage());
      }
    }
  }
 }
 */
}