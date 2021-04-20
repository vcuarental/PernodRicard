global without sharing class ASI_MFM_KR_SubBrand_Sync_Batch implements Database.AllowsCallouts, Database.Batchable<sObject>, Database.Stateful
{   
    //private Set<ID> ids;    
	private String log;
	private Datetime LastSyncDate;
    private String ConcurReturnID;
    private String ListID;
    Map<string, string> CodetoItem = new Map<string, string>();
    private Set<ID> planIDs;
    private ASI_MFM_KR_Concur_Sync_Setting__c api;

    public ASI_MFM_KR_SubBrand_Sync_Batch(Set<ID> pIDs)
    {
        planIDs = pIDs;
    }

    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        this.log = '';
        api = ASI_MFM_KR_Concur_Sync_Setting__c.getInstance();

	    return Database.getQueryLocator([
			Select ID, Name, ASI_MFM_Plan__r.ASI_MFM_Promotion_Code__c
			, ASI_MFM_Sub_Brand_Code_Only__c
            , ASI_MFM_Sub_Brand_Code_Name__c
            , ASI_CRM_KR_ListItemID__c
            , ASI_MFM_KR_Update_ListItemID__c
            , LastModifiedDate
			From ASI_MFM_Plan_Line_Item__c 
            WHERE (RecordType.DeveloperName= 'ASI_MFM_KR_Plan_Line_Item' )
            AND ASI_MFM_Plan__c in :planIDs
            AND ASI_CRM_KR_ListItemID__c = null
			AND LastModifiedDate > :api.ASI_MFM_Sync_Date__c
            order by ID asc
		]);
    }
    
    /// need to skip
    global void execute(Database.BatchableContext BC, List<ASI_MFM_Plan_Line_Item__c> scope)
    {
		String log = '';
        ASI_MFM_KR_ConcurAPICls concurapi = new ASI_MFM_KR_ConcurAPICls();
        ConcurReturnID= '';
        ListID = api.ASI_MFM_Sub_Brand_List_ID__c;
        List<ASI_MFM_Plan_Line_Item__c> updateList = new List<ASI_MFM_Plan_Line_Item__c>();
        
		for (ASI_MFM_Plan_Line_Item__c p : scope)
		{
            concurapi.errorMessage = '';
            String key = p.ASI_MFM_Plan__r.ASI_MFM_Promotion_Code__c + '' + p.ASI_MFM_Sub_Brand_Code_Only__c;
            //update to sf if already exist ( no need to create in concur)
            if (CodetoItem.containsKey(key))
            {
                p.ASI_CRM_KR_ListItemID__c  = CodetoItem.get(key);
                p.ASI_MFM_KR_Update_ListItemID__c = true;
                updateList.add(p);
            }
            else
            {
                ConcurReturnID = concurapi.POSTItemListXML('<?xml version="1.0"?><ListItem><Level1Code >'+ p.ASI_MFM_Plan__r.ASI_MFM_Promotion_Code__c +'</Level1Code><Level2Code >'+ p.ASI_MFM_Sub_Brand_Code_Only__c +'</Level2Code><ListID>' + ListID + '</ListID><Name>' + p.ASI_MFM_Sub_Brand_Code_Name__c + '</Name></ListItem>');
            	CodetoItem.put(key, ConcurReturnID);
                p.ASI_CRM_KR_ListItemID__c  = ConcurReturnID;
                p.ASI_MFM_KR_Update_ListItemID__c = true;
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
            emailTo('Salesforce Support', 'Error in Sub-Brand batch process!', Test.isRunningTest() ? 'Testing' : this.log);
        }
        
        api.ASI_MFM_Sync_Date__c = System.now();
        upsert api ASI_MFM_KR_Concur_Sync_Setting__c.Id;
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