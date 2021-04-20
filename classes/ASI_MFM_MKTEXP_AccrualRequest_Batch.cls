global class ASI_MFM_MKTEXP_AccrualRequest_Batch implements Database.Batchable<sObject>, Database.Stateful
{
    private Set<ID> ids;
    public String log;

    public static ID poItemHKRTID = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_HK_PO_Line_Item');
    public static ID poItemRMRTID = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_RM_PO_Line_Item');
    public static ID poItemTRRTID = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_TR_PO_Line_Item');
    public static ID accrualItemRTID = Global_RecordTypeCache.getRtId('ASI_MFM_Accrual_Request_Item__cASI_MFM_MKTEXP_Accural_Request_Item');

    public ASI_MFM_MKTEXP_AccrualRequest_Batch(Set<ID> ids)
    {
        this.ids = ids;
    }

    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String query = 'select ID, ASI_MFM_Status__c, ASI_MFM_Company_Code__c, ASI_MFM_G_L_Date__c'
                        + ' from ASI_MFM_Accrual_Request__c'
                        + ' where ID in :ids'
                        + ' order by ID asc';
        System.debug('query: ' + query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<ASI_MFM_Accrual_Request__c> scope)
    {
        try
        {
            Set<String> custCode = new Set<String>{
                '00326',
                '00329',
                '00331',
                '00381',
                '00393',
                '00394'
            };

            Set<ID> rtIDs = new Set<ID>{
                poItemHKRTID,
                poItemRMRTID,
                poItemTRRTID
            };

            Date startDate = System.today();
            Date endDate;
            for (ASI_MFM_Accrual_Request__c ar : scope)
            {
                if (ar.ASI_MFM_G_L_Date__c < startDate)
                {
                    startDate = ar.ASI_MFM_G_L_Date__c;
                }

                if (endDate == null || endDate < ar.ASI_MFM_G_L_Date__c)
                {
                    endDate = ar.ASI_MFM_G_L_Date__c;
                }
            }

            if (startDate.month() > 6)
            {
                startDate = Date.newInstance(startDate.year(), 7, 1);    
            }
            else
            {
                startDate = Date.newInstance(startDate.year() - 1, 7, 1);
            }
        
            List<ASI_MFM_Setting__c> custSetting = [select ASI_MFM_MKTEXP_Cutover__c from ASI_MFM_Setting__c];

            List<ASI_MFM_PO_Line_Item__c> poLineItemlist;
            
            if (custSetting != null && custSetting.size() > 0 && custSetting[0].ASI_MFM_MKTEXP_Cutover__c == true)
            {
                poLineItemlist = [select ASI_MFM_PO__c, ID, ASI_MFM_A_C_Code__c, ASI_MFM_Accrual_Balance_Base_Currency__c, ASI_MFM_Accrual_Balance_PO_Currency__c, ASI_MFM_AP_Code__c, ASI_MFM_Currency__c, ASI_MFM_Customer_Name__c, ASI_MFM_Exchange_Rate__c, ASI_MFM_G_L_Date__c, ASI_MFM_Sub_brand_Code__c, ASI_MFM_PO__r.ASI_MFM_Supplier_Name__c, ASI_MFM_BU_Code__r.ASI_MFM_L3__c, ASI_MFM_Accrual_Balance_Base_Verified__c, ASI_MFM_Accrual_Balance_PO_Verified__c from ASI_MFM_PO_Line_Item__c where RecordTypeID in :rtIDs and ASI_MFM_BU_Code__r.ASI_MFM_L3__c in :custCode and ASI_MFM_G_L_Date__c >= :startDate and ASI_MFM_G_L_Date__c <= :endDate and ASI_MFM_Accrual_Balance_Base_Verified__c != 0 and (ASI_MFM_PO__r.ASI_MFM_Status__c = 'Final' or ASI_MFM_PO__r.ASI_MFM_Status__c = 'Partial Paid') and ASI_MFM_PO__r.ASI_MFM_AP_AD__c = 'A&P' order by ASI_MFM_PO__c, ID];
            }
            else
            {
                poLineItemlist = [select
                    ASI_MFM_PO__c, ID,
                    ASI_MFM_A_C_Code__c, ASI_MFM_Accrual_Balance_Base_Currency__c,
                    ASI_MFM_Accrual_Balance_PO_Currency__c, ASI_MFM_AP_Code__c,
                    ASI_MFM_Currency__c, ASI_MFM_Customer_Name__c,
                    ASI_MFM_Exchange_Rate__c, ASI_MFM_G_L_Date__c,
                    ASI_MFM_Sub_brand_Code__c, ASI_MFM_PO__r.ASI_MFM_Supplier_Name__c,
                    ASI_MFM_BU_Code__r.ASI_MFM_L3__c,
                    ASI_MFM_Accrual_Balance_Base_Verified__c, ASI_MFM_Accrual_Balance_PO_Verified__c 
                    from ASI_MFM_PO_Line_Item__c
                    where
                    RecordTypeID in :rtIDs
                    and ASI_MFM_BU_Code__r.ASI_MFM_L3__c in :custCode
                    and ASI_MFM_G_L_Date__c >= :startDate
                    and ASI_MFM_G_L_Date__c <= :endDate
                    and ASI_MFM_Accrual_Balance_Base_Verified__c != 0
                    and (ASI_MFM_PO__r.ASI_MFM_Status__c = 'Final' or ASI_MFM_PO__r.ASI_MFM_Status__c = 'Partial Paid' or ASI_MFM_PO__r.ASI_MFM_Status__c = 'Complete')
                    and ASI_MFM_PO__r.ASI_MFM_AP_AD__c = 'A&P'
                    order by ASI_MFM_PO__c, ID
                ];
            }

            List<ASI_MFM_Accrual_Request_Item__c> insertAccrualItem = new List<ASI_MFM_Accrual_Request_Item__c>();

            for (ASI_MFM_Accrual_Request__c ar : scope)
            {
                Date fiscalStart;
                if (ar.ASI_MFM_G_L_Date__c.month() > 6)
                {
                    fiscalStart = Date.newInstance(ar.ASI_MFM_G_L_Date__c.year(), 7, 1);    
                }
                else
                {
                    fiscalStart = Date.newInstance(ar.ASI_MFM_G_L_Date__c.year() - 1, 7, 1);
                }

                Integer count = 0;
                for (ASI_MFM_PO_Line_Item__c poi: poLineItemlist)
                {
                    System.Debug('poLineItem: ' + ar.ASI_MFM_Company_Code__c + ' : ' + poi.ASI_MFM_G_L_Date__c + ', ' + ar.ASI_MFM_G_L_Date__c + ' : ' + poi.ASI_MFM_BU_Code__r.ASI_MFM_L3__c);
                    if (((ar.ASI_MFM_Company_Code__c != 'ALL' && poi.ASI_MFM_BU_Code__r.ASI_MFM_L3__c == ar.ASI_MFM_Company_Code__c)
                            || (ar.ASI_MFM_Company_Code__c == 'ALL'))
                        && poi.ASI_MFM_G_L_Date__c >= fiscalStart
                        && poi.ASI_MFM_G_L_Date__c <= ar.ASI_MFM_G_L_Date__c)
                    {
                        ASI_MFM_Accrual_Request_Item__c newItem = new ASI_MFM_Accrual_Request_Item__c(
                            RecordTypeID = accrualItemRTID,
                            ASI_MFM_Accrual_Request__c = ar.ID,
                            ASI_MFM_A_C_Code__c = poi.ASI_MFM_A_C_Code__c,
                            ASI_MFM_Accrual_Balance_Base_Currency__c = poi.ASI_MFM_Accrual_Balance_Base_Verified__c,
                            ASI_MFM_Accrual_Balance_Local_Currency__c = poi.ASI_MFM_Accrual_Balance_PO_Verified__c,
                            ASI_MFM_AP_Code__c = poi.ASI_MFM_AP_Code__c,
                            ASI_MFM_Currency__c = poi.ASI_MFM_Currency__c,
                            ASI_MFM_Customer__c = poi.ASI_MFM_Customer_Name__c,
                            ASI_MFM_Exchange_Rate__c = poi.ASI_MFM_Exchange_Rate__c,
                            ASI_MFM_G_L_Date__c = poi.ASI_MFM_G_L_Date__c,
                            ASI_MFM_PO__c = poi.ASI_MFM_PO__c,
                            ASI_MFM_PO_Line_Item__c = poi.ID,
                            ASI_MFM_Sub_brand__c = poi.ASI_MFM_Sub_brand_Code__c,
                            ASI_MFM_Supplier__c = poi.ASI_MFM_PO__r.ASI_MFM_Supplier_Name__c,
                            ASI_MFM_Type__c = 'Accrual Interface'
                        );
                        insertAccrualItem.add(newItem);
                        count++;
                    }
                }

                if (count > 0)
                {
                    ar.ASI_MFM_Status__c = 'Snapshot Completed';   
                }
            }

            System.Debug('insertAccrualItem: ' + insertAccrualItem);
            if (insertAccrualItem.size() > 0)
            {
                insert insertAccrualItem;
                update scope;
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
            email.setSubject('Error in generating accrual request item batch process!');
            email.setPlainTextBody(this.log);    
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
        }
    }
}