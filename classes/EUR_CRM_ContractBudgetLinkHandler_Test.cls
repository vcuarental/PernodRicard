@IsTest(IsParallel = true)
private class EUR_CRM_ContractBudgetLinkHandler_Test {

    @IsTest
    private static void ZA_Contract_AfterInsert() {
        EUR_CRM_Account__c account = makeAccount();
        insert account;

        EUR_CRM_Budget__c budget = makeBudget();
        budget.EUR_CRM_Fiscal_Year__c = 'FY' + String.valueOf(Date.today().year()).substring(2);
        budget.OwnerId = UserInfo.getUserId();
        insert budget;

        EUR_CRM_Contract__c contract = makeContract(account.Id, 'EUR_ZA_Head_Office_Contract');
        contract.EUR_CRM_Start_Date__c = Date.today();
        contract.EUR_CRM_End_Date__c = Date.today().addMonths(1);
        insert contract;

        List<EUR_CRM_Contract__c> insertedContracts = selectContracts();
        System.debug('\n insertedContracts.size() => ' + insertedContracts.size() + '\n');
        System.debug('\n insertedContracts => ' + JSON.serializePretty(insertedContracts) + '\n');

        System.assertEquals(budget.Id, insertedContracts[0].EUR_CRM_Budget__c);
    }

    @IsTest
    private static void ZA_Contract_AfterUpdate() {
        EUR_CRM_Account__c account = makeAccount();
        insert account;

        EUR_CRM_Budget__c budget = makeBudget();
        budget.EUR_CRM_Fiscal_Year__c = 'FY' + String.valueOf(Date.today().year()).substring(2);
        budget.OwnerId = UserInfo.getUserId();
        insert budget;

        EUR_CRM_Contract__c contract = makeContract(account.Id, 'EUR_ZA_Head_Office_Contract');
        contract.EUR_CRM_Start_Date__c = Date.today();
        contract.EUR_CRM_End_Date__c = Date.today().addMonths(1);
        insert contract;

        contract.EUR_CRM_Start_Date__c = Date.today().addDays(5);
        update contract;

        List<EUR_CRM_Contract__c> insertedContracts = selectContracts();
        System.debug('\n insertedContracts.size() => ' + insertedContracts.size() + '\n');
        System.debug('\n insertedContracts => ' + JSON.serializePretty(insertedContracts) + '\n');

        System.assertEquals(budget.Id, insertedContracts[0].EUR_CRM_Budget__c);
    }


    /* ========================================================= */
    /*      Makers
	/* ========================================================= */
    private static EUR_CRM_Account__c makeAccount() {
        return new EUR_CRM_Account__c(
            EUR_CRM_Postal_Code__c = '112233'
        );
    }

    private static EUR_CRM_Contract__c makeContract(Id accId, String rt) {
        Id rtId = Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
        return new EUR_CRM_Contract__c(
            RecordTypeId = rtId
            ,	EUR_CRM_Account__c = accId
        );
    }

    private static EUR_CRM_Budget__c makeBudget() {
        return new EUR_CRM_Budget__c();
    }


    /* ========================================================= */
    /*      SOQL Selectors
	/* ========================================================= */
    private static List<EUR_CRM_Contract__c> selectContracts() {
        return [
            SELECT Id
                ,	EUR_CRM_Budget__c
                ,	EUR_CRM_Country_Code__c
                ,	EUR_CRM_Start_Date__c
                ,	EUR_CRM_Budget__r.EUR_CRM_Fiscal_Year__c
            FROM EUR_CRM_Contract__c
        ];
    }
}