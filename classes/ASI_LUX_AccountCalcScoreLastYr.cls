global class ASI_LUX_AccountCalcScoreLastYr implements Schedulable {
    
    //test run
    public static String CRON_EXP = '0 0 0 3 9 ? 2022';

    public static Integer runningJobCount{
        get{
            if(runningJobCount == null)
                return [Select count() FROM AsyncApexJob WHERE JobType='BatchApex' AND(Status = 'Processing' OR Status = 'Preparing')];
            else
                return runningJobCount;
        }
        set{
            System.assert(Test.isRunningTest(),'This property may only be set in tests');
            runningJobCount = value;
        }
    }
    
    global void execute(SchedulableContext SC) {
        
        map<string, id> rt_mapAcc = getRecordTypeId('Account');
        
        String Query = 'SELECT FirstName, LastName, ID, OwnerID, ASI_LUX_Purchase_Behavior_Spend_LastYear__c, ASI_LUX_Purchase_Behavior_Freq_Last_Year__c, ' +
                        ' ASI_LUX_Segmentation_Value_LastYear__c, ASI_LUX_Segment_Involvement_LastYear__c, recordTypeID, recordtype.developerName, ' +
                        ' (SELECT ID, Name, ASI_HK_CRM_Order_Date__c, ASI_HK_CRM_Total_Amount__c ' +
                        ' FROM ASI_HK_CRM_Sales_Order_Histories__r )' + 
                        ' FROM Account WHERE (recordTypeID = \'' + rt_mapAcc.get('ASI_Luxury_Account_HK_Second_Contact_Le_Cercle_Locked') +  '\'' +
                        ' OR recordTypeID = \'' +rt_mapAcc.get('ASI_Luxury_Account_HK_Second_Contact') + '\'' +
                        ' OR recordTypeID = \'' +rt_mapAcc.get('ASI_Luxury_Account_Regional_Second_Contact') + '\'' +
                        ' OR recordTypeID = \'' +rt_mapAcc.get('ASI_Luxury_Account_TW_Second_Contact') + '\'' +
                        ' OR recordTypeID = \'' +rt_mapAcc.get('ASI_Luxury_Account_TW_Second_Contact_Le_Cercle_Locked') + '\'' +
                        ' OR recordTypeID = \'' +rt_mapAcc.get('ASI_Luxury_Account_Regional_Second_Contact_Le_Cercle_Locked') + '\'' +
                        ' OR recordTypeID = \'' +rt_mapAcc.get('ASI_LUX_SG_Account_Second_Contact') + '\'' +
                        ' OR recordTypeID = \'' +rt_mapAcc.get('ASI_LUX_SG_Account_Second_Contact_Le_Cercle_Locked') + '\'' +
                        ' OR recordTypeID = \'' +rt_mapAcc.get('ASI_Luxury_Account_MY_Second_Contact') + '\'' +
                        ' OR recordTypeID = \'' +rt_mapAcc.get('ASI_Luxury_Account_MY_Second_Contact_Le_Cercle_Locked') + '\') ';
        ASI_LUX_AccountCalcScoreLastYrBatch scoreCalculationforLasyr = new ASI_LUX_AccountCalcScoreLastYrBatch(Query);
        
        //check if there are 5 active batch jobs
        if (runningJobCount <5){
            Database.executeBatch(scoreCalculationforLasyr, 30);
        } else {
            //schedule this same schedulable class again in 30 mins
            ASI_LUX_AccountCalcScoreLastYr sc1 = new ASI_LUX_AccountCalcScoreLastYr();
            Datetime dt = Datetime.now() + (0.024305);
            String timeForScheduler = dt.format('s m H d M \'?\' yyyy'); 
            Id schedId = System.Schedule('MatrixRetry'+timeForScheduler,timeForScheduler,sc1 );
        }

    }
    
    global static map<string, id> getRecordTypeId(string object_type) {
        map<string, id> rt_map = new map<string, id>();
        for (recordType rt:[select id, DeveloperName from recordType where SobjectType = :object_type]) {
            rt_map.put(rt.DeveloperName, rt.id);            
        }
        return rt_map;
    }

}