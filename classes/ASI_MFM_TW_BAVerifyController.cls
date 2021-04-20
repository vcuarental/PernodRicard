public without sharing class ASI_MFM_TW_BAVerifyController {
    protected Integer totalNumOfRecord;
    public Integer numOfRowInTable;
    public Integer LimitFrom;
    private String soql {get;set;}
    public String Plan_Num {get;set;}
    public Date PostGLDate {get;set;}{PostGLDate = system.today();}
    
	public String PO_Num{get;set;}
    public String PO_Line_Num{get;set;}
    public String Suppliers_Num{get;set;}
    public String Suppl{get;set;}
    public String SB_Code{get;set;}
    public String AC_Code{get;set;}
    public String GL_dates{get;set;}
	public String Fiscal_Year{get;set;}
    public String rid {get;set;}
    public String uid {get;set;}
    List <Report> reportList=new List<Report>();
    public ASI_MFM_PO_Line_Item__c gl_fromDate { get; set; }
    public ASI_MFM_PO_Line_Item__c gl_toDate { get; set; }
    
    public void init() {
        ASI_MFM_Settings__c mfmSetting = [select id, ASI_MFM_TW_Accrual_PO_Generation_Day__c, ASI_MFM_TW_Post_G_L_Date__c,ASI_MFM_TW_Today__c from ASI_MFM_Settings__c where recordtype.DeveloperName = 'ASI_MFM_TW_Setting' limit 1];
        if(mfmSetting.ASI_MFM_TW_Post_G_L_Date__c!=null){
            PostGLDate = mfmSetting.ASI_MFM_TW_Post_G_L_Date__c;
        }
        
        soql='select id, name, ASI_MFM_PO__r.ASI_MFM_Fiscal_Year__c,ASI_MFM_Sub_brand_Code__c,ASI_MFM_Base_Currency_Amount__c,ASI_MFM_Post_G_L_Date__c,ASI_MFM_A_C_Code__r.name,ASI_MFM_PO_Supplier_Number__c, ASI_MFM_PO__r.ASI_MFM_Plan__c,ASI_MFM_PO__r.name, ASI_MFM_SG_BA_verify__c,ASI_MFM_PO__c,ASI_MFM_PO__r.ASI_MFM_Supplier_Name__c,ASI_MFM_PO__r.ASI_MFM_PO_Amount__c, ';
        soql+=' ASI_MFM_Amount__c,ASI_MFM_List_Item_Description__c,ASI_MFM_A_C_Code__c,ASI_MFM_Currency__c,ASI_MFM_Remaining_Balance__c,ASI_MFM_G_L_Date__c, ASI_MFM_Customer_Name__c  from ASI_MFM_PO_Line_Item__c ';
        //soql+=' where ASI_MFM_G_L_Date__c <= TODAY AND ASI_MFM_PO__r.ASI_MFM_Status__c = \'Final\'  AND ASI_MFM_PO_Amount__c > 0 AND ASI_MFM_Remaining_Balance__c > 0 AND ASI_MFM_Complete__c = false  AND ASI_MFM_PO__r.RecordTypeId = \''+Global_RecordTypeCache.getRTId('ASI_MFM_PO_Line_Item__cASI_MFM_TW_PO_Line_Item') +'\' ';
        soql+=' where ASI_MFM_G_L_Date__c <= TODAY AND ASI_MFM_PO__r.ASI_MFM_Accrual_PO__c = TRUE AND ASI_MFM_PO__r.ASI_MFM_Status__c = \'Final\'  AND ASI_MFM_Synced__c  = false  AND (ASI_MFM_PO__r.RecordTypeId = \''+Global_RecordTypeCache.getRTId('ASI_MFM_PO__cASI_MFM_TW_PO_Read_Only') +'\'  OR ASI_MFM_PO__r.RecordTypeId = \''+Global_RecordTypeCache.getRTId('ASI_MFM_PO__cASI_MFM_TW_PO') +'\' ) ';
        system.debug(soql);
        this.numOfRowInTable = 30;
        this.currentPageNum = 1;
        this.LimitFrom = 0;
        reportList =[Select ID from Report where DeveloperName = 'ASI_MFM_TW_BA_Verify_Report'];
        if (reportList.size()>0){
            rid= (String)reportList.get(0).get('Id');
        }
        
        reportList =[Select ID from Report where DeveloperName = 'ASI_MFM_TW_Unverified_PO_Line_Report'];
        if (reportList.size()>0){
            uid= (String)reportList.get(0).get('Id');
        }
        Plan_Num=NULL;
        PO_Num=null;
        PO_Line_Num=null;
        Suppliers_Num=null;
        Suppl=null;
        SB_Code=null;
        AC_Code=null;
        GL_dates=null;
        gl_fromDate = new ASI_MFM_PO_Line_Item__c ();
        gl_toDate = new ASI_MFM_PO_Line_Item__c ();
        runQuery();
    }
    public ASI_MFM_TW_BAVerifyController(ApexPages.StandardController controller){
         init();
        /*
        for (ASI_MFM_Default_Value__c Setting : ASI_MFM_Default_Value__c.getAll().values()) {
            if(Setting.name == 'TH_BA_Verify_Report' && Setting.Country__c == 'TH'){
                    rid = Setting.ASI_MFM_value__c;
            }
        }*/ 
    }

    
    
    public String sortDir {
        get  { if (sortDir == null) {  sortDir = 'ASC'; } return sortDir;  }
        set;
    }
    public String sortField {
        get  { if (sortField == null) {sortField = 'ASI_MFM_G_L_Date__c'; } return sortField;  }
        set;
    }
    public String debugSoql {
        get { return soql + ' order by ' + sortField + ' ' + sortDir  + ' Limit ' + this.numOfRowInTable + ' OFFSET ' + LimitFrom; }
        set;
    }
    
    public String SaveResult {get;set;}
    
    public transient List<ASI_MFM_PO_Line_Item__c> TotalLineItem{get;set;}
    public List<ASI_MFM_PO_Line_Item__c> lineItem{get;set;}
    
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
			Date selectedDate =  Date.today(); 
			Date firstDate = selectedDate.toStartOfMonth();
			
            for(ASI_MFM_PO_Line_Item__c pol:lineItem){ 
                //if(){ // && pol.ASI_MFM_Post_G_L_Date__c==null
                pol.ASI_MFM_Post_G_L_Date__c= PostGLDate;//firstDate.addDays(date.daysInMonth(selectedDate.year() , selectedDate.month())  - 1);
            
                pol.ASI_MFM_SG_BA_verify__c =true; 
            }
			
		} catch (Exception e) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()  )); // +'No Records Found, Please Check your search input' + soql
            // +soql + ' order by ' + sortField + ' ' + sortDir + ' Limit ' + this.numOfRowInTable + ' OFFSET ' + LimitFrom 
			System.debug(soql);
		}
        
	}
    
    public PageReference refresh() {
        init();
        return null;
    }
    
    //search function
    public PageReference runSearch() {
        String[] str;
        Datetime searchDate;
        soql='select id, name,ASI_MFM_PO__r.ASI_MFM_Fiscal_Year__c,ASI_MFM_Sub_brand_Code__c, ASI_MFM_Base_Currency_Amount__c,ASI_MFM_Post_G_L_Date__c,ASI_MFM_A_C_Code__r.name,ASI_MFM_PO__r.ASI_MFM_Plan__c, ASI_MFM_SG_BA_verify__c,ASI_MFM_PO__c,ASI_MFM_PO__r.name,ASI_MFM_PO__r.ASI_MFM_Supplier_Name__c,ASI_MFM_PO__r.ASI_MFM_PO_Amount__c,ASI_MFM_Amount__c,ASI_MFM_PO_Supplier_Number__c , ';
        soql+=' ASI_MFM_List_Item_Description__c,ASI_MFM_A_C_Code__c,ASI_MFM_Currency__c,ASI_MFM_Remaining_Balance__c,ASI_MFM_G_L_Date__c,ASI_MFM_Customer_Name__c  ';
        soql+=' from ASI_MFM_PO_Line_Item__c ';
        //soql+=' where ASI_MFM_PO__r.ASI_MFM_Status__c = \'Final\' AND ASI_MFM_PO_Amount__c > 0 AND ASI_MFM_Remaining_Balance__c > 0 AND ASI_MFM_Complete__c = false  AND (ASI_MFM_PO__r.RecordTypeId = \''+Global_RecordTypeCache.getRTId('ASI_MFM_PO__cASI_MFM_TW_PO_Read_Only') +'\'  OR ASI_MFM_PO__r.RecordTypeId = \''+Global_RecordTypeCache.getRTId('ASI_MFM_PO__cASI_MFM_TW_PO') +'\' ) ';
        soql+=' where ASI_MFM_PO__r.ASI_MFM_Accrual_PO__c = TRUE AND ASI_MFM_PO__r.ASI_MFM_Status__c = \'Final\' AND ASI_MFM_Synced__c = false  AND (ASI_MFM_PO__r.RecordTypeId = \''+Global_RecordTypeCache.getRTId('ASI_MFM_PO__cASI_MFM_TW_PO_Read_Only') +'\'  OR ASI_MFM_PO__r.RecordTypeId = \''+Global_RecordTypeCache.getRTId('ASI_MFM_PO__cASI_MFM_TW_PO') +'\' ) ';
        
        if(Plan_Num!=null && Plan_Num.length()>0){
            soql += ' and ASI_MFM_PO__r.ASI_MFM_Plan__r.name LIKE \''+String.escapeSingleQuotes(Plan_Num)+'%\'';
        }
        if(PO_Num!=null && PO_Num.length()>0){
            soql += ' and ASI_MFM_PO__r.name LIKE \''+String.escapeSingleQuotes(PO_Num)+'%\'';
        }
        if(PO_Line_Num!=null && PO_Line_Num.length()>0){
            soql += ' and Name LIKE \''+String.escapeSingleQuotes(PO_Line_Num)+'%\'';
        }
        if(Suppliers_Num!=null && Suppliers_Num.length()>0){
            soql += ' and ASI_MFM_PO_Supplier_Number__c LIKE \''+String.escapeSingleQuotes(Suppliers_Num)+'%\'';
        }
        if(Suppl!=null && Suppl.length()>0){
            soql += ' and ASI_MFM_PO__r.ASI_MFM_Supplier_Name__r.name LIKE \''+String.escapeSingleQuotes(Suppl)+'%\'';
        }
        if(SB_Code!=null && SB_Code.length()>0){
            soql += ' and ASI_MFM_Sub_brand_Code__r.name LIKE \'%'+String.escapeSingleQuotes(SB_Code)+'%\'';
        }
        if(AC_Code!=null && AC_Code.length()>0){
            soql += ' and ASI_MFM_A_C_Code__r.name LIKE \'%'+String.escapeSingleQuotes(AC_Code)+'%\'';
        }
        if (gl_fromDate.ASI_MFM_G_L_Date__c != null) {
            String fromDate = DateTime.newInstance(gl_fromDate.ASI_MFM_G_L_Date__c.year(),gl_fromDate.ASI_MFM_G_L_Date__c.month(),gl_fromDate.ASI_MFM_G_L_Date__c.day(), 0,0,0).format('yyyy-MM-dd');
            soql += ' AND ASI_MFM_G_L_Date__c  >= ' + fromDate + ''; 
        }
        if (gl_toDate.ASI_MFM_G_L_Date__c != null) {
            String toDate = DateTime.newInstance(gl_toDate.ASI_MFM_G_L_Date__c.year(),gl_toDate.ASI_MFM_G_L_Date__c.month(),gl_toDate.ASI_MFM_G_L_Date__c.day(), 0,0,0).format('yyyy-MM-dd');
            soql += ' AND ASI_MFM_G_L_Date__c    <= ' + toDate + ''; 
        }
        
         if(Fiscal_Year!=null && Fiscal_Year.length()>0){
            soql += ' and ASI_MFM_PO__r.ASI_MFM_Fiscal_Year__c = \'' +Fiscal_Year + '\' ';
        }
        this.LimitFrom = 0;
        this.currentPageNum = 1;
        runQuery();
        return null;
    }
    // save BAverify
    public void save(){
        Integer count = 0;
        Set<String> verLines = new Set<String>();
        List<ASI_MFM_PO_Line_Item__c> validatedLines = new List<ASI_MFM_PO_Line_Item__c>();
        
        for (ASI_MFM_PO_Line_Item__c ver : lineItem)
        {	
            Boolean hasCustName = true;
            if (ver.ASI_MFM_SG_BA_verify__c == true ) {
                
                if(ver.ASI_MFM_Customer_Name__c!=null){
                	count++;
                	verLines.add(ver.ASI_MFM_PO__r.name);
                }else{
                    hasCustName =false;
                    ver.ASI_MFM_SG_BA_verify__c = false;
                    ver.addError('Update "'+ver.Name+'" failed: Missing Customer Name');
                }
            }
            if(hasCustName){
            	validatedLines.add(ver);    
            }
            
            
            /**
            Date selectedDate =  Date.today(); 
            Date firstDate = selectedDate.toStartOfMonth();
            if(ver.ASI_MFM_SG_BA_verify__c==false){
                ver.ASI_MFM_Post_G_L_Date__c= firstDate.addDays(date.daysInMonth(selectedDate.year() , selectedDate.month())  - 1);
            }
			**/
        }
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, count + ' PO Lines verified. PO No. ' + verLines));
        //update lineItem;
        try{
        	update validatedLines;    
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Update failed: ' + e));
        }
        
        //runQuery();
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