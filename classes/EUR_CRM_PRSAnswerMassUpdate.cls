public with sharing class EUR_CRM_PRSAnswerMassUpdate implements Database.Batchable<SObject>, Database.Stateful {
    private String countryCode;
    private String questionSetLevel;

    private List<EUR_CRM_PRS_Question__c> questionsToUpdate = new List<EUR_CRM_PRS_Question__c>();

    public EUR_CRM_PRSAnswerMassUpdate(String questionSetLevel, String countryCode) {
        this.questionSetLevel = questionSetLevel;
        this.countryCode = countryCode;
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        String questionsQuery = 'SELECT Id' +
                                    ', RecordType.DeveloperName' +
                                    ', EUR_CRM_PRS_Question_Set__c' +
                                    ', EUR_CRM_Weight_Has_Changed__c' +
                                    ', EUR_CRM_Question_Weight__c' +
                                    ', (' +
                                        ' SELECT Id' +
                                            ', RecordType.DeveloperName' +
                                            ', EUR_CRM_Answer__c' +
                                            ', EUR_CRM_Weight__c' +
                                        ' FROM EUR_CRM_PRS_Answer__r' +
                                    '), ' +
                                    '(' +
                                        ' SELECT Id' +
                                            ', EUR_CRM_PRS_Question__r.RecordType.DeveloperName' +
                                            ', EUR_CRM_Answer_Statement__c' +
                                            ', EUR_CRM_Answer_Condition__c' +
                                            ', EUR_CRM_Criteria_Weight__c' +
                                            ', EUR_CRM_Criteria_Threshold_Number__c' +
                                            ', EUR_CRM_Criteria_Threshold_Currency__c' +
                                            ', EUR_CRM_Criteria_Picklist_Display_Order__c' +
                                            ', EUR_CRM_Criteria_Picklist_Label__c' +
                                            ', EUR_CRM_Criteria_Picklist_Value__c' +
                                        ' FROM EUR_CRM_PRS_Question_Criteria__r' +
                                    ')' +
                                ' FROM EUR_CRM_PRS_Question__c' +
                                    ' WHERE Id IN ' +
                                        ' (' +
                                            ' SELECT EUR_CRM_PRS_Question__c ' +
                                            ' FROM EUR_CRM_PRS_Answer__c ' +
                                            ') ' +
                                    ' AND EUR_CRM_Weight_Has_Changed__c = true' +
                                    ' AND EUR_CRM_Question_Weight__c != NULL ' +
                                    ' AND EUR_CRM_PRS_Question_Set__r.RecordType.DeveloperName LIKE :questionSetLevel';
        if (countryCode != null) {
            questionsQuery += ' AND EUR_CRM_PRS_Question_Set__r.EUR_CRM_Country_Code__c = : countryCode';
        }
        System.debug('\n questionsQuery => ' + questionsQuery + '\n');
        return Database.getQueryLocator(questionsQuery);
    }


    public void execute(Database.BatchableContext BC, List<SObject> scope) {
        List<EUR_CRM_PRS_Question__c> questions = (List<EUR_CRM_PRS_Question__c>) scope;
        System.debug('\n questions.size() => ' + questions.size() + '\n');
        System.debug('\n questions => ' + JSON.serializePretty(questions) + '\n');

        List<AnswerWrapper> answerWrappers = this.getAnswerWrappers(questions);
        System.debug('\n answerWrappers.size() => ' + answerWrappers.size() + '\n');
        System.debug('\n answerWrappers => ' + JSON.serializePretty(answerWrappers) + '\n');
        if (answerWrappers.isEmpty()) { return; }

        List<EUR_CRM_PRS_Answer__c> answersToUpdate = this.updateAnswersAndQuestions(answerWrappers);
        System.debug('\n answersToUpdate.size() => ' + answersToUpdate.size() + '\n');
        System.debug('\n answersToUpdate => ' + JSON.serializePretty(answersToUpdate) + '\n');
        System.debug('\n questionsToUpdate.size() => ' + questionsToUpdate.size() + '\n');
        System.debug('\n questionsToUpdate => ' + JSON.serializePretty(questionsToUpdate) + '\n');
        if (answersToUpdate.isEmpty()) { return; }

        Savepoint sp = Database.setSavepoint();
        try {
            EUR_CRM_CommonRoutine.dmlWithPartialSuccess('update', answersToUpdate);
            EUR_CRM_CommonRoutine.dmlWithPartialSuccess('update', questionsToUpdate);
        } catch(Exception e) {
            System.debug('Exception while update segmentations => ' + e.getStackTraceString() + e.getMessage());
            Database.rollback(sp);
        }
    }

    public void finish(Database.BatchableContext BC) {
        AsyncApexJob apexJob = [SELECT Id FROM AsyncApexJob WHERE Id =:BC.getJobId()];
        EUR_CRM_BatchApexUtilityClass.sendBatchResultEmail(UserInfo.getUserId(), apexJob.id, new String[] {});
    }

    /*===========================================
    *   High Level Helpers
    * ===========================================*/
    private List<AnswerWrapper> getAnswerWrappers(List<EUR_CRM_PRS_Question__c> questions) {
        List<AnswerWrapper> answerWrappers = new List<AnswerWrapper>();
        for (EUR_CRM_PRS_Question__c question : questions) {
            if (this.isQuestionHasCriteria(question)) {
                for (EUR_CRM_PRS_Answer__c answer : question.EUR_CRM_PRS_Answer__r) {
                    if (String.isBlank(answer.EUR_CRM_Answer__c)) { continue; }
                    answerWrappers.add(new AnswerWrapper(answer, question));
                }
            }
        }
        return answerWrappers;
    }

    private List<EUR_CRM_PRS_Answer__c> updateAnswersAndQuestions(List<AnswerWrapper> answerWrappers) {
        List<EUR_CRM_PRS_Answer__c> answersToUpdate = new List<EUR_CRM_PRS_Answer__c>();
        Set<EUR_CRM_PRS_Question__c> tempQuestions = new Set<EUR_CRM_PRS_Question__c>();
        for (AnswerWrapper aw : answerWrappers) {
            Double newAnswerWeight = this.calculateAnswerWeight(aw);
            if (newAnswerWeight != null) {
                aw.answer.EUR_CRM_Weight__c = newAnswerWeight;
                aw.question.EUR_CRM_Weight_Has_Changed__c = false;
                answersToUpdate.add(aw.answer);
                tempQuestions.add(aw.question);
            }
        }
        questionsToUpdate.addAll(tempQuestions);
        return answersToUpdate;
    }


    /*===========================================
    *   Middle Level Helpers
    * ===========================================*/
    private Double calculateAnswerWeight(AnswerWrapper aw) {
        Double newAnswerWeight;
        for (CriterionWrapper cw : aw.criterionWrappers) {
            if (cw.threshold != null) {
                if (String.isBlank(cw.condition)) { continue; }
                newAnswerWeight = this.calculateAnswerWeightForCriterionThreshold(aw, cw);
                if (newAnswerWeight != null) { return newAnswerWeight; }
            }
            if (cw.picklistValue != null) {
                newAnswerWeight = this.calculateAnswerWeightForCriterionPicklist(aw, cw);
                if (newAnswerWeight != null) { return newAnswerWeight; }
            }
        }
        return newAnswerWeight;
    }


    /*===========================================
    *   Low Level Helpers
    * ===========================================*/
    private Boolean isQuestionHasCriteria(EUR_CRM_PRS_Question__c question) {
        return ! question.EUR_CRM_PRS_Question_Criteria__r.isEmpty();
    }

    private Double calculateAnswerWeightForCriterionPicklist(AnswerWrapper aw, CriterionWrapper cw) {
        Double newAnswerWeight = 0;
        if (cw.picklistValue == aw.answer.EUR_CRM_Answer__c) {
            Decimal qCritWeight = cw.weight;
            Decimal qWeight = aw.questionWeight;
            newAnswerWeight = qCritWeight * qWeight / 100;
        }
        return newAnswerWeight;
    }

    private Double calculateAnswerWeightForCriterionThreshold(AnswerWrapper aw, CriterionWrapper cw) {
        Double answerWeight;
        System.debug('\n aw.questionRT => ' + aw.questionRT + '\n');
        System.debug('\n aw.answer + condition + threshold => ' + aw.answer.EUR_CRM_Answer__c + ' ' + cw.condition + ' ' + cw.threshold + '\n');
        System.debug('\n calculateAnswerWeightForCriterionThreshold => ' + answerWeight + '\n');
        if ((cw.condition.equals('<') && (Double.valueOf(aw.answer.EUR_CRM_Answer__c) < cw.threshold)) ||
            (cw.condition.equals('<=') && (Double.valueOf(aw.answer.EUR_CRM_Answer__c) <= cw.threshold)) ||
            (cw.condition.equals('=') && (Double.valueOf(aw.answer.EUR_CRM_Answer__c) == cw.threshold)) ||
            (cw.condition.equals('>') && (Double.valueOf(aw.answer.EUR_CRM_Answer__c) > cw.threshold)) ||
            (cw.condition.equals('>=') && (Double.valueOf(aw.answer.EUR_CRM_Answer__c) >= cw.threshold))) {

            answerWeight = aw.questionWeight * cw.weight / 100;
        }
        return answerWeight;
    }


    /*===========================================
    *   Wrappers
    * ===========================================*/
    private class AnswerWrapper {
        private EUR_CRM_PRS_Answer__c answer;
        private EUR_CRM_PRS_Question__c question;
        private String questionRT;
        private Double questionWeight;
        private List<CriterionWrapper> criterionWrappers;

        private AnswerWrapper(EUR_CRM_PRS_Answer__c answer, EUR_CRM_PRS_Question__c question) {
            this.answer = answer;
            this.question = question;
            this.questionRT = question.RecordType.DeveloperName;
            this.questionWeight = question.EUR_CRM_Question_Weight__c;
            this.criterionWrappers = new CriterionWrapper().getSortedCriterionWrappers(question.EUR_CRM_PRS_Question_Criteria__r);
        }
    }

    public class CriterionWrapper implements Comparable {
        private String condition;
        private Double weight;
        private Double threshold;
        private String picklistValue;

        private CriterionWrapper() {}

        private CriterionWrapper(EUR_CRM_PRS_Question_Criteria__c criterion) {
            this.condition = this.getCriterionCondition(criterion);
            this.weight = criterion.EUR_CRM_Criteria_Weight__c;
            this.threshold = this.getCriterionThreshold(criterion);
            this.picklistValue = this.getCriterionPicklistValue(criterion);
        }

        private List<CriterionWrapper> getSortedCriterionWrappers(List<EUR_CRM_PRS_Question_Criteria__c> criteria) {
            List<CriterionWrapper> criterionWrappers = new List<CriterionWrapper>();
            for (EUR_CRM_PRS_Question_Criteria__c criterion : criteria) {
                if (this.isCriterionHasWeight(criterion)) {
                    criterionWrappers.add(new CriterionWrapper(criterion));
                }
            }
            criterionWrappers.sort();
            System.debug('\n criterionWrappers.size() => ' + criterionWrappers.size() + '\n');
            System.debug('\n criterionWrappers sorted => ' + JSON.serializePretty(criterionWrappers) + '\n');
            return criterionWrappers;
        }

        private String getCriterionCondition(EUR_CRM_PRS_Question_Criteria__c criterion) {
            if (String.isNotBlank(criterion.EUR_CRM_Answer_Condition__c)) {
               return criterion.EUR_CRM_Answer_Condition__c.substringBetween('(', ')').trim();
            }
            return '';
        }

        private Decimal getCriterionThreshold(EUR_CRM_PRS_Question_Criteria__c criterion) {
            if (criterion.EUR_CRM_PRS_Question__r.RecordType.DeveloperName.containsIgnoreCase('Number')) {
                return this.getCriterionThresholdNumber(criterion);
            }
            if (criterion.EUR_CRM_PRS_Question__r.RecordType.DeveloperName.containsIgnoreCase('Currency')) {
                return this.getCriterionThresholdCurrency(criterion);
            }
            return null;
        }

        private String getCriterionPicklistValue(EUR_CRM_PRS_Question_Criteria__c criterion) {
            if (this.isQuestionRTbooleanORpicklistORtext(criterion)) {
                return this.getCriterionPicklistValue(criterion.EUR_CRM_Criteria_Picklist_Value__c);
            }
            return null;
        }

        private Decimal getCriterionThresholdNumber(EUR_CRM_PRS_Question_Criteria__c criterion) {
            return criterion.EUR_CRM_Criteria_Threshold_Number__c == null ? 0 :
                criterion.EUR_CRM_Criteria_Threshold_Number__c;
        }

        private Decimal getCriterionThresholdCurrency(EUR_CRM_PRS_Question_Criteria__c criterion) {
            return criterion.EUR_CRM_Criteria_Threshold_Currency__c == null ? 0 :
                criterion.EUR_CRM_Criteria_Threshold_Currency__c;
        }

        private String getCriterionPicklistValue(String piclistValue) {
            return String.isNotBlank(piclistValue) ? piclistValue : '';
        }

        private Boolean isQuestionRTbooleanORpicklistORtext(EUR_CRM_PRS_Question_Criteria__c criterion) {
            return Pattern.matches('.*((?i)Boolean|Picklist|Text).*',criterion.EUR_CRM_PRS_Question__r.RecordType.DeveloperName);
        }

        private Boolean isCriterionHasWeight(EUR_CRM_PRS_Question_Criteria__c criterion) {
            return criterion.EUR_CRM_Criteria_Weight__c != null;
        }

        public Integer compareTo(Object obj) {
            CriterionWrapper cw = (CriterionWrapper) obj;
            if (this.condition > cw.condition) { return 1; }
            if (this.condition < cw.condition) { return -1; }
            if (cw.condition.equals('>') || cw.condition.equals('>=')) {
               return this.sortThresholdIfGreaterOrEqual(cw);
            } else {
               return this.sortThresholdIfLessOrEqual(cw);
            }
        }

        private Integer sortThresholdIfGreaterOrEqual(CriterionWrapper cw) {
            if (this.threshold > cw.threshold) { return -1; }
            if (this.threshold < cw.threshold) { return 1; }
            return 0;
        }

        private Integer sortThresholdIfLessOrEqual(CriterionWrapper cw) {
            if (this.threshold > cw.threshold) { return 1; }
            if (this.threshold < cw.threshold) { return -1; }
            return 0;
        }

    }

}