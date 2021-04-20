/***********************************************************************************
 * Name: EUR_CRM_PRS_ListingTplAssignmentHdlrTest
 * Description: Test Class for EUR_CRM_PRS_ListingTplAssignmentHandler 
 *
 * Version History
 * Date         Developer   			Comments
 * ----------   -------------------  	--------------------------------------------    
 *  5-7-2017  	[Laputa] Kevin Choi  	Created. 
***********************************************************************************/
@IsTest(IsParallel = true)
public class EUR_CRM_PRS_ListingTplAssignmentHdlrTest {
    private static EUR_CRM_PRS_Group_Outlet_Type__c groupOutletType;
    private static EUR_CRM_PRS_Outlet_Type__c outletType;
    private static EUR_CRM_PRS_Seg_Aspect__c imgLevel;
    private static EUR_CRM_PRS_Seg_Aspect__c volPotential;
    private static EUR_CRM_JB_Template__c template;

    private static final Map<String, String> TEMPLATE_CRITERIA_RT_BY_ACCOUNT_RT = new Map<String, String>{
        'EUR_NL_On_Trade' => 'EUR_NL_On_Trade_Template_Criteria',
        'EUR_SE_On_Trade' => 'EUR_SE_On_Trade_Template_Criteria',
        'EUR_SE_Wholesaler' => 'EUR_SE_On_Trade_Template_Criteria',
        'EUR_BE_On_Trade' => 'EUR_BE_On_Trade_Template_Criteria',
        'EUR_IDL_On_Trade_Account' => 'EUR_IDL_On_Trade_Template_Criteria'
    };

    private static void createData() {
        groupOutletType = makeGroupOutletType('Restaurant');
        insert groupOutletType;

        outletType = makeOutletType(groupOutletType.Id, 'Restaurant');
        insert outletType;

        imgLevel = makeSegAspect('EUR_BE_PRS_Segmentation_Aspect_Image_Level');
        imgLevel.EUR_CRM_Segmentation_IL_Aspect_Name__c = 'Iconic';
        insert imgLevel;

        volPotential = makeSegAspect('EUR_BE_PRS_Segmentation_Aspect_Volume_Potential');
        volPotential.EUR_CRM_Segmentation_VP_Aspect_Name__c = 'High';
        insert volPotential;

        template = makeTemplate('EUR_BE_On_Trade_Template');
        Insert template;

        EUR_CRM_JB_Template_Criteria__c tempCriteria = makeTemplateCriteria('EUR_BE_On_Trade_Template_Criteria');
        insert tempCriteria;

//        EUR_CRM_PRS_ListingTplAssignmentHandler.rtMaps.addAll(makeRtMappingMaps());
        EUR_CRM_RecordTypeHelper_v2.rtMapsForTest.addAll(makeRtMappingMaps());
    }

    @IsTest
    private static void onBeforeInsert_positiveTest(){
        createData();

        Test.startTest();
        EUR_CRM_Account__c acc = makeAccount('EUR_BE_On_Trade');
        acc.EUR_CRM_PRS_Group_Outlet_Type__c = groupOutletType.Id;
        acc.EUR_CRM_PRS_Outlet_Type__c = outletType.Id;
        acc.EUR_CRM_PRS_Image_Level__c = imgLevel.Id;
        acc.EUR_CRM_PRS_Volume_Potential__c = volPotential.Id;
        insert acc;
        Test.stopTest();

        List<EUR_CRM_Account__c> insertedAccounts = selectAccounts();
        System.assertEquals(template.Id, insertedAccounts[0].EUR_CRM_Listing_Template__c);
    }

    @IsTest
    private static void onBeforeInsert_negativeTest(){
        createData();

        Test.startTest();
        EUR_CRM_Account__c acc = makeAccount('EUR_BE_On_Trade');
        acc.EUR_CRM_PRS_Group_Outlet_Type__c = groupOutletType.id;
        acc.EUR_CRM_PRS_Outlet_Type__c = null;
        acc.EUR_CRM_PRS_Image_Level__c = imgLevel.id;
        acc.EUR_CRM_PRS_Volume_Potential__c = volPotential.id;
        acc.EUR_CRM_Delivery_Type__c = 'Direct';
        insert acc;
        Test.stopTest();

        List<EUR_CRM_Account__c> insertedAccounts = selectAccounts();
        System.assertEquals(null, insertedAccounts[0].EUR_CRM_Listing_Template__c);

    }

    @IsTest
    private static void onBeforeUpdate_positiveTest(){
        createData();

        EUR_CRM_Account__c acc = makeAccount('EUR_BE_On_Trade');
        insert acc;

        Test.startTest();
        List<EUR_CRM_Account__c> insertedAccounts = selectAccounts();
        insertedAccounts[0].EUR_CRM_PRS_Group_Outlet_Type__c = groupOutletType.Id;
        insertedAccounts[0].EUR_CRM_PRS_Outlet_Type__c = outletType.Id;
        insertedAccounts[0].EUR_CRM_PRS_Image_Level__c = imgLevel.Id;
        insertedAccounts[0].EUR_CRM_PRS_Volume_Potential__c = volPotential.Id;
        update insertedAccounts;
        Test.stopTest();

        List<EUR_CRM_Account__c> updatedAccounts = selectAccounts();
        System.assertEquals(template.Id, updatedAccounts[0].EUR_CRM_Listing_Template__c);
    }

    @IsTest
    private static void onBeforeUpdate_negativeTest(){
        createData();

        EUR_CRM_Account__c acc = makeAccount('EUR_BE_On_Trade');
        insert acc;

        Test.startTest();
        List<EUR_CRM_Account__c> insertedAccounts = selectAccounts();
        insertedAccounts[0].EUR_CRM_PRS_Group_Outlet_Type__c = groupOutletType.Id;
        insertedAccounts[0].EUR_CRM_PRS_Outlet_Type__c = null;
        insertedAccounts[0].EUR_CRM_PRS_Image_Level__c = imgLevel.Id;
        insertedAccounts[0].EUR_CRM_PRS_Volume_Potential__c = volPotential.Id;
        update insertedAccounts;
        Test.stopTest();

        List<EUR_CRM_Account__c> updatedAccounts = selectAccounts();
        System.assertEquals(null, updatedAccounts[0].EUR_CRM_Listing_Template__c);
    }


    /* ========================================================= */
    /*      Makers
    /* ========================================================= */
    private static EUR_CRM_PRS_Group_Outlet_Type__c makeGroupOutletType(String name) {
        return new EUR_CRM_PRS_Group_Outlet_Type__c(EUR_CRM_Name__c = name);
    }

    private static EUR_CRM_PRS_Outlet_Type__c makeOutletType(Id gotId, String name) {
        return new EUR_CRM_PRS_Outlet_Type__c(
            EUR_CRM_PRS_Outlet_Type_Name__c = name,
            EUR_CRM_PRS_Group_Outlet_Type__c = gotId
        );
    }

    private static EUR_CRM_PRS_Seg_Aspect__c makeSegAspect(String rt) {
        Id rtId = Schema.SObjectType.EUR_CRM_PRS_Seg_Aspect__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
        return new EUR_CRM_PRS_Seg_Aspect__c(
            RecordTypeId = rtId
        );
    }

    private static EUR_CRM_JB_Template__c makeTemplate(String rt) {
        Id templRtId = Schema.SObjectType.EUR_CRM_JB_Template__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
        return new EUR_CRM_JB_Template__c(
            Name = 'Test BE Template',
            RecordTypeId = templRtId);
    }

    private static EUR_CRM_JB_Template_Criteria__c makeTemplateCriteria(String rt) {
        Id templateCriteriaRtId = Schema.SObjectType.EUR_CRM_JB_Template_Criteria__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
        EUR_CRM_JB_Template_Criteria__c tempCriteria = new EUR_CRM_JB_Template_Criteria__c(
            EUR_JB_Active__c = true,
            EUR_CRM_PRS_Group_Outlet_Type__c = groupOutletType.Id,
            EUR_CRM_PRS_Outlet_Type__c = outletType.Id,
            EUR_CRM_PRS_Seg_Aspect_IL__c = imgLevel.Id,
            EUR_CRM_PRS_Seg_Aspect_VP__c = volPotential.Id,
            EUR_JB_Template__c = template.Id,
            RecordTypeId = templateCriteriaRtId);
        return tempCriteria;
    }
    private static EUR_CRM_Account__c makeAccount(String rt) {
        Id rtId = Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
        return new EUR_CRM_Account__c(
            RecordTypeId = rtId
        ,   EUR_CRM_Postal_Code__c = '112233'
        );
    }

    private static List<EUR_CRM_Record_Type_Map__mdt> makeRtMappingMaps() {
        List<EUR_CRM_Record_Type_Map__mdt> rtMappingMaps = new List<EUR_CRM_Record_Type_Map__mdt>();
        for (String accRt : TEMPLATE_CRITERIA_RT_BY_ACCOUNT_RT.keySet()) {
            rtMappingMaps.add(makeRtMappingMap(accRt, TEMPLATE_CRITERIA_RT_BY_ACCOUNT_RT.get(accRt)));
        }
        return rtMappingMaps;
    }

    private static EUR_CRM_Record_Type_Map__mdt makeRtMappingMap(String key, String val) {
        return new EUR_CRM_Record_Type_Map__mdt(
            EUR_CRM_Class_name__c =  'EUR_CRM_PRS_ListingTplAssignmentHandler'
        ,   EUR_CRM_Variable_name__c = 'TEMPLATE_CRITERIA_RT_BY_ACCOUNT_RT'
        ,   EUR_CRM_Key__c = key
        ,   EUR_CRM_Value__c = val
        ,   EUR_CRM_Is_Active__c = true
        );
    }


    /* ========================================================= */
    /*      SOQL Selectors
    /* ========================================================= */
    private static List<EUR_CRM_Account__c> selectAccounts() {
        return [
            SELECT Id
            ,   EUR_CRM_Listing_Template__c
            ,   EUR_CRM_PRS_Group_Outlet_Type__c
            ,   EUR_CRM_PRS_Outlet_Type__c
            ,   EUR_CRM_PRS_Image_Level__c
            ,   EUR_CRM_PRS_Volume_Potential__c
            FROM EUR_CRM_Account__c

        ];
    }
}