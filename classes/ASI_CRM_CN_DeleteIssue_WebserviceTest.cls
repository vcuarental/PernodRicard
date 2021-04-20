/*
Developed by StellaLi
Test Class for ASI_CRM_CN_Delete_Issue
*/
@isTest(SeeAllData=true)
private class ASI_CRM_CN_DeleteIssue_WebserviceTest{
    private Class IssueDel{
    private list <IssueDelStructure> IssueDellist{set;get;}    
    }
    
@isTest static void ASI_CRM_CN_Delete_Issue() {
   StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
  
   Id rtOutlet = Global_RecordTypeCache.getRtId('AccountASI_MFM_CN_Outlet');
   Id rtIssue = Global_RecordTypeCache.getRtId('ASI_CRM_Issue_Zone__cASI_CRM_CN_Consumer_Complaint');
   
   Account a = new Account(RecordTypeId=rtOutlet, Name='TEST1');
   insert a;
        
   ASI_MFM_Sub_brand__c sb= new ASI_MFM_Sub_brand__c ();
   insert sb;
   
   ASI_CRM_City__c city = new ASI_CRM_City__c(ASI_CRM_CN_City_Code__c='TEST',RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_City__cASI_CRM_CN_City'));
   insert city;
   
   ASI_CRM_Issue_Zone__c testIssueZone=new ASI_CRM_Issue_Zone__c(RecordTypeId=rtIssue,ASI_CRM_Bottles_Sighted1__c='5',ASI_CRM_Complainant_Name__c='Destroyed Product',ASI_CRM_Outlet_Involved__c=a.id,ASI_CRM_Sub_brand__c =sb.id);
   insert testIssueZone;
   
   mock.setStatusCode(200);
   mock.setHeader('Content-Type', 'application/json');
   Test.setMock(HttpCalloutMock.class, mock);
   Test.startTest();
   /*test*/   
   
   string record = '{"IssueDelList":[{"RecordID":"' + testIssueZone.id+ '"}]}';
   ASI_CRM_CN_Delete_Issue.Delete_Issue(record);
   Test.stopTest();
   }
 
  private with sharing class IssueDelStructure{
      private String RecordID {set;get;}       
  } 
    
}