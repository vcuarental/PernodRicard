/*
Developed by StellaLi
Used for IPAD Integration
*/
@RestResource(UrlMapping='/ASI_CRM_CN_Upsert_RSP/*')
global without sharing class ASI_CRM_CN_Upsert_RSP{
    global Class RSP{
    global list <RSPStructure> RSPlist{set;get;}    
    }
    
 @HttpPost
 global static string UpsertRSP(String jsonString ){    
     RSP RSP1 = (RSP)JSON.deserialize(jsonString,RSP.class);  
     /*Sample json format - Create + Update:
     {"jsonString":"{\"RSPlist\":[{\"RecordID\":\"a8nM00000008P4d\",\"Input_Time\":\"2014/11/28 11:49\",\"Item_Group\":\"a7GM00000008Sg7\",\"Customer\":\"a8bM00000008TN2\",\"RecordType\":\"012M00000000YKI\",\"Facing_Quantity\":\"2\",\"RSP\":\"200\"},{\"RecordID\":\"\",\"Input_Time\":\"2014/11/28 19:49\",\"Item_Group\":\"a7GM00000008Sg7\",\"Customer\":\"a8bM00000008TN2\",\"RecordType\":\"012M00000000YKI\",\"Facing_Quantity\":\"2\",\"RSP\":\"200\"}]}"}
     */
     list<ASI_TH_CRM_RSP__c> a = new list<ASI_TH_CRM_RSP__c>();
     for(RSPStructure c1: RSP1.RSPlist) { 
            ASI_TH_CRM_RSP__c b = New ASI_TH_CRM_RSP__c();
        
            if( c1.RecordID != null && c1.RecordID !='')
            {
                b.id = c1.RecordID;
            }
            
            if( c1.Customer== null || c1.Customer=='')
            {
                 b.ASI_CRM_CN_Customer__c =null;
            }else{
                b.ASI_CRM_CN_Customer__c = c1.Customer;
            }
            
            if( c1.Item_Group== null || c1.Item_Group=='')
            {
                 b.ASI_CRM_CN_Item_Group__c =null;
            }else{
                b.ASI_CRM_CN_Item_Group__c = c1.Item_Group;
            }
            
            
            b.RecordTypeID = c1.RecordType;
            b.ASI_CRM_CN_Quantity__c = c1.Facing_Quantity;
            b.ASI_CRM_CN_RSP__c = c1.RSP;


            if(c1.Input_Time!= null && c1.Input_Time!= ''){
                   
                    integer YYYY = integer.valueof(c1.Input_Time.left(4));
                    integer MM = integer.valueof(c1.Input_Time.mid(5,2));
                    integer DD = integer.valueof(c1.Input_Time.mid(8,2));
                    integer HH = integer.valueof(c1.Input_Time.mid(11,2));
                    integer Min = integer.valueof(c1.Input_Time.right(2));
                    b.ASI_CRM_CN_Input_Date_Time__c = Datetime.newInstance(YYYY,MM,DD,HH,Min,0);}
            else{
                     b.ASI_CRM_CN_Input_Date_Time__c = Datetime.now();
                 }

            a.add(b);
            
           }  
       upsert a; 
       Return'Success';
 }
 
 
 global with sharing class RSPStructure{
     global string Customer{set;get;}
     global string Item_Group{set;get;}
     global string Input_Time{set;get;}
     global string RecordType{set;get;}
     global string RecordID{set;get;}
     global decimal Facing_Quantity{set;get;}
     global decimal RSP{set;get;}
 
     public void replaceNull() {
     
     if(Customer==null) Customer= '';   
     if(Item_Group==null)Item_Group= ''; 
  
    }  
 }
    
    
    
}