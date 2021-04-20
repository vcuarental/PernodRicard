@isTest
public class EUR_CRM_DE_TestContract_BeforeDelete{
    private static EUR_CRM_Account__c accountEU;
    private static EUR_CRM_Contract__c contract;
    private static EUR_CRM_Contract__c contract2;
    private static EUR_CRM_Budget__c budget;
    private static String FY_STR = 'FY15';
    private static String EXTERNAL_ID = 'TEST_'+FY_STR;
    private static Decimal ALLOCATED_BUDGET = 10000;
    private static Decimal CARRY_FWD = 0;
    private static EUR_CRM_Budget_Transaction__c initialLoadTransaction;
    private static EUR_CRM_Budget_Transaction__c initialLoadTransaction2;

/* Hidden by Laputa Hugo Cheung 26/09/2016
    static void dataInsert1(){
        //Create account
        EUR_CRM_DE_TestClassUtilityHelper.initData();
        accountEU = EUR_CRM_DE_TestClassUtilityHelper.euAccount;

         //Create Contract
        contract = EUR_CRM_TestClassUtilityHelper.createContracts(1, EUR_CRM_DE_TestClassUtilityHelper.DE_CONTRACT_RECORD_TYPE, accountEU.Id, date.today(), date.today().addDays(30))[0];
        insert contract;

        contract2 = EUR_CRM_TestClassUtilityHelper.createContracts(1, EUR_CRM_DE_TestClassUtilityHelper.DE_CONTRACT_RECORD_TYPE, accountEU.Id, date.today(), date.today().addDays(30))[0];
        insert contract2;
        //Create Budget
        budget = EUR_CRM_DE_TestClassUtilityHelper.createBudget(EUR_CRM_DE_TestClassUtilityHelper.DE_BUDGET_RECORD_TYPE,
                                                    UserInfo.getUserId(), 
                                                    determineFiscalYear(contract.EUR_CRM_Start_Date__c), EXTERNAL_ID,
                                                    ALLOCATED_BUDGET, CARRY_FWD);
        insert budget;
        
        //Create Transaction Initial Budget Load
        initialLoadTransaction = EUR_CRM_DE_TestClassUtilityHelper.createBudgetInitialLoad('DE On Trade WKZ- Draft Transaction',
                                    budget.Id, 10000);
        initialLoadTransaction.EUR_CRM_Transaction_Category__c = 'Draft Contract Transaction';
        initialLoadTransaction.EUR_CRM_Contract__c = contract.id;
        insert initialLoadTransaction;

        initialLoadTransaction2 = EUR_CRM_DE_TestClassUtilityHelper.createBudgetInitialLoad('DE On Trade WKZ- Draft Transaction',
                                    budget.Id, 10000);
        initialLoadTransaction2.EUR_CRM_Transaction_Category__c = 'Draft Contract Transaction';
        initialLoadTransaction2.EUR_CRM_Contract__c = contract2.id;
        insert initialLoadTransaction2;


        delete contract;
        delete contract2;
    }
 */
    static testMethod void contractDeleteTest(){
        EUR_CRM_DE_TestClassUtilityHelper.initUsersOntrade();
        system.runAs(EUR_CRM_DE_TestClassUtilityHelper.regionalUser){
            
            test.StartTest();
                //Create account
                EUR_CRM_DE_TestClassUtilityHelper.initData();
                accountEU = EUR_CRM_DE_TestClassUtilityHelper.euAccount;
        
                 //Create Contract
                contract = EUR_CRM_TestClassUtilityHelper.createContracts(1, EUR_CRM_DE_TestClassUtilityHelper.DE_CONTRACT_RECORD_TYPE, accountEU.Id, date.today(), date.today().addDays(30))[0];
                insert contract;
        
                contract2 = EUR_CRM_TestClassUtilityHelper.createContracts(1, EUR_CRM_DE_TestClassUtilityHelper.DE_CONTRACT_RECORD_TYPE, accountEU.Id, date.today(), date.today().addDays(30))[0];
                insert contract2;
                //Create Budget
                budget = EUR_CRM_DE_TestClassUtilityHelper.createBudget(EUR_CRM_DE_TestClassUtilityHelper.DE_BUDGET_RECORD_TYPE,
                                                            UserInfo.getUserId(), 
                                                            determineFiscalYear(contract.EUR_CRM_Start_Date__c), EXTERNAL_ID,
                                                            ALLOCATED_BUDGET, CARRY_FWD);
                insert budget;
                
                //Create Transaction Initial Budget Load
                initialLoadTransaction = EUR_CRM_DE_TestClassUtilityHelper.createBudgetInitialLoad('DE On Trade WKZ- Draft Transaction',
                                            budget.Id, 10000);
                initialLoadTransaction.EUR_CRM_Transaction_Category__c = 'Draft Contract Transaction';
                initialLoadTransaction.EUR_CRM_Contract__c = contract.id;
                insert initialLoadTransaction;
        
                initialLoadTransaction2 = EUR_CRM_DE_TestClassUtilityHelper.createBudgetInitialLoad('DE On Trade WKZ- Draft Transaction',
                                            budget.Id, 10000);
                initialLoadTransaction2.EUR_CRM_Transaction_Category__c = 'Draft Contract Transaction';
                initialLoadTransaction2.EUR_CRM_Contract__c = contract2.id;
                insert initialLoadTransaction2;
        
            test.StopTest();
            delete contract;
            delete contract2;
        }    
    }

    static String determineFiscalYear(Date contractStartDate){
        if (contractStartDate != null){
        Integer contractYear = contractStartDate.year();
        Integer contractMonth = contractStartDate.month();

        Integer FiscalYearStartMonth = [select FiscalYearStartMonth from Organization where id=:Userinfo.getOrganizationId()].FiscalYearStartMonth;
        
        if (contractMonth>=FiscalYearStartMonth){
            return 'FY'+ String.valueOf(contractYear+1).substring(2);
        }else{
            return 'FY' + String.valueOf(contractYear).substring(2);
        }
        }
        return null;
    }
}