//LAT_Opportunity__c TRIGGER
/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 08/11/2016
*
********************************************************************************/

public with sharing class LAT_LATOpportunity_AtualizaDataEntrega {
	
	public static void execute(){
		//Check if this trigger is bypassed by SESAME (data migration Brazil)
		if((UserInfo.getProfileId()!='00eM0000000QNYPIA4') && (UserInfo.getProfileId()!= '00eD0000001AnFlIAK')) {

			//Declaração de variáveis
			Set< Id > setRecTypeOpp = new Set< Id >();
			List< String > lListOppIDs = new List< String >();
			
			//Recupera os ids de tipo de registro de ooportunidade
			setRecTypeOpp.add( RecordTypeForTest.getRecType('LAT_Opportunity__c', 'Bloqueia_alteracao'));
			setRecTypeOpp.add( RecordTypeForTest.getRecType('LAT_Opportunity__c', 'Bloqueia_alteracao_do_cabecalho'));
			setRecTypeOpp.add( RecordTypeForTest.getRecType('LAT_Opportunity__c', 'Nova_oportunidade'));
			
			setRecTypeOpp.add( RecordTypeForTest.getRecType('LAT_Opportunity__c', 'OPP_1_NewOrder_ARG'));
			setRecTypeOpp.add( RecordTypeForTest.getRecType('LAT_Opportunity__c', 'OPP_2_NewOrder_URU'));
			setRecTypeOpp.add( RecordTypeForTest.getRecType('LAT_Opportunity__c', 'OPP_3_HeaderBlocked_ARG'));
			setRecTypeOpp.add( RecordTypeForTest.getRecType('LAT_Opportunity__c', 'OPP_4_HeaderBlocked_URU'));
			setRecTypeOpp.add( RecordTypeForTest.getRecType('LAT_Opportunity__c', 'OPP_5_OrderBlocked_ARG'));
			setRecTypeOpp.add( RecordTypeForTest.getRecType('LAT_Opportunity__c', 'OPP_6_OrderBlocked_URU'));
			
			for( LAT_Opportunity__c x : LAT_OpportunityTriggerHandler.triggerNew ){
				if(setRecTypeOpp.contains( x.RecordTypeId )){
					lListOppIDs.add( x.Id );
				}
			}
			
			if(!lListOppIDs.isEmpty()){
				OportunidadeDataEntrega lCalcula = new OportunidadeDataEntrega( lListOppIDs );
				for( LAT_Opportunity__c x : LAT_OpportunityTriggerHandler.triggerNew ){
					if(setRecTypeOpp.contains( x.RecordTypeId )){
						lCalcula.atualizaPedido( x );
					}
				}
			}
		}

	}

}