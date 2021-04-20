global class LAT_EveryHour_Scheduler implements Schedulable {
	global void execute(SchedulableContext sc) {


		LAT_DebugUtil debugUtil = new LAT_DebugUtil();
		debugUtil.setOrigin('LAT_EveryHour_Scheduler');
        debugUtil.addData('Hora Actual:' , String.valueOf(Datetime.now().hour()));
        debugUtil.addSubTitle('Clases Ejecutadas :');
		System.debug('%%%%% Hora Actual : '+ Datetime.now().hour());
		try {
			

			List<LAT_SchedulerConfig__c> toSchedule = [SELECT Apex_Class__c, Hour__c, Day__c, Batch_Size__c FROM LAT_SchedulerConfig__c WHERE Scheduler__c = 'LAT_EveryHour_Scheduler' 
														AND Hour__c =:Datetime.now().hour()  ];

			Map<String, Integer> batchsToRun = new Map<String, Integer>();
			for (LAT_SchedulerConfig__c conf : toSchedule) {
				if (conf.Day__c == null) {
					batchsToRun.put(conf.Apex_Class__c, Integer.valueOf(conf.Batch_Size__c));
				} else {
					if (conf.Day__c == Datetime.now().day()) {
						batchsToRun.put(conf.Apex_Class__c, Integer.valueOf(conf.Batch_Size__c));
					}
					
				}
				
			}
			System.debug('%%%% Batchs to Run : '+ batchsToRun);

			if (batchsToRun.get('PCS01_AnalyticsOfCCBatch_AR') != null) {
				debugUtil.addData(' - PCS01_AnalyticsOfCCBatch_AR');
	        	Database.executeBatch(new PCS01_AnalyticsOfCCBatch_AR());
			}

			if (batchsToRun.get('LAT_MX_Planejamento_Batch') != null) {
				debugUtil.addData(' - LAT_MX_Planejamento_Batch');
				Database.executeBatch(new LAT_MX_Planejamento_Batch(), batchsToRun.get('LAT_MX_Planejamento_Batch'));
			}

			if (batchsToRun.get('LAT_BR_Planejamento_Batch') != null) {
				debugUtil.addData(' - LAT_BR_Planejamento_Batch');
				Database.executeBatch(new LAT_BR_Planejamento_Batch(), batchsToRun.get('LAT_BR_Planejamento_Batch'));
			}
	 		
			if (batchsToRun.get('LAT_BR_SellOutTaskCreator') != null) {
				debugUtil.addData(' - LAT_BR_SellOutTaskCreator');
				Boolean colletaCreateTasks = false;
				String[] stringBoolean = LAT_GeneralConfigDao.getValueAsStringArray('COLLETA_CREATE_TASKS', ',');
		        if (!stringBoolean.isEmpty()) {
		            colletaCreateTasks = Boolean.valueOf(stringBoolean[0]);
		        } 

		        if (colletaCreateTasks) {
		        	Date lastDay = Date.today().toStartOfMonth().addMonths(1).addDays(-1);
		        	LAT_BR_SellOutTaskCreator.createTask(lastDay);
		        }
			}

			if (batchsToRun.get('LAT_BR_PromotionalActionScheduler') != null) {
				debugUtil.addData(' - LAT_BR_PromotionalActionScheduler');
				LAT_BR_PromotionalActionScheduler.postToChatter();
	        	LAT_BR_PromotionalActionScheduler.generateActivities();
				Database.executebatch(new LAT_PromotionalActionTaskBatch(), 10);
			}

			if (batchsToRun.get('LAT_Contract_Batch') != null) {
				debugUtil.addData(' - LAT_Contract_Batch');
				Database.executeBatch(new LAT_Contract_Batch(), batchsToRun.get('LAT_Contract_Batch'));
			}		

			if (batchsToRun.get('LAT_CheckPaymentStatusOnME_Batch') != null) {
				debugUtil.addData(' - LAT_CheckPaymentStatusOnME_Batch');
				Database.executeBatch(new LAT_CheckPaymentStatusOnME_Batch(), batchsToRun.get('LAT_CheckPaymentStatusOnME_Batch'));
			}

			if (batchsToRun.get('LAT_BR_Check_Pending_Visits_Batch') != null) {
				debugUtil.addData(' - LAT_BR_Check_Pending_Visits_Batch');
				Database.executeBatch(new LAT_BR_Check_Pending_Visits_Batch(), batchsToRun.get('LAT_BR_Check_Pending_Visits_Batch'));
			}
			
			if (batchsToRun.get('LAT_ReceiptValidations_Batch') != null) {
				debugUtil.addData(' - LAT_ReceiptValidations_Batch');
				Database.executeBatch(new LAT_ReceiptValidations_Batch(), batchsToRun.get('LAT_ReceiptValidations_Batch'));
			}

			if (batchsToRun.get('LAT_Check_Account_Chaged_Owner_Batch') != null) {
				debugUtil.addData(' - LAT_Check_Account_Chaged_Owner_Batch');
				Database.executeBatch(new LAT_Check_Account_Chaged_Owner_Batch(), batchsToRun.get('LAT_Check_Account_Chaged_Owner_Batch'));
			}

			if (batchsToRun.get('LAT_ApprovalProcessSLA_Batch') != null) {
				debugUtil.addData(' - LAT_ApprovalProcessSLA_Batch');
				Database.executeBatch(new LAT_ApprovalProcessSLA_Batch(), batchsToRun.get('LAT_ApprovalProcessSLA_Batch'));
			}
			
			if (batchsToRun.get('LAT_RecordIntegrationVerifications') != null) {
				debugUtil.addData(' - LAT_RecordIntegrationVerifications');
				LAT_RecordIntegrationVerifications.verifyBrasilUsers();
				LAT_RecordIntegrationVerifications.verifyManagerFieldsInContracts();
				LAT_RecordIntegrationVerifications.verifyManagerFieldsInPayments();
			}
			if (batchsToRun.get('LAT_AR_B2B_PriceCalc_Scheduler') != null) {
				debugUtil.addData(' - LAT_AR_B2B_PriceCalc_Scheduler');
				Datetime sysTime = System.now();
				sysTime = sysTime.addSeconds(10);
				String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
				LAT_AR_B2B_PriceCalc_Scheduler scheduler = new LAT_AR_B2B_PriceCalc_Scheduler();
				System.schedule('B2B PriceCalculation ' + sysTime,chron_exp,scheduler);
			}
			debugUtil.insertDebug();

		} catch (Exception e) {
            System.debug('Exception : '+ e);
			debugUtil.addException(e);
			debugUtil.insertDebug();
		}
	}
}