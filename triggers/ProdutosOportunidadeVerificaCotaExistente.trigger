/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
*-------------------------------------------------------------------------------
* SEMPRE QUE UM PRODUTO É INSERIDO EM UMA OPORTUNIDADE DEVE SER VERIFICADO 
* SE O EXISTE COTA PARA VENDA. PODERÁ OCORRER 3 CENÁRIOS: 1) NÃO EXISTE COTA, 
* A VENDA É LIBERADA. 2) EXISTE E É INSUFICIENTE, A VENDA É BLOQUEADA. 
* 3) EXISTE E É SUFICIENTE A VENDA É LIBERADA.
*  
* NAME: ProdutosOportunidadeVerificaCotaExistente.trigger
* AUTHOR: CARLOS CARVALHO                          DATE: 
*
*
* MAINTENANCE: INSERIDO FUNCIONALIDADE QUE VALIDA O ID DO TIPO DE REGISTRO 
* DOS OBJETOS.
* AUTHOR: CARLOS CARVALHO                          DATE: 08/01/2013
*******************************************************************************/
trigger ProdutosOportunidadeVerificaCotaExistente on OpportunityLineItem (before insert, before update, before delete) {

    //Check if this trigger is bypassed by SESAME (data migration Brazil)
    if((UserInfo.getProfileId()!='00eM0000000QNYPIA4') && (UserInfo.getProfileId()!= '00eD0000001AnFlIAK')) {
    
        if(trigger.isDelete){
            LAT_Cota.deleteOpportunityLine(Trigger.old);
        
        }
    }
        /*
        //Declaração de variáveis.
        List<OpportunityLineItem> listOpportunityLineItems = new List<OpportunityLineItem>();
        List<OpportunityLineItem> listOpportunityLineItemsOld = new List<OpportunityLineItem>();
        List<Opportunity> listOpportunity;
        List<Cota_regional__c> listCotasRegionais;
        List<String> listIdsSKU = new List<String>();
        List<String> listIdsOpportunity = new List<String>();
        List<String> listIdsPricebookEntry = new List<String>();
        List<Cota_regional__c> listParamsCota;
        Map<String, Cota_regional__c> mapCotaRegional = new Map<String, Cota_regional__c>();
        Map<String, Opportunity> mapOpportunity = new Map<String, Opportunity>();
        List<Cota_regional__c> listCotasRegionaisUpdate = new List<Cota_regional__c>();
        List<PricebookEntry> listPricebookEntry;
        Map<String, String> mapSKUs = new Map<String, String>();
        Map<String, String> idsSkuNew = new Map<String, String>();
        
        //Armazena produtos da oportunidade em uma lista
        Set<Id> setOppRt = Global_RecordTypeCache.getRtIdSet('Opportunity',new set<String>{'Bloqueia_alteracao','Bloqueia_alteracao_do_cabecalho','Nova_oportunidade'});
        
        if(trigger.isInsert){
            for(OpportunityLineItem oli: trigger.New){
                if(setOppRt.contains(oli.LAT_OpportunityRecordTypeId__c)){
                    listOpportunityLineItems.add(oli);
                }
            }
        }
        if(trigger.isUpdate){
            for(OpportunityLineItem oli: trigger.New){
                if(setOppRt.contains(oli.LAT_OpportunityRecordTypeId__c)){
                    listOpportunityLineItems.add(oli);
                }
            }
            for(OpportunityLineItem oli: trigger.Old){
                if(setOppRt.contains(oli.LAT_OpportunityRecordTypeId__c)){
                    listOpportunityLineItemsOld.add(oli);
                }
            }
        }
        if(trigger.isDelete){
            for(OpportunityLineItem oli: trigger.Old){
                if(setOppRt.contains(oli.LAT_OpportunityRecordTypeId__c)){
                    listOpportunityLineItemsOld.add(oli);
                }
            }
        }
        
        //verifica se existem itens na lista.
        if(listOpportunityLineItems != null && listOpportunityLineItems.size()>0){
            
            for(OpportunityLineItem oli:listOpportunityLineItems){
                //Adiciona na lista Ids de PricebookEntry
                listIdsPricebookEntry.add(oli.PricebookEntryId);
                //Adiciona na lista Ids de Oportunidade
                listIdsOpportunity.add(oli.OpportunityId);
            }
            
            //Verifica se foi possível recuperar itens no objeto PricebookEntry.
            if(listIdsPricebookEntry != null && listIdsPricebookEntry.size()>0){
                // Recupera uma lista de objetos do tipo PricebookEntry.
                // @param listIdsPricebookEntry
                listPricebookEntry = PricebookEntryDAO.getInstance().getListPricebookEntry(listIdsPricebookEntry);
                
                for(PricebookEntry pbe:listPricebookEntry){
                    //Adiciona na lista Números de SKU que estão no objeto Product2
                    listIdsSKU.add(pbe.Product2.Sku__c);
                    //Faz um map de chave=ID do pricebookEntry e value=SKU do produto
                    mapSKUs.put(pbe.Id, pbe.Product2.Sku__c);
                }
                // Recupera uma lista de objetos de oportunidade.
                // @param listIdsOpportunity
                listOpportunity = OportunidadeDAO.getInstance().getListOpportunity( listIdsOpportunity );
                
                for ( Opportunity opp : listOpportunity ){
                    //Faz um map de chave=ID da oportunidade e value= objeto oportunidade
                    mapOpportunity.put( opp.Id, opp );
                }
                
                Boolean LerOpp = true;
                for(OpportunityLineItem oli:listOpportunityLineItems){
                    if (LerOpp){
                        List< Opportunity > oppL = [ SELECT id, Origem_do_pedido__c, Pais__c FROM Opportunity WHERE id =: oli.OpportunityId limit 1];
                        LerOpp = false;                       
                        if (oppL.isEmpty()) return;
                        if (oppL[0].Pais__c != 1) return;
                        if (oppL[0].Origem_do_pedido__c != 'CRM') return;
                    }
                }
                
                CotasRegionaisConsulta fCotaRegional = new CotasRegionaisConsulta( listIdsSKU );
                List<Cota_regional__c> lListCotaRegional = CotasRegionaisDAO.getInstance().getListCotasRegionais( listIdsSKU );
                Map<String, Cota_regional__c> lMapSkuCotaR = new Map<String, Cota_regional__c>();
                
                for(Cota_regional__c cota:lListCotaRegional){
                    lMapSkuCotaR.put(cota.Sku__c, cota);
                }
                
                for(OpportunityLineItem oli: listOpportunityLineItems){
                    Cota_regional__c lCotaRegional = lMapSkuCotaR.get(oli.Sku__c);
                    if(lCotaRegional == null) continue;
                    
                    Cota_regional__c cotaR = fCotaRegional.getCota( mapSKUs.get( oli.PricebookEntryId ), mapOpportunity.get( oli.OpportunityId ) );
                    cotaR = getCota(listCotasRegionaisUpdate, cotaR);
                    
                    if ( oli.cd_line_status__c == null && cotaR == null && oli.Quantity > 0){
                        oli.addError('Este cliente não possui cota para o SKU: ' +oli.Sku__c);
                    }else if ( cotaR != null ){
                        if ( Trigger.isInsert ){
                            if ( cotaR.Saldo_de_cota__c >= oli.Quantity ){
                                if ( cotaR.Cota_utilizada__c == null ){cotaR.Cota_utilizada__c = 0;}
                                if(!oli.LAT_BR_isSumInQuota__c){
                                    cotaR.Cota_utilizada__c += oli.Quantity;
                                    addOrReplace(listCotasRegionaisUpdate, cotaR);
                                    oli.LAT_BR_isSumInQuota__c = true;
                                }
                            }else{
                                if (oli.cd_line_status__c == null){
                                    oli.addError('O produto '+oli.sku__c+' não dispõe dessa cota para venda. O limite é =  '+cotaR.Saldo_de_cota__c); 
                                }else{
                                    if ( cotaR.Cota_utilizada__c == null ){cotaR.Cota_utilizada__c = 0;}
                                    if(!oli.LAT_BR_isSumInQuota__c){
                                        cotaR.Cota_utilizada__c += oli.Quantity;
                                        addOrReplace(listCotasRegionaisUpdate, cotaR);
                                        oli.LAT_BR_isSumInQuota__c = true;
                                    }
                                }
                            }
                        }else if ( Trigger.isUpdate ){
                            if ( oli.Remover__c){
                                if ((!Trigger.oldMap.get(oli.Id).Remover__c) && (Trigger.oldMap.get(oli.Id).cd_line_status__c != '999')){
                                    if ( cotaR.Cota_utilizada__c == null ){cotaR.Cota_utilizada__c = 0;}
                                    if(oli.LAT_BR_isSumInQuota__c){
                                        cotaR.Cota_utilizada__c -= oli.Quantity;
                                        addOrReplace(listCotasRegionaisUpdate, cotaR);
                                        oli.LAT_BR_isSumInQuota__c = false;
                                    }
                                }
                            }else{
                                String DescricaoStatus = ' ';
                                if (oli.Descricao_do_status__c == null){
                                    DescricaoStatus = ' ';
                                }else{
                                    DescricaoStatus = oli.Descricao_do_status__c;
                                }
                                String OldDescricaoStatus = ' ';
                                if (Trigger.oldMap.get( oli.Id ).Descricao_do_status__c == null){
                                    OldDescricaoStatus = ' ';
                                }else{
                                    OldDescricaoStatus = Trigger.oldMap.get( oli.Id ).Descricao_do_status__c;
                                }
                                
                                if (!OldDescricaoStatus.startsWith('Cancelado')){
                                    if ( cotaR.Cota_utilizada__c == null ){cotaR.Cota_utilizada__c = 0;}
                                    if(oli.LAT_BR_isSumInQuota__c){
                                        cotaR.Cota_utilizada__c -= Trigger.oldMap.get( oli.Id ).Quantity;
                                        oli.LAT_BR_isSumInQuota__c = false;
                                    }
                                }
                                
                                if ( ( cotaR.Cota__c - cotaR.Cota_utilizada__c ) >= oli.Quantity){
                                    if (!DescricaoStatus.startsWith('Cancelado')){
                                        if ( cotaR.Cota_utilizada__c == null ){cotaR.Cota_utilizada__c = 0;}
                                        if(!oli.LAT_BR_isSumInQuota__c){
                                            cotaR.Cota_utilizada__c += oli.Quantity;
                                            oli.LAT_BR_isSumInQuota__c = true;
                                        }
                                    }
                                    addOrReplace(listCotasRegionaisUpdate, cotaR);
                                }else{
                                    if ( cotaR.Cota_utilizada__c == null ){cotaR.Cota_utilizada__c = 0;}
                                    if (oli.cd_line_status__c == null){
                                        oli.addError('O produto '+oli.sku__c+' não dispõe dessa cota para venda. O limite é de '+Integer.valueOf((cotaR.Cota__c-cotaR.Cota_utilizada__c)));
                                    }else{
                                        if (!DescricaoStatus.startsWith('Cancelado')){
                                            if(!oli.LAT_BR_isSumInQuota__c){
                                                cotaR.Cota_utilizada__c += oli.Quantity;
                                                oli.LAT_BR_isSumInQuota__c = true;
                                            }
                                        }
                                        addOrReplace(listCotasRegionaisUpdate, cotaR);
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    
        if(Trigger.isDelete){
            listIdsPricebookEntry = new List<String>();
            listIdsOpportunity = new List<String>();
            
            for(OpportunityLineItem oli:listOpportunityLineItemsOld){
                //Adiciona na lista Ids de PricebookEntry
                listIdsPricebookEntry.add(oli.PricebookEntryId);
                //Adiciona na lista Ids de Oportunidade
                listIdsOpportunity.add(oli.OpportunityId);
            }
            listOpportunity = OportunidadeDAO.getInstance().getListOpportunity( listIdsOpportunity );
            // Recupera uma lista de objetos do tipo PricebookEntry.
            // @param listIdsPricebookEntry
            listPricebookEntry = PricebookEntryDAO.getInstance().getListPricebookEntry(listIdsPricebookEntry);
            
            for(PricebookEntry pbe:listPricebookEntry){
                //Adiciona na lista Números de SKU que estão no objeto Product2
                listIdsSKU.add(pbe.Product2.Sku__c);
            }
            
            for ( Opportunity opp : listOpportunity ){
                //Faz um map de chave=ID da oportunidade e value= objeto oportunidade
                mapOpportunity.put( opp.Id, opp );
            }
            
            //Recupera as cotas regionais
            mapSKUs = CotasRegionaisConsulta.getPriceEntryXSKU(trigger.old);
            CotasRegionaisConsulta fCotaRegional = new CotasRegionaisConsulta( mapSKUs.values() );
            
            List<Cota_regional__c> lListCotaRegional = new List<Cota_regional__c>();
            lListCotaRegional = CotasRegionaisDAO.getInstance().getListCotasRegionais( listIdsSKU );
            Map<String, Cota_regional__c> lMapSkuCotaR = new Map<String, Cota_regional__c>();
            
            for(Cota_regional__c cota:lListCotaRegional){
                lMapSkuCotaR.put(cota.Sku__c, cota);
            }
            
            for(OpportunityLineItem oliOld:trigger.old){
                Cota_regional__c lCotaRegional = lMapSkuCotaR.get(oliOld.Sku__c);
                
                if(lCotaRegional == null) continue;
                
                if(listOpportunityLineItems == null){
                    Cota_regional__c cotaR = fCotaRegional.getCota( mapSKUs.get( oliOld.PricebookEntryId ), mapOpportunity.get( oliOld.OpportunityId ) );
                    cotaR = getCota(listCotasRegionaisUpdate, cotaR);
                    
                    if ( cotaR != null ){
                        if(oliOld.LAT_BR_isSumInQuota__c){
                            cotaR.Cota_utilizada__c -= oliOld.Quantity;
                            addOrReplace(listCotasRegionaisUpdate, cotaR);
                        }
                    }
                }else{
                    for(OpportunityLineItem oli: listOpportunityLineItems){
                        idsSkuNew.put(oli.Id,oli.Id);
                    }
                    if(idsSkuNew.get(oliOld.Id) == null){
                        Cota_regional__c cotaR = fCotaRegional.getCota( mapSKUs.get( oliOld.PricebookEntryId ), mapOpportunity.get( oliOld.OpportunityId ) );
                        cotaR = getCota(listCotasRegionaisUpdate, cotaR);
                        
                        if ( cotaR != null ){
                            if(oliOld.LAT_BR_isSumInQuota__c){
                                cotaR.Cota_utilizada__c -= oliOld.Quantity;
                            }
                            addOrReplace(listCotasRegionaisUpdate, cotaR);
                        }
                    }
                }
            }
        }
        
        if ( listCotasRegionaisUpdate != null && listCotasRegionaisUpdate.size() > 0 ){
            update listCotasRegionaisUpdate;
        }
    }
    
    private void addOrReplace(List<Cota_regional__c> lcru, Cota_regional__c cotaR){
        if(cotaR != null){
            for(Cota_regional__c cota: lcru){
                if(cota.Id == cotaR.Id){
                    cota = cotaR;
                    return;
                }
            }
        }
        lcru.add(cotaR);
    }
    
    private Cota_regional__c getCota(List<Cota_regional__c> lcru, Cota_regional__c cotaR){
        if(cotaR != null){
            for(Cota_regional__c cota: lcru){
                if(cota.Id == cotaR.Id){
                    return cota;
                }
            }
        }
        return cotaR;
    }*/
    
}