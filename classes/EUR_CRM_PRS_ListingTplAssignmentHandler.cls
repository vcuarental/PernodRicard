/*********************************************************************************
 * Name: EUR_CRM_SE_AssignTemplateToAccountHandlr
 * Description: Automatically assign listing template to an Account when create and update
 *
 * Version History
 * Date         Developer   Comments
 * ----------   ----------  -------------------------------------------------------     
 *  18-4-2017  Jay Chau     Created. Replace EUR_CRM_SE_AssignTemplateToAccountHandlr and EUR_CRM_NL_AssignTemplateToAccountHandlr
*********************************************************************************/

public with sharing class EUR_CRM_PRS_ListingTplAssignmentHandler {

    private Set<Id> groupOutletTypeIds = new Set<Id>();
    private Set<Id> outletTypeIds = new Set<Id>();
    private Set<Id> imageLevelIds = new Set<Id>();
    private Set<Id> volumePotentialIds = new Set<Id>();
    private Set<String> targetTemplateRTs = new Set<String>();

    private final Map<String, String> TEMPLATE_CRITERIA_RT_BY_ACCOUNT_RT = EUR_CRM_RecordTypeHelper_v2.getSettingsMap(EUR_CRM_PRS_ListingTplAssignmentHandler.class.getName(), 'TEMPLATE_CRITERIA_RT_BY_ACCOUNT_RT');
//    private static final Map<String, String> TEMPLATE_CRITERIA_RT_BY_ACCOUNT_RT = new Map<String, String>{
//            'EUR_NL_On_Trade' => 'EUR_NL_On_Trade_Template_Criteria',
//            'EUR_SE_On_Trade' => 'EUR_SE_On_Trade_Template_Criteria',
//            'EUR_SE_Wholesaler' => 'EUR_SE_On_Trade_Template_Criteria',
//            'EUR_BE_On_Trade' => 'EUR_BE_On_Trade_Template_Criteria',
//            'EUR_IDL_On_Trade_Account' => 'EUR_IDL_On_Trade_Template_Criteria',
//            'EUR_DB_On_Trade_Account' => 'EUR_DB_On_Trade_Template_Criteria',
//            'EUR_SE_On_Trade' => 'EUR_SE_On_Trade_Template_Criteria',
//            'EUR_IT_On_Trade_Account' => 'EUR_IT_On_Trade_Template_Criteria',
//
//            'EUR_DE_On_Trade_Gastronomy' => 'EUR_CRM_DE_Template_Criteria',
//            'EUR_DE_On_Trade_Wholesaler' => 'EUR_CRM_DE_Template_Criteria',
//            'EUR_DE_On_Trade_Hotel' => 'EUR_CRM_DE_Template_Criteria',
//            'EUR_DE_On_Trade_System_Gastronomy' => 'EUR_CRM_DE_Template_Criteria',
//            'EUR_DE_On_Trade_Special_Stores' => 'EUR_CRM_DE_Template_Criteria',
//            'EUR_DE_On_Trade_B2B' => 'EUR_CRM_DE_Template_Criteria',
//            'EUR_DE_On_Trade_New_Business' => 'EUR_CRM_DE_Template_Criteria',
//
//            'EUR_AT_ON_Cash_Carry' => 'EUR_AT_Template_Criteria',
//            'EUR_AT_ON_Gastronomy' => 'EUR_AT_Template_Criteria',
//            'EUR_AT_ON_Hotel' => 'EUR_AT_Template_Criteria',
//            'EUR_AT_ON_System_Gastronomy' => 'EUR_AT_Template_Criteria',
//            'EUR_AT_ON_Wholesaler' => 'EUR_AT_Template_Criteria',
//
//            'EUR_BG_On_Trade' => 'EUR_BG_On_Trade_Template_Criteria',
//            'EUR_BG_Wholesaler' => 'EUR_BG_On_Trade_Template_Criteria',
//
//            'EUR_CH_ON_B2B' => 'EUR_CH_On_Trade_Template_Criteria',
//            'EUR_CH_ON_Cash_Carry' => 'EUR_CH_On_Trade_Template_Criteria',
//            'EUR_CH_ON_HORECA' => 'EUR_CH_On_Trade_Template_Criteria',
//            'EUR_CH_ON_Hotel' => 'EUR_CH_On_Trade_Template_Criteria',
//            'EUR_CH_ON_Wholesaler' => 'EUR_CH_On_Trade_Template_Criteria',
//
//            'EUR_DK_On_Trade' => 'EUR_DK_ON_Trade_Template_Criteria',
////            'EUR_DK_OFF_Trade' => 'EUR_DK_OFF_Trade_Template_Criteria',
//
//            'EUR_FI_Direct_On_Trade' => 'EUR_FI_On_Trade_Template_Criteria',
//            'EUR_FI_Indirect_On_Trade' => 'EUR_FI_On_Trade_Template_Criteria',
//
//            'EUR_MA_On_Trade' => 'EUR_MA_On_Trade_Template_Criteria',
//
//            'EUR_RU_On_Trade' => 'EUR_RU_On_Trade_Template_Criteria'
//
//    };

    public void onBeforeInsert(List<EUR_CRM_Account__c> accounts) {
        Map<Id, RecordTypeInfo> rtInfoById = Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosById();

        List<EUR_CRM_Account__c> accsToUpdate = this.getAccountsToUpdate(accounts, rtInfoById);
        System.debug('\n accsToUpdate.size() => ' + accsToUpdate.size() + '\n');
        System.debug('\n accsToUpdate => ' + JSON.serializePretty(accsToUpdate) + '\n');
        if (accsToUpdate.isEmpty()) { return; }

        this.getAccountsPrs(accsToUpdate, rtInfoById);

        Map<String, String> templateCriteriaByPrsKey = this.getTemplateCriteriaByPrsKey(this.selectTemplateCriteriaWherePrs());
        System.debug('\n templateCriteriaByPrsKey.size() => ' + templateCriteriaByPrsKey.size() + '\n');
        System.debug('\n templateCriteriaByPrsKey => ' + JSON.serializePretty(templateCriteriaByPrsKey) + '\n');
        if (templateCriteriaByPrsKey.isEmpty()) { return; }

        this.assignTemplate(accsToUpdate, templateCriteriaByPrsKey);
    }

    public void onBeforeUpdate(List<EUR_CRM_Account__c> accounts, Map<Id, EUR_CRM_Account__c> oldAccountById) {
        Map<Id, RecordTypeInfo> rtInfoById = Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosById();

        List<EUR_CRM_Account__c> accsToUpdate = this.getAccountsToUpdate(accounts, oldAccountById, rtInfoById);
        System.debug('\n accsToUpdate.size() => ' + accsToUpdate.size() + '\n');
        System.debug('\n accsToUpdate => ' + JSON.serializePretty(accsToUpdate) + '\n');
        if (accsToUpdate.isEmpty()) { return; }

        this.getAccountsPrs(accsToUpdate, rtInfoById);

        Map<String, String> templateCriteriaByPrsKey = this.getTemplateCriteriaByPrsKey(this.selectTemplateCriteriaWherePrs());
        System.debug('\n templateCriteriaByPrsKey.size() => ' + templateCriteriaByPrsKey.size() + '\n');
        System.debug('\n templateCriteriaByPrsKey => ' + JSON.serializePretty(templateCriteriaByPrsKey) + '\n');
        if (templateCriteriaByPrsKey.isEmpty()) { return; }

        this.assignTemplate(accsToUpdate, templateCriteriaByPrsKey);
    }


    /* ========================================================= */
    /*      High Level Helpers
    /* ========================================================= */
    private void getAccountsPrs(List<EUR_CRM_Account__c> accsToUpdate, Map<Id, RecordTypeInfo> rtInfoById) {
        for (EUR_CRM_Account__c acc : accsToUpdate) {
            groupOutletTypeIds.add(acc.EUR_CRM_PRS_Group_Outlet_Type__c);
            outletTypeIds.add(acc.EUR_CRM_PRS_Outlet_Type__c);
            imageLevelIds.add(acc.EUR_CRM_PRS_Image_Level__c);
            volumePotentialIds.add(acc.EUR_CRM_PRS_Volume_Potential__c);
            targetTemplateRTs.add(TEMPLATE_CRITERIA_RT_BY_ACCOUNT_RT.get(rtInfoById.get(acc.RecordTypeId).getDeveloperName()));
        }
    }

    private void assignTemplate(List<EUR_CRM_Account__c> accsToUpdate, Map<String, String> templateCriteriaByPrsKey) {
        for (EUR_CRM_Account__c acc : accsToUpdate) {
            String accPrsKey = this.getAccountPrsKey(acc);
            if ( ! templateCriteriaByPrsKey.containsKey(accPrsKey)) { continue; }
            acc.EUR_CRM_Listing_Template__c = templateCriteriaByPrsKey.get(accPrsKey);
        }
    }


    /* ========================================================= */
    /*      Middle Level Helpers
    /* ========================================================= */
    private List<EUR_CRM_Account__c> getAccountsToUpdate(List<EUR_CRM_Account__c> accounts, Map<Id, RecordTypeInfo> rtInfoById) {
        List<EUR_CRM_Account__c> accsToUpdate = new List<EUR_CRM_Account__c>();
        for (EUR_CRM_Account__c acc : accounts) {
//            if (this.isAccRtValid(rtInfoById, acc) && this.isPrsFilled(acc)) {
            if (this.isAccRtValid(rtInfoById, acc)) {
                accsToUpdate.add(acc);
            }
        }
        return accsToUpdate;
    }

    private List<EUR_CRM_Account__c> getAccountsToUpdate(List<EUR_CRM_Account__c> accounts, Map<Id, EUR_CRM_Account__c> oldAccountById, Map<Id, RecordTypeInfo> rtInfoById) {
        List<EUR_CRM_Account__c> accsToUpdate = new List<EUR_CRM_Account__c>();
        for (EUR_CRM_Account__c acc : accounts) {
//            if (this.isAccRtValid(rtInfoById, acc) && this.isPrsChanged(acc, oldAccountById.get(acc.Id)) && this.isPrsFilled(acc)) {
            if (this.isAccRtValid(rtInfoById, acc) && this.isPrsChanged(acc, oldAccountById.get(acc.Id))) {
                accsToUpdate.add(acc);
            }
        }
        return accsToUpdate;
    }

    private Map<String, String> getTemplateCriteriaByPrsKey(List<EUR_CRM_JB_Template_Criteria__c> templateCriteria) {
        System.debug('\n templateCriteria.size() => ' + templateCriteria.size() + '\n');
        System.debug('\n templateCriteria => ' + JSON.serializePretty(templateCriteria) + '\n');
        if (templateCriteria.isEmpty()) { return new Map<String, String>(); }

        Map<String, String> templateCriteriaByPrsKey = new Map<String, String>();
        for (EUR_CRM_JB_Template_Criteria__c template : templateCriteria) {
            templateCriteriaByPrsKey.put(
                (String) template.EUR_CRM_PRS_Group_Outlet_Type__c
                    + (String) template.EUR_CRM_PRS_Outlet_Type__c
                    + (String) template.EUR_CRM_PRS_Seg_Aspect_IL__c
                    + (String) template.EUR_CRM_PRS_Seg_Aspect_VP__c, (String) template.EUR_JB_Template__c);
        }
        return templateCriteriaByPrsKey;
    }


    /* ========================================================= */
    /*      Low Level Helpers
    /* ========================================================= */
    private Boolean isAccRtValid(Map<Id, RecordTypeInfo> rtInfoById, EUR_CRM_Account__c acc) {
        return TEMPLATE_CRITERIA_RT_BY_ACCOUNT_RT.keySet().contains(rtInfoById.get(acc.RecordTypeId).getDeveloperName());
    }

//    private Boolean isPrsFilled(EUR_CRM_Account__c acc) {
//        return acc.EUR_CRM_PRS_Group_Outlet_Type__c != null
//            && acc.EUR_CRM_PRS_Outlet_Type__c != null
//            && acc.EUR_CRM_PRS_Image_Level__c != null
//            && acc.EUR_CRM_PRS_Volume_Potential__c != null;
//    }

    private Boolean isPrsChanged(EUR_CRM_Account__c acc, EUR_CRM_Account__c oldAccount) {
        return acc.EUR_CRM_PRS_Group_Outlet_Type__c != oldAccount.EUR_CRM_PRS_Group_Outlet_Type__c
            || acc.EUR_CRM_PRS_Outlet_Type__c != oldAccount.EUR_CRM_PRS_Outlet_Type__c
            || acc.EUR_CRM_PRS_Image_Level__c != oldAccount.EUR_CRM_PRS_Image_Level__c
            || acc.EUR_CRM_PRS_Volume_Potential__c != oldAccount.EUR_CRM_PRS_Volume_Potential__c;
    }

    private String getAccountPrsKey(EUR_CRM_Account__c acc) {
        return (String) acc.EUR_CRM_PRS_Group_Outlet_Type__c
            + (String) acc.EUR_CRM_PRS_Outlet_Type__c
            + (String) acc.EUR_CRM_PRS_Image_Level__c
            + (String) acc.EUR_CRM_PRS_Volume_Potential__c;
    }


    /* ========================================================= */
    /*      SOQL Selectors
    /* ========================================================= */
    private List<EUR_CRM_JB_Template_Criteria__c> selectTemplateCriteriaWherePrs() {
        return [
            SELECT Name
            ,   EUR_JB_Template__c
            ,   EUR_CRM_PRS_Group_Outlet_Type__c
            ,   EUR_CRM_PRS_Group_Outlet_Type_Name__c
            ,   EUR_CRM_PRS_Outlet_Type__c
            ,   EUR_CRM_PRS_Outlet_Type_Name__c
            ,   EUR_CRM_PRS_Seg_Aspect_IL__c
            ,   EUR_CRM_PRS_Segmentation_IL_Aspect_Name__c
            ,   EUR_CRM_PRS_Seg_Aspect_VP__c
            ,   EUR_CRM_PRS_Segmentation_VP_Aspect_Name__c
            ,   EUR_JB_Active__c
            FROM EUR_CRM_JB_Template_Criteria__c
            WHERE EUR_CRM_PRS_Group_Outlet_Type__c IN :groupOutletTypeIds
            AND EUR_CRM_PRS_Outlet_Type__c IN :outletTypeIds
            AND EUR_CRM_PRS_Seg_Aspect_IL__c IN :imageLevelIds
            AND EUR_CRM_PRS_Seg_Aspect_VP__c IN :volumePotentialIds
            AND EUR_JB_Active__c = true
            AND RecordTYpe.DeveloperName IN :targetTemplateRTs
        ];
    }
}