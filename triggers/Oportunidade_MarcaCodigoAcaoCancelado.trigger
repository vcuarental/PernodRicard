/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
*-------------------------------------------------------------------------------
*
* NAME: Oportunidade_MarcaCodigoAcaoCancelado.trigger
* AUTHOR:                                               DATE: 
*
*
* MAINTENANCE: INSERIDO FUNCIONALIDADE QUE VALIDA O ID DO TIPO DE REGISTRO DOS OBJETOS.
* AUTHOR: CARLOS CARVALHO                               DATE: 08/01/2013
*******************************************************************************/
trigger Oportunidade_MarcaCodigoAcaoCancelado on Opportunity (before update,after update) {

	//    Check if this trigger is bypassed by SESAME (data migration Brazil)
	if((UserInfo.getProfileId()!='00eM0000000QNYPIA4') && (UserInfo.getProfileId()!= '00eD0000001AnFlIAK')) {
	 if(Trigger.isUpdate && Trigger.isBefore){   
	    //Declaração de variáveis
	    Set< Id > setRecTypeOpp = new Set< Id >();
	    setRecTypeOpp.add( RecordTypeForTest.getRecType('Opportunity', 'Bloqueia_alteracao'));
	    setRecTypeOpp.add( RecordTypeForTest.getRecType('Opportunity', 'Bloqueia_alteracao_do_cabecalho'));
	    setRecTypeOpp.add( RecordTypeForTest.getRecType('Opportunity', 'Nova_oportunidade'));    
	        
		//Se campo Cancelamento_aprovado__c é marcado como TRUE pelo processo de aprovação, copia C para 
		//Codigo de acao para os itens de pedido cancelados
		List< String > lListOppId = new List< String >();
	    for ( Opportunity lOpp : Trigger.new ){
			if( !setRecTypeOpp.contains( lOpp.RecordTypeId )) continue;
			
			if ( lOpp.Cancelar_pedido__c )
				lOpp.CD_Action__c = 'C';
			
			if ( lOpp.Tem_Item_cancelado__c > trigger.oldMap.get(lOpp.id).Tem_Item_cancelado__c) {
				lListOppId.add( lOpp.Id );
				lOpp.RecordTypeId = RecordTypeForTest.getRecType('Opportunity', 'Bloqueia_alteracao_do_cabecalho');
			
			
			/*
			if ( lOpp.Cancelamento_aprovado__c && !Trigger.oldMap.get( lOpp.Id ).Cancelamento_aprovado__c ){
				lListOppId.add( lOpp.Id );
				lOpp.Cancelamento_aprovado__c = false;
			}
			*/
			}
	 }
	}
	   if(Trigger.isAfter && Trigger.isUpdate){
	   // if ( lListOppId.size() > 0 ){
	   // 
	    	List< String > lListOppId = new List< String >();
	    	for (Opportunity op : Trigger.new){
	    		if ( op.Tem_Item_cancelado__c > trigger.oldMap.get(op.id).Tem_Item_cancelado__c){ 
						lListOppId.add( op.Id );
	    		}
	    	} 

		    List< OpportunityLineItem > lListOppItem = [ SELECT Id, OpportunityId, Remover__c, CD_Action__c FROM OpportunityLineItem WHERE OpportunityId =:lListOppId AND Remover__c = True ];
		    	if ( lListOppItem.size() > 0 ){
		    		for ( OpportunityLineItem lItem : lListOppItem )
		    			//if(trigger.newMap.get(lItem.Id) != null)
		    				lItem.CD_Action__c = 'C'; 
		    		update lListOppItem;
		    	}
		    }	
		}
	}