/*
Developed by StellaLi
Used for IPAD Integration
*/
@RestResource(UrlMapping='/ASI_CRM_CN_Delete_Issue/*')
global without sharing class ASI_CRM_CN_Delete_Issue{
    global Class IssueDel{
    global list <IssueDelStructure> IssueDellist{set;get;}    
    }
    
  @Httppost
    global static String Delete_Issue(string jsonString) {
  
         IssueDel IssueDel1 = (IssueDel)JSON.deserialize(jsonString,IssueDel.class); 
         List <ASI_CRM_Issue_Zone__c> a = New List<ASI_CRM_Issue_Zone__c>();
       
          for(IssueDelStructure c1: IssueDel1.IssueDelList) { 
            if( c1.RecordID != null && c1.RecordID !=''  ) {
                ASI_CRM_Issue_Zone__c b = New ASI_CRM_Issue_Zone__c();         
                b.id = c1.RecordID;            
                a.add(b);
           }
       
        }
        delete a;
        return 'success' ;
    }
   
   global with sharing class IssueDelStructure{
    global String RecordID {set;get;}       
   }
  
 }