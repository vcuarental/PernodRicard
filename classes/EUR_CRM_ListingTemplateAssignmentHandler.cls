/**
before insert/udpate
"Listing Template - Modify the Trigger to include AO and KE record types:
On Trade - Use the existing criteria (Group Outlet Type, Outlet Type, Image Level and Volume Potential) to match with accounts
Off Trade - Using the same mechanism as On Trade but with 2 other criteria (Outlet Classification and Outlet Classification Type) to match with accounts"

account
recordtypes
field
EUR_AO_Off_Trade
EUR_AO_On_Trade
EUR_KE_Off_Trade
EUR_KE_On_Trade
EUR_FI_Indirect_On_Trade
EUR_FI_Direct_On_Trade
EUR_NG_On_Trade
EUR_NG_Off_Trade_Traditional
EUR_NG_Off_Trade_Modern
EUR_ZA_Off_Trade
EUR_ZA_On_Trade_Direct
EUR_ZA_On_Trade_Indirect
EUR_ZA_On_Trade_Informal


EUR_CRM_JB_Template__c
EUR_AO_Off_Trade_Template
EUR_AO_On_Trade_Template
EUR_KE_Off_Trade_Template
EUR_KE_On_Trade_Template

EUR_CRM_JB_Template_Criteria__c
EUR_AO_Off_Trade_Template_Criteria
EUR_AO_On_Trade_Template_Criteria
EUR_KE_Off_Trade_Template_Criteria
EUR_KE_On_Trade_Template_Criteria
EUR_FI_On_Trade_Template_Criteria
EUR_NG_Off_Trade_Template_Criteria
EUR_NG_On_Trade_Template_Criteria
EUR_ZA_On_Trade_Template_Criteria
EUR_ZA_Off_Trade_Template_Criteria

EUR_CRM_Outlet_Classification__c
EUR_CRM_Outlet_Classification_Type__c
EUR_JB_Active__c
EUR_JB_Template__c
*/
public with sharing class EUR_CRM_ListingTemplateAssignmentHandler extends EUR_CRM_TriggerAbstract {

    public EUR_CRM_ListingTemplateAssignmentHandler() {
        super('EUR_CRM_ListingTemplateAssignmentHandler');
    }

    private static final String CURRENT_CLASS_NAME = 'EUR_CRM_ListingTemplateAssignmentHandler';

    private Map<String, String> templateCriteriaRTMap = EUR_CRM_RecordTypeHelper.ListingTemplateAssignmentHandler_templateCriteriaRecordTypeMap;

    private static Set<String> segmentationRecordTypes = EUR_CRM_RecordTypeHelper.ListingTemplateAssignmentHandler_segmentationRecordTypes;

    private static Set<String> classificationRecordTypes = EUR_CRM_RecordTypeHelper.ListingTemplateAssignmentHandler_classificationRecordTypes;

    private static Set<String> customerTaxonomyRecordTypes = EUR_CRM_RecordTypeHelper_v2.getSettingsSet(CURRENT_CLASS_NAME, 'customerTaxonomyRecordTypes');
//    private static Set<String> customerTaxonomyRecordTypes = new Set<String>{
//            'EUR_FI_Direct_Off_Trade'
//        ,   'EUR_FI_Indirect_Off_Trade'
//        ,   'EUR_IDL_Off_Trade_Account'
//        ,   'EUR_DB_Off_Trade_Account'
//        ,   'EUR_NL_Off_Trade'
//        ,   'EUR_IT_Off_Trade_Account'
//
//        ,   'EUR_BG_Modern_Off_Trade'
//        ,   'EUR_BG_Traditional_Off_Trade'
//
////        ,   'EUR_DE_Off_Trade_New_Business'
////        ,   'EUR_DE_Off_Trade_Retail'
//        ,   'EUR_DK_OFF_Trade'
////        ,   'EUR_MA_Off_Trade'
//    };

    public static Set<String> TargetRecordSet {
        get {
            Set<String> TRt = new Set<String>();
            TRt.addAll(segmentationRecordTypes);
            TRt.addAll(classificationRecordTypes);
            TRt.addAll(customerTaxonomyRecordTypes);
            return TRt;
        }
        private set;
    }


    private Map<Id, Recordtype> accountRecordTypesMap;

    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        System.Debug('EUR_CRM_ListingTemplateAssignmentHandler');
        List<Recordtype> accountRecordTypes = Global_RecordTypeCache.getRtList('EUR_CRM_Account__c');
        accountRecordTypesMap = new Map<Id, Recordtype>();

        for (Recordtype rt : accountRecordTypes) {
            accountRecordTypesMap.put(rt.id, rt);
        }

        Set<String> groupOutletTypeSet = new Set<String>();
        Set<String> outletTypeSet = new Set<String>();
        Set<String> imageLevelSet = new Set<String>();
        Set<String> volumePotentialSet = new Set<String>();
        Set<String> classificationSet = new Set<String>();
        Set<String> classificationTypeSet = new Set<String>();
        Set<String> segmentationRTSet = new Set<String>();
        Set<String> classificationRTSet = new Set<String>();
        Set<String> custTaxonomySet = new Set<String>();

        List<EUR_CRM_Account__c> acctClassification = new List<EUR_CRM_Account__c>();
        List<EUR_CRM_Account__c> acctSegmentationUpdate = new List<EUR_CRM_Account__c>();
        List<EUR_CRM_Account__c> acctCustTaxonomyUpdate = new List<EUR_CRM_Account__c>();

        for (EUR_CRM_Account__c acct : (List<EUR_CRM_Account__c>) sObjList) {
            String rtDevName = accountRecordTypesMap.get(acct.recordtypeid).developername;
            EUR_CRM_Account__c oldEuAccount = Trigger.IsUpdate ? ((EUR_CRM_Account__c) oldMap.get(acct.id)) : null;
            if (Trigger.isInsert || (Trigger.isUpdate && isChanged(acct, oldEuAccount))) {
                if (segmentationRecordTypes.contains(rtDevName) &&
                        acct.EUR_CRM_Group_Outlet_Type__c != null &&
                        acct.EUR_CRM_Outlet_Type__c != null &&
                        acct.EUR_CRM_Volume_Potential__c != null &&
                        acct.EUR_CRM_Image_Level__c != null) {
                    //Add to Segmentation details set
                    groupOutletTypeSet.add(acct.EUR_CRM_Group_Outlet_Type__c);
                    outletTypeSet.add(acct.EUR_CRM_Outlet_Type__c);
                    imageLevelSet.add(acct.EUR_CRM_Image_Level__c);
                    volumePotentialSet.add(acct.EUR_CRM_Volume_Potential__c);
                    //Add to map
                    acctSegmentationUpdate.add(acct);
                    segmentationRTSet.add(templateCriteriaRTMap.get(rtDevName));
                } else if (classificationRecordTypes.contains(rtDevName) &&
                    (acct.EUR_CRM_Outlet_Classification__c != null ||
                        acct.EUR_CRM_Outlet_Classification_Type__c != null))
                         {
                    acctClassification.add(acct);
                    if (acct.EUR_CRM_Outlet_Classification__c != null)
                        classificationSet.add(acct.EUR_CRM_Outlet_Classification__c);
                    if (acct.EUR_CRM_Outlet_Classification_Type__c != null)
                        classificationTypeSet.add(acct.EUR_CRM_Outlet_Classification_Type__c);
                    classificationRTSet.add(templateCriteriaRTMap.get(rtDevName));
                } else if (customerTaxonomyRecordTypes.contains(rtDevName)) {
                    acctCustTaxonomyUpdate.add(acct);
                    if (acct.EUR_JB_Customer_Taxonomy__c != null)
                        custTaxonomySet.add(acct.EUR_JB_Customer_Taxonomy__c);
                }
                // Special case: ZA On trade only need groupOutletType and imageLevelSet
                else if (segmentationRecordTypes.contains(rtDevName) &&
                        acct.EUR_CRM_Group_Outlet_Type__c != null && acct.EUR_CRM_Image_Level__c != null) {
                    //Add to Segmentation details set
                    groupOutletTypeSet.add(acct.EUR_CRM_Group_Outlet_Type__c);
                    //outletTypeSet.add(acct.EUR_CRM_Outlet_Type__c);
                    imageLevelSet.add(acct.EUR_CRM_Image_Level__c);
                    //volumePotentialSet.add(acct.EUR_CRM_Volume_Potential__c);
                    //Add to map
                    acctSegmentationUpdate.add(acct);
                    segmentationRTSet.add(templateCriteriaRTMap.get(rtDevName));
                }
            }
        }

        System.debug('acctClassification size ' + acctClassification.size());
        System.debug('acctSegmentationUpdate size ' + acctSegmentationUpdate.size());
        System.debug('groupOutletTypeSet:'+groupOutletTypeSet);
        System.debug('outletTypeSet:'+outletTypeSet);
        System.debug('imageLevelSet:'+imageLevelSet);
        System.debug('volumePotentialSet:'+volumePotentialSet);
        System.debug('segmentationRTSet:'+segmentationRTSet);

        if (acctSegmentationUpdate.size() > 0) {
            //map key = group outlet + outlet + image level + volume pot + recordtyp dev name;
            Map<String, id> templateMap = new Map<String, id>();
            for (EUR_CRM_JB_Template_Criteria__c templateCriteria : [
                    select EUR_JB_Group_Outlet_Type__c,EUR_JB_Outlet_Type__c,EUR_JB_Image_Level__c,EUR_JB_Volume_Potential__c, EUR_JB_Template__c, recordtype.developername
                    from EUR_CRM_JB_Template_Criteria__c
                    WHERE ((EUR_JB_Image_Level__c IN:imageLevelSet AND EUR_JB_Group_Outlet_Type__c IN:groupOutletTypeSet)
                    OR (EUR_JB_Group_Outlet_Type__c IN:groupOutletTypeSet
                    AND EUR_JB_Outlet_Type__c IN:outletTypeSet
                    AND EUR_JB_Image_Level__c IN:imageLevelSet
                    AND EUR_JB_Volume_Potential__c IN:volumePotentialSet))
                    AND recordtype.developername IN:segmentationRTSet
                    AND EUR_JB_Active__c = true
                    LIMIT 49999
            ]) {
                String key = '' + templateCriteria.EUR_JB_Group_Outlet_Type__c + templateCriteria.EUR_JB_Outlet_Type__c + templateCriteria.EUR_JB_Image_Level__c + templateCriteria.EUR_JB_Volume_Potential__c + templateCriteria.recordtype.developername;
                if (templateCriteria.recordtype.developername == 'EUR_ZA_On_Trade_Template_Criteria') {
                    key = '' + templateCriteria.EUR_JB_Group_Outlet_Type__c + templateCriteria.EUR_JB_Image_Level__c + templateCriteria.recordtype.developername;
                }
                templateMap.put(key, templateCriteria.EUR_JB_Template__c);
                System.debug('##################### key Template ' + key);
            }
            for (EUR_CRM_Account__c acct : acctSegmentationUpdate) {
                String rtDevName = accountRecordTypesMap.get(acct.recordtypeid).developername;
                String key = '' + acct.EUR_CRM_Group_Outlet_Type__c + acct.EUR_CRM_Outlet_Type__c + acct.EUR_CRM_Image_Level__c + acct.EUR_CRM_Volume_Potential__c + templateCriteriaRTMap.get(rtDevName);
                if (templateCriteriaRTMap.get(rtDevName) == 'EUR_ZA_On_Trade_Template_Criteria') {
                    key = '' + acct.EUR_CRM_Group_Outlet_Type__c + acct.EUR_CRM_Image_Level__c + templateCriteriaRTMap.get(rtDevName);
                }
                acct.EUR_CRM_Listing_Template__c = templateMap.get(key);

                System.debug('##################### key Account ' + key);
            }
        }

        if (acctClassification.size() > 0) {
            //map key = Outlet Classification + Outlet Classification Type +  recordtyp dev name;
            Map<String, id> templateMap = new Map<String, id>();
            for (EUR_CRM_JB_Template_Criteria__c templateCriteria : [
                    select EUR_CRM_Outlet_Classification__c, EUR_CRM_Outlet_Classification_Type__c, EUR_JB_Template__c, recordtype.developername
                    from EUR_CRM_JB_Template_Criteria__c
                    WHERE (EUR_CRM_Outlet_Classification__c IN:classificationSet
                    OR (EUR_CRM_Outlet_Classification_Type__c IN:classificationTypeSet AND EUR_CRM_Outlet_Classification__c IN:classificationSet))
                    AND recordtype.developername IN:classificationRTSet
                    AND EUR_JB_Active__c = true
                    LIMIT 49999
            ]) {
                System.debug('TEMPLATE CLASSIFICATION EXIST');
                String key = '' + templateCriteria.EUR_CRM_Outlet_Classification__c + templateCriteria.EUR_CRM_Outlet_Classification_Type__c + templateCriteria.recordtype.developername;
                templateMap.put(key, templateCriteria.EUR_JB_Template__c);
            }
            for (EUR_CRM_Account__c acct : acctClassification) {
                String rtDevName = accountRecordTypesMap.get(acct.recordtypeid).developername;
                String key = '' + acct.EUR_CRM_Outlet_Classification__c + acct.EUR_CRM_Outlet_Classification_Type__c + templateCriteriaRTMap.get(rtDevName);
                acct.EUR_CRM_Listing_Template__c = templateMap.get(key);
            }
        }

        if (acctCustTaxonomyUpdate.size() > 0) {
            //map key = customer taxonomy +  recordtyp dev name;
            Map<String, id> templateMap = new Map<String, id>();
            for (EUR_CRM_JB_Template__c template : [
                    select id, EUR_CRM_Customer_Taxonomy__c
                    from EUR_CRM_JB_Template__c
                    WHERE EUR_CRM_Customer_Taxonomy__c IN:custTaxonomySet
            ]) {
                templateMap.put(template.EUR_CRM_Customer_Taxonomy__c, template.id);
            }
            for (EUR_CRM_Account__c acct : acctCustTaxonomyUpdate) {
                if (acct.EUR_JB_Customer_Taxonomy__c == null) {
                    acct.EUR_CRM_Listing_Template__c = null;
                    continue;
                }
                acct.EUR_CRM_Listing_Template__c = templateMap.get(acct.EUR_JB_Customer_Taxonomy__c);
            }
        }
    }

    private Boolean isChanged(EUR_CRM_Account__c euAccount, EUR_CRM_Account__c oldEuAccount) {
        return euAccount.EUR_CRM_Group_Outlet_Type__c != oldEuAccount.EUR_CRM_Group_Outlet_Type__c ||
                euAccount.EUR_CRM_Image_Level__c != oldEuAccount.EUR_CRM_Image_Level__c ||
                euAccount.EUR_CRM_Outlet_Type__c != oldEuAccount.EUR_CRM_Outlet_Type__c ||
                euAccount.EUR_CRM_Volume_Potential__c != oldEuAccount.EUR_CRM_Volume_Potential__c ||
                euAccount.EUR_CRM_Outlet_Classification__c != oldEuAccount.EUR_CRM_Outlet_Classification__c ||
                euAccount.EUR_CRM_Outlet_Classification_Type__c != oldEuAccount.EUR_CRM_Outlet_Classification_Type__c ||
                euAccount.EUR_JB_Customer_Taxonomy__c != oldEuAccount.EUR_JB_Customer_Taxonomy__c;
    }
}