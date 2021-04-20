public with sharing class ASI_KOR_POSMOrderRequestSubmitController {
    
    private static final String CHANGE_TO_STATUS = 'Requested';
    public ASI_KOR_POSM_Order_Request__c posmReq { get; set; }
    
    public ASI_KOR_POSMOrderRequestSubmitController(ApexPages.StandardController stdCon) {
        ID posmReqId = stdCon.getId();
        this.posmReq = [SELECT Id, ASI_KOR_Request_Status__c FROM ASI_KOR_POSM_Order_Request__c WHERE Id = :posmReqId];
    }
    
    public PageReference submitPOSMOrderRequest() {
        PageReference redirectPage = null;
        if (posmReq.ASI_KOR_Request_Status__c != CHANGE_TO_STATUS) {
            posmReq.ASI_KOR_Request_Status__c = CHANGE_TO_STATUS;
            try {
                update posmReq;
                redirectPage = new PageReference('/' + posmReq.Id);
            } catch (DmlException dmle) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, dmle.getDmlMessage(0)));
            }
        }
        return redirectPage;
    }
    
}