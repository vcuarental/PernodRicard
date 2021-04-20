/*
* LAT_PromotionalActionTaskBatch, generate Kpi Clients recurrents tasks
* Author: Martin Prado (martin@zimmic.com)
* Date: 08/9/2017
*/

global class LAT_PromotionalActionTaskBatch implements Database.Batchable<sObject> {

	String query;

	global LAT_PromotionalActionTaskBatch() {
		query = 'SELECT id, (Select Id, LAT_Account__r.ownerId, LAT_Account__r.recordTypeId, LAT_Account__r.recordType.Name  from LAT_AccountInAction__r), LAT_StartDate__c, LAT_EndDate__c, LAT_status__c, Name, (Select Id, LAT_PromotionalAction__c,  LAT_KPI__c, LAT_KPI__r.Name, LAT_KPI__r.LAT_KPI_Recurring__c, LAT_KPI__r.LAT_KPI_OffTrade__c, LAT_KPI__r.LAT_KPI_OnTrade__c from LAT_ActionKPIs__r where LAT_KPI__r.LAT_KPI_Recurring__c = true) from LAT_PromotionalAction__c where LAT_status__c = \'Ação iniciada\'';
		//'SELECT id, LAT_StartDate__c, LAT_EndDate__c, LAT_status__c, Name, (Select Id, LAT_KPI__c, LAT_KPI__r.Name, LAT_KPI__r.LAT_KPI_Recurring__c from LAT_ActionKPIs__r where LAT_KPI__r.LAT_KPI_Recurring__c = true) from LAT_PromotionalAction__c'
		//return Database.getQueryLocator(query);
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		List<LAT_PromotionalAction__c> promotionalActions = (List<LAT_PromotionalAction__c>)scope;

		Map<ID, LAT_PromotionalAction__c> promotionalMap = new Map<ID, LAT_PromotionalAction__c>((List<LAT_PromotionalAction__c>)scope);

		List<String> clientsIds = new List<String>();

		// Move Through Promotional actions
		for(LAT_PromotionalAction__c ap : promotionalActions) {

			// Has Recurrents KPIS
			if(!ap.LAT_ActionKPIs__r.isEmpty()) {

				// Save the client Id to query when was the last time that the task was created
				for(LAT_AccountInAction__c cliente : ap.LAT_AccountInAction__r ) {
					clientsIds.add(cliente.Id);
				}
			}
		}

		if(!clientsIds.isEmpty()){
			List<LAT_ClientKPI__c> existingKPI = [Select Id, CreatedDate, LAT_AccountInAction__r.LAT_PromotionalAction__c,  LAT_AccountInAction__r.LAT_PromotionalAction__r.LAT_EndDate__c from LAT_ClientKPI__c where LAT_AccountInAction__c IN : clientsIds order by createdDate desc];

			if(!existingKPI.isEmpty()){

				LAT_ClientKPI__c currentKPI = existingKPI.get(0);
				Integer recurrentDays = LAT_PromotionalActionHandler.getSLANumberOfDays('AP_KPI_COLLECTS');
				System.debug('\n######################\n recurrentDays: '+recurrentDays +'\n######################\n' );
				Date lastCreatedDate = Date.valueOf(currentKPI.createdDate);
				System.debug('\n######################\n recurrentDays: '+lastCreatedDate +'\n######################\n' );
				Date today = Date.today();
				Date nexTaskDate = today.addDays(recurrentDays);
				System.debug('\n######################\n nexTaskDate: '+nexTaskDate +'\n######################\n' );

				Integer daysLastTask = lastCreatedDate.daysBetween(today);
				System.debug('\n######################\n daysLastTask: '+daysLastTask +'\n######################\n' );

				List<Integer> taskDatesToSave = new List<Integer>();

				if (currentKPI.LAT_AccountInAction__r.LAT_PromotionalAction__r.LAT_EndDate__c > nexTaskDate && daysLastTask > recurrentDays ) {
					taskDatesToSave.add(recurrentDays);
					System.debug('\n######################\n taskDatesToSave: '+taskDatesToSave +'\n######################\n' );

				}

				if(!taskDatesToSave.isEmpty()){
					System.debug('\n######################\n promotionalMap.get(currentKPI.LAT_AccountInAction__c): '+promotionalMap.get(currentKPI.LAT_AccountInAction__r.LAT_PromotionalAction__c) +'\n######################\n' );

					generateKPIsRecucrentsForClients(promotionalMap.get(currentKPI.LAT_AccountInAction__r.LAT_PromotionalAction__c) , taskDatesToSave);
				}


			} else {
				// Empty Task
				System.debug('FIRST TIME WITH TASK');
			}
		}



	}

	global void finish(Database.BatchableContext BC) {

	}

	/*
    * generateKPIsRecucrentsForClients
    * @param apID = Promotional Action Id
    */
	public static void generateKPIsRecucrentsForClients(LAT_PromotionalAction__c ap, List<Integer> taskDatesToSave) {

		List<LAT_AccountInAction__c> clients = ap.LAT_AccountInAction__r;
		SYSTEM.debug('============\n  clients: '+clients+' \n ===========');
		// KPIS
		List<LAT_ActionKPI__c> kpis = ap.LAT_ActionKPIs__r;
		SYSTEM.debug('============\n  kpis: '+kpis+' \n ===========');

		// we must generate Kpi and brands for each clients based on AP related lists
		if(!clients.isEmpty() && !kpis.isEmpty()) {


			// Insert KPIs
			List<LAT_ClientKPI__c> clientKPIToInsert = new List<LAT_ClientKPI__c>();
			SYSTEM.debug('============\n  clientKPIToInsert: '+clientKPIToInsert+' \n ===========');
			//
			for(Integer taskDate : taskDatesToSave ){
				SYSTEM.debug('============\n  taskDate: '+taskDate+' \n ===========');
				for(LAT_AccountInAction__c cl : clients) {
					String recordType = '';
					if(cl.LAT_Account__r.recordTypeId != null) {
						recordType = cl.LAT_Account__r.recordType.Name;
					}
					Task task = LAT_ProcessesTaks.createTask(cl.id, cl.LAT_Account__r.ownerId, 'Coletar KPI´s',
							 '', Global_RecordTypeCache.getRtId('Task'+'LAT_PromotionalAction'), taskDate, 'AP-Coletar KPI');
					task.LAT_AccountInAction__c = cl.Id;
					insert task;

					SYSTEM.debug('============\n  task: '+task+' \n ===========');
					for(LAT_ActionKPI__c kp : kpis) {
						LAT_ClientKPI__c clientKPI = new LAT_ClientKPI__c();
						clientKPI.LAT_AccountInAction__c = cl.Id;
						clientKPI.Name = kp.LAT_KPI__r.Name;
						clientKPI.LAT_Quantity__c = 0 ;
						clientKPI.LAT_ActionKPI__c = kp.Id ;
						clientKPI.LAT_Task__c =  task.Id;//taskId;
						clientKPI.LAT_TaskName__c =  task.subject;

						if((recordType == 'On Trade' && kp.LAT_KPI__r.LAT_KPI_OnTrade__c) || (recordType == 'Off Trade' && kp.LAT_KPI__r.LAT_KPI_OffTrade__c) ) {
							clientKPIToInsert.add(clientKPI);
						}

						//clientKPIToInsert.add(clientKPI);
					}


				}
				SYSTEM.debug('============\n  clientKPIToInsert: '+clientKPIToInsert+' \n ===========');


			}
			if(!clientKPIToInsert.isEmpty()){
				upsert clientKPIToInsert;
			}

		}
	}

}