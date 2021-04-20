global without sharing class ASI_MFM_KR_Plan_Sync_Batch implements Database.AllowsCallouts, Database.Batchable<sObject>, Database.Stateful
{   
    //private Set<ID> ids;    
	private String log;
	private Datetime LastSyncDate;
    private String ConcurReturnID;
	private String ListID;
	private Set<ID> planIDs = new Set<ID>();
    private ASI_MFM_KR_Concur_Sync_Setting__c api;

    global Database.QueryLocator start(Database.BatchableContext BC)
    {
		this.log = '';
		api = ASI_MFM_KR_Concur_Sync_Setting__c.getInstance();

	    return Database.getQueryLocator([
			Select ID, Name, ASI_MFM_Promotion_Code__c 
			, ASI_CRM_KR_ListItemID__c
			, LastModifiedDate			
			From ASI_MFM_Plan__c 
			WHERE (RecordType.DeveloperName = 'ASI_MFM_KR_Plan' OR RecordType.DeveloperName = 'ASI_MFM_KR_Plan_Read_Only')
			AND (ASI_MFM_Status__c ='Approved')
			AND ASI_CRM_KR_ListItemID__c = null
            AND LastModifiedDate > :api.ASI_MFM_Sync_Date__c
			order by ID asc
		]);
    }
    
    global void execute(Database.BatchableContext BC, List<ASI_MFM_Plan__c> scope)
    {
		String log = '';
        ASI_MFM_KR_ConcurAPICls concurapi = new ASI_MFM_KR_ConcurAPICls();
		ListID = api.ASI_MFM_Plan_List_ID__c;
		List<ASI_MFM_Plan__c> updateList = new List<ASI_MFM_Plan__c>();
		        
		for (ASI_MFM_Plan__c p : scope)
		{
			concurapi.errorMessage = '';
			planIDs.add(p.ID);
			
			ConcurReturnID = concurapi.POSTItemListXML('<?xml version="1.0"?><ListItem><Level1Code >'+ p.ASI_MFM_Promotion_Code__c +'</Level1Code><ListID>' + ListID + '</ListID><Name>' + p.Name + '</Name></ListItem>');
			
			if (ConcurReturnID != null)
            {
				p.ASI_CRM_KR_ListItemID__c  = ConcurReturnID;
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
			emailTo('Salesforce Support', 'Error in Promo Code batch process!', Test.isRunningTest() ? 'Testing' : this.log);
		}     

        //Calling next batch job
		try 
		{
			ASI_MFM_KR_SubBrand_Sync_Batch batch = new ASI_MFM_KR_SubBrand_Sync_Batch(planIDs);
			ID batchID = Database.executeBatch(batch, 60);
		}
		catch (Exception e)
		{
			emailTo('Salesforce Support', 'Error in starting Sub-Brand batch process!', e.getMessage());
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