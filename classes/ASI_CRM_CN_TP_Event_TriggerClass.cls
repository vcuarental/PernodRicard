/**************************************************************************************************
 * Name: ASI_CRM_CN_TP_PlanLineItem_TriggerClass
 * Object: ASI_MFM_Plan_Line_Item__c
 * Purpose: 
 * Author:  (jack yuan)
 * Create Date: 2020-3-23
 * Modify History:
 * 2020-3-23        Create this class
 **************************************************************************************************/
public without sharing class ASI_CRM_CN_TP_Event_TriggerClass {
    public static Boolean AFTEREXECUTEFLAG = false;

    public static void routineAfterInsert(List<ASI_MFM_Event__c> trigger_new) {
        if (AFTEREXECUTEFLAG) return;
        AFTEREXECUTEFLAG = true;
    	Set<Id> planIdSet = new Set<Id>();
    	for (ASI_MFM_Event__c outlet : trigger_new) {
    		planIdSet.add(outlet.ASI_CRM_CN_TP_Plan__c);
    	}
    	calculateOutletCount(planIdSet);
        
    }

    public static void routineAfterDelete(List<ASI_MFM_Event__c> trigger_old) {
    	Set<Id> planIdSet = new Set<Id>();
    	for (ASI_MFM_Event__c outlet : trigger_old) {
    		planIdSet.add(outlet.ASI_CRM_CN_TP_Plan__c);
    	}
    	calculateOutletCount(planIdSet);
    }

    public static void calculateOutletCount(Set<Id> planIdSet) {
    	List<ASI_MFM_Plan__c> tplans = [SELECT ASI_CRM_CN_TP_Outlet_Count__c,
    										   (SELECT Id FROM Events__r) 
    								    FROM ASI_MFM_Plan__c 
    								    WHERE Id IN :planIdSet];
    	for (ASI_MFM_Plan__c plan : tplans) {
    		plan.ASI_CRM_CN_TP_Outlet_Count__c = plan.Events__r.size();
    	}
    	update tplans;
    }

}