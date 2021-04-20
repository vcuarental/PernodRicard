/*********************************************************************************
 * Name:ASI_LUX_JP_CalculateExp_Scheduler
 * Description: Calculate Expenditure Scheduler
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 27/01/2015       Laputa: Conrad          Created
*********************************************************************************/
global class ASI_LUX_JP_CalculateExp_Scheduler implements Schedulable {
    
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
        
        Map<String, Schema.SObjectField> campaignContributionFieldMap = Schema.SObjectType.ASI_LUX_Campaign_Contribution__c.fields.getMap();
        String theQuery = 'Select ';
            
        for(String fields  : campaignContributionFieldMap.keySet()){
            theQuery += fields + ' ,';
        }
             
        thequery = theQuery.subString(0,theQuery.length()-1);
        thequery += ', recordtype.developername ' +
        ' From ASI_LUX_Campaign_Contribution__c where recordtype.developername = \'ASI_LUX_JP_Campaign_Contribution\' ' + 
        ' OR recordtype.developername = \'ASI_LUX_SG_Campaign_Contribution\' ' + ' OR recordtype.developername = \'ASI_BRD_Generic_Campaign_Contribution\' ';
        
        ASI_LUX_JP_CalculateExp_Batch calcExp_Batch = new ASI_LUX_JP_CalculateExp_Batch(thequery);
        
        //check if there are 5 active batch jobs
        if (runningJobCount <5){
            Database.executeBatch(calcExp_Batch, 200);
        } else {
            //schedule this same schedulable class again in 30 mins
            ASI_LUX_JP_CalculateExp_Scheduler sc1 = new ASI_LUX_JP_CalculateExp_Scheduler();
            Datetime dt = Datetime.now() + (0.024305);
            String timeForScheduler = dt.format('s m H d M \'?\' yyyy'); 
            Id schedId = System.Schedule('MatrixRetry'+timeForScheduler,timeForScheduler,sc1 );
        }
        
    }
}