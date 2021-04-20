public without sharing class ASI_FOC_HK_Request_NotifySalesAdminCON {
    public boolean succeed {get; private set;}
    String reqId;
    public ASI_FOC_Free_Goods_Request__c req {get;set;}
    
    public ASI_FOC_HK_Request_NotifySalesAdminCON (ApexPages.StandardController stdController) {
         this.req = (ASI_FOC_Free_Goods_Request__c)stdController.getRecord();
         reqId = req.id;
    }
    
    public PageReference notifySalesAdmin(){        
        System.debug('Request ID: ' + reqId);
        List<ASI_FOC_Request_Item__c> itemList = [select name from ASI_FOC_Request_Item__c where ASI_FOC_Request_Order__c = :reqId];
        
        if (itemList.size() == 0){
            apexpages.addMessage(new apexpages.Message(apexpages.severity.warning, 'Please add Request Item before notify Sales Admin.'));
            succeed = false;
        }
        else {
            apexpages.addMessage(new apexpages.Message(apexpages.severity.info, 'Successfully notified Sales Admin to handle, click the button below to return to the request.'));
            ASI_FOC_Free_Goods_Request__c req = [select ASI_FOC_SYS_Notified_Sales_Admin__c from ASI_FOC_Free_Goods_Request__c where id = :reqId];
            req.ASI_FOC_SYS_Notified_Sales_Admin__c = true;
            update req;
            succeed = true;
        }
        return null;
    }
    
    public PageReference notifyRequester(){        
        System.debug('Request ID: ' + reqId);
                
        ASI_FOC_Free_Goods_Request__c req = [select ASI_FOC_SYS_Notified_Sales_Admin__c from ASI_FOC_Free_Goods_Request__c where id = :reqId];
        
        if (req.ASI_FOC_SYS_Notified_Sales_Admin__c == false){
            apexpages.addMessage(new apexpages.Message(apexpages.severity.warning, 'The request is still in Draft status for requester to handle.'));
            succeed = false;
        }
        else {
            req.ASI_FOC_SYS_Notified_Sales_Admin__c = false;
            update req;
            apexpages.addMessage(new apexpages.Message(apexpages.severity.info, 'Successfully notified requester, click the button below to return to the request.'));
            succeed = true;
        }
        
        return null;
    }
    
    public pageReference goBack() {
        return new pageReference('/' + reqId);
    }
}