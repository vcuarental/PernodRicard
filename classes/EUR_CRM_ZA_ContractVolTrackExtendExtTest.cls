@isTest
public class EUR_CRM_ZA_ContractVolTrackExtendExtTest {

    public static EUR_CRM_Account__c euaccount = new EUR_CRM_Account__c();
    public static Contact contact = new Contact();
    public static EUR_CRM_Contract__c zaContract = new EUR_CRM_Contract__c();
    public static EUR_CRM_Brand__c brand = new EUR_CRM_Brand__c();
    public static EUR_CRM_Quality__c brandQuality = new EUR_CRM_Quality__c();
    public static EUR_CRM_Size__c brandQualitySize = new EUR_CRM_Size__c();
    //public static EUR_CRM_Mechanic_Type__c mechType = new EUR_CRM_Mechanic_Type__c();
    public static EUR_CRM_Contract_Activity_Item__c contractActivityItem = new EUR_CRM_Contract_Activity_Item__c();
    public static List<EUR_CRM_Contract_Product_Item__c> productItems = new List<EUR_CRM_Contract_Product_Item__c> ();

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

    public static List<EUR_CRM_Mechanic_Type__c> dataInsert1(){
        
        euaccount = EUR_CRM_ZA_TestClassHelper.createEUAccount(1,'Test EU ACCOUNT', 'EUR_ZA_On_Trade_Direct').get(0);
        insert euaccount;
        system.assertNotEquals(euaccount, null);


        contact = EUR_CRM_ZA_TestClassHelper.createContact(1, 'TEST CONTACT', euaccount).get(0);
        insert contact;
        system.assertNotEquals(contact, null);

        zaContract = EUR_CRM_ZA_TestClassHelper.createZAContract(1,'test', euaccount, contact, 'EUR_ZA_Head_Office_Contract').get(0);
        insert zaContract;
        system.assertNotEquals(zaContract, null);

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
        //Map<Id, EUR_CRM_Mechanic_Type__c> mechTypeMapId = new Map<Id, EUR_CRM_Mechanic_Type__c>(mechTypeList);

        return mechTypeList;
    }  
    
    public static void insertBrandItems(List<EUR_CRM_Mechanic_Type__c> mechTypeList) {
        brand = EUR_CRM_TestClassUtilityHelper.createBrand(1, 'EUR_ZA_Brand', 'Test-Brand', '', null)[0];
        brand.EUR_CRM_Contributive_Margin_Brand__c = 0.5;
        insert brand;
        system.assertNotEquals(brand, null);

        brandQuality = EUR_CRM_TestClassUtilityHelper.createBrandQuality(1, 'EUR_ZA_Quality', 'Cocktail', 'TEST-0001', null)[0];
        brandQuality.EUR_CRM_Contributive_Margin_BQ__c = 0.6;
        insert brandQuality;
        system.assertNotEquals(brandQuality, null);

        brandQualitySize = EUR_CRM_ZA_TestClassHelper.createBrandQualitySize(1,'test BQS', 'bqs1111', brandQuality.Id).get(0);

        insert brandQualitySize;

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItems = new List<EUR_CRM_Contract_Activity_Item__c>();
        for(EUR_CRM_Mechanic_Type__c mechType : mechTypeList){
            EUR_CRM_Contract_Activity_Item__c cActivity = new EUR_CRM_Contract_Activity_Item__c();
            cActivity = EUR_CRM_ZA_TestClassHelper.createContractActivityItem(1,zaContract, mechType).get(0);

            contractActivityItems.add(cActivity);
        }

        insert contractActivityItems;

        productItems = new List<EUR_CRM_Contract_Product_Item__c>();
        for(EUR_CRM_Contract_Activity_Item__c cActivity : contractActivityItems){
            EUR_CRM_Contract_Product_Item__c productItem = new EUR_CRM_Contract_Product_Item__c();
            productItem = EUR_CRM_ZA_TestClassHelper.createProductItem(1,cActivity).get(0);
            //productItem.EUR_CRM_Brand_Quality__c = brandQuality.Id;
            //productItem.EUR_CRM_Brand__c = brand.Id;
            /*if(mechTypeMapId.get(cActivity.EUR_CRM_Mechanic_Type__c).Name == 'Listing' ||){
                productItem.EUR_CRM_Brand__c = brand.Id;
            }

            if(mechTypeMapId.get(cActivity.EUR_CRM_Mechanic_Type__c).Name == 'Selection Brands Spirit' || mechTypeMapId.get(cActivity.EUR_CRM_Mechanic_Type__c).Name == 'Pouring Refund Spirit'){
                productItem.EUR_CRM_Brand_Quality_Size__c = brandQualitySize.Id;
            }*/
            productItem.EUR_CRM_Brand_Quality__c = brandQuality.Id;
            

            productItems.add(productItem);
        }

        insert productItems;
        
    }
    
      
    static testMethod void test1(){
        setUser();
        System.runAs(eurSysUser){
            List<EUR_CRM_Mechanic_Type__c> mechTypeList = dataInsert1();
            Test.startTest();
            
            insertBrandItems(mechTypeList);
            
            ApexPages.StandardController sc = new ApexPages.StandardController(zaContract);
            EUR_CRM_ZA_ContractVolTrackExtendedExt contractVolTrackExt = new EUR_CRM_ZA_ContractVolTrackExtendedExt(sc);
            Test.stopTest();

        }
    }

    static testMethod void test2(){
        setUser();
        System.runAs(eurSysUser){
            List<EUR_CRM_Mechanic_Type__c> mechTypeList = dataInsert1();
            
            Test.startTest();
            insertBrandItems(mechTypeList);
            
            delete productItems;

            
            ApexPages.StandardController sc = new ApexPages.StandardController(zaContract);
            EUR_CRM_ZA_ContractVolTrackExtendedExt contractVolTrackExt = new EUR_CRM_ZA_ContractVolTrackExtendedExt(sc);
            test.stopTest();

        }
    }

    static testMethod void test3(){
        setUser();
        System.runAs(eurSysUser){
            List<EUR_CRM_Mechanic_Type__c> mechTypeList = dataInsert1();

            /*ApexPages.StandardController sc = new ApexPages.StandardController(fiContract);
            EUR_CRM_FI_ContractVolTrackExtendedExt contractVolTrackExt = new EUR_CRM_FI_ContractVolTrackExtendedExt(sc);
            contractVolTrackExt.addNewVolumePeriod();
            contractVolTrackExt.saveVolTracker();*/

            Test.startTest();
            
            insertBrandItems(mechTypeList);
            
            Test.setCurrentPageReference(new PageReference('Page.EUR_CRM_ZA_ContractVolTrackExtendedExt'));
            System.currentPageReference().getParameters().put('id', zaContract.Id);
            ApexPages.StandardController sc = new ApexPages.StandardController(zaContract);
            EUR_CRM_ZA_ContractVolTrackExtendedExt contractVolTrackExt = new EUR_CRM_ZA_ContractVolTrackExtendedExt(sc);
            //contractVolTrackExt.volumeTrackerItemList;
            contractVolTrackExt.addNewVolumePeriod();
            System.currentPageReference().getParameters().put('IS_QUICK_SAVE', 'true');
            //contractVolTrackExt.saveVolTracker();
            System.debug('%%STARTDATE1-1: '+contractVolTrackExt.volTrackItemPeriodList.get(0).volTrackerPeriods.get(0).EUR_CRM_Start_Date__c);
            System.debug('%%ENDDATE1-1: '+contractVolTrackExt.volTrackItemPeriodList.get(0).volTrackerPeriods.get(0).EUR_CRM_End_Date__c);

            contractVolTrackExt.volTrackItemPeriodList.get(0).volTrackerPeriods.get(0).EUR_CRM_Start_Date__c = Date.Today();
            contractVolTrackExt.volTrackItemPeriodList.get(0).volTrackerPeriods.get(0).EUR_CRM_End_Date__c = Date.Today().addDays(60);

            System.debug('%%STARTDATE1-2: '+contractVolTrackExt.volTrackItemPeriodList.get(0).volTrackerPeriods.get(0).EUR_CRM_Start_Date__c);
            System.debug('%%ENDDATE1-2: '+contractVolTrackExt.volTrackItemPeriodList.get(0).volTrackerPeriods.get(0).EUR_CRM_End_Date__c);
            contractVolTrackExt.saveVolTracker();
            Test.stopTest();

        }
    }

    static testMethod void test4(){
        setUser();
        System.runAs(eurSysUser){
            List<EUR_CRM_Mechanic_Type__c> mechTypeList = dataInsert1();

            /*ApexPages.StandardController sc = new ApexPages.StandardController(fiContract);
            EUR_CRM_FI_ContractVolTrackExtendedExt contractVolTrackExt = new EUR_CRM_FI_ContractVolTrackExtendedExt(sc);
            contractVolTrackExt.addNewVolumePeriod();
            contractVolTrackExt.saveVolTracker();*/

            Test.startTest();
            
            insertBrandItems(mechTypeList);
            
            Test.setCurrentPageReference(new PageReference('Page.EUR_CRM_ZA_ContractVolTrackExtendedExt'));
            System.currentPageReference().getParameters().put('id', zaContract.Id);
            ApexPages.StandardController sc = new ApexPages.StandardController(zaContract);
            EUR_CRM_ZA_ContractVolTrackExtendedExt contractVolTrackExt = new EUR_CRM_ZA_ContractVolTrackExtendedExt(sc);
            //contractVolTrackExt.volumeTrackerItemList;
            contractVolTrackExt.addNewVolumePeriod();
            System.currentPageReference().getParameters().put('IS_QUICK_SAVE', 'true');
            //contractVolTrackExt.saveVolTracker();
            System.debug('%%STARTDATE2-1: '+contractVolTrackExt.volTrackItemPeriodList.get(0).volTrackerPeriods.get(0).EUR_CRM_Start_Date__c);
            System.debug('%%ENDDATE2-1: '+contractVolTrackExt.volTrackItemPeriodList.get(0).volTrackerPeriods.get(0).EUR_CRM_End_Date__c);

            contractVolTrackExt.volTrackItemPeriodList.get(0).volTrackerPeriods.get(0).EUR_CRM_Start_Date__c = Date.Today();
            contractVolTrackExt.volTrackItemPeriodList.get(0).volTrackerPeriods.get(0).EUR_CRM_End_Date__c = Date.Today().addDays(-10);

            System.debug('%%STARTDATE2-2: '+contractVolTrackExt.volTrackItemPeriodList.get(0).volTrackerPeriods.get(0).EUR_CRM_Start_Date__c);
            System.debug('%%ENDDATE2-2: '+contractVolTrackExt.volTrackItemPeriodList.get(0).volTrackerPeriods.get(0).EUR_CRM_End_Date__c);
            contractVolTrackExt.saveVolTracker();
            Test.stopTest();

        }
    }
}