/*********************************************************************************
 * Name:ASI_TnE_ClaimRejectionController_Test
 * Description: Test Class for ASI_TnE_ClaimRejectionController
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------
 * 11/05/2015       Laputa: Hank            Created
*********************************************************************************/
@isTest
private class ASI_TnE_ClaimRejectionController_Test {
    //For ASI_TnE_ClaimRejectionController
    static testMethod void ASI_TnE_ClaimRejectionController_Test() {
        ASI_TnE_TestClassHelper.createRunningNumbers();
        ASI_TnE_ClaimHeader__c header = ASI_TnE_TestClassHelper.createTestClaimHeader('1234567','ASI_TnE_ClaimHeader__cASI_TnE_SG_Claim_Header');
        ASI_TnE_ClaimDetail__c detail = ASI_TnE_TestClassHelper.createClaimDetail(header.Id, 'ASI_TnE_ClaimDetail__cASI_TnE_SG_Claim_Detail');
        
        test.startTest();
        ASI_TnE_ClaimRejectionController controller = new ASI_TnE_ClaimRejectionController();
        controller.currentHeaderId = header.Id;
        controller.getRelatedTo();
        controller.getApprovalSteps();
        test.stopTest();
    }
    
    
    //For ASI_TnE_Formatted_Datetime_Controller
    static testMethod void ASI_TnE_Formatted_Datetime_Controller_Test(){
        ASI_TnE_Formatted_Datetime_Controller controller = new ASI_TnE_Formatted_Datetime_Controller();
        controller.date_time = system.today();
        controller.defined_format = 'yyyyMMdd';
        controller.getFormattedDatetime();
        controller.defined_format = null;
        controller.getFormattedDatetime();
        controller.date_time = null;
        controller.getFormattedDatetime();
    }
}