/*
    Developed by Kendy Tam: 03/04/2014
    Batch to generate the Stock-In-Trade Master, and reparent the Stock-In-Trade Detail
*/
global with sharing class ASI_TH_CRM_SITMaster_Generate_Batch implements Database.Batchable<sObject> ,Database.Stateful{ 

   global Database.QueryLocator start(Database.BatchableContext BC){
      String soqlQuery = 'SELECT ASI_TH_CRM_Account__c, CreatedById, ASI_TH_CRM_Date__c, ASI_TH_CRM_OfftakeSITDetail_External_ID__c, RecordTypeId, ASI_TH_CRM_Year__c,ASI_TH_CRM_Month__c FROM ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c WHERE ASI_TH_CRM_SIT__c = null ';
   
      System.debug('soqlQuery:' + soqlQuery);
   
      return Database.getQueryLocator(soqlQuery);
   }

   global void execute(Database.BatchableContext BC,  List<sObject> scope){
       if (scope == null) return;
       
       List<ASI_TH_CRM_Offtake_Stock_In_Trade__c> stockInTrades = new List<ASI_TH_CRM_Offtake_Stock_In_Trade__c>();
       
       Set<String> masterSet = new Set<String>();
       
       List<RecordType> recordTypes = [SELECT Id FROM RecordType WHERE DeveloperName = 'ASI_TH_CRM_SIT_Editable'];
       
       for(sObject sObj : scope){
           ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c stockInTradeDetail = (ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c) sObj;
           
           String master = stockInTradeDetail.ASI_TH_CRM_Account__c + stockInTradeDetail.ASI_TH_CRM_Year__c + stockInTradeDetail.ASI_TH_CRM_Month__c;
           
           if(!masterSet.contains(master)){  
               ASI_TH_CRM_Offtake_Stock_In_Trade__c stockInTrade = new ASI_TH_CRM_Offtake_Stock_In_Trade__c();
               
               stockInTrade.ASI_TH_CRM_Account__c = stockInTradeDetail.ASI_TH_CRM_Account__c;
               stockInTrade.ASI_TH_CRM_OfftakeSIT_External_ID__c = stockInTradeDetail.ASI_TH_CRM_OfftakeSITDetail_External_ID__c;
               stockInTrade.RecordTypeId = recordTypes[0].Id;
               stockInTrade.ASI_TH_CRM_Month__c = stockInTradeDetail.ASI_TH_CRM_Month__c ;
               stockInTrade.ASI_TH_CRM_Year__c = stockInTradeDetail.ASI_TH_CRM_Year__c;
               stockInTrade.ASI_TH_CRM_Status__c = 'Editable';
    
               stockInTrades.add(stockInTrade);
               
               masterSet.add(master);
           }
       }

       insert stockInTrades;
       
       for(sObject sObj : scope){
           ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c stockInTradeDetail = (ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c) sObj;
           
           for(ASI_TH_CRM_Offtake_Stock_In_Trade__c stockInTrade : stockInTrades){
               if(stockInTrade.ASI_TH_CRM_Account__c == stockInTradeDetail.ASI_TH_CRM_Account__c && stockInTrade.ASI_TH_CRM_Month__c == stockInTradeDetail.ASI_TH_CRM_Month__c && stockInTrade.ASI_TH_CRM_Year__c == stockInTradeDetail.ASI_TH_CRM_Year__c){
                   stockInTradeDetail.ASI_TH_CRM_SIT__c = stockInTrade.Id;
                   break;
               }
           }
       }
       
       update scope;
   }

   global void finish(Database.BatchableContext BC){

   }
}