/*********************************************************************************
 * Name: ASI_CRM_JP_ApprovalRejectionCtrlTest
 * Description: Test class for ASI_CRM_JP_ApprovalRejectionController
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    ---------------------------------------
 * 18/08/2017       Kevin Choi             	Created          
 **********************************************************************************/
@isTest
public class ASI_CRM_JP_ApprovalRejectionCtrlTest {
    
    public static testMethod void testCtrl() {
        ASI_CRM_JP_ApprovalRejectionController approvalRejectionCtrl = new ASI_CRM_JP_ApprovalRejectionController();
        approvalRejectionCtrl.getApprovalStep();
    }

}