public without sharing class EUR_CRM_AccountApprovalProcess {

    @InvocableMethod
    public static void unlock(List<EUR_CRM_Account__c> accounts) {
        List<EUR_CRM_Account__c> accsForUpdate = new List<EUR_CRM_Account__c>();
        for(EUR_CRM_Account__c acc : accounts) {
            accsForUpdate.add(new EUR_CRM_Account__c(
                Id = acc.Id,
                EUR_CRM_Unlock__c = false
            ));
        }
        System.debug('update: ' + Database.update(accsForUpdate, false));
        System.debug('accsForUnlock: ' + Approval.unlock(accsForUpdate, false));
    }

    public static void submitForApproval(List<EUR_CRM_Account__c> accounts, Map<Id, EUR_CRM_Account__c> oldAccountById) {
        List<Approval.ProcessRequest > requests = new List<Approval.ProcessRequest>();
        for(EUR_CRM_Account__c acc : accounts) {
            EUR_CRM_Account__c oldAcc = oldAccountById == null ? null : oldAccountById.get(acc.Id);
            if(acc.EUR_CRM_Country_Code__c == 'RU' && acc.EUR_CRM_Status_Requested__c != null &&
                (oldAcc == null || oldAcc.EUR_CRM_Status_Requested__c != acc.EUR_CRM_Status_Requested__c)
            ) {
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setObjectId(acc.id);
                requests.add(req);
            }
        }
        if(!requests.isEmpty()) {
            Approval.process(requests);
        }
    }
}