@IsTest (IsParallel = true)
private class EUR_CRM_ObjPromoActionSetVisActRTIDTest {

    private static final Integer COUNT_OF_RECORDS = 5;

    @TestSetup
    private static void setupMethod() {
        EUR_CRM_OP_Action_List_Template__c listTemplate = makeActionListTemplate('EUR_RU_OP_Action_List_Template', 'RU_OFF_Discount_Campaign');
        insert listTemplate;
    }


    /* ========================================================= */
    /*     Create Single EUR_CRM_ObjPromo_Action__c
    /* ========================================================= */
    @IsTest
    private static void createSingleObjPromoActionWithNormalRTTest() {
        String visitActionRTDevName = 'EUR_BE_OFF_Trade_Sales_Drive_Enter_Sell_In_Qty';
        EUR_CRM_ObjPromo_Action__c objPromoAction = makeObjPromoAction(visitActionRTDevName);
        Test.startTest();
        insert objPromoAction;
        Test.stopTest();

        objPromoAction = selectObjPromoActions()[0];
        System.assertEquals(selectRecordTypeIdWhereDeveloperName(visitActionRTDevName), objPromoAction.EUR_CRM_Visit_Action_RecordTypeID__c);
    }

    @IsTest
    private static void createSingleObjPromoActionWithInvalidRTTest() {
        String visitActionRTDevName = 'Bla-bla-record-type';
        EUR_CRM_ObjPromo_Action__c objPromoAction = makeObjPromoAction(visitActionRTDevName);
        Test.startTest();
        insert objPromoAction;
        Test.stopTest();

        objPromoAction = selectObjPromoActions()[0];
        System.assertEquals(null, objPromoAction.EUR_CRM_Visit_Action_RecordTypeID__c);
    }

    @IsTest
    private static void createSingleObjPromoActionWithEmptyRTTest() {
        String visitActionRTDevName = null;
        EUR_CRM_ObjPromo_Action__c objPromoAction = makeObjPromoAction(visitActionRTDevName);
        Test.startTest();
        insert objPromoAction;
        Test.stopTest();

        objPromoAction = selectObjPromoActions()[0];
        System.assertEquals(null, objPromoAction.EUR_CRM_Visit_Action_RecordTypeID__c);
    }


    /* ========================================================= */
    /*     Create Multiple EUR_CRM_ObjPromo_Action__c
    /* ========================================================= */
    @IsTest
    private static void createMultipleObjPromoActionsWithNormalRTTest() {
        String visitActionRTDevName = 'EUR_BE_OFF_Trade_Sales_Drive_Enter_Sell_In_Qty';
        List<EUR_CRM_ObjPromo_Action__c> objPromoActions = makeObjPromoActions(visitActionRTDevName);
        Test.startTest();
        insert objPromoActions;
        Test.stopTest();

        Id visitActionRTID = selectRecordTypeIdWhereDeveloperName(visitActionRTDevName);
        objPromoActions = selectObjPromoActions();
        for (EUR_CRM_ObjPromo_Action__c objPromoAction : objPromoActions) {
            System.assertEquals(visitActionRTID, objPromoAction.EUR_CRM_Visit_Action_RecordTypeID__c);
        }
    }

    @IsTest
    private static void createMultipleObjPromoActionsWithInvalidRTTest() {
        String visitActionRTDevName = 'Bla-bla-record-type';
        List<EUR_CRM_ObjPromo_Action__c> objPromoActions = makeObjPromoActions(visitActionRTDevName);
        Test.startTest();
        insert objPromoActions;
        Test.stopTest();

        objPromoActions = selectObjPromoActions();
        for (EUR_CRM_ObjPromo_Action__c objPromoAction : objPromoActions) {
            System.assertEquals(null, objPromoAction.EUR_CRM_Visit_Action_RecordTypeID__c);
        }
    }

    @IsTest
    private static void createMultipleObjPromoActionsWithEmptyRTTest() {
        String visitActionRTDevName = null;
        List<EUR_CRM_ObjPromo_Action__c> objPromoActions = makeObjPromoActions(visitActionRTDevName);
        Test.startTest();
        insert objPromoActions;
        Test.stopTest();

        objPromoActions = selectObjPromoActions();
        for (EUR_CRM_ObjPromo_Action__c objPromoAction : objPromoActions) {
            System.assertEquals(null, objPromoAction.EUR_CRM_Visit_Action_RecordTypeID__c);
        }
    }


    /* ========================================================= */
    /*     Update Single EUR_CRM_ObjPromo_Action__c
    /* ========================================================= */
    @IsTest
    private static void updateSingleObjPromoActionWithNormalRTToNullTest() {
        String visitActionRTDevName = 'EUR_BE_OFF_Trade_Sales_Drive_Enter_Sell_In_Qty';
        EUR_CRM_ObjPromo_Action__c objPromoAction = makeObjPromoAction(visitActionRTDevName);
        insert objPromoAction;

        objPromoAction = selectObjPromoActions()[0];
        System.assertEquals(selectRecordTypeIdWhereDeveloperName(visitActionRTDevName), objPromoAction.EUR_CRM_Visit_Action_RecordTypeID__c);

        objPromoAction.EUR_CRM_Visit_Action_RecordType_DevName__c = null;

        Test.startTest();
        update objPromoAction;
        Test.stopTest();

        objPromoAction = selectObjPromoActions()[0];
        System.assertEquals(selectRecordTypeIdWhereDeveloperName(visitActionRTDevName), objPromoAction.EUR_CRM_Visit_Action_RecordTypeID__c);
    }

    @IsTest
    private static void updateSingleObjPromoActionWithNormalRTToDifferentInvalidRTTest() {
        String visitActionRTDevName = 'EUR_BE_OFF_Trade_Sales_Drive_Enter_Sell_In_Qty';
        EUR_CRM_ObjPromo_Action__c objPromoAction = makeObjPromoAction(visitActionRTDevName);
        insert objPromoAction;

        objPromoAction = selectObjPromoActions()[0];
        System.assertEquals(selectRecordTypeIdWhereDeveloperName(visitActionRTDevName), objPromoAction.EUR_CRM_Visit_Action_RecordTypeID__c);

        objPromoAction.EUR_CRM_Visit_Action_RecordType_DevName__c = 'Bla-bla-record-type';

        Test.startTest();
        update objPromoAction;
        Test.stopTest();

        objPromoAction = selectObjPromoActions()[0];
        System.assertEquals(selectRecordTypeIdWhereDeveloperName(visitActionRTDevName), objPromoAction.EUR_CRM_Visit_Action_RecordTypeID__c);
    }

    @IsTest
    private static void updateSingleObjPromoActionWithNormalRTToDifferentNormalRTTest() {
        String visitActionRTDevName = 'EUR_BE_OFF_Trade_Sales_Drive_Enter_Sell_In_Qty';
        EUR_CRM_ObjPromo_Action__c objPromoAction = makeObjPromoAction(visitActionRTDevName);
        insert objPromoAction;

        objPromoAction = selectObjPromoActions()[0];
        System.assertEquals(selectRecordTypeIdWhereDeveloperName(visitActionRTDevName), objPromoAction.EUR_CRM_Visit_Action_RecordTypeID__c);

        visitActionRTDevName = 'EUR_BE_OFF_Secondary_Placement_CheckImplementation';
        objPromoAction.EUR_CRM_Visit_Action_RecordType_DevName__c = visitActionRTDevName;

        Test.startTest();
        update objPromoAction;
        Test.stopTest();

        objPromoAction = selectObjPromoActions()[0];
        System.assertEquals(selectRecordTypeIdWhereDeveloperName(visitActionRTDevName), objPromoAction.EUR_CRM_Visit_Action_RecordTypeID__c);
    }

    @IsTest
    private static void updateSingleObjPromoActionWithInvalidRTToNormalRTTest() {
        String visitActionRTDevName = 'Bla-bla-record-type';
        EUR_CRM_ObjPromo_Action__c objPromoAction = makeObjPromoAction(visitActionRTDevName);
        insert objPromoAction;

        objPromoAction = selectObjPromoActions()[0];
        System.assertEquals(null, objPromoAction.EUR_CRM_Visit_Action_RecordTypeID__c);

        visitActionRTDevName = 'EUR_BE_OFF_Secondary_Placement_CheckImplementation';
        objPromoAction.EUR_CRM_Visit_Action_RecordType_DevName__c = visitActionRTDevName;

        Test.startTest();
        update objPromoAction;
        Test.stopTest();

        objPromoAction = selectObjPromoActions()[0];
        System.assertEquals(selectRecordTypeIdWhereDeveloperName(visitActionRTDevName), objPromoAction.EUR_CRM_Visit_Action_RecordTypeID__c);
    }

    @IsTest
    private static void updateSingleObjPromoActionWithEmptyRTToInvalidTest() {
        String visitActionRTDevName = null;
        EUR_CRM_ObjPromo_Action__c objPromoAction = makeObjPromoAction(visitActionRTDevName);
        insert objPromoAction;

        objPromoAction = selectObjPromoActions()[0];
        System.assertEquals(null, objPromoAction.EUR_CRM_Visit_Action_RecordTypeID__c);

        visitActionRTDevName = 'Bla-bla-record-type';
        objPromoAction.EUR_CRM_Visit_Action_RecordType_DevName__c = visitActionRTDevName;

        Test.startTest();
        update objPromoAction;
        Test.stopTest();

        objPromoAction = selectObjPromoActions()[0];
        System.assertEquals(null, objPromoAction.EUR_CRM_Visit_Action_RecordTypeID__c);
    }


    /* ========================================================= */
    /*     Update Multiple EUR_CRM_ObjPromo_Action__c
    /* ========================================================= */
    @IsTest
    private static void updateMultipleObjPromoActionsWithNormalRTToNullTest() {
        String visitActionRTDevName = 'EUR_BE_OFF_Trade_Sales_Drive_Enter_Sell_In_Qty';
        List<EUR_CRM_ObjPromo_Action__c> objPromoActions = makeObjPromoActions(visitActionRTDevName);
        insert objPromoActions;

        Id visitActionRTID = selectRecordTypeIdWhereDeveloperName(visitActionRTDevName);
        objPromoActions = selectObjPromoActions();
        for (EUR_CRM_ObjPromo_Action__c objPromoAction : objPromoActions) {
            System.assertEquals(visitActionRTID, objPromoAction.EUR_CRM_Visit_Action_RecordTypeID__c);
        }

        for (EUR_CRM_ObjPromo_Action__c objPromoAction : objPromoActions) {
            objPromoAction.EUR_CRM_Visit_Action_RecordType_DevName__c = null;
        }

        Test.startTest();
        update objPromoActions;
        Test.stopTest();

        objPromoActions = selectObjPromoActions();
        for (EUR_CRM_ObjPromo_Action__c objPromoAction : objPromoActions) {
            System.assertEquals(visitActionRTID, objPromoAction.EUR_CRM_Visit_Action_RecordTypeID__c);
        }
    }

    @IsTest
    private static void updateMultipleObjPromoActionsWithNormalRTToDifferentInvalidRTTest() {
        String visitActionRTDevName = 'EUR_BE_OFF_Trade_Sales_Drive_Enter_Sell_In_Qty';
        List<EUR_CRM_ObjPromo_Action__c> objPromoActions = makeObjPromoActions(visitActionRTDevName);
        insert objPromoActions;

        Id visitActionRTID = selectRecordTypeIdWhereDeveloperName(visitActionRTDevName);
        objPromoActions = selectObjPromoActions();
        for (EUR_CRM_ObjPromo_Action__c objPromoAction : objPromoActions) {
            System.assertEquals(visitActionRTID, objPromoAction.EUR_CRM_Visit_Action_RecordTypeID__c);
        }

        for (EUR_CRM_ObjPromo_Action__c objPromoAction : objPromoActions) {
            objPromoAction.EUR_CRM_Visit_Action_RecordType_DevName__c = 'Bla-bla-record-type';
        }

        Test.startTest();
        update objPromoActions;
        Test.stopTest();

        objPromoActions = selectObjPromoActions();
        for (EUR_CRM_ObjPromo_Action__c objPromoAction : objPromoActions) {
            System.assertEquals(visitActionRTID, objPromoAction.EUR_CRM_Visit_Action_RecordTypeID__c);
        }
    }

    @IsTest
    private static void updateMultipleObjPromoActionsWithNormalRTToNormalRTTest() {
        String visitActionRTDevName = 'EUR_BE_OFF_Trade_Sales_Drive_Enter_Sell_In_Qty';
        List<EUR_CRM_ObjPromo_Action__c> objPromoActions = makeObjPromoActions(visitActionRTDevName);
        insert objPromoActions;

        Id visitActionRTID = selectRecordTypeIdWhereDeveloperName(visitActionRTDevName);
        objPromoActions = selectObjPromoActions();
        for (EUR_CRM_ObjPromo_Action__c objPromoAction : objPromoActions) {
            System.assertEquals(visitActionRTID, objPromoAction.EUR_CRM_Visit_Action_RecordTypeID__c);
        }

        visitActionRTDevName = 'EUR_BE_OFF_Secondary_Placement_CheckImplementation';
        for (EUR_CRM_ObjPromo_Action__c objPromoAction : objPromoActions) {
            objPromoAction.EUR_CRM_Visit_Action_RecordType_DevName__c = visitActionRTDevName;
        }

        Test.startTest();
        update objPromoActions;
        Test.stopTest();

        visitActionRTID = selectRecordTypeIdWhereDeveloperName(visitActionRTDevName);
        objPromoActions = selectObjPromoActions();
        for (EUR_CRM_ObjPromo_Action__c objPromoAction : objPromoActions) {
            System.assertEquals(visitActionRTID, objPromoAction.EUR_CRM_Visit_Action_RecordTypeID__c);
        }
    }

    @IsTest
    private static void updateMultipleObjPromoActionsWithInvalidRTToNormalRTTest() {
        List<EUR_CRM_ObjPromo_Action__c> objPromoActions = makeObjPromoActions('Bla-bla-record-type');
        insert objPromoActions;

        objPromoActions = selectObjPromoActions();
        for (EUR_CRM_ObjPromo_Action__c objPromoAction : objPromoActions) {
            System.assertEquals(null, objPromoAction.EUR_CRM_Visit_Action_RecordTypeID__c);
        }

        String visitActionRTDevName = 'EUR_BE_OFF_Trade_Sales_Drive_Enter_Sell_In_Qty';
        for (EUR_CRM_ObjPromo_Action__c objPromoAction : objPromoActions) {
            objPromoAction.EUR_CRM_Visit_Action_RecordType_DevName__c = visitActionRTDevName;
        }

        Test.startTest();
        update objPromoActions;
        Test.stopTest();

        Id visitActionRTID = selectRecordTypeIdWhereDeveloperName(visitActionRTDevName);
        objPromoActions = selectObjPromoActions();
        for (EUR_CRM_ObjPromo_Action__c objPromoAction : objPromoActions) {
            System.assertEquals(visitActionRTID, objPromoAction.EUR_CRM_Visit_Action_RecordTypeID__c);
        }
    }

    @IsTest
    private static void updateMultipleObjPromoActionsWithEmptyRTToInvalidTest() {
        List<EUR_CRM_ObjPromo_Action__c> objPromoActions = makeObjPromoActions(null);
        insert objPromoActions;

        objPromoActions = selectObjPromoActions();
        for (EUR_CRM_ObjPromo_Action__c objPromoAction : objPromoActions) {
            System.assertEquals(null, objPromoAction.EUR_CRM_Visit_Action_RecordTypeID__c);
        }

        String visitActionRTDevName = 'Bla-bla-record-type';
        for (EUR_CRM_ObjPromo_Action__c objPromoAction : objPromoActions) {
            objPromoAction.EUR_CRM_Visit_Action_RecordType_DevName__c = visitActionRTDevName;
        }

        Test.startTest();
        update objPromoActions;
        Test.stopTest();

        objPromoActions = selectObjPromoActions();
        for (EUR_CRM_ObjPromo_Action__c objPromoAction : objPromoActions) {
            System.assertEquals(null, objPromoAction.EUR_CRM_Visit_Action_RecordTypeID__c);
        }
    }


    /* ========================================================= */
    /*     High Level Makers
    /* ========================================================= */
    private static List<EUR_CRM_ObjPromo_Action__c> makeObjPromoActions(String visitActionRTDevName) {
        Id actionListTemplateId = selectActionListTemplates()[0].Id;

        List<EUR_CRM_ObjPromo_Action__c> objPromoActions = new List<EUR_CRM_ObjPromo_Action__c>();
        for (Integer i = 0; i < COUNT_OF_RECORDS; i++) {
            objPromoActions.add(makeObjPromoAction(actionListTemplateId, visitActionRTDevName));
        }
        return objPromoActions;
    }


    /* ========================================================= */
    /*     Low Level Makers
    /* ========================================================= */
    private static EUR_CRM_OP_Action_List_Template__c makeActionListTemplate(String recordTypeDevName, String externalId) {
        EUR_CRM_OP_Action_List_Template__c actionListTemplate = makeActionListTemplateSkeleton(externalId);
        actionListTemplate.RecordTypeId = selectRecordTypeIdWhereDeveloperName(recordTypeDevName);
        return actionListTemplate;
    }

    private static EUR_CRM_OP_Action_List_Template__c makeActionListTemplateSkeleton(String externalId) {
        return new EUR_CRM_OP_Action_List_Template__c(
            Name = 'Template Name'
        ,   EUR_CRM_External_ID__c = externalId
        );
    }

    private static EUR_CRM_ObjPromo_Action__c makeObjPromoAction(String visitActionRTDevName) {
        EUR_CRM_ObjPromo_Action__c objPromoAction = makeObjPromoActionSkeleton(visitActionRTDevName);
        objPromoAction.EUR_CRM_OP_Action_List_Template__c = selectActionListTemplates()[0].Id;
        return objPromoAction;
    }

    private static EUR_CRM_ObjPromo_Action__c makeObjPromoAction(Id actionListTemplateId, String visitActionRTDevName) {
        EUR_CRM_ObjPromo_Action__c objPromoAction = makeObjPromoActionSkeleton(visitActionRTDevName);
        objPromoAction.EUR_CRM_OP_Action_List_Template__c = actionListTemplateId;
        return objPromoAction;
    }

    private static EUR_CRM_ObjPromo_Action__c makeObjPromoActionSkeleton(String visitActionRTDevName) {
        return new EUR_CRM_ObjPromo_Action__c(
            Name = 'New ObjPromoAction'
        ,   EUR_CRM_Visit_Action_RecordType_DevName__c = visitActionRTDevName
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
            LIMIT 1
        ][0].Id;
    }

    private static List<EUR_CRM_OP_Action_List_Template__c> selectActionListTemplates() {
        return [
            SELECT Id
            FROM EUR_CRM_OP_Action_List_Template__c
        ];
    }

    private static List<EUR_CRM_ObjPromo_Action__c> selectObjPromoActions() {
        return [
            SELECT Id
            ,   EUR_CRM_Visit_Action_RecordTypeID__c
            FROM EUR_CRM_ObjPromo_Action__c
        ];
    }

}