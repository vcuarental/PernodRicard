/***************************************************************************************************************************
* Name:        ASI_TH_CRM_Contract_BeforeUpdate 
* Description: Test class for ASI_TH_CRM_Contract_BeforeUpdateTest
*
* Version History
* Date             Developer               Comments
* ---------------  --------------------    --------------------------------------------------------------------------------
* 2019-08-30       Canter Duan             Created
****************************************************************************************************************************/
@isTest
public class ASI_TH_CRM_Contract_BeforeUpdateTest {
    @testSetup static void setup() {
        test.startTest();
        
    }
    
    static testmethod void ASI_TH_CRM_Contract_BeforeUpdateTest1(){
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        thisUser.BypassVR__c  = true;
        update thisUser;
        System.runAs(thisUser){
            ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='Central Region',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Region__cASI_CRM_CN_Region'));
            insert region;
            
            ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
            insert division;
            
            ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
            insert area;
            
            ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id);
            insert city;
            
      ASI_CRM_CN_Channel_Group__c ChannelGroup = new ASI_CRM_CN_Channel_Group__c(Name='Test',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel_Group__cASI_CRM_CN_Channel_Group'));
            insert ChannelGroup;
            
            ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(Name='MOT',ASI_CRM_BC_Rate__c=98,ASI_CRM_CN_On_Off__c='ON',ASI_CRM_For_Outlet__c=true,
                                                                      RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_For_Contract__c=TRUE, ASI_CRM_CN_Channel_Group__c=ChannelGroup.Id);
            insert channel;
            
            Date PO_Start_Date = date.newinstance(system.today().addMonths(-1).year(), system.today().addMonths(-1).month(), 1);
            Date PO_End_Date = PO_Start_Date.addMonths(1)-1;
            
            Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
            
            list<ASI_CRM_AccountsAdditionalField__c> Customers = new list<ASI_CRM_AccountsAdditionalField__c>();
            Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id, ASI_CRM_CN_BusinessLicenseUploading__c=true, ASI_CRM_CN_Business_License_Expire_date__c=PO_End_Date, ASI_CRM_CN_Business_License_Start_Date__c =PO_Start_Date,ASI_CRM_Channel_Group__c=ChannelGroup.Id));
            insert Customers;
            
            
            User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c FROM USER WHERE id =:UserInfo.getUserId()];
            
            Profile p = [SELECT Id FROM Profile where name = '系统管理员' or name = 'System Administrator'];  
            List<User> LUser = new List<User>();
            LUser.add(new User(Alias = 'standt', Email='standarduser@testorg.com', 
                               EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', ManagerId=userInfo.getUserId(),
                               LocaleSidKey='en_US', ProfileId = p.Id, ASI_CRM_Sales_Team__c = 'a',
                               TimeZoneSidKey='America/Los_Angeles', UserName='standarduser_c1@testing123.com', CompanyName = 'Pernod Ricard China'));
            insert LUser[0];
            
            List<User> userList= new List<User> ();
            userList.add(new User(Alias = 'standt', Email='standarduser@testorg.com', 
                                  EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                  LocaleSidKey='en_US', ProfileId = p.Id, ManagerID = LUser[0].id,
                                  TimeZoneSidKey='America/Los_Angeles', UserName='standarduser_c2@testing123.com', CompanyName = 'Pernod Ricard China', ASI_CRM_Sales_Team__c = 'a'));
            userList.add(new User(Alias = 'standts', Email='standarduser@testorg.com', 
                                  EmailEncodingKey='UTF-8', LastName='Testing3', LanguageLocaleKey='en_US', 
                                  LocaleSidKey='en_US', ProfileId = p.Id, 
                                  TimeZoneSidKey='America/Los_Angeles', UserName='standarduser_c3@testing123.com', CompanyName = 'Pernod Ricard China', ASI_CRM_Sales_Team__c = 'a'));
            insert userList;
            
            ASI_TH_CRM_Contract__c Contract1 = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                                                                          ASI_CRM_CN_Status__c = 'Draft',
                                                                          ownerId = userList[0].id,
                                                                          ASI_CRM_System_Debug__c=true,
                                                                          ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
                                                                          ASI_CRM_CN_PO_End_Date__c =PO_End_Date,
                                                                          ASI_CRM_CN_PO_Version__c = '0.0',
                                                                          ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
                                                                          ASI_CRM_PO_Channel__c = channel.Id,
                                                                          Name = 'Contract1',
                                                                          ASI_CRM_CN_Outlet_WS__c=Customers[0].Id,
                                                                          ASI_CRM_CN_Use_PRC_Contract_Template__c = false,
                                                                          ASI_CRM_Volume_Option__c = 'Normal');
            insert Contract1;
            Contract1.Name = 'Contract1s';
            update Contract1;
            
            ASI_TH_CRM_Contract__c Contract2 = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                                                                          ASI_CRM_CN_Status__c = 'Draft',
                                                                          ownerId = userList[0].id,
                                                                          ASI_CRM_System_Debug__c=true,
                                                                          ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
                                                                          ASI_CRM_CN_PO_End_Date__c =PO_End_Date,
                                                                          ASI_CRM_CN_PO_Version__c = '0.0',
                                                                          ASI_TH_CRM_Promotion_Type__c='Wholesaler Promotion',
                                                                          ASI_CRM_PO_Channel__c = channel.Id,
                                                                          Name = 'Contract2',
                                                                          ASI_CRM_CN_Outlet_WS__c=Customers[0].Id,
                                                                          ASI_CRM_CN_Use_PRC_Contract_Template__c = false,
                                                                          ASI_CRM_Volume_Option__c = 'Normal');
            insert Contract2;
            Contract2.Name = 'Contract2s';
            update Contract2;
            ASI_TH_CRM_Contract__c Contract3 = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                                                                          ASI_CRM_CN_Status__c = 'Draft',
                                                                          ownerId = userList[0].id,
                                                                          ASI_CRM_System_Debug__c=true,
                                                                          ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
                                                                          ASI_CRM_CN_PO_End_Date__c =PO_End_Date,
                                                                          ASI_CRM_CN_PO_Version__c = '0.0',
                                                                          ASI_TH_CRM_Promotion_Type__c='TOT/MOT Contract',
                                                                          ASI_CRM_PO_Channel__c = channel.Id,
                                                                          Name = 'Contract3',
                                                                          ASI_CRM_CN_Outlet_WS__c=Customers[0].Id,
                                                                          ASI_CRM_CN_Use_PRC_Contract_Template__c = false,
                                                                          ASI_CRM_Volume_Option__c = 'Normal');
            insert Contract3;
            Contract3.Name = 'Contract3s';
            update Contract3;
            
            ASI_TH_CRM_Contract__c Contract4 = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Group_Contract'),
                                                                          ASI_CRM_CN_Status__c = 'Draft',
                                                                          ownerId = userList[0].id,
                                                                          ASI_CRM_System_Debug__c=true,
                                                                          ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
                                                                          ASI_CRM_CN_PO_End_Date__c =PO_End_Date,
                                                                          ASI_CRM_CN_PO_Version__c = '0.0',
                                                                          ASI_TH_CRM_Promotion_Type__c='Wholesaler Promotion',
                                                                          ASI_CRM_PO_Channel__c = channel.Id,
                                                                          Name = 'Contract4',
                                                                          ASI_CRM_CN_Outlet_WS__c=Customers[0].Id,
                                                                          ASI_CRM_CN_Use_PRC_Contract_Template__c = false,
                                                                          ASI_CRM_Volume_Option__c = 'Normal');
            insert Contract4;
            Contract4.Name = 'Contract4s';
            update Contract4;
            ASI_TH_CRM_Contract__c Contract5 = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_SG_Contract'),
                                                                          ASI_CRM_CN_Status__c = 'Draft',
                                                                          ownerId = userList[0].id,
                                                                          ASI_CRM_System_Debug__c=true,
                                                                          ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
                                                                          ASI_CRM_CN_PO_End_Date__c =PO_End_Date,
                                                                          ASI_CRM_CN_PO_Version__c = '0.0',
                                                                          ASI_TH_CRM_Promotion_Type__c='Wholesaler Promotion',
                                                                          ASI_CRM_PO_Channel__c = channel.Id,
                                                                          Name = 'Contract5',
                                                                          //ASI_CRM_CN_Outlet_WS__c=Customers[0].Id,
                                                                          ASI_CRM_CN_Use_PRC_Contract_Template__c = false,
                                                                          ASI_CRM_Volume_Option__c = 'Normal');
            insert Contract5;
            Contract5.Name = 'Contract5s';
            update Contract5;
        }
        
    }
    static testmethod void ASI_TH_CRM_Contract_BeforeUpdateTest2(){
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        thisUser.BypassVR__c  = true;
        update thisUser;
        System.runAs(thisUser){
            ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='Central Region',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Region__cASI_CRM_CN_Region'));
            insert region;
            
            ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
            insert division;
            
            ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
            insert area;
            
            ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id);
            insert city;
            
            ASI_CRM_CN_Channel_Group__c ChannelGroup = new ASI_CRM_CN_Channel_Group__c(Name='Test');
            insert ChannelGroup;
            
            ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(Name='MOT',ASI_CRM_BC_Rate__c=98,ASI_CRM_CN_On_Off__c='ON',ASI_CRM_For_Outlet__c=true,
                                                                      RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_For_Contract__c=TRUE, ASI_CRM_CN_Channel_Group__c=ChannelGroup.Id);
            insert channel;
            
            Date PO_Start_Date = date.newinstance(system.today().addMonths(-1).year(), system.today().addMonths(-1).month(), 1);
            Date PO_End_Date = PO_Start_Date.addMonths(1)-1;
            
            Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
            
            list<ASI_CRM_AccountsAdditionalField__c> Customers = new list<ASI_CRM_AccountsAdditionalField__c>();
            Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id, ASI_CRM_CN_BusinessLicenseUploading__c=true, ASI_CRM_CN_Business_License_Expire_date__c=PO_End_Date, ASI_CRM_CN_Business_License_Start_Date__c =PO_Start_Date,ASI_CRM_Channel_Group__c=ChannelGroup.Id));
            insert Customers;
            
            
            User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c FROM USER WHERE id =:UserInfo.getUserId()];
            
            Profile p = [SELECT Id FROM Profile limit 1]; 
            List<User> LUser = new List<User>();
            LUser.add(new User(Alias = 'standt', Email='standarduser@testorg.com', 
                               EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', ManagerId=userInfo.getUserId(),
                               LocaleSidKey='en_US', ProfileId = p.Id, ASI_CRM_Sales_Team__c = 'a',
                               TimeZoneSidKey='America/Los_Angeles', UserName='standarduser_c1@testing123.com', CompanyName = 'Pernod Ricard China'));
            insert LUser[0];
            
            List<User> userList= new List<User> ();
            userList.add(new User(Alias = 'standt', Email='standarduser@testorg.com', 
                                  EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                  LocaleSidKey='en_US', ProfileId = p.Id, ManagerID = LUser[0].id,
                                  TimeZoneSidKey='America/Los_Angeles', UserName='standarduser_c2@testing123.com', CompanyName = 'Pernod Ricard China', ASI_CRM_Sales_Team__c = 'a'));
            userList.add(new User(Alias = 'standts', Email='standarduser@testorg.com', 
                                  EmailEncodingKey='UTF-8', LastName='Testing3', LanguageLocaleKey='en_US', 
                                  LocaleSidKey='en_US', ProfileId = p.Id, 
                                  TimeZoneSidKey='America/Los_Angeles', UserName='standarduser_c3@testing123.com', CompanyName = 'Pernod Ricard China', ASI_CRM_Sales_Team__c = 'a'));
            insert userList;
            ASI_TH_CRM_Contract__c Contract6 = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_SG_Proposal'),
                                                                          ASI_CRM_CN_Status__c = 'Draft',
                                                                          ownerId = userList[0].id,
                                                                          ASI_CRM_System_Debug__c=true,
                                                                          ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
                                                                          ASI_CRM_CN_PO_End_Date__c =PO_End_Date,
                                                                          ASI_CRM_CN_PO_Version__c = '0.0',
                                                                          ASI_TH_CRM_Promotion_Type__c='Wholesaler Promotion',
                                                                          ASI_CRM_PO_Channel__c = channel.Id,
                                                                          Name = 'Contract6',
                                                                          //ASI_CRM_CN_Outlet_WS__c=Customers[0].Id,
                                                                          ASI_CRM_CN_Use_PRC_Contract_Template__c = false,
                                                                          ASI_CRM_Volume_Option__c = 'Normal');
            insert Contract6;
            Contract6.Name = 'Contract6s';
            update Contract6;
        }
    }
}