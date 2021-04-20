@isTest
public class AME_project_cloud_ProjectCharterPDF_Tst{
    static testMethod void test_project_cloud_ProjectCharterPDF(){
        AME_project_cloud_ProjectCharterPDF_Ext extension = new AME_project_cloud_ProjectCharterPDF_Ext(new ApexPages.standardController(new AME_project_cloud_Project_Charter__c()));
        extension.getResources();
        extension.getMilestones();
    }
}