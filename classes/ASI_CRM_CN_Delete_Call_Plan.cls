/*
Developed by StellaLi
Used for IPAD Integration
*/
@RestResource(UrlMapping='/ASI_CRM_CN_Delete_Call_Plan/*')
global without sharing class ASI_CRM_CN_Delete_Call_Plan{
    global Class CallPlanDel {
    global list <CallPlanDelStructure> CallPlanDelList{set;get;}        
    }
    
  @Httppost
  global static String Delete_Call_Plan(string jsonString) {
  
      CallPlanDel CallPlanDel1 = (CallPlanDel)JSON.deserialize(jsonString,CallPlanDel.class); 
      List <Event> a = New List<Event>(); 
      
      for(CallPlanDelStructure c1: CallPlanDel1.CallPlanDelList) { 
            if( c1.RecordID != null && c1.RecordID !=''  ) {
                Event b = New Event();        
                b.id = c1.RecordID;            
                a.add(b);
           }
       
      }
        delete a;
  
   return 'success' ;
  }
  
   global with sharing class CallPlanDelStructure{
    global String RecordID {set;get;}       
   }
  
}