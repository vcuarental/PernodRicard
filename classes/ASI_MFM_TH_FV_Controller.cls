public with sharing class ASI_MFM_TH_FV_Controller {
    protected Integer totalNumOfRecord;
    public Integer numOfRowInTable;
    public Integer LimitFrom;
    private String soql {get;set;}
    /*
    public String Status;
    public String PO_Number;
    public String PO_Line_Number;
    public String Payment_Num;
    public String Payment_Line_Num;
    public String Suppliers;
    public String A_C_Code;
    public String DueDates;
    public String DueDateEnds;*/
    public String eid {get;set;}
    public String rid {get;set;}
    public String pid {get;set;}
    //Search
    public String Statu {get;set;} 
    public String RegionSearch {get;set;} 
    public String PO_Num {get;set;}
    public String PO_Line_Num {get;set;}
    public String Py_Num{get;set;}
    public String Py_Line_Num{get;set;}
    public String Suppl{get;set;}
    public String CustomerNo{get;set;}
    public String Subbrand {get;set;}
    
    public String AC_Code{get;set;}
    public String TAX_ID{get;set;}
   // public String Due_Date{get;set;}
    //public String Due_Date_End {get;set;}
    
    public ASI_MFM_PO_Line_Item__c due_fromDate { get; set; }
    public ASI_MFM_PO_Line_Item__c due_toDate { get; set; }
    
    
    
    public transient List<ASI_MFM_Payment_Line_Item__c> TotalLineItem{get;set;}
    public List<ASI_MFM_Payment_Line_Item__c> lineItem{get;set;}
    List<ASI_MFM_Payment__c> payment =new List<ASI_MFM_Payment__c>();
    List<ASI_MFM_PO_Line_Item__c> poline =new List<ASI_MFM_PO_Line_Item__c>();
    List<ASI_MFM_PO_Line_Item__c> polineupdate =new List<ASI_MFM_PO_Line_Item__c>();
    
    List<ASI_MFM_Payment__c> paymentupdate =new List<ASI_MFM_Payment__c>();
    List <Report> reportList=new List<Report>();
    
    public void init() {
        available_Region= new list<selectOption>();
        available_Region=getRegion();
        
        //ASI_MFM_ETL__c ==null AND 
        soql='select id, name,ASI_MFM_PO_Line_Item__r.ASI_MFM_Customer_Name__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_TH_Region__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__c,ASI_MFM_Complete_POL__c,ASI_MFM_Payee__r.ASI_KOR_Venue_Business_License_Number__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_Remaining_Balance__c,ASI_MFM_A_C_Code__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_A_C_Code__c,ASI_MFM_Comments__c,ASI_MFM_Status__c,ASI_MFM_Invoice_Due_Date__c,ASI_MFM_G_L_Date__c ,ASI_MFM_Payment_Term__c,ASI_MFM_Invoice_Date__c,ASI_MFM_Payment_Line_Item_Finance_Verify__c,ASI_MFM_Payment__r.ASI_MFM_G_L_Date__c,ASI_MFM_Payment__r.name, ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c, ASI_MFM_PO_Line_Item__c, ASI_MFM_Payment__c, ASI_MFM_Payee__c, ASI_MFM_Currency__c , ASI_MFM_PO_Line_Remaining_Amount__c, ASI_MFM_Payment_Amount__c, ASI_MFM_Invoice_Number__c, ASI_MFM_Due_Date__c, ASI_MFM_Payment__r.ASI_MFM_Status__c, ASI_MFM_TH_Tax_Type__c,ASI_MFM_Payment_List_Item_Description__c, ASI_MFM_Withholding_Tax__c, ASI_MFM_Withholding_Tax_Amount__c from ASI_MFM_Payment_Line_Item__c where (ASI_MFM_Invoice_Due_Date__c >= TODAY OR ASI_MFM_Invoice_Due_Date__c = NULL) AND ASI_MFM_Payment__r.ASI_MFM_Status__c!=\'Draft\' AND ASI_MFM_Voucher_Created__c=false AND ASI_MFM_Payment__r.RecordType.DeveloperName LIKE \'ASI_MFM_TH_Payment%\' ';
        this.numOfRowInTable = 50;
        this.currentPageNum = 1;
        this.LimitFrom = 0;
        
        reportList =[Select ID from Report where DeveloperName = 'ASI_MFM_TH_Finance_Verify_Report'];
        if (reportList.size()>0){
            rid= (String)reportList.get(0).get('Id');
        }
        
        reportList =[Select ID from Report where DeveloperName = 'ASI_MFM_TH_ETL_Report'];
        if (reportList.size()>0){
            eid= (String)reportList.get(0).get('Id');
        }
        
        //Get payment report   
        reportList =[Select ID from Report where DeveloperName = 'ASI_MFM_TH_Payment_Report'];
        if (reportList.size()>0){
            pid= (String)reportList.get(0).get('Id');
        }        
        Statu=null;
        PO_Num=null;
        PO_Line_Num=null;
        Py_Num=null;
        Py_Line_Num=null;
        Suppl=null;
        AC_Code=null;
        TAX_ID=null;
        //Due_Date=null;
        //Due_Date_End=null;
        due_fromDate = new ASI_MFM_PO_Line_Item__c ();
        due_toDate = new ASI_MFM_PO_Line_Item__c ();
        
        /*
        for (ASI_MFM_Default_Value__c Setting : ASI_MFM_Default_Value__c.getAll().values()) {
            if(Setting.name == 'TH_Finance_ETL_Report' && Setting.Country__c == 'TH'){
                    eid = Setting.ASI_MFM_value__c;
            }
            if(Setting.name == 'TH_Finance_Verify_Report' && Setting.Country__c == 'TH'){
                    rid = Setting.ASI_MFM_value__c;
            }
        }*/
        runQuery();
    }
    public list<selectOption> available_Region {get; private set;}
    
    //add 20160404 
    public List<SelectOption> getRegion(){
        List<SelectOption> Regionoptions = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = ASI_MFM_PO_Line_Item__c.ASI_MFM_TH_Region__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        Regionoptions.add(new SelectOption('','--None--'));
        for( Schema.PicklistEntry f : ple)
        {
            Regionoptions.add(new SelectOption(f.getLabel(), f.getValue()));
        }
        return Regionoptions;
    }
    
    
    public ASI_MFM_TH_FV_Controller(ApexPages.StandardController controller){
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
        //get  { if (sortField == null) {sortField = 'ASI_MFM_Payment__r.name'; } return sortField;  }     ASI_MFM_Due_Date__c
        get  { if (sortField == null) {sortField = 'ASI_MFM_Invoice_Due_Date__c'; } return sortField;  }
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
            for(ASI_MFM_Payment_Line_Item__c pai: lineItem){
                pai.ASI_MFM_G_L_Date__c=pai.ASI_MFM_Payment__r.ASI_MFM_G_L_Date__c;
                pai.ASI_MFM_Status__c=pai.ASI_MFM_Payment__r.ASI_MFM_Status__c;
                pai.ASI_MFM_A_C_Code__c=pai.ASI_MFM_PO_Line_Item__r.ASI_MFM_A_C_Code__c;
            }
            system.debug(lineItem);
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No Records Found, Please Check your search input' + e));
            //System.debug('Fail123');
        }
    }
    
    //search function
    public PageReference runSearch() {
        /*
        PO_Number = Apexpages.currentPage().getParameters().get('PO_Number');
        PO_Line_Number = Apexpages.currentPage().getParameters().get('PO_Line_Number');
        Payment_Num = Apexpages.currentPage().getParameters().get('Payment_Num');
        Payment_Line_Num = Apexpages.currentPage().getParameters().get('Payment_Line_Num');
        Suppliers = Apexpages.currentPage().getParameters().get('Suppliers');
        A_C_Code = Apexpages.currentPage().getParameters().get('A_C_Code');
        DueDates = Apexpages.currentPage().getParameters().get('DueDates');
        DueDateEnds  = Apexpages.currentPage().getParameters().get('DueDateEnds');
        Status = Apexpages.currentPage().getParameters().get('Status');
        */
        String[] str;
        Datetime searchDate;
        //soql='select id, name, ASI_MFM_Complete_POL__c,ASI_MFM_Payment_Line_Item_Finance_Verify__c, ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c, ASI_MFM_PO_Line_Item__c, ASI_MFM_Payment__c, ASI_MFM_Payee__c, ASI_MFM_Currency__c , ASI_MFM_PO_Line_Remaining_Amount__c, ASI_MFM_Payment_Amount__c, ASI_MFM_Invoice_Number__c, ASI_MFM_Due_Date__c, ASI_MFM_Payment__r.ASI_MFM_Status__c, ASI_MFM_TH_Tax_Type__c,ASI_MFM_Payment_List_Item_Description__c from ASI_MFM_PO_Line_Item__c where ASI_MFM_PO__r.ASI_MFM_Status__c = \'Final\' AND ASI_MFM_PO__r.RecordType.DeveloperName =\'ASI_MFM_TH_PO\' ';
        soql='select id,ASI_MFM_PO_Line_Item__r.ASI_MFM_Customer_Name__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_TH_Region__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__c,ASI_MFM_Payee__r.ASI_KOR_Venue_Business_License_Number__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_Remaining_Balance__c, ASI_MFM_A_C_Code__c,name,ASI_MFM_Payment_Term__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_A_C_Code__c,ASI_MFM_Comments__c,ASI_MFM_Status__c,ASI_MFM_Invoice_Due_Date__c,ASI_MFM_G_L_Date__c ,ASI_MFM_Payment__r.name,ASI_MFM_Invoice_Date__c, ASI_MFM_PO_Line_Item__r.name,ASI_MFM_Payment__r.ASI_MFM_G_L_Date__c,ASI_MFM_Payment_Line_Item_Finance_Verify__c, ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c, ASI_MFM_PO_Line_Item__c, ASI_MFM_Payment__c, ASI_MFM_Payee__c, ASI_MFM_Currency__c , ASI_MFM_PO_Line_Remaining_Amount__c, ASI_MFM_Payment_Amount__c, ASI_MFM_Invoice_Number__c, ASI_MFM_Due_Date__c, ASI_MFM_Payment__r.ASI_MFM_Status__c, ASI_MFM_TH_Tax_Type__c,ASI_MFM_Payment_List_Item_Description__c, ASI_MFM_Withholding_Tax__c, ASI_MFM_Withholding_Tax_Amount__c  from ASI_MFM_Payment_Line_Item__c where ASI_MFM_Voucher_Created__c=false AND ASI_MFM_Payment__r.ASI_MFM_Status__c!=\'Draft\' AND ASI_MFM_Payment__r.RecordType.DeveloperName LIKE \'ASI_MFM_TH_Payment%\' ';
        
        
        
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
        if(Suppl!=null && Suppl.length()>0){
            soql += ' and ASI_MFM_PO__r.ASI_MFM_Supplier_Name__r.name LIKE \''+String.escapeSingleQuotes(Suppl)+'%\'';
        }
        if(TAX_ID!=null && TAX_ID.length()>0){
            soql += ' and ASI_MFM_Payee__r.ASI_KOR_Venue_Business_License_Number__c LIKE \''+String.escapeSingleQuotes(TAX_ID)+'%\'';
        }
        
        if(Subbrand!=null && Subbrand.length()>0){
              soql += ' and ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.Name LIKE \''+String.escapeSingleQuotes(Subbrand)+'%\'';
        }
        
        if(CustomerNo!=null && CustomerNo.length()>0){
              soql += ' and ASI_MFM_PO_Line_Item__r.ASI_MFM_Customer_Name__r.name  LIKE \''+String.escapeSingleQuotes(CustomerNo)+'%\'';
        }
        
        if(RegionSearch!=null && RegionSearch.length()>0){
              soql += ' and ASI_MFM_PO_Line_Item__r.ASI_MFM_TH_Region__c LIKE \''+String.escapeSingleQuotes(RegionSearch)+'%\'';
        }
        
        if(AC_Code!=null && AC_Code.length()>0){
            soql += ' and ASI_MFM_PO_Line_Item__r.ASI_MFM_A_C_Code__r.name LIKE \''+String.escapeSingleQuotes(AC_Code)+'%\'';
        }
        if (due_fromDate.ASI_MFM_G_L_Date__c != null) {
            String fromDate = DateTime.newInstance(due_fromDate.ASI_MFM_G_L_Date__c.year(),due_fromDate.ASI_MFM_G_L_Date__c.month(),due_fromDate.ASI_MFM_G_L_Date__c.day(), 0,0,0).format('yyyy-MM-dd');
            soql += ' AND ASI_MFM_Invoice_Due_Date__c  >= ' + fromDate + ''; 
        }
        if (due_toDate.ASI_MFM_G_L_Date__c != null) {
            String toDate = DateTime.newInstance(due_toDate.ASI_MFM_G_L_Date__c.year(),due_toDate.ASI_MFM_G_L_Date__c.month(),due_toDate.ASI_MFM_G_L_Date__c.day(), 0,0,0).format('yyyy-MM-dd');
            soql += ' AND ASI_MFM_Invoice_Due_Date__c    <= ' + toDate + ''; 
        }
        if(due_fromDate.ASI_MFM_G_L_Date__c==null && due_toDate.ASI_MFM_G_L_Date__c==null){
            soql += ' AND (ASI_MFM_Invoice_Due_Date__c >= TODAY OR ASI_MFM_Invoice_Due_Date__c = NULL)  ';
        }
        /*
        if (!Status.equals('')){
            soql += ' and ASI_MFM_Payment__r.ASI_MFM_Status__c LIKE \''+String.escapeSingleQuotes(Status)+'%\'';  
        }
        if (!PO_Number.equals(''))
            soql += ' and ASI_MFM_PO__r.name LIKE \''+String.escapeSingleQuotes(PO_Number)+'%\'';
        
        if (!PO_Line_Number.equals(''))
            soql += ' and ASI_MFM_PO_Line_Item__r.name LIKE \''+String.escapeSingleQuotes(PO_Line_Number)+'%\''; //ASI_MFM_PO_Line_Item__c    Name
        
        if (!Payment_Num.equals(''))
            soql += ' and ASI_MFM_Payment__r.name LIKE \''+String.escapeSingleQuotes(Payment_Num)+'%\'';
        
        if (!Payment_Line_Num.equals(''))
            soql += ' and Name LIKE \''+String.escapeSingleQuotes(Payment_Line_Num)+'%\'';
        
        if (!Suppliers.equals(''))
            soql += ' and ASI_MFM_PO__r.ASI_MFM_Supplier_Name__r.name LIKE \''+String.escapeSingleQuotes(Suppliers)+'%\'';
        
        if (!A_C_Code.equals(''))
            soql += ' and ASI_MFM_PO_Line_Item__r.ASI_MFM_A_C_Code__r.name LIKE \''+String.escapeSingleQuotes(A_C_Code)+'%\'';
            
        if (!DueDates.equals('')) {
            //DueDates
            str = DueDates.split('-');
            searchDate = Datetime.newInstance(Integer.valueOf(str[0]),Integer.valueOf(str[1]),Integer.valueOf(str[2]),0,0,0);
            soql += ' and ASI_MFM_Due_Date__c >= ' +searchDate.format('yyyy-MM-dd');
        }
        
        if (!DueDateEnds.equals('')) {
            //DueDateEnds
            str = DueDateEnds.split('-');
            searchDate = Datetime.newInstance(Integer.valueOf(str[0]),Integer.valueOf(str[1]),Integer.valueOf(str[2]),0,0,0);
            soql += ' and ASI_MFM_Due_Date__c <= ' +searchDate.format('yyyy-MM-dd');
        }
        
        if (DueDateEnds.equals('') && DueDates.equals('')){
            soql += ' AND (ASI_MFM_Due_Date__c >= TODAY OR ASI_MFM_Due_Date__c = NULL)  ';
        }
        
        */
        
        
        this.currentPageNum = 1;
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
    
        //Payment
        set<id> pay_set = new set<id>();
        set<id> pa_set = new set<id>();
        set<id> paSat_set = new set<id>();
        for(ASI_MFM_Payment_Line_Item__c pli:lineItem){
            pay_set.add(pli.ASI_MFM_Payment__c); // Get Payment Id
        }
        payment=[select id,ASI_MFM_G_L_Date__c,ASI_MFM_Status__c,name from ASI_MFM_Payment__c where id in:pay_set];
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
                if(pa.id==pli.ASI_MFM_Payment__c && changestat==true && pa.ASI_MFM_Status__c!=pli.ASI_MFM_Status__c){
                    pa.ASI_MFM_Status__c=pli.ASI_MFM_Status__c;
                    AddPy=true;
                    paSat_set.add(pa.id);
                    changestat=false;
                }
            }
            if(AddPy==true){
                    paymentupdate.add(pa);
                }
            
        }
        
        update paymentupdate;  // Update Payment
        for(ASI_MFM_Payment_Line_Item__c pli:lineItem){
            if(paSat_set.contains(pli.ASI_MFM_Payment__c)){
                pli.ASI_MFM_Payment_Line_Item_Finance_Verify__c=false;
            }
        }
        
        
        boolean IsSame=true;
        set<String> Invoice=New set <String>();  //Store Invoice Number
        for(Integer countn= 0; countn< lineItem.size(); countn++){
            for(Integer countm=countn;countm<lineItem.size();countm++){ //Same invoice number should have same Withholding Tax Code and Tax.  ASI_MFM_Payee__c
                if(lineItem[countn].ASI_MFM_Invoice_Number__c==lineItem[countm].ASI_MFM_Invoice_Number__c && lineItem[countn].ASI_MFM_Payee__c==lineItem[countm].ASI_MFM_Payee__c){ 
                    if(lineItem[countn].ASI_MFM_Invoice_Due_Date__c!=lineItem[countm].ASI_MFM_Invoice_Due_Date__c || lineItem[countn].ASI_MFM_Invoice_Date__c!=lineItem[countm].ASI_MFM_Invoice_Date__c || lineItem[countn].ASI_MFM_G_L_Date__c!=lineItem[countm].ASI_MFM_G_L_Date__c || lineItem[countn].ASI_MFM_TH_Tax_Type__c!=lineItem[countm].ASI_MFM_TH_Tax_Type__c || lineItem[countn].ASI_MFM_Withholding_Tax__c!=lineItem[countm].ASI_MFM_Withholding_Tax__c){
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
            update updateList;
            runQuery();
        }else{ //runQuery();
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Save Error: Invoice Number: '+Invoice+ '. Same invoice number should have same Withholding Tax Code,Invoice Date,G/L Date,Invoice Due Date and Tax.'));
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