/*********************************************************************************
 * Name: ASI_CRM_SG_CreditDebit_ManageAll_Ctrl
 * Description: Controller class for ASI_CRM_SG_CreditDebit_ManageAll
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 15/03/2017       Vincent Lam             Created          
*/
public class ASI_CRM_SG_CreditDebit_ManageAll_Ctrl {
    
	public static final String REPORT_CONTRACTMARGIN = 'ASI_CRM_SG_Credit_Debit_Note_Breakdown';
	public static final String REPORT_BACKREBATE = 'ASI_CRM_SG_CreditDebitNote_BackRebate';
	public static final String RTAPI_CONTRACTMARGIN = 'ASI_CRM_SG_Contract_Margin';
	public static final String RTAPI_BACKREBATE = 'ASI_CRM_SG_Back_Rebate';
	
    //Inner class for storing the exception
    private class ExceptionWrapper {
		private Integer lineNumber            {get; set;}
		private String errorMessage           {get; set;}
		private List<String> fieldAPINameList {get; set;}

		private ExceptionWrapper(Integer lineNumber, String errorMessage) {
		  this.lineNumber         = lineNumber;
		  this.errorMessage       = errorMessage;
		}

		private ExceptionWrapper(Integer lineNumber, String errorMessage, List<String> fieldAPINameList) {
		  this(lineNumber, errorMessage);
		  this.fieldAPINameList = fieldAPINameList;
		}
	}
    
  //Field Map
    private final static Map<String, Schema.SObjectField> HEADER_FIELD_MAP         = Schema.SObjectType.ASI_CRM_Credit_Debit_Note__c.fields.getMap();
    private final static Map<String, Schema.SObjectField> LINE_ITEM_FIELD_MAP      = Schema.SObjectType.ASI_CRM_Credit_Debit_Note_Line_Item__c.fields.getMap();
    
    //Record Type
    private final static String CONTRACTMARGIN_CREDITNOTE_RECORD_TYPE            = 'ASI_CRM_SG_Contract_Margin_Credit_Note_Line_Item';
    private final static String CONTRACTMARGIN_DEBITNOTE_RECORD_TYPE = 'ASI_CRM_SG_Contract_Margin_Debit_Note_Line_Item';
    private final static String PROMPTPAYMENT_CREDITNOTE_RECORD_TYPE = 'ASI_CRM_SG_Prompt_Payment_Credit_Note_Line_Item';
    private final static String SG_SUB_BRAND_RECORD_TYPE                  = 'ASI_CRM_SG_Sub_brand';
	
	private final static Map<string, string> HEADER_LINE_RT_MAP = new Map<string, string>{
		'ASI_CRM_SG_Contract_Margin_Credit_Note'=>Global_RecordTypeCache.getRTId('ASI_CRM_SG_Contract_Margin_Credit_Note_Line_Item'),
		'ASI_CRM_SG_Contract_Margin_Debit_Note'=>Global_RecordTypeCache.getRTId('ASI_CRM_SG_Contract_Margin_Debit_Note_Line_Item'),
		'ASI_CRM_SG_Prompt_Payment_Credit_Note'=>Global_RecordTypeCache.getRTId('ASI_CRM_SG_Prompt_Payment_Credit_Note_Line_Item')
	};
    
    //Page Parameters Key
    private final static String CONTRACT_ID                       = 'id';
    private final static String SKU_NAME                          = 'skuName';
    private final static String FILTER_OUT_SKU_ID_LIST_JSON       = 'filterOutSKUIdListJson';
    private final static String IS_QUICK_SAVE                     = 'isQuickSave';
    private final static String CONTRACT_TARGET_LIST_JSON         = 'lineItemListJson';
    private final static String UPDATE_LINE_ITEM_LIST_JSON  = 'updatelineItemListJson';
    private final static String DELETE_LINE_ITEM_LIST_JSON  = 'deletelineItemListJson';
    
    //Data Storage
    public ASI_CRM_Credit_Debit_Note__c header {get; set;}
    private List<ASI_CRM_Credit_Debit_Note_Line_Item__c> lineItemList;
    private Map<String, ASI_MFM_Sub_Brand__c> subBrandNameMap;
    private List<ASI_MFM_Sub_Brand__c> searchSubBrandList;
	private string reportAPI;
	
	//Identify which record it is
	public string THIS_RECORDTYPE {get; set;}
    
    //Page Varaible
    public Boolean hasError                     {get; set;}
    public List<ExceptionWrapper> exceptionList {get; set;}
	public String lineItemRecordTypeId     {get {return HEADER_LINE_RT_MAP.get(header.recordtype.developername);}}
	public String headerNo {get {return header.name;}}
	public String wholesalerName {get {return header.ASI_CRM_Wholesaler__r.name;}}
	public String contractNo {get {return header.ASI_CRM_Contract__r.name;}}
	public String outletName {get {return header.ASI_CRM_Outlet__r.name;}}
    
    //JSON String for VF Page
    public String lineItemListJson          {get {return toJsonString(lineItemList);}}
    public String searchSubBrandListJson            {get {return toJsonString(searchSubBrandList);}}
    public String exceptionListJson               {get {return toJsonString(exceptionList);}}
    
    public ASI_CRM_SG_CreditDebit_ManageAll_Ctrl(ApexPages.StandardController standardController) {
        String headerId = ApexPages.currentPage().getParameters().get('id');
        init(headerId);
		reportAPI = getReportAPI(header.recordtype.developername);
    }
    
    /***************
    Data Init Function
    ***************/
    private void init(String headerId) {
        header           = retrieveHeader(headerId);
        lineItemList = retrieveLineItem(headerId);
        
        if(lineItemList.size() > 0) {
          THIS_RECORDTYPE = lineItemList.get(0).RecordType.DeveloperName;
        }
    }
	
	private string getReportAPI(String rtAPI){
		string reportAPI;
		if(rtAPI.contains(RTAPI_CONTRACTMARGIN)){
			reportAPI = REPORT_CONTRACTMARGIN;
		} else 
		if(rtAPI.contains(RTAPI_BACKREBATE)){
			reportAPI = REPORT_BACKREBATE;
		}
		return reportAPI;
	}
	
    /***************
    Page Function
    ***************/
    public void searchSubBrand() {
        Map<String, String> params      = ApexPages.currentPage().getParameters();
    }
    
    public PageReference saveRecord() {
       hasError = false;
        
        Map<String, String> params           = ApexPages.currentPage().getParameters();
        Boolean isQuickSave                  = String.isBlank(params.get('IS_QUICK_SAVE')) ? false : Boolean.valueOf(params.get('IS_QUICK_SAVE'));
      String upsertLineItemDataJson  = params.get(UPDATE_LINE_ITEM_LIST_JSON);
      String removeLineItemDataJson  = params.get(DELETE_LINE_ITEM_LIST_JSON);
        
        List<ASI_CRM_Credit_Debit_Note_Line_Item__c> upsertlineItemList;
        List<String> removeLineItemIdList;
        
      System.Savepoint databaseSavepoint = Database.setSavepoint();
        try {
        
            upsertlineItemList    = (List<ASI_CRM_Credit_Debit_Note_Line_Item__c>) fromJsonString(upsertLineItemDataJson, List<ASI_CRM_Credit_Debit_Note_Line_Item__c>.class);
            removeLineItemIdList  = (List<String>) fromJsonString(removeLineItemDataJson, List<String>.class);
            
            if(removeLineItemIdList != null && removeLineItemIdList.size() > 0) {
                List<ASI_CRM_Credit_Debit_Note_Line_Item__c> removeDataList = new List<ASI_CRM_Credit_Debit_Note_Line_Item__c>();
                for(String removeDataId : removeLineItemIdList) {
                  removeDataList.add(new ASI_CRM_Credit_Debit_Note_Line_Item__c(Id = removeDataId));
                }
                Database.delete(removeDataList);
            }
            
            if(upsertlineItemList != null && upsertlineItemList.size() > 0) {
                
                for(ASI_CRM_Credit_Debit_Note_Line_Item__c line : upsertlineItemList) {
                    line.ASI_CRM_Sub_brand__r = null;
                }
                
                   
                Database.upsert(upsertlineItemList);
                    
            }
        } catch(Exception e) {
            exceptionList = new List<ExceptionWrapper>();
          if(e.getTypeName() == 'System.DmlException') {
            DmlException dmlException = (DmlException) e;
            for(Integer i = 0 ; i < dmlException.getNumDml() ; i++) {
              ExceptionWrapper exceptionWrapper = new ExceptionWrapper(dmlException.getDmlIndex(i), dmlException.getDmlMessage(i), dmlException.getDmlFieldNames(i));
              exceptionList.add(exceptionWrapper);
            }
          } else {
            ExceptionWrapper exceptionWrapper = new ExceptionWrapper(e.getLineNumber(), e.getMessage());
            exceptionList.add(exceptionWrapper);
          }
          hasError = true;
            
          Database.rollback(databaseSavepoint);
            System.debug('Page (ASI_CRM_SG_CreditDebit_ManageAll_Ctrl) Error ' + e.getMessage());
            return null;
        }
        
        if(isQuickSave) {
            //Init the page if is quick save
            init(header.Id);
          return null;
        }
        
        PageReference pageRef = new PageReference('/' + header.Id);
      pageRef.setRedirect(true);
      return pageRef;
    }
    
    public PageReference cancel() {
      PageReference pageRef = new PageReference('/' + header.Id);
      pageRef.setRedirect(true);
      return pageRef;
    }
    
    /***************
    Business Logic Function
    ***************/
    /***************
    Data Retrievement Function
    ***************/
    private ASI_CRM_Credit_Debit_Note__c retrieveHeader(Id headerId) {
        String query = 'SELECT ' + genQueryField(HEADER_FIELD_MAP) + 
                       ', RecordType.DeveloperName, ASI_CRM_Wholesaler__r.name ' + 
					   ', ASI_CRM_Contract__r.name, ASI_CRM_Outlet__r.name ' +
                       'FROM ASI_CRM_Credit_Debit_Note__c ' +
                       'WHERE Id = :headerId ';
        List<ASI_CRM_Credit_Debit_Note__c> headerList = (List<ASI_CRM_Credit_Debit_Note__c>) Database.query(query);
        return headerList.size() > 0 ? headerList.get(0) : null;
    }
    
    private List<ASI_CRM_Credit_Debit_Note_Line_Item__c> retrieveLineItem(Id headerId) {
      String query = 'SELECT ' + genQueryField(LINE_ITEM_FIELD_MAP) + 
                       ', RecordType.DeveloperName, ASI_CRM_Sub_brand__r.Name ' + 
                       ', ASI_CRM_SKU__r.Name, ASI_CRM_Customer__r.Name ' + 
                       'FROM ASI_CRM_Credit_Debit_Note_Line_Item__c ' +
                       'WHERE ASI_CRM_Credit_Debit_Note__c = :headerId ';
        return (List<ASI_CRM_Credit_Debit_Note_Line_Item__c>) Database.query(query);
    }
    
    /*
    private List<ASI_MFM_Sub_Brand__c> retrieveSubBrand(String sbName) {
    	String query = 'SELECT Id, Name ' + 
                       'FROM ASI_MFM_Sub_Brand__c ' + 
                       'WHERE RecordType.DeveloperName = :SG_SUB_BRAND_RECORD_TYPE ';
					   
    	if(String.isNotBlank(sbName)) {
            query += 'AND Name like \'%' + sbName.trim() + '%\' ';
        }
        Map<String, ASI_MFM_Sub_Brand__c> subBrandNameMap = new Map<String, ASI_MFM_Sub_Brand__c>();    
        return (List<ASI_MFM_Sub_Brand__c>) Database.query(query);
    }
    */
    
    /***************
  Tools Function
  ***************/
    private String genQueryField(Map<String, Schema.SObjectField> fieldMap) {
        String queryField = '';
        for(String fields : fieldMap.keySet()) {
          queryField += fields + ',';
        }
        return queryField.subString(0, queryField.length() - 1);
    }

    private String toJsonString(Object obj) {
        return System.JSON.serialize(obj);
    }

    private Object fromJsonString(String jsonString, System.Type apexType) {
        if(String.isBlank(jsonString)) {
            return null;
        }
        return System.JSON.deserialize(jsonString, apexType);
    }
	
	public string getReportLink(){
		report report = [Select ID from Report where DeveloperName = :reportAPI limit 1];
		return report.id;
	}
}