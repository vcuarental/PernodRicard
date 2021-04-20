public with sharing class EUR_CRM_ObjectivePromoHandler extends EUR_CRM_TriggerAbstract {

    public EUR_CRM_ObjectivePromoHandler() {
        super('EUR_CRM_ObjectivePromoHandler');
    }


    /* ========================================================= */
    /*     Interface Methods
    /* ========================================================= */
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap){
        if (tAction == EUR_CRM_TriggerAbstract.TriggerAction.BEFORE_INSERT) {
            this.handleLogicOnBeforeInsert((List<EUR_CRM_ObjPromo__c>)sObjList);
        } else if (tAction == EUR_CRM_TriggerAbstract.TriggerAction.BEFORE_UPDATE) {
            this.handleLogicOnBeforeUpdate((List<EUR_CRM_ObjPromo__c>)sObjList, (Map<ID, EUR_CRM_ObjPromo__c>)oldMap);
        }
    }


    /* ========================================================= */
    /*     Business Logic
    /* ========================================================= */
    private final String ADDITIONAL_LOGIC = 'ADDITIONAL_LOGIC';

    private Map<String, String> templateExternalIdByPromoRecordTypeName = new Map<String, String> {
        'EUR_RU_Off_Trade_Discount_Campaign' => 'RU_OFF_Discount_Campaign'
    ,   'EUR_RU_Off_Trade_InStore_Media_POSM_Control' => 'RU_OFF_Instore_Media_POSM_Control'
    ,   'EUR_RU_Off_Trade_Leaflet_Campaign' => 'RU_OFF_Leaflet_Campaign'
    ,   'EUR_RU_Off_Trade_Loyalty_POSM_Placement' => 'RU_OFF_Loyalty_POSM_Placement'
    ,   'EUR_RU_Off_Trade_Model_Store' => 'RU_OFF_Model_Store'
    ,   'EUR_RU_Off_Trade_On_Site_Promo_Activities' => 'RU_OFF_On_Site_Promo_Activities'
    ,   'EUR_RU_Off_Trade_Outlet_Staff_Incentive' => 'RU_OFF_Outlet_Staff_Incentive'
    ,   'EUR_RU_Off_Trade_POSM_Placement' => 'RU_OFF_POSM_Placement'
    ,   'EUR_RU_Off_Trade_Sales_Rep_Competition' => 'RU_OFF_Sales_Rep_Competition'
    ,   'EUR_RU_Off_Trade_Stop_Rayon' => 'RU_OFF_Stop_Rayon'
    ,   'EUR_RU_ON_Trade_Phase_1' => 'RU_ON_Promo_Phase_1'
    ,   'EUR_RU_ON_Trade_Phase_2' => 'RU_ON_Promo_Phase_2'

    ,   'EUR_DK_Off_Trade_Leaflet_Campaign' => 'DK_OFF_LeafletCampaign'
    ,   'EUR_DK_Off_Trade_Sales_Drive_SKU_Displays' => 'DK_OFF_SalesDrive_SKU_Displays'
    ,   'EUR_DK_Off_2nd_Placement_Sell_In_Qty_Promo_Display' => 'DK_OFF_2ndPlacement_PromoDisplay'
    ,   'EUR_DK_Off_Trade_Distribution_Drive' => 'DK_OFF_DistributionDrive'
    ,   'EUR_DK_OFF_Trade_Sales_Drive_SKU_Cartons' => 'DK_OFF_SalesDrive_SKU_Cartons'
    ,   'EUR_DK_Off_Trade_Secondary_Placement_Standard' => 'DK_OFF_2ndPlacement_Standard'
    ,   'EUR_DK_Off_Trade_Secondary_Placement_Carton' => 'DK_OFF_2ndPlacement_Carton'
    ,   'EUR_DK_Off_Trade_Secondary_Placement_Gondola_End' => 'DK_OFF_2ndPlacement_Gondola'
    ,   'EUR_DK_Off_Trade_Secondary_Placement_Theme' => 'DK_OFF_2ndPlacement_Theme'
    ,   'EUR_DK_Off_Trade_Tasting_Campaign' => 'DK_OFF_Tasting_Campaign'
    ,   'EUR_DK_Off_Trade_EM_Price_Promotion' => 'DK_OFF_EffectsManager_Price_Promotion'
    ,   'EUR_DK_Off_Trade_Sales_Drive_SKU_Bottles' => 'DK_OFF_SalesDrive_SKU_Bottles'

    ,   'EUR_BE_Off_Trade_Sales_Drive' => 'BE_Off_Trade_Sales_Drive'
    ,   'EUR_BE_Off_Trade_Secondary_placement_Spyder_display' => 'BE_Off_Trade_Secondary_placement_Spyder_display'
    ,   'EUR_BE_On_Trade_Promo_Kit_Activation' => 'BE_On_Trade_Promo_Kit_Activation'
    ,   'EUR_BE_On_Trade_Display_Placement_For_Special_Cavist' => 'BE_On_Trade_Display_Placement_For_Special_Cavist'

    ,   'EUR_PT_Off_Trade_OP_No_of_Display' => 'PT_Check_Off_Trade_Display'

    ,   'EUR_DE_Off_Trade_Distribution_Drive' => 'DE_OFF_ALT_Dist_Drive'
    ,   'EUR_DE_Off_Trade_Leaflet_Campaign' => 'DE_OFF_ALT_Leaflet_Campaign'
    ,   'EUR_DE_OnTrade_PROS_TMKT_Promo' => 'DE_ON_ALT_ON_PROS_TMKT_Promos'
    ,   'EUR_DE_Off_Trade_Sales_Drive' => 'DE_OFF_ALT_Sales_Drive'
    ,   'EUR_DE_Off_Trade_Secondary_Placement_Any' => 'DE_OFF_ALT_2nd_PL_Any'
    ,   'EUR_DE_Off_Trade_Secondary_Placement_Carton' => 'DE_OFF_ALT_2nd_PL_Carton'
    ,   'EUR_DE_Off_Trade_Secondary_Placement_Gondelkopf' => 'DE_OFF_ALT_2nd_PL_Gondelkopf'
    ,   'EUR_DE_Off_Trade_Secondary_Placement_Razz_Fazz' => 'DE_OFF_ALT_2nd_PL_Razz_Fazz'
    ,   'EUR_DE_Off_Trade_Secondary_Placement_Standard' => 'DE_OFF_ALT_2nd_PL_STD'
    ,   'EUR_DE_Off_Trade_Secondary_Placement_Theme' => 'DE_OFF_ALT_2nd_PL_Theme'
    ,   'EUR_DE_Off_Trade_Tasting_Campaign' => 'DE_OFF_ALT_Tasting'
    ,   'EUR_DE_Off_Trade_Trade_Fair' => 'DE_OFF_ALT_Trade_Fair'
    ,   'EUR_DE_Off_Trade_Secondary_Placement_Promo_Display' => 'DE_OFF_ALT_2nd_PL_Promo_Display'
    ,   'EUR_DE_Off_Trade_Sales_Drive_SKU_Bottles' => 'DE_OFF_ALT_Sales_Drive_SKU_Bottles'
    ,   'EUR_DE_Off_Trade_Sales_Drive_SKU_Displays' => 'DE_OFF_ALT_Sales_Drive_SKU_Displays'

    ,   'EUR_ZA_Off_Trade_Promotion' => 'ZA_OFF_ALT_Promo'
    ,   'EUR_ZA_On_Trade_Promotion' => 'ZA_ON_ALT_Promo'

    ,   'EUR_FI_Off_Trade_O_P' => ADDITIONAL_LOGIC
    ,   'EUR_FI_On_Trade_O_P' => ADDITIONAL_LOGIC
    };

    private Set<String> promoRecordTypeNamesToResetPromoStatus = new Set<String> {
        'EUR_RU_Off_Trade_Discount_Campaign'
    ,   'EUR_RU_Off_Trade_InStore_Media_POSM_Control'
    ,   'EUR_RU_Off_Trade_Leaflet_Campaign'
    ,   'EUR_RU_Off_Trade_Loyalty_POSM_Placement'
    ,   'EUR_RU_Off_Trade_Model_Store'
    ,   'EUR_RU_Off_Trade_On_Site_Promo_Activities'
    ,   'EUR_RU_Off_Trade_Outlet_Staff_Incentive'
    ,   'EUR_RU_Off_Trade_POSM_Placement'
    ,   'EUR_RU_Off_Trade_Sales_Rep_Competition'
    ,   'EUR_RU_Off_Trade_Stop_Rayon'
    ,   'EUR_RU_ON_Trade_Phase_1'
    ,   'EUR_RU_ON_Trade_Phase_2'

    ,   'EUR_DK_Off_Trade_Leaflet_Campaign'
    ,   'EUR_DK_Off_Trade_Sales_Drive_SKU_Displays'
    ,   'EUR_DK_Off_2nd_Placement_Sell_In_Qty_Promo_Display'
    ,   'EUR_DK_Off_Trade_Distribution_Drive'
    ,   'EUR_DK_OFF_Trade_Sales_Drive_SKU_Cartons'
    ,   'EUR_DK_Off_Trade_Secondary_Placement_Standard'
    ,   'EUR_DK_Off_Trade_Secondary_Placement_Carton'
    ,   'EUR_DK_Off_Trade_Secondary_Placement_Gondola_End'
    ,   'EUR_DK_Off_Trade_Secondary_Placement_Theme'
    ,   'EUR_DK_Off_Trade_Tasting_Campaign'
    ,   'EUR_DK_Off_Trade_EM_Price_Promotion'
    ,   'EUR_DK_Off_Trade_Sales_Drive_SKU_Bottles'

    ,   'EUR_BE_Off_Trade_Sales_Drive'
    ,   'EUR_BE_Off_Trade_Secondary_placement_Spyder_display'
    ,   'EUR_BE_On_Trade_Promo_Kit_Activation'
    ,   'EUR_BE_On_Trade_Display_Placement_For_Special_Cavist'

    ,   'EUR_DE_Off_Trade_Distribution_Drive'
    ,   'EUR_DE_Off_Trade_Leaflet_Campaign'
    ,   'EUR_DE_OnTrade_PROS_TMKT_Promo'
    ,   'EUR_DE_Off_Trade_Sales_Drive'
    ,   'EUR_DE_Off_Trade_Secondary_Placement_Any'
    ,   'EUR_DE_Off_Trade_Secondary_Placement_Carton'
    ,   'EUR_DE_Off_Trade_Secondary_Placement_Gondelkopf'
    ,   'EUR_DE_Off_Trade_Secondary_Placement_Razz_Fazz'
    ,   'EUR_DE_Off_Trade_Secondary_Placement_Standard'
    ,   'EUR_DE_Off_Trade_Secondary_Placement_Theme'
    ,   'EUR_DE_Off_Trade_Tasting_Campaign'
    ,   'EUR_DE_Off_Trade_Trade_Fair'
    ,   'EUR_DE_Off_Trade_Secondary_Placement_Promo_Display'
    ,   'EUR_DE_Off_Trade_Sales_Drive_SKU_Bottles'
    ,   'EUR_DE_Off_Trade_Sales_Drive_SKU_Displays'

    ,   'EUR_ZA_Off_Trade_Promotion'
    ,   'EUR_ZA_On_Trade_Promotion'
    };

    private Set<String> pricePromotionRecordTypes = new Set<String> {
        'EUR_DK_Off_Trade_EM_Price_Promotion'
    };

    private Map<String, String> templateExternalIdByPromoOPType = new Map<String, String> {
        'Type 1' => 'FI_Type_01'
    ,   'Type 2' => 'FI_Type_02'
    };

    private Set<String> promoRecordTypeNamesToSetupPreparationStartDate = new Set<String> {
        'EUR_DE_Off_Trade_Leaflet_Campaign'
    };


    /* ========================================================= */
    /*     Delegate methods
    /* ========================================================= */
    private void handleLogicOnBeforeInsert(List<EUR_CRM_ObjPromo__c> promos) {
        Set<Id> recordTypeIds = this.extractAllRecordTypeIds(promos);
        if (recordTypeIds.isEmpty()) { return ; }

        Map<Id, String> recordTypeDeveloperNamesById = this.getRecordTypeDeveloperNamesById(recordTypeIds);
        if (recordTypeDeveloperNamesById.isEmpty()) { return ; }

        this.setActionListTemplate(promos, recordTypeDeveloperNamesById);
        this.resetPromoStatus(promos, recordTypeDeveloperNamesById);
    }

    private void handleLogicOnBeforeUpdate(List<EUR_CRM_ObjPromo__c> promos, Map<ID, EUR_CRM_ObjPromo__c> oldPromoById) {
        Set<Id> recordTypeIds = this.extractRecordTypeIdsToUpdatePreparationStateDate(promos);
        System.debug('\n\n recordTypeIds => ' + JSON.serializePretty(recordTypeIds) + '\n');
        if (recordTypeIds.isEmpty()) { return ; }

        Map<Id, String> recordTypeDeveloperNamesById = this.getRecordTypeDeveloperNamesById(recordTypeIds);
        System.debug('\n\n recordTypeDeveloperNamesById => ' + JSON.serializePretty(recordTypeDeveloperNamesById) + '\n');
        if (recordTypeDeveloperNamesById.isEmpty()) { return ; }

        this.setPreparationStartDate(promos, recordTypeDeveloperNamesById);
    }


    /* ========================================================= */
    /*     High Level Helpers
    /* ========================================================= */
    private void setActionListTemplate(List<EUR_CRM_ObjPromo__c> promos, Map<Id, String> recordTypeDeveloperNamesById) {
        Set<String> templateExternalIds = this.getTemplateExternalIdsForSpecificRecordTypes(recordTypeDeveloperNamesById);
        if (templateExternalIds.isEmpty()) { return ; }

        Map<String, Id> templateIdByTemplateExternalId = this.getTemplateIdByTemplateExternalId(templateExternalIds);
        System.debug('\n\n templateIdByTemplateExternalId => ' + JSON.serializePretty(templateIdByTemplateExternalId) + '\n');

        for (EUR_CRM_ObjPromo__c promo : promos) {
            if ( ! recordTypeDeveloperNamesById.containsKey(promo.RecordTypeId)) { continue; }

            String rtDevName = recordTypeDeveloperNamesById.get(promo.RecordTypeId);
            if (templateExternalIdByPromoRecordTypeName.containsKey(rtDevName)) {
                String templateExternalId = templateExternalIdByPromoRecordTypeName.get(rtDevName);

                if (templateExternalId.equalsIgnoreCase(ADDITIONAL_LOGIC)) {
                    String promoOPType = promo.EUR_CRM_O_P_Type__c;
                    if (templateExternalIdByPromoOPType.containsKey(promoOPType)) {
                        templateExternalId = templateExternalIdByPromoOPType.get(promoOPType);
                    } else {
                        continue;
                    }
                }

                if (templateIdByTemplateExternalId.containsKey(templateExternalId)) {
                    promo.EUR_CRM_OP_Action_List_Template__c = templateIdByTemplateExternalId.get(templateExternalId);
                } else {
                    promo.addError('No Action List Template found for this type of Objective / Promotion');
                }
            }
        }
    }

    private void resetPromoStatus(List<EUR_CRM_ObjPromo__c> promos, Map<Id, String> recordTypeDeveloperNamesById) {
        for (EUR_CRM_ObjPromo__c promo : promos) {
            if ( ! recordTypeDeveloperNamesById.containsKey(promo.RecordTypeId)) { continue; }

            String rtDevName = recordTypeDeveloperNamesById.get(promo.RecordTypeId);
            if(promoRecordTypeNamesToResetPromoStatus.contains(rtDevName) && ! pricePromotionRecordTypes.contains(rtDevName)){
                promo.EUR_CRM_Status__c = 'Draft';
            }
        }
    }

    private void setPreparationStartDate(List<EUR_CRM_ObjPromo__c> promos, Map<Id, String> recordTypeDeveloperNamesById) {
        Set<String> developerNames = new Set<String>(recordTypeDeveloperNamesById.values());
        developerNames.retainAll(promoRecordTypeNamesToSetupPreparationStartDate);
        System.debug('\n\n developerNames => ' + JSON.serializePretty(developerNames) + '\n');
        if (developerNames.isEmpty()) { return ; }

        Map<Id, EUR_CRM_OP_Customer_Taxonomy_Mapping__c> customerTaxonomyMappingByPromoId = this.getCustomerTaxonomyMappingsByPromoId(new Map<Id, EUR_CRM_ObjPromo__c>(promos).keySet());
        System.debug('\n\n customerTaxonomyMappingByPromoId => ' + JSON.serializePretty(customerTaxonomyMappingByPromoId) + '\n');

        for(EUR_CRM_ObjPromo__c promo : promos){
            if ( ! recordTypeDeveloperNamesById.containsKey(promo.RecordTypeId)) { continue; }

            Decimal weeks = null;
            if (customerTaxonomyMappingByPromoId.containsKey(promo.Id)) {
                weeks = customerTaxonomyMappingByPromoId.get(promo.Id).EUR_CRM_Customer_Taxonomy__r.EUR_CRM_Leaflet_Campaign_Lead_Time_Weeks__c;
            }
            System.debug('\n\n weeks => ' + JSON.serializePretty(weeks) + '\n');

            if (weeks != null) {
                Date d = promo.EUR_CRM_Active_Start_Date__c;
                promo.EUR_CRM_Preparation_Start_Date__c = d.addDays((Integer)weeks * (-7));
            } else {
                promo.EUR_CRM_Preparation_Start_Date__c = null;
            }
        }
    }


    /* ========================================================= */
    /*     Middle Level Helpers
    /* ========================================================= */
    private Map<Id, String> getRecordTypeDeveloperNamesById(Set<Id> recordTypeIds) {
        List<RecordType> recordTypes = this.selectRecordTypesWhereIds(recordTypeIds);

        Map<Id, String> recordTypeDeveloperNamesById = new Map<Id, String>();
        for (RecordType rt : recordTypes) {
            recordTypeDeveloperNamesById.put(rt.Id, rt.DeveloperName);
        }
        return recordTypeDeveloperNamesById;
    }

    private Set<String> getTemplateExternalIdsForSpecificRecordTypes(Map<Id, String> recordTypeDeveloperNamesById) {
        Set<String> externalIds = new Set<String>();
        for (String rtDevName : recordTypeDeveloperNamesById.values()) {
            if (templateExternalIdByPromoRecordTypeName.containsKey(rtDevName)) {
                String templateExternalId = templateExternalIdByPromoRecordTypeName.get(rtDevName);
                if (templateExternalId.equalsIgnoreCase(ADDITIONAL_LOGIC)) {
                    externalIds.addAll(templateExternalIdByPromoOPType.values());
                } else {
                    externalIds.add(templateExternalId);
                }
            }
        }
        return externalIds;
    }

    private Map<String, Id> getTemplateIdByTemplateExternalId(Set<String> templateExternalIds) {
        List<EUR_CRM_OP_Action_List_Template__c> actionListTemplates = selectActionListTemplatesWhereExternalIds(templateExternalIds);

        Map<String, Id> templateIdByTemplateExternalId = new Map<String, Id>();
        for (EUR_CRM_OP_Action_List_Template__c template : actionListTemplates) {
            templateIdByTemplateExternalId.put(template.EUR_CRM_External_ID__c, template.Id);
        }
        return templateIdByTemplateExternalId;
    }

    private Map<Id, EUR_CRM_OP_Customer_Taxonomy_Mapping__c> getCustomerTaxonomyMappingsByPromoId(Set<Id> promoIds) {
        List<EUR_CRM_OP_Customer_Taxonomy_Mapping__c> customerTaxonomy = this.selectCustomerTaxonomyMappingWherePromoIds(promoIds);

        Map<Id, EUR_CRM_OP_Customer_Taxonomy_Mapping__c> customerTaxonomyMappingByPromoId = new Map<Id, EUR_CRM_OP_Customer_Taxonomy_Mapping__c>();
        for (EUR_CRM_OP_Customer_Taxonomy_Mapping__c mapping : customerTaxonomy) {
            if ( ! customerTaxonomyMappingByPromoId.containsKey(mapping.EUR_CRM_ObjPromo__c)) {
                customerTaxonomyMappingByPromoId.put(mapping.EUR_CRM_ObjPromo__c, mapping);
            } else {
                EUR_CRM_OP_Customer_Taxonomy_Mapping__c prevMapping = customerTaxonomyMappingByPromoId.get(mapping.EUR_CRM_ObjPromo__c);
                if (mapping.EUR_CRM_Customer_Taxonomy__r.EUR_CRM_Leaflet_Campaign_Lead_Time_Weeks__c > prevMapping.EUR_CRM_Customer_Taxonomy__r.EUR_CRM_Leaflet_Campaign_Lead_Time_Weeks__c) {
                    customerTaxonomyMappingByPromoId.put(mapping.EUR_CRM_ObjPromo__c, mapping);
                }
            }
        }
        return customerTaxonomyMappingByPromoId;
    }


    /* ========================================================= */
    /*     Low Level Helpers
    /* ========================================================= */
    private Set<Id> extractAllRecordTypeIds(List<EUR_CRM_ObjPromo__c> promos) {
        Set<Id> recordTypeIds = new Set<Id>();
        for (EUR_CRM_ObjPromo__c promo : promos) {
            if (promo.RecordTypeId != null) {
                recordTypeIds.add(promo.RecordTypeId);
            }
        }
        return recordTypeIds;
    }

    private Set<Id> extractRecordTypeIdsToUpdatePreparationStateDate(List<EUR_CRM_ObjPromo__c> promos) {
        Set<Id> recordTypeIds = new Set<Id>();
        for (EUR_CRM_ObjPromo__c promo : promos) {
            if (promo.EUR_CRM_Override_CTax_PrepStartDate__c == false
                && promo.EUR_CRM_Active_Start_Date__c != null
                && promo.RecordTypeId != null) {
                recordTypeIds.add(promo.RecordTypeId);
            }
        }
        return recordTypeIds;
    }


    /* ========================================================= */
    /*     SOQL Selectors
    /* ========================================================= */
    private List<RecordType> selectRecordTypesWhereIds(Set<Id> ids) {
        return [
            SELECT Id
            ,   DeveloperName
            FROM RecordType
            WHERE Id IN :ids
                AND (
                    DeveloperName IN :templateExternalIdByPromoRecordTypeName.keySet()
                    OR DeveloperName IN :pricePromotionRecordTypes
                )
        ];
    }

    private List<EUR_CRM_OP_Action_List_Template__c> selectActionListTemplatesWhereExternalIds(Set<String> externalIds) {
        return [
            SELECT Id
            ,   EUR_CRM_External_ID__c
            FROM EUR_CRM_OP_Action_List_Template__c
            WHERE EUR_CRM_External_ID__c IN :externalIds
        ];
    }

    private List<EUR_CRM_OP_Customer_Taxonomy_Mapping__c> selectCustomerTaxonomyMappingWherePromoIds(Set<Id> promoIds) {
        return [
            SELECT Id
            ,   Name
            ,   EUR_CRM_Customer_Taxonomy__c
            ,   EUR_CRM_Customer_Taxonomy__r.EUR_CRM_Leaflet_Campaign_Lead_Time_Weeks__c
            ,   EUR_CRM_ObjPromo__c
            FROM EUR_CRM_OP_Customer_Taxonomy_Mapping__c
            WHERE EUR_CRM_ObjPromo__c IN :promoIds
        ];
    }

}