/*********************************************************************************
 * Name: ASI_CRM_SG_PaymentSplitOutlet_Ctrl
 * Description: 
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-03-22       Vincent Lam             Created          
*/
public with sharing class ASI_CRM_SG_PaymentSplitOutlet_Ctrl {

    //Inner class for storing contract comparison result
    private class outletWrapper {
        private Boolean isSelected {get; set;}
        
        //Header
        private String outletId             {get; set;}
        private String outletName         {get; set;}
    
        private outletWrapper(AggregateResult ar) {
            this.isSelected = false;
            this.outletId = String.valueOf(ar.get('outletId'));
            this.outletName = String.valueOf(ar.get('outletName'));
        }
        
    }

    private final static Map<String, Schema.SObjectField> PAYMENT_FIELD_MAP = Schema.SObjectType.ASI_TH_CRM_PaymentRequest__c.fields.getMap();
    private final static Map<String, Schema.SObjectField> PAYMENTLINE_FIELD_MAP = Schema.SObjectType.ASI_TH_CRM_PaymentRequestLineItem__c.fields.getMap();
    private final static Map<String, Schema.SObjectField> CREDIT_FIELD_MAP = Schema.SObjectType.ASI_CRM_Credit_Debit_Note__c.fields.getMap();
    private final static Map<String, Schema.SObjectField> CREDITLINE_FIELD_MAP = Schema.SObjectType.ASI_CRM_Credit_Debit_Note_Line_Item__c.fields.getMap();

	private final String TYPE_PAYMENT = 'Payment';
	private final String TYPE_CREDITDEBIT = 'Credit';
    
    //JSON String for VF Page
    public String outletListJson {get {return toJsonString(outletList);}}
	public String newPaymentId {get {return newPaymentIdForRedirect;}}

    //All contract records
	public string recordId { get; set; }
	public string typeOfRecord { get; set; }
    public List<outletWrapper> outletList { get; set; }
	public string newPaymentIdForRedirect { get; set; }
  
    public PageReference pageRef = ApexPages.currentPage();
    
    //Init
    public ASI_CRM_SG_PaymentSplitOutlet_Ctrl() {
        recordId = ApexPages.currentPage().getParameters().get('id');
        typeOfRecord = ApexPages.currentPage().getParameters().get('type');
		outletList = retrieveOutletList(recordId);
        
    }
	
	// split the payment
	public void splitPaymentFromVFPage(){
		Map<String, String> params = ApexPages.currentPage().getParameters();
        String outletIdListJson  = params.get('OUTLET_ID_LIST_JSON');
        
		List<string> list_outletId = (List<String>) fromJsonString(outletIdListJson, List<String>.class);
        
		if(typeOfRecord == TYPE_PAYMENT){
			ASI_TH_CRM_PaymentRequest__c newHeader = retrievePayment(recordId);
			insert newHeader;
			List<ASI_TH_CRM_PaymentRequestLineItem__c> list_existingItems = retrieveExistingPaymentLine(recordId, list_outletId);
			delete list_existingItems;
			List<ASI_TH_CRM_PaymentRequestLineItem__c> list_newItems = createNewPaymentLine(list_existingItems, newHeader.Id);
			insert list_newItems;
			newPaymentIdForRedirect = newHeader.Id;
		} else 
		if(typeOfRecord == TYPE_CREDITDEBIT){
			ASI_CRM_Credit_Debit_Note__c newHeader = retrieveCredit(recordId);
			insert newHeader;
			List<ASI_CRM_Credit_Debit_Note_Line_Item__c> list_existingItems = retrieveExistingCreditLine(recordId, list_outletId);
			delete list_existingItems;
			List<ASI_CRM_Credit_Debit_Note_Line_Item__c> list_newItems = createNewCreditLine(list_existingItems, newHeader.Id);
			insert list_newItems;
			newPaymentIdForRedirect = newHeader.Id;
		}
		
	}

    /***************
    Data Retrievement Function
    ***************/
    private List<outletWrapper> retrieveOutletList(string headerId) {
        List<outletWrapper> list_w = new List<outletWrapper>();
		String query = '';
		if(typeOfRecord == TYPE_PAYMENT){
			query = 'SELECT ASI_CRM_Customer__c outletId, ' +
					'ASI_CRM_Customer__r.Name outletName ' +
				   'FROM ASI_TH_CRM_PaymentRequestLineItem__c ' +
				   'WHERE ASI_TH_CRM_Payment_Request__c = :headerId ' +
				   'AND ASI_CRM_Customer__c <> null ' + 
				   'Group by ASI_CRM_Customer__c, ASI_CRM_Customer__r.Name';
		} else 
		if(typeOfRecord == TYPE_CREDITDEBIT){
			query = 'SELECT ASI_CRM_Customer__c outletId, ' +
					'ASI_CRM_Customer__r.Name outletName ' +
				   'FROM ASI_CRM_Credit_Debit_Note_Line_Item__c ' +
				   'WHERE ASI_CRM_Credit_Debit_Note__c = :headerId ' +
				   'AND ASI_CRM_Customer__c <> null ' + 
				   'Group by ASI_CRM_Customer__c, ASI_CRM_Customer__r.Name';
		}
		

        for(AggregateResult ar : (List<AggregateResult>) Database.query(query)){
			list_w.add(new outletWrapper(ar));
		} 
        return list_w;
    }
	
    private ASI_TH_CRM_PaymentRequest__c retrievePayment(String headerId) {
        String query = 'SELECT ' + genQueryField(PAYMENT_FIELD_MAP) + ' ' +
                       'FROM ASI_TH_CRM_PaymentRequest__c ' +
                       'WHERE id = : headerId limit 1';
					   
		ASI_TH_CRM_PaymentRequest__c existingHeader = (ASI_TH_CRM_PaymentRequest__c) Database.query(query);
		ASI_TH_CRM_PaymentRequest__c newHeader = existingHeader.clone(false, true, false, false);
        return newHeader;
    }
  
    private List<ASI_TH_CRM_PaymentRequestLineItem__c> retrieveExistingPaymentLine(String existingHeaderId, List<String> list_outletId) {
        String query = 'SELECT ' + genQueryField(PAYMENTLINE_FIELD_MAP) + ' ' +
                       'FROM ASI_TH_CRM_PaymentRequestLineItem__c ' +
                       'WHERE ASI_TH_CRM_Payment_Request__c = :existingHeaderId ' +
					   'AND ASI_CRM_Customer__c in :list_outletId';
		
        return (List<ASI_TH_CRM_PaymentRequestLineItem__c>) Database.query(query);
    }
  
    private List<ASI_TH_CRM_PaymentRequestLineItem__c> createNewPaymentLine(List<ASI_TH_CRM_PaymentRequestLineItem__c> list_existingItems, String newHeaderId) {
		List<ASI_TH_CRM_PaymentRequestLineItem__c> list_newLines = new List<ASI_TH_CRM_PaymentRequestLineItem__c>();
		for(ASI_TH_CRM_PaymentRequestLineItem__c l : list_existingItems){
			ASI_TH_CRM_PaymentRequestLineItem__c newLine = l.clone(false, true, false, false);
			newLine.ASI_TH_CRM_Payment_Request__c = newHeaderId;
			list_newLines.add(newLine);
		}
        return list_newLines;
    }
  
    private ASI_CRM_Credit_Debit_Note__c retrieveCredit(String headerId) {
        String query = 'SELECT ' + genQueryField(CREDIT_FIELD_MAP) + ' ' +
                       'FROM ASI_CRM_Credit_Debit_Note__c ' +
                       'WHERE id = : headerId limit 1';
					   
		ASI_CRM_Credit_Debit_Note__c existingHeader = (ASI_CRM_Credit_Debit_Note__c) Database.query(query);
		ASI_CRM_Credit_Debit_Note__c newHeader = existingHeader.clone(false, true, false, false);
        return newHeader;
    }
  
    private List<ASI_CRM_Credit_Debit_Note_Line_Item__c> retrieveExistingCreditLine(String existingHeaderId, List<String> list_outletId) {
        String query = 'SELECT ' + genQueryField(CREDITLINE_FIELD_MAP) + ' ' +
                       'FROM ASI_CRM_Credit_Debit_Note_Line_Item__c ' +
                       'WHERE ASI_CRM_Credit_Debit_Note__c = :existingHeaderId ' +
					   'AND ASI_CRM_Customer__c in :list_outletId';
		
        return (List<ASI_CRM_Credit_Debit_Note_Line_Item__c>) Database.query(query);
    }
  
    private List<ASI_CRM_Credit_Debit_Note_Line_Item__c> createNewCreditLine(List<ASI_CRM_Credit_Debit_Note_Line_Item__c> list_existingItems, String newHeaderId) {
		List<ASI_CRM_Credit_Debit_Note_Line_Item__c> list_newLines = new List<ASI_CRM_Credit_Debit_Note_Line_Item__c>();
		for(ASI_CRM_Credit_Debit_Note_Line_Item__c l : list_existingItems){
			ASI_CRM_Credit_Debit_Note_Line_Item__c newLine = l.clone(false, true, false, false);
			newLine.ASI_CRM_Credit_Debit_Note__c = newHeaderId;
			list_newLines.add(newLine);
		}
        return list_newLines;
    }
  
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

    private String genQueryFieldFromList(list<string> fieldList) {
        return String.join(fieldList, ',');
    }

    private String toJsonString(Object obj) {
        return System.JSON.serialize(obj);
    }

    private List<Object> fromJsonString(String jsonString, System.Type apexType) {
        if(String.isBlank(jsonString)) {
            return null;
        }
        return (List<Object>) System.JSON.deserialize(jsonString, apexType);
    }

}