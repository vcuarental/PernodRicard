public class AME_project_cloud_ProjectCharterPDF_Ext{
    private ApexPages.standardController controller;
    public AME_project_cloud_ProjectCharterPDF_Ext(ApexPages.standardController controller){
        this.controller = controller;
    }
    
    public List<AME_project_cloud_Project_Resource__c> getResources(){
        List<AME_project_cloud_Project_Resource__c> result = [SELECT 
                                                                           Id,
                                                                           AME_project_cloud_Role__c,
                                                                           AME_project_cloud_Name__c,
                                                                           AME_project_cloud_Responsibility__c,
                                                                           AME_project_cloud_Resource_Name__c
                                                                       FROM 
                                                                           AME_project_cloud_Project_Resource__c
                                                                       WHERE 
                                                                           AME_project_cloud_Project_Charter__c = :controller.getId()
                                                                       ORDER BY AME_project_cloud_Order__c, AME_project_cloud_Role__c, AME_project_cloud_Name__c
                                                               ];
        return result;
    }
    
    public List<project_cloud__Project_Task__c> getMilestones(){
        return [SELECT Id, Name, project_cloud__End__c FROM project_cloud__Project_Task__c WHERE AME_project_cloud_Project_Charter__c = :controller.getId() ORDER BY project_cloud__End__c];
    } 
}