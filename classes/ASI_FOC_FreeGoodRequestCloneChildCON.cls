public with sharing class ASI_FOC_FreeGoodRequestCloneChildCON {
    
    private static final Set<String> IGNORE_REQ_ITEM_FIELDS = new Set<String>{
        'ASI_FOC_Sys_Unique_Key__c'
    };
    private static final Map<String, Object> FIELD_TO_SPECIAL_VALUE_REQ_ITEM = new Map<String, Object> {
        'ASI_FOC_Sys_Clone_Flag__c' => true
        , 'ASI_FOC_Brand_Director_Approval_Status__c' => null
        , 'ASI_FOC_Actual_Quantity_Bottle__c' => null
        , 'ASI_FOC_SO_Actual_Extended_Cost__c' => null
        , 'ASI_FOC_ETL_Complete__c' => false
        , 'ASI_FOC_Cancel_Quantity_PC_BT__c' => null
        , 'ASI_FOC_Request_Quantity_Bottle__c' => null
        , 'ASI_FOC_Request_Quantity_PC__c' => null
    };
    
    public String newReqId { get; set; }
    public String oldReqId { get; set; }
    public Boolean hasError { get; set; }
    public Boolean isSuccessCreateReq { get; set; }
    public String requestNumber {get;set;}
    
    private static List<String> cloneReqFields;
    @TestVisible private static String URL_PARAM_NEW_ID = 'newid';
    @TestVisible private static String URL_PARAM_FROM_ID = 'fromid';
    
    public ASI_FOC_FreeGoodRequestCloneChildCON() {
        this.newReqId = ApexPages.currentPage().getParameters().get(URL_PARAM_NEW_ID);
        this.oldReqId = ApexPages.currentPage().getParameters().get(URL_PARAM_FROM_ID);
        requestNumber= '';
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
                if(!this.hasError)
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
        PageReference redirectPage = null;
        Map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_FOC_Free_Goods_Request__c');
        ASI_FOC_Free_Goods_Request__c FOC = [SELECT RecordTypeId FROM ASI_FOC_Free_Goods_Request__c WHERE id= :reqId];
        if (FOC.recordTypeId == rt_map.get('ASI_FOC_CN_Free_Goods_Request') || 
            FOC.recordTypeId == rt_map.get('ASI_FOC_CN_Free_Goods_Request_Read_Only') || 
            FOC.recordTypeId == rt_map.get('ASI_FOC_CN_Request_and_Items_Read_Only')){
               redirectPage = Page.ASI_FOC_FreeGoodRequestDetailEditPage;   
           }
        else if (FOC.recordTypeId == rt_map.get('ASI_FOC_CN_POSM') ||
                 FOC.recordTypeId == rt_map.get('ASI_FOC_CN_POSM_Read_Only')){               
                     redirectPage = Page.ASI_FOC_CN_POSMRequestDetailEditPage;
                 } 
        Map<String, String> pageParams = redirectPage.getParameters();
        pageParams.put('id', reqId);
        pageParams.put('clone', '1');
        pageParams.put('scontrolCaching', '1');
        /*if(requestNumber !='')
        pageParams.put('requestNumber', requestNumber);*/
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
            for (ASI_FOC_Request_Item__c fromReqItem : fromReqItems) {
                ASI_FOC_Request_Item__c newReqItem = fromReqItem.clone(false, false, false, false);
                newReqItem.ASI_FOC_Request_Order__c = toReqId;
                newReqItem.ASI_MFM_AutoComplete__c = false;
                if (specialValFields != null) {
                    for (String f : specialValFields) {
                        Object val = FIELD_TO_SPECIAL_VALUE_REQ_ITEM.get(f);
                        newReqItem.put(f, val);
                    }
                }
                insertFGReqItemList.add(newReqItem);
            }
            System.debug(LoggingLevel.INFO, '*** insertFGReqItemList: ' + insertFGReqItemList);
            insert insertFGReqItemList;

			//-- Commented by Alan Wong (Elufa) 20150902 Too many SOSQL error --//
            //this is to handle the custom request to handle inserting even there are exections, might cause dml limit error
            /*for(ASI_FOC_Request_Item__c foc : insertFGReqItemList){
                try{
                    requestNumber = requestNumber+foc.ASI_FOC_Request_Quantity_Bottle__c+'_';
                    //foc.ASI_FOC_Request_Quantity_Bottle__c=0;
                    insert foc;
                    
                }catch(Exception e){
                    hasError = true;
                }
            }*/
            
            //if(requestNumber!='') requestNumber=requestNumber.subString(0,requestNumber.length()-1); 
            //-- End --//
        }
    }
    public class customException extends Exception{
       
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
    public void showPageWarning(String msg) {
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