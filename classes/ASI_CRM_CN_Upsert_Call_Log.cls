/*
Developed by StellaLi
Used for IPAD Integration
*/
@RestResource(UrlMapping='/ASI_CRM_CN_Upsert_Call_Log/*')
global without sharing class ASI_CRM_CN_Upsert_Call_Log{
    global Class CallLog{
    global list <CallLogStructure> Callloglist{set;get;}    
    }
    global class MerchandiseException extends Exception {}
   
 @HttpPost
    global static string UpsertCalllog (String jsonString ){ 
  /* sample json format
   Request URL:
   https://na14.salesforce.com/services/apexrest/ASI_CRM_CN_Upsert_Call_Log
   Upsert:
{"jsonString":"{\"Callloglist\":[{\"RecordID\":\"a9NM00000008RHX\",\"CreatedFrom\":\"BesPoke\",\"Local_Update_Time\":\"2014/10/09 11:49\",\"CustomerID\":\"a8bM00000008P54\",\"Stock_Room_Check\":\"Yes\",\"Vol_Performance_Check\":\"No\",\"Visit_Date\":\"2014/02/08\",\"Due_Date\":\"2015/12/10\",\"Follow_Up_Tasks\":\"-1-\",\"Assortment_Check\":\"No\",\"Business_Discussion\":\"No\",\"Chat_With_Staff\":\"Yes\",\"Competitor_Check\":\"No\",\"Contract_Negotiation\":\"No\",\"GMA_Check\":\"No\",\"Data_Quality_Check\":\"No\",\"Display_Check\":\"No\",\"Incentive_Payment\":\"No\",\"Offtake_Check\":\"Yes\",\"Price_Check\":\"Yes\",\"Promotion_Execution\":\"Yes\",\"Promotion_Preparation\":\"No\",\"Retail_Price_Check\":\"No\"},{\"RecordID\":\"\",\"RecordType\":\"012M00000000VoZ\",\"Local_Update_Time\":\"2014/10/09 11:46\",\"CustomerID\":\"a8bM00000008Qw7\",\"Stock_Room_Check\":\"Yes\",\"Vol_Performance_Check\":\"Yes\",\"Visit_Date\":\"2014/01/02\",\"Due_Date\":\"2015/12/12\",\"Follow_Up_Tasks\":\"-2-\",\"Assortment_Check\":\"Yes\",\"Business_Discussion\":\"Yes\",\"Chat_With_Staff\":\"Yes\",\"Competitor_Check\":\"Yes\",\"Contract_Negotiation\":\"Yes\",\"GMA_Check\":\"Yes\",\"Data_Quality_Check\":\"Yes\",\"Display_Check\":\"Yes\",\"Incentive_Payment\":\"Yes\",\"Offtake_Check\":\"Yes\",\"Price_Check\":\"Yes\",\"Promotion_Execution\":\"Yes\",\"Promotion_Preparation\":\"Yes\",\"Retail_Price_Check\":\"Yes\"},{\"RecordID\":\"\",\"RecordType\":\"012M00000000VoU\",\"Local_Update_Time\":\"2014/10/09 11:47\",\"CustomerID\":\"a8bM00000008Rx1\",\"Stock_Room_Check\":\"No\",\"Vol_Performance_Check\":\"No\",\"Visit_Date\":\"2014/01/04\",\"Due_Date\":\"2015/12/13\",\"Follow_Up_Tasks\":\"-3-\",\"Assortment_Check\":\"No\",\"Business_Discussion\":\"No\",\"Chat_With_Staff\":\"No\",\"Competitor_Check\":\"No\",\"Contract_Negotiation\":\"No\",\"GMA_Check\":\"No\",\"Data_Quality_Check\":\"No\",\"Display_Check\":\"No\",\"Incentive_Payment\":\"No\",\"Offtake_Check\":\"No\",\"Price_Check\":\"No\",\"Promotion_Execution\":\"No\",\"Promotion_Preparation\":\"No\",\"Retail_Price_Check\":\"No\"}]}"}
   */
        
        CallLog calllog1 = (CallLog)JSON.deserialize(jsonString,CallLog.class);     
                     
        List <ASI_CRM_Call_Log__c> a = New List<ASI_CRM_Call_Log__c>();
//        List <ASI_CRM_Call_Log__c> d = [Select id from ASI_CRM_Call_Log__c];
        /*set<id> f = new set<id>();
        for(ASI_CRM_Call_Log__c e:d){
            f.add(e.id);
             if(!f.contains(c1.RecordID)){
             
            } 
        }*/
        
        for(CallLogStructure c1: calllog1.Callloglist) {
            ASI_CRM_Call_Log__c b = New ASI_CRM_Call_Log__c();
        
            if( c1.RecordID != null && c1.RecordID !='')
            {
                b.id = c1.RecordID;
                
            }
             if( c1.RecordID == null || c1.RecordID =='')
            {
                b.ASI_CRM_AccountsAdditionalField__c =c1.CustomerID;
                
            }
                     
            b.ASI_CRM_Follow_up__c = c1.Follow_Up_Tasks;
            b.ASI_CRM_Assortment_Display_Check__c= c1.Assortment_Check;
            b.ASI_CRM_Inventory_IN_Out_Check__c = c1.Vol_Performance_Check;
            b.ASI_CRM_Business_Development__c = c1.Business_Discussion;
            b.ASI_CRM_Daily_Business__c = c1.Chat_With_Staff;
            b.ASI_CRM_Discuss_Competitor_Product__c= c1.Competitor_Check;
            b.ASI_CRM_Discuss_Business__c= c1.Contract_Negotiation;
            b.ASI_CRM_GMA_CHECK__c= c1.GMA_Check;
            b.ASI_CRM_Data_Quality_Check__c= c1.Data_Quality_Check;
            b.ASI_CRM_Display_Image_Check__c = c1.Display_Check;
            b.ASI_CRM_Incentive_Payment__c= c1.Incentive_Payment;
            b.ASI_CRM_Offtake_Check__c= c1.Offtake_Check;
            b.ASI_CRM_Others__c= c1.Other_Matters;
            b.ASI_CRM_RSP_Check__c = c1.Price_Check;
            b.ASI_CRM_Promotion_Execute_feedback__c= c1.Promotion_Execution;
            b.ASI_CRM_Promotion_Preparation__c= c1.Promotion_Preparation;
            b.ASI_CRM_Retail_Selling_Price__c= c1.Retail_Price_Check;
            b.ASI_CRM_Stock_Check__c= c1.Stock_Room_Check;
            b.ASI_CRM_Created_from__c = c1.CreatedFrom;
            if(c1.RecordType != NULL && c1.RecordType != '')
                b.RecordTypeID =c1.RecordType;
            //20160411 Ben @ Elufa
            /*b.ASI_CRM_Suggest_To_Order__c = c1.suggestToOrder;
            b.ASI_CRM_PromotionEvent1ExecutionFeedback__c = c1.promotionOrEventExecutionAndFeedback1;
            b.ASI_CRM_Promotion_Event_1__c = c1.PromotionOrEvent1;
            b.ASI_CRM_PromotionEvent2ExecutionFeedback__c = c1.promotionOrEventExecutionAndFeedback2;
            b.ASI_CRM_Promotion_Event_2__c = c1.PromotionOrEvent2;
            b.ASI_CRM_RSP_Gap__c = c1.RSPGap;
            b.ASI_CRM_Call_Log_Summary__c = c1.callLogSummary;*///20170705 Introv, commented for deployment
            //20160411 End
            //b.ASI_CRM_Second_Display_Check__c = c1.secondDisplayCheck;//20160923 Ben @ Elufa
            //b.ASI_CRM_POSM__c = c1.posm;//20161025 Ben @ Elufa
            if(c1.Visit_Date != null && c1.Visit_Date!= ''){
           
                    integer YYYY= integer.valueof(c1.Visit_Date.left(4));
                    integer MM= integer.valueof(c1.Visit_Date.mid(5,2));
                    integer DD= integer.valueof(c1.Visit_Date.right(2));
                  
                    b.ASI_CRM_Visit_Date__c = date.newinstance(YYYY,MM,DD);}
            else{
                    b.ASI_CRM_Visit_Date__c = null;
                 }

            if(c1.Due_Date != null && c1.Due_Date!= ''){
                   
                    integer YYYY= integer.valueof(c1.Due_Date.left(4));
                    integer MM= integer.valueof(c1.Due_Date.mid(5,2));
                    integer DD= integer.valueof(c1.Due_Date.right(2));
                   
                    b.ASI_CRM_Due_Date__c = date.newinstance(YYYY,MM,DD);}
            else{
                    b.ASI_CRM_Due_Date__c = null;
                 }
           
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
            
            //20170307 Elufa
            if(c1.latitude != null && c1.longitude !=null)
            {
                b.ASI_CRM_GPS_info__Latitude__s = c1.latitude;
                b.ASI_CRM_GPS_info__Longitude__s = c1.longitude;
            }
          
      /*      if( c1.RecordID == null && c1.RecordID =='')
            {
                
                
               // test account: 'a8bM00000008P54';
                b.RecordTypeID =c1.RecordType;
                //three recordtypeId: '012M00000000VoZ';012M00000000VoU;012M00000000VoP
                
            }
            */
            
            a.add(b);
            
        } 
        upsert a;   
        return 'success'; 
    
      } 
    global with sharing class CallLogStructure{
        
        global string RecordType{set;get;}
        global string Follow_Up_Tasks{set;get;}
        global string Due_Date{set;get;}
        global String RecordID {set;get;}
        global String Vol_Performance_Check{set;get;}
        global String Assortment_Check{set;get;}
        global String Business_Discussion{set;get;}
        global String CustomerID {set;get;}
        global String Chat_With_Staff{set;get;}
        global String Competitor_Check{set;get;}
        global String Contract_Negotiation{set;get;}
        global String GMA_Check{set;get;}
        global String Data_Quality_Check{set;get;}
        global String Display_Check{set;get;}
        global String Incentive_Payment{set;get;}
        global String Offtake_Check{set;get;}
        global String Other_Matters{set;get;}
        global String Price_Check{set;get;}
        global String Promotion_Execution{set;get;}
        global String Promotion_Preparation{set;get;}
        global String Retail_Price_Check{set;get;}
        global String Stock_Room_Check{set;get;}
        global String Visit_Date{set;get;}
        global String Local_Update_Time{set;get;}
        global string CreatedFrom{set;get;}
        //20160411 Ben @ Elufa
        global string suggestToOrder{set;get;}
        global string promotionOrEventExecutionAndFeedback1{set;get;}
        global string PromotionOrEvent1{set;get;}
        global string promotionOrEventExecutionAndFeedback2{set;get;}
        global string PromotionOrEvent2{set;get;}
        global string RSPGap{set;get;}
        global string callLogSummary{set;get;}
        //20160411 End
        Global Boolean secondDisplayCheck{set;get;}//20160923 Ben @ Elufa
        Global Boolean posm{set;get;}//20161025 Ben @ Elufa
        
        //20170307 ELufa
        global Double latitude{set;get;}
        global Double longitude{set;get;}
    
   /* public void replaceNull() {
         if(Follow_Up_Tasks==null) Follow_Up_Tasks= '';
         if(CustomerID==null) CustomerID='';
         if(Due_Date==null) Due_Date ='';
         if(RecordID ==null) RecordID = '';
         if(Vol_Performance_Check==null) Vol_Performance_Check= '';
         if(Assortment_Check==null) Assortment_Check = '';
         if(Business_Discussion==null) Business_Discussion= '';
         if(Chat_With_Staff==null) Chat_With_Staff= '';
         if(Competitor_Check==null) Competitor_Check= '';
         if(Contract_Negotiation==null) Contract_Negotiation= '';
         if(GMA_Check==null) GMA_Check= '';
         if(Data_Quality_Check==null) Data_Quality_Check= '';
         if(Incentive_Payment==null) Incentive_Payment= '';
         if(Offtake_Check==null) Offtake_Check= '';
         if(Other_Matters==null) Other_Matters= '';
         if(Price_Check==null) Price_Check= '';
         if(Promotion_Execution==null) Promotion_Execution= '';
         if(Promotion_Preparation==null) Promotion_Preparation= '';
         if(Retail_Price_Check==null) Retail_Price_Check= '';
         if(Stock_Room_Check==null) Stock_Room_Check= '';
         if(Visit_Date==null) Visit_Date= '';
      //   if(RecordType==null) RecordType= '';
         if(Local_Update_Time==null) Local_Update_Time= '';
    }*/
} 
}