global without sharing class ASI_MFM_KR_WS_Sync_Batch implements Database.AllowsCallouts, Database.Batchable<sObject>, Database.Stateful
{   
    //private Set<ID> ids;    
	private String log;
	private Datetime LastSyncDate;
    private String ConcurReturnID;
    private String ListID;
    private ASI_MFM_KR_Concur_Sync_Setting__c api;

    global Database.QueryLocator start(Database.BatchableContext BC)
    {
		this.log = '';
		api = ASI_MFM_KR_Concur_Sync_Setting__c.getInstance();
		System.debug('Date: ' + api.ASI_MFM_Sync_Date__c);

		return Database.getQueryLocator([
			Select ID, ASI_CRM_MY_CustomerCode__c 
			, Name ,ASI_CRM_CN_Address__c
			, ASI_CRM_CN_Inactive_Flag__c, LastModifiedDate 
			, ASI_CRM_KR_WS_ListItemID__c, ASI_CRM_KR_Venue_ListItemID__c
			From ASI_CRM_AccountsAdditionalField__c 
			WHERE (RecordType.DeveloperName = 'ASI_CRM_KR_Wholesaler' OR (RecordType.DeveloperName = 'ASI_CRM_KR_Venue' AND (NOT ASI_CRM_KR_Salesman__c like 'MD%')))
			AND LastModifiedDate > :api.ASI_MFM_Sync_Date__c
			order by ID asc
		]);
    }
    
    global void execute(Database.BatchableContext BC, List<ASI_CRM_AccountsAdditionalField__c> scope)
    {
		String log = '';
        ASI_MFM_KR_ConcurAPICls concurapi = new ASI_MFM_KR_ConcurAPICls();
		ListID = api.ASI_MFM_Wholesaler_List_ID__c;
		List<ASI_CRM_AccountsAdditionalField__c> updateList = new List<ASI_CRM_AccountsAdditionalField__c>();	
		        
		for (ASI_CRM_AccountsAdditionalField__c p : scope)
		{
			concurapi.errorMessage = '';

			if (p.ASI_CRM_CN_Inactive_Flag__c == false)
			{			
				if (p.ASI_CRM_KR_WS_ListItemID__c == null)
				{
                    ConcurReturnID = concurapi.POSTItemListXML('<?xml version="1.0"?><ListItem><Level1Code >'+ p.ASI_CRM_MY_CustomerCode__c +'</Level1Code><ListID>' + ListID + '</ListID><Name>'+p.Name+'_'+p.ASI_CRM_CN_Address__c +'</Name></ListItem>');
                    if (ConcurReturnID != null)
                    {
                        p.ASI_CRM_KR_WS_ListItemID__c  = ConcurReturnID;
                    }
				}
				else
				{
                    concurapi.PUTItemListXML(p.ASI_CRM_KR_WS_ListItemID__c, '<?xml version="1.0"?><ListItem><Level1Code >'+ p.ASI_CRM_MY_CustomerCode__c +'</Level1Code><ListID>' + ListID + '</ListID><Name>'+p.Name+'_'+p.ASI_CRM_CN_Address__c +'</Name></ListItem>');
				}

				updateList.add(p);
			}
			else if ((p.ASI_CRM_CN_Inactive_Flag__c == true) && (p.ASI_CRM_KR_WS_ListItemID__c != null))
			{
                
                concurapi.DeleteItemListXML(p.ASI_CRM_KR_WS_ListItemID__c, ListID); 
				p.ASI_CRM_KR_WS_ListItemID__c = null;
				updateList.add(p);
			}

			if (concurapi.errorMessage != '')
			{
				log += (concurapi.errorMessage + '\n');
			}
		}
		
		if (log != '')
		{
			this.log += log;
		}
		else
		{
			if (updateList.size() > 0)
			{
				update updateList;
			}
		}
    }

    global void finish(Database.BatchableContext BC)
    {
        if (this.log != '' || Test.isRunningTest())
		{
			emailTo('Salesforce Support', 'Error in Wholesaler batch process!', Test.isRunningTest() ? 'Testing' : this.log);
		}    

		//Calling next batch job
		try 
		{
			ASI_MFM_KR_Venue_Sync_Batch batch = new ASI_MFM_KR_Venue_Sync_Batch();
			ID batchID = Database.executeBatch(batch, 60);
		}
		catch (Exception e)
		{
			emailTo('Salesforce Support', 'Error in starting Venue batch process!', e.getMessage());
		}
	}

	public void emailTo(String displayName, String subject, String body)
	{
		Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
		email.setTargetObjectId(UserInfo.getUserId());
		email.setSaveAsActivity(false);
		email.setSenderDisplayName(displayName);
		email.setSubject(subject);
		email.setPlainTextBody(body);
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
	}
}