@isTest
public class EUR_CRM_TestObjPromoTargetQuotaHandler {
	
    public static testmethod void testObjPromoTarget() {
        EUR_CRM_OP_Action_List_Template__c opActionListTemplate = EUR_CRM_DK_TestClassHelper.createActionListTemplate();
        insert opActionListTemplate;
        
        EUR_CRM_ObjPromo__c objPromo = EUR_CRM_DK_TestClassHelper.createObjPromo(1, 'EUR_DK_Off_Trade_Leaflet_Campaign', 'Testing', opActionListTemplate)[0];
        objPromo.EUR_CRM_Is_Quota__c = true;
        insert objPromo;
        
        Id recordtypeId = EUR_CRM_DK_TestClassHelper.getRecordTypeId('EUR_CRM_ObjPromo_Target__c', 'EUR_DK_Objective_Product');
        EUR_CRM_ObjPromo_Target__c opTarget = new EUR_CRM_ObjPromo_Target__c();
        opTarget.RecordTypeId = recordtypeId;
        opTarget.EUR_CRM_ObjPromo__c = objPromo.Id;
        insert opTarget;
        update opTarget;
    }
    
}