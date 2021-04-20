public with sharing class ASI_KOR_SalesOrderRequestSubmitCON {
    
    private static final String CHANGE_TO_STATUS = 'Requested';
    public ASI_KOR_Sales_Order_Request__c soReq { get; set; }
    
    public ASI_KOR_SalesOrderRequestSubmitCON(ApexPages.StandardController stdCon) {
        ID soReqId = stdCon.getId();
        this.soReq = [SELECT Id, ASI_KOR_Order_Status__c FROM ASI_KOR_Sales_Order_Request__c WHERE Id = :soReqId];
    }
    
    public PageReference submitSalesOrderRequest() {
        PageReference redirectPage = null;
        if (soReq.ASI_KOR_Order_Status__c != CHANGE_TO_STATUS) {
            soReq.ASI_KOR_Order_Status__c = CHANGE_TO_STATUS;
            try {
                update soReq;
                redirectPage = new PageReference('/' + soReq.Id);
            } catch (DmlException dmle) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, dmle.getDmlMessage(0)));
            }
        }
        return redirectPage;
    }
    
}