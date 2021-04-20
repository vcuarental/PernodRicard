/*********************************************************************************
 * Name:ASI_MFM_SG_BAverifyController
 * Description: 
 * Test Class: ASI_MFM_SG_Class_Test
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 15/08/2018       Linus                  [LH 1.0] Add a filter to exclude PO with [No Payment Request Required] 
 * 
*********************************************************************************/
public with sharing class ASI_MFM_SG_BAverifyController {
    protected Integer totalNumOfRecord;
    public Integer numOfRowInTable;
    public Integer LimitFrom;
    private String soql {get;set;}
    public String PO_Number;
    public String PO_Line_Number;
    public String Sub_Brand;
    public String Suppliers_Number;
    public String Suppliers;
    public String A_C_Code;
    public String GLdates;
    public String Departments;
    public String Fiscal_Year;
    public String rid {get;set;}
    public String Pid {get;set;}
    
    public transient String Plan_Num {get;set;}
    public transient String PO_Num {get;set;}
    public transient String PO_Line_Num {get;set;}
    public transient String Sub_Brands {get;set;}
    public transient String Suppliers_Num {get;set;}
    public transient String Suppl {get;set;}
    public transient String AC_Code {get;set;}
    public transient String GL_date {get;set;}
    public transient String Dept {get;set;}
    public transient String Fiscal_Years {get;set;} 
    public ASI_MFM_PO_Line_Item__c gl_fromDate { get; set; }
    public ASI_MFM_PO_Line_Item__c gl_toDate { get; set; }
    public ASI_MFM_PO_Line_Item__c postGLDate { get; set; }
    public ASI_MFM_PO__c poStartDate { get; set; }
    
    
    List <Folder> reportList = new List<Folder>();
    
    public void init() {// Limit: G/L Date <= TODAY ;Status='Final' ;( Complete = false  ;PO Amount > 0 ; Remaining Balance > 0 ) OR(Complete= true AND All_Payment_Effective = false AND Adjustment_Line = false)
        system.debug('Start init');
        postGLDate = new ASI_MFM_PO_Line_Item__c (); 
        poStartDate = new ASI_MFM_PO__c (); 
        Date selectedDate =  Date.today(); 
        Date firstDate = selectedDate.toStartOfMonth();
        
        postGLDate.ASI_MFM_Post_G_L_Date__c = firstDate.addDays(date.daysInMonth(selectedDate.year() , selectedDate.month())  - 1);
        poStartDate.ASI_MFM_PO_Start_Date__c = Date.today();
        
        // [LH 1.0] exclude [no Payment Request required]
        soql='select id, name,ASI_MFM_Synced__c,ASI_MFM_ETL_Date__c,ASI_MFM_PO__r.ASI_MFM_Fiscal_Year__c,ASI_MFM_PO__r.ASI_MFM_Prefix__c, ASI_MFM_PO__r.ASI_MFM_PO_Start_Date__c, ASI_MFM_Post_G_L_Date__c, ASI_MFM_PO__r.ASI_MFM_Department__c,ASI_MFM_PO__r.ASI_MFM_Prefix__r.ASI_MFM_Location__c,ASI_MFM_Base_Currency_Amount__c,ASI_MFM_Sub_brand_Code__r.name,ASI_MFM_Sub_brand_Code__c,ASI_MFM_A_C_Code__r.name,ASI_MFM_PO_Supplier_Number__c,ASI_MFM_PO__r.ASI_MFM_Plan__c,ASI_MFM_PO__r.name, ASI_MFM_SG_BA_verify__c,ASI_MFM_PO__c,ASI_MFM_PO__r.ASI_MFM_Supplier_Name__c,ASI_MFM_PO__r.ASI_MFM_PO_Amount__c,ASI_MFM_Amount__c,ASI_MFM_List_Item_Description__c,ASI_MFM_A_C_Code__c,ASI_MFM_Currency__c,ASI_MFM_Remaining_Balance__c,ASI_MFM_G_L_Date__c from ASI_MFM_PO_Line_Item__c  where ASI_MFM_PO__r.ASI_MFM_PO_Start_Date__c <= Today AND ASI_MFM_PO__r.ASI_MFM_Status__c = \'Final\' AND ((ASI_MFM_PO_Amount__c > 0 AND ASI_MFM_Remaining_Balance__c > 0 AND ASI_MFM_Complete__c = false) OR (ASI_MFM_Complete__c = true AND ASI_MFM_All_Payment_Effective__c = false AND ASI_MFM_Adjustment_Line__c = false)) AND (ASI_MFM_PO__r.RecordType.DeveloperName LIKE \'ASI_MFM_SG_PO%\') AND (NOT ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c like \'%2260%\') AND (ASI_MFM_PO__r.ASI_MFM_SG_No_Payment_Request_Required__c=false) ' ;              
        
        system.debug('SOQL' + soql);
        
        this.numOfRowInTable = 30;
        this.currentPageNum = 1;
        this.LimitFrom = 0;
        
        reportList =[SELECT Id FROM Folder WHERE Name = 'ASI SG MFM Report' And Type = 'Report'];          //reportList =[Select ID from Report where DeveloperName = 'ASI_MFM_SG_BA_Verify_Report'];
        rid= (String)reportList.get(0).get('Id');             // reportList =[Select ID from Report where DeveloperName = 'ASI_SG_Payment_Report'];                 // pid= (String)reportList.get(0).get('Id');
        
        //Search
        Plan_Num=null;
        PO_Num=null;
        PO_Line_Num=null;
        Sub_Brands=null;
        Suppliers_Num=null;        
        Suppl=null;
        AC_Code=null;
        GL_date=null;
        Dept=null;
        Fiscal_Years=null;
        gl_fromDate = new ASI_MFM_PO_Line_Item__c ();
        gl_toDate = new ASI_MFM_PO_Line_Item__c (); 
        
        
        runQuery();
    }
    
    public ASI_MFM_SG_BAverifyController(ApexPages.StandardController controller){
        init();
        /*
        for (ASI_MFM_Default_Value__c Setting : ASI_MFM_Default_Value__c.getAll().values()) {
            if(Setting.name == 'SG_BA_Verify_Report' && Setting.Country__c == 'SG'){
                    rid = Setting.ASI_MFM_value__c;
            }
        }*/
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
        get  { if (sortField == null) {sortField = 'ASI_MFM_Sub_brand_Code__r.name'; } return sortField;  }  //ASI_MFM_G_L_Date__c
        set;
    }
    public String debugSoql {
        get { return soql + ' order by ' + sortField + ' ' + sortDir  + ' Limit ' + this.numOfRowInTable + ' OFFSET ' + LimitFrom; }
        set;
    }
    public transient List<ASI_MFM_PO_Line_Item__c> TotalLineItem{get;set;}
    public List<ASI_MFM_PO_Line_Item__c> lineItem{get;set;}
    
    //sort
    public void toggleSort() {
        sortDir = sortDir.equals('asc') ? 'desc' : 'asc';
        runQuery();
    }
    
    public void runQuery() {
        try {
            system.debug('SOQL: ' + soql + ' order by: ' + sortField + ' sort Direction: ' + sortDir);
            TotalLineItem = Database.query(soql + ' order by ' + sortField + ' ' + sortDir);
            this.totalNumOfRecord = TotalLineItem.size();
            lineItem = Database.query(soql + ' order by ' + sortField + ' ' + sortDir + ' Limit ' + this.numOfRowInTable + ' OFFSET ' + LimitFrom);
            
            Date selectedDate =  Date.today(); 
            Date firstDate = selectedDate.toStartOfMonth();
            
            //Wilken 20151102: Move Post G/L Date to BA Verify page header
            /*for(ASI_MFM_PO_Line_Item__c pol:lineItem){ 
                if(pol.ASI_MFM_SG_BA_verify__c==false){
                    pol.ASI_MFM_Post_G_L_Date__c= firstDate.addDays(date.daysInMonth(selectedDate.year() , selectedDate.month())  - 1);
                }
            }*/
            
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No Records Found, Please Check your search input' + soql));
            //System.debug('Fail123');
        }
    }
    
    //search function
    public PageReference runSearch() {
        PO_Number = Apexpages.currentPage().getParameters().get('PO_Number');
        PO_Line_Number = Apexpages.currentPage().getParameters().get('PO_Line_Number');
        Sub_Brand = Apexpages.currentPage().getParameters().get('Sub_Brand');
        Suppliers_Number = Apexpages.currentPage().getParameters().get('Suppliers_Number');
        Suppliers = Apexpages.currentPage().getParameters().get('Suppliers');
        A_C_Code = Apexpages.currentPage().getParameters().get('A_C_Code');
        GLdates = Apexpages.currentPage().getParameters().get('GLdates');
        Departments=Apexpages.currentPage().getParameters().get('Departments');
        Fiscal_Year=Apexpages.currentPage().getParameters().get('Fiscal_Year');
        String[] str;
        Datetime searchDate;
        String location;
        // [LH 1.0] exclude [no Payment Request required]
        soql='select id, ASI_MFM_Synced__c,ASI_MFM_ETL_Date__c,name,ASI_MFM_PO__r.ASI_MFM_Fiscal_Year__c, ASI_MFM_PO__r.ASI_MFM_PO_Start_Date__c ,ASI_MFM_Post_G_L_Date__c,ASI_MFM_PO__r.ASI_MFM_Department__c,ASI_MFM_PO__r.ASI_MFM_Prefix__r.ASI_MFM_Location__c,ASI_MFM_PO__r.ASI_MFM_Prefix__c, ASI_MFM_Base_Currency_Amount__c,ASI_MFM_Sub_brand_Code__r.name,ASI_MFM_Sub_brand_Code__c,ASI_MFM_A_C_Code__r.name,ASI_MFM_PO_Supplier_Number__c,ASI_MFM_PO__r.ASI_MFM_Plan__c,ASI_MFM_PO__r.name, ASI_MFM_SG_BA_verify__c,ASI_MFM_PO__c,ASI_MFM_PO__r.ASI_MFM_Supplier_Name__c,ASI_MFM_PO__r.ASI_MFM_PO_Amount__c,ASI_MFM_Amount__c,ASI_MFM_List_Item_Description__c,ASI_MFM_A_C_Code__c,ASI_MFM_Currency__c,ASI_MFM_Remaining_Balance__c,ASI_MFM_G_L_Date__c from ASI_MFM_PO_Line_Item__c where ASI_MFM_PO__r.RecordType.DeveloperName LIKE \'ASI_MFM_SG_PO%\' AND ASI_MFM_PO__r.ASI_MFM_Status__c = \'Final\' AND ((ASI_MFM_PO_Amount__c > 0 AND ASI_MFM_Remaining_Balance__c > 0 AND ASI_MFM_Complete__c = false) OR (ASI_MFM_Complete__c = true AND ASI_MFM_All_Payment_Effective__c = false AND ASI_MFM_Adjustment_Line__c = false)) AND (NOT ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c like \'%2260%\') AND (ASI_MFM_PO__r.ASI_MFM_SG_No_Payment_Request_Required__c=false)' ;
        
        if(Plan_Num!=null && Plan_Num.length()>0){
            soql += ' and ASI_MFM_PO__r.ASI_MFM_Plan__r.name LIKE \''+String.escapeSingleQuotes(Plan_Num)+'%\'';
        }
        if(PO_Num!=null && PO_Num.length()>0){
            soql += ' and ASI_MFM_PO__r.name LIKE \''+String.escapeSingleQuotes(PO_Num)+'%\' ';
        }
        if(PO_Line_Num!=null && PO_Line_Num.length()>0){
            soql += ' and Name LIKE \''+String.escapeSingleQuotes(PO_Line_Num)+'%\' ';
        }
        if(Sub_Brands!=null && Sub_Brands.length()>0){
            soql += ' and ASI_MFM_Sub_brand_Code__r.name LIKE \''+String.escapeSingleQuotes(Sub_Brands)+'%\' ';
        }
        if(Suppliers_Num!=null && Suppliers_Num.length()>0){
            soql += ' and ASI_MFM_PO_Supplier_Number__c LIKE \''+String.escapeSingleQuotes(Suppliers_Num)+'%\' ';
        }
        if(Suppl!=null && Suppl.length()>0){
            soql += ' and ASI_MFM_PO__r.ASI_MFM_Supplier_Name__r.name LIKE \''+String.escapeSingleQuotes(Suppl)+'%\' ';
        }
        
        if(AC_Code!=null && AC_Code.length()>0){
            soql += ' and ASI_MFM_A_C_Code__r.name LIKE \''+String.escapeSingleQuotes(AC_Code)+'%\' ';
        }
        if (gl_fromDate.ASI_MFM_G_L_Date__c != null) {
            String fromDate = DateTime.newInstance(gl_fromDate.ASI_MFM_G_L_Date__c.year(),gl_fromDate.ASI_MFM_G_L_Date__c.month(),gl_fromDate.ASI_MFM_G_L_Date__c.day(), 0,0,0).format('yyyy-MM-dd');
            soql += ' AND ASI_MFM_G_L_Date__c  >= ' + fromDate + ''; 
        }
        if (gl_toDate.ASI_MFM_G_L_Date__c != null) {
            String toDate = DateTime.newInstance(gl_toDate.ASI_MFM_G_L_Date__c.year(),gl_toDate.ASI_MFM_G_L_Date__c.month(),gl_toDate.ASI_MFM_G_L_Date__c.day(), 0,0,0).format('yyyy-MM-dd');
            soql += ' AND ASI_MFM_G_L_Date__c    <= ' + toDate + ''; 
        }
        if (poStartDate.ASI_MFM_PO_Start_Date__c != null) {
            String startDate = DateTime.newInstance(poStartDate.ASI_MFM_PO_Start_Date__c.year(),poStartDate.ASI_MFM_PO_Start_Date__c.month(),poStartDate.ASI_MFM_PO_Start_Date__c.day(), 0,0,0).format('yyyy-MM-dd');
            soql += ' AND ASI_MFM_PO__r.ASI_MFM_PO_Start_Date__c    <= ' + startDate + ''; 
        }
        if(Dept!=null && Dept.length()>0){
            if(Dept.contains('SG')){
                location='Singapore';
                soql += ' and ASI_MFM_PO__r.ASI_MFM_Market__c = \'' +location+'\''+ 'and ASI_MFM_PO__r.ASI_MFM_Department__c LIKE \'%' +Dept.substring(3,8)+'%\'';
            }
            if(Dept.contains('CA')){
                location='Cambodia';
                soql += ' and ASI_MFM_PO__r.ASI_MFM_Market__c = \'' +location+'\''+ 'and ASI_MFM_PO__r.ASI_MFM_Department__c LIKE \'%' +Dept.substring(3,8)+'%\'';
            }
            if(Dept.contains('LA')){
                location='Laos';
                soql += ' and ASI_MFM_PO__r.ASI_MFM_Market__c = \'' +location+'\'';
            }
            if(Dept.contains('MM')){
                location='Myanmar';
                soql += ' and ASI_MFM_PO__r.ASI_MFM_Market__c = \'' +location+'\'';
            }
            
        }
        if(Fiscal_Years!=null && Fiscal_Years.length()>0){
            soql += ' and ASI_MFM_PO__r.ASI_MFM_Fiscal_Year__c = \'' +Fiscal_Years + '\' ';
        }
        runQuery();
        
        return null;  //System.debug('test678:'+soql);
        }
    
    // save BAverify 
    public void save(){
        Integer count = 0;
        Set<String> verLines = new Set<String>();
        String Msg='';
        boolean SavePermission=true;
        if(postGLDate.ASI_MFM_Post_G_L_Date__c==null){
            SavePermission=false;
            Msg='Please input Post G/L date.';
        }
        
        if(SavePermission){
            for (ASI_MFM_PO_Line_Item__c ver : lineItem)
            {
                if (ver.ASI_MFM_SG_BA_verify__c == true ) {
                    count++;
                    verLines.add(ver.ASI_MFM_PO__r.name);
                    ver.ASI_MFM_Post_G_L_Date__c = postGLDate.ASI_MFM_Post_G_L_Date__c;
                }
                
              
            }
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, count + ' PO Line verified. PO No. ' + verLines));
            update lineItem;
            GenerateActualPORemaining();
        }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Msg));
        }
        
        
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
    
    public void GenerateActualPORemaining() {
        transient List<ASI_MFM_PO_Line_Item__c> POLList = new List<ASI_MFM_PO_Line_Item__c>();
        Set<id> POList_Set = new Set<id>();
        List<ASI_MFM_Payment_Line_Item__c> PALList = new List<ASI_MFM_Payment_Line_Item__c>();
        List<ASI_MFM_Payment_Line_Item__c> UpdatePALList = new List<ASI_MFM_Payment_Line_Item__c>();
        POLList = [Select id,ASI_MFM_Paid_Amount__c,ASI_MFM_Actual_Paid_Amouint__c FROM ASI_MFM_PO_Line_Item__c WHERE ASI_MFM_SG_BA_verify__c = false AND ASI_MFM_PO__r.ASI_MFM_Status__c = 'Final' AND ASI_MFM_PO__r.RecordType.DeveloperName LIKE 'ASI_MFM_SG_PO%' AND ASI_MFM_Remaining_Balance__c > 0 AND ASI_MFM_All_Payment_Effective__c = false];
        for (ASI_MFM_PO_Line_Item__c POL: POLList) {
            if (POL.ASI_MFM_Paid_Amount__c != POL.ASI_MFM_Actual_Paid_Amouint__c) {
                POList_Set.add(POL.id);
            }
        }
        PALList = [Select id, ASI_MFM_Effective__c FROM ASI_MFM_Payment_Line_Item__c WHERE ASI_MFM_PO_Line_Item__c IN :POList_Set AND ASI_MFM_Effective__c != true AND ASI_MFM_Payment__r.ASI_MFM_G_L_Date__c <= TODAY AND ASI_MFM_Payment__r.ASI_MFM_Status__c = 'Final'];
        for (ASI_MFM_Payment_Line_Item__c PAL : PALList){
            PAL.ASI_MFM_Effective__c = true;    
            UpdatePALList.add(PAL);
        }
        system.debug('UpdatePALList:::' + UpdatePALList);
        if(UpdatePALList.size()>0)
        {
            update UpdatePALList;
        }
        runQuery();
    }
    
    public Integer maxPageNum { get { return maxNumOfPage(); } private set; }
    public Integer currentPageNum { get; protected set { currentPageNum = value; newPageNum = String.valueOf(value); } }
    public String newPageNum { get; set; }

}