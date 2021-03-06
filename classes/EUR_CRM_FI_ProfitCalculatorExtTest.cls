@IsTest
private class EUR_CRM_FI_ProfitCalculatorExtTest {
    
    private static EUR_CRM_Account__c euaccount = new EUR_CRM_Account__c();
    private static Contact contact = new Contact();
    private static EUR_CRM_Contract__c fiContract = new EUR_CRM_Contract__c();
    private static EUR_CRM_Brand__c brand = new EUR_CRM_Brand__c();
    private static EUR_CRM_Quality__c brandQuality = new EUR_CRM_Quality__c();
    private static List<EUR_CRM_Contract_Product_Item__c> productItems = new List<EUR_CRM_Contract_Product_Item__c> ();

    private static User eurSysUser;
    private static void setUser(){
        Profile p = [SELECT Id FROM Profile WHERE Name ='EUR System Admin']; 
        UserRole r = [select id from UserRole where Developername ='EMEA'];
        eurSysUser = new User(Alias = 'standt', Email='userEmail1234aoke@test.com', userroleid=r.id,
        EmailEncodingKey='UTF-8', LastName='userEmail1234aokelastName', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='userEmail1234aoke@test.com');
        insert eurSysUser;

    }

    private static void dataInsert1(){
        Test.startTest();
        euaccount = EUR_CRM_FI_TestClassHelper.createEUAccount(1,'Test EU ACCOUNT', 'EUR_FI_Indirect_On_Trade').get(0);
        insert euaccount;
        system.assertNotEquals(euaccount, null);


        contact = EUR_CRM_FI_TestClassHelper.createContact(1, 'TEST CONTACT', euaccount).get(0);
        insert contact;
        system.assertNotEquals(contact, null);

        fiContract = EUR_CRM_FI_TestClassHelper.createFIContract(1,'test', euaccount, contact, 'EUR_FI_Chain_Contract').get(0);
        insert fiContract;
        system.assertNotEquals(fiContract, null);

        Map<String, String> mechTypeMap = new Map<String, String>{'Pouring Refund Spirits' => 'Finland - Pouring', 
                                                                    'Pouring Refund Wines' => 'Finland - Pouring',
                                                                    'Selection Brands Spirits' => 'Finland - Selection',
                                                                    'Selection Brands Wines' => 'Finland - Selection',
                                                                    'Marketing Activity Spirits' => 'Finland - Marketing',
                                                                    'Marketing Activity Wines' => 'Finland - Marketing',
                                                                    'Trips' => 'Finland - Marketing',
                                                                    'Free stock' => 'Finland - Marketing',
                                                                    'Education' => 'Finland - Marketing'};

        List<EUR_CRM_Mechanic_Type__c> mechTypeList = new List<EUR_CRM_Mechanic_Type__c>();

        //mechType = EUR_CRM_TestClassUtilityHelper.createMechType(1,'EUR_FI_Mechanic_Type','Pouring Spirits').get(0);
        //insert mechType;

        for(String s : mechTypeMap.keyset()){
            EUR_CRM_Mechanic_Type__c mType = new EUR_CRM_Mechanic_Type__c();
            mType = EUR_CRM_TestClassUtilityHelper.createMechType(1,'EUR_FI_Mechanic_Type',s).get(0);
            mType.EUR_CRM_Grouping_Name__c = mechTypeMap.get(s);
            mechTypeList.add(mType);
        }

        insert mechTypeList;

        brand = EUR_CRM_TestClassUtilityHelper.createBrand(1, 'EUR_FI_Brand', 'Test-Brand', '', null)[0];
        brand.EUR_CRM_Contributive_Margin_Brand__c = 0.5;
        insert brand;
        system.assertNotEquals(brand, null);

        brandQuality = EUR_CRM_TestClassUtilityHelper.createBrandQuality(1, 'EUR_FI_Quality', 'Cocktail', 'TEST-0001', null)[0];
        brandQuality.EUR_CRM_Contributive_Margin_BQ__c = 0.6;
        insert brandQuality;
        system.assertNotEquals(brandQuality, null);

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItems = new List<EUR_CRM_Contract_Activity_Item__c>();
        for(EUR_CRM_Mechanic_Type__c mechType : mechTypeList){
            EUR_CRM_Contract_Activity_Item__c cActivity = new EUR_CRM_Contract_Activity_Item__c();
            cActivity = EUR_CRM_FI_TestClassHelper.createContractActivityItem(1,fiContract, mechType).get(0);
            /*if(mechType.EUR_CRM_Grouping_Name__c == 'Finland - Pouring' || mechType.EUR_CRM_Grouping_Name__c == 'Finland - Selection'){

            }*/
            
            if(mechType.Name == 'Marketing Activity Spirits'){
                cActivity.EUR_CRM_Lumpsum_Value__c = 50;
            }
            contractActivityItems.add(cActivity);
        }

        insert contractActivityItems;

        productItems = new List<EUR_CRM_Contract_Product_Item__c>();
        for(EUR_CRM_Contract_Activity_Item__c cActivity : contractActivityItems){
            EUR_CRM_Contract_Product_Item__c productItem = new EUR_CRM_Contract_Product_Item__c();
            productItem = EUR_CRM_FI_TestClassHelper.createProductItem(1,cActivity).get(0);
            productItem.EUR_CRM_Brand_Quality__c = brandQuality.Id;
            productItem.EUR_CRM_Brand__c = brand.Id;

            productItems.add(productItem);
        }
        insert productItems;

        Map<Id, List<EUR_CRM_Contract_Product_Item__c>> cpisByMT = EUR_CRM_FI_UtilClass.retrieveContractProductLineItems(fiContract.Id);
        System.debug('\n cpisByMT.size() => ' + cpisByMT.size() + '\n');
        System.debug('\n cpisByMT => ' + JSON.serializePretty(cpisByMT) + '\n');
        Test.stopTest();

    }
    @IsTest
    private static void test1(){
        setUser();
        System.runAs(eurSysUser){
            dataInsert1();

            ApexPages.StandardController sc = new ApexPages.StandardController(fiContract);
            EUR_CRM_FI_ProfitCalculatorExt profitCalc = new EUR_CRM_FI_ProfitCalculatorExt(sc);

        }
    }
    @IsTest
    private static void test2(){
        setUser();
        System.runAs(eurSysUser){
            dataInsert1();
            delete productItems;

            ApexPages.StandardController sc = new ApexPages.StandardController(fiContract);
            EUR_CRM_FI_ProfitCalculatorExt profitCalc = new EUR_CRM_FI_ProfitCalculatorExt(sc);

        }
    }
}