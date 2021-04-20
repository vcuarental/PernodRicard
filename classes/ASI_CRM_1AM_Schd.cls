/***************************************************************************************************************************
 * Name:        ASI_CRM_1AM_Schd
 * Description: Schedule class that is evoked at 1AM
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-07-27       Calvin Chiu (LAPUTA)   	Created
 * 2019-11-13       Tony Ren (PRA)          [TR1.0] LUX AND TW
 * 2019-12-03		Andy Man (INTROV)		[AM1.0] CN
 * 2020-01-07		Andy Man (INTROV)		[AM2.0] CN
 * 2020-01-21		Andy Man (INTROV)		[AM3.0] CN
 * 2020-03-19		Andy Man (INTROV)		[AM4.0] CN FOC
 * 2020-10-19       COE                     [COE1.0] Change CN Job run time
 ****************************************************************************************************************************/
global class ASI_CRM_1AM_Schd implements Schedulable{    
    global void execute(SchedulableContext sc) {
        Date tddate = System.today();
        Datetime dt = (DateTime)tddate;
        String dayOfWeek = dt.format('u');
        Integer day = tddate.day();
        
        // B5
        // ASI_CRM_CN_Acc2CallSummaryUpdate
        ASI_CRM_CN_Acc2CallSummaryUpdate acc2CallSummaryUpdate = new ASI_CRM_CN_Acc2CallSummaryUpdate();
        database.executebatch(acc2CallSummaryUpdate);
        
        // ASI_CRM_CN_Acc2VisitSuggestionUpdate
        ASI_CRM_CN_Acc2VisitSuggestionUpdate acc2VisitSuggestionUpdate = new ASI_CRM_CN_Acc2VisitSuggestionUpdate();
        database.executeBatch(acc2VisitSuggestionUpdate);
        
        // ASI_CRM_CN_AccountGradeGeneration_Batch
        ASI_CRM_CN_AccountGradeGeneration_Batch accountGradeGeneration_Batch = new ASI_CRM_CN_AccountGradeGeneration_Batch();
        database.executeBatch(accountGradeGeneration_Batch);
        

        
        // ASI_LUX_JP_CalculateExp_Batch
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
        Database.executeBatch(calcExp_Batch, 200);
        
        


        if(day==14 || Test.isRunningTest()){
            //TR1.0 : Monthly, 14th, Apex Class:ASI_LUX_AccountCalcScoreLastYr
            ASI_LUX_AccountCalcScoreLastYr con = new ASI_LUX_AccountCalcScoreLastYr();
        }
        
        Integer count = System.purgeOldAsyncJobs(Date.today()-2);
        
        database.executebatch(new ASI_MFM_TW_AccrualPOGeneration_Batch());
        //TR1.0-end
        
        //AM1.0-start
        database.executebatch(new ASI_MFM_CN_ReceiptGeneration_Batch());
        database.executebatch(new ASI_MFM_CN_CheckItemGroupCode_Batch());
        database.executebatch(new ASI_CRM_CN_IGCPUpdate_Batch());
        //AM1.0-end
        //AM2.0-start
        database.executebatch(new ASI_CRM_CN_CheckIVJunction_Batch());
        database.executebatch(new ASI_CRM_CN_CheckIVJunction_Value_Batch());
        //AM2.0-end
        //AM3.0-start
        database.executebatch(new ASI_CRM_CN_CheckIVJunctionD_Batch());
        database.executebatch(new ASI_CRM_CN_CheckIVJunctionD_Value_Batch());
        //AM3.0-end
        //AM4.0-start
        database.executebatch(new ASI_FOC_CN_CheckAutoReject_Batch());
        //AM4.0-end

        //COE1.0
        if(dayOfWeek=='3' || dayOfWeek=='6' || Test.isRunningTest() ){
            ASI_CRM_CN_ContractShare_Batch contractShare_Batch = new ASI_CRM_CN_ContractShare_Batch();
            database.executeBatch(contractShare_Batch, 100);
        }
        //COE1.0
      
        
        
    }
}