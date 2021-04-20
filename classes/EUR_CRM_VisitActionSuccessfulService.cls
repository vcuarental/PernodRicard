public with sharing class EUR_CRM_VisitActionSuccessfulService {

    private static final String CLASS_NAME = 'EUR_CRM_VisitActionSuccessfulService';
    private static final Map<String, Set<String>> RECORD_TYPES_BY_STATUS = EUR_CRM_RecordTypeHelper_v2.getSettingsMultivalueMap(CLASS_NAME, 'RECORD_TYPES_BY_STATUS');

//    @TestVisible
//    private static final Map<String, Set<String>> RECORD_TYPES_BY_STATUS = new Map<String, Set<String>>{
//        'Yes' => new Set<String> {
//            'EUR_DE_OFF_2nd_PL_Do_TMKT_Doc'
//        ,   'DE_OFF_Ad_hoc_Agree_To_Buy'
//        ,   'EUR_DE_OFF_Leaflet_Campaign_Sell_In_Qty'
//        ,   'EUR_DE_OFF_Tasting_Discussion'
//        }
//    ,   'Participating' => new Set<String> {
//            'EUR_DE_ON_TMKT_Promo_Confirm_Participation'
//        }
//    ,   'Presented' => new Set<String> {
//            'EUR_DE_ON_TMKT_Promo_Presentation'
//        }
//    ,   'Listed' => new Set<String> {
//            'EUR_DE_OFF_Dist_Drive_Listing_Check'
//        }
//    ,   'Qty Confirmed' => new Set<String> {
//            'EUR_DE_OFF_2nd_PL_Sell_In_Qty_Carton'
//        ,   'EUR_DE_OFF_2nd_PL_Sell_In_Qty_Gondelkopf'
//        ,   'EUR_DE_OFF_2nd_PL_Sell_In_Qty_Promo_Display'
//        ,   'EUR_DE_OFF_2nd_PL_Sell_In_Qty_Razz_Fazz'
//        ,   'EUR_DE_OFF_2nd_PL_Sell_In_Qty_Standard'
//        ,   'EUR_DE_OFF_2nd_PL_Sell_In_Qty_Theme'
//        ,   'EUR_DE_OFF_Ad_Hoc_Sell_In_Qty'
//        ,   'EUR_DE_OFF_Leaflet_Campaign_Sell_In_Qty'
//        ,   'EUR_DE_OFF_Sales_Drive_SKU_Bottles_Sell_In_Qty'
//        ,   'EUR_DE_OFF_Sales_Drive_SKU_Displays_Sell_In_Qty'
//        ,   'EUR_DE_OFF_Sales_Drive_Sell_In_Qty'
//        ,   'EUR_DE_OFF_Tasting_Sell_In_Qty'
//        ,   'EUR_DE_OFF_Trade_Fair_Sell_In_Qty'
//        ,   'EUR_DE_ON_TMKT_Promo_Enter_Sell_In_Qty'
//        ,   'EUR_DE_OFF_2nd_PL_Present_Theme'
//        }
//    };


    /* ========================================================= */
    /*     Interface
    /* ========================================================= */
    public void handleSuccess(List<EUR_CRM_Visit_Action__c> visitActions) {
        Map<Id, List<EUR_CRM_Visit_Action__c>> visitActionsByRecordTypeId = this.getVisitActionsWithValidStatusByRecordTypeId(visitActions);
//        System.debug('\n\n visitActionsByRecordTypeId => ' + JSON.serializePretty(visitActionsByRecordTypeId) + '\n');
        if (visitActionsByRecordTypeId.isEmpty()) { return ; }

        this.handle(visitActionsByRecordTypeId);
    }

    public void handleSuccess(List<EUR_CRM_Visit_Action__c> visitActions, Map<Id, EUR_CRM_Visit_Action__c> oldVisitActionById) {
        Map<Id, List<EUR_CRM_Visit_Action__c>> visitActionsByRecordTypeId = this.getVisitActionsWithValidStatusByRecordTypeId(visitActions, oldVisitActionById);
//        System.debug('\n\n visitActionsByRecordTypeId => ' + JSON.serializePretty(visitActionsByRecordTypeId) + '\n');
        if (visitActionsByRecordTypeId.isEmpty()) { return ; }

        this.handle(visitActionsByRecordTypeId);
    }


    /* ========================================================= */
    /*     Delegate Methods
    /* ========================================================= */
    private void handle(Map<Id, List<EUR_CRM_Visit_Action__c>> visitActionsByRecordTypeId) {
        Map<Id, RecordType> recordTypeByIds = this.getRecordTypeByIdWhereIds(visitActionsByRecordTypeId.keySet());
        System.debug('\n\n recordTypeByIds => ' + JSON.serializePretty(recordTypeByIds) + '\n');

        for (Id rtId : visitActionsByRecordTypeId.keySet()) {
            for (EUR_CRM_Visit_Action__c va : visitActionsByRecordTypeId.get(rtId)) {
                if (recordTypeByIds.containsKey(va.RecordTypeId) && RECORD_TYPES_BY_STATUS.containsKey(va.EUR_CRM_Status__c)) {
                    String rtDevName = recordTypeByIds.get(va.RecordTypeId).DeveloperName;
                    if (RECORD_TYPES_BY_STATUS.get(va.EUR_CRM_Status__c).contains(rtDevName)) {
                        va.EUR_CRM_Is_Successful__c = true;
                    } else {
                        va.EUR_CRM_Is_Successful__c = false;
                    }
                } else {
                    va.EUR_CRM_Is_Successful__c = false;
                }
            }
        }
    }


    /* ========================================================= */
    /*     High Level Helpers
    /* ========================================================= */
    private Map<Id, List<EUR_CRM_Visit_Action__c>> getVisitActionsWithValidStatusByRecordTypeId(List<EUR_CRM_Visit_Action__c> visitActions) {
        Map<Id, List<EUR_CRM_Visit_Action__c>> visitActionsByRecordTypeId = new Map<Id, List<EUR_CRM_Visit_Action__c>>();
        for (EUR_CRM_Visit_Action__c va : visitActions) {
            if (RECORD_TYPES_BY_STATUS.containsKey(va.EUR_CRM_Status__c)) {
                if (visitActionsByRecordTypeId.containsKey(va.RecordTypeId)) {
                    visitActionsByRecordTypeId.get(va.RecordTypeId).add(va);
                } else {
                    visitActionsByRecordTypeId.put(va.RecordTypeId, new List<EUR_CRM_Visit_Action__c> { va });
                }
            } else {
                va.EUR_CRM_Is_Successful__c = false;
            }
        }
        return visitActionsByRecordTypeId;
    }

    private Map<Id, List<EUR_CRM_Visit_Action__c>> getVisitActionsWithValidStatusByRecordTypeId(List<EUR_CRM_Visit_Action__c> visitActions, Map<Id, EUR_CRM_Visit_Action__c> oldVisitActionById) {
        Map<Id, List<EUR_CRM_Visit_Action__c>> visitActionsByRecordTypeId = new Map<Id, List<EUR_CRM_Visit_Action__c>>();
        for (EUR_CRM_Visit_Action__c va : visitActions) {
            if (this.isStatusChanged(va, oldVisitActionById)) {
                if (visitActionsByRecordTypeId.containsKey(va.RecordTypeId)) {
                    visitActionsByRecordTypeId.get(va.RecordTypeId).add(va);
                } else {
                    visitActionsByRecordTypeId.put(va.RecordTypeId, new List<EUR_CRM_Visit_Action__c> { va });
                }
            }
        }
        return visitActionsByRecordTypeId;
    }

    private Map<Id, RecordType> getRecordTypeByIdWhereIds(Set<Id> rtIds) {
        Set<String> rtDevNames = new Set<String>();
        for (Set<String> devNames : RECORD_TYPES_BY_STATUS.values()) {
            rtDevNames.addAll(devNames);
        }

        return this.selectRecordTypeByIdWhereIdsAndDeveloperNames(rtIds, rtDevNames);
    }


    /* ========================================================= */
    /*     Low Level Helpers
    /* ========================================================= */
    private Boolean isStatusChanged(EUR_CRM_Visit_Action__c va, Map<Id, EUR_CRM_Visit_Action__c> oldVisitActionById) {
        return va.EUR_CRM_Status__c != oldVisitActionById.get(va.Id).EUR_CRM_Status__c;
    }


    /* ========================================================= */
    /*     SOQL Selectors
    /* ========================================================= */
    private Map<Id, RecordType> selectRecordTypeByIdWhereIdsAndDeveloperNames(Set<Id> rtIds, Set<String> rtDevNames) {
        return new Map<Id, RecordType>([
            SELECT Id
            ,   DeveloperName
            FROM RecordType
            WHERE Id IN :rtIds
                AND DeveloperName IN :rtDevNames
        ]);
    }

}