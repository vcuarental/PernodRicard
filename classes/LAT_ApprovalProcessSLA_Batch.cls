global class LAT_ApprovalProcessSLA_Batch implements Database.Batchable<sObject> {
	
	String query;

	public LAT_ApprovalProcessSLA_Batch() {
		//String objectsToSearch = '\'Account\',\'LAT_Contract2__c\',\'LAT_Opportunity__c\',\'LAT_Payment__c\'';
		String objectsToSearch = LAT_GeneralConfig__c.getInstance('APPROVAL_SLA_OBJECTS').LAT_Value__c;
		String adminQtyDays = LAT_GeneralConfig__c.getInstance('APPROVAL_SLA_ADMIN_DAYS_QTY').LAT_Value__c;


		query = 'SELECT ProcessInstance.targetobject.name, Actor.Profile.Name, Actor.email, Actor.Name, ActorId, OriginalActorId, ProcessInstanceId, ProcessInstance.ProcessDefinition.TableEnumOrId, ProcessInstance.targetobjectid, CreatedDate,ProcessInstance.Status FROM ProcessInstanceWorkitem where createddate = LAST_N_DAYS:'+adminQtyDays;
		query += ' AND ProcessInstance.ProcessDefinition.TableEnumOrId IN ('+ objectsToSearch +') Order by CreatedDate';

	}

	// Start
	global Database.QueryLocator start(Database.BatchableContext BC) {
		System.debug('START APPROVALS SLA BATCH');
		System.debug('%%%% query : ' + query);
		return Database.getQueryLocator(query);
	}

	// Execute
	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		Integer userQtyDays = Integer.valueOf(LAT_GeneralConfig__c.getInstance('APPROVAL_SLA_USER_DAYS_QTY').LAT_Value__c);
		Integer adminQtyDays = Integer.valueOf(LAT_GeneralConfig__c.getInstance('APPROVAL_SLA_ADMIN_DAYS_QTY').LAT_Value__c);
		Integer managerQtyDays = Integer.valueOf(LAT_GeneralConfig__c.getInstance('APPROVAL_SLA_MANAGER_DAYS_QTY').LAT_Value__c);

		Date userDays = Date.today().addDays(-1*userQtyDays);
		Date adminDays = Date.today().addDays(-1*adminQtyDays);
		Date managerDays = Date.today().addDays(-1*managerQtyDays);
		System.debug('userDays : '+ userDays);
		System.debug('adminDays : '+adminDays);
		System.debug('managerDays : '+managerDays);


		List<ProcessInstanceWorkitem> instances = (List<ProcessInstanceWorkitem>)scope;
		System.debug('Encontrados : '+instances.size());
		System.debug('Encontrados : '+instances);
		Map<String, String> mapBodyXUsuarios = new Map<String, String>();
		Map<String, String> mapBodyXManagers = new Map<String, String>();
		Boolean adminEmailBR = false;
		Boolean adminEmailAR = false;
		Boolean adminEmailMX = false;
		String mensajeAdmin = '';

		for(ProcessInstanceWorkitem pi : instances) {
			if(pi.CreatedDate.dayOfYear() == userDays.dayOfYear()) {
				System.debug('%%%% pi : '+ pi.ProcessInstance.targetobjectid);
				if(mapBodyXUsuarios.get(pi.ActorId) == null) mapBodyXUsuarios.put(pi.ActorId, '');
				String aux = mapBodyXUsuarios.get(pi.ActorId);
				aux += ' - '+pi.ProcessInstance.ProcessDefinition.TableEnumOrId +' <a href=\"https://' + URL.getSalesforceBaseUrl().getHost() + '/' + pi.ProcessInstance.targetobjectid+ '\">' +pi.ProcessInstance.targetobject.name +'</a><br>';
				mapBodyXUsuarios.put(pi.ActorId, aux);

			} else if(pi.CreatedDate.dayOfYear() == managerDays.dayOfYear()) {
				System.debug('%%%% pi manager : '+ pi.ProcessInstance.targetobjectid);
				if(mapBodyXManagers.get(pi.ActorId) == null) mapBodyXManagers.put(pi.ActorId, '');
				String aux = mapBodyXManagers.get(pi.ActorId);
				aux += ' - '+pi.ProcessInstance.ProcessDefinition.TableEnumOrId +' <a href=\"https://' + URL.getSalesforceBaseUrl().getHost() + '/' + pi.ProcessInstance.targetobjectid+ '\">' +pi.ProcessInstance.targetobject.name +'</a><br>';
				mapBodyXManagers.put(pi.ActorId, aux);
			} else if(pi.CreatedDate.dayOfYear() == adminDays.dayOfYear()) {

				System.debug('%%%%% pi 30 dias : ' + pi);
				System.debug('%%%%% pi.Actor.Profile.Name : ' + pi.Actor.Profile.Name);
				if(pi.Actor.Profile.Name.contains('LAT_BR2')){
					adminEmailBR = true;
					mensajeAdmin += ' -  Responsável : <b>'+ pi.Actor.Name + '</b>, Registro : <a href=\"https://' + URL.getSalesforceBaseUrl().getHost() + '/' + pi.ProcessInstance.targetobjectid+ '\">' +pi.ProcessInstance.targetobject.name +'</a> ('+pi.ProcessInstance.ProcessDefinition.TableEnumOrId + ').<br>';
				}
				if(pi.Actor.Profile.Name.contains('LAT_AR2')){
					adminEmailAR = true;
					mensajeAdmin += ' -  Responsable : <b>'+ pi.Actor.Name + '</b>, Registro : <a href=\"https://' + URL.getSalesforceBaseUrl().getHost() + '/' + pi.ProcessInstance.targetobjectid+ '\">' +pi.ProcessInstance.targetobject.name +'</a> ('+pi.ProcessInstance.ProcessDefinition.TableEnumOrId + ').<br>';
				}
				if(pi.Actor.Profile.Name.contains('LAT_MX2')){
					adminEmailMX = true;
					mensajeAdmin += ' -  Responsable : <b>'+ pi.Actor.Name + '</b>, Registro : <a href=\"https://' + URL.getSalesforceBaseUrl().getHost() + '/' + pi.ProcessInstance.targetobjectid+ '\">' +pi.ProcessInstance.targetobject.name +'</a> ('+pi.ProcessInstance.ProcessDefinition.TableEnumOrId + ').<br>';
				}
			} 
		}

		if(mapBodyXUsuarios.size() > 0) {
			enviarNotificacionUsuarios(mapBodyXUsuarios, userQtyDays);
		}

		if(mapBodyXManagers.size() > 0) {
			enviarNotificacionManagers(mapBodyXManagers, managerQtyDays);
		}

		if(adminEmailBR) {
			enviarNotificacionAdminsBR(mensajeAdmin, adminQtyDays);
		}
		if(adminEmailAR) {
			enviarNotificacionAdminsAR(mensajeAdmin, adminQtyDays);
		}
		if(adminEmailMX) {
			enviarNotificacionAdminsMX(mensajeAdmin, adminQtyDays);
		}
	}

	public static void enviarNotificacionUsuarios(Map<String, String> mapBodyXUsuarios, Integer userQtyDays){
		
		Map<Id, User> usersIncluded = getUserInfo(mapBodyXUsuarios);

		for (String userId : mapBodyXUsuarios.keySet()) {
			String htmlInicial = (usersIncluded.get(userId).LanguageLocaleKey == 'pt_BR' ? Label.LAT_ApprovalSLA_003_BR :Label.LAT_ApprovalSLA_003);
			//String htmlInicial = 'Estimado XX_NOMBRE_XX, <br><br>Encontramos que los siguientes registros están pendientes de su aprobación desde hace XX_userQtyDays_XX días:<br><br>';
			String subject = (usersIncluded.get(userId).LanguageLocaleKey == 'pt_BR' ? Label.LAT_ApprovalSLA_002_BR :Label.LAT_ApprovalSLA_002);
			//String subject = 'Tiene registros pendientes de aprobación en CRM';
			
			String html = htmlInicial + mapBodyXUsuarios.get(userId);
			html = html.replace('XX_NOMBRE_XX', '');
			html = html.replace('XX_userQtyDays_XX', String.valueOf(userQtyDays));
			html += (usersIncluded.get(userId).LanguageLocaleKey == 'pt_BR' ? Label.LAT_ApprovalSLA_001_BR :Label.LAT_ApprovalSLA_001);
			html = html.replace('LAT_Opportunity__c', 'Pedido');
			html = html.replace('LAT_Case__c', 'Demanda');
			html = html.replace('LAT_Payment__c', 'Pagamento');
			html = html.replace('Account', 'Cliente');
			html = html.replace('LAT_Contract2__c', 'Contrato');
			//html += '<br><br>Por favor revíselos. <br><br>Muchas gracias,<br><br>Equipo CRM';
			sendEmailNotification(new String[]{usersIncluded.get(userId).Email}, html, subject);
		}
	}

	public static void enviarNotificacionManagers(Map<String, String> mapBodyXManagers, Integer userQtyDays){
		

		System.debug('%%% :mapBodyXManagers.keySet() : ' + mapBodyXManagers.keySet());
		Map<Id, User> usersIncluded = getUserInfo(mapBodyXManagers);
		

		for (String userId : mapBodyXManagers.keySet()) {
			String htmlInicial = (usersIncluded.get(userId).LanguageLocaleKey == 'pt_BR' ? Label.LAT_ApprovalSLA_003_BR :Label.LAT_ApprovalSLA_003);
			//String htmlInicial = 'Estimado XX_NOMBRE_XX, <br><br>Encontramos que los siguientes registros están pendientes de su aprobación desde hace XX_userQtyDays_XX días:<br><br>';
			String subject = (usersIncluded.get(userId).LanguageLocaleKey == 'pt_BR' ? Label.LAT_ApprovalSLA_002_BR :Label.LAT_ApprovalSLA_002);
			//String subject = 'Tiene registros pendientes de aprobación en CRM';

			String html = htmlInicial + mapBodyXManagers.get(userId);
			html = html.replace('XX_NOMBRE_XX', usersIncluded.get(userId).Name);
			html = html.replace('XX_userQtyDays_XX', String.valueOf(userQtyDays));
			html += (usersIncluded.get(userId).LanguageLocaleKey == 'pt_BR' ? Label.LAT_ApprovalSLA_001_BR :Label.LAT_ApprovalSLA_001);
			html = html.replace('LAT_Opportunity__c', 'Pedido');
			html = html.replace('LAT_Case__c', 'Demanda');
			html = html.replace('LAT_Payment__c', 'Pagamento');
			html = html.replace('Account', 'Cliente');
			html = html.replace('LAT_Contract2__c', 'Contrato');
			//html += '<br><br>Por favor revíselos. <br><br>Muchas gracias,<br><br>Equipo CRM';
			sendEmailNotification(new String[]{usersIncluded.get(userId).Email, usersIncluded.get(userId).Manager.Email}, html, subject);
		}
	}

	public static void enviarNotificacionAdmins(String mensaje, Integer adminDays){

		String strMails = LAT_GeneralConfig__c.getInstance('OPP_Verification_Email_Recipients').LAT_Value__c;
        System.debug('%%%%% strMails : '+strMails);
        String[] mails  = strMails.split(',');
        System.debug('%%%%% mails : '+mails);

		String htmlInicial = 'Estimado, <br><br>Encontramos que los siguientes registros están pendientes de aprobación desde hace '+ adminDays +' días:<br><br>';
		String subject = 'Hay registros pendientes de aprobación en CRM desde hace más de '+ adminDays +' días';
		String html = htmlInicial + mensaje + '<br><br>Por favor revíselos. <br><br>Muchas gracias,<br><br>Equipo CRM';
		html = html.replace('LAT_Opportunity__c', 'Pedido');
		html = html.replace('LAT_Case__c', 'Demanda');
		html = html.replace('LAT_Payment__c', 'Pagamento');
		html = html.replace('Account', 'Cliente');
		html = html.replace('LAT_Contract2__c', 'Contrato');

		sendEmailNotification(mails, html, subject);
	}

	public static void enviarNotificacionAdminsBR(String mensaje, Integer adminDays){

		String htmlInicial = Label.LAT_ApprovalSLA_003_BR;
		//String htmlInicial = 'Estimado XX_NOMBRE_XX, <br><br>Encontramos que los siguientes registros están pendientes de su aprobación desde hace XX_userQtyDays_XX días:<br><br>';
		String subject = Label.LAT_ApprovalSLA_002_BR;
		//String subject = 'Tiene registros pendientes de aprobación en CRM';

		String html = htmlInicial + mensaje;
		html = html.replace('XX_NOMBRE_XX', 'Administrador');
		html = html.replace('XX_userQtyDays_XX', String.valueOf(adminDays));
		html += Label.LAT_ApprovalSLA_001_BR;
		html = html.replace('LAT_Opportunity__c', 'Pedido');
		html = html.replace('LAT_Case__c', 'Demanda');
		html = html.replace('LAT_Payment__c', 'Pagamento');
		html = html.replace('Account', 'Cliente');
		html = html.replace('LAT_Contract2__c', 'Contrato');
		String strMails = LAT_GeneralConfig__c.getInstance('BR_ADMIN_Receipients').LAT_Value__c;
        System.debug('%%%%% strMails : '+strMails);
        String[] mails  = strMails.split(',');
        System.debug('%%%%% mails : '+mails);

		sendEmailNotification(mails, html, subject);
	}

	public static void enviarNotificacionAdminsAR(String mensaje, Integer adminDays){

		String strMails = LAT_GeneralConfig__c.getInstance('AR_ADMIN_Receipients').LAT_Value__c;
        System.debug('%%%%% strMails : '+strMails);
        String[] mails  = strMails.split(',');
        System.debug('%%%%% mails : '+mails);

		String htmlInicial = 'Estimado, <br><br>Encontramos que los siguientes registros están pendientes de aprobación desde hace '+ adminDays +' días:<br><br>';
		String subject = 'Hay registros pendientes de aprobación en CRM desde hace más de '+ adminDays +' días';
		String html = htmlInicial + mensaje + '<br><br>Por favor revíselos. <br><br>Muchas gracias,<br><br>Equipo CRM';
		html = html.replace('LAT_Opportunity__c', 'Pedido');
		html = html.replace('LAT_Case__c', 'Demanda');
		html = html.replace('LAT_Payment__c', 'Pagamento');
		html = html.replace('Account', 'Cliente');
		html = html.replace('LAT_Contract2__c', 'Contrato');

		sendEmailNotification(mails, html, subject);
	}

	public static void enviarNotificacionAdminsMX(String mensaje, Integer adminDays){

		String strMails = LAT_GeneralConfig__c.getInstance('MX_ADMIN_Receipients').LAT_Value__c;
        System.debug('%%%%% strMails : '+strMails);
        String[] mails  = strMails.split(',');
        System.debug('%%%%% mails : '+mails);

		String htmlInicial = 'Estimado, <br><br>Encontramos que los siguientes registros están pendientes de aprobación desde hace '+ adminDays +' días:<br><br>';
		String subject = 'Hay registros pendientes de aprobación en CRM desde hace más de '+ adminDays +' días';
		String html = htmlInicial + mensaje + '<br><br>Por favor revíselos. <br><br>Muchas gracias,<br><br>Equipo CRM';
		html = html.replace('LAT_Opportunity__c', 'Pedido');
		html = html.replace('LAT_Case__c', 'Demanda');
		html = html.replace('LAT_Payment__c', 'Pagamento');
		html = html.replace('Account', 'Cliente');
		html = html.replace('LAT_Contract2__c', 'Contrato');

		sendEmailNotification(mails, html, subject);
	}



	// Finish process
	global void finish(Database.BatchableContext BC) {
		System.debug('END APPROVALS SLA BATCH');
	}


	/*
	* getSoqlDate
	* Add days to Today and transform to string with valid format
	*/
	private static String getSoqlDate(Integer daysFromNow) {
	    return Datetime.now().addDays(daysFromNow).formatGmt('yyyy-MM-dd\'T\'HH:mm:ss');
	}




	/**
	* sendEmailNotification
	*/
	public static void sendEmailNotification(String[] mailAddress, String html, String subject){

  		
		Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
		email.setToAddresses( mailAddress );
		email.setSaveAsActivity(false);
		email.setHtmlBody(html);
		email.setBccSender(false);
		email.setSubject(subject);
		email.setUseSignature(false);
		if(!Test.isRunningTest()) Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
	}

	public static Map<Id, User> getUserInfo(Map<String, String> mapUsers){
		return new Map<Id, User>([SELECT Id, Email, Name, Manager.Email, LanguageLocaleKey FROM User WHERE Id IN :mapUsers.keySet()]);
	}

}