/*
 * Description : Apex Test class for ASI_CRM_VN_VisitationPlanDetailGenerator
 * 
 * Version        Date        Author          Description
 * 1.0            11/16/2015  Neha            Initial Draft
 */
@isTest

public class ASI_CRM_VN_VisitationPlanDetailGenTest{
    @testSetup
    public static void setupTestData(){
        // DC - 05/02/2016 - Created Running Number Data
        ASI_HK_CRM_Running_Number__c testRunningNumber = ASI_CRM_VN_TestDataFactory.getRunningNumber(
            system.Label.ASI_CRM_VN_Customer_Code,
            1,
            'VN-{YYYY}',
            date.today().month() + 2,
            Date.today().year()
        );
        insert testRunningNumber;  
    }
    
    public static testMethod void generateBasicPlanTest(){
        ASI_CRM_VN_VisitationPlanDetailGenerator objCtrl = new ASI_CRM_VN_VisitationPlanDetailGenerator();
        
        //Test record for Visitation Plan
        ASI_HK_CRM_Visitation_Plan__c testPlan = new ASI_HK_CRM_Visitation_Plan__c();
        insert testPlan;        
        
        //Test record for Account
        List<Account> accountList = ASI_CRM_VN_VisitationPlanDetailGenTest.createTestAccount(1);
        insert accountList;
        
        //Test record for Outlet Type
        List<ASI_TH_CRM_OutletType__c> outletTypeList = ASI_CRM_VN_VisitationPlanDetailGenTest.createTestOutletType(1);
        insert outletTypeList;                        
        
        //Create test record for Customers(ASI_CRM_AccountsAdditionalField__c)
        ASI_CRM_AccountsAdditionalField__c testCustomer = new ASI_CRM_AccountsAdditionalField__c(recordtypeid = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_VN_Outlet_Inactive'));
        testCustomer.Name = 'TestCustomer';
        testCustomer.ASI_CRM_Account__c = accountList[0].Id;
        testCustomer.ASI_TH_CRM_OutletType__c = outletTypeList[0].Id;
        insert testCustomer;                
        
        test.startTest();
            ASI_HK_CRM_Visitation_Plan_Detail__c objPlan = objCtrl.generateVisitationPlanDetail(testPlan, testCustomer, Date.today());
            System.assertNotEquals(Null, objPlan);
        test.stopTest();
    }
    
    //Create Test record for Account
    public static List<Account> createTestAccount(Integer pNumber){
        List<Account> accountList = new List<Account>();
        for(Integer i = 0; i < pNumber; i++){
            Account objAccount = new Account();
            objAccount.Name = 'TestAccount';
            accountList.add(objAccount);
        }
        return accountList;
    }
    
    //Create Test record for Outlet Type
    public static List<ASI_TH_CRM_OutletType__c> createTestOutletType(Integer pNumber){
        List<ASI_TH_CRM_OutletType__c> outletTypeList = new List<ASI_TH_CRM_OutletType__c>();
        for(Integer i = 0; i < pNumber; i++){
            ASI_TH_CRM_OutletType__c objOutlet = new ASI_TH_CRM_OutletType__c();
            objOutlet.ASI_TH_CRM_Code__c = '123' + i;
            outletTypeList.add(objOutlet);
        }
        return outletTypeList;
    }
}