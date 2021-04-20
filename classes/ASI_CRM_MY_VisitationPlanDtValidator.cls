public with sharing class ASI_CRM_MY_VisitationPlanDtValidator extends ASI_HK_CRM_TriggerAbstract {

    public ASI_CRM_MY_VisitationPlanDtValidator() {
        super('ASI_CRM_MY_VisitationPlanDtValidator');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        if ((tAction == TriggerAction.AFTER_INSERT || tAction == TriggerAction.AFTER_UPDATE || tAction == TriggerAction.AFTER_UNDELETE)
            && !isBypassByCurrentUser()) {
            // Check whether validations are needed
            Boolean hasNewVisitDate = (tAction ==  TriggerAction.AFTER_UPDATE) ? false : true;
            List<ASI_HK_CRM_Visitation_Plan_Detail__c> visitDetailList = (List<ASI_HK_CRM_Visitation_Plan_Detail__c>)sObjList;
            if (tAction ==  TriggerAction.AFTER_UPDATE) {
                for (ASI_HK_CRM_Visitation_Plan_Detail__c visitDetail : visitDetailList) {
                    ASI_HK_CRM_Visitation_Plan_Detail__c oldVisitDetail = (ASI_HK_CRM_Visitation_Plan_Detail__c)oldMap.get(visitDetail.Id);
                    if (visitDetail.ASI_HK_CRM_Visit_Date__c != oldVisitDetail.ASI_HK_CRM_Visit_Date__c
                        || visitDetail.ASI_HK_CRM_Account__c != oldVisitDetail.ASI_HK_CRM_Account__c
                        || visitDetail.ASI_HK_CRM_Visitation_Plan__c != oldVisitDetail.ASI_HK_CRM_Visitation_Plan__c) {
                        hasNewVisitDate = true;
                        break;
                    }
                }
            }
            
            if (hasNewVisitDate) {
                final String errMsgNotMatchHeaderDate = Label.ASI_HK_CRM_TG_VPD_ERR_NotMatchHeaderDate;
                final String errMsgConflictDate = Label.ASI_HK_CRM_TG_VPD_ERR_ConflictDate;
                Map<String, Integer> visitMonthStrToIntMap = ASI_HK_CRM_VisitationPlanGenerator.getMonthPLValueToIntegerMap();
                // Get visitation headers
                Set<ID> visitHeaderIdSet = new Set<ID>();
                for (ASI_HK_CRM_Visitation_Plan_Detail__c visitDetail : visitDetailList) visitHeaderIdSet.add(visitDetail.ASI_HK_CRM_Visitation_Plan__c);
                Map<ID, ASI_HK_CRM_Visitation_Plan__c> visitHeaderMap = new Map<ID, ASI_HK_CRM_Visitation_Plan__c>(
                    [SELECT Id, ASI_HK_CRM_Sys_Year__c, ASI_HK_CRM_Month__c
                        , (SELECT Id, ASI_HK_CRM_Account__c, RecordType.DeveloperName, ASI_HK_CRM_Visit_Date__c FROM ASI_HK_CRM_Visitation_Plan_Details__r WHERE RecordType.DeveloperName = 'ASI_CRM_MY_VisitationPlanDetail')
                    FROM ASI_HK_CRM_Visitation_Plan__c
                    WHERE Id IN: visitHeaderIdSet]
                );
                
                Set<ID> foundDuplicateVDetailIdSet = new Set<ID>();
                // Start validating visitation details
                for (ASI_HK_CRM_Visitation_Plan_Detail__c visitDetail : visitDetailList) {
                    ASI_HK_CRM_Visitation_Plan__c visitHeader = visitHeaderMap.get(visitDetail.ASI_HK_CRM_Visitation_Plan__c);
                    Date visitDate = visitDetail.ASI_HK_CRM_Visit_Date__c;      
                    
                    ID visitAcctId = visitDetail.ASI_HK_CRM_Account__c;
 
                    //2013-01-21 by Stella Sing
                    //ByPass validation on ASI_TH_CRM_Visitation Plan Recordtype                    
                    // Visit date must be matched to its header year and month
                    if (visitDetail.RecordType.DeveloperName <> 'ASI_TH_CRM_Visitation_Plan_Detail'){
                        if (visitDate != null && (visitDate.year() != visitHeader.ASI_HK_CRM_Sys_Year__c
                            || visitDate.month() != visitMonthStrToIntMap.get(visitHeader.ASI_HK_CRM_Month__c))) {
                            
                            visitDetail.addError(errMsgNotMatchHeaderDate);
                        }
                    }  
                    // Do not allow visitations having same date for same Account
                    // The account already has visitation plan in this date
                    List<ASI_HK_CRM_Visitation_Plan_Detail__c> existingVisitDetails = visitHeader.ASI_HK_CRM_Visitation_Plan_Details__r;
                    Set<ID> tempFoundVDetailIdSet = new Set<ID>();
                    for (ASI_HK_CRM_Visitation_Plan_Detail__c existingVisitDetail : existingVisitDetails) {
                        /*if (existingVisitDetail.RecordType.DeveloperName == 'ASI_CRM_MY_VisitationPlanDetail' && existingVisitDetail.Id == visitDetail.Id && !foundDuplicateVDetailIdSet.contains(existingVisitDetail.Id)) {
                            if (visitDate != null && existingVisitDetail.ASI_HK_CRM_Visit_Date__c == visitDate && existingVisitDetail.ASI_HK_CRM_Account__c == visitAcctId) {
                                system.debug('---------------------------------------------------' + existingVisitDetail.id);
                                visitDetail.addError(errMsgConflictDate);
                                tempFoundVDetailIdSet.add(visitDetail.Id);
                                ASI_HK_CRM_Visitation_Plan_Detail__c triggerVisitDetail = (ASI_HK_CRM_Visitation_Plan_Detail__c)newMap.get(existingVisitDetail.Id);
                                if (triggerVisitDetail != null){
                                    system.debug('---------------------------------------------------' + existingVisitDetail.id);
                                    triggerVisitDetail.addError(errMsgConflictDate);
                                }
                                tempFoundVDetailIdSet.add(existingVisitDetail.Id);
                            }
                        }*/
                    }
                    foundDuplicateVDetailIdSet.addAll(tempFoundVDetailIdSet);
                }
            }
        } else if (tAction == TriggerAction.BEFORE_DELETE) {
            List<ASI_HK_CRM_Visitation_Plan_Detail__c> visitDetailList = (List<ASI_HK_CRM_Visitation_Plan_Detail__c>)sObjList;
            Set<ID> visitHeaderIdSet = new Set<ID>();
            for (ASI_HK_CRM_Visitation_Plan_Detail__c visitDetail : visitDetailList) visitHeaderIdSet.add(visitDetail.ASI_HK_CRM_Visitation_Plan__c);
            Map<ID, ASI_HK_CRM_Visitation_Plan__c> visitHeaderMap = new Map<ID, ASI_HK_CRM_Visitation_Plan__c>(
                [SELECT Id, ASI_HK_CRM_Confirmed__c FROM ASI_HK_CRM_Visitation_Plan__c WHERE Id IN: visitHeaderIdSet]
            );
            for (ASI_HK_CRM_Visitation_Plan_Detail__c visitDetail : visitDetailList) {
                ASI_HK_CRM_Visitation_Plan__c visitHeader = visitHeaderMap.get(visitDetail.ASI_HK_CRM_Visitation_Plan__c);
                if (visitHeader != null && visitHeader.ASI_HK_CRM_Confirmed__c == true) {
                    visitDetail.addError(Label.ASI_HK_CRM_TG_VPD_ERR_Confirmed);
                }
            }
        }
    }
}