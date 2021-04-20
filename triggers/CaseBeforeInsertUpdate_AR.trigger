/******************************************************************************************
*   Company:Valuenet    Developers:Elena Schwarzböck-Tomás Etchegaray  Date:19/03/2013    *
*******************************************************************************************/


trigger CaseBeforeInsertUpdate_AR on Case (before insert, before update) {
    String i = '';
/*
    public static map<Id, RecordType> mapIdRt = new map<Id, RecordType>(Global_RecordTypeCache.getRtList('Case'));
    set<String> rtsARUY = new Set<String>{'CSE_1_AccountAlteration_ARG','CSE_2_AccountAlteration_URU','CSE_OverdueAccount_AR','CSE_OverdueAccount_UY','CSE_OverdueJustification_AR','CSE_OverdueJustification_UY','CSE_OverdueToAttorneys_AR','CSE_OverdueToAttorneys_UY','CSE_PaymentProposal_AR','CSE_PaymentProposal_UY','CSE_WOPaymentProposal_AR','CSE_WOPaymentProposal_UY'};
        
    List<Case> triggerNewARUY = new List<Case>();
    map<Id, Case> triggerOldMapARUY = new map<Id, Case>();
    for(Case cse: trigger.new){
        if(rtsARUY.contains(mapIdRt.get(cse.RecordTypeId).DeveloperName) ){
            triggerNewARUY.add(cse);
            if(trigger.isUpdate){
                triggerOldMapARUY.put(cse.Id, trigger.oldMap.get(cse.Id));
            }
        }        
    }
    if(!triggerNewARUY.isEmpty()){
        if ( (trigger.isUpdate ) || (trigger.isInsert )){
            AP01_Case_AR.UpdateAccountOwnerAndManagerOwner(triggerNewARUY);
            AP01_Case_AR.UpdateRtandIsoCode(triggerNewARUY);
            AP01_Case_AR.UpdateSubject(triggerNewARUY, 'insert');
        }
        if (trigger.isUpdate  ){
            AP01_Case_AR.TypeValidation(triggerNewARUY, triggerOldMapARUY);
            AP02_CaseWOS_AR.ApprovalProcessFlow(triggerNewARUY, triggerOldMapARUY);
            AP01_Case_AR.ValidateCloseCase(triggerNewARUY);
        }
    }
*/
}