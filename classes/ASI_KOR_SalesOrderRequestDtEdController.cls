public with sharing class ASI_KOR_SalesOrderRequestDtEdController implements ASI_KOR_SFObjSelectTableAbstract, ASI_KOR_MassCreateAndUpdateAbstract {
    
    public final String STATUS_LOCKED = 'Locked';
    public final static Map<String, String> COPY_DETAIL_IG_FIELD_MAP = new Map<String, String> {
        
    };
    public ASI_KOR_Sales_Order_Request__c soReqHeader { get; set; }
    public ASI_KOR_Sales_Order_Transaction__c filterSOReqDetail { get; set; }
    public String filterIGNameOrCode { get; set; }
    public String baseWhereStatm { get; set; }
    
    public ASI_KOR_SalesOrderRequestDtEdController(ApexPages.StandardSetController stdSetController) {
        String soReqHeaderId = ApexPages.currentPage().getParameters().get('id');
        this.soReqHeader = [SELECT Id, (SELECT Id, ASI_KOR_Item_Group_Code__c FROM ASI_KOR_Sales_Order_Transactions__r) FROM ASI_KOR_Sales_Order_Request__c WHERE Id = :soReqHeaderId];
        this.filterSOReqDetail = new ASI_KOR_Sales_Order_Transaction__c();
        this.baseWhereStatm = generateBaseWhereStatement();
        this.componentControllerMap = new Map<String, ASI_KOR_ComponentInterface>();
    }
    
    public void filterItemGroup() {
        String itemGroupNameOrCode = this.filterIGNameOrCode;
        String subBrandId = this.filterSOReqDetail.ASI_KOR_SYS_FILTER_SUB_BRAND__c;
        String whereStatm = '';
        if (itemGroupNameOrCode != null && itemGroupNameOrCode.trim() != '') {
            whereStatm += '(Name LIKE \'%' + itemGroupNameOrCode + '%\' OR ASI_KOR_Item_Group_Name__c LIKE \'%' + itemGroupNameOrCode + '%\' OR ASI_KOR_Name_Kor__c LIKE \'%' + itemGroupNameOrCode + '%\')';
        }
        if (subBrandId != null) {
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
        return null;
    }
    
    public void sobjst_triggerActionForSObject(ASI_KOR_SFObjSelectTableController controller, String actionKey, sObject sObj) {
        if (actionKey == 'add') {
            ASI_KOR_MassCreateAndUpdateController mcauC = (ASI_KOR_MassCreateAndUpdateController)this.getComponentController('massCreateAndUpdate');
            /* Query record only if other fields are needed
            List<ASI_KOR_Item_Group__c> itemGroupList = [SELECT Id FROM ASI_KOR_Item_Group__c WHERE Id = :sObj.Id LIMIT 1];
            if (itemGroupList.size() > 0) {
                ASI_KOR_Item_Group__c itemGroup = itemGroupList.get(0);
                ASI_KOR_Sales_Order_Transaction__c soReqTrans = new ASI_KOR_Sales_Order_Transaction__c(
                    ASI_KOR_Sales_Order_Request__c = this.soReqHeader.Id
                    , ASI_KOR_Item_Group_Code__c = itemGroup.Id
                );
                mcauC.addNewRowByInfo(ASI_KOR_MassCreateAndUpdateController.RTDEVNAME_MASTER, soReqTrans);
            }*/
            ASI_KOR_Item_Group__c itemGroup = (ASI_KOR_Item_Group__c)sObj;
            if (itemGroup != null) {
                ASI_KOR_Sales_Order_Transaction__c soReqTrans = new ASI_KOR_Sales_Order_Transaction__c(
                    ASI_KOR_Sales_Order_Request__c = this.soReqHeader.Id
                    , ASI_KOR_Item_Group_Code__c = itemGroup.Id
                );
                mcauC.addNewRowByInfo(ASI_KOR_MassCreateAndUpdateController.RTDEVNAME_MASTER, soReqTrans);
            }
        }
    }
    
    /**
     * Methods to implement the ASI_KOR_MassCreateAndUpdateAbstract
     */
    
    public List<ASI_KOR_MassCreateAndUpdateController.PageBlockActionBtn> mcau_initPageBlockActionButtonList() {
        return null;
    }
    
    public PageReference mcau_triggerPageBlockAction(ASI_KOR_MassCreateAndUpdateController controller, String actionKey) {
        return null;
    }
    
    public void mcau_triggerActionForSObject(ASI_KOR_MassCreateAndUpdateController controller, String actionKey, sObject sObj) {
        ASI_KOR_Sales_Order_Transaction__c soTran = (ASI_KOR_Sales_Order_Transaction__c)sObj;
        if (soTran != null && soTran.ASI_KOR_Item_Group_Code__c != null && actionKey == ASI_KOR_MassCreateAndUpdateController.ACTION_REMOVE_NEW) {
            ASI_KOR_SFObjSelectTableController selectTableC = (ASI_KOR_SFObjSelectTableController)this.getComponentController('selectTable');
            selectTableC.setBtnStageBySObjId(soTran.ASI_KOR_Item_Group_Code__c, 'add', 0);
        }
    }
    
    private String generateBaseWhereStatement() {
        String result = 'ASI_KOR_Active__c = TRUE';
        if (this.soReqHeader != null && this.soReqHeader.ASI_KOR_Sales_Order_Transactions__r != null && this.soReqHeader.ASI_KOR_Sales_Order_Transactions__r.size() > 0) {
            List<ASI_KOR_Sales_Order_Transaction__c> soReqDetailList = this.soReqHeader.ASI_KOR_Sales_Order_Transactions__r;
            List<String> itemGoupIdList = new List<String>();
            for (ASI_KOR_Sales_Order_Transaction__c soReqDetail : soReqDetailList) {
                ID itemGoupId = soReqDetail.ASI_KOR_Item_Group_Code__c;
                if (itemGoupId != null)
                    itemGoupIdList.add(itemGoupId);
            }
            if (itemGoupIdList.size() > 0) {
                result += ' AND Id NOT IN (' + ASI_KOR_CommonUtils.generateSeparatedStringWithQuote(itemGoupIdList, ',', '\'') + ')';
            }
        }
        return result;
    }
    
    /*
     * Methods and variables that extend the ASI_KOR_PageInterface
     */
    
    private static String DEF_CC_KEY = 'DEFAULT';
    private Map<String, ASI_KOR_ComponentInterface> componentControllerMap;
    public ASI_KOR_SalesOrderRequestDtEdController thisController { get {return this;} set; }
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