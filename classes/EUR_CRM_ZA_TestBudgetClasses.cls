@isTest
public class EUR_CRM_ZA_TestBudgetClasses {

    private static User eurSysUser;
    private static User subEurSysUser;

    private static EUR_CRM_Budget__c budget;
    private static EUR_CRM_Budget__c subBudget;
    private static List<EUR_CRM_Budget__c> budgetList;

    private static List<EUR_CRM_Budget_Transaction__c> transactCredit;
    private static List<EUR_CRM_Budget_Transaction__c> transactDebit;
    private static List<EUR_CRM_Budget_Transaction__c> transactCreditSub;

    private static Profile p;
    private static UserRole r;

    static void setupData(){
        p = [SELECT Id FROM Profile WHERE Name ='EUR System Admin']; 
        r = [select id from UserRole where Developername ='EMEA'];
        eurSysUser = new User(Alias = 'standt', Email='testBudgetControllers@test.com', UserRoleId=r.id,
        EmailEncodingKey='UTF-8', LastName='testBudgetControllersLastName', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='testBudgetControllers@test.com');
        insert eurSysUser;

        r = [select id from UserRole where Developername ='EUR_SSA'];
        subEurSysUser = new User(Alias = 'standt', Email='testBudgetControllers2@test.com', UserRoleId=r.id,
        EmailEncodingKey='UTF-8', LastName='testBudgetControllers2LastName', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='testBudgetControllers2@test.com');
        insert subEurSysUser;

        // Budgets and subBudgets
        budgetList = EUR_CRM_ZA_TestClassHelper.createBudget(3);
        budget = budgetList[0];
        budget.OwnerId = eurSysUser.Id;
        budget.EUR_CRM_Allocated_Budget__c = 2000.00;
        budget.EUR_CRM_Carry_Forward__c = 0.00;
        budget.EUR_CRM_Fiscal_Year__c = 'FY15';

        subBudget = budgetList[1];
        subBudget.OwnerId = subEurSysUser.Id;
        subBudget.EUR_CRM_Allocated_Budget__c = 1000.00;
        subBudget.EUR_CRM_Carry_Forward__c = 0.00;
        subBudget.EUR_CRM_Fiscal_Year__c = 'FY15';
    }

    static testMethod void testBudgetRedirectController(){
        setupData();
        Test.startTest();
            System.runAs(eurSysUser){
                insert budget;
            }
            System.runAs(subEurSysUser){
                insert subBudget;
            }
            ApexPages.StandardController std = new ApexPages.StandardController(budget);
            // Budget Redirect Controller
            EUR_CRM_Budget_Redirect_Controller redirectCnt = new EUR_CRM_Budget_Redirect_Controller(std);
            PageReference pg = redirectCnt.redirect();
            System.assertEquals('/apex/EUR_CRM_BudgetSummaryPage?id=' + budget.Id, pg.getUrl()); 
        Test.stopTest();
    }

    static testMethod void testBudgetSummaryController(){
        setupData();
        Test.startTest();
            System.runAs(eurSysUser){
                insert budget;
            }
            ApexPages.StandardController std = new ApexPages.StandardController(budget);
            // Budget Summary Controller
            EUR_CRM_BudgetSummaryController summaryCnt = new EUR_CRM_BudgetSummaryController(std);
            String fy = summaryCnt.currentFY;
        Test.stopTest();
    }
    

    static testMethod void testBudgetTransferController(){
        setupData();

        User subEurSysUser2 = new User(Alias = 'standt', Email='testBudgetControllers3@test.com', UserRoleId=r.id,
        EmailEncodingKey='UTF-8', LastName='testBudgetControllers3LastName', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='testBudgetControllers3@test.com');
        insert subEurSysUser2;

        // Budgets and subBudgets
        EUR_CRM_Budget__c subBudget2 = budgetList[2];
        subBudget2.OwnerId = subEurSysUser2.Id;
        subBudget2.EUR_CRM_Allocated_Budget__c = 2000.00;
        subBudget2.EUR_CRM_Carry_Forward__c = 0.00;
        subBudget2.EUR_CRM_Fiscal_Year__c = 'FY15';


        Test.startTest();
            System.runAs(eurSysUser){
                insert budget;
            }
            // Empty transactions
            ApexPages.StandardController std1 = new ApexPages.StandardController(budget);
            // Budget Transfer Controller
            EUR_CRM_BudgetTransferController transferCnt1 = new EUR_CRM_BudgetTransferController(std1);
            transferCnt1.save();

            System.runAs(subEurSysUser){
                insert subBudget;
            }
            System.runAs(subEurSysUser2){
                insert subBudget2;
            }

            System.runAs(eurSysUser){              
                transactCredit = EUR_CRM_ZA_TestClassHelper.createBudgetTransactions('EUR_ZA_On_Trade_Transaction', budget.Id, 3, 10.00,'Initial Load', 'Credit');
                insert transactCredit;
                
                transactDebit = EUR_CRM_ZA_TestClassHelper.createBudgetTransactions('EUR_ZA_On_Trade_Transaction', budget.Id, 1, 10.00,'Transfer', 'Debit');
                insert transactDebit;

                transactCreditSub = EUR_CRM_ZA_TestClassHelper.createBudgetTransactions('EUR_ZA_On_Trade_Transaction', subBudget.Id, 1, 20.00,'Initial Load', 'Credit');
                transactCreditSub[0].EUR_CRM_Transfer_From__c = subEurSysUser.Id;
                insert transactCreditSub;
            }

            // Empty transactions
            ApexPages.StandardController std2 = new ApexPages.StandardController(budget);
            // Budget Transfer Controller
            EUR_CRM_BudgetTransferController transferCnt2 = new EUR_CRM_BudgetTransferController(std2);
            Double runningBalanceTo = transferCnt2.runningBalanceTo;
            
            transferCnt2.budgetTransactionFrom.EUR_CRM_Transfer_From__c = subEurSysUser.Id;
            transferCnt2.budgetTransactionFrom.EUR_CRM_Transfer_To__c = subEurSysUser2.Id;
            transferCnt2.budgetTransactionFrom.EUR_CRM_Amount__c = 30.00;
            
            transferCnt2.budgetFromOnChange();
            transferCnt2.budgetToOnChange();
            
            List<SelectOption> transfereeOptions = transferCnt2.transfereeOptions;
            List<SelectOption> transferorOptions = transferCnt2.transferorOptions;
            
            transferCnt2.retrieveUserOptions();
            transferCnt2.quickSave();
            transferCnt2.save();
        Test.stopTest();
    }
}