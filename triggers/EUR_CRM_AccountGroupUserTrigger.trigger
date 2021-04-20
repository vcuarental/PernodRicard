trigger EUR_CRM_AccountGroupUserTrigger on EUR_CRM_AccountGroupUser__c (before delete, after insert, after undelete,
        before update) {

    new EUR_CRM_AccountGroupUserTriggerHandler().run();
    //new EUR_CRM_AccGrpUsrTrgrHndlrWithoutSharing().run();
}