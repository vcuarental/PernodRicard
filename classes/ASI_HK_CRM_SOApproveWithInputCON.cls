/*********************************************************************************
 * Name: ASI_HK_CRM_SOApproveWithInputCON
 * Description: 
 * Test Class: ASI_HK_CRM_SOApproveWithInputCONTest

 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-10-08       Wilken Lee             [WL 1.0] New requirement for SO approval. H0 also requires Mag approval
 */
public without sharing class ASI_HK_CRM_SOApproveWithInputCON {
    
    public enum ApproveType {RESUME, SSM_HS, SSC}
    private static final String APPROVE_ACTION = 'Approve';
    
    // RESUME
    private static String STATUS_ALLOW_RESUME = 'SSC Finance updated';
    private static Set<String> CREDIT_HOLD_ALLOW_RESUME = new Set<String> {
        'H5'
        , 'H8'
    };
    
    // SSM_HS
    private static String STATUS_ALLOW_SSM_HS = 'SSC Finance updated';
    private static Set<String> CREDIT_HOLD_ALLOW_SSM_HS = new Set<String> {
        'H4'
        , 'H7'
    };
    
    // SSC
    //Uodated by Wilken 20160129 HK CRM P2 SO status will be SA Approved or Approved when it passes to SSC for approval
    //private static String STATUS_ALLOW_SSC = 'Hold Code Received';
    private static String STATUS_ALLOW_SSC_1 = 'SA Approved';
    private static String STATUS_ALLOW_SSC_2 = 'Approved';
    
    // Common Inputs
    public String comment { get; set; }
    
    // SSC
    public Boolean isNoComment { get; set; }
    public String moneyReportRemarks { get; set; }
    
    public String soHeaderId { get; private set; }
    public Boolean hasError { get; set; }
    private ApproveType curApproveType;
    public ASI_HK_CRM_Sales_Order__c soHeader { get; set; }
    private ProcessInstanceWorkitem soWorkitem;
    
    public ASI_HK_CRM_SOApproveWithInputCON(ApexPages.StandardController stdCon) {
        this.hasError = false;
        this.curApproveType = currentApproveType();
        this.soHeaderId = stdCon.getId();
        List<ASI_HK_CRM_Sales_Order__c> soHeaders = [
        	SELECT Id, ASI_HK_CRM_Comments_Salesman__c, ASI_HK_CRM_Order_Status_Name__c, ASI_HK_CRM_Credit_Hold_Reason__c
        		, ASI_HK_CRM_Payment_Amt_1__c, ASI_HK_CRM_Payment_Amt_2__c, ASI_HK_CRM_Payment_Amt_3__c, ASI_HK_CRM_Payment_Amt_4__c, ASI_HK_CRM_Payment_Amt_5__c
        		, ASI_HK_CRM_Payment_Date_1__c, ASI_HK_CRM_Payment_Date_2__c, ASI_HK_CRM_Payment_Date_3__c, ASI_HK_CRM_Payment_Date_4__c, ASI_HK_CRM_Payment_Date_5__c
        		, ASI_HK_CRM_Cheque_Amt_1__c, ASI_HK_CRM_Cheque_Amt_2__c, ASI_HK_CRM_Cheque_Amt_3__c, ASI_HK_CRM_Cheque_Amt_4__c, ASI_HK_CRM_Cheque_Amt_5__c
        		, ASI_HK_CRM_Cheque_Date_1__c, ASI_HK_CRM_Cheque_Date_2__c, ASI_HK_CRM_Cheque_Date_3__c, ASI_HK_CRM_Cheque_Date_4__c, ASI_HK_CRM_Cheque_Date_5__c
        	FROM ASI_HK_CRM_Sales_Order__c WHERE Id = :soHeaderId];
        try {
            if (soHeaders.size() > 0) {
                this.soHeader = soHeaders[0];
                checkAllowApprove(this.curApproveType, this.soHeader);
                this.soWorkitem = workitemFromRecordId(this.soHeaderId);
                if (soWorkitem == null/* || soWorkitem.ActorId == null || soWorkitem.ActorId != UserInfo.getUserId()*/) {
                    throw new SOApproveWithInputException('There is no pending approval process');
                }
            } else {
                throw new SOApproveWithInputException(String.format('Sales Order not found for ID {0}', new String[] {soHeaderId}));
            }
        } catch (Exception e) {
			System.debug(LoggingLevel.ERROR, e.getMessage());
            this.hasError = true;
            showPageError(e.getMessage());
        }
    }
    
    public PageReference doApprove() {
        PageReference resultPage = null;
        if (!hasError) {
            try {
                validateInputs();
                Approval.ProcessWorkitemRequest approvalReq = approvalRequest();
                updateSalesOrder(soHeader);
                System.Savepoint sp = database.setSavepoint();
                try {
                    update soHeader;
                    if (approvalReq != null)
                        Approval.ProcessResult approvalResult = Approval.process(approvalReq);
                    resultPage = new PageReference('/' + this.soHeader.Id);
                } catch (Exception e) {
                    database.rollback(sp);
                    System.debug(LoggingLevel.ERROR, e.getMessage());
                    //showPageError(e.getMessage());
                }
            } catch (Exception e) {
                System.debug(LoggingLevel.ERROR, e.getMessage());
                showPageError(e.getMessage());
            }
        }
        return resultPage;
    }
    
    private ApproveType currentApproveType() {
        String baseUrl = ApexPages.currentPage().getUrl().substringBefore('?');
        if (Page.ASI_HK_CRM_SalesOrderResumePage.getUrl() == baseUrl) {
            return ApproveType.RESUME;
        } else if (Page.ASI_HK_CRM_SOApproveWithSSMCommentPage.getUrl() == baseUrl) {
        	return ApproveType.SSM_HS;
        } else if (Page.ASI_HK_CRM_SOApproveWithSSCInputPage.getUrl() == baseUrl) {
            return ApproveType.SSC;
        }
        return null;
    }
    
    private static void checkAllowApprove(ApproveType aType, ASI_HK_CRM_Sales_Order__c so) {
        Boolean isAllow = false;
        String errMsg = null;
        if (ApproveType.RESUME == aType) {
            isAllow = 
            STATUS_ALLOW_RESUME == so.ASI_HK_CRM_Order_Status_Name__c
                && so.ASI_HK_CRM_Credit_Hold_Reason__c != null && CREDIT_HOLD_ALLOW_RESUME.contains(so.ASI_HK_CRM_Credit_Hold_Reason__c);
            errMsg = 'No need to resume the sales order';
        } else if (ApproveType.SSM_HS == aType) {
            isAllow = STATUS_ALLOW_SSM_HS == so.ASI_HK_CRM_Order_Status_Name__c
                && so.ASI_HK_CRM_Credit_Hold_Reason__c != null && CREDIT_HOLD_ALLOW_SSM_HS.contains(so.ASI_HK_CRM_Credit_Hold_Reason__c);
            errMsg = 'Not allowed to approve from this page';
        } else if (ApproveType.SSC == aType) {
			/*[WL 1.0] BEGIN*/
        	/*isAllow = (STATUS_ALLOW_SSC_1 == so.ASI_HK_CRM_Order_Status_Name__c || STATUS_ALLOW_SSC_2 == so.ASI_HK_CRM_Order_Status_Name__c)
        		&& so.ASI_HK_CRM_Credit_Hold_Reason__c != null && so.ASI_HK_CRM_Credit_Hold_Reason__c != 'H0' && so.ASI_HK_CRM_Credit_Hold_Reason__c.startsWith('H');*/
			List<String> sscHoldCode = new List<String>{'H0','H1','H3','H9'};
			
			isAllow = (STATUS_ALLOW_SSC_1 == so.ASI_HK_CRM_Order_Status_Name__c || STATUS_ALLOW_SSC_2 == so.ASI_HK_CRM_Order_Status_Name__c)
        		&& so.ASI_HK_CRM_Credit_Hold_Reason__c != null 
				&& (sscHoldCode.contains(so.ASI_HK_CRM_Credit_Hold_Reason__c));
			/*[WL 1.0] END*/
        	errMsg = 'No need to input SSC comments';
        }
        if (!isAllow) {
        	System.debug(LoggingLevel.ERROR, errMsg);
            throw new SOApproveWithInputException(errMsg);
        }
    }
    
    private void validateInputs() {
        String errMsg = null;
        if (ApproveType.RESUME == this.curApproveType || ApproveType.SSM_HS == this.curApproveType) {
            if (String.isBlank(comment))
                errMsg = 'Please enter the comment';
        }
        if (errMsg != null)
            throw new SOApproveWithInputException(errMsg);
    }
    private Approval.ProcessWorkitemRequest approvalRequest() {
        if (ApproveType.SSM_HS == this.curApproveType) return null;
        Approval.ProcessWorkitemRequest approvalReq = new Approval.ProcessWorkitemRequest();
        approvalReq.setWorkitemId(this.soWorkitem.Id);
        approvalReq.setAction(APPROVE_ACTION);
        if (ApproveType.RESUME == this.curApproveType) {
            approvalReq.setComments(comment);
        }
        return approvalReq;
    }
    private void updateSalesOrder(ASI_HK_CRM_Sales_Order__c so) {
        if (ApproveType.RESUME == this.curApproveType) {
            so.ASI_HK_CRM_Comments_Salesman__c = comment;
        } else if (ApproveType.SSM_HS == this.curApproveType) {
            so.ASI_HK_CRM_Comment_SSM_HS__c = comment;
        } else if (ApproveType.SSC == this.curApproveType) {
        	so.ASI_HK_CRM_No_comments_from_SSC__c = isNoComment;
        	so.ASI_HK_CRM_Comments_SSC__c = comment;
        	so.ASI_HK_CRM_Money_Report_Remarks__c = moneyReportRemarks;
        }
    }
    
    private ProcessInstanceWorkitem workitemFromRecordId(ID recordId) {
        if (recordId == null) return null;
        List<ProcessInstanceWorkitem> workitems = [SELECT Id, ActorId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId = :recordId];
        return (workitems.size() > 0) ? workitems[0] : null;
    }
    
    private void showPageMessage(ApexPages.Severity severity, String msg) { ApexPages.addMessage(new ApexPages.Message(severity, msg)); }
    private void showPageError(String msg) { showPageMessage(ApexPages.Severity.ERROR, msg); }
 
    
    public class SOApproveWithInputException extends Exception {
        
    }

}