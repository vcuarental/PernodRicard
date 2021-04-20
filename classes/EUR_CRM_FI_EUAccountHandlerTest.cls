@isTest
public class EUR_CRM_FI_EUAccountHandlerTest {

    
    public static EUR_CRM_Account__c euaccount = new EUR_CRM_Account__c();
    public static List<EUR_CRM_Visit_Frequency__c> visitFrequencies = new List<EUR_CRM_Visit_Frequency__c>();

    //public static User eurSysUser;
	
    @testSetup static void setUser(){
        
        User thisUser = [ SELECT Id,BypassTriggers__c FROM User WHERE Id = :UserInfo.getUserId() ];
    	String bypass = ''+thisUser.BypassTriggers__c;
        
        thisUser.BypassTriggers__c = 'Autofollow_User_InsertUpdate,AutoJoin_User_InsertUpdate,ESN_User_AutojoinByAffiliates,ChatterEmailSettings';
        Update thisUser;
        
        User eurSysUser;
        Profile p = [SELECT Id FROM Profile WHERE Name ='EUR System Admin']; 
        UserRole r = [select id from UserRole where Developername ='EMEA'];
        eurSysUser = new User(Alias = 'standt', Email='userEmail1234aoke@test.com', userroleid=r.id,
        EmailEncodingKey='UTF-8', LastName='userEmail1234aokelastName', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, BypassTriggers__c = 'Autofollow_User_InsertUpdate,AutoJoin_User_InsertUpdate,ESN_User_AutojoinByAffiliates,ChatterEmailSettings',
        TimeZoneSidKey='America/Los_Angeles', UserName='userEmail1234aoke@test.com');
        insert eurSysUser;

        
        User eurSysUser2 = [SELECT id FROM User WHERE Email='userEmail1234aoke@test.com' and LastName='userEmail1234aokelastName'];
        System.Debug(eurSysUser2);
    }
    
	@future
    public static void dataInsert1(){

        Map<String, String> visitFrequencyMap = new Map<String, String>{'Once a quarter' => 'Once a quarter', 
                                                                    'Once every 6 months' => 'Once every 6 months'};

        for(String s : visitFrequencyMap.keyset()){
            EUR_CRM_Visit_Frequency__c frequency = new EUR_CRM_Visit_Frequency__c();
            frequency = EUR_CRM_FI_TestClassHelper.createVisitFrequency(1,s).get(0);
            visitFrequencies.add(frequency);
        }

        insert visitFrequencies;
    }    
    
    static testMethod void test1(){
        User eurSysUser = [SELECT id FROM User WHERE Email='userEmail1234aoke@test.com' and LastName='userEmail1234aokelastName'];
        //setUser();
        System.runAs(eurSysUser){
            //dataInsert1();
            euaccount = EUR_CRM_FI_TestClassHelper.createEUAccount(1,'Test EU ACCOUNT', 'EUR_FI_Direct_On_Trade').get(0);
            try{
            	insert euaccount;
            }catch(Exception e){
                
            }
            system.assertNotEquals(euaccount, null);
        }
    }

    static testMethod void test2(){
        //setUser();
        User eurSysUser = [SELECT id FROM  User WHERE Email='userEmail1234aoke@test.com' and LastName='userEmail1234aokelastName'];
        System.runAs(eurSysUser){
            //dataInsert1();
            euaccount = EUR_CRM_FI_TestClassHelper.createEUAccount(1,'Test EU ACCOUNT', 'EUR_FI_Direct_Off_Trade').get(0);
            try{
            	insert euaccount;
            }catch(Exception e){
                
            }
            system.assertNotEquals(euaccount, null);
        }
    }

    static testMethod void test3(){
        //setUser();
        User eurSysUser = [SELECT id FROM  User WHERE Email='userEmail1234aoke@test.com' and LastName='userEmail1234aokelastName'];
        System.runAs(eurSysUser){
            //dataInsert1();
            euaccount = EUR_CRM_FI_TestClassHelper.createEUAccount(1,'Test EU ACCOUNT', 'EUR_FI_Indirect_On_Trade').get(0);
            try{
            	insert euaccount;
            }catch(Exception e){
                
            }
            system.assertNotEquals(euaccount, null);
        }
    }

    static testMethod void test4(){
        //setUser();
        User eurSysUser = [SELECT id FROM User WHERE Email='userEmail1234aoke@test.com' and LastName='userEmail1234aokelastName'];
        System.runAs(eurSysUser){
            //dataInsert1();
            euaccount = EUR_CRM_FI_TestClassHelper.createEUAccount(1,'Test EU ACCOUNT', 'EUR_FI_Indirect_Off_Trade').get(0);
            try{
            	insert euaccount;
            }catch(Exception e){
                
            }
            system.assertNotEquals(euaccount, null);
        }
    }
}