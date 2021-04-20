@isTest
public class EUR_CRM_ZA_TestUtilClass {

    static testMethod void testRetrieveOwners(){
        insert EUR_CRM_ZA_TestClassHelper.createEUAccount(1,'Test EU ACCOUNT', 'EUR_ZA_On_Trade_Direct').get(0);
        Test.startTest();
            List<EUR_CRM_Account__c> accList = [SELECT Id, EUR_CRM_Country_Code__c, OwnerId FROM EUR_CRM_Account__c WHERE EUR_CRM_Country_Code__c = 'ZA' LIMIT 1];
            EUR_CRM_ZA_UtilClass.retrieveOwners(accList);
        Test.stopTest();
    }

    static testMethod void testRetrieveOPAccounts(){
        EUR_CRM_Account__c euaccount = EUR_CRM_ZA_TestClassHelper.createEUAccount(1,'Test EU ACCOUNT', 'EUR_ZA_On_Trade_Direct').get(0);
        insert euaccount;
        
        //Create test data for Action List Template        
        EUR_CRM_OP_Action_List_Template__c objActionTemplate = new EUR_CRM_OP_Action_List_Template__c(); 
        objActionTemplate.EUR_CRM_External_ID__c = 'ZA_OFF_ALT_Promo';
        objActionTemplate.recordTypeId = Global_RecordTypeCache.getRtId('EUR_CRM_OP_Action_List_Template__cEUR_ZA_OP_Action_List_Template');
        insert objActionTemplate;
        
        //Create test data for Object Promo
        List<EUR_CRM_ObjPromo__c> objPromoList = EUR_CRM_ZA_TestClassHelper.createObjAndProms(1, 'EUR_ZA_Off_Trade_Promotion');
        EUR_CRM_ObjPromo__c objPromo = objPromoList[0];
        objPromo.EUR_CRM_Status__c = 'test';
        objPromo.EUR_CRM_OP_Action_List_Template__c = objActionTemplate.Id;
        objPromo.EUR_CRM_Active_Start_Date__c = Date.today() - 7;
        objPromo.EUR_CRM_Active_End_Date__c = Date.today();
        objPromo.EUR_CRM_Evaluation_Period_End_Date__c = Date.today() + 1;
        insert objPromo;

        Test.startTest();
            EUR_CRM_ObjPromo__c zaObjPromo = [SELECT Id FROM EUR_CRM_ObjPromo__c LIMIT 1];
            EUR_CRM_ZA_UtilClass.retrieveOPAccounts(zaObjPromo, null, 'Name', 'ASC');
        Test.stopTest();
    }

    static testMethod void testRetrieveContractProductLineItems(){
        EUR_CRM_Account__c euaccount = EUR_CRM_ZA_TestClassHelper.createEUAccount(1,'Test EU ACCOUNT', 'EUR_ZA_On_Trade_Direct').get(0);
        insert euaccount;

        Contact contact = EUR_CRM_ZA_TestClassHelper.createContact(1, 'TEST CONTACT', euaccount).get(0);
        insert contact;

        EUR_CRM_Contract__c zaContract = EUR_CRM_ZA_TestClassHelper.createZAContract(1,'test', euaccount, contact, 'EUR_ZA_Head_Office_Contract').get(0);
        insert zaContract;

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

        EUR_CRM_Quality__c brandQuality = EUR_CRM_TestClassUtilityHelper.createBrandQuality(1, 'EUR_ZA_Quality', 'Cocktail', 'TEST-0001', null)[0];
        brandQuality.EUR_CRM_Contributive_Margin_BQ__c = 0.6;
        insert brandQuality;
        system.assertNotEquals(brandQuality, null);

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItems = new List<EUR_CRM_Contract_Activity_Item__c>();
        for(EUR_CRM_Mechanic_Type__c mechType : mechTypeList){
            EUR_CRM_Contract_Activity_Item__c cActivity = new EUR_CRM_Contract_Activity_Item__c();
            cActivity = EUR_CRM_ZA_TestClassHelper.createContractActivityItem(1,zaContract, mechType).get(0);

            contractActivityItems.add(cActivity);
        }
        insert contractActivityItems;

        List<EUR_CRM_Contract_Product_Item__c> productItems = new List<EUR_CRM_Contract_Product_Item__c>();
        for(EUR_CRM_Contract_Activity_Item__c cActivity : contractActivityItems){
            EUR_CRM_Contract_Product_Item__c productItem = new EUR_CRM_Contract_Product_Item__c();
            productItem = EUR_CRM_ZA_TestClassHelper.createProductItem(1,cActivity).get(0);
            productItem.EUR_CRM_Brand_Quality__c = brandQuality.Id;
            
            productItems.add(productItem);
        }

        insert productItems;

        Test.startTest();
            EUR_CRM_Contract_Activity_Item__c zaContractItem = [SELECT Id,EUR_CRM_Contract__c, EUR_CRM_Contract__r.EUR_CRM_Country_Code__c 
                                                                  FROM EUR_CRM_Contract_Activity_Item__c 
                                                                  WHERE EUR_CRM_Contract__r.EUR_CRM_Country_Code__c = 'ZA' 
                                                                  LIMIT 1 ];
            EUR_CRM_ZA_UtilClass.retrieveContractProductLineItems(zaContractItem.EUR_CRM_Contract__c);
        Test.stopTest();
    }

    static testMethod void testRetrieveBrandQualityItems(){
        Test.startTest();
            EUR_CRM_ZA_UtilClass.retrieveBrandQualityItems();
        Test.stopTest();
    }

    static testMethod void testRetrieveBrandQualitySizeItems(){
        Test.startTest();
            EUR_CRM_ZA_UtilClass.retrieveBrandQualitySizeItems();
        Test.stopTest();
    }

}