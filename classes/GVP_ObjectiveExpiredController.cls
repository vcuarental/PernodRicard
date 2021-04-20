global class GVP_ObjectiveExpiredController implements Schedulable {

    global void execute(SchedulableContext sc) {
        doExecute();
    }
    
    public static void doExecute() {
        List<gvp__Account_Objective__c> results = checkObjectives(
            getObjectives()
        );
        updateObjectives(results);
    }

    public static List<gvp__Account_Objective__c> getObjectives() {
        return [SELECT
                    gvp__Status__c
                FROM
                    gvp__Account_Objective__c
                WHERE
                    Closed_By_Date__c <= TODAY AND
                    gvp__Status__c IN ('Not Started', 'Working') AND
                    gvp__Custom_3__c = 'CorpObjectives'];
    }
    
    public static void updateObjectives(List<gvp__Account_Objective__c> pObjectives) {
        if (pObjectives != null && !pObjectives.isEmpty()) {
            update pObjectives;
        }
    }

    public static List<gvp__Account_Objective__c> checkObjectives(List<gvp__Account_Objective__c> pObjectives) {
        if (pObjectives.isEmpty()) {
            return null;
        }
        
        for (gvp__Account_Objective__c currentObjective : pObjectives) {
            currentObjective.gvp__Status__c = 'Closed - Time Expired';
        }
        return pObjectives;
    }
}