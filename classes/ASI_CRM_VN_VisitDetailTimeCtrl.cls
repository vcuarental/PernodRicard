/*********************************************************************************
 * Name: ASI_CRM_VN_VisitDetailTimeCtrl
 * Description: Class for setting visitation plan detail time-in and time out value
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 19/05/2017       Hugo Cheung             Created          
*/
public class ASI_CRM_VN_VisitDetailTimeCtrl {
    
    private static DateTime CURRENT_DATETIME = System.now();
    
    public ASI_HK_CRM_Visitation_Plan_Detail__c visitationPlanDetail {get; set;}
    public Id userId {get; set;}
    
    public ASI_CRM_VN_VisitDetailTimeCtrl(ApexPages.StandardController stdController) {
        userId = UserInfo.getUserId();
        visitationPlanDetail = (ASI_HK_CRM_Visitation_Plan_Detail__c) stdController.getRecord();
        visitationPlanDetail = retrieveVisitationPlanDetail(visitationPlanDetail.Id);
    }
    
    public PageReference setTimeIn() {
        visitationPlanDetail.ASI_CRM_VN_Time_In__c = CURRENT_DATETIME;
       	update visitationPlanDetail;
        
        PageReference pageRef = new PageReference('/' + visitationPlanDetail.Id);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public PageReference setTimeOut() {
        visitationPlanDetail.ASI_CRM_VN_Time_Out__c = CURRENT_DATETIME;
        visitationPlanDetail.ASI_HK_CRM_Status__c   = 'Achieved';
       	update visitationPlanDetail;
        
        PageReference pageRef = new PageReference('/' + visitationPlanDetail.Id);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    private ASI_HK_CRM_Visitation_Plan_Detail__c retrieveVisitationPlanDetail(Id visitationPlanDetailId) {
    	String query = 'SELECT Id, ASI_CRM_VN_Time_In__c, ASI_CRM_VN_Time_Out__c, ASI_HK_CRM_Visitation_Plan__r.OwnerId ' + 
                       'FROM ASI_HK_CRM_Visitation_Plan_Detail__c ' + 
                       'WHERE Id = :visitationPlanDetailId';
        List<ASI_HK_CRM_Visitation_Plan_Detail__c> visitationPlanDetailList = (List<ASI_HK_CRM_Visitation_Plan_Detail__c>) Database.query(query);
    	return visitationPlanDetailList.size() > 0 ? visitationPlanDetailList.get(0) : null;
    }
    
}