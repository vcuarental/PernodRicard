/***************************************************************************************************************************
* Name:        ASI_CRM_12PM_Schd
* Description: Schedule class that is evoked at 12PM
*
* Version History
* Date             Developer               Comments
* ---------------  --------------------    --------------------------------------------------------------------------------
* 2018-07-27       Calvin Chiu (LAPUTA)   	Created
* 2019-11-07       Tony Ren (PRA)           Add MY ASI_CRM_MY_CalculatedPayment_Schedule
* 2019-12-03		Andy Man (INTROV)		[AM1.0] CN
* 2020-01-07		Andy Man (INTROV)		[AM2.0] CN
* 2020-01-21		Andy Man (INTROV)		[AM3.0] CN
* 2020-03-19		Andy Man (INTROV)		[AM4.0] CN FOC
* 2020-10-21        BLS                     [AM5.0] CN Repack
****************************************************************************************************************************/
global class ASI_CRM_12PM_Schd implements Schedulable{    
    global void execute(SchedulableContext sc) {
        // B7
        Id jobId1 = Database.executeBatch(new ASI_KOR_CalPrevMonthsValueByDetail(), 20);
        System.debug('------ jobId1 ------ : ' + jobId1);
        
        Id jobId2 = Database.executeBatch(new ASI_KOR_CalPrevMonthsValueByBrand(), 20);
        System.debug('------ jobId2 ------ : ' + jobId2);
        
        Id jobId3 = Database.executeBatch(new ASI_KOR_CalPrevMonthsValueByBrand_NSD());
        System.debug('------ jobId3 ------ : ' + jobId3);
        
        Date tddate = System.today();
        Integer day = tddate.day();
        
        // CN
        database.executebatch(new ASI_CRM_CN_IGCPUpdate_Batch());
        
        
        database.executebatch(new ASI_TH_CRM_SITDetail_Init_Batch());
        
        //MY
        if(day==1 || day==2 || day==3 || day==4 || day==5 || day==6 || day==29 || day==30 ||day==31 || Test.isRunningTest()){ 
            ASI_CRM_MY_CalculatedPayment_Schedule calcPayment_Batch = new ASI_CRM_MY_CalculatedPayment_Schedule();
            calcPayment_Batch.genCalculatedPayment();
        }
        
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
        //AM5.0-start
        database.executebatch(new ASI_MFM_CN_RepackCheckAutoRejectBatch());
        //AM5.0-end
        
        ASI_CRM_HK_PAF_Reminder_Batch batchObj = new ASI_CRM_HK_PAF_Reminder_Batch();
        DataBase.executeBatch(batchObj);
        Id jobId4 = Database.executeBatch(new ASI_CRM_HK_PAF_NoPO_Batch(), 50);
        
        
    }
}