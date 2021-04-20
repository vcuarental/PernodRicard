/*********************************************************************************
 * Name:ASI_HK_CRM_PreApprovalFormAssignApprover
 * Description: 
 * Test Class: ASI_HK_CRM_PAF_Test
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
  * 20180918       	Wilken	         		[WL 1.0] Default Actual Period Start and End to be first and last day of month
*********************************************************************************/
public with sharing class ASI_HK_CRM_PreApprovalFormAssignApprover extends ASI_HK_CRM_TriggerAbstract {
    
    private static final Set<String> relevantUserFields = new Set<String>{
        'ASI_HK_CRM_Sales_Director_Approver__c'
        , 'ManagerId'
    };
    private User curUser;
    
    public ASI_HK_CRM_PreApprovalFormAssignApprover() {
        super('ASI_HK_CRM_PreApprovalFormAssignApprover');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        if ((tAction == TriggerAction.BEFORE_INSERT || tAction == TriggerAction.BEFORE_UPDATE)
            && !isBypassByCurrentUser()) {          
            List<ASI_HK_CRM_Pre_Approval_Form__c> pafList = (List<ASI_HK_CRM_Pre_Approval_Form__c>)sObjList;
            curUser = null;
            
            for (ASI_HK_CRM_Pre_Approval_Form__c paf : pafList) {
                //20160215, added by Leo
                if(paf.ASI_HK_CRM_PAF_Customer__c != null)
                {
                    paf.ASI_CRM_HK_Customer_Name__c = paf.ASI_CRM_HK_Customer_FormulaName__c;
                }//end if
                //20160215, added by Leo
                if (curUser == null) {
                    ID curUserId = UserInfo.getUserId();
                    curUser = database.query(ASI_HK_CRM_CommonUtils.genQueryString(relevantUserFields, 'User', 'Id = :curUserId'));
                }
                try {                   
                    //assignSalesDirector(paf);
                    assignSupervisor(paf);
                } catch (Exception e) {
                    paf.addError(e.getMessage());
                }
				
				/*[WL 1.0] BEGIN*/
				if (paf.ASI_CRM_Ref_Start_Date__c != null && paf.ASI_CRM_Ref_Start_Date__c.day() != 1){
					Date newStartDate = Date.newInstance(paf.ASI_CRM_Ref_Start_Date__c.Year(), paf.ASI_CRM_Ref_Start_Date__c.Month(), 1);
					paf.ASI_CRM_Ref_Start_Date__c = newStartDate;
				}
				
				if (paf.ASI_CRM_Ref_End_Date__c != null && paf.ASI_CRM_Ref_End_Date__c.day() != Date.daysInMonth(paf.ASI_CRM_Ref_End_Date__c.Year(),paf.ASI_CRM_Ref_End_Date__c.Month())){
					Integer numberOfDays = Date.daysInMonth(paf.ASI_CRM_Ref_End_Date__c.Year(), paf.ASI_CRM_Ref_End_Date__c.Month());
					
					Date newEndDate = Date.newInstance(paf.ASI_CRM_Ref_End_Date__c.Year(), paf.ASI_CRM_Ref_End_Date__c.Month(), numberOfDays);
					paf.ASI_CRM_Ref_End_Date__c = newEndDate;
				}
				/*[WL 1.0] END*/
            }
        }
    }
    
    private void assignSalesDirector(ASI_HK_CRM_Pre_Approval_Form__c paf) {
        paf.ASI_HK_CRM_SYS_Sales_Director_Approver__c = curUser.ASI_HK_CRM_Sales_Director_Approver__c;
    }
    
    private void assignSupervisor(ASI_HK_CRM_Pre_Approval_Form__c paf) {
        String uid=paf.Ownerid;       
        user u=((user)database.query('select managerid from user where id =:uid'));            
        if(u!=null && u.ManagerId!=null)
            paf.ASI_HK_CRM_SYS_Supervisor__c = u.ManagerId;//curUser.ManagerId;
    }

}