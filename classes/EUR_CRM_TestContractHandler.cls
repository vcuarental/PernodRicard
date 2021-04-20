@isTest
public class EUR_CRM_TestContractHandler {

    public static EUR_CRM_Account__c euaccount = new EUR_CRM_Account__c();
    public static Contact contact = new Contact();
    public static EUR_CRM_Contract__c zaContract = new EUR_CRM_Contract__c();
    public static EUR_CRM_Brand__c brand = new EUR_CRM_Brand__c();
    public static EUR_CRM_Quality__c brandQuality = new EUR_CRM_Quality__c();
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

    public static void dataInsert1(){
        
        euaccount = EUR_CRM_ZA_TestClassHelper.createEUAccount(1,'Test EU ACCOUNT', 'EUR_ZA_On_Trade_Indirect').get(0);
        euaccount.EUR_CRM_Postal_Code__c = '012345';
        insert euaccount;
        system.assertNotEquals(euaccount, null);


        contact = EUR_CRM_ZA_TestClassHelper.createContact(1, 'TEST CONTACT', euaccount).get(0);
        insert contact;
        system.assertNotEquals(contact, null);

        zaContract = EUR_CRM_ZA_TestClassHelper.createZAContract(1,'test', euaccount, contact, 'EUR_ZA_Head_Office_Contract').get(0);
        zaContract.EUR_CRM_Is_Calculate_Profit__c  = false;
        insert zaContract;
        system.assertNotEquals(zaContract, null);

        Map<String, String> mechTypeMap = new Map<String, String>{'Pouring Refund Spirits' => 'South Africa - Pouring', 
                                                                    'Pouring Refund Wines' => 'South Africa - Pouring',
                                                                    'Selection Brands Spirits' => 'South Africa - Selection',
                                                                    'Selection Brands Wines' => 'South Africa - Selection',
                                                                    'Marketing Activity Spirits' => 'South Africa - Marketing',
                                                                    'Marketing Activity Wines' => 'South Africa - Marketing',
                                                                    'Trips' => 'South Africa - Marketing',
                                                                    'Free stock' => 'South Africa - Marketing',
                                                                    'Education' => 'South Africa - Marketing'};

        List<EUR_CRM_Mechanic_Type__c> mechTypeList = new List<EUR_CRM_Mechanic_Type__c>();

        for(String s : mechTypeMap.keyset()){
            EUR_CRM_Mechanic_Type__c mType = new EUR_CRM_Mechanic_Type__c();
            mType = EUR_CRM_TestClassUtilityHelper.createMechType(1,'EUR_ZA_Mechanic_Type',s).get(0);
            mType.EUR_CRM_Grouping_Name__c = mechTypeMap.get(s);
            mechTypeList.add(mType);
        }

        insert mechTypeList;

        brand = EUR_CRM_TestClassUtilityHelper.createBrand(1, 'EUR_ZA_Brand', 'Test-Brand', '', null)[0];
        brand.EUR_CRM_Contributive_Margin_Brand__c = 0.5;
        insert brand;
        system.assertNotEquals(brand, null);

        brandQuality = EUR_CRM_TestClassUtilityHelper.createBrandQuality(1, 'EUR_ZA_Quality', 'Cocktail', 'TEST-0001', null)[0];
        brandQuality.EUR_CRM_Contributive_Margin_BQ__c = 0.6;
        insert brandQuality;
        system.assertNotEquals(brandQuality, null);

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItems = new List<EUR_CRM_Contract_Activity_Item__c>();
        for(EUR_CRM_Mechanic_Type__c mechType : mechTypeList){
            EUR_CRM_Contract_Activity_Item__c cActivity = new EUR_CRM_Contract_Activity_Item__c();
            cActivity = EUR_CRM_ZA_TestClassHelper.createContractActivityItem(1,zaContract, mechType).get(0);
            
            if(mechType.Name == 'Marketing Activity Spirits'){
                cActivity.EUR_CRM_Lumpsum_Value__c = 50;
            }
            contractActivityItems.add(cActivity);
        }

        insert contractActivityItems;

        productItems = new List<EUR_CRM_Contract_Product_Item__c>();
        for(EUR_CRM_Contract_Activity_Item__c cActivity : contractActivityItems){
            EUR_CRM_Contract_Product_Item__c productItem = new EUR_CRM_Contract_Product_Item__c();
            productItem = EUR_CRM_ZA_TestClassHelper.createProductItem(1,cActivity).get(0);
            productItem.EUR_CRM_Brand_Quality__c = brandQuality.Id;
            productItem.EUR_CRM_Brand__c = brand.Id;

            productItems.add(productItem);
        }

        insert productItems;
    }    

    static testMethod void test1(){
        setUser();
        System.runAs(eurSysUser){
            Test.startTest();
                dataInsert1();
            Test.stopTest();

            zaContract.EUR_CRM_Is_Calculate_Profit__c = true;
            update zaContract;
        }
    }
}