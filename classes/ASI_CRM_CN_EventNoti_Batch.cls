global without sharing class ASI_CRM_CN_EventNoti_Batch implements Database.Batchable<sObject> ,Database.Stateful{
   global Database.QueryLocator start(Database.BatchableContext BC){
       date a = date.today().addDays(1);
      String soqlQuery = 'SELECT Id, ASI_MFM_Outlet__c,ASI_CRM_CN_EvaluationCreated__c, ASI_MFM_Beginning_Date__c, ASI_MFM_Event__r.ASI_MFM_Start_Date__c,ASI_MFM_Event__r.OwnerId, ASI_MFM_Outlet__r.Name, ASI_MFM_Event__r.Name, ASI_MFM_Event__r.ASI_MFM_CN_Chinese_Name__c FROM ASI_MFM_Event_Outlet__c where ASI_MFM_Beginning_Date__c = :a';//ASI_MFM_End_Date__c <= TOMORROW';
   
      return Database.getQueryLocator(soqlQuery);
   }

   global void execute(Database.BatchableContext BC,  List<sObject> scope){
       if (scope == null) return;
       
       List<ASI_CRM_Event_Evaluation__c> newEventEvaluations = new List<ASI_CRM_Event_Evaluation__c>();
       List<Task> newTasks = new List<Task>();
       
       Map<String, String> outletMap = new Map<String, String>();
       
       for(sObject sObj : scope){
           ASI_MFM_Event_Outlet__c eventOutlet = (ASI_MFM_Event_Outlet__c) sObj;
           
           outletMap.put(eventOutlet.ASI_MFM_Outlet__c,eventOutlet.ASI_MFM_Outlet__c); 
       }
       
       List<ASI_CRM_AccountsAdditionalField__c> customers = [SELECT Id,ASI_CRM_Account__c,ASI_CRM_CN_PG_Head__c,OwnerId FROM ASI_CRM_AccountsAdditionalField__c WHERE ASI_CRM_Account__c IN :outletMap.KeySet()];
       Map<String, ASI_CRM_AccountsAdditionalField__c> customerMap = new Map<String, ASI_CRM_AccountsAdditionalField__c>();
       
       for(ASI_CRM_AccountsAdditionalField__c customer : customers){
           if(!customerMap.containsKey(customer.ASI_CRM_Account__c))
               customerMap.put(customer.ASI_CRM_Account__c, customer);
       }
       for(sObject sObj : scope){
           
           ASI_CRM_AccountsAdditionalField__c eventEvaluationCustomer = null;
           ASI_MFM_Event_Outlet__c eventOutlet = (ASI_MFM_Event_Outlet__c) sObj;

           if(customerMap.containsKey(eventOutlet.ASI_MFM_Outlet__c))
               eventEvaluationCustomer = customerMap.get(eventOutlet.ASI_MFM_Outlet__c);
			
           
           
           for(integer i = 0 ; i < 3 ; i++ ){
               id ownerid;
               if(i == 0){
                   ownerid = eventEvaluationCustomer.OwnerId;
               }else if(i == 1){
                   ownerid = eventOutlet.ASI_MFM_Event__r.OwnerId;
               }else if(i == 2){
                   if(eventEvaluationCustomer.ASI_CRM_CN_PG_Head__c == null)
                       continue;
                   ownerid = eventEvaluationCustomer.ASI_CRM_CN_PG_Head__c;
               }
               
               system.debug('check111 ' + ownerid);
               
               Task newTask = new Task();
                       
               newTask.RecordTypeId = Global_RecordTypeCache.getRtId('TaskASI_CRM_CN_Task');
               newTask.Subject = '活动提醒 : 活动 ' + eventOutlet.ASI_MFM_Event__r.Name + ' 將在' + Date.today().addDays(1).year() + '年' + Date.today().addDays(1).month() + '月' + Date.today().addDays(1).day() + '举办';
               newTask.Status = 'In Progress';
               newTask.ActivityDate = Date.today();
               newTask.Priority = 'Normal';
               newTask.OwnerId = ownerid;
               newTask.WhatId = eventOutlet.ASI_MFM_Event__c;
               newTask.ReminderDateTime = date.today();
               newTask.Description = 'Kindly Noticed that ' + eventOutlet.ASI_MFM_Event__r.Name + ' will be taken place at ' + eventOutlet.ASI_MFM_Outlet__r.Name + ' on ' + Date.today().addDays(1).year() + '/' + Date.today().addDays(1).month() + '/' + Date.today().addDays(1).day() + '.\r\n请注意：店家' + eventOutlet.ASI_MFM_Outlet__r.Name + '在' + Date.today().addDays(1).year() + '年' + Date.today().addDays(1).month() + '月' + Date.today().addDays(1).day() + '将会举办一场' + eventOutlet.ASI_MFM_Event__r.ASI_MFM_CN_Chinese_Name__c + '活动，敬请期待！';//'活动將在明天' + Date.today().addDays(1).year() + '年' + Date.today().addDays(1).month() + '月' + Date.today().addDays(1).day() + '舉行';
               newTasks.add(newTask);
           }
       }
       insert newTasks;
   }

   global void finish(Database.BatchableContext BC){

   }
}