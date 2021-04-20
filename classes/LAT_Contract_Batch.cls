/*
* LAT_Contract_Batch.
* Author: Martin Prado (martin@zimmic.com)
* Date: 07/28/2017
*/
global class LAT_Contract_Batch implements Database.Batchable<sObject> {

	String query;
	Static Integer daysToFinish;

	// Constructor
	global LAT_Contract_Batch() {
		String days_out_30 = getSoqlDate(30);
		query = 'SELECT Name, owner.Email, Account__r.Name, (Select Ammount__c,Finality__c,Id,LAT_Contract__c,Name, '
			+ 'PaymentDateDone__c,PaymentDate__c,ProductGroup__c,RecordTypeId,Status__c,Type__c, ParentPayment__c, IntegrationMessage__c FROM LAT_Payments__r WHERE '
			+ 'LAT_Contract__r.RecordType.DeveloperName <> \'LAT_Eventos_Contrato_de_Parceria\' OR '
			+ 'Finality__c <>\'Condição Comercial\' OR (LAT_Contract__r.RecordType.DeveloperName = \'LAT_Eventos_Contrato_de_Parceria\' AND '
			+ 'Finality__c =\'Condição Comercial\' AND LAT_IsCommCondParentPayment__c=true)), '
			+ '(SELECT Id, LAT_Status__c FROM Eventos__r),'
			+ 'EndDate__c,OwnerId,Status__c, ProcessStatus__c, RecordType.DeveloperName FROM LAT_Contract2__c '
			+ 'WHERE Status__c = \'ativo\' and  (EndDate__c = TODAY	or EndDate__c = '+days_out_30+' OR ProcessStatus__c = \'Contrato Prorrogado\')';
	}

	// Start
	global Database.QueryLocator start(Database.BatchableContext BC) {
		System.debug('START CONTRACT BATCH');
		return Database.getQueryLocator(query);
	}

	// Execute
	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		daysToFinish = 15;
		String[] tdays = LAT_GeneralConfigDao.getValueAsStringArray('CONTRACT_TASK_DAYS', ' ');
		if(tdays != null && tdays.size()>0)daysToFinish = Integer.valueOf(tdays[0]);

		List<LAT_Contract2__c> contracts = (List<LAT_Contract2__c>)scope;
		for(LAT_Contract2__c contract : contracts) {
			System.debug('Contrato : '+ contract.Name);
			if(contract.RecordType.DeveloperName == 'LAT_Eventos_Contrato_de_Parceria') {
				processEventContract(contract);
			} else {
				if(contract.ProcessStatus__c == 'Contrato Prorrogado') {
					processProrrogatedContract(contract);
				} else {
					if(contract.EndDate__c == Date.Today()){
						System.debug(contract.id + 'ENDs TODAY');
						processExpireTodayContract(contract);
					} else {
						System.debug(contract.id + 'ENDs next month');
						processExpireNextMonthContract(contract);
					}
				}	
			}
		}
	}

	// Finish process
	global void finish(Database.BatchableContext BC) {
		System.debug('END CONTRACT BATCH');
	}


	/*
	* getSoqlDate
	* Add days to Today and transform to string with valid format
	*/
	private static String getSoqlDate(Integer daysFromNow) {
	    return Datetime.now().addDays(daysFromNow).formatGmt('yyyy-MM-dd');
	}

	/*
	* processExpireTodayContract
	* If the Contract expire today and all the payments are done, we must close the contract, if we have payements unpaid we
	* have to create a task to the contract's owner
	*/
    @TestVisible
	private static void processExpireTodayContract(LAT_Contract2__c contract) {

		Boolean allPaymentsDone = true;
		for(LAT_Payment__c pay : contract.LAT_Payments__r) {
			if((pay.Status__c != 'E' && pay.Status__c !='C') && pay.ParentPayment__c == null) {
				allPaymentsDone = false;
			}
		}
		System.debug('allPaymentsDone:' +allPaymentsDone);

		// If allPaymentsDone we must close the contract and post on chatter
		if(allPaymentsDone) {
			List<CollaborationGroup> groupC = [SELECT Id,Name From CollaborationGroup WHERE name='Contratos OnTrade'];
			if(groupC.size()>0){
				FeedItem post = new FeedItem();
				post.Body = 'Contrato Número '+contract.Name+' com o cliente '+contract.Account__r.Name+' Encerrado.';
				post.ParentId = groupC[0].Id;
				post.Title = 'Contrato: ' + contract.Name + ' Encerrado';
				insert post;
			}
			contract.status__c = 'Encerrado';
			update contract;
			if(contract.RecordType.DeveloperName == 'LAT_CartaAtivacao'){
				Task notif = LAT_ProcessesTaks.createTask(contract.id, contract.OwnerId, 'Registrar Resultados',
							'', Global_RecordTypeCache.getRtId('Task'+'LAT_Contract'),
							daysToFinish, 'CON - Encerramento');
				insert notif;
			}
		}
		// If we have unpaid payments, we must generate a task to the owner
		else {
			Task notif = LAT_ProcessesTaks.createTask(contract.id, contract.OwnerId, 'Distrato ou Prorrogação',
							'', Global_RecordTypeCache.getRtId('Task'+'LAT_Contract'),
							daysToFinish, 'CT-ExtendOrCancel');
			insert notif;
		}
	}

	/*
	* processExpireNextMonthContract
	* If the contract Expire next month we must to notify the owner if we have some payments != "efeito" we must
	* send an email to the owner to notify
	*/
    @TestVisible
	private static void processExpireNextMonthContract(LAT_Contract2__c contract) {

		Boolean mustNotify = false;
		for(LAT_Payment__c pay : contract.LAT_Payments__r) {
			if((pay.Status__c != 'E' && pay.Status__c !='C') && pay.ParentPayment__c == null) {
				mustNotify = true;
			}
		}
		System.debug('mustNotify:' +mustNotify);

		String[] mails = new String[]{contract.owner.Email};
		if(mustNotify){
			sendEmailNotification(mails, contract.Name, contract.Account__r.Name , contract.EndDate__c.format() );
		}
	}

	/*
	* processProrrogatedContract
	* If the Contract has been prorrogated and all the payments are done, we must close the contract.
	*/
    @TestVisible
	private static void processProrrogatedContract(LAT_Contract2__c contract) {

		Boolean allPaymentsDone = true;
		for(LAT_Payment__c pay : contract.LAT_Payments__r) {
			if((pay.Status__c != 'E' && pay.Status__c !='C') && pay.ParentPayment__c == null) {
				allPaymentsDone = false;
			}
		}
		System.debug('allPaymentsDone:' +allPaymentsDone);

		// If allPaymentsDone we must close the contract and post on chatter
		if(allPaymentsDone) {
			List<CollaborationGroup> groupC = [SELECT Id,Name From CollaborationGroup WHERE name='Contratos OnTrade'];
			if(groupC.size()>0){
				FeedItem post = new FeedItem();
				post.Body = 'Contrato Número '+contract.Name+' com o cliente '+contract.Account__r.Name+' Encerrado.';
				post.ParentId = groupC[0].Id;
				post.Title = 'Contrato: ' + contract.Name + ' Encerrado';
				insert post;
			}
			contract.status__c = 'Encerrado';
			update contract;
			if(contract.RecordType.DeveloperName == 'LAT_CartaAtivacao'){
				Task notif = LAT_ProcessesTaks.createTask(contract.id, contract.OwnerId, 'Registrar Resultados',
							'', Global_RecordTypeCache.getRtId('Task'+'LAT_Contract'),
							daysToFinish, 'CON - Encerramento');
				insert notif;
			}
		}
	}

	@TestVisible
	private static void processEventContract(LAT_Contract2__c contract) {

		Boolean allPaymentsDone = true;
		for(LAT_Payment__c pay : contract.LAT_Payments__r) {
			if((pay.Status__c != 'E' && pay.Status__c !='C') && pay.ParentPayment__c == null)  {
				allPaymentsDone = false;
			}
		}
		System.debug('allPaymentsDone:' +allPaymentsDone);

		Boolean allEventsDone = true;
		for(LAT_Contract_Eventos__c evento : contract.Eventos__r) {
			if(evento.LAT_Status__c != 'Realizado' && evento.LAT_Status__c != 'Não Realizado')  {
				allEventsDone = false;
			}
		}
		System.debug('allEventsDone:' +allEventsDone);

		// If allPaymentsDone we must close the contract and post on chatter
		if(allPaymentsDone && allEventsDone) {
			contract.status__c = 'Encerrado';
			update contract;
		} else {
			if(contract.EndDate__c == Date.Today()){
				System.debug(contract.id + 'ENDs TODAY');
				Integer daysToFinish = 15;
				String[] tdays = LAT_GeneralConfigDao.getValueAsStringArray('CONTRACT_TASK_DAYS', ' ');
				if(tdays != null && tdays.size()>0)daysToFinish = Integer.valueOf(tdays[0]);
				Task notif = LAT_ProcessesTaks.createTask(contract.id, contract.OwnerId, 'Distrato ou Prorrogação',
								'', Global_RecordTypeCache.getRtId('Task'+'LAT_Contract'),
								daysToFinish, 'CT-ExtendOrCancel');
				insert notif;
			} else if(contract.EndDate__c == Date.Today().addDays(30)){
				System.debug(contract.id + 'ENDs next month');
				String[] mails = new String[]{contract.owner.Email};
				sendEmailNotification(mails, contract.Name, contract.Account__r.Name , contract.EndDate__c.format() );
			}
		}
	}
	/**
	* sendEmailNotification
	*/
	public static void sendEmailNotification(String[] mailAddress, String contractName, String accountName, String endDate){

  		String html = 'O Contrato '+contractName+' do Cliente '+accountName+' vencerá em '+endDate+'. <br/> Avaliar a necessidade de Prorrogação ou Cancelamento do Contrato. <br/> Obrigado.<br/> Trade';
		String subject = 'Vencimento Contrato '+contractName;
		Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
		email.setToAddresses( mailAddress );
		email.setSaveAsActivity(false);
		email.setHtmlBody(html);
		email.setBccSender(false);
		email.setSubject(subject);
		email.setUseSignature(false);
		Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
	}
}