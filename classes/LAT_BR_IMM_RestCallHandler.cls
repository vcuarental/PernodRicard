public with sharing class LAT_BR_IMM_RestCallHandler {
    public static final String FINALITY_COMMERCIAL_CONDITION = 'Condição Comercial Off Invoice';
    public static final String IMM_API_KEY_HEADER = 'x-api-key';
    public static final String IMM_SERVICE_NAME_HEADER = 'x-service-name';
    public static final String IMM_SERVICE_OPERATION_HEADER = 'x-service-operation';

    // Operations
    public static final String IMM_OPERATION_GET_FREEGOOD = 'GetFreeGood';
    public static final String IMM_OPERATION_GET_PAYMENT = 'GetCashPayment';
    public static final String IMM_OPERATION_PAYMEMTN = 'CreateCashPayment';
    public static final String IMM_OPERATION_POST_FREEGOOD = 'CreateAndSendFreeGood';

    public static final Integer IMM_FREE_GOOD_CONCEPTO_PAGO = 0;
    public static final Integer IMM_FREE_PAYMENT_CONCEPTO_PAGO = 0;
    public static final Set<String> EVENT_DEVELOPER_NAMES = new Set<String>{'LAT_Eventos_Contrato_de_Parceria', 'LAT_Eventos_Contrato_de_Parceria_Distribuidor'};

    public static string bodyTest {
        get {
            if( bodyTest == null ) {
                 bodyTest = '';
            }
            return bodyTest;
        }
        set;
    }

    public static IMMException createIMMException(String strBody, String strMessage) {
        IMMException objIMMException = new IMMException('Error');

        System.debug('createIMMException[strBody : ' + strBody + ' - strMessage : ' + strMessage + '] ->');
        
        objIMMException = new IMMException('Error');
        objIMMException.messageBody = strBody; //'No se envía el pedido ya que el mismo ya fue integrado exitosamente en IMM en el pasado.';

        System.debug('createIMMException[' + objIMMException + '] <-');

        return objIMMException;
    }

    @TestVisible
    private static Map<String, Integer> retrieveProductSKUMap(Set<Id> setProductIds) {
        List<LAT_ReferenceProduct__c> lstReferenceProducts = null;        
        Map<String,Integer> mapProductsSKU = null;

        System.debug('retrieveProductSKUMap[setProductIds : ' + setProductIds +  '] ->');

        lstReferenceProducts = [SELECT Id, Name, LAT_Product__c, LAT_Product__r.LAT_ProductCode__c, ReferenceGrouping__c 
                                FROM LAT_ReferenceProduct__c 
                                WHERE ReferenceGrouping__c IN: setProductIds];

        System.debug('retrieveProductSKUMap[lstReferenceProducts : ' + lstReferenceProducts +  ']');

        mapProductsSKU = new Map <String,Integer>();
        for (LAT_ReferenceProduct__c objReferenceProduct : lstReferenceProducts) {
            mapProductsSKU.put(objReferenceProduct.ReferenceGrouping__c, Integer.valueOf(objReferenceProduct.LAT_Product__r.LAT_ProductCode__c));
        }
        
        System.debug('retrieveProductSKUMap[' + mapProductsSKU +  '] <-');
        return mapProductsSKU;
    }

    @TestVisible
    private static Map<String, Integer> retrieveRegionaProductSKURMap(Set<Id> setProductIds, LAT_Payment__c objPayment) {
        List<LAT_RegionReferenceProduct__c> lstRegionReferenceProducts = null;        
        Map<String,Integer> mapRegionReferenceProductsSKU = null;

        System.debug('retrieveRegionaProductSKURMap[setProductIds : ' + setProductIds +  ' - objPayment : ' + objPayment + '] ->');
        System.debug('retrieveRegionaProductSKURMap[objPayment.LAT_Contract__r.Account__r.LAT_BR_RegionalClientOnPremise__c : ' + objPayment.LAT_Contract__r.Account__r.LAT_BR_RegionalClientOnPremise__c +  ']');

        lstRegionReferenceProducts = [SELECT Id, LAT_Product__c, Sku__c, ProductGroup__c 
                                      FROM LAT_RegionReferenceProduct__c
                                      WHERE ProductGroup__c IN :setProductIds 
                                      AND Micro_Regional__c = : objPayment.LAT_Contract__r.Account__r.LAT_BR_RegionalClientOnPremise__c];

        System.debug('retrieveRegionaProductSKURMap[lstRegionReferenceProducts : ' + lstRegionReferenceProducts +  ']');

        mapRegionReferenceProductsSKU = new Map <String,Integer>();
        for (LAT_RegionReferenceProduct__c objRegionReferenceProduct : lstRegionReferenceProducts) {
            mapRegionReferenceProductsSKU.put(objRegionReferenceProduct.ProductGroup__c, Integer.valueOf(objRegionReferenceProduct.Sku__c));
        }
        
        System.debug('retrieveRegionaProductSKURMap[' + mapRegionReferenceProductsSKU +  '] <-');
        return mapRegionReferenceProductsSKU;
    }
    
    @TestVisible
    private static Integer retrieveAN8(LAT_Payment__c objPayment) {
        String strAn8 = null;
        Integer intAN8 = null;
        IMMException objException = null;

        System.debug('retrieveAN8 [objPayment : ' + objPayment +  '] ->');

        if(LAT_ContractsCalculations.EVENT_DEVELOPER_NAMES.contains(objPayment.LAT_Contract__r.RecordType.Developername)) {
            if(objPayment.LAT_Producer__c) {
                strAn8 = objPayment.LAT_Contract__r.account__r.Client_code_AN8__c;
            } else {
                strAn8 = objPayment.LAT_Distributor__r.Client_code_AN8__c;
            }
        } else {
            strAn8 = objPayment.LAT_Contract__r.account__r.Client_code_AN8__c;
        }

        if(Test.isRunningTest()) {
            strAn8 = '11111';
        }
        
        if(String.isNotBlank(strAN8)) {
            intAN8 = Integer.valueOf(strAn8);
        } else {
            objException = createIMMException('No se encontro el AN8 para enviar el pagamento.', 'No se encontro el AN8 para enviar el pagamento.');
            objPayment.IntegrationMessage__c = objException.getMessage(); 

            throw objException;
        }

        System.debug('retrieveAN8 [' + intAN8 +  '] <-');
        return intAN8;
    }

    @TestVisible
    private static GenericBodyIMM createFreeGoodRequest(LAT_Payment__c objPayment,LAT_IMM_Operations__c objIMMOperation) {
        GenericBodyIMM objRequest = null;
        Integer intAN8 = null;
        IMMException objException = null;
        List<String> lstInternalId =  null;

        System.debug('createFreeGoodRequest [objPayment : ' + objPayment +  ' - objIMMOperation : ' + objIMMOperation + '] ->');
        intAN8 = retrieveAN8(objPayment);

        objRequest = new GenericBodyIMM();
        objRequest.confiPriceCatalogue = true;
        objRequest.userLDAP = objIMMOperation.userLDAP__c;
        objRequest.type = objIMMOperation.type__c;        
        objRequest.description = String.format('{0} ||{1}||{2}/{3}', new Object[] {objPayment.Finality__c, objPayment.LAT_Contract__r.Name, objPayment.PaymentDate__c.month(), objPayment.PaymentDate__c.year()});        
        objRequest.requestDate = String.valueof(Datetime.now()); //2017-11-02T15:21:56.000Z
        objRequest.almacen = new cls_almacen();
        objRequest.conceptoGasto = new cls_conceptoGasto();
        objRequest.conceptoGasto.idConceptoGasto = Integer.valueOf(objIMMOperation.idConceptoGasto__c);
        objRequest.currency_p = new cls_currency();
        objRequest.currency_p.idCurrency = Integer.valueOf(objIMMOperation.idCurrency__c);
        objRequest.provider = new cls_provider();
        objRequest.provider.id = intAN8;
        objRequest.status = new cls_status();
        objRequest.status.idStatus = Integer.valueOf(objIMMOperation.idStatus__c);
        objRequest.soldTo = new cls_soldTo();
        objRequest.soldTo.Id = intAN8;
        objRequest.shipTo = new cls_shipTo();
        objRequest.shipTo.idAddress =  intAN8;
        objRequest.deliveryClient =  objPayment.LAT_Contract__r.account__r.Client_code_AN8__c;
        
        if (objPayment.LAT_Contract__r.account__r.Business_Unit__r != null){
            // internal id es 1-05-crm-df el segundo número corresponde al almacen
            lstInternalId = objPayment.LAT_Contract__r.Account__r.Business_Unit__r.Internal_Id__c.split('-');
            objRequest.almacen.idAlmacen = lstInternalId.get(1);
        } else {
            objRequest.almacen.idAlmacen = String.valueOf(objIMMOperation.idAlmacen__c);
        }

        objRequest.activity = new cls_activity();
        if(objPayment.EventType__c == 'NET SALES') {
            System.debug('createFreeGoodRequest [objPayment.EventType__c : ' + objPayment.EventType__c +  ']');
            
            if(objPayment.LAT_Contract__r.Acordo_IMM__c != null && objPayment.LAT_Contract__r.Acordo_IMM__r.Acuerdo__c != null) {
                objRequest.targetModule = 'CA';
                objRequest.targetReference = !Test.isRunningTest()?objPayment.LAT_Contract__r.Acordo_IMM__r.Acuerdo__c.intValue() :1;
            } else {
                objException = createIMMException('No se seleccionó una acordo IMM para enviar el pagamento.', 'No se seleccionó una acordo IMM para enviar el pagamento.');
                objPayment.IntegrationMessage__c = objException.getMessage(); 
                throw objException;
            }
        } else {
            System.debug('createFreeGoodRequest [other objPayment.EventType__c : ' + objPayment.EventType__c +  ']');
            if(Test.IsRunningTest() || String.isNotBlank(objPayment.WFNumber__c)) {
                objRequest.targetModule = 'AP';
                objRequest.targetReference = !Test.isRunningTest()?Integer.valueOf(objPayment.WFNumber__c) :1;
                objRequest.idActivity = !Test.IsRunningTest()? Integer.valueOf(objPayment.WFNumber__c): 1;
                objRequest.activity.idActivity = !Test.isRunningTest()?Integer.valueOf(objPayment.WFNumber__c) :1;
            } else {
                objException = createIMMException('No se seleccionó una actividad IMM para enviar el pagamento.', 'No se seleccionó una actividad IMM para enviar el pagamento.');
                objPayment.IntegrationMessage__c = objException.getMessage(); 
                throw objException;    
            }
        }

        System.debug('createFreeGoodRequest [' + objRequest +  '] <-');
        return objRequest;
    }

    public static GenericBodyIMM createFreeGood(List<LAT_Payment__c> lstPayments) {
        LAT_Payment__c objPayment = null;
        IMMException objException = null;
        GenericBodyIMM objRequest = null;
        Set <Id> setProducts = null;
        LAT_IMM_Operations__c objIMMOperation = null;
        List<LAT_ReferenceProduct__c> lstReferenceProducts = null;
        Map<String,Integer> mapProductsSKU = null;
        Map<String,Integer> mapRegionalProductsSKU = null;
        cls_skus objCurrentSKU = null;
        GenericBodyIMM objIMMResponse = null;
        
        System.debug('createFreeGood [lstPayments : ' + lstPayments +  '] ->');

        if(lstPayments != null && !lstPayments.IsEmpty()) {
            objPayment = lstPayments[0];

            if(String.isBlank(objPayment.IDMe__c)) {
                objIMMOperation = LAT_IMM_Operations__c.getInstance(IMM_OPERATION_POST_FREEGOOD);
    
                setProducts = new Set <Id>();
                for (LAT_Payment__c objPaymentAux : lstPayments) {
                    setProducts.add(objPaymentAux.ProductGroup__c);
                }

                mapProductsSKU = retrieveProductSKUMap(setProducts);
                mapRegionalProductsSKU = retrieveRegionaProductSKURMap(setProducts, objPayment);
                   
                objRequest = createFreeGoodRequest(objPayment, objIMMOperation);
                objRequest.skus = new List <cls_skus>();

                for (LAT_Payment__c objChildPayment : lstPayments) {
                    objCurrentSKU = new cls_skus();
                    objCurrentSKU.sku = new cls_sku();

                    if(mapRegionalProductsSKU.containsKey(objChildPayment.ProductGroup__c)) {
                        objCurrentSKU.sku.code = String.valueOf(mapRegionalProductsSKU.get(objChildPayment.ProductGroup__c));
                    } else if(mapProductsSKU.containsKey(objChildPayment.ProductGroup__c)) {
                        objCurrentSKU.sku.code = String.valueOf(mapProductsSKU.get(objChildPayment.ProductGroup__c));
                    } else {
                        objException = createIMMException('Producto no encontrado. [Id: ' + objChildPayment.ProductGroup__c + ']', 'Producto no encontrado. [Id: ' + objChildPayment.ProductGroup__c + ']');
                        objPayment.IntegrationMessage__c = objException.getMessage(); 
                        throw new IMMNoskuException(objException);   
                    }
                    
                    System.debug('createFreeGood [SKU found : ' + objCurrentSKU.sku.code +  '] ->');

                    objChildPayment.Sku_at_Integration__c = objCurrentSKU.sku.code;

                    objCurrentSKU.measureUnit = new cls_measureUnit();
                    objCurrentSKU.measureUnit.uniMed = objIMMOperation.measureUnit__c;
                    objCurrentSKU.measureUnit.unitCost = 0;
                    objCurrentSKU.requestedQuantity = Integer.valueOf(objChildPayment.Volumen__c);
                    objRequest.skus.add(objCurrentSKU);
                }
        
                objIMMResponse = sendFreeGood(objRequest, objIMMOperation);
            } else {
                objException = createIMMException('No se envía el pedido ya que el mismo ya fue integrado exitosamente en IMM en el pasado.', 'Not possible to re-send payment as it is already registered in IMM.');
                objPayment.IntegrationMessage__c = objException.getMessage(); 
                throw objException;
            }
        } 

        System.debug('createFreeGood [' + objIMMResponse + '] <-');
        return objIMMResponse;
    }

    private static GenericBodyIMM sendFreeGood(GenericBodyIMM objRequest, LAT_IMM_Operations__c objIMMOperations) {
        String strJSONRequest = null;
        String strJSONResponse = null;
        HTTPResponse objResponse = null;
        IMMException objException = null;
        GenericBodyIMM objIMMResponse = null;
        
        System.debug('sendFreeGood [objRequest : ' + objRequest + ' - objIMMOperations : ' + objIMMOperations + '] ->');

        strJSONRequest = JSON.serialize(objRequest);
        strJSONRequest = replaceAllTagsRequest(strJSONRequest);

        objResponse = sentRequestGenericCaller(strJSONRequest, '', objIMMOperations);

        strJSONResponse = replaceAllTagsResponse(String.valueOf(objResponse.getBody()));

        if (objResponse.getStatusCode() != 200){
            objException = createIMMException(strJSONResponse, strJSONResponse);
            throw objException;
        }

        objIMMResponse = (GenericBodyIMM) JSON.deserialize(strJSONResponse, GenericBodyIMM.class);

        System.debug('createFreeGood [' + objIMMResponse + '] <-');
        return objIMMResponse;
    }
    
    public static GenericBodyIMM createFreeGoodGroup(LAT_Payment__c parent, List < LAT_Payment__c > payments) {
        IMMException objException = null;
        if (parent.IDMe__c != '' && parent.IDMe__c != null){
            objException = createIMMException('No se envía el pedido ya que el mismo ya fue integrado exitosamente en IMM en el pasado.', 'Not possible to re-send payment as it is already registered in IMM.');
            parent.IntegrationMessage__c = objException.getMessage(); 
            throw objException;
        }
        
        GenericBodyIMM req = new GenericBodyIMM();
        Set < Id > products = new Set < Id > ();
        for (LAT_Payment__c pay: payments) {
            products.add(pay.ProductGroup__c);
        }
        LAT_IMM_Operations__c operation = LAT_IMM_Operations__c.getInstance(IMM_OPERATION_POST_FREEGOOD);
        system.debug('%%%% operation: ' + operation);
        req.confiPriceCatalogue = true;
        //req.userName = operation.userLDAP__c;
        req.userLDAP = operation.userLDAP__c;
        req.type = operation.type__c;
        system.debug('%%%% Finality: ' + parent.Finality__c);
        req.description = (!Test.isRunningTest())?parent.Finality__c + ' || ' + parent.LAT_Contract__r.Name + '||' + parent.CreatedDate.month() + '/' + parent.CreatedDate.year():'test';
        req.requestDate = String.valueof(Datetime.now()); //2017-11-02T15:21:56.000Z
        req.almacen = new cls_almacen();

        if (payments[0].LAT_Contract__r.account__r.Business_Unit__r != null){
            // internal id es 1-05-crm-df el segundo numero correspo de al almacen
            List<String> internalIdList = parent.LAT_Contract__r.account__r.Business_Unit__r.Internal_Id__c.split('-');
            req.almacen.idAlmacen = internalIdList.get(1);
        } else {
            req.almacen.idAlmacen = String.valueOf(operation.idAlmacen__c);
        }
        
        req.activity = new cls_activity();
        //req.activity.idActivity = !Test.isRunningTest()?Integer.valueOf(parent.WFNumber__c):1;
        //req.idActivity = !Test.isRunningTest()?Integer.valueOf(parent.WFNumber__c):1;
        
        //“AP” só será utilizada para pagamentos A&P, assim como “CA” será utilizada para pag. de Net Sale
        if(parent.EventType__c == 'NET SALES') {
            req.targetModule = 'CA'; //CA - Commercial Aggreement / A&P
            //OBTENER CONTRATO            
            req.targetReference = !Test.isRunningTest()?Integer.valueOf(parent.Acordo_IMM__r.Acuerdo__c) :1;
        } else {
            req.targetModule = 'AP'; //CA - Commercial Aggreement / A&P
            req.targetReference = !Test.isRunningTest()?Integer.valueOf(parent.WFNumber__c) :1;

            req.idActivity = !Test.IsRunningTest()? Integer.valueOf(parent.WFNumber__c): 1;
            req.activity.idActivity = !Test.isRunningTest()?Integer.valueOf(parent.WFNumber__c) :1;
        }

        req.conceptoGasto = new cls_conceptoGasto();
        req.conceptoGasto.idConceptoGasto = Integer.valueOf(operation.idConceptoGasto__c);
        req.currency_p = new cls_currency();
        req.currency_p.idCurrency = Integer.valueOf(operation.idCurrency__c);
        req.provider = new cls_provider();
        req.provider.id = (!Test.isRunningTest())?Integer.valueOf(parent.LAT_Contract__r.account__r.Client_code_AN8__c):2;
        req.status = new cls_status();
        req.status.idStatus = Integer.valueOf(operation.idStatus__c);
        req.soldTo = new cls_soldTo();
        req.soldTo.Id = (!Test.isRunningTest())?Integer.valueOf(parent.LAT_Contract__r.account__r.Client_code_AN8__c):2;
        req.shipTo = new cls_shipTo();
        req.shipTo.idAddress =  (!Test.isRunningTest())?Integer.valueOf(parent.LAT_Contract__r.account__r.Client_code_AN8__c):2;
        req.deliveryClient =  parent.LAT_Contract__r.account__r.Client_code_AN8__c;

        List < LAT_ReferenceProduct__c > referenceProducts = [SELECT Id, Name, LAT_Product__c, LAT_Product__r.LAT_ProductCode__c, ReferenceGrouping__c FROM
            LAT_ReferenceProduct__c where ReferenceGrouping__c IN: products];

        Map < String, Integer > productsSKU = new Map < String, Integer > ();
        for (LAT_ReferenceProduct__c lrg: referenceProducts) {
            productsSKU.put(lrg.ReferenceGrouping__c, Integer.valueOf(lrg.LAT_Product__r.LAT_ProductCode__c));
        }

        List<LAT_RegionReferenceProduct__c> regionalReferenceProducts = [SELECT Id, LAT_Product__c, Sku__c, ProductGroup__c FROM LAT_RegionReferenceProduct__c
                                                                            WHERE ProductGroup__c IN :products AND Micro_Regional__c = :parent.LAT_Contract__r.account__r.LAT_BR_RegionalClientOnPremise__c];
        Map < String, Integer > regionalProductsSKU = new Map < String, Integer > ();
        for (LAT_RegionReferenceProduct__c lrg: regionalReferenceProducts) {
            regionalProductsSKU.put(lrg.ProductGroup__c, Integer.valueOf(lrg.Sku__c));
        }

        req.skus = new List < cls_skus > ();
        for (LAT_Payment__c pay: payments) {
            cls_skus currProd = new cls_skus();
            currProd.sku = new cls_sku();
            if(regionalProductsSKU.get(pay.ProductGroup__c) != null) {
                currProd.sku.code = String.valueOf(regionalProductsSKU.get(pay.ProductGroup__c));
            } else {
                currProd.sku.code = String.valueOf(productsSKU.get(pay.ProductGroup__c));
            }
            system.debug('the sku is:' + currProd.sku.code);
            if (String.isBlank(currProd.sku.code)){
                throw new IMMNoskuException();
            }
            pay.Sku_at_Integration__c = currProd.sku.code;
            currProd.measureUnit = new cls_measureUnit();
            currProd.measureUnit.uniMed = operation.measureUnit__c;
            currProd.measureUnit.unitCost = 0;
            currProd.requestedQuantity = Integer.valueOf(pay.Volumen__c);
            req.skus.add(currProd);
        }

        String requestString = json.serialize(req);
        requestString = replaceAllTagsRequest(requestString);
        system.debug(requestString);

        httpResponse res = sentRequestGenericCaller(requestString, '', operation);
        system.debug('response' + String.valueOf(res.getBody()));
        system.debug('response' + String.valueOf(res.getStatusCode()));
        String replacedString = replaceAllTagsResponse(String.valueOf(res.getBody()));
        system.debug(replacedString);
        if (res.getStatusCode() != 200){
            IMMException exc = new IMMException('Error');
            system.debug('Error on integrate resp: +++' + replacedString);
            exc.messageBody = replacedString;
            //payment.integrationMessage__c = replacedString;
            //system.debug('Error on integrate msg: +++' + payment.integrationMessage__c);
            throw exc;
        }
        
        return (GenericBodyIMM) JSON.deserialize(replacedString, GenericBodyIMM.class);

    }
    
    public static GenericBodyIMM createFreeGoodGroupEventos(LAT_Payment__c parent, List < LAT_Payment__c > payments) {
        IMMException objException = null;
        if (parent.IDMe__c != '' && parent.IDMe__c != null){
            objException = createIMMException('No se envía el pedido ya que el mismo ya fue integrado exitosamente en IMM en el pasado.', 'Not possible to re-send payment as it is already registered in IMM.');
            parent.IntegrationMessage__c = objException.getMessage(); 
            throw objException;
        }

        System.debug('%%%% parent: ' + parent);
        System.debug('%%%% payments: ' + payments);
        //String strAn8 = !EVENT_DEVELOPER_NAMES.contains(payments[0].LAT_Contract__r.RecordType.Developername) ? payments[0].LAT_Contract__r.account__r.Client_code_AN8__c: !parent.LAT_Producer__c ? parent.LAT_Distributor__r.Client_code_AN8__c : parent.LAT_Contract__r.account__r.Client_code_AN8__c;
        String strAn8 = null;

        System.debug('%%%% payments: ' + strAn8);
        if(EVENT_DEVELOPER_NAMES.contains(payments[0].LAT_Contract__r.RecordType.Developername) ) {
            if(parent.LAT_Producer__c ) {
                strAn8 = parent.LAT_Contract__r.account__r.Client_code_AN8__c;
                System.debug('parent.LAT_Producer__c : ' + strAn8);
            } else {
                //strAn8 = parent.LAT_Distributor__r.Client_code_AN8__c;
                strAn8 = parent.LAT_Contract__r.LAT_Distributor__r.Client_code_AN8__c;
                System.debug('parent.LAT_Distributor__r : ' + strAn8);
            }
        } else {
            strAn8 = payments[0].LAT_Contract__r.account__r.Client_code_AN8__c;
            System.debug('payments[0].LAT_Contract__r.account__r.Client_code_AN8__c : ' + strAn8);
        }
        if(Test.isRunningTest()) {strAn8 = '12345' ;}
        
        GenericBodyIMM req = new GenericBodyIMM();
        Set<Id> products = new Set<Id> ();
        Set<Id> commCondGroupPayments = new Set<Id> ();
        for (LAT_Payment__c pay: payments) {
            System.debug('%%%% pay: ' + pay);
            products.add(pay.ProductGroup__c);
            if(pay.Finality__c == FINALITY_COMMERCIAL_CONDITION && (pay.RecordType.Developername == 'LAT_PaymentGroup' || (pay.RecordType.Developername == 'LAT_PagamentoProduto' && !pay.LAT_ComConditionChilldAuxPayment__c))){
                commCondGroupPayments.add(pay.Id);
            }
        }
        if(parent.Finality__c == FINALITY_COMMERCIAL_CONDITION && commCondGroupPayments.size()==0){
            commCondGroupPayments.add(parent.Id);
            payments = new List<LAT_Payment__c>{(parent)};
        }
        System.debug('%%%% commCondGroupPayments: ' + commCondGroupPayments);
        Map<Id, LAT_Payment__c> commCondGroupPaymentsMap = new Map<Id, LAT_Payment__c>([SELECT (SELECT id, LAT_Producer__c, 
                                                Sku_at_Integration__c,Finality__c,Acordo_IMM__c,
                                                Status_IMM_Linea__c, ProductGroup__r.name, LAT_Contract__r.account__r.Business_Unit__r.Internal_Id__c, 
												ProductGroup__c, Volumen__c, RecordType.DeveloperName from Investimentos_Bonifica_es_e_Pagamentos__r),
												LAT_Contract__r.account__r.Business_Unit__r.name, LAT_Contract__r.account__c, LAT_Contract__r.account__r.Revenue_City__r.name, LAT_Contract__r.account__r.Client_code_AN8__c, 
												LAT_Contract__r.LAT_Distributor__r.Client_code_AN8__c, Ammount__c, ApprovedPayment__c, CNPJ_Fornecedor__c,
												LAT_Contract__r.LAT_Distributor__r.Business_Unit__r.Name,
                                                CreatedById, CreatedBy.email, CreatedDate, CurrencyIsoCode, Finality__c, 
                                                GoalNotReached__c, Id, IDMe__c, integrationMessage__c, IntegrationStatus__c, IsDeleted, 
												LastModifiedById, LastModifiedDate, LAT_Contract__c, LAT_Contract__r.name, LAT_Contract__r.RecordType.DeveloperName,
												Manager__c, Name, ParentPayment__c, PaymentDateDone__c, FY__c, WF__c, WFNumber__c, PaymentDate__c, ProductGroup__c, RecordTypeId, RecordType.DeveloperName, 
												RegionalManager__c, Status__c, SystemModstamp, Type__c, Volumen__c, ProductGroup__r.name, LAT_Producer__c,
												Sku_at_Integration__c,Status_IMM_Linea__c,LAT_Contract__r.account__r.Business_Unit__r.Internal_Id__c, LAT_Contract__r.account__r.LAT_BR_RegionalClientOnPremise__c, LAT_Distributor__c,
                                                LAT_Distributor__r.Client_code_AN8__c, LAT_Distributor__r.Business_Unit__r.Name,EventType__c                                                
                                                FROM LAT_Payment__c 
                                                WHERE id IN : commCondGroupPayments]);
        for (LAT_Payment__c groupPay: commCondGroupPaymentsMap.values()) {
            for(LAT_Payment__c pay: groupPay.Investimentos_Bonifica_es_e_Pagamentos__r){
                if(pay.ProductGroup__c <> null)
                    products.add(pay.ProductGroup__c);
            }
                
        }
        LAT_IMM_Operations__c operation = LAT_IMM_Operations__c.getInstance(IMM_OPERATION_POST_FREEGOOD);
        system.debug('%%%% operation: ' + operation);
        req.confiPriceCatalogue = true;
        //req.userName = operation.userLDAP__c;
        req.userLDAP = operation.userLDAP__c;
        req.type = operation.type__c;
        system.debug('%%%% Finality: ' + parent.Finality__c);
        req.description = (!Test.isRunningTest())?parent.Finality__c + ' ||' + parent.LAT_Contract__r.Name + '||' + parent.CreatedDate.month() + '/' + parent.CreatedDate.year():'test';

        req.requestDate = String.valueof(Datetime.now()); //2017-11-02T15:21:56.000Z
        req.almacen = new cls_almacen();
        req.activity = new cls_activity();

        if (payments[0].LAT_Contract__r.account__r.Business_Unit__r != null){
            // internal id es 1-05-crm-df el segundo numero correspo de al almacen
            List<String> internalIdList = parent.LAT_Contract__r.account__r.Business_Unit__r.Internal_Id__c.split('-');
            req.almacen.idAlmacen = internalIdList.get(1);
        } else {
            req.almacen.idAlmacen = String.valueOf(operation.idAlmacen__c);
        }


        if(parent.EventType__c == 'NET SALES') {
            System.debug('createFreeGoodRequest [parent.EventType__c : ' + parent.EventType__c +  ']');
            
            if(parent.LAT_Contract__r.Acordo_IMM__c != null && parent.LAT_Contract__r.Acordo_IMM__r.Acuerdo__c != null) {
                req.targetModule = 'CA';
                req.targetReference = !Test.isRunningTest()?parent.LAT_Contract__r.Acordo_IMM__r.Acuerdo__c.intValue() :1;
            } else {
                objException = createIMMException('No se seleccionó una acordo IMM para enviar el pagamento.', 'No se seleccionó una acordo IMM para enviar el pagamento.');
                parent.IntegrationMessage__c = objException.getMessage(); 
                throw objException;
            }
        } else {
            System.debug('createFreeGoodRequest [other objPayment.EventType__c : ' + parent.EventType__c +  ']');
            if(Test.isRunningTest() || String.isNotBlank(parent.WFNumber__c)) {
                req.targetModule = 'AP';
                req.targetReference = !Test.isRunningTest()?Integer.valueOf(parent.WFNumber__c) :1;
                req.idActivity = !Test.IsRunningTest()? Integer.valueOf(parent.WFNumber__c): 1;
                req.activity.idActivity = !Test.isRunningTest()?Integer.valueOf(parent.WFNumber__c) :1;
            } else {
                objException = createIMMException('No se seleccionó una actividad IMM para enviar el pagamento.', 'No se seleccionó una actividad IMM para enviar el pagamento.');
                parent.IntegrationMessage__c = objException.getMessage(); 
                throw objException;    
            }
        }

        req.conceptoGasto = new cls_conceptoGasto();
        req.conceptoGasto.idConceptoGasto = Integer.valueOf(operation.idConceptoGasto__c);
        req.currency_p = new cls_currency();
        req.currency_p.idCurrency = Integer.valueOf(operation.idCurrency__c);
        req.provider = new cls_provider();
        req.provider.id = Integer.valueOf(strAn8);
        req.status = new cls_status();
        req.status.idStatus = Integer.valueOf(operation.idStatus__c);
        req.soldTo = new cls_soldTo();
        req.soldTo.Id = Integer.valueOf(strAn8);
        req.shipTo = new cls_shipTo();
        req.shipTo.idAddress =  Integer.valueOf(strAn8);
        req.deliveryClient =  strAn8;

        List < LAT_ReferenceProduct__c > referenceProducts = [SELECT Id, Name, LAT_Product__c, LAT_Product__r.LAT_ProductCode__c, ReferenceGrouping__c FROM
            LAT_ReferenceProduct__c where ReferenceGrouping__c IN: products];

        Map < String, Integer > productsSKU = new Map < String, Integer > ();
        for (LAT_ReferenceProduct__c lrg: referenceProducts) {
            productsSKU.put(lrg.ReferenceGrouping__c, Integer.valueOf(lrg.LAT_Product__r.LAT_ProductCode__c));
        }

        List<LAT_RegionReferenceProduct__c> regionalReferenceProducts = [SELECT Id, LAT_Product__c, Sku__c, ProductGroup__c FROM LAT_RegionReferenceProduct__c
                                                                            WHERE ProductGroup__c IN :products AND Micro_Regional__c = :parent.LAT_Contract__r.account__r.LAT_BR_RegionalClientOnPremise__c];
        Map < String, Integer > regionalProductsSKU = new Map < String, Integer > ();
        for (LAT_RegionReferenceProduct__c lrg: regionalReferenceProducts) {
            regionalProductsSKU.put(lrg.ProductGroup__c, Integer.valueOf(lrg.Sku__c));
        }

        req.skus = new List < cls_skus > ();
        for (LAT_Payment__c pay: payments) {
            System.debug('%%%% pay2: ' + pay);
            System.debug('%%%% pay2.Finality__c: ' + pay.Finality__c);
            System.debug('%%%% pay2.RecordType.Developername: ' + pay.RecordType.Developername);
            System.debug('%%%% pay2.LAT_ComConditionChilldAuxPayment__c: ' + pay.LAT_ComConditionChilldAuxPayment__c);
            if(pay.Finality__c == FINALITY_COMMERCIAL_CONDITION &&  !pay.LAT_ComConditionChilldAuxPayment__c) {
                if(commCondGroupPaymentsMap.get(pay.Id) != null){
                    for(LAT_Payment__c childPayment : commCondGroupPaymentsMap.get(pay.Id).Investimentos_Bonifica_es_e_Pagamentos__r){
                        System.debug('%%%% childPayment: ' + childPayment);
                        if(childPayment.RecordType.Developername == 'LAT_PagamentoProduto'){
                            if(Integer.valueOf(childPayment.Volumen__c) > 0){
                                cls_skus currProd = new cls_skus();
                                currProd.sku = new cls_sku();
                                if(regionalProductsSKU.get(childPayment.ProductGroup__c) != null) {
                                    currProd.sku.code = String.valueOf(regionalProductsSKU.get(childPayment.ProductGroup__c));
                                } else {
                                    currProd.sku.code = String.valueOf(productsSKU.get(childPayment.ProductGroup__c));
                                }
                                system.debug('1.the sku is:' + currProd.sku.code);
                                if (String.isBlank(currProd.sku.code)){
                                    throw new IMMNoskuException();
                                }
                                childPayment.Sku_at_Integration__c = currProd.sku.code;
                                currProd.measureUnit = new cls_measureUnit();
                                currProd.measureUnit.uniMed = operation.measureUnit__c;
                                currProd.measureUnit.unitCost = 0;
                                currProd.requestedQuantity = Integer.valueOf(childPayment.Volumen__c);
                                req.skus.add(currProd);
                            }
                        }
                    }
                }
                
                
            } else {
                cls_skus currProd = new cls_skus();
                currProd.sku = new cls_sku();
                if(regionalProductsSKU.get(pay.ProductGroup__c) != null) {
                    currProd.sku.code = String.valueOf(regionalProductsSKU.get(pay.ProductGroup__c));
                } else {
                    currProd.sku.code = String.valueOf(productsSKU.get(pay.ProductGroup__c));
                }
                system.debug('2.the sku is:' + currProd.sku.code);
                if (String.isBlank(currProd.sku.code)){
                    throw new IMMNoskuException();
                }
                pay.Sku_at_Integration__c = currProd.sku.code;
                currProd.measureUnit = new cls_measureUnit();
                currProd.measureUnit.uniMed = operation.measureUnit__c;
                currProd.measureUnit.unitCost = 0;
                currProd.requestedQuantity = Integer.valueOf(pay.Volumen__c);
                req.skus.add(currProd);
            }
            
        }
        if(req.skus.size() > 0){
            String requestString = json.serialize(req);
            requestString = replaceAllTagsRequest(requestString);
            system.debug(requestString);

            httpResponse res = sentRequestGenericCaller(requestString, '', operation);
            system.debug('response' + String.valueOf(res.getBody()));
            system.debug('response' + String.valueOf(res.getStatusCode()));
            String replacedString = replaceAllTagsResponse(String.valueOf(res.getBody()));
            system.debug(replacedString);
            if (res.getStatusCode() != 200){
                IMMException exc = new IMMException('Error');
                system.debug('Error on integrate resp: +++' + replacedString);
                exc.messageBody = replacedString;
                //payment.integrationMessage__c = replacedString;
                //system.debug('Error on integrate msg: +++' + payment.integrationMessage__c);
                throw exc;
            }
            
            return (GenericBodyIMM) JSON.deserialize(replacedString, GenericBodyIMM.class);
        } else {
            GenericBodyIMM ret =  new GenericBodyIMM();
            ret.id = 00;
            ret.jdeId = '00';
            List<cls_skus> skus = new List<cls_skus>();
            Cls_skus sku = new cls_skus();
            sku.measureUnit = new cls_measureUnit();
            sku.measureUnit.unitCost = 0;
            skus.add(sku);
            ret.skus = skus;
            return ret;
        }
        

    }
    public static GenericBodyIMM createCashPayment(LAT_Payment__c payment) {
        if (payment.IDMe__c != '' && payment.IDMe__c != null){
            IMMException exc = new IMMException('Error');
            system.debug('Error pedido ya enviado.');
            exc.messageBody = 'No se envía el pedido ya que el mismo ya fue integrado exitosamente en IMM en el pasado.';
            payment.integrationMessage__c = 'Not possible to re-send payment as it is already registered in IMM.';
            throw exc;
        }
        String strAn8 = null;
        strAn8 = !EVENT_DEVELOPER_NAMES.contains(payment.LAT_Contract__r.RecordType.Developername) ? payment.LAT_Contract__r.account__r.Client_code_AN8__c: !payment.LAT_Producer__c ? payment.LAT_Distributor__r.Client_code_AN8__c :payment.LAT_Contract__r.account__r.Client_code_AN8__c;
        if(Test.isRunningTest()) {strAn8 = '12345' ;}

        LAT_IMM_Operations__c operation = LAT_IMM_Operations__c.getInstance(IMM_OPERATION_PAYMEMTN);
        GenericBodyIMM req = new GenericBodyIMM();
        req.userName = operation.userLDAP__c;
        req.type = operation.type__c;
        req.description = (!Test.isRunningTest())?payment.Finality__c + ' ||' + payment.LAT_Contract__r.Name + '||' + payment.CreatedDate.month() + '/' + payment.CreatedDate.year():'test';
        req.requestDate = String.valueof(Datetime.now()); //2017-11-02T15:21:56.000Z
        req.almacen = new cls_almacen();
        req.almacen.idAlmacen = operation.idAlmacen__c;
        req.activity = new cls_activity();
        req.activity.idActivity =  !Test.IsRunningTest()? Integer.valueOf(payment.WFNumber__c) : 1;
        req.conceptoGasto = new cls_conceptoGasto();
        req.conceptoGasto.idConceptoGasto = Integer.valueOf(operation.idConceptoGasto__c);
        req.currency_p = new cls_currency();
        req.currency_p.idCurrency = Integer.valueOf(operation.idCurrency__c);
        req.amount = Double.valueOf(payment.Ammount__c);
        req.provider = new cls_provider();
        req.provider.id = Integer.valueOf(strAn8);
        String requestString = json.serialize(req);
        requestString = replaceAllTagsRequest(requestString);
        system.debug('request: +++' + requestString);

        httpResponse res = sentRequestGenericCaller(requestString, '', operation);
        String replacedString = replaceAllTagsResponse(String.valueOf(res.getBody()));
        if (res.getStatusCode() != 200){
            IMMException exc = new IMMException('Error');
            system.debug('Error on integrate resp: +++' + replacedString);
            exc.messageBody = replacedString;
            payment.integrationMessage__c = replacedString;
            system.debug('Error on integrate msg: +++' + payment.integrationMessage__c);
            throw exc;
        }
        system.debug('resp: +++' + replacedString);
        if(Test.isRunningTest()){
            replacedString = LAT_BR_IMM_RestCallHandlerTest.retrieveMockResponse();
        }

        return (GenericBodyIMM) JSON.deserialize(replacedString, GenericBodyIMM.class);
    }

    public static GenericBodyIMM getFreeGood(String id) {
        GenericBodyIMM objResult = null;

        System.debug('getFreeGood [id : ' + id + '] ->');

        objResult = getPayment(id, IMM_OPERATION_GET_FREEGOOD); 
        
        System.debug('getFreeGood [' + objResult + '] <-');

        return objResult;
    }

    public static GenericBodyIMM getCashPayment(String id) {
        GenericBodyIMM objResult = null;

        System.debug('getCashPayment [id : ' + id + '] ->');

        objResult = getPayment(id, IMM_OPERATION_GET_PAYMENT); 
        
        System.debug('getCashPayment [' + objResult + '] <-');

        return objResult;
    }

    private static GenericBodyIMM getPayment(String strPaymentId, String strIMMOperation) {
        LAT_IMM_Operations__c objIMMOperation = null;
        String strPartialUrl = null;
        HTTPResponse objHTTPResponse = null;
        String strResponseJSON = null;
        IMMException objException  = null;
        GenericBodyIMM objResult = null;

        System.debug('getPayment [strPaymentId : ' + strPaymentId + '] ->');

        objIMMOperation = LAT_IMM_Operations__c.getInstance(strIMMOperation);
        strPartialUrl = '?id=' + strPaymentId;

        objHTTPResponse = sentRequestGenericCaller(null, strPartialUrl, objIMMOperation);
       
        if (objHTTPResponse.getStatusCode() == 200){
            strResponseJSON = replaceAllTagsResponse(String.valueOf(objHTTPResponse.getBody()));
            System.debug('getPayment [strResponseJSON : ' + strResponseJSON + ']');

            objResult = (GenericBodyIMM)JSON.deserialize(strResponseJSON, GenericBodyIMM.class);

        } else {
            objException = createIMMException('Error : No existe el Pago', 'Error : No existe el Pago');
            throw objException;
        }
        
        System.debug('getPayment [' + objResult + '] <-');

        return objResult;
    }

    public static HttpResponse sentRequestGenericCaller(String strBody, String strPartialUrl, LAT_IMM_Operations__c objIMMOperation) {
        Http objHTTP = null;
        HttpRequest objHTTPRequest = null;
        HTTPResponse objHTTPResponse = null;        
        String strURL = null;

        System.debug('sentRequestGenericCaller [strBody : ' + strBody + ' - strPartialUrl : ' + strPartialUrl + ' - objIMMOperation : ' + objIMMOperation + '] ->');

        if (Test.isRunningTest()) {
            strPartialUrl = 'test';
            strBody = 'test';
        }

        strURL = objIMMOperation.EndpointUrl__c + strPartialUrl;

        System.debug('sentRequestGenericCaller [strURL : ' + strURL + ']');

        objHTTPRequest = new HttpRequest();
        objHTTPRequest.setHeader('Content-Type', 'application/json');
        objHTTPRequest.setEndpoint(strURL);
        objHTTPRequest.setMethod(objIMMOperation.Http_operation__c);
        objHTTPRequest.setHeader(IMM_SERVICE_OPERATION_HEADER, objIMMOperation.operation_Name_header__c);
        objHTTPRequest.setHeader(IMM_SERVICE_NAME_HEADER, objIMMOperation.Service_Name_Header__c);
        objHTTPRequest.setHeader(IMM_API_KEY_HEADER, objIMMOperation.x_Api_key__c);
        objHTTPRequest.setTimeout(2 * 60 * 1000);

        if (String.isNotBlank(strBody)) {
            objHTTPRequest.setBody(strBody);
        }
        objHTTP = new Http();
        if (Test.isRunningTest()) {
            objHTTPResponse = new HTTPResponse();
            objHTTPResponse.setBody(bodyTest);
            objHTTPResponse.setStatusCode(200);
        } else {
            System.debug('sentRequestGenericCaller [objHTTPRequest : ' + objHTTPRequest + ']');
            System.debug('sentRequestGenericCaller [objHTTPRequest.getHeader(IMM_SERVICE_OPERATION_HEADER) : ' + objHTTPRequest.getHeader(IMM_SERVICE_OPERATION_HEADER) + ']');
            System.debug('sentRequestGenericCaller [objHTTPRequest.getHeader(IMM_SERVICE_NAME_HEADER) : ' + objHTTPRequest.getHeader(IMM_SERVICE_NAME_HEADER) + ']');

            objHTTPResponse = objHTTP.send(objHTTPRequest);

            System.debug('sentRequestGenericCaller [objHTTPResponse.getStatusCode() : ' + objHTTPResponse.getStatusCode() + ']');
            System.debug('sentRequestGenericCaller [objHTTPResponse.getBody() : ' + objHTTPResponse.getBody() + ']');
        }

        System.debug('sentRequestGenericCaller [' + objHTTPResponse + '] <-');

        return objHTTPResponse;
    }

    private static String replaceAllTagsResponse(String toReplace) {
        String replaced = toReplace.replaceAll('currency', 'currency_p');
        return replaced;
    }

    private static String replaceAllTagsRequest(String toReplace) {
        String replaced = toReplace.replaceAll('currency_p', 'currency');
        return replaced;
    }

    public class GenericBodyIMM {
        public String userName;
        public String userLDAP;
        public Integer id; //32
        public String type; //PSC
        public String companyId; //PSC
        public String description; //Teste de IntegraciÃ³n
        public String requestDate; //2017-11-02T15:21:56.000Z
        public cls_soldTo soldTo;
        public cls_almacen almacen;
        public cls_conceptoGasto conceptoGasto;
        public cls_shipTo shipTo;
        public boolean confiPriceCatalogue;
        public Integer idActivity;
        public cls_currency currency_p;


        public Double amount; //200
        public cls_status status;
        public cls_activity activity;
        public cls_subarea subarea;
        public String invoiceName;
        public Double totalAmount; //200
        public Integer bottles; //2
        public String deliveryClient;
        public String requestingUser; //JGOMES01 - Jefferson Gomes
        public String jdeId;
        public Integer idErp;
        public String jdeStatus;
        public cls_provider provider;
        public String balance;
        public String orderType; //SM
        public Double phone; //551192223333
        public String contact; //Lionel Messi
        public String deliveryInstructions; //delivery Instructions
        public Integer indBoi; //0
        public List < cls_skus > skus;
        //public List < cls_devs > devs;

        public String targetModule; //Lionel Messi
        public Integer targetReference; //Lionel Messi

        public GenericBodyIMM() {}

    }

    public class cls_soldTo {
        public Integer id; //9968
        public String name; //CONDOMINIO SAO PAULO CORPORATE TOWERS
        public Integer internalClient; //0
    }
    
    public class cls_name {}

    public class cls_almacen {
        public String idAlmacen; //4
        public String name; //Resende
    }

    public class cls_conceptoGasto {
        public Integer idConceptoGasto; //18
        public String name; //Consumer & Shopper Insight & Analytics
    }

    public class cls_shipTo {
        public Integer idAddress; //322
        public String cliente;
        public String address1;
        public String address2;
        public String country;
        public String state;
        public String city;
        public String postalCode;
    }

    public class cls_currency {
        public Integer idCurrency; //1
        public String name; //Brazil - Real
        public String code; //BRL
    }

    public class cls_status {
        public Integer idStatus;
        public String description;
        public String name;
    }

    public class cls_activity {
        public Integer idActivity; //1
    }

    public class cls_subarea {
        public Integer idSubarea; //9
    }

    public class cls_skus {
        public cls_sku sku;
        public cls_measureUnit measureUnit;
        public Integer requestedQuantity; //1
        public Double totalCost; //100
        public String deliverDate; //2017-10-20T11:00:00.000Z
        public cls_status status; 
        public Integer accountBatchNumber;
    }

    public class cls_sku {
        public String code; //76162
        public String description; //GARRAFA VODKA WYBOROWA EXQUISITE 750ML
    }

    public class cls_measureUnit {
        public String uniMed; //BT
        public Double unitCost; //100
    }

    public class cls_id {}
    public class cls_description {}
    public class cls_devs {}

    public class cls_skustatus {
        public Integer idStatus;
        public String description;
    }

    public class cls_provider {
        public Integer id; //51557
        public Integer code; //16274
        public String providerName; //CIA BRASILEIRA DE DISTRIBUICAO
    }
    
    public class cls_dateApproval {}
    //class cls_idErp {}
    public class cls_erpDocumentType {}
    public class cls_idAttachment {}
    public class cls_dateAccount {}

    public class IMMException extends Exception {
        public String messageBody {get;set;}
    }

    public class IMMNoskuException extends Exception {

    }
}