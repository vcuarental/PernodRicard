public without sharing class ASI_CTY_CN_WS_SalesOrderDetailEditCtrl {
    public String soHeaderId { get; private set; }
    public Boolean hasError { get; private set; }
    public Set<String> inApprovalSORStatus = new Set<String>{'Submitted','Pending for Order Advisor'};

    public ASI_CTY_CN_WS_SalesOrderDetailEditCtrl(ApexPages.StandardSetController stdSetController) {
        this.soHeaderId = ApexPages.currentPage().getParameters().get('id');
        hasError = false;
        ASI_KOR_Sales_Order_Request__c sor = [select ASI_KOR_Order_Status__c, ASI_CTY_CN_WS_IsCommunity__c from ASI_KOR_Sales_Order_Request__c where Id = :soHeaderId];
        if (!inApprovalSORStatus.contains(sor.ASI_KOR_Order_Status__c) || !sor.ASI_CTY_CN_WS_IsCommunity__c) {
            hasError = true;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Insufficient Privileges'));
            return;
        }
    }

    @RemoteAction
    public static List<ASI_KOR_Sales_Order_Transaction__c> lineItemList(ID headerId) {
        return [select ASI_CRM_CN_Product_Name__c, ASI_CRM_CN_Product_Name__r.Name, 
                       ASI_CRM_CN_Unit_Price_BT_with_VAT__c, ASI_KOR_Order_Qty__c,
                       ASI_CRM_UOM_Text__c, ASI_KOR_Sales_Order_Request__c,Id
                  from ASI_KOR_Sales_Order_Transaction__c
                  where ASI_KOR_Sales_Order_Request__c = :headerId];
    }

    @RemoteAction
    public static String saveChanges(String headerId, String changeItems, String deleteItems) {
        List<ASI_KOR_Sales_Order_Transaction__c> updateItems = new List<ASI_KOR_Sales_Order_Transaction__c>();
        if (String.isNotBlank(changeItems)) {
            List<Object> changeItemList = (List<Object>)JSON.deserializeUntyped(changeItems);
            for (Object obj : changeItemList) {
                Map<String, Object> objMap = (Map<String, Object>)obj;
                System.debug(LoggingLevel.INFO, '*** objMap: ' + objMap);
                ASI_KOR_Sales_Order_Transaction__c item = new ASI_KOR_Sales_Order_Transaction__c(Id = Id.valueOf(objMap.get('id') + ''), ASI_KOR_Order_Qty__c = Decimal.valueOf(objMap.get('orderQty') + ''));
                updateItems.add(item);
            }
        }

        List<Id> deleteIds = new List<Id>();
        if (String.isNotBlank(deleteItems)) {
            List<Object> deleteItemList = (List<Object>)JSON.deserializeUntyped(deleteItems);
            for (Object obj : deleteItemList) {
                System.debug(LoggingLevel.INFO, '*** obj: ' + obj);
                deleteIds.add(Id.valueOf(obj+''));
            }
            
        }
        try {
            if(Approval.isLocked(headerId)){
                Approval.unlock(headerId);
            }

            if (deleteIds.size() > 0) {
                Database.delete(deleteIds);
            }
            if (updateItems.size() > 0) {
                Database.update(updateItems);
            }

            Approval.lock(headerId);
            return 'SUCCESS';
        }catch(Exception e){
            System.debug(LoggingLevel.INFO, '*** e.getMessage(): ' + e.getMessage());
            return e.getMessage();
        }
    }

}