/*********************************************************************************
 * Name: ASI_CRM_VN_ApprovalRejectionCtrlTest
 * Description: Test class for ASI_CRM_VN_ApprovalRejectionController
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 13/07/2017       Hugo Cheung             Created          
*/
@isTest
public class ASI_CRM_VN_ApprovalRejectionCtrlTest {
    public static testMethod void testCtrl() {
        ASI_CRM_VN_ApprovalRejectionController approvalRejectionCtrl = new ASI_CRM_VN_ApprovalRejectionController();
        approvalRejectionCtrl.getApprovalStep();
    }
}