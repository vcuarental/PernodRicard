//LAT_CASE__c TRIGGER
/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 08/11/2016
*
********************************************************************************/

public with sharing class LAT_LATCase_CancelaContrato {
	
	public static void execute(){
		//    Check if this trigger is bypassed by SESAME (data migration Brazil)
		if((UserInfo.getProfileId()!='00eM0000000QNYPIA4') && (UserInfo.getProfileId()!= '00eD0000001AnFlIAK')) {
		    
		    //Declaração de variáveis
		    List< String > lListIdsContrato = new List< String >();
		    List< LAT_Contract__c > lListContract = new List< LAT_Contract__c >();
		    List< LAT_Contract__c > lListContractUpdate = new List< LAT_Contract__c >();
		    
		    //RecordType de Caso - Inserir tipo de verba e Gerar DA
		    Id idRecTypeITV = RecordTypeForTest.getRecType( 'LAT_Case__c', 'Inserir_o_Tipo_de_Verba' );
		    Id idRecTypeGDA = RecordTypeForTest.getRecType( 'LAT_Case__c', 'Gerar_D_A_no_sistema_ME' );
		    Id idRecTypeOnContNaoAprovado = RecordTypeForTest.getRecType( 'LAT_Contract__c', 'OnTradeContratoNaoAprovado' );
		  
		    for( LAT_Case__c caso:LAT_CaseTriggerHandler.triggerNew ){
		        if( ( caso.LAT_Status__c == 'Não aprovado' || caso.LAT_Status__c == 'Fechado e cancelado') && 
		            (caso.RecordTypeId == idRecTypeGDA || caso.RecordTypeId == idRecTypeITV) ){
		            
		            lListIdsContrato.add( caso.LAT_Contract__c );
		        }
		    }
		    
		    if( lListIdsContrato != null && lListIdsContrato.size() > 0 ){
		        lListContract = ContractDAO.getInstance().getListContractByIds( lListIdsContrato );
		        
		        if( lListContract.size() == 0 ) return;
		        
		        for( LAT_Contract__c c : lListContract ){
		            //if ( ContratoSemaphoro.hasExec( c.id ) ) continue;
		            if( ContratoSemaphoro.setNewCode( c.Id, 'CasoCancelaContrato' ) ) continue;
		            c.Status__c = 'Não aprovado';
		            c.RecordTypeId = idRecTypeOnContNaoAprovado;
		            lListContractUpdate.add( c );
		        }
		        
		        if( lListContractUpdate != null ){
		            update lListContractUpdate;
		        }
		    }

		}

	}

}