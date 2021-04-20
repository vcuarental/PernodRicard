/*
*    CAPEX/OPEX
*/
@isTest
public class ASI_MFM_CAP_Budget_Test {

    static testMethod void testBudgetTrigger()
    {
        ASI_MFM_Budget__c budget = ASI_MFM_CAP_TestClassHelper.createBudget();
    }

}