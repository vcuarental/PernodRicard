/***************************************************************************************************************************
 * Name:		ASI_CRM_SG_Batch_ApprovalReminder
 * Description:	Trigger class for ASI_TH_CRM_Contract__c object
 *
 * Version History
 * Date				Developer				Comments
 * ---------------	--------------------	--------------------------------------------------------------------------------
 * 2017-11-16		Jeffrey Cheung          Created				
 ****************************************************************************************************************************/
global class ASI_CRM_SG_Batch_ApprovalReminder implements Database.Batchable<sObject>, Database.Stateful {

    private static final String SUBJECT = 'Please review Pending approvals - ';
    private static final String CONTENT = 'Dear approver, please review the following records.';
    private static final String THANKS = 'Thanks';
    private static final String LINE_BREAK = '<br />';
    private static final String ANCHOR_START = '<a href="';
    private static final String ANCHOR_END = '"> ';
    private static final String ANCHOR_CLOSING_TAG = '</a>';
    private static final String BASE_URL = URL.getSalesforceBaseUrl().toExternalForm() + '/';

    private Datetime dateTimeNow =  System.now();
	private map<string, List<ProcessInstanceHistory>> map_user_items = new map<string, List<ProcessInstanceHistory>>();
	private map<string, ProcessInstance> map_process = new map<string, ProcessInstance>();
	private map<string, string> userIdToEmail = new map<string, string>();
	
	private string objectName;

    private Integer inputDay = 3;
    
	private class objectWrapper{
		private string objectAPI {get; set;}
		private list<string> list_recordtype {get; set;}
		private string displayName {get; set;}
		
		private objectWrapper(string objectAPI, list<string> list_recordtype, string displayName){
			this.objectAPI = objectAPI;
			this.list_recordtype = list_recordtype;
			this.displayName = displayName;
		}
	}
	
	private map<string, objectWrapper> map_object = new map<string, objectWrapper>{
		'Contract' => new objectWrapper(
							'ASI_TH_CRM_Contract__c',
							new List<string>{'ASI_CRM_SG_Proposal', 'ASI_CRM_SG_Contract', 'ASI_CRM_SG_Contract_Read_Only', 'ASI_CRM_SG_Proposal_Read_Only'},
							'Proposal / Contract'
						),
		'Payment Request' => new objectWrapper(
							'ASI_TH_CRM_PaymentRequest__c',
							new List<string>{'ASI_CRM_SG_Payment_Request'},
							'Payment Request'
						),
		'FOC Request' => new objectWrapper(
							'ASI_FOC_Free_Goods_Request__c',
							new List<string>{'ASI_CRM_SG_FOC', 'ASI_CRM_SG_POSM'},
							'FOC Request'
						)
	};
	
    public ASI_CRM_SG_Batch_ApprovalReminder(String objectName){
        this.objectName = objectName;
    }
    
    public ASI_CRM_SG_Batch_ApprovalReminder(String objectName, Integer inputDay){
        this.inputDay = inputDay;
        this.objectName = objectName;
    }
    
    // Getting the records matching the criteria.
    global Database.QueryLocator start(Database.BatchableContext contextInstance) {
        objectWrapper w = map_object.get(objectName);
		string objectAPI = w.objectAPI;
		List<string> list_recordtype = w.list_recordtype;
		
		String query = 'Select Id, TargetObjectId, TargetObject.Name, isDeleted, Status, '+
				'	( '+
				'		Select Id, ProcessInstanceId, ActorId, Actor.Name, StepStatus, Comments, Createddate '+
				'		From StepsAndWorkItems '+
				'		Where  '+
				'			StepStatus = \'Pending\'  and '+
				'			isDeleted = false  '+
				'		Order By  '+
				'			Createddate Desc '+
				'	) '+
				'From ProcessInstance '+
				'Where '+
				'TargetObject.type = :objectAPI and ' +
				'TargetObject.RecordType.DeveloperName in :list_recordtype and ' +
				'	isDeleted = false and '+
				'	Status = \'Pending\' '+
				'Order By  '+
				'	Createddate Desc ';
		return Database.getQueryLocator(query);
    }
    
    // Processing records and generating email body.
    global void execute(Database.BatchableContext contextInstance, list<Sobject> pLstContracts) {
    
        List<ProcessInstance> list_process = (List<ProcessInstance>) pLstContracts;
		List<string> actorIds = new List<string>();
		
		for (ProcessInstance p : list_process){
			for (ProcessInstanceHistory s : p.StepsAndWorkItems){
			    Integer days = Math.abs(dateTimeNow.Date().daysBetween(s.Createddate.Date()));
				if (days == inputDay || days == 3 || days == 7 || days >= 14 ){
					List<ProcessInstanceHistory> list_s = map_user_items.containsKey(s.ActorId) ? map_user_items.get(s.ActorId) : new List<ProcessInstanceHistory>();
					list_s.add(s);
					map_user_items.put(s.ActorId, list_s);
					map_process.put(s.ProcessInstanceId, p);
					actorIds.add(s.ActorId);
				}
			}
		}
		
		for (user u : [select id, email from user where id in :actorIds]){
			userIdToEmail.put(u.id, u.email);
		}

	}
	
    // Sending out notification emails.
    global void finish(Database.BatchableContext contextInstance) {
		if( map_user_items.isEmpty() ) {
		    return;
		}

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
		try {
			for(string userId : map_user_items.keySet()) {
				if (userIdToEmail.containsKey(userId)){
					Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
				
					email.setToAddresses( new List<String> { userIdToEmail.get(userId)});

					email.setSubject(SUBJECT + map_object.get(objectName).displayName);

					String emailBody = '';
					for(ProcessInstanceHistory s : map_user_items.get(userId)){
						ProcessInstance p = map_process.get(s.ProcessInstanceId);
						string recordLink = BASE_URL + p.TargetObjectId;
						string recordName = p.TargetObject.name;
						emailBody += ANCHOR_START + recordLink + ANCHOR_END + recordName + ANCHOR_CLOSING_TAG + LINE_BREAK;
					}
					
					email.setHtmlBody(
						CONTENT + LINE_BREAK + emailBody + THANKS
					);
                    
                    emails.add(email);
				}
			}

			Messaging.sendEmail(emails);
		} catch(Exception exceptionInstance) {
			System.debug('------ exceptionInstance ------ : ' + exceptionInstance.getMessage());

			// TODO : Nothing
		}
    }
}