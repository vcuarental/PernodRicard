global class LAT_EveryMinute_Scheduler implements Schedulable {
	global void execute(SchedulableContext sc) {
		LAT_DebugUtil debugUtil = new LAT_DebugUtil();
		debugUtil.setOrigin('LAT_EveryMinute_Scheduler');
        debugUtil.addData('Minuto Actual' , String.valueOf(Datetime.now().minute()));
        debugUtil.addSubTitle('Clases Ejecutadas :');
		System.debug('%%%%% Minuto Actual : '+ Datetime.now().minute());
		try {
			

			List<LAT_SchedulerConfig__c> toSchedule = [SELECT Apex_Class__c, Minute__c, Batch_Size__c FROM LAT_SchedulerConfig__c WHERE Scheduler__c = 'LAT_EveryMinute_Scheduler' 
														AND Minute__c =:Datetime.now().minute()  ];

			Map<String, Integer> batchsToRun = new Map<String, Integer>();
			for (LAT_SchedulerConfig__c conf : toSchedule) {
				batchsToRun.put(conf.Apex_Class__c, Integer.valueOf(conf.Batch_Size__c));
			}
			System.debug('%%%% Batchs to Run : '+ batchsToRun);

			if (batchsToRun.get('LAT_UY_StockCheckBatch') != null) {
				debugUtil.addData(' - LAT_UY_StockCheckBatch');
				Database.executeBatch(new LAT_UY_StockCheckBatch(), batchsToRun.get('LAT_UY_StockCheckBatch'));
			}

			if (batchsToRun.get('LAT_AR_StockCheckBatch') != null) {
				debugUtil.addData(' - LAT_AR_StockCheckBatch');
				Database.executeBatch(new LAT_AR_StockCheckBatch(), batchsToRun.get('LAT_AR_StockCheckBatch'));
			}
	 		
			if (batchsToRun.get('LAT_RecordIntegrationVerifications') != null) {
				debugUtil.addData(' - LAT_RecordIntegrationVerifications');
				LAT_RecordIntegrationVerifications.verifyOpportunitiesIntegration();
				LAT_RecordIntegrationVerifications.verifyAccountsIntegration();
				LAT_RecordIntegrationVerifications.verifyDocusignUsers();
				LAT_RecordIntegrationVerifications.verifyApprovalsUsers();
			}

			debugUtil.insertDebug();
			//MyBatchClass b = new MyBatchClass();
			//database.executebatch(b);
		} catch (Exception e) {
			debugUtil.addException(e);
			debugUtil.insertDebug();
		}

	}


}