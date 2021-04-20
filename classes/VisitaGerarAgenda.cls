/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
*-------------------------------------------------------------------------------
* 
* 
* NAME: VisitaGerarAgenda.cls
* AUTHOR:                                           DATE: 
*
*
* MAINTENANCE
* AUTHOR: CARLOS CARVALHO                           DATE: 17/01/2013
* DESC: INSERIDO FUNCIONALIDADE QUE VALIDA O ID DO TIPO DE REGISTRO DOS OBJETOS.
*******************************************************************************/
global class VisitaGerarAgenda {
    Webservice static void processaBotao(Id idPlanej) {
    	
        Id idRecTypePlan = RecordTypeForTest.getRecType( 'Planejamento__c' , 'BRA_Standard' );
        Id idRecTypeVis = RecordTypeForTest.getRecType( 'Visitas__c' , 'BRA_Standard' );
        Id idRecTypeComp = RecordTypeForTest.getRecType( 'Event' , 'Planejamentovisitas' );
        
		Planejamento__c planej = [Select Id, OwnerId from planejamento__c 
		  where Id = : idPlanej and RecordTypeId =: idRecTypePlan limit 1];
		  
		List<Visitas__c> visitas = [ SELECT Id, Name, Conta__c, Data_da_Visita__c,Hora_da_Visita__c, 
		                                    Planejamento__c, Resumo_da_Visita__c 
		                                    FROM Visitas__c WHERE Planejamento__c = :idPlanej
		                                    AND RecordTypeId =: idRecTypeVis]; 
		for (Visitas__c v: visitas ){
			//Procura os compromissos dessa visita
			List<Event> compromissos = [ SELECT AccountId, ActivityDateTime, Subject, WhatId 
                FROM Event WHERE WhatId =: v.Id AND RecordTypeId =: idRecTypeComp limit 1];
			// Se tem compromissos, Atualiza a data e hora
			Integer i = 0;
			for(Event c:compromissos) {
				i++;
				c.WhatId = v.Id;
				c.Subject = 'Visita a cliente (' + [Select Name from Account where Id = :v.Conta__c limit 1].Name +')'; 
				c.ActivityDateTime = datetime.valueof(string.valueof(v.Data_da_Visita__c) + ' ' + v.Hora_da_Visita__c + ':00');
				update c;
			}
			if (i == 0){
				// Se não tem compromisso, cria um para esta visita
  				Event compromisso = new Event();
  				//compromisso.AccountId = v.Conta__c;
  				
  				compromisso.WhatId = v.Id;
  				compromisso.Type = 'Visit';
  				compromisso.Subject = 'Visita a cliente (' + [Select Name from Account where Id = :v.Conta__c limit 1].Name +')'; 
  				if ( v.Data_da_Visita__c != null ) compromisso.ActivityDatetime = datetime.valueof(string.valueof(v.Data_da_Visita__c) + ' ' + v.Hora_da_Visita__c+ ':00');
  				else compromisso.ActivityDatetime = system.now();
  				compromisso.DurationInMinutes = 60;
  				insert compromisso;
			}
				
    	}
    
    }
}