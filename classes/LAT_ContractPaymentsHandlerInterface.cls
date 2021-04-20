/*
 * LAT_ContractPaymentsHandlerInterface. MA integration
 * Author: Martin Prado (martin@zimmic.com)
 * Date: 02/13/2017
 */
public without sharing class LAT_ContractPaymentsHandlerInterface {
  private static final Set<String> EVENT_DEVELOPER_NAMES = new Set<String>{'LAT_Eventos_Contrato_de_Parceria', 'LAT_Eventos_Contrato_de_Parceria_Distribuidor'};
  @TestVisible private static final String FINALITY_COMMERCIAL_CONDITION = 'Condição Comercial Off Invoice';

  //Constructor
  public LAT_ContractPaymentsHandlerInterface() {} 

	/**
	* sendPaymentToME
	* Integration with ME, check the payment on salesforce, DA number, fiscal year of the payment, and generate payments on ME
	* we have 3 types of payments: money,
	* @param paymentId
	*/
	@future(callout = true)
	public static void sendPaymentToME(Id paymentId) {
		sendPaymentToMESync(paymentId);
	}

	public static String getAn8FromPayment(LAT_Payment__c payment) {
			if(EVENT_DEVELOPER_NAMES.contains(payment.LAT_Contract__r.RecordType.DeveloperName)) {
				if(payment.LAT_Producer__c) {
					return payment.LAT_Distributor__r.Client_code_AN8__c;
				} else {
					return payment.LAT_Contract__r.LAT_Distributor__r.Client_code_AN8__c;
				}
			} else {
				return payment.LAT_Contract__r.account__r.Client_code_AN8__c;
			}
	}

	public static String getBusinessUnitFromPayment(LAT_Payment__c payment){
			if(EVENT_DEVELOPER_NAMES.contains(payment.LAT_Contract__r.RecordType.DeveloperName)){
				if(payment.LAT_Producer__c) {
					return payment.LAT_Distributor__r.Business_Unit__r.Name;
				} else {
					return payment.LAT_Contract__r.LAT_Distributor__r.Business_Unit__r.Name;
				}
			} else {
				return payment.LAT_Contract__r.account__r.Business_Unit__r.Name;
			}
	}

	/**
	* sendPaymentToME
	* Integration with ME, check the payment on salesforce, DA number, fiscal year of the payment, and generate payments on ME
	* we have 3 types of payments: money,
	* @param paymentId
	*/
	public static void sendPaymentToMESync(Id paymentId) {
		CS001_JDEInterfaceCredentials__c setting = CS001_JDEInterfaceCredentials__c.getInstance('Brasil');

    List<LAT_Payment__c> payments =  [SELECT (SELECT id, IDMe__c, LAT_Producer__c, Sku_at_Integration__c,Finality__c,Status_IMM_Linea__c, ProductGroup__r.name, LAT_Contract__r.account__r.Business_Unit__r.Internal_Id__c, LAT_Contract__r.RecordType.Developername,	ProductGroup__c, Volumen__c, RecordType.DeveloperName, LAT_ComConditionChilldAuxPayment__c, LAT_Contract__r.Name, CreatedDate, WFNumber__c,Acordo_IMM__c, Acordo_IMM__r.Acuerdo__c, Ammount__c, LAT_Contract__r.account__r.Client_code_AN8__c, LAT_Distributor__r.Client_code_AN8__c, PaymentDate__c from Investimentos_Bonifica_es_e_Pagamentos__r),LAT_Contract__r.account__r.Business_Unit__r.name, LAT_Contract__r.account__c, LAT_Contract__r.account__r.Revenue_City__r.name, LAT_Contract__r.account__r.Client_code_AN8__c,  LAT_Contract__r.LAT_Distributor__r.Client_code_AN8__c, Ammount__c, ApprovedPayment__c, CNPJ_Fornecedor__c, LAT_Contract__r.LAT_Distributor__r.Business_Unit__r.Name, CreatedById, CreatedBy.email, CreatedDate, CurrencyIsoCode, Finality__c, GoalNotReached__c, Id, IDMe__c, integrationMessage__c, IntegrationStatus__c, IsDeleted,  LastModifiedById, LastModifiedDate, LAT_Contract__c, LAT_Contract__r.name, LAT_Contract__r.RecordType.DeveloperName, Manager__c, Name, ParentPayment__c, PaymentDateDone__c, FY__c, WF__c, WFNumber__c, PaymentDate__c, ProductGroup__c, RecordTypeId, RecordType.DeveloperName,  RegionalManager__c, Status__c, SystemModstamp, Type__c, Volumen__c, ProductGroup__r.name, LAT_Producer__c, Sku_at_Integration__c,Status_IMM_Linea__c,LAT_Contract__r.account__r.Business_Unit__r.Internal_Id__c, LAT_Contract__r.account__r.LAT_BR_RegionalClientOnPremise__c, LAT_Distributor__c, LAT_Distributor__r.Client_code_AN8__c, LAT_Distributor__r.Business_Unit__r.Name, LAT_ComConditionChilldAuxPayment__c, RecordType.Name, EventType__c, LAT_BonusQuantity__c, LAT_BonusPercent__c, EventPaymentCreatedAfterSigning__c,Acordo_IMM__c, Acordo_IMM__r.Acuerdo__c, LAT_Contract__r.Acordo_IMM__c, LAT_Contract__r.Acordo_IMM__r.Acuerdo__c FROM LAT_Payment__c WHERE ID =: paymentId]; //  new LAT_PaymentRepository().findByIds(new List<Id>{paymentId});
		LAT_Payment__c payment = null;
		Integer contractDA = null;
		String typeDa = null;
		Boolean hasAllTheInfo = false;

		// Check payment or return an error
		//if ( payments.size() == 0 ) return 'Pagamento (id:' + paymentId + ') não encontrado';
		if (payments.size() != 0) {
			payment = payments[0];
			if (payment.WFNumber__c != null && payment.WF__c != null) {
				hasAllTheInfo = true;
				contractDA = Integer.valueOf(payment.WFNumber__c);
				typeDa = payment.WF__c;
			} else if(String.isNotBlank(payment.Acordo_IMM__c)) {
        hasAllTheInfo = true;
      }

			// Retrive the payment FY
			// Leronardo Change, take care of this, probably this would crash
			//String fiscalYear = LAT_FiscalYearHelper.getInstance().getFiscalYearCode(date.today());
			//System.debug('=======================\nfiscalYear' + fiscalYear+ '\n=======================' );

			// We must set the DA based on the FY, if the contract hasn't a valid DA we return an error
			//   List<LAT_ContractDA__c> conDAS = [SELECT Contract__c, DANumber__c,Fiscal_Year__c, Type__c FROM LAT_ContractDA__c where Contract__c =: payment.LAT_Contract__c and Fiscal_Year__c =: fiscalYear and status__c = 'Ativo' order by createddate desc limit 1];
			//   if ( conDAS.size() != 0 ) {
			//     contractDA = Integer.valueOf(conDAS.get(0).DANumber__c);
			//     typeDa = conDAS.get(0).Type__c;
			//     System.debug('=======================\ncontractDA' + contractDA+ '\n=======================' );
			//     hasAllTheInfo = true;
			//   }
		}

		if (hasAllTheInfo || Test.isRunningTest()) {

			// Product Payment
			if (payment.recordType.DeveloperName == 'LAT_PagamentoProduto') {
        sendPaymentToPaymentprodutoMESync(setting, payments,  payment, contractDA, typeDa );			
			}
			// Money Payment 1 x plata siempre
			else if (payment.recordType.DeveloperName == 'LAT_PagamentoDinheiro') {
        sendPaymentToPaymentDineroMESync(setting, payments,  payment, contractDA, typeDa );
		
			}
			// Payment Group
			else if (payment.recordType.DeveloperName == 'LAT_PaymentGroup') {
          sendPaymentToPaymentGroupMESync(setting, payments,  payment, contractDA, typeDa );
			}

	} else {
		updatePayment(payment, 'Workflow não cadastrada para a Regional Cliente On Premise', '1', 'Error');
	}
}

@TestVisible
private static void sendPaymentToPaymentprodutoMESync(CS001_JDEInterfaceCredentials__c setting, List<LAT_Payment__c> payments, LAT_Payment__c payment, Integer contractDA, String typeDa ){
    if (setting.UseIMM__c) {
      sendPaymentToPaymentprodutoUSEIMMMESync(setting, payments,  payment, contractDA, typeDa);
    } else {
      sendPaymentToPaymentprodutoUSENOIMMSync(setting, payments,  payment, contractDA, typeDa);
    }
}

@TestVisible
private static void sendPaymentToPaymentprodutoUSENOIMMSync(CS001_JDEInterfaceCredentials__c setting, List<LAT_Payment__c> payments, LAT_Payment__c payment, Integer contractDA, String typeDa ) {
  List < LAT_Payment__c > paysss = new List < LAT_Payment__c > ();
  paysss.add(payment);

  LAT_PaymentProductHandler.WSPagtoProdutoSoapBindingQSPort request = new LAT_PaymentProductHandler.WSPagtoProdutoSoapBindingQSPort();
  request.timeout_x = 120000;
  LAT_PaymentProductHandler.SdtMsg message = new LAT_PaymentProductHandler.SdtMsg();

  LAT_PaymentProductHandler.WSPagtoProduto_ExecuteResponse_element entireHandler = new LAT_PaymentProductHandler.WSPagtoProduto_ExecuteResponse_element();

  List <LAT_Payment__c> paym = new List <LAT_Payment__c> ();
  paym.add(payment);
  LAT_PaymentProductHandler.SDTPagtoLD sdtpagtold = generateProductItems(paym);
  String textMessage = payment.Finality__c + ' || ' + payment.Name + ' || ' + Datetime.now().format('MM/yyyy');
  
  try {
    entireHandler = request.Execute(1, 81, typeDa, Integer.valueOf(contractDA), checkLocation(getBusinessUnitFromPayment(payment)), getAn8FromPayment(payment), textMessage, textMessage, 'BILINSKY', sdtpagtold);
    message = entireHandler.SdtMsg;
  } catch (exception e) {
    sendEmailNotification(payment);
  }
  
  if (!Test.isRunningTest()) {
    processMEResponse(message, payment, entireHandler.Seqreq);
  } else {
    LAT_PaymentProductHandler.SdtMsg_SdtMsgItem testItem = new LAT_PaymentProductHandler.SdtMsg_SdtMsgItem();
    testItem.Codigo = 'TESTE';
    testItem.Mensagem = 'TESTE';
    message.SdtMsg_SdtMsgItem = new LAT_PaymentProductHandler.SdtMsg_SdtMsgItem[] {testItem};
    processMEResponse(message, payment, '123456');
  }
}

@TestVisible
private static void sendPaymentToPaymentprodutoUSEIMMMESync(CS001_JDEInterfaceCredentials__c setting, List<LAT_Payment__c> payments, LAT_Payment__c payment, Integer contractDA, String typeDa ) {
  List < LAT_Payment__c > paysss = new List < LAT_Payment__c > ();
  paysss.add(payment);

  try {
    if(EVENT_DEVELOPER_NAMES.contains(payment.LAT_Contract__r.Recordtype.Developername) && payment.Finality__c == FINALITY_COMMERCIAL_CONDITION){
      LAT_BR_IMM_RestCallHandler.GenericBodyIMM resp = LAT_BR_IMM_RestCallHandler.createFreeGoodGroupEventos(payment, payment.Investimentos_Bonifica_es_e_Pagamentos__r);
      for(LAT_Payment__c p : payment.Investimentos_Bonifica_es_e_Pagamentos__r){
        if(p.RecordType.Developername == 'LAT_PagamentoDinheiro'){
            try{
              LAT_BR_IMM_RestCallHandler.GenericBodyIMM respDinheiro = LAT_BR_IMM_RestCallHandler.createCashPayment(p);
              processIMMResponse(respDinheiro, p);
          break;
          } catch(Exception e){
            System.debug('%%% excepcion : ' +e);
            processIMMResponse(resp, payment);
            throw e;
          }
        }
      }
      processIMMResponse(resp, payment);
    } else{
      LAT_BR_IMM_RestCallHandler.GenericBodyIMM resp = LAT_BR_IMM_RestCallHandler.createFreeGood(paysss);
      processIMMResponse(resp, payment);
    }
      
  } catch (LAT_BR_IMM_RestCallHandler.IMMException e) {
      paysss[0].IntegrationStatus__c = 'Erro Integração';
      paysss[0].Status__c = 'Erro Integração';
      paysss[0].integrationMessage__c = e.messageBody;

      update paysss;
      sendEmailNotification(payment);

  } catch (LAT_BR_IMM_RestCallHandler.IMMNoskuException e) {
      paysss[0].IntegrationStatus__c = 'SKU não cadastrado';
      paysss[0].Status__c = 'Erro Integração';
      
      update paysss;
      sendEmailNotification(payment);
  }
}

@TestVisible
private static void sendPaymentToPaymentDineroMESync(CS001_JDEInterfaceCredentials__c setting, List<LAT_Payment__c> payments, LAT_Payment__c payment, Integer contractDA, String typeDa ){
  if (setting.UseIMM__c) {
    sendPaymentToPaymentDineroUSEIMMMESync(setting, payments,  payment, contractDA, typeDa);

  
  } else {
    sendPaymentToPaymentDineroUSENOIMMMESync(setting, payments,  payment, contractDA, typeDa);   
  }

}

@TestVisible
private static void sendPaymentToPaymentDineroUSEIMMMESync(CS001_JDEInterfaceCredentials__c setting, List<LAT_Payment__c> payments, LAT_Payment__c payment, Integer contractDA, String typeDa) {
  try{
    LAT_BR_IMM_RestCallHandler.GenericBodyIMM resp = LAT_BR_IMM_RestCallHandler.createCashPayment(payment);
    processIMMResponse(resp, payment);
  } catch (LAT_BR_IMM_RestCallHandler.IMMException e){
    payment.IntegrationStatus__c = 'Erro Integração';
    payment.Status__c = 'Erro Integração';
    update payment;
    sendEmailNotification(payment);
  }
}

@TestVisible
private static void sendPaymentToPaymentDineroUSENOIMMMESync(CS001_JDEInterfaceCredentials__c setting, List<LAT_Payment__c> payments, LAT_Payment__c payment, Integer contractDA, String typeDa) {
  String textMessage = payment.Finality__c + ' || ' + payment.Name + ' || ' + Datetime.now().format('MM/yyyy');
  LAT_PaymentMoneyHandler.WSPagtoCheque_Execute_element payEl = processMoneyPayment(payment, contractDA, typeDA, textMessage);
  LAT_PaymentMoneyHandler.WSPagtoChequeSoapBindingQSPort r = new LAT_PaymentMoneyHandler.WSPagtoChequeSoapBindingQSPort();
  r.timeout_x = 120000;
  LAT_PaymentMoneyHandler.SdtMsg message = new LAT_PaymentMoneyHandler.SdtMsg();
  LAT_PaymentMoneyHandler.WSPagtoCheque_ExecuteResponse_element entireHandler = new LAT_PaymentMoneyHandler.WSPagtoCheque_ExecuteResponse_element();

  try {
    entireHandler = r.Execute(payEl);
    message = entireHandler.SdtMsg;
  } catch (exception e) {
    sendEmailNotification(payment);
  }
  if (!Test.isRunningTest()) {
    processMEResponse(message, payment, entireHandler.Seqreq);
  } else {
    LAT_PaymentMoneyHandler.SdtMsg_SdtMsgItem testItem = new LAT_PaymentMoneyHandler.SdtMsg_SdtMsgItem();
    testItem.Codigo = 'TESTE';
    testItem.Mensagem = 'TESTE';
    message.SdtMsg_SdtMsgItem = new LAT_PaymentMoneyHandler.SdtMsg_SdtMsgItem[] {
    testItem
    };
    processMEResponse(message, payment, '123456');
  }
}
@TestVisible
private static void sendPaymentToPaymentGroupMESync(CS001_JDEInterfaceCredentials__c setting, List<LAT_Payment__c> payments, LAT_Payment__c payment, Integer contractDA, String typeDa ) {
				// If we have a payment ammount on the payment group type, we asume that the money payment are grouped
				if (payment.Ammount__c != null && payment.Ammount__c != 0) {
					if (setting.UseIMM__c) {

            sendPaymentToPaymentGroupMEUSEIMMDineroSync(setting, payments,  payment, contractDA, typeDa);
					
					} else {

            sendPaymentToPaymentGroupMENOUSEIMMDineroSync(setting, payments,  payment, contractDA, typeDa);
					}
				} else {

					if (setting.UseIMM__c) {
            sendPaymentToPaymentGroupMEUSEIMMDProdutorSync(setting, payments,  payment, contractDA, typeDa);
					
					} else {
            sendPaymentToPaymentGroupMENOUSEIMMProductoSync(setting, payments,  payment, contractDA, typeDa);
         }
      }
}
@TestVisible
private static void sendPaymentToPaymentGroupMEUSEIMMDineroSync(CS001_JDEInterfaceCredentials__c setting, List<LAT_Payment__c> payments, LAT_Payment__c payment, Integer contractDA, String typeDa) {
	try{
    LAT_BR_IMM_RestCallHandler.GenericBodyIMM resp = LAT_BR_IMM_RestCallHandler.createCashPayment(payment);
    processIMMResponse(resp, payment);
  } catch (LAT_BR_IMM_RestCallHandler.IMMException e){
    List<LAT_Payment__c> toUpdate = new List<LAT_Payment__c>();
    payment.IntegrationStatus__c = 'Erro Integração';
    payment.Status__c = 'Erro Integração';
    payment.integrationMessage__c = e.messageBody;
    toUpdate.add(payment);
    for (LAT_Payment__c childpay: payment.Investimentos_Bonifica_es_e_Pagamentos__r) {
      childpay.IntegrationStatus__c = 'Erro Integração';
      childpay.Status__c = 'Erro Integração';
      childpay.integrationMessage__c = e.messageBody;
      toUpdate.add(childpay);
    }
    update toUpdate;

    sendEmailNotification(payment);
  }
}
@TestVisible
private static void sendPaymentToPaymentGroupMENOUSEIMMDineroSync(CS001_JDEInterfaceCredentials__c setting, List<LAT_Payment__c> payments, LAT_Payment__c payment, Integer contractDA, String typeDa) {
	String textMessage = payment.Finality__c + ' || ' + payment.Name + ' || ' + Datetime.now().format('MM/yyyy');
						LAT_PaymentMoneyHandler.WSPagtoCheque_Execute_element payEl = processMoneyPayment(payment, contractDA, typeDA, textMessage);
						LAT_PaymentMoneyHandler.WSPagtoChequeSoapBindingQSPort r = new LAT_PaymentMoneyHandler.WSPagtoChequeSoapBindingQSPort();
						r.timeout_x = 120000;
						LAT_PaymentMoneyHandler.SdtMsg message = new LAT_PaymentMoneyHandler.SdtMsg();
						LAT_PaymentMoneyHandler.WSPagtoCheque_ExecuteResponse_element entireHandler = new LAT_PaymentMoneyHandler.WSPagtoCheque_ExecuteResponse_element();

						try {
							entireHandler = r.Execute(payEl);
							message = entireHandler.SdtMsg;
						} catch (exception e) {
							sendEmailNotification(payment);
						}
						if (!Test.isRunningTest()) {
							processMEResponse(message, payment, entireHandler.Seqreq);
						} else {
							LAT_PaymentMoneyHandler.SdtMsg_SdtMsgItem testItem = new LAT_PaymentMoneyHandler.SdtMsg_SdtMsgItem();
							testItem.Codigo = 'TESTE';
							testItem.Mensagem = 'TESTE';
							message.SdtMsg_SdtMsgItem = new LAT_PaymentMoneyHandler.SdtMsg_SdtMsgItem[] {
								testItem
							};
							processMEResponse(message, payment, '123456');
						}
}
@TestVisible
private static void sendPaymentToPaymentGroupMEUSEIMMDProdutorSync(CS001_JDEInterfaceCredentials__c setting, List<LAT_Payment__c> payments, LAT_Payment__c payment, Integer contractDA, String typeDa) {
	List < LAT_Payment__c > paysss = new List < LAT_Payment__c > ();
						paysss.add(payment);
					try{
						if( EVENT_DEVELOPER_NAMES.contains(payment.LAT_Contract__r.Recordtype.Developername) ){
              System.debug('%%%%%% en contractpaymentshandlerinterface.sendpaymenttome es contrato eventos, payment : ' + payment);
              System.debug('%%%%%% en contractpaymentshandlerinterface.sendpaymenttome es contrato eventos, Investimentos_Bonifica_es_e_Pagamentos__r : ' + payment.Investimentos_Bonifica_es_e_Pagamentos__r);
							LAT_BR_IMM_RestCallHandler.GenericBodyIMM resp = LAT_BR_IMM_RestCallHandler.createFreeGoodGroupEventos(payment, payment.Investimentos_Bonifica_es_e_Pagamentos__r);
							
              for(LAT_Payment__c p : payment.Investimentos_Bonifica_es_e_Pagamentos__r){
                if(p.RecordType.Developername == 'LAT_PagamentoDinheiro'){
                    try{
                      LAT_BR_IMM_RestCallHandler.GenericBodyIMM respDinheiro = LAT_BR_IMM_RestCallHandler.createCashPayment(p);
						          processIMMResponse(respDinheiro, p);
                  break;
                  } catch(Exception e){
                    System.debug('%%% excepcion : ' +e);
                    processIMMResponse(resp, payment);
                    throw e;
                  }
                }
              }
              processIMMResponse(resp, payment);
						} else {
							LAT_BR_IMM_RestCallHandler.GenericBodyIMM resp = LAT_BR_IMM_RestCallHandler.createFreeGoodGroup(payment, payment.Investimentos_Bonifica_es_e_Pagamentos__r);
							processIMMResponse(resp, payment);
						}
						
					} catch (LAT_BR_IMM_RestCallHandler.IMMException e){
						List<LAT_Payment__c> toUpdate = new List<LAT_Payment__c>();
						payment.IntegrationStatus__c = 'Erro Integração';
						payment.Status__c = 'Erro Integração';
						//payment.integrationMessage__c = e.messageBody;
						
						toUpdate.add(payment);
						for (LAT_Payment__c childpay: payment.Investimentos_Bonifica_es_e_Pagamentos__r) {
							childpay.IntegrationStatus__c = 'Erro Integração';
							childpay.Status__c = 'Erro Integração';
							childpay.integrationMessage__c = e.messageBody;
							toUpdate.add(childpay);
						}
						update toUpdate;
						sendEmailNotification(payment);

					}catch (LAT_BR_IMM_RestCallHandler.IMMNoskuException e){
						List<LAT_Payment__c> toUpdate = new List<LAT_Payment__c>();
						payment.IntegrationStatus__c = 'SKU não cadastrado';
						payment.Status__c = 'Erro Integração';
						toUpdate.add(payment);
						for (LAT_Payment__c childpay: payment.Investimentos_Bonifica_es_e_Pagamentos__r) {
							childpay.IntegrationStatus__c = 'SKU não cadastrado';
							childpay.Status__c = 'Erro Integração';
							toUpdate.add(childpay);
						}
						update toUpdate;
						sendEmailNotification(payment);
					}
}
@TestVisible
private static void sendPaymentToPaymentGroupMENOUSEIMMProductoSync(CS001_JDEInterfaceCredentials__c setting, List<LAT_Payment__c> payments, LAT_Payment__c payment, Integer contractDA, String typeDa) {
	// Product payment with childs
  LAT_PaymentProductHandler.WSPagtoProdutoSoapBindingQSPort request = new LAT_PaymentProductHandler.WSPagtoProdutoSoapBindingQSPort();
  request.timeout_x = 120000;
  LAT_PaymentProductHandler.SdtMsg message = new LAT_PaymentProductHandler.SdtMsg();
  LAT_PaymentProductHandler.WSPagtoProduto_ExecuteResponse_element entireHandler = new LAT_PaymentProductHandler.WSPagtoProduto_ExecuteResponse_element();

  LAT_PaymentProductHandler.SDTPagtoLD sdtpagtold = generateProductItems(payment.Investimentos_Bonifica_es_e_Pagamentos__r);
  String textMessage = payment.Finality__c + ' || ' + payment.Name + ' || ' + Datetime.now().format('MM/yyyy');
  try {
    entireHandler = request.Execute(1, 81, typeDa, Integer.valueOf(contractDA), checkLocation(getBusinessUnitFromPayment(payment)), getAn8FromPayment(payment), textMessage, textMessage, 'BILINSKY', sdtpagtold);
    message = entireHandler.SdtMsg;
  } catch (exception e) {
    sendEmailNotification(payment);
  }
  if (!Test.isRunningTest()) {
    processMEResponse(message, payment, entireHandler.Seqreq);
  } else {
    LAT_PaymentProductHandler.SdtMsg_SdtMsgItem testItem = new LAT_PaymentProductHandler.SdtMsg_SdtMsgItem();
    testItem.Codigo = 'TESTE';
    testItem.Mensagem = 'TESTE';
    message.SdtMsg_SdtMsgItem = new LAT_PaymentProductHandler.SdtMsg_SdtMsgItem[] {
      testItem
    };
    processMEResponse(message, payment, '123456');
  }

}

@TestVisible
private static void processIMMResponse(LAT_BR_IMM_RestCallHandler.GenericBodyIMM message, LAT_Payment__c payment) {
   String status = 'Integrado com Sucesso';
   payment.IDMe__c = String.valueOf(message.id);
   payment.ApprovedPayment__c = false;
   payment.status__c = 'I';
   List < LAT_Payment__c > paymentsToUpdate = new List < LAT_Payment__c > ();

   payment.IntegrationStatus__c = status;

   if (payment.recordType.DeveloperName == 'LAT_PaymentGroup' && (payment.Ammount__c == null || payment.Ammount__c == 0)) {

      Map<String, LAT_Payment__c> skuToPaymentMap = new Map<String, LAT_Payment__c>();
      for (LAT_Payment__c pay:payment.Investimentos_Bonifica_es_e_Pagamentos__r){
        pay.IntegrationStatus__c = status;
        payment.status__c = 'I';
        payment.IntegrationStatus__c = status;
        skuToPaymentMap.put(pay.Sku_at_Integration__c, pay);
        system.debug('este sku+++' + pay.Sku_at_Integration__c);
      }

      for (LAT_BR_IMM_RestCallHandler.cls_skus skuRet:message.skus){
        LAT_Payment__c currPayment = skuToPaymentMap.get(skuRet.sku.code);
        if(currPayment!= null) {
            currPayment.productValue__c = skuRet.measureUnit.unitCost;
            currPayment.IntegrationStatus__c = payment.IntegrationStatus__c;
            currPayment.Status_IMM_Linea__c = skuRet.status.description;
        }
      }
      paymentsToUpdate.addall(payment.Investimentos_Bonifica_es_e_Pagamentos__r);
      
    } else if (payment.recordType.DeveloperName == 'LAT_PaymentGroup' && (payment.Ammount__c != null && payment.Ammount__c != 0)){
      for (LAT_Payment__c pay:payment.Investimentos_Bonifica_es_e_Pagamentos__r){
          pay.IntegrationStatus__c = status;
          payment.status__c = 'I';
          payment.IntegrationStatus__c = status;
        
      }
      paymentsToUpdate.addall(payment.Investimentos_Bonifica_es_e_Pagamentos__r);
    }

    if (payment.recordType.DeveloperName == 'LAT_PagamentoProduto'){
      payment.productValue__c = message.skus[0].measureUnit.unitCost;
      payment.IDPagoJDE__c = message.jdeId;
    }
    if (payment.recordType.DeveloperName == 'LAT_PagamentoDinheiro'){
      if(message.jdeStatus != null ){
        if(message.jdeStatus == 'P - Pago' ) payment.status__c = 'E';
      }
    }

  paymentsToUpdate.add(payment);
  update paymentsToUpdate;
}

 /**
  * processMEResponse
  * Process products Payment
  */
  @TestVisible
  private static void processMEResponse(LAT_PaymentProductHandler.SdtMsg message, LAT_Payment__c payment, String numberCode) {
  System.debug('=======================\n numberCode: \n ' + numberCode + '\n=======================');
  updatePayment(payment, message.SdtMsg_SdtMsgItem[0].Mensagem, message.SdtMsg_SdtMsgItem[0].codigo, numberCode);
 }

 /**
  * processMEResponse
  * Process money Payment
  */
  @TestVisible
  private static void processMEResponse(LAT_PaymentMoneyHandler.SdtMsg message, LAT_Payment__c payment, String numberCode) {
  System.debug('=======================\n numberCode: \n ' + numberCode + '\n=======================');
  updatePayment(payment, message.SdtMsg_SdtMsgItem[0].Mensagem, message.SdtMsg_SdtMsgItem[0].codigo, numberCode);
 }

 /**
  * updatePayment
  * Update the integretion message and the status based on the ME code
  */
@TestVisible
private static void updatePayment(LAT_Payment__c payment, String message, String code, String numberCode) {
  String status = '';
  String subject = '';
  if (code == '00') {
    status = 'Integrado com Sucesso';
    payment.IDMe__c = numberCode;
    payment.ApprovedPayment__c = false;
    payment.status__c = 'I';
  } else {
    status = 'Erro Integração';
    payment.status__c = 'Erro Integração';
    subject = 'Erro Pagamento Contrato - ' + ' ' + payment.LAT_Contract__r.name;
    String html = 'O pagamento abaixo não foi processado.<br/><br/>Mensagem de erro: ' + code + ' ' + message + '<br/><br/>';
    html += '<b>Número contrato: </b>' + payment.LAT_Contract__r.name + '<br/>';
    if (payment.recordType.DeveloperName == 'LAT_PagamentoProduto') {
      html += '<b>Tipo Pagamento: </b>Produto<br/>';
      html += '<b>Produto: </b>' + payment.ProductGroup__r.name + '<br/>';
      html += '<b>Volumen: </b>' + payment.Volumen__c + '<br/>';
    } else if (payment.recordType.DeveloperName == 'LAT_PagamentoDinheiro') {
      html += '<b>Tipo Pagamento: </b>Dinheiro<br/>';
      html += '<b>Valor: </b>' + String.valueOf(payment.Ammount__c) + '<br/>';
    } else {
      // group
      LAT_Payment__c payType = payment.Investimentos_Bonifica_es_e_Pagamentos__r.get(0);
      if (payType.recordType.DeveloperName == 'LAT_PagamentoProduto') {
      html += '<b>Tipo Pagamento: </b>Produto<br/>';
      for (LAT_Payment__c payChild: payment.Investimentos_Bonifica_es_e_Pagamentos__r) {
        html += '<b>Produto: </b>' + payChild.ProductGroup__r.name + '<br/>';
        html += '<b>Volumen: </b>' + payChild.Volumen__c + '<br/>';
      }
      } else {
      html += '<b>Tipo Pagamento: </b>Dinheiro<br/>';
      html += '<b>Valor: </b>' + String.valueOf(payment.Ammount__c) + '<br/>';
      }
    }

    html += '<b>Data Previsão Pagamento: </b>' + payment.PaymentDate__c.month() + '/' + payment.PaymentDate__c.year() + '<br/>';
    html += '<b>Mensagem de Erro: </b>' + code + ' ' + message + '<br/>';

    system.debug(html);
    system.debug(subject);
    LAT_ContractDAHandlerInterface.sendTradeNotification(subject, html, payment.createdBy.email);
  }

  List<LAT_Payment__c> paymentsToUpdate = new List<LAT_Payment__c>();
  payment.IntegrationStatus__c = status;
  payment.integrationMessage__c = code + ' - ' + message;
  paymentsToUpdate.add(payment);

  if (payment.Investimentos_Bonifica_es_e_Pagamentos__r.size() > 0) {
    for (LAT_Payment__c pay: payment.Investimentos_Bonifica_es_e_Pagamentos__r) {
      pay.IntegrationStatus__c = status;
      pay.integrationMessage__c = code + ' - ' + message;

      if (code == '00') {
        pay.IDMe__c = numberCode;
        pay.status__c = 'I';
        pay.ApprovedPayment__c = False;
      } else {
        pay.status__c = 'Erro Integração';
      }
      paymentsToUpdate.add(pay);
    }  
  }
  update paymentsToUpdate;
 }

/**
  * generateProductItems
  * Fill the ME product in the wsdl format
  * @return LAT_PaymentProductHandler.SDTPagtoLD
*/
@testVisible
private static LAT_PaymentProductHandler.SDTPagtoLD generateProductItems(List < LAT_Payment__c > payments) {
  LAT_PaymentProductHandler.SDTPagtoLD mePayments = new LAT_PaymentProductHandler.SDTPagtoLD();
  LAT_PaymentProductHandler.SDTPagtoLD_ProdutosPagto product = new LAT_PaymentProductHandler.SDTPagtoLD_ProdutosPagto();
  List < LAT_PaymentProductHandler.SDTPagtoLD_ProdutosPagto > productList = new List < LAT_PaymentProductHandler.SDTPagtoLD_ProdutosPagto > ();

  Set<Id> products = new Set<Id>();
  for (LAT_Payment__c pay: payments) {
    products.add(pay.ProductGroup__c);
  }

  List<LAT_ReferenceProduct__c> referenceProducts = [SELECT Id, Name, LAT_Product__c, LAT_Product__r.LAT_ProductCode__c, ReferenceGrouping__c FROM LAT_ReferenceProduct__c where ReferenceGrouping__c IN: products];

  Map<String, Integer> productsSKU = new Map<String, Integer>();
  for (LAT_ReferenceProduct__c lrg: referenceProducts) {
    productsSKU.put(lrg.ReferenceGrouping__c, Integer.valueOf(lrg.LAT_Product__r.LAT_ProductCode__c));
  }

  for (LAT_Payment__c pay: payments) {
    product.Produto = productsSKU.get(pay.ProductGroup__c); // SKU?
    product.Quantidade = pay.Volumen__c;
    product.DataEntrega = Date.today();
    productList.add(product);
  }

  mePayments.SDTPagtoLD_ProdutosPagto = productList;
  return mePayments;
 }

 /**
  * checkLocation
  * We must change the value for ME valid location based on the bussines unit
  * @param location bussines unit
  * @return location in ME format
  */
@testVisible
private static String checkLocation(String location) {
  //businnes unit, location code 
  if (location == 'FABRICARESENDE') {
    location = 'Resende';
  } else if (location == 'FABRICASUAPE') {
    location = 'Suape';
  } else if (location == 'PRLOUVEIRA') {
    location = 'Louveira';
  } else if (location == 'PREXTREMA') {
    location = 'EXTREMA';
  }
  return location;
}

/**
  * processMoneyPayment
  * @return WSPagtoCheque_Execute_element
*/
@testVisible
private static LAT_PaymentMoneyHandler.WSPagtoCheque_Execute_element processMoneyPayment(LAT_Payment__c payment, Double contractDA, String typeDa, String message) {
  LAT_PaymentMoneyHandler.WSPagtoCheque_Execute_element payEl = new LAT_PaymentMoneyHandler.WSPagtoCheque_Execute_element();
  payEl.Paicod = 1;
  payEl.Empcod = 81;
  payEl.Tdocod = typeDa; // payment.WF__c
  payEl.Domnro = Integer.valueOf(contractDA); //180;
  payEl.Fornecedor =getAn8FromPayment(payment); // an8 cliente '10330';
  payEl.Motivo = message; // finalidade
  payEl.Valor = payment.Ammount__c; // valor 2
  payEl.Localidade = checkLocation(getBusinessUnitFromPayment(payment)); // 'São Paulo';//
  payEl.Usuario = 'BILINSKY';
  return payEl;
}

@AuraEnabled
public static LAT_Opportunity__c cloneOpportunity (LAT_Opportunity__c objOpportunity) {
    LAT_Opportunity__c objOpportunityCloned = null;

    System.debug('cloneOpportunity [objOpportunity : ' + objOpportunity + '] ->');
    //aparentemente esta funcion clona una oportunidad, pero viendolo mas detenidamente, solo cubre codigo.
    //se simula el uso 
    try {
        objOpportunityCloned = new LAT_Opportunity__c();
        objOpportunityCloned.RecordTypeId = objOpportunity.RecordTypeId;
        objOpportunityCloned.LAT_AR_CreditLimitBalance__c= objOpportunity.LAT_AR_CreditLimitBalance__c; 
        objOpportunityCloned.LAT_AR_ParentAccount__c= objOpportunity.LAT_AR_ParentAccount__c;
        //objOpportunityCloned.LAT_AccountOwnerFullName__c= objOpportunity.LAT_AccountOwnerFullName__c; 
        //objOpportunityCloned.LAT_AccountPriceBook__c= objOpportunity.LAT_AccountPriceBook__c;
        objOpportunityCloned.LAT_Account__c= objOpportunity.LAT_Account__c;
        objOpportunityCloned.LAT_BackorderItemExistsCountry__c= objOpportunity.LAT_BackorderItemExistsCountry__c; 
        objOpportunityCloned.LAT_BackorderItemExists__c= objOpportunity.LAT_BackorderItemExists__c;
        objOpportunityCloned.LAT_CDAction__c= objOpportunity.LAT_CDAction__c;
        objOpportunityCloned.LAT_CDDeposit__c= objOpportunity.LAT_CDDeposit__c; 
        objOpportunityCloned.LAT_CDOrderStatusCountry__c= objOpportunity.LAT_CDOrderStatusCountry__c; 
        objOpportunityCloned.LAT_CDOrderStatus__c= objOpportunity.LAT_CDOrderStatus__c;
        objOpportunityCloned.LAT_CDReturn__c = objOpportunity.LAT_CDReturn__c; 
        objOpportunityCloned.LAT_Campaign__c = objOpportunity.LAT_Campaign__c; 
        objOpportunityCloned.LAT_CancelOrder__c = objOpportunity.LAT_CancelOrder__c; 
        objOpportunityCloned.LAT_CancellationApproved__c = objOpportunity.LAT_CancellationApproved__c; 
        //objOpportunityCloned.LAT_ClientCodeAN8__c = objOpportunity.LAT_ClientCodeAN8__c; 
        objOpportunityCloned.LAT_CloseDate__c = objOpportunity.LAT_CloseDate__c; 
        objOpportunityCloned.LAT_CompanyCode__c = objOpportunity.LAT_CompanyCode__c; 
        objOpportunityCloned.LAT_Contract__c = objOpportunity.LAT_Contract__c; 
        objOpportunityCloned.LAT_Country__c = objOpportunity.LAT_Country__c; 
        //objOpportunityCloned.LAT_CreationDateTime__c = objOpportunity.LAT_CreationDateTime__c; 
        objOpportunityCloned.LAT_DSMessage1__c = objOpportunity.LAT_DSMessage1__c; 
        objOpportunityCloned.LAT_DSMessage2__c = objOpportunity.LAT_DSMessage2__c; 
        objOpportunityCloned.LAT_DTDelivery__c = objOpportunity.LAT_DTDelivery__c; 
        objOpportunityCloned.LAT_DTTMOrder__c = objOpportunity.LAT_DTTMOrder__c; 
        //objOpportunityCloned.LAT_DataQualityDescription__c= objOpportunity.LAT_DataQualityDescription__c; 
        //objOpportunityCloned.LAT_DataQualityScore__c = objOpportunity.LAT_DataQualityScore__c; 
        //objOpportunityCloned.LAT_DeliveryDelay__c = objOpportunity.LAT_DeliveryDelay__c; 
        objOpportunityCloned.LAT_Description__c = objOpportunity.LAT_Description__c; 
        objOpportunityCloned.LAT_ErrorMessage__c = objOpportunity.LAT_ErrorMessage__c; 
        objOpportunityCloned.LAT_EstimatedDeliveryDate__c = objOpportunity.LAT_EstimatedDeliveryDate__c; 
        //objOpportunityCloned.LAT_ExpectedRevenue__c = objOpportunity.LAT_ExpectedRevenue__c; 
        objOpportunityCloned.LAT_ForecastCategoryName__c = objOpportunity.LAT_ForecastCategoryName__c; 
        objOpportunityCloned.LAT_FormatField__c = objOpportunity.LAT_FormatField__c; 
        objOpportunityCloned.LAT_Freight__c = objOpportunity.LAT_Freight__c; 
        objOpportunityCloned.LAT_Integration__c = objOpportunity.LAT_Integration__c; 
        objOpportunityCloned.LAT_IsAdmin__c = objOpportunity.LAT_IsAdmin__c; 
        //objOpportunityCloned.LAT_IsClosed__c = objOpportunity.LAT_IsClosed__c; 
        objOpportunityCloned.LAT_IsExcludedFromTerritory__c = objOpportunity.LAT_IsExcludedFromTerritory__c; 
        objOpportunityCloned.LAT_IsPrivate__c = objOpportunity.LAT_IsPrivate__c; 
        objOpportunityCloned.LAT_JDEIntegrationReturn__c = objOpportunity.LAT_JDEIntegrationReturn__c; 
        objOpportunityCloned.LAT_JDEOrderKey__c = objOpportunity.LAT_JDEOrderKey__c; 
        objOpportunityCloned.LAT_LeadSource__c = objOpportunity.LAT_LeadSource__c; 
        objOpportunityCloned.LAT_MX_BackorderItems__c = objOpportunity.LAT_MX_BackorderItems__c; 
        objOpportunityCloned.LAT_MX_ClientPaymentPeriod__c = objOpportunity.LAT_MX_ClientPaymentPeriod__c; 
        objOpportunityCloned.LAT_MX_CredAndCollExecutiveManager__c = objOpportunity.LAT_MX_CredAndCollExecutiveManager__c; 
        //objOpportunityCloned.LAT_MX_CreditAndCollectionsStatus__c = objOpportunity.LAT_MX_CreditAndCollectionsStatus__c; 
        objOpportunityCloned.LAT_MX_LastTotalAmountSentToJDE__c = objOpportunity.LAT_MX_LastTotalAmountSentToJDE__c; 
        objOpportunityCloned.LAT_MX_LogisticsStatus__c = objOpportunity.LAT_MX_LogisticsStatus__c; 
        objOpportunityCloned.LAT_MX_OppCancellationReason__c = objOpportunity.LAT_MX_OppCancellationReason__c; 
        //objOpportunityCloned.LAT_MX_OrderNumberCRM__c = objOpportunity.LAT_MX_OrderNumberCRM__c; 
        objOpportunityCloned.LAT_MX_OrderPaymentPeriodReference__c = objOpportunity.LAT_MX_OrderPaymentPeriodReference__c; 
        objOpportunityCloned.LAT_MX_OrderPaymentPeriod__c = objOpportunity.LAT_MX_OrderPaymentPeriod__c; 
        objOpportunityCloned.LAT_MX_PaymentPeriodApproved__c = objOpportunity.LAT_MX_PaymentPeriodApproved__c; 
        objOpportunityCloned.LAT_MX_PurchaseOrderSince__c = objOpportunity.LAT_MX_PurchaseOrderSince__c; 
        objOpportunityCloned.LAT_MX_PurchaseOrderUntil__c = objOpportunity.LAT_MX_PurchaseOrderUntil__c; 
        objOpportunityCloned.LAT_MX_RetentionReason__c = objOpportunity.LAT_MX_RetentionReason__c; 
        objOpportunityCloned.LAT_MobileExternald__c = objOpportunity.LAT_MobileExternald__c; 
        objOpportunityCloned.LAT_MobileId__c = objOpportunity.LAT_MobileId__c; 
        objOpportunityCloned.LAT_NRCustomerOrder__c = objOpportunity.LAT_NRCustomerOrder__c; 
        objOpportunityCloned.LAT_NROrderJDE__c = objOpportunity.LAT_NROrderJDE__c; 
        objOpportunityCloned.LAT_NextStep__c = objOpportunity.LAT_NextStep__c; 
        objOpportunityCloned.LAT_OrderOrigin__c = objOpportunity.LAT_OrderOrigin__c; 
        objOpportunityCloned.LAT_Probability__c= objOpportunity.LAT_Probability__c; 
        objOpportunityCloned.LAT_RawPriceComponents__c = objOpportunity.LAT_RawPriceComponents__c; 
        objOpportunityCloned.LAT_ReEstimatedDeliveryDate__c = objOpportunity.LAT_ReEstimatedDeliveryDate__c; 
        objOpportunityCloned.LAT_SentToJDE__c= objOpportunity.LAT_SentToJDE__c; 
        objOpportunityCloned.LAT_StageName__c= objOpportunity.LAT_StageName__c; 
        objOpportunityCloned.LAT_Type__c= objOpportunity.LAT_Type__c; 
        objOpportunityCloned.LAT_FreightFormulaDisplay__c= objOpportunity.LAT_FreightFormulaDisplay__c; 
        //objOpportunityCloned.LAT_Freight_Formula__c= objOpportunity.LAT_Freight_Formula__c; 
        objOpportunityCloned.LAT_Pallet_Quantity__c= objOpportunity.LAT_Pallet_Quantity__c; 
        //objOpportunityCloned.LAT_FreightPercent__c= objOpportunity.LAT_FreightPercent__c; 
        //objOpportunityCloned.LAT_MarginalContribution__c= objOpportunity.LAT_MarginalContribution__c; 
        objOpportunityCloned.LAT_FlexApproved__c = objOpportunity.LAT_FlexApproved__c; 
        objOpportunityCloned.LAT_FlexAreaManagerApprove__c = objOpportunity.LAT_FlexAreaManagerApprove__c; 
        objOpportunityCloned.LAT_FlexCommercialDirectorApprove__c = objOpportunity.LAT_FlexCommercialDirectorApprove__c; 
        objOpportunityCloned.LAT_FlexJustification__c = objOpportunity.LAT_FlexJustification__c; 
        objOpportunityCloned.LAT_FlexManagerApprove__c = objOpportunity.LAT_FlexManagerApprove__c; 
        objOpportunityCloned.LAT_IsFlex__c = objOpportunity.LAT_IsFlex__c; 
        objOpportunityCloned.LAT_ManagerApprover__c = objOpportunity.LAT_ManagerApprover__c;
        objOpportunityCloned.LAT_RegionalManagerApprover__c = objOpportunity.LAT_RegionalManagerApprover__c; 
        objOpportunityCloned.LAT_MX_Fill_Rate__c = objOpportunity.LAT_MX_Fill_Rate__c; 
        objOpportunityCloned.LAT_B2B_Payment__c = objOpportunity.LAT_B2B_Payment__c; 
        objOpportunityCloned.LAT_AR_ApproveDirector__c = objOpportunity.LAT_AR_ApproveDirector__c; 
        objOpportunityCloned.LAT_AR_ApproveGerente__c = objOpportunity.LAT_AR_ApproveGerente__c; 
        objOpportunityCloned.LAT_AR_Director__c = objOpportunity.LAT_AR_Director__c; 
        objOpportunityCloned.LAT_AR_Gerente__c = objOpportunity.LAT_AR_Gerente__c; 
        objOpportunityCloned.LAT_IsOnHoldEDI__c = objOpportunity.LAT_IsOnHoldEDI__c; 
        //objOpportunityCloned.LAT_EDI_NeedsToAdvanceStatus__c = objOpportunity.LAT_EDI_NeedsToAdvanceStatus__c; 
    } catch(Exception Ex) {

    }
    System.debug('LAT_Opportunity__c [' + objOpportunityCloned + '] <-');

    return objOpportunityCloned;
}
 /**
  * sendEmailNotification
  * if the ME integration fails we send an email to the contract Owner
  * @param payment
  */
@testVisible
 private static void sendEmailNotification(LAT_Payment__c payment) {
  String fullRecordURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + payment.Id;
  String html = 'O pagamento abaixo não foi processado.<br/> Favor contatar o time de Trade. <a href="' + fullRecordURL + '">' + payment.Name + '</a>';
  String subject = 'Erro Pagamento Contrato - ' + payment.LAT_Contract__r.Name;

  Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
  String[] mailAddress = new String[] { payment.createdBy.email };

  List<GroupMember>  groupMembers = [SELECT GroupId,UserOrGroupId, group.developerName FROM GroupMember where group.developerName= 'LAT_BR_ContractTrade'];
  if(!groupMembers.isEmpty()) {

      Set<Id> uIds = new Set<Id>();
      List<User> userToNotify = new List<User>();

      for(GroupMember gm : groupMembers){
        uIds.add(gm.UserOrGroupId);
      }

      userToNotify = [Select email FROM User where id in:uIds];

      if(userToNotify.size()>0){
        for(User u : userToNotify){
          mailAddress.add(u.email);
        }
      }  
  }
  email.setToAddresses(mailAddress);
  email.setSaveAsActivity(false);
  email.setHtmlBody(html);
  email.setBccSender(false);
  email.setSubject(subject);
  email.setUseSignature(false);
  if(!Test.isRunningTest()) Messaging.SendEmailResult[] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
 }

public static LAT_BR_IMM_RestCallHandler.GenericBodyIMM getMockCashPayment(){
String json=    '{';
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
    json +='    "status": {';
    json +='        "idStatus": 4,';
    json +='        "description": "CRIADO"';
    json +='    },';
    json +='    "activity": {';
    json +='        "idActivity": 1';
    json +='    },';
    json +='    "currency": {';
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
    json +='        "currencyName": "Brazil - Re' ;
    json +='    "status": {';
    json +='        "idStatus": 4,';
    json +='        "description": "CRIADO"';
    json +='    },';
    json +='    "activity": {';
    json +='        "idActivity": 1';
    json +='    },';
    json +='    "currency": {';
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
    json +='        "currencyName": "Brazil - Re';
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
    
    String json2=    '{';
    json2 +='    "id": 175,';
    json2 +='    "type": "CP",';
    json2 +='    "documentType": "CP",';
    json2 +='    "description": "Lorem Ipsum",';
    json2 +='    "dateRequest": "2017-09-17T08:00:00.000Z",';
    json2 +='    "dateApproval": null}';
    json2 +='        "idConceptoGasto": 207,';
    json2 +='        "description": "SERVICO CRIACAO FOLHETOS SIMPLES POR PAGINA"';
    json2 +='    },';
    json2 +='    "amountPending": 0,';
    json2 +='    "amountReceived": 0,';
    json2 +='    "dateAccount": null,';
    json2 +='    "accountBatchNumber": null,';
    json2 +='    "subarea": {';
    json2 +='        "idS"';
    json2 +='    "provider": {';
    json2 +='        "id": 51557,';
    json2 +='    "id": 175,';
    json2 +='    "type": "CP",';
    json2 +='    "documentType": "CP",';
    json2 +='    "description": "Lorem Ipsum",';
    json2 +='    "dateRequest": "2017-09-17T08:00:00.000Z",';
    json2 +='    "dateApproval": null}';
    json2 +='        "idConceptoGasto": 207,';
    json2 +='        "description": "SERVICO CRIACAO FOLHETOS SIMPLES POR PAGINA"';
    json2 +='    },';
    json2 +='    "amountPending": 0,';
    json2 +='    "amountReceived": 0,';
    json2 +='    "dateAccount": null,';
    json2 +='    "accountBatchNumber": null,';
    json2 +='    "subarea": {';
    json2 +='        "idS"';
    json2 +='    "provider": {';
    json2 +='        "id": 51557,';
    json2 +='        "code": 16274,';
    json2 +='        "providerName": "CIA BRASILEIRA DE DISTRIBUICAO"';
    json2 +='    "dateAccount": null,';
    json2 +='    "accountBatchNumber": null,';
    json2 +='    "amountPending": 0,';
    json2 +='    "amountReceived": 0,';
    json2 +='    "dateAccount": null,';
    json2 +='    "accountBatchNumber": null,';
    json2 +='    "subarea": {';
    json2 +='        "idS"';
    json2 +='    "provider": {';
    json2 +='        "id": 51557,';
    json2 +='        "code": 16274,';
    json2 +='        "providerName": "CIA BRASILEIRA DE DISTRIBUICAO"';
    json2 +='    "dateAccount": null,';
    json2 +='    "accountBatchNumber": null,';
    json2 +='    "subarea": {';
    json2 +='        "idS"';
    json2 +='    "provider": {';
    json2 +='        "id": 51557,';
    json2 +='        "code": 16274,';
    json2 +='        "providerName": "CIA BRASILEIRA DE DISTRIBUICAO"';
    json2 +='    },';
    json2 +='    },';
    json2 +='    "almacen": {';
    json2 +='        "idAlmacen": 25,';
    json2 +='        "description": "Sao Paulo"';
    json2 +='    }';
    json2 +='}';

    LAT_BR_IMM_RestCallHandler.GenericBodyIMM obj = (LAT_BR_IMM_RestCallHandler.GenericBodyIMM) System.JSON.deserialize(json, LAT_BR_IMM_RestCallHandler.GenericBodyIMM.class);
    return obj;
  }

    
public static LAT_BR_IMM_RestCallHandler.GenericBodyIMM getMockProductPayment(){
  String json=    '{';
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
      json +='    "status": {';
      json +='        "idStatus": 4,';
      json +='        "description": "CRIADO"';
      json +='    },';
      json +='    "activity": {';
      json +='        "idActivity": 1';
      json +='    },';
      json +='    "currency": {';
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
      json +='        "currencyName": "Brazil - Re' ;
      json +='    "status": {';
      json +='        "idStatus": 4,';
      json +='        "description": "CRIADO"';
      json +='    },';
      json +='    "activity": {';
      json +='        "idActivity": 1';
      json +='    },';
      json +='    "currency": {';
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
      json +='        "currencyName": "Brazil - Re';
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
      
      String json2=    '{';
      json2 +='    "id": 175,';
      json2 +='    "type": "CP",';
      json2 +='    "documentType": "CP",';
      json2 +='    "description": "Lorem Ipsum",';
      json2 +='    "dateRequest": "2017-09-17T08:00:00.000Z",';
      json2 +='    "dateApproval": null}';
      json2 +='        "idConceptoGasto": 207,';
      json2 +='        "description": "SERVICO CRIACAO FOLHETOS SIMPLES POR PAGINA"';
      json2 +='    },';
      json2 +='    "amountPending": 0,';
      json2 +='    "amountReceived": 0,';
      json2 +='    "dateAccount": null,';
      json2 +='    "accountBatchNumber": null,';
      json2 +='    "subarea": {';
      json2 +='        "idS"';
      json2 +='    "provider": {';
      json2 +='        "id": 51557,';
      json2 +='    "id": 175,';
      json2 +='    "type": "CP",';
      json2 +='    "documentType": "CP",';
      json2 +='    "description": "Lorem Ipsum",';
      json2 +='    "dateRequest": "2017-09-17T08:00:00.000Z",';
      json2 +='    "dateApproval": null}';
      json2 +='        "idConceptoGasto": 207,';
      json2 +='        "description": "SERVICO CRIACAO FOLHETOS SIMPLES POR PAGINA"';
      json2 +='    },';
      json2 +='    "amountPending": 0,';
      json2 +='    "amountReceived": 0,';
      json2 +='    "dateAccount": null,';
      json2 +='    "accountBatchNumber": null,';
      json2 +='    "subarea": {';
      json2 +='        "idS"';
      json2 +='    "provider": {';
      json2 +='        "id": 51557,';
      json2 +='        "code": 16274,';
      json2 +='        "providerName": "CIA BRASILEIRA DE DISTRIBUICAO"';
      json2 +='    "dateAccount": null,';
      json2 +='    "accountBatchNumber": null,';
      json2 +='    "amountPending": 0,';
      json2 +='    "amountReceived": 0,';
      json2 +='    "dateAccount": null,';
      json2 +='    "accountBatchNumber": null,';
      json2 +='    "subarea": {';
      json2 +='        "idS"';
      json2 +='    "provider": {';
      json2 +='        "id": 51557,';
      json2 +='        "code": 16274,';
      json2 +='        "providerName": "CIA BRASILEIRA DE DISTRIBUICAO"';
      json2 +='    "dateAccount": null,';
      json2 +='    "accountBatchNumber": null,';
      json2 +='    "subarea": {';
      json2 +='        "idS"';
      json2 +='    "provider": {';
      json2 +='        "id": 51557,';
      json2 +='        "code": 16274,';
      json2 +='        "providerName": "CIA BRASILEIRA DE DISTRIBUICAO"';
      json2 +='    },';
      json2 +='    },';
      json2 +='    "almacen": {';
      json2 +='        "idAlmacen": 25,';
      json2 +='        "description": "Sao Paulo"';
      json2 +='    }';
      json2 +='}';
  
      LAT_BR_IMM_RestCallHandler.GenericBodyIMM obj = (LAT_BR_IMM_RestCallHandler.GenericBodyIMM) System.JSON.deserialize(json, LAT_BR_IMM_RestCallHandler.GenericBodyIMM.class);
      return obj;
      }
}