@isTest
public class EUR_CRM_FI_SubChainExtTest {

    public static EUR_CRM_Account__c euaccount = new EUR_CRM_Account__c();
    public static List<EUR_CRM_Account__c> euAccounts = new List<EUR_CRM_Account__c>();
    public static Contact contact = new Contact();
    public static EUR_CRM_Contract__c fiContract = new EUR_CRM_Contract__c();

    public static User eurSysUser;
    public static void setUser(){
        Profile p = [SELECT Id FROM Profile WHERE Name ='EUR System Admin']; 
        UserRole r = [select id from UserRole where Developername ='EMEA'];
        eurSysUser = new User(Alias = 'standt', Email='userEmail1234aoke@test.com', userroleid=r.id,
        EmailEncodingKey='UTF-8', LastName='userEmail1234aokelastName', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='userEmail1234aoke@test.com');
        insert eurSysUser;

    }

    public static void dataInsert1(){
        
        euaccount = EUR_CRM_FI_TestClassHelper.createEUAccount(1,'Test EU ACCOUNT', 'EUR_FI_Indirect_On_Trade').get(0);
        insert euaccount;

        euAccounts = EUR_CRM_FI_TestClassHelper.createEUAccount(3,'Test EU ACCOUNT--TEST', 'EUR_FI_Indirect_On_Trade');
        euAccounts.get(0).EUR_CRM_Parent_Account__c = euaccount.Id;
        euAccounts.get(1).EUR_CRM_Parent_Account__c = euaccount.Id;
        euAccounts.get(2).EUR_CRM_Parent_Account__c = euaccount.Id;

        contact = EUR_CRM_FI_TestClassHelper.createContact(1, 'TEST CONTACT', euaccount).get(0);
        insert contact;

        fiContract = EUR_CRM_FI_TestClassHelper.createFIContract(1,'test', euaccount, contact, 'EUR_FI_Chain_Contract').get(0);
        insert fiContract;

    }    
    static testMethod void test1(){
        setUser();
        System.runAs(eurSysUser){
            dataInsert1();

            ApexPages.StandardController sc = new ApexPages.StandardController(fiContract);
            EUR_CRM_FI_SubChainExt subChain = new EUR_CRM_FI_SubChainExt(sc);

        }
    }
}