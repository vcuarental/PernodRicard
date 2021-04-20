@IsTest (IsParallel = true)
private class EUR_CRM_PRSSegAspCriteriaMassUpdtTest {

    private static EUR_CRM_PRS_Segmentation__c segmentation;

    @testSetup
    private static void insertData() {
        Test.startTest();
        EUR_CRM_PRS_Group_Outlet_Type__c groupOutletType = makeGroupOutletType('EUR_NL_PRS_On_Trade_Group_Outlet_Type');
        groupOutletType.EUR_CRM_Name__c = 'NightClub';
        insert groupOutletType;

        EUR_CRM_PRS_Seg_Aspect__c imageLevelSegAspect = makeSegmentationAspect('EUR_NL_PRS_Segmentation_Aspect_Image_Level');
        imageLevelSegAspect.EUR_CRM_Segmentation_IL_Aspect_Name__c = 'Iconic';

        EUR_CRM_PRS_Seg_Aspect__c volumePotentialSegAspect = makeSegmentationAspect('EUR_NL_PRS_Segmentation_Aspect_Volume_Potential');
        volumePotentialSegAspect.EUR_CRM_Segmentation_VP_Aspect_Name__c = 'High';
        insert new List<EUR_CRM_PRS_Seg_Aspect__c>{ imageLevelSegAspect, volumePotentialSegAspect};

        EUR_CRM_PRS_Seg_Aspect_Criteria__c segAspectCriteria1 = makeSegAspectCriteria('EUR_PRS_Segmentation_Aspect_Criteria_Volume_Potential');
        segAspectCriteria1.EUR_CRM_PRS_Group_Outlet_Type__c = groupOutletType.Id;
        segAspectCriteria1.EUR_CRM_Minimum_Weight__c = 50;
        segAspectCriteria1.EUR_CRM_Is_Weight_Changed__c = true;
        segAspectCriteria1.EUR_CRM_Volume_Potential__c = volumePotentialSegAspect.Id;

        EUR_CRM_PRS_Seg_Aspect_Criteria__c segAspectCriteria2 = makeSegAspectCriteria('EUR_PRS_Segmentation_Aspect_Criteria_Volume_Potential');
        segAspectCriteria2.EUR_CRM_PRS_Group_Outlet_Type__c = groupOutletType.Id;
        segAspectCriteria2.EUR_CRM_Minimum_Weight__c = 60;
        segAspectCriteria2.EUR_CRM_Is_Weight_Changed__c = true;
        segAspectCriteria2.EUR_CRM_Volume_Potential__c = volumePotentialSegAspect.Id;

        EUR_CRM_PRS_Seg_Aspect_Criteria__c segAspectCriteria3 = makeSegAspectCriteria('EUR_PRS_Segmentation_Aspect_Criteria_Image_Level');
        segAspectCriteria3.EUR_CRM_PRS_Group_Outlet_Type__c = groupOutletType.Id;
        segAspectCriteria3.EUR_CRM_Minimum_Weight__c = 70;
        segAspectCriteria3.EUR_CRM_Is_Weight_Changed__c = true;
        segAspectCriteria3.EUR_CRM_Image_Level__c = imageLevelSegAspect.Id;

        EUR_CRM_PRS_Seg_Aspect_Criteria__c segAspectCriteria4 = makeSegAspectCriteria('EUR_PRS_Segmentation_Aspect_Criteria_Image_Level');
        segAspectCriteria4.EUR_CRM_PRS_Group_Outlet_Type__c = groupOutletType.Id;
        segAspectCriteria4.EUR_CRM_Minimum_Weight__c = 80;
        segAspectCriteria4.EUR_CRM_Is_Weight_Changed__c = true;
        segAspectCriteria4.EUR_CRM_Image_Level__c = imageLevelSegAspect.Id;
        List<EUR_CRM_PRS_Seg_Aspect_Criteria__c> segAspectCriterias = new List<EUR_CRM_PRS_Seg_Aspect_Criteria__c>{
            segAspectCriteria1, segAspectCriteria2, segAspectCriteria3, segAspectCriteria4
        };
        insert segAspectCriterias;

        EUR_CRM_Account__c account = makeAccount('EUR_NL_On_Trade');
        insert account;
        Test.stopTest();

        segmentation = makeSegmentation('EUR_PRS_Segmentation_On_Trade');
        segmentation.EUR_CRM_Account__c = account.Id;
        segmentation.EUR_CRM_PRS_Group_Outlet_Type__c = groupOutletType.Id;
        insert segmentation;

        EUR_CRM_PRS_Answer__c answer1 = makeAnswer(segmentation.Id, 'EUR_PRS_Answer_Image_Level',40);
        EUR_CRM_PRS_Answer__c answer2 = makeAnswer(segmentation.Id, 'EUR_PRS_Answer_Image_Level',20);
        EUR_CRM_PRS_Answer__c answer3 = makeAnswer(segmentation.Id, 'EUR_PRS_Answer_Image_Level',10);

        EUR_CRM_PRS_Answer__c answer4 = makeAnswer(segmentation.Id, 'EUR_PRS_Answer_Volume_Potential',40);
        EUR_CRM_PRS_Answer__c answer5 = makeAnswer(segmentation.Id, 'EUR_PRS_Answer_Volume_Potential',20);
        EUR_CRM_PRS_Answer__c answer6 = makeAnswer(segmentation.Id, 'EUR_PRS_Answer_Volume_Potential',10);
        insert new List<EUR_CRM_PRS_Answer__c>{ answer1, answer2, answer3, answer4, answer5, answer6 };
    }

    /*===================================================
    *   Image Level Tests
    * ===================================================*/
    @IsTest
    private static void segmentationWithEqualGroupOutletTypeToSegAspectCriteria_PositiveImageLevelTest() {
        EUR_CRM_PRS_Segmentation__c segmentation = getSegmentation();

        Test.startTest();
        EUR_CRM_PRSSegAspCriteriaMassUpdt imgLvlBatch = new EUR_CRM_PRSSegAspCriteriaMassUpdt('NL', 'EUR_CRM_Image_Level__c');
        Database.executeBatch(imgLvlBatch);
        Test.stopTest();

        List<EUR_CRM_PRS_Segmentation__c> updatedSegmentations = selectSegmentation(segmentation.Id);
        List<EUR_CRM_PRS_Seg_Aspect_Criteria__c> segAspectCriterias = selectSegAspectCriteriasWhereRT('%Image_Level');

        for (EUR_CRM_PRS_Seg_Aspect_Criteria__c segAspectCriteria : segAspectCriterias) {
            System.assertEquals(false, segAspectCriteria.EUR_CRM_Is_Weight_Changed__c);
        }
        System.assertEquals(70, updatedSegmentations[0].EUR_CRM_Image_Level_Criteria__r.EUR_CRM_Minimum_Weight__c);
        System.assertEquals('Iconic', updatedSegmentations[0].EUR_CRM_Image_Level__r.EUR_CRM_Segmentation_IL_Aspect_Name__c);
        System.assertEquals(null, updatedSegmentations[0].EUR_CRM_Volume_Potential__c);
    }

    @IsTest
    private static void segmentationWithoutEqualGroupOutletTypeToSegAspectCriteria_NegativeImageLevelTest() {
        EUR_CRM_PRS_Segmentation__c segmentation = getSegmentation();

        EUR_CRM_PRS_Group_Outlet_Type__c groupOutletType = makeGroupOutletType('EUR_NL_PRS_On_Trade_Group_Outlet_Type');
        groupOutletType.EUR_CRM_Name__c = 'Restaurant';
        insert groupOutletType;

        segmentation.EUR_CRM_PRS_Group_Outlet_Type__c = groupOutletType.Id;
        update segmentation;

        Test.startTest();
        EUR_CRM_PRSSegAspCriteriaMassUpdt imgLvlBatch = new EUR_CRM_PRSSegAspCriteriaMassUpdt('NL', 'EUR_CRM_Image_Level__c');
        Database.executeBatch(imgLvlBatch);
        Test.stopTest();

        List<EUR_CRM_PRS_Segmentation__c> updatedSegmentations = selectSegmentation(segmentation.Id);
        List<EUR_CRM_PRS_Seg_Aspect_Criteria__c> segAspectCriterias = selectSegAspectCriteriasWhereRT('%Image_Level');

        for (EUR_CRM_PRS_Seg_Aspect_Criteria__c segAspectCriteria : segAspectCriterias) {
            System.assertEquals(true, segAspectCriteria.EUR_CRM_Is_Weight_Changed__c);
        }
        System.assertEquals(null, updatedSegmentations[0].EUR_CRM_Image_Level__c);
        System.assertEquals(null, updatedSegmentations[0].EUR_CRM_Volume_Potential__c);
    }

    @IsTest
    private static void segmentationWithGroupOutletTypeAndWithoutSegAspectCriteria_NegativeImageLevelTest() {
        EUR_CRM_PRS_Segmentation__c segmentation = getSegmentation();

        delete selectSegAspectCriteriasWhereRT('%Image_Level');

        Test.startTest();
        EUR_CRM_PRSSegAspCriteriaMassUpdt imgLvlBatch = new EUR_CRM_PRSSegAspCriteriaMassUpdt('NL', 'EUR_CRM_Image_Level__c');
        Database.executeBatch(imgLvlBatch);
        Test.stopTest();

        List<EUR_CRM_PRS_Segmentation__c> updatedSegmentations = selectSegmentation(segmentation.Id);
        List<EUR_CRM_PRS_Seg_Aspect_Criteria__c> segAspectCriterias = selectSegAspectCriteriasWhereRT('%Image_Level');

        for (EUR_CRM_PRS_Seg_Aspect_Criteria__c segAspectCriteria : segAspectCriterias) {
            System.assertEquals(true, segAspectCriteria.EUR_CRM_Is_Weight_Changed__c);
        }
        System.assertEquals(null, updatedSegmentations[0].EUR_CRM_Image_Level__c);
        System.assertEquals(null, updatedSegmentations[0].EUR_CRM_Volume_Potential__c);
    }


    /*===================================================
    *   Volume Potential Tests
    * ===================================================*/
    @IsTest
    private static void segmentationWithEqualGroupOutletTypeToSegAspectCriteria_PositiveVolumePotentialTest() {
        EUR_CRM_PRS_Segmentation__c segmentation = getSegmentation();

        Test.startTest();
        EUR_CRM_PRSSegAspCriteriaMassUpdt imgLvlBatch = new EUR_CRM_PRSSegAspCriteriaMassUpdt('NL', 'EUR_CRM_Volume_Potential__c');
        Database.executeBatch(imgLvlBatch);
        Test.stopTest();

        List<EUR_CRM_PRS_Segmentation__c> updatedSegmentations = selectSegmentation(segmentation.Id);
        List<EUR_CRM_PRS_Seg_Aspect_Criteria__c> segAspectCriterias = selectSegAspectCriteriasWhereRT('%Volume_Potential');

        for (EUR_CRM_PRS_Seg_Aspect_Criteria__c segAspectCriteria : segAspectCriterias) {
            System.assertEquals(false, segAspectCriteria.EUR_CRM_Is_Weight_Changed__c);
        }
        System.assertEquals(60, updatedSegmentations[0].EUR_CRM_Volume_Potential_Criteria__r.EUR_CRM_Minimum_Weight__c);
        System.assertEquals('High', updatedSegmentations[0].EUR_CRM_Volume_Potential__r.EUR_CRM_Segmentation_VP_Aspect_Name__c);
        System.assertEquals(null, updatedSegmentations[0].EUR_CRM_Image_Level__c);
    }

    @IsTest
    private static void segmentationWithoutEqualGroupOutletTypeToSegAspectCriteria_NegativeVolumePotentialTest() {
        EUR_CRM_PRS_Segmentation__c segmentation = getSegmentation();

        EUR_CRM_PRS_Group_Outlet_Type__c groupOutletType = makeGroupOutletType('EUR_NL_PRS_On_Trade_Group_Outlet_Type');
        groupOutletType.EUR_CRM_Name__c = 'Restaurant';
        insert groupOutletType;

        segmentation.EUR_CRM_PRS_Group_Outlet_Type__c = groupOutletType.Id;
        update segmentation;

        Test.startTest();
        EUR_CRM_PRSSegAspCriteriaMassUpdt imgLvlBatch = new EUR_CRM_PRSSegAspCriteriaMassUpdt('NL', 'EUR_CRM_Volume_Potential__c');
        Database.executeBatch(imgLvlBatch);
        Test.stopTest();

        List<EUR_CRM_PRS_Segmentation__c> updatedSegmentations = selectSegmentation(segmentation.Id);
        List<EUR_CRM_PRS_Seg_Aspect_Criteria__c> segAspectCriterias = selectSegAspectCriteriasWhereRT('%Volume_Potential');

        for (EUR_CRM_PRS_Seg_Aspect_Criteria__c segAspectCriteria : segAspectCriterias) {
            System.assertEquals(true, segAspectCriteria.EUR_CRM_Is_Weight_Changed__c);
        }
        System.assertEquals(null, updatedSegmentations[0].EUR_CRM_Image_Level__c);
        System.assertEquals(null, updatedSegmentations[0].EUR_CRM_Volume_Potential__c);

    }

    @IsTest
    private static void segmentationWithGroupOutletTypeAndWithoutSegAspectCriteria_NegativeVolumePotentialTest() {
        EUR_CRM_PRS_Segmentation__c segmentation = getSegmentation();

        delete selectSegAspectCriteriasWhereRT('%Volume_Potential');

        Test.startTest();
        EUR_CRM_PRSSegAspCriteriaMassUpdt imgLvlBatch = new EUR_CRM_PRSSegAspCriteriaMassUpdt('NL', 'EUR_CRM_Volume_Potential__c');
        Database.executeBatch(imgLvlBatch);
        Test.stopTest();

        List<EUR_CRM_PRS_Segmentation__c> notUpdatedSegmentations = selectSegmentation(segmentation.Id);
        List<EUR_CRM_PRS_Seg_Aspect_Criteria__c> segAspectCriterias = selectSegAspectCriteriasWhereRT('%Volume_Potential');

        System.assert(segAspectCriterias.isEmpty());
        System.assertEquals(null, notUpdatedSegmentations[0].EUR_CRM_Image_Level__c);
        System.assertEquals(null, notUpdatedSegmentations[0].EUR_CRM_Volume_Potential__c);
    }

    private static EUR_CRM_PRS_Segmentation__c getSegmentation() {
        return [SELECT Id, EUR_CRM_Account__c, EUR_CRM_PRS_Group_Outlet_Type__c FROM EUR_CRM_PRS_Segmentation__c WHERE EUR_CRM_PRS_Group_Outlet_Type__c != null LIMIT 1];
    }

    /*===================================================
    *   Makers
    * ===================================================*/
    private static EUR_CRM_Account__c makeAccount(String rtDevName) {
        Id recTypeId = Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get(rtDevName).getRecordTypeId();
        return new EUR_CRM_Account__c(
                RecordTypeId = recTypeId
            ,   Name = 'Test Account'
            ,   EUR_CRM_Postal_Code__c = '00000'
        );
    }

    private static EUR_CRM_PRS_Group_Outlet_Type__c makeGroupOutletType(String rtDevName) {
        Id recTypeId = Schema.SObjectType.EUR_CRM_PRS_Group_Outlet_Type__c.getRecordTypeInfosByDeveloperName().get(rtDevName).getRecordTypeId();
        return new EUR_CRM_PRS_Group_Outlet_Type__c(
                RecordTypeId = recTypeId
        );
    }

    private static EUR_CRM_PRS_Seg_Aspect__c makeSegmentationAspect(String rtDevName) {
        Id recTypeId = Schema.SObjectType.EUR_CRM_PRS_Seg_Aspect__c.getRecordTypeInfosByDeveloperName().get(rtDevName).getRecordTypeId();
        return new EUR_CRM_PRS_Seg_Aspect__c(
            RecordTypeId = recTypeId
        );
    }

    private static EUR_CRM_PRS_Seg_Aspect_Criteria__c makeSegAspectCriteria(String rtDevName) {
        Id recTypeId = Schema.SObjectType.EUR_CRM_PRS_Seg_Aspect_Criteria__c.getRecordTypeInfosByDeveloperName().get(rtDevName).getRecordTypeId();
        return new EUR_CRM_PRS_Seg_Aspect_Criteria__c(
            RecordTypeId = recTypeId
        );
    }

    private static EUR_CRM_PRS_Segmentation__c makeSegmentation(String rtDevName) {
        Id recTypeId = Schema.SObjectType.EUR_CRM_PRS_Segmentation__c.getRecordTypeInfosByDeveloperName().get(rtDevName).getRecordTypeId();
        return new EUR_CRM_PRS_Segmentation__c(
                RecordTypeId = recTypeId
        );
    }

    private static EUR_CRM_PRS_Answer__c makeAnswer(Id prSegmId, String rtDevName, Decimal weight) {
        Id recTypeId = Schema.SObjectType.EUR_CRM_PRS_Answer__c.getRecordTypeInfosByDeveloperName().get(rtDevName).getRecordTypeId();
        return new EUR_CRM_PRS_Answer__c(
                RecordTypeId = recTypeId
            ,   EUR_CRM_PRS_Segmentation__c = prSegmId
            ,   EUR_CRM_Weight__c = weight
        );
    }


    /*===================================================
    *   SOQL Selectors
    * ===================================================*/
    private static List<EUR_CRM_PRS_Segmentation__c> selectSegmentation(Id sId) {
        return [
            SELECT Id
                , EUR_CRM_PRS_ImageLevel_TotalAnswWgt__c
                , EUR_CRM_PRS_Group_Outlet_Type__c
                , EUR_CRM_Image_Level__c
                , EUR_CRM_Image_Level__r.EUR_CRM_Segmentation_IL_Aspect_Name__c
                , EUR_CRM_Volume_Potential__c
                , EUR_CRM_Volume_Potential__r.EUR_CRM_Segmentation_VP_Aspect_Name__c
                , EUR_CRM_Image_Level_Criteria__r.EUR_CRM_Minimum_Weight__c
                , EUR_CRM_Volume_Potential_Criteria__r.EUR_CRM_Minimum_Weight__c
                , EUR_CRM_Volume_Potential_Criteria__r.RecordType.DeveloperName
                , EUR_CRM_Image_Level_Criteria__r.RecordType.DeveloperName
            FROM EUR_CRM_PRS_Segmentation__c
            Where Id = :sId
        ];
    }

    private static List<EUR_CRM_PRS_Seg_Aspect_Criteria__c> selectSegAspectCriteriasWhereRT(String rtDevName) {
        return [
            SELECT Id
                , EUR_CRM_Is_Weight_Changed__c
            FROM EUR_CRM_PRS_Seg_Aspect_Criteria__c
            WHERE RecordType.DeveloperName LIKE :rtDevName
        ];
    }
}