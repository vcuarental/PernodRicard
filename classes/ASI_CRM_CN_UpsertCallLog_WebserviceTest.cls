/*
Developed by StellaLi
Test Class for ASI_CRM_CN_Upsert_Call_Log
*/
@isTest(SeeAllData=true)
private class ASI_CRM_CN_UpsertCallLog_WebserviceTest{
  private Class CallLog{
    private list <CallLogStructure> Callloglist{set;get;} 
  }
  @isTest static void ASI_CRM_CN_Upsert_Call_Log () {
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
        
        /*insert calllog*/  
        Id rt3 = Global_RecordTypeCache.getRtId('ASI_CRM_Call_Log__cASI_CRM_CallLog_CN_WS');
        ASI_CRM_Call_Log__c testcalllog = new ASI_CRM_Call_Log__c(ASI_CRM_AccountsAdditionalField__c= ass.id,recordTypeId=rt3,ASI_CRM_Assortment_Display_Check__c ='Yes',ASI_CRM_Inventory_IN_Out_Check__c ='Yes',ASI_CRM_Business_Development__c ='Yes',ASI_CRM_Daily_Business__c ='Yes',ASI_CRM_Discuss_Competitor_Product__c='Yes',ASI_CRM_Discuss_Business__c='Yes',ASI_CRM_GMA_CHECK__c='Yes',ASI_CRM_Data_Quality_Check__c='Yes',ASI_CRM_Display_Image_Check__c ='Yes',ASI_CRM_Incentive_Payment__c='Yes',ASI_CRM_Offtake_Check__c='Yes',ASI_CRM_RSP_Check__c ='Yes',ASI_CRM_Promotion_Execute_feedback__c='Yes',ASI_CRM_Promotion_Preparation__c='Yes',ASI_CRM_Retail_Selling_Price__c='Yes',ASI_CRM_Stock_Check__c='Yes',ASI_CRM_Others__c='for test2',ASI_CRM_Visit_Date__c =date.today(),ASI_CRM_Follow_up__c ='test class',ASI_CRM_Due_Date__c= date.today(),ASI_CRM_Local_Update_Time__c = Datetime.now()  );
        insert testcalllog ;
        
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        
        /*update test*/
        string record = '{"Callloglist":[{"RecordID ":"' + testcalllog.id+ '","recordType":"'+ rt3 +'","CustomerID":"'+ ass.id +'","Follow_Up_Tasks":"testclass11/26/2014","Due_Date":"2015/10/01","Vol_Performance_Check":"No","Assortment_Check":"No","Business_Discussion":"No","Chat_With_Staff":"No","Competitor_Check":"No","Contract_Negotiation":"No","GMA_Check":"No","Data_Quality_Check":"No","Display_Check":"No","Incentive_Payment":"No","Offtake_Check":"No","Price_Check":"No","Promotion_Execution":"No","Promotion_Preparation":"No","Retail_Price_Check":"No","Stock_Room_Check":"No","Visit_Date":"2014/10/01","Local_Update_Time":"2014/10/09 11:49","Other_Matters":"testclass11/26/2014"}]}';
        ASI_CRM_CN_Upsert_Call_Log.UpsertCalllog (record);
        
        /*insert test*/
        string record1 = '{"Callloglist":[{"RecordID ":"","CustomerID":"'+ ass.id +'","recordType":"'+ rt3 +'","Follow_Up_Tasks":"testclass11/26/2014","Due_Date":"2015/10/01","Vol_Performance_Check":"No","Assortment_Check":"No","Business_Discussion":"No","Chat_With_Staff":"No","Competitor_Check":"No","Contract_Negotiation":"No","GMA_Check":"No","Data_Quality_Check":"No","Display_Check":"No","Incentive_Payment":"No","Offtake_Check":"No","Price_Check":"No","Promotion_Execution":"No","Promotion_Preparation":"No","Retail_Price_Check":"No","Stock_Room_Check":"No","Visit_Date":"2014/10/01","Local_Update_Time":"2014/10/09 11:49","Other_Matters":"testclass11/26/2014"}]}';
        ASI_CRM_CN_Upsert_Call_Log.UpsertCalllog (record1);
        Test.stopTest();
       
        
  }      
        
        
        
          
 private with sharing class CallLogStructure{
    
    private string RecordType{set;get;}
    private string Follow_Up_Tasks{set;get;}
    private string Due_Date{set;get;}
    private String RecordID {set;get;}
    private String Vol_Performance_Check{set;get;}
    private String Assortment_Check{set;get;}
    private String Business_Discussion{set;get;}
    private String CustomerID {set;get;}
    private String Chat_With_Staff{set;get;}
    private String Competitor_Check{set;get;}
    private String Contract_Negotiation{set;get;}
    private String GMA_Check{set;get;}
    private String Data_Quality_Check{set;get;}
    private String Display_Check{set;get;}
    private String Incentive_Payment{set;get;}
    private String Offtake_Check{set;get;}
    private String Other_Matters{set;get;}
    private String Price_Check{set;get;}
    private String Promotion_Execution{set;get;}
    private String Promotion_Preparation{set;get;}
    private String Retail_Price_Check{set;get;}
    private String Stock_Room_Check{set;get;}
    private String Visit_Date{set;get;}
    private String Local_Update_Time{set;get;}

    
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
         if(RecordType==null) RecordType= '';
         if(Local_Update_Time==null) Local_Update_Time= '';
    }*/
 }   
}