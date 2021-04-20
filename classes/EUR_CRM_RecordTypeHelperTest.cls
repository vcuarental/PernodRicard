/**
*   Test class for EUR_CRM_RecordTypeHelper
*
*
**/
@isTest
public class EUR_CRM_RecordTypeHelperTest {

    /**
    *   TestMethod: testRecordTypeHelper
    *   
    *   Smoke test for all Maps and Lists stored in EUR_CRM_RecordTypeHelper
    **/
    static testMethod void testRecordTypeHelper() {
        EUR_CRM_RecordTypeHelper helper = new EUR_CRM_RecordTypeHelper();
        
        EUR_CRM_RecordTypeHelper.getGroupOutletControllerExt_outletRecordType('EUR_LT_Group_Outlet');
        EUR_CRM_RecordTypeHelper.getProsSegmentationExtCombined_RenderInfo('LT');
        EUR_CRM_RecordTypeHelper.getProsSegmentationExt_FlowInfo('LT');
        EUR_CRM_RecordTypeHelper.getAccountProsSegController_isServicePackRendered('LT');
        EUR_CRM_RecordTypeHelper.getGroupOutletControllerExt_outletRecordType('EUR_LT_Group_Outlet');
        EUR_CRM_RecordTypeHelper.getAccountCreatePRSegHandler_RecordTypeId('EUR_PRS_Segmentation_Off_Trade');
        EUR_CRM_RecordTypeHelper.getProsSegmentationExtCombined_RenderInfo('RU');
        EUR_CRM_RecordTypeHelper.getProsSegmentationExt_FlowInfo('RU');
        //EUR_CRM_RecordTypeHelper.getAssignAccountOwnerHandler_initTerritoryMap()
        //EUR_CRM_RecordTypeHelper.getAssignAccoutnOwnerHandler_ownerId()
    }

    @IsTest
    private static void EUR_CRM_AccountTriggerHandler_deleteAccount_Test() {
        EUR_CRM_Account__c acc = new EUR_CRM_Account__c(
                Name = 'Test acc'
            ,   EUR_CRM_Postal_Code__c = '0000'
        );
        insert acc;

        delete acc;

    }

}