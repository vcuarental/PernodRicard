trigger LAT_MasiveCreditLineLine on LAT_MasiveCreditLineLine__c (before insert, after update) {
	
	Map<String,LAT_MasiveCreditLineHeader__c> headers = new Map<String,LAT_MasiveCreditLineHeader__c>();
		Map<String,Account> accounts = new Map<String,Account>();

	List<String> lineIds = new List<String>();
	List<String> accountIds = new List<String>();


	for(LAT_MasiveCreditLineLine__c line: trigger.new){
		lineIds.add(line.LAT_Header__c);
		accountIds.add(line.LAT_Account__c);
	}

	for(LAT_MasiveCreditLineHeader__c he : [Select id,LAT_Status__c from  LAT_MasiveCreditLineHeader__c where id in: lineIds]){
		headers.put(he.id, he);
	}

	for(Account acc : [Select id,client_country_an8__c,Credit_line__c from Account where id in : accountIds]){
		accounts.put(acc.id, acc);
	
	}

	if(trigger.isBefore){
		if(trigger.isInsert){ 
			for(integer i =0; i < trigger.new.size(); i++){
				LAT_MasiveCreditLineLine__c line = trigger.new[i];
				if(headers.get(line.LAT_Header__c) != null && headers.get(line.LAT_Header__c).lat_status__c != 'Nuevo' ){
						line.addError('No se puede añadir una linea en una carga en ejecución');

				}else{
					Account acc = accounts.get(line.LAT_Account__c);
					line.LAT_AccountAN8__c = acc.client_country_an8__c;
        			line.LAT_OldValue__c = acc.Credit_line__c;
				}
			}
		}
	}

	if(trigger.isAfter){
		if(trigger.isUpdate){ 
			for(integer i =0; i < trigger.new.size(); i++){
				LAT_MasiveCreditLineLine__c line = trigger.new[i];
				if(headers.get(line.LAT_Header__c) != null && headers.get(line.LAT_Header__c).lat_status__c != 'Nuevo' && line.LAT_New_Value__c != trigger.old[i].LAT_New_Value__c){
					line.addError('No se puede modificar una linea en una carga en ejecución');
				}
			}
		}	
	}

}