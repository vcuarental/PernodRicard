public without sharing class ASI_CRM_CN_Event_TriggerClass{
    
    public static void routineAfterInsert(list<Event> trigger_new) {
        
        //START:Call Plan related updates
        {
            list<Event> callPlans = new list<Event>();
            for(Event e :trigger_new) {
                
                if(Global_RecordTypeCache.getRt(e.RecordTypeId).DeveloperName.startsWith('ASI_CRM_CN_Call_Plan'))
                    callPlans.add(e);
            }
            
            if(callPlans.size()>0) {
                map<Id, map<Date, ASI_CRM_Call_Monthly_Summary__c>> summaries = PrepareSummaries(callPlans);
                
                set<ASI_CRM_Call_Monthly_Summary__c> updates = new set<ASI_CRM_Call_Monthly_Summary__c>();
                
                for(Event e :callPlans) {
                    PrepareSummaryUpdates(e, 1, summaries, updates);
                }
                
                if(updates.size()>0) {
                    list<ASI_CRM_Call_Monthly_Summary__c> updatesList = new list<ASI_CRM_Call_Monthly_Summary__c>();
                    updatesList.addAll(updates);
                    upsert updatesList;
                }
                
                set<Id> account2Ids = new set<Id>();
                for(Event e :callPlans) {
                    if(e.WhatId!=null)
                        account2Ids.add(e.WhatId);
                }
                if(account2Ids.size()>0) {
                    list<Id> account2IdsList = new list<Id>();
                    account2IdsList.addAll(account2Ids);
                    ASI_CRM_CN_Acc2CallSummaryUpdate.UpdateAccount2CallSummary(account2IdsList);
                }
            }
        }
        //END:Call Plan related updates
    }
    
    public static void routineAfterUpdate(list<Event> trigger_new, map<id, Event> trigger_oldMap) {
        
        //START:Call Plan related updates
        {
            map<Id, Event> mapNew = new map<Id, Event>(); 
            map<Id, Event> mapOld = new map<Id, Event>();
            set<Id> callPlanIds = new set<Id>();
            for(Event e :trigger_new) {
                if(Global_RecordTypeCache.getRt(e.RecordTypeId).DeveloperName.startsWith('ASI_CRM_CN_Call_Plan')) {
                    mapNew.put(e.Id, e);
                    callPlanIds.add(e.Id);
                }
            }
            for(Event e:trigger_oldMap.values()) {
                if(Global_RecordTypeCache.getRt(e.RecordTypeId).DeveloperName.startsWith('ASI_CRM_CN_Call_Plan')) {
                    mapOld.put(e.Id, e);
                    callPlanIds.add(e.Id);
                }
            }
            
            if(callPlanIds.size()>0 ) {
                list<Event> allCallPlans = new list<Event>();
                allCallPlans.addAll(mapNew.values());
                allCallPlans.addAll(mapOld.values());
                
                map<Id, map<Date, ASI_CRM_Call_Monthly_Summary__c>> summaries = PrepareSummaries(allCallPlans);
                
                set<ASI_CRM_Call_Monthly_Summary__c> updates = new set<ASI_CRM_Call_Monthly_Summary__c>();
                
                for(Id eid: callPlanIds) {

                    Event e0 = mapOld.containsKey(eid) ? mapOld.get(eid) : null;
                    Event e1 = mapNew.containsKey(eid) ? mapNew.get(eid) : null;
                    
                    if(e0!=null && e1!=null &&
                       (e1.WhatId==e0.WhatId && e1.StartDateTime.year()==e0.StartDateTime.year() && e1.StartDateTime.month()==e0.StartDateTime.month())) continue;
                    
                    if(e0!=null) PrepareSummaryUpdates(e0, -1, summaries, updates);
                    if(e1!=null) PrepareSummaryUpdates(e1, 1, summaries, updates);
                }

                if(updates.size()>0) {
                    list<ASI_CRM_Call_Monthly_Summary__c> updatesList = new list<ASI_CRM_Call_Monthly_Summary__c>();
                    updatesList.addAll(updates);
                    upsert updatesList;
                }
                
                set<Id> account2Ids = new set<Id>();
                for(Id eid: callPlanIds) {
                    Event e0 = mapOld.containsKey(eid) ? mapOld.get(eid) : null;
                    Event e1 = mapNew.containsKey(eid) ? mapNew.get(eid) : null;
                    
                    if(e0!=null && e0.WhatId!=null)
                        account2Ids.add(e0.WhatId);
                    
                    if(e1!=null && e1.WhatId!=null)
                        account2Ids.add(e1.WhatId);
                    
                }
                if(account2Ids.size()>0) {
                    list<Id> account2IdsList = new list<Id>();
                    account2IdsList.addAll(account2Ids);
                    ASI_CRM_CN_Acc2CallSummaryUpdate.UpdateAccount2CallSummary(account2IdsList);
                }
            }
        }
        //END:Call Plan related updates
    }
    
    public static void routineAfterDelete(list<Event> trigger_old) {
        
        //START:Call Plan related updates
        {
            list<Event> callPlans = new list<Event>();
            for(Event e :trigger_old) {
                
                if(Global_RecordTypeCache.getRt(e.RecordTypeId).DeveloperName.startsWith('ASI_CRM_CN_Call_Plan'))
                    callPlans.add(e);
            }
            
            if(callPlans.size()>0) {
                map<Id, map<Date, ASI_CRM_Call_Monthly_Summary__c>> summaries = PrepareSummaries(callPlans);
                
                set<ASI_CRM_Call_Monthly_Summary__c> updates = new set<ASI_CRM_Call_Monthly_Summary__c>();
                
                for(Event e :callPlans) {
                    PrepareSummaryUpdates(e, -1, summaries, updates);
                }
                
                if(updates.size()>0) {
                    list<ASI_CRM_Call_Monthly_Summary__c> updatesList = new list<ASI_CRM_Call_Monthly_Summary__c>();
                    updatesList.addAll(updates);
                    upsert updatesList;
                }
                
                set<Id> account2Ids = new set<Id>();
                for(Event e :callPlans) {
                    if(e.WhatId!=null)
                        account2Ids.add(e.WhatId);
                }
                if(account2Ids.size()>0) {
                    list<Id> account2IdsList = new list<Id>();
                    account2IdsList.addAll(account2Ids);
                    ASI_CRM_CN_Acc2CallSummaryUpdate.UpdateAccount2CallSummary(account2IdsList);
                }
            }
        }
        //END:Call Plan related updates
    }
    
    private static void PrepareSummaryUpdates(Event e, integer change, map<Id, map<Date, ASI_CRM_Call_Monthly_Summary__c>> summaries, set<ASI_CRM_Call_Monthly_Summary__c> updates) {
        if(e.WhatId!=null && e.StartDateTime!=null) {
            ASI_CRM_Call_Monthly_Summary__c summary = summaries.get(e.WhatId).get(Date.newInstance(e.StartDateTime.year(), e.StartDateTime.month(), 1));
            summary.ASI_CRM_Number_of_Call_Plan__c += change;
            if(!updates.contains(summary))
                updates.add(summary);
        }
    }
    
    private static map<Id, map<Date, ASI_CRM_Call_Monthly_Summary__c>> PrepareSummaries(list<Event> events) {
        
        map<Id, map<Date, ASI_CRM_Call_Monthly_Summary__c>> summaries = new map<Id, map<Date, ASI_CRM_Call_Monthly_Summary__c>>();
        set<Id> account2Ids = new set<Id>();
        set<Date> startDates = new set<Date>();
        for(Event e :events) {
            if(e.WhatId==null || e.StartDateTime==null) continue;
            account2Ids.add(e.WhatId);
            startDates.add(Date.newInstance(e.StartDateTime.year(), e.StartDateTime.month(), 1));
        }
        
        if(account2Ids.size()>0 && startDates.size()>0) {
            
            for(ASI_CRM_Call_Monthly_Summary__c cms :[SELECT Id, ASI_CRM_Account__c, ASI_CRM_Summary_Start_Date__c , ASI_CRM_Number_of_Call_Plan__c, ASI_CRM_Number_of_Call_Log__c 
                                                      FROM ASI_CRM_Call_Monthly_Summary__c
                                                      WHERE ASI_CRM_Account__c IN :account2Ids AND ASI_CRM_Summary_Start_Date__c  in :startDates
                                                      FOR UPDATE]) {
                                                          if(!summaries.containsKey(cms.ASI_CRM_Account__c))
                                                              summaries.put(cms.ASI_CRM_Account__c, new map<Date, ASI_CRM_Call_Monthly_Summary__c>());
                                                          summaries.get(cms.ASI_CRM_Account__c).put(cms.ASI_CRM_Summary_Start_Date__c, cms);
                                                      }                    
        }
        
        for(Event e :events) {
            if(e.WhatId==null || e.StartDateTime==null) continue;
            Date startDate = Date.newInstance(e.StartDateTime.year(), e.StartDateTime.month(), 1);
            if(!summaries.containsKey(e.WhatId))
                summaries.put(e.WhatId, new map<Date, ASI_CRM_Call_Monthly_Summary__c>());
            if(!summaries.get(e.WhatId).containsKey(startDate))
                summaries.get(e.WhatId).put(startDate, new ASI_CRM_Call_Monthly_Summary__c(recordtypeid = Global_RecordTypeCache.getRtId('ASI_CRM_Call_Monthly_Summary__cASI_CRM_CN_Call_Monthly_Summary'),ASI_CRM_Account__c=e.WhatId, ASI_CRM_Summary_Start_Date__c=startDate, ASI_CRM_Number_of_Call_Plan__c=0, ASI_CRM_Number_of_Call_Log__c=0));
        }  
        
        return summaries;
    }
    
}