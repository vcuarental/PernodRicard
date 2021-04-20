/*
    Developed by Kendy Tam: 08/04/2014
    Batch to generate the RSP 
*/
global with sharing class ASI_TH_CRM_RSPGenerateBatch implements Database.Batchable<sObject> ,Database.Stateful{
   global Database.QueryLocator start(Database.BatchableContext BC){
      String soqlQuery = 'SELECT CreatedById, CurrencyIsoCode, OwnerId, RecordTypeId, ASI_TH_CRM_Sub_Brand__c FROM ASI_TH_CRM_RSP__c WHERE ASI_TH_CRM_Date__c = LAST_MONTH ORDER BY ASI_TH_CRM_Sub_Brand__c';
   
      System.debug('soqlQuery:' + soqlQuery);
   
      return Database.getQueryLocator(soqlQuery);
   }

   global void execute(Database.BatchableContext BC,  List<sObject> scope){
       if (scope == null) return;
       
       List<ASI_TH_CRM_RSP__c> thisMonthRSPs = new List<ASI_TH_CRM_RSP__c>();
       
       for(sObject sObj : scope){
           ASI_TH_CRM_RSP__c lastMonthRSP = (ASI_TH_CRM_RSP__c) sObj;
           
           ASI_TH_CRM_RSP__c thisMonthRSP = new ASI_TH_CRM_RSP__c();
           
           thisMonthRSP.CurrencyIsoCode = lastMonthRSP.CurrencyIsoCode;
           thisMonthRSP.OwnerId = lastMonthRSP.OwnerId;
           thisMonthRSP.RecordTypeId = lastMonthRSP.RecordTypeId;
           thisMonthRSP.ASI_TH_CRM_Sub_Brand__c = lastMonthRSP.ASI_TH_CRM_Sub_Brand__c;
           thisMonthRSP.ASI_TH_CRM_Date__c = Date.today();
           
           thisMonthRSPs.add(thisMonthRSP);
       }

       insert thisMonthRSPs;
   }

   global void finish(Database.BatchableContext BC){

   } 
}