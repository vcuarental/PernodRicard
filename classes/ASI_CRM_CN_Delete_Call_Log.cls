/*
Developed by StellaLi
Used for IPAD Integration
*/
@RestResource(UrlMapping='/ASI_CRM_CN_Delete_Call_Log/*')
global without sharing class ASI_CRM_CN_Delete_Call_Log{
    global Class CallLogDel {
    global list <CallLogDelStructure> CallLogDelList{set;get;}        
    }
    
      
 @Httppost
    global static String Delete_Call_Log(string jsonString) {
  
         CallLogDel CallLogDel1 = (CallLogDel)JSON.deserialize(jsonString,CallLogDel.class); 
         List <ASI_CRM_Call_Log__c> a = New List<ASI_CRM_Call_Log__c>();
       
          for(CallLogDelStructure c1: CallLogDel1.CallLogDelList) { 
            if( c1.RecordID != null && c1.RecordID !=''  ) {
                ASI_CRM_Call_Log__c b = New ASI_CRM_Call_Log__c();         
                b.id = c1.RecordID;            
                a.add(b);
           }
       
        }
        delete a;
        return 'success' ;
    }
   
   global with sharing class CallLogDelStructure{
    global String RecordID {set;get;}       
   }
  
 }