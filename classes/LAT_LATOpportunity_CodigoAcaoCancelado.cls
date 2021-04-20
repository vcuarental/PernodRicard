//LAT_Opportunity__c TRIGGER
/********************************************************************************
*
* MIGRACION LICENCIAS
* AUTHOR: ZIMMIC                     DATE: 08/11/2016
*
********************************************************************************/

public with sharing class LAT_LATOpportunity_CodigoAcaoCancelado  {

	public static void execute(){
		//    Check if this trigger is bypassed by SESAME (data migration Brazil)
		if((UserInfo.getProfileId()!='00eM0000000QNYPIA4') && (UserInfo.getProfileId()!= '00eD0000001AnFlIAK')) {
		 if(Trigger.isUpdate && Trigger.isBefore){
		    //Declaração de variáveis
		    Set< Id > setRecTypeOpp = new Set< Id >();
		    setRecTypeOpp.add( RecordTypeForTest.getRecType('LAT_Opportunity__c', 'Bloqueia_alteracao'));
		    setRecTypeOpp.add( RecordTypeForTest.getRecType('LAT_Opportunity__c', 'Bloqueia_alteracao_do_cabecalho'));
		    setRecTypeOpp.add( RecordTypeForTest.getRecType('LAT_Opportunity__c', 'Nova_oportunidade'));

			//Se campo Cancelamento_aprovado__c é marcado como TRUE pelo processo de aprovação, copia C para
			//Codigo de acao para os itens de pedido cancelados
			List< String > lListOppId = new List< String >();
		    for ( LAT_Opportunity__c lOpp : LAT_OpportunityTriggerHandler.triggerNew ){
				if( !setRecTypeOpp.contains( lOpp.RecordTypeId )) continue;

				if ( lOpp.LAT_CancelOrder__c )
					lOpp.LAT_CDAction__c = 'C';
				
				if ( lOpp.LAT_ItemsCanceled__c > LAT_OpportunityTriggerHandler.mapOld.get(lOpp.id).LAT_ItemsCanceled__c) {
					lListOppId.add( lOpp.Id );
					lOpp.RecordTypeId = RecordTypeForTest.getRecType('LAT_Opportunity__c', 'Bloqueia_alteracao_do_cabecalho');


				}
		 }
		}
	   if(Trigger.isAfter && Trigger.isUpdate){
	   // if ( lListOppId.size() > 0 ){
	   //
	    	List< String > lListOppId = new List< String >();
	    	for (LAT_Opportunity__c op : LAT_OpportunityTriggerHandler.triggerNew){
	    		if ( op.LAT_ItemsCanceled__c > LAT_OpportunityTriggerHandler.mapOld.get(op.id).LAT_ItemsCanceled__c){
						lListOppId.add( op.Id );
	    		}
	    	}

			if(!lListOppId.isEmpty()){
				List< LAT_OpportunityLineItem__c > lListOppItem = [ SELECT Id, LAT_Opportunity__c, LAT_Remover__c, LAT_CDAction__c FROM LAT_OpportunityLineItem__c WHERE LAT_Opportunity__c =:lListOppId AND LAT_Remover__c = True ];
			    	if ( lListOppItem.size() > 0 ){
			    		for ( LAT_OpportunityLineItem__c lItem : lListOppItem )
			    			//if(trigger.newMap.get(lItem.Id) != null)
			    				lItem.LAT_CDAction__c = 'C';
			    		update lListOppItem;
			    	}
			    }
			}

		}

	}
}