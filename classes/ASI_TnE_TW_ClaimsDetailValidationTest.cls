@isTest
public class ASI_TnE_TW_ClaimsDetailValidationTest {
   private static testMethod void testInsert() {

        ASI_TnE_ClaimHeader__c headerInstance = ASI_TnE_TW_TestClassHelper.createClaimHeader();
        
        ASI_JP_TnE_Expense_Category__c category = 
            ASI_TnE_TW_TestClassHelper.createExpenseCategory('ASI_JP_TnE_Expense_Category__cASI_TnE_TW_Expense_Category');
        
        ASI_JP_TnE_Expense_Classification__c classification = ASI_TnE_TW_TestClassHelper.createExpenseCls(
            'ASI_JP_TnE_Expense_Classification__cASI_TnE_TW_Expense_Classification',
            category,
            ASI_TnE_TW_TestClassHelper.createAccMap('ASI_TnE_Account_Mapping__cASI_TnE_TW_Account_Mapping')
        );
        
        System.Test.startTest();

           ASI_TnE_ClaimDetail__c detailInstance = ASI_TnE_TW_TestClassHelper.createClaimDetail(
                headerInstance.Id,
                'ASI_TnE_ClaimDetail__cASI_TnE_TW_Claim_Detail',
                classification
            );

       System.Test.stopTest();

       List<ASI_TnE_ClaimDetail__c> detailList = [
           SELECT Id,
                  ASI_TnE_KR_Receipt_Time__c
             FROM ASI_TnE_ClaimDetail__c
            WHERE Id = :detailInstance.Id
       ];

       System.assertNotEquals(NULL, detailList[0].ASI_TnE_KR_Receipt_Time__c);
       System.assertEquals(TRUE, String.valueOf(detailList[0].ASI_TnE_KR_Receipt_Time__c).containsIgnoreCase(UserInfo.getUserId()));
   }
   
   private static testMethod void testUpdate() {

        ASI_TnE_ClaimHeader__c headerInstance = ASI_TnE_TW_TestClassHelper.createClaimHeader();

        ASI_JP_TnE_Expense_Category__c category = 
            ASI_TnE_TW_TestClassHelper.createExpenseCategory('ASI_JP_TnE_Expense_Category__cASI_TnE_TW_Expense_Category');

        ASI_JP_TnE_Expense_Classification__c classification = ASI_TnE_TW_TestClassHelper.createExpenseCls(
            'ASI_JP_TnE_Expense_Classification__cASI_TnE_TW_Expense_Classification',
            category,
            ASI_TnE_TW_TestClassHelper.createAccMap('ASI_TnE_Account_Mapping__cASI_TnE_TW_Account_Mapping')
        );

       System.Test.startTest();

           ASI_TnE_ClaimDetail__c detailInstance = ASI_TnE_TW_TestClassHelper.createClaimDetail(
               headerInstance.Id,
               'ASI_TnE_ClaimDetail__cASI_TnE_TW_Claim_Detail',
               classification
           );
           detailInstance.ASI_TnE_Receipt_Date__c = Date.today().addDays(30);
           update detailInstance;

       System.Test.stopTest();

       List<ASI_TnE_ClaimDetail__c> detailList = [
           SELECT Id,
                  ASI_TnE_KR_Receipt_Time__c
             FROM ASI_TnE_ClaimDetail__c
            WHERE Id = :detailInstance.Id
       ];

       System.assertNotEquals(NULL, detailList[0].ASI_TnE_KR_Receipt_Time__c);
       System.assertEquals(TRUE, String.valueOf(detailList[0].ASI_TnE_KR_Receipt_Time__c).containsIgnoreCase(UserInfo.getUserId()));
   }
}