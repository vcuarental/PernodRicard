/**
 *
 *
 */
@RestResource(UrlMapping='/CreateImmPayment/*')
global with sharing class LAT_IMM_IntegrateService {
	
	public static final Map < String,
	String > IMM_STATUS_TO_CRMSTATUS = new Map < String,
	String > {
		'PENDENTE DE APROVAÇÃO' =>'P',
		'APROVADO' =>'I',
		'REPROVADO' =>'R',
		'CRIADO' =>'I',
		'LIBERADO' =>'E',
		'CANCELADO' =>'C',
		'USUÁRIO NÃO REGISTRADO NO JDE' =>'Erro Integração',
		'ERRO DE INTEGRAÇÃO' =>'Erro Integração'
	};

	@HttpPost
    global static IntegrationResponse send(id paymentId){ 
    	IntegrationResponse resp;
    	try {
    		sentPaymenToImm(paymentId);
    		resp = new IntegrationResponse('Imm created', 'success');
		} catch (Exception e){
			resp = new IntegrationResponse('Something went wrong', 'ERROR');
		}

    	return resp;
    }

    @HttpGet
    global static IntegrationResponse updatePayment(){ 
    	RestRequest req = new RestRequest();
    	RestContext.request = req;
    	String paymentId = req.params.get('paymentId');
    	IntegrationResponse resp;
    	try {
    		updatePaymentFromImm(paymentId);
    		resp = new IntegrationResponse('Imm created', 'success');
		} catch (Exception e){
			resp = new IntegrationResponse('Something went wrong', 'ERROR');
		}

    	return resp;
    }

    /**
     * Method to use from the button in the payment detail Page
     * @param paymentId
	 *
     */
    webservice static void sentPaymenToImm(id paymentId){
    	LAT_ContractPaymentsHandlerInterface.sendPaymentToMESync(paymentId);



    }

    // UTILS METHOD TO MAP ANSWERS TO AYMENT

    /**
     * Method to use from the button in the payment detail Page
     * @param paymentId
	 *
     */
    webservice static void updatePaymentFromImm(id paymentId){
    	LAT_Payment__c p = [SELECT Id, Status__c,Sku_at_Integration__c, IDMe__c,Status_IMM_Linea__c,IDPagoJDE__c,Ammount__c, ApprovedPayment__c,productValue__c, LAT_Contract__c, (Select id, ProductGroup__r.name, ProductGroup__c,productValue__c, Volumen__c,Status__c, IDMe__c,IDPagoJDE__c, recordType.DeveloperName,Status_IMM_Linea__c,Sku_at_Integration__c from Investimentos_Bonifica_es_e_Pagamentos__r), RecordType.DeveloperName, WorkflowME__r.WorkflowNumber__c, WorkflowME__r.WF__c FROM LAT_Payment__c where Id = :paymentId LIMIT 1];
    	List < LAT_Payment__c > toUpdate = new List < LAT_Payment__c > ();
    	if (p.RecordType.DeveloperName == 'LAT_PagamentoDinheiro') {
    		LAT_BR_IMM_RestCallHandler.GenericBodyIMM resp;
    		if (!Test.isRunningTest()){
				System.debug('%%%% vamos a getCashPayment');
    			resp = LAT_BR_IMM_RestCallHandler.getCashPayment(p.IDMe__c);
			} else {
				resp = getMockCashPayment();
			}
    		
			if (LAT_IMM_IntegrateService.updatePaymentFields(resp, p)){
				toUpdate.add(p);
				for (LAT_Payment__c childpay: p.Investimentos_Bonifica_es_e_Pagamentos__r) {
					toUpdate.add(childpay);
				}
			}
		} else if (p.RecordType.DeveloperName == 'LAT_PagamentoProduto'){
    		LAT_BR_IMM_RestCallHandler.GenericBodyIMM resp;
    		if (!Test.isRunningTest()){
    			resp = LAT_BR_IMM_RestCallHandler.getFreeGood(p.IDMe__c);
			} else {
				resp = getMockFreeGood();
			}
			if (updatePaymentFields(resp, p)){
				toUpdate.add(p);
			}
		} else if (p.RecordType.DeveloperName == 'LAT_PaymentGroup') {
				system.debug('paymentGroup++');
				if (p.Ammount__c != null && p.Ammount__c != 0) {
					system.debug('amonnt no zer++');


					LAT_BR_IMM_RestCallHandler.GenericBodyIMM resp;
					if (!Test.isRunningTest()){
		    			resp = LAT_BR_IMM_RestCallHandler.getCashPayment(p.IDMe__c);
					} else {
						resp = getMockFreeGood();
					}

					if (LAT_IMM_IntegrateService.updatePaymentGroupDinheroFields(resp, p)){
						toUpdate.add(p);
					}
					for (LAT_Payment__c childpay: p.Investimentos_Bonifica_es_e_Pagamentos__r) {
							toUpdate.add(childpay);
						}

				} else {
					system.debug('amonnt zero++');

					LAT_BR_IMM_RestCallHandler.GenericBodyIMM resp;
					if (!Test.isRunningTest()){
		    			resp = LAT_BR_IMM_RestCallHandler.getFreeGood(p.IDMe__c);
					} else {
						resp = getMocDinheroGroup();
					}

					if (LAT_IMM_IntegrateService.updatePaymentGroupProductosFields(resp, p)){
						system.debug('amonnt zero2++ ');
						toUpdate.add(p);
					}
					for (LAT_Payment__c childpay: p.Investimentos_Bonifica_es_e_Pagamentos__r) {
							toUpdate.add(childpay);
						}
				}

			}
		update toUpdate;

    }


    public static boolean updatePaymentFields(LAT_BR_IMM_RestCallHandler.GenericBodyIMM resp, LAT_Payment__c payment) {
		boolean mustupdate = (payment.Status__c != IMM_STATUS_TO_CRMSTATUS.get(resp.status.description));
		payment.IDMe__c = String.valueOf(resp.id);
		payment.Status__c = IMM_STATUS_TO_CRMSTATUS.get(resp.status.description);
		system.debug('%%% en updatePaymentFields, payment.RecordType.DeveloperName:'  + payment.RecordType.DeveloperName );
		if (payment.RecordType.DeveloperName == 'LAT_PagamentoProduto') {
			//resp.skus[0].sku.code;
			//payment.productValue__c = resp.skus[0].totalCost;
			payment.IDPagoJDE__c = resp.jdeId;
			mustupdate = (payment.Status__c != IMM_STATUS_TO_CRMSTATUS.get(resp.status.name));
			payment.Status__c = IMM_STATUS_TO_CRMSTATUS.get(resp.status.name);
			payment.productValue__c = resp.skus[0].measureUnit.unitCost;
		} else {
			system.debug('%%% en payment.IDPagoJDE__c, :'  + payment.IDPagoJDE__c);
			system.debug('%%% String.valueOf(resp.idErp): '  + String.valueOf(resp.idErp));
			system.debug('%%% resp.jdeStatus: '  + resp.jdeStatus);
			//for dihnhero
			mustupdate = mustupdate || (payment.IDPagoJDE__c !=  String.valueOf(resp.idErp));
			if(resp.jdeStatus != null && payment.Status__c != 'E'){
				if(resp.jdeStatus == 'P - Pago'){
					mustupdate = true;
					payment.Status__c = 'E';
				}
			}
			payment.IDPagoJDE__c = String.valueOf(resp.idErp);
		}
		//Como setear el status me?
		return mustupdate;
	}

	public static boolean updatePaymentGroupProductosFields(LAT_BR_IMM_RestCallHandler.GenericBodyIMM resp, LAT_Payment__c payment) {
		system.debug('groupProductos+++');
		boolean mustupdate = (payment.Status__c != IMM_STATUS_TO_CRMSTATUS.get(resp.status.name));
		system.debug('%%% mustupdate : ' + mustupdate);
		mustupdate = mustupdate || (payment.IDPagoJDE__c !=  resp.jdeId);
		system.debug('%%% mustupdate2 : ' + mustupdate);
		payment.IDMe__c = String.valueOf(resp.id);
		System.debug('%%% resp.status.name : ' + resp.status.name);
		System.debug('%%% IMM_STATUS_TO_CRMSTATUS.get(resp.status.name) : ' + IMM_STATUS_TO_CRMSTATUS.get(resp.status.name));
		payment.Status__c = IMM_STATUS_TO_CRMSTATUS.get(resp.status.name);
		payment.IDPagoJDE__c = resp.jdeId;
		system.debug('enter the batch');
		system.debug('enter the batch2' + payment.recordType.DeveloperName);
		if (payment.recordType.DeveloperName == 'LAT_PaymentGroup' && (payment.Ammount__c == null || payment.Ammount__c == 0)) {
	      Map<String, LAT_Payment__c> skuToPaymentMap = new Map<String, LAT_Payment__c>();
	      for (LAT_Payment__c pay:payment.Investimentos_Bonifica_es_e_Pagamentos__r){
	        skuToPaymentMap.put(pay.Sku_at_Integration__c, pay);
	      }
	      system.debug('skuToPaymentMap+++' + skuToPaymentMap);

      for (LAT_BR_IMM_RestCallHandler.cls_skus skuRet:resp.skus){
        LAT_Payment__c currPayment = skuToPaymentMap.get(skuRet.sku.code);
        system.debug('payment'+ currPayment);
        if(currPayment!= null){
        	mustupdate = (mustupdate) || (currPayment.IDPagoJDE__c !=  resp.jdeId) || (currPayment.Status_IMM_Linea__c != skuRet.status.description) || (currPayment.productValue__c != skuRet.measureUnit.unitCost);
     		currPayment.Status__c = IMM_STATUS_TO_CRMSTATUS.get(resp.status.name);
            currPayment.productValue__c = skuRet.measureUnit.unitCost;
            currPayment.Status_IMM_Linea__c = skuRet.status.description;
            //mustupdate = (mustupdate) || (currPayment.IDPagoJDE__c !=  resp.jdeId) || (currPayment.Status_IMM_Linea__c != skuRet.status.description) || (currPayment.productValue__c != skuRet.measureUnit.unitCost);
        }


      }
   }
		return mustupdate;
		//Como setear el status me?
	}

	public static boolean updatePaymentGroupDinheroFields(LAT_BR_IMM_RestCallHandler.GenericBodyIMM resp, LAT_Payment__c payment) {
		boolean mustupdate = (payment.Status__c != IMM_STATUS_TO_CRMSTATUS.get(resp.status.description));
		mustupdate = mustupdate || (payment.IDPagoJDE__c !=  String.valueOf(resp.idErp));
		payment.IDMe__c = String.valueOf(resp.id);
		payment.Status__c = IMM_STATUS_TO_CRMSTATUS.get(resp.status.description);
		System.debug('%%%%% resp en updatePaymentGroupDinheroFields: ' + resp);
		if(resp.jdeStatus != null){
			if(resp.jdeStatus == 'P - Pago'){
				payment.Status__c = 'E';
			}
		}
		
		payment.IDPagoJDE__c = String.valueOf(resp.idErp);

		for (LAT_Payment__c childpay: payment.Investimentos_Bonifica_es_e_Pagamentos__r) {
			mustupdate = (mustupdate) || (childpay.IDPagoJDE__c !=  String.valueOf(resp.idErp)) || (childpay.Status__c != IMM_STATUS_TO_CRMSTATUS.get(resp.status.description));
			childpay.IDMe__c = String.valueOf(resp.id);
			childpay.Status__c = IMM_STATUS_TO_CRMSTATUS.get(resp.status.description);
			if(resp.jdeStatus != null){
				if(resp.jdeStatus == 'P - Pago'){
					payment.Status__c = 'E';
				}
			}
			childpay.IDPagoJDE__c = String.valueOf(resp.idErp);
			
			//resp.skus[0].sku.code
			//toUpdate.add(p); resp.skus[0].sku.code;
		}
		return mustupdate;
		//Como setear el status me?
	}

	public static LAT_BR_IMM_RestCallHandler.GenericBodyIMM getMockCashPayment(){
    	String json=		'{';
		json +='    "id": 175,';
		json +='    "type": "CP",';
		json +='    "documentType": "CP",';
		json +='    "description": "Lorem Ipsum",';
		json +='    "dateRequest": "2017-09-17T08:00:00.000Z",';
		json +='    "dateApproval": null,';
		json +='    "jdeStatus": "-",';
		json +='    "userName": "BSOUZA01 - Bruno Souza",';
		json +='    "login": "BSOUZA01",';
		json +='    "jdeId": "234234234",';
		
		json +='    "idErp": null,';
		json +='    "erpDocumentType": null,';
		json +='    "amount": 0,';
		json +='    "indBoi": 0,';
		json +='    "idAttachment": null,';
		json +='    "amountPending": 0,';
		json +='    "amountReceived": 0,';
		json +='    "dateAccount": null,';
		json +='    "accountBatchNumber": null,';
		json +='    "subarea": {';
		json +='        "idSubarea": 9';
		json +='    },';
		json +='    "status": {';
		json +='        "idStatus": 4,';
		json +='        "description": "CRIADO"';
		json +='    },';
		json +='    "activity": {';
		json +='        "idActivity": 1';
		json +='    },';
		json +='    "currency": {';
		json +='        "idCurrency": 1,';
		json +='        "exchangeRate": 1,';
		json +='        "currencyCode": "BRL",';
		json +='        "currencyName": "Brazil - Real"';
		json +='    },';
		json +='    "conceptoGasto": {';
		json +='        "idConceptoGasto": 207,';
		json +='        "description": "SERVICO CRIACAO FOLHETOS SIMPLES POR PAGINA"';
		json +='    },';
		json +='    "provider": {';
		json +='        "id": 51557,';
		json +='        "code": 16274,';
		json +='        "providerName": "CIA BRASILEIRA DE DISTRIBUICAO"';
		json +='    },';
		json +='    "almacen": {';
		json +='        "idAlmacen": 25,';
		json +='        "description": "Sao Paulo"';
		json +='    }';
		json +='}';
		LAT_BR_IMM_RestCallHandler.GenericBodyIMM obj = (LAT_BR_IMM_RestCallHandler.GenericBodyIMM) System.JSON.deserialize(json, LAT_BR_IMM_RestCallHandler.GenericBodyIMM.class);
		return obj;
    }

	public static LAT_BR_IMM_RestCallHandler.GenericBodyIMM getMockFreeGood(){
		String json=		'{';
		json +='    "id": 175,';
		json +='    "type": "CP",';
		json +='    "documentType": "CP",';
		json +='    "description": "Lorem Ipsum",';
		json +='    "dateRequest": "2017-09-17T08:00:00.000Z",';
		json +='    "dateApproval": null,';
		json +='    "jdeStatus": "-",';
		json +='    "userName": "BSOUZA01 - Bruno Souza",';
		json +='    "login": "BSOUZA01",';
		json +='    "idErp": null,';
		json +='    "erpDocumentType": null,';
		json +='    "amount": 0,';
		json +='    "jdeId": "234234234",';
		json +='    "indBoi": 0,';
		json +='    "idAttachment": null,';
		json +='    "amountPending": 0,';
		json +='    "amountReceived": 0,';
		json +='    "dateAccount": null,';
		json +='    "accountBatchNumber": null,';
		json +='    "subarea": {';
		json +='        "idSubarea": 9';
		json +='    },';
		json +='    "status": {';
		json +='        "idStatus": 4,';
		json +='        "description": "CRIADO"';
		json +='    },';
		json +='    "activity": {';
		json +='        "idActivity": 1';
		json +='    },';
		json +='    "currency": {';
		json +='        "idCurrency": 1,';
		json +='        "exchangeRate": 1,';
		json +='        "currencyCode": "BRL",';
		json +='        "currencyName": "Brazil - Real"';
		json +='    },';
		json +='    "conceptoGasto": {';
		json +='        "idConceptoGasto": 207,';
		json +='        "description": "SERVICO CRIACAO FOLHETOS SIMPLES POR PAGINA"';
		json +='    },';
		json +='    "provider": {';
		json +='        "id": 51557,';
		json +='        "code": 16274,';
		json +='        "providerName": "CIA BRASILEIRA DE DISTRIBUICAO"';
		json +='    },';
		json +='    "almacen": {';
		json +='        "idAlmacen": 25,';
		json +='        "description": "Sao Paulo"';
		json +='    }';
		json +='}';
		LAT_BR_IMM_RestCallHandler.GenericBodyIMM obj = (LAT_BR_IMM_RestCallHandler.GenericBodyIMM) System.JSON.deserialize(json, LAT_BR_IMM_RestCallHandler.GenericBodyIMM.class);
		return obj;
    }

	public static LAT_BR_IMM_RestCallHandler.GenericBodyIMM getMockFreeGoodGroup(){
		String json=		'{';
		json +='    "id": 175,';
		json +='    "type": "CP",';
		json +='    "documentType": "CP",';
		json +='    "description": "Lorem Ipsum",';
		json +='    "dateRequest": "2017-09-17T08:00:00.000Z",';
		json +='    "dateApproval": null,';
		json +='    "jdeStatus": "-",';
		json +='    "userName": "BSOUZA01 - Bruno Souza",';
		json +='    "login": "BSOUZA01",';
		json +='    "idErp": null,';
		json +='    "erpDocumentType": null,';
		json +='    "amount": 0,';
		json +='    "jdeId": "234234234",';
		json +='    "indBoi": 0,';
		json +='    "idAttachment": null,';
		json +='    "amountPending": 0,';
		json +='    "amountReceived": 0,';
		json +='    "dateAccount": null,';
		json +='    "accountBatchNumber": null,';
		json +='    "subarea": {';
		json +='        "idSubarea": 9';
		json +='    },';
		json +='    "status": {';
		json +='        "idStatus": 4,';
		json +='        "description": "CRIADO"';
		json +='    },';
		json +='    "activity": {';
		json +='        "idActivity": 1';
		json +='    },';
		json +='    "currency": {';
		json +='        "idCurrency": 1,';
		json +='        "exchangeRate": 1,';
		json +='        "currencyCode": "BRL",';
		json +='        "currencyName": "Brazil - Real"';
		json +='    },';
		json +='    "conceptoGasto": {';
		json +='        "idConceptoGasto": 207,';
		json +='        "description": "SERVICO CRIACAO FOLHETOS SIMPLES POR PAGINA"';
		json +='    },';
		json +='    "provider": {';
		json +='        "id": 51557,';
		json +='        "code": 16274,';
		json +='        "providerName": "CIA BRASILEIRA DE DISTRIBUICAO"';
		json +='    },';
		json +='    "almacen": {';
		json +='        "idAlmacen": 25,';
		json +='        "description": "Sao Paulo"';
		json +='    }';
		json +='}';
		LAT_BR_IMM_RestCallHandler.GenericBodyIMM obj = (LAT_BR_IMM_RestCallHandler.GenericBodyIMM) System.JSON.deserialize(json, LAT_BR_IMM_RestCallHandler.GenericBodyIMM.class);
		return obj;
    }

    public static LAT_BR_IMM_RestCallHandler.GenericBodyIMM getMocDinheroGroup(){
		String json=		'{';
		json +='    "id": 175,';
		json +='    "type": "CP",';
		json +='    "documentType": "CP",';
		json +='    "description": "Lorem Ipsum",';
		json +='    "dateRequest": "2017-09-17T08:00:00.000Z",';
		json +='    "dateApproval": null,';
		json +='    "jdeStatus": "-",';
		json +='    "userName": "BSOUZA01 - Bruno Souza",';
		json +='    "login": "BSOUZA01",';
		json +='    "idErp": null,';
		json +='    "erpDocumentType": null,';
		json +='    "amount": 0,';
		json +='    "jdeId": "234234234",';
		json +='    "indBoi": 0,';
		json +='    "idAttachment": null,';
		json +='    "amountPending": 0,';
		json +='    "amountReceived": 0,';
		json +='    "dateAccount": null,';
		json +='    "accountBatchNumber": null,';
		json +='    "subarea": {';
		json +='        "idSubarea": 9';
		json +='    },';
		json +='    "status": {';
		json +='        "idStatus": 4,';
		json +='        "description": "CRIADO"';
		json +='    },';
		json +='    "activity": {';
		json +='        "idActivity": 1';
		json +='    },';
		json +='    "currency": {';
		json +='        "idCurrency": 1,';
		json +='        "exchangeRate": 1,';
		json +='        "currencyCode": "BRL",';
		json +='        "currencyName": "Brazil - Real"';
		json +='    },';
		json +='    "conceptoGasto": {';
		json +='        "idConceptoGasto": 207,';
		json +='        "description": "SERVICO CRIACAO FOLHETOS SIMPLES POR PAGINA"';
		json +='    },';
		json +='    "provider": {';
		json +='        "id": 51557,';
		json +='        "code": 16274,';
		json +='        "providerName": "CIA BRASILEIRA DE DISTRIBUICAO"';
		json +='    },';
		json +='    "almacen": {';
		json +='        "idAlmacen": 25,';
		json +='        "description": "Sao Paulo"';
		json +='    }';
		json +='}';
		LAT_BR_IMM_RestCallHandler.GenericBodyIMM obj = (LAT_BR_IMM_RestCallHandler.GenericBodyIMM) System.JSON.deserialize(json, LAT_BR_IMM_RestCallHandler.GenericBodyIMM.class);
		return obj;
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

}