/*
Developed by StellaLi
Test Class for WebService:ASI_CRM_CN_Delete_Call_Log
*/
@isTest(SeeAllData=true)
private class ASI_CRM_CN_DeleteCallLog_WebserviceTest{
  private Class CallLogDel {
    private list <CallLogDelStructure> CallLogDelList{set;get;}
  }
  
  @isTest static void ASI_CRM_CN_Delete_Call_Log() {
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
       
        /*delete test*/
        Test.startTest();
        string record = '{"CallLogDelList":[{"RecordID":"' + testcalllog.id+ '"}]}';
        ASI_CRM_CN_Delete_Call_Log.Delete_Call_Log(record);
        Test.stopTest();
       
  }
  
  
private with sharing class CallLogDelStructure{
    private String RecordID {set;get;}       
   }
  
 }