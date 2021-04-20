global class LAT_BR_BTN01_CloseVisitValidations {

	webservice static String serviceName(String id){
		String retorno = '';
		if (id != null) {
			Visitas__c vis = [SELECT Id, Name, LAT_BR_PRB__c, LAT_BR_Client__c, Resumo_da_Visita__c, LAT_MX_GoalAchieved__c,   
						LAT_BR_CommentsAboutVisitGoal__c FROM Visitas__c WHERE Id = :id];
			if (vis != null) {
				//if (vis.Resumo_da_Visita__c == null || vis.Resumo_da_Visita__c == '') {
				if (vis.LAT_BR_PRB__c == null || vis.LAT_BR_PRB__c == '' 
					|| vis.LAT_BR_Client__c == null || vis.LAT_BR_Client__c == '') {
					retorno += ' - ' + Label.LAT_BR_BTN01_Error_Msg_1 + '\n\n';
				}
				if (vis.LAT_MX_GoalAchieved__c == null || vis.LAT_MX_GoalAchieved__c == '') {
					retorno += ' - ' + Label.LAT_BR_BTN01_Error_Msg_2  + '\n\n';
				}
				if (vis.LAT_BR_CommentsAboutVisitGoal__c == null || vis.LAT_BR_CommentsAboutVisitGoal__c == '') {
					retorno += ' - ' + Label.LAT_BR_BTN01_Error_Msg_3+ '\n\n';
				}
			} else {
				retorno = Label.LAT_BR_BTN01_Error_Msg_4;
			} 			
		} else {
			retorno = Label.LAT_BR_BTN01_Error_Msg_4;
		}
		
		return retorno;
	}
}