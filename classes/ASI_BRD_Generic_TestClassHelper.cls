/*********************************************************************************
 * Name:ASI_BRD_Generic_TestClassHelper
 * Description: For generating test data for ASI BRD Generic
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------
 * 10/23/2015         Laputa: Hank            Created
*********************************************************************************/
@isTest
public class ASI_BRD_Generic_TestClassHelper{
    //Create custom settings: ASI_BRD_Generic_CRM_Mapping__c
    public static void createCrmMapping(){
        List<ASI_BRD_Generic_CRM_Mapping__c> crmList = new List<ASI_BRD_Generic_CRM_Mapping__c>();
        crmList.add(new ASI_BRD_Generic_CRM_Mapping__c(Name = 'Taiwan', ASI_BRD_Running_Number__c = 'ASI_Luxury_Account_TW', ASI_BRD_Record_Type__c = 'ASI_BRD_Generic_TW_CRM_Account', ASI_BRD_Primary_Market_HTML_Id__c = 'test'));
        insert crmList;
    }
    
    //Create running number: ASI_HK_CRM_Running_Number__c
    public static void createRunningNo(){
        List<ASI_HK_CRM_Running_Number__c> noList = new List<ASI_HK_CRM_Running_Number__c>();
        noList.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 7, ASI_HK_CRM_Object_Name__c = 'ASI_Luxury_Account_TW', ASI_HK_CRM_Format__c = 'TWN-{000000}', ASI_HK_CRM_Running_Number__c = 0));
        noList.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 7, ASI_HK_CRM_Object_Name__c ='ASI_HK_CRM_Sales_Order__c', ASI_HK_CRM_Format__c = 'SO-{YY}{000000}', ASI_HK_CRM_Running_Number__c = 0));
        noList.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 7, ASI_HK_CRM_Object_Name__c ='ASI_Luxury_Brand_Account_SG', ASI_HK_CRM_Format__c = 'SO-{YY}{000000}', ASI_HK_CRM_Running_Number__c = 0));
        insert noList;
    }
    
    //Create custom settings: ASI_BRD_Generic_CRM_Default_Values__c
    public static void createDefValMapping(){
        List<ASI_BRD_Generic_CRM_Default_Values__c> defValList = new List<ASI_BRD_Generic_CRM_Default_Values__c>();
        defValList.add(new ASI_BRD_Generic_CRM_Default_Values__c(Name = 'Taiwan'));
        insert defValList;
    }
    
    //Create Account
    public static Account createAcc(){
        Account acc = new Account(LastName = 'TestAcc', recordtypeId = Global_RecordTypeCache.getRtId('AccountASI_BRD_Generic_CRM_Account'), ASI_BRD_Converted_Lead_Record_Type__pc = 'ASI_BRD_Generic_CRM_Lead', ASI_BRD_Primary_Market__pc = 'Taiwan');
        insert acc;
        return acc;
    }
    
    //Create Account **BUT DONT INSERT**
    public static Account newAcc(){
        Account acc = new Account(LastName = 'TestAcc', recordtypeId = Global_RecordTypeCache.getRtId('AccountASI_BRD_Generic_CRM_Account'), ASI_BRD_Converted_Lead_Record_Type__pc = 'ASI_BRD_Generic_CRM_Lead', ASI_BRD_Primary_Market__pc = 'Taiwan');
        return acc;
    }
    
    //Create Account with email/phone
    public static Account createAcc(String emailStr, String bEmailStr, String phoneStr, String mobileStr){
        Account acc = new Account(LastName = 'TestAcc', recordtypeId = Global_RecordTypeCache.getRtId('AccountASI_BRD_Generic_TW_CRM_Account'), ASI_BRD_Converted_Lead_Record_Type__pc = 'ASI_BRD_Generic_CRM_Lead', ASI_BRD_Primary_Market__pc = 'Taiwan');
        acc.PersonEmail = emailStr;
        acc.ASI_LUX_Email_Business__c = bEmailStr;
        acc.Phone = phoneStr;
        acc.PersonMobilePhone = mobileStr;
        insert acc;
        return acc;
    }
    
    //Create Account with email/phone **BUT DONT INSERT**
    public static Account newAcc(String emailStr, String bEmailStr, String phoneStr, String mobileStr){
        Account acc = new Account(LastName = 'TestAcc', recordtypeId = Global_RecordTypeCache.getRtId('AccountASI_BRD_Generic_TW_CRM_Account'), ASI_BRD_Converted_Lead_Record_Type__pc = 'ASI_BRD_Generic_CRM_Lead', ASI_BRD_Primary_Market__pc = 'Taiwan');
        acc.PersonEmail = emailStr;
        acc.ASI_LUX_Email_Business__c = bEmailStr;
        acc.Phone = phoneStr;
        acc.PersonMobilePhone = mobileStr;
        return acc;
    }
    
    //Create User with primary market
    public static User createUser(String mkt){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u1 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, ASI_BRD_CRM_Market__c = mkt,
            TimeZoneSidKey='America/Los_Angeles', UserName='test1_brd_generic@laputa.com');
        insert u1;
        return u1;
    }
    
    //Create User without primary market
    public static User createUser(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u1 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='test1_brd_generic@laputa.com');
        insert u1;
        return u1;
    }
    
    //Create Lead
    public static Lead createLead(){
        Lead l = new Lead(RecordTypeId = Global_RecordTypeCache.getRtId('LeadASI_BRD_Generic_CRM_Lead'),LastName = 'test', Status = 'Open', LeadSource = 'Web', Email = 'test1_brd_generic@laputa.com', ASI_BRD_Primary_Market__c = 'Taiwan', ASI_BRD_Acquired_By__c = 'Absolut');
        insert l;
        return l;
    }
    
    //Create CampaignMember
    public static CampaignMember newCampaignMember(Id conId){
        Campaign c = new Campaign(Name = 'Test Campaign', RecordTypeId = Global_RecordTypeCache.getRtId('CampaignASI_BRD_Generic_CRM_Campaign'), StartDate = date.today().addMonths(-2), 
                                 endDate = date.today().addMonths(-1), status = 'Planned');
        insert c;
        List<CampaignMemberStatus> statusList = new List<CampaignMemberStatus>();
        CampaignMemberStatus newStatus1 = new CampaignMemberStatus(
            CampaignID=c.id,
            Label='Attended',
            IsDefault=false,
            HasResponded=false,
            SortOrder=3
        );
        CampaignMemberStatus newStatus2 = new CampaignMemberStatus(
            CampaignID=c.id,
            Label='Not Attended',
            IsDefault=false,
            HasResponded=false,
            SortOrder=4
        );
        statusList.add(newStatus1);
        statusList.add(newStatus2);
        insert statusList;
        
        CampaignMember cm = new CampaignMember(CampaignId = c.Id,contactId = conId);
        return cm;   
    }
}