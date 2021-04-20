@RestResource(urlMapping='/LAT_Rest_OpportunityFlex/*')
global with sharing class LAT_Rest_OpportunityFlex {

    public static final String SYNC_BALANCE_METHOD = 'initialSyncBalance';
    public static final String SYNC_PARAMS_METHOD = 'initialSyncParams';
    public static boolean shouldhaveException;
    public static Account acc;
    private static Boolean isFlexHeader;
    public static Map<String, List<SyncParam>> mapParamsByBrand;
    public static Map<Integer, List<SyncParam>> mapParamsByAccountId;
    public static Map<String, List<SyncParam>> mapParamsByChannel;
    public static Map<String, List<SyncParam>> mapParamsByRegion;
    public static List<SyncParam> defaultParams;
    public static Map<Id, LAT_Product__c> mapProdById;
    public static Map<String, Decimal> mapPriceBySku;
    public static Integer uuid;

    @HttpPost
    global static void process() {

        RestRequest req = RestContext.request;
        ServiceResponse res;

        LAT_OpportunityHandlerJSON pedido = (LAT_OpportunityHandlerJSON)System.JSON.deserialize(req.requestBody.toString(), LAT_OpportunityHandlerJSON.class);
        System.debug('Pedido : ' + pedido);
        System.debug('Pedido.account : ' + pedido.header.account);
        acc = [SELECT Id, Client_code_AN8__c, Business_Unit_AR__r.CodDefUsuario__c, Payment_Condition__r.CodDefUsuario__c, Regional__r.CodDefUsuario__c, LAT_Account__r.LAT_JDEZone__c FROM Account WHERE Id =:pedido.header.account LIMIT 1];
        //ServiceResponse res = calculateFlexAmount(pedido);
        try{
            res = processFlexOrder(pedido);
        } catch(Exception e){
            res = new LAT_Rest_OpportunityFlex.ServiceResponse(e.getMessage(), 'FLEX_Error', false);
            if(pedido.header.aquilaId != null && pedido.header.aquilaId != ''){
                LAT_IMM_Logs__c log = new LAT_IMM_Logs__c();     
                String mesasge = sendTransactionToAquila(pedido, mapProdById, log, true);
            }
        }
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody   = Blob.valueOf(JSON.serialize(res));
        if (res.success) {
            RestContext.response.statusCode     = 200;
        } else {
            RestContext.response.statusCode     = 400;
        }
    }

    @HttpPut
    global static void processPut() {

        RestRequest req = RestContext.request;
        ServiceResponse res;
        LAT_OpportunityHandlerJSON pedido = (LAT_OpportunityHandlerJSON)System.JSON.deserialize(req.requestBody.toString(), LAT_OpportunityHandlerJSON.class);
        System.debug('Pedido : ' + pedido);
        System.debug('Pedido.account : ' + pedido.header.account);
        acc = [SELECT Id, Client_code_AN8__c, Business_Unit_AR__r.CodDefUsuario__c, Payment_Condition__r.CodDefUsuario__c, Regional__r.CodDefUsuario__c, LAT_Account__r.LAT_JDEZone__c FROM Account WHERE Id =:pedido.header.account LIMIT 1];
        //ServiceResponse res = calculateFlexAmount(pedido);
        try{
            res = processFlexOrder(pedido);
        } catch(Exception e){
            res = new LAT_Rest_OpportunityFlex.ServiceResponse(e.getMessage(), 'FLEX_Error', false);
            if(pedido.header.aquilaId != null && pedido.header.aquilaId != ''){
                LAT_IMM_Logs__c log = new LAT_IMM_Logs__c();     
                String mesasge = sendTransactionToAquila(pedido, mapProdById, log, true);
            }
        }
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody   = Blob.valueOf(JSON.serialize(res));
        if (res.success) {
            RestContext.response.statusCode     = 200;
        } else {
            RestContext.response.statusCode     = 400;
        }
    }

    public static ServiceResponse processFlexOrder(LAT_OpportunityHandlerJSON pedido) {
        Set<Id> setProdIds = new Set<Id>();
        Boolean integrateToIMM = false;
        for(LAT_OpportunityHandlerJSON.Detail oppItem: pedido.detail) {
            oppItem.compassId = oppItem.Id;
            if(oppItem.isFlex) {
                pedido.header.isFlex = true;
                integrateToIMM = true;
                setProdIds.add(oppItem.product);
            }
        }
        pedido.header.flexApproveManager = pedido.header.flexApproveAreaManager = pedido.header.flexApproveRegionalManager = pedido.header.flexApproveCommercialDirector = false; 
        if(integrateToIMM) {       
            
            LAT_IMM_Logs__c log = new LAT_IMM_Logs__c(); 
            mapProdById = new Map<Id, LAT_Product__c>([SELECT Id, Name,LAT_ScheduleC__r.KeyBrand__r.Key__c FROM LAT_Product__c WHERE Id IN:setProdIds]);    
            String mesasge = sendTransactionToAquila(pedido, mapProdById, log);
            if(mesasge == 'OK'){
                calculateApprovals(pedido);
            } else {
                insert log;
                return  new ServiceResponse(mesasge, 'flex3Error', false);
            }
            insert log;
        }
        LAT_Opportunity__c newOpp = insertOpportunity(pedido);
        System.debug('%%%% NO HAY ERRORES, integrateToIMM ? '+integrateToIMM);
        return  new ServiceResponse(newOpp.Id);
    }

    public static void calculateApprovals(LAT_OpportunityHandlerJSON pedido){
        loadParamsMaps();
        for(LAT_OpportunityHandlerJSON.Detail oppItem: pedido.detail) { 
            if(oppItem.isFlex && oppItem.discount < 0) {
                if(!pedido.header.flexApproveCommercialDirector) {
                    SyncParam param = getParam(oppItem);
                    if(param == null) {
                        param = defaultParams[0];
                    }
                    System.debug('%%%%% param : ' + param);
                    if(param != null) {
                        if (oppItem.finalFlexDiscount*(-1) > param.minPercentCommercialDirector) {
                            pedido.header.flexApproveManager = pedido.header.flexApproveAreaManager = pedido.header.flexApproveRegionalManager = pedido.header.flexApproveCommercialDirector = true;
                            continue;
                        }
                        if (oppItem.finalFlexDiscount*(-1) > param.minPercentRegionalManager) {
                            pedido.header.flexApproveManager = pedido.header.flexApproveAreaManager = pedido.header.flexApproveRegionalManager = true;
                            continue;
                        }
                        if (oppItem.finalFlexDiscount*(-1) > param.minPercentManager) {
                            pedido.header.flexApproveManager = pedido.header.flexApproveAreaManager = true;
                            continue;
                        }	
                        if (oppItem.finalFlexDiscount*(-1) > param.minPercentExecutive) {
                            pedido.header.flexApproveManager = true;
                            continue;
                        }                 
                    }
                }
            }
        }
    }
    public static String sendTransactionToAquila(LAT_OpportunityHandlerJSON pedido, Map<Id, LAT_Product__c> mapProducts, LAT_IMM_Logs__c log){
        return sendTransactionToAquila(pedido, mapProducts, log, false);
    }
    public static String sendTransactionToAquila(LAT_OpportunityHandlerJSON pedido, Map<Id, LAT_Product__c> mapProducts, LAT_IMM_Logs__c log, Boolean isRollback){
        String codigoVendedor = '';
        Boolean useCompassId = true;
        if(pedido.header.Id.startsWith('aPW')){
            LAT_Opportunity__c opp = [SELECT OwnerId, LAT_OrderOrigin__c FROM LAT_Opportunity__c WHERE Id = :pedido.header.Id];
            User usuario = [SELECT C_digo_JDE__C FROM User WHERE Id =:opp.OwnerId];
            codigoVendedor = usuario.C_digo_JDE__C;
            if(opp.LAT_OrderOrigin__c == 'EDI') useCompassId = false;
        } else {
            User usuario = [SELECT C_digo_JDE__C FROM User WHERE Id =:UserInfo.getUserId()];
            codigoVendedor = usuario.C_digo_JDE__C;

        }
        if(Test.isRunningTest()){
            codigoVendedor = '12';
        }
        LAT_IMM_Operations__c operation = LAT_IMM_Operations__c.getInstance(LAT_Rest_PriceFlex_SyncParams.ADD_TRANSACTION_METHOD);
        TransactionBody pBody = new TransactionBody();
        pBody.header = new TransactionBodyHeader();
        pBody.header.idCRM = pedido.header.Id;
        pBody.header.idAgreement = pedido.header.agreementId == '0' ? null : pedido.header.agreementId;
        pBody.header.customerCode = String.ValueOf(acc.Client_code_AN8__c);
        pBody.header.salesRepCode = codigoVendedor;
        pBody.header.salesRegionCode = codigoVendedor.substring(0, 1);
        pBody.header.fundingTypeCode = pedido.header.fundingType == 'On Invoice' ? 'ON' : 'FX';
        pBody.header.typeERP = 'SO';
        pBody.header.idERP  = pedido.header.jdeOrderNumber;
        pBody.detail = new List<TransactionBodyDetail>();
        System.debug('useCompassId: ' + useCompassId);
        for(LAT_OpportunityHandlerJSON.Detail oppItem: pedido.detail){
            if(oppItem.discount != 0){
                TransactionBodyDetail line = new TransactionBodyDetail();
                line.skuCode = oppItem.productSKU;
                System.debug('useCompassId: ' + useCompassId);
                System.debug('oppItem.compassId: ' + oppItem.compassId);
                if(isRollback){
                    oppItem.flexAmount = oppItem.flexAmount * (-1);
                    oppItem.discount = oppItem.discount * (-1);
                }
                line.idCRMLine = useCompassId ? oppItem.compassId : oppItem.Id ;
                line.discountAmount = oppItem.flexAmount;
                line.keyBrand = mapProducts.get(oppItem.product).LAT_ScheduleC__r.KeyBrand__r.Key__c;
                line.transactionType = oppItem.discount > 0 ? 'E' : 'S';
                line.lineNumberERP = oppItem.lineNumberJDE;
                pBody.detail.add(line);
            }
                
        }
        System.debug('request body : ' + JSON.serialize(pBody));
        log.LAT_Request__c              = JSON.serialize(pBody);
        log.LAT_Service__c              = LAT_Rest_PriceFlex_SyncParams.ADD_TRANSACTION_METHOD;
        log.LAT_TimeStamp__c            = Datetime.now();

        String message = '';
        try {
             
            HttpResponse resp = LAT_Rest_PriceFlex_SyncParams.sentRequestGenericCaller(JSON.serialize(pBody), operation, String.valueOf(operation.LAT_Company__c.setScale(0)));
            System.debug('Response body: ' + resp.getBody());
            if(resp.getStatusCode() == 200){
                TransactionResponseBody res = (TransactionResponseBody)System.JSON.deserialize(resp.getBody(), TransactionResponseBody.class);
                if(res.header.validationStatusOrder == '3') {
                    pedido.header.aquilaId = log.LAT_IMM_Id__c   = res.header.idAquila;
                    log.LAT_Response__c = JSON.serialize(res);
                    message = 'OK';
                } else {
                    log.LAT_IMM_Id__c   = 'ERROR';
                    log.LAT_Response__c = JSON.serialize(res);
                    
                    for(TransactionResponseBodyDetail line : res.detail){
                        if(line.validationStatusLine == '2'){
                            message += line.validationMessage + '.\n';
                        }
                    }
                }
            } else {
                log.LAT_IMM_Id__c   = 'ERROR';
                log.LAT_Response__c = resp.getBody();
                message = resp.getBody();
            }
                
        } catch (Exception e) {
            log.LAT_IMM_Id__c   = 'ERROR';
            log.LAT_Response__c = e.getMessage() + ' || ' + e.getStackTraceString();
            message = e.getMessage() + ' || ' + e.getStackTraceString();
        } 
        return message;

    }

    public static void rollBackTransactionInAquila(String oppId){
        LAT_Opportunity__c opp = [SELECT Id,  Agreement_Id__c, LAT_Account__c, Funding_Type__c, LAT_NROrderJDE__c, (SELECT Id, LAT_NROrderLine__c, Compass_Id__c, LAT_Product__c, LAT_IsFlex__c, LAT_FlexAmount__c, LAT_OriginalFlexAmount__c, LAT_NisAmount__c, LAT_OriginalNisAmount__c, LAT_Sku__c, 
                                                LAT_Product__r.LAT_ScheduleC__r.KeyBrand__r.Key__c, LAT_IdIMM__c,
                                                LAT_Opportunity__r.LAT_Account__r.Client_code_an8__c, LAT_Opportunity__r.LAT_Account__r.Regional__r.CodDefUsuario__c,
                                                LAT_Opportunity__r.LAT_Account__r.LAT_Account__r.LAT_JDEZone__c, LAT_CdLineStatus__c, LAT_AR_Discount__c, LAT_FlexNeedsValidation__c, 
                                                LAT_CreatedFromJDE__c, LAT_OriginalUnitNisAmount__c, LAT_Quantity__c FROM OpportunityLineItems__r WHERE LAT_AR_Discount__c < 0 OR LAT_AR_Discount__c > 0) 
                                    FROM LAT_Opportunity__c WHERE Id =:oppId];
        
        acc = [SELECT Id, Client_code_AN8__c, Business_Unit_AR__r.CodDefUsuario__c, Payment_Condition__r.CodDefUsuario__c, Regional__r.CodDefUsuario__c, LAT_Account__r.LAT_JDEZone__c FROM Account WHERE Id =:opp.LAT_Account__c LIMIT 1];

        Set<Id> setProdIds = new Set<Id>();
        LAT_OpportunityHandlerJSON pedido = new LAT_OpportunityHandlerJSON();
        pedido.header = new LAT_OpportunityHandlerJSON.Header();
        pedido.header.Id = opp.Id;
        pedido.header.agreementId = opp.Agreement_Id__c;
        pedido.header.fundingType = opp.Funding_Type__c;
        pedido.header.jdeOrderNumber = opp.LAT_NROrderJDE__c;
        pedido.detail = new List<LAT_OpportunityHandlerJSON.Detail>();
        for(LAT_OpportunityLineItem__c oli : opp.OpportunityLineItems__r ){
            setProdIds.add(oli.LAT_Product__c);
            LAT_OpportunityHandlerJSON.Detail line = new LAT_OpportunityHandlerJSON.Detail();
            line.discount = oli.LAT_AR_Discount__c * (-1);
            line.productSKU = oli.LAT_Sku__c;
            line.Id = oli.Id;
            line.compassId = oli.Compass_Id__c;
            line.flexAmount = oli.LAT_FlexAmount__c * (-1);
            line.product = oli.LAT_Product__c;
            line.lineNumberJDE = oli.LAT_NROrderLine__c;
            pedido.detail.add(line);
        }

        Map<Id, LAT_Product__c> mapProdById = new Map<Id, LAT_Product__c>([SELECT Id, Name,LAT_ScheduleC__r.KeyBrand__r.Key__c FROM LAT_Product__c WHERE Id IN:setProdIds]);
        LAT_IMM_Logs__c log = new LAT_IMM_Logs__c();
        String res = sendTransactionToAquila(pedido, mapProdById, log);
        if(res ==  'OK'){
            opp.Aquila_Id__c = null;
            update opp;
        }
        insert log;

    }

    public class TransactionBody {
        TransactionBodyHeader header;
        List<TransactionBodyDetail> detail;
    }

    public class TransactionBodyHeader {
        String idCRM;
        String idERP;
        String typeERP;
        String idAgreement;
        String customerCode;
        String salesRepCode;
        String salesRegionCode;
        String fundingTypeCode;
    }

    public class TransactionBodyDetail {
        String skuCode;
        String lineNumberERP;
        String idCRMLine;
        String keyBrand;
        Decimal discountAmount;
        String transactionType;
    }

    public class TransactionResponseBody {
        TransactionResponseBodyHeader header;
        List<TransactionResponseBodyDetail> detail;
    }

    public class TransactionResponseBodyHeader {
        String idCRM;
        String idERP;
        String typeERP;
        String transactionType;
        String idAgreement;
        String customerCode;
        String salesRepCode;
        String salesRegionCode;
        String fundingTypeCode;
        String company;
        String idAquila;
        String validationStatusOrder;
    }

    public class TransactionResponseBodyDetail {
        String skuCode;
        String lineNumberERP;
        String idCRMLine;
        Decimal discountAmount;
        String keyBrand;
        String validationStatusLine;
        String validationMessage;
    }

    public class SyncBalanceReturn {
        public String regionCode;
        public String brandCode;
        public String executiveCode;
        public Decimal balanceAmount;
    }

    public class ServiceResponse {

        public ServiceResponse(LAT_OpportunityHandlerJSON pedido) {
            success = true;
            message = JSON.serialize(pedido);
        }

        public ServiceResponse(String pedido) {
            success = true;
            Id = pedido;
        }

        public ServiceResponse(String msg, Boolean bool) {
            success = bool;
            message = msg;
        }

        public ServiceResponse(String msg, String error, Boolean bool) {
            success = bool;
            message = msg;
            errorCode = error;
        }
        public String Id;
        public Boolean success;
        public String message;
        public String errorCode;
    }

    public static Map<String, Decimal> getBalance() {
        LAT_IMM_Operations__c operation = LAT_IMM_Operations__c.getInstance(SYNC_BALANCE_METHOD);
        HttpResponse resp = LAT_Rest_PriceFlex_SyncParams.sentRequestGenericCaller(null, operation, '?where[salesStrucCode]='+acc.LAT_Account__r.LAT_JDEZone__c);
        system.debug('response getBalance:' + String.valueOf(resp.getBody()));
        List<SyncBalanceReturn> balanceResp = (List<SyncBalanceReturn>)System.JSON.deserialize(resp.getBody(), List<SyncBalanceReturn>.class);

        Map<String, Decimal> mapSyncBalance = new Map<String, Decimal>();
        for(SyncBalanceReturn r : balanceResp) {
            mapSyncBalance.put(r.regionCode +'-'+r.brandCode +'-'+r.executiveCode, r.balanceAmount);
        }
        return mapSyncBalance;
    }

    public static LAT_IMM_Logs__c addTransaction(LAT_OpportunityHandlerJSON.Detail oli, Map<Id, LAT_Product__c> mapProducts) {
        LAT_IMM_Operations__c operation = LAT_IMM_Operations__c.getInstance(LAT_Rest_PriceFlex_SyncParams.ADD_TRANSACTION_METHOD);

        LAT_Rest_PriceFlex_SyncParams.TransactionBody pBody       = new LAT_Rest_PriceFlex_SyncParams.TransactionBody();
        pBody.company               = Integer.valueOf(operation.LAT_Company__c);
        pBody.regionCode            = acc.Regional__r.CodDefUsuario__c;
        //se comenta para las pruebas ya que el servicio retorna regon code not found para la regional de la account, en este caso es 4.
        //pBody.regionCode            = '123';
        pBody.executiveCode         = acc.LAT_Account__r.LAT_JDEZone__c;
        pBody.brandCode             = mapProducts.get(oli.product).LAT_ScheduleC__r.KeyBrand__r.Key__c;
        pBody.accountId             = Integer.valueOf(acc.Client_code_an8__c);
        //se comenta para las pruebas ya que el servicio retorna  Customer not found para la  account, que en este caso es 16451.
        //pBody.accountId             = 12345;
        pBody.skuId                 = oli.productSKU;
        pBody.transDate             = String.valueOf(Datetime.now());
        pBody.amount                = oli.flexAmount;
        pBody.transType             = 'S';
        pBody.transOpType           = (oli.flexAmount >= 0.00 )? 'C':'D';
        pBody.originalTransNumber   = String.valueOf(uuid);

        LAT_IMM_Logs__c log             = new LAT_IMM_Logs__c();
        
        log.LAT_Request__c              = JSON.serialize(pBody);
        log.LAT_Service__c              = LAT_Rest_PriceFlex_SyncParams.ADD_TRANSACTION_METHOD;
        log.LAT_LineStatus__c           = 'NEW LINE';
        log.LAT_OpportunityLineItem__c  = null;
        log.LAT_TimeStamp__c            = Datetime.now();
        log.LAT_Amount__c               = oli.flexAmount;
        log.LAT_uuid__c               	= String.valueOf(uuid);

        try {

            HttpResponse resp = LAT_Rest_PriceFlex_SyncParams.sentRequestGenericCaller(JSON.serialize(pBody), operation);
            LAT_Rest_PriceFlex_SyncParams.ResponseFromIMM res = (LAT_Rest_PriceFlex_SyncParams.ResponseFromIMM)System.JSON.deserialize(resp.getBody(), LAT_Rest_PriceFlex_SyncParams.ResponseFromIMM.class);
            if(res.idMovement != null) {
                log.LAT_IMM_Id__c   = res.idMovement;
                log.LAT_Response__c = JSON.serialize(res);
                oli.idImm           = res.idMovement;
            } else {
                log.LAT_IMM_Id__c   = 'ERROR';
                log.LAT_Response__c = JSON.serialize(res);
            }
        } catch (Exception e) {
            log.LAT_IMM_Id__c   = 'ERROR';
            log.LAT_Response__c = e.getMessage() + ' || ' + e.getStackTraceString();
        } 
        return log;
    }

    public static LAT_Opportunity__c insertOpportunity(LAT_OpportunityHandlerJSON pedido) {
        User usuario = [SELECT Id, ManagerId, Gerente_de_area__c, Gerente_regional__c FROM User WHERE Id = :UserInfo.getUserId()];

        LAT_Opportunity__c opp = new LAT_Opportunity__c();
        opp.Name                            = pedido.header.name;
        opp.CurrencyIsoCode                 = 'BRL';
        opp.LAT_Account__c                  = pedido.header.account;
        opp.LAT_NRCustomerOrder__c          = pedido.header.customerOrderNr;
        opp.LAT_DSMessage1__c               = pedido.header.message1;
        opp.LAT_DSMessage2__c               = pedido.header.message2;
        opp.LAT_OrderOrigin__c              = 'APP';
        opp.LAT_Type__c                     = pedido.header.type_Z;
        opp.LAT_StageName__c                = pedido.header.stage;
        opp.LAT_CloseDate__c                = Date.valueOf(pedido.header.closeDate);
        if(pedido.header.isFlex != null) {
            opp.LAT_IsFlex__c                   = pedido.header.isFlex;
        }
        
        if(pedido.header.deliveryDate != null && pedido.header.deliveryDate != '') {
            opp.LAT_DTDelivery__c               = Date.valueOf(pedido.header.deliveryDate);
            opp.LAT_EstimatedDeliveryDate__c    = Date.valueOf(pedido.header.deliveryDate);
        }
        //opp.LAT_JDEOrderKey__c            = pedido.header.uuid;
        opp.LAT_FreightFormulaDisplay__c    	  = pedido.header.totalFreightPercent;
        opp.LAT_Pallet_Quantity__c          	  = pedido.header.totalPalletQuantity;
        opp.LAT_FlexManagerApprove__c          	  = pedido.header.flexApproveManager;
        opp.LAT_FlexAreaManagerApprove__c      	  = pedido.header.flexApproveAreaManager;
        opp.LAT_FlexRegionalManagerApprove__c     = pedido.header.flexApproveRegionalManager;
        opp.LAT_FlexCommercialDirectorApprove__c  = pedido.header.flexApproveCommercialDirector;
        opp.LAT_FlexJustification__c		 	  = pedido.header.flexJustification;
        opp.LAT_AreaManagerApprover__c            = usuario.Gerente_de_area__c;
        opp.LAT_ManagerApprover__c                = usuario.ManagerId;
        opp.LAT_RegionalManagerApprover__c        = usuario.Gerente_regional__c;
        opp.Agreement_Id__c        = pedido.header.agreementId;
        opp.Funding_Type__c        = pedido.header.fundingType;
        opp.Aquila_Id__c        = pedido.header.aquilaId;
        if(pedido.header.Id.startsWith('aPW')){
            opp.Id = pedido.header.Id;
            opp.RecordTypeId = RecordTypeForTest.getRecType( 'LAT_Opportunity__c','Nova_oportunidade');
        } 
        upsert opp;

        List<LAT_OpportunityLineItem__c> lines = new List<LAT_OpportunityLineItem__c>();
        Set<Id> idsFound = new Set<Id>();
        for (LAT_OpportunityHandlerJSON.Detail oppItem: pedido.detail) {
            LAT_OpportunityLineItem__c line = new LAT_OpportunityLineItem__c();
            line.LAT_PaymentCondition__c        = oppItem.paymentCondition;
            line.LAT_SkuText__c                 = oppItem.productSKU;
            line.LAT_UnitCode__c                = oppItem.measurementUnit;
            line.LAT_AR_Discount__c             = oppItem.discount;
            line.LAT_Quantity__c                = oppItem.quantity;
            line.LAT_UnitPrice__c               = oppItem.unitPrice;
            line.LAT_Product__c                 = oppItem.PriceBookEntryId;
            line.LAT_PercentualOfBonus__c       = oppItem.percentualBonus;
            line.LAT_FreightPercent__c          = oppItem.skuFreightPercent;
            line.LAT_Pallet_Total_Quantity__c   = oppItem.skuPalletQuantity;
            line.LAT_OriginalFlexAmount__c      = oppItem.flexAmount;
            line.LAT_OriginalNisAmount__c       = oppItem.baseNisAmount;
            line.LAT_FlexAmount__c              = oppItem.flexAmount;
            line.LAT_IdIMM__c					= oppItem.idImm;
            line.LAT_FlexFinalDiscount__c       = oppItem.finalFlexDiscount;
            line.LAT_Opportunity__c             = opp.Id;
            line.LAT_IsFlex__c                  = oppItem.isFlex;
            if(oppItem.Id.startsWith('aPV')) {
                line.Id = oppItem.Id;
                idsFound.add(oppItem.Id);
            } else {
                line.Compass_Id__c = oppItem.Id;
            }
            lines.add(line);
        } 

        if(idsFound.size() > 0) {
            List<LAT_OpportunityLineItem__c> toDelete = [SELECT Id FROM LAT_OpportunityLineItem__c WHERE Id NOT IN :idsFound AND LAT_Opportunity__c = :opp.Id ];
            if(toDelete.size() > 0) delete toDelete;
        }

        if(lines.size() > 0) {
            upsert lines;
        }

        

        return opp;
    }

    public static void loadParamsMaps() {
    	LAT_IMM_Operations__c operation = LAT_IMM_Operations__c.getInstance(SYNC_PARAMS_METHOD);
        System.debug('%%%%%% operation : ' + operation);
        System.debug('%%%%%% acc.LAT_Account__r.LAT_JDEZone__c : ' + acc.LAT_Account__r.LAT_JDEZone__c);
        HttpResponse resp = LAT_Rest_PriceFlex_SyncParams.sentRequestGenericCaller(null, operation, '?where[salesStrucCode]='+acc.LAT_Account__r.LAT_JDEZone__c);
        system.debug('response loadParamsMaps:' + String.valueOf(resp.getBody()));
        System.debug('%%%%%% operation : ' + operation);

        List<SyncParam> paramsResp = (List<SyncParam>)System.JSON.deserialize(resp.getBody(), List<SyncParam>.class);

        mapParamsByBrand = mapParamsByChannel = mapParamsByRegion = new  Map<String, List<SyncParam>>();
        defaultParams  = new List<SyncParam>();
        mapParamsByAccountId = new Map<Integer, List<SyncParam>>();

        for(SyncParam sp : paramsResp) {
        	if(sp.regionCode != null && sp.regionCode != '') {
        		if(mapParamsByRegion.get(sp.regionCode) == null) {
        			mapParamsByRegion.put(sp.regionCode, new List<SyncParam>());
        		}
        		mapParamsByRegion.get(sp.regionCode).add(sp);
        	}
        	if(sp.channelCode != null && sp.channelCode != '') {
        		if(mapParamsByChannel.get(sp.channelCode) == null) {
        			mapParamsByChannel.put(sp.channelCode, new List<SyncParam>());
        		}
        		mapParamsByChannel.get(sp.channelCode).add(sp);
        	}
        	if(sp.accountId != null) {
        		if(mapParamsByAccountId.get(sp.accountId) == null) {
        			mapParamsByAccountId.put(sp.accountId, new List<SyncParam>());
        		}
        		mapParamsByAccountId.get(sp.accountId).add(sp);
        	}
        	if(sp.brandCode != null && sp.brandCode != '') {
        		if(mapParamsByBrand.get(sp.brandCode) == null) {
        			mapParamsByBrand.put(sp.brandCode, new List<SyncParam>());
        		}
        		mapParamsByBrand.get(sp.brandCode).add(sp);
        	}

        	if((sp.executiveCode == null || sp.executiveCode == '') && (sp.brandCode == null || sp.brandCode == '') && (sp.accountId == null) 
        			&& (sp.channelCode == null || sp.channelCode == '') && (sp.regionCode == null || sp.regionCode == '')) {
        		defaultParams.add(sp);
        	}
        }
    }

    public static SyncParam getParam(LAT_OpportunityHandlerJSON.Detail oppItem) {
		SyncParam param;
		if(mapParamsByAccountId.get(Integer.valueOf(acc.Client_code_AN8__c)) != null) {
			for(SyncParam p : mapParamsByAccountId.get(Integer.valueOf(acc.Client_code_AN8__c))) {
				if(p.brandCode == mapProdById.get(oppItem.product).LAT_ScheduleC__r.KeyBrand__r.Key__c) {
					return p;
				}
			}
            for(SyncParam p : mapParamsByAccountId.get(Integer.valueOf(acc.Client_code_AN8__c))) {
                if(p.brandCode == null) {
                    return p;
                }
            }
		}
		if(mapParamsByRegion.get(acc.Regional__r.CodDefUsuario__c) != null) {
			for(SyncParam p : mapParamsByRegion.get(acc.Regional__r.CodDefUsuario__c)) {
				if(p.brandCode == mapProdById.get(oppItem.product).LAT_ScheduleC__r.KeyBrand__r.Key__c) {
					return p;
				}
			}
            for(SyncParam p : mapParamsByRegion.get(acc.Regional__r.CodDefUsuario__c)) {
                if(p.brandCode == null) {
                    return p;
                }
            }
		}
		if(mapParamsByChannel.get(acc.Client_code_AN8__c) != null) {
			for(SyncParam p : mapParamsByChannel.get(acc.Client_code_AN8__c)) {
				if(p.brandCode == mapProdById.get(oppItem.product).LAT_ScheduleC__r.KeyBrand__r.Key__c) {
					return p;
				}
			}
            for(SyncParam p : mapParamsByChannel.get(acc.Client_code_AN8__c)) {
                if(p.brandCode == null) {
                    return p;
                }
            }
		}
		if(mapParamsByBrand.get(mapProdById.get(oppItem.product).LAT_ScheduleC__r.KeyBrand__r.Key__c) != null) {
			for(SyncParam p : mapParamsByBrand.get(mapProdById.get(oppItem.product).LAT_ScheduleC__r.KeyBrand__r.Key__c)) {
				if((p.brandCode == null  || p.brandCode == '') && (p.regionCode == null || p.regionCode == '') && (p.channelCode == null || p.channelCode == '') &&(p.accountId == null)) {
					return p;
				}
			}
		}
		if(defaultParams.size() > 0) {
			return defaultParams[0];
    	} else {
    		return null;
    	}
    }

    public static String mockResponse() {
        String json = '{';
        json += '  \"header\": {';
        json += '    \"id\": \"58e7c7f4\",';
        json += '    \"owner\": null,';
        json += '    \"name\": \"B2W COMPANHIA GLOBAL DO VAREJO - 17/10/2018\",';
        json += '    \"account\": \"001D0000015iAB7IAM\",';
        json += '    \"customerOrderNr\": \"PRueba Javi #3 18/10.\",';
        json += '    \"accountAN8\": \"172811\",';
        json += '    \"businessUnit\": \"17\",';
        json += '    \"freighpetTy\": null,';
        json += '    \"message1\": null,';
        json += '    \"message2\": null,';
        json += '    \"flexJustification\": null,';
        json += '    \"lastItemModifiedDate\": \"2018-10-17T19:57:42.705Z\",';
        json += '    \"creationDateTime\": \"2018-10-17T19:57:42.705Z\",';
        json += '    \"jdeOrderNumber\": null,';
        json += '    \"source\": null,';
        json += '    \"type\": \"SO\",';
        json += '    \"type_Z\": \"SO\",';
        json += '    \"stage\": \"Mobile Order\",';
        json += '    \"closeDate\": \"2018-10-17T19:55:32.962Z\",';
        json += '    \"deliveryDate\": \"2018-10-17T03:00:00.000Z\",';
        json += '    \"sugestedDeliveryDate\": \"\",';
        json += '    \"totalAmmount\": 31881.360000000004,';
        json += '    \"totalBoxes\": null,';
        json += '    \"recordType\": null,';
        json += '    \"hasBackorder\": null,';
        json += '    \"creditLimitBalance\": null,';
        json += '    \"parentAccount\": null,';
        json += '    \"actionCode\": null,';
        json += '    \"LastModifiedDate\": null,';
        json += '    \"mxPaymentCondition\": \"a4yD0000000Ce63IAC\",';
        json += '    \"mxPurchaseOrderSince\": \"\",';
        json += '    \"mxPurchaseOrderUntil\": \"\",';
        json += '    \"mxCreditCollectionsStatus\": null,';
        json += '    \"mxLogisticsStatus\": null,';
        json += '    \"currency\": \"BRL\",';
        json += '    \"totalFreightPercent\": 3.0,';
        json += '    \"totalPalletQuantity\": 0.01,';
        json += '    \"marginalContribution\": null,';
        json += '    \"isFlex\": false';
        json += '  },';
        json += '  \"detail\": [';
        json += '    {';
        json += '      \"id\": \"e142\",';
        json += '      \"product\": \"aPZD0000000CaR7\",';
        json += '      \"productSKU\": \"146\",';
        json += '      \"PriceBookEntryId\": \"aPZD0000000CaR7\",';
        json += '      \"paymentCondition\": \"V00\",';
        json += '      \"measurementUnit\": \"CA\",';
        json += '      \"maxDiscount\": null,';
        json += '      \"quantity\": 1.0,';
        json += '      \"discount\": -7.0,';
        json += '      \"sendDicountToApproval\": false,';
        json += '      \"unitPrice\": 0.0,';
        json += '      \"totalPrice\": 18818.34,';
        json += '      \"bottlesPerBox\": \"12\",';
        json += '      \"lineStatus\": null,';
        json += '      \"statusDescription\": null,';
        json += '      \"retentionCode\": null,';
        json += '      \"backorder\": 0.0,';
        json += '      \"quantityBonus\": null,';
        json += '      \"percentualBonus\": null,';
        json += '      \"totalQuantity\": 0.0,';
        json += '      \"totalPriceBR\": 18818.34,';
        json += '      \"bottlePrice\": null,';
        json += '      \"actionCode\": null,';
        json += '      \"skuFreightPercentIndividual\": 0.18,';
        json += '      \"skuFreightPercent\": 1.6199999999999999,';
        json += '      \"skuPalletQuantity\": 0.0,';
        json += '      \"indexMarca\": null,';
        json += '      \"detailAmmountSummaryType\": null,';
        json += '      \"detailAmmountSummaryType_ID\": null,';
        json += '      \"isFlex\": true';
        json += '    },';
        json += '    {';
        json += '      \"id\": \"e142\",';
        json += '      \"product\": \"aPZD0000000CaR7\",';
        json += '      \"productSKU\": \"146\",';
        json += '      \"PriceBookEntryId\": \"aPZD0000000CaR7\",';
        json += '      \"paymentCondition\": \"V00\",';
        json += '      \"measurementUnit\": \"CA\",';
        json += '      \"maxDiscount\": null,';
        json += '      \"quantity\": 1.0,';
        json += '      \"discount\": -7.0,';
        json += '      \"sendDicountToApproval\": false,';
        json += '      \"unitPrice\": 0.0,';
        json += '      \"totalPrice\": 18818.34,';
        json += '      \"bottlesPerBox\": \"12\",';
        json += '      \"lineStatus\": null,';
        json += '      \"statusDescription\": null,';
        json += '      \"retentionCode\": null,';
        json += '      \"backorder\": 0.0,';
        json += '      \"quantityBonus\": null,';
        json += '      \"percentualBonus\": null,';
        json += '      \"totalQuantity\": 0.0,';
        json += '      \"totalPriceBR\": 18818.34,';
        json += '      \"bottlePrice\": null,';
        json += '      \"actionCode\": null,';
        json += '      \"skuFreightPercentIndividual\": 0.18,';
        json += '      \"skuFreightPercent\": 1.6199999999999999,';
        json += '      \"skuPalletQuantity\": 0.0,';
        json += '      \"indexMarca\": null,';
        json += '      \"detailAmmountSummaryType\": null,';
        json += '      \"detailAmmountSummaryType_ID\": null,';
        json += '      \"isFlex\": true';
        json += '    },';
        json += '    {';
        json += '      \"id\": \"e142\",';
        json += '      \"product\": \"aPZD0000000CaR7\",';
        json += '      \"productSKU\": \"146\",';
        json += '      \"PriceBookEntryId\": \"aPZD0000000CaR7\",';
        json += '      \"paymentCondition\": \"V00\",';
        json += '      \"measurementUnit\": \"CA\",';
        json += '      \"maxDiscount\": null,';
        json += '      \"quantity\": 1.0,';
        json += '      \"discount\": -7.0,';
        json += '      \"sendDicountToApproval\": false,';
        json += '      \"unitPrice\": 0.0,';
        json += '      \"totalPrice\": 18818.34,';
        json += '      \"bottlesPerBox\": \"12\",';
        json += '      \"lineStatus\": null,';
        json += '      \"statusDescription\": null,';
        json += '      \"retentionCode\": null,';
        json += '      \"backorder\": 0.0,';
        json += '      \"quantityBonus\": null,';
        json += '      \"percentualBonus\": null,';
        json += '      \"totalQuantity\": 0.0,';
        json += '      \"totalPriceBR\": 18818.34,';
        json += '      \"bottlePrice\": null,';
        json += '      \"actionCode\": null,';
        json += '      \"skuFreightPercentIndividual\": 0.18,';
        json += '      \"skuFreightPercent\": 1.6199999999999999,';
        json += '      \"skuPalletQuantity\": 0.0,';
        json += '      \"indexMarca\": null,';
        json += '      \"detailAmmountSummaryType\": null,';
        json += '      \"detailAmmountSummaryType_ID\": null,';
        json += '      \"isFlex\": true';
        json += '    },';
        json += '    {';
        json += '      \"id\": \"e142\",';
        json += '      \"product\": \"aPZD0000000CaR7\",';
        json += '      \"productSKU\": \"146\",';
        json += '      \"PriceBookEntryId\": \"aPZD0000000CaR7\",';
        json += '      \"paymentCondition\": \"V00\",';
        json += '      \"measurementUnit\": \"CA\",';
        json += '      \"maxDiscount\": null,';
        json += '      \"quantity\": 1.0,';
        json += '      \"discount\": -7.0,';
        json += '      \"sendDicountToApproval\": false,';
        json += '      \"unitPrice\": 0.0,';
        json += '      \"totalPrice\": 18818.34,';
        json += '      \"bottlesPerBox\": \"12\",';
        json += '      \"lineStatus\": null,';
        json += '      \"statusDescription\": null,';
        json += '      \"retentionCode\": null,';
        json += '      \"backorder\": 0.0,';
        json += '      \"quantityBonus\": null,';
        json += '      \"percentualBonus\": null,';
        json += '      \"totalQuantity\": 0.0,';
        json += '      \"totalPriceBR\": 18818.34,';
        json += '      \"bottlePrice\": null,';
        json += '      \"actionCode\": null,';
        json += '      \"skuFreightPercentIndividual\": 0.18,';
        json += '      \"skuFreightPercent\": 1.6199999999999999,';
        json += '      \"skuPalletQuantity\": 0.0,';
        json += '      \"indexMarca\": null,';
        json += '      \"detailAmmountSummaryType\": null,';
        json += '      \"detailAmmountSummaryType_ID\": null,';
        json += '      \"isFlex\": true';
        json += '    }';
        json += '  ]';
        json += '}';
        return json;
    }

    public static String mockResponseNotFlex() {
        String json = '{';
        json += '  \"header\": {';
        json += '    \"id\": \"58e7c7f4\",';
        json += '    \"owner\": null,';
        json += '    \"name\": \"B2W COMPANHIA GLOBAL DO VAREJO - 17/10/2018\",';
        json += '    \"account\": \"001D0000015iAB7IAM\",';
        json += '    \"customerOrderNr\": \"PRueba Javi #3 18/10.\",';
        json += '    \"accountAN8\": \"172811\",';
        json += '    \"businessUnit\": \"17\",';
        json += '    \"freighpetTy\": null,';
        json += '    \"message1\": null,';
        json += '    \"message2\": null,';
        json += '    \"flexJustification\": null,';
        json += '    \"lastItemModifiedDate\": \"2018-10-17T19:57:42.705Z\",';
        json += '    \"creationDateTime\": \"2018-10-17T19:57:42.705Z\",';
        json += '    \"jdeOrderNumber\": null,';
        json += '    \"source\": null,';
        json += '    \"type\": \"SO\",';
        json += '    \"type_Z\": \"SO\",';
        json += '    \"stage\": \"Mobile Order\",';
        json += '    \"closeDate\": \"2018-10-17T19:55:32.962Z\",';
        json += '    \"deliveryDate\": \"2018-10-17T03:00:00.000Z\",';
        json += '    \"sugestedDeliveryDate\": \"\",';
        json += '    \"totalAmmount\": 31881.360000000004,';
        json += '    \"totalBoxes\": null,';
        json += '    \"recordType\": null,';
        json += '    \"hasBackorder\": null,';
        json += '    \"creditLimitBalance\": null,';
        json += '    \"parentAccount\": null,';
        json += '    \"actionCode\": null,';
        json += '    \"LastModifiedDate\": null,';
        json += '    \"mxPaymentCondition\": \"a4yD0000000Ce63IAC\",';
        json += '    \"mxPurchaseOrderSince\": \"\",';
        json += '    \"mxPurchaseOrderUntil\": \"\",';
        json += '    \"mxCreditCollectionsStatus\": null,';
        json += '    \"mxLogisticsStatus\": null,';
        json += '    \"currency\": \"BRL\",';
        json += '    \"totalFreightPercent\": 3.0,';
        json += '    \"totalPalletQuantity\": 0.01,';
        json += '    \"marginalContribution\": null,';
        json += '    \"isFlex\": false';
        json += '  },';
        json += '  \"detail\": [';
        json += '    {';
        json += '      \"id\": \"e142\",';
        json += '      \"product\": \"aPZD0000000CaR7\",';
        json += '      \"productSKU\": \"146\",';
        json += '      \"PriceBookEntryId\": \"aPZD0000000CaR7\",';
        json += '      \"paymentCondition\": \"V00\",';
        json += '      \"measurementUnit\": \"CA\",';
        json += '      \"maxDiscount\": null,';
        json += '      \"quantity\": 1.0,';
        json += '      \"discount\": -7.0,';
        json += '      \"sendDicountToApproval\": false,';
        json += '      \"unitPrice\": 0.0,';
        json += '      \"totalPrice\": 18818.34,';
        json += '      \"bottlesPerBox\": \"12\",';
        json += '      \"lineStatus\": null,';
        json += '      \"statusDescription\": null,';
        json += '      \"retentionCode\": null,';
        json += '      \"backorder\": 0.0,';
        json += '      \"quantityBonus\": null,';
        json += '      \"percentualBonus\": null,';
        json += '      \"totalQuantity\": 0.0,';
        json += '      \"totalPriceBR\": 18818.34,';
        json += '      \"bottlePrice\": null,';
        json += '      \"actionCode\": null,';
        json += '      \"skuFreightPercentIndividual\": 0.18,';
        json += '      \"skuFreightPercent\": 1.6199999999999999,';
        json += '      \"skuPalletQuantity\": 0.0,';
        json += '      \"indexMarca\": null,';
        json += '      \"detailAmmountSummaryType\": null,';
        json += '      \"detailAmmountSummaryType_ID\": null,';
        json += '      \"isFlex\": false';
        json += '    },';
        json += '    {';
        json += '      \"id\": \"e142\",';
        json += '      \"product\": \"aPZD0000000CaR7\",';
        json += '      \"productSKU\": \"146\",';
        json += '      \"PriceBookEntryId\": \"aPZD0000000CaR7\",';
        json += '      \"paymentCondition\": \"V00\",';
        json += '      \"measurementUnit\": \"CA\",';
        json += '      \"maxDiscount\": null,';
        json += '      \"quantity\": 1.0,';
        json += '      \"discount\": -7.0,';
        json += '      \"sendDicountToApproval\": false,';
        json += '      \"unitPrice\": 0.0,';
        json += '      \"totalPrice\": 18818.34,';
        json += '      \"bottlesPerBox\": \"12\",';
        json += '      \"lineStatus\": null,';
        json += '      \"statusDescription\": null,';
        json += '      \"retentionCode\": null,';
        json += '      \"backorder\": 0.0,';
        json += '      \"quantityBonus\": null,';
        json += '      \"percentualBonus\": null,';
        json += '      \"totalQuantity\": 0.0,';
        json += '      \"totalPriceBR\": 18818.34,';
        json += '      \"bottlePrice\": null,';
        json += '      \"actionCode\": null,';
        json += '      \"skuFreightPercentIndividual\": 0.18,';
        json += '      \"skuFreightPercent\": 1.6199999999999999,';
        json += '      \"skuPalletQuantity\": 0.0,';
        json += '      \"indexMarca\": null,';
        json += '      \"detailAmmountSummaryType\": null,';
        json += '      \"detailAmmountSummaryType_ID\": null,';
        json += '      \"isFlex\": false';
        json += '    },';
        json += '    {';
        json += '      \"id\": \"e142\",';
        json += '      \"product\": \"aPZD0000000CaR7\",';
        json += '      \"productSKU\": \"146\",';
        json += '      \"PriceBookEntryId\": \"aPZD0000000CaR7\",';
        json += '      \"paymentCondition\": \"V00\",';
        json += '      \"measurementUnit\": \"CA\",';
        json += '      \"maxDiscount\": null,';
        json += '      \"quantity\": 1.0,';
        json += '      \"discount\": -7.0,';
        json += '      \"sendDicountToApproval\": false,';
        json += '      \"unitPrice\": 0.0,';
        json += '      \"totalPrice\": 18818.34,';
        json += '      \"bottlesPerBox\": \"12\",';
        json += '      \"lineStatus\": null,';
        json += '      \"statusDescription\": null,';
        json += '      \"retentionCode\": null,';
        json += '      \"backorder\": 0.0,';
        json += '      \"quantityBonus\": null,';
        json += '      \"percentualBonus\": null,';
        json += '      \"totalQuantity\": 0.0,';
        json += '      \"totalPriceBR\": 18818.34,';
        json += '      \"bottlePrice\": null,';
        json += '      \"actionCode\": null,';
        json += '      \"skuFreightPercentIndividual\": 0.18,';
        json += '      \"skuFreightPercent\": 1.6199999999999999,';
        json += '      \"skuPalletQuantity\": 0.0,';
        json += '      \"indexMarca\": null,';
        json += '      \"detailAmmountSummaryType\": null,';
        json += '      \"detailAmmountSummaryType_ID\": null,';
        json += '      \"isFlex\": false';
        json += '    },';
        json += '    {';
        json += '      \"id\": \"e142\",';
        json += '      \"product\": \"aPZD0000000CaR7\",';
        json += '      \"productSKU\": \"146\",';
        json += '      \"PriceBookEntryId\": \"aPZD0000000CaR7\",';
        json += '      \"paymentCondition\": \"V00\",';
        json += '      \"measurementUnit\": \"CA\",';
        json += '      \"maxDiscount\": null,';
        json += '      \"quantity\": 1.0,';
        json += '      \"discount\": -7.0,';
        json += '      \"sendDicountToApproval\": false,';
        json += '      \"unitPrice\": 0.0,';
        json += '      \"totalPrice\": 18818.34,';
        json += '      \"bottlesPerBox\": \"12\",';
        json += '      \"lineStatus\": null,';
        json += '      \"statusDescription\": null,';
        json += '      \"retentionCode\": null,';
        json += '      \"backorder\": 0.0,';
        json += '      \"quantityBonus\": null,';
        json += '      \"percentualBonus\": null,';
        json += '      \"totalQuantity\": 0.0,';
        json += '      \"totalPriceBR\": 18818.34,';
        json += '      \"bottlePrice\": null,';
        json += '      \"actionCode\": null,';
        json += '      \"skuFreightPercentIndividual\": 0.18,';
        json += '      \"skuFreightPercent\": 1.6199999999999999,';
        json += '      \"skuPalletQuantity\": 0.0,';
        json += '      \"indexMarca\": null,';
        json += '      \"detailAmmountSummaryType\": null,';
        json += '      \"detailAmmountSummaryType_ID\": null,';
        json += '      \"isFlex\": false';
        json += '    }';
        json += '  ]';
        json += '}';
        return json;
    }
    public class SyncParam {
    	public String regionCode;
        public String channelCode;
        public Integer accountId;
        public String brandCode;
        public String executiveCode;
        public Decimal minPercentExecutive;
        public Decimal minPercentManager;
        public Decimal minPercentRegionalManager;
        public Decimal minPercentCommercialDirector;
        public Decimal maxPercent;
    }


}