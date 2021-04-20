public with sharing class ASI_MFM_SG_FV_Controller {
    protected Integer totalNumOfRecord;
    public Integer numOfRowInTable;
    public Integer LimitFrom;
    private String soql {get;set;}
    //Search
    public transient String Statu {get;set;}
    public transient String PO_Num {get;set;}
    public transient String PO_Line_Num {get;set;}
    public transient String Py_Num{get;set;}
    public transient String Py_Line_Num{get;set;}
    public transient String Dept {get;set;}
    public transient String Suppl{get;set;}
    public transient String AC_Code {get;set;}
    public transient String GL_Date{get;set;}
    public transient String GL_Date_End {get;set;}
    public transient String eid {get;set;}
    public transient String rid {get;set;}
    public transient String pid {get;set;}    
    public transient String Bid {get;set;}
    public ASI_MFM_PO_Line_Item__c gl_fromDate { get; set; }
    public ASI_MFM_PO_Line_Item__c gl_toDate { get; set; }
    
    public transient List<ASI_MFM_Payment_Line_Item__c> TotalLineItem{get;set;}
    public List<ASI_MFM_Payment_Line_Item__c> lineItem{get;set;}
    List<ASI_MFM_Payment__c> payment =new List<ASI_MFM_Payment__c>();
    List<ASI_MFM_PO_Line_Item__c> poline =new List<ASI_MFM_PO_Line_Item__c>();
    List<ASI_MFM_PO_Line_Item__c> polineupdate =new List<ASI_MFM_PO_Line_Item__c>();
    
    List<ASI_MFM_Payment__c> paymentupdate =new List<ASI_MFM_Payment__c>();
    List <Report> reportList=new List<Report>();
    List <Folder> reportLists = new List<Folder>();
    
    //Introv 20170306
	public Map<id,list<Attachment>> attachmentMap {get;set;}
    
    public void init() {
        // Modified by 2017-12-05 Linus@introv // Add KH record type
        soql='select id, name,ASI_MFM_Payment__r.ASI_MFM_GST__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_Remaining_Balance__c,ASI_MFM_Payment__r.ASI_MFM_Prefix__r.ASI_MFM_Location__c,ASI_MFM_Payment__r.ASI_MFM_Prefix__c,ASI_MFM_Payment__r.ASI_MFM_Prefix__r.ASI_MFM_Department__c,ASI_MFM_GST_Amount__c,ASI_MFM_Invoice_Total__c,ASI_MFM_A_C_Code__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_A_C_Code__c,ASI_MFM_Comments__c,ASI_MFM_Status__c,ASI_MFM_Invoice_Due_Date__c,ASI_MFM_G_L_Date__c ,ASI_MFM_Payment_Term__c,ASI_MFM_Invoice_Date__c,ASI_MFM_Payment_Line_Item_Finance_Verify__c,ASI_MFM_Payment__r.ASI_MFM_G_L_Date__c,ASI_MFM_Payment__r.name, ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c, ASI_MFM_PO_Line_Item__c, ASI_MFM_Payment__c, ASI_MFM_Payee__c, ASI_MFM_Currency__c , ASI_MFM_PO_Line_Remaining_Amount__c, ASI_MFM_Payment_Amount__c, ASI_MFM_Invoice_Number__c, ASI_MFM_Due_Date__c, ASI_MFM_Payment__r.ASI_MFM_Status__c, ASI_MFM_TH_Tax_Type__c,ASI_MFM_Payment_List_Item_Description__c, ASI_MFM_Withholding_Tax__c, ASI_MFM_Withholding_Tax_Amount__c from ASI_MFM_Payment_Line_Item__c where ASI_MFM_Payment__r.ASI_MFM_Status__c!=\'Draft\' AND ASI_MFM_Voucher_Created__c=false AND ASI_MFM_Payment_Line_Item_Finance_Verify__c=false  AND (ASI_MFM_Payment__r.RecordType.DeveloperName LIKE \'ASI_MFM_SG_Payment%\' or ASI_MFM_Payment__r.RecordType.DeveloperName LIKE \'ASI_MFM_KH_Payment%\') ';
        this.numOfRowInTable = 30;
        this.currentPageNum = 1;
        this.LimitFrom = 0;
        
        Statu=null;
        PO_Num=null;
        PO_Line_Num=null;
        Py_Num=null;
        Py_Line_Num=null;
        Dept=null;
        Suppl=null;
        AC_Code=null;
        GL_Date=null;
        GL_Date_End=null;
        gl_fromDate = new ASI_MFM_PO_Line_Item__c ();
        gl_toDate = new ASI_MFM_PO_Line_Item__c ();
		attachmentMap = new Map<id, list<Attachment>>(); 
        
        reportList =[Select ID from Report where DeveloperName = 'ASI_MFM_SG_Finance_Verified_Report'];
        if (reportList.size()>0){
            rid= (String)reportList.get(0).get('Id');
        }
        reportList =[Select ID from Report where DeveloperName = 'ASI_MFM_SG_ETL_Report'];
        if (reportList.size()>0){
            eid= (String)reportList.get(0).get('Id');
        }
        
        //Get payment report   
        reportList =[Select ID from Report where DeveloperName = 'ASI_MFM_SG_Payment_Report'];
        if (reportList.size()>0){
            pid= (String)reportList.get(0).get('Id');
        }
        
        reportLists =[SELECT Id FROM Folder WHERE Name = 'ASI SG MFM Report' And Type = 'Report'];
        if (reportLists.size()>0){
            Bid= (String)reportLists.get(0).get('Id');
        }
        runQuery();
    }
    public ASI_MFM_SG_FV_Controller(ApexPages.StandardController controller){
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
    //  Due Date  : ASI_MFM_Due_Date__c
    public String sortField {
        get  { if (sortField == null) {sortField = 'ASI_MFM_Payment__r.name'; } return sortField;  }
        //get  { if (sortField == null) {sortField = 'ASI_MFM_Due_Date__c'; } return sortField;  }
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
        try {
            TotalLineItem = Database.query(soql + ' order by ' + sortField + ' ' + sortDir);
            this.totalNumOfRecord = TotalLineItem.size();
            lineItem = Database.query(soql + ' order by ' + sortField + ' ' + sortDir + ' Limit ' + this.numOfRowInTable + ' OFFSET ' + LimitFrom);
            list<id> paymentIdList = new list<id>();
            for(ASI_MFM_Payment_Line_Item__c pai: lineItem){
                pai.ASI_MFM_G_L_Date__c=pai.ASI_MFM_Payment__r.ASI_MFM_G_L_Date__c;
                //pai.ASI_MFM_Status__c=pai.ASI_MFM_Payment__r.ASI_MFM_Status__c;
                pai.ASI_MFM_A_C_Code__c=pai.ASI_MFM_PO_Line_Item__r.ASI_MFM_A_C_Code__c;
                
                //introv 20180306
                if(pai.ASI_MFM_Payment__c!=null && !paymentIdList.contains(pai.ASI_MFM_Payment__c)){
                	paymentIdList.add(pai.ASI_MFM_Payment__c);
                }
            }
            
            //introv 20180306
            attachmentMap.clear();
            if(paymentIdList.size()>0){
				list<Attachment> attachments = [select Id, ParentId, Name, Description, LastModifiedDate from Attachment where ParentId in:paymentIdList order by Name];
                for(Attachment att: attachments){
            		system.debug('att : ' + att);
                    if(!attachmentMap.containsKey(att.ParentId)){
                        list<Attachment> attachmentList = new list<Attachment>(); 
                        attachmentList.add(att);
                        attachmentMap.put(att.ParentId, attachmentList);
                    }else{
                        list<Attachment> attachmentList = attachmentMap.get(att.ParentId);
                        attachmentList.add(att);
                        attachmentMap.put(att.ParentId, attachmentList);
                    }
            	}
            }
            for(ASI_MFM_Payment_Line_Item__c pai: lineItem){
                if(pai.ASI_MFM_Payment__c!=null && !paymentIdList.contains(pai.ASI_MFM_Payment__c)){
					attachmentMap.put(pai.ASI_MFM_Payment__c, new list<Attachment>());
                }
            }
            system.debug('attachmentMap : ' + attachmentMap);            
            system.debug(lineItem);
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No Records Found, Please Check your search input' + e));
            //System.debug('Fail123');
        }
    }
    

    
    //search function
    public PageReference runSearch() {
        String[] str;
        Datetime searchDate;
        soql='select id,ASI_MFM_Payment__r.ASI_MFM_GST__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_Remaining_Balance__c,ASI_MFM_Payment__r.ASI_MFM_Prefix__r.ASI_MFM_Location__c,ASI_MFM_Payment__r.ASI_MFM_Prefix__c,ASI_MFM_Payment__r.ASI_MFM_Prefix__r.ASI_MFM_Department__c, ASI_MFM_GST_Amount__c,ASI_MFM_Invoice_Total__c,ASI_MFM_A_C_Code__c,name,ASI_MFM_Payment_Term__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_A_C_Code__c,ASI_MFM_Comments__c,ASI_MFM_Status__c,ASI_MFM_Invoice_Due_Date__c,ASI_MFM_G_L_Date__c ,ASI_MFM_Payment__r.name,ASI_MFM_Invoice_Date__c, ASI_MFM_PO_Line_Item__r.name,ASI_MFM_Payment__r.ASI_MFM_G_L_Date__c,ASI_MFM_Payment_Line_Item_Finance_Verify__c, ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c, ASI_MFM_PO_Line_Item__c, ASI_MFM_Payment__c, ASI_MFM_Payee__c, ASI_MFM_Currency__c , ASI_MFM_PO_Line_Remaining_Amount__c, ASI_MFM_Payment_Amount__c, ASI_MFM_Invoice_Number__c, ASI_MFM_Due_Date__c, ASI_MFM_Payment__r.ASI_MFM_Status__c, ASI_MFM_TH_Tax_Type__c,ASI_MFM_Payment_List_Item_Description__c, ASI_MFM_Withholding_Tax__c, ASI_MFM_Withholding_Tax_Amount__c  from ASI_MFM_Payment_Line_Item__c where ASI_MFM_Payment__r.ASI_MFM_Status__c!=\'Draft\' AND ASI_MFM_Voucher_Created__c=false AND ASI_MFM_Payment_Line_Item_Finance_Verify__c=false  AND ASI_MFM_Payment__r.RecordType.DeveloperName LIKE \'ASI_MFM_SG_Payment%\' ';
        String location;
        Boolean dateflag1=false;
        Boolean dateflag2=false;
        //Search commandButton
        if(Statu!=null && Statu.length()>0){
           soql += ' and ASI_MFM_Payment__r.ASI_MFM_Status__c LIKE \''+String.escapeSingleQuotes(Statu)+'%\'';
        }
        if(PO_Num!=null && PO_Num.length()>0){
                soql += ' and ASI_MFM_PO__r.name LIKE \''+String.escapeSingleQuotes(PO_Num)+'%\''; 
        }
        if(PO_Line_Num!=null && PO_Line_Num.length()>0){
            soql += ' and ASI_MFM_PO_Line_Item__r.name LIKE \''+String.escapeSingleQuotes(PO_Line_Num)+'%\'';
        }
        if(Py_Num!=null && Py_Num.length()>0){
            soql += ' and ASI_MFM_Payment__r.name LIKE \''+String.escapeSingleQuotes(Py_Num)+'%\'';
        }
        if(Py_Line_Num!=null && Py_Line_Num.length()>0){
            soql += ' and Name LIKE \''+String.escapeSingleQuotes(Py_Line_Num)+'%\'';
        }
        if(Dept!=null && Dept.length()>0){
            if(Dept.contains('SG')){
                location='Singapore';
                soql += ' and ASI_MFM_Payment__r.ASI_MFM_Prefix__r.ASI_MFM_Location__c = \'' +location+'\''+ 'and ASI_MFM_Payment__r.ASI_MFM_Prefix__r.ASI_MFM_Department__c LIKE \'%' +Dept.substring(3,8)+'%\'';
            }
            if(Dept.contains('CA')){
                location='Cambodia';
                soql += ' and ASI_MFM_Payment__r.ASI_MFM_Prefix__r.ASI_MFM_Location__c = \'' +location+'\''+ 'and ASI_MFM_Payment__r.ASI_MFM_Prefix__r.ASI_MFM_Department__c LIKE \'%' +Dept.substring(3,8)+'%\'';
            }
            if(Dept.contains('LA')){
                location='Laos';
                soql += ' and ASI_MFM_Payment__r.ASI_MFM_Prefix__r.ASI_MFM_Location__c = \'' +location+'\'';
            }
            if(Dept.contains('MM')){
                location='Myanmar';
                soql += ' and ASI_MFM_Payment__r.ASI_MFM_Prefix__r.ASI_MFM_Location__c = \'' +location+'\'';
            }
            
        }
        
        if(Suppl!=null && Suppl.length()>0){
            soql += ' and ASI_MFM_PO__r.ASI_MFM_Supplier_Name__r.name LIKE \''+String.escapeSingleQuotes(Suppl)+'%\'';
        }
        if(AC_Code!=null && AC_Code.length()>0){
            soql += ' and ASI_MFM_PO_Line_Item__r.ASI_MFM_A_C_Code__r.name LIKE \''+String.escapeSingleQuotes(AC_Code)+'%\'';
        }      
        if (gl_fromDate.ASI_MFM_G_L_Date__c != null) {
            String fromDate = DateTime.newInstance(gl_fromDate.ASI_MFM_G_L_Date__c.year(),gl_fromDate.ASI_MFM_G_L_Date__c.month(),gl_fromDate.ASI_MFM_G_L_Date__c.day(), 0,0,0).format('yyyy-MM-dd');
            soql += ' AND ASI_MFM_G_L_Date__c  >= ' + fromDate + ''; 
        }
        if (gl_toDate.ASI_MFM_G_L_Date__c != null) {
            String toDate = DateTime.newInstance(gl_toDate.ASI_MFM_G_L_Date__c.year(),gl_toDate.ASI_MFM_G_L_Date__c.month(),gl_toDate.ASI_MFM_G_L_Date__c.day(), 0,0,0).format('yyyy-MM-dd');
            soql += ' AND ASI_MFM_G_L_Date__c    <= ' + toDate + ''; 
        }
        /*
        if(GL_Date_End!=null){
            str = GL_Date_End.split('/');
            if(str.size()>1){
                searchDate = Datetime.newInstance(Integer.valueOf(str[2]),Integer.valueOf(str[0]),Integer.valueOf(str[1]));
                soql += ' and ASI_MFM_Payment__r.ASI_MFM_G_L_Date__c <= ' +searchDate.format('yyyy-MM-dd');
            }else{
                dateflag2=true;
            }
        }
        */
        
        runQuery();
        return null;
        }
    
    
    // /////////////////////////save FVerify 
    public void save(){//system.debug('SeelineItem'+lineItem);
        //poline   ASI_MFM_PO_Line_Item__c
        set<id> po_set = new set<id>();
        for(ASI_MFM_Payment_Line_Item__c pli:lineItem){
            po_set.add(pli.ASI_MFM_PO_Line_Item__c); // Get Payment Id
        }
        poline=[select id,name,ASI_MFM_A_C_Code__c from ASI_MFM_PO_Line_Item__c where id in: po_set];
        for(ASI_MFM_PO_Line_Item__c poli:poline){
            Boolean changestat = true;
            for(ASI_MFM_Payment_Line_Item__c pli:lineItem){
                if(pli.ASI_MFM_PO_Line_Item__c==poli.id && pli.ASI_MFM_A_C_Code__c!=poli.ASI_MFM_A_C_Code__c && changestat == true){
                    poli.ASI_MFM_A_C_Code__c=pli.ASI_MFM_A_C_Code__c;
                    polineupdate.add(poli);
                    changestat=false;    
                }
            }
        }
        
        update polineupdate;
        polineupdate.clear();
    
        //Payment
        set<id> pay_set = new set<id>();
        set<id> pa_set = new set<id>();
        set<id> paSat_set = new set<id>();
        for(ASI_MFM_Payment_Line_Item__c pli:lineItem){
            pay_set.add(pli.ASI_MFM_Payment__c); // Get Payment Id
        }
        payment=[select id,ASI_MFM_G_L_Date__c,ASI_MFM_Status__c,name,ASI_MFM_GST__c from ASI_MFM_Payment__c where id in:pay_set];
        for(ASI_MFM_Payment__c pa:payment){
            Boolean changehappen = true;
            Boolean changestat = true;
            Boolean AddPy = False;
            // Change Payment G/L Date 
            for(ASI_MFM_Payment_Line_Item__c pli:lineItem){
                if(pa.id==pli.ASI_MFM_Payment__c  && changehappen == true && pa.ASI_MFM_G_L_Date__c!=pli.ASI_MFM_G_L_Date__c){
                    pa.ASI_MFM_G_L_Date__c=pli.ASI_MFM_G_L_Date__c;
                    AddPy=true;  //paymentupdate.add(pa);
                    changehappen = false;
                }
                //if(pa.id==pli.ASI_MFM_Payment__c && changestat==true && pa.ASI_MFM_Status__c!=pli.ASI_MFM_Status__c){
                //    AddPy=true;
                   // paSat_set.add(pa.id);
                 //   changestat=false;
                //}
            }
            if(AddPy==true){
                    paymentupdate.add(pa);
                }
            
        }
        
        update paymentupdate;  // Update Payment
        paymentupdate.clear();
        
        //for(ASI_MFM_Payment_Line_Item__c pli:lineItem){
        //    if(paSat_set.contains(pli.ASI_MFM_Payment__c)){
         //       pli.ASI_MFM_Payment_Line_Item_Finance_Verify__c=false;
         //   }
        //}
        
        
        boolean IsSame=true;
        set<String> Invoice=New set <String>();  //Store Invoice Number
        for(Integer countn= 0; countn< lineItem.size(); countn++){
            for(Integer countm=countn;countm<lineItem.size();countm++){ //Same invoice number should have same Withholding Tax Code and Tax.  ASI_MFM_Payee__c
                if(lineItem[countn].ASI_MFM_Invoice_Number__c==lineItem[countm].ASI_MFM_Invoice_Number__c && lineItem[countn].ASI_MFM_Payee__c==lineItem[countm].ASI_MFM_Payee__c){ 
                    if(lineItem[countn].ASI_MFM_Invoice_Due_Date__c!=lineItem[countm].ASI_MFM_Invoice_Due_Date__c || lineItem[countn].ASI_MFM_Invoice_Date__c!=lineItem[countm].ASI_MFM_Invoice_Date__c || lineItem[countn].ASI_MFM_G_L_Date__c!=lineItem[countm].ASI_MFM_G_L_Date__c ){
                        IsSame=false;  // difference exist
                        Invoice.add(lineItem[countn].ASI_MFM_Invoice_Number__c);
                    }
                }
            }
            
        }
        
        if(IsSame==true){ //Same
            Integer count = 0;
            Set<String> verLines = new Set<String>();
            List<ASI_MFM_Payment_Line_Item__c> updateList = new List<ASI_MFM_Payment_Line_Item__c>();
            for (ASI_MFM_Payment_Line_Item__c ver : lineItem)
            {
                if (ver.ASI_MFM_Payment_Line_Item_Finance_Verify__c == true ) {
                    count++;
                    verLines.add(ver.ASI_MFM_Payment__r.name);
                }
                if(ver.ASI_MFM_Payment__r.ASI_MFM_Status__c == 'Final'){
                    updateList.add(ver);
                }
            }
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, count + ' Payment Line verified. Payment No. ' + verLines));
            update updateList; //update lineItem;
            lineItem.clear();
            runQuery();
        }else{ //runQuery();
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Save Error: Invoice Number: '+Invoice+ '. Same invoice number should have same Invoice Date,G/L Date,Invoice Due Date.'));
        }
        
    }
    ///////////////////////////  Finshed save FVerify 
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
    
    public Integer maxPageNum { get { return maxNumOfPage(); } private set; }
    public Integer currentPageNum { get; protected set { currentPageNum = value; newPageNum = String.valueOf(value); } }
    public String newPageNum { get; set; }

}