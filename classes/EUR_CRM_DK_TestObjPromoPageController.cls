@isTest
public class EUR_CRM_DK_TestObjPromoPageController {

    public static testmethod void testObjPromoPageController() {
        EUR_CRM_Account__c acc = EUR_CRM_DK_TestClassHelper.createEUAccountsDKOFF('Testing');
        insert acc;
        
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
        
        Id recordtypeId2 = EUR_CRM_DK_TestClassHelper.getRecordTypeId('EUR_CRM_ObjPromo_Target__c', 'EUR_DK_Manager_Volume_Target');
        EUR_CRM_ObjPromo_Target__c opTarget2 = new EUR_CRM_ObjPromo_Target__c();
        opTarget2.RecordTypeId = recordtypeId2;
        opTarget2.EUR_CRM_ObjPromo__c = objPromo.Id;
        opTarget2.EUR_CRM_O_P_Target__c = opTarget.Id;
        insert opTarget2;
        
        Test.startTest();
        	ApexPages.StandardController stdController = new ApexPages.StandardController(objPromo);
        	EUR_CRM_DK_ObjectivePromoPageController controller = new EUR_CRM_DK_ObjectivePromoPageController(stdController);
        	
        	controller.getActions();
        	controller.getOPStatus();
        	controller.getIsTargetsRendered();
        	controller.getIsSize();
        	controller.getIsSKU();
        	controller.publishOP();
        
        	controller.targetWraps[0].getHasChild();
        Test.stopTest();
    }
    
}