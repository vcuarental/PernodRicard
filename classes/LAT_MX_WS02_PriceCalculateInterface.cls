/********************************************************************************
*     Company:Valuenet  Developer:Elena J. Schwarzböck    Date:22/11/2013       *
*********************************************************************************/
/********************************************************************************
*                       
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 05/11/2016
*
********************************************************************************/

global class LAT_MX_WS02_PriceCalculateInterface{
    
    private static LAT_Log__c logAsRegistry;
    private static LAT_DebugUtil debug;
    private static Opportunity opp;
    private static LAT_Opportunity__c LAT_opp;
    
    public static String execute(String idSalesforce, List<OpportunityLineItem> oppItems){
        String result = '';

        /*logAsRegistry = new LAT_Log__c();
        debug = new LAT_DebugUtil();
        logAsRegistry.LAT_Origin__c = 'LAT_MX_WS02_PriceCalculateInterface';
        logAsRegistry.LAT_StartTime__c = system.now();
        logAsRegistry.LAT_Date__c = date.today();
        logAsRegistry.LAT_User__c = system.Userinfo.getUserId();
        debug.setOrigin('LAT_MX_WS02_PriceCalculateInterface');
        
        result = PriceCalculation(idSalesforce, oppItems);

        logAsRegistry.LAT_Account__c = opp.AccountId;
        logAsRegistry.LAT_OrderNumber__c = opp.NR_order_JDE__c;
        logAsRegistry.LAT_Country__c = string.valueOf(opp.Pais__c); 
        logAsRegistry.LAT_ReturnTime__c = system.now();
        try{insert logAsRegistry;}catch(Exception e){}
        
        if(result != ''){
            debug.setResult(result);
            debug.insertDebug();
        }*/
        return result;
    }
    //MIGRATED 05/11/2016
    public static String execute(String idSalesforce, List<LAT_OpportunityLineItem__c> oppItems){
        logAsRegistry = new LAT_Log__c();
        debug = new LAT_DebugUtil();
        logAsRegistry.LAT_Origin__c = 'LAT_MX_WS02_PriceCalculateInterface';
        logAsRegistry.LAT_StartTime__c = system.now();
        logAsRegistry.LAT_Date__c = date.today();
        logAsRegistry.LAT_User__c = system.Userinfo.getUserId();
        debug.setOrigin('LAT_MX_WS02_PriceCalculateInterface');
        
        String result = '';
        CS001_JDEInterfaceCredentials__c cred = LAT_WS_Utils.getHeaderKey('12');
        // Execute the method as it was migrated
        if(!cred.Exec_new_Price_Calc__c){
            System.debug('OldPrice');
            result = LAT_PriceCalculation(idSalesforce, oppItems); 
        } else {
            System.debug('NewPrice');
            result = LAT_MX_NewPriceCalculation(idSalesforce, oppItems);
        }


        logAsRegistry.LAT_Account__c = LAT_opp.LAT_Account__c;
        logAsRegistry.LAT_OrderNumber__c = LAT_opp.LAT_NROrderJDE__c;
        logAsRegistry.LAT_Country__c = string.valueOf(LAT_opp.LAT_Country__c);
        logAsRegistry.LAT_ReturnTime__c = system.now();
        //try{insert logAsRegistry;}catch(Exception e){}
        
        if(result != ''){
            debug.setResult(result);
            debug.insertDebug();
        }
        return result;
    }
    
    Webservice static String PriceCalculation(String idSalesforce, List<OpportunityLineItem> oppItems){
        /*try{
            debug.addTitle('Input parameter');
            debug.addData('idSalesforce', idSalesforce);
            debug.addData('oppItems', String.ValueOf(oppItems));
            
            try{
                opp = [SELECT Id, Owner.C_digo_JDE__c, Account.Client_code_AN8__c, Codigo_do_cliente_AN8__c, Freight__c, DT_delivery__c, Account.Business_Unit_AR__r.CodDefUsuario__c, Type, Account.Payment_Condition__r.CodDefUsuario__c, LAT_MX_OrderPaymentPeriodReference__r.CodDefUsuario__c, Integracao_Retorno_JDE__c, AccountId, NR_order_JDE__c, Pais__c FROM Opportunity WHERE Id =: idSalesforce LIMIT 1]; 
                }catch(Exception e){}
             
            if(opp == null){
                return label.LAT_MX_WS02_00001;
                //LAT_MX_WS02_00001: El pedido no existe
            }
            
            if(oppItems.isEmpty()){
                return label.LAT_MX_WS02_00002;
                //LAT_MX_WS02_00002: El pedido no contiene productos
            }
            
            debug.addTitle('Header');
            debug.addData('Owner.C_digo_JDE__c', String.ValueOf(opp.Owner.C_digo_JDE__c));
            debug.addData('Account.Client_code_AN8__c', String.ValueOf(opp.Account.Client_code_AN8__c));
            debug.addData('Freight__c', String.ValueOf(opp.Freight__c));
            debug.addData('Account.Business_Unit_AR__r.CodDefUsuario__c', String.ValueOf(opp.Account.Business_Unit_AR__r.CodDefUsuario__c));
            debug.addData('Type', String.ValueOf((opp.Type != null && opp.Type.length() > 2) ? opp.Type.substring(0,2) : opp.Type));
            
            //Mapeo de Header de pedido
            PriceCalculationTypes.PriceCalculationHeaderRequestType header = new PriceCalculationTypes.PriceCalculationHeaderRequestType();
            
            header.salesman     = opp.Owner.C_digo_JDE__c;
            header.customerCode = Integer.valueOf(opp.Account.Client_code_AN8__c);
            header.freightType  = opp.Freight__c;
            header.businessUnit = opp.Account.Business_Unit_AR__r.CodDefUsuario__c;
            header.orderType    = (opp.Type != null && opp.Type.length() > 2) ? opp.Type.substring(0,2) : opp.Type;
            
            //Mapeo de los productos del pedido
            List<PriceCalculationTypes.PriceCalculationItemRequestType> items = new List<PriceCalculationTypes.PriceCalculationItemRequestType>();
            debug.addTitle('Items');
            for(OpportunityLineItem oppItem: oppItems){
                PriceCalculationTypes.PriceCalculationItemRequestType item = new PriceCalculationTypes.PriceCalculationItemRequestType();
                
                debug.addSubTitle('Item');
                debug.addData('LAT_SkuText__c', String.ValueOf(oppItem.LAT_SkuText__c));
                debug.addData('UOM_AR__c', String.ValueOf(oppItem.UOM_AR__c));
                debug.addData('Quantity', String.ValueOf(oppItem.Quantity));
                debug.addData('LAT_MX_OrderPaymentPeriodReference__r.CodDefUsuario__c', String.ValueOf(opp.LAT_MX_OrderPaymentPeriodReference__r.CodDefUsuario__c != null ? opp.LAT_MX_OrderPaymentPeriodReference__r.CodDefUsuario__c: opp.Account.Payment_Condition__r.CodDefUsuario__c));
                
                item.sku                 = oppItem.LAT_SkuText__c;
                item.salesUOM            = oppItem.UOM_AR__c;
                item.billedTotalQuantity = oppItem.Quantity;
                item.paymentTerm         = opp.LAT_MX_OrderPaymentPeriodReference__r.CodDefUsuario__c != null ? opp.LAT_MX_OrderPaymentPeriodReference__r.CodDefUsuario__c: opp.Account.Payment_Condition__r.CodDefUsuario__c;
                item.percentualDiscount  = 0; // campo obligatorio
                items.add(item);
            }
            
            //ejecuto la interfaz
            PriceCalculation.port request = new PriceCalculation.port();
            request.timeout_x = 120000;
            PriceCalculationTypes.PriceCalculationResponseType response;
            try{

                response = request.operation(getConnectionParameter('México'), header, items);
            }catch(Exception e){
            
                logAsRegistry.LAT_Account__c = opp.AccountId;
                logAsRegistry.LAT_OrderNumber__c = opp.NR_order_JDE__c;
                logAsRegistry.LAT_Opportunity__c = opp.Id;
                logAsRegistry.LAT_Country__c = string.valueOf(opp.Pais__c);
                logAsRegistry.LAT_ReturnTime__c = system.now();
                try{insert logAsRegistry;}catch(Exception e1){}
                
                debug.addTitle('Unexpected Error');
                debug.addData('Error', e.getMessage());
                return label.LAT_MX_WS02_00003;
                //LAT_MX_WS02_00003: Error inesperado en el envio a JDE. Contacte a su administrador de sistema
            }
            
            if(response == null){
                return label.LAT_MX_WS02_00003;
                //LAT_MX_WS02_00003: Error inesperado en el envio a JDE. Contacte a su administrador de sistema
            }
            
            Map<String, PriceCalculationTypes.PriceCalculationItemResponseType> mapItems = new Map<String, PriceCalculationTypes.PriceCalculationItemResponseType>();
            for(PriceCalculationTypes.PriceCalculationItemResponseType respItem: response.item){
                mapItems.put(String.ValueOf(respItem.sku).trim(), respItem);
            }
            
            debug.addTitle('Response');
            debug.addData('mapItems', String.ValueOf(mapItems));
            
            //Se cargan los valores obtenidos en la interfaz a la lista que se envia al metodo
            for(OpportunityLineItem oli: oppItems){
                if(mapItems.containsKey(oli.LAT_SkuText__c)){
                    oli.UnitPrice              = mapItems.get(oli.LAT_SkuText__c).salesPriceValue;
                    oli.Campo_de_formatacao__c = Utils.decodeString(mapItems.get(oli.LAT_SkuText__c).priceComponents, false);
                }
            }
            
        } catch(Exception e) {
            debug.addTitle('Unexpected Error');
            debug.addData('Error', e.getMessage());
            return label.LAT_MX_WS02_00003;
            //LAT_MX_WS02_00003: Error inesperado en el envio a JDE. Contacte a su administrador de sistema
        }*/
        
        return '';
    }

    Webservice static String LAT_MX_NewPriceCalculation(String idSalesforce, List<LAT_OpportunityLineItem__c> oppItems){
        String resp = '';
            try{
                LAT_opp = [SELECT Id, LAT_Account__r.Owner.C_digo_JDE__c, LAT_Account__r.Client_code_AN8__c, LAT_ClientCodeAN8__c, LAT_Freight__c, LAT_DTDelivery__c, LAT_Account__r.Business_Unit_AR__r.CodDefUsuario__c, LAT_Type__c, LAT_Account__r.Payment_Condition__r.CodDefUsuario__c, LAT_MX_OrderPaymentPeriodReference__r.CodDefUsuario__c, LAT_JDEIntegrationReturn__c, LAT_Account__c, LAT_NROrderJDE__c, LAT_Country__c FROM LAT_Opportunity__c WHERE Id =: idSalesforce LIMIT 1];
            }catch(Exception e){}
             
            if(LAT_opp == null){
                return label.LAT_MX_WS02_00001;
                //LAT_MX_WS02_00001: El pedido no existe
            }
            
            if(oppItems.isEmpty()){
                return label.LAT_MX_WS02_00002;
                //LAT_MX_WS02_00002: El pedido no contiene productos
            }
            
            debug.addTitle('Header');
            debug.addData('Owner.C_digo_JDE__c', String.ValueOf(LAT_opp.LAT_Account__r.Owner.C_digo_JDE__c));
            debug.addData('Account.Client_code_AN8__c', String.ValueOf(LAT_opp.LAT_Account__r.Client_code_AN8__c));
            debug.addData('Account.Business_Unit_AR__r.CodDefUsuario__c', String.ValueOf(LAT_opp.LAT_Account__r.Business_Unit_AR__r.CodDefUsuario__c));
            debug.addData('Type', String.ValueOf((LAT_opp.LAT_Type__c != null && LAT_opp.LAT_Type__c.length() > 2) ? LAT_opp.LAT_Type__c.substring(0,2) : LAT_opp.LAT_Type__c));
            
            //Mapeo de Header de pedido
            //PriceCalculationTypes.PriceCalculationHeaderRequestType header = new PriceCalculationTypes.PriceCalculationHeaderRequestType();
            LAT_MX_PriceCalculation.priceCatalogueHeaderInput header = new LAT_MX_PriceCalculation.priceCatalogueHeaderInput();

            String businessUnit = LAT_opp.LAT_Account__r.Business_Unit_AR__r.CodDefUsuario__c;
            String ediTransactionType = '';
            Datetime priceEffectiveDate = Date.today();
            String paymentTerm = LAT_opp.LAT_MX_OrderPaymentPeriodReference__r.CodDefUsuario__c != null ? LAT_opp.LAT_MX_OrderPaymentPeriodReference__r.CodDefUsuario__c: LAT_opp.LAT_Account__r.Payment_Condition__r.CodDefUsuario__c;
            String countryCode = '12';
            Integer shipTo = Integer.valueOf(LAT_opp.LAT_Account__r.Client_code_AN8__c);
            Integer soldTo = Integer.valueOf(LAT_opp.LAT_Account__r.Client_code_AN8__c);
            Datetime taxEffectiveDate = date.today();
            String orderType = String.ValueOf((LAT_opp.LAT_Type__c != null && LAT_opp.LAT_Type__c.length() > 2) ? LAT_opp.LAT_Type__c.substring(0,2) : LAT_opp.LAT_Type__c);

            //Mapeo de los productos del pedido
            List<LAT_MX_PriceCalculation.priceCatalogueDetailsInput> priceCatalogueDetails = new List<LAT_MX_PriceCalculation.priceCatalogueDetailsInput>();
            for(LAT_OpportunityLineItem__c oppItem: oppItems){
                LAT_MX_PriceCalculation.priceCatalogueDetailsInput item = new LAT_MX_PriceCalculation.priceCatalogueDetailsInput();
                
                debug.addSubTitle('Item');
                debug.addData('LAT_SkuText__c', String.ValueOf(oppItem.LAT_SkuText__c));
                debug.addData('UOM_AR__c', String.ValueOf(oppItem.LAT_AR_UOM__c));
                debug.addData('Quantity', String.ValueOf(oppItem.LAT_Quantity__c));
                debug.addData('LAT_MX_OrderPaymentPeriodReference__r.CodDefUsuario__c', String.ValueOf(LAT_opp.LAT_MX_OrderPaymentPeriodReference__r.CodDefUsuario__c != null ? LAT_opp.LAT_MX_OrderPaymentPeriodReference__r.CodDefUsuario__c: LAT_opp.LAT_Account__r.Payment_Condition__r.CodDefUsuario__c));
                
                item.secondItemNumber     = oppItem.LAT_SkuText__c;
                item.unitOfMeasure        = oppItem.LAT_AR_UOM__c;
                item.quantityOrdered      = oppItem.LAT_Quantity__c;
                item.paymentTerms         = LAT_opp.LAT_MX_OrderPaymentPeriodReference__r.CodDefUsuario__c != null ? LAT_opp.LAT_MX_OrderPaymentPeriodReference__r.CodDefUsuario__c: LAT_opp.LAT_Account__r.Payment_Condition__r.CodDefUsuario__c;
                //item.percentualDiscount  = 0; // campo obligatorio
                priceCatalogueDetails.add(item);
            }
            LAT_MX_PriceCalculation.priceCatalogueHeaderOutput response;

            try{

                LAT_MX_PriceCalculation.PriceCatalogueManagerPort calloutClient = new LAT_MX_PriceCalculation.PriceCatalogueManagerPort();
                response =
            calloutClient.getPriceCatalogue(
                                        orderType, 
                                        businessUnit,
                                        ediTransactionType,
                                        paymentTerm,
                                        priceCatalogueDetails,
                                        priceEffectiveDate,
                                        shipTo,
                                        soldTo,
                                        taxEffectiveDate, 
                                        countryCode);
            system.debug('Ernesto+++Answer+++++' + response);
            resp = String.valueOf(response);
            }catch(Exception e) {
                system.debug('Ernesto+++ Exception1' + e.getCause() + e.getStackTraceString());
                logAsRegistry.LAT_Account__c = LAT_opp.LAT_Account__c;
                logAsRegistry.LAT_OrderNumber__c = LAT_opp.LAT_NROrderJDE__c;
                logAsRegistry.LAT_Opportunity2__c = LAT_opp.Id;
                logAsRegistry.LAT_Country__c = string.valueOf(LAT_opp.LAT_Country__c);
                logAsRegistry.LAT_ReturnTime__c = system.now();
                try{ insert logAsRegistry; }catch(Exception e1){system.debug('Ernesto+++ Exception1' + e.getCause() + e.getStackTraceString());}
                
                debug.addTitle('Unexpected Error');
                debug.addData('Error', e.getMessage());
                return label.LAT_MX_WS02_00003;
                //LAT_MX_WS02_00003: Error inesperado en el envio a JDE. Contacte a su administrador de sistema
            }
        

            if(response == null){
                system.debug('Ernesto+++ Exception23123');
                return label.LAT_MX_WS02_00003;
                //LAT_MX_WS02_00003: Error inesperado en el envio a JDE. Contacte a su administrador de sistema
            
            }
            
            system.debug('Sigue+++');
            Map<String, LAT_MX_PriceCalculation.priceCatalogueDetailsOutput> mapItems = new Map<String, LAT_MX_PriceCalculation.priceCatalogueDetailsOutput>();
            if(response.priceCatalogueDetails != null) {
              for(LAT_MX_PriceCalculation.priceCatalogueDetailsOutput respItem: response.priceCatalogueDetails){
                system.debug('Sigue+++ForItems' + respItem);
                mapItems.put(String.ValueOf(respItem.secondItemNumber).trim(), respItem);
            }  
            }
            
            
            debug.addTitle('Response');
            debug.addData('mapItems+++', String.ValueOf(mapItems));
            system.debug('mapItems+++' + String.ValueOf(mapItems));
            system.debug('mapItemsKEYSET+++' + mapItems.keySet());
            
            //Se cargan los valores obtenidos en la interfaz a la lista que se envia al metodo
            for(LAT_OpportunityLineItem__c oli: oppItems){
                system.debug('oppSKU' + oli.LAT_SkuText__c);
                system.debug('oppSKUCONTAINSKEY' + mapItems.containsKey(oli.LAT_SkuText__c));
                if(mapItems.containsKey(oli.LAT_SkuText__c)){
                    system.debug('forLineitem+++' + String.ValueOf(oli));
                    oli.LAT_UnitPrice__c              = mapItems.get(oli.LAT_SkuText__c).unitPrice.setScale(4);
                    system.debug('theItemSkuMap+++' + mapItems.get(oli.LAT_SkuText__c));
                    oli.LAT_FormatField__c = Lat_Utils.generatePriceTableForLineItem(mapItems.get(oli.LAT_SkuText__c));

                    oli.lat_mx_iva__c = mapItems.get(oli.LAT_SkuText__c).amountTax.setScale(2);
                    oli.lat_mx_ieps__c = mapItems.get(oli.LAT_SkuText__c).amountExcise.setScale(2);
                    oli.LAT_MX_Total_Amount_Taxes__c = mapItems.get(oli.LAT_SkuText__c).amountTaxable.setScale(2) + mapItems.get(oli.LAT_SkuText__c).amountTax.setScale(2) + mapItems.get(oli.LAT_SkuText__c).amountExcise.setScale(2);
                }
            }

            return '';
    }

    Webservice static String LAT_PriceCalculation(String idSalesforce, List<LAT_OpportunityLineItem__c> oppItems){
        try{
            debug.addTitle('Input parameter');
            debug.addData('idSalesforce', idSalesforce);
            debug.addData('oppItems', String.ValueOf(oppItems));
            
            try{
                LAT_opp = [SELECT Id, LAT_Account__r.Owner.C_digo_JDE__c, LAT_Account__r.Client_code_AN8__c, LAT_ClientCodeAN8__c, LAT_Freight__c, LAT_DTDelivery__c, LAT_Account__r.Business_Unit_AR__r.CodDefUsuario__c, LAT_Type__c, LAT_Account__r.Payment_Condition__r.CodDefUsuario__c, LAT_MX_OrderPaymentPeriodReference__r.CodDefUsuario__c, LAT_JDEIntegrationReturn__c, LAT_Account__c, LAT_NROrderJDE__c, LAT_Country__c FROM LAT_Opportunity__c WHERE Id =: idSalesforce LIMIT 1];
            }catch(Exception e){}
             
            if(LAT_opp == null){
                return label.LAT_MX_WS02_00001;
                //LAT_MX_WS02_00001: El pedido no existe
            }
            
            if(oppItems.isEmpty()){
                return label.LAT_MX_WS02_00002;
                //LAT_MX_WS02_00002: El pedido no contiene productos
            }
            
            debug.addTitle('Header');
            debug.addData('Owner.C_digo_JDE__c', String.ValueOf(LAT_opp.LAT_Account__r.Owner.C_digo_JDE__c));
            debug.addData('Account.Client_code_AN8__c', String.ValueOf(LAT_opp.LAT_Account__r.Client_code_AN8__c));
            debug.addData('Freight__c', String.ValueOf(LAT_opp.LAT_Freight__c));
            debug.addData('Account.Business_Unit_AR__r.CodDefUsuario__c', String.ValueOf(LAT_opp.LAT_Account__r.Business_Unit_AR__r.CodDefUsuario__c));
            debug.addData('Type', String.ValueOf((LAT_opp.LAT_Type__c != null && LAT_opp.LAT_Type__c.length() > 2) ? LAT_opp.LAT_Type__c.substring(0,2) : LAT_opp.LAT_Type__c));
            
            //Mapeo de Header de pedido
            PriceCalculationTypes.PriceCalculationHeaderRequestType header = new PriceCalculationTypes.PriceCalculationHeaderRequestType();
            
            header.salesman     = LAT_opp.LAT_Account__r.Owner.C_digo_JDE__c;
            header.customerCode = Integer.valueOf(LAT_opp.LAT_Account__r.Client_code_AN8__c);
            header.freightType  = LAT_opp.LAT_Freight__c;
            header.businessUnit = LAT_opp.LAT_Account__r.Business_Unit_AR__r.CodDefUsuario__c;
            header.orderType    = (LAT_opp.LAT_Type__c != null && LAT_opp.LAT_Type__c.length() > 2) ? LAT_opp.LAT_Type__c.substring(0,2) : LAT_opp.LAT_Type__c;
            
            //Mapeo de los productos del pedido
            List<PriceCalculationTypes.PriceCalculationItemRequestType> items = new List<PriceCalculationTypes.PriceCalculationItemRequestType>();
            debug.addTitle('Items');
            for(LAT_OpportunityLineItem__c oppItem: oppItems){
                PriceCalculationTypes.PriceCalculationItemRequestType item = new PriceCalculationTypes.PriceCalculationItemRequestType();
                
                debug.addSubTitle('Item');
                debug.addData('LAT_SkuText__c', String.ValueOf(oppItem.LAT_SkuText__c));
                debug.addData('UOM_AR__c', String.ValueOf(oppItem.LAT_AR_UOM__c));
                debug.addData('Quantity', String.ValueOf(oppItem.LAT_Quantity__c));
                debug.addData('LAT_MX_OrderPaymentPeriodReference__r.CodDefUsuario__c', String.ValueOf(LAT_opp.LAT_MX_OrderPaymentPeriodReference__r.CodDefUsuario__c != null ? LAT_opp.LAT_MX_OrderPaymentPeriodReference__r.CodDefUsuario__c: LAT_opp.LAT_Account__r.Payment_Condition__r.CodDefUsuario__c));
                
                item.sku                 = oppItem.LAT_SkuText__c;
                item.salesUOM            = oppItem.LAT_AR_UOM__c;
                item.billedTotalQuantity = oppItem.LAT_Quantity__c;
                item.paymentTerm         = LAT_opp.LAT_MX_OrderPaymentPeriodReference__r.CodDefUsuario__c != null ? LAT_opp.LAT_MX_OrderPaymentPeriodReference__r.CodDefUsuario__c: LAT_opp.LAT_Account__r.Payment_Condition__r.CodDefUsuario__c;
                item.percentualDiscount  = 0; // campo obligatorio
                items.add(item);
            }
            
            //ejecuto la interfaz
            PriceCalculation.port request = new PriceCalculation.port();
            request.timeout_x = 120000;
            PriceCalculationTypes.PriceCalculationResponseType response;
            try{
                response = request.operation(getConnectionParameter('México'), header, items);
            }catch(Exception e){
            
                logAsRegistry.LAT_Account__c = LAT_opp.LAT_Account__c;
                logAsRegistry.LAT_OrderNumber__c = LAT_opp.LAT_NROrderJDE__c;
                logAsRegistry.LAT_Opportunity2__c = LAT_opp.Id;
                logAsRegistry.LAT_Country__c = string.valueOf(LAT_opp.LAT_Country__c);
                logAsRegistry.LAT_ReturnTime__c = system.now();
                try{insert logAsRegistry;}catch(Exception e1){}
                
                debug.addTitle('Unexpected Error');
                debug.addData('Error', e.getMessage());
                return label.LAT_MX_WS02_00003;
                //LAT_MX_WS02_00003: Error inesperado en el envio a JDE. Contacte a su administrador de sistema
            }
            
            if(response == null){
                return label.LAT_MX_WS02_00003;
                //LAT_MX_WS02_00003: Error inesperado en el envio a JDE. Contacte a su administrador de sistema
            }
            
            Map<String, PriceCalculationTypes.PriceCalculationItemResponseType> mapItems = new Map<String, PriceCalculationTypes.PriceCalculationItemResponseType>();
            for(PriceCalculationTypes.PriceCalculationItemResponseType respItem: response.item){
                mapItems.put(String.ValueOf(respItem.sku).trim(), respItem);
            }
            
            debug.addTitle('Response');
            debug.addData('mapItems', String.ValueOf(mapItems));
            
            //Se cargan los valores obtenidos en la interfaz a la lista que se envia al metodo
            for(LAT_OpportunityLineItem__c oli: oppItems){
                if(mapItems.containsKey(oli.LAT_SkuText__c)){ 
                    oli.LAT_UnitPrice__c              = mapItems.get(oli.LAT_SkuText__c).salesPriceValue;
                    oli.LAT_FormatField__c = Utils.decodeString(mapItems.get(oli.LAT_SkuText__c).priceComponents, false);


                }
            }
            
        }catch(Exception e){
            debug.addTitle('Unexpected Error');
            debug.addData('Error', e.getMessage());
            return label.LAT_MX_WS02_00003;
            //LAT_MX_WS02_00003: Error inesperado en el envio a JDE. Contacte a su administrador de sistema
        }
        
        return '';
    }
      
    public static PriceCalculationTypes.ClientInfoType getConnectionParameter(string country){
        PriceCalculationTypes.ClientInfoType connParms = new PriceCalculationTypes.ClientInfoType();
        CS001_JDEInterfaceCredentials__c cred = CS001_JDEInterfaceCredentials__c.getInstance(country);
        if(cred!=null){
            connParms.country      = cred.Country__c;
            connParms.remoteHostIP = cred.RemoteHostIP__c;
            connParms.system_x     = cred.System__c;
            connParms.systemUserID = cred.SystemUserID__c;
            connParms.time_x       = Datetime.now();
        }
        return connParms;
    }
}