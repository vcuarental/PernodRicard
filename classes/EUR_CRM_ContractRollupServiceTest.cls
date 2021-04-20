@IsTest
private class EUR_CRM_ContractRollupServiceTest {

    @TestSetup
    private static void setupMethod() {
        EUR_CRM_Mechanic_Type__c EUR_DE_WKZ_Fix_Amount = new EUR_CRM_Mechanic_Type__c(EUR_CRM_External_ID__c = 'EUR_DE_WKZ_Fix_Amount', Name = 'EUR_DE_WKZ_Fix_Amount');
        EUR_CRM_Mechanic_Type__c EUR_DE_Drinks_Menu = new EUR_CRM_Mechanic_Type__c(EUR_CRM_External_ID__c = 'EUR_DE_Drinks_Menu', Name = 'EUR_DE_Drinks_Menu');
        EUR_CRM_Mechanic_Type__c EUR_DE_Events = new EUR_CRM_Mechanic_Type__c(EUR_CRM_External_ID__c = 'EUR_DE_Events', Name = 'EUR_DE_Events');
        EUR_CRM_Mechanic_Type__c EUR_DE_Visibility_Branding = new EUR_CRM_Mechanic_Type__c(EUR_CRM_External_ID__c = 'EUR_DE_Visibility_Branding', Name = 'EUR_DE_Visibility_Branding');
        EUR_CRM_Mechanic_Type__c EUR_DE_POS_WKZ = new EUR_CRM_Mechanic_Type__c(EUR_CRM_External_ID__c = 'EUR_DE_POS_WKZ', Name = 'EUR_DE_POS_WKZ');
        EUR_CRM_Mechanic_Type__c EUR_DE_POS_Material = new EUR_CRM_Mechanic_Type__c(EUR_CRM_External_ID__c = 'EUR_DE_POS_Material', Name = 'EUR_DE_POS_Material');
        EUR_CRM_Mechanic_Type__c EUR_DE_Napkins = new EUR_CRM_Mechanic_Type__c(EUR_CRM_External_ID__c = 'EUR_DE_Napkins', Name = 'EUR_DE_Napkins');
        EUR_CRM_Mechanic_Type__c EUR_DE_Training = new EUR_CRM_Mechanic_Type__c(EUR_CRM_External_ID__c = 'EUR_DE_Training', Name = 'EUR_DE_Training');
        EUR_CRM_Mechanic_Type__c EUR_DE_Others = new EUR_CRM_Mechanic_Type__c(EUR_CRM_External_ID__c = 'EUR_DE_Others', Name = 'EUR_DE_Others');
        insert new List<EUR_CRM_Mechanic_Type__c> {EUR_DE_WKZ_Fix_Amount, EUR_DE_Drinks_Menu, EUR_DE_Events, EUR_DE_Visibility_Branding, EUR_DE_POS_WKZ, EUR_DE_POS_Material, EUR_DE_Napkins, EUR_DE_Training, EUR_DE_Others};

        EUR_CRM_Account__c account = new EUR_CRM_Account__c(
                Name = 'Test',
                EUR_CRM_Postal_Code__c = '112233',
                recordTypeId = Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_On_Trade_B2B').getRecordTypeId()

        );
        insert account;

        //Create Contract
        EUR_CRM_Contract__c contract = new EUR_CRM_Contract__c();
        contract.recordTypeId = Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract').getRecordTypeId();
        contract.EUR_CRM_Account__c = account.Id;
        contract.EUR_CRM_Start_Date__c = date.today();
        contract.EUR_CRM_End_Date__c = date.today().addDays(30);
        contract.EUR_CRM_Contract_Sub_Type__c = 'Basic Contract';
        contract.EUR_CRM_Active__c = false;
        contract.EUR_CRM_Status__c = 'Draft';
        insert contract;

        List<EUR_CRM_Contract_Activity_Item__c> activityItems = new List<EUR_CRM_Contract_Activity_Item__c>();
        activityItems.add(new EUR_CRM_Contract_Activity_Item__c(EUR_CRM_Amount__c = 1, EUR_CRM_Mechanic_Type__c = EUR_DE_WKZ_Fix_Amount.Id, EUR_CRM_Contract__c = contract.Id));
        activityItems.add(new EUR_CRM_Contract_Activity_Item__c(EUR_CRM_Amount__c = 1, EUR_CRM_Mechanic_Type__c = EUR_DE_WKZ_Fix_Amount.Id, EUR_CRM_Contract__c = contract.Id));

        activityItems.add(new EUR_CRM_Contract_Activity_Item__c(EUR_CRM_Amount__c = 2, EUR_CRM_Mechanic_Type__c = EUR_DE_Drinks_Menu.Id, EUR_CRM_Contract__c = contract.Id));
        activityItems.add(new EUR_CRM_Contract_Activity_Item__c(EUR_CRM_Amount__c = 2, EUR_CRM_Mechanic_Type__c = EUR_DE_Drinks_Menu.Id, EUR_CRM_Contract__c = contract.Id));

        activityItems.add(new EUR_CRM_Contract_Activity_Item__c(EUR_CRM_Amount__c = 3, EUR_CRM_Mechanic_Type__c = EUR_DE_Events.Id, EUR_CRM_Is_PR_Event__c = false, EUR_CRM_Contract__c = contract.Id));
        activityItems.add(new EUR_CRM_Contract_Activity_Item__c(EUR_CRM_Amount__c = 3, EUR_CRM_Mechanic_Type__c = EUR_DE_Events.Id, EUR_CRM_Is_PR_Event__c = false, EUR_CRM_Contract__c = contract.Id));

        activityItems.add(new EUR_CRM_Contract_Activity_Item__c(EUR_CRM_Amount__c = 4, EUR_CRM_Mechanic_Type__c = EUR_DE_Events.Id, EUR_CRM_Is_PR_Event__c = true, EUR_CRM_Contract__c = contract.Id));
        activityItems.add(new EUR_CRM_Contract_Activity_Item__c(EUR_CRM_Amount__c = 4, EUR_CRM_Mechanic_Type__c = EUR_DE_Events.Id, EUR_CRM_Is_PR_Event__c = true, EUR_CRM_Contract__c = contract.Id));

        activityItems.add(new EUR_CRM_Contract_Activity_Item__c(EUR_CRM_Amount__c = 5, EUR_CRM_Mechanic_Type__c = EUR_DE_Visibility_Branding.Id, EUR_CRM_Contract__c = contract.Id));
        activityItems.add(new EUR_CRM_Contract_Activity_Item__c(EUR_CRM_Amount__c = 5, EUR_CRM_Mechanic_Type__c = EUR_DE_Visibility_Branding.Id, EUR_CRM_Contract__c = contract.Id));

        activityItems.add(new EUR_CRM_Contract_Activity_Item__c(EUR_CRM_Amount__c = 6, EUR_CRM_Mechanic_Type__c = EUR_DE_POS_WKZ.Id, EUR_CRM_Contract__c = contract.Id));
        activityItems.add(new EUR_CRM_Contract_Activity_Item__c(EUR_CRM_Amount__c = 6, EUR_CRM_Mechanic_Type__c = EUR_DE_POS_WKZ.Id, EUR_CRM_Contract__c = contract.Id));

        activityItems.add(new EUR_CRM_Contract_Activity_Item__c(EUR_CRM_Amount__c = 7, EUR_CRM_Mechanic_Type__c = EUR_DE_POS_Material.Id, EUR_CRM_Contract__c = contract.Id));
        activityItems.add(new EUR_CRM_Contract_Activity_Item__c(EUR_CRM_Amount__c = 7, EUR_CRM_Mechanic_Type__c = EUR_DE_POS_Material.Id, EUR_CRM_Contract__c = contract.Id));

        activityItems.add(new EUR_CRM_Contract_Activity_Item__c(EUR_CRM_Amount__c = 8, EUR_CRM_Mechanic_Type__c = EUR_DE_Napkins.Id, EUR_CRM_Contract__c = contract.Id));
        activityItems.add(new EUR_CRM_Contract_Activity_Item__c(EUR_CRM_Amount__c = 8, EUR_CRM_Mechanic_Type__c = EUR_DE_Napkins.Id, EUR_CRM_Contract__c = contract.Id));

        activityItems.add(new EUR_CRM_Contract_Activity_Item__c(EUR_CRM_Amount__c = 9, EUR_CRM_Mechanic_Type__c = EUR_DE_Training.Id, EUR_CRM_Contract__c = contract.Id));
        activityItems.add(new EUR_CRM_Contract_Activity_Item__c(EUR_CRM_Amount__c = 9, EUR_CRM_Mechanic_Type__c = EUR_DE_Training.Id, EUR_CRM_Contract__c = contract.Id));

        activityItems.add(new EUR_CRM_Contract_Activity_Item__c(EUR_CRM_Amount__c = 10, EUR_CRM_Mechanic_Type__c = EUR_DE_Others.Id, EUR_CRM_Exclude_Budget_Deduction__c = true, EUR_CRM_Contract__c = contract.Id));
        activityItems.add(new EUR_CRM_Contract_Activity_Item__c(EUR_CRM_Amount__c = 10, EUR_CRM_Mechanic_Type__c = EUR_DE_Others.Id, EUR_CRM_Exclude_Budget_Deduction__c = true, EUR_CRM_Contract__c = contract.Id));

        activityItems.add(new EUR_CRM_Contract_Activity_Item__c(EUR_CRM_Amount__c = 11, EUR_CRM_Mechanic_Type__c = EUR_DE_Others.Id, EUR_CRM_Exclude_Budget_Deduction__c = false, EUR_CRM_Contract__c = contract.Id));
        activityItems.add(new EUR_CRM_Contract_Activity_Item__c(EUR_CRM_Amount__c = 11, EUR_CRM_Mechanic_Type__c = EUR_DE_Others.Id, EUR_CRM_Exclude_Budget_Deduction__c = false, EUR_CRM_Contract__c = contract.Id));
        insert activityItems;
    }

    @isTest
    private static void testPolulationRollupFields() {
        EUR_CRM_Contract__c contract = [
            SELECT Id,
                EUR_CRM_WKZ_Fix_Amount__c,
                EUR_CRM_Drinks_Menu__c,
                EUR_CRM_Non_PRD_Events__c,
                EUR_CRM_PRD_Events__c,
                EUR_CRM_Visibility_Branding__c,
                EUR_CRM_POS_WKZ__c,
                EUR_CRM_POS_Material__c,
                EUR_CRM_Napkins__c,
                EUR_CRM_Training__c,
                EUR_CRM_Others_PRD__c,
                EUR_CRM_Others__c
            FROM EUR_CRM_Contract__c
            WHERE EUR_CRM_Status__c = 'Draft'
            LIMIT 1
        ];
        System.assertEquals(2, contract.EUR_CRM_WKZ_Fix_Amount__c);
        System.assertEquals(4, contract.EUR_CRM_Drinks_Menu__c);
        System.assertEquals(6, contract.EUR_CRM_Non_PRD_Events__c);
        System.assertEquals(8, contract.EUR_CRM_PRD_Events__c);
        System.assertEquals(10, contract.EUR_CRM_Visibility_Branding__c);
        System.assertEquals(12, contract.EUR_CRM_POS_WKZ__c);
        System.assertEquals(14, contract.EUR_CRM_POS_Material__c);
        System.assertEquals(16, contract.EUR_CRM_Napkins__c);
        System.assertEquals(18, contract.EUR_CRM_Training__c);
        System.assertEquals(20, contract.EUR_CRM_Others_PRD__c);
        System.assertEquals(22, contract.EUR_CRM_Others__c);
    }

    @isTest
    private static void testUpdatingRollupFields() {
        EUR_CRM_Contract_Activity_Item__c cai = [SELECT Id, EUR_CRM_Amount__c FROM EUR_CRM_Contract_Activity_Item__c WHERE EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c = 'EUR_DE_WKZ_Fix_Amount' LIMIT 1];

        Test.startTest();
        cai.EUR_CRM_Amount__c += 100;
        update cai;
        Test.stopTest();

        EUR_CRM_Contract__c contract = [
                SELECT Id, EUR_CRM_WKZ_Fix_Amount__c
                FROM EUR_CRM_Contract__c
                WHERE EUR_CRM_Status__c = 'Draft'
                LIMIT 1
        ];
        System.assertEquals(102, contract.EUR_CRM_WKZ_Fix_Amount__c);
    }

    @isTest
    private static void testDecreasingRollupFields() {
        EUR_CRM_Contract_Activity_Item__c cai = [SELECT Id, EUR_CRM_Amount__c FROM EUR_CRM_Contract_Activity_Item__c WHERE EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c = 'EUR_DE_WKZ_Fix_Amount' LIMIT 1];

        Test.startTest();
        
        delete cai;
        System.assertEquals(1, [
            SELECT Id, EUR_CRM_WKZ_Fix_Amount__c
            FROM EUR_CRM_Contract__c
            WHERE EUR_CRM_Status__c = 'Draft'
            LIMIT 1
        ].EUR_CRM_WKZ_Fix_Amount__c);

        undelete cai;
        System.assertEquals(2, [
                SELECT Id, EUR_CRM_WKZ_Fix_Amount__c
                FROM EUR_CRM_Contract__c
                WHERE EUR_CRM_Status__c = 'Draft'
                LIMIT 1
        ].EUR_CRM_WKZ_Fix_Amount__c);

        Test.stopTest();
    }

}