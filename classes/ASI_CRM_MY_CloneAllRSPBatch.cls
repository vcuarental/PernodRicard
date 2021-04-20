global class ASI_CRM_MY_CloneAllRSPBatch implements Database.Batchable<sObject>, Database.Stateful
{   
    public Id customerRecTypeID = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_MY_Outlet');
    public Id customerRecTypeID2 = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_MY_Potential_Outlet');
    public Id headerRecTypeID = Global_RecordTypeCache.getRtId('ASI_CRM_RSPHeader__cASI_CRM_MY_RSPHeader');
    public Id itemRecTypeID = Global_RecordTypeCache.getRtId('ASI_TH_CRM_RSP__cASI_CRM_MY_RSP');
    public String log;
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        string query = 'select Id, OwnerId ' +
            'from ASI_CRM_AccountsAdditionalField__c ' +
            'where RecordTypeId in (\'' + customerRecTypeID + '\', \'' + customerRecTypeID2 + '\') and ASI_CRM_CN_Inactive_Flag__c = false';
        system.debug('query: ' + query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<ASI_CRM_AccountsAdditionalField__c> scope)
    {
        try
        {
            for (ASI_CRM_AccountsAdditionalField__c s : scope)
            {
                for (ASI_CRM_RSPHeader__c header : [
                    select Id, ASI_CRM_Remark__c, ASI_CRM_Date__c
                    from ASI_CRM_RSPHeader__c
                    where ASI_CRM_Customer__c = :s.Id
                    order by ASI_CRM_Date__c desc limit 1
                ])
                {
                    string checkDate = header.ASI_CRM_Date__c.year() + '-' + header.ASI_CRM_Date__c.month();
                    if (checkDate == system.now().format('YYYY-MM'))
                    {
                        continue;
                    }
                    ASI_CRM_RSPHeader__c cRSPHeader = new ASI_CRM_RSPHeader__c(
                    ASI_CRM_Customer__c = s.Id,
                    ASI_CRM_Date__c = system.today(),
                    ASI_CRM_Remark__c = header.ASI_CRM_Remark__c,
                    RecordTypeId = headerRecTypeID
                    );
                    insert cRSPHeader;
    
                    List<ASI_TH_CRM_RSP__c> newRSPList = new List<ASI_TH_CRM_RSP__c>();
                    List<ASI_TH_CRM_RSP__c> rspList = [select ASI_TH_CRM_Sub_Brand__c, ASI_TH_CRM_Date__c, 
                                                        ASI_CRM_SKU__c, ASI_CRM_Price_to_Consumer__c, ASI_CRM_MY_Facing__c, ASI_CRM_MY_PriceDate__c
                                                       from ASI_TH_CRM_RSP__c where ASI_CRM_RSPHeader__c = :header.Id];

                    for (ASI_TH_CRM_RSP__c rsp : rspList)
                    {
                        ASI_TH_CRM_RSP__c cRSP = new ASI_TH_CRM_RSP__c(
                            ASI_CRM_RSPHeader__c = cRSPHeader.Id,
                            ASI_TH_CRM_Sub_Brand__c = rsp.ASI_TH_CRM_Sub_Brand__c,
                            ASI_TH_CRM_Date__c = cRSPHeader.ASI_CRM_Date__c,
                            ASI_CRM_SKU__c = rsp.ASI_CRM_SKU__c,
                            ASI_CRM_Price_to_Consumer__c = rsp.ASI_CRM_Price_to_Consumer__c,
                            ASI_CRM_MY_Facing__c = rsp.ASI_CRM_MY_Facing__c,
                            ASI_CRM_MY_PriceDate__c = rsp.ASI_CRM_MY_PriceDate__c,
                            RecordTypeId = itemRecTypeID,
                            OwnerId = s.OwnerId
                        );
                        newRSPList.add(cRSP);
                    }
                    
                    insert(newRSPList);
                }
            }

            Database.SaveResult[] srList = database.update(scope, false);
            for (Integer i = 0; i < srList.size(); i++)
            {
                if (!srList[i].isSuccess())
                {
                    this.log += '\n Error in scope: ' + scope[i].name + '. Error msg=' + srList[i].getErrors()[0].getMessage();
                }
            }
        }
        catch (exception e)
        {
            System.debug(e.getMessage());
        }
    }
    
    global void finish(Database.BatchableContext BC)
    {
        if (!String.isEmpty(this.log))
        {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setTargetObjectId(UserInfo.getUserId());
            email.setSaveAsActivity(false);
            email.setSenderDisplayName('Salesforce Support');
            email.setSubject('Error in clone all MY RSP Header batch process!');
            email.setPlainTextBody(this.log);    
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
        }
    }
}