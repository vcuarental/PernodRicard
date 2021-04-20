public without sharing class ASI_CRM_CN_Call_Log_TriggerClass{

    public static void routineAfterInsert(list<ASI_CRM_Call_Log__c> trigger_new) {
        
        // START: Update Call Monthly Summary
        {
            map<Id, map<Date, ASI_CRM_Call_Monthly_Summary__c>> summaries = PrepareSummaries(trigger_new);
            
            set<ASI_CRM_Call_Monthly_Summary__c> updates = new set<ASI_CRM_Call_Monthly_Summary__c>();
            
            for(ASI_CRM_Call_Log__c e :trigger_new) {
                PrepareSummaryUpdates(e, 1, summaries, updates);
            }
            
            if(updates.size()>0) {
                list<ASI_CRM_Call_Monthly_Summary__c> updatesList = new list<ASI_CRM_Call_Monthly_Summary__c>();
                updatesList.addAll(updates);
                upsert updatesList;
            }
        }
        // END: Update Call Monthly Summary        
        
        // START: Update Call Summary in Accounts Additional Field record
        set<Id> account2Ids = new set<Id>();
        for(ASI_CRM_Call_Log__c e :trigger_new) {
            if(e.ASI_CRM_AccountsAdditionalField__c!=null)
                account2Ids.add(e.ASI_CRM_AccountsAdditionalField__c);
        }
        if(account2Ids.size()>0) {
            list<Id> account2IdsList = new list<Id>();
            account2IdsList.addAll(account2Ids);
            ASI_CRM_CN_Acc2CallSummaryUpdate.UpdateAccount2CallSummary(account2IdsList);
        }
        // END: Update Call Summary in Accounts Additional Field record
        
        // START: Create Follow-up Task
        list<Task> followupTasks = new list<Task>();
        for(ASI_CRM_Call_Log__c e :trigger_new) {
            if(e.ASI_CRM_Follow_up__c!=null && e.ASI_CRM_Follow_up__c!=''){
                followupTasks.add(CreateFollowUpTask(e));
            }
        }
        if(followupTasks.size()>0)
            insert followupTasks;
        // END: Create Follow-up Task
    }
        
    public static void routineAfterUpdate(list<ASI_CRM_Call_Log__c> trigger_new, map<id, ASI_CRM_Call_Log__c> trigger_oldMap) {

        // START: Update Call Monthly Summary
        list<ASI_CRM_Call_Log__c> allCallLogs = new list<ASI_CRM_Call_Log__c>();
        allCallLogs.addAll(trigger_new);
        allCallLogs.addAll(trigger_oldMap.values());
        
        map<Id, map<Date, ASI_CRM_Call_Monthly_Summary__c>> summaries = PrepareSummaries(allCallLogs);
        
        set<ASI_CRM_Call_Monthly_Summary__c> updates = new set<ASI_CRM_Call_Monthly_Summary__c>();
        
        for(ASI_CRM_Call_Log__c e1 :trigger_new) {
            ASI_CRM_Call_Log__c e0 = trigger_oldMap.get(e1.Id);
            
            if(e1.ASI_CRM_AccountsAdditionalField__c==e0.ASI_CRM_AccountsAdditionalField__c && e1.ASI_CRM_Visit_Date__c.year()==e0.ASI_CRM_Visit_Date__c.year() && e1.ASI_CRM_Visit_Date__c.month()==e0.ASI_CRM_Visit_Date__c.month()) continue;
            
            PrepareSummaryUpdates(e0, -1, summaries, updates);
            PrepareSummaryUpdates(e1, 1, summaries, updates);
        }
        
        if(updates.size()>0) {
            list<ASI_CRM_Call_Monthly_Summary__c> updatesList = new list<ASI_CRM_Call_Monthly_Summary__c>();
            updatesList.addAll(updates);
            upsert updatesList;
        }
        
        // END: Update Call Monthly Summary        
        
        // START: Update Call Summary in Accounts Additional Field record
        set<Id> account2Ids = new set<Id>();
        for(ASI_CRM_Call_Log__c e :trigger_new) {
            if(e.ASI_CRM_AccountsAdditionalField__c!=null)
                account2Ids.add(e.ASI_CRM_AccountsAdditionalField__c);
        }
        if(account2Ids.size()>0) {
            list<Id> account2IdsList = new list<Id>();
            account2IdsList.addAll(account2Ids);
            ASI_CRM_CN_Acc2CallSummaryUpdate.UpdateAccount2CallSummary(account2IdsList);
        }
        // END: Update Call Summary in Accounts Additional Field record
        
        // START: Create Follow-up Task
        list<Task> followupTasks = new list<Task>();
        for(ASI_CRM_Call_Log__c e1 :trigger_new) {
            ASI_CRM_Call_Log__c e0 = trigger_oldMap.get(e1.Id);
            if((e0.ASI_CRM_Follow_up__c==null || e0.ASI_CRM_Follow_up__c=='') &&
                e1.ASI_CRM_Follow_up__c!=null && e1.ASI_CRM_Follow_up__c!=''){
                followupTasks.add(CreateFollowUpTask(e1));
            }
        }
        if(followupTasks.size()>0)
            insert followupTasks;
        // END: Create Follow-up Task
    }
    
    public static void routineAfterDelete(list<ASI_CRM_Call_Log__c> trigger_old) {
        
        // START: Update Call Monthly Summary
        map<Id, map<Date, ASI_CRM_Call_Monthly_Summary__c>> summaries = PrepareSummaries(trigger_old);
        
        set<ASI_CRM_Call_Monthly_Summary__c> updates = new set<ASI_CRM_Call_Monthly_Summary__c>();
        
        for(ASI_CRM_Call_Log__c e :trigger_old) {
            PrepareSummaryUpdates(e, -1, summaries, updates);
        }
        
        if(updates.size()>0) {
            list<ASI_CRM_Call_Monthly_Summary__c> updatesList = new list<ASI_CRM_Call_Monthly_Summary__c>();
            updatesList.addAll(updates);
            upsert updatesList;
        }
        // END: Update Call Monthly Summary        
        
        // START: Update Call Summary in Accounts Additional Field record
        set<Id> account2Ids = new set<Id>();
        for(ASI_CRM_Call_Log__c e :trigger_old) {
            if(e.ASI_CRM_AccountsAdditionalField__c!=null)
                account2Ids.add(e.ASI_CRM_AccountsAdditionalField__c);
        }
        if(account2Ids.size()>0) {
            list<Id> account2IdsList = new list<Id>();
            account2IdsList.addAll(account2Ids);
            ASI_CRM_CN_Acc2CallSummaryUpdate.UpdateAccount2CallSummary(account2IdsList);
        }
        // END: Update Call Summary in Accounts Additional Field record
    }
    
    private static void PrepareSummaryUpdates(ASI_CRM_Call_Log__c e, integer change, map<Id, map<Date, ASI_CRM_Call_Monthly_Summary__c>> summaries, set<ASI_CRM_Call_Monthly_Summary__c> updates) {
        if(e.ASI_CRM_AccountsAdditionalField__c!=null && e.ASI_CRM_Visit_Date__c!=null) {
            ASI_CRM_Call_Monthly_Summary__c summary = summaries.get(e.ASI_CRM_AccountsAdditionalField__c).get(Date.newInstance(e.ASI_CRM_Visit_Date__c.year(), e.ASI_CRM_Visit_Date__c.month(), 1));
            summary.ASI_CRM_Number_of_Call_Log__c += change;
            if(!updates.contains(summary))
                updates.add(summary);
        }
    }
    
    private static map<Id, map<Date, ASI_CRM_Call_Monthly_Summary__c>> PrepareSummaries(list<ASI_CRM_Call_Log__c> callLogs) {
        
        map<Id, map<Date, ASI_CRM_Call_Monthly_Summary__c>> summaries = new map<Id, map<Date, ASI_CRM_Call_Monthly_Summary__c>>();
        
        set<Id> account2Ids = new set<Id>();
        set<Date> startDates = new set<Date>();
        for(ASI_CRM_Call_Log__c e :callLogs) {
            if(e.ASI_CRM_AccountsAdditionalField__c==null || e.ASI_CRM_Visit_Date__c==null) continue;
            account2Ids.add(e.ASI_CRM_AccountsAdditionalField__c);
            startDates.add(Date.newInstance(e.ASI_CRM_Visit_Date__c.year(), e.ASI_CRM_Visit_Date__c.month(), 1));
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
        
        for(ASI_CRM_Call_Log__c e :callLogs) {
            if(e.ASI_CRM_AccountsAdditionalField__c==null || e.ASI_CRM_Visit_Date__c==null) continue;
            Date startDate = Date.newInstance(e.ASI_CRM_Visit_Date__c.year(), e.ASI_CRM_Visit_Date__c.month(), 1);
            if(!summaries.containsKey(e.ASI_CRM_AccountsAdditionalField__c))
                summaries.put(e.ASI_CRM_AccountsAdditionalField__c, new map<Date, ASI_CRM_Call_Monthly_Summary__c>());
            if(!summaries.get(e.ASI_CRM_AccountsAdditionalField__c).containsKey(startDate))
                summaries.get(e.ASI_CRM_AccountsAdditionalField__c).put(startDate, new ASI_CRM_Call_Monthly_Summary__c(ASI_CRM_Account__c=e.ASI_CRM_AccountsAdditionalField__c, ASI_CRM_Summary_Start_Date__c=startDate, ASI_CRM_Number_of_Call_Plan__c=0, ASI_CRM_Number_of_Call_Log__c=0));
        }  
        
        return summaries;
    }
    
    private static Task CreateFollowupTask(ASI_CRM_Call_Log__c callLog) {
        Id rtid = Global_RecordTypeCache.getRtId('TaskASI_CRM_CN_Task');
        
        Task t = new Task();
        t.RecordTypeId = rtid;
        t.Type = 'Other';
        t.Subject = 'Call Log Follow-up';
        t.Description = callLog.ASI_CRM_Follow_up__c;
        t.ActivityDate = callLog.ASI_CRM_Due_Date__c;
        t.OwnerId = callLog.CreatedById;
        t.WhatId = callLog.ASI_CRM_AccountsAdditionalField__c!=null? callLog.ASI_CRM_AccountsAdditionalField__c : callLog.Id;
        t.Status = 'Not started';
        t.Priority = 'High';
        return t;
    }
    
}