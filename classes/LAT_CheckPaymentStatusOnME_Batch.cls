global class LAT_CheckPaymentStatusOnME_Batch implements Database.Batchable < sObject > ,
Database.AllowsCallouts {

	String query;
	

	global LAT_CheckPaymentStatusOnME_Batch() {

}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		CS001_JDEInterfaceCredentials__c setting = CS001_JDEInterfaceCredentials__c.getInstance('Brasil');
		if (!setting.UseIMM__c) {
			query = 'SELECT Id, Status__c, IDMe__c,';
            query+= 'ApprovedPayment__c, LAT_Contract__c, RecordType.DeveloperName, WorkflowME__r.WorkflowNumber__c, WorkflowME__r.WF__c ';
			query+= 'FROM LAT_Payment__c where IDMe__c <> null AND Status__c <> \'E\' ';
		} else {
			//query = 'SELECT Id, Status__c, IDMe__c,IDPagoJDE__c, ApprovedPayment__c,productValue__c, LAT_Contract__c, (Select id, ProductGroup__r.name, ProductGroup__c,productValue__c, Volumen__c,Status__c, IDMe__c,IDPagoJDE__c, recordType.DeveloperName from Investimentos_Bonifica_es_e_Pagamentos__r), RecordType.DeveloperName, WorkflowME__r.WorkflowNumber__c, WorkflowME__r.WF__c FROM LAT_Payment__c where IDMe__c <> null AND Status__c <> \'E\' ';
            query = 'SELECT Id, Status__c,Sku_at_Integration__c, ';
            query+= 'IDMe__c,Status_IMM_Linea__c,IDPagoJDE__c,Ammount__c, ApprovedPayment__c,productValue__c, LAT_Contract__c,';
            query+= '(Select id,Name, ProductGroup__r.name, ProductGroup__c,productValue__c, Volumen__c,Status__c, IDMe__c,IDPagoJDE__c, recordType.DeveloperName,Status_IMM_Linea__c,Sku_at_Integration__c, EventPaymentCreatedAfterSigning__c, LAT_IsCommCondParentPayment__c from Investimentos_Bonifica_es_e_Pagamentos__r), ';
            query+= 'RecordType.DeveloperName, WorkflowME__r.WorkflowNumber__c, WorkflowME__r.WF__c FROM LAT_Payment__c where (ParentPayment__c = null or (LAT_IsCommCondParentPayment__c =true and EventPaymentCreatedAfterSigning__c = true)) and IDMe__c!=null and IDMe__c!=\'\' AND Status__c <> \'E\'';
		
		}

		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List < sObject > scope) {

		CS001_JDEInterfaceCredentials__c setting = CS001_JDEInterfaceCredentials__c.getInstance('Brasil');
		List < LAT_Payment__c > pagamentos = 
            (List < LAT_Payment__c > ) scope;
		List < LAT_Payment__c > toUpdate = 
            new List < LAT_Payment__c > ();

		system.debug('scope++' + pagamentos);
		for (LAT_Payment__c p: pagamentos) {

			System.debug('%%%%%%%%%%%%  pagamhento : ' + p);
			String statusME;
			if (p.RecordType.DeveloperName == 'LAT_PagamentoDinheiro') {
				//Consulto el servicio de ME para Payments del tipo Check
				if (!setting.UseIMM__c) {
					LAT_CheckStatusPaymentMoneyWS.WSConsultarPagtoChequeSoapBindingQSPort request = 
                        new LAT_CheckStatusPaymentMoneyWS.WSConsultarPagtoChequeSoapBindingQSPort();
					request.timeout_x = 120000;

					LAT_CheckStatusPaymentMoneyWS.SdtMsg message 
                        = new LAT_CheckStatusPaymentMoneyWS.SdtMsg();
					LAT_CheckStatusPaymentMoneyWS.WSConsultarPagtoCheque_ExecuteResponse_element responseHandler = new LAT_CheckStatusPaymentMoneyWS.WSConsultarPagtoCheque_ExecuteResponse_element();
					responseHandler = request.Execute(1, 81, p.WorkflowME__r.WF__c, Integer.valueOf(p.WorkflowME__r.WorkflowNumber__c), Integer.valueOf(p.IDMe__c));
					//responseHandler = request.Execute(1, 81, 'CI', 224, Integer.valueOf(p.IDMe__c));
					//(Integer Paicod,Integer Empcod,String Tdocod,Integer Domnro,Integer Seqreq)
					System.debug('=======================\n message Money: ' + responseHandler + '\n=======================');
					if (!Test.isRunningTest()) {
						if (responseHandler.Status != null && responseHandler.Status != '') {
							statusME = responseHandler.Status;
						}
					} else {
						statusME = 'E';
					}
				} else {
					try {
						LAT_BR_IMM_RestCallHandler.GenericBodyIMM resp = LAT_BR_IMM_RestCallHandler.getCashPayment(p.IDMe__c);

						if (LAT_IMM_IntegrateService.updatePaymentFields(resp, p)){
							toUpdate.add(p);
							System.debug('%%% agrego a toUpdate p.Id: ' + p.Id);
							for (LAT_Payment__c childpay: p.Investimentos_Bonifica_es_e_Pagamentos__r) {
								System.debug('%%% agrego a toUpdate p.Id: ' + childpay.Id);
								toUpdate.add(childpay);
							}
						}

					} catch (LAT_BR_IMM_RestCallHandler.IMMException e){
						system.debug('Error en obtener Datos: +' + p.Id);
					} catch (Exception e) {
						system.debug('Error desconocido para: +' + p.Id);
						system.debug('Error desconocido para: +' + e.getStackTraceString());
					}
					// CALL IMMM SERV
				}

			} else if (p.RecordType.DeveloperName == 'LAT_PagamentoProduto') {
				system.debug('LAT_PagamentoProduto++');
				if (!setting.UseIMM__c) {
					//Consulto el servicio de ME para Payments del tipo Producto
					LAT_CheckStatusPaymentProductWS.WSConsultarPagtoProdutoSoapBindingQSPort request = 
                        new LAT_CheckStatusPaymentProductWS.WSConsultarPagtoProdutoSoapBindingQSPort();
					request.timeout_x = 120000;
					LAT_CheckStatusPaymentProductWS.SdtMsg message = new LAT_CheckStatusPaymentProductWS.SdtMsg();
					LAT_CheckStatusPaymentProductWS.WSConsultarPagtoProduto_ExecuteResponse_element responseHandler = 
                        new LAT_CheckStatusPaymentProductWS.WSConsultarPagtoProduto_ExecuteResponse_element();
					// to do, add try catch
					responseHandler = request.Execute(1, 81, p.WorkflowME__r.WF__c, Integer.valueOf(p.WorkflowME__r.WorkflowNumber__c), Integer.valueOf(p.IDMe__c));
					//responseHandler = request.Execute(1, 81, 'CI', 224, Integer.valueOf(p.IDMe__c));
					System.debug('=======================\n message Prod: ' + responseHandler + '\n=======================');
					if (!Test.isRunningTest()) {
						if (responseHandler.Produtos.Produtos_ProdutosItem != null) {
							statusME = responseHandler.Produtos.Produtos_ProdutosItem[0].Status;
						}
					} else {
						statusME = 'E';
					}
				} else {

					try{
						LAT_BR_IMM_RestCallHandler.GenericBodyIMM resp = LAT_BR_IMM_RestCallHandler.getFreeGood(p.IDMe__c);
						if (LAT_IMM_IntegrateService.updatePaymentFields(resp, p)){
							System.debug('%%% agrego a toUpdate p.Id: ' + p.Id);
							toUpdate.add(p);
						}
					} catch (LAT_BR_IMM_RestCallHandler.IMMException e){
						system.debug('Error en obtener Datos: +' + p.Id);
					} catch (Exception e) {
						system.debug('Error desconocido para: +' + p.Id);
						system.debug('Error desconocido para: +' + e.getStackTraceString());
					}
					// call imm service
				}

			} else if (setting.UseIMM__c && p.RecordType.DeveloperName == 'LAT_PaymentGroup') {
				system.debug('paymentGroup++');
				if (p.Ammount__c != null && p.Ammount__c != 0) {
					system.debug('amonnt no zer++');
					try {
						LAT_BR_IMM_RestCallHandler.GenericBodyIMM resp = LAT_BR_IMM_RestCallHandler.getCashPayment(p.IDMe__c);
						if (LAT_IMM_IntegrateService.updatePaymentGroupDinheroFields(resp, p)){
							System.debug('%%% agrego a toUpdate p.Id: ' + p.Id);
							toUpdate.add(p);
						}
						for (LAT_Payment__c childpay: p.Investimentos_Bonifica_es_e_Pagamentos__r) {
								System.debug('%%% agrego a toUpdate childpay: ' + childpay.Id);
								toUpdate.add(childpay);
							}
					} catch (LAT_BR_IMM_RestCallHandler.IMMException e){
						system.debug('Error en obtener Datos: +' + p.Id);
					} catch (Exception e) {
						system.debug('Error desconocido para: +' + p.Id);
						system.debug('Error desconocido para: +' + e.getStackTraceString());
					}

				} else {
					system.debug('amonnt zero++');
					try {
						LAT_BR_IMM_RestCallHandler.GenericBodyIMM resp = LAT_BR_IMM_RestCallHandler.getFreeGood(p.IDMe__c);
						if (LAT_IMM_IntegrateService.updatePaymentGroupProductosFields(resp, p)){
							system.debug('amonnt zero2++');
							System.debug('%%% agrego a toUpdate p.Id: ' + p.Id);
							toUpdate.add(p);
						}	
						for (LAT_Payment__c childpay: p.Investimentos_Bonifica_es_e_Pagamentos__r) {
							System.debug('%%% agrego a toUpdate p.Id: ' + childpay.Id);
							if(childpay.LAT_IsCommCondParentPayment__c && childpay.RecordType.DeveloperName == 'LAT_PagamentoDinheiro'){
								continue;
							}
							toUpdate.add(childpay);
						}
					} catch (LAT_BR_IMM_RestCallHandler.IMMException e){
						system.debug('Error en obtener Datos: +' + p.Id);
					} catch (Exception e) {
						system.debug('Error desconocido para: +' + p.Id);
						system.debug('Error desconocido para: +' + e.getStackTraceString());
					}
					
				}

			}

			// check if update is needed
			if (!setting.UseIMM__c) {
				if (statusME != p.Status__c) {

					p.Status__c = statusME;
					if (statusME == 'E') {
						p.PaymentDateDone__c = Date.today();
					}
					System.debug('%%% agrego a toUpdate p.Id: ' + p.Id);
					toUpdate.add(p);
				}
			}
		}
		Integer i = 0;
		for (LAT_Payment__c toup:toUpdate){
			system.debug('pagamento1++++' + i);
			i++;
			system.debug(toup.Status__c );
			system.debug(toup.Name );
			system.debug(toup.RecordType.DeveloperName );
			system.debug(toup.productValue__c);
		}
		update toUpdate;
	}




	/**public void generateSkuMap(List < LAT_Payment__c > payments) {
		Set < Id > products = new Set < Id > ();
		for (LAT_Payment__c pay: payments) {
			products.add(pay.ProductGroup__c);
		}

		List < LAT_ReferenceProduct__c > referenceProducts = [SELECT Id, Name, LAT_Product__c, LAT_Product__r.LAT_ProductCode__c, ReferenceGrouping__c FROM
		LAT_ReferenceProduct__c where ReferenceGrouping__c IN: products];

		Map < String,
		Integer > productsSKU = new Map < String,
		Integer > ();
		for (LAT_ReferenceProduct__c lrg: referenceProducts) {
			productsSKU.put(lrg.ReferenceGrouping__c, Integer.valueOf(lrg.LAT_Product__r.LAT_ProductCode__c));
		}
	}*/

	global void finish(Database.BatchableContext BC) {
		System.debug('Terminó el Batch de chequeo de Status de Pagamentos en ME/IMM. Gracias por su atención. :) by CantegrileArte & PandaSoft');
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

}