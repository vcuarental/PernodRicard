/*
Test for EUR_CRM_PRSSegmentationToAccHandler.cls
* */
@IsTest(IsParallel = true)
private class EUR_CRM_Test_PRSSegmentationTrigger {

    private static final Map<String, Set<String>> ACC_RTS_BY_SEGMENTATION_RT_TO_UPDATE_PRIORITY_LEVEL_CRITERIA_TEST = new Map<String, Set<String>>{
		'EUR_PRS_Segmentation_Off_Trade' => new Set<String>{ 'EUR_BE_Off_Trade' }
	};

    //EUR_CRM_PRS_Seg_Aspect__c RTs
    private static final String EUR_BE_PRS_SEGMENTATION_ASPECT_BBP = 'EUR_BE_PRS_Segmentation_Aspect_BBP';
    private static final String EUR_BE_PRS_SEGMENTATION_ASPECT_BP = 'EUR_BE_PRS_Segmentation_Aspect_BP';


    //EUR_CRM_PRS_Priority_Level_Criteria__c RTs
    private static final String EUR_BE_PRS_PRIORITY_LEVEL_CRITERIA = 'EUR_BE_PRS_Priority_Level_Criteria';

    //EUR_CRM_Account__c RTs
    private static final String EUR_BE_OFF_TRADE = 'EUR_BE_Off_Trade';
    private static final String EUR_LV_DIR_ON_TRADE = 'EUR_LV_DIR_ON_Trade';

    //EUR_CRM_PRS_Segmentation__c RTs
    private static final String EUR_PRS_SEGMENTATION_ON_TRADE = 'EUR_PRS_Segmentation_On_Trade';
    private static final String EUR_PRS_SEGMENTATION_OFF_TRADE = 'EUR_PRS_Segmentation_Off_Trade';


    //Test EUR_CRM_PRSSegmentationToAccHandler.updateAccountPros
    @IsTest
    private static void updateSegmentation_PositiveTest() {
        EUR_CRM_Account__c acc = makeAccount(EUR_LV_DIR_ON_TRADE);
        insert acc;

        EUR_CRM_PRS_Group_Outlet_Type__c got = makeGOT();
        insert got;

        EUR_CRM_PRS_Segmentation__c seg = makeSegmentation(acc.Id, EUR_PRS_SEGMENTATION_ON_TRADE);
        Test.startTest();
        insert seg;

        seg.EUR_CRM_PRS_Group_Outlet_Type__c = got.Id;
        update seg;

        delete seg;
        undelete seg;
        Test.stopTest();
    }

    //Test EUR_CRM_PRSSegmentationToAccHandler.checkPrsSegmentationCount
    @IsTest
    private static void checkPrsSegmentationCount_PositiveTest() {
        EUR_CRM_Account__c acc = makeAccount(EUR_LV_DIR_ON_TRADE);
        insert acc;

        EUR_CRM_PRS_Segmentation__c seg1 = makeSegmentation(acc.Id, EUR_PRS_SEGMENTATION_ON_TRADE);

        insert seg1;
        Test.startTest();
        EUR_CRM_PRS_Segmentation__c seg2 = makeSegmentation(acc.Id, EUR_PRS_SEGMENTATION_ON_TRADE);
        try{
            insert seg2;
        } catch(Exception e) {
            System.assertEquals('Account can have only one PRS Segmentation', ApexPages.getMessages()[0].getDetail());
        }
        Test.stopTest();
        List<EUR_CRM_PRS_Segmentation__c> segmentations = selectSegmentations();
        System.debug('\n segmentations.size() => ' + segmentations.size() + '\n');
        System.debug('\n segmentations => ' + JSON.serializePretty(segmentations) + '\n');
        System.assertEquals(1, segmentations.size());
    }

    //Test EUR_CRM_PRSSegmentationToAccHandler.checkPrsSegmentationCount
    @IsTest
    private static void checkPrsSegmentationCount2_PositiveTest() {
        EUR_CRM_Account__c acc = makeAccount(EUR_LV_DIR_ON_TRADE);
        insert acc;

        EUR_CRM_PRS_Segmentation__c seg1 = makeSegmentation(acc.Id, EUR_PRS_SEGMENTATION_ON_TRADE);
        EUR_CRM_PRS_Segmentation__c seg2 = makeSegmentation(acc.Id, EUR_PRS_SEGMENTATION_ON_TRADE);

        Test.startTest();
        try{
            Database.insert(new List<EUR_CRM_PRS_Segmentation__c>{ seg1, seg2 }, false);
        } catch(Exception e) {
            System.assertEquals('Account can have only one PRS Segmentation', ApexPages.getMessages()[0].getDetail());
        }
        Test.stopTest();
        List<EUR_CRM_PRS_Segmentation__c> segmentations = selectSegmentations();
        System.debug('\n segmentations.size() => ' + segmentations.size() + '\n');
        System.debug('\n segmentations => ' + JSON.serializePretty(segmentations) + '\n');
        System.assertEquals(1, segmentations.size());
    }

    //Test EUR_CRM_PRSSegmentationToAccHandler.updatePriorityLevelCriteria
    @IsTest
    private static void beforeInsert_updatePriorityLevelCriteria_PositiveTest() {
        EUR_CRM_RecordTypeHelper_v2.rtMultivalueMapsForTest.addAll(
        EUR_CRM_RecordTypeHelper_v2.makeMultivalueMapsForTest(
            'EUR_CRM_PRSSegmentationToAccHandler', 'ACC_RTS_BY_SEGMENTATION_RT_TO_UPDATE_PRIORITY_LEVEL_CRITERIA', ACC_RTS_BY_SEGMENTATION_RT_TO_UPDATE_PRIORITY_LEVEL_CRITERIA_TEST)
        );

        EUR_CRM_Account__c acc = makeAccount(EUR_BE_OFF_TRADE);
        acc.EUR_CRM_Is_PRS_Exist__c = true;
        insert acc;

        EUR_CRM_PRS_Seg_Aspect__c bbp = makeSegAspect(EUR_BE_PRS_SEGMENTATION_ASPECT_BBP);
        EUR_CRM_PRS_Seg_Aspect__c bp = makeSegAspect(EUR_BE_PRS_SEGMENTATION_ASPECT_BP);
        insert new List<EUR_CRM_PRS_Seg_Aspect__c>{ bbp, bp };

        EUR_CRM_PRS_Priority_Level_Criteria__c plc = makePLC(EUR_BE_PRS_PRIORITY_LEVEL_CRITERIA);
        plc.EUR_CRM_Brand_Building_Potential__c = bbp.Id;
        plc.EUR_CRM_Business_Potential__c = bp.Id;
        insert plc;

        List<EUR_CRM_PRS_Segmentation__c> segmsBefore = selectSegmentations();
        System.assertEquals(0, segmsBefore.size());

        Test.startTest();
        EUR_CRM_PRS_Segmentation__c segm = makeSegmentation(acc.Id, EUR_PRS_SEGMENTATION_OFF_TRADE);
        segm.EUR_CRM_Brand_Building_Potential__c = bbp.Id;
        segm.EUR_CRM_Business_Potential__c = bp.Id;
        insert segm;
        Test.stopTest();

        List<EUR_CRM_PRS_Segmentation__c> segmsAfter = selectSegmentations();
        System.assertEquals(1, segmsAfter.size());
        System.assertEquals(plc.Id, segmsAfter[0].EUR_CRM_PRS_Priority_Level_Criteria__c);
    }

    @IsTest
    private static void beforeInsert_updatePriorityLevelCriteria_NegativeTest_1() {
        EUR_CRM_RecordTypeHelper_v2.rtMultivalueMapsForTest.addAll(
            EUR_CRM_RecordTypeHelper_v2.makeMultivalueMapsForTest(
                'EUR_CRM_PRSSegmentationToAccHandler', 'ACC_RTS_BY_SEGMENTATION_RT_TO_UPDATE_PRIORITY_LEVEL_CRITERIA', ACC_RTS_BY_SEGMENTATION_RT_TO_UPDATE_PRIORITY_LEVEL_CRITERIA_TEST)
        );

        EUR_CRM_Account__c acc = makeAccount(EUR_BE_OFF_TRADE);
        acc.EUR_CRM_Is_PRS_Exist__c = true;
        insert acc;

        EUR_CRM_PRS_Seg_Aspect__c bbp = makeSegAspect(EUR_BE_PRS_SEGMENTATION_ASPECT_BBP);
        EUR_CRM_PRS_Seg_Aspect__c bp = makeSegAspect(EUR_BE_PRS_SEGMENTATION_ASPECT_BP);
        insert new List<EUR_CRM_PRS_Seg_Aspect__c>{ bbp, bp };

        EUR_CRM_PRS_Priority_Level_Criteria__c plc = makePLC(EUR_BE_PRS_PRIORITY_LEVEL_CRITERIA);
        plc.EUR_CRM_Brand_Building_Potential__c = bbp.Id;
        plc.EUR_CRM_Business_Potential__c = bp.Id;
        insert plc;

        List<EUR_CRM_PRS_Segmentation__c> segmsBefore = selectSegmentations();
        System.assertEquals(0, segmsBefore.size());

        Test.startTest();
        EUR_CRM_PRS_Segmentation__c segm = makeSegmentation(acc.Id, EUR_PRS_SEGMENTATION_OFF_TRADE);
//        segm.EUR_CRM_Brand_Building_Potential__c = bbp.Id;
        segm.EUR_CRM_Business_Potential__c = bp.Id;
        insert segm;
        Test.stopTest();

        List<EUR_CRM_PRS_Segmentation__c> segmsAfter = selectSegmentations();
        System.assertEquals(1, segmsAfter.size());
        System.assertEquals(null, segmsAfter[0].EUR_CRM_PRS_Priority_Level_Criteria__c);
    }

    @IsTest
    private static void beforeInsert_updatePriorityLevelCriteria_NegativeTest_2() {
//        EUR_CRM_RecordTypeHelper_v2.rtMultivalueMapsForTest.addAll(
//            EUR_CRM_RecordTypeHelper_v2.makeMultivalueMapsForTest(
//                'EUR_CRM_PRSSegmentationToAccHandler', 'ACC_RTS_BY_SEGMENTATION_RT_TO_UPDATE_PRIORITY_LEVEL_CRITERIA', ACC_RTS_BY_SEGMENTATION_RT_TO_UPDATE_PRIORITY_LEVEL_CRITERIA_TEST)
//        );

        EUR_CRM_Account__c acc = makeAccount(EUR_BE_OFF_TRADE);
        acc.EUR_CRM_Is_PRS_Exist__c = true;
        insert acc;

        EUR_CRM_PRS_Seg_Aspect__c bbp = makeSegAspect(EUR_BE_PRS_SEGMENTATION_ASPECT_BBP);
        EUR_CRM_PRS_Seg_Aspect__c bp = makeSegAspect(EUR_BE_PRS_SEGMENTATION_ASPECT_BP);
        insert new List<EUR_CRM_PRS_Seg_Aspect__c>{ bbp, bp };

        EUR_CRM_PRS_Priority_Level_Criteria__c plc = makePLC(EUR_BE_PRS_PRIORITY_LEVEL_CRITERIA);
        plc.EUR_CRM_Brand_Building_Potential__c = bbp.Id;
        plc.EUR_CRM_Business_Potential__c = bp.Id;
        insert plc;

        List<EUR_CRM_PRS_Segmentation__c> segmsBefore = selectSegmentations();
        System.assertEquals(0, segmsBefore.size());

        Test.startTest();
        EUR_CRM_PRS_Segmentation__c segm = makeSegmentation(acc.Id, EUR_PRS_SEGMENTATION_OFF_TRADE);
        segm.EUR_CRM_Brand_Building_Potential__c = bbp.Id;
        segm.EUR_CRM_Business_Potential__c = bp.Id;
        insert segm;
        Test.stopTest();

        List<EUR_CRM_PRS_Segmentation__c> segmsAfter = selectSegmentations();
        System.assertEquals(1, segmsAfter.size());
        System.assertEquals(null, segmsAfter[0].EUR_CRM_PRS_Priority_Level_Criteria__c);
    }

    @IsTest
    private static void beforeUpdate_updatePriorityLevelCriteria_PositiveTest() {
        EUR_CRM_RecordTypeHelper_v2.rtMultivalueMapsForTest.addAll(
            EUR_CRM_RecordTypeHelper_v2.makeMultivalueMapsForTest(
                'EUR_CRM_PRSSegmentationToAccHandler', 'ACC_RTS_BY_SEGMENTATION_RT_TO_UPDATE_PRIORITY_LEVEL_CRITERIA', ACC_RTS_BY_SEGMENTATION_RT_TO_UPDATE_PRIORITY_LEVEL_CRITERIA_TEST)
        );

        EUR_CRM_Account__c acc = makeAccount(EUR_BE_OFF_TRADE);
        acc.EUR_CRM_Is_PRS_Exist__c = true;
        insert acc;

        EUR_CRM_PRS_Seg_Aspect__c bbp = makeSegAspect(EUR_BE_PRS_SEGMENTATION_ASPECT_BBP);
        EUR_CRM_PRS_Seg_Aspect__c bp = makeSegAspect(EUR_BE_PRS_SEGMENTATION_ASPECT_BP);
        insert new List<EUR_CRM_PRS_Seg_Aspect__c>{ bbp, bp };

        EUR_CRM_PRS_Priority_Level_Criteria__c plc = makePLC(EUR_BE_PRS_PRIORITY_LEVEL_CRITERIA);
        plc.EUR_CRM_Brand_Building_Potential__c = bbp.Id;
        plc.EUR_CRM_Business_Potential__c = bp.Id;
        insert plc;

        List<EUR_CRM_PRS_Segmentation__c> segmsBefore = selectSegmentations();
        System.assertEquals(0, segmsBefore.size());

        EUR_CRM_PRS_Segmentation__c segm = makeSegmentation(acc.Id, EUR_PRS_SEGMENTATION_OFF_TRADE);
//        segm.EUR_CRM_Brand_Building_Potential__c = bbp.Id;
//        segm.EUR_CRM_Business_Potential__c = bp.Id;
        insert segm;

        List<EUR_CRM_PRS_Segmentation__c> segmsAfterInsert = selectSegmentations();
        System.assertEquals(1, segmsAfterInsert.size());
        System.assertEquals(null, segmsAfterInsert[0].EUR_CRM_PRS_Priority_Level_Criteria__c);

        Test.startTest();
        segmsAfterInsert[0].EUR_CRM_Brand_Building_Potential__c = bbp.Id;
        segmsAfterInsert[0].EUR_CRM_Business_Potential__c = bp.Id;
        update segmsAfterInsert;
        Test.stopTest();

        List<EUR_CRM_PRS_Segmentation__c> segmsAfterUpdate = selectSegmentations();
        System.assertEquals(1, segmsAfterUpdate.size());
        System.assertEquals(plc.Id, segmsAfterUpdate[0].EUR_CRM_PRS_Priority_Level_Criteria__c);
    }

    @IsTest
    private static void beforeUpdate_updatePriorityLevelCriteria_NegativeTest_1() {
        EUR_CRM_RecordTypeHelper_v2.rtMultivalueMapsForTest.addAll(
            EUR_CRM_RecordTypeHelper_v2.makeMultivalueMapsForTest(
                'EUR_CRM_PRSSegmentationToAccHandler', 'ACC_RTS_BY_SEGMENTATION_RT_TO_UPDATE_PRIORITY_LEVEL_CRITERIA', ACC_RTS_BY_SEGMENTATION_RT_TO_UPDATE_PRIORITY_LEVEL_CRITERIA_TEST)
        );

        EUR_CRM_Account__c acc = makeAccount(EUR_BE_OFF_TRADE);
        acc.EUR_CRM_Is_PRS_Exist__c = true;
        insert acc;

        EUR_CRM_PRS_Seg_Aspect__c bbp = makeSegAspect(EUR_BE_PRS_SEGMENTATION_ASPECT_BBP);
        EUR_CRM_PRS_Seg_Aspect__c bp = makeSegAspect(EUR_BE_PRS_SEGMENTATION_ASPECT_BP);
        insert new List<EUR_CRM_PRS_Seg_Aspect__c>{ bbp, bp };

        EUR_CRM_PRS_Priority_Level_Criteria__c plc = makePLC(EUR_BE_PRS_PRIORITY_LEVEL_CRITERIA);
        plc.EUR_CRM_Brand_Building_Potential__c = bbp.Id;
        plc.EUR_CRM_Business_Potential__c = bp.Id;
        insert plc;

        List<EUR_CRM_PRS_Segmentation__c> segmsBefore = selectSegmentations();
        System.assertEquals(0, segmsBefore.size());

        EUR_CRM_PRS_Segmentation__c segm = makeSegmentation(acc.Id, EUR_PRS_SEGMENTATION_OFF_TRADE);
//        segm.EUR_CRM_Brand_Building_Potential__c = bbp.Id;
//        segm.EUR_CRM_Business_Potential__c = bp.Id;
        insert segm;

        List<EUR_CRM_PRS_Segmentation__c> segmsAfterInsert = selectSegmentations();
        System.assertEquals(1, segmsAfterInsert.size());
        System.assertEquals(null, segmsAfterInsert[0].EUR_CRM_PRS_Priority_Level_Criteria__c);

        Test.startTest();
        segmsAfterInsert[0].EUR_CRM_Brand_Building_Potential__c = bbp.Id;
//        segmsAfterInsert[0].EUR_CRM_Business_Potential__c = bp.Id;
        update segmsAfterInsert;
        Test.stopTest();

        List<EUR_CRM_PRS_Segmentation__c> segmsAfterUpdate = selectSegmentations();
        System.assertEquals(1, segmsAfterUpdate.size());
        System.assertEquals(null, segmsAfterUpdate[0].EUR_CRM_PRS_Priority_Level_Criteria__c);
    }

    @IsTest
    private static void beforeUpdate_updatePriorityLevelCriteria_NegativeTest_2() {
//        EUR_CRM_RecordTypeHelper_v2.rtMultivalueMapsForTest.addAll(
//            EUR_CRM_RecordTypeHelper_v2.makeMultivalueMapsForTest(
//                'EUR_CRM_PRSSegmentationToAccHandler', 'ACC_RTS_BY_SEGMENTATION_RT_TO_UPDATE_PRIORITY_LEVEL_CRITERIA', ACC_RTS_BY_SEGMENTATION_RT_TO_UPDATE_PRIORITY_LEVEL_CRITERIA_TEST)
//        );

        EUR_CRM_Account__c acc = makeAccount(EUR_BE_OFF_TRADE);
        acc.EUR_CRM_Is_PRS_Exist__c = true;
        insert acc;

        EUR_CRM_PRS_Seg_Aspect__c bbp = makeSegAspect(EUR_BE_PRS_SEGMENTATION_ASPECT_BBP);
        EUR_CRM_PRS_Seg_Aspect__c bp = makeSegAspect(EUR_BE_PRS_SEGMENTATION_ASPECT_BP);
        insert new List<EUR_CRM_PRS_Seg_Aspect__c>{ bbp, bp };

        EUR_CRM_PRS_Priority_Level_Criteria__c plc = makePLC(EUR_BE_PRS_PRIORITY_LEVEL_CRITERIA);
        plc.EUR_CRM_Brand_Building_Potential__c = bbp.Id;
        plc.EUR_CRM_Business_Potential__c = bp.Id;
        insert plc;

        List<EUR_CRM_PRS_Segmentation__c> segmsBefore = selectSegmentations();
        System.assertEquals(0, segmsBefore.size());

        EUR_CRM_PRS_Segmentation__c segm = makeSegmentation(acc.Id, EUR_PRS_SEGMENTATION_OFF_TRADE);
//        segm.EUR_CRM_Brand_Building_Potential__c = bbp.Id;
//        segm.EUR_CRM_Business_Potential__c = bp.Id;
        insert segm;

        List<EUR_CRM_PRS_Segmentation__c> segmsAfterInsert = selectSegmentations();
        System.assertEquals(1, segmsAfterInsert.size());
        System.assertEquals(null, segmsAfterInsert[0].EUR_CRM_PRS_Priority_Level_Criteria__c);

        Test.startTest();
        segmsAfterInsert[0].EUR_CRM_Brand_Building_Potential__c = bbp.Id;
        segmsAfterInsert[0].EUR_CRM_Business_Potential__c = bp.Id;
        update segmsAfterInsert;
        Test.stopTest();

        List<EUR_CRM_PRS_Segmentation__c> segmsAfterUpdate = selectSegmentations();
        System.assertEquals(1, segmsAfterUpdate.size());
        System.assertEquals(null, segmsAfterUpdate[0].EUR_CRM_PRS_Priority_Level_Criteria__c);
    }



    //Makers
    private static EUR_CRM_Account__c makeAccount(String rt) {
        Id rtId = Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
        return new EUR_CRM_Account__c(
            EUR_CRM_Postal_Code__c = '1122'
            ,   RecordTypeId = rtId
            ,   EUR_CRM_Channel__c = 'ON TRADE'
        );
    }

    private static EUR_CRM_PRS_Segmentation__c makeSegmentation(Id accId, String rt) {
        Id rtId = Schema.SObjectType.EUR_CRM_PRS_Segmentation__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
        return new EUR_CRM_PRS_Segmentation__c(
            EUR_CRM_Account__c = accId
        ,   RecordTypeId = rtId
        );
    }

    private static EUR_CRM_PRS_Group_Outlet_Type__c makeGOT() {
        return new EUR_CRM_PRS_Group_Outlet_Type__c();
    }

    private static EUR_CRM_PRS_Priority_Level_Criteria__c makePLC(String rt) {
        Id rtId = Schema.SObjectType.EUR_CRM_PRS_Priority_Level_Criteria__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
        return new EUR_CRM_PRS_Priority_Level_Criteria__c(
            RecordTypeId = rtId
        );
    }

    private static EUR_CRM_PRS_Seg_Aspect__c makeSegAspect(String rt) {
        Id rtId = Schema.SObjectType.EUR_CRM_PRS_Seg_Aspect__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
        return new EUR_CRM_PRS_Seg_Aspect__c(
            RecordTypeId = rtId
        );
    }



    //Selectors
    private static List<EUR_CRM_PRS_Segmentation__c> selectSegmentations() {
        return [
            SELECT Id
            ,   EUR_CRM_PRS_Priority_Level_Criteria__c
            FROM EUR_CRM_PRS_Segmentation__c];
    }

    private static List<EUR_CRM_Account__c> selectAccounts() {
        return [
            SELECT Id
            ,    (SELECT Id FROM EUR_CRM_PRS_Segmentation__r)
            FROM EUR_CRM_Account__c
        ];
    }

    private static List<EUR_CRM_PRS_Priority_Level_Criteria__c> selectPLCs() {
        return [
            SELECT Id
            ,	EUR_CRM_Brand_Building_Potential__c
            ,   EUR_CRM_Business_Potential__c
            ,   EUR_CRM_Brand_Building_Potential_Name__c
            ,   EUR_CRM_Business_Potential_Name__c
            ,   EUR_CRM_Country_Code__c
            ,   EUR_CRM_Priority_Level__c
            FROM EUR_CRM_PRS_Priority_Level_Criteria__c
        ];
    }
}