public with sharing class ASI_KOR_StockInTradeDtEditController implements ASI_KOR_SFObjSelectTableAbstract, ASI_KOR_MassCreateAndUpdateAbstract {
    
    public final static String STATUS_LOCKED = 'Locked';
    public final static Map<String, String> COPY_DETAIL_IG_FIELD_MAP = new Map<String, String> {
        
    };
    public final static String BTN_ID_ADD = 'add';
    public ASI_KOR_Stock_In_Trade__c stockInTradeHeader { get; set; }
    public ASI_KOR_WS_Stock_In_Trade_Detail__c filterSitDetail { get; set; }
    public String filterIGNameOrCode { get; set; }
    public Boolean isLocked { get; set; }
    public String baseWhereStatm { get; set; }
    
    private Set<String> siTradeDtCloneFieldSet;
    private Map<String, Integer> monthIntMap;
    
    public ASI_KOR_StockInTradeDtEditController(ApexPages.StandardController stdController) {
        ID stockInTradeHeaderId = null;
        if (stdController != null)
            stockInTradeHeaderId = stdController.getId();
        if (stockInTradeHeaderId == null)
            stockInTradeHeaderId = ApexPages.currentPage().getParameters().get('newid');
        this.stockInTradeHeader = [
            SELECT Id, ASI_KOR_Wholesaler__c, ASI_KOR_Year__c, ASI_KOR_Month__c, ASI_KOR_Status__c, ASI_KOR_Sys_YearMonthNumber__c
                , (SELECT Id, ASI_KOR_Item_Group_Code__c, ASI_KOR_WS_SIT_LastMonthEndingStock__c FROM Stock_In_Trade_Details__r)
            FROM ASI_KOR_Stock_In_Trade__c
            WHERE Id = :stockInTradeHeaderId];
        this.isLocked = stockInTradeHeader.ASI_KOR_Status__c == STATUS_LOCKED;
        if (this.isLocked) {
            showPageError(Label.ASI_KOR_VF_SIT_ERR_IsLocked);
            return;
        }
        this.filterSitDetail = new ASI_KOR_WS_Stock_In_Trade_Detail__c();
        this.baseWhereStatm = 'ASI_KOR_Active__c = TRUE';
        this.monthIntMap = ASI_KOR_StockInTradeGenerator.getMonthPLValueToIntegerMap();
        this.siTradeDtCloneFieldSet = getStockInTradeDetailCloneFields();
        this.componentControllerMap = new Map<String, ASI_KOR_ComponentInterface>();
    }
    
    public void filterItemGroup() {
        String itemGroupNameOrCode = this.filterIGNameOrCode;
        String subBrandId = this.filterSitDetail.ASI_KOR_SYS_FILTER_SUB_BRAND__c;
        String whereStatm = '';
        if (itemGroupNameOrCode != null && itemGroupNameOrCode.trim() != '') {
            whereStatm += '(Name LIKE \'%' + itemGroupNameOrCode + '%\' OR ASI_KOR_Item_Group_Name__c LIKE \'%' + itemGroupNameOrCode + '%\' OR ASI_KOR_Name_Kor__c LIKE \'%' + itemGroupNameOrCode + '%\')';
        }
        if (subBrandId != null && subBrandId.trim() != '') {
            if (whereStatm.length() > 0) whereStatm += ' AND ';
            whereStatm += 'ASI_KOR_Sub_Brand__c = \'' + subBrandId + '\'';
        }
        if (whereStatm.trim() == '')
            whereStatm = baseWhereStatm == '' ? null : baseWhereStatm;
        else if (baseWhereStatm != null && baseWhereStatm.trim() != '')
            whereStatm = '(' + whereStatm + ') AND (' + baseWhereStatm + ')';
        
        ASI_KOR_SFObjSelectTableController sobjstController = (ASI_KOR_SFObjSelectTableController)this.getComponentController('selectTable');
        if (sobjstController != null) {
            sobjstController.setDataFilter(whereStatm);
            sobjstController.reloadData();
        }
    }
    
    /**
     * Methods to implement the ASI_KOR_SFObjSelectTableAbstract
     */
    
    public List<ASI_KOR_SFObjSelectTableController.SFObjSelectTableActionBtn> sobjst_initActionButtonList() {
        return null;
    }
    
    public Map<ID, Map<String, Integer>> sobjst_initActionButtonStageMap() {
        Map<ID, Map<String, Integer>> btnStageMap = new Map<ID, Map<String, Integer>>();
        List<ASI_KOR_WS_Stock_In_Trade_Detail__c> tempSIDetailList = this.stockInTradeHeader.Stock_In_Trade_Details__r;
        if (tempSIDetailList != null) {
            for (ASI_KOR_WS_Stock_In_Trade_Detail__c tempSIDetail : tempSIDetailList) {
                if (tempSIDetail.ASI_KOR_Item_Group_Code__c != null) {
                    btnStageMap.put(
                        tempSIDetail.ASI_KOR_Item_Group_Code__c
                        , new Map<String, Integer>{BTN_ID_ADD => 1});
                }
            }
        }
        return btnStageMap;
    }
    
    public void sobjst_triggerActionForSObject(ASI_KOR_SFObjSelectTableController controller, String actionKey, sObject sObj) {
        if (actionKey == 'add') {
            ASI_KOR_MassCreateAndUpdateController mcauC = (ASI_KOR_MassCreateAndUpdateController)this.getComponentController('massCreateAndUpdate');
            List<ASI_KOR_Item_Group__c> itemGroupList = [SELECT Id FROM ASI_KOR_Item_Group__c WHERE Id = :sObj.Id LIMIT 1];
            if (itemGroupList.size() > 0) {
                ASI_KOR_Item_Group__c itemGroup = itemGroupList.get(0);
                ASI_KOR_WS_Stock_In_Trade_Detail__c stockInTradeDetail = new ASI_KOR_WS_Stock_In_Trade_Detail__c(
                    Stock_In_Trade__c = this.stockInTradeHeader.Id
                    , ASI_KOR_Item_Group_Code__c = itemGroup.Id
                    , ASI_KOR_WS_SIT_End_Stock__c = null
                );
                Set<String> siTradeDetailFieldSet = COPY_DETAIL_IG_FIELD_MAP.keySet();
                for (String siTradeFN : siTradeDetailFieldSet) {
                    String itemGroupFN = COPY_DETAIL_IG_FIELD_MAP.get(siTradeFN);
                    stockInTradeDetail.put(siTradeFN, itemGroup.get(itemGroupFN));
                }
                mcauC.addNewRowByInfo(ASI_KOR_MassCreateAndUpdateController.RTDEVNAME_MASTER, stockInTradeDetail);
            }
        }
    }
    
    /**
     * Methods to implement the ASI_KOR_MassCreateAndUpdateAbstract
     */
    
    public List<ASI_KOR_MassCreateAndUpdateController.PageBlockActionBtn> mcau_initPageBlockActionButtonList() {
        return new List<ASI_KOR_MassCreateAndUpdateController.PageBlockActionBtn>{
            new ASI_KOR_MassCreateAndUpdateController.PageBlockActionBtn('cloneLatest', 'Clone From Last Month')
        };
    }
    
    public PageReference mcau_triggerPageBlockAction(ASI_KOR_MassCreateAndUpdateController controller, String actionKey) {
        if ('cloneLatest' == actionKey) {
            controller.clearAll();
            ASI_KOR_SFObjSelectTableController sobjstController = (ASI_KOR_SFObjSelectTableController)componentControllerMap.get('selectTable');
            sobjstController.setBtnStagesForAll(new Map<String, Integer>{BTN_ID_ADD => 0});
            ASI_KOR_Stock_In_Trade__c latestSITrade = getLastLatestStockInTrade(this.siTradeDtCloneFieldSet);
            if (latestSITrade != null && latestSITrade.Stock_In_Trade_Details__r != null) {
                List<ASI_KOR_WS_Stock_In_Trade_Detail__c> siTradeDetailList = latestSITrade.Stock_In_Trade_Details__r;
                for (ASI_KOR_WS_Stock_In_Trade_Detail__c siTradeDetail : siTradeDetailList) {
                    ASI_KOR_WS_Stock_In_Trade_Detail__c newSITradeDetail = siTradeDetail.clone(false, false, false, false);
                    newSITradeDetail.Stock_In_Trade__c = this.stockInTradeHeader.Id;
                    newSITradeDetail.ASI_KOR_WS_SIT_LastMonthEndingStock__c = newSITradeDetail.ASI_KOR_WS_SIT_End_Stock__c;
                    newSITradeDetail.ASI_CRM_External_ID__c = ''; //20160901
                    controller.addNewRowByInfo(ASI_KOR_MassCreateAndUpdateController.RTDEVNAME_MASTER, newSITradeDetail);
                    sobjstController.setBtnStageBySObjId(newSITradeDetail.ASI_KOR_Item_Group_Code__c, BTN_ID_ADD, 1);
                }
            }
        }
        return null;
    }
    
    public void mcau_triggerActionForSObject(ASI_KOR_MassCreateAndUpdateController controller, String actionKey, sObject sObj) {
        ASI_KOR_WS_Stock_In_Trade_Detail__c sitDetail = (ASI_KOR_WS_Stock_In_Trade_Detail__c)sObj;
        if (sitDetail != null && sitDetail.ASI_KOR_Item_Group_Code__c != null && actionKey == ASI_KOR_MassCreateAndUpdateController.ACTION_REMOVE_NEW) {
            ASI_KOR_SFObjSelectTableController selectTableC = (ASI_KOR_SFObjSelectTableController)this.getComponentController('selectTable');
            selectTableC.setBtnStageBySObjId(sitDetail.ASI_KOR_Item_Group_Code__c, BTN_ID_ADD, 0);
        }
    }
    
    
    
    private ASI_KOR_Stock_In_Trade__c getLastLatestStockInTrade(Set<String> stockInTradeDetailFieldSet) {
        ID acctId = stockInTradeHeader.ASI_KOR_Wholesaler__c;
        Decimal yearMonthNum = stockInTradeHeader.ASI_KOR_Sys_YearMonthNumber__c;
        List<ASI_KOR_Stock_In_Trade__c> latestSITradeList = database.query(String.format('SELECT Id, ASI_KOR_Year__c, ASI_KOR_Month__c, (SELECT {0} FROM Stock_In_Trade_Details__r) FROM ASI_KOR_Stock_In_Trade__c WHERE ASI_KOR_Wholesaler__c = :acctId AND ASI_KOR_Sys_YearMonthNumber__c < :yearMonthNum ORDER BY ASI_KOR_Sys_YearMonthNumber__c DESC LIMIT 1', new String[] {
            String.join(new List<String>(stockInTradeDetailFieldSet), ',')
        }));
        return latestSITradeList.size() == 0 ? null : latestSITradeList.get(0);
    }
    
    private Set<String> getStockInTradeDetailCloneFields() {
        Map<String, Schema.SObjectField> allFieldDescribeMap = Schema.SObjectType.ASI_KOR_WS_Stock_In_Trade_Detail__c.fields.getMap();
        Set<String> allFieldSet = allFieldDescribeMap.keySet();
        Set<String> cloneFieldSet = new Set<String>();
        for (String fn : allFieldSet) {
            Schema.DescribeFieldResult fieldDescribe = allFieldDescribeMap.get(fn).getDescribe();
            if (!fieldDescribe.isCalculated() && !fieldDescribe.isAutoNumber()) {
                cloneFieldSet.add(fn);
            }
        }
        return cloneFieldSet;
    }
    
    private void showPageMessage(ApexPages.Severity severity, String msg) {
        ApexPages.addMessage(new ApexPages.Message(severity, msg));
    }
    
    private void showPageError(String msg) {
        showPageMessage(ApexPages.Severity.ERROR, msg);
    }
    
    /*
     * Methods and variables that extend the ASI_KOR_PageInterface
     */
    
    private static String DEF_CC_KEY = 'DEFAULT';
    private Map<String, ASI_KOR_ComponentInterface> componentControllerMap;
    public ASI_KOR_StockInTradeDtEditController thisController { get {return this;} set; }
    public void setComponentController(ASI_KOR_ComponentInterface cController) {
        this.componentControllerMap.put(DEF_CC_KEY, cController);
    }
    public void setComponentController(String key, ASI_KOR_ComponentInterface cController) {
        this.componentControllerMap.put(key, cController);
    }
    public ASI_KOR_ComponentInterface getComponentController() {
        return this.componentControllerMap.get(DEF_CC_KEY);
    }
    public ASI_KOR_ComponentInterface getComponentController(String key) {
        return this.componentControllerMap.get(key);
    }
    
    
    
}