//LAT_CASE__c TRIGGER
/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 08/11/2016
*
********************************************************************************/

public with sharing class LAT_LATCase_CopiaIdGerenteRegionalArea {
	
	public static void execute(){
		    
		//    Check if this trigger is bypassed by SESAME (data migration Brazil)
		if((UserInfo.getProfileId()!='00eM0000000QNYPIA4') && (UserInfo.getProfileId()!= '00eD0000001AnFlIAK')) {
		  
		    //Declaração de variáveis.
		    List<String> listIdOwnerObjeto = new List<String>();
		    Map< String, User > userMap = new Map< String, User >();
		    List<User> listUser = new List<User>();
		    Set< Id > setRecType = new Set< Id >();
		    setRecType.add( RecordTypeForTest.getRecType('LAT_Case__c', 'Alteracao_rota_de_promotor') );
		    setRecType.add( RecordTypeForTest.getRecType('LAT_Case__c', 'Alteracao_cadastro_de_clientes') );
		    setRecType.add( RecordTypeForTest.getRecType('LAT_Case__c', 'Cancelar_D_A_no_sistema_ME') );
		    setRecType.add( RecordTypeForTest.getRecType('LAT_Case__c', 'Cliente_inadimplente') );
		    setRecType.add( RecordTypeForTest.getRecType('LAT_Case__c', 'Contrato') );
		    setRecType.add( RecordTypeForTest.getRecType('LAT_Case__c', 'Contrato_aprovacao_de_proposta') );
		    setRecType.add( RecordTypeForTest.getRecType('LAT_Case__c', 'Contrato_Assinatura_da_diretoria') );
		    setRecType.add( RecordTypeForTest.getRecType('LAT_Case__c', 'Contrato_Assinatura_de_distrato_procurador') );
		    setRecType.add( RecordTypeForTest.getRecType('LAT_Case__c', 'Contrato_Assinatura_do_procurador') );
		    setRecType.add( RecordTypeForTest.getRecType('LAT_Case__c', 'Contrato_Negociacao_de_cancelamento') );
		    setRecType.add( RecordTypeForTest.getRecType('LAT_Case__c', 'Contrato_Processo_de_prorrogacao') );
		    setRecType.add( RecordTypeForTest.getRecType('LAT_Case__c', 'Contrato_Proposta_de_renovacao') );
		    setRecType.add( RecordTypeForTest.getRecType('LAT_Case__c', 'LAT_BR_ContractProrogation') );
		    setRecType.add( RecordTypeForTest.getRecType('LAT_Case__c', 'Contrato_assinatura_de_distrato_do_cliente') );
		    setRecType.add( RecordTypeForTest.getRecType('LAT_Case__c', 'Contrato_assinatura_de_prorrogacao_de_contrato') );
		    setRecType.add( RecordTypeForTest.getRecType('LAT_Case__c', 'Contrato_assinatura_prorroga_o_do_cliente') );
		    setRecType.add( RecordTypeForTest.getRecType('LAT_Case__c', 'Contrato_coleta_de_assinatura_do_cliente') );
		    setRecType.add( RecordTypeForTest.getRecType('LAT_Case__c', 'Contrato_coleta_de_assinatura_do_cliente_off') );
		    setRecType.add( RecordTypeForTest.getRecType('LAT_Case__c', 'Contrato_conferencia_de_documentacao') );
		    setRecType.add( RecordTypeForTest.getRecType('LAT_Case__c', 'Contrato_entrega_do_contrato') );
		    setRecType.add( RecordTypeForTest.getRecType('LAT_Case__c', 'Contrato_nao_renovacao_de_contrato') );
		    setRecType.add( RecordTypeForTest.getRecType('LAT_Case__c', 'Contrato_renovacao_de_contrato') );
		    setRecType.add( RecordTypeForTest.getRecType('LAT_Case__c', 'Gerar_D_A_no_sistema_ME' ) );
		    setRecType.add( RecordTypeForTest.getRecType('LAT_Case__c', 'Inserir_o_Tipo_de_Verba' ) );
		    setRecType.add( RecordTypeForTest.getRecType('LAT_Case__c', 'Justificativa_de_inadimplencia' ) );
		    setRecType.add( RecordTypeForTest.getRecType('LAT_Case__c', 'Novo_cadastro_de_cliente' ) );
		    setRecType.add( RecordTypeForTest.getRecType('LAT_Case__c', 'nao_renovacao' ) );
		    setRecType.add( RecordTypeForTest.getRecType('LAT_Case__c', 'Proposta_de_pagamento' ) );
		    setRecType.add( RecordTypeForTest.getRecType('LAT_Case__c', 'Sem_proposta_de_pagamento' ) );
		    setRecType.add( RecordTypeForTest.getRecType('LAT_Case__c', 'Solicitacoes_e_Reclamacoes' ) );
		    setRecType.add( RecordTypeForTest.getRecType('LAT_Case__c', 'Termino_de_contrato' ) );
		    
		    set<Id> setIdContaCaso = new set<Id>();
		    
		    for(LAT_Case__c caso : LAT_CaseTriggerHandler.triggerNew){
		        if( caso.OwnerId != null && setRecType.contains( caso.RecordTypeId ) ){
		            listIdOwnerObjeto.add(caso.OwnerId);
		            setIdContaCaso.add(caso.LAT_Account__c);
		        }
		    }
		    
		    // <Marcos 14.03.13>
		    // Tipos de registro nos quais tem atribuições diferentes de gerentes
		    set <Id> setRecTypeKAM = new set<id>();
		    setRecTypeKAM.add( RecordTypeForTest.getRecType('LAT_Case__c', 'Alteracao_cadastro_de_clientes') );
		    setRecTypeKAM.add( RecordTypeForTest.getRecType('LAT_Case__c', 'Novo_cadastro_de_cliente') );
		    // </Marcos>
		    
		    if(listIdOwnerObjeto.size() >0)
		    {
		        listUser = UserDAO.getInstance().getListUserById(listIdOwnerObjeto);
		        
		        for(User u:listUser){
		            userMap.put( u.id, u );
		        }
		        
		        map<Id,Account> mapAccCaso = new map<Id, Account>(
		                [SELECT Id, Regional_Manager__c, Area_Manager__c, Customer_is_KA__c FROM Account WHERE Id = :setIdContaCaso]);
		        
		        for(LAT_Case__c caso:LAT_CaseTriggerHandler.triggerNew){
		            User lUser = userMap.get( caso.OwnerId );
		            if ( lUser == null ) continue;
		            //<Marcos 14.03.2013>
		            Account contaCaso = mapAccCaso.get( caso.LAT_Account__c );
		            if( contaCaso == null ) continue;
		            if ( setRecTypeKAM.contains(caso.RecordTypeId) ){
		              if (contaCaso.Regional_Manager__c != null) { caso.LAT_RegionalManager__c = contaCaso.Regional_Manager__c; }
		              if (contaCaso.Area_Manager__c != null) { caso.LAT_AreaManager__c   = contaCaso.Area_Manager__c; }
		            } else {
		              caso.LAT_RegionalManager__c = lUser.gerente_regional__c;
		              caso.LAT_AreaManager__c    = lUser.gerente_de_area__c;
		            }
		            caso.LAT_Manager__c  = lUser.ManagerId;
		            
		            caso.LAT_CustomerIsKA__c = contaCaso.Customer_is_KA__c;
		            //</Marcos>
		        }
		    } 
		}
	}

}