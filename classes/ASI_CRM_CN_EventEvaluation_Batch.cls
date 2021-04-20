/*
    Developed by Kendy Tam: 21/06/2014
    Batch to generate the Event Evaluation 
*/
global without sharing class ASI_CRM_CN_EventEvaluation_Batch implements Database.Batchable<sObject> ,Database.Stateful{
   global Database.QueryLocator start(Database.BatchableContext BC){
      String soqlQuery = 'SELECT Id,ASI_MFM_Outlet__c,ASI_CRM_CN_EvaluationCreated__c, ASI_MFM_CN_Customer__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_CN_RTMK__c, ASI_MFM_Event__r.OwnerId, ASI_MFM_Event__r.Name FROM ASI_MFM_Event_Outlet__c where ASI_CRM_CN_EvaluationCreated__c = false and ASI_MFM_End_Date__c <= TOMORROW';
   
      System.debug('soqlQuery:' + soqlQuery);
   
      return Database.getQueryLocator(soqlQuery);
   }

   global void execute(Database.BatchableContext BC,  List<sObject> scope){
       if (scope == null) return;
       
       List<ASI_CRM_Event_Evaluation__c> newEventEvaluations = new List<ASI_CRM_Event_Evaluation__c>();
       List<Task> newTasks = new List<Task>();
       
       Map<String, String> outletMap = new Map<String, String>();


       //RecordType pgEventEvaluationRcrdTyp = [SELECT Id FROM RecordType WHERE DeveloperName = 'ASI_CRM_CN_PG_Event_Evaluation_Form'];
       //RecordType rtmtkEventEvaluationRcrdTyp = [SELECT Id FROM RecordType WHERE DeveloperName = 'ASI_CRM_CN_RTMTK'];
       //RecordType salesEventEvaluationRcrdTyp = [SELECT Id FROM RecordType WHERE DeveloperName = 'ASI_CRM_CN_sales_evaluation'];       
       
       String pgEventEvaluationRcrdTypId = Global_RecordTypeCache.getRtId('ASI_CRM_Event_Evaluation__cASI_CRM_CN_PG_Event_Evaluation_Form');
       String rtmtkEventEvaluationRcrdTypId = Global_RecordTypeCache.getRtId('ASI_CRM_Event_Evaluation__cASI_CRM_CN_RTMTK');
       String salesEventEvaluationRcrdTypId = Global_RecordTypeCache.getRtId('ASI_CRM_Event_Evaluation__cASI_CRM_CN_sales_evaluation');
       
       for(sObject sObj : scope){
           ASI_MFM_Event_Outlet__c eventOutlet = (ASI_MFM_Event_Outlet__c) sObj;
           
           outletMap.put(eventOutlet.ASI_MFM_Outlet__c,eventOutlet.ASI_MFM_Outlet__c); 
       }
       
       System.Debug('outletMap.KeySet(): ' + outletMap.KeySet());
       
       Map<String, Task> mapTask = new Map<String, Task>();
       List<ASI_CRM_AccountsAdditionalField__c> customers = [SELECT Id,ASI_CRM_Account__c,ASI_CRM_CN_PG_Head__c,OwnerId FROM ASI_CRM_AccountsAdditionalField__c WHERE ASI_CRM_Account__c IN :outletMap.KeySet()];
       Map<String, ASI_CRM_AccountsAdditionalField__c> customerMap = new Map<String, ASI_CRM_AccountsAdditionalField__c>();
       for(ASI_CRM_AccountsAdditionalField__c customer : customers){
           if(customerMap.containsKey(customer.ASI_CRM_Account__c))
           {
               
           } else
           {
               customerMap.put(customer.ASI_CRM_Account__c, customer);
           }
       }
       for(sObject sObj : scope){
           ASI_MFM_Event_Outlet__c eventOutlet = (ASI_MFM_Event_Outlet__c) sObj;
           
           ASI_CRM_AccountsAdditionalField__c eventEvaluationCustomer = null;
           
           System.Debug('customers.size(): ' + customers.size());
           
         //  for(ASI_CRM_AccountsAdditionalField__c customer : customers){
               if(customerMap.containsKey(eventOutlet.ASI_MFM_Outlet__c)){
                   eventEvaluationCustomer = customerMap.get(eventOutlet.ASI_MFM_Outlet__c);
               //    break;
               }
          // }
           
           ASI_CRM_Event_Evaluation__c pgEventEvaluation = new ASI_CRM_Event_Evaluation__c();
           pgEventEvaluation.ASI_CRM_CN_eventoutlet__c = eventOutlet.Id;
           pgEventEvaluation.ASI_CRM_CN_Outlet__c = eventOutlet.ASI_MFM_Outlet__c;
            pgEventEvaluation.RecordTypeId = pgEventEvaluationRcrdTypId;
           if(eventEvaluationCustomer != null){
               pgEventEvaluation.ASI_CRM_CN_Customer__c = eventEvaluationCustomer.Id;
               if(eventEvaluationCustomer.ASI_CRM_CN_PG_Head__c != null){
                   pgEventEvaluation.OwnerId = eventEvaluationCustomer.ASI_CRM_CN_PG_Head__c;
                   newEventEvaluations.add(pgEventEvaluation);
                   Task newTask = new Task();
                   newTask.RecordTypeId = Global_RecordTypeCache.getRtId('TaskASI_CRM_CN_Task');
                   newTask.Subject = '活动评估提醒 ' + eventOutlet.ASI_MFM_Event__r.Name;
                       newTask.Status = 'In Progress';
                   newTask.Priority = 'Normal';
                   newTask.ActivityDate = Date.today();
                   newTask.ReminderDateTime = System.now().addDays(-1);
                   newTask.OwnerId = eventEvaluationCustomer.ASI_CRM_CN_PG_Head__c;
                   //newTask.WhatID = eventOutlet.id;
                   newTask.Description = '请在' + System.now().addDays(14).year() + '年' + System.now().addDays(14).month() + '月' + System.now().addDays(14).day() + '日之前给 ' + eventOutlet.ASI_MFM_Event__r.Name + '进行评估，否则系统会自动默认为满分';
                   //newTasks.add(newTask);
                   mapTask.put(pgEventEvaluation.ASI_CRM_CN_eventoutlet__c + '' + pgEventEvaluation.ASI_CRM_CN_Outlet__c + '' + pgEventEvaluation.RecordTypeId, newTask);
               }else{
                   //pgEventEvaluation.OwnerId = eventEvaluationCustomer.OwnerId;
               }             
           }else{
              // pgEventEvaluation.OwnerId = eventOutlet.ASI_MFM_Event__r.OwnerId;
           }
          
           
           
           if(eventOutlet.ASI_MFM_CN_Customer__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_CN_RTMK__c != Null){
               ASI_CRM_Event_Evaluation__c rtmtkEventEvaluation = new ASI_CRM_Event_Evaluation__c();
               rtmtkEventEvaluation.ASI_CRM_CN_eventoutlet__c = eventOutlet.Id;
               rtmtkEventEvaluation.ASI_CRM_CN_Outlet__c = eventOutlet.ASI_MFM_Outlet__c;
               rtmtkEventEvaluation.OwnerId = eventOutlet.ASI_MFM_CN_Customer__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_CN_RTMK__c;
               rtmtkEventEvaluation.RecordTypeId = rtmtkEventEvaluationRcrdTypId;
               if(eventEvaluationCustomer != null){
                   rtmtkEventEvaluation.ASI_CRM_CN_Customer__c = eventEvaluationCustomer.Id;
                   newEventEvaluations.add(rtmtkEventEvaluation);
                   Task newTask = new Task();
                   newTask.RecordTypeId = Global_RecordTypeCache.getRtId('TaskASI_CRM_CN_Task');
                       newTask.Subject = '活动评估提醒 ' + eventOutlet.ASI_MFM_Event__r.Name;
                           newTask.Status = 'In Progress';
                       newTask.Priority = 'Normal';
                   newTask.ActivityDate = Date.today();
                   newTask.OwnerId = eventOutlet.ASI_MFM_Event__r.OwnerId;
                       newTask.ReminderDateTime = System.now();
                       //newTask.WhatID = eventOutlet.id;
                       newTask.Description = '请在' + System.now().addDays(14).year() + '年' + System.now().addDays(14).month() + '月' + System.now().addDays(14).day() + '日之前给 ' + eventOutlet.ASI_MFM_Event__r.Name + '进行评估，否则系统会自动默认为满分';
                       //newTasks.add(newTask);
                   mapTask.put(rtmtkEventEvaluation.ASI_CRM_CN_eventoutlet__c + '' + rtmtkEventEvaluation.ASI_CRM_CN_Outlet__c + '' + rtmtkEventEvaluation.RecordTypeId, newTask);
                   //rtmtkEventEvaluation.OwnerId = eventEvaluationCustomer.OwnerId;
               }/*else{
                   pgEventEvaluation.OwnerId = eventOutlet.ASI_MFM_Event__r.OwnerId;
               }*/
           }
           
           ASI_CRM_Event_Evaluation__c salesEventEvaluation = new ASI_CRM_Event_Evaluation__c();
           salesEventEvaluation.ASI_CRM_CN_eventoutlet__c = eventOutlet.Id;
           salesEventEvaluation.ASI_CRM_CN_Outlet__c = eventOutlet.ASI_MFM_Outlet__c;
           salesEventEvaluation.RecordTypeId = salesEventEvaluationRcrdTypId;
           if(eventEvaluationCustomer != null){
               salesEventEvaluation.ASI_CRM_CN_Customer__c = eventEvaluationCustomer.Id;
               salesEventEvaluation.OwnerId = eventEvaluationCustomer.OwnerId;
               newEventEvaluations.add(salesEventEvaluation);
               Task newTask = new Task();
               newTask.RecordTypeId = Global_RecordTypeCache.getRtId('TaskASI_CRM_CN_Task');
                   newTask.Subject = '活动评估提醒 ' + eventOutlet.ASI_MFM_Event__r.Name;
                       newTask.Status = 'In Progress';
                   newTask.Priority = 'Normal';
               newTask.ActivityDate = Date.today();
               newTask.OwnerId = eventEvaluationCustomer.OwnerId;
                   newTask.ReminderDateTime = System.now();
                   //newTask.WhatID = eventOutlet.id;
                   newTask.Description = '请在' + System.now().addDays(14).year() + '年' + System.now().addDays(14).month() + '月' + System.now().addDays(14).day() + '日之前给 ' + eventOutlet.ASI_MFM_Event__r.Name + '进行评估，否则系统会自动默认为满分';
                   //newTasks.add(newTask);
               mapTask.put(salesEventEvaluation.ASI_CRM_CN_eventoutlet__c + '' + salesEventEvaluation.ASI_CRM_CN_Outlet__c + '' + salesEventEvaluation.RecordTypeId, newTask);
           }/*else{
               salesEventEvaluation.OwnerId = eventOutlet.ASI_MFM_Event__r.OwnerId;
           }*/
           eventOutlet.ASI_CRM_CN_EvaluationCreated__c = true;
       }
       List<Database.SaveResult> results = new List<Database.SaveResult>();
       List<id> headerID = new List<id>();
       results = database.insert(newEventEvaluations,true);
       //insert newEventEvaluations;
       for(Database.SaveResult res: results){
           if(res.isSuccess()){
               headerID.add(res.getId());
           }
       }
       List<ASI_CRM_Event_Evaluation__c> eventEval = new List<ASI_CRM_Event_Evaluation__c>([SELECT id
                                                                                            , ASI_CRM_CN_eventoutlet__c
                                                                                            , ASI_CRM_CN_Outlet__c
                                                                                            , RecordTypeId
                                                                                            FROM ASI_CRM_Event_Evaluation__c
                                                                                            WHERE id IN : headerID
                                                                                           ]);
       for(ASI_CRM_Event_Evaluation__c obj : eventEval){
           if(mapTask.containsKey(obj.ASI_CRM_CN_eventoutlet__c + '' + obj.ASI_CRM_CN_Outlet__c + '' + obj.RecordTypeId))
               mapTask.get(obj.ASI_CRM_CN_eventoutlet__c + '' + obj.ASI_CRM_CN_Outlet__c + '' + obj.RecordTypeId).whatId = obj.id;
           newTasks.add(mapTask.get(obj.ASI_CRM_CN_eventoutlet__c + '' + obj.ASI_CRM_CN_Outlet__c + '' + obj.RecordTypeId));
       }
       insert newTasks;
       update scope;
   }

   global void finish(Database.BatchableContext BC){
		database.executebatch(new ASI_CRM_CN_EventAlert_Batch());
   } 
}