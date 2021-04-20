/*
* LAT_Payments
* Author: Martin Prado (martin@zimmic.com)
* Date: 08/15/2016
*/ 
trigger LAT_Payments on LAT_Payment__c (before insert, before update, after insert, after update) {
	System.debug('LAT_Payments [] ->');

	public final Set<String> EVENT_DEVELOPER_NAMES = new Set<String>{'LAT_Eventos_Contrato_de_Parceria'};

	if (Trigger.isBefore) {
		System.debug('LAT_Payments [before]');
		Set<Id> contractsIds = new Set<Id>();
		List<LAT_Payment__c> paymentsRecalculateCost = new List<LAT_Payment__c>();
		Set<String> fys = new Set<String>();
		Set<String> clientsOnPromise = new Set<String>();

		// Set the manager and regional manager to use on the approval process
		Set<Id> userIds = new Set<Id>();
		for ( LAT_Payment__c payment : trigger.new ) {
			System.debug('LAT_Payments [iteration PaymentId' + payment.Id + ']');
			System.debug('LAT_Payments [iteration ' + payment.Id + ' - Contract : ' + payment.LAT_Contract__c + ']');
			System.debug('LAT_Payments [iteration ' + payment.Id + ' - Contract owner : ' + payment.LAT_Contract__r.OwnerId + ']');

			contractsIds.add(payment.LAT_Contract__c);
			fys.add(LAT_FiscalYearHelper.getInstance().getFiscalYearCode(payment.PaymentDate__c));

			if (Trigger.isInsert || payment.PaymentDate__c != trigger.oldMap.get(payment.id).PaymentDate__c || payment.ProductGroup__c != trigger.oldMap.get(payment.id).ProductGroup__c) {
				System.debug('LAT_Payments [iteration ' + payment.Id + ' - insert o modificacion de fecha o modificacion de grupo de productos]');
				if (payment.ProductGroup__c != null) {
					System.debug('LAT_Payments [iteration ' + payment.Id + ' - payment.ProductGroup__c : ' + payment.ProductGroup__c + ']');
					paymentsRecalculateCost.add(payment);
				}

				System.debug('LAT_Payments [iteration ' + payment.Id + ' - payment : ' + payment + ']');
			}
		}

		System.debug('LAT_Payments [paymentsRecalculateCost : ' + paymentsRecalculateCost + ']');
		if (paymentsRecalculateCost.size() > 0) {
			System.debug('LAT_Payments [recalculado pagamentos...]');

			LAT_ContractsCalculations cc = new LAT_ContractsCalculations();
			cc.setProductCostOnPayment(paymentsRecalculateCost);
		}

		Map <Id, LAT_Contract2__c> contractsInfo = new Map <Id, LAT_Contract2__c>([SELECT Id, RecordType.Developername, Account__r.LAT_BR_RegionalClientOnPremise__c, OwnerId FROM LAT_Contract2__c WHERE id IN:contractsIds]);
		System.debug('LAT_Payments [contractsInfo : ' + contractsInfo + ']');
		Set<Id> setContractOwner = new Set<Id>();

		for (Id conId : contractsInfo.keySet()) {
			System.debug('LAT_Payments [iteration ' + conId + ']');

			userIds.add(contractsInfo.get(conId).OwnerId);	
			String clientOP = contractsInfo.get(conId).Account__r.LAT_BR_RegionalClientOnPremise__c;
			if (clientOP != null) {
				System.debug('LAT_Payments [iteration ' + conId + ' - clientOP : ' + clientOP + ']');
				clientsOnPromise.add(clientOP);
			}

			setContractOwner.add(contractsInfo.get(conId).OwnerId);
		}

		System.debug('LAT_Payments [clientsOnPromise : ' + clientsOnPromise + ']');
		System.debug('LAT_Payments [fys : ' + fys + ']');

		List<LAT_ContractWorflow__c> workflows = [	SELECT FY__c,RegionalClientOnPremise__c,WF__c,WorkflowNumber__c, Id 
													FROM LAT_ContractWorflow__c 
													WHERE FY__c IN:fys 
													OR RegionalClientOnPremise__c in: clientsOnPromise ];

		List<LAT_ContractAcuerdo__c> actividadesIMM = [	SELECT FY__c, Id 
														FROM LAT_ContractAcuerdo__c 
														WHERE FY__c IN:fys 
														AND User__c in: setContractOwner ];

		System.debug('LAT_Payments [workflows : ' + workflows + ']');

		for (LAT_Payment__c payment : trigger.new) {
			String fy = payment.FY__c;
			System.debug('LAT_Payments [iteration ' + payment.id + ']');
			System.debug('LAT_Payments [iteration ' + payment.id + ' - contractsInfo : ' + contractsInfo + ']');
			System.debug('LAT_Payments [iteration ' + payment.id + ' - payment.LAT_Contract__c : ' + payment.LAT_Contract__c + ']');
			System.debug('LAT_Payments [iteration ' + payment.id + ' - contractsInfo.get(payment.LAT_Contract__c).Account__r : ' + contractsInfo.get(payment.LAT_Contract__c).Account__r + ']');

			String clientOP = contractsInfo.get(payment.LAT_Contract__c).Account__r.LAT_BR_RegionalClientOnPremise__c;
			
			System.debug('LAT_Payments [iteration ' + payment.id + ' - clientOP : ' + clientOP + ']');
			payment.WorkflowME__c = null;
			for (LAT_ContractWorflow__c wf : workflows) {
				if (fy == wf.FY__c && clientOP == wf.RegionalClientOnPremise__c ) {
					System.debug('LAT_Payments [iteration ' + payment.id + ' - Actividad IMM found : ' + wf + ']');
					payment.WorkflowME__c = wf.Id;
				}
			}

			if(payment.WorkflowME__c == null) {
				System.debug('LAT_Payments [iteration ' + payment.id + ' - fy : ' + fy + ' - clientOP : ' + clientOP + ' - Activodad IMM NOT Found]');
			}

			for(LAT_ContractAcuerdo__c objContractIMM : actividadesIMM) {
				if (fy == objContractIMM.FY__c ) {
					System.debug('LAT_Payments [iteration ' + payment.id + ' - Acordo IMM found : ' + objContractIMM + ']');
					payment.Acordo_IMM__c = objContractIMM.Id;
				}
			}
		}
		
		Map<Id, User> idUserMap =  new Map<Id,User>([SELECT Gerente_de_area__c,Gerente_regional__c,ManagerId FROM User where Id in: userIds]);

		System.debug('LAT_Payments [idUserMap : ' + idUserMap + ']');

		//MRLLANOS: REFACTORIZAR PARA NO RECORRER POR TERCERA VEZ EL MISMO ARRAY
		for (LAT_Payment__c payment : trigger.new) {
			System.debug('LAT_Payments [iteration : ' + payment.id + ' - payment.LAT_Contract__c : ' + payment.LAT_Contract__c + ' ]');
			System.debug('LAT_Payments [iteration : ' + payment.id + ' - contractsInfo.get(payment.LAT_Contract__c) : ' + contractsInfo.get(payment.LAT_Contract__c) + ' ]');
			System.debug('LAT_Payments [iteration : ' + payment.id + ' - contractsInfo.get(payment.LAT_Contract__c).OwnerId : ' + contractsInfo.get(payment.LAT_Contract__c).OwnerId + ' ]');

			if (idUserMap.containsKey(contractsInfo.get(payment.LAT_Contract__c).OwnerId)){
				System.debug('LAT_Payments [iteration : ' + payment.id + ' - idUserMap has this key :' + contractsInfo.get(payment.LAT_Contract__c).OwnerId + ' ]');
 
				User owner = idUserMap.get(contractsInfo.get(payment.LAT_Contract__c).OwnerId);
				payment.Manager__c = owner.ManagerId;
				payment.RegionalManager__c = owner.Gerente_regional__c;

				System.debug('LAT_Payments [iteration : ' + payment.id + ' - payment manager/regional manager changed :' + contractsInfo.get(payment.LAT_Contract__c).OwnerId + ' ]');
			}
		
		}

		//MRLLANOS: REFACTORIZAR PARA NO RECORRER POR CUARTA VEZ EL MISMO ARRAY
		for(LAT_Payment__c p: trigger.new){
			if(contractsInfo.get(p.LAT_Contract__c) != null){
				if(EVENT_DEVELOPER_NAMES.contains(contractsInfo.get(p.LAT_Contract__c).RecordType.Developername) ){
					if(p.RecordTypeId == Global_RecordTypeCache.getRtId('LAT_Payment__c'+'LAT_PagamentoDinheiro') && p.Finality__c == 'Patrocínio'){
						p.LAT_Producer__c = true;
						System.debug('LAT_Payments [iteration : ' + p.id + ' is producer]');
					}
				}
			} else {
				System.debug('LAT_Payments [iteration : ' + p.id + ' - contract info not found]');
			}
		}
	} else if (Trigger.isAfter) {
		Set<Id> contractIds = new Set<Id>();
		Map<Id,LAT_Payment__c> latpaymentsnewmap= new Map<Id,LAT_Payment__c>(); 
		List<ID> paymentsparentIds=new List<Id>();
		
		System.debug('LAT_Payments [isAfter]');

		for (LAT_Payment__c payment : trigger.new) {
			contractIds.add(payment.LAT_Contract__c);

			System.debug('LAT_Payments [iteration : ' + payment.id + ' - ' + payment.ApprovedPayment__c + ']');
			System.debug('LAT_Payments [iteration : ' + payment.id + ' - ' + payment.ApprovedPayment__c + ']');

			// ME integration
			//si esta aprobado y el status es "en aprovacao"
			if (payment.Status__c != 'Erro Integração' ) {
				if (payment.IntegrationStatus__c != 'Integrado com Sucesso' && ( (payment.ApprovedPayment__c == true && payment.Status__c == 'Em Aprovação'  && payment.ParentPayment__c == null ) || (payment.ApprovedPayment__c == true && trigger.oldMap.get(payment.Id).ApprovedPayment__c != true  && payment.ParentPayment__c == null && (payment.ApprovedPayment__c == true && payment.Status__c == 'P' ||  payment.Status__c == 'Em Aprovação')) )) {
					System.debug('LAT_Payments [iteration : ' + payment.id + ' - send payment to integrate]');
					LAT_ContractPaymentsHandlerInterface.sendPaymentToME(payment.Id);
				} else {
					System.debug('LAT_Payments [iteration : ' + payment.id + ' - no integrarlo en Aquila]');
				}
			}

			if (trigger.isUpdate) {
				if ((payment.paymentGoals__c != trigger.oldMap.get(payment.Id).paymentGoals__c ) || (payment.GoalNotReached__c != trigger.oldMap.get(payment.Id).GoalNotReached__c ) || (payment.ReleaseReason__c != trigger.oldMap.get(payment.Id).ReleaseReason__c ) || (payment.Status__c != trigger.oldMap.get(payment.Id).Status__c )){
					paymentsparentIds.add(payment.id);				
					System.debug('LAT_Payments [iteration : ' + payment.id + ' - modified]');
				}
			}
		} 
		System.debug('LAT_Payments [paymentsparentIds : ' + paymentsparentIds + ']');

		if (paymentsparentIds.size() > 0) {
			List<LAT_Payment__c> payChilds = [SELECT id,paymentGoals__c, GoalNotReached__c, ReleaseReason__c, Status__c,ParentPayment__c 
											  FROM LAT_Payment__c 
											  WHERE ParentPayment__c in: paymentsparentIds];

			System.debug('LAT_Payments [child payments: ' + payChilds + ']');

			List<LAT_Payment__c> paymentsToUpdate = new List<LAT_Payment__c>();
			if (payChilds.size() > 0) {
				for (LAT_Payment__c paychild : payChilds) {
					paychild.paymentGoals__c =  trigger.newMap.get(paychild.ParentPayment__c).paymentGoals__c;
					paychild.GoalNotReached__c = trigger.newMap.get(paychild.ParentPayment__c).GoalNotReached__c;
					paychild.ReleaseReason__c = trigger.newMap.get(paychild.ParentPayment__c).ReleaseReason__c;
					paychild.Status__c = trigger.newMap.get(paychild.ParentPayment__c).Status__c;
					paymentsToUpdate.add(paychild);

					System.debug('LAT_Payments [iteration : ' + paychild.id + ' - updating child payment]');
				} 
				if (paymentsToUpdate.size() > 0) {
					System.debug('LAT_Payments [updating payments]');

					update paymentsToUpdate;
				}
			}
		}
   
		// Create all the calculation based on the payments
		LAT_ContractsCalculations cc = new LAT_ContractsCalculations();
		System.debug('LAT_Payments [caculate payments information... : ' + contractIds + ']');
		cc.calculatePaymentsInformation(contractIds);  
	}  
}