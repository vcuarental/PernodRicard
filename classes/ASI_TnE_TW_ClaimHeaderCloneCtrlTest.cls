@isTest
public class ASI_TnE_TW_ClaimHeaderCloneCtrlTest {
   private static testMethod void testCloneWithDetails() {

        ASI_TnE_ClaimHeader__c headerInstance = ASI_TnE_TW_TestClassHelper.createClaimHeader();
        
        ASI_JP_TnE_Expense_Category__c category = 
            ASI_TnE_TW_TestClassHelper.createExpenseCategory('ASI_JP_TnE_Expense_Category__cASI_TnE_TW_Expense_Category');
        
        ASI_JP_TnE_Expense_Classification__c classification = ASI_TnE_TW_TestClassHelper.createExpenseCls(
            'ASI_JP_TnE_Expense_Classification__cASI_TnE_TW_Expense_Classification',
            category,
            ASI_TnE_TW_TestClassHelper.createAccMap('ASI_TnE_Account_Mapping__cASI_TnE_TW_Account_Mapping')
        );
        
        ASI_TnE_ClaimDetail__c detailInstance = ASI_TnE_TW_TestClassHelper.createClaimDetail(
            headerInstance.Id,
            'ASI_TnE_ClaimDetail__cASI_TnE_TW_Claim_Detail',
            classification
        );
        
        Test.setCurrentPage(Page.ASI_TnE_TW_ClaimHeaderClonePage);
        ApexPages.currentPage().getParameters().put('id', headerInstance.Id);

        ApexPages.StandardController controller = new ApexPages.StandardController(headerInstance);
        ASI_TnE_TW_ClaimHeaderCloneController controllerInstance = new ASI_TnE_TW_ClaimHeaderCloneController(controller);

        System.Test.startTest();
            controllerInstance.cloneTnE();
        System.Test.stopTest();

        List<ASI_TnE_ClaimDetail__c> detailList = [
            SELECT Id
              FROM ASI_TnE_ClaimDetail__c
        ];

        List<ASI_TnE_ClaimHeader__c> headerList = [
            SELECT Id
              FROM ASI_TnE_ClaimHeader__c
        ];

        System.assertEquals(2, detailList.size());
        System.assertEquals(2, headerList.size());
    }

   private static testMethod void testCloneWithoutDetails() {

        ASI_TnE_ClaimHeader__c headerInstance = ASI_TnE_TW_TestClassHelper.createClaimHeader();

        Test.setCurrentPage(Page.ASI_TnE_TW_ClaimHeaderClonePage);
        ApexPages.currentPage().getParameters().put('id', headerInstance.Id);

        ApexPages.StandardController controller = new ApexPages.StandardController(headerInstance);
        ASI_TnE_TW_ClaimHeaderCloneController controllerInstance = new ASI_TnE_TW_ClaimHeaderCloneController(controller);

        System.Test.startTest();
            controllerInstance.cloneTnE();
        System.Test.stopTest();

        List<ASI_TnE_ClaimHeader__c> headerList = [
            SELECT Id
              FROM ASI_TnE_ClaimHeader__c
        ];
        
        System.assertEquals(2, headerList.size());
    }

}