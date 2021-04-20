global class LAT_BR_Planejamento_Batch implements Database.Batchable<sObject> {
	
	String query;

	
	global LAT_BR_Planejamento_Batch() {
		
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
        List<String> integrationUsers = LAT_GeneralConfigDao.getValueAsStringArray('INTEGRATION_USERS',',');
        if(integrationUsers == null){
            integrationUsers = new List<String>();
        }
//TODO : cambiar el filtro de la query por los nuevos RT correlativos a esos dos.
// Account Status <> novo cadastro

        List<AggregateResult> owners = [SELECT owner.id FROM Account where Recordtype.DeveloperName IN :AP01_Account_BR.BR_RECORDTYPES 
        								AND  Rating <> 'Cliente inativo'  AND Status__c != 'Não aprovado' AND Status__c != 'Novo cadastro'
        								AND Owner.Name NOT IN: integrationUsers GROUP BY Owner.id];
        query = 'SELECT Id FROM User where id in (\'\'' ;
        
        for(AggregateResult ar : owners){
        	query += ',\'' + ar.get('id') + '\'';
        }
        query += ')';


		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
   		LAT_BR_AP01_Planejamento.generateMonthlyPlans(scope);
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}