/*****************************************************************************
*     Company:Valuenet  Developer:Elena J. Schwarzböck  Date:22/11/2013      *
******************************************************************************/
/********************************************************************************
*                       
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 07/11/2016
*
********************************************************************************/

global class LAT_MX_WS03_SalesOrderHandlerInterface{
    
    private static LAT_DebugUtil debug;
    public static boolean isProcessing {get; set;}
    
    @future (callout = true)
    Webservice static void SalesOrderInterfaceFuture(String idSalesforce){
        sendOpportunity(idSalesforce);
    }
    
    private static String sendOpportunity(String idSalesforce) {
        debug = new LAT_DebugUtil();
        debug.setOrigin('LAT_MX_WS03_SalesOrderHandlerInterface--future');
        
        //usar Bridge???  
        LAT_GeneralConfig__c cs = LAT_GeneralConfig__c.getInstance('MX_USE_BRIDGE_IN_SALESORDER');
        if(cs!= null){
            if(cs.LAT_Value__C == 'true') {
                LAT_Opportunity__c OPP = [SELECT Id, LAT_StageName__c FROM LAT_Opportunity__c WHERE Id = :idSalesforce];
                try{
                    LAT_BridgeGS1_Order.execute(idSalesforce);

                    if(opp.LAT_StageName__c != 'Pedido cancelado no JDE'){
                        opp.LAT_StageName__c = 'Pedido enviado para o JDE';
                        opp.RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Opportunity__c' + 'LAT_MX_OPP_HeaderBlocked');
                    }  
                
                    opp.LAT_Integration__c = true;
                    update opp;
                } catch(Exception e){
                    opp.LAT_StageName__c = 'Pedido com erro no JDE';
                    opp.LAT_Integration__c = true;
                    update opp;
                
                    debug.addTitle('Unexpected Error');
                    debug.addData('error', e.getMessage());
                    
                    debug.insertDebug();
                }
                return label.LAT_MX_WS03_00005;
            }
        }

        //Ejecucion de la interfaz por SOA
        String result = SalesOrderInterface(idSalesforce);
        
        debug.setResult(result);
        debug.insertDebug(); 

        return result;
    }


    Webservice static String SalesOrderInterface(String idSalesforce){
        LAT_GeneralConfig__c cs = LAT_GeneralConfig__c.getInstance('MX_USE_BRIDGE_IN_SALESORDER');

        if(cs != null) {
            return sendOpportunity(idSalesforce);
        }
        debug = new LAT_DebugUtil();
        debug.setOrigin('LAT_MX_WS03_SalesOrderHandlerInterface');

        if(!Utils.wasMigrationDone('12')) {
            debug.addTitle('Input parameter');
            debug.addData('idSalesforce', idSalesforce);
            
            //Validacion del pedido
            Opportunity opp;
            try{opp = [SELECT Id, Codigo_do_cliente_AN8__c, NR_order_JDE__c, NR_customer_order__c, CloseDate, Data_Entrega_Calculada__c, Type, RecordTypeId,
                       DS_Message1__c, DS_Message2__c, CD_return__c, LAT_MX_OrderPaymentPeriodReference__r.CodDefUsuario__c, LAT_MX_PurchaseOrderSince__c, LAT_MX_PurchaseOrderUntil__c, 
                       LAT_MX_RetentionReason__c, Integracao_Retorno_JDE__c, Pais__c, Owner.C_digo_JDE__c, Account.Business_Unit_AR__r.CodDefUsuario__c, 
                       LAT_MX_OppCancellationReason__c, Freight__c, Account.Client_code_AN8__c, Account.Parent.Client_code_AN8__c, StageName, Origem_do_pedido__c, DT_delivery__c
                       FROM Opportunity
                       WHERE Id =: idSalesforce LIMIT 1];}catch(Exception e){}
            
            if(opp == null){
                return (label.LAT_MX_WS03_00006 + ' (id: ' + idSalesforce + ') ' + label.LAT_MX_WS03_00007);
                //LAT_MX_WS03_00006: Pedido
                //LAT_MX_WS03_00007:no encontrado.
            }
            if(opp.Origem_do_pedido__c != 'CRM' && opp.Origem_do_pedido__c != 'APP'){
                return label.LAT_MX_WS03_00001; 
                //LAT_MX_WS03_00001: Solamente los pedidos con origen CRM se pueden enviar a JDE.
            }
            
            //Validacion de los productos del pedido
            List<OpportunityLineItem> listaItens = [SELECT CD_Action__c, LAT_SkuText__c, LAT_PaymentCondition__c, NR_order_line__c, QT_Bonus__c, Quantity,
                                                    cd_unit_bonif__c, LAT_UnitCode__c, LAT_PercentualBonus__c, pc_discount__c, cd_line_status__c, UOM_AR__c,
                                                    Discount_AR__c, SenttoApproveDiscount_AR__c, Remover__c, Campo_de_formatacao__c, LAT_MX_CDLineStatusFrom__c,
                                                    LAT_MX_KAMPromisedDate__c, LAT_MX_EstimatedDeliveryDate__c, LAT_MX_LogisticsPromisedDate__c,
                                                    LAT_MX_RealDeliveryDate__c, LAT_MX_CancellationReason__c, CD_unit__c
                                                    FROM OpportunityLineItem
                                                    WHERE OpportunityId =: idSalesforce AND cd_line_status__c <> '999' ORDER BY NR_order_line__c, PricebookEntry.Product2.Name];
            
            if(listaItens.isEmpty()){
                return label.LAT_MX_WS03_00003;
                //LAT_MX_WS03_00003: No es posible enviar a JDE porque no hay productos seleccionados.
            }
            for(OpportunityLineItem oppItem : listaItens){
                if(oppItem.Campo_de_formatacao__c == null || oppItem.Campo_de_formatacao__c.length() == 0){
                    return label.LAT_MX_WS03_00004;
                    //LAT_MX_WS03_00004: No es posible enviar a JDE porque hay productos sin cálculo de precio.
                }
            }
            
            debug.addTitle('Header');
            debug.addData('customerCode', String.ValueOf(opp.Account.Client_code_AN8__c));
            debug.addData('customerShippingCode', String.ValueOf(opp.Account.Parent.Client_code_AN8__c != null ? Integer.valueOf(opp.Account.Parent.Client_code_AN8__c) : Integer.valueOf(opp.Account.Client_code_AN8__c)));
            debug.addData('orderNumber', String.ValueOf(opp.NR_order_JDE__c));
            debug.addData('customerBuyOrder', String.ValueOf(opp.NR_customer_order__c));
            debug.addData('orderRequestDate', String.ValueOf(opp.CloseDate));
            debug.addData('purchaseOrderUntil', String.ValueOf(opp.LAT_MX_PurchaseOrderUntil__c));
            debug.addData('orderType', String.ValueOf(opp.Type));
            debug.addData('note1', String.ValueOf(opp.DS_Message1__c));
            debug.addData('note2', String.ValueOf(opp.DS_Message2__c));
            debug.addData('freightType', String.ValueOf(opp.Freight__c));
            debug.addData('orderNumberForeign', String.ValueOf(opp.Id));
            debug.addData('salesman', String.ValueOf(opp.Owner.C_digo_JDE__c));
            debug.addData('businessUnit', String.ValueOf(opp.Account.Business_Unit_AR__r.CodDefUsuario__c));
            debug.addData('paymentTerm', String.ValueOf(opp.LAT_MX_OrderPaymentPeriodReference__r.CodDefUsuario__c));
            
            //Mapeo de Header de pedido
            SalesOrderHandlerTypes.SalesOrderHeaderRequestType header = new SalesOrderHandlerTypes.SalesOrderHeaderRequestType();
            
            header.customerShippingCode = opp.Account.Parent.Client_code_AN8__c != null ? Integer.valueOf(opp.Account.Parent.Client_code_AN8__c) : Integer.valueOf(opp.Account.Client_code_AN8__c);
            header.orderNumber          = (opp.NR_order_JDE__c != null && opp.NR_order_JDE__c != '') ? Long.valueOf(opp.NR_order_JDE__c) : null;
            header.orderType            = (opp.Type != null && opp.Type.length() > 2) ? opp.Type.substring(0,2) : opp.Type;
            header.paymentTerm          = opp.LAT_MX_OrderPaymentPeriodReference__r.CodDefUsuario__c;
            header.businessUnit         = opp.Account.Business_Unit_AR__r.CodDefUsuario__c;
            header.customerCode         = Integer.valueOf(opp.Account.Client_code_AN8__c);
            header.purchaseOrderUntil   = getDateTime(opp.LAT_MX_PurchaseOrderUntil__c);
            header.orderRequestDate     = getDateTime(opp.CloseDate);
            header.customerBuyOrder     = opp.NR_customer_order__c;    
            header.salesman             = opp.Owner.C_digo_JDE__c;
            header.note1                = opp.DS_Message1__c;
            header.note2                = opp.DS_Message2__c;        
            header.freightType          = opp.Freight__c;
            header.orderNumberForeign   = opp.Id;        
            header.promisedDate         = opp.DT_delivery__c != null ? getDateTime(opp.DT_delivery__c) : null;
            
            header.invoiceDate          = getDateTime(Date.today());//Campo obligatorio en la interfaz
            //header.promisedDate           = getDateTime(Date.today());//Campo obligatorio en la interfaz
            
            // campos obligatorios de la interfaz
            if (header.purchaseOrderUntil == null) header.purchaseOrderUntil = getDateTime(Date.today());
            
            if(opp.StageName == 'Pedido cancelado no JDE'){
                header.actionCode = 'C';
            }else if(opp.NR_order_JDE__c != null && opp.NR_order_JDE__c != ''){
                header.actionCode = 'U';
            }else{
                header.actionCode = 'I';
            }
            
            debug.addTitle('Items');
            //Mapeo de los productos del pedido
            List<SalesOrderHandlerTypes.SalesOrderItemRequestType> items = new List<SalesOrderHandlerTypes.SalesOrderItemRequestType>();
            for(OpportunityLineItem oppItem: listaItens){
                SalesOrderHandlerTypes.SalesOrderItemRequestType item = new SalesOrderHandlerTypes.SalesOrderItemRequestType();
                
                debug.addSubTitle('Item');
                debug.addData('billedTotalQuantity', String.ValueOf(oppItem.Quantity));
                debug.addData('orderLineStatus', String.ValueOf(oppItem.cd_line_status__c));
                debug.addData('orderLineLastStatus', String.ValueOf(oppItem.LAT_MX_CDLineStatusFrom__c));
                debug.addData('lineNumber', String.ValueOf(oppItem.NR_order_line__c));
                debug.addData('sku', String.ValueOf(oppItem.LAT_SkuText__c));
                debug.addData('promisedDate', String.ValueOf(oppItem.LAT_MX_KAMPromisedDate__c));
                debug.addData('estimatedDeliveryDate', String.ValueOf(oppItem.LAT_MX_EstimatedDeliveryDate__c));
                debug.addData('logisticsPromisedDate', String.ValueOf(oppItem.LAT_MX_LogisticsPromisedDate__c));
                debug.addData('realDeliveryDate', String.ValueOf(oppItem.LAT_MX_RealDeliveryDate__c));
                debug.addData('cancellationReason', String.ValueOf(oppItem.LAT_MX_CancellationReason__c));
                
                item.lineNumber            = oppItem.NR_order_line__c != null ? Integer.valueOf(oppItem.NR_order_line__c) : null;
                item.estimatedDeliveryDate = getDateTime(oppItem.LAT_MX_EstimatedDeliveryDate__c);
                item.logisticsPromisedDate = getDateTime(oppItem.LAT_MX_LogisticsPromisedDate__c);
                item.realDeliveryDate      = getDateTime(oppItem.LAT_MX_RealDeliveryDate__c);
                item.promisedDate          = getDateTime(oppItem.LAT_MX_KAMPromisedDate__c);
                item.cancellationReason    = oppItem.LAT_MX_CancellationReason__c;
                item.orderLineLastStatus   = oppItem.LAT_MX_CDLineStatusFrom__c;
                item.orderLineStatus       = oppItem.cd_line_status__c;
                item.sku                   = oppItem.LAT_SkuText__c;
                item.salesUOM              = oppItem.CD_unit__c;
                item.billedTotalQuantity   = oppItem.Quantity;
                
                // Campos obligatorios de items
                if (item.promisedDate == null) item.promisedDate = header.promisedDate;
                if (item.estimatedDeliveryDate == null) item.estimatedDeliveryDate = header.promisedDate;
                if (item.logisticsPromisedDate == null) item.logisticsPromisedDate = header.promisedDate;
                if (item.realDeliveryDate == null) item.realDeliveryDate = header.promisedDate;
                           
                if(oppItem.Remover__c){
                    item.actionCode = 'C';
                }else if(oppItem.NR_order_line__c != null && oppItem.NR_order_line__c != ''){
                    item.actionCode = 'U';
                }else{
                    item.actionCode = 'I';  
                }
                items.add(item);                     
            }
            
            //Llamado a la interfase
            SalesOrderHandler.execute_pt request = new SalesOrderHandler.execute_pt();
            request.timeout_x = 120000;
            SalesOrderHandlerTypes.SalesOrderHandlerResponseType response;
            integer responseCode = 0;
            
            try{
                responseCode = request.execute(getConnectionParameter('México'), header, items);
            }catch(Exception e){
                opp.Integracao_Retorno_JDE__c = e.getMessage();
                opp.StageName = 'Pedido com erro no JDE';
                opp.Integracao__c = true;
                update opp;
                
                debug.addTitle('Unexpected Error');
                debug.addData('error', e.getMessage());
                
                return label.LAT_MX_WS03_00005;
                //LAT_MX_WS03_00005: Error inespedado en el envio a JDE.
            }
            
            if(responseCode == 0){
                if(opp.StageName != 'Pedido cancelado no JDE'){
                    opp.StageName = 'Pedido enviado para o JDE';
                    opp.RecordTypeId = Global_RecordTypeCache.getRtId('Opportunity' + 'LAT_MX_OPP_HeaderBlocked');
                }  
            }else{
                opp.StageName = 'Pedido com erro no JDE';
            }
            
            opp.Integracao__c = true;
            update opp;
            return String.ValueOf(responseCode);
        }
        //MIGRATED 07/11/2016
        else {
            debug.addTitle('Input parameter');
            debug.addData('idSalesforce', idSalesforce);
            
            //Validacion del pedido
            LAT_Opportunity__c opp;
            try{opp = [SELECT Id, LAT_ClientCodeAN8__c, LAT_NROrderJDE__c, LAT_NRCustomerOrder__c, LAT_CloseDate__c, LAT_EstimatedDeliveryDate__c, LAT_Type__c, RecordTypeId,
                       LAT_DSMessage1__c, LAT_DSMessage2__c, LAT_CDReturn__c, LAT_MX_OrderPaymentPeriodReference__r.CodDefUsuario__c, LAT_MX_PurchaseOrderSince__c, LAT_MX_PurchaseOrderUntil__c, 
                       LAT_MX_RetentionReason__c, LAT_JDEIntegrationReturn__c, LAT_Country__c, LAT_Account__r.Owner.C_digo_JDE__c, LAT_Account__r.Business_Unit_AR__r.CodDefUsuario__c, 
                       LAT_MX_OppCancellationReason__c, LAT_Freight__c, LAT_Account__r.Client_code_AN8__c, LAT_Account__r.Parent.Client_code_AN8__c, LAT_StageName__c, LAT_OrderOrigin__c, LAT_DTDelivery__c
                       FROM LAT_Opportunity__c
                       WHERE Id =: idSalesforce LIMIT 1];}catch(Exception e){}
            
            if(opp == null){
                return (label.LAT_MX_WS03_00006 + ' (id: ' + idSalesforce + ') ' + label.LAT_MX_WS03_00007);
                //LAT_MX_WS03_00006: Pedido
                //LAT_MX_WS03_00007:no encontrado.
            }
            if(opp.LAT_OrderOrigin__c != 'CRM' && opp.LAT_OrderOrigin__c != 'APP'){
                return label.LAT_MX_WS03_00001; 
                //LAT_MX_WS03_00001: Solamente los pedidos con origen CRM se pueden enviar a JDE.
            }
            
            //Validacion de los productos del pedido
            List<LAT_OpportunityLineItem__c> listaItens = [SELECT LAT_Product__r.Name, LAT_CDAction__c, LAT_SkuText__c, LAT_PaymentCondition__c, LAT_NROrderLine__c, LAT_QTBonus__c, LAT_Quantity__c,
                                                    LAT_CdUnitBonification__c, LAT_UnitCode__c, LAT_PercentualBonus__c, LAT_PcDiscount__c, LAT_CdLineStatus__c, LAT_AR_UOM__c,
                                                    LAT_AR_Discount__c, LAT_AR_SentToApproveDiscount__c, LAT_Remover__c, LAT_FormatField__c, LAT_MX_CDLineStatusFrom__c,
                                                    LAT_MX_KAMPromisedDate__c, LAT_MX_EstimatedDeliveryDate__c, LAT_MX_LogisticsPromisedDate__c,
                                                    LAT_MX_RealDeliveryDate__c, LAT_MX_CancellationReason__c, LAT_CDUnit__c
                                                    FROM LAT_OpportunityLineItem__c
                                                    WHERE LAT_Opportunity__c =: idSalesforce AND LAT_CdLineStatus__c <> '999' ORDER BY LAT_NROrderLine__c, LAT_Product__r.Name];
            
            if(listaItens.isEmpty()){
                return label.LAT_MX_WS03_00003;
                //LAT_MX_WS03_00003: No es posible enviar a JDE porque no hay productos seleccionados.
            }
            if (opp.LAT_OrderOrigin__c == 'APP' ) {
                //LAT_MX_WS02_PriceCalculateInterface.execute(idSalesforce, listaItens);
            } else {
                for(LAT_OpportunityLineItem__c oppItem : listaItens){
                    if(oppItem.LAT_FormatField__c == null || oppItem.LAT_FormatField__c.length() == 0){
                        return label.LAT_MX_WS03_00004;
                        //LAT_MX_WS03_00004: No es posible enviar a JDE porque hay productos sin cálculo de precio.
                    }
                }            
            }

            
            debug.addTitle('Header');
            debug.addData('customerCode', String.ValueOf(opp.LAT_Account__r.Client_code_AN8__c));
            debug.addData('customerShippingCode', String.ValueOf(opp.LAT_Account__r.Parent.Client_code_AN8__c != null ? Integer.valueOf(opp.LAT_Account__r.Parent.Client_code_AN8__c) : Integer.valueOf(opp.LAT_Account__r.Client_code_AN8__c)));
            debug.addData('orderNumber', String.ValueOf(opp.LAT_NROrderJDE__c));
            debug.addData('customerBuyOrder', String.ValueOf(opp.LAT_NRCustomerOrder__c));
            debug.addData('orderRequestDate', String.ValueOf(opp.LAT_CloseDate__c));
            debug.addData('purchaseOrderUntil', String.ValueOf(opp.LAT_MX_PurchaseOrderUntil__c));
            debug.addData('orderType', String.ValueOf(opp.LAT_Type__c));
            debug.addData('note1', String.ValueOf(opp.LAT_DSMessage1__c));
            debug.addData('note2', String.ValueOf(opp.LAT_DSMessage2__c));
            debug.addData('freightType', String.ValueOf(opp.LAT_Freight__c));
            debug.addData('orderNumberForeign', String.ValueOf(opp.Id));
            debug.addData('salesman', String.ValueOf(opp.LAT_Account__r.Owner.C_digo_JDE__c));
            debug.addData('businessUnit', String.ValueOf(opp.LAT_Account__r.Business_Unit_AR__r.CodDefUsuario__c));
            debug.addData('paymentTerm', String.ValueOf(opp.LAT_MX_OrderPaymentPeriodReference__r.CodDefUsuario__c));
            debug.addData('origin', String.ValueOf(opp.LAT_OrderOrigin__c));
            
            //Mapeo de Header de pedido
            SalesOrderHandlerTypes.SalesOrderHeaderRequestType header = new SalesOrderHandlerTypes.SalesOrderHeaderRequestType();
            
            header.customerShippingCode = opp.LAT_Account__r.Parent.Client_code_AN8__c != null ? Integer.valueOf(opp.LAT_Account__r.Parent.Client_code_AN8__c) : Integer.valueOf(opp.LAT_Account__r.Client_code_AN8__c);
            header.orderNumber          = (opp.LAT_NROrderJDE__c != null && opp.LAT_NROrderJDE__c != '') ? Long.valueOf(opp.LAT_NROrderJDE__c) : null;
            header.orderType            = (opp.LAT_Type__c != null && opp.LAT_Type__c.length() > 2) ? opp.LAT_Type__c.substring(0,2) : opp.LAT_Type__c;
            header.paymentTerm          = opp.LAT_MX_OrderPaymentPeriodReference__r.CodDefUsuario__c;
            header.businessUnit         = opp.LAT_Account__r.Business_Unit_AR__r.CodDefUsuario__c;
            header.customerCode         = Integer.valueOf(opp.LAT_Account__r.Client_code_AN8__c);
            header.purchaseOrderUntil   = getDateTime(opp.LAT_MX_PurchaseOrderUntil__c);
            header.orderRequestDate     = getDateTime(opp.LAT_CloseDate__c);
            header.customerBuyOrder     = opp.LAT_NRCustomerOrder__c;    
            header.salesman             = opp.LAT_Account__r.Owner.C_digo_JDE__c;
            header.note1                = opp.LAT_DSMessage1__c;
            header.note2                = opp.LAT_DSMessage2__c;        
            header.freightType          = opp.LAT_Freight__c;
            header.orderNumberForeign   = opp.Id;        
            header.promisedDate         = opp.LAT_DTDelivery__c != null ? getDateTime(opp.LAT_DTDelivery__c) : null;
            
            header.invoiceDate          = getDateTime(Date.today());//Campo obligatorio en la interfaz
            //header.promisedDate           = getDateTime(Date.today());//Campo obligatorio en la interfaz
            
            // campos obligatorios de la interfaz
            if (header.purchaseOrderUntil == null) header.purchaseOrderUntil = getDateTime(Date.today());
            
            if(opp.LAT_StageName__c == 'Pedido cancelado no JDE'){
                header.actionCode = 'C';
            }else if(opp.LAT_NROrderJDE__c != null && opp.LAT_NROrderJDE__c != ''){
                header.actionCode = 'U';
            }else{
                header.actionCode = 'I';
            }
            
            debug.addTitle('Items');
            //Mapeo de los productos del pedido
            List<SalesOrderHandlerTypes.SalesOrderItemRequestType> items = new List<SalesOrderHandlerTypes.SalesOrderItemRequestType>();
            for(LAT_OpportunityLineItem__c oppItem: listaItens){
                SalesOrderHandlerTypes.SalesOrderItemRequestType item = new SalesOrderHandlerTypes.SalesOrderItemRequestType();
                
                debug.addSubTitle('Item');
                debug.addData('billedTotalQuantity', String.ValueOf(oppItem.LAT_Quantity__c));
                debug.addData('orderLineStatus', String.ValueOf(oppItem.LAT_CdLineStatus__c));
                debug.addData('orderLineLastStatus', String.ValueOf(oppItem.LAT_MX_CDLineStatusFrom__c));
                debug.addData('lineNumber', String.ValueOf(oppItem.LAT_NROrderLine__c));
                debug.addData('sku', String.ValueOf(oppItem.LAT_SkuText__c));
                debug.addData('promisedDate', String.ValueOf(oppItem.LAT_MX_KAMPromisedDate__c));
                debug.addData('estimatedDeliveryDate', String.ValueOf(oppItem.LAT_MX_EstimatedDeliveryDate__c));
                debug.addData('logisticsPromisedDate', String.ValueOf(oppItem.LAT_MX_LogisticsPromisedDate__c));
                debug.addData('realDeliveryDate', String.ValueOf(oppItem.LAT_MX_RealDeliveryDate__c));
                debug.addData('cancellationReason', String.ValueOf(oppItem.LAT_MX_CancellationReason__c));
                
                item.lineNumber            = oppItem.LAT_NROrderLine__c != null ? Integer.valueOf(oppItem.LAT_NROrderLine__c) : null;
                item.estimatedDeliveryDate = getDateTime(oppItem.LAT_MX_EstimatedDeliveryDate__c);
                item.logisticsPromisedDate = getDateTime(oppItem.LAT_MX_LogisticsPromisedDate__c);
                item.realDeliveryDate      = getDateTime(oppItem.LAT_MX_RealDeliveryDate__c);
                item.promisedDate          = getDateTime(oppItem.LAT_MX_KAMPromisedDate__c);
                item.cancellationReason    = oppItem.LAT_MX_CancellationReason__c;
                item.orderLineLastStatus   = oppItem.LAT_MX_CDLineStatusFrom__c;
                item.orderLineStatus       = oppItem.LAT_CdLineStatus__c;
                item.sku                   = oppItem.LAT_SkuText__c;
                item.salesUOM              = oppItem.LAT_CDUnit__c;
                item.billedTotalQuantity   = oppItem.LAT_Quantity__c;
                
                // Campos obligatorios de items
                if (item.promisedDate == null) item.promisedDate = header.promisedDate;
                if (item.estimatedDeliveryDate == null) item.estimatedDeliveryDate = header.promisedDate;
                if (item.logisticsPromisedDate == null) item.logisticsPromisedDate = header.promisedDate;
                if (item.realDeliveryDate == null) item.realDeliveryDate = header.promisedDate;
                           
                if(oppItem.LAT_Remover__c){
                    item.actionCode = 'C';
                }else if(oppItem.LAT_NROrderLine__c != null && oppItem.LAT_NROrderLine__c != ''){
                    item.actionCode = 'U';
                }else{
                    item.actionCode = 'I';  
                }
                items.add(item);                     
            }
            
            //Llamado a la interfase
            SalesOrderHandler.execute_pt request = new SalesOrderHandler.execute_pt();
            request.timeout_x = 120000;
            SalesOrderHandlerTypes.SalesOrderHandlerResponseType response;
            integer responseCode = 0;
            
            try{
                responseCode = request.execute(getConnectionParameter('México'), header, items);
            }catch(Exception e){
                opp.LAT_JDEIntegrationReturn__c = e.getMessage();
                opp.LAT_StageName__c = 'Pedido com erro no JDE';
                opp.LAT_Integration__c = true;
                update opp;
                
                debug.addTitle('Unexpected Error');
                debug.addData('error', e.getMessage());
                
                return label.LAT_MX_WS03_00005;
                //LAT_MX_WS03_00005: Error inespedado en el envio a JDE.
            }
            
            if(responseCode == 0){
                if(opp.LAT_StageName__c != 'Pedido cancelado no JDE'){
                    opp.LAT_StageName__c = 'Pedido enviado para o JDE';
                    opp.RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Opportunity__c' + 'LAT_MX_OPP_HeaderBlocked');
                }  
            }else{
                opp.LAT_StageName__c = 'Pedido com erro no JDE';
            }
            
            opp.LAT_Integration__c = true;
            update opp;
            return String.ValueOf(responseCode);            
        }
    }
    
    public static SalesOrderHandlerTypes.ClientInfoType getConnectionParameter(string country){
        CS001_JDEInterfaceCredentials__c cred = CS001_JDEInterfaceCredentials__c.getInstance(country);
        SalesOrderHandlerTypes.ClientInfoType connParms = new SalesOrderHandlerTypes.ClientInfoType();
        if(cred != null){
            connParms.country = cred.Country__c;
            connParms.remoteHostIP = cred.RemoteHostIP__c;
            connParms.system_x = cred.System__c;
            connParms.systemUserID = cred.SystemUserID__c;
            connParms.time_x=Datetime.now();
        }
        return connParms;
    }
    
    private static Datetime getDateTime(Datetime fecha){
        if(fecha != null){
            return Datetime.newinstance( fecha.year(), fecha.month(), fecha.day(), 14, 01, 02 );
        }
        return null;
    }
    
    private static Datetime getDateTime(Date fecha){
        if(fecha != null){
            return Datetime.newinstance( fecha.year(), fecha.month(), fecha.day(), 14, 01, 02 );
        }
        return null;
    }
    
}