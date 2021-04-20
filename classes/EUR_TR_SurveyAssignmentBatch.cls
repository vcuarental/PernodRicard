/**
 * Created by bsavcı on 8/28/2020.
 */

public with sharing class EUR_TR_SurveyAssignmentBatch implements Database.Batchable<SObject>, Database.Stateful {

    private String query;
    private String templateMasterId;
    private String operationType;

    public EUR_TR_SurveyAssignmentBatch(String query, String operationType) {
        this.query = query;
        this.operationType = operationType;
    }
    public EUR_TR_SurveyAssignmentBatch(String query, String templateMasterId, String operationType) {
        this.query = query;
        this.templateMasterId = templateMasterId;
        this.operationType = operationType;
    }

    public Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext context, List<SObject> sObjects) {
        EUR_TR_SurveyAssignmentController.SurveyAssignmentRequest request = new EUR_TR_SurveyAssignmentController.SurveyAssignmentRequest();
        request.FromBatch = true;
        if (operationType == 'Assign') {
            request.SelectedSurveyId = templateMasterId;
            request.Accounts = sObjects;
            EUR_TR_SurveyAssignmentController.assignSurveyRequest(request);
        } else if (operationType == 'Delete') {
            request.TargetSurveys = sObjects;
            EUR_TR_SurveyAssignmentController.removeSurveyAssignmentRequest(request);
        }
    }

    public void finish(Database.BatchableContext context) {
    }


}