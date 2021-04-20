public without sharing class ASI_MFM_CN_POSM_ApprovalEmailPDFCON {
    
    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }
    public String currentHeaderID {set;get;}
    public List<ASI_MFM_POSM_Return_Request_Item__c> ItemList {get;set;}
    public ASI_MFM_POSM_Return_Request__c ReturnRequest {get;set;}
    public Map<Id, Decimal> unitCostMap {get;set;}
    public Integer size {get;set;}
    public boolean init(){
        {
            ReturnRequest = new ASI_MFM_POSM_Return_Request__c();
            ReturnRequest = [Select Id, Name, ASI_MFM_Return_Request_Date__c, ASI_MFM_Return_Request_Time__c, ASI_MFM_Return_Request_Contact__c, ASI_MFM_Recipient_Contact__c
                                , ASI_MFM_To_Warehouse__c, ASI_MFM_To_Warehouse__r.Name, ASI_MFM_To_Warehouse__r.ASI_FOC_Warehouse_Code__c 
                                , ASI_MFM_Address__c,ASI_MFM_To_Address__c, ASI_MFM_To_Warehouse__r.ASI_MFM_Normal_Warehouse__c
                                , Owner.Name, ASI_MFM_Approver_1__r.Name, ASI_MFM_Approver_2__r.Name
                                //20200907 added by Leo Jing BLS strat.
                                ,ASI_MFM_Consignee__c,ASI_MFM_Consignee_Contact__c,ASI_MFM_Request_Delivery_Date__c,ASI_MFM_Other_Request__c
                            From ASI_MFM_POSM_Return_Request__c
                            Where Id = :currentHeaderID];

            ItemList = new List<ASI_MFM_POSM_Return_Request_Item__c>();
            ItemList = [SELECT Name
                        , ASI_MFM_SKU__c, ASI_MFM_SKU_Chinese_Description__c, ASI_MFM_SKU__r.Name, ASI_MFM_SKU__r.ASI_MFM_SKU_Code__c 
                        , ASI_MFM_QTY_Issued__c
                        , ASI_MFM_Item_Owner__c, ASI_MFM_VAS__c, ASI_MFM_Item_Owner__r.Name, ASI_MFM_Owner__c, ASI_MFM_Owner__r.Name, ASI_MFM_JDE_Owner__c 
                        FROM ASI_MFM_POSM_Return_Request_Item__c 
                        Where ASI_MFM_Request_Order__c = :currentHeaderID
                        Order By Name];
            Set<Id> skuIds = new Set<Id>();
            for (ASI_MFM_POSM_Return_Request_Item__c item : ItemList) {
                if (item.ASI_MFM_SKU__c != null) skuIds.add(item.ASI_MFM_SKU__c);
            }

            unitCostMap = new Map<Id, Decimal>();
            for(ASI_MFM_Inventory_Balance__c invBalance : [SELECT ASI_MFM_SKU__c, ASI_MFM_Unit_Cost__c FROM ASI_MFM_Inventory_Balance__c 
                                                            WHERE ASI_MFM_Warehouse__c = :ReturnRequest.ASI_MFM_To_Warehouse__r.ASI_MFM_Normal_Warehouse__c
                                                              AND ASI_MFM_SKU__c IN:skuIds]){
                unitCostMap.put(invBalance.ASI_MFM_SKU__c, invBalance.ASI_MFM_Unit_Cost__c != null ? invBalance.ASI_MFM_Unit_Cost__c : 0);
            }

            for (Id sku : skuIds) {
                if (!unitCostMap.containsKey(sku)) {
                    unitCostMap.put(sku, 0);
                }
            }
            size = skuIds.size();
            return true;
        }
    }

}