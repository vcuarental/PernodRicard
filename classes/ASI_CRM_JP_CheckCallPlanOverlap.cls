/*********************************************************************************
 * Name:ASI_CRM_JP_CheckCallPlanOverlap
 * Description: Check Overlap for Call Plan Period
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 18/11/2014       Laputa: Hank          Created
*********************************************************************************/

public with sharing class ASI_CRM_JP_CheckCallPlanOverlap extends ASI_CRM_JP_TriggerAbstract {

    public ASI_CRM_JP_CheckCallPlanOverlap() {
        super('ASI_CRM_JP_CheckCallPlanOverlap');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        
        List<ASI_CRM_Call_Plan__c> planList = (List<ASI_CRM_Call_Plan__c>)sObjList;
  		Set<Id> ownerIdSet = new Set<Id>();      
  
        if (oldMap == null) {
            for (ASI_CRM_Call_Plan__c plan : planList) {
            	ownerIdSet.add(plan.OwnerId);    
            }
        }
        else {
            Map<ID, ASI_CRM_Call_Plan__c> oldPlanMap = (Map<ID, ASI_CRM_Call_Plan__c>) oldMap;
            for (ASI_CRM_Call_Plan__c plan: planList) {
                if(plan.ASI_CRM_Period_From__c != oldPlanMap.get(plan.Id).ASI_CRM_Period_From__c || plan.ASI_CRM_Period_To__c != oldPlanMap.get(plan.Id).ASI_CRM_Period_To__c){
                	ownerIdSet.add(plan.OwnerId); 
                }
            }
        }
        
        List<ASI_CRM_Call_Plan__c> allPlanList = [Select Name, OwnerId, ASI_CRM_Period_From__c, ASI_CRM_Period_To__c From ASI_CRM_Call_Plan__c Where OwnerId In :ownerIdSet];
        
        if (oldMap == null) {
            for (ASI_CRM_Call_Plan__c plan : planList) {
            	for(ASI_CRM_Call_Plan__c otherPlan:allPlanList){
            		if(plan.OwnerId == otherPlan.OwnerId && plan.Id != otherPlan.Id){
            			if(!(plan.ASI_CRM_Period_From__c > otherPlan.ASI_CRM_Period_To__c || plan.ASI_CRM_Period_To__c < otherPlan.ASI_CRM_Period_From__c)){
            				plan.addError(System.Label.ASI_CRM_JP_Call_Plan_Overlap + ' (' + otherPlan.Name + ': ' + otherPlan.ASI_CRM_Period_From__c.format() + '~' + otherPlan.ASI_CRM_Period_To__c.format() + ')');
            			}
            		}
            	}	    
            }
        }
        else {
            Map<ID, ASI_CRM_Call_Plan__c> oldPlanMap = (Map<ID, ASI_CRM_Call_Plan__c>) oldMap;
            for (ASI_CRM_Call_Plan__c plan: planList) {
                if(plan.ASI_CRM_Period_From__c != oldPlanMap.get(plan.Id).ASI_CRM_Period_From__c || plan.ASI_CRM_Period_To__c != oldPlanMap.get(plan.Id).ASI_CRM_Period_To__c){
               		for(ASI_CRM_Call_Plan__c otherPlan:allPlanList){
            			if(plan.OwnerId == otherPlan.OwnerId && plan.Id != otherPlan.Id){ 
            				if(!(plan.ASI_CRM_Period_From__c > otherPlan.ASI_CRM_Period_To__c || plan.ASI_CRM_Period_To__c < otherPlan.ASI_CRM_Period_From__c)){
            					plan.addError(System.Label.ASI_CRM_JP_Call_Plan_Overlap + ' (' + otherPlan.Name + ': ' + otherPlan.ASI_CRM_Period_From__c.format() + '~' + otherPlan.ASI_CRM_Period_To__c.format() + ')');
            				}
            			}
            		}
                }
            }
        }
    }
}