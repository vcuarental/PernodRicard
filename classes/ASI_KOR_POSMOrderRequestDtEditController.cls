public with sharing class ASI_KOR_POSMOrderRequestDtEditController implements ASI_KOR_SFObjSelectTableAbstract, ASI_KOR_MassCreateAndUpdateAbstract {
    
    public final String STATUS_LOCKED = 'Locked';
    public final static Map<String, String> COPY_DETAIL_IG_FIELD_MAP = new Map<String, String> {
        
    };
    public ASI_KOR_POSM_Order_Request__c posmReqHeader { get; set; }
    public String filterNameOrCode { get; set; }
    public ASI_KOR_POSM_Order_Detail__c filterPosmReqDetail { get; set; }
    public String filterType { get; set; }
    public List<SelectOption> filterTypeSelectOptions { get; set; }
    public String baseWhereStatm { get; set; }
    
    public ASI_KOR_POSMOrderRequestDtEditController(ApexPages.StandardSetController stdSetController) {
        String posmReqHeaderId = ApexPages.currentPage().getParameters().get('id');
        //delete by Elufa support 20160525
        this.posmReqHeader = [SELECT Id, (SELECT Id, ASI_KOR_Item_Name__c FROM ASI_KOR_POSM_Order_Details__r) FROM ASI_KOR_POSM_Order_Request__c WHERE Id = :posmReqHeaderId];
        //this.posmReqHeader = [SELECT Id, ASI_KOR_Item_Owner__c, (SELECT Id, ASI_KOR_Item_Name__c FROM ASI_KOR_POSM_Order_Details__r) FROM ASI_KOR_POSM_Order_Request__c WHERE Id = :posmReqHeaderId];
        this.filterPosmReqDetail = new ASI_KOR_POSM_Order_Detail__c();
        this.filterTypeSelectOptions = filterTypeOptions();
        this.baseWhereStatm = generateBaseWhereStatement();
        this.componentControllerMap = new Map<String, ASI_KOR_ComponentInterface>();
    }
    
    public void filterPOSMProduct() {
        String posmNameOrCode = this.filterNameOrCode;
        String subBrandId = this.filterPosmReqDetail.ASI_KOR_SYS_FILTER_POSM_SUB_BRAND__c;
        String posmPdType = filterType;
        String whereStatm = '';
        if (posmNameOrCode != null && posmNameOrCode.trim() != '') {
            whereStatm += '(Name LIKE \'%' + posmNameOrCode + '%\' OR ASI_KOR_Item_Code__c LIKE \'%' + posmNameOrCode + '%\' OR ASI_KOR_Item_Name_Kor__c LIKE \'%' + posmNameOrCode + '%\')';
        }
        if (subBrandId != null) {
            if (whereStatm.length() > 0) whereStatm += ' AND ';
            whereStatm += 'ASI_KOR_Sub_Brand__c = \'' + subBrandId + '\'';
        }
        if (posmPdType != null) {
            if (whereStatm.length() > 0) whereStatm += ' AND ';
            whereStatm += 'ASI_KOR_Type__c = \'' + posmPdType + '\'';
        }
        if (whereStatm.trim() == '')
            whereStatm = baseWhereStatm == '' ? null : baseWhereStatm;
        else if (baseWhereStatm != null && baseWhereStatm.trim() != '')
            whereStatm = '(' + whereStatm + ') AND (' + baseWhereStatm + ')';
        
        ASI_KOR_SFObjSelectTableController sobjstController = (ASI_KOR_SFObjSelectTableController)this.getComponentController('selectTable');
        if (sobjstController != null) {
            System.debug('whereStatm: ' + whereStatm);
            sobjstController.setDataFilter(whereStatm);
            sobjstController.reloadData();
        }
    }
    
    private List<SelectOption> filterTypeOptions() {
        List<SelectOption> result = new List<SelectOption>();
        List<Schema.PicklistEntry> typePLs = ASI_KOR_POSM_Product__c.ASI_KOR_Type__c.getDescribe().getPicklistValues();
        for (Schema.PicklistEntry typePL : typePLs) {
            result.add(new SelectOption(typePL.getValue(), typePL.getLabel()));
        }
        return result;
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
            List<ASI_KOR_POSM_Product__c> posmPdList = [SELECT Id FROM ASI_KOR_POSM_Product__c WHERE Id = :sObj.Id LIMIT 1];
            if (posmPdList.size() > 0) {
                ASI_KOR_POSM_Product__c posmPd = posmPdList.get(0);
                ASI_KOR_POSM_Order_Detail__c posmReqDetail = new ASI_KOR_POSM_Order_Detail__c(
                    ASI_KOR_POSM_Order_Request__c = this.posmReqHeader.Id
                    , ASI_KOR_Item_Name__c = posmPd.Id
                );
                mcauC.addNewRowByInfo(ASI_KOR_MassCreateAndUpdateController.RTDEVNAME_MASTER, posmReqDetail);
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
        ASI_KOR_POSM_Order_Detail__c posmDetail = (ASI_KOR_POSM_Order_Detail__c)sObj;
        if (posmDetail != null && posmDetail.ASI_KOR_Item_Name__c != null && actionKey == ASI_KOR_MassCreateAndUpdateController.ACTION_REMOVE_NEW) {
            ASI_KOR_SFObjSelectTableController selectTableC = (ASI_KOR_SFObjSelectTableController)this.getComponentController('selectTable');
            selectTableC.setBtnStageBySObjId(posmDetail.ASI_KOR_Item_Name__c, 'add', 0);
        }
    }
    
    private String generateBaseWhereStatement() {
        String result = '';
        if (this.posmReqHeader != null) {
            /*if (this.posmReqHeader.ASI_KOR_Item_Owner__c != null) {
                result = 'ASI_KOR_Item_Owner__c = \'' + this.posmReqHeader.ASI_KOR_Item_Owner__c + '\'';
            }*/
            //delete by Elufa support 20160525
            if (this.posmReqHeader.ASI_KOR_POSM_Order_Details__r != null && this.posmReqHeader.ASI_KOR_POSM_Order_Details__r.size() > 0) {
                List<ASI_KOR_POSM_Order_Detail__c> posmReqDetailList = this.posmReqHeader.ASI_KOR_POSM_Order_Details__r;
                List<String> posmPdIdList = new List<String>();
                for (ASI_KOR_POSM_Order_Detail__c posmReqDetail : posmReqDetailList) {
                    ID posmPdId = posmReqDetail.ASI_KOR_Item_Name__c;
                    if (posmPdId != null)
                        posmPdIdList.add(posmPdId);
                }
                if (posmPdIdList.size() > 0) {
                    if (result != null && result.length() > 0) {
                        result += ' AND ';
                    }
                    result += 'Id NOT IN (' + ASI_KOR_CommonUtils.generateSeparatedStringWithQuote(posmPdIdList, ',', '\'') + ')';
                }
            }
        }
        return result;
    }
    
    /*
     * Methods and variables that extend the ASI_KOR_PageInterface
     */
    
    private static String DEF_CC_KEY = 'DEFAULT';
    private Map<String, ASI_KOR_ComponentInterface> componentControllerMap;
    public ASI_KOR_POSMOrderRequestDtEditController thisController { get {return this;} set; }
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