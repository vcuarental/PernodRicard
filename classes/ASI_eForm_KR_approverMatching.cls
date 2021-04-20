public class ASI_eForm_KR_approverMatching
{
    private List<ASI_eForm_Approval_Routing__c> eFormApprover;
    
    public ASI_eForm_KR_approverMatching(List<ASI_eForm_Recruitment__c> triggerNew)
    {
        eFormApprover = new List<ASI_eForm_Approval_Routing__c>
            ([SELECT id, ASI_eForm_Branch_Code__c, ASI_eForm_Approver_1__c, ASI_eForm_Approver_2__c, ASI_eForm_Approver_3__c, 
              ASI_eForm_MC_Approver__c FROM ASI_eForm_Approval_Routing__c WHERE ASI_eForm_Form_Type__c = 'Recruitment Request']);
        
        for(ASI_eForm_Approval_Routing__c tempS : eFormApprover)
        {
            for(ASI_eForm_Recruitment__c tempObj : triggerNew)
            {
                if(tempObj.ASI_eForm_Opt_Approver_1__c == null && tempObj.ASI_eForm_Opt_Approver_2__c == null 
                  && tempObj.ASI_eForm_Opt_Approver_3__c == null && tempObj.ASI_eForm_Opt_MC_Approver__c == null)
                {
                	if(tempS.ASI_eForm_Branch_Code__c.contains(tempObj.ASI_eForm_Requester_Department__c))
                	{
                    	tempObj.ASI_eForm_Opt_Approver_1__c = tempS.ASI_eForm_Approver_1__c;
                    	tempObj.ASI_eForm_Opt_Approver_2__c = tempS.ASI_eForm_Approver_2__c;
                    	tempObj.ASI_eForm_Opt_Approver_3__c = tempS.ASI_eForm_Approver_3__c;
                    	tempObj.ASI_eForm_Opt_MC_Approver__c = tempS.ASI_eForm_MC_Approver__c;
            		}//end if
                }//end if
            }//end for
        }//end for
    }//end constructor
    
    public ASI_eForm_KR_approverMatching(List<ASI_eForm_Leave_Request__c> triggerNew)
    {
        eFormApprover = new List<ASI_eForm_Approval_Routing__c>
            ([SELECT id, ASI_eForm_Branch_Code__c, ASI_eForm_Approver_1__c, ASI_eForm_Approver_2__c, ASI_eForm_Approver_3__c, 
              ASI_eForm_MC_Approver__c FROM ASI_eForm_Approval_Routing__c WHERE ASI_eForm_Form_Type__c = 'Leave Request']);
        
        for(ASI_eForm_Approval_Routing__c tempS : eFormApprover)
        {
            for(ASI_eForm_Leave_Request__c tempObj : triggerNew)
            {
				if(tempS.ASI_eForm_Branch_Code__c.contains(tempObj.ASI_eForm_Requester_Department__c))
                {
                    tempObj.ASI_eForm_Opt_Approver_1__c = tempS.ASI_eForm_Approver_1__c;
                    tempObj.ASI_eForm_Opt_Approver_2__c = tempS.ASI_eForm_Approver_2__c;
                    tempObj.ASI_eForm_Opt_Approver_3__c = tempS.ASI_eForm_Approver_3__c;
                    tempObj.ASI_eForm_Opt_MC_Approver__c = tempS.ASI_eForm_MC_Approver__c;
            	}//end if
            }//end for
        }//end for
    }//end constructor
    
}