@isTest
private class EUR_CRM_EUAccountTeamHandlerTest {

    static testMethod void myUnitTest() {
        Id rtId = [select id from recordtype where developername = 'EUR_GB_FS_Indirect' and sobjecttype = 'eur_crm_account__c' limit 1].id;
        Id accTeamRTId = [SELECT Id FROM RecordType Where DeveloperName = 'EUR_GB_Account_Team' and SObjectType = 'EUR_CRM_Account_Team__c' LIMIT 1].Id;
  
        EUR_CRM_Account__c euAcct = new EUR_CRM_Account__c(name='test eu account', recordtypeid=rtId );
        insert euAcct;
        User usr = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' and IsActive = true limit 1];
        EUR_CRM_Account_Team__c acctTeam = new EUR_CRM_Account_Team__c(EUR_CRM_Account__c=euAcct.id);
        acctTeam.EUR_CRM_Team_Member__c = usr.Id;
        acctTeam.EUR_CRM_Access_Level__c = 'Read Only';
        acctTeam.RecordTypeId = accTeamRTId;
        insert acctTeam;
        
        acctTeam.EUR_CRM_Access_Level__c = 'Read/Write';
        update acctTeam;
        
        delete acctTeam;
    }
}