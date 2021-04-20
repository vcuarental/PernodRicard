/*
Developed by StellaLi
Test Class for ASI_CRM_CN_Upsert_Issue
*/
@isTest//(SeeAllData=true)
private class ASI_CRM_CN_UpsertIssue_WebserviceTest{
    private Class Issue{
    private list <IssueStructure> Issuelist{set;get;}    
    }
   
  @isTest static void ASI_CRM_CN_Upsert_Issue() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
  
   Id rtOutlet = Global_RecordTypeCache.getRtId('AccountASI_MFM_CN_Outlet');
   Id rtIssue = Global_RecordTypeCache.getRtId('ASI_CRM_Issue_Zone__cASI_CRM_CN_Consumer_Complaint');   
      
   Account a = new Account(RecordTypeId=rtOutlet, Name='TEST1');
   insert a;
        
   ASI_MFM_Sub_brand__c sb= new ASI_MFM_Sub_brand__c ();
   insert sb;
   
   ASI_CRM_City__c city = new ASI_CRM_City__c(ASI_CRM_CN_City_Code__c='TEST',RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_City__cASI_CRM_CN_City'));
   insert city;
   
   ASI_CRM_Issue_Zone__c testIssueZone=new ASI_CRM_Issue_Zone__c(ASI_CRM_QR_Code_Sticker_Issue_Category__c = 'testing', RecordTypeId=rtIssue,ASI_CRM_Bottles_Sighted1__c='5',ASI_CRM_Complainant_Name__c='Destroyed Product',ASI_CRM_Outlet_Involved__c=a.id,ASI_CRM_Sub_brand__c =sb.id);
   insert testIssueZone;
   
   ASI_CRM_CN_Issue_Sharing_Admin__c tmpIssueSharingAdmin = new ASI_CRM_CN_Issue_Sharing_Admin__c(Name = 'testName', ASI_CRM_CN_Inactive__c = FALSE, ASI_CRM_QR_Code_Sticker_Issue_Category__c = 'testing', ASI_CRM_CN_Issue_Type__c = 'Consumer Complaint');
   insert tmpIssueSharingAdmin;
      
   ASI_CRM_CN_Issue_Sharing_Admin_User_List__c tmpIssueAdminUser = new ASI_CRM_CN_Issue_Sharing_Admin_User_List__c(ASI_CRM_CN_Issue_Sharing_Group__c = tmpIssueSharingAdmin.id);
   insert tmpIssueAdminUser;
       
   mock.setStatusCode(200);
   mock.setHeader('Content-Type', 'application/json');
   Test.setMock(HttpCalloutMock.class, mock);
   Test.startTest();
   /*test*/
  string record = '{"Issuelist":[{"RecordID ":"' + testIssueZone.id+ '","Bottle_Sight_1":"1","Bottle_Sight_2":"1","Bottle_Sight_3":"1","Bottle_Sight_4":"1","Bottle_Sight_5":"1","Bottle_Sight_6":"1","Product2":"test","Product3":"test","CityID":"' + city.id + '","Consumer_Name":"Test","Date_Of_Purchase":"2014/11/30","Detail":"Test","Discussion_With_Seller":"Test","IOM_Detail":"Test","Expectation":"Test","How_Complaint_Learnt":"Internal","Location":"TEst","Lot_Code":"Test","Manufacturing_Date":"2014/11/30","Lookalike_Detail":"test","Origin_Of_GMA":"test","Origin_Of_GMA2":"test","OutletID":"'+a.id+'","Packing_Specification":"test","Description":"test","Price1":"99","Price2":"99","Price3":"99","Product":"MCB 1L","Reason_For_Complaint":"No","Referred_BTL":"99","Remarks":"test","Traceability_Detail":"test","Sub_brandID":"'+sb.id+'","Tel_No":"61234567","Distributor_Contact_Info":"test","Distributor_Contact_Person":"test","AccountID":"'+a.id+'","RecordType":"'+rtIssue+'","Local_Update_Time":"2014/12/01 11:30","WeChatID":"123456"}]}';
  string record1 = '{"Issuelist":[{"RecordID ":"","Bottle_Sight_1":"1","Bottle_Sight_2":"1","Bottle_Sight_3":"1","Bottle_Sight_4":"1","Bottle_Sight_5":"1","Bottle_Sight_6":"1","Product2":"test","Product3":"test","CityID":"' + city.id + '","Consumer_Name":"Test","Date_Of_Purchase":"2014/11/30","Detail":"Test","Discussion_With_Seller":"Test","IOM_Detail":"Test","Expectation":"Test","How_Complaint_Learnt":"Internal","Location":"TEst","Lot_Code":"Test","Manufacturing_Date":"2014/11/30","Lookalike_Detail":"test","Origin_Of_GMA":"test","Origin_Of_GMA2":"test","OutletID":"'+a.id+'","Packing_Specification":"test","Description":"test","Price1":"99","Price2":"99","Price3":"99","Product":"MCB 1L","Reason_For_Complaint":"No","Referred_BTL":"99","Remarks":"test","Traceability_Detail":"test","Sub_brandID":"'+sb.id+'","Tel_No":"61234567","Distributor_Contact_Info":"test","Distributor_Contact_Person":"test","AccountID":"'+a.id+'","RecordType":"'+rtIssue+'","Local_Update_Time":"2014/12/01 11:30","WeChatID":"123456"}]}';
  ASI_CRM_CN_Upsert_Issue.UpsertIssue(record);
  ASI_CRM_CN_Upsert_Issue.UpsertIssue(record1);
  update testIssueZone;
  Test.stopTest();
   }
  
  private with sharing class IssueStructure{
     private string Bottle_Sight_1{set;get;}
     private string Bottle_Sight_2{set;get;}
     private string Bottle_Sight_3{set;get;}
     private string Bottle_Sight_4{set;get;}
     private string Bottle_Sight_5{set;get;}
     private string Bottle_Sight_6{set;get;}
     private string Product2{set;get;}
     private string Product3{set;get;}
     private string CityID{set;get;}
     private string Consumer_Name{set;get;}
     private string Date_Of_Purchase{set;get;}
     private string Detail{set;get;}
     private string Discussion_With_Seller{set;get;}
     private string IOM_Detail{set;get;}
     private string Expectation{set;get;}
     private string How_Complaint_Learnt{set;get;}
     private string Location{set;get;}
     private string Lot_Code{set;get;}
     private string Manufacturing_Date{set;get;}
     private string Lookalike_Detail{set;get;}
     private string Origin_Of_GMA{set;get;}
     private string Origin_Of_GMA2{set;get;}
     private string OutletID{set;get;}
     private string Packing_Specification{set;get;}
     private string Description{set;get;}
     private Decimal Price1{set;get;}
     private Decimal Price2{set;get;}
     private Decimal Price3{set;get;}
     private string Product{set;get;}
     private string Reason_For_Complaint{set;get;}
     private Decimal Referred_BTL{set;get;}
     private string Remarks{set;get;}
     private string Traceability_Detail{set;get;}
     private string Sub_brandID{set;get;}
     private string Tel_No{set;get;}
     private string Distributor_Contact_Info{set;get;}
     private string Distributor_Contact_Person{set;get;}
     private string AccountID{set;get;}
     private string RecordType{set;get;}
     private string RecordID{set;get;}
     private string Local_Update_Time{set;get;}
     private string WeChatID{set;get;}
     } 
 }