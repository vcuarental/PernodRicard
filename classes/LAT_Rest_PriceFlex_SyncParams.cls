@RestResource(urlMapping='/LAT_Rest_PriceFlex_SyncParams/*')
global with sharing class LAT_Rest_PriceFlex_SyncParams {

	public static final String ERROR_MSG_NOTFOUND_METHOD = 'El método seleccionado no existe, por favor ingrese un método correcto.';
	public static final String ERROR_MSG_EXCEPTION = 'Exception: ';
	public static final String ADD_TRANSACTION_METHOD = 'AddTransaction';
    public static final String IMM_API_KEY_HEADER = 'x-api-key';
    public static boolean isProcessing;

	@HttpGet
    global static void doGet(){ 
    	String filter = RestContext.request.params.get('executiveCode');
		String method = RestContext.request.params.get('method');
		RestContext.response.addHeader('Content-Type', 'application/json');
		System.debug('%%%%%% method : '+method);
    	try {
    		if (method == 'initialSyncParams' || method == 'initialSyncBalance') {

    			if (filter != null && filter != '') {
    				filter = '?where[salesStrucCode]='+filter;
    			}    			
    			LAT_IMM_Operations__c operation = LAT_IMM_Operations__c.getInstance(method);
    			HttpResponse resp = sentRequestGenericCaller(null, operation, filter);
    			system.debug('response' + String.valueOf(resp.getBody()));
				RestContext.response.responseBody 	= Blob.valueOf(resp.getBody());
				RestContext.response.statusCode 	= 200;
    		}  else {
				IntegrationResponse response = new IntegrationResponse(ERROR_MSG_NOTFOUND_METHOD, 'NOT FOUND');
				RestContext.response.responseBody 	= Blob.valueOf(JSON.serialize(response));
				RestContext.response.statusCode 	= 404;
			}

		} catch (Exception e){
			IntegrationResponse response = new IntegrationResponse(ERROR_MSG_EXCEPTION + e.getMessage() + '. Trace: ' + e.getStackTraceString(), 'EXCEPTION');
			RestContext.response.responseBody 	= Blob.valueOf(JSON.serialize(response));
			RestContext.response.statusCode 	= 500;
		}

    }

    @HttpPost
    global static void POST() {
        RestRequest req = RestContext.request;
        BalanceBody receivedBody = (BalanceBody)System.JSON.deserialize(req.requestBody.toString(), BalanceBody.class);
        System.debug('receivedBody : ' + receivedBody);
    	try {
            String filter = 'fundingTypeCode=';
            if (receivedBody.fundingType == 'On Invoice') {
                filter += 'ON';
            } else if (receivedBody.fundingType == 'FLEX') { 
                filter += 'FX';
            }
            System.debug('receivedBody.executiveCode:' + receivedBody.executiveCode);
            System.debug('receivedBody.executiveCode.substring(0, 1):' + receivedBody.executiveCode.substring(0, 1));
            filter += '&salesRegionCode=' + receivedBody.executiveCode.substring(0, 1);
            filter += '&salesRepCode=' + receivedBody.executiveCode;
            if(receivedBody.fundingType == 'On Invoice' && receivedBody.customerCode != null && receivedBody.customerCode.length() > 0){
                filter += '&customerCode=' + receivedBody.customerCode;
            }
            LAT_IMM_Operations__c operation = LAT_IMM_Operations__c.getInstance('Flex_Balance');
            HttpResponse resp = sentRequestGenericCaller(null, operation, filter);
            RestContext.response.addHeader('Content-Type', 'application/json');
            system.debug('response' + String.valueOf(resp.getBody()));
            RestContext.response.responseBody 	= Blob.valueOf(resp.getBody());
            RestContext.response.statusCode 	= 200;

		} catch (Exception e){
			IntegrationResponse response = new IntegrationResponse(ERROR_MSG_EXCEPTION + e.getMessage() + '. Trace: ' + e.getStackTraceString(), 'EXCEPTION');
            RestContext.response.addHeader('Content-Type', 'application/json');
			RestContext.response.responseBody 	= Blob.valueOf(JSON.serialize(response));
			RestContext.response.statusCode 	= 500;
		}

    }

    global class BalanceBody{
        public String fundingType;
        public String salesRegionCode;
        public String executiveCode;
        public String customerCode;
    }

    /**
	 * Class to handle status with appropiate msg
	 */
	global class IntegrationResponse{
		public String msg{get; set;}
		public String status{get; set;}

		public IntegrationResponse(String msg, String status) {
			this.msg = msg;
			this.status = status;
		}

	}

	public static HttpResponse sentRequestGenericCaller(String reqBody, LAT_IMM_Operations__c operation){
		return sentRequestGenericCaller(reqBody, operation, null);
	}


    public static HttpResponse sentRequestGenericCaller(String reqBody, LAT_IMM_Operations__c operation, String urlParam) {
		
		if (Test.isRunningTest()) {
            reqBody = 'test';
        }

        String endpoint = operation.EndpointUrl__c;
        if(urlParam != null) {
        	endpoint = endpoint + urlParam;
        }
        System.debug('URL : ' +endpoint);
        HttpRequest req = new HttpRequest();
        req.setHeader('Content-Type', 'application/json');
        req.setEndpoint(endpoint);
        req.setMethod(operation.Http_operation__c);
        req.setHeader(IMM_API_KEY_HEADER, operation.x_Api_key__c);
        req.setTimeout(2 * 50 * 1000);


        if (reqBody != null) {
            req.setBody(reqBody);
        }
        Http http = new Http();
        HTTPResponse res;
        /*if (Test.isRunningTest()) {
            res = new HTTPResponse();
            res.setBody(bodyTest);
        } else {*/
            res = http.send(req);
        //}

        return res;
    }
    
    public static string bodyTest {
        get {
            if( bodyTest == null ) {
                 bodyTest = '';
            }
            return bodyTest;
        }
        set;
    }

    @future(callout=true)
    public static void processFlexOpportunity(String oppId ) {
        return;
        /*
        System.debug('Entramos en processFlexOpportunity. oppId : '+ oppId + ' || isProcessing = '+isProcessing);
        if(isProcessing == null ){
            isProcessing = true;
        } else {
            return;
        }
    	String ret = '';
        LAT_GeneralConfig__c cs = LAT_GeneralConfig__c.getInstance('IMM_LOG_NRO');
        Integer uuid = Integer.valueOf(cs.LAT_Value__c);

    	LAT_Opportunity__c opp = [SELECT Id, Name, (SELECT Id, LAT_IsFlex__c, LAT_FlexAmount__c, LAT_OriginalFlexAmount__c, LAT_NisAmount__c, LAT_OriginalNisAmount__c, LAT_Sku__c, 
                                                LAT_Product__r.LAT_ScheduleC__r.KeyBrand__r.Key__c, LAT_IdIMM__c,
    											LAT_Opportunity__r.LAT_Account__r.Client_code_an8__c, LAT_Opportunity__r.LAT_Account__r.Regional__r.CodDefUsuario__c,
    											LAT_Opportunity__r.LAT_Account__r.LAT_Account__r.LAT_JDEZone__c, LAT_CdLineStatus__c, LAT_AR_Discount__c, LAT_FlexNeedsValidation__c, 
                                                LAT_CreatedFromJDE__c, LAT_OriginalUnitNisAmount__c, LAT_Quantity__c FROM OpportunityLineItems__r) 
    								FROM LAT_Opportunity__c WHERE Id =:oppId];

    	if(opp == null ) {
    		System.debug('En LAT_Rest_PriceFlex_SyncParams.addTransaction : Pedido no Encontrado, oppId: ' +oppId );
    		ret = 'Pedido No encontrado';
    	} else {

            Map<String, LAT_OpportunityLineItem__c> map_JDE_OlisBySku = new Map<String, LAT_OpportunityLineItem__c>();
    		Map<String, Decimal> mapAmountBySku = new Map<String, Decimal>();
    		Map<String, LAT_OpportunityLineItem__c> mapOliBySku = new Map<String, LAT_OpportunityLineItem__c>();
    		for(LAT_OpportunityLineItem__c oli : opp.OpportunityLineItems__r) {
    			if(oli.LAT_IsFlex__c && !oli.LAT_CreatedFromJDE__c) {
    				mapOliBySku.put(oli.LAT_Sku__c, oli);
    			}
    		}
            List<LAT_OpportunityLineItem__c> toUpdate = new List<LAT_OpportunityLineItem__c>();

    		for(LAT_OpportunityLineItem__c oli : opp.OpportunityLineItems__r) {
    			if(mapOliBySku.keySet().contains(oli.LAT_Sku__c)) {
    				if(!mapAmountBySku.keySet().contains(oli.LAT_Sku__c)) {
    					mapAmountBySku.put(oli.LAT_Sku__c, 0);
    				}
    				Decimal aux = mapAmountBySku.get(oli.LAT_Sku__c);
    				if(oli.LAT_NisAmount__c != null) {
    					aux += oli.LAT_NisAmount__c ;
    				}
    				mapAmountBySku.put(oli.LAT_Sku__c, aux); 
    			} else {
                    map_JDE_OlisBySku.put(oli.Id, oli);
                }
                
    		}
            List<LAT_IMM_Logs__c> logsToInsert = new List<LAT_IMM_Logs__c>();
            Boolean enviarEmailAvisoDiferenciaValoresPrecio = false;
            //Lineas que se crearon en compass + lineas que se craron por splits del mismo SKU en JDE
			for(LAT_OpportunityLineItem__c oli : opp.OpportunityLineItems__r){
                //venta más barata
                if(oli.LAT_AR_Discount__c < 0) {
                    System.debug('%%%% 5');
                    System.debug('%%%% 5 mapAmountBySku.get(oli.LAT_Sku__c) : ' +mapAmountBySku.get(oli.LAT_Sku__c));
                    System.debug('%%%% 5 oliLAT_OriginalNisAmount__c : ' +oli.LAT_OriginalNisAmount__c);
                    System.debug('%%%% 5 oliLAT_UnitOriginalNisAmount__c : ' +oli.LAT_OriginalUnitNisAmount__c);
                    System.debug('%%%% 5 oliLAT_Quantity__c : ' +oli.LAT_Quantity__c);
                    if(oli.LAT_OriginalUnitNisAmount__c != null) {
                        System.debug('%%%% 5 (oli.LAT_OriginalUnitNisAmount__c * oli.LAT_Quantity__c) : ' +(oli.LAT_OriginalUnitNisAmount__c * oli.LAT_Quantity__c));
                        System.debug('%%%% 5 oli.LAT_OriginalFlexAmount__c : ' +oli.LAT_OriginalFlexAmount__c);
                        Decimal flexAmount = (oli.LAT_NisAmount__c - (oli.LAT_OriginalUnitNisAmount__c * oli.LAT_Quantity__c));
                        System.debug('%%%% 5 flexAmount : ' +flexAmount);
                        if(flexAmount != oli.LAT_OriginalFlexAmount__c) {
                            if(flexAmount.setScale(2) != oli.LAT_OriginalFlexAmount__c.setScale(2)) {
                                System.debug('%%%% 6');
                                if(oli.LAT_NisAmount__c == 0) {
                                        Decimal amount = oli.LAT_OriginalFlexAmount__c * (-1);
                                        System.debug('%%%% 6.1 amount:' + amount);
                                        System.debug('%%%% 6.1 oli.LAT_IdIMM__c:' + oli.LAT_IdIMM__c);
                                        if(oli.LAT_IdIMM__c == null) uuid++;
                                        LAT_IMM_Logs__c retorno = (oli.LAT_IdIMM__c != null)? addTransactionBulk(oli, amount) : addTransactionBulk(oli, amount, uuid);
                                        logsToInsert.add(retorno);
                                        ret = retorno.LAT_IMM_Id__c;
                                        System.debug('%%%% ret : ' + ret);
                                        if(ret != 'ERROR') {
                                            oli.LAT_OriginalFlexAmount__c = 0;
                                            oli.LAT_OriginalNisAmount__c = 0;
                                            oli.LAT_IdIMM__c = ret;
                                            toUpdate.add(oli);
                                        } else {
                                            break;
                                        }
                                    } else {
                                        Decimal amount = flexAmount - oli.LAT_OriginalFlexAmount__c;
                                        System.debug('%%%% 6.2 amount:' + amount);
                                        if(oli.LAT_IdIMM__c == null) uuid++;
                                        LAT_IMM_Logs__c retorno = (oli.LAT_IdIMM__c != null)? addTransactionBulk(oli, amount) : addTransactionBulk(oli, amount, uuid);
                                        logsToInsert.add(retorno);
                                        ret = retorno.LAT_IMM_Id__c;
                                        System.debug('%%%% ret : ' + ret);
                                        if(ret != 'ERROR') {
                                            oli.LAT_FlexAmount__c = oli.LAT_OriginalFlexAmount__c = flexAmount;
                                            oli.LAT_IdIMM__c = ret;
                                            toUpdate.add(oli);
                                        } else {
                                            break;
                                        }
                                    } 
                            } else {
                                oli.LAT_OriginalFlexAmount__c = flexAmount;
                                toUpdate.add(oli);
                            }
                        }
                    }
                } 
                //venta más cara
                else {
                    if(oli.LAT_AR_Discount__c > 0) {
                        System.debug('%%%% 7');
                        System.debug('%%%% 7 oli.LAT_CdLineStatus__c :' + oli.LAT_CdLineStatus__c);
                        System.debug('%%%% 7 mapAmountBySku.get(oli.LAT_Sku__c) : ' +mapAmountBySku.get(oli.LAT_Sku__c));
                        System.debug('%%%% 7 oliLAT_OriginalNisAmount__c : ' +oli.LAT_OriginalNisAmount__c);
                        System.debug('%%%% 7 oliLAT_UnitOriginalNisAmount__c : ' +oli.LAT_OriginalUnitNisAmount__c);
                        System.debug('%%%% 7 oliLAT_Quantity__c : ' +oli.LAT_Quantity__c);
                        
                        if(oli.LAT_OriginalUnitNisAmount__c != null) {
                            System.debug('%%%% 7 (oli.LAT_OriginalUnitNisAmount__c * oli.LAT_Quantity__c) : ' +(oli.LAT_OriginalUnitNisAmount__c * oli.LAT_Quantity__c));
                            System.debug('%%%% 7 oli.LAT_OriginalFlexAmount__c : ' +oli.LAT_OriginalFlexAmount__c);
                            Decimal flexAmount = (oli.LAT_NisAmount__c - (oli.LAT_OriginalUnitNisAmount__c * oli.LAT_Quantity__c));
                            System.debug('%%%% 7 flexAmount : ' +flexAmount);
                            System.debug('%%%% 7 oli.LAT_FlexAmount__c : ' +oli.LAT_FlexAmount__c);
                            
                            if(flexAmount < 0){
                                //Si el valor flex a enviar es negativo y el % de descuento es positivo, no envío a integrar ya que algo está mal.
                                LAT_IMM_Operations__c operation = LAT_IMM_Operations__c.getInstance(ADD_TRANSACTION_METHOD);
                                TransactionBody pBody = getBody(operation, oli, flexAmount);

                                LAT_IMM_Logs__c log 			= new LAT_IMM_Logs__c();
                                log.LAT_Request__c 				= JSON.serialize(pBody);
                                log.LAT_Service__c 				= ADD_TRANSACTION_METHOD;
                                log.LAT_IMM_Id__c               = 'ERROR_NO_ENVIADO_X_DIFERENCIA_EN_PRECIO';
                                log.LAT_LineStatus__c 			= oli.LAT_CdLineStatus__c;
                                log.LAT_OpportunityLineItem__c	= oli.Id;
                                log.LAT_TimeStamp__c			= Datetime.now();
                                log.LAT_Amount__c				= flexAmount;
                                logsToInsert.add(log);
                                enviarEmailAvisoDiferenciaValoresPrecio = true;
                            } else {
                                if(oli.LAT_CdLineStatus__c == '620' && oli.LAT_OriginalNisAmount__c != 0) {
                                    uuid++;
                                    LAT_IMM_Logs__c retorno = addTransactionBulk(oli, flexAmount, uuid);
                                    logsToInsert.add(retorno);
                                    ret = retorno.LAT_IMM_Id__c;
                                    System.debug('%%%% ret : ' + ret);
                                    if(ret != 'ERROR') {
                                        oli.LAT_OriginalNisAmount__c = 0;
                                        oli.LAT_IdIMM__c = ret;
                                        toUpdate.add(oli);
                                    } 
                                }
                            }
                            
                        }
                    }
                }
				
			}    

            if(logsToInsert.size() > 0) {
                insert logsToInsert;
            }
            if(cs.LAT_Value__c != String.valueOf(uuid)) {
                cs.LAT_Value__c = String.valueOf(uuid);
                update cs;
            }
            for(LAT_OpportunityLineItem__c oli : opp.OpportunityLineItems__r){

                if(oli.LAT_FlexNeedsValidation__c && !toUpdate.contains(oli)){
                    toUpdate.add(oli);
                }
                oli.LAT_FlexNeedsValidation__c = false;
            }

			if(toUpdate.size() > 0) {
				update toUpdate;
			}

            if(enviarEmailAvisoDiferenciaValoresPrecio){
                String strMails = LAT_GeneralConfig__c.getInstance('OPP_Verification_Email_Recipients').LAT_Value__c;
                String[] mails  = strMails.split(',');
                String html = 'Estimado, <br><br> El pedido <a href=\"https://' + URL.getSalesforceBaseUrl().getHost() + '/' + opp.Id+ '\">' + opp.name +'</a> contiene líneas con descuento positivo pero Amount Flex negativo, por favor revisar, ya que el sistema no enviará a IMM esas transacciones. <br><br>  Gracias,<br><br> Equipo CRM';
                LAT_ApprovalProcessSLA_Batch.sendEmailNotification(mails,html , 'Verificar Pedido FLEX por diferencias entre Valores FLEX y % Descuento.');
            }
            
			return;

    	}



        return;
        */
    }

    public static String  addTransaction(LAT_OpportunityLineItem__c oli, Decimal amount) {
    	String ret = '';
    	LAT_IMM_Operations__c operation = LAT_IMM_Operations__c.getInstance(ADD_TRANSACTION_METHOD);

    	TransactionBody pBody = getBody(operation, oli, amount);

    	LAT_IMM_Logs__c log 			= new LAT_IMM_Logs__c();
    	log.LAT_Request__c 				= JSON.serialize(pBody);
    	log.LAT_Service__c 				= ADD_TRANSACTION_METHOD;
    	log.LAT_LineStatus__c 			= oli.LAT_CdLineStatus__c;
    	log.LAT_OpportunityLineItem__c	= oli.Id;
    	log.LAT_TimeStamp__c			= Datetime.now();
    	log.LAT_Amount__c				= amount;

    	try {

    		HttpResponse resp = sentRequestGenericCaller(JSON.serialize(pBody), operation);
			ResponseFromIMM res = (ResponseFromIMM)System.JSON.deserialize(resp.getBody(), ResponseFromIMM.class);
			if(res.idMovement != null) {
				log.LAT_IMM_Id__c 	= res.idMovement;
				log.LAT_Response__c	= JSON.serialize(res);
			} else {
				ret = 'Error al procesar : \n';
				log.LAT_IMM_Id__c 	= 'ERROR';
				log.LAT_Response__c	= JSON.serialize(res);
				if(res.message != null) {
					ret += res.message + '\n';
				}
				if(res.error != null) {
					ret += res.error + '\n';
				}
			}
			
			insert log;
		} catch (Exception e) {
			ret = 'Error al procesar : \n';
			ret += e.getMessage() + ' || ' + e.getStackTraceString();
			log.LAT_IMM_Id__c 	= 'ERROR';
			log.LAT_Response__c	= e.getMessage() + ' || ' + e.getStackTraceString();
			insert log;
		}
    	return ret;
    }

    public static TransactionBody getBody(LAT_IMM_Operations__c operation, LAT_OpportunityLineItem__c oli, Decimal amount){
        TransactionBody pBody 		= new TransactionBody();
    	pBody.company				= Integer.valueOf(operation.LAT_Company__c);
    	//pBody.regionCode			= oli.LAT_Opportunity__r.LAT_Account__r.Regional__r.CodDefUsuario__c;
    	//se comenta para las pruebas ya que el servicio retorna regon code not found para la regional de la account, en este caso es 4.
    	pBody.regionCode			= oli.LAT_Opportunity__r.LAT_Account__r.Regional__r.CodDefUsuario__c;
    	pBody.executiveCode			= oli.LAT_Opportunity__r.LAT_Account__r.LAT_Account__r.LAT_JDEZone__c;
    	pBody.brandCode				= oli.LAT_Product__r.LAT_ScheduleC__r.KeyBrand__r.Key__c;
    	pBody.accountId				= Integer.valueOf(oli.LAT_Opportunity__r.LAT_Account__r.Client_code_an8__c);
    	//se comenta para las pruebas ya que el servicio retorna  Customer not found para la  account, que en este caso es 16451.
    	//pBody.accountId				= 12345;
    	pBody.skuId					= oli.LAT_Sku__c;
    	pBody.originalTransNumber	= oli.LAT_IdIMM__c;
    	pBody.transDate				= String.valueOf(Datetime.now());
    	pBody.amount				= amount;
    	pBody.transType				= 'S';
    	pBody.transOpType			= (amount >= 0.00 )? 'C':'D';
        return pBody;

    }

    public static LAT_IMM_Logs__c  addTransactionBulk(LAT_OpportunityLineItem__c oli, Decimal amount) {
        System.debug('%%%% SIN uuid!!!! ');
        return addTransactionBulk(oli, amount, null);
    }

    public static LAT_IMM_Logs__c  addTransactionBulk(LAT_OpportunityLineItem__c oli, Decimal amount, Integer uuid) {

        System.debug('%%%% uuid : ' + uuid);
        String ret = '';
        LAT_IMM_Operations__c operation = LAT_IMM_Operations__c.getInstance(ADD_TRANSACTION_METHOD);

        TransactionBody pBody       = new TransactionBody();
        pBody.company               = Integer.valueOf(operation.LAT_Company__c);
        //pBody.regionCode          = oli.LAT_Opportunity__r.LAT_Account__r.Regional__r.CodDefUsuario__c;
        //se comenta para las pruebas ya que el servicio retorna regon code not found para la regional de la account, en este caso es 4.
        pBody.regionCode            = oli.LAT_Opportunity__r.LAT_Account__r.Regional__r.CodDefUsuario__c;
        pBody.executiveCode         = oli.LAT_Opportunity__r.LAT_Account__r.LAT_Account__r.LAT_JDEZone__c;
        pBody.brandCode             = oli.LAT_Product__r.LAT_ScheduleC__r.KeyBrand__r.Key__c;
        pBody.accountId             = Integer.valueOf(oli.LAT_Opportunity__r.LAT_Account__r.Client_code_an8__c);
        //se comenta para las pruebas ya que el servicio retorna  Customer not found para la  account, que en este caso es 16451.
        //pBody.accountId               = 12345;

        pBody.skuId                 = oli.LAT_Sku__c;
        if(uuid != null) {
            pBody.originalTransNumber   = String.valueOf(uuid);
        } else {
            pBody.originalTransNumber   = oli.LAT_IdIMM__c;
        }        
        pBody.transDate             = String.valueOf(Datetime.now());
        pBody.amount                = amount;
        pBody.transType             = 'S';
        pBody.transOpType           = (amount >= 0.00 )? 'C':'D';

        LAT_IMM_Logs__c log             = new LAT_IMM_Logs__c();
        log.LAT_Request__c              = JSON.serialize(pBody);
        log.LAT_Service__c              = ADD_TRANSACTION_METHOD;
        log.LAT_LineStatus__c           = oli.LAT_CdLineStatus__c;
        log.LAT_OpportunityLineItem__c  = oli.Id;
        log.LAT_TimeStamp__c            = Datetime.now();
        log.LAT_Amount__c               = amount;
        log.LAT_uuid__c                 = pBody.originalTransNumber;


        try {

            HttpResponse resp = sentRequestGenericCaller(JSON.serialize(pBody), operation);
            ResponseFromIMM res = (ResponseFromIMM)System.JSON.deserialize(resp.getBody(), ResponseFromIMM.class);
            if(res.idMovement != null) {
                log.LAT_IMM_Id__c   = res.idMovement;
                log.LAT_Response__c = JSON.serialize(res);
            } else {
                ret = 'Error al procesar : \n';
                log.LAT_IMM_Id__c   = 'ERROR';
                log.LAT_Response__c = JSON.serialize(res);
                if(res.message != null) {
                    ret += res.message + '\n';
                }
                if(res.error != null) {
                    ret += res.error + '\n';
                }
            }
            
            
        } catch (Exception e) {
            ret = 'Error al procesar : \n';
            ret += e.getMessage() + ' || ' + e.getStackTraceString();
            log.LAT_IMM_Id__c   = 'ERROR';
            log.LAT_Response__c = e.getMessage() + ' || ' + e.getStackTraceString();
        }
        return log;
    }

    @future(callout=true)
    public static void processRejectedFlexOpportunity(String oppId ) {
        System.debug('Entramos en processFlexOpportunity. oppId : '+ oppId + ' || isProcessing = '+isProcessing);
        if(isProcessing == null ){
            isProcessing = true;
        } else {
            return;
        }
        LAT_Rest_OpportunityFlex.rollBackTransactionInAquila(oppId);
        return;
        /*
        String ret = '';

        LAT_GeneralConfig__c cs = LAT_GeneralConfig__c.getInstance('IMM_LOG_NRO');
        List<LAT_IMM_Logs__c> logsToInsert = new List<LAT_IMM_Logs__c>();
        Integer uuid = Integer.valueOf(cs.LAT_Value__c);

        LAT_Opportunity__c opp = [SELECT Id, (SELECT Id, LAT_IsFlex__c, LAT_FlexAmount__c, LAT_OriginalFlexAmount__c, LAT_NisAmount__c, LAT_OriginalNisAmount__c, LAT_Sku__c, 
                                                LAT_Product__r.LAT_ScheduleC__r.KeyBrand__r.Key__c, LAT_IdIMM__c,
                                                LAT_Opportunity__r.LAT_Account__r.Client_code_an8__c, LAT_Opportunity__r.LAT_Account__r.Regional__r.CodDefUsuario__c,
                                                LAT_Opportunity__r.LAT_Account__r.LAT_Account__r.LAT_JDEZone__c, LAT_CdLineStatus__c, LAT_AR_Discount__c, LAT_FlexNeedsValidation__c, 
                                                LAT_CreatedFromJDE__c, LAT_OriginalUnitNisAmount__c, LAT_Quantity__c FROM OpportunityLineItems__r WHERE LAT_AR_Discount__c < 0) 
                                    FROM LAT_Opportunity__c WHERE Id =:oppId];
        
        List<LAT_OpportunityLineItem__c> toUpdate = new List<LAT_OpportunityLineItem__c>();

        if(opp == null ) {
            System.debug('En LAT_Rest_PriceFlex_SyncParams.processRejectedFlexOpportunity : Pedido no Encontrado, oppId: ' +oppId );
            ret = 'Pedido No encontrado';
        } else {
            for(LAT_OpportunityLineItem__c oli : opp.OpportunityLineItems__r){
                Decimal amount = oli.LAT_OriginalFlexAmount__c * (-1);
                System.debug('%%%% 15.1 amount:' + amount);
                System.debug('%%%% 15.1 oli.LAT_IdIMM__c:' + oli.LAT_IdIMM__c);
                if(oli.LAT_IdIMM__c == null) uuid++;
                LAT_IMM_Logs__c retorno = (oli.LAT_IdIMM__c != null)? addTransactionBulk(oli, amount) : addTransactionBulk(oli, amount, uuid);
                logsToInsert.add(retorno);
                ret = retorno.LAT_IMM_Id__c;
                System.debug('%%%% ret : ' + ret);
                if(ret != 'ERROR') {
                    oli.LAT_OriginalFlexAmount__c = 0;
                    oli.LAT_OriginalNisAmount__c = 0;
                    oli.LAT_IdIMM__c = ret;
                    toUpdate.add(oli);
                } 
            }  
        }
        if(logsToInsert.size() > 0 ) insert logsToInsert;
        if(toUpdate.size() > 0 ) update toUpdate;*/
    }


    public class ResponseFromIMM {
    	public String idMovement;
    	public String message;
    	public String error;
    }

	public class TransactionBody{

		public Integer 	company;
		public String 	regionCode;
		public String 	executiveCode;
		public String 	brandCode;
		public Integer 	accountId;
		public String 	skuId;
		public String 	originalTransNumber;
		public String 	transDate;
		public Decimal 	amount;
		public String 	transType;
		public String 	transOpType;
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
        json += '    }';
        json += '  ]';
        json += '}';
        return json;
    }

}