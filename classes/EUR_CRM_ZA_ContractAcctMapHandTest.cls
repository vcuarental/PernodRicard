@isTest
public class EUR_CRM_ZA_ContractAcctMapHandTest {


    public static EUR_CRM_Account__c euaccount = new EUR_CRM_Account__c();
    public static EUR_CRM_Account__c euaccount2 = new EUR_CRM_Account__c();
    public static Contact contact = new Contact();
    public static EUR_CRM_Contract__c zaContract = new EUR_CRM_Contract__c();

    public static User eurSysUser;
    public static void setUser(){
        //Profile p = [SELECT Id FROM Profile WHERE Name ='EUR System Admin'];
        Profile p = [SELECT Id FROM Profile WHERE Name ='EUR ZA Standard On Trade User'];  
        UserRole r = [select id from UserRole where Developername ='EMEA'];
        eurSysUser = new User(Alias = 'standt', Email='userEmail1234aoke@test.com', userroleid=r.id,
        EmailEncodingKey='UTF-8', LastName='userEmail1234aokelastName', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='userEmail1234aoke@test.com');
        insert eurSysUser;

    }

     public static void dataInsert1(){

        euaccount = EUR_CRM_ZA_TestClassHelper.createEUAccount(1,'Test EU ACCOUNT', 'EUR_ZA_On_Trade_Direct').get(0);
        insert euaccount;
        system.assertNotEquals(euaccount, null);

        //euaccount2 = EUR_CRM_ZA_TestClassHelper.createEUAccount(1,'Test EU ACCOUNT2', 'EUR_ZA_On_Trade_Direct').get(0);
        //euaccount2.EUR_CRM_Parent_Account__c = euaccount.Id;
        //insert euaccount2;
        //system.assertNotEquals(euaccount2, null);


        contact = EUR_CRM_ZA_TestClassHelper.createContact(1, 'TEST CONTACT', euaccount).get(0);
        insert contact;
        system.assertNotEquals(contact, null);

        zaContract = EUR_CRM_ZA_TestClassHelper.createZAContract(1,'test', euaccount, contact, 'EUR_ZA_Head_Office_Contract').get(0);
        insert zaContract;
        system.assertNotEquals(zaContract, null);
        
      	
    }

    static testMethod void test1(){
    	setUser();
        System.runAs(eurSysUser){
        	dataInsert1();
            test.startTest();
                
                zaContract.EUR_CRM_Status__c = 'Activated';
                update zaContract;
                

            test.stopTest();
        }
    }
}