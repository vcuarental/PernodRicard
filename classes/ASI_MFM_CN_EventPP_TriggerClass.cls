public with sharing class ASI_MFM_CN_EventPP_TriggerClass {
	public static void routineBeforeInsert(list<ASI_MFM_Event_PP__c> trigger_new) {
        set<Id> eventIds = new set<Id>();
        set<Id> planIds = new set<Id>();
        for(ASI_MFM_Event_PP__c eventPP: trigger_new) {
            eventIds.add(eventPP.ASI_MFM_Event__c);
            planIds.add(eventPP.ASI_MFM_Plan__c);
        }
        
        map<Id, ASI_MFM_Event__c> mapEvents = new map<Id, ASI_MFM_Event__c>(
        	[SELECT Id, (SELECT ASI_MFM_Sub_brand__c FROM ASI_MFM_Event__c.Event_Sub_Brands__r)
             FROM ASI_MFM_Event__c 
             WHERE Id IN :eventIds]);
        
        map<Id, ASI_MFM_Plan__c> mapPlans = new map<Id, ASI_MFM_Plan__c>(
        	[SELECT Id, Name, (SELECT ASI_MFM_Sub_brand_Code__c FROM ASI_MFM_Plan__c.Plan_Line_Items__r)
             FROM ASI_MFM_Plan__c
             WHERE Id IN :planIds]);
        
        for(ASI_MFM_Event_PP__c eventPP: trigger_new) {
            if(!mapEvents.containsKey(eventPP.ASI_MFM_Event__c)) {
                eventPP.addError('Invalid Event');
                continue;
            }
            if(!mapPlans.containsKey(eventPP.ASI_MFM_Plan__c)) {
                eventPP.addError('Invalid Plan');
                continue;
            }
            
   //         if(!CommonSubBrandFound(mapEvents.get(eventPP.ASI_MFM_Event__c), mapPlans.get(eventPP.ASI_MFM_Plan__c))) {
   //             eventPP.addError('Sub-brand mismatch ' + mapPlans.get(eventPP.ASI_MFM_Plan__c).Name);
   //            continue;
   //        }
        }
    }
    
    private static boolean CommonSubBrandFound(ASI_MFM_Event__c event, ASI_MFM_Plan__c plan) {
        for(ASI_MFM_Event_Sub_Brand__c esb :event.Event_Sub_Brands__r) {
            for(ASI_MFM_Plan_Line_Item__c pli :plan.Plan_Line_Items__r) {
                if(pli.ASI_MFM_Sub_brand_Code__c==esb.ASI_MFM_Sub_brand__c)
                    return true;
            }    
        }
        
        return false;
    }
}