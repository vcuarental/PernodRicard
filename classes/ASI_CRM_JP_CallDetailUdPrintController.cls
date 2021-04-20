/*********************************************************************************
 * Name:ASI_CRM_JP_CallDetailUdPrintController
 * Description: 
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 20/1/2014       Laputa: Hank            Created
*********************************************************************************/
public with sharing class ASI_CRM_JP_CallDetailUdPrintController{

    private ASI_CRM_Call_Plan__c plan = new ASI_CRM_Call_Plan__c();        
    private ApexPages.StandardController standardController;

    public ASI_CRM_JP_CallDetailUdPrintController(ApexPages.StandardController standardController)
    {
        this.standardController = standardController;
        plan = (ASI_CRM_Call_Plan__c)standardController.getRecord();
        plan = [Select OwnerId, ASI_CRM_Sys_Is_Real_Time_Print__c From ASI_CRM_Call_Plan__c Where Id = :plan.Id];
    }
    
    public PageReference updatePara(){
        plan.ASI_CRM_Sys_Is_Real_Time_Print__c = true;
        update plan;
        PageReference listviewPage = new pageReference('/aBJ?isdtp=nv');
        listviewPage.setRedirect(true);
        return listviewPage ;
    }
}