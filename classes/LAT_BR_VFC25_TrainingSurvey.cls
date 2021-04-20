public with sharing class LAT_BR_VFC25_TrainingSurvey {
	public List<Questions> questions {get; set;}
	public List<SelectOption> posibleAnswers {set;}
	public Visitas__c vis {get; set;}
	private Boolean noVisita {get; set;}

	public LAT_BR_VFC25_TrainingSurvey() {
		
		String visitId = ApexPages.currentPage().getParameters().get('visita');
		List <Visitas__c> lstVisitas = [SELECT Id, Conta__c, Status__c FROM Visitas__c WHERE Id = :visitId LIMIT 1];
		if (!lstVisitas.isEmpty()) {
			this.vis =  lstVisitas[0];
			noVisita = false;
		}	else {
			ApexPages.Message errorMsg4 = new ApexPages.Message(ApexPages.severity.ERROR, 'No se encontró la visita, por favor vaya a la visita y selecione "Cerrar Visita" para poder realizar la encuesta.'); 
			ApexPages.addMessage(errorMsg4);
			noVisita = true;
			return;
		}
		questions = new List<Questions>();
		List <LAT_BR_TrainingSurveyQuestions__c> customSettingList = [SELECT Id, Name, LAT_BR_TSQ_Type__c, LAT_BR_TSQ_Question__c, LAT_BR_TSQ_Order__c, LAT_BR_TSQ_Months_Ago__c
																 FROM LAT_BR_TrainingSurveyQuestions__c ORDER BY LAT_BR_TSQ_Order__c]; 
		Integer i = 1;
		for (LAT_BR_TrainingSurveyQuestions__c csq : customSettingList) {
			Integer customSetMonthsAgo = Integer.valueOf(csq.LAT_BR_TSQ_Months_Ago__c);
			if (customSetMonthsAgo < 0 || customSetMonthsAgo == null) {
				customSetMonthsAgo = 6; // Sets default time of last done survey older than 6 months.
			} 
			Date nMonthsAgo =  Date.Today().addMonths(-customSetMonthsAgo);			
			List <LAT_BR_Training_Survey__c> surveisList = [SELECT Id, LAT_BR_TS_TrainingType__c, LAT_BR_TS_Data__c , LAT_BR_TS_Client__c
														FROM LAT_BR_Training_Survey__c WHERE LAT_BR_TS_Client__c = :vis.Conta__c 
														AND (NOT LAT_BR_TS_TrainingType__c LIKE 'OTHER%') AND LAT_BR_TS_TrainingType__c LIKE :csq.LAT_BR_TSQ_Type__c AND LAT_BR_TS_Answer__c = true 
														AND LAT_BR_TS_Data__c > :nMonthsAgo];			
			if (surveisList.isEmpty()) {
				String strQuestion = '' + i + ' ) ' + csq.LAT_BR_TSQ_Question__c;
				questions.add( new Questions(strQuestion, csq.LAT_BR_TSQ_Type__c));
				i++;
			}	
			
		}								 
		
	}

	public List<SelectOption> getposibleAnswers() {
		List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption('SIM','SIM'));
		options.add(new SelectOption('NÃO', 'NÃO'));
		return options;
	}
	
	public PageReference save() {
		if (!noVisita) {	
			Boolean isOk = true;
			ApexPages.Message errorMsg = null;
			List <LAT_BR_Training_Survey__c> surveisToInsert = new List<LAT_BR_Training_Survey__c>();
			for (Questions q : questions) {
				if (q.Answer == 'SIM' || q.Answer == 'NÃO') {
					if (q.Answer == 'NÃO' || (q.Answer == 'SIM' && q.data != null)) {
						if (q.Type != 'OTHER' || (q.Type == 'OTHER' && (q.Answer == 'NÃO' || (q.OtherText != '' && q.OtherText != null)))) {
						
								LAT_BR_Training_Survey__c survey = new LAT_BR_Training_Survey__c(); 
								survey.LAT_BR_TS_Client__c = this.vis.Conta__c;
								survey.LAT_BR_TS_Visita__c = this.vis.Id;
								survey.LAT_BR_TS_Data__c = q.data;
								survey.LAT_BR_TS_TrainingType__c = q.Type;
								survey.LAT_BR_TS_Answer__c = (q.Answer == 'SIM');
								survey.LAT_BR_TS_Other__c = q.OtherText;
								survey.LAT_BR_TS_Question__c = q.Name;
								surveisToInsert.add(survey);
							} else {
									errorMsg = new ApexPages.Message(ApexPages.severity.ERROR, Label.LAT_BR_VFC25_TrainingSurvey_ErrorMsg_04); // messagge : 'Debe especificar el tipo de entrenamiento para ingresar el entrenamiento'
	       			    ApexPages.addMessage(errorMsg);
		      			  isOk = false;
							}
						 
					} else {
						errorMsg = new ApexPages.Message(ApexPages.severity.ERROR, Label.LAT_BR_VFC25_TrainingSurvey_ErrorMsg_01); 
     				ApexPages.addMessage(errorMsg);
     				if ((q.OtherText == '' || q.OtherText == null) && q.Type == 'OTHER' && q.Answer == 'SIM') {
     					errorMsg = new ApexPages.Message(ApexPages.severity.ERROR, Label.LAT_BR_VFC25_TrainingSurvey_ErrorMsg_04); 
     					ApexPages.addMessage(errorMsg);
     				}
     			  isOk = false;
						
					}
				} else {
						errorMsg = new ApexPages.Message(ApexPages.severity.ERROR, Label.LAT_BR_VFC25_TrainingSurvey_ErrorMsg_03); // message : 'Debe responder todas las preguntas para poder cerrar la visita.'
		        ApexPages.addMessage(errorMsg);
		        isOk = false;
					}	
			}
			if (!surveisToInsert.isEmpty() && isOk) {	

		    if (vis.Status__c == 'Encerrada') { 
					errorMsg = new ApexPages.Message(ApexPages.severity.ERROR, Label.VF_VTS_00042_AR); // message : No se puede cerrar, la visita ya esta cerrada!
		    	ApexPages.addMessage(errorMsg);
				} else { 
					vis.Status__c = 'Encerrada';
					try {
						vis.LAT_isTrigger__c = true;
						update vis;
						errorMsg = new ApexPages.Message(ApexPages.severity.CONFIRM, Label.LAT_BR_VFC25_TrainingSurvey_ConfirmMsg_01); // message : 'Se ha cerrado la visita con exito.'
				    ApexPages.addMessage(errorMsg);	
				    insert surveisToInsert;
				    return new pageReference('/' + vis.id);
			  	} catch (DmlException  e) {
			  		String excError = e.getMessage();
			  		ApexPages.Message errorMsg2 = new ApexPages.Message(ApexPages.severity.ERROR, Label.LAT_BR_VFC25_TrainingSurvey_ErrorMsg_02);  // message : 'Para volver a la visita selecione "Cancelar".'
		    		ApexPages.addMessage(errorMsg2);
			  	}
			  }  	
			}
			if (!isOk) {
				surveisToInsert.clear();
			}
			
		} else {
			ApexPages.Message errorMsg4 = new ApexPages.Message(ApexPages.severity.ERROR, Label.LAT_BR_VFC25_TrainingSurvey_ErrorMsg_05); // message : No se encontró la visita, por favor vaya a la visita y selecione "Cerrar Visita" para poder realizar la encuesta.
			ApexPages.addMessage(errorMsg4);
		}
			
		return null;
	}

	public PageReference cancel() {
		if (!noVisita) {
			return new pageReference('/' + vis.id);
		} else {
			return new pageReference('/a51');
		}
	}

	//Inner class for Sales Prevission section
	public class Questions {
		public String Name {get; Set;}
		public String Answer {get; Set;}
		public Date data {get; Set;}
		public String OtherText {get; Set;}
		public String Type {get; Set;}
		public Boolean isRendered {get; Set;}
		
		public Questions (String Name, String Type){
			this.Name = Name;
			this.Type = Type;
			this.Answer = 'NÃO';
			this.isRendered = true;
		}
	}
}