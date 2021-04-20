@isTest
public with sharing class EUR_CRM_ZA_ProductEnabledBQSHandTest {

	public static EUR_CRM_Account__c euaccount = new EUR_CRM_Account__c();
    public static EUR_CRM_Account__c euaccount2 = new EUR_CRM_Account__c();
    public static EUR_CRM_Account_Volume_Tracker__c acctVolTracker = new EUR_CRM_Account_Volume_Tracker__c();
    public static EUR_CRM_Account_Volume_Tracker__c acctVolTracker2 = new EUR_CRM_Account_Volume_Tracker__c();
    public static Contact contact = new Contact();
    public static EUR_CRM_Contract__c zaContract = new EUR_CRM_Contract__c();
    public static EUR_CRM_Brand__c brand = new EUR_CRM_Brand__c();
    public static EUR_CRM_Quality__c brandQuality = new EUR_CRM_Quality__c();
    public static EUR_CRM_Size__c brandQualitySize = new EUR_CRM_Size__c();
    //public static EUR_CRM_Mechanic_Type__c mechType = new EUR_CRM_Mechanic_Type__c();
    public static EUR_CRM_Contract_Activity_Item__c contractActivityItem = new EUR_CRM_Contract_Activity_Item__c();
    public static EUR_CRM_Account_Volume_Tracker_Line_Item__c volTrackItem = new EUR_CRM_Account_Volume_Tracker_Line_Item__c();
    

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
        
        euaccount = EUR_CRM_ZA_TestClassHelper.createEUAccount(1,'Test EU ACCOUNT', 'EUR_ZA_On_Trade_Indirect').get(0);
        insert euaccount;
        system.assertNotEquals(euaccount, null);
        
        List<EUR_CRM_Account_Volume_Tracker__c> volTrackItems = EUR_CRM_ZA_TestClassHelper.createAccountVolumeTracker(2,euaccount);

        //acctVolTracker = EUR_CRM_ZA_TestClassHelper.createAccountVolumeTracker(1,euaccount).get(0);
        acctVolTracker = volTrackItems.get(0);
        insert acctVolTracker;
        system.assertNotEquals(acctVolTracker, null);
        
        acctVolTracker2 = volTrackItems.get(1);
        insert acctVolTracker2;
        system.assertNotEquals(acctVolTracker2, null);

        brand = EUR_CRM_TestClassUtilityHelper.createBrand(1, 'EUR_ZA_Brand', 'Test-Brand', '', null)[0];
        brand.EUR_CRM_Contributive_Margin_Brand__c = 0.5;
        insert brand;
        system.assertNotEquals(brand, null);

        brandQuality = EUR_CRM_TestClassUtilityHelper.createBrandQuality(1, 'EUR_ZA_Quality', 'Cocktail', 'TEST-0001', null)[0];
        brandQuality.EUR_CRM_Contributive_Margin_BQ__c = 0.6;
        brandQuality.EUR_CRM_Enable_Account_Volume_Tracking__c = FALSE;
        insert brandQuality;
        system.assertNotEquals(brandQuality, null);

        brandQualitySize = EUR_CRM_ZA_TestClassHelper.createBrandQualitySize(1,'test BQS', 'bqs1111', brandQuality.Id).get(0);
        brandQualitySize.EUR_CRM_Enable_Account_Volume_Tracking__c = FALSE;

        insert brandQualitySize;
        
        
        volTrackItem = EUR_CRM_ZA_TestClassHelper.createAccountVolumeTrackerLineItem(1,acctVolTracker).get(0);
        volTrackItem.EUR_CRM_Brand_Quality__c = brandQuality.id;
        volTrackItem.EUR_CRM_Brand_Quality_Size__c = brandQualitySize.Id;
        insert volTrackItem;


    } 
    
    public static void dataInsert2(){
        
        euaccount = EUR_CRM_ZA_TestClassHelper.createEUAccount(1,'Test EU ACCOUNT', 'EUR_ZA_On_Trade_Indirect').get(0);
        insert euaccount;
        system.assertNotEquals(euaccount, null);

        acctVolTracker = EUR_CRM_ZA_TestClassHelper.createAccountVolumeTracker(1,euaccount).get(0);
        insert acctVolTracker;
        system.assertNotEquals(acctVolTracker, null);

        brand = EUR_CRM_TestClassUtilityHelper.createBrand(1, 'EUR_ZA_Brand', 'Test-Brand', '', null)[0];
        brand.EUR_CRM_Contributive_Margin_Brand__c = 0.5;
        insert brand;
        system.assertNotEquals(brand, null);

        brandQuality = EUR_CRM_TestClassUtilityHelper.createBrandQuality(1, 'EUR_ZA_Quality', 'Cocktail', 'TEST-0001', null)[0];
        brandQuality.EUR_CRM_Contributive_Margin_BQ__c = 0.6;
        brandQuality.EUR_CRM_Enable_Account_Volume_Tracking__c = TRUE;
        insert brandQuality;
        system.assertNotEquals(brandQuality, null);

        brandQualitySize = EUR_CRM_ZA_TestClassHelper.createBrandQualitySize(1,'test BQS', 'bqs1111', brandQuality.Id).get(0);
        brandQualitySize.EUR_CRM_Enable_Account_Volume_Tracking__c = TRUE;

        insert brandQualitySize;
        
        volTrackItem = EUR_CRM_ZA_TestClassHelper.createAccountVolumeTrackerLineItem(1,acctVolTracker).get(0);
        volTrackItem.EUR_CRM_Brand_Quality__c = brandQuality.id;
        volTrackItem.EUR_CRM_Brand_Quality_Size__c = brandQualitySize.Id;
        insert volTrackItem;

    } 
    
    static testMethod void test1(){
        setUser();
        System.runAs(eurSysUser){
            Test.startTest();
            dataInsert1();
            
			brandQuality.EUR_CRM_Enable_Account_Volume_Tracking__c = TRUE;
			update brandQuality;
           	
            Test.stopTest();

        }
    }
    
    static testMethod void test2(){
        setUser();
        System.runAs(eurSysUser){
            Test.startTest();
            dataInsert1();
            
			brandQualitySize.EUR_CRM_Enable_Account_Volume_Tracking__c = TRUE;
			update brandQualitySize;
           	
            Test.stopTest();

        }
    }
    
    static testMethod void test3(){
        setUser();
        System.runAs(eurSysUser){
            Test.startTest();
            dataInsert2();
            
			brandQuality.EUR_CRM_Enable_Account_Volume_Tracking__c = FALSE;
			update brandQuality;
           	
            Test.stopTest();

        }
    }
    
    static testMethod void test4(){
        setUser();
        System.runAs(eurSysUser){
            Test.startTest();
            dataInsert2();
            
			brandQualitySize.EUR_CRM_Enable_Account_Volume_Tracking__c = FALSE;
			update brandQualitySize;
           	
            Test.stopTest();

        }
    }
}