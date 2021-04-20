/*
Developed by StellaLi
Test Class for ASI_CRM_CN_Delete_Call_Plan
*/
@isTest(SeeAllData=true)
private without sharing class ASI_CRM_CN_DeleteCallPlan_WebserviceTest{
    private Class CallPlanDel {
    private list <CallPlanDelStructure> CallPlanDelList{set;get;}        
    }
    
 @isTest static void ASI_CRM_CN_Delete_Call_Plan() {    
       StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        /*insert account*/
        Id rt1 = Global_RecordTypeCache.getRtId('AccountASI_CRM_CN_Wholesales_CN');
        Account a = new Account(Name='TEST', RecordTypeId=rt1);
        insert a;
       
        /*insert customer*/   
        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='TEST',RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Region__cASI_CRM_CN_Region'));
        insert region;
        
        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id,RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Division__cASI_CRM_CN_Region'));
        insert division;
        
        
        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id,RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_CN_Area__cASI_CRM_CN_Area'));
        insert area;
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id,RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_City__cASI_CRM_CN_City'));
        insert city;
                
        Id rt2 = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
        ASI_CRM_AccountsAdditionalField__c ass =  new ASI_CRM_AccountsAdditionalField__c(Name='TEST',ASI_CRM_Account__c=a.Id, RecordTypeId= rt2,ASI_CRM_CN_CCity__c=city.Id);
        insert ass;
        
          
        Id rt3 = Global_RecordTypeCache.getRtId('EventASI_CRM_CN_Call_Plan');
       
        /*insert callplan*/
        Event testCallPlan = new Event(Subject='Call Plan:'+ass.Name,recordTypeId=rt3,StartDateTime=Datetime.now(),EndDateTime=Datetime.now(),IsAllDayEvent =true,WhatID =ass.id);
        insert testCallPlan;
        
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, mock);
        
        /*delete test*/
        Test.startTest();
        string record = '{"CallPlanDelList":[{"RecordID":"' + testcallPlan.id+ '"}]}';
        ASI_CRM_CN_Delete_Call_Plan.Delete_Call_Plan(record);
        Test.stopTest();
 }
 
  private with sharing class CallPlanDelStructure{
      private String RecordID {set;get;}       
  } 
    
}