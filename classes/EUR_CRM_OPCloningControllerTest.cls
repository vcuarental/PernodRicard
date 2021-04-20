@IsTest (IsParallel = true)
private class EUR_CRM_OPCloningControllerTest {

    @TestSetup
    private static void setupMethod() {
        List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {
            EUR_CRM_Account_Target_Group__c atg = makeAccountTargetGroup();
            insert atg;

            EUR_CRM_OP_Template__c opTemplate = makeOPTemplate(EUR_CRM_ObjPromoTargetMngmntCtrl.DEFAULT_SECTION_TO_DISPLAY);
            insert opTemplate;

            List<EUR_CRM_OP_Action__c> opActions = new List<EUR_CRM_OP_Action__c>();
            opActions.add(makeOPAction(opTemplate.Id, 'EUR_CRM_Target_Quantity_Listing__c'));
            opActions.add(makeOPAction(opTemplate.Id, 'EUR_CRM_Target_Quantity_People__c'));
            opActions.add(makeOPAction(opTemplate.Id, 'EUR_CRM_Target_Quantity_Promo_Kits__c'));
            opActions.add(makeOPAction(opTemplate.Id, 'EUR_CRM_Target_Quantity_Spyders__c'));
            opActions.add(makeOPAction(opTemplate.Id, 'EUR_CRM_Target_Sell_in_Amount_Bottle__c'));
            insert opActions;

            EUR_CRM_Objectives_Promotions__c op = makeObjectivesPromotions(opTemplate.Id, atg.Id);
            insert op;

            EUR_CRM_Brand__c brand = makeBrand('ABSOLUT');
            insert brand;
            EUR_CRM_OP_Product__c product = makeProduct(op.Id, 'EUR_CRM_Brand__c', brand.Id);
            insert product;
        }
    }

    @IsTest
    private static void setupTest() {
        List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {
            List<EUR_CRM_OP_Template__c> opTemplates = selectOPTemplates();
            System.assertEquals(1, opTemplates.size());

            List<EUR_CRM_OP_Action__c> opActions = selectOPActions();
            System.assertEquals('EUR_CRM_Target_Quantity_Listing__c', opActions[0].EUR_CRM_MultiPLOpTarget__c);
            System.assertEquals('EUR_CRM_Target_Quantity_People__c', opActions[1].EUR_CRM_MultiPLOpTarget__c);
            System.assertEquals('EUR_CRM_Target_Quantity_Promo_Kits__c', opActions[2].EUR_CRM_MultiPLOpTarget__c);
            System.assertEquals('EUR_CRM_Target_Quantity_Spyders__c', opActions[3].EUR_CRM_MultiPLOpTarget__c);
            System.assertEquals('EUR_CRM_Target_Sell_in_Amount_Bottle__c', opActions[4].EUR_CRM_MultiPLOpTarget__c);
            System.assertEquals(5, opActions.size());

            List<EUR_CRM_Objectives_Promotions__c> ops = selectObjectivesPromotions();
            System.assertEquals(1, ops.size());
        }
    }


    @IsTest
    private static void getRecordToCloneTest() {
        List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {
            List<EUR_CRM_Objectives_Promotions__c> ops = selectObjectivesPromotions();

            Test.startTest();
            EUR_CRM_Objectives_Promotions__c opToClone = EUR_CRM_OPCloningController.getRecordToClone(ops[0].Id);
            Test.stopTest();

            System.assertNotEquals(null, opToClone);
            System.assertEquals(ops[0].EUR_CRM_OP_Template__c, opToClone.EUR_CRM_OP_Template__c);
            System.assertEquals(ops[0].EUR_CRM_Account_Target_Group__c, opToClone.EUR_CRM_Account_Target_Group__c);
            System.assertEquals(ops[0].Name + ' - Cloned', opToClone.Name);

            System.assertNotEquals(null, opToClone.EUR_CRM_Active_Start_Date__c);
            System.assertNotEquals(null, opToClone.EUR_CRM_Active_End_Date__c);
            System.assertNotEquals(null, opToClone.EUR_CRM_Publish_Date__c);
            System.assertNotEquals(null, opToClone.EUR_CRM_Preparation_Start_Date__c);
            System.assertNotEquals(null, opToClone.EUR_CRM_Evaluation_End_Date__c);
        }
    }

    @IsTest
    private static void cloneRecordWithRelatedListsTest() {
        List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {
            List<EUR_CRM_Objectives_Promotions__c> ops = selectObjectivesPromotions();
            EUR_CRM_Objectives_Promotions__c opToClone = EUR_CRM_OPCloningController.getRecordToClone(ops[0].Id);

            Test.startTest();
            String opId = EUR_CRM_OPCloningController.cloneRecordWithRelatedLists(opToClone);
            Test.stopTest();

            System.assertNotEquals(null, opId);

            ops = selectObjectivesPromotions();
            System.assertEquals(2, ops.size());

            System.assertEquals(ops[1].Id, opId);

            System.assertEquals(ops[0].OP_Products_EU__r.size(), ops[1].OP_Products_EU__r.size());
            System.assertEquals(ops[0].Name + ' - Cloned', ops[1].Name);
            System.assertEquals(ops[0].OP_Products_EU__r[0].EUR_CRM_Brand__c, ops[1].OP_Products_EU__r[0].EUR_CRM_Brand__c);

            System.assertEquals(null, ops[1].EUR_CRM_Active_Start_Date__c);
            System.assertEquals(null, ops[1].EUR_CRM_Active_End_Date__c);
            System.assertEquals(null, ops[1].EUR_CRM_Publish_Date__c);
            System.assertEquals(null, ops[1].EUR_CRM_Preparation_Start_Date__c);
            System.assertEquals(null, ops[1].EUR_CRM_Evaluation_End_Date__c);
        }
    }


    /* ========================================================= */
    /*     Low Level Makers
    /* ========================================================= */
    private static EUR_CRM_Account_Target_Group__c makeAccountTargetGroup() {
        return new EUR_CRM_Account_Target_Group__c(Name = 'ATG Test');
    }

    private static EUR_CRM_OP_Template__c makeOPTemplate(String level) {
        return new EUR_CRM_OP_Template__c(
            Name = 'OP Template Test'
        ,   EUR_CRM_Target_Quota_Levels__c = level
        );
    }

    private static EUR_CRM_OP_Action__c makeOPAction(Id templateId, String fieldName) {
        return new EUR_CRM_OP_Action__c(
            Name = 'OP Action Test'
        ,   EUR_CRM_OP_Template__c = templateId
        ,   EUR_CRM_MultiPLOpTarget__c = fieldName
        ,   EUR_CRM_Reoccuring_Type__c = 'Repeat all time'
        );
    }

    private static EUR_CRM_Objectives_Promotions__c makeObjectivesPromotions(Id templateId, Id atgId) {
        return new EUR_CRM_Objectives_Promotions__c(
            EUR_CRM_OP_Template__c = templateId
        ,   Name = 'OP Test'
        ,   EUR_CRM_Account_Target_Group__c = atgId
        ,   EUR_CRM_Active_Start_Date__c = Date.today().addMonths(1)
        ,   EUR_CRM_Active_End_Date__c = Date.today().addMonths(2)
        ,   EUR_CRM_Publish_Date__c = Date.today().addMonths(1).addDays(-1)
        ,   EUR_CRM_Preparation_Start_Date__c = Date.today()
        ,   EUR_CRM_Evaluation_End_Date__c = Date.today().addMonths(2).addDays(7)
        );
    }

    private static EUR_CRM_Brand__c makeBrand(String name) {
        return new EUR_CRM_Brand__c(
            Name = name
        );
    }

    private static EUR_CRM_OP_Product__c makeProduct(Id opId, String productApiName, String productId) {
        EUR_CRM_OP_Product__c product = new EUR_CRM_OP_Product__c(
            EUR_CRM_Objectives_Promotions__c = opId
        );
        product.put(productApiName, productId);
        return product;
    }


    /* ========================================================= */
    /*     SOQL Wrappers
    /* ========================================================= */
    private static List<EUR_CRM_OP_Template__c> selectOPTemplates() {
        return [
            SELECT Id
            FROM EUR_CRM_OP_Template__c
        ];
    }

    private static List<EUR_CRM_OP_Action__c> selectOPActions() {
        return [
            SELECT Id
            ,   EUR_CRM_MultiPLOpTarget__c
            FROM EUR_CRM_OP_Action__c
        ];
    }

    private static List<EUR_CRM_Objectives_Promotions__c> selectObjectivesPromotions() {
        return [
            SELECT Id
            ,   Name
            ,   EUR_CRM_OP_Template__c
            ,   EUR_CRM_Account_Target_Group__c
            ,   EUR_CRM_Active_Start_Date__c
            ,   EUR_CRM_Active_End_Date__c
            ,   EUR_CRM_Publish_Date__c
            ,   EUR_CRM_Preparation_Start_Date__c
            ,   EUR_CRM_Evaluation_End_Date__c
            ,   (
                SELECT Id
                ,   EUR_CRM_Brand__c
                FROM OP_Products_EU__r
            )
            FROM EUR_CRM_Objectives_Promotions__c
        ];
    }

    private static List<User> getEMEAandEURsystemAdminUser() {
        return [
            SELECT Id
            FROM User
            WHERE Profile.Name = 'EUR System Admin'
                AND UserRole.Name = 'EMEA'
            LIMIT 1
        ];
    }

}