/***************************************************************************************************************************
 * Name:        ASI_CRM_9AM_Schd
 * Description: Schedule class that is evoked at 9AM
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-07-27       Calvin Chiu (LAPUTA)   	Created
 * 2019-11-13       Tony Ren (PRA)          [TR1.0] HK
 * 2019-12-03		Andy Man (INTROV)		[AM1.0] CN
 * 2020-01-07		Andy Man (INTROV)		[AM2.0] CN
 * 2020-01-21		Andy Man (INTROV)		[AM3.0] CN
 * 2020-03-19		Andy Man (INTROV)		[AM4.0] CN FOC
 ****************************************************************************************************************************/
global without sharing class ASI_CRM_9AM_Schd implements Schedulable{    
	global void execute(SchedulableContext sc) {        

        
        // B6
        // ASI_eForm_KR_CCRemind
    	Integer CCRe1 = Integer.valueOf(ASI_KR_Schd_Setting__c.getValues('For CC Reminder').ASI_KR_numOfDays1__c);
        Integer CCRe2 = Integer.valueOf(ASI_KR_Schd_Setting__c.getValues('For CC Reminder').ASI_KR_numOfDays2__c);
        if(ASI_KR_Schd_Setting__c.getValues('For CC Reminder').ASI_KR_isActivate__c)
        	database.executebatch(new ASI_eForm_KR_CCRemind(CCRe1,CCRe2));
        
        // ASI_eForm_KR_CTRemind
        Integer CTRe1 = Integer.valueOf(ASI_KR_Schd_Setting__c.getValues('For CT Reminder').ASI_KR_numOfDays1__c);
        Integer CTRe2 = Integer.valueOf(ASI_KR_Schd_Setting__c.getValues('For CT Reminder').ASI_KR_numOfDays2__c);
        if(ASI_KR_Schd_Setting__c.getValues('For CT Reminder').ASI_KR_isActivate__c)
        	database.executebatch(new ASI_eForm_KR_CTRemind(CTRe1,CTRe2));
        
        // ASI_eForm_KR_leaveRemind
        Integer LRRe1 = Integer.valueOf(ASI_KR_Schd_Setting__c.getValues('For LR Reminder').ASI_KR_numOfDays1__c);
        Integer LRRe2 = Integer.valueOf(ASI_KR_Schd_Setting__c.getValues('For LR Reminder').ASI_KR_numOfDays2__c);
        if(ASI_KR_Schd_Setting__c.getValues('For LR Reminder').ASI_KR_isActivate__c)
        	database.executebatch(new ASI_eForm_KR_leaveRemind(LRRe1,LRRe2));
        
        // ASI_TnE_KR_remindAnP
        Integer AnPRe1 = Integer.valueOf(ASI_KR_Schd_Setting__c.getValues('For AnP Reminder').ASI_KR_numOfDays1__c);
        Integer AnPRe2 = Integer.valueOf(ASI_KR_Schd_Setting__c.getValues('For AnP Reminder').ASI_KR_numOfDays2__c);
        if(ASI_KR_Schd_Setting__c.getValues('For AnP Reminder').ASI_KR_isActivate__c)
        	database.executebatch(new ASI_TnE_KR_remindAnP(AnPRe1,AnPRe2));
        
        // ASI_TnE_KR_remindTnE
        Integer TnERe1 = Integer.valueOf(ASI_KR_Schd_Setting__c.getValues('For TnE Reminder').ASI_KR_numOfDays1__c);
        Integer TnERe2 = Integer.valueOf(ASI_KR_Schd_Setting__c.getValues('For TnE Reminder').ASI_KR_numOfDays2__c);
        if(ASI_KR_Schd_Setting__c.getValues('For TnE Reminder').ASI_KR_isActivate__c){
            database.executebatch(new ASI_TnE_KR_remindTnE(TnERe1,TnERe2));   
        }
        
        
        database.executebatch(new ASI_CRM_TW_UpdateActualOfftake_Batch());
        
        
        Date tddate = System.today();
        Datetime dt = (DateTime)tddate;
        String dayOfWeek = dt.format('u');
        
        //TR1.0
        if(dayOfWeek!='6' || dayOfWeek!='7' || Test.isRunningTest() ){ // working day
            ASI_MFM_HK_GenPOReceipt_Sche s = new ASI_MFM_HK_GenPOReceipt_Sche();
            s.init();  
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
        
    }
}