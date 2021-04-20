@IsTest (IsParallel = true)
private class EUR_CRM_ContractPouringControllerTest {

    @TestSetup
    private static void setupMethod() {
        EUR_CRM_Mechanic_Type__c mechanicType = new EUR_CRM_Mechanic_Type__c(EUR_CRM_External_ID__c = 'EUR_DE_House_Pouring', Name = 'House Pouring');
        EUR_CRM_Mechanic_Type__c mechanicType2 = new EUR_CRM_Mechanic_Type__c(EUR_CRM_External_ID__c = 'EUR_DE_Listing', Name = 'Listing');
        insert new List <EUR_CRM_Mechanic_Type__c> {mechanicType, mechanicType2};
    }

//    @IsTest
//    private static void setupTest() {
//
//        Test.startTest();
//
//        Test.stopTest();
//
//    }


    @IsTest
    private static void firstTest() {
        EUR_CRM_Account__c account = new EUR_CRM_Account__c(Name = 'Test', EUR_CRM_Postal_Code__c = '112233');
        insert account;

        EUR_CRM_Contract__c contract = new EUR_CRM_Contract__c(EUR_CRM_Account__c = account.Id);
        insert contract;

        EUR_CRM_Category__c category = new EUR_CRM_Category__c(Name = 'Test Category');
        insert category;

        EUR_CRM_Brand__c brand = new EUR_CRM_Brand__c(Name = 'Test B', EUR_CRM_Category__c = category.Id);
        insert brand;

        EUR_CRM_Quality__c quality = new EUR_CRM_Quality__c(Name = 'Test BQ', EUR_CRM_Brand__c = brand.Id);
        insert quality;

        quality = [
            SELECT Id
            ,   Name
            ,   EUR_CRM_Brand__c
            ,   EUR_CRM_Brand__r.EUR_CRM_Category__c
            ,   EUR_CRM_Brand__r.EUR_CRM_Category__r.Name
            FROM EUR_CRM_Quality__c
            LIMIT 1
        ][0];

        Test.startTest();
        EUR_CRM_ContractPouringController controller = new EUR_CRM_ContractPouringController();
        controller.contractObj = contract;
        controller.brandQualityReferenceList = new List<EUR_CRM_Quality__c> { quality };
        controller.init();
        controller.validateListingPouringCategory();

        controller.pouringMap.get(category.Id).createdListingPouring.get(quality.Id).isChecked = true;
        controller.save();

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItems = [
            SELECT Id
            ,   (SELECT Id, EUR_CRM_Brand_Quality__c FROM Contract_Product_Items__r)
            FROM EUR_CRM_Contract_Activity_Item__c
        ];
        System.assertEquals(2, contractActivityItems.size());
        System.assertEquals(1, contractActivityItems[0].Contract_Product_Items__r.size());
        System.assertEquals(quality.Id, contractActivityItems[0].Contract_Product_Items__r[0].EUR_CRM_Brand_Quality__c);

        controller.pouringMap.get(category.Id).createdListingPouring.get(quality.Id).isChecked = false;
        controller.save();

        contractActivityItems = [
            SELECT Id
            ,   (SELECT Id, EUR_CRM_Brand_Quality__c FROM Contract_Product_Items__r)
            FROM EUR_CRM_Contract_Activity_Item__c
        ];
        System.assertEquals(1, contractActivityItems.size());
        Test.stopTest();
    }


    /* ========================================================= */
    /*     Helpers
    /* ========================================================= */


    /* ========================================================= */
    /*     High Level Makers
    /* ========================================================= */


    /* ========================================================= */
    /*     Low Level Makers
    /* ========================================================= */


    /* ========================================================= */
    /*     SOQL Wrappers
    /* ========================================================= */

}