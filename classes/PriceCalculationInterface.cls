global class PriceCalculationInterface{

/********************************************************************************
*
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 03/11/2016
*
********************************************************************************/


    public static LAT_Log__c logAsRegistry;
    public static LAT_DebugUtil debug;

    // test vars
    public static boolean shouldhaveError;
    public static boolean shouldhaveException;

    Webservice static String PriceCalculation(String idSalesforce, Opportunity oppParam, List<OpportunityLineItem> olisParam){

        Opportunity opp;
        logAsRegistry = new LAT_Log__c();
        String debugStr = '';

        logAsRegistry.LAT_Origin__c = 'PriceCalculationInterface';
        logAsRegistry.LAT_StartTime__c = system.now();
        logAsRegistry.LAT_Date__c = date.today();
        logAsRegistry.LAT_User__c = system.Userinfo.getUserId();

        Set< Id > setRecTypeOpp = new Set< Id >();
        setRecTypeOpp.add(Global_RecordTypeCache.getRtId('Opportunity' + 'Bloqueia_alteracao'));
        setRecTypeOpp.add(Global_RecordTypeCache.getRtId('Opportunity' + 'Bloqueia_alteracao_do_cabecalho') );
        setRecTypeOpp.add(Global_RecordTypeCache.getRtId('Opportunity' + 'Nova_oportunidade'));

        Boolean isById = true;

        try{
            List<Opportunity> oppL = [SELECT Owner.C_digo_JDE__c, DT_delivery__c, Freight__c, Account.Client_code_AN8__c,
                                      Integracao_Retorno_JDE__c, Account.Business_Unit__c, Type, AccountId, NR_order_JDE__c, Pais__c
                                      FROM Opportunity WHERE Id =: idSalesforce AND RecordTypeId =: setRecTypeOpp limit 1];

            if(!oppL.IsEmpty()){
                opp = oppL[0];
            }

            if(opp == null){
                opp = oppParam;
                isById = false;
            }

            if(opp == null){
                return 'Pedido não encontrado';
            }

            PriceCalculationTypes.PriceCalculationHeaderRequestType header = new PriceCalculationTypes.PriceCalculationHeaderRequestType();

            header.salesman = '0';
            header.customerCode = Integer.valueOf(opp.Account.Client_code_AN8__c);
            header.promisedDate = opp.DT_delivery__c < date.today() ? date.today() : opp.DT_delivery__c;
            if(opp.Freight__c != null && opp.Freight__c.equalsIgnoreCase('FOB'))
                header.freightType = 'F';
            else
                header.freightType = '';
            header.businessUnit = Utils.getCodeFromUDC(opp.Account.Business_Unit__c);
            string oppType = opp.Type;
            if(oppType != null && oppType.length() > 2){
                header.orderType = oppType.substring(0,2);
            }else{
                header.orderType = 'SO';
            }

            debugStr = 'salesman: ' + header.salesman +' | customerCode: ' +header.customerCode+' | promisedDate: '+header.promisedDate+' | freightType: '+header.freightType+' | businessUnit: '+header.businessUnit + ' | orderType: ' + header.orderType;

            Map<String,OpportunityLineItem> mapItems = new Map<String,OpportunityLineItem>();

            PriceCalculationTypes.PriceCalculationItemRequestType item;
            List<OpportunityLineItem> listaItens = [SELECT Id, Quantity, LAT_PercentualBonus__c, QT_Bonus__c, LAT_UnitCode__c,
                                                    cd_unit_bonif__c, LAT_PaymentCondition__c, Discount, LAT_SkuText__c
                                                    FROM OpportunityLineItem WHERE OpportunityId=:idSalesforce AND cd_line_status__c<>'999'];

            List<PriceCalculationTypes.PriceCalculationItemRequestType> items = new List<PriceCalculationTypes.PriceCalculationItemRequestType>();

            if(listaItens.IsEmpty()){
                if(olisParam != null){
                    listaItens = olisParam;
                }
            }

            if(listaItens == null || listaItens.IsEmpty()){
                return 'Pedido não possui produtos';
            }

            for(OpportunityLineItem oppItem : listaItens){
                item = new PriceCalculationTypes.PriceCalculationItemRequestType();
                item.billedTotalQuantity = oppItem.Quantity;
                item.bonusPercentual = oppItem.LAT_PercentualBonus__c;
                item.bonusQuantity = Integer.valueOf( oppItem.QT_Bonus__c );
                item.paymentTerm = oppItem.LAT_PaymentCondition__c;
                if(oppItem.Discount != null){
                    item.percentualDiscount = oppItem.Discount;
                }else{
                    item.percentualDiscount = 0;
                }
                if(oppItem.LAT_UnitCode__c == null || oppItem.LAT_UnitCode__c.equalsIgnoreCase(''))
                  item.bonusUnit = 'CA';
                else
                  item.bonusUnit = String.valueOf(oppItem.LAT_UnitCode__c);
                item.salesUOM = item.bonusUnit;

                item.sku = oppItem.LAT_SkuText__c;
                items.add(item);
                mapItems.put(oppItem.LAT_SkuText__c,oppItem);

                debugStr +='=ITEM= | billedTotalQuantity: '+item.billedTotalQuantity+' | bonusPercentual: '+item.bonusPercentual+' | bonusQuantity: '+item.bonusQuantity+' | bonusUnit: '+item.bonusUnit
                +' | paymentTerm: '+ item.paymentTerm+' | percentualDiscount: '+item.percentualDiscount+' | salesUOM: '+item.salesUOM+' | item: '+item.sku + '\n';
            }

            PriceCalculation.port request = new PriceCalculation.port();
            request.timeout_x = 120000;
            PriceCalculationTypes.PriceCalculationResponseType response;

            response = request.operation( getConnectionParameter(), header, items );

            // creates a registry log
            logAsRegistry.LAT_Account__c = opp.AccountId;
            logAsRegistry.LAT_OrderNumber__c = opp.NR_order_JDE__c;
            logAsRegistry.LAT_Opportunity__c = opp.Id;
            logAsRegistry.LAT_Country__c = string.valueOf(opp.Pais__c);
            logAsRegistry.LAT_ReturnTime__c = system.now();

            try{insert logAsRegistry;}catch(exception e){}

            if(response == null) return 'Erro inesperado no envio para o JDE. Contate o administrador do sistema';

            opp.Account.Client_code_AN8__c = String.valueOf(response.header.customerCode);

            if(isById){
                update opp;
            }

            for(PriceCalculationTypes.PriceCalculationItemResponseType respItem : response.item){
                if(mapItems.containsKey(respItem.sku.trim())){
                    OpportunityLineItem oppItem = mapItems.get(respItem.sku.trim());
                    oppItem.Campo_de_formatacao__c = utils.decodeString(respItem.priceComponents, false);
                    oppItem.UnitPrice = respItem.salesPriceValue;
                }
            }

            if(isById){
                update listaItens;
            }

        }catch(Exception e){

            if(opp != null){
                // creates a registry log
                logAsRegistry.LAT_Account__c = opp.AccountId;
                logAsRegistry.LAT_OrderNumber__c = opp.NR_order_JDE__c;
                logAsRegistry.LAT_Country__c = string.valueOf(opp.Pais__c);
                logAsRegistry.LAT_ReturnTime__c = system.now();

                try{insert logAsRegistry;}catch(exception e1){}

                opp.Integracao_Retorno_JDE__c = debugStr+e.getMessage();
                if(isById){
                    update opp;
                }
            }
            return e.getMessage();
        } finally{
        }
        return '';
    }


    //MIGRATED 03/11/2016
    Webservice static String LAT_PriceCalculation(String idSalesforce, LAT_Opportunity__c oppParam, List<LAT_OpportunityLineItem__c> olisParam){
        System.debug('%%%%%%%% oppParam '+ oppParam + ' olisParam : ' + olisParam);
        if(oppParam!=null){
            System.debug('%%%%%%%% acc AN8 '+ oppParam.LAT_Account__r.Client_code_AN8__c );
        }
        LAT_Opportunity__c opp;
        logAsRegistry = new LAT_Log__c();
        String debugStr = '';

        logAsRegistry.LAT_Origin__c = 'PriceCalculationInterface';
        logAsRegistry.LAT_StartTime__c = system.now();
        logAsRegistry.LAT_Date__c = date.today();
        logAsRegistry.LAT_User__c = system.Userinfo.getUserId();

        Set< Id > setRecTypeOpp = new Set< Id >();
        setRecTypeOpp.add(Global_RecordTypeCache.getRtId('LAT_Opportunity__c' + 'Bloqueia_alteracao'));
        setRecTypeOpp.add(Global_RecordTypeCache.getRtId('LAT_Opportunity__c' + 'Bloqueia_alteracao_do_cabecalho') );
        setRecTypeOpp.add(Global_RecordTypeCache.getRtId('LAT_Opportunity__c' + 'Nova_oportunidade'));

        Boolean isById = true;

        try{
            List<LAT_Opportunity__c> oppL = [SELECT LAT_DTDelivery__c, LAT_Freight__c, LAT_Account__r.Client_code_AN8__c,
                                      LAT_JDEIntegrationReturn__c, LAT_Account__r.Business_Unit__c, LAT_Type__c, LAT_Account__c, LAT_NROrderJDE__c, LAT_Country__c
                                      FROM LAT_Opportunity__c WHERE Id =: idSalesforce AND RecordTypeId =: setRecTypeOpp limit 1];
            System.debug('%%%%%%%% setRecTypeOpp : '+ setRecTypeOpp);
            System.debug('%%%%%%%% idSalesforce : '+ idSalesforce);
            System.debug('%%%%%%%% en PriceCalculationInterface oppL '+ oppL);

            if(!oppL.IsEmpty()){
                opp = oppL[0];
            }

            if(opp == null){
                opp = oppParam;
                if(oppParam!=null)
                    idSalesforce = oppParam.Id;
                isById = false;
            }

            if(opp == null){
                return 'Pedido não encontrado';
            }
            // Check if it should use the old Price Calculation or the new Price Catalogue
            if (isNewPriceCalculation('Brasil')) {
                //NEW
                System.debug('%%%%% entramos en el nuevo Prica Catalogue');
                logAsRegistry = new LAT_Log__c();
                debug = new LAT_DebugUtil();
                String result = LAT_BR_NewPriceCalculation(idSalesforce, olisParam, isById);
                return result;
            }
            //OLD
            else {

                PriceCalculationTypes.PriceCalculationHeaderRequestType header = new PriceCalculationTypes.PriceCalculationHeaderRequestType();

                header.salesman = '0';
                header.customerCode = Integer.valueOf(opp.LAT_Account__r.Client_code_AN8__c);
                header.promisedDate = opp.LAT_DTDelivery__c < date.today() ? date.today() : opp.LAT_DTDelivery__c;
                if(opp.LAT_Freight__c != null && opp.LAT_Freight__c.equalsIgnoreCase('FOB'))
                    header.freightType = 'F';
                else
                    header.freightType = '';
                header.businessUnit = Utils.getCodeFromUDC(opp.LAT_Account__r.Business_Unit__c);
                string oppType = opp.LAT_Type__c;
                if(oppType != null && oppType.length() > 2){
                    header.orderType = oppType.substring(0,2);
                }else{
                    header.orderType = 'SO';
                }

                debugStr = 'salesman: ' + header.salesman +' | customerCode: ' +header.customerCode+' | promisedDate: '+header.promisedDate+' | freightType: '+header.freightType+' | businessUnit: '+header.businessUnit + ' | orderType: ' + header.orderType;

                Map<String,LAT_OpportunityLineItem__c> mapItems = new Map<String,LAT_OpportunityLineItem__c>();

                PriceCalculationTypes.PriceCalculationItemRequestType item;
                List<LAT_OpportunityLineItem__c> listaItens = [SELECT Id, LAT_Quantity__c, LAT_PercentualBonus__c, LAT_QTBonus__c, LAT_UnitCode__c,
                                                        LAT_CdUnitBonification__c, LAT_PaymentCondition__c, LAT_Discount__c, LAT_SkuText__c
                                                        FROM LAT_OpportunityLineItem__c WHERE LAT_Opportunity__c=:idSalesforce AND LAT_CdLineStatus__c<>'999'];

                List<PriceCalculationTypes.PriceCalculationItemRequestType> items = new List<PriceCalculationTypes.PriceCalculationItemRequestType>();

                if(listaItens.IsEmpty()){
                    if(olisParam != null){
                        listaItens = olisParam;
                    }
                }

                if(listaItens == null || listaItens.IsEmpty()){
                    return 'Pedido não possui produtos';
                }

                for(LAT_OpportunityLineItem__c oppItem : listaItens){
                    item = new PriceCalculationTypes.PriceCalculationItemRequestType();
                    item.billedTotalQuantity = oppItem.LAT_Quantity__c;
                    item.bonusPercentual = oppItem.LAT_PercentualBonus__c;
                    item.bonusQuantity = Integer.valueOf( oppItem.LAT_QTBonus__c );
                    item.paymentTerm = oppItem.LAT_PaymentCondition__c;
                    if(oppItem.LAT_Discount__c != null){
                        item.percentualDiscount = oppItem.LAT_Discount__c;
                    }else{
                        item.percentualDiscount = 0;
                    }
                    if(oppItem.LAT_UnitCode__c == null || oppItem.LAT_UnitCode__c.equalsIgnoreCase(''))
                      item.bonusUnit = 'CA';
                    else
                      item.bonusUnit = String.valueOf(oppItem.LAT_UnitCode__c);
                    item.salesUOM = item.bonusUnit;

                    item.sku = oppItem.LAT_SkuText__c;
                    items.add(item);
                    mapItems.put(oppItem.LAT_SkuText__c,oppItem);

                    debugStr +='=ITEM= | billedTotalQuantity: '+item.billedTotalQuantity+' | bonusPercentual: '+item.bonusPercentual+' | bonusQuantity: '+item.bonusQuantity+' | bonusUnit: '+item.bonusUnit
                    +' | paymentTerm: '+ item.paymentTerm+' | percentualDiscount: '+item.percentualDiscount+' | salesUOM: '+item.salesUOM+' | item: '+item.sku + '\n';
                }

                PriceCalculation.port request = new PriceCalculation.port();
                request.timeout_x = 120000;
                PriceCalculationTypes.PriceCalculationResponseType response;

                response = request.operation( getConnectionParameter(), header, items );

                // creates a registry log
                logAsRegistry.LAT_Account__c = opp.LAT_Account__c;
                logAsRegistry.LAT_OrderNumber__c = opp.LAT_NROrderJDE__c;
                logAsRegistry.LAT_Opportunity2__c = opp.Id;
                logAsRegistry.LAT_Country__c = string.valueOf(opp.LAT_Country__c);
                logAsRegistry.LAT_ReturnTime__c = system.now();

                //}catch(exception e){}

                if(response == null) return 'Erro inesperado no envio para o JDE. Contate o administrador do sistema';
                System.debug('%%%%%% response : ' + response);
                System.debug('%%%%%% isById : ' + isById);
                opp.LAT_Account__r.Client_code_AN8__c = String.valueOf(response.header.customerCode);

                if(isById){
                    update opp;
                    upsert logAsRegistry;
                }

                for(PriceCalculationTypes.PriceCalculationItemResponseType respItem : response.item){
                    if(mapItems.containsKey(respItem.sku.trim())){
                        LAT_OpportunityLineItem__c oppItem = mapItems.get(respItem.sku.trim());
                        oppItem.LAT_FormatField__c = utils.decodeString(respItem.priceComponents, false);
                        oppItem.LAT_UnitPrice__c = respItem.salesPriceValue;
                        System.debug('%%%% item : '+ respItem.salesPriceValue + ' SKU : '+ oppItem.LAT_SkuText__c);
                    }
                }

                if(isById){
                    upsert listaItens;
                    upsert logAsRegistry;
                }
            }

        }catch(Exception e){

            if(opp != null){
                // creates a registry log
                logAsRegistry.LAT_Account__c = opp.LAT_Account__c;
                logAsRegistry.LAT_OrderNumber__c = opp.LAT_NROrderJDE__c;
                logAsRegistry.LAT_Country__c = string.valueOf(opp.LAT_Country__c);
                logAsRegistry.LAT_ReturnTime__c = system.now();

                try{upsert logAsRegistry;}catch(exception e1){}

                opp.LAT_JDEIntegrationReturn__c = debugStr+e.getMessage();
                if(isById){
                    update opp;
                }
            }
            return e.getMessage();
        } finally{
        }
        return '';
    }

    public static Boolean isNewPriceCalculation(String countr) {
        CS001_JDEInterfaceCredentials__c cred = CS001_JDEInterfaceCredentials__c.getInstance('Brasil');
        return cred.Exec_new_Price_Calc__c;
    }

    public static PriceCalculationTypes.ClientInfoType getConnectionParameter(){
        PriceCalculationTypes.ClientInfoType connParms = new PriceCalculationTypes.ClientInfoType();
        CS001_JDEInterfaceCredentials__c cred = CS001_JDEInterfaceCredentials__c.getInstance('Brasil');
        if(cred!=null){
            connParms.country = cred.Country__c;
            connParms.remoteHostIP = cred.RemoteHostIP__c;
            connParms.system_x = cred.System__c;
            connParms.systemUserID = cred.SystemUserID__c;
            connParms.time_x=Datetime.now();
        }
        return connParms;
    }

    Webservice static String LAT_BR_NewPriceCalculation(String idSalesforce, List<LAT_OpportunityLineItem__c> oppItems, Boolean isById){
        String resp = '';

        LAT_Opportunity__c LAT_opp;
        // Removed by Martin
        // for (LAT_OpportunityLineItem__c opp : oppItems ) {
        //     System.debug('DETEALLE OPPLINEITEM : ' + opp.Id + ' |||' + opp);
        // }
        try{
            LAT_opp = [SELECT Id, LAT_Account__r.Client_code_AN8__c, LAT_ClientCodeAN8__c, LAT_Freight__c, LAT_DTDelivery__c, LAT_Account__r.Business_Unit_AR__r.CodDefUsuario__c, LAT_Type__c, LAT_Account__r.Payment_Condition__r.CodDefUsuario__c, LAT_MX_OrderPaymentPeriodReference__r.CodDefUsuario__c, LAT_JDEIntegrationReturn__c, LAT_Account__c, LAT_NROrderJDE__c, LAT_Country__c, LAT_Account__r.Parentid FROM LAT_Opportunity__c WHERE Id =: idSalesforce LIMIT 1];
        } catch(Exception e) {
            System.debug('Error NOT FOUND Opportunity. Trace : '+ e.getCause() + e.getStackTraceString());
        }


        if (LAT_opp == null) {
            return label.LAT_MX_WS02_00001;
            //LAT_MX_WS02_00001: El pedido no existe
        }
        List<LAT_OpportunityLineItem__c> listaItens = oppItems;
        if (listaItens == null || listaItens.IsEmpty()) {
            return label.LAT_MX_WS02_00002;
            //LAT_MX_WS02_00002: El pedido no contiene productos
        }

        debug.addTitle('Header');
        debug.setOrigin('LAT_BR_NewPriceCalculation');
        debug.addData('Account.Client_code_AN8__c', String.ValueOf(LAT_opp.LAT_Account__r.Client_code_AN8__c));
        debug.addData('Account.Business_Unit_AR__r.CodDefUsuario__c', String.ValueOf(LAT_opp.LAT_Account__r.Business_Unit_AR__r.CodDefUsuario__c));
        debug.addData('Type', String.ValueOf((LAT_opp.LAT_Type__c != null && LAT_opp.LAT_Type__c.length() > 2) ? LAT_opp.LAT_Type__c.substring(0,2) : LAT_opp.LAT_Type__c));

        //Mapeo de Header de pedido
        //PriceCalculationTypes.PriceCalculationHeaderRequestType header = new PriceCalculationTypes.PriceCalculationHeaderRequestType();
        LAT_BR_PriceCalculation.priceCatalogueHeaderInput header = new LAT_BR_PriceCalculation.priceCatalogueHeaderInput();

        String businessUnit                     = LAT_opp.LAT_Account__r.Business_Unit_AR__r.CodDefUsuario__c;
        String ediTransactionType               = '';
        Datetime priceEffectiveDate             = LAT_opp.LAT_DTDelivery__c < date.today() ? date.today() : LAT_opp.LAT_DTDelivery__c;
        String paymentTerm                      = listaItens.get(0).LAT_PaymentCondition__c;
        String countryCode                      = String.valueOf(LAT_opp.LAT_Country__c);
        Integer shipTo                          = Integer.valueOf(LAT_opp.LAT_Account__r.Client_code_AN8__c);//0;//Integer.valueOf(LAT_opp.LAT_Account__r.Client_code_AN8__c);null no funciona.
        Integer soldTo                          = Integer.valueOf(LAT_opp.LAT_Account__r.Client_code_AN8__c);
        Datetime taxEffectiveDate               = LAT_opp.LAT_DTDelivery__c < date.today() ? date.today() : LAT_opp.LAT_DTDelivery__c;
        String orderType                        = String.ValueOf((LAT_opp.LAT_Type__c != null && LAT_opp.LAT_Type__c.length() > 2) ? LAT_opp.LAT_Type__c.substring(0,2) : LAT_opp.LAT_Type__c);
        //Mapeo de los productos del pedido
        List<LAT_BR_PriceCalculation.priceCatalogueDetailsInput> priceCatalogueDetails = new List<LAT_BR_PriceCalculation.priceCatalogueDetailsInput>();
        for (LAT_OpportunityLineItem__c oppItem: listaItens) {
            LAT_BR_PriceCalculation.priceCatalogueDetailsInput item = new LAT_BR_PriceCalculation.priceCatalogueDetailsInput();

            debug.addSubTitle('Item');
            debug.addData('LAT_SkuText__c', String.ValueOf(oppItem.LAT_SkuText__c));
            debug.addData('Quantity', String.ValueOf(oppItem.LAT_Quantity__c));
            debug.addData('LAT_PaymentCondition__c', String.ValueOf(oppItem.LAT_PaymentCondition__c));

            item.secondItemNumber           = oppItem.LAT_SkuText__c;
            if (oppItem.LAT_UnitCode__c == null || oppItem.LAT_UnitCode__c.equalsIgnoreCase('')) {
                  item.unitOfMeasure        = 'CA';
            }
            else {
                  item.unitOfMeasure        = String.valueOf(oppItem.LAT_UnitCode__c);
            }
            if (countryCode == '5' || countryCode == '6')  {
                List<Account> accListParent = [SELECT Client_code_AN8__c FROM Account WHERE Id =:LAT_opp.LAT_Account__r.Parentid limit 1];
                if (accListParent.size() > 0 && LAT_opp.LAT_Country__c == 6) {
                    shipTo = Integer.valueOf(accListParent[0].Client_code_AN8__c);
                    soldTo = Integer.valueOf(accListParent[0].Client_code_AN8__c);
                }
                if (oppItem.LAT_AR_UOM__c != null){
                        item.unitOfMeasure = oppItem.LAT_AR_UOM__c;
                } else {
                    item.unitOfMeasure = '';
                }
                if (oppItem.LAT_AR_Discount__c != null) {
                    item.ratePercentCashDiscount = oppItem.LAT_AR_Discount__c;
                } else {
                    item.ratePercentCashDiscount = 0;
                }

            } else if (countryCode == '1') {
                    item.quantityFree               = oppItem.LAT_QTBonus__c;
            }
            item.quantityOrdered            = oppItem.LAT_Quantity__c;
            item.paymentTerms               = oppItem.LAT_PaymentCondition__c;

            priceCatalogueDetails.add(item);
        }
        LAT_BR_PriceCalculation.priceCatalogueHeaderOutput response;

        try {

            system.debug('isRunningTest +++' + Test.isRunningTest());
            system.debug('exception +++' + shouldhaveException);
            if (Test.isRunningTest() && shouldhaveException != null && shouldhaveException){
                response = getMockResponse();
            } else {
                LAT_BR_PriceCalculation.PriceCatalogueManagerPort calloutClient = new LAT_BR_PriceCalculation.PriceCatalogueManagerPort();
                response = calloutClient.getPriceCatalogue(
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
            }

            system.debug('Ernesto+++Answer+++++' + response);
            resp = String.valueOf(response);
        } catch(Exception e) {
            system.debug('Ernesto+++ Exception1' + e.getCause() + e.getStackTraceString());
            logAsRegistry.LAT_Account__c = LAT_opp.LAT_Account__c;
            logAsRegistry.LAT_OrderNumber__c = LAT_opp.LAT_NROrderJDE__c;
            logAsRegistry.LAT_Opportunity2__c = LAT_opp.Id;
            logAsRegistry.LAT_Country__c = string.valueOf(LAT_opp.LAT_Country__c);
            logAsRegistry.LAT_ReturnTime__c = system.now();
            try {
                insert logAsRegistry;
            } catch(Exception e1) {
                system.debug('Ernesto+++ Exception1' + e.getCause() + e.getStackTraceString());
            }

            debug.addTitle('Unexpected Error');
            debug.addData('Error', e.getMessage());
            debug.setResult(label.LAT_MX_WS02_00003);
            debug.insertDebug();

            return label.LAT_MX_WS02_00003;
            //LAT_MX_WS02_00003: Error inesperado en el envio a JDE. Contacte a su administrador de sistema
        }

        if (response == null) {
            system.debug('Ernesto+++ Exception23123');
            debug.setResult(label.LAT_MX_WS02_00003);
            debug.insertDebug();
            return label.LAT_MX_WS02_00003;
            //LAT_MX_WS02_00003: Error inesperado en el envio a JDE. Contacte a su administrador de sistema
        }

        system.debug('Sigue+++');
        // Chequeo si se el retorno contiene un error, en caso afirmativo hay que loguear el error y retornar.
        if (response.errorRecords != null && response.errorRecords.size() > 0) {
            system.debug('Ernesto+++ Error de Negocio');
            debug.addTitle('Business Error');
            String retorno = '';
            for (LAT_BR_PriceCalculation.errorRecords e : response.errorRecords) {
                debug.addData('Error Code ', e.errorCode);
                debug.addData('Description ', e.errorDescription);
                retorno =  e.errorDescription;

            }
            debug.insertDebug();
            return retorno;

        }

        Map<String, LAT_BR_PriceCalculation.priceCatalogueDetailsOutput> mapItems = new Map<String, LAT_BR_PriceCalculation.priceCatalogueDetailsOutput>();
        for (LAT_BR_PriceCalculation.priceCatalogueDetailsOutput respItem : response.priceCatalogueDetails) {
            system.debug('Sigue+++ForItems' + respItem);
            mapItems.put(String.ValueOf(respItem.secondItemNumber).trim(), respItem);
        }

        debug.addTitle('Response');
        debug.addData('mapItems+++', String.ValueOf(mapItems));
        //debug.insertDebug();
        system.debug('mapItems+++' + String.ValueOf(mapItems));
        system.debug('mapItems+++' + String.ValueOf(mapItems));
        system.debug('mapItemsKEYSET+++' + mapItems.keySet());

        //Se cargan los valores obtenidos en la interfaz a la lista que se envia al metodo
        for (LAT_OpportunityLineItem__c oli : listaItens) {
            system.debug('oppSKU' + oli.LAT_SkuText__c);
            system.debug('oppSKUCONTAINSKEY' + mapItems.containsKey(oli.LAT_SkuText__c));
            if (mapItems.containsKey(oli.LAT_SkuText__c)) {
                system.debug('forLineitem+++' + String.ValueOf(oli));
                oli.LAT_UnitPrice__c              = mapItems.get(oli.LAT_SkuText__c).unitPrice.setScale(2);
                oli.LAT_JDETotalDiscount__c       = getBaseDiscount(mapItems.get(oli.LAT_SkuText__c)).setScale(2);
                System.debug('%%%%%%%%%% descuento : ' + mapItems.get(oli.LAT_SkuText__c).ratePercentDiscountsAndCharges.setScale(2));
                System.debug('%%%%%%%%%% oli.LAT_JDETotalDiscount__c  : ' + oli.LAT_JDETotalDiscount__c );
                System.debug('%%%%%%%%%% isById  : ' + isById );
                system.debug('theItemSkuMap+++' + mapItems.get(oli.LAT_SkuText__c));

                oli.LAT_FormatField__c = Lat_Utils.generatePriceTableForLineItem(mapItems.get(oli.LAT_SkuText__c), countryCode);

                if(countryCode == '6' || countryCode == '5'){
                    oli.LAT_AR_Total_Descuentos__c = LAT_Utils.getTotalDiscount(mapItems.get(oli.LAT_SkuText__c));    
                }
                

            }
        }
        if (isById) {
            update LAT_opp;
            System.debug('%%%%%% listaItens antes de update : '+ listaItens);
            update listaItens;
            System.debug('%%%%%% listaItens despues de update : '+ listaItens);
        }

        return '';
    }

    public static Decimal getBaseDiscount(LAT_BR_PriceCalculation.priceCatalogueDetailsOutput item) {
        try {
            Decimal retorno = 0;
            Decimal unitPrice = item.unitPriceExclusiveDiscountsAndCharges.setScale(2);
            Decimal unitDiscount = 0;
            if (item.discountAndChargeDetails != null) {
                for (LAT_BR_PriceCalculation.discountAndChargeDetailsOutput d: item.discountAndChargeDetails ) {
                    if (d.discountOrChargeGroup.trim() == 'BASE' && d.discountOrChargeType.trim().equals('D')) {
                        unitDiscount = d.unitDiscountOrCharge.setScale(2);
                        continue;
                    }
                }
                retorno = unitDiscount/unitPrice * 100;
            }
            return retorno;
        } catch (Exception e) {
            System.debug('ERROR AL CALCULAR EL DESCUENTO BASE, SE RETORNA 0.');
            return 0;
        }
    }

    /**
     * Used for test scenarios
     *
     *LAT_BR_PriceCalculation.priceCatalogueDetailsOutput[] priceCatalogueDetails
     */
    public static LAT_BR_PriceCalculation.priceCatalogueHeaderOutput getMockResponse(){
        LAT_BR_PriceCalculation.priceCatalogueHeaderOutput response = new LAT_BR_PriceCalculation.priceCatalogueHeaderOutput();
        response.businessUnit = 'test';
        response.company = 'test';
        LAT_BR_PriceCalculation.priceCatalogueDetailsOutput test123 = new LAT_BR_PriceCalculation.priceCatalogueDetailsOutput();
        response.priceCatalogueDetails = new LAT_BR_PriceCalculation.priceCatalogueDetailsOutput[]{test123};
        response.priceCatalogueDetails[0].amountDiscountsAndCharges = 55;
        response.priceCatalogueDetails[0].amountExcise = 55;
        response.priceCatalogueDetails[0].amountExclusiveDiscountsAndCharges = 55;
        response.priceCatalogueDetails[0].amountGross = 55;
        response.priceCatalogueDetails[0].amountTax = 55;
        response.priceCatalogueDetails[0].amountTaxable = 55;
        response.priceCatalogueDetails[0].description1 = 'test';
        response.priceCatalogueDetails[0].description2= 'test';
        response.priceCatalogueDetails[0].exciseRate = 55;
        response.priceCatalogueDetails[0].itemNumberShort= 55;
        response.priceCatalogueDetails[0].ordinalNumber = 55;
        response.priceCatalogueDetails[0].paymentTerms = 'test';
        response.priceCatalogueDetails[0].quantityOrdered = 55;
        response.priceCatalogueDetails[0].quantityFree = 55;
        response.priceCatalogueDetails[0].ratePercentCashDiscount = 55;
        response.priceCatalogueDetails[0].ratePercentDiscountsAndCharges = 55;
        response.priceCatalogueDetails[0].secondItemNumber = 'test';
        response.priceCatalogueDetails[0].taxRate = 55;
        response.priceCatalogueDetails[0].unitPrice = 4;
        response.priceCatalogueDetails[0].unitPriceExclusiveDiscountsAndCharges= 4;
        response.priceCatalogueDetails[0].unitPriceGross =4;
        response.priceCatalogueDetails[0].unitofMeasure = 'ca';
        response.priceCatalogueDetails[0].paymentTerms = 'test';
        response.priceCatalogueDetails[0].quantityOrdered = 55;
        response.priceCatalogueDetails[0].quantityFree = 55;
        response.priceCatalogueDetails[0].ratePercentCashDiscount = 55;
        response.priceCatalogueDetails[0].ratePercentDiscountsAndCharges = 55;
        response.priceCatalogueDetails[0].secondItemNumber = 'test';
        response.priceCatalogueDetails[0].taxRate = 55;
        response.priceCatalogueDetails[0].unitPrice = 4;
        response.priceCatalogueDetails[0].unitPriceExclusiveDiscountsAndCharges= 4;
        response.priceCatalogueDetails[0].unitPriceGross =4;
        response.priceCatalogueDetails[0].unitofMeasure = 'ca';
        LAT_BR_PriceCalculation.discountAndChargeDetailsOutput discountAndChargeDetails = new LAT_BR_PriceCalculation.discountAndChargeDetailsOutput();
        discountAndChargeDetails.discountOrChargeGroup = 'BASE';
        discountAndChargeDetails.discountOrChargeType  = 'D';
        discountAndChargeDetails.discountOrChargeGroupDescription   = 'TEST';
        discountAndChargeDetails.discountOrChargeType              = 'D';
        discountAndChargeDetails.ratePercentDiscountsAndCharges     = 10;    
        discountAndChargeDetails.unitDiscountOrCharge               = 10;
        response.priceCatalogueDetails[0].discountAndChargeDetails = new List<LAT_BR_PriceCalculation.discountAndChargeDetailsOutput>{discountAndChargeDetails};
        response.shipTo = 5;
        response.soldTo = 5;
        response.taxArea = 'area';
        response.taxExplanation = 'test';
        response.errorRecords = new LAT_BR_PriceCalculation.errorRecords[]{new LAT_BR_PriceCalculation.errorRecords()};
        response.errorRecords[0].errorCode = '5';
        response.errorRecords[0].errorDescription = '5';
        return response;
    }


}