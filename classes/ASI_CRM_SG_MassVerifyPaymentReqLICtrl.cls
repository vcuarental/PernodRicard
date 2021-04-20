/**********************************************************************************
 * Name : ASI_CRM_SG_MassVerifyPaymentReqLICtrl
 * Created : DC @1/1/2016 10:57 AM
 * Revision History:
 * 1. 01/01/2016 - [DC 1.0] Created
 * 2. 01/04/2016 - [DC 2.0] Updated to include only records of “ASI CRM SG Payment Request” or “ASI CRM SG Payment Request Read-Only” recordtype.
 * 2. 01/04/2016 - [DC 2.1] Updated to set "Amount", "Type", "Outlet" be mandatory fields.
 * 2. 01/04/2016 - [DC 2.2] Updated to fetch ASI_CRM_SG_Sub_brand__c instead of ASI_TH_CRM_Subbrand__c.
 * 2. 01/25/2016 - [DC 2.3] Updated fields for Outlet and Vendor.
 * 3. 02/22/2016 - [DC 3.0] Added fields to search bar.
 * 3. 02/23/2016 - [DC 3.1] Added fields and validations to Main table.
 * 4. 03/10/2016 - [DC 4.0] Changed data fetching and filtering.
 * 4. 03/10/2016 - [DC 4.1] Re-arranged class variables and methods.
 * 5. 03/21/2016 - [VL 5.0] For G/L Dates in Search, also check the G/L Date in header
 * 6. 03/22/2016 - [DC 5.0] Fetched Ids from lookup fields to form links to the detail pages of records.
 * 7. 08 Apr 2016 - [VL 6.0] On save, if any line item in a payment request is checked as "Verified", alert if any other line items are not "Verified"
 * 8. 15 Apr 2016 - [VL 7.0] After save, refresh page (it has been done in the very first version, but don't know why it disappears)
 * 9. 03/22/2016 - [DC 6.0] Updated logic to sort by Payment Request No., then Payment Request Ref. in ASC
 * 10. 2016-05-18 - [VL 8.0] Wilken informed that JDE will sync those payment request with Sync To JDE = false and status = Approved, then mark it back to Sync to JDE, 
 *                           so after verified in this page, mark Finance Verified instead of Sync to JDE,
 *                           and don't change the status of payment request header
 * 11. 2017-11-08 - [WL 9.0] P4.1A Validate Type selected for old vs RTM Contract (To be removed, alternative to change Mass Verify SelectList's SelectOption instead
 **********************************************************************************/

public with sharing class ASI_CRM_SG_MassVerifyPaymentReqLICtrl {

    private final static String START_INVOICE_NO = 'Different Invoice No. in the same Payment Request:';
    private final static String START_INVOICE_DATE = 'Different Invoice Date in the same Payment Request:';
    private final static String PAYMENT_REQUEST = 'Payment Request';
    private final static String COLON = ' : ';
    private final static String DATE_SEPARATOR = '/';
    private final static String NEXT_LINE = 'NEXT';
    private final static String CONFIRMATION = 'Do you want to proceed?';

    /* DC 4.1 Rearranged and grouped variables and properties */    
    private Set<Id> setRequestHeaderIds;
    private List<ASI_TH_CRM_PaymentRequest__c> lstRequestHeaders;
    private Map<Id, ASI_TH_CRM_PaymentRequest__c> mapID_RequestHeader;
    private List<ASI_TH_CRM_PaymentRequestLineItem__c> lstInitialLineItems;

    protected Integer totalNumOfRecord;
    
    public Integer numOfRowInTable;
    public Integer limitFrom;
    public String paymentRequestNo;
    public String paymentRequestRef;
    public String outlet;
    public String vendor;
    public String fromGLdates;
    public String toGLdates;
    /* DC 3.0 start */
    public String contractNo;
    public String jdeCoaCode;
    public String status;
    /* DC 3.0 end */
	
	/*[WL 9.0 BEGIN]*/
	//private Set<String> beforeRTMContractType = new Set<String>{'Cash - Upfront', 'Cash - Target Achieved', 'Bottle Incentive', 'Ad-hoc Promotions', 'Advertising Spot', 'Events', 'Product Branding Display', 'Sales Support', 'Signages', 'Trade Incentive Trips'};
	//private Set<String> afterRTMContractType = new Set<String>{'Cash - Upfront', 'Cash - Target Achieved', 'Back Rebates', 'Ad-hoc Promotions', 'Sales Support'};
	/*[WL 9.0 END]*/
	
    private String soql {get;set;}
    private String soqlHeader {get;set;}

    public List<ASI_TH_CRM_PaymentRequestLineItem__c> lstTotalLineItems{get;set;}
    public List<ASI_TH_CRM_PaymentRequestLineItem__c> lstLineItems{get;set;}
    public String newPageNum { get; set; }

    public String alertMessage { get; set; }
    public Boolean isError { get; set; }
    public Boolean isErrorOnSave { get; set; }

    public Integer maxPageNum {
        get {
            return maxNumOfPage();
        }
        private set;
    }

    public Integer currentPageNum { 
        get; 
        protected set {
            currentPageNum = value;
            newPageNum = String.valueOf(value);
        } 
    }

    public String sortDir = 'ASC';
    /*
    public String sortDir {
        get {
            if(sortDir == null) {
                sortDir = 'DESC';
            }
            return sortDir;
        }
        set;
    }
    */

    /*
    public String sortField {
        get {
            if(sortField == null) {
                sortField = 'Name';
            }
            return sortField;
        }
        set;
    }
    */

    /*
    public String debugSoql {
        get {
            return soql + ' order by ' + sortField + ' ' + sortDir  + ' Limit ' + this.numOfRowInTable + ' OFFSET ' + LimitFrom;
        }
        set;
    }
    */

    // Constructor
    public ASI_CRM_SG_MassVerifyPaymentReqLICtrl(ApexPages.StandardController controller) {
        
        setRequestHeaderIds = new Set<Id>();
        lstLineItems = new List<ASI_TH_CRM_PaymentRequestLineItem__c>();
        this.numOfRowInTable = 30;
        this.totalNumOfRecord = 0;
        this.currentPageNum = 1;
        this.LimitFrom = 0;
    }

    // Initializer function for fetching and filtering data on load of page.
    public void init() {

        Map<String, Schema.SObjectField> lineItemFieldMap = Schema.SObjectType.ASI_TH_CRM_PaymentRequestLineItem__c.fields.getMap();
        soql = 'Select ';
        
        for(String fields  : lineItemFieldMap.keySet()){
           soql += fields + ' ,';
        }
        
        soql = soql.subString(0,soql.length()-1);
        soql += ', recordtype.developername, ASI_TH_CRM_Payment_Request__r.Id,'
              + ' ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Contract__c,' // [DC 5.0]
              + ' ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Contract_No__c,'
              + ' ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Status__c,'
              + ' ASI_TH_CRM_Payment_Request__r.ASI_CRM_SG_Invoice_No__c,'
              + ' ASI_TH_CRM_Payment_Request__r.ASI_CRM_SG_Invoice_Date__c,'
              + ' ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_GL_Date__c,'
              + ' ASI_TH_CRM_Payment_Request__r.Name,'
              + ' ASI_TH_CRM_Payment_Request__r.ASI_CRM_Outlet_Fx__c,'
              + ' ASI_TH_CRM_Payment_Request__r.ASI_CRM_CN_OutletWS__c,' // [DC 5.0]
              + ' ASI_TH_CRM_Payment_Request__r.ASI_CRM_Vendor__c'
              + ' FROM ASI_TH_CRM_PaymentRequestLineItem__c'
              //+ ' WHERE ASI_CRM_Verified__c = FALSE'
              + ' WHERE ASI_TH_CRM_Payment_Request__r.ASI_CRM_SG_Finance_Verified__c = FALSE'
              + ' AND ASI_TH_CRM_Payment_Request__r.ASI_CRM_Sync_to_JDE__c = FALSE'
              + ' AND ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Status__c = \'Approved\''
              + ' AND (ASI_TH_CRM_Payment_Request__r.RecordType.DeveloperName = \'ASI_CRM_SG_Payment_Request\''
              + ' OR ASI_TH_CRM_Payment_Request__r.RecordType.DeveloperName = \'ASI_CRM_SG_Payment_Request_Read_Only\')'
              // + ' Order by ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Contract_No__c, ASI_TH_CRM_Payment_Request__r.Name, Name';
              + ' Order by ASI_TH_CRM_Payment_Request__r.Name ASC, Name ASC';

        lstTotalLineItems = (List<ASI_TH_CRM_PaymentRequestLineItem__c>) Database.query(soql);
        this.totalNumOfRecord = lstTotalLineItems.size();

        for(ASI_TH_CRM_PaymentRequestLineItem__c lineItemIterator : lstTotalLineItems) {
            setRequestHeaderIds.add(lineItemIterator.ASI_TH_CRM_Payment_Request__r.Id);
        }

        if(!setRequestHeaderIds.isEmpty()) {
            Map<String, Schema.SObjectField> headerFieldMap = Schema.SObjectType.ASI_TH_CRM_PaymentRequest__c.fields.getMap();
            soqlHeader = 'Select ';
            
            for(String fields  : headerFieldMap.keySet()){
               soqlHeader += fields + ' ,';
            }
            
            soqlHeader = soqlHeader.subString(0,soqlHeader.length()-1);
            soqlHeader += ', recordtype.developername'
                        + ' FROM ASI_TH_CRM_PaymentRequest__c'
                        + ' WHERE Id IN :setRequestHeaderIds';
            
            lstRequestHeaders = (List<ASI_TH_CRM_PaymentRequest__c>) Database.query(soqlHeader);
            mapID_RequestHeader = new Map<Id, ASI_TH_CRM_PaymentRequest__c>(lstRequestHeaders);

            /* This part seems no need
            soql = 'Select ';
            
            for(String fields  : lineItemFieldMap.keySet()){
               soql += fields + ' ,';
            }
            
            soql = soql.subString(0,soql.length()-1);
            soql += ', recordtype.developername, ASI_TH_CRM_Payment_Request__r.Id,'
                  + ' ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Contract__c,' // [DC 5.0]
                  + ' ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Contract_No__c,'
                  + ' ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Status__c,'
                  + ' ASI_TH_CRM_Payment_Request__r.ASI_CRM_SG_Invoice_No__c,'
                  + ' ASI_TH_CRM_Payment_Request__r.ASI_CRM_SG_Invoice_Date__c,'
                  + ' ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_GL_Date__c,'
                  + ' ASI_TH_CRM_Payment_Request__r.Name,'
                  + ' ASI_TH_CRM_Payment_Request__r.ASI_CRM_Outlet_Fx__c,'
                  + ' ASI_TH_CRM_Payment_Request__r.ASI_CRM_CN_OutletWS__c,' // [DC 5.0]
                  + ' ASI_TH_CRM_Payment_Request__r.ASI_CRM_Vendor__c'
                  + ' FROM ASI_TH_CRM_PaymentRequestLineItem__c'
                  + ' WHERE (ASI_TH_CRM_Payment_Request__r.RecordType.DeveloperName = \'ASI_CRM_SG_Payment_Request\''
                  + ' OR ASI_TH_CRM_Payment_Request__r.RecordType.DeveloperName = \'ASI_CRM_SG_Payment_Request_Read_Only\')'
                  + ' AND ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Status__c = \'Approved\''
                  + ' Order by ASI_TH_CRM_Payment_Request__r.Name ASC, Name ASC';

            lstTotalLineItems = (List<ASI_TH_CRM_PaymentRequestLineItem__c>) Database.query(soql);
            this.totalNumOfRecord = lstTotalLineItems.size();
            */

            for(ASI_TH_CRM_PaymentRequestLineItem__c lineItemIterator : lstTotalLineItems) {
                
                if(lineItemIterator.ASI_CRM_SG_Invoice_Date__c == NULL) {
                    lineItemIterator.ASI_CRM_SG_Invoice_Date__c 
                        = mapID_RequestHeader.get(lineItemIterator.ASI_TH_CRM_Payment_Request__r.Id).ASI_CRM_SG_Invoice_Date__c;
                }
                if(lineItemIterator.ASI_TH_CRM_Invoice_No__c == NULL) {
                    lineItemIterator.ASI_TH_CRM_Invoice_No__c 
                        = mapID_RequestHeader.get(lineItemIterator.ASI_TH_CRM_Payment_Request__r.Id).ASI_CRM_SG_Invoice_No__c;
                }
                if(lineItemIterator.ASI_CRM_GL_Date__c == NULL) {
                    lineItemIterator.ASI_CRM_GL_Date__c 
                        = mapID_RequestHeader.get(lineItemIterator.ASI_TH_CRM_Payment_Request__r.Id).ASI_TH_CRM_GL_Date__c;
                }
                if(lineItemIterator.ASI_CRM_Verified__c == false) {
                    lstLineItems.add(lineItemIterator);
                }
            }
        }

    }
    
    /*
    //sort
    public void toggleSort() {
        sortDir = sortDir.equals('asc') ? 'desc' : 'asc';
        runQuery();
    }
    */
    
    public void runQuery() {
        System.debug('------ soql ------ : ' + soql);
        try {
            // lstTotalLineItems = Database.query(soql + ' order by ' + sortField + ' ' + sortDir);
            lstTotalLineItems = Database.query(soql + ' Order by ASI_TH_CRM_Payment_Request__r.Name ASC, Name ASC');
            this.totalNumOfRecord = lstTotalLineItems.size();
            lstLineItems = Database.query(soql + ' Order by ASI_TH_CRM_Payment_Request__r.Name ASC, Name ASC Limit ' + this.numOfRowInTable + ' OFFSET ' + LimitFrom);
            List<ASI_TH_CRM_PaymentRequestLineItem__c> temp_lstLineItems =
                new List<ASI_TH_CRM_PaymentRequestLineItem__c>();
            System.debug('Testing ' + lstLineItems);
            for(ASI_TH_CRM_PaymentRequestLineItem__c lineItemIterator : lstLineItems) {
                
                if(lineItemIterator.ASI_CRM_SG_Invoice_Date__c == NULL) {
                    lineItemIterator.ASI_CRM_SG_Invoice_Date__c 
                        = mapID_RequestHeader.get(lineItemIterator.ASI_TH_CRM_Payment_Request__r.Id).ASI_CRM_SG_Invoice_Date__c;
                }
                if(lineItemIterator.ASI_TH_CRM_Invoice_No__c == NULL) {
                    lineItemIterator.ASI_TH_CRM_Invoice_No__c 
                        = mapID_RequestHeader.get(lineItemIterator.ASI_TH_CRM_Payment_Request__r.Id).ASI_CRM_SG_Invoice_No__c;
                }
                if(lineItemIterator.ASI_CRM_GL_Date__c == NULL) {
                    lineItemIterator.ASI_CRM_GL_Date__c 
                        = mapID_RequestHeader.get(lineItemIterator.ASI_TH_CRM_Payment_Request__r.Id).ASI_TH_CRM_GL_Date__c;
                }
                if(lineItemIterator.ASI_CRM_Verified__c == false) {
                    temp_lstLineItems.add(lineItemIterator);
                }
            }

            lstLineItems = temp_lstLineItems;
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No Records Found, Please Check your search input ' + soql));
            //System.debug('Fail123');
        }
    }
    
    //search function
    public PageReference runSearch() {
        PaymentRequestNo = Apexpages.currentPage().getParameters().get('PaymentRequestNo');
        PaymentRequestRef = Apexpages.currentPage().getParameters().get('PaymentRequestRef');
        Outlet = Apexpages.currentPage().getParameters().get('Outlet');
        Vendor = Apexpages.currentPage().getParameters().get('Vendor');
        fromGLdates = Apexpages.currentPage().getParameters().get('fromGLdates');
        toGLdates = Apexpages.currentPage().getParameters().get('toGLdates');
        /* DC 3.0 start */
        contractNo = Apexpages.currentPage().getParameters().get('ContractNo');
        jdeCoaCode = Apexpages.currentPage().getParameters().get('JdeCoaCode');
        status = Apexpages.currentPage().getParameters().get('Status');
        /* DC 3.0 end */
        String[] str;
        Datetime searchDate;
        
        Map<String, Schema.SObjectField> lineItemFieldMap = Schema.SObjectType.ASI_TH_CRM_PaymentRequestLineItem__c.fields.getMap();
        soql = 'Select ';
        
        for(String fields  : lineItemFieldMap.keySet()){
           soql += fields + ' ,';
        }
        
        soql = soql.subString(0,soql.length()-1);
        soql += ', recordtype.developername, ASI_TH_CRM_Payment_Request__r.Id,'
              + ' ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Contract__c,' // [DC 5.0]
              + ' ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Contract_No__c,'
              + ' ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Status__c,'
              + ' ASI_TH_CRM_Payment_Request__r.ASI_CRM_SG_Invoice_No__c,'
              + ' ASI_TH_CRM_Payment_Request__r.ASI_CRM_SG_Invoice_Date__c,'
              + ' ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_GL_Date__c,'
              + ' ASI_TH_CRM_Payment_Request__r.Name,'
              + ' ASI_TH_CRM_Payment_Request__r.ASI_CRM_Outlet_Fx__c,'
              + ' ASI_TH_CRM_Payment_Request__r.ASI_CRM_CN_OutletWS__c,' // [DC 5.0]
              + ' ASI_TH_CRM_Payment_Request__r.ASI_CRM_Vendor__c'
              + ' FROM ASI_TH_CRM_PaymentRequestLineItem__c'
              //+ ' WHERE ASI_CRM_Verified__c = FALSE'
              + ' WHERE ASI_TH_CRM_Payment_Request__r.ASI_CRM_SG_Finance_Verified__c = FALSE'
              + ' AND ASI_TH_CRM_Payment_Request__r.ASI_CRM_Sync_to_JDE__c = FALSE'
              + ' AND ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Status__c = \'Approved\''
              + ' AND (ASI_TH_CRM_Payment_Request__r.RecordType.DeveloperName = \'ASI_CRM_SG_Payment_Request\''
              + ' OR ASI_TH_CRM_Payment_Request__r.RecordType.DeveloperName = \'ASI_CRM_SG_Payment_Request_Read_Only\')';

        /*soql = 'SELECT id,' 
             + '       Name,'
             + '       ASI_CRM_Verified__c,'
             + '       ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Contract_No__c,' // DC 3.1
             + '       ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Status__c,' // DC 3.1
             + '       ASI_TH_CRM_Payment_Request__r.ASI_CRM_SG_Invoice_No__c,' // DC 3.1
             + '       ASI_TH_CRM_Payment_Request__r.ASI_CRM_SG_Invoice_Date__c,' // DC 3.1
             + '       ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_GL_Date__c,' // DC 3.1
             + '       ASI_TH_CRM_Payment_Request__r.Name,'
             + '       ASI_TH_CRM_Payment_Request__r.ASI_CRM_Outlet_Fx__c,' // DC 2.3
             + '       ASI_TH_CRM_Payment_Request__r.ASI_CRM_Vendor__c,' // DC 2.3
             + '       ASI_TH_CRM_Amount__c,'
             + '       ASI_CRM_SG_Type__c,'
             + '       ASI_CRM_SG_Sub_brand__c,' // DC 2.2
             + '       ASI_CRM_SG_JDE_COA_Code__c,'
             + '       ASI_CRM_SG_JDE_Is_Append_Local_Channel__c'
             + '  FROM ASI_TH_CRM_PaymentRequestLineItem__c'
             + ' WHERE ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Status__c = \'Approved\''
             + '   AND (ASI_TH_CRM_Payment_Request__r.RecordType.DeveloperName = \'ASI_CRM_SG_Payment_Request\'' // DC 2.0
             + '    OR ASI_TH_CRM_Payment_Request__r.RecordType.DeveloperName = \'ASI_CRM_SG_Payment_Request_Read_Only\')' // DC 2.0
             + '   AND ASI_CRM_Verified__c = FALSE';*/
        
        if (!String.isBlank(PaymentRequestNo))
            soql += ' AND ASI_TH_CRM_Payment_Request__r.Name LIKE \'%'+String.escapeSingleQuotes(PaymentRequestNo)+'%\'';
        
        if (!String.isBlank(PaymentRequestRef))
            soql += ' AND Name LIKE \'%'+String.escapeSingleQuotes(PaymentRequestRef)+'%\'';
        
        if (!String.isBlank(Outlet))
            soql += ' AND ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Outlet__c LIKE \'%'+String.escapeSingleQuotes(Outlet)+'%\'';
        
        if (!String.isBlank(Vendor))
            soql += ' AND ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Vendor__r.Name LIKE \'%'+String.escapeSingleQuotes(Vendor)+'%\'';
        
        if (!String.isBlank(fromGLdates)) {
            str = fromGLdates.split('-');
            searchDate = Datetime.newInstance(Integer.valueOf(str[0]),Integer.valueOf(str[1]),Integer.valueOf(str[2]),0,0,0);
            /* [VL 5.0] BEGIN */
            /*
            soql += ' AND ASI_CRM_GL_Date__c >= ' +searchDate.format('yyyy-MM-dd');
            */
            soql += ' AND (ASI_CRM_GL_Date__c >= ' +searchDate.format('yyyy-MM-dd') + ' OR ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_GL_Date__c >= ' +searchDate.format('yyyy-MM-dd') +')';
            /* [VL 5.0] END */
        }
        
        if (!String.isBlank(toGLdates)) {
            str = toGLdates.split('-');
            searchDate = Datetime.newInstance(Integer.valueOf(str[0]),Integer.valueOf(str[1]),Integer.valueOf(str[2]),0,0,0);
            /* [VL 5.0] BEGIN */
            /*
            soql += ' AND ASI_CRM_GL_Date__c <= ' +searchDate.format('yyyy-MM-dd');
            */
            soql += ' AND (ASI_CRM_GL_Date__c <= ' +searchDate.format('yyyy-MM-dd') + ' OR ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_GL_Date__c <= ' +searchDate.format('yyyy-MM-dd') +')';
            /* [VL 5.0] END */
        }

        /* DC 3.0 start */
        if (!String.isBlank(contractNo))
            soql += ' AND ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Contract_No__c LIKE \'%'+String.escapeSingleQuotes(contractNo)+'%\'';
        
        if (!String.isBlank(jdeCoaCode))
            soql += ' AND ASI_CRM_SG_JDE_COA_Code__c LIKE \'%'+String.escapeSingleQuotes(jdeCoaCode)+'%\'';

        if (!String.isBlank(status))
            soql += ' AND ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Status__c LIKE \'%'+String.escapeSingleQuotes(status)+'%\'';
        /* DC 3.0 end */
        
        runQuery();
        System.debug('test678:'+soql);
        return null;
        }
    
    // save Payment Request Line Items
    public PageReference save(){
        string alertMsg = '';
        decimal lineItemProceed = 0;
        decimal lineItemVerified = 0;
        decimal headerVerified = 0;

        isErrorOnSave = false;
        
        try {

            if(lstLineItems != NULL && lstLineItems.isEmpty() == false) {

                List<ASI_TH_CRM_PaymentRequestLineItem__c> lstFinalizedLineItems =
                    new List<ASI_TH_CRM_PaymentRequestLineItem__c>();

                Set<ASI_TH_CRM_PaymentRequest__c> list_finalizedHeader =
                    new Set<ASI_TH_CRM_PaymentRequest__c>();

                Map<Id, ASI_TH_CRM_PaymentRequestLineItem__c> mapId_UpdatedLineItem =
                    new Map<Id, ASI_TH_CRM_PaymentRequestLineItem__c>(lstLineItems);
                    
                for(ASI_TH_CRM_PaymentRequestLineItem__c lineItemIterator : lstTotalLineItems) {

                    if(mapId_UpdatedLineItem.containsKey(lineItemIterator.Id)) {
                        lstFinalizedLineItems.add(mapId_UpdatedLineItem.get(lineItemIterator.Id));
                    } else {
                        lstFinalizedLineItems.add(lineItemIterator);
                    }
                    list_finalizedHeader.add(mapID_RequestHeader.get(lineItemIterator.ASI_TH_CRM_Payment_Request__r.Id));
                }
                
                system.debug('---list_finalizedHeader---'+list_finalizedHeader);
                system.debug('---lstFinalizedLineItems---'+lstFinalizedLineItems);

                ASI_CRM_SG_Payment_ValidationHelper_V2 validator = 
                    new ASI_CRM_SG_Payment_ValidationHelper_V2(true, new List<ASI_TH_CRM_PaymentRequest__c>(list_finalizedHeader), lstFinalizedLineItems);

                String validationResult = validator.validateAmountExceed();
					
                if(String.isNotBlank(validationResult)) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, validationResult));
                    return null;
                }

                /* [VL 6.0] BEGIN */
                Map<id, decimal> map_header_totalLine = new Map<id, decimal>();
                Map<id, decimal> map_header_verifiedLine = new Map<id, decimal>();
                Decimal totalLine = 0.0;
                Decimal verifiedLine = 0.0;
                Map<id, string> map_headerID_name = new Map<id, string>();
                /* [VL 6.0] END */
                
                for(ASI_TH_CRM_PaymentRequestLineItem__c lineItemIterator : lstFinalizedLineItems) {

                    /* [VL 6.0] BEGIN */
                    /*
                    if(lineItemIterator.ASI_CRM_Verified__c == false
                    && setRequestHeaderIds.contains(lineItemIterator.ASI_TH_CRM_Payment_Request__c)) {

                        setRequestHeaderIds.remove(lineItemIterator.ASI_TH_CRM_Payment_Request__c);

                    }
                    */
                    
                    totalLine = map_header_totalLine.containsKey(lineItemIterator.ASI_TH_CRM_Payment_Request__c) ? map_header_totalLine.get(lineItemIterator.ASI_TH_CRM_Payment_Request__c) : 0.0;
                    verifiedLine = map_header_verifiedLine.containsKey(lineItemIterator.ASI_TH_CRM_Payment_Request__c) ? map_header_verifiedLine.get(lineItemIterator.ASI_TH_CRM_Payment_Request__c) : 0.0;
                    if(lineItemIterator.ASI_CRM_Verified__c) {
                        verifiedLine += 1;
                        lineItemVerified++;
                    }
                    totalLine += 1;
                    map_header_totalLine.put(lineItemIterator.ASI_TH_CRM_Payment_Request__c, totalLine);
                    map_header_verifiedLine.put(lineItemIterator.ASI_TH_CRM_Payment_Request__c, verifiedLine);
                    map_headerID_name.put(lineItemIterator.ASI_TH_CRM_Payment_Request__c, lineItemIterator.ASI_TH_CRM_Payment_Request__r.name);
                    /* [VL 6.0] END */
					
					/*[WL 9.0 BEGIN]*/
					/*if (lineItemIterator.ASI_CRM_Contract_Exist_Before_RTM__c){
						if (!beforeRTMContractType.contains(lineItemIterator.ASI_CRM_SG_Type__c)){
							system.debug('Incorrect Type for Non-RTM Contract Payment');
							ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Incorrect Type for Non-RTM Contract Payment: ' + map_headerID_name.get(lineItemIterator.ASI_TH_CRM_Payment_Request__c)));
							return null;
						}
					}
					else {
						if (!afterRTMContractType.contains(lineItemIterator.ASI_CRM_SG_Type__c)){
							system.debug('Incorrect Type for RTM Contract Payment');
							ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Incorrect Type for RTM Contract Payment: ' + map_headerID_name.get(lineItemIterator.ASI_TH_CRM_Payment_Request__c)));
							return null;
						}
					}*/
					/*[WL 9.0 END]*/
                }
                
                /* [VL 6.0] BEGIN */
                String notAllVerified = '';
                Set<id> finalHeaderID = new Set<id>();
                
                for (id headerID : map_header_totalLine.keySet()){
                    totalLine = map_header_totalLine.get(headerID);
                    verifiedLine = map_header_verifiedLine.get(headerID);
                    if (verifiedLine != 0.0 && totalLine > verifiedLine) {
                        notAllVerified += 'For payment '+map_headerID_name.get(headerID)+', not all line items are verified. ';
                    } else 
                    if (verifiedLine != 0.0) {
                        finalHeaderID.add(headerID);
                    }
                }
                
                if(String.isNotBlank(notAllVerified)) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, notAllVerified));
                    return null;
                }
                /* [VL 6.0] END */
			
                List<ASI_TH_CRM_PaymentRequest__c> lstRequestHeaders_ToUpdate = new List<ASI_TH_CRM_PaymentRequest__c>();

                /* [VL 6.0] BEGIN */
                /*
                if(!setRequestHeaderIds.isEmpty()) {
                    for(Id requestHeaderId : setRequestHeaderIds)
                    lstRequestHeaders_ToUpdate.add(
                        new ASI_TH_CRM_PaymentRequest__c(
                            Id = requestHeaderId,
                            ASI_TH_CRM_Status__c = 'Final',
                            ASI_CRM_Sync_to_JDE__c = true
                        )
                    );

                    if(!lstRequestHeaders_ToUpdate.isEmpty()) {
                        update lstRequestHeaders_ToUpdate;
                    }
                }
                */

                if(!finalHeaderID.isEmpty()) {
                    for(Id requestHeaderId : finalHeaderID)
                    lstRequestHeaders_ToUpdate.add(
                        new ASI_TH_CRM_PaymentRequest__c(
                            Id = requestHeaderId,
                            /* [VL 8.0] BEGIN */
                            /*
                            ASI_TH_CRM_Status__c = 'Final',
                            ASI_CRM_Sync_to_JDE__c = true
                            */
                            ASI_CRM_SG_Finance_Verified__c = true
                            /* [VL 8.0] BEGIN */
                        )
                    );

                    if(!lstRequestHeaders_ToUpdate.isEmpty()) {
                        update lstRequestHeaders_ToUpdate;
                    }
                    
                    headerVerified = finalHeaderID.size();
                }
                /* [VL 6.0] END */

                update lstFinalizedLineItems;
                
                lineItemProceed = lstFinalizedLineItems.size();

            }

        } catch(Exception exceptionInstance) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, exceptionInstance.getMessage()));
            return null;
        }
        
        /* [VL 7.0] BEGIN */
        /*
        return null;
        */
        //PageReference pageRef = new PageReference(ApexPages.currentPage().getUrl());
        PageReference pageRef = runSearch();
        //pageRef.setRedirect(true);
        //alertMsg = lineItemProceed + ' line items are proceeded. ';
        alertMsg = 'Your changes have been saved. ';
        alertMsg += (headerVerified != 0) ? (headerVerified + ' headers with ' + lineItemVerified + ' line items are verified.') : '';
        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, alertMsg));
        return pageRef;
        /* [VL 7.0] END */
    }

    public void validateDataOnSave() {

        isErrorOnSave = false;
        isError = false;

        Map<Id, List<ASI_TH_CRM_PaymentRequestLineItem__c>> mapHeaderId_LineItems =
            new Map<Id, List<ASI_TH_CRM_PaymentRequestLineItem__c>>();
        
        Boolean isDifferentNo = false, isDifferentDate = false;
        alertMessage = '';

        for(ASI_TH_CRM_PaymentRequestLineItem__c lineItemIterator : lstLineItems) {

            if(lineItemIterator.ASI_TH_CRM_Payment_Request__c != NULL) {
                if( !mapHeaderId_LineItems.containsKey(lineItemIterator.ASI_TH_CRM_Payment_Request__c)) {
                    mapHeaderId_LineItems.put(
                        lineItemIterator.ASI_TH_CRM_Payment_Request__c,
                        new List<ASI_TH_CRM_PaymentRequestLineItem__c> {lineItemIterator}
                    );
                } else {
                    mapHeaderId_LineItems.get(lineItemIterator.ASI_TH_CRM_Payment_Request__c)
                                         .add(lineItemIterator);
                }
            }
        }

        for(Id headerId : mapHeaderId_LineItems.keySet()) {

            isDifferentNo = isDifferentDate = false;

            String invoiceNo = mapHeaderId_LineItems.get(headerId).get(0).ASI_TH_CRM_Invoice_No__c;
            Date invoiceDate = mapHeaderId_LineItems.get(headerId).get(0).ASI_CRM_SG_Invoice_Date__c;

            for(ASI_TH_CRM_PaymentRequestLineItem__c lineItemIterator : mapHeaderId_LineItems.get(headerId)) {

                if(lineItemIterator.ASI_TH_CRM_Invoice_No__c != invoiceNo) {
                    isDifferentNo = true;
                }

                if(lineItemIterator.ASI_CRM_SG_Invoice_Date__c != invoiceDate) {
                    isDifferentDate = true;
                }
            }

            if(isDifferentNo == true) {
                alertMessage =
                    geneateAlert(alertMessage, mapHeaderId_LineItems.get(headerId), 'ASI_TH_CRM_Invoice_No__c');
            }
            if(isDifferentDate == true) {
                alertMessage =
                    geneateAlert(alertMessage, mapHeaderId_LineItems.get(headerId), 'ASI_CRM_SG_Invoice_Date__c');
            }
        }

        alertMessage += NEXT_LINE + CONFIRMATION;

        isErrorOnSave = String.isNotBlank(alertMessage);
    }

    public void validateData() {

        isError = false;
        isErrorOnSave = false;

        Id pRequestHeaderId = Apexpages.currentPage().getParameters().get('headerId');
        String pInvoiceNo = Apexpages.currentPage().getParameters().get('invoiceNo');
        String pInvoiceDate = Apexpages.currentPage().getParameters().get('invoiceDate');

        Boolean isDifferent = false;
        alertMessage = '';
        List<ASI_TH_CRM_PaymentRequestLineItem__c> invalidDataLines;

        System.debug('------ lstLineItems ------ : ' + lstLineItems);
		
        System.debug('Testing ' + pRequestHeaderId);
        System.debug('Testing ' + pInvoiceNo);
        System.debug('Testing ' + lstLineItems);
        
        if(pRequestHeaderId != NULL && String.isNotBlank(pInvoiceNo)) {

            for(ASI_TH_CRM_PaymentRequestLineItem__c lineItemIterator : lstLineItems) {

                if( lineItemIterator.ASI_TH_CRM_Payment_Request__c == pRequestHeaderId
                &&  String.isNotBlank(lineItemIterator.ASI_TH_CRM_Invoice_No__c)
                &&  !pInvoiceNo.equalsIgnoreCase(lineItemIterator.ASI_TH_CRM_Invoice_No__c)) {
                    isDifferent = true;
                }
            }

            if(isDifferent == true) {

                invalidDataLines = new List<ASI_TH_CRM_PaymentRequestLineItem__c>();

                for(ASI_TH_CRM_PaymentRequestLineItem__c lineItemIterator : lstLineItems) {

                    if( lineItemIterator.ASI_TH_CRM_Payment_Request__c == pRequestHeaderId) {
                        invalidDataLines.add(lineItemIterator);
                    }
                }

                if(!invalidDataLines.isEmpty() && invalidDataLines.size() != 1) {
                    alertMessage =
                        geneateAlert(alertMessage, invalidDataLines, 'ASI_TH_CRM_Invoice_No__c');
                }
            }

        } else if(pRequestHeaderId != NULL && String.isNotBlank(pInvoiceDate)) {

            List<String> dateComponents = pInvoiceDate.split('/');

            /*DateTime invoiceDate_Temp = DateTime.newInstance(
                Integer.valueOf(dateComponents.get(2)),
                Integer.valueOf(dateComponents.get(0)),
                Integer.valueOf(dateComponents.get(1))
            );*/

            Date invoiceDate_Temp = Date.parse(pInvoiceDate);

            System.debug('------ pInvoiceDate ------ : ' + pInvoiceDate);
            System.debug('------ invoiceDate_Temp ------ : ' + invoiceDate_Temp);

            for(ASI_TH_CRM_PaymentRequestLineItem__c lineItemIterator : lstLineItems) {

                if( lineItemIterator.ASI_TH_CRM_Payment_Request__c == pRequestHeaderId
                &&  lineItemIterator.ASI_CRM_SG_Invoice_Date__c != NULL 
                &&  invoiceDate_Temp != lineItemIterator.ASI_CRM_SG_Invoice_Date__c) {
                    isDifferent = true;
                }
            }

            if(isDifferent == true) {

                invalidDataLines = new List<ASI_TH_CRM_PaymentRequestLineItem__c>();

                for(ASI_TH_CRM_PaymentRequestLineItem__c lineItemIterator : lstLineItems) {

                    if( lineItemIterator.ASI_TH_CRM_Payment_Request__c == pRequestHeaderId) {
                        invalidDataLines.add(lineItemIterator);
                    }
                }

                if(!invalidDataLines.isEmpty() && invalidDataLines.size() != 1) {
                    alertMessage =
                        geneateAlert(alertMessage, invalidDataLines, 'ASI_CRM_SG_Invoice_Date__c');
                }
            }
        }

        isError = String.isNotBlank(alertMessage);

        System.debug('------ alertMessage ------ : ' + alertMessage);
        System.debug('------ isError ------ : ' + isError);

    }

    private String geneateAlert(
        String pAlertMessage, List<ASI_TH_CRM_PaymentRequestLineItem__c> pLstLineItems, String pFieldName ) {

        if(pFieldName.equalsIgnoreCase('ASI_CRM_SG_Invoice_Date__c')) {

                           // Different Invoice Date in the same Payment Request:\n
            pAlertMessage += NEXT_LINE + START_INVOICE_DATE + NEXT_LINE
                           // Payment Request : {! Payment Request No. }\n
                           + PAYMENT_REQUEST + COLON + pLstLineItems[0].ASI_TH_CRM_Payment_Request__r.Name + NEXT_LINE;

            for(ASI_TH_CRM_PaymentRequestLineItem__c lineItemIterator : pLstLineItems) {

                // {! Payment Request Ref. } : {! Invoice Date }\n
                pAlertMessage += lineItemIterator.Name + COLON ;
                Date lineItemDate = (Date) lineItemIterator.get(pFieldName);
                pAlertMessage += lineItemDate.day() + DATE_SEPARATOR
                               + lineItemDate.month() + DATE_SEPARATOR
                               + lineItemDate.year() + NEXT_LINE;
            }

        }

        if(pFieldName.equalsIgnoreCase('ASI_TH_CRM_Invoice_No__c')) {

                           // Different Invoice No. in the same Payment Request:\n
            pAlertMessage += NEXT_LINE + START_INVOICE_NO + NEXT_LINE
                           // Payment Request : {! Payment Request No. }\n
                           + PAYMENT_REQUEST + COLON + pLstLineItems[0].ASI_TH_CRM_Payment_Request__r.Name + NEXT_LINE;

            for(ASI_TH_CRM_PaymentRequestLineItem__c lineItemIterator : pLstLineItems) {

                // {! Payment Request Ref. } : {! Invoice No. }\n
                pAlertMessage += lineItemIterator.Name + COLON + lineItemIterator.get(pFieldName) + NEXT_LINE;
            }

        }
				
        return pAlertMessage;

    }
    
    // change page function
    public void firstPage() {
        this.currentPageNum=1;
        implChangePage(1);
        this.LimitFrom = 0;
        runQuery();
    }
    
    public void lastPage() {
        this.currentPageNum=this.maxNumOfPage();
        implChangePage(this.maxNumOfPage());
        this.LimitFrom = this.maxPageNum*this.numOfRowInTable-this.numOfRowInTable;
        runQuery();
    }
    
    public void prevPage() {
        if(this.currentPageNum>0){
            this.currentPageNum = this.currentPageNum -1;
            implChangePage(this.currentPageNum);
            this.LimitFrom=this.LimitFrom-this.numOfRowInTable;
            runQuery();
        }
    }
    
    public void nextPage() {
        if(this.currentPageNum<this.maxPageNum){
            this.currentPageNum=this.currentPageNum + 1;
            implChangePage(this.currentPageNum);
        //this.numOfRowInTable=this.numOfRowInTable+2;
            this.LimitFrom=this.LimitFrom+this.numOfRowInTable;
            runQuery();
        //implChangePage(this.currentPageNum + 1); 
        }
        
    }
    
    public void implChangePage(Integer pageNum) {
        Integer maxPNum = this.maxNumOfPage();
        if (pageNum <= 0) this.currentPageNum = 1;
        else if (pageNum > maxPNum) this.currentPageNum = maxPNum;
    }
    
    private Integer maxNumOfPage() {
        if (this.totalNumOfRecord == 0 || this.numOfRowInTable == 0)
            return 1;
        return ((this.totalNumOfRecord - 1) / this.numOfRowInTable) + 1;
    }

}