@isTest
public with sharing class EUR_CRM_TestContractProductItemTriggers {

    private static EUR_CRM_Account__c accountEU;
    private static EUR_CRM_Contract__c contract;
    private static EUR_CRM_Wine_Spirits__c wineSpirits;
    private static EUR_CRM_Category__c category;
    private static EUR_CRM_Brand__c brand;
    private static EUR_CRM_Mechanic_Type__c mechType;
    private static EUR_CRM_Contract_Activity_Item__c contractActivity;  
    private static EUR_CRM_Contract_Product_Item__c productItem;
    private static User regionalUser;

    static TestMethod void testTriggers(){

        EUR_CRM_DE_TestClassUtilityHelper.initUsers();
        regionalUser = EUR_CRM_DE_TestClassUtilityHelper.regionalUser;

        System.runAs(regionalUser){
            Test.startTest();
                //Create account
                EUR_CRM_DE_TestClassUtilityHelper.initData();
                accountEU = EUR_CRM_DE_TestClassUtilityHelper.euAccount;

                //Create Wine Spirit
                wineSpirits = EUR_CRM_TestClassUtilityHelper.createWineSpirits(1, EUR_CRM_DE_TestClassUtilityHelper.DE_WINE_SPIRIT_RECORD_TYPE, 'TEST-0001', 'SPIRITS')[0];
                insert wineSpirits;

                //Create category
                category = EUR_CRM_TestClassUtilityHelper.createCategory(1, EUR_CRM_DE_TestClassUtilityHelper.DE_CATEGORY_RECORD_TYPE, 'TEST-0001', wineSpirits.Id)[0];
                insert category;
                
                //Create Brand
                brand = EUR_CRM_TestClassUtilityHelper.createBrand(1, EUR_CRM_DE_TestClassUtilityHelper.DE_BRAND_RECORD_TYPE, 'VODKA', 'TEST-0001', category.Id)[0];
                insert brand;

                //Create Mechanic Type
                mechType = EUR_CRM_TestClassUtilityHelper.createMechType(1, EUR_CRM_DE_TestClassUtilityHelper.DE_MECHANIC_TYPE_RECORD_TYPE, 'Pouring Refund')[0];
                mechType.EUR_CRM_Grouping_Name__c = 'Germany';
                mechType.EUR_CRM_Has_Lump_Sum__c = false;
                mechType.EUR_CRM_Has_Per_BQ__c = true;
                mechType.EUR_CRM_Lump_Sum_Or_Per_BQ__c  = false;
                mechType.EUR_CRM_Is_Pro_Rated_by_Month__c = true;
                mechType.EUR_CRM_Has_Multiple_Activity_Item__c = false;
                insert mechType;
            Test.stopTest();

            //Create Contract
            contract = EUR_CRM_TestClassUtilityHelper.createContracts(1, EUR_CRM_DE_TestClassUtilityHelper.DE_CONTRACT_RECORD_TYPE, accountEU.Id, date.today(), date.today().addYears(3))[0];
            insert contract;
            
            //Create Contract Activity1
            contractActivity = EUR_CRM_DE_TestClassUtilityHelper.createContractActivityItem(null, contract.Id, mechType.Id);
            insert contractActivity;

            //Create Contract Product Item
            productItem = EUR_CRM_DE_TestClassUtilityHelper.createContractProductItem(null, contractActivity.Id, brand);
            insert productItem;
            update productItem;
        }
    }
}