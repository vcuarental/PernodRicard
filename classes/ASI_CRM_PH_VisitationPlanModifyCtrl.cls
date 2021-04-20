public with sharing class ASI_CRM_PH_VisitationPlanModifyCtrl {

    public static final Set<String> PH_SUB_BRAND_RECORD_TYPE_DEV_NAME = new Set<String> {
        'ASI_MFM_PH_DF_Sub_brand',
        'ASI_MFM_PH_DP_Sub_brand',
        'ASI_TnE_PH_Sub_brand'
    };

    public ASI_CRM_PH_VisitationPlanModifyCtrl() {
    }

    @AuraEnabled
    public static ASI_HK_CRM_Visitation_Plan_Detail__c getRecord(String recordId) {
        ASI_HK_CRM_Visitation_Plan_Detail__c visitationPlanDetail = [SELECT Id, 
            ASI_CRM_Menu_Listing__c, 
            ASI_CRM_Pouring__c
            FROM ASI_HK_CRM_Visitation_Plan_Detail__c 
            WHERE id = :recordId];

        return visitationPlanDetail;
    }

    @AuraEnabled
    public static Map<String, Id> getSubBrand() {
        List<ASI_MFM_Sub_brand__c> subBrandList = [SELECT Id,
            Name
            FROM ASI_MFM_Sub_brand__c
            WHERE RecordType.DeveloperName in :PH_SUB_BRAND_RECORD_TYPE_DEV_NAME
            AND ASI_TH_CRM_Active__c = true
            ORDER BY Name];

        Map<String, Id> subbrandIdMap = new Map<String, Id>();
        for(ASI_MFM_Sub_brand__c subBrand : subBrandList) {
            subbrandIdMap.put(subBrand.Name, subBrand.Id);
        }

        return subbrandIdMap;
    }

    @AuraEnabled
    public static void saveRecord(String recordId, String menuListing, String pouring) {
        ASI_HK_CRM_Visitation_Plan_Detail__c visitationPlanDetail = new ASI_HK_CRM_Visitation_Plan_Detail__c();
        visitationPlanDetail.Id                      = recordId;
        visitationPlanDetail.ASI_CRM_Menu_Listing__c = menuListing;
        visitationPlanDetail.ASI_CRM_Pouring__c      = pouring;

        Database.update(visitationPlanDetail);
    }

}