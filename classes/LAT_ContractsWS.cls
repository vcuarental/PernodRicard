/*
* LAT_ContractsWS, class to manage webservice methods related with contracts
* Author: Martin Prado (martin@zimmic.com)
* Date: 07/22/2016  GONZA y FFFACCCC
*/
global class LAT_ContractsWS { 
	public static final Set<String> RT_EVENTOS = new Set<String>{'LAT_Eventos_Contrato_de_Parceria', 'LAT_Eventos_Contrato_de_Parceria_Distribuidor'};
	public static final String RT_CARTA_ATIVACAO = 'LAT_CartaAtivacao';

	/*
	* @Contract Class
	* Used as a parameter to calculate ROI
	*/
	global class Contract{
		webservice String recordType;
		webservice Integer contractTerms;
		webservice List<Payments> payments;
		webservice List<ContractVolume> contractVolume;
		webservice String roiSegment;
		webservice String uf;
	}
	/*
	* @Payments
	* Payment class to simulate the payment object, if the record type is
	* "money" the user must set the ammount, and if the type is "bonus", we must to know the
	* product group and the boxes ammount
	*/
	global class Payments{
		webservice String recordType;
		webservice Id productGroup;
		webservice Double	ammount;
		webservice Double volumen;
	}

	/*
	* @ContractVolume
	* If the contract record type is "CC- Commercial Condition"
	*/
	global class ContractVolume {
		webservice Id product;
		webservice Double boxesMinimum;
		webservice Double boxesMaximum;
        webservice String simulation;
        webservice Double cartVolumen; 
        webservice Double contractVolumen;
		//webservice Double	businessCondition;
	}

	/*
	* @ContractInformation
	* For use in the simulation, we received some contract parameters(volume, payments) and we return the contract information related with money
	*/
	global class ContractInformation {
		webservice Double Roi;
		webservice Double cashMoney;
		webservice Double productMoney;
		webservice Double totalMoney;
		webservice Double totalPerceivedValue;
		webservice Double maxInvestmentSuggested;
		webservice String errorOnProducts;
	}

	/*
	* @Payment Class
	* Payment class to use on the webservice to check the payments status
	*/
	global class Payment{
		webservice String paymentID;
		webservice String statusCode;
		webservice String description;
		webservice String  mailTemplate;
	}

	/*
	* @paymentToAprove Class
	* paymentToAprove
	*/
	global class paymentToAprove{
		webservice String paymentID;
	}

	private static Set<Id> productNotFound = new Set<Id>();
	private static String errorOnProducts { get; set; }
	private static Map<Id, String> productError =  new Map<Id, String>();
	private static List<productErrorClass> customErrors = new List<productErrorClass>();

	/*
	* cancelDAWS
	*/
	WebService static String cancelDAWS(String contractName) {
		String cId = [Select Id from LAT_Contract2__c where Name =: contractName].id;
		//LAT_ContractDAHandlerInterface.cancelDA(cId);
		return cId;
	}

	/*
	* sendPayToMe
	*/
	WebService static String sendPayToMe(Id paymentId) {
		LAT_ContractPaymentsHandlerInterface.sendPaymentToME(paymentId);
		return paymentId;
	}

	/**
	* runApprovalProcess
	*/
	public static void runApprovalProcess(List<String> paymentsIds) {
		for(String paymentId : paymentsIds) {
			Approval.ProcessSubmitRequest submitRequest = new Approval.ProcessSubmitRequest();
			submitRequest.setComments('Submitting payment for approval.');
			submitRequest.setObjectId(paymentId);
			Approval.ProcessResult result = Approval.process(submitRequest);
		}
	}

	/*
	* generatePaymentWS
	* Check the status of the contract, the type, and generate all the payments
	* @param contractId
	* @return Boolean if we regenerate all the payments
	*/
	WebService static Boolean generatePaymentWS(Id contractId) {
		LAT_ContractsCalculations lcc = new LAT_ContractsCalculations();
		Boolean ret = lcc.generatePayments(contractId, true);
		return ret;
	}

	/*
	* calculateRoi
	* @param contract
	* @param List of contractVolume
	* @param List of Payments 
	*/
	WebService static Double calculateRoi(LAT_ContractsWS.Contract contract ){
		//Invoke calculations methods to get Investment and Gain From Investment
		double gFI = calculateGainFromInvestment(contract.contractVolume, contract.contractTerms, contract.uf);
		double inv = calculateInvestment(contract.payments, contract.uf);

		// Calculate ROI
		LAT_ContractsCalculations lcc = new LAT_ContractsCalculations();
		Double roi = lcc.calculateROI(gFI, inv);
		return roi;
	}

	/*
	* checkPaymentRelease
	* @param id paymentId
	*
	*/
	WebService static List<LAT_ContractsWS.paymentToAprove>  groupPayments(List<LAT_ContractsWS.paymentToAprove> payments) {
		Set<String> paymentsIds = new Set<String>();
		for(LAT_ContractsWS.paymentToAprove pay : payments ){
			paymentsIds.add(pay.paymentID);
		}

		Map<String, LAT_Payment__c> paymentsToAnalize = new Map<String, LAT_Payment__c>([Select Id, LAT_Contract__c, Ammount__c, Finality__c, ProductGroup__c, PaymentDate__c, RecordTypeId, RecordType.Developername, PaymentDateOriginal__c, LAT_Distributor__c from LAT_Payment__c where Id in: paymentsIds]);

		Map<String, Set<String>> groupedPayments = new Map<String, Set<String>>();
		System.debug('============ paymentsToAnalize =============== \n '+paymentsToAnalize);

		for(string p : paymentsToAnalize.keySet()){
			String externalId = paymentsToAnalize.get(p).PaymentDate__c.month()+'-'+paymentsToAnalize.get(p).PaymentDate__c.year() + '-' + paymentsToAnalize.get(p).Finality__c + '-' +paymentsToAnalize.get(p).RecordType.Developername;
			if(groupedPayments.get(externalId) == null) {
				groupedPayments.put(externalId, new Set<String>{p});
			} else {
				groupedPayments.get(externalId).add(p);
			}
		}
		System.debug('============ groupedPayments =============== \n '+groupedPayments);

		List<LAT_Payment__c> payToUpdate = new List<LAT_Payment__c>();
		List<String> payToCheckAndSendToApproval = new List<String>();

		// Iterate Map, if the lenght is 1, we should't agrupate the payment, and we can send to aproval
		for (String extId : groupedPayments.keySet()){
			if(groupedPayments.get(extId).size() == 1){
				System.debug('============ No parent =============== \n '+groupedPayments.get(extId));
				for(String myId : groupedPayments.get(extId)){
					payToCheckAndSendToApproval.add(myId);
				}
				// Send to aproval
			} else {
				System.debug('============ With parent =============== \n '+groupedPayments.get(extId));
				LAT_Payment__c newPaymentGroup = new LAT_Payment__c();
				Id recordTypeId = Schema.SObjectType.LAT_Payment__c.getRecordTypeInfosByName().get('Payment Group').getRecordTypeId();
				newPaymentGroup.Ammount__c = 0;
				newPaymentGroup.recordTypeId = recordTypeId;
				Date paymentdate = null;
				for(String myId : groupedPayments.get(extId)){
					LAT_Payment__c paym = paymentsToAnalize.get(myId);
					if(paym.LAT_Distributor__c != null){
						newPaymentGroup.LAT_Distributor__c = paym.LAT_Distributor__c;
					}
					if (paymentdate == null || paymentdate < paym.PaymentDate__c ){
						system.debug('paymentdate++++2' + paymentdate);
						paymentdate = paym.PaymentDate__c ;
					}
					system.debug('paymentdate++++3' + paymentdate);
					newPaymentGroup.PaymentDate__c  = paymentdate;

					if(paym.RecordType.Developername == 'LAT_PagamentoDinheiro'){
						newPaymentGroup.Ammount__c = newPaymentGroup.Ammount__c + paym.Ammount__c;
					}
					newPaymentGroup.LAT_Contract__c = paym.LAT_Contract__c;
					newPaymentGroup.Finality__c = paym.Finality__c;
				}
				insert newPaymentGroup;

				payToCheckAndSendToApproval.add(newPaymentGroup.id);

				for(String myId : groupedPayments.get(extId)){
					LAT_Payment__c paym = paymentsToAnalize.get(myId);
					paym.ParentPayment__c = newPaymentGroup.id;
					payToUpdate.add(paym);
				}
				System.debug('============ newPaymentGroup =============== \n '+newPaymentGroup);

			}
		}
		System.debug('============ payToUpdate =============== \n '+payToUpdate);
		update payToUpdate;
		List<LAT_ContractsWS.paymentToAprove> retList = new List<LAT_ContractsWS.paymentToAprove>();
		for(String payId : payToCheckAndSendToApproval) {
			LAT_ContractsWS.paymentToAprove r = new LAT_ContractsWS.paymentToAprove();
			r.paymentID = payId;
			retList.add(r);
			//checkPaymentRelease(payId);
		}
		return retList;
		//runApprovalProcess(payToCheckAndSendToApproval);
	}

	/*
	* checkPaymentRelease
	* @param id paymentId
	*
	*/
	WebService static LAT_ContractsWS.Payment  checkPaymentRelease(Id paymentId){
		LAT_ContractsWS.Payment payRet = new LAT_ContractsWS.Payment();
		List<LAT_Payment__c> payments = [SELECT Months_Elapsed__c, (Select Id, PaymentDateOriginal__c, LAT_Contract__r.StartDate__c, LAT_Contract__c, ProductGroup__c, PaymentDate__c, LAT_Contract__r.Account__c,  LAT_Contract__r.MonthElapsed__c, Months_Elapsed__c from Investimentos_Bonifica_es_e_Pagamentos__r), Ammount__c,CNPJ_Fornecedor__c,CreatedById,CreatedDate,CurrencyIsoCode, PaymentDateOriginal__c, Finality__c,GoalNotReached__c,Id,IDMe__c,IsDeleted,LastModifiedById,LastModifiedDate,LAT_Contract__c,Name,ParentPayment__c,PaymentDateDone__c,PaymentDate__c,ProductGroup__c,RecordTypeId,Status__c,SystemModstamp,Type__c,Volumen__c, LAT_Contract__r.Account__c, LAT_Contract__r.MonthElapsed__c, LAT_Contract__r.StartDate__c FROM LAT_Payment__c where id=:paymentId];

		if (payments.size() > 0) {
			LAT_Payment__c payment = payments.get(0);
			payRet.paymentID = paymentId;

			// Payment should works only if the register is Parent group or has not parent.
			if (payment.ParentPayment__c != null) {
				payRet.statusCode = 'Este pagamento não pode ser processado, e parte de um grupo de pagamentos';
				payRet.description = '';
				SYSTEM.debug(payRet);
			} else {
				// Have Child to check
				List<LAT_Payment__c> childPayments = payment.Investimentos_Bonifica_es_e_Pagamentos__r;
				// Group Payments
				if(childPayments.size()>0){
					payRet = checkSalesNew(childPayments, payRet);
				}
				// Simply Payment
				else {
					childPayments.add(payment);
					payRet = checkSalesNew(childPayments, payRet);
				}
			}
		} else {
			payRet.statusCode = 'ID incorreta';
			payRet.description = '';

		}
		if(payments.size() > 0){
			LAT_Payment__c payment = payments.get(0);
			if(payRet.statusCode == 'META ATINGIDA'){
				payment.GoalNotReached__c = 'Sim';
			} else {
				payment.GoalNotReached__c = 'Não';
			}
			payment.paymentGoals__c = payRet.mailTemplate;
			update payment;
		}
		payRet.mailTemplate = '';
		SYSTEM.debug('Retorno de checkpaymentrelease: ' + payRet);
		return payRet;

	}

	/*
	* calculateRoiWithInfo
	* @param contract
	*/
	WebService static LAT_ContractsWS.ContractInformation getContractInformation(LAT_ContractsWS.Contract contract ){

		//Invoke calculations methods to get Investment and Gain From Investment
		Decimal gFI = calculateGainFromInvestment(contract.contractVolume, contract.contractTerms, contract.uf);
		Decimal invProductCM = 0;
		Decimal inv = 0;
		Decimal invCash = 0;
		Decimal invProduct = 0;
		//calculateInvestment(contract.payments);
		List<Double> invValues = calculateInvestmentGroupedByType(contract.payments, contract.uf);
		if(invValues.size() > 1) {invCash = invValues.get(0); invProduct = invValues.get(1); invProductCM = invValues.get(2); }
		errorOnProducts = '';

		// Calculate ROI
		LAT_ContractsCalculations lcc = new LAT_ContractsCalculations();
		Double roi = lcc.calculateROI(Double.valueOF(gFI), Double.valueOF(invCash+invProduct));
		Decimal dRoi = roi;

		LAT_ContractsWS.ContractInformation cInfo = new LAT_ContractsWS.ContractInformation();
		cInfo.Roi = dRoi.SetScale(2);
		cInfo.productMoney = double.valueOf(invProduct.SetScale(0));
		cInfo.cashMoney = double.valueOf(invCash.SetScale(0));
		cInfo.totalMoney = double.valueOf(invProduct.SetScale(0) + invCash.SetScale(0));
		Decimal totalV = 0;
		totalV = invProductCM + invCash;
		totalV = totalV.SetScale(0);
		cInfo.totalPerceivedValue  = double.valueOf(totalV.SetScale(0));
		// error new implementation
		errorOnProducts = '';
		if(customErrors.size()>0) {
			Set<Id> proIds = new Set<Id>();
			for(productErrorClass pError :customErrors) {
				proIds.add(pError.productId);
			}
			Map<Id, LAT_ReferenceProductGrouping__c> rP = new Map<Id, LAT_ReferenceProductGrouping__c>([Select Id, Name from LAT_ReferenceProductGrouping__c where Id in: proIds]);

			for(productErrorClass pError :customErrors) {
				if(rP.get(pError.productId) != null) {
					String comment = (pError.recordType != null) ? '('+pError.recordType+') - ' : ' - ';
					errorOnProducts += rP.get(pError.productId).Name + ': '+ pError.type + comment ;
				} else {
					errorOnProducts += '??????' + ': '+ pError.type +' - '+ pError.type +'('+pError.recordType+') - '  ;
				}

			}

		}
		cInfo.errorOnProducts = errorOnProducts.removeEnd('- ');

		if(contract.roiSegment != '' && contract.roiSegment != null){
			List<LAT_ROISegments__c> lrs = [SELECT ROI__c,Segment__c FROM LAT_ROISegments__c where Segment__c =: contract.roiSegment limit 1];
			if(lrs.size() > 0){

				//1.000.000 / (1 + 0.25)
				system.debug(gFI);
				Double newROI = (lrs.get(0).ROI__c != null) ? lrs.get(0).ROI__c / 100 : null;
				system.debug(newROI);
				if(newROI != null){
					Decimal maxInv = (gFI / (1 + newROI)).SetScale(0);
					cInfo.maxInvestmentSuggested = Double.valueOf(maxInv);
				} else {
					cInfo.maxInvestmentSuggested = null;
				}

			}else {
				cInfo.maxInvestmentSuggested = null;
			}

		}

		// webservice Double Roi;
		// webservice Double cashMoney;
		// webservice Double productMoney;
		// webservice Double totalMoney;
		// webservice Double maxInvestmentSuggested;
		return cInfo;
	}

	/*
	* @param contractId
	*/
	WebService static Double emulateRoi(Id contractId) {
		List<LAT_Contract2__c> lstContracts = null;
		Double dblResult = null;
		LAT_Contract2__c objContract = null;
		Map<Id, Double> mapProductGroupMap = new Map<Id, Double>();
		Id objProductGroupId = null;
		Double dblVolume = null;
		Double gFI = 0;
		Double inv = 0;
		Double dblCurrentVolume = null;
		Double dblMonthlyGain = null;
		Double dblROI = null; 
		LAT_ContractsCalculations objLATContractCalculations = null;
		ProductErrorClass objError = null;
		Map<Id, LAT_ReferenceProductGrouping__c> mapReferenceProductMappings = null;
		Set<Id> setProductIds = null;
		String strComment = null;

		System.debug('emulateRoi [contractId : ' + contractId + '] ->');
		try {
			if(String.IsNotBlank(contractId)) {
				clearContractErrors(contractId);

				lstContracts = [SELECT OriginalContractNumber__c, Account__r.Revenue_UF__c, Account__c, ContractTerms__c,  (SELECT BoxesContract__c, Id ,ProductGroup__c, ProductGroup__r.Name FROM LAT_ContractVolumes__r), (SELECT RecordType.DeveloperName, RecordType.Name, Ammount__c, CurrencyIsoCode, Finality__c, Id, LAT_Contract__c, Name, PaymentDateDone__c, PaymentDate__c, ProductGroup__c, ProductGroup__r.Name, RecordTypeId, Status__c, Type__c, Volumen__c FROM LAT_Payments__r) FROM LAT_Contract2__c WHERE id =:contractId];
				if(!lstContracts.isEmpty()) {
					mapProductGroupMap = new Map<Id, Double>();

					objContract = lstContracts[0];
					clearContractErrors(contractId);

					System.debug('emulateRoi [objContract.LAT_ContractVolumes__r : ' + objContract.LAT_ContractVolumes__r + ']');
					System.debug('emulateRoi [objContract.LAT_Payments__r : ' + objContract.LAT_Payments__r + ']');

					for(LAT_ContractVolume__c objContractVolume : objContract.LAT_ContractVolumes__r){
						objProductGroupId = objContractVolume.ProductGroup__c;
						dblVolume = Double.valueOf(objContractVolume.BoxesContract__c);
						
						if(mapProductGroupMap.containsKey(objProductGroupId)) {
							dblCurrentVolume = mapProductGroupMap.get(objProductGroupId);
							mapProductGroupMap.put(objProductGroupId, dblCurrentVolume + dblVolume);
						} else {
							mapProductGroupMap.put(objProductGroupId, dblVolume);
						}
					}		
					System.debug('emulateRoi [mapProductGroupMap : ' + mapProductGroupMap + ']');
					System.debug('emulateRoi [objContract.Account__r.Revenue_UF__c : ' + objContract.Account__r.Revenue_UF__c + ']');

					dblMonthlyGain = calculateGainFromInvestmentBoxes(mapProductGroupMap, objContract.Account__r.Revenue_UF__c);
					System.debug('emulateRoi [objContract.ContractTerms__c : ' + objContract.ContractTerms__c + ']');
					System.debug('emulateRoi [dblMonthlyGain : ' + dblMonthlyGain + ']');

					gFI = dblMonthlyGain * objContract.ContractTerms__c;
					inv = 0;

					mapProductGroupMap.clear();
					
					for(LAT_Payment__c objPayment: objContract.LAT_Payments__r){
						// If the type is money, we only need sum the values
						if(objPayment.RecordType.DeveloperName == LAT_Rest_Contracts.CONTRACTS_PAYMENT_DINHEIRO){
							inv = inv + objPayment.Ammount__c;
						} else if(objPayment.RecordType.DeveloperName == LAT_Rest_Contracts.CONTRACTS_PAYMENT_PRODUCT){
							objProductGroupId = objPayment.ProductGroup__c;
							dblVolume = Double.valueOf(objPayment.Volumen__c);
		
							// If is an modified contract, we must to exclude the payments done for calculations.
							if(objContract.OriginalContractNumber__c == null || objPayment.status__c != 'Efeito') {
								//If exists I must add the volume to the current volume
								if(mapProductGroupMap.containsKey(objProductGroupId)){
									dblCurrentVolume = mapProductGroupMap.get(objProductGroupId);
									mapProductGroupMap.put(objProductGroupId, dblCurrentVolume + dblVolume);
								} else {
									//If not exists create a new map item
									mapProductGroupMap.put(objProductGroupId, dblVolume);
								}
							} 
						}
					}

					System.debug('emulateRoi [inv : ' + inv + ']');
					System.debug('emulateRoi [mapProductGroupMap : ' + mapProductGroupMap + ']');
					System.debug('emulateRoi [c.Account__r.Revenue_UF__c : ' + objContract.Account__r.Revenue_UF__c + ']');

					inv = calculateBonusInvestment(mapProductGroupMap, inv, 'LDCOST',  objContract.Account__r.Revenue_UF__c);

					System.debug('emulateRoi [calculated bonus investment : ' + inv + ']');
					System.debug('emulateRoi [GFI : ' + gFI + ']');

					// Calculate ROI
					objLATContractCalculations = new LAT_ContractsCalculations();
					dblROI = objLATContractCalculations.calculateROI(gFI, inv);
					System.debug('emulateRoi [dblROI : ' + dblROI + ']');

					if(productNotFound.size() > 0) {
						for(LAT_Payment__c objPayment: objContract.LAT_Payments__r) {
							if(objPayment.RecordType.DeveloperName == LAT_Rest_Contracts.CONTRACTS_PAYMENT_PRODUCT){
								objProductGroupId = objPayment.ProductGroup__c;
		
								if(productNotFound.contains(objProductGroupId)) {
									productError.put(objPayment.ProductGroup__C, 'NOT SKU FOUND');
									objError = new ProductErrorClass();
									objError.productId = objPayment.ProductGroup__c;
									objError.skuName = objPayment.ProductGroup__r.name;
									objError.type = 'NOT SKU FOUND';

									customErrors.add(objError);								
								}
							}
						}
						System.debug('emulateRoi [after payments... customErrors : ' + customErrors + ']');

						for(LAT_ContractVolume__c objContractVolume : objContract.LAT_ContractVolumes__r){
							objProductGroupId = objContractVolume.ProductGroup__c;

							if(productNotFound.contains(objProductGroupId)) {
								productError.put(objContractVolume.ProductGroup__C, 'NOT SKU FOUND');
								objError = new ProductErrorClass();
								objError.productId = objContractVolume.ProductGroup__c;
								objError.skuName = objContractVolume.ProductGroup__r.name;
								objError.type = 'NOT SKU FOUND';

								customErrors.add(objError);	
							}
						}

						System.debug('emulateRoi [after volumes... customErrors : ' + customErrors + ']');
					}
					errorOnProducts = '';
					if(customErrors.size() > 0) {
						clearContractErrors(contractId);
						insertContractErrors(contractId);

						setProductIds = new Set<Id>();
						for(productErrorClass objError1 :customErrors) {
							setProductIds.add(objError1.productId);
						}
						mapReferenceProductMappings = new Map<Id, LAT_ReferenceProductGrouping__c>([SELECT Id, Name FROM LAT_ReferenceProductGrouping__c WHERE Id in: setProductIds]);
		
						for(productErrorClass objError2 : customErrors ) {
							strComment = ( objError2.recordType != null) ? ' (' + objError2.recordType + ') - ' : ' - ' ;
							if(mapReferenceProductMappings.containsKey(objError2.productId) && mapReferenceProductMappings.get(objError2.productId) != null) {
								errorOnProducts += mapReferenceProductMappings.get(objError2.productId).Name + ' : ' + objError2.type  + strComment;
							} else {
								errorOnProducts += '??????' + ': '+ objError2.type + ' - ' + objError2.type + strComment;
							}		
						}
					}

					objContract.CalculationErrors__c = errorOnProducts.removeEnd('- ');
					objContract.ROI__c = dblROI;
					update objContract;
				} else {
					throw new LAT_Rest_Contracts.RestContractException('No se encontró el contrato a calcular el roi [' + contractId + ']');
				}
			} else {
				throw new LAT_Rest_Contracts.RestContractException('El contrato a calcular no puede ser nulo');
			}
		} catch (Exception Ex) {

		}

		return dblROI;
	}

	/*
	* clearContractErrors
	* Starting the contract calculation we must delete all the old errors.
	* @param contractId
	*/
	private static void clearContractErrors(Id contractId) {
		List<LAT_ContractError__c> lce = [Select Id from LAT_ContractError__c where LAT_Contract__c =:contractId];
		if(!lce.isEmpty()){
			delete lce;
		}
	}

	/*
	* clearContractErrors
	* Starting the contract calculation we must delete all the old errors.
	* @param contractId
	*/
	private static void insertContractErrors(Id contractId) {
		List<LAT_ContractError__c> lce = new List<LAT_ContractError__c>();

		for(productErrorClass pError :customErrors) {
			LAT_ContractError__c error = new LAT_ContractError__c();
			error.LAT_Contract__c = contractId;

			if(pError.type == 'Custo de Produto') error.LAT_Type__c =  'Custo do Produto';
			if(pError.type == 'Conversão Unidade de Medida/SKU Referência') error.LAT_Type__c =  'Conversão Unidade de Medida/SKU Referência';
			if(pError.type == 'NOT SKU FOUND') error.LAT_Type__c =  'SKU';

			error.LAT_Comments__c = pError.recordType;
			error.LAT_ProductGroup__c = pError.productId;
			lce.add(error);
		}

		if(!lce.isEmpty()){insert lce;}
	}

	/*
	* checkSalesNew
	* @param List payments, payments return
	*/
	private static LAT_ContractsWS.Payment  checkSalesNew(List<LAT_Payment__c> payments, LAT_ContractsWS.Payment payRet) {
		String contractId = '';
		String accountId = '';
		Decimal monthElapsed = 0;
		Decimal paymentMonthElapsed;
		Date startOfMonth;
		Date startOfNextMonth;
		Map<String, String> status = new Map<String,String>();
		String htmlTable = '';
		String uf = 'N/A';

		// Save the info to filter into the collect sellout
		for(LAT_Payment__c pay : payments) {
			contractId = pay.LAT_Contract__c;
			monthElapsed = pay.LAT_Contract__r.monthElapsed__c;
			accountId = pay.LAT_Contract__r.Account__c;
			// We must check the sales from the init of the contract ....
			startOfMonth = pay.LAT_Contract__r.StartDate__c.toStartOfMonth();
			paymentMonthElapsed = pay.Months_Elapsed__c;
			// ... Until the next month

			startOfNextMonth = (pay.PaymentDateOriginal__c != null) ? pay.PaymentDateOriginal__c.addMonths(1).toStartOfMonth() : pay.PaymentDate__c.addMonths(1).toStartOfMonth();
			//Old Value = startOfNextMonth = pay.PaymentDate__c.addMonths(1).toStartOfMonth();
		}

		Set<Id> accountsId = new Set<Id>();
		LAT_Contract2__c con = [SELECT Id, Name, Recordtype.developername , (SELECT Client__c FROM Clientes_do_Contrato__r) FROM LAT_Contract2__c WHERE Id =: contractId];

		if(RT_EVENTOS.contains(con.RecordType.Developername) || con.RecordType.Developername == RT_CARTA_ATIVACAO){
			return payRet;
		}

		accountsId.add(accountId);
		for(LAT_ContractClient__c contractClient : con.Clientes_do_Contrato__r) {
			accountsId.add(contractClient.Client__c);
		}

		System.debug('=======================\ncontractId:' +contractId+ '|| accountId ' +accountId+ '\n=======================' );
		System.debug('=======================\nmonthElapsed'  +monthElapsed+ '\n=======================' );
		System.debug('=======================\nstartOfMonth' + startOfMonth+ 'startOfNextMonth' + startOfNextMonth+'\n=======================' );

		// Check the monthly volume, with the new implementation the product of lat_contractvolume are represented on generic products: 'Chivas 12'
		List<LAT_ContractVolume__c> monthlyVolume = [SELECT LAT_Contract__c, BoxesContract__c, ProductGroup__c, ProductGroup__r.Name, LAT_Contract__r.Account__r.Revenue_UF__c
		from LAT_ContractVolume__c WHERE LAT_Contract__c =: contractId];//WHERE ProductGroup__c IN: pg

		uf = monthlyVolume.get(0).LAT_Contract__r.Account__r.Revenue_UF__c;
		System.debug('=======================\nuf:' +uf+ '\n=======================' );
		Set<Id> parentItemsIDs = new Set<Id>();
		Set<Id> childItems = new Set<Id>();
		Map<Id, Set<Id>> mapProductWithChilds = new Map<Id, Set<Id>>();
		Set<String> keysToConvertion = new Set<String>();

		for(LAT_ContractVolume__c contractVol : monthlyVolume ){
			parentItemsIDs.add(contractVol.ProductGroup__c);
		}

		System.debug('=======================\nparentItemsIDs' + parentItemsIDs+ '\n=======================' );

		// We must find the child product to compare withe sellout line
		List<LAT_ReferenceProductGrouping__c> parentItems = [SELECT Id, (Select Id, Parent__c FROM ReferenceProductGroupChilds__r)  FROM LAT_ReferenceProductGrouping__c where Id in :parentItemsIDs];
		for(LAT_ReferenceProductGrouping__c	 rpg : parentItems) {
			for(LAT_ReferenceProductGrouping__c child : rpg.ReferenceProductGroupChilds__r){
				childItems.add(child.Id);
				// Add key to convertions
				if(mapProductWithChilds.get(child.Parent__c) == null) {
					mapProductWithChilds.put(child.Parent__c, new Set<Id>{child.id});
				} else {
					mapProductWithChilds.get(child.Parent__c).add(child.id);
				}
			}
		}
		System.debug('=======================\nchildItems' + childItems+ '\n=======================' );
		System.debug('=======================\nmapProductWithChilds' + mapProductWithChilds+ '\n=======================' );

		List<LAT_ReferenceProduct__c> listRefProduct = [SELECT Id, Name, LAT_Product__c, LAT_Product__r.LAT_SKU__c, ReferenceGrouping__c FROM
		LAT_ReferenceProduct__c WHERE ReferenceGrouping__c in : childItems];

		System.debug('=======================\nlistRefProduct' + listRefProduct+ '\n=======================' );
		Map<Id, String> mapSKUsXProductGroup = new Map<Id, String>();
		for (LAT_ReferenceProduct__c refProd : listRefProduct) {
			mapSKUsXProductGroup.put(refProd.ReferenceGrouping__c, refProd.LAT_Product__r.LAT_SKU__c);
		}

		System.debug('=======================\nmapSKUsXProductGroup ' + mapSKUsXProductGroup+ '\n=======================' );
		// Get the collect sellout

		List<LAT_SellOutCollectLine__c> lines = [SELECT ReferenceProductGrouping__r.Name, Bottle__c, CreatedById, CreatedDate,
												CurrencyIsoCode, Dose__c, Id, IsDeleted, LastModifiedById, LastModifiedDate, Name,
												Positivated__c, ReferenceProductGrouping__c, SellOutCollect__c, SellOut__c, Stock__c,
												SystemModstamp, SellOutCollect__r.ReferencedMonth__c, SellOutCollect__r.RecordTypeId,
												SellOutCollect__r.recordType.Name , SellOutCollect__r.AccountID__c
												FROM LAT_SellOutCollectLine__c where ReferenceProductGrouping__c IN :childItems
												AND SellOutCollect__r.ReferencedMonth__c >= :startOfMonth
												AND SellOutCollect__r.ReferencedMonth__c < today // Today add filter here  :startOfNextMonth
												AND SellOutCollect__r.RecordType.Name = 'Nota Fiscal'
												AND SellOutCollect__r.AccountID__c IN :accountsId];

		// Get the collect sellout
		List<LAT_SellOutCollectLine__c> linesNotInContract = [SELECT ReferenceProductGrouping__r.Name, Bottle__c, CreatedById, CreatedDate,
																CurrencyIsoCode, Dose__c, Id, IsDeleted, LastModifiedById, LastModifiedDate, Name,
																Positivated__c, ReferenceProductGrouping__c, SellOutCollect__c, SellOut__c, Stock__c,
																SystemModstamp, SellOutCollect__r.ReferencedMonth__c, SellOutCollect__r.RecordTypeId,
																SellOutCollect__r.recordType.Name , SellOutCollect__r.AccountID__c,  ReferenceProductGrouping__r.parent__r.name
																FROM LAT_SellOutCollectLine__c where ReferenceProductGrouping__c NOT IN :childItems
																AND SellOutCollect__r.ReferencedMonth__c >= :startOfMonth
																AND SellOutCollect__r.ReferencedMonth__c < today //:startOfNextMonth
																AND SellOutCollect__r.RecordType.Name = 'Nota Fiscal'
																AND SellOutCollect__r.AccountID__c IN :accountsId];

		// Add the current keys to optimize the queries qty
		for(LAT_SellOutCollectLine__c line : lines){
			String key = '1-'+mapSKUsXProductGroup.get(line.ReferenceProductGrouping__c)+'-BT-LT';
			keysToConvertion.add(key);
		}

		// Check products not in the contract
		Set<Id> otherProductsReference = new set<Id>();
		for(LAT_SellOutCollectLine__c line : linesNotInContract){
			otherProductsReference.add(line.ReferenceProductGrouping__c);
		}
		List<LAT_ReferenceProduct__c> listRefProductNotInContract = [SELECT Id, Name, LAT_Product__c, LAT_Product__r.LAT_SKU__c, ReferenceGrouping__c FROM
		LAT_ReferenceProduct__c WHERE ReferenceGrouping__c in : otherProductsReference];

		System.debug('=======================\nlistRefProductNotInContract' + listRefProductNotInContract+ '\n=======================' );
		// Add to SKU MAP
		for (LAT_ReferenceProduct__c refProd : listRefProductNotInContract) {
			mapSKUsXProductGroup.put(refProd.ReferenceGrouping__c, refProd.LAT_Product__r.LAT_SKU__c);
		}
		// Add to the convertion key the products not in the contract
		for(LAT_SellOutCollectLine__c line : linesNotInContract){
			String key = '1-'+mapSKUsXProductGroup.get(line.ReferenceProductGrouping__c)+'-BT-LT';
			keysToConvertion.add(key);
		}

		System.debug('=======================\nkeysToConvertion ' + keysToConvertion+ '\n=======================' );

		List<LAT_UnitConversionRates__c> ucr = [SELECT Factor__c, LAT_KeyUnica__c FROM LAT_UnitConversionRates__c WHERE LAT_KeyUnica__c IN: keysToConvertion];

		System.debug('=======================\nucr ' + ucr+ '\n=======================' );
		// Save a Map with the childs items and the liters ammount
		Map<Id, Double> productLiters = new Map<Id, Double>();

		// Convert the collect line to liters
		for(LAT_SellOutCollectLine__c line : lines){
			String key = '1-'+mapSKUsXProductGroup.get(line.ReferenceProductGrouping__c)+'-BT-LT';
			Double factor = 1;
			// Save the factor
			for(LAT_UnitConversionRates__c lcr :ucr ) {
				if(lcr.LAT_KeyUnica__c == key ){
					factor = lcr.Factor__c;
				}
			}
			Double liters = line.SellOut__c * factor;
			if(productLiters.get(line.ReferenceProductGrouping__c) == null) {
				productLiters.put(line.ReferenceProductGrouping__c, liters );
			} else {
				Double currentLiters = productLiters.get(line.ReferenceProductGrouping__c);
				productLiters.put(line.ReferenceProductGrouping__c, currentLiters + liters );
			}
		}

		Map<Id, String> productNamesMap = new Map<Id, String> ();
		// Convert the collect line to liters PIRATE
		Map<String, Double> productLitersParent = new Map<String, Double>();
		for(LAT_SellOutCollectLine__c line : linesNotInContract){
			String key = '1-'+mapSKUsXProductGroup.get(line.ReferenceProductGrouping__c)+'-BT-LT';
			Double factor = 1;
			// Save the factor
			for(LAT_UnitConversionRates__c lcr :ucr ) {
				if(lcr.LAT_KeyUnica__c == key ){
					factor = lcr.Factor__c;
				}
			}
			Double liters = 0;
			if(line.SellOut__c != null) {
				liters = line.SellOut__c * factor;
			}
			if(productLitersParent.get(line.ReferenceProductGrouping__r.parent__c) == null) {
				productLitersParent.put(line.ReferenceProductGrouping__r.parent__c, liters );
			} else {
				Double currentLiters = productLitersParent.get(line.ReferenceProductGrouping__r.parent__c);
				productLitersParent.put(line.ReferenceProductGrouping__r.parent__c, currentLiters + liters );
			}
			productNamesMap.put(line.ReferenceProductGrouping__r.parent__c, line.ReferenceProductGrouping__r.parent__r.name);
		}

		System.debug('=======================\npproductLitersParent ' + productLitersParent+ '\n=======================' );
		System.debug('=======================\nproductLiters ' + productLiters+ '\n=======================' );

		// Map to agroup the liters ammount by parent like Chivas 12 - 20
		Map<Id, Double> parentTotalLiters = new Map<Id, Double>();

		for(Id keyId : mapProductWithChilds.keySet() ){
			Set<Id> chIds = mapProductWithChilds.get(keyId);
			Double parentLiters = 0;
			for(Id childID : chIds){
				if(productLiters.get(childID) != null){
					parentLiters = parentLiters + productLiters.get(childID);
				}
			}
			parentTotalLiters.put(keyId, parentLiters );
		}

		List<String> allProducts = new  List<String>();
		for (Id idProd : parentTotalLiters.keySet()) {
			allProducts.add(String.valueOf(idProd));
		}
		for (String idProd : productLitersParent.keySet()) {
			allProducts.add(idProd);
		}

		for (LAT_ContractVolume__c contractVol : monthlyVolume ){
			if (contractVol.ProductGroup__c != null) {
				allProducts.add(contractVol.ProductGroup__c);
			} else {
				System.debug('El LAT_ContractVolume__c : '+contractVol.id+' no tiene Agrupamiento de Producto');
			}
		}
		Map<String, Decimal> parentCostCM = getProductCostsByProdsXMonth(allProducts, uf);

		System.debug('=======================\nparentTotalLiters ' + parentTotalLiters+ '\n=======================' );
		Double totalPeriod  = 0;
		Decimal totalCMPeriod  = 0;
		Double totalParentLiters  = 0;
		Decimal totalCMParentLiters  = 0;
		htmlTable += '<table cellpadding="4" border="0" style="width: 100%; font: 12px/16px Arial, Helvetica" cellspacing="0"> <thead   bgcolor="#404784" > <tr bgcolor="#404784"> <th style=" text-align: left;" bgcolor="#404784">Produto</th> <th style=" text-align: left;" bgcolor="#404784">Volume Previsto(LT)</th><th style=" text-align: left;" bgcolor="#404784">CM Previsto</th> <th style=" text-align: left;" bgcolor="#404784">Volume Comprovado(LT)</th><th style=" text-align: left;" bgcolor="#404784">CM Comprovado</th> <th style=" text-align: left;" bgcolor="#404784">Meta Atingida?</th> </tr> </thead>';
		htmlTable += '<tbody>';
		Set<String> productosSincost = new Set<String>();
		for(LAT_ContractVolume__c contractVol : monthlyVolume ){
			Double costoProducto = 0;
			String notFound = 'N/F';
			Boolean hayCosto = false;
			if (parentCostCM.keySet().contains(contractVol.ProductGroup__c)) {
				hayCosto = true;
				costoProducto = parentCostCM.get(contractVol.ProductGroup__c); // TODO :Hacer logica para obtener este costo.
			}
			System.debug('=======================\ncostoProducto ' + costoProducto+ '\n=======================' );

			// If we are in the first month, the month elapsed is 0, and we must to calculate the total of liters
			// example: 10 liters of Chivas 12 per month, on the first month, we must buy 10, second month(month elapsed 1) 20, etc
			Decimal volumeInPeriod = contractVol.BoxesContract__c * (paymentMonthElapsed);
			System.debug('=======================\nvolumeInPeriod ' + volumeInPeriod+ '\n=======================' );
			String cmInPeriod     = String.valueOf((volumeInPeriod * costoProducto).setscale(2));
			String cmComprovado;
			if(parentTotalLiters.get(contractVol.ProductGroup__c) != null) {
				cmComprovado   = String.valueOf(Decimal.valueOf((parentTotalLiters.get(contractVol.ProductGroup__c)*costoProducto)).setscale(2));
			} else {
				cmComprovado   = '0';
			}
			
			System.debug('=======================\ncmInPeriod ' + cmInPeriod+ '\n=======================' );
			System.debug('=======================\nparentTotalLiters.get(contractVol.ProductGroup__c) ' + parentTotalLiters.get(contractVol.ProductGroup__c)+ '\n=======================' );
			
			if (!hayCosto) {
				productosSincost.add(contractVol.ProductGroup__c);
				cmInPeriod 		= notFound;
				cmComprovado 	= notFound;
			} 
			htmlTable += '<tr>';
			htmlTable += '<td><strong>'+contractVol.ProductGroup__r.Name+'</strong></td>';
			htmlTable += '<td>'+string.valueOf(volumeInPeriod)+'</td>';
			htmlTable += '<td>'+cmInPeriod+'</td>';
			if(parentTotalLiters.get(contractVol.ProductGroup__c) != null) {
				htmlTable += '<td>'+string.valueOf(parentTotalLiters.get(contractVol.ProductGroup__c))+'</td>';
			} else {
				htmlTable += '<td>0</td>';
			}
			
			htmlTable += '<td>'+cmComprovado+'</td>';
			totalPeriod = totalPeriod + volumeInPeriod;
			if (cmInPeriod != notFound) {
				totalCMPeriod = totalCMPeriod + Decimal.valueOf(cmInPeriod);
			} 
			if(parentTotalLiters.get(contractVol.ProductGroup__c) != null){
				totalParentLiters = totalParentLiters + parentTotalLiters.get(contractVol.ProductGroup__c);
				totalCMParentLiters = totalCMParentLiters + parentTotalLiters.get(contractVol.ProductGroup__c)*costoProducto;
			}
			
			if(parentTotalLiters.get(contractVol.ProductGroup__c) != null){
				if(parentTotalLiters.get(contractVol.ProductGroup__c) >= volumeInPeriod){
					htmlTable += '<td>Sim</td>';
					status.put(contractVol.ProductGroup__r.Name, 'YES - '+String.valueOf(volumeInPeriod)+ ' - ' + string.valueof(parentTotalLiters.get(contractVol.ProductGroup__c)));
				} else {
					htmlTable += '<td>Não</td>';
					status.put(contractVol.ProductGroup__r.Name, 'NO - '+String.valueOf(volumeInPeriod)+ ' - ' + string.valueof(parentTotalLiters.get(contractVol.ProductGroup__c)));
				}
			} else {
				htmlTable += '<td>Não</td>';
				status.put(contractVol.ProductGroup__r.Name, 'NO - '+String.valueOf(volumeInPeriod)+ ' - 0');
			}
			htmlTable += '</tr>';
		}

		System.debug('=======================\npproductLitersParent ' + productLitersParent+ '\n=======================' );
		//Products bought not in the contract
		
		for(String parentProd : productLitersParent.keySet()){
			Double costoParentProd = 0;
			String notFound = 'N/F';
			Boolean hayCosto = false;
			if (parentCostCM.keySet().contains(parentProd)) {
				hayCosto = true;
				costoParentProd = parentCostCM.get(parentProd); 
			}		
			String cmComprovado = string.valueOf(Decimal.valueOf((productLitersParent.get(parentProd)*costoParentProd)).setscale(2));
			if (!hayCosto) {
				productosSincost.add(parentProd);
				cmComprovado = notFound;
			}

			htmlTable += '<tr>';
			htmlTable += '<td><strong>'+productNamesMap.get(parentProd)+'</strong></td>';
			htmlTable += '<td>0</td>';
			htmlTable += '<td>0</td>';
			htmlTable += '<td>'+string.valueOf(productLitersParent.get(parentProd))+'</td>';
			htmlTable += '<td>'+cmComprovado+'</td>';
			htmlTable += '<td>Sim</td>';

			totalParentLiters = totalParentLiters + productLitersParent.get(parentProd);
			totalCMParentLiters = totalCMParentLiters + productLitersParent.get(parentProd)*costoParentProd;
			htmlTable += '</tr>';

		}
		htmlTable += '</tbody>';
		String metaAtingidaTotalCM = 'Não';
		if (totalCMParentLiters > totalCMPeriod) {
			metaAtingidaTotalCM = 'Sim';
		}
		htmlTable += '<tfoot><tr><td><strong>TOTAL</strong></td><td><strong>'+string.valueOf(totalPeriod)+'</strong></td><td></td><td><strong>'+string.valueOf(totalParentLiters)+'</strong></td><td></td><td></td></tr></tfoot>';
		htmlTable += '</table>';

		String firstTable = createCMHeaderTable(String.valueOf(totalCMPeriod.setscale(2)), String.valueOf(totalCMParentLiters.setscale(2)), metaAtingidaTotalCM);

		System.debug('=======================\nhtml' + htmlTable+ '\n=======================' );
		System.debug('=======================\nstatus' + status+ '\n=======================' );
		payRet.statusCode = 'META ATINGIDA';

		// If one of the goal volumes is not reached, the payment is invalid
		String att = 'Sim';
		for(String st : status.keySet()){
			if(status.get(st).contains('NO')){
				payRet.statusCode = 'META NAO ATINGIDA';
				att = 'Não';
				//payRet.description =  (payRet.description == null) ?  st : payRet.description  +  ' - ' +  status.get(st);
			} else {
				att = 'Sim';
			}
			payRet.description =  (payRet.description == null) ?  st + ' ' + status.get(st).replace('YES ', '').replace('NO ', '') +' - '+att : payRet.description  +  ' | ' + st + ' ' +  status.get(st).replace('YES ', '').replace('NO ', '') +' - '+att;
		}

		payRet.mailTemplate = firstTable + htmlTable;
		System.debug('=======================\npayRet  ' + payRet+ '\n=======================' );
		if(productosSincost.size() > 0 && con.Recordtype.Developername <> 'LAT_Eventos_Contrato_de_Parceria'){
			sendEmailProductsNotFound(productosSincost, con, uf);
		}
		return payRet;
	}

	/*
	* calculateGainFromInvestment
	* @param List cVolume
	*
	*/
	private static Double calculateGainFromInvestment(List<LAT_ContractsWS.ContractVolume> cVolume, Integer months, String uf ){
		Map<Id, Double> productGroupMap = new Map<Id, Double>();
		for(LAT_ContractsWS.ContractVolume cV : cVolume){
			Id productGroup = cV.product;
			Double volume = cV.boxesMinimum;
			if(productGroupMap.containsKey(productGroup)){
				Double currentVolume = productGroupMap.get(productGroup);
				productGroupMap.put(productGroup, currentVolume + volume);
			}
			else {
				//If not exists create a new map item
				productGroupMap.put(productGroup, volume);
			}
		}
		Double monthlyGain = calculateGainFromInvestmentBoxes(productGroupMap, uf);
		Double totalGain = monthlyGain * months;
		return totalGain;
	}

	/*
	* calculateGainFromInvestmentBoxes
	*
	* @param Map productGroupMap
	* @return double Bounus Invesment
	*/
	private static double calculateGainFromInvestmentBoxes(Map<Id, Double> mapProductGroup, String strUF){
		List<LAT_ContractsCalculations.productCost> lstProductCosts = null;
		List<LAT_ContractsCalculations.productCost> lstProductCostsResult = null;
		LAT_ContractsCalculations.productCost objProductCost = null;
		Set<Id> setProductsId = null;
		Set<Id> setProductsNotFound = null;
		LAT_ContractsCalculations objContractCalculations = null;
		Double inv = null;
		ProductErrorClass objError = null;
		Double dblVolume = null;

		System.debug('calculateGainFromInvestmentBoxes [mapProductGroup : ' + mapProductGroup + ' - strUF : ' + strUF + '] ->');

		setProductsId = mapProductGroup.keySet();
		lstProductCosts = new List<LAT_ContractsCalculations.productCost>();
		setProductsNotFound = new Set<Id>();
		inv = 0;
		
		for (Id strProductId : setProductsId){
			objProductCost = new LAT_ContractsCalculations.productCost();
			objProductCost.productId = strProductId;

			lstProductCosts.add(objProductCost);
			setProductsNotFound.add(strProductId);
			//productError.put(productId, 'NO PRODUCT PRICE');
		}

		System.debug('calculateGainFromInvestmentBoxes [lstProductCosts : ' + lstProductCosts + ']');
		System.debug('calculateGainFromInvestmentBoxes [setProductsNotFound : ' + setProductsNotFound + ']');

		objContractCalculations = new LAT_ContractsCalculations();
		lstProductCostsResult = new List<LAT_ContractsCalculations.productCost>();
		
		System.debug('calculateGainFromInvestmentBoxes [lstProductCosts : ' + lstProductCosts + ']');
		lstProductCostsResult = objContractCalculations.getProductAverages(lstProductCosts, strUF, 'LAT_ContractVolume');
		System.debug('calculateGainFromInvestmentBoxes [lstProductCostsResult : ' + lstProductCostsResult + ']');

		for(LAT_ContractsCalculations.productCost objProductCostAux : lstProductCostsResult ) {
			setProductsNotFound.remove(objProductCostAux.productId);
		}

		if(setProductsNotFound != null && !setProductsNotFound.IsEmpty()) {
			for (Id strProductId : setProductsId){
				if(setProductsNotFound.contains(strProductId)){
					objError = new productErrorClass();
					objError.productId = strProductId;
					objError.skuName= 'Unknow';
					objError.type='Custo de Produto';
					objError.recordType = 'Volume Contrato';

					customErrors.add(objError);
				}
			}
		}

		System.debug('calculateGainFromInvestmentBoxes [setProductsNotFound : ' + setProductsNotFound + ']');
		System.debug('calculateGainFromInvestmentBoxes [customErrors : ' + customErrors + ']');

		lstProductCostsResult = convertUnits(lstProductCostsResult, 'LT');

		System.debug('calculateGainFromInvestmentBoxes [lstProductCostsResult (converted): ' + lstProductCostsResult + ']');

		for(LAT_ContractsCalculations.productCost objProductCostAux : lstProductCostsResult){
			dblVolume = mapProductGroup.get(objProductCostAux.productId);
			
			System.debug('calculateGainFromInvestmentBoxes [productId : ' + objProductCostAux.productId + ' -  dblVolume : ' + dblVolume + ']');

			if(objProductCostAux.cmCase == null || dblVolume == null ){
				errorOnProducts = (errorOnProducts != null)? errorOnProducts + ' - ' + objProductCostAux.skuName : objProductCostAux.skuName;
			} else {
				inv =  inv + (objProductCostAux.cmCase * dblVolume);
			}
		}

		System.debug('calculateGainFromInvestmentBoxes [' + inv + '] <-');

		return inv;
	}

	private static String getConversionRateKey(Map<Id, String> skuByProductGroup, Id productId, String fromUnit, String toUnit) {
		String sku = skuByProductGroup.get(productId); 
		
		return '1-' + sku + '-' + fromUnit + '-' + toUnit;
	}

	@TestVisible
	private static LAT_ContractsCalculations.productCost applyFactor(LAT_ContractsCalculations.productCost productCost, Decimal firstFactor, Decimal secondFactor) {
		if (secondFactor == null) secondFactor = 1;	

		productCost.nis = (productCost.nis / secondFactor) / firstFactor;
		productCost.ldCost = (productCost.ldCost / secondFactor) / firstFactor;
		productCost.distCost = (productCost.distCost / secondFactor) / firstFactor;
		productCost.cmCase = (productCost.cmCase  / secondFactor) / firstFactor;
		productCost.hasSKU = true;

		return productCost;
	}

	@TestVisible
	private static Map<String, Id> getKeyByProductGroup(List<LAT_ContractsCalculations.productCost> productCosts, Map<Id, String> skuByProductGroup, String unit) {
		Map<String, Id> keyByProductGroup = new Map<String, Id>();

		for(LAT_ContractsCalculations.productCost productCost : productCosts) {

			String fromUnit = productCost.unitOfMeasurement;
			String toUnit = unit;
			String key = getConversionRateKey(skuByProductGroup, productCost.productId, fromUnit, toUnit);

			keyByProductGroup.put(key, productCost.productId);
		}

		return keyByProductGroup;
	}

	public static List<LAT_ContractsCalculations.productCost> convertEventUnits(List<LAT_ContractsCalculations.productCost> productCosts, Map<Id, Double> productGroupMap, String unit) {		
		List<Id> productCostIds = new List<Id>();
		Map<Id, String> skuByProductGroup = new Map<Id, String>();
		Map<String, Decimal> factorByKey = new Map<String, Decimal>();
		Map<Id, LAT_ContractsCalculations.productCost> productCostByProductId = new Map<Id, LAT_ContractsCalculations.productCost>();

		for (LAT_ContractsCalculations.productCost productCost : productCosts) {
			productCostIds.add(productCost.productId);
		}
		List<LAT_ReferenceProduct__c> referenceProducts = new LAT_ReferenceProductRepository().findByReferenceGrouping(productCostIds);

		for (LAT_ReferenceProduct__c referenceProduct : referenceProducts) {
			skuByProductGroup.put(referenceProduct.ReferenceGrouping__c, referenceProduct.LAT_Product__r.LAT_SKU__c);
		}

		for (LAT_ContractsCalculations.productCost productCost : productCosts) {
			productCostByProductId.put(productCost.productId, productCost);
		}

		Map<String, Id> keyByProductGroup = getKeyByProductGroup(productCosts, skuByProductGroup, unit);

		List<LAT_UnitConversionRates__c> unityConversionRates = new LAT_UnitConversionRatesRepository().findByKeyUnica(new List<String>(keyByProductGroup.keySet())); 
		for (LAT_UnitConversionRates__c unityConversionRate : unityConversionRates) {
			factorByKey.put(unityConversionRate.LAT_KeyUnica__c, unityConversionRate.Factor__c);
		}

		for (LAT_ContractsCalculations.productCost productCost : productCosts) {
			String fromUnit = productCost.unitOfMeasurement;
			String toUnit = unit;

			if (fromUnit == 'CA' && toUnit == 'BT') {
				String key = getConversionRateKey(skuByProductGroup, productCost.productId, fromUnit, toUnit);			

				Decimal factor = (factorByKey.get(key) == null) ? 0 : factorByKey.get(key);
				System.debug('convertEventUnits [productGroupMap.get(productCost.productId) : ' + productGroupMap.get(productCost.productId) + ']');

				Double quantity = (productGroupMap.get(productCost.productId) == null) ? 0 : productGroupMap.get(productCost.productId);
				System.debug('convertEventUnits [quantity : ' + quantity + ']');
				Double convertedQtt = quantity/factor;

				System.debug('convertEventUnits [productCost.ldCost : ' + productCost.ldCost + ']');
				System.debug('convertEventUnits [convertedQtt : ' + convertedQtt + ']');
				productCost.ldCost = productCost.ldCost * convertedQtt;
				continue;
			}
		}

		return productCosts;
	}

	/* convertUnits
	* Now we have boxes, liters and bottles, this method recive the LAT_ContractsCalculations.productCost and the convertion unit, and will
	* return the productCost in the new uni
	* @param List<LAT_ContractsCalculations.productCost> product  cost
	* @param String new unit
	*/
	public static List<LAT_ContractsCalculations.productCost> convertUnits(List<LAT_ContractsCalculations.productCost> lstProductCosts, String strUF) {
		LAT_UnitConversionRatesRepository objUnitConversionRatesRepository = null;
		List<LAT_UnitConversionRates__c> lstUnitsConversionRates = null;
		LAT_UnitConversionRates__c objUnitsConversionRates = null;
		List<Id> lstProductCostIds = null;
		List<LAT_ReferenceProduct__c> lstReferenceProducts = null;
		Map<Id, String> mapSKUByProductGroup = null;
		String strFROMUnit = null;
		String strTOUnit = null;
		String strKey = null;
		List<String> lstUnitsConvertions = null;
		Map<String, LAT_UnitConversionRates__c> mapConvertionUnits = null;
		Decimal dblFactor1 = null;
		Decimal dblFactor2 = null;
		ProductErrorClass objError = null;
		String strKeyCABT = null;
		String strKeyBTLT = null;

		System.debug('convertUnits [lstProductCosts : ' + lstProductCosts + ' - strUF : ' + strUF + '] ->');

		objUnitConversionRatesRepository = new LAT_UnitConversionRatesRepository();
		lstProductCostIds = new List<Id>();

		for(LAT_ContractsCalculations.productCost objProductCost : lstProductCosts) {
			lstProductCostIds.add(objProductCost.productId);
		}
		System.debug('convertUnits [lstProductCostIds : ' + lstProductCostIds + ']');

		lstReferenceProducts = new LAT_ReferenceProductRepository().findByReferenceGrouping(lstProductCostIds);
		System.debug('convertUnits [lstReferenceProducts : ' + lstReferenceProducts + ']');

		mapSKUByProductGroup = new Map<Id, String>();
		for (LAT_ReferenceProduct__c objReferenceProduct : lstReferenceProducts) {
			mapSKUByProductGroup.put(objReferenceProduct.ReferenceGrouping__c, objReferenceProduct.LAT_Product__r.LAT_SKU__c);
		}

		System.debug('convertUnits [mapSKUByProductGroup : ' + mapSKUByProductGroup + ']');
		
		lstUnitsConvertions = new List<String>();
		for(LAT_ContractsCalculations.productCost objProductCost : lstProductCosts) {
			strFROMUnit = objProductCost.unitOfMeasurement;
			strTOUnit = strUF;

			if(strFROMUnit != strTOUnit ) { 
				if(strFROMUnit == 'CA' && strTOUnit == 'LT') {
					strKey = getConversionRateKey(mapSKUByProductGroup, objProductCost.productId, 'CA', 'BT');
					lstUnitsConvertions.add(strKey);
					strKey = getConversionRateKey(mapSKUByProductGroup, objProductCost.productId, 'BT', 'LT');
					lstUnitsConvertions.add(strKey);
				} else {
					strKey = getConversionRateKey(mapSKUByProductGroup, objProductCost.productId, strFROMUnit, strTOUnit);
					lstUnitsConvertions.add(strKey);
				}
			}
		}
		System.debug('convertUnits [lstUnitsConvertions : ' + lstUnitsConvertions + ']');
		mapConvertionUnits = new Map<String, LAT_UnitConversionRates__c>();

		if(!lstUnitsConvertions.IsEmpty()) {
			lstUnitsConversionRates = objUnitConversionRatesRepository.findByKeyUnica(lstUnitsConvertions); 
			System.debug('convertUnits [lstUnityConversionRates : ' + lstUnitsConversionRates + ']');

			if(!lstUnitsConversionRates.IsEmpty()) {
				for(LAT_UnitConversionRates__c objUnitConvertionRate : lstUnitsConversionRates) {
					if(!mapConvertionUnits.containsKey(objUnitConvertionRate.LAT_KeyUnica__c)) {
						mapConvertionUnits.put(objUnitConvertionRate.LAT_KeyUnica__c, objUnitConvertionRate);
					}
				}
			}
		}
		
		System.debug('convertUnits [mapConvertionUnits : ' + mapConvertionUnits + ']');

		for(LAT_ContractsCalculations.productCost objProductCost : lstProductCosts) {
			strFROMUnit = objProductCost.unitOfMeasurement;
			strTOUnit = strUF;

			if(strFROMUnit != strTOUnit ) {
				// We cant convert from CA to LT, so we need to convert to bottle first
				if(strFROMUnit == 'CA' && strTOUnit == 'LT') {
					strKeyCABT = getConversionRateKey(mapSKUByProductGroup, objProductCost.productId, 'CA', 'BT');
					strKeyBTLT = getConversionRateKey(mapSKUByProductGroup, objProductCost.productId, 'BT', 'LT');

					if(mapConvertionUnits.containsKey(strKeyBTLT) && mapConvertionUnits.containsKey(strKeyCABT)) {
						if (mapConvertionUnits.get(strKeyBTLT).Factor__c != null && mapConvertionUnits.get(strKeyCABT).Factor__c != null) {
							// If the value is 1, we have to sum 0 , Math factorization
							dblFactor1 = mapConvertionUnits.get(strKeyBTLT).Factor__c;
							dblFactor2 = mapConvertionUnits.get(strKeyCABT).Factor__c;
							
							objProductCost = applyFactor(objProductCost, dblFactor1, dblFactor2);
							System.debug('convertUnits [objProductCost : ' + objProductCost + ']');
						} else {							
							objProductCost.hasSKU = false;
							errorOnProducts = (errorOnProducts != null)? errorOnProducts + ' - ' + objProductCost.skuName : objProductCost.skuName;
							productError.put(objProductCost.productId, 'Conversão Unidade de Medida/SKU Referência');
							objError = new productErrorClass(objProductCost, 'Conversão Unidade de Medida/SKU Referência');
							customErrors.add(objError);

							System.debug('convertUnits [objError : ' + objError + ']');
						}
					} else {
						objProductCost.hasSKU = false;
						errorOnProducts = (errorOnProducts != null)? errorOnProducts + ' - ' + objProductCost.skuName : objProductCost.skuName;
						productError.put(objProductCost.productId, 'Conversão Unidade de Medida/SKU Referência');
						objError = new productErrorClass(objProductCost, 'Conversão Unidade de Medida/SKU Referência');
						customErrors.add(objError);
					}
				} else {

					strKey = getConversionRateKey(mapSKUByProductGroup, objProductCost.productId, strFROMUnit, strTOUnit);

					if(mapConvertionUnits.containsKey(strKey) && mapConvertionUnits.get(strKey) != null && mapConvertionUnits.get(strKey).Factor__c != null) {
						objUnitsConversionRates = mapConvertionUnits.get(strKey);
						objProductCost.nis = objProductCost.nis * objUnitsConversionRates.Factor__c;
						objProductCost.ldCost = objProductCost.ldCost * objUnitsConversionRates.Factor__c;
						objProductCost.distCost = objProductCost.distCost * objUnitsConversionRates.Factor__c;
						objProductCost.cmCase = objProductCost.cmCase * objUnitsConversionRates.Factor__c;
						objProductCost.hasSKU = true;
						System.debug('convertUnits [objProductCost : ' + objProductCost + ']');
					} else {						
						objProductCost.hasSKU = false;
						errorOnProducts = (errorOnProducts != null)? errorOnProducts + ' - ' + objProductCost.skuName : objProductCost.skuName;
						productError.put(objProductCost.productId, 'Conversão Unidade de Medida/SKU Referência');
						objError = new productErrorClass(objProductCost, 'Conversão Unidade de Medida/SKU Referência');
						customErrors.add(objError);

						System.debug('convertUnits [objError : ' + objError + ']');

					}
				}

				System.debug('convertUnits [mapConvertionUnits : ' + mapConvertionUnits + ']');
			}
		}

		System.debug('convertUnits [' + lstProductCosts+ '] <-');
		return lstProductCosts;
	}

	/*
	public static List<LAT_ContractsCalculations.productCost> convertUnits(List<LAT_ContractsCalculations.productCost> lstProductCosts, String strUF) {
		LAT_UnitConversionRatesRepository objUnitConversionRatesRepository = null;
		List<LAT_UnitConversionRates__c> lstUnityConversionRates = null;
		List<Id> lstProductCostIds = null;
		List<LAT_ReferenceProduct__c> lstReferenceProducts = null;
		Map<Id, String> mapSKUByProductGroup = null;
		String strFROMUnit = null;
		String strTOUnit = null;
		String strKeyCABT = null;
		String strKeyBTLT = null;
		Ma

		System.debug('convertUnits [lstProductCosts : ' + lstProductCosts + ' - strUF : ' + strUF + '] ->');

		objUnitConversionRatesRepository = new LAT_UnitConversionRatesRepository();
		lstProductCostIds = new List<Id>();

		for(LAT_ContractsCalculations.productCost objProductCost : lstProductCosts) {
			lstProductCostIds.add(objProductCost.productId);
		}
		System.debug('convertUnits [lstProductCostIds : ' + lstProductCostIds + ']');

		lstReferenceProducts = new LAT_ReferenceProductRepository().findByReferenceGrouping(lstProductCostIds);
		System.debug('convertUnits [lstReferenceProducts : ' + lstReferenceProducts + ']');

		mapSKUByProductGroup = new Map<Id, String>();
		for (LAT_ReferenceProduct__c objReferenceProduct : lstReferenceProducts) {
			mapSKUByProductGroup.put(objReferenceProduct.ReferenceGrouping__c, objReferenceProduct.LAT_Product__r.LAT_SKU__c);
		}

		System.debug('convertUnits [mapSKUByProductGroup : ' + mapSKUByProductGroup + ']');

		for(LAT_ContractsCalculations.productCost objProductCost : lstProductCosts) {
			strFROMUnit = productCost.unitOfMeasurement;
			strTOUnit = strUF;

			if(strFROMUnit != strTOUnit ) {
				// We cant convert from CA to LT, so we need to convert to bottle first
				if(strFROMUnit == 'CA' && strTOUnit == 'LT') {
					strKeyCABT = getConversionRateKey(mapSKUByProductGroup, objProductCost.productId, 'CA', 'BT');
					strKeyBTLT = getConversionRateKey(mapSKUByProductGroup, objProductCost.productId, 'BT', 'LT');

					lstUnityConversionRates = unitConversionRatesRepository.findByKeyUnica(new List<String>{keyCABT, keyBTLT}); 

					if(unityConversionRates.size() == 2) {

						if (unityConversionRates.get(0).Factor__c != null && unityConversionRates.get(1).Factor__c != null) {
							// If the value is 1, we have to sum 0 , Math factorization
							Decimal factor1 = unityConversionRates.get(0).Factor__c;
							Decimal factor2 = unityConversionRates.get(1).Factor__c;

							productCost = applyFactor(productCost, factor1, factor2);

						} else {
							
							productCost.hasSKU = false;
							errorOnProducts = (errorOnProducts != null)? errorOnProducts + ' - ' + productCost.skuName : productCost.skuName;
							productError.put(productCost.productId, 'Conversão Unidade de Medida/SKU Referência');
							productErrorClass myError = new productErrorClass(productCost, 'Conversão Unidade de Medida/SKU Referência');

							customErrors.add(myError);
						}

					} else {

						productCost.hasSKU = false;
						productError.put(productCost.productId, 'Conversão Unidade de Medida/SKU Referência');
						productErrorClass myError = new productErrorClass(productCost, 'Conversão Unidade de Medida/SKU Referência');

						customErrors.add(myError);
						errorOnProducts = (errorOnProducts != null)? errorOnProducts + ' - ' + productCost.skuName : productCost.skuName;
					}

				} else {

					String key = getConversionRateKey(skuByProductGroup, productCost.productId, fromUnit, toUnit);

					List<LAT_UnitConversionRates__c> unityConversionRates = unitConversionRatesRepository.findByKeyUnica(new List<String>{key}); 

					if(!unityConversionRates.isEmpty()){

						LAT_UnitConversionRates__c convRate = unityConversionRates.get(0);
						Decimal factor = convRate.Factor__c;

						if (factor != null) {

							productCost.nis = productCost.nis * factor;
							productCost.ldCost = productCost.ldCost * factor;
							productCost.distCost = productCost.distCost * factor;
							productCost.cmCase = productCost.cmCase * factor;
							productCost.hasSKU = true;
						
						} else {
						
							productCost.hasSKU = false;
							productError.put(productCost.productId, 'Conversão Unidade de Medida/SKU Referência');
							productErrorClass myError = new productErrorClass(productCost, 'Conversão Unidade de Medida/SKU Referência');

							customErrors.add(myError);
							errorOnProducts = (errorOnProducts != null)? errorOnProducts + ' - ' + productCost.skuName : productCost.skuName;
						}

					} else {
						
						productCost.hasSKU = false;
						productError.put(productCost.productId, 'Conversão Unidade de Medida/SKU Referência');
						productErrorClass myError = new productErrorClass(productCost, 'Conversão Unidade de Medida/SKU Referência');
						
						customErrors.add(myError);
						errorOnProducts = (errorOnProducts != null)? errorOnProducts + ' - ' + productCost.skuName : productCost.skuName;
					}
				}
			}

		}

		return productCosts;
	}
	*/

	/*
	* calculateInvestment
	* Sum the payments in money and group the boxes to calculate the cost
	* @param List of Payments
	* @return double pernod investment
	*/
	private static Double calculateInvestment(List<LAT_ContractsWS.Payments> payments, String uf){

		List<Double> invGroup = calculateInvestmentGroupedByType(payments, uf);
		system.debug(invGroup + '<<<<<<<<<<< INVG');
		Double inv = 0;
		if(invGroup.size() >= 2){
			invGroup.remove(2);
		}
		for(Double invG : invGroup){
			inv = inv+invG;
		}
		return inv;
	}

	/*
	* calculateInvestment
	* Sum the payments in money and group the boxes to calculate the cost
	* @param List of Payments
	* @return double pernod investment
	*/
	private static List<Double> calculateInvestmentGroupedByType(List<LAT_ContractsWS.Payments> payments, String uf){
		Double invMoney = 0;
		Double invProducts = 0;
		Double invProductsLDCost = 0;

		List<Double> retInv = new List<Double>();

		//Note: I want group the products only to optimize queries to the database
		Map<Id, Double> productGroupMap = new Map<Id, Double>();

		for(LAT_ContractsWS.Payments payment: payments){
			// If the type is money, we only need sum the values
			if(payment.recordType == 'Pagamento Dinheiro' || payment.recordType.contains(Global_RecordTypeCache.getRtId('LAT_Payment__c'+'LAT_PagamentoDinheiro'))){
				invMoney = invMoney + payment.ammount;
			}
			else if(payment.recordType == 'Pagamento Produto' || payment.recordType.contains(Global_RecordTypeCache.getRtId('LAT_Payment__c'+'LAT_PagamentoProduto'))){
				Id productGroup = payment.productGroup;
				Double volume = payment.volumen;
				//If exists I must add the volume to the current volume
				if(productGroupMap.containsKey(productGroup)){
					Double currentVolume = productGroupMap.get(productGroup);
					productGroupMap.put(productGroup, currentVolume + volume);
				}
				else {
					//If not exists create a new map item
					productGroupMap.put(productGroup, volume);
				}
			}
		}

		retInv.add(invMoney);
		//invProducts = calculateBonusInvestment(productGroupMap, invMoney);
		invProductsLDCost = calculateBonusInvestment(productGroupMap, 0, 'LDCOST', uf);
		retInv.add(invProductsLDCost);

		invProducts= calculateBonusInvestment(productGroupMap, 0,uf);
		retInv.add(invProducts);
		return retInv;
	}


	/*
	* calculateBonusInvestment
	* Check the product cost and calculate the total investments in product boxes
	* @param Map productGroupMap
	* @param Double currentInv
	* @return double Bounus Invesment
	*/
	private static double calculateBonusInvestment(Map<Id, Double> productGroupMap, double currentInv, String uf){
		return calculateBonusInvestment(productGroupMap, currentInv, 'DISTRIBUTORCOST', uf);
	}

	/*
	* calculateBonusInvestment
	* Check the product cost and calculate the total investments in product boxes
	* @param Map productGroupMap
	* @param Double currentInv
	* @param string type
	* @param string uf
	* @return double calculation
	*/
	private static double calculateBonusInvestment(Map<Id, Double> productGroupMap, double currentInv, string type, String uf){
		//Set<Id> productsId = productGroupMap.keySet();
		//List<LAT_ProductCost__c> products = [SELECT CM_Case__c,DistributorCost__c,EndDate__c,Id,LDCost__c,Name,Net_Sales_Case__c,Product__c,StartDate__c,UF__c FROM LAT_ProductCost__c where Product__c IN : productsId and EndDate__c > today and UF__c =: uf order by id desc];

		system.debug('%$^%^%^%^%%^' + productGroupMap);

		// New implementation using average by channels
		List<LAT_ContractsCalculations.productCost> productCosts = new List<LAT_ContractsCalculations.productCost>();
		Set<Id> invalidProducts = new Set<Id>();

		for (String productId : productGroupMap.keySet()){
			LAT_ContractsCalculations.productCost c = new LAT_ContractsCalculations.productCost();
			c.productId = productId;
			productCosts.add(c);
			invalidProducts.add(productId);
		}

		system.debug('invalidProducts' + invalidProducts);

		LAT_ContractsCalculations LL = new LAT_ContractsCalculations();
		List<LAT_ContractsCalculations.productCost> productCostsResult = new List<LAT_ContractsCalculations.productCost>();
		productCostsResult = LL.getProductAverages(productCosts, uf, 'LAT_ProductPayment');

		//if(productCostsResult.size() < productCosts.size()){
			for(LAT_ContractsCalculations.productCost pr : productCostsResult ) {
				invalidProducts.remove(pr.productId);
			}
		//}

		system.debug('invalidProducts' + invalidProducts);

		if(invalidProducts.size()>0) {
			for (Id productId : productGroupMap.keySet()){
				if(invalidProducts.contains(productId)){
					// We call this method twice to calculate based on distriburor or ld cost, we dont wants duplicate errors,
					if(type == 'LDCOST'){
						productErrorClass myError = new productErrorClass();
						myError.productId = productId;
						myError.skuName= 'Unknow';
						myError.type='Custo de Produto';
						myError.recordType = 'Pagamento Produto';
						customErrors.add(myError);
					}

				}
			}
		}

		system.debug(productCostsResult + ' < ---- P cost before transformation payment ><><>>>>>>>>>>>>>>');
		// We must convert to LT
		productCostsResult = convertUnits(productCostsResult, 'CA');
		system.debug(productCostsResult + ' < ---- P cost after transformation payment ><><>>>>>>>>>>>>>>');

		for(LAT_ContractsCalculations.productCost prod : productCostsResult){
			Double volume = productGroupMap.get(prod.productId);
			if(type == 'DISTRIBUTORCOST'){
				currentInv =  currentInv + (prod.distCost * volume);
			}
			else if(type == 'LDCOST'){
				currentInv =  currentInv + (prod.ldCost * volume);
			} else {
				currentInv =  currentInv + (prod.cmCase * volume);
			}
		}

		return currentInv;
	}

	public static Map<String, Decimal> getProductCostsByProdsXMonth(List<String> idProducts, String uf) {
		System.debug('%%%% entramos en el getProductCostsByProdsXMonth con idProducts : '+idProducts +' y UF : '+uf);
		Map<String, Decimal> retorno = new Map<String, Decimal>();
		List<LAT_ContractsCalculations.productCost> params = new List<LAT_ContractsCalculations.productCost>();
		for (String prodId : idProducts) {
			LAT_ContractsCalculations.productCost pcw = new LAT_ContractsCalculations.productCost();
			pcw.productId =prodId;
			params.add(pcw);
		}
		LAT_ContractsCalculations cl = new LAT_ContractsCalculations();
		List<LAT_ContractsCalculations.productCost> aux = cl.getProductAverages(params,uf, 'LAT_ContractVolume');
		System.debug('%%%% retorno de ejecutar el aux : '+aux);
		List<LAT_ContractsCalculations.productCost> prodConCosto = convertUnits(aux, 'LT');
		System.debug('%%%% retorno de ejecutar el prodConCosto : '+prodConCosto);

		for (LAT_ContractsCalculations.productCost pcw : prodConCosto) {
			System.debug('%%%% estamos recorriendo el retorno');

			retorno.put(pcw.productId, pcw.cmCase);
			System.debug('%%%% insertamos en el retorno Todo :' +retorno);
			System.debug('%%%% insertamos en el retorno Este en particular:' +retorno.get(pcw.productId));
		}
		System.debug('%%%% nos vamos con el siguiente retorno :' +retorno);
		return retorno;
	}

	public static String createCMHeaderTable(String cmPrevisto, String cmComprovado, String metaAtingida) {
		String htmlTable = '<table cellpadding="4" border="0" style="width: 100%; font: 12px/16px Arial, Helvetica" cellspacing="0"><thead   bgcolor="#404784" ><tr bgcolor="#404784"><th style=" text-align: left;" bgcolor="#404784">Meta CM</th><th style=" text-align: left;" bgcolor="#404784">CM Previsto(BRL)</th><th style=" text-align: left;" bgcolor="#404784">CM Realizado(BRL)</th><th style=" text-align: left;" bgcolor="#404784">Meta Atingida?</th></tr></thead>';
		htmlTable += '<tbody>';
		htmlTable += '<tr><td></td>';
		htmlTable += '<td>'+cmPrevisto+'</td>';
		htmlTable += '<td>'+cmComprovado+'</td>';
		htmlTable += '<td>'+metaAtingida+'</td>';

		htmlTable += '</tr></tbody></table>';
		return htmlTable;
	}
	/*
	* productCost
	* Inner class
	*/
	public class productErrorClass {
		public Id productId { get; set; }
		public String skuName { get; set; }
		public String type { get; set; }
		public String recordType { get; set; }
		
		public productErrorClass(){}

		public productErrorClass(LAT_ContractsCalculations.productCost productCost, String errorType) {
			this.productId = productCost.productId;
			this.skuName = productCost.skuName;
			this.type = errorType; 
		}
	}

	public static void sendEmailProductsNotFound(Set<String> productosSincost, LAT_Contract2__c con, String uf){	
		String emailSubject = 'Se encontraron Agrupamientos de Producto sin Costo';
		String emailBody = 'Estimado, </br>Se encontraron los siguientes Agrupamientos de Producto sin Costos para el contrato <b>'+ con.Name + '</b> (Id  : ' +con.Id +'): </br></br>';
		emailBody += '<b>UF: ' +uf+ '</b></br>Agrupamientos: ';
		for(String s: productosSincost){
			emailBody += '</br> - '+ URL.getSalesforceBaseUrl().toExternalForm()+'/'+s;
		}
		emailBody += '</br></br>Gracias, </br>Equipo CRM';
		AP01_Case_AR.enviarEmail(emailBody, emailSubject, new List<String> {'crm-latam@pernod-ricard.com'});
	}
}