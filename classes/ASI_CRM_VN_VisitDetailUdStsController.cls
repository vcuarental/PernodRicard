/*********************************************************************************
 * Name:ASI_CRM_VN_VisitDetailUdStsController
 * Description: Update status to cancelled
 *
 * Version History
 * Date               Developer               Comments
 * ---------------  --------------------    --------------------------------------
 * 06/01/2016         Laputa: Hank            Created
*********************************************************************************/
public with sharing class ASI_CRM_VN_VisitDetailUdStsController{
    public ASI_HK_CRM_Visitation_Plan_Detail__c detail {get;set;}
    public ASI_CRM_VN_VisitDetailUdStsController(ApexPages.StandardController stdController){
        detail = (ASI_HK_CRM_Visitation_Plan_Detail__c) stdController.getRecord();
        if(detail != null){
            detail = [Select ASI_HK_CRM_Status__c From ASI_HK_CRM_Visitation_Plan_Detail__c Where Id = :detail.Id];
            system.debug(detail);
        }
    }
    
    Public void updateStatus(){
        system.debug(detail);
        detail.ASI_HK_CRM_Status__c = 'Cancelled';
        try{
            update detail;
            system.debug(detail);
        }catch(Exception e){
            
        }
    } 
}