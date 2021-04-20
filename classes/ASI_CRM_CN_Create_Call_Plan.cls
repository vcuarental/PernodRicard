/*
Developed by StellaLi
Used for IPAD Integration
*/
@RestResource(UrlMapping='/ASI_CRM_CN_Create_Call_Plan/*')
global without sharing class ASI_CRM_CN_Create_Call_Plan{
    global Class CallPlan{
    global list <CallPlanStructure> CallPlanList{set;get;}    
    }
   
 @HttpPost
    global static string CreateCallPlan(String jsonString ){  
   /* Sample json format
   Single record:
   {"jsonString":"{\"CallPlanList\":[{\"Start_Date_Time\":\"2014-11-28\",\"CustomerID\":\"a8bM00000008Qw7\",\"RecordType\":\"012M00000000V2u\"}]}"}
   Multiple record:
   {"jsonString":"{\"CallPlanList\":[{\"Start_Date_Time\":\"2014-11-28\",\"CustomerID\":\"a8bM00000008Qw7\",\"RecordType\":\"012M00000000V2u\"},{\"Start_Date_Time\":\"2014-11-28\",\"CustomerID\":\"a8bM00000008TN2\",\"RecordType\":\"012M00000000V2u\"}]}"}
   */
    CallPlan CallPlan1= (CallPlan)JSON.deserialize(jsonString,CallPlan.class);     
    
        List <Event> a = New List<Event>(); 
        for(CallPlanStructure c1: CallPlan1.CallPlanList) { 
               
                Event b = New Event();
                     
           
            if(c1.Start_Date_Time!= null && c1.Start_Date_Time!= ''){ 
                integer Y1= integer.valueof(c1.Start_Date_Time.left(4));
                integer MM= integer.valueof(c1.Start_Date_Time.mid(5,2));
                integer DD= integer.valueof(c1.Start_Date_Time.right(2));
                b.StartDateTime= Datetime.newInstance(Y1, MM, DD, 12, 30, 2);
                b.EndDateTime = Datetime.newInstance(Y1, MM, DD, 12, 30, 2);
             }else{
                b.StartDateTime= Datetime.now();
                b.EndDateTime = Datetime.now();
             }

             
                RecordType rt = Global_RecordTypeCache.getRtRec('Event'+'ASI_CRM_CN_Call_Plan');              
                b.RecordTypeID = rt.id;
                if (c1.CustomerID!=null && c1.CustomerID!=''){
               ASI_CRM_AccountsAdditionalField__c ab = new ASI_CRM_AccountsAdditionalField__c ();
               ab = [SELECT Id, Name FROM ASI_CRM_AccountsAdditionalField__c WHERE id=:c1.CustomerID];              
               b.subject = 'Call Plan: ' + ab.Name;
               b.IsAllDayEvent =true; 
               b.WhatID = c1.CustomerID;
               }else{
                b.WhatID = null;
                b.subject = 'Call Plan: ';
                b.IsAllDayEvent =true; 
               }
           
               a.add(b);

           }
       insert a;  
       return 'Success';
    }
    

   global with sharing class CallPlanStructure{ 
    
   global String Start_Date_Time{set;get;} 
   global String CustomerID{set;get;} 
   global String RecordType{set;get;} 
   
   public void replaceNull() {
   if (CustomerID==null) CustomerID = '';
   if (Start_Date_Time==null) Start_Date_Time= '';

   }   
    
   }
    
}