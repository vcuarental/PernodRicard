/*
Developed by StellaLi
Used for IPAD Integration
*/
@RestResource(UrlMapping='/ASI_CRM_CN_Update_Event_Evaluation/*')
global without sharing class ASI_CRM_CN_Update_Event_Evaluation{
    global Class EventEvaluation{
    global list <EventEvaluationStructure> EventEvaluationlist{set;get;}    
    }
   
 @HttpPost
    global static string UpdateEventEvaluation (String jsonString ){ 
     
     EventEvaluation EventEvaluation1 = (EventEvaluation)JSON.deserialize(jsonString,EventEvaluation.class);     
     List <ASI_CRM_Event_Evaluation__c> a = New List<ASI_CRM_Event_Evaluation__c>();
        for(EventEvaluationStructure c1: EventEvaluation1.EventEvaluationlist) { 
            ASI_CRM_Event_Evaluation__c b = New ASI_CRM_Event_Evaluation__c();
            
             b.id = c1.RecordID;
             
             if(c1.Local_Update_Time!= null && c1.Local_Update_Time!= ''){
                   
                    integer YYYY = integer.valueof(c1.Local_Update_Time.left(4));
                    integer MM = integer.valueof(c1.Local_Update_Time.mid(5,2));
                    integer DD = integer.valueof(c1.Local_Update_Time.mid(8,2));
                    integer HH = integer.valueof(c1.Local_Update_Time.mid(11,2));
                    integer Min = integer.valueof(c1.Local_Update_Time.right(2));
                    b.ASI_CRM_Local_Update_Time__c = Datetime.newInstance(YYYY,MM,DD,HH,Min,0);}
            else{
                     b.ASI_CRM_Local_Update_Time__c = Datetime.now();
                  }
             b.ASI_CRM_CN_satisfaction_of_gift_pg__c=c1.Satisfaction_Gift_PG;
             b.ASI_CRM_CN_giftsatisfactcontentpg__c=c1.Satisfaction_Gift_Comment_PG;
             b.ASI_CRM_CN_topic__c=c1.Topic;
             b.ASI_CRM_CN_topiccontent__c=c1.Topic_Comment;
             b.ASI_CRM_CN_performance__c=c1.Performance;
             b.ASI_CRM_CN_performcontent__c=c1.Performance_Comment;
             b.ASI_CRM_CN_display__c=c1.Display;
             b.ASI_CRM_CN_displaycontent__c=c1.Display_Comment;
             b.ASI_CRM_CN_interaction__c=c1.Interaction;
             b.ASI_CRM_CN_interactioncontent__c=c1.Interaction_Comment;
             b.ASI_CRM_CN_performance2__c=c1.Peformance_2;
             b.ASI_CRM_CN_perform2content__c=c1.Performance_2_Comment;
             b.ASI_CRM_CN_earlystage_communication__c=c1.Early_Communication;

             b.ASI_CRM_CN_content__c=c1.Early_Communication_Comment;
             b.ASI_CRM_CN_eventcreativity__c=c1.Event_Creativity;
             b.ASI_CRM_CN_creativitycontent__c=c1.Event_Creativity_Comment;
             b.ASI_CRM_CN_eventdisplay__c=c1.Event_Display;
             b.ASI_CRM_CN_eventdisplaycontent__c=c1.Event_DisplayComment;
             b.ASI_CRM_CN_consumerinteraction__c=c1.Consumer_Interaction;
             b.ASI_CRM_CN_consumerinteractcontent__c=c1.Consumer_InteractionComment;
             b.ASI_CRM_CN_eventperformance__c=c1.Event_Performance;
             b.ASI_CRM_CN_eventpercontent__c=c1.Event_PerformanceComment;
             b.ASI_CRM_CN_satisfaction_of_gift__c=c1.Satisfaction_Gift;
             b.ASI_CRM_CN_giftsatisfactioncontent__c=c1.Satisfaction_GiftComment;
             b.ASI_CRM_CN_eventcoordination__c=c1.Event_Coordination;
             b.ASI_CRM_CN_eventcoordinatecontent__c=c1.Event_Coordination_Comment;
             b.ASI_CRM_CN_amountofgifts__c=c1.Amount_Gift;
             b.ASI_CRM_CN_giftamountcontent__c=c1.Amount_Gift_Comment;
             b.ASI_CRM_CN_storecommunication__c=c1.Store_Communication;
             b.ASI_CRM_CN_storecommucontent__c=c1.Store_Communication_Comment;
             b.ASI_CRM_CN_promotion__c=c1.Promotion;
             b.ASI_CRM_CN_promotecontent__c=c1.Promotion_Comment;
            
            a.add(b);
            }
     update a;
     return 'success';
    }
   
   
   
 global with sharing class EventEvaluationStructure{
    
    global String RecordID{set;get;}
    global String Local_Update_Time{set;get;}
    global string Satisfaction_Gift_PG{set;get;}
    global string Satisfaction_Gift_Comment_PG{set;get;}
    global string Topic{set;get;}
    global string Topic_Comment{set;get;}
    global string Performance{set;get;}
    global string Performance_Comment{set;get;}
    global string Display{set;get;}
    global string Display_Comment{set;get;}
    global string Interaction{set;get;}
    global string Interaction_Comment{set;get;}
    global string Peformance_2{set;get;}
    global string Performance_2_Comment{set;get;}
    global string Early_Communication{set;get;}
    global string Early_Communication_Comment{set;get;}
    global string Event_Creativity{set;get;}
    global string Event_Creativity_Comment{set;get;}
    global string Event_Display{set;get;}
    global string Event_DisplayComment{set;get;}
    global string Consumer_Interaction{set;get;}
    global string Consumer_InteractionComment{set;get;}
    global string Event_Performance{set;get;}
    global string Event_PerformanceComment{set;get;}
    global string Satisfaction_Gift{set;get;}
    global string RecordType{set;get;}
    global string Satisfaction_GiftComment{set;get;}
    global string Event_Coordination{set;get;}
    global string Event_Coordination_Comment{set;get;}
    global string Amount_Gift{set;get;}
    global string Amount_Gift_Comment{set;get;}
    global string Store_Communication{set;get;}
    global string Store_Communication_Comment{set;get;}
    global string Promotion{set;get;}
    global string Promotion_Comment{set;get;}
    
    
  }
  
 }