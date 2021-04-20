/*********************************************************************************
 * Name: ASI_FOC_HK_RequestDetailEditCON
 * Description: 
 * Test Class: 
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-07-12		Wilken Lee				[WL 1.0] Remove ASI_HK_CRM_Active__c checking for FOC SKU selection
*/
public with sharing class ASI_FOC_HK_RequestDetailEditCON extends ASI_FOC_AbstractPageController implements ASI_FOC_MassCreateAndUpdateAbstract, ASI_FOC_SFObjSelectTableAbstract {
    
    public String baseWhereStatm { get; private set; }
    public ASI_FOC_Request_Item__c filterReqItemInput { get; set; }
    public String filterName { get; set; }
    public boolean disableClone {get; private set;}
    public boolean showSKUList {get; private set;}
    private String defReqItemRTDevName;
    private List<ASI_FOC_Request_Item__c> origReqItemList;
    private ASI_FOC_Free_Goods_Request__c req;
    
    public ASI_FOC_HK_RequestDetailEditCON(ApexPages.StandardSetController stdSetCON) {
        this.defReqItemRTDevName = ASI_FOC_FreeGoodRequestDetailGenerator.RT_HK;
        this.filterReqItemInput = new ASI_FOC_Request_Item__c();
        this.disableClone = false;
        this.showSKUList = true;
        String reqId = ApexPages.currentPage().getParameters().get('id');
        if (reqId != null && reqId.trim() != '') {
            this.origReqItemList = [SELECT Id, ASI_FOC_SKU__c FROM ASI_FOC_Request_Item__c WHERE ASI_FOC_Request_Order__c = :reqId];
            this.req = [select ASI_FOC_Request_Status__c, ASI_FOC_Request_Type__c from ASI_FOC_Free_Goods_Request__c where id = :reqId];
            if (this.req.ASI_FOC_Request_Status__c == 'Rejected by Logistic') {
                this.disableClone = true;
                this.showSKUList = false;
            }
        }
        
        System.debug('Before base Statement');
			/*[WL 1.0] BEGIN*/
            //this.baseWhereStatm = 'RecordType.DeveloperName = \'' + ASI_FOC_SKUGenerator.RT_HK + '\' AND ASI_FOC_Active__c = TRUE AND ASI_FOC_Inventory__c > 0 AND ASI_HK_CRM_Active__c = TRUE ';
			this.baseWhereStatm = 'RecordType.DeveloperName = \'' + ASI_FOC_SKUGenerator.RT_HK + '\' AND ASI_FOC_Active__c = TRUE AND ASI_FOC_Inventory__c > 0 ';
			/*[WL 1.0] END*/
            //AND ASI_FOC_Stock_Price__c != NULL AND ASI_FOC_Stock_Price__c > 0 
        
        System.debug('After base Statement');
        
        //Check is POS Request Type
        if (req.ASI_FOC_Request_Type__c == 'POS'){
            this.baseWhereStatm += 'and ASI_HK_CRM_IsPOSProduct__c = true';
        }
        else {
            this.baseWhereStatm += 'and ASI_HK_CRM_IsPOSProduct__c = false';
        }
    }
    
    public void filterSKU() {
        String whereStatm = baseWhereStatm;
        ID filterSubBrandId = this.filterReqItemInput.ASI_FOC_Sys_InputSubBrand__c;
        ID filterBrandId = this.filterReqItemInput.ASI_FOC_Sys_InputBrand__c;
        if (filterName != null && filterName.trim() != '') {
            whereStatm += ' AND Name LIKE \'%' + String.escapeSingleQuotes(filterName.trim()) + '%\'';
        }
        if (filterSubBrandId != null) {
            whereStatm += ' AND ASI_MFM_Sub_brand__c = \'' + String.escapeSingleQuotes((String)filterSubBrandId) + '\'';
        }
        if (filterBrandId != null) {
            whereStatm += ' AND ASI_MFM_Sub_brand__r.ASI_MFM_Brand__c = \'' + String.escapeSingleQuotes((String)filterBrandId) + '\'';
        }
        ASI_FOC_SFObjSelectTableController sobjstController = (ASI_FOC_SFObjSelectTableController)this.getComponentController('selectTable');
        
        System.debug('Where Statement: ' + whereStatm);
        if (sobjstController != null) {
            sobjstController.setDataFilter(whereStatm);
            sobjstController.reloadData();
        }
    }
    
    /**
     * Methods to implement the ASI_FOC_MassCreateAndUpdateAbstract
     */
    
    public List<ASI_FOC_MassCreateAndUpdateController.PageBlockActionBtn> mcau_initPageBlockActionButtonList() {
        return null;
    }
    
    public PageReference mcau_triggerPageBlockAction(ASI_FOC_MassCreateAndUpdateController controller, String actionKey) {
        return null;
    }
    
    public void mcau_triggerActionForSObject(ASI_FOC_MassCreateAndUpdateController controller, String actionKey, sObject sObj) {
        ASI_FOC_Request_Item__c reqItem = (ASI_FOC_Request_Item__c)sObj;
        if (reqItem != null && reqItem.ASI_FOC_SKU__c != null 
            && (actionKey == ASI_FOC_MassCreateAndUpdateController.ACTION_REMOVE_NEW
                || actionKey == ASI_FOC_MassCreateAndUpdateController.ACTION_DELETE_OLD
                )
            ) {
            ASI_FOC_SFObjSelectTableController selectTableC = (ASI_FOC_SFObjSelectTableController)this.getComponentController('selectTable');
            selectTableC.setBtnStageBySObjId(
                reqItem.ASI_FOC_SKU__c
                , ASI_FOC_SFObjSelectTableController.DEF_BTN_KEY_ADD
                , ASI_FOC_SFObjSelectTableController.DEF_BTN_ADD_STAGE_NOT_ADD
            );
        }
    }
    
    /**
     * Methods to implement the ASI_FOC_SFObjSelectTableAbstract
     */
    
    public List<ASI_FOC_SFObjSelectTableController.SFObjSelectTableActionBtn> sobjst_initActionButtonList() {
        return null;
    }
    
    public Map<ID, Map<String, Integer>> sobjst_initActionButtonStageMap() {
        if (this.origReqItemList != null && this.origReqItemList.size() > 0) {
            final String btnKeyAdd = ASI_FOC_SFObjSelectTableController.DEF_BTN_KEY_ADD;
            final Integer btnAddStageAdded = ASI_FOC_SFObjSelectTableController.DEF_BTN_ADD_STAGE_ADDED;
            Map<ID, Map<String, Integer>> btnStageMap = new Map<ID, Map<String, Integer>>();
            for (ASI_FOC_Request_Item__c reqItem : this.origReqItemList) {
                ID skuId = reqItem.ASI_FOC_SKU__c;
                if (skuId != null) {
                    btnStageMap.put(
                    skuId
                    , new Map<String, Integer> {
                        btnKeyAdd => btnAddStageAdded
                        }
                    );
                }
            }
            if (btnStageMap.size() > 0)
                return btnStageMap;
        }
        return null;
    }
    
    public void sobjst_triggerActionForSObject(ASI_FOC_SFObjSelectTableController controller, String actionKey, sObject sObj) {
        if (actionKey == ASI_FOC_SFObjSelectTableController.DEF_BTN_KEY_ADD) {
            ASI_FOC_MassCreateAndUpdateController mcauC = (ASI_FOC_MassCreateAndUpdateController)this.getComponentController('massCreateAndUpdate');
            ASI_MFM_SKU_Code__c sku = (ASI_MFM_SKU_Code__c)sObj;
            ASI_FOC_Request_Item__c reqItem = new ASI_FOC_Request_Item__c(
                ASI_FOC_SKU__c = sku.Id
                , ASI_FOC_Allow_for_Editing__c = false
            );
            mcauC.addNewRowByInfo(this.defReqItemRTDevName, reqItem);
        }
    }
}