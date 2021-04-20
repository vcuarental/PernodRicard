/*
Developed by StellaLi
Used for IPAD Integration
*/
@RestResource(UrlMapping='/ASI_CRM_CN_Delete_RSP/*')
global without sharing class ASI_CRM_CN_Delete_RSP{
    global Class RSPDel{
    global list <RSPDelStructure> RSPDellist{set;get;}    
    }
    
 @Httppost
  global static String Delete_RSP(string jsonString) {
    /*sample json format
    {"jsonString":"{\"RSPDellist\":[{\"RecordID\":\"a8nM00000008P72\"}]}"}
    */
         RSPDel RSPDel1 = (RSPDel)JSON.deserialize(jsonString,RSPDel.class); 
         List <ASI_TH_CRM_RSP__c > a = New List<ASI_TH_CRM_RSP__c >();
       
          for(RSPDelStructure c1: RSPDel1.RSPDelList) { 
            if( c1.RecordID != null && c1.RecordID !=''  ) {
                ASI_TH_CRM_RSP__c b = New ASI_TH_CRM_RSP__c();       
                b.id = c1.RecordID;            
                a.add(b);
           }
       
        }
        delete a;
        return 'success' ;
    }
    
    
    global with sharing class RSPDelStructure{
    global String RecordID {set;get;}       
   }  
    
}