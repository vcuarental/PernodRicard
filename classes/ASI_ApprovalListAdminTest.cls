@isTest
public class ASI_ApprovalListAdminTest {
    
    private static ASI_eForm_HR_MDM__c tempMDM = new ASI_eForm_HR_MDM__c(Name='1234567', ASI_eForm_MDM_Department__c='tempHR',ASI_eForm_Employee_Company_Code__c = '222', 
      ASI_eForm_Employee_First_Name__c='ab', ASI_eForm_Employee_Last_Name__c='cd', ASI_eForm_Employee_Job_Title__c='none', 
       ASI_eForm_Employee_Eligible_PD__c = true, ASI_eForm_Employee_Branch_Code__c='300-Management', ASI_eForm_Employee_Is_Salesman__c=True, ASI_eForm_Employee_Gender__c='M', 
        ASI_eForm_Employee_Work_Email__c='123.345@email.com');
    
    Private static User tempU = [select id,ASI_KOR_Commission_Code__c/*,ASI_CRM_Region__c*/ from user where id = :userInfo.getUserId()];
    
    static testMethod void ASI_ApprovalListAdminController_TEST() {
        
        insert tempMDM;
        
        tempU.ASI_KOR_Commission_Code__c = '1234567';
        //tempU.ASI_CRM_Region__c='CN-Admin';
        update tempU;

        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_eForm_Home_Appliance__cASI_eForm_KR_Home_Appliance');
        
        ASI_eForm_Home_Appliance__c a2 = new ASI_eForm_Home_Appliance__c(
            RecordTypeId=rtOutlet
            , ownerID=tempU.id
            , ASI_eForm_Status__c= 'draft');
        insert a2;
        
        //System.runAs(tempU){
        test.startTest();
            
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(a2.Id);
        req1.setNextApproverIds(new Id[] {tempU.id});
        req1.setSubmitterID(tempU.id);
        req1.setSkipEntryCriteria(true);
        req1.setProcessDefinitionNameOrId('ASI_eForm_KR_HA_2');
        Approval.process(req1);
                
        ASI_ApprovalListAdminCtrl con = new ASI_ApprovalListAdminCtrl();
        con.init();
        con.Beginning();
        con.Next();
        con.Previous();
        con.End();
        con.getDisablePrevious();
        con.getDisableNext();
        con.getTotal_size();
        con.getPageNumber();
        con.total_size = 20;
        con.getTotalPages();
        con.total_size = 21;
        con.getTotalPages();
        con.changeStatus2();
        con.changeStatus();
        con.getSubmitterList();
        con.getApproverList();
        con.getTypeList();
        //con.getRegion();
        con.statusSelected = 'Pending';
        con.selectedRegion = 'CN-ALL';
        con.selectedApprover = 'ALL';        
        con.queryRec();
        con.statusSelected = 'Pending';
        con.selectedRegion = 'CN-ALL';
        con.selectedApprover = tempU.id;
        con.docNum = a2.name;
        con.queryRec();
        
        ASI_ApprovalListAdminCtrl.ApprovalRecord r;
        r = new ASI_ApprovalListAdminCtrl.ApprovalRecord();
        r = new ASI_ApprovalListAdminCtrl.ApprovalRecord((ProcessInstanceWorkitem)null);
        r = new ASI_ApprovalListAdminCtrl.ApprovalRecord((ProcessInstanceStep)null);
        test.stopTest();
    }
}