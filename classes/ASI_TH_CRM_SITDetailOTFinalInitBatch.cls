/*
    Developed by Kendy Tam: 08/04/2014
    Batch to Init Stock-In-Trade Detail
*/
global with sharing class ASI_TH_CRM_SITDetailOTFinalInitBatch implements Database.Batchable<sObject> ,Database.Stateful{
   global Database.QueryLocator start(Database.BatchableContext BC){
      String soqlQuery = 'SELECT ASI_TH_CRM_Account_2nd_Upload__c , ASI_TH_CRM_Sub_brand__c, ASI_TH_CRM_Year__c , ASI_TH_CRM_Month__c, ASI_TH_CRM_Total_Offtake_Final__c  FROM ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c WHERE RecordType.DeveloperName = \'ASI_TH_CRM_MT_SITD_Temp\'';
   
      System.debug('soqlQuery:' + soqlQuery);
   
      return Database.getQueryLocator(soqlQuery);
   }

   global void execute(Database.BatchableContext BC,  List<sObject> scope){
       if (scope == null) return;
       
       Map<id, ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c> delTempStockInTradDetails = new Map<id, ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c>();
       
       List<String> accounts = new List<String>();
       List<String> subBrands = new List<String>();
       List<String> years = new List<String>();
       List<String> months = new List<String>();
       
       for(sObject sObj : scope){
           ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c tempStockInTradeDetail = (ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c) sObj;
           
           accounts.add(tempStockInTradeDetail.ASI_TH_CRM_Account_2nd_Upload__c);
           subBrands.add(tempStockInTradeDetail.ASI_TH_CRM_Sub_brand__c);
           years.add(tempStockInTradeDetail.ASI_TH_CRM_Year__c);
           months.add(tempStockInTradeDetail.ASI_TH_CRM_Month__c);
       }

       List<ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c> existStockInTradeDetails = [SELECT ASI_TH_CRM_Account__c, ASI_TH_CRM_Sub_brand__c, ASI_TH_CRM_Year__c, ASI_TH_CRM_Month__c, ASI_TH_CRM_Total_Offtake_Final__c FROM ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c WHERE RecordType.DeveloperName = 'ASI_TH_CRM_MT_Stock_In_Trade_Detail' AND ASI_TH_CRM_Account__c IN :accounts AND ASI_TH_CRM_Sub_brand__c IN :subBrands AND ASI_TH_CRM_Year__c IN :years AND ASI_TH_CRM_Month__c IN :months];
       
       for(ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c existStockInTradeDetail : existStockInTradeDetails){
           for(sObject sObj : scope){
               ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c tempStockInTradeDetail = (ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c) sObj;
               
               if(tempStockInTradeDetail.ASI_TH_CRM_Account_2nd_Upload__c == existStockInTradeDetail.ASI_TH_CRM_Account__c &&
                   tempStockInTradeDetail.ASI_TH_CRM_Sub_brand__c == existStockInTradeDetail.ASI_TH_CRM_Sub_brand__c && 
                   tempStockInTradeDetail.ASI_TH_CRM_Year__c == existStockInTradeDetail.ASI_TH_CRM_Year__c && 
                   tempStockInTradeDetail.ASI_TH_CRM_Month__c == existStockInTradeDetail.ASI_TH_CRM_Month__c){
                   if(existStockInTradeDetail.ASI_TH_CRM_Total_Offtake_Final__c == null || existStockInTradeDetail.ASI_TH_CRM_Total_Offtake_Final__c == 0){
                       existStockInTradeDetail.ASI_TH_CRM_Total_Offtake_Final__c = tempStockInTradeDetail.ASI_TH_CRM_Total_Offtake_Final__c;
                   }else{
                       existStockInTradeDetail.ASI_TH_CRM_Total_Offtake_Final__c = existStockInTradeDetail.ASI_TH_CRM_Total_Offtake_Final__c + tempStockInTradeDetail.ASI_TH_CRM_Total_Offtake_Final__c;
                   }
                   
                    if(!delTempStockInTradDetails.containsKey(tempStockInTradeDetail.id))
                        delTempStockInTradDetails.put(tempStockInTradeDetail.id, tempStockInTradeDetail);
                   break;   
               }
           }
       }
       
       update existStockInTradeDetails;
       
       delete delTempStockInTradDetails.values();
   }

   global void finish(Database.BatchableContext BC){
   /*
       AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :BC.getJobId()];
        // Send an email to the Apex job's submitter notifying of job completion. 
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       String[] toAddresses = new String[] {a.CreatedBy.Email};
       mail.setToAddresses(toAddresses);
       mail.setSubject('Stock-In-Trade Detail Offtake Total Init Batch finished');
       mail.setPlainTextBody('The batch Apex job status:' +  + a.Status + ', processed ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures.');
       System.debug('The batch Apex job status:' +  + a.Status + ', processed ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures.');
       Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });        
   */
   } 
}