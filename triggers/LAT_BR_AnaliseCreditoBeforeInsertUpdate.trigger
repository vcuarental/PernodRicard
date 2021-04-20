trigger LAT_BR_AnaliseCreditoBeforeInsertUpdate on Analise_de_credito__c (before insert, before update) {
	LAT_BR_AP01_AnaliseDeCredito.setManagers(trigger.new);
	LAT_BR_AP01_AnaliseDeCredito.inactivateAC(trigger.new);
	if (trigger.isUpdate) {
		LAT_BR_AP01_AnaliseDeCredito.updateSubmiter(trigger.new);
		LAT_BR_AP01_AnaliseDeCredito.checkForCC(trigger.newMap, trigger.old);
		LAT_BR_AP01_AnaliseDeCredito.lunchCCApproval(trigger.new);
		LAT_BR_AP01_AnaliseDeCredito.integrateWithJDE(trigger.new, trigger.oldMap);
		LAT_BR_AP01_AnaliseDeCredito.checkAccountIsNotNovo(trigger.new);
	}
}