/***************************************************************************************************************************
 * Name:        ASI_HK_CRM_PAFApprovalRecallController
 * Description:  
 * Test Class:  ASI_HK_CRM_PAFRecallControllerTest
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2019-12-06       Wilken Lee              [WL 1.0] Allow recall PAF at any stage
 ****************************************************************************************************************************/
public without sharing class ASI_HK_CRM_PAFApprovalRecallController {
  
  private static final String STATUS_AFTER_RECALL = 'Draft';
  private static final Set<String> STATUS_ALLOW_RECALL = new Set<String> {
    'Submitted'
  };
  private static final Set<String> PERMIT_PROFILE_NAMES = new Set<String> {
		'ASI HK CRM Sales Admin'
		, 'ASI HK CRM System Administrator'
		, 'System Administrator'
		, 'ASI HK CRM Approver'
		, 'ASI Vendor Support System Administrator'
		, 'ASI System Administrator',
            'ASI HK CRM Approver'
	};
  public ID pafId { get; private set; }
  private ASI_HK_CRM_Pre_Approval_Form__c paf;
  Set<ID> permitProfileIds;
  
  public ASI_HK_CRM_PAFApprovalRecallController(ApexPages.StandardController stdCon) {
    this.pafId = stdCon.getId();
    
    if (this.pafId != null)
    {
      paf = [SELECT Id, OwnerId, ASI_HK_CRM_PAF_Status__c FROM ASI_HK_CRM_Pre_Approval_Form__c WHERE Id = :pafId];

      List<Profile> profiles = [SELECT Id FROM Profile WHERE Name IN :PERMIT_PROFILE_NAMES];
			permitProfileIds = new Set<ID>();
			for (Profile p : profiles) {
				permitProfileIds.add(p.Id);
			}
    }
  }
  
  public PageReference doRecall() {
    PageReference redirectPage = null;

    if (paf == null)
    {
      showPageError('Invalid ID');
    }
    else if (UserInfo.getUserId() != paf.OwnerId && !permitProfileIds.contains(UserInfo.getProfileId()))
    {
      showPageError('You are not allowed to recall this record');
    }
    else
    {
      ProcessInstanceWorkitem workitem = workitemFromRecordId(pafId);
      if (workitem != null) {
        Approval.ProcessWorkitemRequest recallReq = new Approval.ProcessWorkitemRequest();
        recallReq.setWorkitemId(workitem.Id);
        recallReq.setAction('Removed');
        paf.ASI_HK_CRM_PAF_Status__c = STATUS_AFTER_RECALL;
        System.Savepoint sp = database.setSavepoint();
        try {
          update paf;
          Approval.ProcessResult recallResult = Approval.process(recallReq);
          redirectPage = new PageReference('/' + pafId);
        } catch (Exception e) {
          database.rollback(sp);
          showPageError(e.getMessage());
        }
      } else {
        showPageError('No approval process is running');
      }
    }
    
    return redirectPage;
  }
  
  private ProcessInstanceWorkitem workitemFromRecordId(ID recordId) {
    if (recordId == null) return null;
    List<ProcessInstanceWorkitem> workitems = [SELECT Id, ActorId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId = :recordId];
    return (workitems.size() > 0) ? workitems[0] : null;
  }
  
  private void showPageMessage(ApexPages.Severity severity, String msg) { ApexPages.addMessage(new ApexPages.Message(severity, msg)); }
  private void showPageError(String msg) { showPageMessage(ApexPages.Severity.ERROR, msg); }
}