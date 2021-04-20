/*Created by Twinkle Li @10/17/2014
/*
*/
global class ASI_CRM_CN_UpdateChannelStrategy_Batch implements Database.Batchable<sObject>{
   
   global Database.QueryLocator start(Database.BatchableContext BC){
      String soqlQuery = 'Select id, ASI_CRM_CN_Sub_Channel__c, ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.id, ASI_CRM_CN_Image__c From ASI_CRM_AccountsAdditionalField__c WHERE RecordType.DeveloperName = \'ASI_CRM_Outlet_CN\'';  
      System.debug('soqlQuery:' + soqlQuery);
      return Database.getQueryLocator(soqlQuery);
   }
   
    global void execute(Database.BatchableContext BC,  List<sObject> scope){
      if (scope == null) return;
      
      Date myDate = date.today();
      String FiscalYear;
      
      if(myDate.month() >= 7){
          FiscalYear = String.valueof(myDate.year()) +'/'+ String.valueof(myDate.year()+1);
          system.debug(FiscalYear);
      } 
      else{
          FiscalYear = String.valueof(myDate.year()-1) +'/'+ String.valueof(myDate.year());
          system.debug(FiscalYear);
      }
      
      List<ASI_CRM_CN_Channel_Strategy__c> LChannelS = [Select id, RecordType.DeveloperName, ASI_CRM_CN_Sub_Channel__c, ASI_CRM_CN_Area__r.id, ASI_CRM_CN_Image__c From ASI_CRM_CN_Channel_Strategy__c Where (RecordType.DeveloperName = 'ASI_CRM_CN_Area' OR RecordType.DeveloperName = 'ASI_CRM_CN_National') AND ASI_CRM_CN_Status__c = 'Final' and ASI_CRM_CN_Fiscal_Year__c =: FiscalYear];  
      List<ASI_CRM_AccountsAdditionalField__c> LCust = scope;      
      Map<String,String> MChannelA = new Map<String,String>();
      Map<String,String> MChannelN = new Map<String,String>();
      
      for(ASI_CRM_CN_Channel_Strategy__c channel : LChannelS){
          if(channel.RecordType.DeveloperName == 'ASI_CRM_CN_Area'){
              MChannelA.put(channel.ASI_CRM_CN_Sub_Channel__c + String.valueof(channel.ASI_CRM_CN_Area__r.id) + channel.ASI_CRM_CN_Image__c, channel.id);
          }
          else if(channel.RecordType.DeveloperName == 'ASI_CRM_CN_National'){
              MChannelN.put(channel.ASI_CRM_CN_Sub_Channel__c + channel.ASI_CRM_CN_Image__c, channel.id);
          }
      }
      
      for(ASI_CRM_AccountsAdditionalField__c cust : LCust){
          if(MChannelA.get(cust.ASI_CRM_CN_Sub_Channel__c + String.valueof(cust.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.id) + cust.ASI_CRM_CN_Image__c) != NULL){
              cust.ASI_CRM_CN_Channel_Strategy__c = MChannelA.get(cust.ASI_CRM_CN_Sub_Channel__c + String.valueof(cust.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.id) + cust.ASI_CRM_CN_Image__c);
          }
          else if(MChannelN.get(cust.ASI_CRM_CN_Sub_Channel__c + cust.ASI_CRM_CN_Image__c) != NULL){
              cust.ASI_CRM_CN_Channel_Strategy__c = MChannelN.get(cust.ASI_CRM_CN_Sub_Channel__c + cust.ASI_CRM_CN_Image__c);
          }
      }
      update LCust;   
   }

   global void finish(Database.BatchableContext BC){
   } 
   
}