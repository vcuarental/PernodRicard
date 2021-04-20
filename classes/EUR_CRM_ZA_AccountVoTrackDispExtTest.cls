@isTest
public class EUR_CRM_ZA_AccountVoTrackDispExtTest {

    public static EUR_CRM_Account__c euaccount = new EUR_CRM_Account__c();
    public static EUR_CRM_Account_Volume_Tracker__c acctVolTracker = new EUR_CRM_Account_Volume_Tracker__c();
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

        acctVolTracker = EUR_CRM_ZA_TestClassHelper.createAccountVolumeTracker(1,euaccount).get(0);
        insert acctVolTracker;
        system.assertNotEquals(acctVolTracker, null);


        Map<String, String> mechTypeMap = new Map<String, String>{'Listing' => 'ZA Listing', 
                                                                    'Exclusivity' => 'ZA Exclusivity',
                                                                    'House pour' => 'ZA House pour',
                                                                    'Stock deals' => 'ZA Stock deals'};

        List<EUR_CRM_Mechanic_Type__c> mechTypeList = new List<EUR_CRM_Mechanic_Type__c>();

        for(String s : mechTypeMap.keyset()){
            EUR_CRM_Mechanic_Type__c mType = new EUR_CRM_Mechanic_Type__c();
            mType = EUR_CRM_TestClassUtilityHelper.createMechType(1,'EUR_ZA_Mechanic_Type',s).get(0);
            mType.EUR_CRM_Grouping_Name__c = mechTypeMap.get(s);
            mechTypeList.add(mType);
        }

        insert mechTypeList;
        Map<Id, EUR_CRM_Mechanic_Type__c> mechTypeMapId = new Map<Id, EUR_CRM_Mechanic_Type__c>(mechTypeList);

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
        insert volTrackItem;

    }    

    static testMethod void test2(){
        setUser();
        System.runAs(eurSysUser){
            Test.startTest();
            dataInsert1();

            
            ApexPages.StandardController sc = new ApexPages.StandardController(euaccount);
            EUR_CRM_ZA_AccountVolumeTrackDisplayExt contractVolTrackDisplayExt = new EUR_CRM_ZA_AccountVolumeTrackDisplayExt(sc);
            Test.stopTest();

        }
    }

    static testMethod void test5(){
        setUser();
        System.runAs(eurSysUser){
            dataInsert1();

            Test.startTest();
            Test.setCurrentPageReference(new PageReference('Page.EUR_CRM_ZA_AccountVolumeTrackerDisplay'));
            System.currentPageReference().getParameters().put('id', euaccount.Id);
            ApexPages.StandardController sc = new ApexPages.StandardController(euaccount);
            EUR_CRM_ZA_AccountVolumeTrackDisplayExt contractVolTrackExt = new EUR_CRM_ZA_AccountVolumeTrackDisplayExt(sc);
            contractVolTrackExt.openAccountVolumeTracker();


            Test.stopTest();

        }
    }

}