/**********************************************************************************
 * Name : ASI_CRM_JP_ApprovalRecall
 * Created : DC @02/04/2016 2:06 PM
 * Revision History:
 * 1. 02/04/2016 - [DC 1.0] Created
 **********************************************************************************/

global without sharing class ASI_CRM_JP_ApprovalRecall {
    webservice static void recallApproval(Id recId)    
    {        
        if(String.isBlank(recId)) {
            return;
        }
        List<ProcessInstanceWorkitem> piwi = [SELECT Id,
                                                     ProcessInstanceId,
                                                     ProcessInstance.TargetObjectId
                                                FROM ProcessInstanceWorkitem
                                               WHERE ProcessInstance.TargetObjectId =: recId];
        if(!piwi.isEmpty()) {
            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
            req.setAction('Removed');        
            req.setWorkitemId(piwi.get(0).Id);
   
            Approval.process(req,false);
        }
    }
}