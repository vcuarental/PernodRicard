/*
Developed by StellaLi
Test Class for ASI_CRM_CN_Upsert_RSP
*/
@isTest(SeeAllData=true)
private class ASI_CRM_CN_UpsertRSP_WebserviceTest{
    private Class RSP{
    private list <RSPStructure> RSPlist{set;get;}    
    }

 @isTest static void ASI_CRM_CN_Upsert_RSP() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();

        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
        Id rtRsp = Global_RecordTypeCache.getRtId('ASI_TH_CRM_RSP__cASI_CRM_CN_RSP');
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(ASI_CRM_CN_City_Code__c='TEST',RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_City__cASI_CRM_CN_City'));
        insert city;
        
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c='ON');
        insert channel;
        
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;
        
        ASI_CRM_AccountsAdditionalField__c a2 = new ASI_CRM_AccountsAdditionalField__c(RecordTypeId=rtOutlet, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_CN_Sub_Channel__c=subChannel.Id);
        insert a2;
        
        ASI_MFM_Item_Group__c ig = new ASI_MFM_Item_Group__c(RecordTypeId= Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_CRM_CN_CRM_Item_Group'),Name='TEST', ASI_CRM_CN_Consumer_Website__c=true);
        insert ig;
        
        ASI_TH_CRM_RSP__c testRSP = new ASI_TH_CRM_RSP__c(ASI_CRM_CN_Customer__c=a2.Id, RecordTypeId=rtRsp, ASI_CRM_CN_Input_Date_Time__c=system.today().addDays(-1));
        insert testRSP ;
        
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        /*test update*/
        string record = '{"RSPlist":[{"RecordID ":"' + testRSP.id+ '","recordType":"'+ rtRsp +'","Customer":"'+ a2.id +'","Item_Group":"'+ ig.id +'","Input_Time":"2015/11/28 20:20","Facing_Quantity":"199","RSP":"4"}]}';
        ASI_CRM_CN_Upsert_RSP.UpsertRSP(record);
        /*test insert*/
        string record1 = '{"RSPlist":[{"RecordID ":"","recordType":"'+ rtRsp +'","Customer":"'+ a2.id +'","Item_Group":"'+ ig.id +'","Input_Time":"2015/11/28 20:20","Facing_Quantity":"199","RSP":"4"}]}';
        ASI_CRM_CN_Upsert_RSP.UpsertRSP(record1);
        Test.stopTest();
 }
 
  private with sharing class RSPStructure{
     private string Customer{set;get;}
     private string Item_Group{set;get;}
     private string Input_Time{set;get;}
     private string RecordType{set;get;}
     private string RecordID{set;get;}
     private decimal Facing_Quantity{set;get;}
     private decimal RSP{set;get;}
 
 }
    
    
}