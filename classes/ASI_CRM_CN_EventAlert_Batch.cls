global without sharing class ASI_CRM_CN_EventAlert_Batch implements Database.Batchable<sObject> ,Database.Stateful{
	
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        String queryStr = 'SELECT id, ASI_MFM_Event_Type__c, ASI_MFM_Proposed_Outet_Coverage_Total__c, ASI_MFM_Event_ID__c, Name, OwnerId, ASI_MFM_End_Date__c, ASI_MFM_CN_Before_10_Day_Alert__c, ASI_MFM_CN_After_End_Date_Alert__c, ASI_MFM_Start_Date__c FROM ASI_MFM_Event__c WHERE ( ASI_MFM_Proposed_Outet_Coverage_Total__c != Null AND ASI_MFM_Proposed_Outet_Coverage_Total__c != \'\' ) AND ( ASI_MFM_CN_After_End_Date_Alert__c = FALSE OR ASI_MFM_CN_Before_10_Day_Alert__c = FALSE )';
        
        return Database.getQueryLocator(queryStr);
    }
    
    global void execute(Database.BatchableContext BC,  List<sObject> scope){
        
        Map<id, ASI_MFM_Event__c> mapBefore10DayEvent = new Map<id, ASI_MFM_Event__c>();
        Map<id, ASI_MFM_Event__c> mapAfterEndDayEvent = new Map<id, ASI_MFM_Event__c>();
        Map<id, Integer> countingMapB4 = new Map<id, Integer>();
        Map<id, Integer> countingMapAf = new Map<id, Integer>();
        List<Task> newTasks = new List<Task>();
        
        for(sObject obj : scope){
            
            if(date.today() < date.valueOf(obj.get('ASI_MFM_Start_Date__c')) && date.today() >= date.valueOf(obj.get('ASI_MFM_Start_Date__c')).addDays(-10) && !boolean.valueOf(obj.get('ASI_MFM_CN_Before_10_Day_Alert__c'))){
                
                mapBefore10DayEvent.put(obj.id, (ASI_MFM_Event__c) obj);
            }else if(date.today() > date.valueOf(obj.get('ASI_MFM_End_Date__c')) && !boolean.valueOf(obj.get('ASI_MFM_CN_After_End_Date_Alert__c'))){
                
                mapAfterEndDayEvent.put(obj.id, (ASI_MFM_Event__c) obj);
            }
        }
        if(mapBefore10DayEvent.size() > 0)
        	countingMapB4 = countOutLet(mapBefore10DayEvent.keySet());
        if(mapAfterEndDayEvent.size() > 0)
        	countingMapAf = countOutLet(mapAfterEndDayEvent.keySet());
        
        for(sObject obj : scope){
            
            //if(obj.get('ASI_MFM_Proposed_Outet_Coverage_Total__c') != Null && obj.get('ASI_MFM_Proposed_Outet_Coverage_Total__c') != ''){
            if(countingMapB4.containsKey(obj.id)){
                try{
                    if(Double.valueOf(countingMapB4.get(obj.id))/Double.valueOf(obj.get('ASI_MFM_Proposed_Outet_Coverage_Total__c')) < 0.5){
                        
                        String description = '';
                        Task newTask = new Task();
                        
                        newTask.RecordTypeId = Global_RecordTypeCache.getRtId('TaskASI_CRM_CN_Task');
                        newTask.Subject = '活动提醒 : 活动 ' + mapBefore10DayEvent.get(obj.id).Name + ' 的活动店家数少于预期参与店家数的50%';
                        newTask.Status = 'In Progress';
                        newTask.Priority = 'Normal';
                        newTask.OwnerId = mapBefore10DayEvent.get(obj.id).OwnerId;
                        newTask.WhatID = obj.id;
                        newTask.ReminderDateTime = date.today().addDays(-1);
                        description = 'Event ID ' + mapBefore10DayEvent.get(obj.id).ASI_MFM_Event_ID__c + ' with less than 50% outlet upload within 10 days before event start';
                        description += '\r\n\r\nKindly noticed that the uploaded outlet number is less than 50% of proposed outlet number. Pls upload the outlets in time or adjust your proposed outlet coverage. THX.';
                        description += '\r\n请注意：您已上传的活动店家数少于预期参与店家数的50%，请及时上传活动店家或者及时调整预期参与店家数。谢谢！';
                        description += '\r\nEvent ID : ' + mapBefore10DayEvent.get(obj.id).ASI_MFM_Event_ID__c;
                        description += '\r\nEvent Name : ' + mapBefore10DayEvent.get(obj.id).Name;
                        description += '\r\nProposed Start Date : ' + mapBefore10DayEvent.get(obj.id).ASI_MFM_Start_Date__c.year() + '-' + mapBefore10DayEvent.get(obj.id).ASI_MFM_Start_Date__c.month() + '-' + mapBefore10DayEvent.get(obj.id).ASI_MFM_Start_Date__c.day();
                        description += '\r\nProposed End Date : ' + mapBefore10DayEvent.get(obj.id).ASI_MFM_End_Date__c.year() + '-' + mapBefore10DayEvent.get(obj.id).ASI_MFM_End_Date__c.month() + '-' + mapBefore10DayEvent.get(obj.id).ASI_MFM_End_Date__c.day();
                        description += '\r\nKey Event Type : ' + mapBefore10DayEvent.get(obj.id).ASI_MFM_Event_Type__c;
                        description += '\r\nProposed Outlet Coverage (Total) : ' + mapBefore10DayEvent.get(obj.id).ASI_MFM_Proposed_Outet_Coverage_Total__c;
                        description += '\r\nTotal Number of Outlet Uploaded : ' + countingMapB4.get(obj.id);
                        newTask.Description = description;
                        
                        obj.put('ASI_MFM_CN_Before_10_Day_Alert__c', TRUE);
                        
                        newTasks.add(newTask);
                    }
                }catch(exception e){
                    
                }
            }
            
            if(countingMapAf.containsKey(obj.id)){
                try{
                    if(countingMapAf.get(obj.id) != integer.valueOf(obj.get('ASI_MFM_Proposed_Outet_Coverage_Total__c'))){
                    
                        String description = '';
                        Task newTask = new Task();
                    
                        newTask.RecordTypeId = Global_RecordTypeCache.getRtId('TaskASI_CRM_CN_Task');
                        newTask.Subject = '活动提醒 : 活动 ' + mapAfterEndDayEvent.get(obj.id).Name + ' 的活动店家数不等于预期参与店家数';
                        newTask.Status = 'In Progress';
                        newTask.Priority = 'Normal';
                        newTask.OwnerId = mapAfterEndDayEvent.get(obj.id).OwnerId;
                        newTask.WhatID = obj.id;
                        newTask.ReminderDateTime = date.today().addDays(-1);
                        description = 'Event ID ' + mapAfterEndDayEvent.get(obj.id).ASI_MFM_Event_ID__c + ' uploaded outlet number is not equals to proposed outlet coverage';
                        description += '\r\n\r\nKindly noticed that the uploaded outlet number  is not equals to proposed outlet coverage. Pls check the outlet list or adjust your proposed outlet coverage. THX.';
                        description += '\r\n请注意：您已上传的活动店家数不等于预期参与店家数，请检查您已上传的活动店家或者调整预期参与店家数。谢谢！';
                        description += '\r\nEvent ID : ' + mapAfterEndDayEvent.get(obj.id).ASI_MFM_Event_ID__c;
                        description += '\r\nEvent Name : ' + mapAfterEndDayEvent.get(obj.id).Name;
                        description += '\r\nProposed Start Date : ' + mapAfterEndDayEvent.get(obj.id).ASI_MFM_Start_Date__c.year() + '-' + mapAfterEndDayEvent.get(obj.id).ASI_MFM_Start_Date__c.month() + '-' + mapAfterEndDayEvent.get(obj.id).ASI_MFM_Start_Date__c.day();
                        description += '\r\nProposed End Date : ' + mapAfterEndDayEvent.get(obj.id).ASI_MFM_End_Date__c.year() + '-' + mapAfterEndDayEvent.get(obj.id).ASI_MFM_End_Date__c.month() + '-' + mapAfterEndDayEvent.get(obj.id).ASI_MFM_End_Date__c.day();
                        description += '\r\nKey Event Type : ' + mapAfterEndDayEvent.get(obj.id).ASI_MFM_Event_Type__c;
                        description += '\r\nProposed Outlet Coverage (Total) : ' + mapAfterEndDayEvent.get(obj.id).ASI_MFM_Proposed_Outet_Coverage_Total__c;
                        description += '\r\nTotal Number of Outlet Uploaded : ' + countingMapAf.get(obj.id);
                        newTask.Description = description;
                    
                        obj.put('ASI_MFM_CN_After_End_Date_Alert__c', TRUE);
                    
                        newTasks.add(newTask);
                    }
                }catch(exception e){
                    
                }
            }
        }
        insert newTasks;
        update scope;
    }
    
    global void finish(Database.BatchableContext BC){
		database.executebatch(new ASI_CRM_CN_EventNoti_Batch());
    } 
    
    private Map<id, Integer> countOutLet(Set<id> recordSet){
        
        Map<id, Integer> countingMap = new Map<id, Integer>();
        Map<String, String> duplicateOutlet = new Map<String, String>();
        
        for(ASI_MFM_Event_Outlet__c obj : [SELECT id, ASI_MFM_Event__c, ASI_MFM_Outlet__c FROM ASI_MFM_Event_Outlet__c WHERE ASI_MFM_Event__c IN : recordSet]){
            
            if(!countingMap.containsKey(obj.ASI_MFM_Event__c)){
                    
                countingMap.put(obj.ASI_MFM_Event__c, 1);
                duplicateOutlet.put(obj.ASI_MFM_Event__c + '' + obj.ASI_MFM_Outlet__c, '');
                
            }else{
                if(!duplicateOutlet.containsKey(obj.ASI_MFM_Event__c + '' + obj.ASI_MFM_Outlet__c)){
                    
                    countingMap.put(obj.ASI_MFM_Event__c, countingMap.get(obj.ASI_MFM_Event__c)+1);
                    duplicateOutlet.put(obj.ASI_MFM_Event__c + '' + obj.ASI_MFM_Outlet__c, '');
                }
            }
        }
        
        for(id obj : recordSet){
            if(!countingMap.containsKey(obj))
                countingMap.put(obj, 0);
        }
        
        return countingMap;
    }
}