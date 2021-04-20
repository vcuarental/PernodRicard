/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
*-------------------------------------------------------------------------------
* 
* NAME: ProdutosOportunidadeAtualizaDataEntrega.trigger
* AUTHOR: ROGÉRIO ALVARENGA                        DATE: 
*
* MAINTENANCE: INSERIDO FUNCIONALIDADE QUE VALIDA O ID DO TIPO DE REGISTRO DOS 
* OBJETOS.
* AUTHOR: CARLOS CARVALHO                          DATE: 08/01/2013
*******************************************************************************/
trigger ProdutosOportunidadeAtualizaDataEntrega on OpportunityLineItem (after delete, after insert, after update){


    if( LAT_SalesOrderReturn.isFirstContextCall ){
        
        LAT_SalesOrderReturn.isFirstContextCall = false;
        //    Check if this trigger is bypassed by SESAME (data migration Brazil)
        if((UserInfo.getProfileId()!='00eM0000000QNYPIA4') && (UserInfo.getProfileId()!= '00eD0000001AnFlIAK')){
            
            Set<Id> setOppRt = Global_RecordTypeCache.getRtIdSet('Opportunity',new set<String>{'Bloqueia_alteracao','Bloqueia_alteracao_do_cabecalho','Nova_oportunidade','OPP_1_NewOrder_ARG', 'OPP_2_NewOrder_URU','OPP_3_HeaderBlocked_ARG','OPP_4_HeaderBlocked_URU','OPP_5_OrderBlocked_ARG', 'OPP_6_OrderBlocked_URU'});
                                                            
            List<OpportunityLineItem> lItems = new List<OpportunityLineItem>();
            if(trigger.isInsert || trigger.isUpdate){
                for(OpportunityLineItem oli: trigger.New){
                    if(setOppRt.contains(oli.LAT_OpportunityRecordTypeId__c)){
                        lItems.add(oli);
                    }
                }
            }else{
                for(OpportunityLineItem oli: trigger.Old){
                    if(setOppRt.contains(oli.LAT_OpportunityRecordTypeId__c)){
                        lItems.add(oli);
                    }
                }
            }
            
            //Si no hay ningun registro de LAT no continua
            if(!lItems.isEmpty()){
    	        List< String > lListOppIDs = new List< String >();
    	        for(OpportunityLineItem x : lItems)
    	            if(x.CD_Action__c != 'C')
    	                lListOppIDs.add(x.OpportunityId);
    	        
    	        if(lListOppIDs.size() > 0){
    	            OportunidadeDataEntrega lCalcula = new OportunidadeDataEntrega(lListOppIDs);
    	            List<Opportunity> lListOpps = new List<Opportunity>();
    	            Set<String> lSetOpp = new Set<String>();
    	          
    	            for(OpportunityLineItem x: lItems){
    	                if(lSetOpp.contains(x.OpportunityId)) continue;
    	                lSetOpp.add(x.OpportunityId);
    	                Opportunity lOpp = lCalcula.atualizaPedido(x.OpportunityId);
    	                if(lOpp != null ) lListOpps.add(lOpp);
    	            }
    	            if(!lListOpps.isEmpty()) update lListOpps;
    	        }
            }
        }

    }


}