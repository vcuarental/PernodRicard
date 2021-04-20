public class AME_project_cloud_ProjectReport_Cont {
    public List<project_cloud__Project__c> projects{get; private set;}
    public Map<Id, String> charters{get; private set;}
    public Map<Id, String> areasAffected{get; private set;}
    public String toBreak{get; set;}
    
    public AME_project_cloud_ProjectReport_Cont() {
        projects = [SELECT Id,
                           Name,
                           AME_project_cloud_Status__c,
                           project_cloud__Start__c,
                           project_cloud__End__c,
                           project_cloud__Health__c,
                           project_cloud__Health_Reason__c,
                           project_cloud__Ticket__r.AME_project_cloud_IT_Functional_Area__c,
                           project_cloud__Ticket__r.AME_project_cloud_Business_Area_Affected__c,
                           (SELECT AME_project_cloud_Strat_Classification__c
                            FROM Project_Charters__r
                            LIMIT 1)
                    FROM project_cloud__Project__c
                    ORDER BY AME_project_cloud_Status__c ASC, project_cloud__End__c, Name ASC];
                    
        List<project_cloud__Project__c> rearrange = new List<project_cloud__Project__c>();
        charters = new Map<Id, String>();
        areasAffected = new Map<Id, String>();
        Integer i = 0;
        while(i < projects.size()) {
            project_cloud__Project__c project = projects.get(i++);
            //Populate charter map(if one exists)
            if(project.Project_Charters__r != null && project.Project_Charters__r.size() > 0) {
                String classification = project.Project_Charters__r.get(0).AME_project_cloud_Strat_Classification__c;
                charters.put(project.Id, (classification == null ? '' : classification));
            } else {
                charters.put(project.Id, '');
            }
            //Populate area map(is one exists)
            String areas = project.project_cloud__Ticket__r.AME_project_cloud_Business_Area_Affected__c;
            if(areas != null) {
                List<String> split = areas.split(';');
                split.sort();
                areas = String.join(split, ',\n');
                areasAffected.put(project.Id, areas);
            } else {
                areasAffected.put(project.Id, '');
            }
        }
    }
}