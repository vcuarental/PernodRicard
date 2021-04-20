public with sharing class ASI_FOC_HK_FreeGoodRequestCloneChildCON {
    
    private static final Set<String> IGNORE_REQ_ITEM_FIELDS = new Set<String>{
        'ASI_FOC_Sys_Unique_Key__c'
    };
    private static final Map<String, Object> FIELD_TO_SPECIAL_VALUE_REQ_ITEM = new Map<String, Object> {
        'ASI_FOC_Sys_Clone_Flag__c' => true
        , 'ASI_FOC_Brand_Director_Approval_Status__c' => null
        , 'ASI_FOC_Actual_Quantity_Bottle__c' => null
        , 'ASI_FOC_SO_Actual_Extended_Cost__c' => null
    };
    
    public String newReqId { get; set; }
    public String oldReqId { get; set; }
    public Boolean hasError { get; set; }
    public Boolean isSuccessCreateReq { get; set; }
    
    private static List<String> cloneReqFields;
    @TestVisible private static String URL_PARAM_NEW_ID = 'newid';
    @TestVisible private static String URL_PARAM_FROM_ID = 'fromid';
    
    public ASI_FOC_HK_FreeGoodRequestCloneChildCON () {
        this.newReqId = ApexPages.currentPage().getParameters().get(URL_PARAM_NEW_ID);
        this.oldReqId = ApexPages.currentPage().getParameters().get(URL_PARAM_FROM_ID);
        this.hasError = false;
        this.isSuccessCreateReq = false;
        if (this.newReqId == null || !isValidId(this.newReqId)) {
            this.newReqId = null;
            showPageError('Invalid URL parameter');
        } else {
            this.isSuccessCreateReq = true;
            if (this.oldReqId == null || !isValidId(this.oldReqId)) {
                this.oldReqId = null;
                showPageError('Invalid URL parameter');
            }
        }
    }
    
    public PageReference initPage() {
        PageReference redirectPage = null;
        if (!this.hasError) {
            try {
                cloneRequestItems(this.oldReqId, this.newReqId);
                redirectPage = massEditPage(this.newReqId);
            } catch (DmlException dmle) {
                Set<String> errMsgs = new Set<String>();
                Integer dmlCount = dmle.getNumDml();
                for (Integer i = 0; i < dmlCount; i++) {
                    String err = dmle.getDmlMessage(i);
                    if (!errMsgs.contains(err))
                        showPageWarning(err);
                    errMsgs.add(err);
                }
            } catch (Exception e) {
                showPageWarning(e.getMessage());
            }
        }
        return redirectPage;
    }
    
    public PageReference redirectToAnotherPage() {
        if (this.newReqId != null) {
            return massEditPage(this.newReqId);
        } else if (this.newReqId != null) {
            return new PageReference('/' + this.oldReqId);
        }
        return new PageReference('/home/home.jsp');
    }
    @TestVisible private static final String FAIL_LINK_LABEL_Continue = 'Continue to the new request';
    @TestVisible private static final String FAIL_LINK_LABEL_Return = 'Return';
    @TestVisible private static final String FAIL_LINK_LABEL_Other = 'Home Page';
    public String anotherPageLabel {
        get {
            if (this.newReqId != null) {
                return FAIL_LINK_LABEL_Continue;
            } else if (this.newReqId != null) {
                return FAIL_LINK_LABEL_Return;
            }
            return FAIL_LINK_LABEL_Other;
        }
        private set;
    }
    
    private PageReference massEditPage(String reqId) {
        PageReference redirectPage = Page.ASI_FOC_HK_RequestDetailEditPage;
        Map<String, String> pageParams = redirectPage.getParameters();
        pageParams.put('id', reqId);
        pageParams.put('clone', '1');
        pageParams.put('scontrolCaching', '1');
        return redirectPage;
    }
    
    private void cloneRequestItems(ID fromReqId, ID toReqId) {
        if (fromReqId != null && toReqId != null) {
            if (cloneReqFields == null) {
                Set<String> reqItemFieldSet = allFieldsOfObject('ASI_FOC_Request_Item__c', true, true, IGNORE_REQ_ITEM_FIELDS);
                reqItemFieldSet.add('id');
                cloneReqFields = new List<String>(reqItemFieldSet);
            }
            String queryStr = String.format(
                'SELECT {0} FROM ASI_FOC_Request_Item__c WHERE ASI_FOC_Request_Order__c = :fromReqId ORDER BY Name'
                , new String[] {String.join(cloneReqFields, ',')}
            );
            List<ASI_FOC_Request_Item__c> fromReqItems = (List<ASI_FOC_Request_Item__c>)database.query(queryStr);
            
            List<ASI_FOC_Request_Item__c> insertFGReqItemList = new List<ASI_FOC_Request_Item__c>();
            Set<String> specialValFields = FIELD_TO_SPECIAL_VALUE_REQ_ITEM == null ? null : FIELD_TO_SPECIAL_VALUE_REQ_ITEM.keySet();
            
            String fromReqType = [select ASI_FOC_Request_Type__c from ASI_FOC_Free_Goods_Request__c where id = :fromReqId limit 1].ASI_FOC_Request_Type__c;
            String toReqType = [select ASI_FOC_Request_Type__c from ASI_FOC_Free_Goods_Request__c where id = :toReqId limit 1].ASI_FOC_Request_Type__c;

//Added by Wilken on 20131030, if clone request changed type to or from POS, do not clone request item          
            if (fromReqType != toReqType && (fromReqType == 'POS' || toReqType == 'POS')){
                //Do not clone request item for this case
            }
            else {
                for (ASI_FOC_Request_Item__c fromReqItem : fromReqItems) {
                    ASI_FOC_Request_Item__c newReqItem = fromReqItem.clone(false, false, false, false);
                    newReqItem.ASI_FOC_Request_Order__c = toReqId;
                    //Added by Wilken on 20141031, To set all to zero after cloning to prevent exceed cloning amount  
                    newReqItem.ASI_FOC_Request_Quantity_Bottle__c = 0;
                    if (specialValFields != null) {
                        for (String f : specialValFields) {
                            Object val = FIELD_TO_SPECIAL_VALUE_REQ_ITEM.get(f);
                            newReqItem.put(f, val);
                        }
                    }
                    insertFGReqItemList.add(newReqItem);
                }
                insert insertFGReqItemList;
            }
        }
    }
    
    private Set<String> allFieldsOfObject(String objTypeStr, Boolean checkAccessible, Boolean checkCreateable, Set<String> ignoreFields) {
        Set<String> result = new Set<String>();
        if (objTypeStr != null && objTypeStr.trim() != '') {
            Schema.SObjectType objType = Schema.getGlobalDescribe().get(objTypeStr);
            if (objType != null) {
                Map<String, Schema.SObjectField> fieldMap = objType.getDescribe().fields.getMap();
                if (fieldMap != null) {
                    Set<String> allFields = fieldMap.keySet();
                    Set<String> ignoreFieldsLowerCase = new Set<String>();
                    if (ignoreFields != null)
                        for (String ignoreField : ignoreFields)
                            ignoreFieldsLowerCase.add(ignoreField.toLowerCase());
                    for (String f : allFields) {
                        if (!ignoreFieldsLowerCase.contains(f)) {
                            Schema.DescribeFieldResult fieldDescribe = fieldMap.get(f).getDescribe();
                            if ((!checkAccessible || fieldDescribe.isAccessible())
                                && (!checkCreateable || fieldDescribe.isCreateable())) {
                                result.add(f);
                            }
                        }
                    }
                }
            }
        }
        return result;
    }
    
    private void showPageMessage(ApexPages.Severity severity, String msg) {
        ApexPages.addMessage(new ApexPages.Message(severity, msg));
    }
    private void showPageError(String msg) {
        this.hasError = true;
        showPageMessage(ApexPages.Severity.ERROR, msg);
    }
    private void showPageWarning(String msg) {
        this.hasError = true;
        showPageMessage(ApexPages.Severity.WARNING, msg);
    }
    
    private Boolean isValidId(String theStr) {
        try {
            ID testId = theStr;
        } catch (Exception e) {
            return false;
        }
        return true;
    }
}