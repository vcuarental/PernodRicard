@IsTest (IsParallel = true)
private class EUR_CRM_ObjectiveCalcAchieveServiceTest {

    
    /* ========================================================= */
    /*     Insert Single Record
    /* ========================================================= */
    @IsTest
    private static void createSinglePositiveTest() {
        EUR_CRM_GB_Objective__c objective = makeObjective('EUR_AT_Central_Objective', 5, 5);
        insert objective;

        objective = selectObjectives()[0];
        System.assertEquals(true, objective.EUR_CRM_Achieved__c);
    }

    @IsTest
    private static void createSingleAnotherRecordTypeNegativeTest() {
        EUR_CRM_GB_Objective__c objective = makeObjective('EUR_AT_Personal_Objective', 5, 5);
        insert objective;

        objective = selectObjectives()[0];
        System.assertEquals(false, objective.EUR_CRM_Achieved__c);
    }

    @IsTest
    private static void createSingleNotAllAchievementAreReachedNegativeTest() {
        EUR_CRM_GB_Objective__c objective = makeObjective('EUR_AT_Central_Objective', 5, 3);
        insert objective;

        objective = selectObjectives()[0];
        System.assertEquals(false, objective.EUR_CRM_Achieved__c);
    }


    /* ========================================================= */
    /*     Update Single Record
    /* ========================================================= */
    @IsTest
    private static void updateSingle_from_NullOfNull_to_5of5_PositiveTest() {
        EUR_CRM_GB_Objective__c objective = makeObjective('EUR_AT_Central_Objective', null, null);
        insert objective;

        objective = selectObjectives()[0];
        System.assertEquals(false, objective.EUR_CRM_Achieved__c);

        objective.EUR_CRM_Target_Number_of_Actions__c = 5;
        objective.EUR_CRM_Achieved_Number_of_Actions__c = 5;
        update objective;

        objective = selectObjectives()[0];
        System.assertEquals(true, objective.EUR_CRM_Achieved__c);
    }

    @IsTest
    private static void updateSingle_from_NullOfNull_to_3of5_PositiveTest() {
        EUR_CRM_GB_Objective__c objective = makeObjective('EUR_AT_Central_Objective', null, null);
        insert objective;

        objective = selectObjectives()[0];
        System.assertEquals(false, objective.EUR_CRM_Achieved__c);

        objective.EUR_CRM_Target_Number_of_Actions__c = 5;
        objective.EUR_CRM_Achieved_Number_of_Actions__c = 3;
        update objective;

        objective = selectObjectives()[0];
        System.assertEquals(false, objective.EUR_CRM_Achieved__c);
    }

    @IsTest
    private static void updateSingle_from_NullOfNull_to_nullOf5_PositiveTest() {
        EUR_CRM_GB_Objective__c objective = makeObjective('EUR_AT_Central_Objective', null, null);
        insert objective;

        objective = selectObjectives()[0];
        System.assertEquals(false, objective.EUR_CRM_Achieved__c);

        objective.EUR_CRM_Target_Number_of_Actions__c = 5;
        objective.EUR_CRM_Achieved_Number_of_Actions__c = null;
        update objective;

        objective = selectObjectives()[0];
        System.assertEquals(false, objective.EUR_CRM_Achieved__c);
    }

    @IsTest
    private static void updateSingle_from_NullOfNull_to_5ofNull_PositiveTest() {
        EUR_CRM_GB_Objective__c objective = makeObjective('EUR_AT_Central_Objective', null, null);
        insert objective;

        objective = selectObjectives()[0];
        System.assertEquals(false, objective.EUR_CRM_Achieved__c);

        objective.EUR_CRM_Target_Number_of_Actions__c = null;
        objective.EUR_CRM_Achieved_Number_of_Actions__c = 5;
        update objective;

        objective = selectObjectives()[0];
        System.assertEquals(false, objective.EUR_CRM_Achieved__c);
    }

    @IsTest
    private static void updateSingle_from_NullOf5_to_3of5_PositiveTest() {
        EUR_CRM_GB_Objective__c objective = makeObjective('EUR_AT_Central_Objective', 5, null);
        insert objective;

        objective = selectObjectives()[0];
        System.assertEquals(false, objective.EUR_CRM_Achieved__c);

        objective.EUR_CRM_Target_Number_of_Actions__c = 5;
        objective.EUR_CRM_Achieved_Number_of_Actions__c = 3;
        update objective;

        objective = selectObjectives()[0];
        System.assertEquals(false, objective.EUR_CRM_Achieved__c);
    }

    @IsTest
    private static void updateSingle_from_NullOf5_to_5of5_PositiveTest() {
        EUR_CRM_GB_Objective__c objective = makeObjective('EUR_AT_Central_Objective', 5, null);
        insert objective;

        objective = selectObjectives()[0];
        System.assertEquals(false, objective.EUR_CRM_Achieved__c);

        objective.EUR_CRM_Target_Number_of_Actions__c = 5;
        objective.EUR_CRM_Achieved_Number_of_Actions__c = 5;
        update objective;

        objective = selectObjectives()[0];
        System.assertEquals(true, objective.EUR_CRM_Achieved__c);
    }

    @IsTest
    private static void updateSingle_from_5ofNull_to_3of5_PositiveTest() {
        EUR_CRM_GB_Objective__c objective = makeObjective('EUR_AT_Central_Objective', null, 5);
        insert objective;

        objective = selectObjectives()[0];
        System.assertEquals(false, objective.EUR_CRM_Achieved__c);

        objective.EUR_CRM_Target_Number_of_Actions__c = 5;
        objective.EUR_CRM_Achieved_Number_of_Actions__c = 3;
        update objective;

        objective = selectObjectives()[0];
        System.assertEquals(false, objective.EUR_CRM_Achieved__c);
    }

    @IsTest
    private static void updateSingle_from_5ofNull_to_5of5_PositiveTest() {
        EUR_CRM_GB_Objective__c objective = makeObjective('EUR_AT_Central_Objective', null, 5);
        insert objective;

        objective = selectObjectives()[0];
        System.assertEquals(false, objective.EUR_CRM_Achieved__c);

        objective.EUR_CRM_Target_Number_of_Actions__c = 5;
        objective.EUR_CRM_Achieved_Number_of_Actions__c = 5;
        update objective;

        objective = selectObjectives()[0];
        System.assertEquals(true, objective.EUR_CRM_Achieved__c);
    }

    @IsTest
    private static void updateSingle_from_5of5_to_3of5_PositiveTest() {
        EUR_CRM_GB_Objective__c objective = makeObjective('EUR_AT_Central_Objective', 5, 5);
        insert objective;

        objective = selectObjectives()[0];
        System.assertEquals(true, objective.EUR_CRM_Achieved__c);

        objective.EUR_CRM_Target_Number_of_Actions__c = 5;
        objective.EUR_CRM_Achieved_Number_of_Actions__c = 3;
        update objective;

        objective = selectObjectives()[0];
        System.assertEquals(false, objective.EUR_CRM_Achieved__c);
    }

    @IsTest
    private static void updateSingle_from_5of5_to_3ofNull_PositiveTest() {
        EUR_CRM_GB_Objective__c objective = makeObjective('EUR_AT_Central_Objective', 5, 5);
        insert objective;

        objective = selectObjectives()[0];
        System.assertEquals(true, objective.EUR_CRM_Achieved__c);

        objective.EUR_CRM_Target_Number_of_Actions__c = null;
        objective.EUR_CRM_Achieved_Number_of_Actions__c = 3;
        update objective;

        objective = selectObjectives()[0];
        System.assertEquals(false, objective.EUR_CRM_Achieved__c);
    }

    @IsTest
    private static void updateSingle_from_5of5_to_nullOf5_PositiveTest() {
        EUR_CRM_GB_Objective__c objective = makeObjective('EUR_AT_Central_Objective', 5, 5);
        insert objective;

        objective = selectObjectives()[0];
        System.assertEquals(true, objective.EUR_CRM_Achieved__c);

        objective.EUR_CRM_Target_Number_of_Actions__c = 5;
        objective.EUR_CRM_Achieved_Number_of_Actions__c = null;
        update objective;

        objective = selectObjectives()[0];
        System.assertEquals(false, objective.EUR_CRM_Achieved__c);
    }


    /* ========================================================= */
    /*     Insert Multiple Identical Records
    /* ========================================================= */
    @IsTest
    private static void createMultiplePositiveTest() {
        List<EUR_CRM_GB_Objective__c> objectives = makeObjectives('EUR_AT_Central_Objective', 5, 5);
        insert objectives;

        objectives = selectObjectives();
        for (EUR_CRM_GB_Objective__c objective : objectives) {
            System.assertEquals(true, objective.EUR_CRM_Achieved__c);
        }
    }

    @IsTest
    private static void createMultipleAnotherRecordTypeNegativeTest() {
        List<EUR_CRM_GB_Objective__c> objectives = makeObjectives('EUR_AT_Personal_Objective', 5, 5);
        insert objectives;

        objectives = selectObjectives();
        for (EUR_CRM_GB_Objective__c objective : objectives) {
            System.assertEquals(false, objective.EUR_CRM_Achieved__c);
        }
    }

    @IsTest
    private static void createMultipleNotAllAchievementAreReachedNegativeTest() {
        List<EUR_CRM_GB_Objective__c> objectives = makeObjectives('EUR_AT_Central_Objective', 5, 3);
        insert objectives;

        objectives = selectObjectives();
        for (EUR_CRM_GB_Objective__c objective : objectives) {
            System.assertEquals(false, objective.EUR_CRM_Achieved__c);
        }
    }


    /* ========================================================= */
    /*     Insert Multiple Different Records
    /* ========================================================= */
    @IsTest
    private static void createMultipleDifferentRecordTypesPositiveTest() {
        Id centralObjectiveRTID = selectRecordTypeIdWhereDeveloperName('EUR_AT_Central_Objective');
        Id personalObjectiveRTID = selectRecordTypeIdWhereDeveloperName('EUR_AT_Personal_Objective');

        List<EUR_CRM_GB_Objective__c> objectives = new List<EUR_CRM_GB_Objective__c>();
        objectives.add(makeObjective(centralObjectiveRTID, 5, 5));
        objectives.add(makeObjective(personalObjectiveRTID, 5, 5));
        objectives.add(makeObjective(personalObjectiveRTID, 5, 5));
        objectives.add(makeObjective(centralObjectiveRTID, 5, 5));
        objectives.add(makeObjective(personalObjectiveRTID, 5, 5));
        objectives.add(makeObjective(centralObjectiveRTID, 5, 5));
        insert objectives;

        objectives = selectObjectives();
        System.assertEquals(6, objectives.size());
        System.assertEquals(true, objectives[0].EUR_CRM_Achieved__c);
        System.assertEquals(false, objectives[1].EUR_CRM_Achieved__c);
        System.assertEquals(false, objectives[2].EUR_CRM_Achieved__c);
        System.assertEquals(true, objectives[3].EUR_CRM_Achieved__c);
        System.assertEquals(false, objectives[4].EUR_CRM_Achieved__c);
        System.assertEquals(true, objectives[5].EUR_CRM_Achieved__c);
    }

    @IsTest
    private static void createMultipleDifferentReachLevelPositiveTest() {
        Id centralObjectiveRTID = selectRecordTypeIdWhereDeveloperName('EUR_AT_Central_Objective');

        List<EUR_CRM_GB_Objective__c> objectives = new List<EUR_CRM_GB_Objective__c>();
        objectives.add(makeObjective(centralObjectiveRTID, 5, 5));
        objectives.add(makeObjective(centralObjectiveRTID, 5, 3));
        objectives.add(makeObjective(centralObjectiveRTID, 5, 0));
        objectives.add(makeObjective(centralObjectiveRTID, 5, 5));
        objectives.add(makeObjective(centralObjectiveRTID, 5, 1));
        objectives.add(makeObjective(centralObjectiveRTID, 5, 5));
        insert objectives;

        objectives = selectObjectives();
        System.assertEquals(6, objectives.size());
        System.assertEquals(true, objectives[0].EUR_CRM_Achieved__c);
        System.assertEquals(false, objectives[1].EUR_CRM_Achieved__c);
        System.assertEquals(false, objectives[2].EUR_CRM_Achieved__c);
        System.assertEquals(true, objectives[3].EUR_CRM_Achieved__c);
        System.assertEquals(false, objectives[4].EUR_CRM_Achieved__c);
        System.assertEquals(true, objectives[5].EUR_CRM_Achieved__c);
    }

    @IsTest
    private static void createMultipleDifferentReachLevelAndNullPositiveTest() {
        Id centralObjectiveRTID = selectRecordTypeIdWhereDeveloperName('EUR_AT_Central_Objective');

        List<EUR_CRM_GB_Objective__c> objectives = new List<EUR_CRM_GB_Objective__c>();
        objectives.add(makeObjective(centralObjectiveRTID, 5, 5));
        objectives.add(makeObjective(centralObjectiveRTID, null, 3));
        objectives.add(makeObjective(centralObjectiveRTID, 5, null));
        objectives.add(makeObjective(centralObjectiveRTID, 5, 5));
        objectives.add(makeObjective(centralObjectiveRTID, null, null));
        objectives.add(makeObjective(centralObjectiveRTID, 5, 5));
        insert objectives;

        objectives = selectObjectives();
        System.assertEquals(6, objectives.size());
        System.assertEquals(true, objectives[0].EUR_CRM_Achieved__c);
        System.assertEquals(false, objectives[1].EUR_CRM_Achieved__c);
        System.assertEquals(false, objectives[2].EUR_CRM_Achieved__c);
        System.assertEquals(true, objectives[3].EUR_CRM_Achieved__c);
        System.assertEquals(false, objectives[4].EUR_CRM_Achieved__c);
        System.assertEquals(true, objectives[5].EUR_CRM_Achieved__c);
    }

    @IsTest
    private static void createMultipleDifferentReachLevelAndNullAndDifferentRecordTypesPositiveTest() {
        Id centralObjectiveRTID = selectRecordTypeIdWhereDeveloperName('EUR_AT_Central_Objective');
        Id personalObjectiveRTID = selectRecordTypeIdWhereDeveloperName('EUR_AT_Personal_Objective');

        List<EUR_CRM_GB_Objective__c> objectives = new List<EUR_CRM_GB_Objective__c>();
        objectives.add(makeObjective(personalObjectiveRTID, 5, 5));
        objectives.add(makeObjective(centralObjectiveRTID, null, 3));
        objectives.add(makeObjective(personalObjectiveRTID, 5, null));
        objectives.add(makeObjective(centralObjectiveRTID, 5, 5));
        objectives.add(makeObjective(personalObjectiveRTID, null, null));
        objectives.add(makeObjective(centralObjectiveRTID, 5, 5));
        insert objectives;

        objectives = selectObjectives();
        System.assertEquals(6, objectives.size());
        System.assertEquals(false, objectives[0].EUR_CRM_Achieved__c);
        System.assertEquals(false, objectives[1].EUR_CRM_Achieved__c);
        System.assertEquals(false, objectives[2].EUR_CRM_Achieved__c);
        System.assertEquals(true, objectives[3].EUR_CRM_Achieved__c);
        System.assertEquals(false, objectives[4].EUR_CRM_Achieved__c);
        System.assertEquals(true, objectives[5].EUR_CRM_Achieved__c);
    }


    /* ========================================================= */
    /*     Update Multiple Records
    /* ========================================================= */
    @IsTest
    private static void updateMultipleDifferentReachLevelAndNullPositiveTest() {
        Id centralObjectiveRTID = selectRecordTypeIdWhereDeveloperName('EUR_AT_Central_Objective');

        List<EUR_CRM_GB_Objective__c> objectives = new List<EUR_CRM_GB_Objective__c>();
        objectives.add(makeObjective(centralObjectiveRTID, 5, 5));
        objectives.add(makeObjective(centralObjectiveRTID, null, 3));
        objectives.add(makeObjective(centralObjectiveRTID, 5, null));
        objectives.add(makeObjective(centralObjectiveRTID, 5, 5));
        objectives.add(makeObjective(centralObjectiveRTID, null, null));
        objectives.add(makeObjective(centralObjectiveRTID, 5, 5));
        insert objectives;

        objectives = selectObjectives();
        System.assertEquals(6, objectives.size());
        System.assertEquals(true, objectives[0].EUR_CRM_Achieved__c);
        System.assertEquals(false, objectives[1].EUR_CRM_Achieved__c);
        System.assertEquals(false, objectives[2].EUR_CRM_Achieved__c);
        System.assertEquals(true, objectives[3].EUR_CRM_Achieved__c);
        System.assertEquals(false, objectives[4].EUR_CRM_Achieved__c);
        System.assertEquals(true, objectives[5].EUR_CRM_Achieved__c);

        objectives[0].EUR_CRM_Target_Number_of_Actions__c = 5;
        objectives[0].EUR_CRM_Achieved_Number_of_Actions__c = null;

        objectives[1].EUR_CRM_Target_Number_of_Actions__c = 5;
        objectives[1].EUR_CRM_Achieved_Number_of_Actions__c = 5;

        objectives[2].EUR_CRM_Target_Number_of_Actions__c = 5;
        objectives[2].EUR_CRM_Achieved_Number_of_Actions__c = 3;

        objectives[3].EUR_CRM_Target_Number_of_Actions__c = 5;
        objectives[3].EUR_CRM_Achieved_Number_of_Actions__c = 3;

        objectives[4].EUR_CRM_Target_Number_of_Actions__c = 5;
        objectives[4].EUR_CRM_Achieved_Number_of_Actions__c = 5;

        objectives[5].EUR_CRM_Target_Number_of_Actions__c = null;
        objectives[5].EUR_CRM_Achieved_Number_of_Actions__c = 5;

        update objectives;

        objectives = selectObjectives();
        System.assertEquals(6, objectives.size());
        System.assertEquals(false, objectives[0].EUR_CRM_Achieved__c);
        System.assertEquals(true, objectives[1].EUR_CRM_Achieved__c);
        System.assertEquals(false, objectives[2].EUR_CRM_Achieved__c);
        System.assertEquals(false, objectives[3].EUR_CRM_Achieved__c);
        System.assertEquals(true, objectives[4].EUR_CRM_Achieved__c);
        System.assertEquals(false, objectives[5].EUR_CRM_Achieved__c);
    }


    /* ========================================================= */
    /*     High Level Makers
    /* ========================================================= */
    private static List<EUR_CRM_GB_Objective__c> makeObjectives(String rtDevName, Integer countOfAllActions, Integer countOfAchievedActions) {
        List<EUR_CRM_GB_Objective__c> objectives = new List<EUR_CRM_GB_Objective__c>();

        Id rtId = selectRecordTypeIdWhereDeveloperName(rtDevName);
        for (Integer i = 0; i < 10; i++) {
            objectives.add(makeObjective(rtId, countOfAllActions, countOfAchievedActions));
        }
        return objectives;
    }


    /* ========================================================= */
    /*     Low Level Makers
    /* ========================================================= */
    private static EUR_CRM_GB_Objective__c makeObjective(String rtDevName, Integer countOfAllActions, Integer countOfAchievedActions) {
        EUR_CRM_GB_Objective__c objective = makeObjectiveSkeleton(countOfAllActions, countOfAchievedActions);
        objective.RecordTypeId = selectRecordTypeIdWhereDeveloperName(rtDevName);
        return objective;
    }

    private static EUR_CRM_GB_Objective__c makeObjective(Id rtId, Integer countOfAllActions, Integer countOfAchievedActions) {
        EUR_CRM_GB_Objective__c objective = makeObjectiveSkeleton(countOfAllActions, countOfAchievedActions);
        objective.RecordTypeId = rtId;
        return objective;
    }

    private static EUR_CRM_GB_Objective__c makeObjectiveSkeleton(Integer countOfAllActions, Integer countOfAchievedActions) {
        return new EUR_CRM_GB_Objective__c(
            EUR_CRM_Target_Number_of_Actions__c = countOfAllActions
        ,   EUR_CRM_Achieved_Number_of_Actions__c = countOfAchievedActions
        );
    }


    /* ========================================================= */
    /*     SOQL Selectors
    /* ========================================================= */
    private static Id selectRecordTypeIdWhereDeveloperName(String devName) {
        return [
            SELECT Id
            FROM RecordType
            WHERE DeveloperName = :devName
                AND SobjectType = 'EUR_CRM_GB_Objective__c'
            LIMIT 1
        ][0].Id;
    }

    private static List<EUR_CRM_GB_Objective__c> selectObjectives() {
        return [
            SELECT Id
            ,   EUR_CRM_Achieved__c
            FROM EUR_CRM_GB_Objective__c
        ];
    }

}