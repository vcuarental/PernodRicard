/***************************************************************************************************************************
* Name:        ASI_CRM_6AM_Schd
* Description: Schedule class that is evoked at 6AM
* Test Class:   ASI_CRM_6AM_Schd_Test
********************************************************************************************************
* NOTE TO DEVELOPER: This class is shared between B5 and B6, please apply your update to both sandboxes*
*********************************************************************************************************
* Version History
* Date             Developer               Comments
* ---------------  --------------------    --------------------------------------------------------------------------------
* 2018-07-27       Calvin Chiu (LAPUTA)      Created
* 2019-03-05       Vincent Lam (LAPUTA)     [VL 2.0] Add 2 new jobs on CN
* 2019-04-11       Wilken Lee               [WL 3.0] Add 1 new job for HK CRM EDI Invoice
* 2019-05-02       Vincent Lam (LAPUTA)     [VL 4.0] Add 1 new job on CN
* 2019-10-29       Tony Ren (PRA)           [TR 1.0] Add 3 new job on TH, 2 CN job
* 2019-11-05       Tony Ren (PRA)           [TR 2.0] Add 3 SG , 1 TW ,1 TH
 * 2019-12-03		Andy Man (INTROV)		[AM 1.0] CN
 * 2020-01-07		Andy Man (INTROV)		[AM2.0] CN
 * 2020-01-21		Andy Man (INTROV)		[AM3.0] CN
 * 2020-03-19		Andy Man (INTROV)		[AM4.0] CN FOC
 * 2020-10-21        BLS                    [AM5.0] CN Repack
 * 2021-2-22        BLS                     [AM6.0] Approved by logistics Cancel
****************************************************************************************************************************/
global class ASI_CRM_6AM_Schd implements Schedulable{    
    global void execute(SchedulableContext sc) {
        //B5
        /*[WL 3.0] BEGIN*/
        Database.executeBatch(new ASI_CRM_HK_EDISO_To_Invoice_Batch(), 200);
        /*[WL 3.0] END*/

        // B5 ：ASI_CRM_SG_DailyRollUp_Batch
        Id jobId1 = Database.executeBatch(new ASI_CRM_SG_DailyRollUp_Batch(), 200);
        
        

        /* [VL 2.0] BEGIN */
        Database.executeBatch(new ASI_CRM_CN_Inventory_Visibility_Schedule());
        set<string> set_location = new set<string>();
        for (ASI_CRM_CN_InventoryVisibilityWarehouse__mdt w : [select ASI_CRM_Location__c from ASI_CRM_CN_InventoryVisibilityWarehouse__mdt ]) {
            set_location.add(w.ASI_CRM_Location__c);
        }
        for(string location : set_location){
            Database.executeBatch(new ASI_CRM_CN_InventoryVisibilityDetail_Job(location), 100);
        }
        //Database.executeBatch(new ASI_CRM_CN_InventoryVisibilityDetail_Job(), 50);
        
        /* [VL 2.0] END */ 
        /* [VL 4.0] BEGIN */
        Database.executeBatch(new ASI_CRM_CN_PnD_NearEnd_EffectiveDate(), 200);
        /* [VL 4.0] END */
        
        // B6
        // ASI_CRM_VN_MCF_Contract_Batch
        Database.executeBatch(new ASI_CRM_VN_MCF_Contract_Batch(), 1);
        // ASI_CRM_VN_VisitationPlanBatch
        Database.executeBatch(new ASI_CRM_VN_VisitationPlanBatch());
        
        // B7
        // ASI_KOR_BarStyling_Scheduler
        ASI_KOR_BarStyling_Scheduler barStyling_Scheduler = new ASI_KOR_BarStyling_Scheduler();
        barStyling_Scheduler.execute(null);
        
        
        //TR 1.0 BEGIN: ASI_TH_CRM_SITMaster_Generate_Schedule
        ASI_TH_CRM_SITMaster_Generate_Batch SITMasterGenerateBatch = new ASI_TH_CRM_SITMaster_Generate_Batch(); 
        database.executebatch(SITMasterGenerateBatch);
        
        // ASI_CRM_TH_ActiveContractScheduler
        ASI_CRM_TH_ActiveContractBatch activeContractBatch= new ASI_CRM_TH_ActiveContractBatch(); 
        database.executebatch(activeContractBatch);
        
        // ASI_CRM_TH_UpdateOutstandingPR_Scheduler
        ASI_CRM_TH_UpdateOutstandingPR_Batch batch = new ASI_CRM_TH_UpdateOutstandingPR_Batch(); 
        database.executebatch(new ASI_CRM_TH_UpdateOutstandingPR_Batch());
        
        //ASI_CRM_CN_EventEvaluation_Schd
        database.executebatch(new ASI_CRM_CN_EventEvaluation_Batch());
        
        //ASI_MFM_EventSchedule
        database.executebatch(new ASI_MFM_EventCompleteCalculation());
        //TR 1.0  END
        
        database.executebatch(new ASI_TH_CRM_SITDetail_Init_Batch());
        
        //TR2.0  Monthly 
        Date tddate = System.today();
        Integer day = tddate.day();
        if(day==1 || Test.isRunningTest()){ // first day of month
            //"Monthly, on day 1 of every month   Apex Class : ASI_CRM_SG_GenWSDepletion_Scheduler"
			
            // ASI_TH_CRM_RSPGenarateScheduler 
            ASI_TH_CRM_RSPGenerateBatch rspGenerateBatch= new ASI_TH_CRM_RSPGenerateBatch(); 
            database.executebatch(rspGenerateBatch);
        }
        
        
        if(day==8 || Test.isRunningTest()){ 
            //ASI_CRM_TW_SalesVolumeCalculation_Schd
            database.executebatch(new ASI_CRM_TW_SalesVolumeCalculation_Batch());
        }
        
        
        if(day==16 || Test.isRunningTest()){ 
            Database.executebatch(new ASI_CRM_CN_PhysicalInventory_Batch());
            Database.executeBatch(new ASI_CRM_SG_YtdAchievementNotif_Batch(), 1);
        }
        
        
        Datetime dt = (DateTime)tddate;
        String dayOfWeek = dt.format('u');
        
        if(dayOfWeek!='6' || dayOfWeek!='7' || Test.isRunningTest() ){ // working day
            //ASI_CRM_SG_PymtSchedNotif_Scheduler
            Id jobId6 = Database.executeBatch(new ASI_CRM_SG_PymtSchedIssuanceNotif_Batch(), 50);
            //ASI_CRM_SG_YtdAchievementNotif_Scheduler
            jobId6 = Database.executeBatch(new ASI_CRM_SG_YtdAchievementNotif_Batch(), 1);
        }
        
       //TR2.0 end
            
		//AM1.0-start
        database.executebatch(new ASI_MFM_CN_ReceiptGeneration_Batch());
        database.executebatch(new ASI_MFM_CN_CheckItemGroupCode_Batch());
        database.executebatch(new ASI_CRM_CN_IGCPUpdate_Batch());
        //AM1.0-end
        //AM2.0-start
        database.executebatch(new ASI_CRM_CN_CheckIVJunction_Batch());
        database.executebatch(new ASI_CRM_CN_CheckIVJunction_Value_Batch());
        database.executebatch(new ASI_MFM_CN_CheckPOSMImageUpload_Batch());
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
        //AM6.0-start
        database.executeBatch( new ASI_FOC_CN_FreeRequestItemCancelBatch(),200);
        //AM6.0-start
    }
}