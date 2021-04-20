/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
*-------------------------------------------------------------------------------
*
* Classifica o cliente como cliente atendido, se houver visita encerrada e
* o cliente não estiver com contrato
* NAME: Visita_ClassificarCliente.trigger
* AUTHOR: ROGERIO ALVARENGA                         DATE: 26/06/2012
*
*
* MAINTENANCE: INSERIDO FUNCIONALIDADE QUE VALIDA O ID DO TIPO DE REGISTRO DOS 
* OBJETOS.
* AUTHOR: CARLOS CARVALHO                           DATE: 09/01/2013
*******************************************************************************/

trigger Visita_ClassificarCliente on Visitas__c (after insert, after update) {

	//Check if this trigger is bypassed by SESAME (data migration Brazil)
	if((UserInfo.getProfileId()!='00eM0000000QNYPIA4') && (UserInfo.getProfileId()!= '00eD0000001AnFlIAK')) {
		//Declaração de variáveis
		List<String> lListAccId = new List<String>();
		Id idRecTypeVis = RecordTypeForTest.getRecType('Visitas__c', 'BRA_Standard');
		Set<Id> setRecTypeAcc = new Set<Id>();
		
		//Recupera ids dos tipos de registro
		setRecTypeAcc.add(RecordTypeForTest.getRecType('Account', 'Eventos'));
		setRecTypeAcc.add(RecordTypeForTest.getRecType('Account', 'Off_Trade'));
		setRecTypeAcc.add(RecordTypeForTest.getRecType('Account', 'On_Trade'));
		
		for(Visitas__c lVis : trigger.new){
			if(lVis.RecordTypeId == idRecTypeVis && lVis.Status__c == 'Encerrada' ){
				lListAccId.add(lVis.Conta__c);
			}
		}
		
		if(lListAccId.size() > 0){
			List<Account> lListAccUpdated = new List<Account>();
			List<Account> lListAcc = [SELECT id, Rating FROM account WHERE id =: lListAccId AND Channel__c = 'On Trade' AND RecordTypeId =: setRecTypeAcc];
			
			Map<String, Account> lMapAcc = new Map< String, Account>();
			for (Account lAcc : lListAcc){
				lMapAcc.put(lAcc.id, lAcc);
			}
			
			for(Visitas__c lVis : trigger.new){
				if(lVis.RecordTypeId == idRecTypeVis && lVis.Status__c != 'Encerrada'){
					continue;
				}
				Account lAcc = lMapAcc.get(lVis.Conta__c);
				if (lAcc != null && lAcc.Rating != 'Cliente com contrato'){
					lAcc.Rating = 'Cliente atendido';
					//lListAccUpdated.add(lAcc);
				}
			}
			
			if(lListAccUpdated.size() > 0){
				//update lListAccUpdated;
				String error;
				
		        List<DataBase.saveResult> results = DataBase.update(lListAccUpdated, false);
		        for(DataBase.saveResult result: results){
		            if(!result.isSuccess()){
		                for(Database.Error er: result.getErrors()){
		                	error = er.getMessage();
		                }
		            }
		        }
		        if(error != null){
		        	for(Visitas__c lVis : trigger.new){
		        		lVis.addError('Ocorreu um erro ao tentar atualizar um Cliente: '+error);
		        	}
		        }
			}
		}
	}
}