global class LAT_HandleOverduePromotinalActions implements Schedulable, Database.Stateful {

	public List<String> paIds;
	public String type;

	// There are 2 types 'Start' and 'End'. They will indicate if the email to be sent 
	// is for the start of the promotional actio or the end
	global LAT_HandleOverduePromotinalActions (List<String> paIds, String type) {
		this.paIds = paIds;
		this.type = type;
	}

	@InvocableMethod
    public static void handleOverdues(List<String> ids) {
    	system.debug('ids------->' + ids);
    	if (!ids.isEmpty()) {
	    	Integer dueDaysStartOverdue = LAT_PromotionalActionHandler.getSLANumberOfDays('AP_SLA_STARTOVERDUE');
	    	Integer dueDaysEndOverdue = LAT_PromotionalActionHandler.getSLANumberOfDays('AP_SLA_ENDOVERDUE');
	    	Date currentDay = Date.today();

	    	List<ConnectApi.BatchInput> posts = new List<ConnectApi.BatchInput>();
		    String groupId = '';
		    String[] groups = LAT_GeneralConfigDao.getValueAsStringArray('AP_CHATTER_GROUP', ' ');
		    if(groups != null && groups.size()>0)groupId = groups[0];


	    	List<LAT_PromotionalAction__c> promotionalActions = [SELECT id, Name, RecordTypeId, RecordType.DeveloperName, 
	    																OwnerId, Owner.Name, LAT_BusinessCycle__c,
	    																LAT_StartDate__c, LAT_EndDate__c, LAT_Description__c, 
	    																LAT_Booster__c, LAT_Brand__c, LAT_Mecanica__c, 
	    																LAT_CancelationReason__c, LAT_PromotionalPack__c, 
	    																LAT_Quantidade_de_Clientes__c, LAT_status__c
	    															FROM LAT_PromotionalAction__c WHERE id =: ids];
	    	
	    	
	    	for (LAT_PromotionalAction__c pa: promotionalActions) {
	    		if (pa.LAT_status__c != 'Ação cancelada' ) {
		    		if (pa.LAT_status__c != 'Ação iniciada' && pa.LAT_status__c != 'Ação Finalizada' 
		    			&& currentDay.daysBetween(pa.LAT_StartDate__c) <= 0 && currentDay.daysBetween(pa.LAT_EndDate__c) > 0) {
		    			LAT_HandleOverduePromotinalActions overdueNotification = new LAT_HandleOverduePromotinalActions(ids, 'Start');
		    			Date notificationDay = LAT_ProcessesTaks.AddBusinessDays(pa.LAT_StartDate__c,dueDaysStartOverdue);
						
						String sch = '0 0 20 ' + notificationDay.day() + ' ' + notificationDay.month() + ' ? ' + notificationDay.year();
						String jobID = system.schedule('LAT_APHandleStartOverdue ' + pa.Name, sch, overdueNotification);

						String message = 'Ação Promocional ' + pa.Name + ' com Data de Início vencida. Favor iniciar a mesma.'; 
		    			
						ConnectApi.BatchInput post = LAT_ProcessesNotifications.generateChatterPost(groupId,new List<String>{pa.OwnerId}, message, pa.id);
        				if(post != null)posts.add(post);
      
		    		} else if (pa.LAT_status__c != 'Ação Finalizada' && currentDay.daysBetween(pa.LAT_EndDate__c) <= 0) {
		    			LAT_HandleOverduePromotinalActions overdueNotification = new LAT_HandleOverduePromotinalActions(ids, 'End');
		    			Date notificationDay = LAT_ProcessesTaks.AddBusinessDays(pa.LAT_EndDate__c,dueDaysEndOverdue);
						String sch = '0 0 20 ' + notificationDay.day() + ' ' + notificationDay.month() + ' ? ' + notificationDay.year();
						String jobID = system.schedule('LAT_APHandleEndOverdue ' + pa.Name, sch, overdueNotification);

						String message = 'Ação Promocional ' + pa.Name + ' com Data de Término vencida. Favor finalizar a mesma.'; 
		    			
						ConnectApi.BatchInput post = LAT_ProcessesNotifications.generateChatterPost(groupId,new List<String>{pa.OwnerId}, message, pa.id);
        				if(post != null)posts.add(post);
      
		    		}
		    	}
	    	}

	    	if (!posts.isEmpty()) {
	    		LAT_ProcessesNotifications.post(posts);
	    	}
	    }
    }

	global void execute(SchedulableContext sc) {
		List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
      	List<ConnectApi.BatchInput> posts = new List<ConnectApi.BatchInput>();
	    String groupId = '';
	    String[] groups = LAT_GeneralConfigDao.getValueAsStringArray('AP_CHATTER_GROUP', ' ');
	    if(groups != null && groups.size()>0)groupId = groups[0];

      	List<LAT_PromotionalAction__c> promotionalActions = [SELECT id, Name, RecordTypeId, RecordType.DeveloperName, 
	    																OwnerId, Owner.Name, LAT_status__c, LAT_Mecanica__c,
	    																LAT_StartDate__c, LAT_EndDate__c, LAT_BusinessCycle__c,
	    																LAT_Description__c, LAT_Booster__c, LAT_Brand__c, 
	    																LAT_CancelationReason__c, LAT_PromotionalPack__c, 
	    																LAT_Quantidade_de_Clientes__c
	    															FROM LAT_PromotionalAction__c WHERE id =: this.paIds];


	    if (!promotionalActions.isEmpty()) {
	    	List<String> ids = new List<String>();
	    	for (LAT_PromotionalAction__c pa: promotionalActions) {
	    		ids.add(pa.OwnerId);
	    	}
	    	Map<id, User> managerMap = new Map<id, User>([Select id, ManagerId FROM User WHERE id IN: ids]); 
	    	if (this.type == 'Start') {
	    		for (LAT_PromotionalAction__c pa: promotionalActions) {
	    			if (pa.LAT_status__c == 'Ação aprovada' || pa.LAT_status__c == 'Ação registrada no sistema'
	    				|| pa.LAT_status__c == 'Ação encaminhada a aprovação') {
		    			String subject = 'Ação Promocional ' + pa.Name + ' com Data de Início vencida';
		  				String message = 'Ação Promocional ' + pa.Name + ' com Data de Início vencida. Favor iniciar a mesma.'; 
		    			
		    			ConnectApi.BatchInput post = LAT_ProcessesNotifications.generateChatterPost(groupId,new List<String>{pa.OwnerId, managerMap.get(pa.OwnerId).ManagerId}, message, pa.id);
        				if(post != null)posts.add(post);
      
		    			//emailsToSend.add(sendEmailtoManager(subject, message, new List<String>{managerMap.get(pa.OwnerId).Manager.Email}));
	    			}
	    		}
	    	} else if (this.type == 'End') {
	    		for (LAT_PromotionalAction__c pa: promotionalActions) {
	    			if (pa.LAT_status__c == 'Ação iniciada') {
		    			String subject = 'Ação Promocional ' + pa.Name + ' com Data de Término vencida';
		  				String message = 'Ação Promocional ' + pa.Name + ' com Data de Término	 vencida. Favor finalizar a mesma.'; 
		    			
		  				ConnectApi.BatchInput post = LAT_ProcessesNotifications.generateChatterPost(groupId,new List<String>{pa.OwnerId, managerMap.get(pa.OwnerId).ManagerId}, message, pa.id);
        				if(post != null)posts.add(post);

		    			//emailsToSend.add(sendEmailtoManager(subject, message, new List<String>{ManagerMap.get(pa.OwnerId).Manager.Email}));
	    			}
	    		}
	    	}

	    	if (!posts.isEmpty()) {
	    		LAT_ProcessesNotifications.post(posts);
	    	}
	    }
	    	
	}

	public static Messaging.SingleEmailMessage sendEmailtoManager(String subject, String message, List<String> toAddress) {
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		mail.setToAddresses(toAddress);
		mail.setSubject(subject);
		mail.setPlainTextBody(message);
		return mail;
   }
}