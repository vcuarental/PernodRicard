@isTest
private class EUR_CRM_FI_TestContractBuilderController{

    private static Map<String, String> mtExtIdByEnglishName = new Map<String, String>{
        'Education' => 'EUR_FI_Education'
        ,'Free Stock' => 'EUR_FI_Free_Stock'
        ,'Marketing Activity Spirits' => 'EUR_FI_Mktg_Activity_Spirits'
        ,'Marketing Activity Wines' => 'EUR_FI_Mktg_Activity_Wines'
        ,'Pouring Refund Spirits' => 'EUR_FI_Pouring_Refund_Spirits'
        ,'Pouring Refund Wines' => 'EUR_FI_Pouring_Refund_Wines'
        ,'Selection Brands Spirits' => 'EUR_FI_Selection_Brands_Spirits'
        ,'Selection Brands Wines' => 'EUR_FI_Selection_Brands_Wines'
        ,'Trips' => 'EUR_FI_Trips'
    };

    private static Map<String, EUR_CRM_Mechanic_Type__c> mechanicTypeMap;
    private static EUR_CRM_Wine_Spirits__c wineSpirit;
    private static EUR_CRM_Category__c category;
    private static EUR_CRM_Brand__c brand;
    private static EUR_CRM_Quality__c bq;
    private static EUR_CRM_Size__c bqs;
    private static EUR_CRM_SKU__c sku;
    private static EUR_CRM_Account__c account;
    private static EUR_CRM_Contract__c contract;
    private static List<EUR_CRM_Contract_Activity_Item__c> CAIs;
    private static List<EUR_CRM_Contract_Product_Item__c> CPIs;

    /**
       EUR_CRM_FI_ContractBuilderController
    */
    private static testMethod  void testContractBuilder(){

            Test.startTest();
            account = makeAccount('EUR_FI_Direct_On_Trade');
            insert account;
            contract = makeContract('EUR_FI_Independent_Contract');
            insert contract;
            Test.stopTest();
            setMasterData();

            contract = selectContractWhereId(contract.Id);

            PageReference aPage = Page.EUR_CRM_FI_ContractBuilderPage;
            test.setCurrentPage(aPage);
            ApexPages.StandardController sc = new ApexPages.StandardController(contract);
            EUR_CRM_FI_ContractBuilderController.testContractSettings = makeContractSettings();
            EUR_CRM_FI_ContractBuilderController.testDisplaySettings = makeContractDisplaySettings();
            EUR_CRM_FI_ContractBuilderController con = new EUR_CRM_FI_ContractBuilderController(sc);
            
            EUR_CRM_FI_ContractBuilderController.MechanicTypeWrapper pouringRefundSpiritsMechType = con.mechanicTypeWrapperMap.get('Pouring Refund Spirits');
            
            aPage.getParameters().put('PARAM_MECHANIC_TYPE_NAME', 'Pouring Refund Spirits');
            aPage.getParameters().put('PARAM_PRODUCT_ID', bqs.id);
            aPage.getParameters().put('PARAM_ROW_NUMBER', '0');
            con.addContractLineItem();
            con.removeContractLineItem();
            con.getIsCurrentUserApprover();
            pouringRefundSpiritsMechType.getProductName();
            
            //PORUING REFUNDS
            List<EUR_CRM_Contract_Product_Item__c> productItems = pouringRefundSpiritsMechType.getContractProductItems();
            EUR_CRM_Contract_Product_Item__c prod= productItems.get(0);
            prod.EUR_CRM_Quantity__c = 10000; 
            prod.EUR_CRM_Amount__c = 0.1;
            prod.EUR_CRM_Volume_Btl__c = 100;

            //- TRIPS
            aPage.getParameters().put('PARAM_MECHANIC_TYPE_NAME', 'Trips');
            aPage.getParameters().put('PARAM_PRODUCT_ID', brand.id);
            aPage.getParameters().put('PARAM_ROW_NUMBER', '0');
            con.addContractLineItem();
               
            EUR_CRM_FI_ContractBuilderController.MechanicTypeWrapper tripsMechType = con.mechanicTypeWrapperMap.get('Trips');
            EUR_CRM_Contract_Product_Item__c tripProd= tripsMechType .getContractProductItems().get(0);
            tripProd.EUR_CRM_Marketing_Amount__c= 1000;
            tripProd.EUR_CRM_No_of_People__c= 1000;
            con.getContractMaterialColor();
            con.getProfitColor();
            con.save();
            system.assert(pouringRefundSpiritsMechType.getHasValue());
            system.assert(!pouringRefundSpiritsMechType.getHasLumpSumValue());
            system.assert(pouringRefundSpiritsMechType.getHasVolumeValue());

            //reload
            con = new EUR_CRM_FI_ContractBuilderController(sc);
            tripsMechType = con.mechanicTypeWrapperMap.get('Trips');
            pouringRefundSpiritsMechType = con.mechanicTypeWrapperMap.get('Pouring Refund Spirits');
    }

    private static void setMasterData(){
        wineSpirit = makeWineSpirit('EUR_FI_Wine_Spirits');
        wineSpirit.Name = 'Wine';
        insert wineSpirit;

        category = makeCategory(wineSpirit.Id, 'EUR_FI_Category');
        insert category;

        brand = makeBrand(category.Id, 'EUR_FI_Brand');
        insert brand;

        bq= makeBQ(brand.Id, 'EUR_FI_Quality');
        insert bq;

        bqs= makeBQS(bq.Id, 'EUR_FI_Size');
        insert bqs;

        sku= makeSKU(bqs.Id, 'EUR_FI_SKU');
        insert sku;

        mechanicTypeMap = new Map<String, EUR_CRM_Mechanic_Type__c>();
        for(String mtEnglishName : mtExtIdByEnglishName.keySet()){
            EUR_CRM_Mechanic_Type__c mt = makeMT('EUR_FI_Mechanic_Type');
            mt.Name = mtEnglishName;
            mt.EUR_CRM_Mechanic_Type_Name_English__c = mtEnglishName;
            mt.EUR_CRM_External_ID__c = mtExtIdByEnglishName.get(mtEnglishName);

            mechanicTypeMap.put(mtEnglishName, mt);
        }
        insert mechanicTypeMap.values();

        CAIs = new List<EUR_CRM_Contract_Activity_Item__c>();
        for (EUR_CRM_Mechanic_Type__c mt : mechanicTypeMap.values()) {
            EUR_CRM_Contract_Activity_Item__c cai = makeCAI('EUR_FI_Contract_Activity_Item');
            cai.EUR_CRM_Contract__c = contract.Id;
            cai.EUR_CRM_Mechanic_Type__c = mt.Id;
            CAIs.add(cai);
        }
        insert CAIs;

        CPIs = new List<EUR_CRM_Contract_Product_Item__c>();
        for (EUR_CRM_Contract_Activity_Item__c cai : CAIs) {
            EUR_CRM_Contract_Product_Item__c cpi = makeCPI('EUR_FI_Contract_Product_Item');
            cpi.EUR_CRM_Contract_Activity_Item__c = cai.Id;
            cpi.EUR_CRM_Brand__c = brand.Id;
            cpi.EUR_CRM_Brand_Quality__c = bq.Id;
            cpi.EUR_CRM_Brand_Quality_Size__c = bqs.Id;
            cpi.EUR_CRM_Volume_Btl__c = 10;
            cpi.EUR_CRM_Quantity__c = 5;
            CPIs.add(cpi);
        }
        insert CPIs;

        EUR_CRM_Apex_Configuration__c config1 = makeApexConfiguration();
        config1.EUR_CRM_Decimal_Value__c = 20;
        config1.EUR_CRM_Sequence__c = 1;

        EUR_CRM_Apex_Configuration__c config2 = makeApexConfiguration();
        config2.EUR_CRM_Decimal_Value__c = 20;
        config2.EUR_CRM_Sequence__c = 2;

        EUR_CRM_Apex_Configuration__c config3 = makeApexConfiguration();
        config3.EUR_CRM_Decimal_Value__c = 40;
        config3.EUR_CRM_Sequence__c = 3;

        EUR_CRM_Apex_Configuration__c  config4 = makeApexConfiguration();
        config4.EUR_CRM_Decimal_Value__c = 1000;
        config4.EUR_CRM_Sequence__c = 1;

        EUR_CRM_Apex_Configuration__c  config5 = makeApexConfiguration();
        config5.EUR_CRM_Decimal_Value__c = 1000;
        config5.EUR_CRM_Sequence__c = 1;

        EUR_CRM_Apex_Configuration__c  config6 = makeApexConfiguration();
        config6.EUR_CRM_Decimal_Value__c = 2000;
        config6.EUR_CRM_Sequence__c = 1;

        insert new List<EUR_CRM_Apex_Configuration__c >{ config1, config2, config3, config4, config5, config6 };
    }

    private static EUR_CRM_Apex_Configuration__c makeApexConfiguration() {
        Id rtId = Schema.SObjectType.EUR_CRM_Apex_Configuration__c.getRecordTypeInfosByDeveloperName().get('EUR_CRM_General_Configuration').getRecordTypeId();
        return new EUR_CRM_Apex_Configuration__c(
            RecordTypeId = rtId
        ,   EUR_CRM_Country_Code__c = 'fi'
        ,   EUR_CRM_Module__c = 'EUR_CRM_FI_ContractBuilder'
        ,   EUR_CRM_Sub_Module__c = 'EUR_CRM_Profitability'
        ,   EUR_CRM_Text_Value__c = 'red'
        );
    }

    private static EUR_CRM_SKU__c makeSKU(Id bqsId, String rt) {
        Id rtId = Schema.SObjectType.EUR_CRM_SKU__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
        return new EUR_CRM_SKU__c(
            Name = 'test sku'
        ,   RecordTypeId = rtId
        ,   EUR_CRM_Active__c = true
        ,   EUR_CRM_Brand_Quality_Size__c = bqsId
        );
    }

    private static EUR_CRM_Size__c makeBQS(Id bqId, String rt) {
        Id rtId = Schema.SObjectType.EUR_CRM_Size__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
        return new EUR_CRM_Size__c(
            Name = 'test bqs'
        ,   RecordTypeId = rtId
        ,   EUR_CRM_Active__c = true
        ,   EUR_CRM_Is_Competitor__c = false
        ,   EUR_CRM_Brand_Quality__c = bqId
        );
    }

    private static EUR_CRM_Quality__c makeBQ(Id brandId, String rt) {
        Id rtId = Schema.SObjectType.EUR_CRM_Quality__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
        return new EUR_CRM_Quality__c(
            Name = 'test bq'
        ,   RecordTypeId = rtId
        ,   EUR_CRM_Active__c = true
        ,   EUR_CRM_Brand__c = brandId
        );
    }

    private static EUR_CRM_Brand__c makeBrand(Id categoryId, String rt) {
        Id rtId = Schema.SObjectType.EUR_CRM_Brand__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
        return new EUR_CRM_Brand__c(
            Name = 'test brand'
        ,   RecordTypeId = rtId
        ,   EUR_CRM_Active__c = true
        ,   EUR_CRM_Is_Competitor__c = false
        ,   EUR_CRM_Category__c = categoryId
        );
    }

    private static EUR_CRM_Category__c makeCategory(Id wineSpiritId, String rt) {
        Id rtId = Schema.SObjectType.EUR_CRM_Category__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
        return new EUR_CRM_Category__c(
            Name = 'test category'
        ,   RecordTypeId = rtId
        ,   EUR_CRM_Wine_Spirits__c = wineSpiritId);
    }

    private static EUR_CRM_Account__c makeAccount(String rt) {
        Id rtId = Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
        return new EUR_CRM_Account__c(
            Name = 'Test Account'
            ,   EUR_CRM_Postal_Code__c = '112233'
            ,   RecordTypeId = rtId
        );
    }

    private static EUR_CRM_Contract__c makeContract(String rt) {
        Id rtId = Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
        return new EUR_CRM_Contract__c(
            RecordTypeId = rtId
        ,   EUR_CRM_Account__c = account.id
        ,   EUR_CRM_Start_Date__c = System.today()
        ,   EUR_CRM_End_Date__c = System.today()
        ,   EUR_CRM_Status__c = 'Draft'
        ,   EUR_CRM_Is_this_contract_material__c = 60000
        ,   EUR_CRM_Is_this_contract_profitable__c = 60
        );
    }

    private static EUR_CRM_Contract_Activity_Item__c makeCAI(String rt) {
        Id rtId = Schema.SObjectType.EUR_CRM_Contract_Activity_Item__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
        return new EUR_CRM_Contract_Activity_Item__c(
            RecordTypeId = rtId
        );
    }

    private static EUR_CRM_Contract_Product_Item__c makeCPI(String rt) {
        Id rtId = Schema.SObjectType.EUR_CRM_Contract_Product_Item__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
        return new EUR_CRM_Contract_Product_Item__c(
            RecordTypeId = rtId
        );
    }

    private static EUR_CRM_Mechanic_Type__c makeMT(String rt) {
        Id rtId = Schema.SObjectType.EUR_CRM_Mechanic_Type__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
        return new EUR_CRM_Mechanic_Type__c(
            RecordTypeId = rtId
        );
    }

    private static EUR_CRM_Wine_Spirits__c makeWineSpirit(String rt) {
        Id rtId = Schema.SObjectType.EUR_CRM_Wine_Spirits__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
        return new EUR_CRM_Wine_Spirits__c(
            Name = 'Wine'
        ,   RecordTypeId = rtId
        );
    }

    private static List<EUR_CRM_CTM_Contract_setting__mdt> makeContractSettings() {
        List<EUR_CRM_CTM_Contract_setting__mdt> contractSettings = new List<EUR_CRM_CTM_Contract_setting__mdt>();
        contractSettings.add(makeContractSetting('EUR_FI_Selection_Brands_Wines', 'EUR_CRM_Brand__c'));
        contractSettings.add(makeContractSetting('EUR_FI_Pouring_Refund_Spirits', 'EUR_CRM_Size__c'));
        contractSettings.add(makeContractSetting('EUR_FI_Education', 'EUR_CRM_Brand__c'));
        contractSettings.add(makeContractSetting('EUR_FI_Free_Stock', 'EUR_CRM_Quality__c'));
        contractSettings.add(makeContractSetting('EUR_FI_Mktg_Activity_Spirits', 'EUR_CRM_Brand__c'));
        contractSettings.add(makeContractSetting('EUR_FI_Mktg_Activity_Wines', 'EUR_CRM_Brand__c'));
        contractSettings.add(makeContractSetting('EUR_FI_Pouring_Refund_Wines', 'EUR_CRM_SKU__c'));
        contractSettings.add(makeContractSetting('EUR_FI_Selection_Brands_Spirits', 'EUR_CRM_Size__c'));
        contractSettings.add(makeContractSetting('EUR_FI_Trips', 'EUR_CRM_Brand__c'));
        return contractSettings;

    }

    private static List<EUR_CRM_CTM_Contract_Display_Setting__mdt> makeContractDisplaySettings() {
        List<EUR_CRM_CTM_Contract_Display_Setting__mdt> displaySettings = new List<EUR_CRM_CTM_Contract_Display_Setting__mdt>();
        displaySettings.add(makeDisplaySetting('EUR_FI_Mktg_Activity_Spirits', 'Spirits'));
        displaySettings.add(makeDisplaySetting('EUR_FI_Pouring_Refund_Wines', 'Wine'));
        displaySettings.add(makeDisplaySetting('EUR_FI_Mktg_Activity_Wines', 'Wine'));
        displaySettings.add(makeDisplaySetting('EUR_FI_Pouring_Refund_Spirits,EUR_FI_Selection_Brands_Spirits', 'Spirits'));
        displaySettings.add(makeDisplaySetting('EUR_FI_Selection_Brands_Wines', 'Wine'));
        return displaySettings;
    }

    private static EUR_CRM_CTM_Contract_setting__mdt makeContractSetting(String mtExtId, String productLevel) {
        return new EUR_CRM_CTM_Contract_setting__mdt(
            EUR_CRM_Mechanic_ExtID__c = mtExtId
        ,   EUR_CRM_Product_level__c = productLevel
        );
    }

    private static EUR_CRM_CTM_Contract_Display_Setting__mdt makeDisplaySetting(String mtExtId, String wineSpirits) {
        return new EUR_CRM_CTM_Contract_Display_Setting__mdt(
            EUR_CRM_Mechanic_type_ext_IDs__c = mtExtId
        ,   EUR_CRM_Wine_Spirits__c = wineSpirits
        );
    }

    private static EUR_CRM_Contract__c selectContractWhereId(Id contractId) {
        return [
            select id, EUR_CRM_Include_VAT__c,EUR_CRM_Contact__c,EUR_CRM_Account__c,EUR_CRM_Account__r.ownerid,EUR_CRM_Is_this_contract_material__c,EUR_CRM_Is_this_contract_profitable__c,RecordType.developername,EUR_CRM_Country_Code__c
            from EUR_CRM_Contract__c
            where id = :contractId
        ];
    }

}