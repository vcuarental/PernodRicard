public with sharing class EUR_CRM_GenericGroupController {

    private static EUR_CRM_ObjAndPromoConfigPageService.GroupSelector selector = new EUR_CRM_ObjAndPromoConfigPageService.GroupSelector();

    @AuraEnabled
    public static List<EUR_CRM_Account_Target_Group__c> selectAccountGroups(String promoId) {
        if (String.isNotEmpty(promoId)) {
            return selector.selectAccountGroups(promoId);
        }
        return Test.isRunningTest() ? null : new List<EUR_CRM_Account_Target_Group__c>();
    }

    @AuraEnabled
    public static List<SObject> selectRecords(String query, Id[] ids) {
        System.debug('EUR_CRM_GenericGroupController.selectRecords.query: ' + query);
        System.debug('EUR_CRM_GenericGroupController.selectRecords.ids: ' + ids);
        List<SObject> sObjects = Database.query(query);
        System.debug('sObjects => ' + sObjects);
        return sObjects;
    }


    @AuraEnabled
    public static Integer countRecords(String countQuery, Id[] ids) {
        System.debug('EUR_CRM_GenericGroupController.countRecords:' + countQuery);
        Integer result = Database.countQuery(countQuery);
        System.debug('EUR_CRM_GenericGroupController.result:' + result);
        return result;
    }

    @AuraEnabled
    public static Map<String, Object> selectAndCountRecords(String query, String countQuery, Id[] ids) {

        return new Map<String, Object>{
                'queryResult' => selectRecords(query, ids),
                'countQueryResult' => countRecords(countQuery, ids)
        };
    }
}