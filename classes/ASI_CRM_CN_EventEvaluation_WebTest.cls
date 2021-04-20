/*
Developed by StellaLi
Test Class for ASI_CRM_CN_Update_Event_Evaluation
*/
@isTest(SeeAllData=true)
private class ASI_CRM_CN_EventEvaluation_WebTest{
  private Class EventEvaluation{
    private list <EventEvaluationStructure> EventEvaluationList{set;get;} 
  }

 @isTest static void ASI_CRM_CN_Update_Event_Evaluation() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        
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
        ASI_CRM_AccountsAdditionalField__c ass =  new ASI_CRM_AccountsAdditionalField__c(Name='TEST',RecordTypeId= rt2,ASI_CRM_CN_CCity__c=city.Id);
        insert ass;
        
        //ASI_MFM_Event_Outlet__c eo = new ASI_MFM_Event_Outlet__c();
        ASI_CRM_Event_Evaluation__c ee = new ASI_CRM_Event_Evaluation__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Event_Evaluation__cASI_CRM_CN_sales_evaluation'),ASI_CRM_CN_Customer__c=ass.id);        
        insert ee;
        
        Test.startTest(); 
        string record1 = '{"EventEvaluationList":[{"RecordID":"'+ee.id+'","Local_Update_Time":"2014/11/28 11:49","Satisfaction_Gift_PG":"5","Satisfaction_Gift_Comment_PG":"good","Topic":"5","Topic_Comment":"good","Performance":"5","Performance_Comment":"good","Display":"5","Display_Comment":"good","Interaction":"5","Interaction_Comment":"good","Peformance_2":"5","Performance_2_Comment":"good","Early_Communication":"5","Early_Communication_Comment":"good","Event_Creativity":"5","Event_Creativity_Comment":"good","Event_Display":"5","Event_DisplayComment":"good","Consumer_Interaction":"5","Consumer_InteractionComment":"good","Event_Performance":"5","Event_PerformanceComment":"good","Satisfaction_Gift":"5","Satisfaction_GiftComment":"good","Event_Coordination":"5","Event_Coordination_Comment":"good","Amount_Gift":"5","Amount_Gift_Comment":"good","Store_Communication":"5","Store_Communication_Comment":"good","Promotion":"5","Promotion_Comment":"good"}]}';
        ASI_CRM_CN_Update_Event_Evaluation.UpdateEventEvaluation(record1);
        Test.stopTest();
        
 }
 
 
   private with sharing class EventEvaluationStructure{
    
    private String RecordID{set;get;}
    private String Local_Update_Time{set;get;}
    private string Satisfaction_Gift_PG{set;get;}
    private string Satisfaction_Gift_Comment_PG{set;get;}
    private string Topic{set;get;}
    private string Topic_Comment{set;get;}
    private string Performance{set;get;}
    private string Performance_Comment{set;get;}
    private string Display{set;get;}
    private string Display_Comment{set;get;}
    private string Interaction{set;get;}
    private string Interaction_Comment{set;get;}
    private string Peformance_2{set;get;}
    private string Performance_2_Comment{set;get;}
    private string Early_Communication{set;get;}
    private string Early_Communication_Comment{set;get;}
    private string Event_Creativity{set;get;}
    private string Event_Creativity_Comment{set;get;}
    private string Event_Display{set;get;}
    private string Event_DisplayComment{set;get;}
    private string Consumer_Interaction{set;get;}
    private string Consumer_InteractionComment{set;get;}
    private string Event_Performance{set;get;}
    private string Event_PerformanceComment{set;get;}
    private string Satisfaction_Gift{set;get;}
    private string RecordType{set;get;}
    private string Satisfaction_GiftComment{set;get;}
    private string Event_Coordination{set;get;}
    private string Event_Coordination_Comment{set;get;}
    private string Amount_Gift{set;get;}
    private string Amount_Gift_Comment{set;get;}
    private string Store_Communication{set;get;}
    private string Store_Communication_Comment{set;get;}
    private string Promotion{set;get;}
    private string Promotion_Comment{set;get;}
    
   }
    
  }