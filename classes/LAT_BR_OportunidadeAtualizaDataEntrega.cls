//LAT_OpportunityLineItem__c TRIGGER
/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 09/11/2016
*
********************************************************************************/

public with sharing class LAT_BR_OportunidadeAtualizaDataEntrega {
	
	public static void execute(){
		
	    if( LAT_SalesOrderReturn.isFirstContextCall ){
        
	        LAT_SalesOrderReturn.isFirstContextCall = false;
	        //    Check if this trigger is bypassed by SESAME (data migration Brazil)
	        if((UserInfo.getProfileId()!='00eM0000000QNYPIA4') && (UserInfo.getProfileId()!= '00eD0000001AnFlIAK')){
	            
	            Set<Id> setOppRt = Global_RecordTypeCache.getRtIdSet('LAT_Opportunity__c',new set<String>{'Bloqueia_alteracao','Bloqueia_alteracao_do_cabecalho','Nova_oportunidade','OPP_1_NewOrder_ARG', 'OPP_2_NewOrder_URU','OPP_3_HeaderBlocked_ARG','OPP_4_HeaderBlocked_URU','OPP_5_OrderBlocked_ARG', 'OPP_6_OrderBlocked_URU'});
	                                                            
	            List<LAT_OpportunityLineItem__c> lItems = new List<LAT_OpportunityLineItem__c>();
	            if(trigger.isInsert || trigger.isUpdate){
	                for(LAT_OpportunityLineItem__c oli: LAT_OpportunityLineItemTriggerHandler.triggerNew){
	                    if(setOppRt.contains(oli.LAT_OpportunityRecordTypeId__c)){
	                        lItems.add(oli);
	                    }
	                }
	            }else{
	                for(LAT_OpportunityLineItem__c oli: LAT_OpportunityLineItemTriggerHandler.triggerOld){
	                    if(setOppRt.contains(oli.LAT_OpportunityRecordTypeId__c)){
	                        lItems.add(oli);
	                    }
	                }
	            }
	            
	            //Si no hay ningun registro de LAT no continua
	            if(!lItems.isEmpty()){
	    	        List< String > lListOppIDs = new List< String >();
	    	        for(LAT_OpportunityLineItem__c x : lItems)
	    	            if(x.LAT_CDAction__c != 'C')
	    	                lListOppIDs.add(x.LAT_Opportunity__c);
	    	        
	    	        if(lListOppIDs.size() > 0){
	    	            OportunidadeDataEntrega lCalcula = new OportunidadeDataEntrega(lListOppIDs);
	    	            List<LAT_Opportunity__c> lListOpps = new List<LAT_Opportunity__c>();
	    	            Set<String> lSetOpp = new Set<String>();
	    	          
	    	            for(LAT_OpportunityLineItem__c x: lItems){
	    	                if(lSetOpp.contains(x.LAT_Opportunity__c)) continue;
	    	                lSetOpp.add(x.LAT_Opportunity__c);
	    	                LAT_Opportunity__c lOpp = lCalcula.LAT_atualizaPedido(x.LAT_Opportunity__c);
	    	                if(lOpp != null ) lListOpps.add(lOpp);
	    	            }
	    	            if(!lListOpps.isEmpty()) update lListOpps;
	    	        }
	            }
	        }

	    }

	    
	    
	}

}