public with sharing class ASI_MFM_PH_BAverifyController {
    
    public ASI_MFM_PH_BAverifyController(){}
    //-- search criteria --//
    public transient String BAVerify {get;set;}
    public transient String Plan_ID {get;set;}{Plan_ID=null;}
    public transient String PO_ID {get;set;}{PO_ID=null;}
    public transient String POLine_ID {get;set;}{POLine_ID=null;} 
    public transient String Creator {get;set;}{Creator=null;}
    public transient String Userfilter {get;set;}{Userfilter=null;}
    
    public transient String Suppl {get;set;}{Suppl=null;}
    public transient String ACCode {get;set;}{ACCode=null;}
    public transient String SBCode {get;set;}{SBCode=null;}
    
    public transient String Fiscalyear {get;set;}
    public String WhereStatm {get;set;}{WhereStatm = '';}
    public String NowFY {get;set;}
    public ASI_MFM_PO_Line_Item__c gl_fromDate { get; set; }
    public ASI_MFM_PO_Line_Item__c gl_toDate { get; set; }
    //-- End --//
    
    
    public String reportFolderid {get;set;}
    public static final String FolderName ='ASI MFM PH Report';
    
    //Page Information
    public boolean UpsertPermission {get;set;}
    public boolean SaveSuccess {get;set;}
    public String Msg {get;set;} {msg = '';}
    
    private String init_soql {get;set;} 
    
    //page Result
    public String jsonDataMinimal {set;get;} {jsonDataMinimal = null;}
    public String lineItemJson {get; set;} {lineItemJson = null;}
    public transient List<ASI_MFM_PO_Line_Item__c> LineItem {get; set;}
    public transient Map<Id, ASI_MFM_PO_Line_Item__c> PoLineMap { get; set; }  {PoLineMap = new  Map<Id, ASI_MFM_PO_Line_Item__c>();}
    
    
    public static final String selectedFields  =  'Select id,ASI_MFM_PO__r.owner.name,ASI_MFM_A_C_Code__r.Id,ASI_MFM_PO__r.ownerId, ASI_MFM_PO__r.CreatedBy.name,CreatedBy.name,ASI_MFM_Finance_Verify_Date__c,ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c,ASI_MFM_Synced__c,ASI_MFM_ETL_Date__c,name, ASI_MFM_PO__r.name,ASI_MFM_Base_Currency_Amount__c,ASI_MFM_Post_G_L_Date__c,ASI_MFM_PO__r.ASI_MFM_Exchange_Rate__c,ASI_MFM_Base_Currency_Remaining_Balance__c,ASI_MFM_PO__r.ASI_MFM_Plan__r.name,ASI_MFM_PO__r.ASI_MFM_PO_Name__c,ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Plan_Name__c,ASI_MFM_Sub_brand_Code__r.name,ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c,ASI_MFM_PO_Supplier_Number__c, ASI_MFM_PO__r.ASI_MFM_Plan__c, ASI_MFM_SG_BA_verify__c,ASI_MFM_PO__c,ASI_MFM_PO__r.ASI_MFM_Supplier_Name__c,ASI_MFM_PO__r.ASI_MFM_PO_Amount__c,ASI_MFM_Amount__c,ASI_MFM_List_Item_Description__c,ASI_MFM_A_C_Code__c,ASI_MFM_Currency__c,ASI_MFM_Remaining_Balance__c,ASI_MFM_G_L_Date__c from ASI_MFM_PO_Line_Item__c'; 
    public static final String mustWhereClause = ' where ASI_MFM_PO__r.ASI_MFM_Status__c = \'Final\'  AND ((ASI_MFM_PO_Amount__c > 0 AND ASI_MFM_Remaining_Balance__c > 0 AND ASI_MFM_Complete__c = false) OR (ASI_MFM_Complete__c = true AND ASI_MFM_All_Payment_Effective__c = false AND ASI_MFM_Adjustment_Line__c = false))';
    public static final String additionalGLDateClause = ' AND ASI_MFM_G_L_Date__c <= TODAY';
    public static final String PH_DF_PO_Developer_Name = 'ASI_MFM_PH_DF_PO';
    public static final String PH_DP_PO_Developer_Name = 'ASI_MFM_PH_DP_PO';
    public static final String DP_ACCode_RecordType_Developer_Name ='ASI_MFM_PH_DP_A_C_Code';
    public static final String DF_ACCode_RecordType_Developer_Name ='ASI_MFM_PH_DF_A_C_Code';

    public void defaultGLDate(List<ASI_MFM_PO_Line_Item__c> LineItems){
            Date selectedDate =  Date.today(); 
            Date firstDate = selectedDate.toStartOfMonth();
            
            for(ASI_MFM_PO_Line_Item__c line : LineItems){

                if(line.ASI_MFM_SG_BA_verify__c==false){
                    line.ASI_MFM_Post_G_L_Date__c= firstDate.addDays(date.daysInMonth(selectedDate.year() , selectedDate.month())  - 1);
                }                
            }
    }
    
    public void GenerateActualPORemaining(String recordTypeName , String AdditonalWhereClause) { // copy from ASI SG MFM BA Verify 

        
        UpsertPermission = true;
        SaveSuccess = false;
        
		transient List<ASI_MFM_PO_Line_Item__c> POLList = new List<ASI_MFM_PO_Line_Item__c>();
		transient Map<Id, ASI_MFM_PO_Line_Item__c> POLMap = new Map<Id, ASI_MFM_PO_Line_Item__c>();
		List<ASI_MFM_Payment_Line_Item__c> UpdatePALList = new List<ASI_MFM_Payment_Line_Item__c>();
		Database.upsertResult[] updateTarget;
		
		system.debug('RecordTypeName : ' + RecordTypeName);
		
		String init_po_soql_str = 'Select Id, ASI_MFM_Paid_Amount__c,ASI_MFM_Actual_Paid_Amouint__c';
		String init_po_where_str  = ' FROM ASI_MFM_PO_Line_Item__c WHERE ASI_MFM_PO__r.RecordType.DeveloperName LIKE \''+ recordTypeName  +'%\'' + ' AND ASI_MFM_PO__r.ASI_MFM_Status__c = \'Final\' AND  ASI_MFM_SG_BA_verify__c = false  AND ASI_MFM_Remaining_Balance__c > 0 AND ASI_MFM_All_Payment_Effective__c = false';
	    String init_payment_soql_str = '(Select id, ASI_MFM_Effective__c FROM Payment_Line_Items__r WHERE ASI_MFM_Effective__c != true AND ASI_MFM_Payment__r.ASI_MFM_G_L_Date__c <= TODAY AND ASI_MFM_Payment__r.ASI_MFM_Status__c  = \'Final\' )';	
	    
	    String database_query_soql = init_po_soql_str + ',' + init_payment_soql_str + init_po_where_str + AdditonalWhereClause  + (recordTypeName.contains('ASI_MFM_PH_DF')?additionalGLDateClause:'') ;
	    
	    system.debug('Generate Actual PO Remaining SOQL: ' +database_query_soql);
          
        //system.assertEquals(database_query_soql, null);  

        try {
                POLList = Database.query(database_query_soql);
                
                if(POLList!=null){

                    //SaveSuccess= true;
                     POLMap = new Map<Id, ASI_MFM_PO_Line_Item__c>( POLList);
                }
                
        } catch (Exception e) {
            //msg = 'No Records Found, Please Check your search input';
            //UpsertPermission = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No Records Found, Please Check your search input'));
        }
        
        if(POLList!=null && POLList.size()>0)
        for (ASI_MFM_PO_Line_Item__c POL: POLList) {
            
            if (POL.ASI_MFM_Paid_Amount__c != POL.ASI_MFM_Actual_Paid_Amouint__c) {
                 
                POLMap.put(POL.id, pol);
            }
  
        }
		
		
		if(!POLMap.isEmpty()){
		    
		    List<ASI_MFM_Payment_Line_Item__c> paymentLines = new  List<ASI_MFM_Payment_Line_Item__c>();
		    
		    for (ASI_MFM_PO_Line_Item__c POL: POLMap.values()) {
		        
		      
            
                paymentLines = POL.getSObjects('Payment_Line_Items__r'); 
                
                if(paymentLines!=null && paymentLines.size()>0)
                for(ASI_MFM_Payment_Line_Item__c paymentLine : paymentLines){
                    paymentLine.ASI_MFM_Effective__c = true;  
                    UpdatePALList.add(paymentLine);
                }
  
            }
		    
		}
		
        //Update
        System.Savepoint pSavepoint = Database.setSavepoint();
        
        try{   
            if(UpdatePALList!=null && UpdatePALList.size()>0)
                updateTarget = Database.upsert(UpdatePALList); //updateList);
                
        }catch(Exception e){
            msg = e.getMessage();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Save Error!' + e.getMessage()));
            Database.rollback(pSavepoint);      
            
        }		
		
    }
    
    public void initSOQL (String PO_Developer_Name ){
        
        
        reportFolderid =[SELECT Id FROM Folder WHERE Name =:FolderName And Type = 'Report']!=null? (String)[SELECT Id FROM Folder WHERE Name =:FolderName And Type = 'Report'][0].Id : '';
        

        //Get Current Fisacal Year
        NowFY='FY';
        Date Today_date=Date.today();
        if(Today_date.month()>0 && Today_date.month()<7){  
            NowFY=NowFY+string.valueof(Today_date.year()-1).substring(2,4)+string.valueof(Today_date.year()).substring(2,4);
        }else{
            NowFY=NowFY+string.valueof(Today_date.year()).substring(2,4)+string.valueof(Today_date.year()+1).substring(2,4);
        }
        Fiscalyear=NowFY;
        init_soql = selectedFields +  mustWhereClause  + ' AND ASI_MFM_PO__r.RecordType.DeveloperName LIKE \''+ PO_Developer_Name +'%\'';

        //Default as current Fiscal Year
        if(Fiscalyear!=null && Fiscalyear.length()>0){
            WhereStatm += ' and ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c LIKE \''+String.escapeSingleQuotes(Fiscalyear)+'%\'';
        }
        BAVerify='Unchecked';
         WhereStatm += ' and ASI_MFM_SG_BA_verify__c=false';
        
        if(PO_Developer_Name == PH_DF_PO_Developer_Name)
        whereStatm += additionalGLDateClause; // only GL <=Today 
        
        gl_fromDate = new ASI_MFM_PO_Line_Item__c ();
        gl_toDate = new ASI_MFM_PO_Line_Item__c ();
        
        GenerateActualPORemaining(PO_Developer_Name, ' and ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c LIKE \''+String.escapeSingleQuotes(Fiscalyear)+'%\'');       
        
    }
    
    
    public void initDF() { //for Duty Free
        initSOQL (PH_DF_PO_Developer_Name);
        runQuery();        
    }
    
    public void initDP() { //for Duty Paid
        initSOQL (PH_DP_PO_Developer_Name);
        runQuery();     
    }
    
    
    public void runQuery() {
        
        //UpsertPermission = true;
        //SaveSuccess = false;
        
        try {
            LineItem = Database.query(init_soql + WhereStatm);
            
            if(LineItem!=null){
                
                 defaultGLDate(LineItem);
                 LineItemJson = JSON.serialize(LineItem);
                 PoLineMap = new Map<Id, ASI_MFM_PO_Line_Item__c>(lineItem);
            
                 List<SmallDataRow> dataRows = new List<SmallDataRow>();  
                    
                 for(ASI_MFM_PO_Line_Item__c  poline : LineItem){  
                        SmallDataRow  inputFields = new SmallDataRow(poline); 
                        dataRows.add(inputFields);  
                 }  
                    
                 this.jsonDataMinimal = JSON.serialize(dataRows);     
                
            }else{
                
                this.LineItemJson = null;
                this.PoLineMap = null;
                this.jsonDataMinimal  =null; 
                
            }
        } catch (Exception e) {
            msg+='No Records Found, Please Check your search input'+'</br>';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No Records Found, Please Check your search input' +e.getMessage()));
        }
    }
    
    
    public PageReference runSearch() {
        
        WhereStatm = '';
        
        Map<String, String> params = ApexPages.currentPage().getParameters();
        
         String PORecordTypeStr = params.get('ASI_MFM_PH_PO_RECORD_TYPE');
       // WhereStatm += (PORecordTypeStr==null)?' and ASI_MFM_PO__r.RecordType.DeveloperName LIKE \'ASI_MFM_PH_DP_PO%\' ':' and ASI_MFM_PO__r.RecordType.DeveloperName LIKE \'ASI_MFM_PH_DF_PO%\' ';  
         String SearchRecordTYpe = (PORecordTypeStr!=null&& PORecordTypeStr=='DF')?PH_DF_PO_Developer_Name:PH_DP_PO_Developer_Name; 
        
         if(BAVerify!=null && BAVerify.length()>0){
             if(BAVerify=='Unchecked'){
                WhereStatm +=  ' and ASI_MFM_SG_BA_verify__c =false ';
            }
            if(BAVerify=='Checked'){
                WhereStatm +=  ' and ASI_MFM_SG_BA_verify__c =true ';
            }
        }
        
         if(Plan_ID!=null && Plan_ID.length()>0){
            WhereStatm += ' and ASI_MFM_PO__r.ASI_MFM_Plan__r.name LIKE \''+String.escapeSingleQuotes(Plan_ID)+'%\'';
        }
        
        if (PO_ID!=null && PO_ID.length()>0){
            WhereStatm += ' and ASI_MFM_PO__r.name LIKE \''+String.escapeSingleQuotes(PO_ID)+'%\'';
        }
        
        if (POLine_ID!=null && POLine_ID.length()>0){
            WhereStatm += ' and Name LIKE \''+String.escapeSingleQuotes(POLine_ID)+'%\'';
        }
        
        if (Suppl!=null && Suppl.length()>0){
            WhereStatm += ' AND ASI_MFM_PO__r.ASI_MFM_Supplier_Name__r.name LIKE \'%'+String.escapeSingleQuotes(Suppl)+'%\'';
        }
       
        
        if(Fiscalyear!=null && Fiscalyear.length()>0 && POLine_ID.length()==0 && PO_ID.length()==0 && Plan_ID.length()==0 && gl_fromDate.ASI_MFM_G_L_Date__c == null && gl_toDate.ASI_MFM_G_L_Date__c == null){
            WhereStatm += ' and ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c LIKE \''+String.escapeSingleQuotes(Fiscalyear)+'%\'';
        }
 
        if(ACCode!=null && ACCode.length()>0 ){
            WhereStatm += ' and ASI_MFM_A_C_Code__r.name LIKE \'%'+String.escapeSingleQuotes(ACCode)+'%\'';
        }
        
        if(SBCode!=null && SBCode.length()>0 ){
            WhereStatm += ' and ASI_MFM_Sub_brand_Code__r.name LIKE \'%'+String.escapeSingleQuotes(SBCode)+'%\'';
        }
        
        if(Userfilter!=null && Userfilter.length()>0 ){
            WhereStatm += ' AND ASI_MFM_PO__r.owner.name LIKE \'%'+String.escapeSingleQuotes(Userfilter)+'%\'';
        }
         if (gl_fromDate.ASI_MFM_G_L_Date__c != null) {
            String fromDate = DateTime.newInstance(gl_fromDate.ASI_MFM_G_L_Date__c.year(),gl_fromDate.ASI_MFM_G_L_Date__c.month(),gl_fromDate.ASI_MFM_G_L_Date__c.day(), 0,0,0).format('yyyy-MM-dd');
            WhereStatm += ' AND ASI_MFM_G_L_Date__c  >= ' + fromDate + ''; 
        }
        if (gl_toDate.ASI_MFM_G_L_Date__c != null) {
            String toDate = DateTime.newInstance(gl_toDate.ASI_MFM_G_L_Date__c.year(),gl_toDate.ASI_MFM_G_L_Date__c.month(),gl_toDate.ASI_MFM_G_L_Date__c.day(), 0,0,0).format('yyyy-MM-dd');
            WhereStatm += ' AND ASI_MFM_G_L_Date__c    <= ' + toDate + ''; 
        }
        
        GenerateActualPORemaining(SearchRecordTYpe, WhereStatm);
        
        runQuery();
        return null;
    }
    
    public PageReference save() {
        UpsertPermission = true;
        SaveSuccess=false;
        PageReference pageRef = null;
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String RecordTypeStr = params.get('ASI_MFM_PH_ACCODE_RECORD_TYPE');
        String SearchRecordType = (RecordTypeStr!=null&& RecordTypeStr=='DF')? DF_ACCode_RecordType_Developer_Name:DP_ACCode_RecordType_Developer_Name; 
         
                 
        Database.upsertResult[] updateTarget;
        List<ASI_MFM_PO_Line_Item__c> updateList = new List<ASI_MFM_PO_Line_Item__c>();
        //Count Number of line update
        Integer count = 0;
        Set<String> verLines = new Set<String>();
        
             if(LineItemJson!=null){
                 
                 LineItem = (List<ASI_MFM_PO_Line_Item__c>) JSON.deserialize(LineItemJson, List<ASI_MFM_PO_Line_Item__c>.class);

             }
         
             if(LineItem!=null){
                 
                     PoLineMap = new Map<Id, ASI_MFM_PO_Line_Item__c>(lineItem);
            }       
        
        
        //system.assertEquals(PoLineMap.size(), 21);
 
          List<ASI_MFM_PO_Line_Item__c> poLinesToUpdate = new List<ASI_MFM_PO_Line_Item__c>();  
          List<SmallDataRow> smallTableRow = (List<SmallDataRow>)JSON.deserialize(jsonDataMinimal, List<SmallDataRow>.class);  
          
          //for POST GL Date
          Date selectedDate =  Date.today(); 
          Date firstDate = selectedDate.toStartOfMonth();
          Boolean isRedirect = True; 
          
          for(SmallDataRow sdr : smallTableRow){  
               if(PoLineMap!=null){  // && sdr.BAVerify
                  // if(!PoLineMap.get(sdr.recordId).ASI_MFM_Synced__c){
                      PoLineMap.get(sdr.recordId).ASI_MFM_SG_BA_verify__c  = sdr.BAVerify;  
                      PoLineMap.get(sdr.recordId).ASI_MFM_Post_G_L_Date__c  = sdr.PostGLDate!=null? date.parse(sdr.PostGLDate): null;  //convert back to date format 
                 //  } 
                 
                   try{
                        PoLineMap.get(sdr.recordId).ASI_MFM_A_C_Code__c  = sdr.accodeId!=null? Id.valueOf(sdr.accodeId): null; 
                   }catch(Exception ex){
                        system.debug('---cannot find the relevant a_c_code---');
                   }
                   
                   if(sdr.BAVerify){
                       count++;
                       verLines.add(PoLineMap.get(sdr.recordId).ASI_MFM_PO__r.name);
                   }
                   else{
                       PoLineMap.get(sdr.recordId).ASI_MFM_Post_G_L_Date__c= firstDate.addDays(date.daysInMonth(selectedDate.year() , selectedDate.month())  - 1);
                   }
                    
                   poLinesToUpdate.add(PoLineMap.get(sdr.recordId));  
               }  
        }       

        
        if(poLinesToUpdate!=null && !poLinesToUpdate.isEmpty() && poLinesToUpdate!=null && poLinesToUpdate.size()>0 ){
       
            Map<Id, ASI_MFM_PO_Line_Item__c> ValidatePOLineMap = new Map<Id, ASI_MFM_PO_Line_Item__c>(poLinesToUpdate);
            isRedirect =  valdationCheckingStep(ValidatePOLineMap, SearchRecordType);
            
        } 
        
         if(!isRedirect){
            
            UpsertPermission = false;
            SaveSuccess = false;
            return null;
            
        }        
        //Update
        System.Savepoint pSavepoint = Database.setSavepoint();
        
        try{
            
            Msg= count!=null && count>0? string.valueOf(count) + ' PO Line(s) verified. PO No. ' +verLines +'</br>': ' No selected PO line(s) is needed to be verified. ' +'</br>';
            
            if(POLineMap!=null){
                lineItem = new List<ASI_MFM_PO_Line_Item__c>();
                lineItem.addAll(POLineMap.values()); 
                LineItemJson = JSON.serialize(LineItem);
            }   
            
            if(poLinesToUpdate!=null && poLinesToUpdate.size()>0){
                updateTarget = Database.upsert(poLinesToUpdate); //updateList);
                updateTarget.clear();
                poLinesToUpdate.clear();                
            }

            SaveSuccess=true;
            
        }catch(Exception e){
            msg += 'Save Error!'+  e.getMessage() +'</br>';
            UpsertPermission = false;
            SaveSuccess= false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Save Error!' + e));
            Database.rollback(pSavepoint);      
            return null;
        }
        return pageRef;
  
    }

    /*Method: For valdationCheckingStep*/   
    public Boolean valdationCheckingStep(Map<Id, ASI_MFM_PO_Line_Item__c> POLineMap , String SearchRecordType){
         
         Boolean isProcess = true;
         msg = ''; 
         Set<Id> ACCodes = new Set<Id>();
         
         if(POLineMap == null) return false; 
         
         for(ASI_MFM_PO_Line_Item__c poline : POLineMap.values()){
             
            
            if(poline.ASI_MFM_A_C_Code__c == null){
                isProcess = false;      
                poline.ASI_MFM_A_C_Code__c.addError('Please input A/C Code.');
                msg += 'Save Error: ('+ poline.Name + '): '+  ' Please input A/C Code.'  +'</br>';                
            }else{
                
                ACCodes.add(poline.ASI_MFM_A_C_Code__c);
            }
             
         }


        if(!ACCodes.isEmpty()){
            
            Map<Id, ASI_MFM_A_C_Code__c> acCodesMap = new Map<Id, ASI_MFM_A_C_Code__c> ([Select id, RecordType.DeveloperName from ASI_MFM_A_C_Code__c where Id in: ACCodes ]);
            
            for(ASI_MFM_PO_Line_Item__c poline : POLineMap.values()){
                
                 if(poline.ASI_MFM_A_C_Code__c != null && acCodesMap.containsKey(poline.ASI_MFM_A_C_Code__c) && acCodesMap.get(poline.ASI_MFM_A_C_Code__c).RecordType.DeveloperName<> SearchRecordType ){
                
                         isProcess = false;      
                         poline.ASI_MFM_A_C_Code__c.addError('Please input suitable A/C Code.');
                         msg +='Save Error: ('+  poline.Name + '): '+  ' Please input suitable A/C Code.'  +SearchRecordType+'</br>';                
                }
            }            
            
            ACCodes.clear();
        }
        
         return isProcess;
    }
    
    
     public class SmallDataRow {  
          public String  PostGLDate {set;get;}
          public Id recordId { get; set; }  
          public boolean BAVerify {get;set;}
          public String accodeId {set;get;}
            
          public SmallDataRow(ASI_MFM_PO_Line_Item__c poline){  
               this.PostGLDate =  poline.ASI_MFM_Post_G_L_Date__c!=null? poline.ASI_MFM_Post_G_L_Date__c.format():null; //convert date to string format before sync to page 
               this.recordId =  poline.Id;  
               this.BAVerify = poline.ASI_MFM_SG_BA_verify__c;
               this.accodeId = String.valueOf(poline.ASI_MFM_A_C_Code__r.Id);
          }  
     }   
     

 
    
}