/*****************************************************************************************************
*                           			Company: ValueNet
*-----------------------------------------------------------------------------------------------------
*   Clase que funciona con el boton "Novo gabarito de execução" en el objeto Gabarito_de_Execucao__c
******************************************************************************************************/

global with sharing class LAT_BR_BTN01_VerifyNewGabDeExe {
	
	webService static String validationOfNewGab(String idOfCheckList){
		
		//Validamos que el parametro idOfCheckList exista como registro
		Checklist_de_visita__c checklist;
		try{checklist  = [SELECT Id, Name, Visita__r.Conta__c, RecordType.DeveloperName, Visita__r.Planejamento__r.LAT_MonthYear__c, (SELECT Id FROM Gabaritos_de_Execucao__r) FROM Checklist_de_visita__c WHERE Id =: idOfCheckList];}catch(Exception e){}
		if(checklist == null){
			return 'Checklist error: ' + Label.LAT_BR_BTN01_00002;
			//Label.LAT_BR_BTN01_00002 = There is no cdv registry found for that ID. Please return to the cdv and try again. If the problem persist please contact your System Administrator.
		}
		
		if(!checklist.Gabaritos_de_Execucao__r.IsEmpty()){
        	return 'Checklist error: ' + Label.LAT_BR_BTN01_00003;
        	//Label.LAT_BR_BTN01_00003 = Não é possível a criação de mais de um Gabarito de Execução no mesmo CheckList de Visita. Se deseja alterar o Gabarito, clique em Editar
        }
		
        List<Checklist_de_visita__c> checkValid = [SELECT Id, Name, LAT_BR_ValidOnTradeChecklistGE__c FROM Checklist_de_visita__c WHERE LAT_BR_ValidOnTradeChecklistGE__c = true AND Visita__r.Conta__c =: checklist.Visita__r.Conta__c AND Visita__r.Planejamento__r.LAT_MonthYear__c =: checklist.Visita__r.Planejamento__r.LAT_MonthYear__c LIMIT 1];
        if(!checkValid.isEmpty()){
        	return 'Error: ' + Label.LAT_BR_BTN01_00001 + checkValid[0].Name + '?';
        	//Label.LAT_BR_BTN01_00001 = There is already a Gabarito Of Execution registered for that month and is marked as valid. Are you sure you want to Ignore Gabarito of Execution Template number #
        }
        
        return reDirectToNewGab(checklist);
	}
	
	webService static String confirmationOfNewGab(String idOfCheckList){
		Checklist_de_visita__c checklist = [SELECT Id, Name, RecordType.DeveloperName FROM Checklist_de_visita__c WHERE Id =: idOfCheckList];
		return reDirectToNewGab(checklist);
	}
	
	public static string reDirectToNewGab(Checklist_de_visita__c cdv){
		
		String idCampo = [SELECT Id, FieldId__c FROM CS002_FIeldsIds__c WHERE FieldApiName__c='Checklist_de_Visita__c' AND ObjectApiName__c='Gabarito_de_Execucao__c'].FieldId__c;
        String gabRtId = '';
        if (cdv.RecordType.DeveloperName.contains('On_Trade')) {
        	gabRtId = Global_RecordTypeCache.getRtId('Gabarito_de_Execucao__c' + 'LAT_BR_GDE_On_Trade');
        } else {
			gabRtId = Global_RecordTypeCache.getRtId('Gabarito_de_Execucao__c' + 'BRA_Standard');	
        }
        String prefixObj = Gabarito_de_Execucao__c.SObjectType.getDescribe().getKeyPrefix();
        
        String urlReturn = prefixObj + '/e?';
        urlReturn += '&RecordType=' + gabRtId;
        urlReturn += '&' + idCampo + '=' + EncodingUtil.urlEncode(cdv.Name,'UTF-8');
        urlReturn += '&' + idCampo + '_lkid=' + cdv.id;
        urlReturn += '&retURL=%2F' + cdv.id;
        
        return urlReturn;
	}
}