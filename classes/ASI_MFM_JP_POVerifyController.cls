public with sharing class ASI_MFM_JP_POVerifyController {
    //-- pagination --//
    
   
    protected Integer totalNumOfRecord;
    public Integer numOfRowInTable;
    public Integer LimitFrom;
    public boolean SaveSuccess {get;set;}
    public String Msg {get;set;}
    public transient boolean UpsertPermission {get;set;}
    public transient boolean SearchPermission {get;set;}{SearchPermission=true;}
    //-- End --//
    
    public String CtrlType {get;set;}
    
    //-- search criteria --//
    public transient String OwnerVerify {get;set;}
    public transient String Plan_ID {get;set;}
    public transient String PO_ID {get;set;}
    public transient String POLine_ID {get;set;}
    public transient String PORL_ID {get;set;}
    public transient String Suppl {get;set;}
    public transient String Fiscalyear {get;set;}
    public String NowFY {get;set;}
    public transient String Userfilter {get;set;}{Userfilter=null;}
    public ASI_MFM_PO_Receipt_Item__c fromDate { get; set; }
    public ASI_MFM_PO_Receipt_Item__c toDate { get; set; }
    public ASI_MFM_PO_Receipt_Item__c PostGLDate { get; set; }
    public String WhereStatm {get;set;}
    //-- End --//
    
    public transient Map<id, id> APACMap { get; set; } {APACMap = new Map<id, id>();}//id is AP Code ID
    
    
    private String init_soql {get;set;} 
    public List<ASI_MFM_PO_Receipt_Item__c> LineItem {get; set;}
     
    //For Amount Checking
    public Map<id, decimal> AmountCheckingMap {get;set;}{ AmountCheckingMap = new Map<id, decimal>();}
    public String jsonDataMinimal {set;get;} {jsonDataMinimal = null;}
    public String lineItemJson {get; set;} {lineItemJson = null;}
    
    public static final String RecordType_Developer_Name ='ASI_MFM_JP_PO_Receipt_item';
    public transient Map<Id, ASI_MFM_PO_Receipt_Item__c> OrignalMap { get; set; }  {OrignalMap = new  Map<Id, ASI_MFM_PO_Receipt_Item__c>();}
    
    
    //report
 	Public static final String FolderName ='ASI MFM JP Report';
    public String reportFolderid {get;set;}
    
    
    public class SmallDataRow {  
        
        public Id recordId 						{ get; set; }  
        public boolean Verify 						{get;set;}
        public string Amount 						{set;get;}
        public String  Remark 						{set;get;}
        public string ReceiptDate  					{set;get;}
        public String apCode                      { get; set;}
        
        public SmallDataRow(ASI_MFM_PO_Receipt_Item__c porline,string CtrlType){  
            this.recordId =  porline.Id;  
            
            if(CtrlType=='PO'){
                this.Verify = porline.ASI_MFM_Marketing_Verify__c;
            }else{
                this.Verify = porline.ASI_MFM_ACC_Verify__c;
            }
            this.apCode = porline.ASI_MFM_AP_Code__c!=null? String.valueOf(porline.ASI_MFM_AP_Code__c): null;
            this.Amount=String.valueOf(porline.ASI_MFM_Amount__c);
            if(porline.ASI_MFM_Remark__c!=null){
                this.Remark=porline.ASI_MFM_Remark__c;
            }
            this.ReceiptDate =  porline.ASI_MFM_Receipt_Date__c!=null? porline.ASI_MFM_Receipt_Date__c.format():null;    // this.ReceiptDate=porline.ASI_MFM_Receipt_Date__c;this.accodeId = String.valueOf(poline.ASI_MFM_A_C_Code__r.Id);
        }  
    }   
    
    
    
    public ASI_MFM_JP_POVerifyController(){ //ApexPages.StandardController controller)
        
    }
    

          
    public void initPOVerify(){
        
           //-- init search query --//
        init_soql='SELECT id,ASI_MFM_PO_Line_Item__r.ASI_MFM_Paid_Amount__c,ASI_MFM_Paid_Amount__c，ASI_MFM_PO_Receipt_Balance_Amount__c,ASI_MFM_Remaining_Balance__c,ASI_MFM_Post_G_L_Date__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Responsible_By__r.name,CreatedBy.name,Name,ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_PO_Fiscal_Year__c ,ASI_MFM_A_C_Code_temp__c,ASI_MFM_AP_Code__c,ASI_MFM_Remark__c,ASI_MFM_ACC_Verify__c, ASI_MFM_PO_Receipt__r.ownerId,ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.Name , ASI_MFM_PO_Receipt__r.name,ASI_MFM_Marketing_Verify__c, ASI_MFM_PO_Line_Item__c, ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c, ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Plan__c, ASI_MFM_PO_Receipt__r.CreatedDate,ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c,'+
            'ASI_MFM_PO_Line_Item__r.ASI_MFM_List_Item_Description__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_Verified_Receipt_Amount__c, ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Supplier_Name__c, ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Currency__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_A_C_Code__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_AP_Code__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_Customer_Name__c,' +
            'ASI_MFM_PO_Line_Item__r.ASI_MFM_Amount__c, ASI_MFM_PO_Receipt__r.owner.name,ASI_MFM_PO_Line_Item__r.ASI_MFM_CN_Remaining_Receipt_Balance__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_Remaining_Balance__c, ASI_MFM_Receipt_Date__c, ASI_MFM_Amount__c FROM ASI_MFM_PO_Receipt_Item__c WHERE recordtype.developername=\'';
        init_soql +=RecordType_Developer_Name+'\'';
        init_soql+=' and ASI_MFM_ACC_Verify__c =false and ASI_MFM_Paid__c=false and ASI_MFM_PO_Line_Item__r.ASI_MFM_Complete__c=false and ASI_MFM_Remaining_Balance__c>0';
        //-- End --//
         CtrlType='PO';
        init();
       
    }
        
    
    public void initBAVerify(){
        
        reportFolderid =[SELECT Id FROM Folder WHERE Name =:FolderName And Type = 'Report']!=null? (String)[SELECT Id FROM Folder WHERE Name =:FolderName And Type = 'Report'][0].Id : '';
        
        
           //-- init search query --//        and ASI_MFM_Marketing_Verify__c =true
        init_soql='SELECT id,ASI_MFM_PO_Line_Item__r.ASI_MFM_Paid_Amount__c,ASI_MFM_Paid_Amount__c,ASI_MFM_Post_G_L_Date__c,ASI_MFM_PO_Receipt_Balance_Amount__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_Customer_Name__r.name,ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Responsible_By__r.name,ASI_MFM_ETL__c,ASI_MFM_ETL_Date__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_PO_Fiscal_Year__c ,ASI_MFM_A_C_Code_temp__c,CreatedBy.name,Name,ASI_MFM_AP_Code__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_VAT__c,ASI_MFM_Remark__c,ASI_MFM_ACC_Verify__c, ASI_MFM_PO_Receipt__r.ownerId,ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.Name , ASI_MFM_PO_Receipt__r.name,ASI_MFM_Marketing_Verify__c, ASI_MFM_PO_Line_Item__c, ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c, ASI_MFM_PO_Line_Item__r.ASI_MFM_G_L_Date__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Plan__c, ASI_MFM_PO_Receipt__r.CreatedDate,ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c,'+
            'ASI_MFM_PO_Line_Item__r.ASI_MFM_List_Item_Description__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_Verified_Receipt_Amount__c, ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Supplier_Name__c, ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Currency__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_A_C_Code__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_AP_Code__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_Customer_Name__c, ' +
            'ASI_MFM_PO_Line_Item__r.ASI_MFM_Amount__c, ASI_MFM_PO_Receipt__r.owner.name,ASI_MFM_PO_Line_Item__r.ASI_MFM_CN_Remaining_Receipt_Balance__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_Remaining_Balance__c, ASI_MFM_Receipt_Date__c, ASI_MFM_Amount__c FROM ASI_MFM_PO_Receipt_Item__c WHERE recordtype.developername=\'';
        init_soql +=RecordType_Developer_Name+'\'';
        init_soql+=' and ASI_MFM_PO_Line_Item__r.ASI_MFM_Complete__c=false ';
        init_soql+=ASI_MFM_ByPass_Setting.ReturnSqlStatement('ASI_MFM_JP_POVerifyController','Initialization','JP');
        //-- End --//
		CtrlType='BA';
		 init();
        //Get month end date
        Date selectedDate =  Date.today(); 
        Date firstDate = selectedDate.toStartOfMonth();
        
        PostGLDate = new ASI_MFM_PO_Receipt_Item__c ();
        PostGLDate.ASI_MFM_Post_G_L_Date__c= firstDate.addDays(date.daysInMonth(selectedDate.year() , selectedDate.month())  - 1);
       
    }
    
    
    
    public void init() {
     
        
          //Get Current Fisacal Year
        NowFY='FY';
        Date Today_date=Date.today();
        if(Today_date.month()>0 && Today_date.month()<7){  
            NowFY=NowFY+string.valueof(Today_date.year()-1).substring(2,4)+string.valueof(Today_date.year()).substring(2,4);
        }else{
            NowFY=NowFY+string.valueof(Today_date.year()).substring(2,4)+string.valueof(Today_date.year()+1).substring(2,4);
        }
        Fiscalyear=NowFY;
        
        WhereStatm='';
        
        //Default as current Fiscal Year
        if(Fiscalyear!=null && Fiscalyear.length()>0){
            WhereStatm += ' and ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_PO_Fiscal_Year__c LIKE \''+String.escapeSingleQuotes(Fiscalyear)+'%\'';
        }
        
        if(CtrlType=='PO'){
             WhereStatm += ' and ASI_MFM_Marketing_Verify__c=false';
        }else{
             WhereStatm += ' and ASI_MFM_ACC_Verify__c=false';
        }
        
        
        SaveSuccess=false;
        UpsertPermission = true;
        OwnerVerify='Unchecked';
        Plan_ID=null;
        PO_ID =null;
        POLine_ID=null;
        PORL_ID=null;
        Suppl =null;
        fromDate = new ASI_MFM_PO_Receipt_Item__c ();
        toDate = new ASI_MFM_PO_Receipt_Item__c ();
        
        Date selectedDate =  Date.today(); 
		Date firstDate = selectedDate.toStartOfMonth();
        fromDate.ASI_MFM_Receipt_Date__c=firstDate;
        toDate.ASI_MFM_Receipt_Date__c=firstDate.addDays(date.daysInMonth(selectedDate.year() , selectedDate.month())  - 1);

         
        String fromDate_s = DateTime.newInstance(fromDate.ASI_MFM_Receipt_Date__c.year(),fromDate.ASI_MFM_Receipt_Date__c.month(),fromDate.ASI_MFM_Receipt_Date__c.day(), 0,0,0).format('yyyy-MM-dd');
        WhereStatm += ' AND ASI_MFM_Receipt_Date__c >= ' + fromDate_s + ''; 
        
        String toDate_c = DateTime.newInstance(toDate.ASI_MFM_Receipt_Date__c.year(),toDate.ASI_MFM_Receipt_Date__c.month(),toDate.ASI_MFM_Receipt_Date__c.day(), 0,0,0).format('yyyy-MM-dd');
        WhereStatm += ' AND ASI_MFM_Receipt_Date__c <= ' + toDate_c + ''; 
        
        
        //-- End --//

        
        runQuery();
    }
    
    public void runQuery() {
        try {
            
            AmountCheckingMap=new Map<id, decimal>();
            List<ASI_MFM_PO_Receipt_Item__c> LineItemtemp; 
            if(LineItem!=null){
                LineItemtemp=LineItem;
            }
            LineItem = Database.query(init_soql + WhereStatm +' order by ' + sortField + ' ' + sortDir);
            if(LineItem.size()>1000){
                SearchPermission=false;
                Msg='Select Size > 1000. Please minimize you filter.';
                SaveSuccess=false;
                LineItem=LineItemtemp;
            }else{
                if(LineItem!=null){
                    List<SmallDataRow> dataRows = new List<SmallDataRow>();  
                    OrignalMap = new Map<Id, ASI_MFM_PO_Receipt_Item__c>(lineItem);
                    //LineItemJson = JSON.serialize(LineItem);
                    for(ASI_MFM_PO_Receipt_Item__c  porl : LineItem){  
                        porl.ASI_MFM_AP_Code__c=porl.ASI_MFM_PO_Line_Item__r.ASI_MFM_AP_Code__c;
                        porl.ASI_MFM_A_C_Code_temp__c=porl.ASI_MFM_PO_Line_Item__r.ASI_MFM_A_C_Code__c;
                        SmallDataRow  inputFields = new SmallDataRow(porl,CtrlType); 
                        dataRows.add(inputFields); 
                        AmountCheckingMap.put(porl.id, porl.ASI_MFM_Amount__c+porl.ASI_MFM_PO_Line_Item__r.ASI_MFM_CN_Remaining_Receipt_Balance__c);
                    }  
                    this.jsonDataMinimal = JSON.serialize(dataRows);     
                }else{
                    // this.LineItemJson = null;
                    this.OrignalMap = null;
                    this.jsonDataMinimal  =null; 
                    
                }
                
            }
            
        } catch (Exception e) {
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, init_soql+WhereStatm+'No Records Found, Please Check your search input'));
        }
    }
    
    public PageReference runSearch() {
        
        
        if(!ASI_MFM_ByPass_Setting.ByPassClass('ASI_MFM_JP_BAVerify','JP')){
            if(fromDate.ASI_MFM_Receipt_Date__c==null || toDate.ASI_MFM_Receipt_Date__c == null){
                SearchPermission=false;
                Msg='Receipt Date cannot be null.';
            }else if(fromDate.ASI_MFM_Receipt_Date__c.month() !=toDate.ASI_MFM_Receipt_Date__c.month()){
                SearchPermission=false;
                Msg='Receipt Date Range can not cross one month.';
            }else{
                SearchPermission=true;
            }
        }else{
            SearchPermission=true;
        }
        
        SaveSuccess=false;
        UpsertPermission = true;
        
        
        if(SearchPermission){
            WhereStatm = '';
            if(CtrlType=='PO' && OwnerVerify!=null && OwnerVerify.length()>0){
                if(OwnerVerify=='Unchecked'){
                    WhereStatm +=  ' and ASI_MFM_Marketing_Verify__c =false ';
                    
                }
                if(OwnerVerify=='Checked'){
                    WhereStatm +=  ' and ASI_MFM_Marketing_Verify__c =true ';
                    
                }
            }else{
                if(OwnerVerify=='Unchecked'){
                    WhereStatm +=  ' and ASI_MFM_ACC_Verify__c =false ';
                    
                }
                if(OwnerVerify=='Checked'){
                    WhereStatm +=  ' and ASI_MFM_ACC_Verify__c =true ';
                    
                }
            }
            if(Plan_ID!=null && Plan_ID.length()>0){
                WhereStatm += ' and ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Plan__r.name LIKE \''+String.escapeSingleQuotes(Plan_ID)+'%\'';
            }
            
            if (PO_ID!=null && PO_ID.length()>0){
                WhereStatm += ' and ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.name LIKE \''+String.escapeSingleQuotes(PO_ID)+'%\'';
            }
            
            if (POLine_ID!=null && POLine_ID.length()>0){
                WhereStatm += ' and ASI_MFM_PO_Line_Item__r.Name LIKE \''+String.escapeSingleQuotes(POLine_ID)+'%\'';
            }
            
            if(Fiscalyear!=null && Fiscalyear.length()>0 && Plan_ID.length()==0 && POLine_ID.length()==0 && PORL_ID.length()==0 && fromDate.ASI_MFM_Receipt_Date__c==null && toDate.ASI_MFM_Receipt_Date__c == null){
                WhereStatm += ' and ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_PO_Fiscal_Year__c LIKE \''+String.escapeSingleQuotes(Fiscalyear)+'%\'';
            }
            
            
            if (PORL_ID!=null && PORL_ID.length()>0){
                WhereStatm += ' and Name LIKE \''+String.escapeSingleQuotes(PORL_ID)+'%\'';
            }
            if (Suppl!=null && Suppl.length()>0){
                WhereStatm += ' AND ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Supplier_Name__r.name LIKE \'%'+String.escapeSingleQuotes(Suppl)+'%\'';
            }
            if (Userfilter!=null && Userfilter.length()>0){
                WhereStatm += ' AND ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Responsible_By__r.name LIKE \'%'+String.escapeSingleQuotes(Userfilter)+'%\'';
            }
            
            if (fromDate.ASI_MFM_Receipt_Date__c != null) {
                String fromDate_s = DateTime.newInstance(fromDate.ASI_MFM_Receipt_Date__c.year(),fromDate.ASI_MFM_Receipt_Date__c.month(),fromDate.ASI_MFM_Receipt_Date__c.day(), 0,0,0).format('yyyy-MM-dd');
                WhereStatm += ' AND ASI_MFM_Receipt_Date__c >= ' + fromDate_s + ''; 
            }
            if (toDate.ASI_MFM_Receipt_Date__c != null) {
                String toDate_c = DateTime.newInstance(toDate.ASI_MFM_Receipt_Date__c.year(),toDate.ASI_MFM_Receipt_Date__c.month(),toDate.ASI_MFM_Receipt_Date__c.day(), 0,0,0).format('yyyy-MM-dd');
                WhereStatm += ' AND ASI_MFM_Receipt_Date__c <= ' + toDate_c + ''; 
            }
            runQuery();
            
        }
        
        return null;
    }
    
    public PageReference save() {
           //Get AP & A/C Code Map
    	 List<ASI_MFM_AP_AC_Code_Map__c> APACList = new List<ASI_MFM_AP_AC_Code_Map__c>();  
        APACList=[select id,ASI_MFM_A_C_Code__c,ASI_MFM_AP_Code__c,ASI_MFM_AP_Code__r.id from ASI_MFM_AP_AC_Code_Map__c where ASI_MFM_AP_Code__r.RecordType.DeveloperName='ASI_JP_AP_Code'];

        APACMap = new Map<id, id>();
        for(ASI_MFM_AP_AC_Code_Map__c apac:APACList){
            if(!APACMap.containsKey(apac.ASI_MFM_AP_Code__r.id)){
                
                APACMap.put(apac.ASI_MFM_AP_Code__r.id, apac.ASI_MFM_A_C_Code__c);
                
            }
        }
        
        
        SearchPermission=true;
        UpsertPermission = true;
        SaveSuccess=true;
        PageReference pageRef = null;
        Boolean isRedirect = True; 

        Database.upsertResult[] updateTarget;
        Database.upsertResult[] updatePOLinesResult;

        List<ASI_MFM_PO_Receipt_Item__c> LinesToUpdate = new List<ASI_MFM_PO_Receipt_Item__c>();  
        Integer count = 0;
        Set<String> verLines = new Set<String>();
        
        //if(LineItemJson!=null){
        //  LineItem = (List<ASI_MFM_PO_Receipt_Item__c>) JSON.deserialize(LineItemJson, List<ASI_MFM_PO_Receipt_Item__c>.class);
        //}
        
        if(LineItem!=null){
            OrignalMap = new Map<Id, ASI_MFM_PO_Receipt_Item__c>(lineItem); //LineItemMapChecking = new Map<Id, ASI_MFM_PO_Receipt_Item__c>(lineItem);
        }       
        
        
        List<SmallDataRow> smallTableRow = (List<SmallDataRow>)JSON.deserialize(jsonDataMinimal, List<SmallDataRow>.class);  
        
        for(SmallDataRow sdr : smallTableRow){ 
            if(OrignalMap!=null){
                if(CtrlType=='PO'){
                    OrignalMap.get(sdr.recordId).ASI_MFM_Marketing_Verify__c  = sdr.Verify;
                }else{
                    OrignalMap.get(sdr.recordId).ASI_MFM_ACC_Verify__c  = sdr.Verify;
                }
                
                OrignalMap.get(sdr.recordId).ASI_MFM_Receipt_Date__c  = sdr.ReceiptDate!=null? date.parse(sdr.ReceiptDate): null;
                OrignalMap.get(sdr.recordId).ASI_MFM_Amount__c  = sdr.Amount!=null?  Decimal.valueOf(sdr.Amount.replace(',','')): null;
                //OrignalMap.get(sdr.recordId).ASI_MFM_Remark__c  = sdr.Remark!=null? sdr.Remark: null;
                OrignalMap.get(sdr.recordId).ASI_MFM_AP_Code__c = sdr.apCode!=null? Id.valueOf(sdr.apCode) : null; 
                //Count Verify line and display
                if(sdr.Verify){
                       count++;
                       verLines.add(OrignalMap.get(sdr.recordId).ASI_MFM_PO_Receipt__r.name);
                   }
                
            }
            
            LinesToUpdate.add(OrignalMap.get(sdr.recordId));
        }
        
        if(LinesToUpdate!=null && !LinesToUpdate.isEmpty() && LinesToUpdate!=null && LinesToUpdate.size()>0 ){
            
            Map<Id, ASI_MFM_PO_Receipt_Item__c> ValidatePORLMap = new Map<Id, ASI_MFM_PO_Receipt_Item__c>(LinesToUpdate);
            isRedirect =  valdationCheckingStep(ValidatePORLMap);
            
        } 
        
        if(!isRedirect){
            UpsertPermission = false;
            SaveSuccess = false;
            return null;
        }
        
        Map<Id, ASI_MFM_PO_Line_Item__c> update_ASI_MFM_PO_Lines = new Map<Id, ASI_MFM_PO_Line_Item__c>();
        
        if(OrignalMap!=null && !OrignalMap.isEmpty()){
            for(ASI_MFM_PO_Receipt_Item__c PORLine : OrignalMap.values()){
                
                ASI_MFM_PO_Line_Item__c updatePOLine = new ASI_MFM_PO_Line_Item__c(Id = PORLine.ASI_MFM_PO_Line_Item__c);
                if(PORLine.ASI_MFM_AP_Code__c!=null && (PORLine.ASI_MFM_AP_Code__c <> PORLine.ASI_MFM_PO_Line_Item__r.ASI_MFM_AP_Code__c)){
                    updatePOLine.ASI_MFM_AP_Code__c = PORLine.ASI_MFM_AP_Code__c;
                     if(APACMap.containsKey(PORLine.ASI_MFM_AP_Code__c)){
                        updatePOLine.ASI_MFM_A_C_Code__c=APACMap.get(PORLine.ASI_MFM_AP_Code__c);
                        PORLine.ASI_MFM_A_C_Code_temp__c=APACMap.get(PORLine.ASI_MFM_AP_Code__c);
                    }else{
                         PORLine.ASI_MFM_A_C_Code_temp__c=PORLine.ASI_MFM_PO_Line_Item__r.ASI_MFM_A_C_Code__c;
                    }

                    
                    update_ASI_MFM_PO_Lines.put(PORLine.ASI_MFM_PO_Line_Item__c, updatePOLine);
                }else{
                    PORLine.ASI_MFM_AP_Code__c=PORLine.ASI_MFM_PO_Line_Item__r.ASI_MFM_AP_Code__c;
                    PORLine.ASI_MFM_A_C_Code_temp__c=PORLine.ASI_MFM_PO_Line_Item__r.ASI_MFM_A_C_Code__c;
                }
                
                OrignalMap.put(PORLine.Id, PORLine);
            }
        }
        try{
            
            if(update_ASI_MFM_PO_Lines!=null && update_ASI_MFM_PO_Lines.size()>0){
                updatePOLinesResult = Database.upsert(update_ASI_MFM_PO_Lines.values());
            }

            
            Msg= count!=null && count>0? string.valueOf(count) + ' PO Receipt Line(s) verified. PO Receipt No. ' +verLines +'</br>': ' No selected PO Receipt line(s) is needed to be verified. ' +'</br>';
            
              
            if(LinesToUpdate!=null && LinesToUpdate.size()>0){
                updateTarget = Database.upsert(LinesToUpdate); 
                updateTarget.clear();
                LinesToUpdate.clear();                
            }
            
            
            if(OrignalMap!=null){
                lineItem = new List<ASI_MFM_PO_Receipt_Item__c>();
                lineItem.addAll(OrignalMap.values()); 
                LineItemJson = JSON.serialize(LineItem);
            }   
            UpsertPermission = true;            
        }catch(Exception e){
            msg += 'Save Error!'+  e.getMessage() +'</br>';
            UpsertPermission = false;
            SaveSuccess= false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Save Error!' + e));
            return null;
        }
        
        
        return pageRef;
        
       /*
        Integer count = 0;
        Integer idx=1;
        Set<String> verLines = new Set<String>();
         
        //Validation  Checking
   
        for (ASI_MFM_PO_Receipt_Item__c ver : LineItem) {
            
            verLines.add(ver.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.name);
            if (ver.ASI_MFM_Marketing_Verify__c == true ) {
                count++;
                verLines.add(ver.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.name);
            }
            
             Date selectedDate= date.newinstance(ver.ASI_MFM_PO_Receipt__r.CreatedDate.year(), ver.ASI_MFM_PO_Receipt__r.CreatedDate.month(),ver.ASI_MFM_PO_Receipt__r.CreatedDate.day());           
            Date firstDate =date.newinstance(integer.valueof('20'+ver.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c.substring(2,4)),7, 1); //Date firstDate = selectedDate.toStartOfMonth();
            if(ver.ASI_MFM_Receipt_Date__c<firstDate && ver.ASI_MFM_Receipt_Date__c!=null){
                SaveSuccess=false;
                Msg += 'Line ' + idx + ' : Receipt Date can not before the first day of this Fiscal Year.'+firstDate.format() +'</br>';
            }
            if(ver.ASI_MFM_Receipt_Date__c>selectedDate && ver.ASI_MFM_Receipt_Date__c!=null ){
                SaveSuccess=false;
                Msg += 'Line ' + idx + ' : Receipt Date can not after Created Date:' + selectedDate.format()+'.</br>';
            }
            idx++;
            
        }
        SaveSuccess=true;
        Msg=string.valueOf(count) + ' PO Receipt Line verified. PO No. ' +verLines;
   
        update LineItem;
        return null;*/
    }
    
    
    
    
    
    
    public Boolean valdationCheckingStep(Map<ID, ASI_MFM_PO_Receipt_Item__c> allLineItemMap){
        
        Boolean isProcess = true;
        Integer idx = 1; 
        
        Msg = '';
        if(allLineItemMap == null) return false;
        
        if(ASI_MFM_Function.bypassTriggersFunctionCache('ASI_MFM_JP_JDE_Accruals')) {
            for(ID key : allLineItemMap.keySet()){
                
                //Update Post G/L Date
                //Update 'Marketing_Verify' flag
                if(allLineItemMap.get(key).ASI_MFM_ACC_Verify__c){
                    if(allLineItemMap.get(key).ASI_MFM_Post_G_L_Date__c==null){
                        allLineItemMap.get(key).ASI_MFM_Post_G_L_Date__c=PostGLDate.ASI_MFM_Post_G_L_Date__c;
                    }
                    //allLineItemMap.get(key).ASI_MFM_Marketing_Verify__c=true;
                }else{
                    allLineItemMap.get(key).ASI_MFM_Post_G_L_Date__c=null;
                    //allLineItemMap.get(key).ASI_MFM_Marketing_Verify__c=false;
                }
            }
            
            Msg = '';
            return true;
        }else{
            for(ID key : allLineItemMap.keySet()){
                
                //Update Post G/L Date
                //Update 'Marketing_Verify' flag
                if(allLineItemMap.get(key).ASI_MFM_ACC_Verify__c){
                    //if(allLineItemMap.get(key).ASI_MFM_Post_G_L_Date__c==null){
                        allLineItemMap.get(key).ASI_MFM_Post_G_L_Date__c=PostGLDate.ASI_MFM_Post_G_L_Date__c;
                    //}
                    allLineItemMap.get(key).ASI_MFM_Marketing_Verify__c=true;
                }else{
                    allLineItemMap.get(key).ASI_MFM_Post_G_L_Date__c=null;
                    allLineItemMap.get(key).ASI_MFM_Marketing_Verify__c=false;
                }
                //----------------Update End----------------
                
                //Receipt Date can not be null
                if(allLineItemMap.get(key).ASI_MFM_Receipt_Date__c==null){
                    isProcess=false;
                    Msg += 'Line ' + idx + ' : Receipt Date can not be null'+'</br>';
                    allLineItemMap.get(key).ASI_MFM_Receipt_Date__c.adderror(' Receipt Date can not be null.');
                }
                
                
                //Requirement 1: PO Receipt Date needs to be in between 1st day of the current fiscal year and today’s date //Date selectedDate =  Date.today();
                Date selectedDate= date.newinstance(allLineItemMap.get(key).ASI_MFM_PO_Receipt__r.CreatedDate.year(), allLineItemMap.get(key).ASI_MFM_PO_Receipt__r.CreatedDate.month(),allLineItemMap.get(key).ASI_MFM_PO_Receipt__r.CreatedDate.day());           
                Date firstDate =date.newinstance(integer.valueof('20'+allLineItemMap.get(key).ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c.substring(2,4)),7, 1);
                
                if(allLineItemMap.get(key).ASI_MFM_Receipt_Date__c<firstDate && allLineItemMap.get(key).ASI_MFM_Receipt_Date__c!=null){
                    isProcess=false;
                    Msg += 'Line ' + idx + ' : Receipt Date can not before the first day of this Fiscal Year.'+firstDate.format() +'</br>';
                    allLineItemMap.get(key).ASI_MFM_Receipt_Date__c.adderror('Receipt Date can not before the first day of this Fiscal Year.');
                }
                if(allLineItemMap.get(key).ASI_MFM_Receipt_Date__c>selectedDate && allLineItemMap.get(key).ASI_MFM_Receipt_Date__c!=null ){
                    isProcess=false;
                    Msg += 'Line ' + idx + ' : Receipt Date can not after Created Date:' + selectedDate.format()+'.</br>';
                    allLineItemMap.get(key).ASI_MFM_Receipt_Date__c.adderror('Receipt Date can not after Created Date.');
                }
                
                
                // Requirement 2: PO Receipt Amount could be no more than 10% of the PO Line Amount  LineItemMapChecking
                // allLineItemMap.get(key).ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Currency__c=='JPY' &&
                if(allLineItemMap.get(key).ASI_MFM_Amount__c!=null && AmountCheckingMap.get(key)!=null){
                    //if(allLineItemMap.get(key).ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Currency__c=='JPY' && allLineItemMap.get(key).ASI_MFM_Amount__c!=null && LineItemMapChecking.get(key).ASI_MFM_Amount__c !=null){
                    if(allLineItemMap.get(key).ASI_MFM_PO_Line_Item__r.ASI_MFM_Amount__c>100000){
                        if(allLineItemMap.get(key).ASI_MFM_Amount__c>(AmountCheckingMap.get(key)+100000)){
                            isProcess=false;
                            Msg += 'Line ' + idx + ' : Receipt Amount > the PO Line Amount :'+AmountCheckingMap.get(key) +'</br>';
                            allLineItemMap.get(key).ASI_MFM_Amount__c.adderror('Please Check Receipt Amount.');
                        }
                        
                    }else{
                        if(allLineItemMap.get(key).ASI_MFM_Amount__c>(AmountCheckingMap.get(key)*1.1)){
                            isProcess=false;
                            Msg += 'Line ' + idx + ' : Receipt Amount > 10% more of the PO Line Amount :'+AmountCheckingMap.get(key) +'</br>';
                            allLineItemMap.get(key).ASI_MFM_Amount__c.adderror('Please Check Receipt Amount.');
                        }
                    }
                }
                
                
                
                //Receipt Amount can not be null
                if(allLineItemMap.get(key).ASI_MFM_Amount__c==null){
                    isProcess=false;
                    Msg += 'Line ' + idx + ' : Receipt Amount can not be null'+'</br>';
                    allLineItemMap.get(key).ASI_MFM_Amount__c.adderror(' Receipt Amount can not be null.');
                }
                
                
                idx++;
                
            }
            
        }
        
       
        return isProcess;
    }

    
    public String sortField {
        get  { if (sortField == null) {sortField = 'ASI_MFM_Receipt_Date__c'; } return sortField;  }
        set;
    }
    
    
    public String sortDir {
        get  { if (sortDir == null) {  sortDir = 'ASC'; } return sortDir;  }
        set;
    }
  /*
    public Integer maxPageNum { get { return maxNumOfPage(); } private set; }
    private Integer maxNumOfPage() {
        if (this.totalNumOfRecord == 0 || this.numOfRowInTable == 0)
            return 1;
        return ((this.totalNumOfRecord - 1) / this.numOfRowInTable) + 1;
    }
    */

}