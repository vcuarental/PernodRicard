@isTest
public class ASI_JP_TnE_ObjectPickListHelperTest
{
    
    
    
    public static testMethod void testASI_JP_TnE_ObjectPickListHelperWithLang()
    {
       ASI_JP_TnE_TestClassHelper.createExpenseClassTestData();
       
       ASI_JP_TnE_ObjectPickListHelper objectPickListHelper = new ASI_JP_TnE_ObjectPickListHelper('ASI_TnE_ClaimDetail__c',
        'ASI_TnE_Expense_Classification__c','ASI_JP_TnE_Expense_Category__c','en_US','en_US');
       
       System.assert(objectPickListHelper.dependentExpenseCategoryClassificationMap != null,' Error: Null');
       System.assert(objectPickListHelper.dependentMap != null,' Error: Null') ;
       System.assert(objectPickListHelper.pickList != null,' Error: Null');           

    }
        
    public static testMethod void testASI_JP_TnE_ObjectPickListHelper()
    {
            new ASI_JP_TnE_ObjectPickListHelper('ASI_TnE_ClaimDetail__c',
        'ASI_TnE_Expense_Classification__c');
    }

}