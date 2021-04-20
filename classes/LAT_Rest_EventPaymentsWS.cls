@RestResource(urlMapping='/LAT_Rest_EventPaymentsWS/*')
global without sharing class LAT_Rest_EventPaymentsWS {
    global static final String FINALITY_COMMERCIAL_CONDITION = 'Condição Comercial Off Invoice';

    @HttpPost
    global static void doPOST() {    	
        RestRequest req = RestContext.request;
        System.debug('Antes de todo ');
        System.debug('Body : ' + req.requestBody.toString());
        LAT_ContractHandlerJSON.Payment payment = (LAT_ContractHandlerJSON.Payment)System.JSON.deserialize(req.requestBody.toString(), LAT_ContractHandlerJSON.Payment.class);
    	System.debug('%%%% pagamento : ' +payment);
    	
    	String res = insertPayment(payment);

    	RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody   = Blob.valueOf(res);
		RestContext.response.statusCode     = 200;
	}

    @HttpPut
    global static void doPUT() {
    	
        RestRequest req = RestContext.request;
        System.debug('Antes de todo ');
        System.debug('Body : ' + req.requestBody.toString());
        LAT_ContractHandlerJSON.ListPayment payments = (LAT_ContractHandlerJSON.ListPayment)System.JSON.deserialize(req.requestBody.toString(), LAT_ContractHandlerJSON.ListPayment.class);
    	System.debug('%%%% pagamento : ' +payments);
    	
    	String res = groupPayments(payments);

    	RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody   = Blob.valueOf(res);
		RestContext.response.statusCode     = 200;
	}

    public static string insertPayment(LAT_ContractHandlerJSON.Payment pay){
        
        LAT_Payment__c nuevo = new LAT_Payment__c();
        nuevo.LAT_Contract__c = pay.contract;
        nuevo.Finality__c = pay.finality;
        if(pay.paymentDate != null && pay.paymentDate != ''){
            System.debug('%%%% pay.paymentDate : ' + pay.paymentDate);
            System.debug('%%%% pay.paymentDate.split(-) : ' + pay.paymentDate.split('-'));
            if(pay.paymentDate.split('-').size() == 2){
                String mes = pay.paymentDate.split('-')[0];
                System.debug('%%%% mes: ' + mes);
                String year = pay.paymentDate.split('-')[1];
                System.debug('%%%% mes: ' + year);
                pay.paymentDate = year + '-' + mes +'-01';
            }
            nuevo.PaymentDate__c = Date.valueOf(pay.paymentDate);
        }

        nuevo.EventType__c = pay.eventType;
        nuevo.ProductGroup__c = pay.productGroup;
        nuevo.RecordTypeId = pay.recordType;
        nuevo.Volumen__c = pay.volumen;
        if(pay.paymentDateDone != null && pay.paymentDateDone !='')
        nuevo.PaymentDateDone__c = Date.valueOf(pay.paymentDateDone);
        nuevo.Status__c = pay.status;
        nuevo.ReleaseReason__c = pay.releaseReason;
        nuevo.Ammount__c       = pay.ammount;
        nuevo.LAT_EventValue__c             = pay.valorEventoTotal;
        nuevo.LAT_EventCashValue__c         = pay.valorEventoCash;
        nuevo.LAT_EventProductValue__c      = pay.valorEventoProuto;
        nuevo.LAT_EventBoxQuantity__c       = pay.cajasProduto;
        nuevo.LAT_BonusPercent__c           = 0;
        nuevo.LAT_BonusQuantity__c           = 0;

        if (pay.imposto != null){
            nuevo.LAT_Taxes__c  = pay.imposto;
            nuevo.LAT_BonusPercent__c  = pay.imposto * 100;
            nuevo.LAT_BonusQuantity__c = pay.volumen - pay.volumen/(1+pay.imposto);
        }
            

        if (pay.EventPaymentCreatedAfterSigning != null)
            nuevo.EventPaymentCreatedAfterSigning__c    = pay.EventPaymentCreatedAfterSigning;
        if (pay.distribuitorId != null && pay.distribuitorId != '')
            nuevo.LAT_Distributor__c    = pay.distribuitorId;
        if(pay.producer != null ) nuevo.LAT_Producer__c = pay.producer;
        if(pay.id != null)
            if(pay.id.startsWith(LAT_Payment__c.sObjectType.getDescribe().getKeyPrefix())) nuevo.Id = pay.id;
    
        insert nuevo;
        return '{"Id":"'+nuevo.Id+'"}';
    }

    public static String  groupPayments(LAT_ContractHandlerJSON.ListPayment payments) {
        Set<String> paymentsIds = new Set<String>();
        List<LAT_Payment__c> lstPayments = null;
        
		for(LAT_ContractHandlerJSON.Payment pay : payments.payment){
			paymentsIds.add(pay.Id);
		}

		Map<String, LAT_Payment__c> paymentsToAnalize = new Map<String, LAT_Payment__c>([Select Id,EventType__c, LAT_Contract__c, Ammount__c, Finality__c, ProductGroup__c, PaymentDate__c,
                                                                            LAT_EventCashValue__c, LAT_EventProductValue__c, LAT_EventValue__c, Volumen__c,
                                                                            RecordTypeId, RecordType.DeveloperName, PaymentDateOriginal__c, FY__c, Status__c, IntegrationStatus__c,
                                                                            ReleaseReason__c, LAT_Distributor__c 
                                                                            FROM LAT_Payment__c where Id in: paymentsIds]);

		Map<String, Set<String>> groupedPayments = new Map<String, Set<String>>();
		System.debug('%%% Pagos a Analizar: \n '+paymentsToAnalize);
        Set<Id> productGroupIds = new Set<Id>();
		for(string p : paymentsToAnalize.keySet()){
			String externalId = paymentsToAnalize.get(p).PaymentDate__c.month()+'-'+paymentsToAnalize.get(p).PaymentDate__c.year() + '-' + paymentsToAnalize.get(p).Finality__c + '-';
            externalId +=  paymentsToAnalize.get(p).Finality__c==FINALITY_COMMERCIAL_CONDITION ?'LAT_PagamentoProduto':paymentsToAnalize.get(p).RecordType.Developername;
            System.debug('%%%% externalId: ' + externalId);
			if(groupedPayments.get(externalId) == null) {
				groupedPayments.put(externalId, new Set<String>{p});
			} else {
				groupedPayments.get(externalId).add(p);
			}
            if(paymentsToAnalize.get(p).ProductGroup__c !=  null){
                productGroupIds.add(paymentsToAnalize.get(p).ProductGroup__c);
            }
		}
        List<LAT_Payment__c> toUpdateReleaseResons = new List<LAT_Payment__c>();
        for(LAT_ContractHandlerJSON.Payment pay : payments.payment){
            if(paymentsToAnalize.get(pay.Id) <> null && pay.releaseReason != null){
                paymentsToAnalize.get(pay.Id).ReleaseReason__c = pay.releaseReason;
            }
		}

        System.debug('%%% productGroupIds:  \n '+productGroupIds);
        List<LAT_ReferenceProduct__c> refProds = [SELECT Id, LAT_Product__r.LAT_BottlesPerBox__c, ReferenceGrouping__c FROM LAT_ReferenceProduct__c 
                                                    WHERE ReferenceGrouping__c IN :productGroupIds];
        Map<Id, LAT_ReferenceProduct__c> refProdMap = new Map<Id, LAT_ReferenceProduct__c>();
        for(LAT_ReferenceProduct__c ref : refProds){
            refProdMap.put(ref.ReferenceGrouping__c, ref);
        }
        System.debug('%%% Pagos a Agrupados antes de generar hijos:  \n '+groupedPayments);
        generateCommercialConditionChilds(paymentsToAnalize.values(), refProdMap);
		System.debug('%%% Pagos a Agrupados despues de generar hijos:  \n '+groupedPayments);

		List<LAT_Payment__c> payToUpdate = new List<LAT_Payment__c>();
		List<String> payToCheckAndSendToApproval = new List<String>();

		// Iterate Map, if the lenght is 1, we should't agrupate the payment, and we can send to aproval
		for (String extId : groupedPayments.keySet()){
			if(groupedPayments.get(extId).size() == 1){
				System.debug('%%% Sin Padre: \n '+groupedPayments.get(extId));
				for(String myId : groupedPayments.get(extId)){
                    payToCheckAndSendToApproval.add(myId);
				}
			} else {
				System.debug('%%% Con Padre: \n '+groupedPayments.get(extId));
				LAT_Payment__c newPaymentGroup = new LAT_Payment__c();
				Id recordTypeId = Schema.SObjectType.LAT_Payment__c.getRecordTypeInfosByName().get('Payment Group').getRecordTypeId();
				newPaymentGroup.Ammount__c = 0;
				newPaymentGroup.recordTypeId = recordTypeId;
                newPaymentGroup.LAT_IsCommCondParentPayment__c = true;
                newPaymentGroup.EventPaymentCreatedAfterSigning__c = true;

				Date paymentdate = null;
                LAT_Payment__c newPaymentGroupDinheiro = newPaymentGroup.clone();
                
                
				for(String myId : groupedPayments.get(extId)){
					LAT_Payment__c paym = paymentsToAnalize.get(myId);
                    if(paym.LAT_Distributor__c!=null)
                        newPaymentGroup.LAT_Distributor__c = paym.LAT_Distributor__c;
					if (paymentdate == null || paymentdate < paym.PaymentDate__c ){
						system.debug('paymentdate++++2' + paymentdate);
						paymentdate = paym.PaymentDate__c ;
					}
					system.debug('paymentdate++++3' + paymentdate);
					newPaymentGroup.PaymentDate__c = newPaymentGroupDinheiro.PaymentDate__c  = paymentdate;

					if(paym.RecordType.Developername == 'LAT_PagamentoDinheiro'){
						newPaymentGroup.Ammount__c = newPaymentGroup.Ammount__c + paym.Ammount__c;
					} 
                    else if(paym.LAT_EventCashValue__c > 0){
                        newPaymentGroupDinheiro.Ammount__c = newPaymentGroupDinheiro.Ammount__c + paym.LAT_EventCashValue__c;
                    }
					newPaymentGroup.LAT_Contract__c = newPaymentGroupDinheiro.LAT_Contract__c = paym.LAT_Contract__c;
                    newPaymentGroup.Finality__c = newPaymentGroupDinheiro.Finality__c = paym.Finality__c;
                    newPaymentGroup.EventType__c = newPaymentGroupDinheiro.EventType__c = paym.EventType__c;
				}
                List<LAT_Payment__c> toInsert =new List<LAT_Payment__c>{newPaymentGroup};
                insert toInsert;
                System.debug('%%% se insertó el toInsert');
                if(newPaymentGroupDinheiro.Ammount__c > 0){
                    newPaymentGroupDinheiro.RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Payment__c'+'LAT_PagamentoDinheiro');
                    newPaymentGroupDinheiro.ParentPayment__c = newPaymentGroup.Id;
                    newPaymentGroupDinheiro.LAT_Distributor__c = newPaymentGroup.LAT_Distributor__c;

                    insert newPaymentGroupDinheiro;
                    System.debug('%%% se insertó el newPaymentGroupDinheiro');
                }

				payToCheckAndSendToApproval.add(newPaymentGroup.id);
                //if(newPaymentGroupDinheiro.Ammount__c > 0)
                  //  payToCheckAndSendToApproval.add(newPaymentGroupDinheiro.id);
                System.debug('%%% groupedPayments' + groupedPayments);   
				for(String myId : groupedPayments.get(extId)){
                    System.debug('%%% extId' + extId);
					LAT_Payment__c paym = paymentsToAnalize.get(myId);
                    paym.ParentPayment__c = newPaymentGroup.id;
					payToUpdate.add(paym);

                    System.debug('%%% paym' + paym);
				}
				System.debug('%%% Nuevo Payment Group:\n '+newPaymentGroup);

			}
		}
		System.debug('%%% PAgo a Actualizar: \n '+payToUpdate);
        System.debug('%%% payToCheckAndSendToApproval: \n '+payToCheckAndSendToApproval);

       
        update payToUpdate; 
        //update payToCheckAndSendToApproval;
        lstPayments = [SELECT ID, LAT_Send_to_Approval__c FROM LAT_Payment__c WHERE Id IN :payToCheckAndSendToApproval];
        for(LAT_Payment__c objPayment : lstPayments) {
            objPayment.LAT_Send_to_Approval__c = true;
        }

        update lstPayments;

        sendApprovalFuture(payToCheckAndSendToApproval);
        
		return JSON.serialize(payToCheckAndSendToApproval);
	} 

    @future
    public static void sendApprovalFuture(List<String> payToCheckAndSendToApproval){
        List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest>();
		for(String payId : payToCheckAndSendToApproval) {
            
            Approval.ProcessSubmitRequest submitRequest = new Approval.ProcessSubmitRequest();
			submitRequest.setComments('Submitting payment for approval.');
			submitRequest.setObjectId(payId);
			requests.add(submitRequest);
		}
        if(requests.size() > 0){
            Approval.process(requests);
        }
    }
    public static void generateCommercialConditionChilds(List<LAT_Payment__c> payments, Map<Id, LAT_ReferenceProduct__c> refProdMap){
        List<LAT_Payment__c> toInsert = new List<LAT_Payment__c>();
        for(LAT_Payment__c pay : payments){
            if(pay.Finality__c == FINALITY_COMMERCIAL_CONDITION){
                if(pay.LAT_EventCashValue__c > 0){
                    toInsert.add(createCommercialConditionCashPayment(pay));
                }  
                System.debug('%%%% pay.Volumen__c:' + pay.Volumen__c);
                System.debug('%%%% refProdMap.get(pay.ProductGroup__c):' + refProdMap.get(pay.ProductGroup__c));
                System.debug('%%%% refProdMap.get(pay.ProductGroup__c).LAT_Product__r.LAT_BottlesPerBox__c:' + refProdMap.get(pay.ProductGroup__c).LAT_Product__r.LAT_BottlesPerBox__c);
                if(Math.floor(pay.Volumen__c/refProdMap.get(pay.ProductGroup__c).LAT_Product__r.LAT_BottlesPerBox__c) > 0){
                    toInsert.add(createCommercialConditionProductPayment(pay, refProdMap));
                }  
                //pay.RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Payment__c'+'LAT_PaymentGroup'); 
            }
        }
        update payments;
        if(toInsert.size()>0) insert toInsert;
    }

    public static LAT_Payment__c createCommercialConditionCashPayment(LAT_Payment__c pay){
        LAT_Payment__c nuevo = new LAT_Payment__c();
        nuevo.RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Payment__c'+'LAT_PagamentoDinheiro');
        nuevo.Ammount__c = pay.LAT_EventCashValue__c;
        nuevo.ParentPayment__c = pay.Id;
        nuevo.PaymentDate__c  = pay.PaymentDate__c;
        nuevo.LAT_Contract__c  = pay.LAT_Contract__c;
        nuevo.ReleaseReason__c  = pay.ReleaseReason__c;
        nuevo.LAT_Distributor__c  = pay.LAT_Distributor__c;
        nuevo.PaymentDateOriginal__c  = pay.PaymentDateOriginal__c;
        nuevo.CurrencyIsoCode = 'BRL';
        nuevo.Status__c = pay.Status__c;
        nuevo.IntegrationStatus__c = pay.IntegrationStatus__c;
        nuevo.Finality__c = pay.Finality__c;
        nuevo.EventPaymentCreatedAfterSigning__c = true;
        return nuevo;
    }
    public static LAT_Payment__c createCommercialConditionProductPayment(LAT_Payment__c pay, Map<Id, LAT_ReferenceProduct__c> refProdMap){
        LAT_Payment__c nuevo = new LAT_Payment__c();
        nuevo.RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Payment__c'+'LAT_PagamentoProduto');
        nuevo.ProductGroup__c           = pay.ProductGroup__c;
        nuevo.Volumen__c                = Math.floor(pay.Volumen__c/refProdMap.get(pay.ProductGroup__c).LAT_Product__r.LAT_BottlesPerBox__c);
        nuevo.ParentPayment__c          = pay.Id;
        nuevo.PaymentDate__c            = pay.PaymentDate__c;
        nuevo.LAT_Contract__c           = pay.LAT_Contract__c;
        nuevo.ReleaseReason__c          = pay.ReleaseReason__c;
        nuevo.LAT_Distributor__c        = pay.LAT_Distributor__c;
        nuevo.PaymentDateOriginal__c    = pay.PaymentDateOriginal__c;
        nuevo.CurrencyIsoCode           = 'BRL';
        nuevo.Status__c                 = pay.Status__c;
        nuevo.IntegrationStatus__c      = pay.IntegrationStatus__c;
        nuevo.Finality__c = pay.Finality__c;
        nuevo.EventPaymentCreatedAfterSigning__c = true;
        nuevo.LAT_ComConditionChilldAuxPayment__c = true;
        return nuevo;
    }
}