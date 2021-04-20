//LAT_CASE__c TRIGGER
/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 07/11/2016
*
********************************************************************************/

public with sharing class LAT_LATCase_AtualizaCamposContrato {

	public static void execute(){
		//    Check if this trigger is bypassed by SESAME (data migration Brazil)
		if((UserInfo.getProfileId()!='00eM0000000QNYPIA4') && (UserInfo.getProfileId()!= '00eD0000001AnFlIAK')) {
		    
		  //RecordType de Caso - Inserir tipo de verba
		  Id idRecTypeITV = RecordTypeForTest.getRecType( 'LAT_Case__c', 'Inserir_o_Tipo_de_Verba' );
		  Id idRecTypeGDA = RecordTypeForTest.getRecType( 'LAT_Case__c', 'Gerar_D_A_no_sistema_ME' );
		  
		  Map< String, String > lMapContract = new Map< String, String >();
		  List< String > listIdsContracts = new List< String >();
		  
		  for( LAT_Case__c c : LAT_CaseTriggerHandler.triggerNew ){
		    if(c.LAT_Status__c == 'Fechado e resolvido' && ( Trigger.isInsert || c.LAT_Status__c != LAT_CaseTriggerHandler.mapOld.get( c.id ).LAT_Status__c )
		    && c.recordTypeId == idRecTypeGDA )
		    {
		      lMapContract.put( c.LAT_Contract__c, 'DA' );
		      listIdsContracts.add( c.LAT_Contract__c );
		    }
		    
		    if(c.recordTypeId == idRecTypeITV && c.LAT_Status__c == 'Aprovado' && 
		    ( Trigger.isInsert || c.LAT_Status__c != LAT_CaseTriggerHandler.mapOld.get( c.id ).LAT_Status__c ) )
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
	    
	}
}