/********************************************************************************
* Methods for update during approval process
*
* NAME: LAT_BR_AP01_AnaliseDeCredito.cls
* AUTHOR: Mariano Boezio                         
********************************************************************************/
public with sharing class LAT_BR_AP01_AnaliseDeCredito {
	
	public static void setManagers(List<Analise_de_Credito__c> TriggerNew) {
		List<String> AccountIds = new List<String>();
		for (Analise_de_Credito__c adc: TriggerNew) {
			AccountIds.add(adc.Conta__c);
		}

		Map<id, Account> accList = new Map<id, Account>([SELECT id, Area_Manager__c, Regional_Manager__c 
																FROM Account WHERE id IN: AccountIds]);
		for (Analise_de_Credito__c adc: TriggerNew) {
			adc.LAT_BR_Regional_Manager__c = accList.get(adc.Conta__c).Regional_Manager__c;
			adc.Area_Manager__c = accList.get(adc.Conta__c).Area_Manager__c;
		}
	}

	public static void updateSubmiter(List<Analise_de_Credito__c> TriggerNew) {
		
		for (Analise_de_Credito__c adc: TriggerNew) {
			if (adc.Initial_Submiter__c != null) {
				adc.LAT_BR_Initial_Approval_Submiter__c = adc.Initial_Submiter__c;
			} else {
				adc.LAT_BR_Initial_Approval_Submiter__c = null;
			}
		}
	}

	public static void checkForCC(Map<id, Analise_de_Credito__c> TriggerNew, List<Analise_de_Credito__c> TriggerOld) {
		
		for (Analise_de_Credito__c adc: TriggerOld) {
			if (adc.LAT_BR_CurrentStep__c == 'C&C' && adc.LAT_BR_Status__c == 'Em aprovação'
				&& TriggerNew.get(adc.id).Sugestao_do_analista__c == null && TriggerNew.get(adc.id).LAT_BR_Status__c != 'Reprovado') {
				TriggerNew.get(adc.id).AddError('Campo SUGESTÃO DO ANALISTA não está preenchido na Análise de Crédito. Favor revisar.');
			}
		}
	}

	public static void lunchCCApproval(List<Analise_de_Credito__c> TriggerNew) {
		List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest> ();

		for (Analise_de_Credito__c adc: TriggerNew) {
			if (adc.LAT_BR_CurrentStep__c == 'C&C' && adc.LAT_BR_Status__c == 'Em aprovação') {
				Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
			    req.setObjectId(adc.Id);
			    requests.add(req);
			}
		}

		try{
	    	Approval.ProcessResult[] proc = Approval.process(requests, true);
	    } catch (Exception e) { 
	    	LAT_DebugUtil debugUtil = new LAT_DebugUtil();
			debugUtil.setOrigin('LAT_BR_AP01_AnaliseDeCredito.lunchCCApproval.EXCEPTION');
			debugUtil.addTitle('lunchCCApproval');
			debugUtil.addException(e);
			debugUtil.insertDebug();
			//update triggerNew;
	    }
	}

	public static void integrateWithJDE(List<Analise_de_Credito__c> TriggerNew, Map<id, Analise_de_Credito__c> TriggerOld) {
		List<String> AccountIds = new List<String>();
		for (Analise_de_Credito__c adc: TriggerNew) {
			AccountIds.add(adc.Conta__c);
		}

		Map<id, Account> accList = new Map<id, Account>([SELECT id, Status__c, Credit_Line__c
																FROM Account WHERE id IN: AccountIds]);

		List<Account> toUpdate = new List<Account>();
		for (Analise_de_Credito__c adc: TriggerNew) {
			if (TriggerOld.get(adc.id).LAT_BR_Status__c == 'Em aprovação'
				&& adc.LAT_BR_Status__c == 'Ativo'
				&& adc.Sugestao_do_analista__c != null) {
				accList.get(adc.Conta__c).Status__c = 'Aprovado - Aguardando retorno do JDE';
				accList.get(adc.Conta__c).Credit_Line__c = adc.Sugestao_do_analista__c;
				toUpdate.add(accList.get(adc.Conta__c));
			}
		}

		update toUpdate;
	}

	public static void checkAccountIsNotNovo(List<Analise_de_Credito__c> TriggerNew) {
		List<String> AccountIds = new List<String>();
		for (Analise_de_Credito__c adc: TriggerNew) {
			AccountIds.add(adc.Conta__c);
		}

		Map<id, Account> accList = new Map<id, Account>([SELECT id, Status__c
																FROM Account WHERE id IN: AccountIds]);

		for (Analise_de_Credito__c adc: TriggerNew) {
			if (adc.LAT_BR_Status__c == 'Em aprovação'
				&& (accList.get(adc.Conta__c).Status__c == 'Novo cadastro'
					|| accList.get(adc.Conta__c).Status__c == 'Não aprovado')) {
				adc.AddError('Não é permitido o Envio a Aprovação de uma Análise de Crédito de um cliente novo. Favor enviar o cliente a aprovação.');
			}
		}

	}

	public static void inactivateAC(List<Analise_de_Credito__c> TriggerNew) {
		List<Analise_de_Credito__c> AcAtivos = new List<Analise_de_Credito__c>();
		List<String> Contas = new List<String>();

		for (Analise_de_Credito__c ac: TriggerNew) {
			if (ac.LAT_BR_Status__c == 'Ativo') {
				AcAtivos.add(ac);
				Contas.add(ac.Conta__c);
			}
		}

		if (!AcAtivos.isEmpty()) {  
			List<Analise_de_credito__c> toUpdateStatus = [SELECT id, LAT_BR_Status__c 
	                                                                FROM Analise_de_credito__c 
	                                                                WHERE Conta__c IN: Contas AND (NOT id IN: AcAtivos)];
	        for (Analise_de_credito__c adc : toUpdateStatus) {
	            adc.LAT_BR_Status__c = 'Inativo';
	        }

	        update toUpdateStatus;
	    }
	}
}