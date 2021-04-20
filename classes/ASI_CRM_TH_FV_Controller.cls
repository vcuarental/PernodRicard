/*********************************************************************************
 * Name: ASI_CRM_TH_FV_Controller
 * Page: ASI_CRM_TH_FV_Page
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 03/05/2016       Introv: Kevani Chow        
*********************************************************************************/


public without sharing class ASI_CRM_TH_FV_Controller {
    protected Integer totalNumOfRecord;
    public Integer numOfRowInTable;
    public Integer LimitFrom;
    private String soql {get;set;}

    public String eid {get;set;}
    public String rid {get;set;}
    public String pid {get;set;}

    //Seacrh Filters
    public String seacrhConNo {get;set;}
    public String searchPayReqNo {get;set;}
    public String searchVendor {get;set;}
    public String searchTaxId {get;set;}
    public String searchACCode {get;set;}
    public String searchStatus {get;set;}
    public ASI_TH_CRM_PaymentRequestLineItem__c searchDueDateFrom { get; set; }
    public ASI_TH_CRM_PaymentRequestLineItem__c searchDueDateTo { get; set; }
    
    
    Public List <ASI_TH_CRM_PaymentRequestLineItem__c> listUpdatePRLineItem { get; set; }
    Public List <paymentRequest> paymentRequestList{get; set;}
    
    public transient List<ASI_TH_CRM_PaymentRequestLineItem__c> TotalLineItem {get;set;}
    public List<ASI_TH_CRM_PaymentRequestLineItem__c> lineItem {get;set;}
    public List<ASI_TH_CRM_PaymentRequest__c> listUpdatePR { get; set; }
    public Set<Id> setUpdatePR { get; set; }
    
    List <Report> reportList=new List<Report>();
    
    public void init() {
        
        
        soql='SELECT Id, Name, ASI_CRM_Finance_Verify__c , ASI_CRM_GL_Date__c , ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Contract_No__c , ASI_TH_CRM_Payment_Request__r.Name, ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Vendor__c, ASI_CRM_Tax_ID__c, ASI_TH_CRM_Subbrand__c,ASI_CRM_BU__c, ASI_TH_CRM_COA__c, ASI_CRM_AC_Code__c, ASI_CRM_AC_Code__r.Name, ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Outlet_Code__c, ASI_TH_CRM_Amount__c, ASI_TH_CRM_Invoice_No__c, ASI_CRM_SG_Invoice_Date__c, ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_PORaiseDate__c, ASI_CRM_Invoice_Due_Date__c, ASI_CRM_Remark__c, ASI_CRM_Withholding_Tax__c, ASI_CRM_Tax_Type__c, ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Status__c, ASI_CRM_CN_Comment__c, ASI_CRM_ETL_Date__c, ASI_CRM_Sync_to_JDE__c, ASI_CRM_JDE_Document_No__c, ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Vendor__r.ASI_MFM_City__c FROM ASI_TH_CRM_PaymentRequestLineItem__c WHERE (ASI_CRM_Invoice_Due_Date__c >= TODAY OR ASI_CRM_Invoice_Due_Date__c = NULL)AND ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Status__c IN(\'Draft\',\'Ready for Approval\',\'Pending Regional Sales Manager\',\'Pending Head of National On Trade\',\'Pending Head of Finance and Operations\',\'Pending Managing Director\',\'Approved\') AND ASI_TH_CRM_Payment_Request__r.RecordType.DeveloperName LIKE \'ASI_TH_CRM_Payment%\' ';
        this.numOfRowInTable = 50;
        this.currentPageNum = 1;
        this.LimitFrom = 0;
        
        reportList =[Select ID from Report where DeveloperName = 'ASI_CRM_TH_Finance_Verify_Report'];
        if (reportList!=null && reportList.size()>0){
            rid= (String)reportList.get(0).get('Id');
        }
        
        reportList =[Select ID from Report where DeveloperName = 'ASI_CRM_TH_ETL_Report'];
        if (reportList!=null && reportList.size()>0){
            eid= (String)reportList.get(0).get('Id');
        }
        
        //Get payment report   
        reportList =[Select ID from Report where DeveloperName = 'ASI_CRM_TH_Payment_Report'];
        if (reportList!=null && reportList.size()>0){
            pid= (String)reportList.get(0).get('Id');
        }      
        
        //Search intitial
        seacrhConNo =null;
        searchPayReqNo =null;
        searchVendor =null;
        searchTaxId =null;
        searchACCode =null;
        searchStatus =null;
        searchDueDateFrom = new ASI_TH_CRM_PaymentRequestLineItem__c ();
        searchDueDateTo = new ASI_TH_CRM_PaymentRequestLineItem__c ();
        runQuery();
    }
    public list<selectOption> available_Region {get; private set;}

    
    
    public ASI_CRM_TH_FV_Controller(ApexPages.StandardController controller){
        init();
    }
    public PageReference refresh() {
        init();
        return null;
    }
    
    public String sortDir {
        get  { if (sortDir == null) {  sortDir = 'ASC'; } return sortDir;  }
        set;
    }

    public String sortField {

        get  { if (sortField == null) {sortField = 'ASI_CRM_Invoice_Due_Date__c'; } return sortField;  }
        set;
    }
    public String debugSoql {
        get { return soql + ' order by ' + sortField + ' ' + sortDir  + ' Limit ' + this.numOfRowInTable + ' OFFSET ' + LimitFrom; }
        set;
    }
   
    //sort
    public void toggleSort() {
        sortDir = sortDir.equals('asc') ? 'desc' : 'asc';
        runQuery();
      }
    
    public void runQuery() {
        Map<String, id> map1stPRitm = new Map<String, id>();
        setUpdatePR = new Set<Id>();
        
        try {
            system.debug('soql endtered runquery: '+soql);
            TotalLineItem = Database.query(soql + ' order by ' + sortField + ' ' + sortDir);
            system.debug('TotalLineItem: '+TotalLineItem);
            if(TotalLineItem!=null)
            this.totalNumOfRecord = TotalLineItem.size();
            system.debug(soql + ' order by ' + sortField + ' ' + sortDir + ' Limit ' + this.numOfRowInTable + ' OFFSET ' + LimitFrom);
            lineItem = Database.query(soql + ' order by ' + sortField + ' ' + sortDir + ' Limit ' + this.numOfRowInTable + ' OFFSET ' + LimitFrom);
            
            //Assign values to the list of paymentRequest class for display
            system.debug('runQuery lineItem: '+ lineItem);
            
            paymentRequestList = new List <paymentRequest>();
            if (lineItem!=null && lineItem.size()>0){
                for (ASI_TH_CRM_PaymentRequestLineItem__c payReqItems : lineItem){
                    paymentRequest payRequest= new paymentRequest();
                    payRequest.editable=true;
                    payRequest.payReqItem = payReqItems;
                    
                    //Added by Twinkle @20160616
                    if(map1stPRitm == NULL)
                        map1stPRitm.put(payRequest.payReqItem.ASI_TH_CRM_Payment_Request__c+'_'+payRequest.payReqItem.ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Vendor__c, payRequest.payReqItem.id);
                    else if(map1stPRitm.get(payRequest.payReqItem.ASI_TH_CRM_Payment_Request__c+'_'+payRequest.payReqItem.ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Vendor__c) == NULL){
                        //map PRitm by PR & Vendor
                        map1stPRitm.put(payRequest.payReqItem.ASI_TH_CRM_Payment_Request__c+'_'+payRequest.payReqItem.ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Vendor__c, payRequest.payReqItem.id);
                    }
                    
                    if(map1stPRitm != NULL && map1stPRitm.get(payRequest.payReqItem.ASI_TH_CRM_Payment_Request__c+'_'+payRequest.payReqItem.ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Vendor__c)==payRequest.payReqItem.id){
                        setUpdatePR.add(payRequest.payReqItem.ASI_TH_CRM_Payment_Request__c);
                        payRequest.firstPRitm = TRUE;
                    }
                    //End by Twinkle @20160616
                
                    if(payRequest.payReqItem.ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Status__c !='Approved' || payRequest.payReqItem.ASI_CRM_Sync_to_JDE__c==true||payRequest.payReqItem.ASI_CRM_Finance_Verify__c==true){
                        payRequest.editable=false;
                        payRequest.editverify = false;
                    }
                    if(payRequest.payReqItem.ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Status__c =='Approved' && payRequest.payReqItem.ASI_CRM_Sync_to_JDE__c!=true){
                        payRequest.editverify = true;
                    }
                    
                    paymentRequestList.add(payRequest);
                    
                }            }
            system.debug('runQuery paymentRequestList: '+ paymentRequestList);

            system.debug('lineItem: '+lineItem);
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No Records Found, Please Check your search input' + e));
            //System.debug('Fail123');
        }
    }
    
    //search function
    public PageReference runSearch() {
        
        String[] str;
        Datetime searchDate;
        soql='SELECT Id, Name, ASI_CRM_Finance_Verify__c , ASI_CRM_GL_Date__c ,ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Contract_No__c , ASI_TH_CRM_Payment_Request__r.Name, ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Vendor__c, ASI_CRM_Tax_ID__c, ASI_TH_CRM_Subbrand__c,ASI_CRM_BU__c, ASI_TH_CRM_COA__c, ASI_CRM_AC_Code__c,ASI_CRM_AC_Code__r.Name, ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Outlet_Code__c, ASI_TH_CRM_Amount__c, ASI_TH_CRM_Invoice_No__c, ASI_CRM_SG_Invoice_Date__c, ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_PORaiseDate__c, ASI_CRM_Invoice_Due_Date__c, ASI_CRM_Remark__c, ASI_CRM_Withholding_Tax__c, ASI_CRM_Tax_Type__c, ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Status__c, ASI_CRM_CN_Comment__c, ASI_CRM_ETL_Date__c, ASI_CRM_Sync_to_JDE__c, ASI_CRM_JDE_Document_No__c, ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Vendor__r.ASI_MFM_City__c FROM ASI_TH_CRM_PaymentRequestLineItem__c WHERE ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Status__c IN(\'Draft\',\'Ready for Approval\',\'Pending Regional Sales Manager\',\'Pending Head of National On Trade\',\'Pending Head of Finance and Operations\',\'Pending Managing Director\',\'Approved\') AND ASI_TH_CRM_Payment_Request__r.RecordType.DeveloperName LIKE \'ASI_TH_CRM_Payment%\' ';

        Boolean dateflag1=false;
        Boolean dateflag2=false;
        //Search commandButton
        if(searchStatus!=null && searchStatus.length()>0){
            soql += ' and ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Status__c = \''+String.escapeSingleQuotes(searchStatus)+'\'';
        }
        if(searchPayReqNo!=null && searchPayReqNo.length()>0){
            soql += ' and ASI_TH_CRM_Payment_Request__r.Name LIKE \''+String.escapeSingleQuotes(searchPayReqNo)+'%\'';
        }
        if(searchVendor!=null && searchVendor.length()>0){
            soql += ' and ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Vendor__r.Name LIKE \''+String.escapeSingleQuotes(searchVendor)+'%\'';
        }
        if(searchTaxId!=null && searchTaxId.length()>0){
            soql += ' and ASI_CRM_Tax_ID__c LIKE \''+String.escapeSingleQuotes(searchTaxId)+'%\'';
        }
        if(searchACCode!=null && searchACCode.length()>0){
            soql += ' and ASI_CRM_AC_Code__r.Name LIKE \''+String.escapeSingleQuotes(searchACCode)+'%\'';
        }
        
        if(seacrhConNo!=null && seacrhConNo.length()>0){
            soql += ' and ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Contract_No__c LIKE \''+String.escapeSingleQuotes(seacrhConNo)+'%\'';
        }
        
        //Kevani@04052016
        if (searchDueDateFrom.ASI_CRM_Invoice_Due_Date__c != null) {
            String fromDate = DateTime.newInstance(searchDueDateFrom.ASI_CRM_Invoice_Due_Date__c.year(),searchDueDateFrom.ASI_CRM_Invoice_Due_Date__c.month(),searchDueDateFrom.ASI_CRM_Invoice_Due_Date__c.day(), 0,0,0).format('yyyy-MM-dd');
            soql += ' AND ASI_CRM_Invoice_Due_Date__c  >= ' + fromDate + ''; 
        }
        if (searchDueDateTo.ASI_CRM_Invoice_Due_Date__c != null) {
            String toDate = DateTime.newInstance(searchDueDateTo.ASI_CRM_Invoice_Due_Date__c.year(),searchDueDateTo.ASI_CRM_Invoice_Due_Date__c.month(),searchDueDateTo.ASI_CRM_Invoice_Due_Date__c.day(), 0,0,0).format('yyyy-MM-dd');
            soql += ' AND ASI_CRM_Invoice_Due_Date__c    <= ' + toDate + ''; 
        }
        //Vincent@20161122 Add another scenario, if search by Tax ID + Contract Number, bypass date parameter
        if(searchDueDateFrom.ASI_CRM_Invoice_Due_Date__c==null && searchDueDateTo.ASI_CRM_Invoice_Due_Date__c==null && searchTaxId!=null && searchTaxId.length()>0 && searchPayReqNo!=null && searchPayReqNo.length()>0){
            soql += ' AND (ASI_CRM_Invoice_Due_Date__c >= TODAY OR ASI_CRM_Invoice_Due_Date__c = NULL)  ';
        }
        if(searchDueDateFrom.ASI_CRM_Invoice_Due_Date__c==null && searchDueDateTo.ASI_CRM_Invoice_Due_Date__c==null){
            soql += ' AND (ASI_CRM_Invoice_Due_Date__c >= TODAY OR ASI_CRM_Invoice_Due_Date__c = NULL)  ';
        }
         
        system.debug('soql in run search: '+soql); 
        
        this.currentPageNum = 1;
        this.LimitFrom = 0;
        runQuery();
        return null;
        }
    
    // /////////////////////////save FVerify 
    public void save(){
        // update ASI_TH_CRM_PaymentRequestLineItem__c
        listUpdatePRLineItem = new List<ASI_TH_CRM_PaymentRequestLineItem__c>();
        Boolean blnIsError =false;
        
        //Added by Twinkle @20160616
        listUpdatePR = new List<ASI_TH_CRM_PaymentRequest__c>();
        Map<Id, ASI_TH_CRM_PaymentRequest__c> mapUpdatePR = new Map<Id, ASI_TH_CRM_PaymentRequest__c>();
        
        List<ASI_TH_CRM_PaymentRequest__c> listInvoledPR = [SELECT id, ASI_TH_CRM_Vendor__c FROM ASI_TH_CRM_PaymentRequest__c WHERE id IN: setUpdatePR];
        for(ASI_TH_CRM_PaymentRequest__c pr : listInvoledPR){
            mapUpdatePR.put(pr.id, pr);
        }
        //End by Twinkle @20160616
        
        for (paymentRequest updateLineItem: paymentRequestList){
            updateLineItem.strErrMsgInvoiceDueDate ='';
            updateLineItem.strErrMsgGlDate ='';
            updateLineItem.strErrMsgInvoiceDate ='';
            updateLineItem.strErrMsgInvoiceNo ='';
            updateLineItem.strErrMsgCoa ='';
            updateLineItem.strErrMsgSubBrand ='';
                   
            if(updateLineItem.editable == true||updateLineItem.editverify == true){
                ASI_TH_CRM_PaymentRequestLineItem__c updatePRLineItem = new ASI_TH_CRM_PaymentRequestLineItem__c();
                updatePRLineItem.id = updateLineItem.payReqItem.id;
                
                updatePRLineItem.ASI_CRM_Finance_Verify__c = updateLineItem.payReqItem.ASI_CRM_Finance_Verify__c;
                
                system.debug('updateLineItem.payReqItem.ASI_TH_CRM_Subbrand__c: '+updateLineItem.payReqItem.ASI_TH_CRM_Subbrand__c);
                if(updateLineItem.payReqItem.ASI_TH_CRM_Subbrand__c!=null){
                    updatePRLineItem.ASI_TH_CRM_Subbrand__c = updateLineItem.payReqItem.ASI_TH_CRM_Subbrand__c;
                }else if(updatePRLineItem.ASI_CRM_Finance_Verify__c ==true){
                    updateLineItem.strErrMsgSubBrand = 'Please input Sub-Brand';
                    blnIsError = true;
                }
                
                if(updateLineItem.payReqItem.ASI_TH_CRM_COA__c!=null && updateLineItem.payReqItem.ASI_TH_CRM_COA__c!=''){
                    updatePRLineItem.ASI_TH_CRM_COA__c = updateLineItem.payReqItem.ASI_TH_CRM_COA__c;
                }else if(updatePRLineItem.ASI_CRM_Finance_Verify__c ==true){
                    updateLineItem.strErrMsgCoa = 'Please input COA';
                    blnIsError = true; 
                }
                
                if(updateLineItem.payReqItem.ASI_TH_CRM_Invoice_No__c!=null && updateLineItem.payReqItem.ASI_TH_CRM_Invoice_No__c!=''){
                    updatePRLineItem.ASI_TH_CRM_Invoice_No__c = updateLineItem.payReqItem.ASI_TH_CRM_Invoice_No__c;
                }else if(updatePRLineItem.ASI_CRM_Finance_Verify__c ==true){
                    updateLineItem.strErrMsgInvoiceNo = 'Please input Invoice No.';
                    blnIsError = true;
                }
                
                if(updateLineItem.payReqItem.ASI_CRM_SG_Invoice_Date__c!=null){
                    updatePRLineItem.ASI_CRM_SG_Invoice_Date__c = updateLineItem.payReqItem.ASI_CRM_SG_Invoice_Date__c;
                }else if(updatePRLineItem.ASI_CRM_Finance_Verify__c ==true){
                    updateLineItem.strErrMsgInvoiceDate = 'Please input Invoice Date';
                    blnIsError = true;                
                }
                
                if(updateLineItem.payReqItem.ASI_CRM_GL_Date__c!=null){
                    updatePRLineItem.ASI_CRM_GL_Date__c = updateLineItem.payReqItem.ASI_CRM_GL_Date__c;
                }else if(updatePRLineItem.ASI_CRM_Finance_Verify__c ==true){
                    updateLineItem.strErrMsgGlDate = 'Please input GL Date';
                    blnIsError = true;
                }
                
                if(updateLineItem.payReqItem.ASI_CRM_Invoice_Due_Date__c!=null){
                    updatePRLineItem.ASI_CRM_Invoice_Due_Date__c = updateLineItem.payReqItem.ASI_CRM_Invoice_Due_Date__c;
                }else if(updatePRLineItem.ASI_CRM_Finance_Verify__c ==true){ 
                    updateLineItem.strErrMsgInvoiceDueDate = 'Please input Invoice Due Date';
                    blnIsError = true;
                }
               
                updatePRLineItem.ASI_CRM_Remark__c  = updateLineItem.payReqItem.ASI_CRM_Remark__c;
                updatePRLineItem.ASI_CRM_Withholding_Tax__c = updateLineItem.payReqItem.ASI_CRM_Withholding_Tax__c;
                updatePRLineItem.ASI_CRM_Tax_Type__c  = updateLineItem.payReqItem.ASI_CRM_Tax_Type__c;
                updatePRLineItem.ASI_CRM_CN_Comment__c = updateLineItem.payReqItem.ASI_CRM_CN_Comment__c;
                
                if(mapUpdatePR != NULL && mapUpdatePR.get(updateLineItem.payReqItem.ASI_TH_CRM_Payment_Request__c) != NULL){
                    mapUpdatePR.get(updateLineItem.payReqItem.ASI_TH_CRM_Payment_Request__c).ASI_TH_CRM_Vendor__c = updateLineItem.payReqItem.ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Vendor__c;                
                }
                listUpdatePRLineItem.add(updatePRLineItem);
            }
            
            listUpdatePR = new List<ASI_TH_CRM_PaymentRequest__c>();
            for(String pr : mapUpdatePR.KeySet()){
                listUpdatePR.add(mapUpdatePR.get(pr));
            }
        }
        
        
        /*//added for checking same invoice number
        set<string> setInvoiceNo = new set<string>();
        for(ASI_TH_CRM_PaymentRequestLineItem__c lstInvoice : listUpdatePRLineItem){
            if(setInvoiceNo.contains(lstInvoice.ASI_TH_CRM_Invoice_No__c)!=null){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Line Items with duplicated Invoice No. found.');
                blnIsError = true;
            }else{
                setInvoiceNo.add(lstInvoice.ASI_TH_CRM_Invoice_No__c);
            }
    
        }*/
        
        try {
            if (!blnIsError){
                update listUpdatePRLineItem;
                update listUpdatePR;
                
                runSearch();
                
                if(listUpdatePRLineItem!=null && listUpdatePRLineItem.size()>0 &&
                   listUpdatePR != null && listUpdatePR.size() > 0){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Record(s) updated successfully'));
    
                Integer verifyCount =0;
                for(ASI_TH_CRM_PaymentRequestLineItem__c verify :listUpdatePRLineItem){
                    if(verify.ASI_CRM_Finance_Verify__c==true) 
                        verifyCount++;
                }
                if(verifyCount > 0) 
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, verifyCount + ' Record(s) verified'));
                }
            }else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please check the error below.'));
            }
        }
        catch(System.DmlException e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ''+e.getDmlMessage(0)));
        }
        catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Update Failed. '+e.getMessage()));
        }
        
      /*boolean IsSame=true;
        set<String> Invoice=New set <String>();  //Store Invoice Number
        //Kevani
        for(Integer countn= 0; countn< lineItem.size(); countn++){
            for(Integer countm=countn;countm<lineItem.size();countm++){ //Same invoice number should have same Withholding Tax Code and Tax.  ASI_MFM_Payee__c
                if(lineItem[countn].ASI_TH_CRM_Invoice_No__c==lineItem[countm].ASI_TH_CRM_Invoice_No__c){ 
                    if(lineItem[countn].ASI_CRM_Invoice_Due_Date__c!=lineItem[countm].ASI_CRM_Invoice_Due_Date__c || lineItem[countn].ASI_CRM_SG_Invoice_Date__c!=lineItem[countm].ASI_CRM_SG_Invoice_Date__c || lineItem[countn].ASI_CRM_GL_Date__c!=lineItem[countm].ASI_CRM_GL_Date__c || lineItem[countn].ASI_CRM_Tax_Type__c!=lineItem[countm].ASI_CRM_Tax_Type__c || lineItem[countn].ASI_CRM_Withholding_Tax__c!=lineItem[countm].ASI_CRM_Withholding_Tax__c){
                        IsSame=false;  // difference exist
                        Invoice.add(lineItem[countn].ASI_TH_CRM_Invoice_No__c);
                    }
                }
            }
            
        }
        if(IsSame==true){ //Same
            Integer count = 0;
            Set<String> verLines = new Set<String>();
            List<ASI_TH_CRM_PaymentRequestLineItem__c> updateList = new List<ASI_TH_CRM_PaymentRequestLineItem__c>();
            
            for (ASI_TH_CRM_PaymentRequestLineItem__c ver : lineItem)
            {
                if (ver.ASI_CRM_Finance_Verify__c == true ) {
                    count++;
                    verLines.add(ver.ASI_TH_CRM_Payment_Request__r.name);
                }
                if(ver.ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Status__c == 'Final'){
                    updateList.add(ver);
                }
            }
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, count + ' Payment Line verified. Payment No. ' + verLines));
            update updateList;
            runQuery();
        }else{ 
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Save Error: Invoice Number: '+Invoice+ '. Same invoice number should have same Withholding Tax Code,Invoice Date,G/L Date,Invoice Due Date and Tax.'));
        }*/
        
    }
    ///////////////////////////  Finshed save FVerify 
    
    ///////payment request class
    public class paymentRequest{    
        Public ASI_TH_CRM_PaymentRequestLineItem__c payReqItem {get;set;}
        
        public boolean editable {get;set;}
        public boolean editverify {get;set;}
        public boolean firstPRitm {get;set;}
        
        //Error Msg
        public string strErrMsgInvoiceDueDate {get;set;}
        public string strErrMsgGlDate {get;set;}
        public string strErrMsgInvoiceDate {get;set;}
        public string strErrMsgInvoiceNo {get;set;}
        public string strErrMsgCoa {get;set;}
        public string strErrMsgSubBrand {get;set;}    
    }
    ////////End of payment request class
    
    
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
    
    public void gotopage() {
        this.currentPageNum=this.newPageNum;
        implChangePage(this.currentPageNum);
        this.LimitFrom=(this.currentPageNum - 1 ) * +this.numOfRowInTable;
        runQuery();
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
    
    public Integer maxPageNum { get { return maxNumOfPage(); } private set; }
    public Integer currentPageNum { get; protected set { currentPageNum = value; newPageNum = value; } }
    public Integer newPageNum { get; set; }
 

}