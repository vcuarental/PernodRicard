/*
  @Company:     IP-Converge Data Services, Inc.
  @Description: Test Class for EUR_CRM_DE_ContractApprovedHandler Class.
  @Author:      IPC
  @History:     July 2014 - Created
*/
@isTest
private with sharing class EUR_CRM_DE_TestContractApprovedHandler{
    private static final Integer COUNT_OF_RECORDS = 5;

    @TestSetup
    private static void setup() {
        EUR_CRM_Account__c account = makeAccount();
        insert account;

        EUR_CRM_Budget__c budget = makeBudget();
        budget.EUR_CRM_Fiscal_Year__c = 'FY' + String.valueOf(Date.today().year()).substring(2);
        budget.OwnerId = UserInfo.getUserId();
        insert budget;


        EUR_CRM_Contract__c contract = makeContract(account.Id, 'EUR_ZA_Head_Office_Contract');
        contract.EUR_CRM_Start_Date__c = Date.today();
        contract.EUR_CRM_End_Date__c = Date.today().addMonths(2);
        contract.EUR_CRM_Budget__c = budget.Id;

        EUR_CRM_Contract__c contract2 = makeContract(account.Id, 'EUR_ZA_Head_Office_Contract');
        contract2.EUR_CRM_Start_Date__c = Date.today();
        contract2.EUR_CRM_End_Date__c = Date.today().addMonths(2);
        insert new List<EUR_CRM_Contract__c>{ contract, contract2 };

        List<EUR_CRM_Mechanic_Type__c> mts = makeMTs();
        insert mts;

        EUR_CRM_Budget_Transaction__c budgetTrans = makeBudgetTrans('EUR_ZA_On_Trade_Draft_Transaction');
        budgetTrans.EUR_CRM_Contract__c = contract.Id;
        budgetTrans.EUR_CRM_Budget_Header__c = budget.Id;
        budgetTrans.EUR_CRM_Transaction_Category__c = new EUR_CRM_ContractDraftTransactionHandler().DRAFT_CONTRACT_TRANSACTION;
        insert budgetTrans;

        EUR_CRM_Budget_Transaction__c budgetTrans2 = makeBudgetTrans('EUR_ZA_On_Trade_Draft_Transaction');
        budgetTrans2.EUR_CRM_Budget_Header__c = budget.Id;
        budgetTrans2.EUR_CRM_Transaction_Category__c = new EUR_CRM_ContractDraftTransactionHandler().DRAFT_CONTRACT_TRANSACTION;
        insert budgetTrans2;

        List<EUR_CRM_Contract_Activity_Item__c> cais = makeCAIs(mts, contract, 'EUR_ZA_Contract_Activity_Item');
        insert cais;
    }
    @IsTest
    private static void ZA_ContractApproved_AfterUpdate_SimpleTest() {

        Test.startTest();
        List<EUR_CRM_Contract__c> insertedContracts = selectContracts();
        System.debug('\n insertedContracts.size() => ' + insertedContracts.size() + '\n');
        System.debug('\n insertedContracts => ' + JSON.serializePretty(insertedContracts) + '\n');
        insertedContracts[0].EUR_CRM_Budget__c = [SELECT Id FROM EUR_CRM_Budget__c LIMIT 1].Id;
        insertedContracts[0].EUR_CRM_Status__c = 'Approved';
        insertedContracts[0].EUR_CRM_Contract_Approved_Date__c = Date.today();
        update insertedContracts[0];
        Test.stopTest();

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

    private static EUR_CRM_Budget_Transaction__c makeBudgetTrans(String rt) {
        Id rtId = Schema.SObjectType.EUR_CRM_Budget_Transaction__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
        return new EUR_CRM_Budget_Transaction__c(
                RecordTypeId = rtId
        );
    }

    private static List<EUR_CRM_Mechanic_Type__c> makeMTs() {
        List<EUR_CRM_Mechanic_Type__c> mts = new List<EUR_CRM_Mechanic_Type__c>();
        for (Integer i = 0; i < COUNT_OF_RECORDS; i++) {
            mts.add(new EUR_CRM_Mechanic_Type__c(
                    Name = 'Test' + i
                    ,	EUR_CRM_Is_Pro_Rated_by_Month__c = true
            ));
        }
        return mts;
    }

    private static List<EUR_CRM_Contract_Activity_Item__c> makeCAIs(List<EUR_CRM_Mechanic_Type__c> mts, EUR_CRM_Contract__c contract, String rt) {
        List<EUR_CRM_Contract_Activity_Item__c> cais = new List<EUR_CRM_Contract_Activity_Item__c>();
        for (Integer i = 0; i < COUNT_OF_RECORDS; i++) {
            EUR_CRM_Contract_Activity_Item__c cai = makeCAI(rt);
            cai.EUR_CRM_Contract__c = contract.Id;
            cai.EUR_CRM_Mechanic_Type__c = mts.get(i).Id;
            cai.EUR_CRM_Amount__c = 100 + i * 10;
            cais.add(cai);
        }
        return cais;
    }

    private static EUR_CRM_Contract_Activity_Item__c makeCAI(String rt) {
        Id rtId = Schema.SObjectType.EUR_CRM_Contract_Activity_Item__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
        return new EUR_CRM_Contract_Activity_Item__c(
                RecordTypeId = rtId
        );
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
                        ,	EUR_CRM_End_Date__c
                        ,	EUR_CRM_Budget__r.EUR_CRM_Fiscal_Year__c
                FROM EUR_CRM_Contract__c
        ];
    }
}