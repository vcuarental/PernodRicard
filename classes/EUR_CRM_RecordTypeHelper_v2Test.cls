@IsTest(IsParallel = true)
private class EUR_CRM_RecordTypeHelper_v2Test {

    private static final Map<String, String> TEMPLATE_CRITERIA_RT_BY_ACCOUNT_RT = new Map<String, String>{
        'EUR_NL_On_Trade' => 'EUR_NL_On_Trade_Template_Criteria',
        'EUR_SE_On_Trade' => 'EUR_SE_On_Trade_Template_Criteria',
        'EUR_SE_Wholesaler' => 'EUR_SE_On_Trade_Template_Criteria',
        'EUR_BE_On_Trade' => 'EUR_BE_On_Trade_Template_Criteria',
        'EUR_IDL_On_Trade_Account' => 'EUR_IDL_On_Trade_Template_Criteria'
    };

    @IsTest
    private static void getAvailableObjectRecordTypesTest() {
        Test.startTest();
        EUR_CRM_RecordTypeHelper_v2.getAvailableObjectRecordTypes('EUR_CRM_Account__c');
        Test.stopTest();
    }

    @IsTest
    private static void getObjectRtsTest() {
        Test.startTest();
        EUR_CRM_RecordTypeHelper_v2.getObjectRts(null);
        new EUR_CRM_RecordTypeHelper_v2().getObjectRts(Schema.SObjectType.EUR_CRM_Account__c.getSObjectType());
        Test.stopTest();
    }

    @IsTest
    private static void getObjectRtzTest() {
        Test.startTest();
        new EUR_CRM_RecordTypeHelper_v2().getObjectRtz('EUR_CRM_Account__c');
        Test.stopTest();
    }

    @IsTest
    private static void isValidRTTest() {
        Test.startTest();
        new EUR_CRM_RecordTypeHelper_v2().isValidRT('EUR_CRM_Account__c',  'FakeRTDevName');
        new EUR_CRM_RecordTypeHelper_v2().isValidRT('EUR_CRM_Account__c',  'EUR_AO_Distributor');
        Test.stopTest();
    }

    @IsTest
    private static void getRTByDevNameTest() {
        Test.startTest();
        EUR_CRM_RecordTypeHelper_v2.getRTByDevName('EUR_CRM_Account__c',  'FakeRTDevName');
        EUR_CRM_RecordTypeHelper_v2.getRTByDevName('EUR_CRM_Account__c',  'EUR_AO_Distributor');
        Test.stopTest();
    }

    @IsTest
    private static void getRTByDevNamezTest() {
        Test.startTest();
        new EUR_CRM_RecordTypeHelper_v2().getRTByDevNamez('EUR_CRM_Account__c',  'FakeRTDevName');
        new EUR_CRM_RecordTypeHelper_v2().getRTByDevNamez('EUR_CRM_Account__c',  'EUR_AO_Distributor');
        Test.stopTest();
    }

    @IsTest
    private static void getSimilarRTsbyDevNameTest() {
        Test.startTest();
        new EUR_CRM_RecordTypeHelper_v2().getSimilarRTsbyDevName(Schema.SObjectType.EUR_CRM_Account__c.getSObjectType(),  'FakeRTDevName');
        new EUR_CRM_RecordTypeHelper_v2().getSimilarRTsbyDevName(Schema.SObjectType.EUR_CRM_Account__c.getSObjectType(),  'EUR_AO_Distributor');
        new EUR_CRM_RecordTypeHelper_v2().getSimilarRTsbyDevName('EUR_CRM_Account__c',  'FakeRTDevName');
        new EUR_CRM_RecordTypeHelper_v2().getSimilarRTsbyDevName('EUR_CRM_Account__c',  'EUR_AO_Distributor');
        Test.stopTest();
    }

    @IsTest
    private static void getFlippedRTByIdTest() {
        Id rtId = EUR_CRM_RecordTypeHelper_v2.getRTByDevName('EUR_CRM_Account__c',  'EUR_AO_Distributor');
        Test.startTest();
        new EUR_CRM_RecordTypeHelper_v2().getFlippedRTById(Schema.SObjectType.EUR_CRM_Account__c.getSObjectType(), rtId, 'bla', '_');
        new EUR_CRM_RecordTypeHelper_v2().getFlippedRTById('EUR_CRM_Account__c', rtId, 'bla', '_');
        Test.stopTest();
    }

    @IsTest
    private static void getRTsByDevNamesTest() {
        Test.startTest();
        new EUR_CRM_RecordTypeHelper_v2().getRTsByDevNames(Schema.SObjectType.EUR_CRM_Account__c.getSObjectType(), new List<String> { 'EUR_AO_Distributor' });
        Test.stopTest();
    }

    @IsTest
    private static void getRTNameByIdTest() {
        Id rtId = EUR_CRM_RecordTypeHelper_v2.getRTByDevName('EUR_CRM_Account__c',  'EUR_AO_Distributor');
        Test.startTest();
        new EUR_CRM_RecordTypeHelper_v2().getRTNameById(Schema.SObjectType.EUR_CRM_Account__c.getSObjectType(), rtId);
        new EUR_CRM_RecordTypeHelper_v2().getRTNameById('EUR_CRM_Account__c', rtId);
        Test.stopTest();
    }

    @IsTest
    private static void getValidRTByCurrentObjRTTest() {
        EUR_CRM_RecordTypeHelper_v2.rtMapsForTest = makeRtMaps();
        Test.startTest();
        EUR_CRM_RecordTypeHelper_v2.getSettingsMap('EUR_CRM_PRS_ListingTplAssignmentHandler', 'TEMPLATE_CRITERIA_RT_BY_ACCOUNT_RT');
        Test.stopTest();
    }

    @IsTest
    private static void getValidRTsForSpecifClassAndVarNameTest() {
        EUR_CRM_RecordTypeHelper_v2.rtListsForTest.add(makeRtList('EUR_DE_On_Trade, EUR_BG_Off_Trade'));
        Test.startTest();
        EUR_CRM_RecordTypeHelper_v2.getSettingsSet('EUR_CRM_AccountTerrAssignmentService', 'variableName');
        Test.stopTest();
    }


    /* ========================================================= */
    /*      Makers
    /* ========================================================= */
    private static List<EUR_CRM_Record_Type_Map__mdt> makeRtMaps() {
        List<EUR_CRM_Record_Type_Map__mdt> rtMappingMaps = new List<EUR_CRM_Record_Type_Map__mdt>();
        for (String accRt : TEMPLATE_CRITERIA_RT_BY_ACCOUNT_RT.keySet()) {
            rtMappingMaps.add(makeRtMap(accRt, TEMPLATE_CRITERIA_RT_BY_ACCOUNT_RT.get(accRt)));
        }
        return rtMappingMaps;
    }

    private static EUR_CRM_Record_Type_Map__mdt makeRtMap(String key, String val) {
        return new EUR_CRM_Record_Type_Map__mdt(
            EUR_CRM_Class_name__c =  'EUR_CRM_PRS_ListingTplAssignmentHandler'
            ,   EUR_CRM_Variable_name__c = 'TEMPLATE_CRITERIA_RT_BY_ACCOUNT_RT'
            ,   EUR_CRM_Key__c = key
            ,   EUR_CRM_Value__c = val
            ,   EUR_CRM_Is_Active__c = true
        );
    }

    private static EUR_CRM_Record_Type_List__mdt makeRtList(String recordTypes) {
        return new EUR_CRM_Record_Type_List__mdt(
            EUR_CRM_Class_name__c = 'EUR_CRM_AccountTerrAssignmentService'
        ,   EUR_CRM_Variable_name__c = 'variableName'
        ,   EUR_CRM_Valid_Record_Types__c = recordTypes
        ,   EUR_CRM_Is_Active__c = true
        );
    }

}