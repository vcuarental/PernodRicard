/*
*Created by Stella Li 16th Sep 2014
*/
public with sharing class ASI_CRM_Competitor_Contract_TriggerClass{
   public static String className = 'ASI_CRM_Competitor_Contract_TriggerClass';
  
   public static void routineAfterInsertAfterUpdate(list<ASI_CRM_Competitor_Contract__c> trigger_new){   
    if(!ASI_CRM_CN_Function.IsBypassTrigger(className)) {             
      Set<id> i = new set<id>();
      For (ASI_CRM_Competitor_Contract__c e :trigger_new){ 
          if(!i.contains(e.ASI_CRM_WS_Outlet__c)){
           i.add(e.ASI_CRM_WS_Outlet__c);
           } 
      }
      /*updated by Stella Li 14th Jan 2015,use map*/
      list <ASI_CRM_AccountsAdditionalField__c> customer = new list <ASI_CRM_AccountsAdditionalField__c>();   
      customer  = [SELECT id, ASI_CRM_CN_Competitor_Contract_EndDate__c,ASI_CRM_CN_Competitor_Contract_StartDate__c FROM ASI_CRM_AccountsAdditionalField__c WHERE Id IN:i];        
      map<id,ASI_CRM_AccountsAdditionalField__c> customermap =new map<id,ASI_CRM_AccountsAdditionalField__c>(customer);
      Date customerEndDate=date.today();
      Date customerStartDate=date.today();
      For (ASI_CRM_Competitor_Contract__c e :trigger_new){ 
          if(customermap.get(e.ASI_CRM_WS_Outlet__c)!=null){
              customerEndDate=customermap.get(e.ASI_CRM_WS_Outlet__c).ASI_CRM_CN_Competitor_Contract_EndDate__c;
              customerStartDate=customermap.get(e.ASI_CRM_WS_Outlet__c).ASI_CRM_CN_Competitor_Contract_StartDate__c; 
              if(e.ASI_CRM_PO_Start__c!=null){           
                  if(customerStartDate==null ||(customerStartDate!=null && e.ASI_CRM_PO_Start__c<customerStartDate)){
                      customermap.get(e.ASI_CRM_WS_Outlet__c).ASI_CRM_CN_Competitor_Contract_StartDate__c=e.ASI_CRM_PO_Start__c;
                      customermap.put(e.ASI_CRM_WS_Outlet__c,customermap.get(e.ASI_CRM_WS_Outlet__c));
                  }
               }
              if(e.ASI_CRM_PO_End__c!=null){
                  if(customerEndDate ==null || (customerEndDate!=null && e.ASI_CRM_PO_End__c>customerEndDate)){
                      customermap.get(e.ASI_CRM_WS_Outlet__c).ASI_CRM_CN_Competitor_Contract_EndDate__c=e.ASI_CRM_PO_End__c;
                      customermap.put(e.ASI_CRM_WS_Outlet__c,customermap.get(e.ASI_CRM_WS_Outlet__c));
                  }
              }
          }
      }
      update customermap.values();
    }
   }
 }