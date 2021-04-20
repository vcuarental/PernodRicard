trigger LAT_VisitaTrigger on Visitas__c (after insert, after update, after delete) {

	LAT_Trigger trigger_LAT = new LAT_Trigger('Visitas__c', new set<String>{'BRA_Standard'});

	if(trigger.isInsert || trigger.isUpdate){
		LAT_BR_AP01_Planejamento.updatePlanejamentoStatus(trigger_LAT.getNew());
	}else if (trigger.isDelete){
		LAT_BR_AP01_Planejamento.updatePlanejamentoStatus(trigger_LAT.getOld());
	}

}