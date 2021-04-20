@IsTest (IsParallel = true)
private class EUR_CRM_ObjectivePromoHandlerTest {


    /* ======================================================================================= */
    /*     Create ObjPromo object with/without Action List Template test: single record
    /* ======================================================================================= */
    @IsTest
    private static void createObjPromoWithoutActionListTemplatePositiveTest() {
        EUR_CRM_ObjPromo__c objPromo = makeObjPromo('EUR_RU_Off_Trade_Discount_Campaign');

        Boolean hasAppropriateErrorMessage = false;
        try {
            insert objPromo;
        } catch (Exception e) {
            System.debug('\n\n e.getMessage() => ' + JSON.serializePretty(e.getMessage()) + '\n');
            hasAppropriateErrorMessage = e.getMessage().contains('No Action List Template found for this type of Objective / Promotion');
        }

        System.assertEquals(true, hasAppropriateErrorMessage);
    }

    @IsTest
    private static void createObjPromoWithAppropriate_RU_ActionListTemplatePositiveTest() {
        EUR_CRM_OP_Action_List_Template__c listTemplate = makeActionListTemplate('EUR_RU_OP_Action_List_Template', 'RU_OFF_Discount_Campaign');
        insert listTemplate;

        EUR_CRM_ObjPromo__c objPromo = makeObjPromo('EUR_RU_Off_Trade_Discount_Campaign');
        insert objPromo;

        objPromo = selectObjPromoWhereId(objPromo.Id);
        System.assertEquals(listTemplate.Id, objPromo.EUR_CRM_OP_Action_List_Template__c);
        System.assertEquals('Draft', objPromo.EUR_CRM_Status__c);
    }

    @IsTest
    private static void createObjPromoWithAppropriate_DK_ActionListTemplatePositiveTest() {
        EUR_CRM_OP_Action_List_Template__c listTemplate = makeActionListTemplate('EUR_DK_OP_Action_List_Template', 'DK_OFF_LeafletCampaign');
        insert listTemplate;

        EUR_CRM_ObjPromo__c objPromo = makeObjPromo('EUR_DK_Off_Trade_Leaflet_Campaign');
        insert objPromo;

        objPromo = selectObjPromoWhereId(objPromo.Id);
        System.assertEquals(listTemplate.Id, objPromo.EUR_CRM_OP_Action_List_Template__c);
        System.assertEquals('Draft', objPromo.EUR_CRM_Status__c);
    }

    @IsTest
    private static void createObjPromoWithAppropriate_DK_PricePromotionRecordType_ActionListTemplatePositiveTest() {
        EUR_CRM_OP_Action_List_Template__c listTemplate = makeActionListTemplate('EUR_DK_OP_Action_List_Template', 'DK_OFF_EffectsManager_Price_Promotion');
        insert listTemplate;

        EUR_CRM_ObjPromo__c objPromo = makeObjPromo('EUR_DK_Off_Trade_EM_Price_Promotion');
        insert objPromo;

        objPromo = selectObjPromoWhereId(objPromo.Id);
        System.assertEquals(listTemplate.Id, objPromo.EUR_CRM_OP_Action_List_Template__c);
        System.assertEquals('Active', objPromo.EUR_CRM_Status__c);
    }

    @IsTest
    private static void createObjPromoWithAppropriate_BE_ActionListTemplatePositiveTest() {
        EUR_CRM_OP_Action_List_Template__c listTemplate = makeActionListTemplate('EUR_BE_O_P_Action_List_Template', 'BE_Off_Trade_Sales_Drive');
        insert listTemplate;

        EUR_CRM_ObjPromo__c objPromo = makeObjPromo('EUR_BE_Off_Trade_Sales_Drive');
        insert objPromo;

        objPromo = selectObjPromoWhereId(objPromo.Id);
        System.assertEquals(listTemplate.Id, objPromo.EUR_CRM_OP_Action_List_Template__c);
        System.assertEquals('Draft', objPromo.EUR_CRM_Status__c);
    }

    @IsTest
    private static void createObjPromoWithAppropriate_PT_ActionListTemplatePositiveTest() {
        EUR_CRM_OP_Action_List_Template__c listTemplate = makeActionListTemplate('EUR_PT_OP_Action_List_Template', 'PT_Check_Off_Trade_Display');
        insert listTemplate;

        EUR_CRM_ObjPromo__c objPromo = makeObjPromo('EUR_PT_Off_Trade_OP_No_of_Display');
        insert objPromo;

        objPromo = selectObjPromoWhereId(objPromo.Id);
        System.assertEquals(listTemplate.Id, objPromo.EUR_CRM_OP_Action_List_Template__c);
        System.assertEquals('Active', objPromo.EUR_CRM_Status__c);
    }

    @IsTest
    private static void createObjPromoWithAppropriate_DE_ActionListTemplatePositiveTest() {
        EUR_CRM_OP_Action_List_Template__c listTemplate = makeActionListTemplate('EUR_DE_OP_Action_List_Template', 'DE_OFF_ALT_Dist_Drive');
        insert listTemplate;

        EUR_CRM_ObjPromo__c objPromo = makeObjPromo('EUR_DE_Off_Trade_Distribution_Drive');
        insert objPromo;

        objPromo = selectObjPromoWhereId(objPromo.Id);
        System.assertEquals(listTemplate.Id, objPromo.EUR_CRM_OP_Action_List_Template__c);
        System.assertEquals('Draft', objPromo.EUR_CRM_Status__c);
    }

    @IsTest
    private static void createObjPromoWithAppropriate_FI_Type1_ActionListTemplatePositiveTest() {
        EUR_CRM_OP_Action_List_Template__c listTemplate = makeActionListTemplate('EUR_FI_O_P_Action_List_Template', 'FI_Type_01');
        insert listTemplate;

        EUR_CRM_ObjPromo__c objPromo = makeObjPromo('EUR_FI_Off_Trade_O_P');
        objPromo.EUR_CRM_O_P_Type__c = 'Type 1';
        insert objPromo;

        objPromo = selectObjPromoWhereId(objPromo.Id);
        System.assertEquals(listTemplate.Id, objPromo.EUR_CRM_OP_Action_List_Template__c);
        System.assertEquals('Active', objPromo.EUR_CRM_Status__c);
    }

    @IsTest
    private static void createObjPromoWithAppropriate_FI_Type2_ActionListTemplatePositiveTest() {
        EUR_CRM_OP_Action_List_Template__c listTemplate = makeActionListTemplate('EUR_FI_O_P_Action_List_Template', 'FI_Type_02');
        insert listTemplate;

        EUR_CRM_ObjPromo__c objPromo = makeObjPromo('EUR_FI_On_Trade_O_P');
        objPromo.EUR_CRM_O_P_Type__c = 'Type 2';
        insert objPromo;

        objPromo = selectObjPromoWhereId(objPromo.Id);
        System.assertEquals(listTemplate.Id, objPromo.EUR_CRM_OP_Action_List_Template__c);
        System.assertEquals('Active', objPromo.EUR_CRM_Status__c);
    }

    @IsTest
    private static void createObjPromoWithAppropriate_FI_Type3_ActionListTemplatePositiveTest() {
        EUR_CRM_OP_Action_List_Template__c listTemplate = makeActionListTemplate('EUR_FI_O_P_Action_List_Template', 'FI_Type_02');
        insert listTemplate;

        EUR_CRM_ObjPromo__c objPromo = makeObjPromo('EUR_FI_On_Trade_O_P');
        objPromo.EUR_CRM_O_P_Type__c = 'Type 3';
        insert objPromo;

        objPromo = selectObjPromoWhereId(objPromo.Id);
        System.assertEquals(null, objPromo.EUR_CRM_OP_Action_List_Template__c);
        System.assertEquals('Active', objPromo.EUR_CRM_Status__c);
    }

    @IsTest
    private static void createObjPromoWithAppropriate_FI_WithoutType_ActionListTemplatePositiveTest() {
        EUR_CRM_OP_Action_List_Template__c listTemplate = makeActionListTemplate('EUR_FI_O_P_Action_List_Template', 'FI_Type_02');
        insert listTemplate;

        EUR_CRM_ObjPromo__c objPromo = makeObjPromo('EUR_FI_On_Trade_O_P');
        insert objPromo;

        objPromo = selectObjPromoWhereId(objPromo.Id);
        System.assertEquals(null, objPromo.EUR_CRM_OP_Action_List_Template__c);
        System.assertEquals('Active', objPromo.EUR_CRM_Status__c);
    }

    @IsTest
    private static void createObjPromoWithAppropriate_ZA_ActionListTemplatePositiveTest() {
        EUR_CRM_OP_Action_List_Template__c listTemplate = makeActionListTemplate('EUR_ZA_OP_Action_List_Template', 'ZA_OFF_ALT_Promo');
        insert listTemplate;

        EUR_CRM_ObjPromo__c objPromo = makeObjPromo('EUR_ZA_Off_Trade_Promotion');
        insert objPromo;

        objPromo = selectObjPromoWhereId(objPromo.Id);
        System.assertEquals(listTemplate.Id, objPromo.EUR_CRM_OP_Action_List_Template__c);
        System.assertEquals('Draft', objPromo.EUR_CRM_Status__c);
    }


    /* ======================================================================================= */
    /*     Create ObjPromo object with/without Action List Template test: multiple records
    /* ======================================================================================= */
    @IsTest
    private static void createObjPromosMultipleWithoutActionListTemplatePositiveTest() {
        Set<String> promoRecordTypes = new Set<String> {
            'EUR_RU_Off_Trade_Discount_Campaign'
            ,   'EUR_DK_Off_Trade_Leaflet_Campaign'
            ,   'EUR_DK_Off_Trade_EM_Price_Promotion'
            ,   'EUR_BE_Off_Trade_Sales_Drive'
            ,   'EUR_PT_Off_Trade_OP_No_of_Display'
            ,   'EUR_DE_Off_Trade_Distribution_Drive'
            ,   'EUR_ZA_Off_Trade_Promotion'
        };
        List<EUR_CRM_ObjPromo__c> objPromos = makeObjPromos(promoRecordTypes);

        Boolean hasAppropriateErrorMessage = false;
        List<Database.SaveResult> saveResults = Database.insert(objPromos, false);
        System.debug('\n\n saveResults => ' + JSON.serializePretty(saveResults) + '\n');

        for (Database.SaveResult saveResult : saveResults) {
            System.debug('\n\n saveResult => ' + JSON.serializePretty(saveResult) + '\n');

            if ( ! saveResult.isSuccess()) {
                for(Database.Error error : saveResult.getErrors()) {
                    System.debug('\n\n error.getMessage() => ' + JSON.serializePretty(error.getMessage()) + '\n');
                    hasAppropriateErrorMessage = error.getMessage().contains('No Action List Template found for this type of Objective / Promotion');
                    System.assertEquals(true, hasAppropriateErrorMessage);
                }
            } else {
                hasAppropriateErrorMessage = false;
                break;
            }
        }

        System.assertEquals(true, hasAppropriateErrorMessage);
    }

    @IsTest
    private static void createObjPromosMultipleWithAppropriate_RU_ActionListTemplatePositiveTest() {
        EUR_CRM_OP_Action_List_Template__c listTemplate = makeActionListTemplate('EUR_RU_OP_Action_List_Template', 'RU_OFF_Discount_Campaign');
        insert listTemplate;

        Set<String> promoRecordTypes = new Set<String> {
            'EUR_RU_Off_Trade_Discount_Campaign'
            ,   'EUR_RU_Off_Trade_Discount_Campaign'
            ,   'EUR_RU_Off_Trade_Discount_Campaign'
            ,   'EUR_RU_Off_Trade_Discount_Campaign'
            ,   'EUR_RU_Off_Trade_Discount_Campaign'
            ,   'EUR_RU_Off_Trade_Discount_Campaign'
            ,   'EUR_RU_Off_Trade_Discount_Campaign'
        };
        List<EUR_CRM_ObjPromo__c> objPromos = makeObjPromos(promoRecordTypes);
        insert objPromos;

        objPromos = selectAllObjPromos();
        for (EUR_CRM_ObjPromo__c objPromo : objPromos) {
            System.assertEquals(listTemplate.Id, objPromo.EUR_CRM_OP_Action_List_Template__c);
            System.assertEquals('Draft', objPromo.EUR_CRM_Status__c);
        }
    }

    @IsTest
    private static void createObjPromosMultipleWithAppropriate_DK_PricePromotionRecordType_ActionListTemplatePositiveTest() {
        EUR_CRM_OP_Action_List_Template__c listTemplate = makeActionListTemplate('EUR_DK_OP_Action_List_Template', 'DK_OFF_EffectsManager_Price_Promotion');
        insert listTemplate;

        Set<String> promoRecordTypes = new Set<String> {
            'EUR_DK_Off_Trade_EM_Price_Promotion'
            ,   'EUR_DK_Off_Trade_EM_Price_Promotion'
            ,   'EUR_DK_Off_Trade_EM_Price_Promotion'
            ,   'EUR_DK_Off_Trade_EM_Price_Promotion'
            ,   'EUR_DK_Off_Trade_EM_Price_Promotion'
            ,   'EUR_DK_Off_Trade_EM_Price_Promotion'
            ,   'EUR_DK_Off_Trade_EM_Price_Promotion'
        };
        List<EUR_CRM_ObjPromo__c> objPromos = makeObjPromos(promoRecordTypes);
        insert objPromos;

        objPromos = selectAllObjPromos();
        for (EUR_CRM_ObjPromo__c objPromo : objPromos) {
            System.assertEquals(listTemplate.Id, objPromo.EUR_CRM_OP_Action_List_Template__c);
            System.assertEquals('Active', objPromo.EUR_CRM_Status__c);
        }
    }

    @IsTest
    private static void createObjPromosMultipleWithAppropriateMultipleActionListTemplatesPositiveTest() {
        Map<String, String> templateExternalIdRecordTypeName = new Map<String, String> {
            'EUR_RU_OP_Action_List_Template' => 'RU_OFF_Discount_Campaign'
            ,   'EUR_DK_OP_Action_List_Template' => 'DK_OFF_LeafletCampaign'
            ,   'EUR_BE_O_P_Action_List_Template' => 'BE_Off_Trade_Sales_Drive'
            ,   'EUR_DE_OP_Action_List_Template' => 'DE_OFF_ALT_Dist_Drive'
            ,   'EUR_ZA_OP_Action_List_Template' => 'ZA_OFF_ALT_Promo'
        };

        List<EUR_CRM_OP_Action_List_Template__c> listTemplates = makeActionListTemplates(templateExternalIdRecordTypeName);
        insert listTemplates;

        Set<String> recordTypes = new Set<String> {
            'EUR_RU_Off_Trade_Discount_Campaign'
            ,   'EUR_DK_Off_Trade_Leaflet_Campaign'
            ,   'EUR_BE_Off_Trade_Sales_Drive'
            ,   'EUR_DE_Off_Trade_Distribution_Drive'
            ,   'EUR_ZA_Off_Trade_Promotion'
        };
        List<EUR_CRM_ObjPromo__c> objPromos = makeObjPromos(recordTypes);
        insert objPromos;

        objPromos = selectAllObjPromos();
        for (Integer i = 0; i < objPromos.size(); i++) {
            System.assertNotEquals(null, objPromos[i].EUR_CRM_OP_Action_List_Template__c);
            System.assertEquals('Draft', objPromos[i].EUR_CRM_Status__c);
        }
    }

    @IsTest
    private static void createObjPromosMultipleWithAppropriate_FI_MultipleActionListTemplatesPositiveTest() {
        Id rtId = selectRecordTypeIdWhereDeveloperName('EUR_FI_O_P_Action_List_Template');

        List<EUR_CRM_OP_Action_List_Template__c> listTemplates = new List<EUR_CRM_OP_Action_List_Template__c>();
        listTemplates.add(makeActionListTemplate(rtId, 'FI_Type_01'));
        listTemplates.add(makeActionListTemplate(rtId, 'FI_Type_02'));
        insert listTemplates;

        Set<String> recordTypes = new Set<String> {
            'EUR_FI_Off_Trade_O_P'
            ,   'EUR_FI_On_Trade_O_P'
        };
        List<EUR_CRM_ObjPromo__c> objPromos = makeObjPromos(recordTypes);
        objPromos[0].EUR_CRM_O_P_Type__c = 'Type 1';
        objPromos[1].EUR_CRM_O_P_Type__c = 'Type 2';
        insert objPromos;

        objPromos = selectAllObjPromos();
        for (Integer i = 0; i < objPromos.size(); i++) {
            System.assertNotEquals(null, objPromos[i].EUR_CRM_OP_Action_List_Template__c);
            System.assertEquals('Active', objPromos[i].EUR_CRM_Status__c);
        }
    }


    /* ======================================================================================= */
    /*     Set ObjPromo.PreparationsStartDate: single record
    /* ======================================================================================= */
    @IsTest
    private static void setupPreparationStartDatePositiveTest() {
        EUR_CRM_OP_Action_List_Template__c listTemplate = makeActionListTemplate('EUR_DE_OP_Action_List_Template', 'DE_OFF_ALT_Leaflet_Campaign');
        insert listTemplate;

        EUR_CRM_ObjPromo__c objPromo = makeObjPromo('EUR_DE_Off_Trade_Leaflet_Campaign');
        insert objPromo;

        EUR_CRM_Customer_Taxonomy__c customerTaxonomy = makeCustomerTaxonomy();
        insert customerTaxonomy;

        EUR_CRM_OP_Customer_Taxonomy_Mapping__c customerTaxonomyMapping = makeCustomerTaxonomyMapping(objPromo.Id, customerTaxonomy.Id);
        insert customerTaxonomyMapping;

        objPromo.EUR_CRM_Active_Start_Date__c = Date.today();
        update objPromo;

        objPromo = selectObjPromoWhereId(objPromo.Id);
        System.assertEquals(objPromo.EUR_CRM_Active_Start_Date__c.addDays(10 * (-7)), objPromo.EUR_CRM_Preparation_Start_Date__c);
    }

    @IsTest
    private static void setupPreparationStartDateDeleteCustomerTaxonomyMappingPositiveTest() {
        EUR_CRM_OP_Action_List_Template__c listTemplate = makeActionListTemplate('EUR_DE_OP_Action_List_Template', 'DE_OFF_ALT_Leaflet_Campaign');
        insert listTemplate;

        EUR_CRM_ObjPromo__c objPromo = makeObjPromo('EUR_DE_Off_Trade_Leaflet_Campaign');
        insert objPromo;

        EUR_CRM_Customer_Taxonomy__c customerTaxonomy = makeCustomerTaxonomy();
        insert customerTaxonomy;

        EUR_CRM_OP_Customer_Taxonomy_Mapping__c customerTaxonomyMapping = makeCustomerTaxonomyMapping(objPromo.Id, customerTaxonomy.Id);
        insert customerTaxonomyMapping;

        objPromo.EUR_CRM_Active_Start_Date__c = Date.today();
        update objPromo;

        objPromo = selectObjPromoWhereId(objPromo.Id);
        System.assertEquals(objPromo.EUR_CRM_Active_Start_Date__c.addDays(10 * (-7)), objPromo.EUR_CRM_Preparation_Start_Date__c);

        delete customerTaxonomyMapping;

        objPromo.Name = 'Promo Name updated';
        update objPromo;

        objPromo = selectObjPromoWhereId(objPromo.Id);
        System.assertEquals(null, objPromo.EUR_CRM_Preparation_Start_Date__c);
    }

    @IsTest
    private static void setupPreparationStartDateEmptyActivateStartDateNegativeTest() {
        EUR_CRM_OP_Action_List_Template__c listTemplate = makeActionListTemplate('EUR_DE_OP_Action_List_Template', 'DE_OFF_ALT_Leaflet_Campaign');
        insert listTemplate;

        EUR_CRM_ObjPromo__c objPromo = makeObjPromo('EUR_DE_Off_Trade_Leaflet_Campaign');
        objPromo.EUR_CRM_Active_Start_Date__c = null;
        objPromo.EUR_CRM_Active_End_Date__c = null;
        insert objPromo;

        EUR_CRM_Customer_Taxonomy__c customerTaxonomy = makeCustomerTaxonomy();
        insert customerTaxonomy;

        EUR_CRM_OP_Customer_Taxonomy_Mapping__c customerTaxonomyMapping = makeCustomerTaxonomyMapping(objPromo.Id, customerTaxonomy.Id);
        insert customerTaxonomyMapping;

        objPromo.Name = 'Promo Name Updated';
        update objPromo;

        objPromo = selectObjPromoWhereId(objPromo.Id);
        System.assertEquals(null, objPromo.EUR_CRM_Preparation_Start_Date__c);
    }

    @IsTest
    private static void setupPreparationStartDateOverrideCTaxPrepStartDateTrueNegativeTest() {
        EUR_CRM_OP_Action_List_Template__c listTemplate = makeActionListTemplate('EUR_DE_OP_Action_List_Template', 'DE_OFF_ALT_Leaflet_Campaign');
        insert listTemplate;

        EUR_CRM_ObjPromo__c objPromo = makeObjPromo('EUR_DE_Off_Trade_Leaflet_Campaign');
        insert objPromo;

        EUR_CRM_Customer_Taxonomy__c customerTaxonomy = makeCustomerTaxonomy();
        insert customerTaxonomy;

        EUR_CRM_OP_Customer_Taxonomy_Mapping__c customerTaxonomyMapping = makeCustomerTaxonomyMapping(objPromo.Id, customerTaxonomy.Id);
        insert customerTaxonomyMapping;

        objPromo.EUR_CRM_Override_CTax_PrepStartDate__c = true;
        objPromo.EUR_CRM_Active_Start_Date__c = Date.today();
        update objPromo;

        objPromo = selectObjPromoWhereId(objPromo.Id);
        System.assertEquals(null, objPromo.EUR_CRM_Preparation_Start_Date__c);
    }

    @IsTest
    private static void setupPreparationStartDateDifferentRecordTypeNegativeTest() {
        EUR_CRM_OP_Action_List_Template__c listTemplate = makeActionListTemplate('EUR_DE_OP_Action_List_Template', 'DE_OFF_ALT_Dist_Drive');
        insert listTemplate;

        EUR_CRM_ObjPromo__c objPromo = makeObjPromo('EUR_DE_Off_Trade_Distribution_Drive');
        insert objPromo;

        EUR_CRM_Customer_Taxonomy__c customerTaxonomy = makeCustomerTaxonomy();
        insert customerTaxonomy;

        EUR_CRM_OP_Customer_Taxonomy_Mapping__c customerTaxonomyMapping = makeCustomerTaxonomyMapping(objPromo.Id, customerTaxonomy.Id);
        insert customerTaxonomyMapping;

        objPromo.EUR_CRM_Active_Start_Date__c = Date.today();
        update objPromo;

        objPromo = selectObjPromoWhereId(objPromo.Id);
        System.assertEquals(null, objPromo.EUR_CRM_Preparation_Start_Date__c);
    }


    /* ======================================================================================= */
    /*     Set ObjPromo.PreparationsStartDate: multiple records
    /* ======================================================================================= */
    @IsTest
    private static void setupPreparationStartDateMultipleRecordsPositiveTest() {
        EUR_CRM_OP_Action_List_Template__c listTemplate = makeActionListTemplate('EUR_DE_OP_Action_List_Template', 'DE_OFF_ALT_Leaflet_Campaign');
        insert listTemplate;

        Id rtId = selectRecordTypeIdWhereDeveloperName('EUR_DE_Off_Trade_Leaflet_Campaign');
        List<EUR_CRM_ObjPromo__c> objPromos = new List<EUR_CRM_ObjPromo__c>();
        for (Integer i = 0; i < 10; i++) {
            objPromos.add(makeObjPromo(rtId));
        }
        insert objPromos;

        EUR_CRM_Customer_Taxonomy__c customerTaxonomy = makeCustomerTaxonomy();
        insert customerTaxonomy;

        List<EUR_CRM_OP_Customer_Taxonomy_Mapping__c> customerTaxonomyMappings = new List<EUR_CRM_OP_Customer_Taxonomy_Mapping__c>();
        for (EUR_CRM_ObjPromo__c objPromo : objPromos) {
            customerTaxonomyMappings.add(makeCustomerTaxonomyMapping(objPromo.Id, customerTaxonomy.Id));
        }
        insert customerTaxonomyMappings;

        for (EUR_CRM_ObjPromo__c objPromo : objPromos) {
            objPromo.EUR_CRM_Active_Start_Date__c = Date.today();
        }
        update objPromos;

        objPromos = selectAllObjPromos();
        for (EUR_CRM_ObjPromo__c objPromo : objPromos) {
            System.assertEquals(objPromo.EUR_CRM_Active_Start_Date__c.addDays(10 * (-7)), objPromo.EUR_CRM_Preparation_Start_Date__c);
        }
    }

    @IsTest
    private static void setupPreparationStartDateDeleteCustomerTaxonomyMappingMultipleRecordsPositiveTest() {
        EUR_CRM_OP_Action_List_Template__c listTemplate = makeActionListTemplate('EUR_DE_OP_Action_List_Template', 'DE_OFF_ALT_Leaflet_Campaign');
        insert listTemplate;

        Id rtId = selectRecordTypeIdWhereDeveloperName('EUR_DE_Off_Trade_Leaflet_Campaign');
        List<EUR_CRM_ObjPromo__c> objPromos = new List<EUR_CRM_ObjPromo__c>();
        for (Integer i = 0; i < 10; i++) {
            objPromos.add(makeObjPromo(rtId));
        }
        insert objPromos;

        EUR_CRM_Customer_Taxonomy__c customerTaxonomy = makeCustomerTaxonomy();
        insert customerTaxonomy;

        List<EUR_CRM_OP_Customer_Taxonomy_Mapping__c> customerTaxonomyMappings = new List<EUR_CRM_OP_Customer_Taxonomy_Mapping__c>();
        for (EUR_CRM_ObjPromo__c objPromo : objPromos) {
            customerTaxonomyMappings.add(makeCustomerTaxonomyMapping(objPromo.Id, customerTaxonomy.Id));
        }
        insert customerTaxonomyMappings;

        for (EUR_CRM_ObjPromo__c objPromo : objPromos) {
            objPromo.EUR_CRM_Active_Start_Date__c = Date.today();
        }
        update objPromos;

        objPromos = selectAllObjPromos();
        for (EUR_CRM_ObjPromo__c objPromo : objPromos) {
            System.assertEquals(objPromo.EUR_CRM_Active_Start_Date__c.addDays(10 * (-7)), objPromo.EUR_CRM_Preparation_Start_Date__c);
        }

        delete customerTaxonomyMappings;

        for (EUR_CRM_ObjPromo__c objPromo : objPromos) {
            objPromo.Name = 'Promo Name updated';
        }
        update objPromos;

        objPromos = selectAllObjPromos();
        for (EUR_CRM_ObjPromo__c objPromo : objPromos) {
            System.assertEquals(null, objPromo.EUR_CRM_Preparation_Start_Date__c);
        }
    }

    @IsTest
    private static void setupPreparationStartDateEmptyActivateStartDateMultipleNegativeTest() {
        EUR_CRM_OP_Action_List_Template__c listTemplate = makeActionListTemplate('EUR_DE_OP_Action_List_Template', 'DE_OFF_ALT_Leaflet_Campaign');
        insert listTemplate;

        Id rtId = selectRecordTypeIdWhereDeveloperName('EUR_DE_Off_Trade_Leaflet_Campaign');
        List<EUR_CRM_ObjPromo__c> objPromos = new List<EUR_CRM_ObjPromo__c>();
        for (Integer i = 0; i < 10; i++) {
            EUR_CRM_ObjPromo__c objPromo = makeObjPromo(rtId);
            objPromo.EUR_CRM_Active_Start_Date__c = null;
            objPromo.EUR_CRM_Active_End_Date__c = null;
            objPromos.add(objPromo);
        }
        insert objPromos;

        EUR_CRM_Customer_Taxonomy__c customerTaxonomy = makeCustomerTaxonomy();
        insert customerTaxonomy;

        List<EUR_CRM_OP_Customer_Taxonomy_Mapping__c> customerTaxonomyMappings = new List<EUR_CRM_OP_Customer_Taxonomy_Mapping__c>();
        for (EUR_CRM_ObjPromo__c objPromo : objPromos) {
            customerTaxonomyMappings.add(makeCustomerTaxonomyMapping(objPromo.Id, customerTaxonomy.Id));
        }
        insert customerTaxonomyMappings;

        for (EUR_CRM_ObjPromo__c objPromo : objPromos) {
            objPromo.Name = 'Promo Name updated';
        }
        update objPromos;

        objPromos = selectAllObjPromos();
        for (EUR_CRM_ObjPromo__c objPromo : objPromos) {
            System.assertEquals(null, objPromo.EUR_CRM_Preparation_Start_Date__c);
        }
    }

    @IsTest
    private static void setupPreparationStartDateOverrideCTaxPrepStartDateTrueMultipleNegativeTest() {
        EUR_CRM_OP_Action_List_Template__c listTemplate = makeActionListTemplate('EUR_DE_OP_Action_List_Template', 'DE_OFF_ALT_Leaflet_Campaign');
        insert listTemplate;

        Id rtId = selectRecordTypeIdWhereDeveloperName('EUR_DE_Off_Trade_Leaflet_Campaign');
        List<EUR_CRM_ObjPromo__c> objPromos = new List<EUR_CRM_ObjPromo__c>();
        for (Integer i = 0; i < 10; i++) {
            objPromos.add(makeObjPromo(rtId));
        }
        insert objPromos;

        EUR_CRM_Customer_Taxonomy__c customerTaxonomy = makeCustomerTaxonomy();
        insert customerTaxonomy;

        List<EUR_CRM_OP_Customer_Taxonomy_Mapping__c> customerTaxonomyMappings = new List<EUR_CRM_OP_Customer_Taxonomy_Mapping__c>();
        for (EUR_CRM_ObjPromo__c objPromo : objPromos) {
            customerTaxonomyMappings.add(makeCustomerTaxonomyMapping(objPromo.Id, customerTaxonomy.Id));
        }
        insert customerTaxonomyMappings;

        for (EUR_CRM_ObjPromo__c objPromo : objPromos) {
            objPromo.EUR_CRM_Override_CTax_PrepStartDate__c = true;
            objPromo.EUR_CRM_Active_Start_Date__c = Date.today();
        }
        update objPromos;

        objPromos = selectAllObjPromos();
        for (EUR_CRM_ObjPromo__c objPromo : objPromos) {
            System.assertEquals(null, objPromo.EUR_CRM_Preparation_Start_Date__c);
        }
    }

    @IsTest
    private static void setupPreparationStartDateDifferentRecordTypeMultipleNegativeTest() {
        EUR_CRM_OP_Action_List_Template__c listTemplate = makeActionListTemplate('EUR_DE_OP_Action_List_Template', 'DE_OFF_ALT_Dist_Drive');
        insert listTemplate;

        Id rtId = selectRecordTypeIdWhereDeveloperName('EUR_DE_Off_Trade_Distribution_Drive');
        List<EUR_CRM_ObjPromo__c> objPromos = new List<EUR_CRM_ObjPromo__c>();
        for (Integer i = 0; i < 10; i++) {
            objPromos.add(makeObjPromo(rtId));
        }
        insert objPromos;

        EUR_CRM_Customer_Taxonomy__c customerTaxonomy = makeCustomerTaxonomy();
        insert customerTaxonomy;

        List<EUR_CRM_OP_Customer_Taxonomy_Mapping__c> customerTaxonomyMappings = new List<EUR_CRM_OP_Customer_Taxonomy_Mapping__c>();
        for (EUR_CRM_ObjPromo__c objPromo : objPromos) {
            customerTaxonomyMappings.add(makeCustomerTaxonomyMapping(objPromo.Id, customerTaxonomy.Id));
        }
        insert customerTaxonomyMappings;

        for (EUR_CRM_ObjPromo__c objPromo : objPromos) {
            objPromo.EUR_CRM_Active_Start_Date__c = Date.today();
        }
        update objPromos;

        objPromos = selectAllObjPromos();
        for (EUR_CRM_ObjPromo__c objPromo : objPromos) {
            System.assertEquals(null, objPromo.EUR_CRM_Preparation_Start_Date__c);
        }
    }


    /* ========================================================= */
    /*     High Level Makers
    /* ========================================================= */
    private static List<EUR_CRM_OP_Action_List_Template__c> makeActionListTemplates(Map<String, String> templateExternalIdRecordTypeName) {
        List<RecordType> recordTypes = selectRecordTypesWhereDeveloperNames(templateExternalIdRecordTypeName.keySet());

        Map<String, Id> rtIdByDevName = new Map<String, Id>();
        for (RecordType rt : recordTypes) {
            rtIdByDevName.put(rt.DeveloperName, rt.Id);
        }

        List<EUR_CRM_OP_Action_List_Template__c> templates = new List<EUR_CRM_OP_Action_List_Template__c> ();
        for (String rtDevName : templateExternalIdRecordTypeName.keySet()) {
            String templateExternalId = templateExternalIdRecordTypeName.get(rtDevName);
            templates.add(makeActionListTemplate(rtIdByDevName.get(rtDevName), templateExternalId));
        }
        return templates;
    }

    private static List<EUR_CRM_ObjPromo__c> makeObjPromos(Set<String> rtDevNames) {
        List<RecordType> recordTypes = selectRecordTypesWhereDeveloperNames(rtDevNames);

        List<EUR_CRM_ObjPromo__c> objPromos = new List<EUR_CRM_ObjPromo__c> ();
        for (RecordType rt : recordTypes) {
            objPromos.add(makeObjPromo(rt.Id));
        }

        return objPromos;
    }


    /* ========================================================= */
    /*     Low Level Makers
    /* ========================================================= */
    private static EUR_CRM_OP_Action_List_Template__c makeActionListTemplate(String recordTypeDevName, String externalId) {
        EUR_CRM_OP_Action_List_Template__c actionListTemplate = makeActionListTemplateSkeleton(externalId);
        actionListTemplate.RecordTypeId = selectRecordTypeIdWhereDeveloperName(recordTypeDevName);
        return actionListTemplate;
    }

    private static EUR_CRM_OP_Action_List_Template__c makeActionListTemplate(Id rtId, String externalId) {
        EUR_CRM_OP_Action_List_Template__c actionListTemplate = makeActionListTemplateSkeleton(externalId);
        actionListTemplate.RecordTypeId = rtId;
        return actionListTemplate;
    }

    private static EUR_CRM_OP_Action_List_Template__c makeActionListTemplateSkeleton(String externalId) {
        return new EUR_CRM_OP_Action_List_Template__c(
            Name = 'Template Name'
        ,   EUR_CRM_External_ID__c = externalId
        );
    }

    private static EUR_CRM_ObjPromo__c makeObjPromo(String recordTypeDevName) {
        EUR_CRM_ObjPromo__c objPromo = makeObjPromoSkeleton();
        objPromo.RecordTypeId = selectRecordTypeIdWhereDeveloperName(recordTypeDevName);
        return objPromo;
    }

    private static EUR_CRM_ObjPromo__c makeObjPromo(Id rtId) {
        EUR_CRM_ObjPromo__c objPromo = makeObjPromoSkeleton();
        objPromo.RecordTypeId = rtId;
        return objPromo;
    }

    private static EUR_CRM_ObjPromo__c makeObjPromoSkeleton() {
        return new EUR_CRM_ObjPromo__c(
            Name = 'Promo Name'
        ,   EUR_CRM_MAF_ID__c = '12345'
        ,   EUR_CRM_Active_Start_Date__c = Date.today().addDays(1)
        ,   EUR_CRM_Active_End_Date__c = Date.today().addDays(7)
        ,   EUR_CRM_Status__c = 'Active'
        );
    }

    private static EUR_CRM_Customer_Taxonomy__c makeCustomerTaxonomy() {
        return new EUR_CRM_Customer_Taxonomy__c(
            EUR_CRM_Leaflet_Campaign_Lead_Time_Weeks__c = 10
        );
    }

    private static EUR_CRM_OP_Customer_Taxonomy_Mapping__c makeCustomerTaxonomyMapping(Id promoId, Id customerTaxonomyId) {
        return new EUR_CRM_OP_Customer_Taxonomy_Mapping__c(
            EUR_CRM_ObjPromo__c = promoId
        ,   EUR_CRM_Customer_Taxonomy__c = customerTaxonomyId
        );
    }


    /* ========================================================= */
    /*     SOQL Selectors
    /* ========================================================= */
    private static Id selectRecordTypeIdWhereDeveloperName(String devName) {
        return [
            SELECT Id
            FROM RecordType
            WHERE DeveloperName = :devName
            LIMIT 1
        ][0].Id;
    }

    private static List<RecordType> selectRecordTypesWhereDeveloperNames(Set<String> rtDevNames) {
        return [
            SELECT Id
            ,   DeveloperName
            FROM RecordType
            WHERE DeveloperName IN :rtDevNames
        ];
    }

    private static EUR_CRM_ObjPromo__c selectObjPromoWhereId(Id promoId) {
        return [
            SELECT Id
            ,   EUR_CRM_OP_Action_List_Template__c
            ,   EUR_CRM_Status__c
            ,   EUR_CRM_Active_Start_Date__c
            ,   EUR_CRM_Preparation_Start_Date__c
            FROM EUR_CRM_ObjPromo__c
            WHERE Id = :promoId
        ];
    }

    private static List<EUR_CRM_ObjPromo__c> selectAllObjPromos() {
        return [
            SELECT Id
            ,   EUR_CRM_OP_Action_List_Template__c
            ,   EUR_CRM_Status__c
            ,   EUR_CRM_Active_Start_Date__c
            ,   EUR_CRM_Preparation_Start_Date__c
            FROM EUR_CRM_ObjPromo__c
        ];
    }

}