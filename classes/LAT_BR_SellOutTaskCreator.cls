public with sharing class LAT_BR_SellOutTaskCreator {
	public LAT_BR_SellOutTaskCreator() {

	}
	public static void createTask(Date vence){
		// Obtengo mapa de meses para traduccion
		Map<Integer, String> monthMap = LAT_BR_SellOutTaskCreator.getMonthMap();

		// BUSCAR TODOS LOS OWNERS DE ACCOUNTSREFERENCES-ACCOUNT (Sin duplicados)
		// https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/langCon_apex_SOQL_agg_fns.htm?search_text=aggregateresult
		
		//AggregateResult[] ownersIds = [SELECT Account__r.ownerid accOwner
		//	FROM LAT_ReferenceAccount__c 
		//	where isActive__c = true 
		//	group by Account__r.ownerid];

		// Calculo las fechas
		Date lastDay = vence;//Date.today().toStartOfMonth().addMonths(1).addDays(-1);
		Datetime alertOn = Datetime.newInstance(vence.addDays(-1), Time.newInstance(9, 0, 0, 0));
		
		String Description = 'Prezado(a),\n\n' + 
							 'Segue abaixo a relação de clientes para Coleta de Sell Out que deverá ser realizada ' +
							 'até a Data de vencimento informada nesta tarefa.\n\n' +
							 'Precisamos garantir a coleta das informações de todos os clientes em anexo.\n\n' +
							 'Qualquer dúvida, favor entrar em contato.\n\n' +
							 'Obrigado\n' +
							 'Administração de Vendas\n\n' +
							 'Lista de Clientes para Coleta de Sell Out:\n\n';

		Map<String, List<LAT_ReferenceAccount__c>> ownerIds = new Map<String, List<LAT_ReferenceAccount__c>>();
		for (LAT_ReferenceAccount__c ac: [SELECT AccountName__c, AN8__c, Account__r.ownerid FROM LAT_ReferenceAccount__c 
											WHERE IsActive__c = true]) {
			if (ownerIds.get(ac.Account__r.ownerId) == null) {
				ownerIds.put(ac.Account__r.ownerId, new List<LAT_ReferenceAccount__c>{ac});
			} else {
				ownerIds.get(ac.Account__r.ownerId).add(ac);
			}
			//Description += ac.AccountName__c + ' - ' + ac.AN8__c + '\n';
		}

		//if (Description.length() > 32000) {
		//	Description = Description.substring(0,31999);
		//}

		// Crear tareas!
		List<Task> tasksToCreate = new List<Task>();
		//for (AggregateResult owner : ownersIds) {
		for (String owner : ownerIds.keySet()) {
			String ownerDescription =  Description;

			if (ownerIds.get(owner) != null) {
				for (LAT_ReferenceAccount__c ra: ownerIds.get(owner)) {
					ownerDescription += ra.AccountName__c + ' - ' + ra.AN8__c + '\n';
				}
			}

			if (ownerDescription.length() > 32000) {
				ownerDescription = ownerDescription.substring(0,31999);
			}

			tasksToCreate.add(new Task(OwnerId = (ID) owner,
				Subject = 'Coleta Sell Out – FECHAMENTO - ' + monthMap.get(vence.month()) + '/' + vence.year(),
				Priority = 'High',
				ActivityDate = lastDay,
				ReminderDateTime = alertOn,
				IsReminderSet = true,
				Description = ownerDescription));
		}

		// inserto las tareas
		if (tasksToCreate.size() > 0) {
			insert tasksToCreate;
		}
	}

	public static Map<Integer, String> getMonthMap() {
		Map<Integer, String> result = new Map<Integer,String>();
	
		result.put(1, Label.LAT_January);
		result.put(2, Label.LAT_February);
		result.put(3, Label.LAT_March);
		result.put(4, Label.LAT_April);
		result.put(5, Label.LAT_May);
		result.put(6, Label.LAT_June);
		result.put(7, Label.LAT_July);
		result.put(8, Label.LAT_August);
		result.put(9, Label.LAT_September);
		result.put(10, Label.LAT_October);
		result.put(11, Label.LAT_November);
		result.put(12, Label.LAT_December);

		return result;
	}
}