@isTest
public class EUR_CRM_PT_AssignOPTargetActNoBatTest {
    @testSetUp static void initData(){
        
        EUR_CRM_Category__c categoryPT = EUR_CRM_PT_TestClassHelper.createCategory('EUR_PT_Category');
        insert categoryPT;
        
        EUR_CRM_Brand__c brand = EUR_CRM_PT_TestClassHelper.createBrand('Test Name', categoryPT);
        insert brand;
        
        EUR_CRM_OP_Action_List_Template__c testTemplate = EUR_CRM_PT_TestClassHelper.createActionListTemplate();
        insert testTemplate;
        
        EUR_CRM_ObjPromo__c objectPromo = EUR_CRM_PT_TestClassHelper.createObjPromo(1,'EUR_PT_Off_Trade_OP_No_of_Display','test ObjPromo',testTemplate).get(0);
        insert objectPromo;
        
        EUR_CRM_Account__c euAccount = EUR_CRM_PT_TestClassHelper.createEUAccount('testAccount');
        insert euAccount;
        
        Id visitPlanRtId = Global_RecordTypeCache.getRtId('EUR_CRM_Visit_Action__c'+ 'EUR_PT_Off_Trade_SR_To_Check_No_of_Display');
        EUR_CRM_Visit_Action__c visitPlanPT = EUR_CRM_PT_TestClassHelper.createVisitAction(euAccount,objectPromo);
        visitPlanPT.recordTypeId = visitPlanRtId;
        visitPlanPT.EUR_CRM_Actual_No_of_Display__c = 10;
        visitPlanPT.EUR_CRM_Brand__c = brand.Id;
        insert visitPlanPT;
        
        List<EUR_CRM_ObjPromo_Target__c> objectPromoTargetAccountList = EUR_CRM_PT_TestClassHelper.createOPTarget(5,'EUR_PT_Off_Trade_OP_Target_per_Account', objectPromo.Id, null, euAccount.Id, brand.Id);
        insert objectPromoTargetAccountList;
        
        List<EUR_CRM_ObjPromo_Target__c> objectPromoTargetBrandList = EUR_CRM_PT_TestClassHelper.createOPTarget(5,'EUR_PT_Off_Trade_OP_Target_per_Brand', objectPromo.Id, null, euAccount.Id, brand.Id);
        insert objectPromoTargetBrandList;
        
    }
    
    static testMethod void test1(){        
        Test.startTest();
        EUR_CRM_PT_AssignOPTargetActualNoBatch batch = new EUR_CRM_PT_AssignOPTargetActualNoBatch();
        Database.executeBatch(batch);
        Test.stopTest();        
    }
}