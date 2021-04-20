/*********************************************************************************
 * Name:ASI_CRM_VN_VisitDetailEditController
 * Description: overwrite the Edit Button for Edit
 *
 * Version History
 * Date               Developer               Comments
 * ---------------  --------------------    --------------------------------------
 * 06/10/2015         Laputa: Hank            Created
*********************************************************************************/
public with sharing class ASI_CRM_VN_VisitDetailEditController{
    public ASI_HK_CRM_Visitation_Plan_Detail__c detail;
    public ASI_CRM_VN_VisitDetailEditController(ApexPages.StandardController stdController){
        detail = (ASI_HK_CRM_Visitation_Plan_Detail__c) stdController.getRecord();
        if(detail != null){
            detail = [Select RecordType.DeveloperName From ASI_HK_CRM_Visitation_Plan_Detail__c  Where Id = :detail.Id];
        }
    }
    public pageReference pageRedirect(){
        if(detail != null && detail.RecordType.DeveloperName.Contains('ASI_CRM_VN')){
            return new PageReference('/' + detail.Id + '/e?retURL=' + detail.Id + '&nooverride=1&saveURL=/apex/ASI_CRM_VN_VisitDetailGPSPage?id=' + detail.Id);
        }else if(detail != null){
            return new PageReference('/' + detail.Id + '/e?retURL=' + detail.Id + '&nooverride=1');
        }else{
            return null;
        }
    }
}