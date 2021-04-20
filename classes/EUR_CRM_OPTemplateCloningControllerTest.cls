@IsTest (IsParallel = true)
private class EUR_CRM_OPTemplateCloningControllerTest {

    @TestSetup
    private static void setupMethod() {
        List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {
            EUR_CRM_OP_Template__c opTemplate = makeOPTemplate(EUR_CRM_ObjPromoTargetMngmntCtrl.DEFAULT_SECTION_TO_DISPLAY);
            insert opTemplate;

            List<EUR_CRM_OP_Action__c> opActions = new List<EUR_CRM_OP_Action__c>();
            opActions.add(makeOPAction(1, opTemplate.Id, 'EUR_CRM_Target_Quantity_Listing__c'));
            opActions.add(makeOPAction(2, opTemplate.Id, 'EUR_CRM_Target_Quantity_People__c'));
            opActions.add(makeOPAction(3, opTemplate.Id, 'EUR_CRM_Target_Quantity_Promo_Kits__c'));
            opActions.add(makeOPAction(4, opTemplate.Id, 'EUR_CRM_Target_Quantity_Spyders__c'));
            opActions.add(makeOPAction(5, opTemplate.Id, 'EUR_CRM_Target_Sell_in_Amount_Bottle__c'));
            insert opActions;

            for (Integer i = 1; i < opActions.size(); i ++) {
                opActions[i].EUR_CRM_Parent_Action__c = opActions[i - 1].Id;
            }
            update opActions;
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
            System.assertEquals(5, opActions.size());
            System.assertEquals('EUR_CRM_Target_Quantity_Listing__c', opActions[0].EUR_CRM_MultiPLOpTarget__c);
            System.assertEquals('EUR_CRM_Target_Quantity_People__c', opActions[1].EUR_CRM_MultiPLOpTarget__c);
            System.assertEquals('EUR_CRM_Target_Quantity_Promo_Kits__c', opActions[2].EUR_CRM_MultiPLOpTarget__c);
            System.assertEquals('EUR_CRM_Target_Quantity_Spyders__c', opActions[3].EUR_CRM_MultiPLOpTarget__c);
            System.assertEquals('EUR_CRM_Target_Sell_in_Amount_Bottle__c', opActions[4].EUR_CRM_MultiPLOpTarget__c);

            for (Integer i = 1; i < opActions.size(); i ++) {
                System.assertEquals(opActions[i - 1].Id, opActions[i].EUR_CRM_Parent_Action__c);
            }
        }
    }


    @IsTest
    private static void getRecordToCloneTest() {
        List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {
            List<EUR_CRM_OP_Template__c> templates = selectOPTemplates();

            Test.startTest();
            EUR_CRM_OP_Template__c templateToClone = EUR_CRM_OPTemplateCloningController.getRecordToClone(templates[0].Id);
            Test.stopTest();

            System.assertNotEquals(null, templateToClone);
            System.assertEquals(templates[0].EUR_CRM_Target_Quota_Levels__c, templateToClone.EUR_CRM_Target_Quota_Levels__c);
            System.assertEquals(templates[0].Name + ' - Cloned', templateToClone.Name);
        }
    }

    @IsTest
    private static void cloneRecordWithRelatedListsTest() {
        List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {
            List<EUR_CRM_OP_Template__c> templates = selectOPTemplates();
            EUR_CRM_OP_Template__c templateToClone = EUR_CRM_OPTemplateCloningController.getRecordToClone(templates[0].Id);

            Test.startTest();
            String templateId = EUR_CRM_OPTemplateCloningController.cloneRecordWithRelatedLists(templateToClone);
            Test.stopTest();

            System.assertNotEquals(null, templateId);

            templates = selectOPTemplates();
            System.assertEquals(2, templates.size());

            System.assertEquals(templates[1].Id, templateId);

            System.assertEquals(templates[0].OP_Actions_EU__r.size(), templates[1].OP_Actions_EU__r.size());
            System.assertEquals(templates[0].Name + ' - Cloned', templates[1].Name);
            for (Integer i = 0; i < templates[0].OP_Actions_EU__r.size(); i ++) {
                System.assertEquals(templates[0].OP_Actions_EU__r[i].EUR_CRM_MultiPLOpTarget__c, templates[1].OP_Actions_EU__r[i].EUR_CRM_MultiPLOpTarget__c);
            }

            for (Integer i = 1; i < templates[1].OP_Actions_EU__r.size(); i ++) {
                System.assertEquals(templates[1].OP_Actions_EU__r[i - 1].Id, templates[1].OP_Actions_EU__r[i].EUR_CRM_Parent_Action__c);
            }
        }
    }


    /* ========================================================= */
    /*     Low Level Makers
    /* ========================================================= */
    private static EUR_CRM_OP_Template__c makeOPTemplate(String level) {
        return new EUR_CRM_OP_Template__c(
            Name = 'OP Template Test'
        ,   EUR_CRM_Target_Quota_Levels__c = level
        );
    }

    private static EUR_CRM_OP_Action__c makeOPAction(Integer stepOrder, Id templateId, String fieldName) {
        return new EUR_CRM_OP_Action__c(
            Name = 'OP Action Name'
        ,   EUR_CRM_Step_Order__c = stepOrder
        ,   EUR_CRM_OP_Template__c = templateId
        ,   EUR_CRM_MultiPLOpTarget__c = fieldName
        ,   EUR_CRM_Reoccuring_Type__c = 'Repeat all time'
        );
    }


    /* ========================================================= */
    /*     SOQL Wrappers
    /* ========================================================= */
    private static List<EUR_CRM_OP_Template__c> selectOPTemplates() {
        return [
            SELECT Id
            ,   Name
            ,   EUR_CRM_Target_Quota_Levels__c
            ,   (
                SELECT Id
                ,   EUR_CRM_MultiPLOpTarget__c
                ,   EUR_CRM_Parent_Action__c
                FROM OP_Actions_EU__r
                ORDER BY Id
            )
            FROM EUR_CRM_OP_Template__c
        ];
    }

    private static List<EUR_CRM_OP_Action__c> selectOPActions() {
        return [
            SELECT Id
            ,   EUR_CRM_MultiPLOpTarget__c
            ,   EUR_CRM_Parent_Action__c
            FROM EUR_CRM_OP_Action__c
            ORDER BY Id
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