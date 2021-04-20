/*******************************************************************************
*                           Company: Zimmic
*-------------------------------------------------------------------------------
*   Clase que contiene los triggers del objeto LAT_CotaMarket__c
*******************************************************************************/
/********************************************************************************
*                       
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 04/11/2016.
*
********************************************************************************/

global class LAT_Cota {   


    public static void updateInitDate(List<LAT_CotaMarket__c> triggerNew){
        List<LAT_CotaMarket__c> toUpdate = new List<LAT_CotaMarket__c>();

        for(LAT_CotaMarket__c lc : triggerNew){
            if(lc.startDate__c == Date.today()){
                lc.initDate__c = DateTime.now();
            }else{
                                lc.initDate__c = DateTime.newInstance(lc.startDate__c, Time.newInstance(0, 0, 0, 0));

            }

        }
    }

    //Valida si ya existe una cota para ese producto
    public static void validateProduct(List<LAT_CotaMarket__c> triggerNew){
        if(!Utils.wasMigrationDone('1')){            
            Map<Id, List<LAT_CotaMarket__c>> productMap = new Map<Id, List<LAT_CotaMarket__c>>();
            List<string> productIds = new List<string>();
             
            for(LAT_CotaMarket__c cota : triggerNew){
                productIds.add(cota.SKU__c);
            }
            
            for(LAT_CotaMarket__c cota : [Select id,SKU__c,startDate__c,endDate__c from LAT_CotaMarket__c where SKU__c in: productIds]){
                if(productMap.get(cota.SKU__c) == null){
                    productMap.put(cota.SKU__c, new List<LAT_CotaMarket__c>{cota});
                }else{
                    productMap.get(cota.SKU__c).add(cota);
                }
            }
            for(LAT_CotaMarket__c cota : triggerNew){
                if(productMap.get(cota.SKU__c) != null){
                    for(LAT_CotaMarket__c co : productMap.get(cota.SKU__c)){
                        if(cota.id != co.id && 
                        (co.startDate__c >= cota.startDate__c && co.startDate__c <= cota.endDate__c ||
                         co.endDate__c >= cota.startDate__c && co.endDate__c <= cota.endDate__c ||
                         co.startDate__c < cota.startDate__c && co.endDate__c > cota.endDate__c)){
                          
                          cota.addError(Label.LAT_COTA_00007);
                          return;
                        }
                    }
                }
            }
        }
        //MIGRATED 04/11/2016
        else {
            Map<Id, List<LAT_CotaMarket__c>> productMap = new Map<Id, List<LAT_CotaMarket__c>>();
            List<string> productIds = new List<string>();
             
            for(LAT_CotaMarket__c cota : triggerNew){
                productIds.add(cota.LAT_Product__c);
            }
            
            for(LAT_CotaMarket__c cota : [Select id,LAT_Product__c,startDate__c,endDate__c from LAT_CotaMarket__c where LAT_Product__c in: productIds]){
                if(productMap.get(cota.LAT_Product__c) == null){
                    productMap.put(cota.LAT_Product__c, new List<LAT_CotaMarket__c>{cota});
                }else{
                    productMap.get(cota.LAT_Product__c).add(cota);
                }
            }
            for(LAT_CotaMarket__c cota : triggerNew){
                if(productMap.get(cota.LAT_Product__c) != null){
                    for(LAT_CotaMarket__c co : productMap.get(cota.LAT_Product__c)){
                        if(cota.id != co.id && 
                        (co.startDate__c >= cota.startDate__c && co.startDate__c <= cota.endDate__c ||
                         co.endDate__c >= cota.startDate__c && co.endDate__c <= cota.endDate__c ||
                         co.startDate__c < cota.startDate__c && co.endDate__c > cota.endDate__c)){
                          
                          cota.addError(Label.LAT_COTA_00007);
                          return;
                        }
                    }
                }
            }            
        }
        
    }

    webservice static String validateCotaAndIntegrate(String oppId){
       return validateConsumeCota(oppId);
    }


    @future (callout=true)
    public static void validateCotaAndIntegrateFuture(String oppId){

        System.debug('%%%%%% Entramos validateCotaAndIntegrateFuture 1.');
        String msg = validateConsumeCota(oppId);
    }

    public static boolean isProcessing {get; set;}
    public static Set<Id> processingIds {get; set;}

    //Valida y consume una cota para una lista de lineas de oppty
    public static String validateConsumeCota(String oppId){
        if(!Utils.wasMigrationDone('1')){         
            Opportunity opp = null;
            Set< Id > setRecTypeOpp = new Set< Id >();
            setRecTypeOpp.add( RecordTypeForTest.getRecType( 'Opportunity', 'Bloqueia_alteracao' ) );
            setRecTypeOpp.add( RecordTypeForTest.getRecType( 'Opportunity', 'Bloqueia_alteracao_do_cabecalho' ) );
            setRecTypeOpp.add( RecordTypeForTest.getRecType( 'Opportunity', 'Nova_oportunidade' ) );
            
            List< Opportunity > oppL = [ SELECT id,ownerId,account.Regional__c,account.Sub_Channel__c,account.Sub_Channel_Rating__c,account.Customer_Flag__c, CD_Action__c, Owner.C_digo_JDE__c, Account.Business_Unit__c,
                                Freight__c, DS_Message1__c, DS_Message2__c, CloseDate, Account.Client_code_AN8__c, CreatedDate, 
                                type, NR_order_JDE__c, CD_order_status__c, NR_customer_order__c, Origem_do_pedido__c, RecordTypeId, 
                                Quantidade_total_de_caixas__c, Cancelar_pedido__c, LAT_Enviado_a_JDE__c, Integracao__c 
                                FROM Opportunity WHERE Id =: oppId AND RecordTypeId =: setRecTypeOpp limit 1];


                                  
            if ( oppL.size() == 0 ) return 'Pedido (id:' + oppId + ') não encontrado';
            opp = oppL[ 0 ];

            if ( opp.Origem_do_pedido__c != 'CRM' && opp.Origem_do_pedido__c != 'APP' ) return Label.LAT_COTA_00001;
            if (opp.type != null && opp.type.length() >1)if (opp.type.substring(0,2) != 'SO' )return null;
            
            //Nao enviar pedido sem itens para o JDE - 24/07/2013 - inicio
            if (opp.Quantidade_total_de_caixas__c == 0) return Label.LAT_COTA_00002;
            //Nao enviar pedido sem itens para o JDE - 24/07/2013 - fim
            

            String lRecType = RecordTypeForTest.getRecType( 'Opportunity','Bloqueia_alteracao' );
            if ( opp.RecordTypeId == lRecType ) return Label.LAT_COTA_00003;

            //Actualiza la closeDate con la fecha del primer envio
            if(!opp.LAT_Enviado_a_JDE__c && opp.nr_order_jde__c != '' && opp.nr_order_jde__c != null)opp.LAT_Enviado_a_JDE__c = true;
            
            if(!opp.LAT_Enviado_a_JDE__c){
                opp.CloseDate = Date.today();
                opp.LAT_Enviado_a_JDE__c = true;
            }


            List<OpportunityLineItem> listaItens = [ SELECT opportunity.AccountId,Cota_Consumida__r.consumo__c,Cota_Consumida__c,cantidadCotaConsumida__c,PriceBookEntry.Product2Id, 
             Quantity FROM OpportunityLineItem 
            WHERE OpportunityId =: opp.id AND (NOT Descricao_do_status__c LIKE 'Cancelado%')];//cd_line_status__c <> '999' ];
            
            List<String> linesProductsIds = new List<String>();
            Map<String,Lat_cotaMarket__c> cotasMap = new Map<String,Lat_cotaMarket__c>();

            List<OpportunityLineItem> linesToUpdate = new List<OpportunityLineItem>();
            List<LAT_DetalheCotaMarket__c> detalhesToUpdate = new List<LAT_DetalheCotaMarket__c>();

            Map<String,LAT_DetalheCotaMarket__c> mapToUpdate = new Map<String,LAT_DetalheCotaMarket__c>();
            
            for(OpportunityLineItem li : listaItens){
                linesProductsIds.add(li.PriceBookEntry.Product2Id);
            }

            for(Lat_cotaMarket__c cota : getCotasToConsume(opp.CloseDate,linesProductsIds)){
                cotasMap.put(cota.SKU__c, cota);
            }

            for(OpportunityLineItem li : listaItens){
                if(li.cantidadCotaConsumida__c == null)li.cantidadCotaConsumida__c = 0;

                if(cotasMap.get(li.PriceBookEntry.Product2Id) != null){
                    if(li.Cota_Consumida__c != null){
                        LAT_DetalheCotaMarket__c dc = mapToUpdate.get(li.Cota_Consumida__c);
                        if(dc == null)dc = li.Cota_Consumida__r;

                        dc.consumo__c +=  (li.Quantity - li.cantidadCotaConsumida__c);
                        li.cantidadCotaConsumida__c = li.Quantity;
                        linesToUpdate.add(li);
                        detalhesToUpdate.add(dc);
                        mapToUpdate.put(dc.id,dc);
                    }else{
                        for(LAT_DetalheCotaMarket__c detalhe : cotasMap.get(li.PriceBookEntry.Product2Id).Detalhes_Cota__r){
                            if(detalhe.cliente__c == opp.AccountId){
                                if(detalhe.consumo__c + li.Quantity > detalhe.cota__c){
                                        return Label.LAT_COTA_00004;
                                }else{
                                    LAT_DetalheCotaMarket__c dc = mapToUpdate.get(detalhe.id);
                                    if(dc == null)dc = detalhe;

                                    dc.consumo__c +=  (li.Quantity - li.cantidadCotaConsumida__c);
                                    li.Cota_Consumida__c = detalhe.id;
                                    li.cantidadCotaConsumida__c = li.Quantity;
                                    linesToUpdate.add(li);
                                    detalhesToUpdate.add(detalhe);
                                    mapToUpdate.put(dc.id,dc);
                                    break;
                                }
                            }else if(detalhe.cliente__c == null){
                                if((detalhe.executivo__c == null || detalhe.executivo__c == opp.ownerId)
                                 && (detalhe.bandeira__c == null || (detalhe.bandeira__c == opp.account.Customer_Flag__c && opp.account.Customer_Flag__c != null))
                                 && (detalhe.Regional__c == null || (detalhe.Regional__c == opp.account.Regional__c && opp.account.Regional__c != null))
                                 && (detalhe.sub_canal__c == null || (detalhe.sub_canal__c == opp.account.Sub_Channel__c && opp.account.Sub_Channel__c != null))
                                 && (detalhe.segmento__c == null || (detalhe.segmento__c == opp.account.Sub_Channel_Rating__c && opp.account.Sub_Channel_Rating__c != null))
                                 ){
                                    if((detalhe.consumo__c + li.Quantity) > detalhe.cota__c){
                                        return Label.LAT_COTA_00004;
                                    }else{
                                        LAT_DetalheCotaMarket__c dc = mapToUpdate.get(detalhe.id);
                                        if(dc == null)dc = detalhe;

                                        dc.consumo__c +=  (li.Quantity - li.cantidadCotaConsumida__c);
                                        li.Cota_Consumida__c = detalhe.id;
                                        li.cantidadCotaConsumida__c = li.Quantity;
                                        linesToUpdate.add(li);
                                        detalhesToUpdate.add(detalhe);
                                        mapToUpdate.put(dc.id,dc);

                                        break;
                                    }
                                }
                            }
                        }
                    }
                    if(li.Cota_Consumida__c == null){
                        return Label.LAT_COTA_00005;
                    } 
                }
            }

            String msg = '';
            msg = SalesOrderHandlerInterface.SalesOrderInterface(oppId);
            

            if(msg == ''){
                update linesToUpdate;
                //update detalhesToUpdate;
                update mapToUpdate.values();
            }

            return msg;
        }
        //MIGRATED 04/11/2016
        else {
            System.debug('%%%%%% Entramos validateConsumeCota 1.');
            LAT_Opportunity__c opp = null;
            Set< Id > setRecTypeOpp = new Set< Id >();
            setRecTypeOpp.add( RecordTypeForTest.getRecType( 'LAT_Opportunity__c', 'Bloqueia_alteracao' ) );
            setRecTypeOpp.add( RecordTypeForTest.getRecType( 'LAT_Opportunity__c', 'Bloqueia_alteracao_do_cabecalho' ) );
            setRecTypeOpp.add( RecordTypeForTest.getRecType( 'LAT_Opportunity__c', 'Nova_oportunidade' ) );
            
            List< LAT_Opportunity__c > oppL = [ SELECT id,ownerId,LAT_Account__r.Regional__c,LAT_Account__r.Sub_Channel__c,LAT_Account__r.Sub_Channel_Rating__c,LAT_Account__r.Customer_Flag__c, LAT_CDAction__c, LAT_Account__r.Owner.C_digo_JDE__c, LAT_Account__r.Business_Unit__c,
                                LAT_Freight__c, LAT_DSMessage1__c, LAT_DSMessage2__c, LAT_CloseDate__c, LAT_Account__r.Client_code_AN8__c, CreatedDate, 
                                LAT_Type__c, LAT_NROrderJDE__c, LAT_CDOrderStatus__c, LAT_NRCustomerOrder__c, LAT_OrderOrigin__c, RecordTypeId, 
                                LAT_ItemsTotalQuantity__c, LAT_CancelOrder__c, LAT_SentToJDE__c, LAT_Integration__c, LAT_IsFlex__c
                                FROM LAT_Opportunity__c WHERE Id =: oppId AND RecordTypeId =: setRecTypeOpp limit 1];


                                  
            if ( oppL.size() == 0 ) return 'Pedido (id:' + oppId + ') não encontrado';
            opp = oppL[ 0 ];
            System.debug('%%%%%% Entramos validateConsumeCota 2.');

            if ( opp.LAT_OrderOrigin__c != 'CRM' && opp.LAT_OrderOrigin__c != 'APP' ) return Label.LAT_COTA_00001;
            if (opp.LAT_Type__c != null && opp.LAT_Type__c.length() >1)if (opp.LAT_Type__c.substring(0,2) != 'SO' )return null;
            
            //Nao enviar pedido sem itens para o JDE - 24/07/2013 - inicio
            if (opp.LAT_ItemsTotalQuantity__c == 0) return Label.LAT_COTA_00002;
            //Nao enviar pedido sem itens para o JDE - 24/07/2013 - fim
            

            String lRecType = RecordTypeForTest.getRecType( 'LAT_Opportunity__c','Bloqueia_alteracao' );
            if ( opp.RecordTypeId == lRecType && !opp.LAT_IsFlex__c) return Label.LAT_COTA_00003;

            //Actualiza la closeDate con la fecha del primer envio
            if(!opp.LAT_SentToJDE__c && opp.LAT_NROrderJDE__c != '' && opp.LAT_NROrderJDE__c != null)opp.LAT_SentToJDE__c = true;
            
            if(!opp.LAT_SentToJDE__c){
                opp.LAT_CloseDate__c = Date.today();
                opp.LAT_SentToJDE__c = true;
            }


            System.debug('%%%%%% Entramos validateConsumeCota 3.');
            List<LAT_OpportunityLineItem__c> listaItens = [ SELECT LAT_Opportunity__r.LAT_Account__c,LAT_ConsumedQuote__r.consumo__c,LAT_ConsumedQuote__c,LAT_ConsumedQuoteQuantity__c,LAT_Product__c, LAT_Product__r.Name,
             LAT_Quantity__c FROM LAT_OpportunityLineItem__c 
            WHERE LAT_Opportunity__c =: opp.id AND (NOT LAT_StatusDescription__c LIKE 'Cancelado%')];//cd_line_status__c <> '999' ];
            
            List<String> linesProductsIds = new List<String>();
            Map<String,Lat_cotaMarket__c> cotasMap = new Map<String,Lat_cotaMarket__c>();

            List<LAT_OpportunityLineItem__c> linesToUpdate = new List<LAT_OpportunityLineItem__c>();
            List<LAT_DetalheCotaMarket__c> detalhesToUpdate = new List<LAT_DetalheCotaMarket__c>();

            Map<String,LAT_DetalheCotaMarket__c> mapToUpdate = new Map<String,LAT_DetalheCotaMarket__c>();
            
            for(LAT_OpportunityLineItem__c li : listaItens){
                linesProductsIds.add(li.LAT_Product__c);
            }

            for(Lat_cotaMarket__c cota : getCotasToConsume(opp.LAT_CloseDate__c,linesProductsIds)){
                cotasMap.put(cota.LAT_Product__c, cota);
            }
            String returnMessage = Label.LAT_COTA_00011;
            Boolean isFirst = true;
            for(LAT_OpportunityLineItem__c li : listaItens){
                if(li.LAT_ConsumedQuoteQuantity__c == null)li.LAT_ConsumedQuoteQuantity__c = 0;

                if(cotasMap.get(li.LAT_Product__c) != null){
                    if(li.LAT_ConsumedQuote__c != null){
                        LAT_DetalheCotaMarket__c dc = mapToUpdate.get(li.LAT_ConsumedQuote__c);
                        if(dc == null)dc = li.LAT_ConsumedQuote__r;

                        dc.consumo__c +=  (li.LAT_Quantity__c - li.LAT_ConsumedQuoteQuantity__c);
                        li.LAT_ConsumedQuoteQuantity__c = li.LAT_Quantity__c;
                        linesToUpdate.add(li);
                        detalhesToUpdate.add(dc);
                        mapToUpdate.put(dc.id,dc);
                    }else{
                        for(LAT_DetalheCotaMarket__c detalhe : cotasMap.get(li.LAT_Product__c).Detalhes_Cota__r){
                            if(detalhe.cliente__c == opp.LAT_Account__c){
                                if(detalhe.consumo__c + li.LAT_Quantity__c > detalhe.cota__c){
                                        //return Label.LAT_COTA_00004;
                                        if(!isFirst) {
                                            returnMessage = returnMessage + ',';
                                        } 
                                        returnMessage = returnMessage +' '+  li.LAT_Product__r.Name;
                                        isFirst = false;
                                }else{
                                    LAT_DetalheCotaMarket__c dc = mapToUpdate.get(detalhe.id);
                                    if(dc == null)dc = detalhe;

                                    dc.consumo__c +=  (li.LAT_Quantity__c - li.LAT_ConsumedQuoteQuantity__c);
                                    li.LAT_ConsumedQuote__c = detalhe.id;
                                    li.LAT_ConsumedQuoteQuantity__c = li.LAT_Quantity__c;
                                    linesToUpdate.add(li);
                                    detalhesToUpdate.add(detalhe);
                                    mapToUpdate.put(dc.id,dc);
                                    break;
                                }
                            }else if(detalhe.cliente__c == null){
                                if((detalhe.executivo__c == null || detalhe.executivo__c == opp.ownerId)
                                 && (detalhe.bandeira__c == null || (detalhe.bandeira__c == opp.LAT_Account__r.Customer_Flag__c && opp.LAT_Account__r.Customer_Flag__c != null))
                                 && (detalhe.Regional__c == null || (detalhe.Regional__c == opp.LAT_Account__r.Regional__c && opp.LAT_Account__r.Regional__c != null))
                                 && (detalhe.sub_canal__c == null || (detalhe.sub_canal__c == opp.LAT_Account__r.Sub_Channel__c && opp.LAT_Account__r.Sub_Channel__c != null))
                                 && (detalhe.segmento__c == null || (detalhe.segmento__c == opp.LAT_Account__r.Sub_Channel_Rating__c && opp.LAT_Account__r.Sub_Channel_Rating__c != null))
                                 ){
                                    if((detalhe.consumo__c + li.LAT_Quantity__c) > detalhe.cota__c){
                                        //return Label.LAT_COTA_00004;                                        
                                        if (!returnMessage.contains(li.LAT_Product__r.Name)) {
                                            if(!isFirst) {
                                                returnMessage = returnMessage + ',';
                                            } 
                                            returnMessage = returnMessage +' '+  li.LAT_Product__r.Name;
                                            isFirst = false;
                                        }
                                    }else{
                                        LAT_DetalheCotaMarket__c dc = mapToUpdate.get(detalhe.id);
                                        if(dc == null)dc = detalhe;

                                        dc.consumo__c +=  (li.LAT_Quantity__c - li.LAT_ConsumedQuoteQuantity__c);
                                        li.LAT_ConsumedQuote__c = detalhe.id;
                                        li.LAT_ConsumedQuoteQuantity__c = li.LAT_Quantity__c;
                                        linesToUpdate.add(li);
                                        detalhesToUpdate.add(detalhe);
                                        mapToUpdate.put(dc.id,dc);

                                        break;
                                    }
                                }
                            }
                        }
                    }
                    if(li.LAT_ConsumedQuote__c == null){
                        if (!returnMessage.contains(li.LAT_Product__r.Name)) {
                            //return Label.LAT_COTA_00005;
                            if(!isFirst) {
                                returnMessage = returnMessage + ',';
                            } 
                            returnMessage = returnMessage +' '+  li.LAT_Product__r.Name;
                            isFirst = false;
                        }
                    } 
                }
            }
            System.debug('%%%%%% Entramos validateConsumeCota 5.');
            if (!isFirst) {
                return returnMessage;
            }

            String msg = '';
            System.debug('%%%%%% Entramos a mandar a integrar.');
            msg = SalesOrderHandlerInterface.LAT_SalesOrderInterface(oppId);
            
            System.debug('%%%%%% msg : ' + msg);
            if(msg == ''){
                update linesToUpdate;
                //update detalhesToUpdate;
                update mapToUpdate.values();
            }

            return msg;
        }
    }




    //Valida y consume una cota para una lista de lineas de oppty cuando envian un pedido desde Mobile
    public static String validateConsumeCotaForMobile(String oppId){
        
        LAT_Opportunity__c opp = null;
        Set< Id > setRecTypeOpp = new Set< Id >();
        String msg = '';
        
        setRecTypeOpp.add( RecordTypeForTest.getRecType( 'LAT_Opportunity__c', 'Bloqueia_alteracao' ) );
        setRecTypeOpp.add( RecordTypeForTest.getRecType( 'LAT_Opportunity__c', 'Bloqueia_alteracao_do_cabecalho' ) );
        setRecTypeOpp.add( RecordTypeForTest.getRecType( 'LAT_Opportunity__c', 'Nova_oportunidade' ) );
        
        List< LAT_Opportunity__c > oppL = [ SELECT id,ownerId,LAT_Account__r.Regional__c,LAT_Account__r.Sub_Channel__c,LAT_Account__r.Sub_Channel_Rating__c,LAT_Account__r.Customer_Flag__c, LAT_CDAction__c, LAT_Account__r.Owner.C_digo_JDE__c, LAT_Account__r.Business_Unit__c,
                            LAT_Freight__c, LAT_DSMessage1__c, LAT_DSMessage2__c, LAT_CloseDate__c, LAT_Account__r.Client_code_AN8__c, CreatedDate, 
                            LAT_Type__c, LAT_NROrderJDE__c, LAT_CDOrderStatus__c, LAT_NRCustomerOrder__c, LAT_OrderOrigin__c, RecordTypeId, 
                            LAT_ItemsTotalQuantity__c, LAT_CancelOrder__c, LAT_SentToJDE__c, LAT_Integration__c 
                            FROM LAT_Opportunity__c WHERE Id =: oppId AND RecordTypeId =: setRecTypeOpp limit 1];
                              
        if ( oppL.size() == 0 ) return 'Pedido (id:' + oppId + ') não encontrado';
        opp = oppL[ 0 ];

        //if ( opp.LAT_OrderOrigin__c != 'CRM' && opp.LAT_OrderOrigin__c != 'APP' ) return Label.LAT_COTA_00001;
        if (opp.LAT_Type__c != null && opp.LAT_Type__c.length() >1)if (opp.LAT_Type__c.substring(0,2) != 'SO' )return null;
        
        //Nao enviar pedido sem itens para o JDE - 24/07/2013 - inicio
        if (opp.LAT_ItemsTotalQuantity__c == 0) return Label.LAT_COTA_00002;
        //Nao enviar pedido sem itens para o JDE - 24/07/2013 - fim
        
        String lRecType = RecordTypeForTest.getRecType( 'LAT_Opportunity__c','Bloqueia_alteracao' );
        if ( opp.RecordTypeId == lRecType ) return Label.LAT_COTA_00003;

        //Actualiza la closeDate con la fecha del primer envio
        //if(!opp.LAT_SentToJDE__c && opp.LAT_NROrderJDE__c != '' && opp.LAT_NROrderJDE__c != null)opp.LAT_SentToJDE__c = true;
        
        //if(!opp.LAT_SentToJDE__c){
            //opp.LAT_CloseDate__c = Date.today();
            //opp.LAT_SentToJDE__c = true;
        //}

        List<LAT_OpportunityLineItem__c> listaItens = [ SELECT LAT_Opportunity__r.LAT_Account__c,LAT_ConsumedQuote__r.consumo__c,LAT_ConsumedQuote__c,LAT_ConsumedQuoteQuantity__c,LAT_Product__c, 
         LAT_Quantity__c FROM LAT_OpportunityLineItem__c 
        WHERE LAT_Opportunity__c =: opp.id AND (NOT LAT_StatusDescription__c LIKE 'Cancelado%')];//cd_line_status__c <> '999' ];
        
        List<String> linesProductsIds = new List<String>();
        Map<String,Lat_cotaMarket__c> cotasMap = new Map<String,Lat_cotaMarket__c>();

        List<LAT_OpportunityLineItem__c> linesToUpdate = new List<LAT_OpportunityLineItem__c>();
        List<LAT_DetalheCotaMarket__c> detalhesToUpdate = new List<LAT_DetalheCotaMarket__c>();

        Map<String,LAT_DetalheCotaMarket__c> mapToUpdate = new Map<String,LAT_DetalheCotaMarket__c>();
        
        for(LAT_OpportunityLineItem__c li : listaItens){
            linesProductsIds.add(li.LAT_Product__c);
        }

        for(Lat_cotaMarket__c cota : getCotasToConsume(opp.LAT_CloseDate__c,linesProductsIds)){
            cotasMap.put(cota.LAT_Product__c, cota);
        }

        for(LAT_OpportunityLineItem__c li : listaItens){
            if(li.LAT_ConsumedQuoteQuantity__c == null)li.LAT_ConsumedQuoteQuantity__c = 0;

            if(cotasMap.get(li.LAT_Product__c) != null){
                if(li.LAT_ConsumedQuote__c != null){
                    LAT_DetalheCotaMarket__c dc = mapToUpdate.get(li.LAT_ConsumedQuote__c);
                    if(dc == null)dc = li.LAT_ConsumedQuote__r;

                    dc.consumo__c +=  (li.LAT_Quantity__c - li.LAT_ConsumedQuoteQuantity__c);
                    li.LAT_ConsumedQuoteQuantity__c = li.LAT_Quantity__c;
                    linesToUpdate.add(li);
                    detalhesToUpdate.add(dc);
                    mapToUpdate.put(dc.id,dc);
                }else{
                    for(LAT_DetalheCotaMarket__c detalhe : cotasMap.get(li.LAT_Product__c).Detalhes_Cota__r){
                        if(detalhe.cliente__c == opp.LAT_Account__c){
                            if(detalhe.consumo__c + li.LAT_Quantity__c > detalhe.cota__c){
                                    return Label.LAT_COTA_00004;
                            }else{
                                LAT_DetalheCotaMarket__c dc = mapToUpdate.get(detalhe.id);
                                if(dc == null)dc = detalhe;

                                dc.consumo__c +=  (li.LAT_Quantity__c - li.LAT_ConsumedQuoteQuantity__c);
                                li.LAT_ConsumedQuote__c = detalhe.id;
                                li.LAT_ConsumedQuoteQuantity__c = li.LAT_Quantity__c;
                                linesToUpdate.add(li);
                                detalhesToUpdate.add(detalhe);
                                mapToUpdate.put(dc.id,dc);
                                break;
                            }
                        }else if(detalhe.cliente__c == null){
                            if((detalhe.executivo__c == null || detalhe.executivo__c == opp.ownerId)
                             && (detalhe.bandeira__c == null || (detalhe.bandeira__c == opp.LAT_Account__r.Customer_Flag__c && opp.LAT_Account__r.Customer_Flag__c != null))
                             && (detalhe.Regional__c == null || (detalhe.Regional__c == opp.LAT_Account__r.Regional__c && opp.LAT_Account__r.Regional__c != null))
                             && (detalhe.sub_canal__c == null || (detalhe.sub_canal__c == opp.LAT_Account__r.Sub_Channel__c && opp.LAT_Account__r.Sub_Channel__c != null))
                             && (detalhe.segmento__c == null || (detalhe.segmento__c == opp.LAT_Account__r.Sub_Channel_Rating__c && opp.LAT_Account__r.Sub_Channel_Rating__c != null))
                             ){
                                if((detalhe.consumo__c + li.LAT_Quantity__c) > detalhe.cota__c){
                                    return Label.LAT_COTA_00004;
                                }else{
                                    LAT_DetalheCotaMarket__c dc = mapToUpdate.get(detalhe.id);
                                    if(dc == null)dc = detalhe;

                                    dc.consumo__c +=  (li.LAT_Quantity__c - li.LAT_ConsumedQuoteQuantity__c);
                                    li.LAT_ConsumedQuote__c = detalhe.id;
                                    li.LAT_ConsumedQuoteQuantity__c = li.LAT_Quantity__c;
                                    linesToUpdate.add(li);
                                    detalhesToUpdate.add(detalhe);
                                    mapToUpdate.put(dc.id,dc);

                                    break;
                                }
                            }
                        }
                    }
                }
                if(li.LAT_ConsumedQuote__c == null){
                    return Label.LAT_COTA_00005;
                } 
            }
        }

        //String msg = SalesOrderHandlerInterface.LAT_SalesOrderInterface(oppId);
        
        //if(msg == ''){
            //update linesToUpdate;
            //update detalhesToUpdate;
            //update mapToUpdate.values(); 
        //}

        return msg;
    }


    public static void updateOppty(Opportunity opp,Opportunity oppToUpdate){
        oppToUpdate.CloseDate = opp.CloseDate;
        oppToUpdate.LAT_Enviado_a_JDE__c = opp.LAT_Enviado_a_JDE__c;
        update oppToUpdate;
    }

    //MIGRATED 04/11/2016
    public static void updateOppty(LAT_Opportunity__c opp,LAT_Opportunity__c oppToUpdate){
        oppToUpdate.LAT_CloseDate__c = opp.LAT_CloseDate__c;
        oppToUpdate.LAT_SentToJDE__c = opp.LAT_SentToJDE__c;
        update oppToUpdate;
    }

    public Static List<Lat_cotaMarket__c> getCotasToConsume(Date closeDate, List<String> linesProductsIds){
        if(!Utils.wasMigrationDone('1')){  
            return [Select id,SKU__c,(SELECT id,cliente__c,bandeira__c,consumo__c,cota__c,endDate__c,startDate__c,executivo__c,prioridad__c,regional__c,segmento__c,sub_canal__c FROM Detalhes_Cota__r where startDate__c <=: closeDate and endDate__c >=: closeDate order by prioridad__c asc) from Lat_cotaMarket__c where SKU__c in: linesProductsIds and startDate__c <=: closeDate and endDate__c >=: closeDate];
        }
        //MIGRATED 04/11/2016
        else {
            return [Select id,LAT_Product__c,(SELECT id,cliente__c,bandeira__c,consumo__c,cota__c,endDate__c,startDate__c,executivo__c,prioridad__c,regional__c,segmento__c,sub_canal__c FROM Detalhes_Cota__r where startDate__c <=: closeDate and endDate__c >=: closeDate order by prioridad__c asc) from Lat_cotaMarket__c where LAT_Product__c in: linesProductsIds and startDate__c <=: closeDate and endDate__c >=: closeDate];
        }
    }

    public Static List<LAT_DetalheCotaMarket__c> getDetalheCotasToConsume(List<String> linesProductsIds){
        if(!Utils.wasMigrationDone('1')){  
            return [SELECT id,cotaMarket__r.SKU__c,cliente__c,bandeira__c,consumo__c,cota__c,endDate__c,startDate__c,executivo__c,prioridad__c,regional__c,segmento__c,sub_canal__c FROM LAT_DetalheCotaMarket__c where cotaMarket__r.SKU__c in: linesProductsIds  order by prioridad__c asc];
        } 
        //MIGRATED 04/11/2016
        else {
            return [SELECT id,cotaMarket__r.LAT_Product__c,cliente__c,bandeira__c,consumo__c,cota__c,endDate__c,startDate__c,executivo__c,prioridad__c,regional__c,segmento__c,sub_canal__c FROM LAT_DetalheCotaMarket__c where cotaMarket__r.LAT_Product__c in: linesProductsIds  order by prioridad__c asc];
        }
    }

    public Static List<LAT_DetalheCotaMarket__c> getDetalhesList(List<LAT_DetalheCotaMarket__c> detalheList, DAte closeDate){
        List<LAT_DetalheCotaMarket__c> ret = new List<LAT_DetalheCotaMarket__c>();
        for(LAT_DetalheCotaMarket__c detalhe : detalheList){
            if(detalhe.startDate__c <= closeDate && detalhe.endDate__c >= closeDate){
                ret.add(detalhe);
            }
        }
        return ret;
    }
    
    //Elimina el consumo de cotas cuando se elimina una linea de oppty
    public static void deleteOpportunityLine(List<OpportunityLineItem> opptys){ 
         List<String> cotaIds = new List<String>();
         Map<String, LAT_DetalheCotaMarket__c> cotasMap = new Map<String, LAT_DetalheCotaMarket__c>();
         List<LAT_DetalheCotaMarket__c> toUpdate = new List<LAT_DetalheCotaMarket__c>();
         
         for(OpportunityLineItem oli : opptys){
             if(oli.Cota_Consumida__c != null)cotaIds.add(oli.Cota_Consumida__c);
         }
         
         for(LAT_DetalheCotaMarket__c detalhe : [Select id,consumo__c from LAT_DetalheCotaMarket__c where id in : cotaIds]){
             cotasMap.put(detalhe.id,detalhe);
         }
         
         for(OpportunityLineItem oli : opptys){
             if(oli.Cota_Consumida__c != null && cotasMap.get(oli.Cota_Consumida__c) != null){
                 LAT_DetalheCotaMarket__c dc = cotasMap.get(oli.Cota_Consumida__c);
                 dc.consumo__c -= oli.cantidadCotaConsumida__c;
                 toUpdate.add(dc);
             }
         
         }
         
         update toUpdate;
     }
    //MIGRATED 04/11/2016
    //Elimina el consumo de cotas cuando se elimina una linea de oppty
    public static void deleteOpportunityLine(List<LAT_OpportunityLineItem__c> opptys){ 
         List<String> cotaIds = new List<String>();
         Map<String, LAT_DetalheCotaMarket__c> cotasMap = new Map<String, LAT_DetalheCotaMarket__c>();
         List<LAT_DetalheCotaMarket__c> toUpdate = new List<LAT_DetalheCotaMarket__c>();
         
         for(LAT_OpportunityLineItem__c oli : opptys){
             if(oli.LAT_ConsumedQuote__c != null)cotaIds.add(oli.LAT_ConsumedQuote__c);
         }
         
         for(LAT_DetalheCotaMarket__c detalhe : [Select id,consumo__c from LAT_DetalheCotaMarket__c where id in : cotaIds]){
             cotasMap.put(detalhe.id,detalhe);
         }
         
         for(LAT_OpportunityLineItem__c oli : opptys){
             if(oli.LAT_ConsumedQuote__c != null && cotasMap.get(oli.LAT_ConsumedQuote__c) != null){
                 LAT_DetalheCotaMarket__c dc = cotasMap.get(oli.LAT_ConsumedQuote__c);
                 dc.consumo__c -= oli.LAT_ConsumedQuoteQuantity__c;
                 toUpdate.add(dc);
             }
         
         }
         
         update toUpdate;
     }

    //consume las cotas cuando el pedido es devuelto desde jde
    public static void consumeReturnBulk(List<OpportunityLineItem> listaItens){
        List<String> linesProductsIds = new List<String>();
        List<String> cotaIds = new List<String>();
        Map<String,LisT<LAT_DetalheCotaMarket__c>> cotasMap = new Map<String,List<LAT_DetalheCotaMarket__c>>();

        Map<String,LAT_DetalheCotaMarket__c> cotasUsed = new Map<String,LAT_DetalheCotaMarket__c>();

        List<OpportunityLineItem> linesToUpdate = new List<OpportunityLineItem>();
        List<LAT_DetalheCotaMarket__c> detalhesToUpdate = new List<LAT_DetalheCotaMarket__c>();
        Map<String,LAT_DetalheCotaMarket__c> mapToUpdate = new Map<String,LAT_DetalheCotaMarket__c>();
        List<Opportunity> opptiesToUpdate = new List<Opportunity>();


        List<String> itemIds = new List<String>();
        List<String> opptyIds = new List<String>();
        Map<String, list<OpportunityLineItem>> opptyWithLines = new Map<String, list<OpportunityLineItem>>();



        for(OpportunityLineItem li : listaItens){
            itemIds.add(li.id);
            opptyIds.add(li.opportunityId);
        }

        Map<ID,Opportunity> opptiesMap = new MAp<ID,Opportunity>([SELECT id,type,LAT_Enviado_a_JDE__c, Integracao__c,nr_order_jde__c, CloseDate, ownerId,AccountId, account.Customer_Flag__c,account.Regional__c,account.Sub_Channel__c,account.Sub_Channel_Rating__c FROM Opportunity WHERE id in :opptyIds]);

        system.debug('999999 ' + itemIds);


        listaItens = [SELECT opportunity.type,opportunity.LAT_Enviado_a_JDE__c, opportunity.Integracao__c,opportunity.nr_order_jde__c, opportunity.CloseDate, opportunity.ownerId,opportunity.AccountId, opportunity.account.Customer_Flag__c,opportunity.account.Regional__c,opportunity.account.Sub_Channel__c,opportunity.account.Sub_Channel_Rating__c, Cota_Consumida__r.consumo__c,Cota_Consumida__c,cantidadCotaConsumida__c,PriceBookEntry.Product2Id, CD_Action__c, LAT_SkuText__c, LAT_PaymentCondition__c, 
            NR_order_line__c, QT_Bonus__c, Quantity, LAT_UnitCode__c, LAT_PercentualBonus__c, Descricao_do_status__c, 
            pc_discount__c, cd_line_status__c FROM OpportunityLineItem 
            WHERE id in :itemIds];

        linesProductsIds = new List<String>();


        for(OpportunityLineItem li : listaItens){
            linesProductsIds.add(li.PriceBookEntry.Product2Id);

            if(li.Cota_Consumida__c != null)cotaIds.add(li.Cota_Consumida__c);

            if(opptyWithLines.get(li.opportunityId) == null){
                opptyWithLines.put(li.opportunityId, new List<OpportunityLineItem>{li});
            }else{
                opptyWithLines.get(li.opportunityId).add(li);
            }
        }

        for(LAT_DetalheCotaMarket__c detalhe : [Select id,consumo__c from LAT_DetalheCotaMarket__c where id in : cotaIds]){
            cotasUsed.put(detalhe.id,detalhe);
        }

        system.debug('lineProducts ' + linesProductsIds);


        for(LAT_DetalheCotaMarket__c detalhe : getDetalheCotasToConsume(linesProductsIds)){
            if(cotasMap.get(detalhe.cotaMarket__r.SKU__c) != null){
                cotasMap.get(detalhe.cotaMarket__r.SKU__c).add(detalhe);
            }else{
                cotasMap.put(detalhe.cotaMarket__r.SKU__c, new List<LAT_DetalheCotaMarket__c>{detalhe});
            }
        }


        for(String oppId : opptyWithLines.keySet()){
            Opportunity opp = opptiesMap.get(oppId);

            system.debug('oppId ' + oppId);
            system.debug('oppLines ' + opptyWithLines.get(oppId));
            
            if(!opp.LAT_Enviado_a_JDE__c)opp.LAT_Enviado_a_JDE__c = true;

            String oppType = (opp.type != null && opp.type.length() >1 ? opp.type.substring(0,2) : '');
            Double oppTypeSigno = SalesOrderReturn.getOrderSigno(1, oppType);


            for(OpportunityLineItem li : opptyWithLines.get(oppId)){
                if(li.cantidadCotaConsumida__c == null)li.cantidadCotaConsumida__c = 0;

                if(li.Cota_Consumida__c != null && cotasUsed.get(li.Cota_Consumida__c) != null && (li.cd_line_status__c == '999' && (li.Descricao_do_status__c != null &&li.Descricao_do_status__c.startsWithIgnoreCase('Cancelado')))){
                    LAT_DetalheCotaMarket__c dc = cotasUsed.get(li.Cota_Consumida__c);
                    if(mapToUpdate.get(dc.id) != null)dc = mapToUpdate.get(dc.id);
                    dc.consumo__c -= li.cantidadCotaConsumida__c;
                    li.Cota_Consumida__c = null;
                    li.cantidadCotaConsumida__c = 0;
                    mapToUpdate.put(dc.id,dc);
                    detalhesToUpdate.add(dc);
                    linesToUpdate.add(li);
                }else if(li.Cota_Consumida__c != null && (li.Descricao_do_status__c == null || !li.Descricao_do_status__c.startsWithIgnoreCase('Cancelado'))){
                    LAT_DetalheCotaMarket__c dc = cotasUsed.get(li.Cota_Consumida__c);
                    if(mapToUpdate.get(dc.id) != null)dc = mapToUpdate.get(dc.id);
                    dc.consumo__c +=  (li.Quantity - li.cantidadCotaConsumida__c) * oppTypeSigno; 
                    li.cantidadCotaConsumida__c = li.Quantity;
                    linesToUpdate.add(li);
                    mapToUpdate.put(dc.id,dc);
                    detalhesToUpdate.add(dc);
                }else if(li.Cota_Consumida__c == null && (li.Descricao_do_status__c == null || !li.Descricao_do_status__c.startsWithIgnoreCase('Cancelado'))){
                    if(cotasMap.get(li.PriceBookEntry.Product2Id) != null){
                        List<LAT_DetalheCotaMarket__c> detalles = getDetalhesList(cotasMap.get(li.PriceBookEntry.Product2Id),opp.closeDate);
                        if(detalles != null){
                            for(LAT_DetalheCotaMarket__c detalhe : detalles){
                                if(mapToUpdate.get(detalhe.id) != null)detalhe = mapToUpdate.get(detalhe.id);
                                if(detalhe.cliente__c == opp.AccountId){
                                    detalhe.consumo__c +=  (li.Quantity - li.cantidadCotaConsumida__c) * oppTypeSigno;
                                    li.Cota_Consumida__c = detalhe.id;
                                    li.cantidadCotaConsumida__c = li.Quantity;
                                    linesToUpdate.add(li);
                                    mapToUpdate.put(detalhe.id,detalhe);
                                    detalhesToUpdate.add(detalhe);
                                    break;
                                }else if(detalhe.cliente__c == null){
                                    if((detalhe.executivo__c == null || detalhe.executivo__c == opp.ownerId)
                                     && (detalhe.bandeira__c == null || (detalhe.bandeira__c == opp.account.Customer_Flag__c && opp.account.Customer_Flag__c != null))
                                     && (detalhe.Regional__c == null || (detalhe.Regional__c == opp.account.Regional__c && opp.account.Regional__c != null))
                                     && (detalhe.sub_canal__c == null || (detalhe.sub_canal__c == opp.account.Sub_Channel__c && opp.account.Sub_Channel__c != null))
                                     && (detalhe.segmento__c == null || (detalhe.segmento__c == opp.account.Sub_Channel_Rating__c && opp.account.Sub_Channel_Rating__c != null))
                                     ){
                                        detalhe.consumo__c +=  (li.Quantity - li.cantidadCotaConsumida__c) * oppTypeSigno;
                                        li.Cota_Consumida__c = detalhe.id;
                                        li.cantidadCotaConsumida__c = li.Quantity;
                                        linesToUpdate.add(li);
                                        mapToUpdate.put(detalhe.id,detalhe);
                                        detalhesToUpdate.add(detalhe);
                                        break;
                                    }
                                }
                            }
                        }
                    }
    
                }
            }
            opptiesToUpdate.add(opp);
           



        }

        update linesToUpdate;
        update mapToUpdate.values();
        update opptiesToUpdate;
    }

    //MIGRATED 04/11/2016
    //consume las cotas cuando el pedido es devuelto desde jde
    public static void consumeReturnBulk(List<LAT_OpportunityLineItem__c> listaItens){
        List<String> linesProductsIds = new List<String>();
        List<String> cotaIds = new List<String>();
        Map<String,LisT<LAT_DetalheCotaMarket__c>> cotasMap = new Map<String,List<LAT_DetalheCotaMarket__c>>();

        Map<String,LAT_DetalheCotaMarket__c> cotasUsed = new Map<String,LAT_DetalheCotaMarket__c>();

        List<LAT_OpportunityLineItem__c> linesToUpdate = new List<LAT_OpportunityLineItem__c>();
        List<LAT_DetalheCotaMarket__c> detalhesToUpdate = new List<LAT_DetalheCotaMarket__c>();
        Map<String,LAT_DetalheCotaMarket__c> mapToUpdate = new Map<String,LAT_DetalheCotaMarket__c>();
        List<LAT_Opportunity__c> opptiesToUpdate = new List<LAT_Opportunity__c>();


        List<String> itemIds = new List<String>();
        List<String> opptyIds = new List<String>();
        Map<String, list<LAT_OpportunityLineItem__c>> opptyWithLines = new Map<String, list<LAT_OpportunityLineItem__c>>();



        for(LAT_OpportunityLineItem__c li : listaItens){
            itemIds.add(li.id);
            opptyIds.add(li.LAT_Opportunity__c);
        }

        Map<ID,LAT_Opportunity__c> opptiesMap = new MAp<ID,LAT_Opportunity__c>([SELECT id,LAT_Type__c,LAT_SentToJDE__c, LAT_Integration__c,LAT_NROrderJDE__c, LAT_CloseDate__c, ownerId,LAT_Account__c, LAT_Account__r.Customer_Flag__c,LAT_Account__r.Regional__c,LAT_Account__r.Sub_Channel__c,LAT_Account__r.Sub_Channel_Rating__c FROM LAT_Opportunity__c WHERE id in :opptyIds]);

        system.debug('999999 ' + itemIds);


        listaItens = [SELECT LAT_Opportunity__r.LAT_Type__c,LAT_Opportunity__r.LAT_SentToJDE__c, LAT_Opportunity__r.LAT_Integration__c,LAT_Opportunity__r.LAT_NROrderJDE__c, LAT_Opportunity__r.LAT_CloseDate__c, LAT_Opportunity__r.OwnerId,LAT_Opportunity__r.LAT_Account__c, LAT_Opportunity__r.LAT_Account__r.Customer_Flag__c,LAT_Opportunity__r.LAT_Account__r.Regional__c,LAT_Opportunity__r.LAT_Account__r.Sub_Channel__c,LAT_Opportunity__r.LAT_Account__r.Sub_Channel_Rating__c, LAT_ConsumedQuote__r.consumo__c,LAT_ConsumedQuote__c,LAT_ConsumedQuoteQuantity__c,LAT_Product__c, LAT_CDAction__c, LAT_SkuText__c, LAT_PaymentCondition__c, 
            LAT_NROrderLine__c, LAT_QTBonus__c, LAT_Quantity__c, LAT_UnitCode__c, LAT_PercentualBonus__c, LAT_StatusDescription__c, 
            LAT_PcDiscount__c, LAT_CdLineStatus__c FROM LAT_OpportunityLineItem__c 
            WHERE id in :itemIds];

        linesProductsIds = new List<String>();


        for(LAT_OpportunityLineItem__c li : listaItens){
            linesProductsIds.add(li.LAT_Product__c);

            if(li.LAT_ConsumedQuote__c != null)cotaIds.add(li.LAT_ConsumedQuote__c);

            if(opptyWithLines.get(li.LAT_Opportunity__c) == null){
                opptyWithLines.put(li.LAT_Opportunity__c, new List<LAT_OpportunityLineItem__c>{li});
            }else{
                opptyWithLines.get(li.LAT_Opportunity__c).add(li);
            }
        }

        for(LAT_DetalheCotaMarket__c detalhe : [Select id,consumo__c from LAT_DetalheCotaMarket__c where id in : cotaIds]){
            cotasUsed.put(detalhe.id,detalhe);
        }

        system.debug('lineProducts ' + linesProductsIds);


        for(LAT_DetalheCotaMarket__c detalhe : getDetalheCotasToConsume(linesProductsIds)){
            if(cotasMap.get(detalhe.cotaMarket__r.LAT_Product__c) != null){
                cotasMap.get(detalhe.cotaMarket__r.LAT_Product__c).add(detalhe);
            }else{
                cotasMap.put(detalhe.cotaMarket__r.LAT_Product__c, new List<LAT_DetalheCotaMarket__c>{detalhe});
            }
        }


        for(String oppId : opptyWithLines.keySet()){
            LAT_Opportunity__c opp = opptiesMap.get(oppId);

            system.debug('oppId ' + oppId);
            system.debug('oppLines ' + opptyWithLines.get(oppId));
            
            if(!opp.LAT_SentToJDE__c)opp.LAT_SentToJDE__c = true;

            String oppType = (opp.LAT_Type__c != null && opp.LAT_Type__c.length() >1 ? opp.LAT_Type__c.substring(0,2) : '');
            Double oppTypeSigno = SalesOrderReturn.getOrderSigno(1, oppType);


            for(LAT_OpportunityLineItem__c li : opptyWithLines.get(oppId)){
                if(li.LAT_ConsumedQuoteQuantity__c == null)li.LAT_ConsumedQuoteQuantity__c = 0;

                if(li.LAT_ConsumedQuote__c != null && cotasUsed.get(li.LAT_ConsumedQuote__c) != null && (li.LAT_CdLineStatus__c == '999' && (li.LAT_StatusDescription__c != null &&li.LAT_StatusDescription__c.startsWithIgnoreCase('Cancelado')))){
                    LAT_DetalheCotaMarket__c dc = cotasUsed.get(li.LAT_ConsumedQuote__c);
                    if(mapToUpdate.get(dc.id) != null)dc = mapToUpdate.get(dc.id);
                    dc.consumo__c -= li.LAT_ConsumedQuoteQuantity__c;
                    li.LAT_ConsumedQuote__c = null;
                    li.LAT_ConsumedQuoteQuantity__c = 0;
                    mapToUpdate.put(dc.id,dc);
                    detalhesToUpdate.add(dc);
                    linesToUpdate.add(li);
                }else if(li.LAT_ConsumedQuote__c != null && (li.LAT_StatusDescription__c == null || !li.LAT_StatusDescription__c.startsWithIgnoreCase('Cancelado'))){
                    LAT_DetalheCotaMarket__c dc = cotasUsed.get(li.LAT_ConsumedQuote__c);
                    if(mapToUpdate.get(dc.id) != null)dc = mapToUpdate.get(dc.id);
                    dc.consumo__c +=  (li.LAT_Quantity__c - li.LAT_ConsumedQuoteQuantity__c) * oppTypeSigno; 
                    li.LAT_ConsumedQuoteQuantity__c = li.LAT_Quantity__c;
                    linesToUpdate.add(li);
                    mapToUpdate.put(dc.id,dc);
                    detalhesToUpdate.add(dc);
                }else if(li.LAT_ConsumedQuote__c == null && (li.LAT_StatusDescription__c == null || !li.LAT_StatusDescription__c.startsWithIgnoreCase('Cancelado'))){
                    if(cotasMap.get(li.LAT_Product__c) != null){
                        List<LAT_DetalheCotaMarket__c> detalles = getDetalhesList(cotasMap.get(li.LAT_Product__c),opp.LAT_CloseDate__c);
                        if(detalles != null){
                            for(LAT_DetalheCotaMarket__c detalhe : detalles){
                                if(mapToUpdate.get(detalhe.id) != null)detalhe = mapToUpdate.get(detalhe.id);
                                if(detalhe.cliente__c == opp.LAT_Account__c){
                                    detalhe.consumo__c +=  (li.LAT_Quantity__c - li.LAT_ConsumedQuoteQuantity__c) * oppTypeSigno;
                                    li.LAT_ConsumedQuote__c = detalhe.id;
                                    li.LAT_ConsumedQuoteQuantity__c = li.LAT_Quantity__c;
                                    linesToUpdate.add(li);
                                    mapToUpdate.put(detalhe.id,detalhe);
                                    detalhesToUpdate.add(detalhe);
                                    break;
                                }else if(detalhe.cliente__c == null){
                                    if((detalhe.executivo__c == null || detalhe.executivo__c == opp.ownerId)
                                     && (detalhe.bandeira__c == null || (detalhe.bandeira__c == opp.LAT_Account__r.Customer_Flag__c && opp.LAT_Account__r.Customer_Flag__c != null))
                                     && (detalhe.Regional__c == null || (detalhe.Regional__c == opp.LAT_Account__r.Regional__c && opp.LAT_Account__r.Regional__c != null))
                                     && (detalhe.sub_canal__c == null || (detalhe.sub_canal__c == opp.LAT_Account__r.Sub_Channel__c && opp.LAT_Account__r.Sub_Channel__c != null))
                                     && (detalhe.segmento__c == null || (detalhe.segmento__c == opp.LAT_Account__r.Sub_Channel_Rating__c && opp.LAT_Account__r.Sub_Channel_Rating__c != null))
                                     ){
                                        detalhe.consumo__c +=  (li.LAT_Quantity__c - li.LAT_ConsumedQuoteQuantity__c) * oppTypeSigno;
                                        li.LAT_ConsumedQuote__c = detalhe.id;
                                        li.LAT_ConsumedQuoteQuantity__c = li.LAT_Quantity__c;
                                        linesToUpdate.add(li);
                                        mapToUpdate.put(detalhe.id,detalhe);
                                        detalhesToUpdate.add(detalhe);
                                        break;
                                    }
                                }
                            }
                        }
                    }
    
                }
            }
            opptiesToUpdate.add(opp);
           



        }

        update linesToUpdate;
        update mapToUpdate.values();
        update opptiesToUpdate;
    }

    //consume las cotas cuando el pedido es devuelto desde jde
    public static void consumeReturn(List<OpportunityLineItem> listaItens){
        List<String> itemIds = new List<String>();
        for(OpportunityLineItem li : listaItens){
            itemIds.add(li.id);
        }
        
        listaItens = [SELECT opportunity.type,opportunity.LAT_Enviado_a_JDE__c, opportunity.Integracao__c,opportunity.nr_order_jde__c, opportunity.CloseDate, opportunity.ownerId,opportunity.AccountId, opportunity.account.Customer_Flag__c,opportunity.account.Regional__c,opportunity.account.Sub_Channel__c,opportunity.account.Sub_Channel_Rating__c, Cota_Consumida__r.consumo__c,Cota_Consumida__c,cantidadCotaConsumida__c,PriceBookEntry.Product2Id, CD_Action__c, LAT_SkuText__c, LAT_PaymentCondition__c, 
        NR_order_line__c, QT_Bonus__c, Quantity, LAT_UnitCode__c, LAT_PercentualBonus__c, Descricao_do_status__c, 
        pc_discount__c, cd_line_status__c FROM OpportunityLineItem 
        WHERE id in :itemIds];
         
        List<String> linesProductsIds = new List<String>();
        List<String> cotaIds = new List<String>();
        Map<String,Lat_cotaMarket__c> cotasMap = new Map<String,Lat_cotaMarket__c>();
        Map<String,LAT_DetalheCotaMarket__c> cotasUsed = new Map<String,LAT_DetalheCotaMarket__c>();
        
        Opportunity opp;


        List<OpportunityLineItem> linesToUpdate = new List<OpportunityLineItem>();
        List<LAT_DetalheCotaMarket__c> detalhesToUpdate = new List<LAT_DetalheCotaMarket__c>();
        Map<String,LAT_DetalheCotaMarket__c> mapToUpdate = new Map<String,LAT_DetalheCotaMarket__c>();
        
        if(!listaItens.isEmpty()){
            opp = listaItens[0].opportunity;

            if(!opp.LAT_Enviado_a_JDE__c)opp.LAT_Enviado_a_JDE__c = true;


            String oppType = (opp.type != null && opp.type.length() >1 ? opp.type.substring(0,2) : '');
            Double oppTypeSigno = SalesOrderReturn.getOrderSigno(1, oppType);
            for(OpportunityLineItem li : listaItens){
                linesProductsIds.add(li.PriceBookEntry.Product2Id);
                if(li.Cota_Consumida__c != null)cotaIds.add(li.Cota_Consumida__c);
            }
            
            for(LAT_DetalheCotaMarket__c detalhe : [Select id,consumo__c from LAT_DetalheCotaMarket__c where id in : cotaIds]){
                 cotasUsed.put(detalhe.id,detalhe);
             }
    
            for(Lat_cotaMarket__c cota : getCotasToConsume(opp.CloseDate,linesProductsIds)){
                cotasMap.put(cota.SKU__c, cota);
            }
            
    
            for(OpportunityLineItem li : listaItens){
                if(li.cantidadCotaConsumida__c == null)li.cantidadCotaConsumida__c = 0;

                if(li.Cota_Consumida__c != null && cotasUsed.get(li.Cota_Consumida__c) != null && (li.cd_line_status__c == '999' && (li.Descricao_do_status__c != null &&li.Descricao_do_status__c.startsWithIgnoreCase('Cancelado')))){
                    LAT_DetalheCotaMarket__c dc = cotasUsed.get(li.Cota_Consumida__c);
                    if(mapToUpdate.get(dc.id) != null)dc = mapToUpdate.get(dc.id);
                    dc.consumo__c -= li.cantidadCotaConsumida__c;
                    li.Cota_Consumida__c = null;
                    li.cantidadCotaConsumida__c = 0;
                    mapToUpdate.put(dc.id,dc);
                    detalhesToUpdate.add(dc);
                    linesToUpdate.add(li);
                }else if(li.Cota_Consumida__c != null && (li.Descricao_do_status__c == null || !li.Descricao_do_status__c.startsWithIgnoreCase('Cancelado'))){
                    LAT_DetalheCotaMarket__c dc = cotasUsed.get(li.Cota_Consumida__c);
                    if(mapToUpdate.get(dc.id) != null)dc = mapToUpdate.get(dc.id);
                    dc.consumo__c +=  (li.Quantity - li.cantidadCotaConsumida__c) * oppTypeSigno; 
                    li.cantidadCotaConsumida__c = li.Quantity;
                    linesToUpdate.add(li);
                    mapToUpdate.put(dc.id,dc);
                    detalhesToUpdate.add(dc);
                }else if(li.Cota_Consumida__c == null && (li.Descricao_do_status__c == null || !li.Descricao_do_status__c.startsWithIgnoreCase('Cancelado'))){
                    if(cotasMap.get(li.PriceBookEntry.Product2Id) != null){
                        for(LAT_DetalheCotaMarket__c detalhe : cotasMap.get(li.PriceBookEntry.Product2Id).Detalhes_Cota__r){
                            if(mapToUpdate.get(detalhe.id) != null)detalhe = mapToUpdate.get(detalhe.id);
                            if(detalhe.cliente__c == opp.AccountId){
                                detalhe.consumo__c +=  (li.Quantity - li.cantidadCotaConsumida__c) * oppTypeSigno;
                                li.Cota_Consumida__c = detalhe.id;
                                li.cantidadCotaConsumida__c = li.Quantity;
                                linesToUpdate.add(li);
                                mapToUpdate.put(detalhe.id,detalhe);
                                detalhesToUpdate.add(detalhe);
                                break;
                            }else if(detalhe.cliente__c == null){
                                if((detalhe.executivo__c == null || detalhe.executivo__c == opp.ownerId)
                                 && (detalhe.bandeira__c == null || (detalhe.bandeira__c == opp.account.Customer_Flag__c && opp.account.Customer_Flag__c != null))
                                 && (detalhe.Regional__c == null || (detalhe.Regional__c == opp.account.Regional__c && opp.account.Regional__c != null))
                                 && (detalhe.sub_canal__c == null || (detalhe.sub_canal__c == opp.account.Sub_Channel__c && opp.account.Sub_Channel__c != null))
                                 && (detalhe.segmento__c == null || (detalhe.segmento__c == opp.account.Sub_Channel_Rating__c && opp.account.Sub_Channel_Rating__c != null))
                                 ){
                                    detalhe.consumo__c +=  (li.Quantity - li.cantidadCotaConsumida__c) * oppTypeSigno;
                                    li.Cota_Consumida__c = detalhe.id;
                                    li.cantidadCotaConsumida__c = li.Quantity;
                                    linesToUpdate.add(li);
                                    mapToUpdate.put(detalhe.id,detalhe);
                                    detalhesToUpdate.add(detalhe);
                                    break;
                                }
                            }
                        }
                    }
    
                }
            }
            update linesToUpdate;
            update mapToUpdate.values();
            update opp;
       }

    }

    //MIGRATED 04/11/2016
    //consume las cotas cuando el pedido es devuelto desde jde
    public static void consumeReturn(List<LAT_OpportunityLineItem__c> listaItens){
        List<String> itemIds = new List<String>();
        for(LAT_OpportunityLineItem__c li : listaItens){
            itemIds.add(li.id);
        }
        
        listaItens = [SELECT LAT_Opportunity__r.LAT_Type__c,LAT_Opportunity__r.LAT_SentToJDE__c, LAT_Opportunity__r.LAT_Integration__c,LAT_Opportunity__r.LAT_NROrderJDE__c, LAT_Opportunity__r.LAT_CloseDate__c, LAT_Opportunity__r.ownerId,LAT_Opportunity__r.LAT_Account__c, LAT_Opportunity__r.LAT_Account__r.Customer_Flag__c,LAT_Opportunity__r.LAT_Account__r.Regional__c,LAT_Opportunity__r.LAT_Account__r.Sub_Channel__c,LAT_Opportunity__r.LAT_Account__r.Sub_Channel_Rating__c, LAT_ConsumedQuote__r.consumo__c,LAT_ConsumedQuote__c,LAT_ConsumedQuoteQuantity__c,LAT_Product__c, LAT_CDAction__c, LAT_SkuText__c, LAT_PaymentCondition__c, 
        LAT_NROrderLine__c, LAT_QTBonus__c, LAT_Quantity__c, LAT_UnitCode__c, LAT_PercentualBonus__c, LAT_StatusDescription__c, 
        LAT_PcDiscount__c, LAT_CdLineStatus__c FROM LAT_OpportunityLineItem__c 
        WHERE id in :itemIds];
         
        List<String> linesProductsIds = new List<String>();
        List<String> cotaIds = new List<String>();
        Map<String,Lat_cotaMarket__c> cotasMap = new Map<String,Lat_cotaMarket__c>();
        Map<String,LAT_DetalheCotaMarket__c> cotasUsed = new Map<String,LAT_DetalheCotaMarket__c>();
        
        LAT_Opportunity__c opp;


        List<LAT_OpportunityLineItem__c> linesToUpdate = new List<LAT_OpportunityLineItem__c>();
        List<LAT_DetalheCotaMarket__c> detalhesToUpdate = new List<LAT_DetalheCotaMarket__c>();
        Map<String,LAT_DetalheCotaMarket__c> mapToUpdate = new Map<String,LAT_DetalheCotaMarket__c>();
    
        if(!listaItens.isEmpty()){
            opp = listaItens[0].LAT_Opportunity__r;

            if(!opp.LAT_SentToJDE__c)opp.LAT_SentToJDE__c = true;


            String oppType = (opp.LAT_Type__c != null && opp.LAT_Type__c.length() >1 ? opp.LAT_Type__c.substring(0,2) : '');
            Double oppTypeSigno = SalesOrderReturn.getOrderSigno(1, oppType);
            for(LAT_OpportunityLineItem__c li : listaItens){
                linesProductsIds.add(li.LAT_Product__c);
                if(li.LAT_ConsumedQuote__c != null)cotaIds.add(li.LAT_ConsumedQuote__c);
            }
            
            for(LAT_DetalheCotaMarket__c detalhe : [Select id,consumo__c from LAT_DetalheCotaMarket__c where id in : cotaIds]){
                 cotasUsed.put(detalhe.id,detalhe);
             }
    
            for(Lat_cotaMarket__c cota : getCotasToConsume(opp.LAT_CloseDate__c,linesProductsIds)){
                cotasMap.put(cota.LAT_Product__c, cota);
            }
            
    
            for(LAT_OpportunityLineItem__c li : listaItens){
                if(li.LAT_ConsumedQuoteQuantity__c == null)li.LAT_ConsumedQuoteQuantity__c = 0;

                if(li.LAT_ConsumedQuote__c != null && cotasUsed.get(li.LAT_ConsumedQuote__c) != null && (li.LAT_CdLineStatus__c == '999' && (li.LAT_StatusDescription__c != null &&li.LAT_StatusDescription__c.startsWithIgnoreCase('Cancelado')))){
                    LAT_DetalheCotaMarket__c dc = cotasUsed.get(li.LAT_ConsumedQuote__c);
                    if(mapToUpdate.get(dc.id) != null)dc = mapToUpdate.get(dc.id);
                    dc.consumo__c -= li.LAT_ConsumedQuoteQuantity__c;
                    li.LAT_ConsumedQuote__c = null;
                    li.LAT_ConsumedQuoteQuantity__c = 0;
                    mapToUpdate.put(dc.id,dc);
                    detalhesToUpdate.add(dc);
                    linesToUpdate.add(li);
                }else if(li.LAT_ConsumedQuote__c != null && (li.LAT_StatusDescription__c == null || !li.LAT_StatusDescription__c.startsWithIgnoreCase('Cancelado'))){
                    LAT_DetalheCotaMarket__c dc = cotasUsed.get(li.LAT_ConsumedQuote__c);
                    if(mapToUpdate.get(dc.id) != null)dc = mapToUpdate.get(dc.id);
                    dc.consumo__c +=  (li.LAT_Quantity__c - li.LAT_ConsumedQuoteQuantity__c) * oppTypeSigno; 
                    li.LAT_ConsumedQuoteQuantity__c = li.LAT_Quantity__c;
                    linesToUpdate.add(li);
                    mapToUpdate.put(dc.id,dc);
                    detalhesToUpdate.add(dc);
                }else if(li.LAT_ConsumedQuote__c == null && (li.LAT_StatusDescription__c == null || !li.LAT_StatusDescription__c.startsWithIgnoreCase('Cancelado'))){
                    if(cotasMap.get(li.LAT_Product__c) != null){
                        for(LAT_DetalheCotaMarket__c detalhe : cotasMap.get(li.LAT_Product__c).Detalhes_Cota__r){
                            if(mapToUpdate.get(detalhe.id) != null)detalhe = mapToUpdate.get(detalhe.id);
                            if(detalhe.cliente__c == opp.LAT_Account__c){
                                detalhe.consumo__c +=  (li.LAT_Quantity__c - li.LAT_ConsumedQuoteQuantity__c) * oppTypeSigno;
                                li.LAT_ConsumedQuote__c = detalhe.id;
                                li.LAT_ConsumedQuoteQuantity__c = li.LAT_Quantity__c;
                                linesToUpdate.add(li);
                                mapToUpdate.put(detalhe.id,detalhe);
                                detalhesToUpdate.add(detalhe);
                                break;
                            }else if(detalhe.cliente__c == null){
                                if((detalhe.executivo__c == null || detalhe.executivo__c == opp.ownerId)
                                 && (detalhe.bandeira__c == null || (detalhe.bandeira__c == opp.LAT_Account__r.Customer_Flag__c && opp.LAT_Account__r.Customer_Flag__c != null))
                                 && (detalhe.Regional__c == null || (detalhe.Regional__c == opp.LAT_Account__r.Regional__c && opp.LAT_Account__r.Regional__c != null))
                                 && (detalhe.sub_canal__c == null || (detalhe.sub_canal__c == opp.LAT_Account__r.Sub_Channel__c && opp.LAT_Account__r.Sub_Channel__c != null))
                                 && (detalhe.segmento__c == null || (detalhe.segmento__c == opp.LAT_Account__r.Sub_Channel_Rating__c && opp.LAT_Account__r.Sub_Channel_Rating__c != null))
                                 ){
                                    detalhe.consumo__c +=  (li.LAT_Quantity__c - li.LAT_ConsumedQuoteQuantity__c) * oppTypeSigno;
                                    li.LAT_ConsumedQuote__c = detalhe.id;
                                    li.LAT_ConsumedQuoteQuantity__c = li.LAT_Quantity__c;
                                    linesToUpdate.add(li);
                                    mapToUpdate.put(detalhe.id,detalhe);
                                    detalhesToUpdate.add(detalhe);
                                    break;
                                }
                            }
                        }
                    }
    
                }
            }
            update linesToUpdate;
            update mapToUpdate.values();
            update opp;
       }

    }
    
     //Elimina la referencia a las cotas borradas
     public static void cotaDeleted(List<LAT_DetalheCotaMarket__c> cotas){ 
        if(!Utils.wasMigrationDone('1')){         
             List<String> cotaIds = new List<String>();
             List<OpportunityLineItem> toUpdate = new List<OpportunityLineItem>();
             
             for(LAT_DetalheCotaMarket__c cota : cotas){
                 if(cota.startDate__c < Date.Today()){
                     cota.addError(Label.LAT_COTA_00006);
                     return;
                 }
                 cotaIds.add(cota.id);
             }
             
             for(OpportunityLineItem line : [Select id,Cota_Consumida__c,cantidadCotaConsumida__c from OpportunityLineItem where Cota_Consumida__c in: cotaIds]){
                 line.Cota_Consumida__c = null;
                 line.cantidadCotaConsumida__c = 0;
                 toUpdate.add(line);
             }
             
             update toUpdate;
        }
    //MIGRATED 04/11/2016
        else {
             List<String> cotaIds = new List<String>();
             List<LAT_OpportunityLineItem__c> toUpdate = new List<LAT_OpportunityLineItem__c>();
             
             for(LAT_DetalheCotaMarket__c cota : cotas){
                 if(cota.startDate__c < Date.Today()){
                     cota.addError(Label.LAT_COTA_00006);
                     return;
                 }
                 cotaIds.add(cota.id);
             }
             
             for(LAT_OpportunityLineItem__c line : [Select id,LAT_ConsumedQuote__c,LAT_ConsumedQuoteQuantity__c from LAT_OpportunityLineItem__c where LAT_ConsumedQuote__c in: cotaIds]){
                 line.LAT_ConsumedQuote__c = null;
                 line.LAT_ConsumedQuoteQuantity__c = 0;
                 toUpdate.add(line);
             }
             
             update toUpdate;            
        }
     }
              
     
}