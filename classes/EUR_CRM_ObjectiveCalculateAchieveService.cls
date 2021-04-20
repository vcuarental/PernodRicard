public with sharing class EUR_CRM_ObjectiveCalculateAchieveService {

    private Set<String> recordTypeDeveloperNamesToCalculateAchievement = new Set<String>{
        'EUR_AT_Central_Objective'
    };


    /* ========================================================= */
    /*     Interface
    /* ========================================================= */
    public void calculateAchievement(List<EUR_CRM_GB_Objective__c> objectives) {
        Map<Id, List<EUR_CRM_GB_Objective__c>> objectivesWithNotBlankDataByRecordTypeId = this.getObjectivesWithNotBlankDataByRecordTypeId(objectives);
        System.debug('\n\n objectivesWithNotBlankDataByRecordTypeId => ' + JSON.serializePretty(objectivesWithNotBlankDataByRecordTypeId) + '\n');
        if (objectivesWithNotBlankDataByRecordTypeId.isEmpty()) { return ; }

        this.doCalculation(objectivesWithNotBlankDataByRecordTypeId);
    }

    public void calculateAchievement(List<EUR_CRM_GB_Objective__c> objectives, Map<Id, EUR_CRM_GB_Objective__c> oldObjectivesById) {
        Map<Id, List<EUR_CRM_GB_Objective__c>> objectivesWithChangedDataByRecordTypeId = this.getObjectivesWithChangedDataByRecordTypeId(objectives, oldObjectivesById);
        System.debug('\n\n objectivesWithChangedDataByRecordTypeId => ' + JSON.serializePretty(objectivesWithChangedDataByRecordTypeId) + '\n');
        if (objectivesWithChangedDataByRecordTypeId.isEmpty()) { return ; }

        this.doCalculation(objectivesWithChangedDataByRecordTypeId);
    }


    /* ========================================================= */
    /*     Delegate Methods
    /* ========================================================= */
    private void doCalculation(Map<Id, List<EUR_CRM_GB_Objective__c>> objectivesRecordTypeId) {
        Map<String, Id> recordTypeIdByDeveloperName = this.getRecordTypeIdByDeveloperName(objectivesRecordTypeId.keySet());
        System.debug('\n\n recordTypeIdByDeveloperName => ' + JSON.serializePretty(recordTypeIdByDeveloperName) + '\n');
        if (recordTypeIdByDeveloperName.isEmpty()) { return ; }

        for (String rtDevName : recordTypeIdByDeveloperName.keySet()) {
            Id rtId = recordTypeIdByDeveloperName.get(rtDevName);
            if (objectivesRecordTypeId.containsKey(rtId)) {
                for (EUR_CRM_GB_Objective__c objective : objectivesRecordTypeId.get(rtId)) {
                    objective.EUR_CRM_Achieved__c = this.isTargetReached(objective);
                }
            }
        }
    }


    /* ========================================================= */
    /*     High Level Helpers
    /* ========================================================= */
    private Map<Id, List<EUR_CRM_GB_Objective__c>> getObjectivesWithNotBlankDataByRecordTypeId(List<EUR_CRM_GB_Objective__c> objectives) {
        Map<Id, List<EUR_CRM_GB_Objective__c>> objectivesByRecordTypeId = new Map<Id, List<EUR_CRM_GB_Objective__c>>();
        for (EUR_CRM_GB_Objective__c objective : objectives) {
            if (this.areFieldsNotBlank(objective)) {
                if (objectivesByRecordTypeId.containsKey(objective.RecordTypeId)) {
                    objectivesByRecordTypeId.get(objective.RecordTypeId).add(objective);
                } else {
                    objectivesByRecordTypeId.put(objective.RecordTypeId, new List<EUR_CRM_GB_Objective__c> { objective });
                }
            }
        }
        return objectivesByRecordTypeId;
    }

    private Map<Id, List<EUR_CRM_GB_Objective__c>> getObjectivesWithChangedDataByRecordTypeId(List<EUR_CRM_GB_Objective__c> objectives, Map<Id, EUR_CRM_GB_Objective__c> oldObjectivesById) {
        Map<Id, List<EUR_CRM_GB_Objective__c>> objectivesByRecordTypeId = new Map<Id, List<EUR_CRM_GB_Objective__c>>();
        for (EUR_CRM_GB_Objective__c objective : objectives) {
            if (this.isDataChanged(objective, oldObjectivesById)) {
                if (objectivesByRecordTypeId.containsKey(objective.RecordTypeId)) {
                    objectivesByRecordTypeId.get(objective.RecordTypeId).add(objective);
                } else {
                    objectivesByRecordTypeId.put(objective.RecordTypeId, new List<EUR_CRM_GB_Objective__c> { objective });
                }
            }
        }
        return objectivesByRecordTypeId;
    }

    private Map<String, Id> getRecordTypeIdByDeveloperName(Set<Id> rtIds) {
        List<RecordType> recordTypes = this.selectRecordTypesWhereIds(rtIds);

        Map<String, Id> recordTypeIdsByDeveloperName = new Map<String, Id>();
        for (RecordType rt : recordTypes) {
            recordTypeIdsByDeveloperName.put(rt.DeveloperName, rt.Id);
        }
        return recordTypeIdsByDeveloperName;
    }


    /* ========================================================= */
    /*     Low Level Helpers
    /* ========================================================= */
    private Boolean areFieldsNotBlank(EUR_CRM_GB_Objective__c objective) {
        return objective.EUR_CRM_Target_Number_of_Actions__c != null
            && objective.EUR_CRM_Achieved_Number_of_Actions__c != null
        ;
    }

    private Boolean isDataChanged(EUR_CRM_GB_Objective__c objective, Map<Id, EUR_CRM_GB_Objective__c> oldObjectivesById) {
        return this.isTargetNumberOfActionsChanged(objective, oldObjectivesById)
            || this.isAchievedNumberOfActionsChanged(objective, oldObjectivesById)
        ;
    }

    private Boolean isTargetNumberOfActionsChanged(EUR_CRM_GB_Objective__c objective, Map<Id, EUR_CRM_GB_Objective__c> oldObjectivesById) {
        return objective.EUR_CRM_Target_Number_of_Actions__c != oldObjectivesById.get(objective.Id).EUR_CRM_Target_Number_of_Actions__c;
    }

    private Boolean isAchievedNumberOfActionsChanged(EUR_CRM_GB_Objective__c objective, Map<Id, EUR_CRM_GB_Objective__c> oldObjectivesById) {
        return objective.EUR_CRM_Achieved_Number_of_Actions__c != oldObjectivesById.get(objective.Id).EUR_CRM_Achieved_Number_of_Actions__c;
    }

    private Boolean isTargetReached(EUR_CRM_GB_Objective__c obj) {
        if (obj.EUR_CRM_Achieved_Number_of_Actions__c == null || obj.EUR_CRM_Target_Number_of_Actions__c == null) {
            return false;
        }
        return obj.EUR_CRM_Achieved_Number_of_Actions__c >= obj.EUR_CRM_Target_Number_of_Actions__c;
    }


    /* ========================================================= */
    /*     SOQL Selectors
    /* ========================================================= */
    private List<RecordType> selectRecordTypesWhereIds(Set<Id> rtIds) {
        return [
            SELECT Id
            ,   DeveloperName
            FROM RecordType
            WHERE Id IN :rtIds
                AND DeveloperName IN :recordTypeDeveloperNamesToCalculateAchievement
        ];
    }

}