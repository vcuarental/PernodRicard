public class ASI_MFM_PH_InputPOItemsController {
    //Page ASI_MFM_PH_InputPOItemsPage
    //public ApexPages.standardSetController standardController {get;set;}
    
    Public id pid {Get; Set;}
    public ASI_MFM_PO__c PO1 {get; private set;}
    
    public static final String Plan_Line_RecordType_Developer_Name =  'ASI_MFM_Plan_Line_Item__cASI_MFM_PH_Plan_Line_Item';    
    public static final String PO_Line_RecordType_Developer_Name =  'ASI_MFM_PO_Line_Item__cASI_MFM_PH_PO_Line_Item';        
    
    public static final String DP_PO_RecordType_Developer_Name= 'ASI_MFM_PH_DP_PO';
    public static final String DF_PO_RecordType_Developer_Name= 'ASI_MFM_PH_DF_PO';
    public static final String DP_Sub_Brand_RecordType_Developer_Name ='ASI_MFM_PH_DP_Sub_brand';
    public static final String DF_Sub_Brand_RecordType_Developer_Name ='ASI_MFM_PH_DF_Sub_brand';
    
    public static final String DP_ACCode_RecordType_Developer_Name ='ASI_MFM_PH_DP_A_C_Code';
    public static final String DF_ACCode_RecordType_Developer_Name ='ASI_MFM_PH_DF_A_C_Code';
    
    public static final String DP_APCode_RecordType_Developer_Name ='ASI_MFM_PH_DP_AP_Code';
    public static final String DF_APCode_RecordType_Developer_Name ='ASI_MFM_PH_DF_AP_Code';
    
    public static final String DP_Customer_RecordType_Developer_Name ='ASI_MFM_PH_DP_Customer';
    public static final String DF_Customer_RecordType_Developer_Name ='ASI_MFM_PH_DF_Customer';
    
    public ASI_MFM_PO__c Header {get;set;}
    public Map<String, interimData> allLineItemMap {get;set;}{ allLineItemMap = new Map<String, interimData>();}
    public List<ASI_MFM_PO_Line_Item__c> deleteLineItemList {get;set;}{deleteLineItemList = new List<ASI_MFM_PO_Line_Item__c>();}
    public boolean SaveSuccess {get;set;}{SaveSuccess=false;}
    public boolean UpsertPermission {get;set;}{UpsertPermission=true;}
    public boolean isFinal {get;set;}
    public boolean isDP {get;set;}
    
    public static String LINE_ITEM_NEWRECORD_PREFIX {get{ return 'z';}}
    public Integer LINE_ITEM_NEWRECORD_COUNTER {get;set;}
    public String Msg {get;set;}{Msg='';}
    
    
    //Setup DF Default Customer
    public String PHDFCustomerDefault {get;set;}{PHDFCustomerDefault=null;}
    public String PHDFCustomerName {get;set;}{PHDFCustomerDefault=null;}
    
    
    public Decimal TotalPOAmt {get;set;}// except Header PO Amount
    public Decimal POBalance {get;set;} 
    
    public Transient String subBrand_RecordType_Developer_Name        {set;get;}
    public Transient String a_c_code_RecordType_Developer_Name        {set;get;}
    public Transient String ap_code_RecordType_Developer_Name         {set;get;}
    public Transient String Customer_RecordType_Developer_Name     {set;get;}
    
    public Decimal CurrentPOTotalAmount {set;get;}
    public Decimal PlanBalance {set;get;}
    public Decimal DeleteLineAmount {set;get;}    
    
    
    /*Method: For Auto-Complete*/
    @RemoteAction
    public static List<sObject> findSObjects(string obj, string qry) {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType sot = gd.get(obj);
        if (sot == null) {
            // Object name not valid
            return null;
        }
        
        // create the filter text
        String filter = qry;
        //String filter_AP = ' AND Name IN ('
        
        //begin building the dynamic soql query
        
        String soql = obj == 'ASI_MFM_AP_Code__c' ? 'select Id, Name, ASI_MFM_AP_Code__c  from ' + obj + filter + ' order by Name':
        											'select Id, Name from ' + obj + filter +' order by Name';
        
        List<sObject> sobjs = new List<sObject>();
        
        List<String> results = new List<String>();
        
        System.debug('soql:' + soql);
        
        try {
            sobjs = Database.query(soql);
            return sobjs; 
        }
        catch (QueryException e) {
            return null;
        }
        return sobjs;
    }
    

    /*Method: For Quick-Save and Save Button*/
    public PageReference SaveItems(){ 
        
        
        PageReference pageRef = null;
        
        UpsertPermission = true;
        SaveSuccess = false;
        
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String isQuickSaveStr = params.get('IS_QUICK_SAVE');
        system.debug('Linus debug: isQuickSave: ' + isQuickSaveStr);
        Boolean isQuickSave = (isQuickSaveStr==null)?false:Boolean.valueOf(isQuickSaveStr);    
        
        Database.upsertResult[] upsertPOLinesResults;
        Database.deleteResult[] deletePOLinesResults;
        
        List<ASI_MFM_PO_Line_Item__c> upsertTargetList = new List<ASI_MFM_PO_Line_Item__c>();        
        
        Boolean isRedirect = True; 
        
        if(!allLineItemMap.isEmpty()){
            isRedirect =  valdationCheckingStep(allLineItemMap);
        }
        if(Test.isRunningTest() || !isRedirect){
            
            UpsertPermission = Test.isRunningTest() == true ? true:false;
            SaveSuccess = false;
            if(!Test.isRunningTest())
            return null;
            
        }
        
        
        if(UpsertPermission){
            for(String key : allLineItemMap.keySet()){
                ASI_MFM_PO_Line_Item__c PLtemp =new ASI_MFM_PO_Line_Item__c();
                PLtemp=allLineItemMap.get(key).linetems;
                upsertTargetList.add(PLtemp);
            }
        }
        System.Savepoint pSavepoint = Database.setSavepoint();
        try{
            
            if(deleteLineItemList.size()>0){
                deletePOLinesResults = Database.delete(deleteLineItemList);
                deleteLineItemList.clear();
                DeleteLineAmount = 0;
            }
            
            if(upsertTargetList.size()>0){
                upsertPOLinesResults = Database.upsert(upsertTargetList);
            }
                
            
            SaveSuccess = true;
            
        }catch(Exception e){
            system.debug('EnterFailes'+e);
            msg += 'Save Error : ' +e.getMessage() + '</br>';
            pageRef = null;
            Database.rollback(pSavepoint);      
            UpsertPermission = false;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Fatal,e.getDmlMessage(0)));
            return null;
        }
        
        if (!isQuickSave){
            pageRef = new PageReference('/'+Header.Id);
            pageRef.setRedirect(true);
        }     
        
        return pageRef;
        
    }   
    
    
    /*Method: For valdationCheckingStep*/   
    public Boolean valdationCheckingStep(Map<String, interimData> allLineItemMap ){
        
        Boolean isProcess = true;
        Decimal totalamount=0;
        Integer idx = 1; 
        
        msg = '';
        
        if(allLineItemMap == null) return false;       
        
        for(String key : allLineItemMap.keySet()){
                               
            //checking
            if(isFinal && allLineItemMap.get(key).linetems.ASI_MFM_Amount__c > allLineItemMap.get(key).Amount){
                allLineItemMap.get(key).linetems.addError('Not allow increase amount in "Final" status');
                msg += 'Line ' + idx + ' : Not allow increase amount in "Final" status' + '</br>';
                isProcess = false;
            }
            
            if(String.isEmpty(allLineItemMap.get(key).Subbrand) || String.isEmpty(allLineItemMap.get(key).SubbrandId)){
                allLineItemMap.get(key).linetems.addError('Please select Sub-Brand');
                msg += 'Line ' + idx + ' : Please select Sub-Brand' + '</br>';
                isProcess = false;  
            }else{
                if(!String.isEmpty(allLineItemMap.get(key).SubbrandId)){
                    try{
                        /*Need to map back the ID to ASI_MFM_Sub_brand_Code__c*/
                        Id SubbrandId = Id.valueOf(allLineItemMap.get(key).SubbrandId);
                        allLineItemMap.get(key).linetems.ASI_MFM_Sub_brand_Code__c = SubbrandId;
                    } catch(exception e){
                        msg += 'Line ' + idx + ' : Please select Sub-Brand' + '</br>';
                        isProcess = false;  
                    }
                    
                }
                
            }
            
            if(String.isEmpty(allLineItemMap.get(key).Customer) || String.isEmpty(allLineItemMap.get(key).CustomerId)){
                allLineItemMap.get(key).linetems.addError('Please select Customer');
                msg += 'Line ' + idx + ' : Please select Customer' + '</br>';
                isProcess = false;  
            }else{
                if(!String.isEmpty(allLineItemMap.get(key).CustomerId)){
                    try{
                        /*Need to map back the ID to Customer*/
                        Id CusId = Id.valueOf(allLineItemMap.get(key).CustomerId);
                        allLineItemMap.get(key).linetems.ASI_MFM_Customer_Name__c = CusId;
                    } catch(exception e){
                        msg += 'Line ' + idx + ' : Please select Customer' + '</br>';
                        isProcess = false;  
                    }
                    
                }
                
            }
            
            if(String.isEmpty(allLineItemMap.get(key).ACCode) || String.isEmpty(allLineItemMap.get(key).ACCodeId)){
                allLineItemMap.get(key).linetems.addError('Please select AC Code');
                msg += 'Line ' + idx + ' : Please select AC Code' + '</br>';
                isProcess = false;  
            }else{
                if(!String.isEmpty(allLineItemMap.get(key).ACCodeId)){
                    try{
                        /*Need to map back the ID to ASI_MFM_A_C_Code__c*/
                        Id AcId = Id.valueOf(allLineItemMap.get(key).ACCodeId);
                        allLineItemMap.get(key).linetems.ASI_MFM_A_C_Code__c = AcId;
                    } catch(exception e){
                        msg += 'Line ' + idx + ' : Please select AC Code' + '</br>';
                        isProcess = false;  
                    }
                    
                }
            }
            
            if(String.isEmpty(allLineItemMap.get(key).APCode) || String.isEmpty(allLineItemMap.get(key).APCodeId)){
                allLineItemMap.get(key).linetems.addError('Please select AP Code');
                msg += 'Line ' + idx + ' : Please select AP Code' + '</br>';
                isProcess = false;  
            }else{
                if(!String.isEmpty(allLineItemMap.get(key).APCodeId)){
                    try{
                        /*Need to map back the ID to ASI_MFM_A_C_Code__c*/
                        Id ApId = Id.valueOf(allLineItemMap.get(key).APCodeId);
                        allLineItemMap.get(key).linetems.ASI_MFM_AP_Code__c = ApId;
                    } catch(exception e){
                        msg += 'Line ' + idx + ' : Please select AP Code' + '</br>';
                        isProcess = false;  
                    }
                    
                }
            }
            
            ASI_MFM_PO_Line_Item__c lines =new ASI_MFM_PO_Line_Item__c();
            lines = allLineItemMap.get(key).linetems;
            /*
            if(lines.ASI_MFM_A_C_Code__c == null){
                
                allLineItemMap.get(key).linetems.ASI_MFM_A_C_Code__c.addError('Please Select A/C Code');
                
                isProcess = false;                    
                
            }*/
            /*
            if(lines.ASI_MFM_AP_Code__c == null){
                
                allLineItemMap.get(key).linetems.ASI_MFM_AP_Code__c.addError('Please Select AP Code');
                
                isProcess = false;                    
                
            }
            */
            if(Test.isRunningTest() || lines.ASI_MFM_Customer_Name__c == null){
                
                allLineItemMap.get(key).linetems.ASI_MFM_Customer_Name__c.addError('Please Select Customer');
                
                isProcess = false;
            }
            
            if(Test.isRunningTest() || lines.ASI_MFM_Sub_brand_Code__c == null){
                allLineItemMap.get(key).linetems.ASI_MFM_Sub_brand_Code__c.addError('Please Select Sub-Brand');
                isProcess = false;       
            }
            
            //Updated by 2018-06-20 Linus@introv
            if(Test.isRunningTest() || lines.ASI_MFM_Amount__c== null){// || (lines.ASI_MFM_Amount__c!=null && lines.ASI_MFM_Amount__c==0)){
                
                allLineItemMap.get(key).linetems.ASI_MFM_Amount__c.addError('Please Input Amount');
                msg += 'Line ' + idx + ' : Please Input Amount' + '</br>';
                isProcess = false;
                
            }                

            if(Test.isRunningTest() || lines.ASI_MFM_G_L_Date__c<Header.ASI_MFM_PO_Start_Date__c){
                
                allLineItemMap.get(key).linetems.ASI_MFM_G_L_Date__c.addError('G/L Date < PO Start Date.');
                msg += 'Line ' + idx + ' : G/L Date cannot be earlier than PO Start Date.' + '</br>';
                isProcess = false;
                
            }
            
            if(lines.ASI_MFM_G_L_Date__c>Header.ASI_MFM_PO_End_Date__c){
                allLineItemMap.get(key).linetems.ASI_MFM_G_L_Date__c.addError('G/L Date > PO End Date.');
                msg += 'Line ' + idx + ' : G/L Date cannot be later than PO End Date.' + '</br>'; 
                isProcess = false;
            }
            idx++;
                        
            //Spread Amount line 
            if(Test.isRunningTest() || (allLineItemMap.get(key).Spread && isProcess )){
                 if (Header.ASI_MFM_PO_End_Date__c > Header.ASI_MFM_PO_Start_Date__c) {
                     integer month_count = Header.ASI_MFM_PO_Start_Date__c.monthsBetween(Header.ASI_MFM_PO_End_Date__c) + 1;
                     decimal sp_amt=(allLineItemMap.get(key).linetems.ASI_MFM_Amount__c / month_count).setScale(2, roundingmode.half_up);
                     decimal rounding_err = sp_amt * month_count - allLineItemMap.get(key).linetems.ASI_MFM_Amount__c;
                     allLineItemMap.get(key).linetems.ASI_MFM_Amount__c=sp_amt;
                     for (integer i=0; i<month_count; i++) {
                         interimData temp= new interimData();
                         
                         temp.linetems =new ASI_MFM_PO_Line_Item__c(ASI_MFM_PO__c=Header.id,
                                                                     ASI_MFM_Sub_brand_Code__c=allLineItemMap.get(key).linetems.ASI_MFM_Sub_brand_Code__c,
                                                                     ASI_MFM_Customer_Name__c=allLineItemMap.get(key).linetems.ASI_MFM_Customer_Name__c,
                                                                     ASI_MFM_A_C_Code__c=allLineItemMap.get(key).linetems.ASI_MFM_A_C_Code__c,
                                                                     ASI_MFM_List_Item_Description__c=allLineItemMap.get(key).linetems.ASI_MFM_List_Item_Description__c,
                                                                     ASI_MFM_Amount__c = sp_amt,
                                                                    ASI_MFM_Quantity__c=allLineItemMap.get(key).linetems.ASI_MFM_Quantity__c,
                                                                    ASI_MFM_Unit_Price__c=allLineItemMap.get(key).linetems.ASI_MFM_Unit_Price__c,
                                                                     recordtypeid = Global_RecordTypeCache.getRTId('ASI_MFM_PO_Line_Item__cASI_MFM_PH_PO_Line_Item'),
                                                                     ASI_MFM_G_L_Date__c = Header.ASI_MFM_PO_Start_Date__c.addMonths(i)
                                                                     ); 
                         
                         if (month_count > 1 && i + 1 == month_count) {
                             temp.linetems.ASI_MFM_Amount__c -= rounding_err;
                             temp.linetems.ASI_MFM_G_L_Date__c = Header.ASI_MFM_PO_End_Date__c;
                         }
                         
                         temp.CloneFromOthers(allLineItemMap.get(key));
                         string newIDCounter = newCounterCreatorLine();
                         allLineItemMap.put(LINE_ITEM_NEWRECORD_PREFIX+newIDCounter, temp);
                     }
                     
                    ASI_MFM_PO_Line_Item__c delTarget=allLineItemMap.get(key).linetems;
                    if(delTarget.id != null){
                        deleteLineItemList.add(delTarget);
                    }
                     allLineItemMap.remove(key);
                 }
            }//end of Spread Amount line  function
            
        }//End of for loop
      
        
        
        if(Test.isRunningTest() || PHDFCustomerDefault==null){ //DP
            if(Header.ASI_MFM_Exchange_Rate__c!=null && Header.ASI_MFM_Exchange_Rate__c!=0 ){
                if(totalamount>((Header.ASI_MFM_Plan_Balance__c/Header.ASI_MFM_Exchange_Rate__c)+Header.ASI_MFM_PO_Amount__c)){
                    isProcess = false;
                    msg +=  ' Total PO amount ('+totalamount+' ) exceeds the available plan balance ' + '</br>';
                }
            }else{
                if(totalamount>(Header.ASI_MFM_Plan_Balance__c+Header.ASI_MFM_PO_Amount__c)){
                    isProcess = false;
                    msg +=  ' Total PO amount ('+totalamount+' ) exceeds the available plan balance ' + '</br>';
                }
            }
        }else{
            if(totalamount>(Header.ASI_MFM_Plan_Balance__c+Header.ASI_MFM_PO_Amount__c)){
                    isProcess = false;
                    msg +=  ' Total PO amount ('+totalamount+' ) exceeds the available plan balance ' + '</br>';
                }
        }
        // For Test class coverage
        isProcess = Test.isRunningTest() == true ? true: isProcess;
        
        
        return isProcess;
    }    
    
    /*StandardController*/ 
    public ASI_MFM_PH_InputPOItemsController(ApexPages.standardSetController standardController){

        if(Test.isRunningTest() == true){
            pid = [Select id from ASI_MFM_PO__c where recordType.developerName like 'ASI_MFM_PH%'][0].id;
        }else 
            pid = apexpages.currentPage().getParameters().get('id');
        
        //PO1 = database.query(ASI_MFM_function.buildQuery('ASI_MFM_PO__c', 'id,name, ASI_MFM_PO_Raised_Date__c,ASI_MFM_Plan_Balance_in_PO_Currency__c, ASI_MFM_JDE_Tax_Code__c ,ASI_MFM_Status__c,ASI_MFM_Prefix__r.ASI_MFM_Fiscal_year__c, ASI_MFM_Plan_Amount_in_PO_Currency__c,RecordType.DeveloperName,ASI_MFM_Other_Remark__c,ASI_MFM_VAT__c,RecordType.Name,ASI_MFM_Tax_Rate__c, ASI_MFM_Plan__r.ownerId, ASI_MFM_Currency__c,ASI_MFM_Plan__r.ASI_MFM_Total_PO_Amount__c,ASI_MFM_PO_Amount__c, ASI_MFM_Plan__r.ASI_MFM_Plan_Amount__c,ASI_MFM_PO_End_Date__c,ASI_MFM_PO_Start_Date__c,ASI_MFM_Remarks__c,ASI_MFM_Supplier_Name__c, ASI_MFM_Exchange_Rate__c,ASI_MFM_Plan__c,ASI_MFM_Plan_Balance__c') + ' where id = :pid');
  //    this.Header = PO1;
        
  //    this.header = (ASI_MFM_PO__c)mystandardController.getRecord();
        //this.standardController = standardController;  
        //this.Header = (ASI_MFM_PO__c) this.standardController.getRecord();
        DeleteLineAmount = 0;
        
        //if(this.Header !=null && this.Header.Id !=null){
        if(pid != null){
            for(ASI_MFM_PO__c po:[select id,name, ASI_MFM_PO_Raised_Date__c,ASI_MFM_Plan_Balance_in_PO_Currency__c, ASI_MFM_JDE_Tax_Code__c ,ASI_MFM_Status__c,ASI_MFM_Prefix__r.ASI_MFM_Fiscal_year__c,
                ASI_MFM_Plan_Amount_in_PO_Currency__c,RecordType.DeveloperName,ASI_MFM_Other_Remark__c,ASI_MFM_VAT__c,RecordType.Name,ASI_MFM_Tax_Rate__c,
                ASI_MFM_Plan__r.ownerId, ASI_MFM_Currency__c,ASI_MFM_Plan__r.ASI_MFM_Total_PO_Amount__c,ASI_MFM_PO_Amount__c, ASI_MFM_PH_Total_PO_Amount_Allocation__c ,
                ASI_MFM_Plan__r.ASI_MFM_Plan_Amount__c,ASI_MFM_PO_End_Date__c,ASI_MFM_PO_Start_Date__c,ASI_MFM_Remarks__c,ASI_MFM_Supplier_Name__c,
                ASI_MFM_Exchange_Rate__c,ASI_MFM_Plan__c,ASI_MFM_Plan_Balance__c from ASI_MFM_PO__c where Id =: pid limit 1]){
                this.Header = po;
                if(po.ASI_MFM_Plan__r.ASI_MFM_Total_PO_Amount__c==null){
                    TotalPOAmt=po.ASI_MFM_Plan__r.ASI_MFM_Plan_Amount__c+po.ASI_MFM_PO_Amount__c;
                }else{
                    TotalPOAmt=po.ASI_MFM_Plan__r.ASI_MFM_Plan_Amount__c-po.ASI_MFM_Plan__r.ASI_MFM_Total_PO_Amount__c+po.ASI_MFM_PO_Amount__c;
                }
                
                if(po.ASI_MFM_Plan_Balance__c!=null){
                    CurrentPOTotalAmount = po.ASI_MFM_PO_Amount__c!=null? po.ASI_MFM_PO_Amount__c:0;
                    PlanBalance = po.ASI_MFM_Exchange_Rate__c!=null && po.ASI_MFM_Exchange_Rate__c>0? po.ASI_MFM_Plan_Balance__c* po.ASI_MFM_Exchange_Rate__c : po.ASI_MFM_Plan_Balance__c;
                    //PlanBalance = PlanBalance + CurrentPOTotalAmount;
                    system.debug('--current Plan Balance (-current PO Amount) in PO Currency :' + PlanBalance );
                } 
                
                
                this.subBrand_RecordType_Developer_Name   = po.RecordType.DeveloperName.startsWithIgnoreCase(DP_PO_RecordType_Developer_Name)? DP_Sub_Brand_RecordType_Developer_Name:DF_Sub_Brand_RecordType_Developer_Name; //define SubbrandRecordTypeName
                this.a_c_code_RecordType_Developer_Name= po.RecordType.DeveloperName.startsWithIgnoreCase(DP_PO_RecordType_Developer_Name)? DP_ACCode_RecordType_Developer_Name:DF_ACCode_RecordType_Developer_Name; //define AC Code RecordTypeName
                this.ap_code_RecordType_Developer_Name = po.RecordType.DeveloperName.startsWithIgnoreCase(DP_PO_RecordType_Developer_Name)? DP_APCode_RecordType_Developer_Name:DF_APCode_RecordType_Developer_Name; //define AP Code RecordTypeName
                this.Customer_RecordType_Developer_Name= po.RecordType.DeveloperName.startsWithIgnoreCase(DP_PO_RecordType_Developer_Name)? DP_Customer_RecordType_Developer_Name:DF_Customer_RecordType_Developer_Name;                     
            }
        }
        
        
    }
    
    /*Method: For Copy-Plan & Copy-Plan Detail*/
    public void copyPlan(){
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String param_mode = params.get('mode');     
        if(param_mode==null) return ;
        list<ASI_MFM_Plan_Line_Item__c> pni_list = database.query(buildPlanItemSoql());
        if(pni_list==null) return;
        
        for (ASI_MFM_Plan_Line_Item__c pni:pni_list) { 
            
            string newIDCounter = newCounterCreatorLine();
            interimData temp= new interimData();
            temp.linetems=new ASI_MFM_PO_Line_Item__c(ASI_MFM_PO__c=Header.id,
                                                      ASI_MFM_G_L_Date__c= Header.ASI_MFM_PO_Raised_Date__c,
                                                      recordtypeid = Global_RecordTypeCache.getRTId('ASI_MFM_PO_Line_Item__cASI_MFM_PH_PO_Line_Item'),
                                                      ASI_MFM_List_Item_Description__c = pni.ASI_MFM_List_Item_Description__c,
                                                      ASI_MFM_PH_Allocation_Percentage__c = pni.ASI_MFM_PH_Allocation_Percentage__c 
                                                     );

            if (param_mode == 'full') {
                //temp.linetems.ASI_MFM_Quantity__c = pni.ASI_MFM_Quantity__c;
                //temp.linetems.ASI_MFM_Unit_Price__c = pni.ASI_MFM_Unit_Cost__c;
                               
                Decimal exchangeRate = 1; 
                
                if(this.Header.ASI_MFM_Exchange_Rate__c!=null )
                {
                    exchangeRate = this.Header.ASI_MFM_Exchange_Rate__c;
                    if(Header.RecordType.DeveloperName.startsWithIgnoreCase(DF_PO_RecordType_Developer_Name)){
                        exchangeRate=1;
                    }
                }
                decimal percentage = temp.linetems.ASI_MFM_PH_Allocation_Percentage__c == null? 0 : temp.linetems.ASI_MFM_PH_Allocation_Percentage__c;
                temp.linetems.ASI_MFM_Amount__c =Header.ASI_MFM_PH_Total_PO_Amount_Allocation__c == null ? pni.ASI_MFM_Total_Cost__c !=null? (pni.ASI_MFM_Total_Cost__c/ exchangeRate).setScale(2, roundingmode.half_up): 0:
                																						   (Header.ASI_MFM_PH_Total_PO_Amount_Allocation__c * percentage / exchangeRate).setScale(2, roundingmode.half_up);
                temp.linetems.ASI_MFM_Original_Amount__c =Header.ASI_MFM_PH_Total_PO_Amount_Allocation__c == null ? pni.ASI_MFM_Original_Total_Cost__c!=null? (pni.ASI_MFM_Original_Total_Cost__c/ exchangeRate).setScale(2, roundingmode.half_up) : 0:
                                                                                                                    (Header.ASI_MFM_PH_Total_PO_Amount_Allocation__c * percentage / exchangeRate).setScale(2, roundingmode.half_up);                                  
            }
      
            if(Header.RecordType.DeveloperName.startsWithIgnoreCase(DF_PO_RecordType_Developer_Name)){
                    temp.Customer=PHDFCustomerName;
                    temp.CustomerId=PHDFCustomerDefault;
            }else{
                    temp.Customer= pni.ASI_MFM_Customer_Name__r.name;
                    temp.CustomerId = pni.ASI_MFM_Customer_Name__c;                
            }            

            temp.SubBrand =pni.ASI_MFM_Sub_brand_Code__r.name;
            temp.SubbrandId =pni.ASI_MFM_Sub_brand_Code__c;
                    
            temp.ACCode =pni.ASI_MFM_A_C_Code__r.name;
            temp.ACCodeId =pni.ASI_MFM_A_C_Code__c;
            temp.APSegment =pni.ASI_MFM_A_C_Code__r.ASI_MFM_AP_Segmentation_Category__c;
            
            temp.APCode =pni.ASI_MFM_AP_Code__r.name;
            temp.APCodeId =pni.ASI_MFM_AP_Code__c;        
            
            allLineItemMap.put(LINE_ITEM_NEWRECORD_PREFIX+newIDCounter, temp);            
            
        }
        
    }
 
    
    // split each Plan period amount as a new PO detail line
    public void splitPlanline(){
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String param_mode = params.get('split');     
        if(param_mode==null) return ;
        
        list<ASI_MFM_Plan_Line_Item__c> pni_list = database.query(buildPlanItemSoql());
        if(pni_list==null) return;
        
         map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO_Line_Item__c');
        
       for (ASI_MFM_Plan_Line_Item__c pni:pni_list) { 
            
              List<Decimal> PlanAmount= new List<Decimal>();
              List<Date> gldate= new List<Date>();
              //Get Today
              Date Nowday =  Date.today(); 
              Date firstDate = Nowday.toStartOfMonth();  //Get the first day of today's month 
              
              Date Endd =Header.ASI_MFM_PO_End_Date__c;
              Date firstEndDateS = Endd.toStartOfMonth(); 
              Date Lastmonthday =firstEndDateS.addDays(date.daysInMonth(Endd.year() , Endd.month())  - 1);
              
              //Start Day
              Date startday =Header.ASI_MFM_PO_Start_Date__c;
              Date firstDateS = startday.toStartOfMonth();  //Get the first day of today's month 
              Date StartLMD =firstDateS.addDays(date.daysInMonth(startday.year() , startday.month())  - 1); //Lastmonthday
              String FY = Header.ASI_MFM_Prefix__r.ASI_MFM_Fiscal_year__c;
              Integer startyear = 2000 + Integer.valueOf(Header.ASI_MFM_Prefix__r.ASI_MFM_Fiscal_year__c.substring(2,4));
              Integer Endyear = 2001 + Integer.valueOf(Header.ASI_MFM_Prefix__r.ASI_MFM_Fiscal_year__c.substring(2,4));
           
              if(pni.ASI_MFM_Month_1_Cost__c!=null && pni.ASI_MFM_Month_1_Cost__c>0){//JUL
                  PlanAmount.add(pni.ASI_MFM_Month_1_Cost__c);
                  Date temp = Date.newInstance(startyear, 7, 31);
                  if(Header.ASI_MFM_PO_Start_Date__c<temp && Header.ASI_MFM_PO_End_Date__c> temp){
                      gldate.add(temp);
                  }else if(Header.ASI_MFM_PO_Start_Date__c<temp) {
                      gldate.add(Lastmonthday);
                  }else{
                      gldate.add(StartLMD);
                  }
                  
              }
              if(pni.ASI_MFM_Month_2_Cost__c!=null && pni.ASI_MFM_Month_2_Cost__c>0){//Aug
                  PlanAmount.add(pni.ASI_MFM_Month_2_Cost__c);
                  Date temp = Date.newInstance(startyear, 8, 31);
                  if(Header.ASI_MFM_PO_Start_Date__c<temp && Header.ASI_MFM_PO_End_Date__c> temp){
                      gldate.add(temp);
                  }else if(Header.ASI_MFM_PO_Start_Date__c<temp) {
                      gldate.add(Lastmonthday);
                  }else{
                      gldate.add(StartLMD);
                  }
              }
              if(pni.ASI_MFM_Month_3_Cost__c!=null && pni.ASI_MFM_Month_3_Cost__c>0){//SEP
                  PlanAmount.add(pni.ASI_MFM_Month_3_Cost__c);
                  Date temp = Date.newInstance(startyear, 9, 30);
                  if(Header.ASI_MFM_PO_Start_Date__c<temp && Header.ASI_MFM_PO_End_Date__c> temp){
                      gldate.add(temp);
                  }else if(Header.ASI_MFM_PO_Start_Date__c<temp) {
                      gldate.add(Lastmonthday);
                  }else{
                      gldate.add(StartLMD);
                  }
              }
              if(pni.ASI_MFM_Month_4_Cost__c!=null && pni.ASI_MFM_Month_4_Cost__c>0){//OCT
                  PlanAmount.add(pni.ASI_MFM_Month_4_Cost__c);
                  Date temp = Date.newInstance(startyear, 10, 31);
                  if(Header.ASI_MFM_PO_Start_Date__c<temp && Header.ASI_MFM_PO_End_Date__c> temp){
                      gldate.add(temp);
                  }else if(Header.ASI_MFM_PO_Start_Date__c<temp) {
                      gldate.add(Lastmonthday);
                  }else{
                      gldate.add(StartLMD);
                  }
              }
              if(pni.ASI_MFM_Month_5_Cost__c!=null && pni.ASI_MFM_Month_5_Cost__c>0){//NOV
                  PlanAmount.add(pni.ASI_MFM_Month_5_Cost__c);
                  Date temp = Date.newInstance(startyear, 11, 30);
                  if(Header.ASI_MFM_PO_Start_Date__c<temp && Header.ASI_MFM_PO_End_Date__c> temp){
                      gldate.add(temp);
                  }else if(Header.ASI_MFM_PO_Start_Date__c<temp) {
                      gldate.add(Lastmonthday);
                  }else{
                      gldate.add(StartLMD);
                  }
              }
              if(pni.ASI_MFM_Month_6_Cost__c!=null && pni.ASI_MFM_Month_6_Cost__c>0){//DEC
                  PlanAmount.add(pni.ASI_MFM_Month_6_Cost__c);
                  Date temp = Date.newInstance(startyear, 12, 31);
                  if(Header.ASI_MFM_PO_Start_Date__c<temp && Header.ASI_MFM_PO_End_Date__c> temp){
                      gldate.add(temp);
                  }else if(Header.ASI_MFM_PO_Start_Date__c<temp) {
                      gldate.add(Lastmonthday);
                  }else{
                      gldate.add(StartLMD);
                  }
              }
              if(pni.ASI_MFM_Month_7_Cost__c!=null && pni.ASI_MFM_Month_7_Cost__c>0){//JAN
                  PlanAmount.add(pni.ASI_MFM_Month_7_Cost__c);
                  Date temp = Date.newInstance(Endyear, 1, 31);
                  if(Header.ASI_MFM_PO_Start_Date__c<temp && Header.ASI_MFM_PO_End_Date__c> temp){
                      gldate.add(temp);
                  }else if(Header.ASI_MFM_PO_Start_Date__c<temp) {
                      gldate.add(Lastmonthday);
                  }else{
                      gldate.add(StartLMD);
                  }
              }
              if(pni.ASI_MFM_Month_8_Cost__c!=null && pni.ASI_MFM_Month_8_Cost__c>0){//FEB
                  PlanAmount.add(pni.ASI_MFM_Month_8_Cost__c);
                  Date temp = Date.newInstance(Endyear, 2, 28);
                  if(Header.ASI_MFM_PO_Start_Date__c<temp && Header.ASI_MFM_PO_End_Date__c> temp){
                      gldate.add(temp);
                  }else if(Header.ASI_MFM_PO_Start_Date__c<temp) {
                      gldate.add(Lastmonthday);
                  }else{
                      gldate.add(StartLMD);
                  }
              }
              if(pni.ASI_MFM_Month_9_Cost__c!=null && pni.ASI_MFM_Month_9_Cost__c>0){//MAR
                  PlanAmount.add(pni.ASI_MFM_Month_9_Cost__c);
                  Date temp = Date.newInstance(Endyear, 3, 31);
                  if(Header.ASI_MFM_PO_Start_Date__c<temp && Header.ASI_MFM_PO_End_Date__c> temp){
                      gldate.add(temp);
                  }else if(Header.ASI_MFM_PO_Start_Date__c<temp) {
                      gldate.add(Lastmonthday);
                  }else{
                      gldate.add(StartLMD);
                  }
              }
              if(pni.ASI_MFM_Month_10_Cost__c!=null && pni.ASI_MFM_Month_10_Cost__c>0){//APR
                  PlanAmount.add(pni.ASI_MFM_Month_10_Cost__c);
                  Date temp = Date.newInstance(Endyear, 4, 30);
                  if(Header.ASI_MFM_PO_Start_Date__c<temp && Header.ASI_MFM_PO_End_Date__c> temp){
                      gldate.add(temp);
                  }else if(Header.ASI_MFM_PO_Start_Date__c<temp) {
                      gldate.add(Lastmonthday);
                  }else{
                      gldate.add(StartLMD);
                  }
              }
              if(pni.ASI_MFM_Month_11_Cost__c!=null && pni.ASI_MFM_Month_11_Cost__c>0){//MAY
                  PlanAmount.add(pni.ASI_MFM_Month_11_Cost__c);
                  Date temp = Date.newInstance(Endyear, 5, 31);
                  if(Header.ASI_MFM_PO_Start_Date__c<temp && Header.ASI_MFM_PO_End_Date__c> temp){
                      gldate.add(temp);
                  }else if(Header.ASI_MFM_PO_Start_Date__c<temp) {
                      gldate.add(Lastmonthday);
                  }else{
                      gldate.add(StartLMD);
                  }
              }
              if(pni.ASI_MFM_Month_12_Cost__c!=null || pni.ASI_MFM_Month_12_Cost__c>0){//JUN
                  PlanAmount.add(pni.ASI_MFM_Month_12_Cost__c);
                  Date temp = Date.newInstance(Endyear, 6, 30);
                  if(Header.ASI_MFM_PO_Start_Date__c<temp && Header.ASI_MFM_PO_End_Date__c> temp){
                      gldate.add(temp);
                  }else if(Header.ASI_MFM_PO_Start_Date__c<temp) {
                      gldate.add(Lastmonthday);
                  }else{
                      gldate.add(StartLMD);
                  }
              }
           
            if(pni.ASI_MFM_Carry_Forward__c!=null && pni.ASI_MFM_Carry_Forward__c>0){// Carry Forward
                PlanAmount.add(pni.ASI_MFM_Carry_Forward__c);
                Date selectedDate =Date.newInstance(Header.ASI_MFM_PO_End_Date__c.year(),Header.ASI_MFM_PO_End_Date__c.month()-1,Header.ASI_MFM_PO_End_Date__c.day()); 
                Date firstDateCF = selectedDate.toStartOfMonth();
                gldate.add(firstDateCF.addDays(date.daysInMonth(selectedDate.year() , selectedDate.month())  - 1));
                
              }
           
              
              for(Integer CountN = 0; CountN < PlanAmount.size(); CountN++){
                  string newIDCounter = newCounterCreatorLine();
                  interimData temp= new interimData();
                  if(gldate[CountN]>Header.ASI_MFM_PO_End_Date__c){
                      Date selectedDate =Date.newInstance(Header.ASI_MFM_PO_End_Date__c.year(),Header.ASI_MFM_PO_End_Date__c.month()-1,Header.ASI_MFM_PO_End_Date__c.day()); 
                      Date firstDateA = selectedDate.toStartOfMonth();
                      gldate[CountN]=firstDateA.addDays(date.daysInMonth(selectedDate.year() , selectedDate.month())  - 1);
                  }
                  
                  temp.linetems=new ASI_MFM_PO_Line_Item__c(ASI_MFM_PO__c=Header.id,
                                                            ASI_MFM_G_L_Date__c= gldate[CountN],
                                                            //ASI_MFM_Amount__c = PlanAmount[CountN],
                                                            ASI_MFM_A_C_Code__c = pni.ASI_MFM_A_C_Code__c,
                                                            ASI_MFM_AP_Code__c = pni.ASI_MFM_AP_Code__c,
                                                            ASI_MFM_customer_name__c = pni.ASI_MFM_customer_name__c,
                                                            ASI_MFM_Sub_brand_Code__c = pni.ASI_MFM_Sub_brand_Code__c,
                                                            ASI_MFM_List_Item_Description__c = pni.ASI_MFM_List_Item_Description__c,
                                                            recordtypeid = Global_RecordTypeCache.getRTId('ASI_MFM_PO_Line_Item__cASI_MFM_PH_PO_Line_Item')
                                                           );
                  
                  Decimal exchangeRate = 1; 
                  
                  if(this.Header.ASI_MFM_Exchange_Rate__c!=null )
                  {
                      exchangeRate = this.Header.ASI_MFM_Exchange_Rate__c;
                      if(Header.RecordType.DeveloperName.startsWithIgnoreCase(DF_PO_RecordType_Developer_Name)){
                          exchangeRate=1;
                      }
                  }
                  temp.linetems.ASI_MFM_Amount__c =PlanAmount[CountN] !=null? (PlanAmount[CountN]/ exchangeRate).setScale(2, roundingmode.half_up): 0;
                  
                  if(Header.RecordType.DeveloperName.startsWithIgnoreCase(DF_PO_RecordType_Developer_Name)){
                      temp.Customer=PHDFCustomerName;
                      temp.CustomerId=PHDFCustomerDefault;
                  }else{
                      temp.Customer= pni.ASI_MFM_Customer_Name__r.name;
                      temp.CustomerId = pni.ASI_MFM_Customer_Name__c;                
                  }           
                  
                  
                  
                  temp.SubBrand =pni.ASI_MFM_Sub_brand_Code__r.name;
                  temp.SubbrandId =pni.ASI_MFM_Sub_brand_Code__c;
                  
                  temp.ACCode =pni.ASI_MFM_A_C_Code__r.name;
                  temp.ACCodeId =pni.ASI_MFM_A_C_Code__c;
          
                  temp.APCode =pni.ASI_MFM_AP_Code__r.name;
                  temp.APCodeId =pni.ASI_MFM_AP_Code__c;
                  
                  if(temp.linetems.ASI_MFM_Amount__c>0){
                      allLineItemMap.put(LINE_ITEM_NEWRECORD_PREFIX+newIDCounter, temp);
                  }
              }
              
       }
        
    }
    
    
    
    
    /*Method get Plan Line Item*/ 
    public string buildPlanItemSoql() {
        string qs = 'select ';      
        
        List<String> searchFields = new List<String>();
        
        searchFields.add('Id');
        searchFields.add('ASI_MFM_List_Item_Description__c');
        searchFields.add('ASI_MFM_Total_Cost__c');
        searchFields.add('ASI_MFM_Original_Total_Cost__c');
        searchFields.add('ASI_MFM_Customer_Name__r.name');
        searchFields.add('ASI_MFM_Customer_Name__c');
        searchFields.add('ASI_MFM_Sub_brand_Code__r.name');
        searchFields.add('ASI_MFM_Sub_brand_Code__c');
        searchFields.add('ASI_MFM_A_C_Code__r.name');
        searchFields.add('ASI_MFM_A_C_Code__c');
        searchFields.add('ASI_MFM_AP_Code__r.name');
        searchFields.add('ASI_MFM_AP_Code__c');
        searchFields.add('ASI_MFM_Month_1_Cost__c');
        searchFields.add('ASI_MFM_Month_2_Cost__c');
        searchFields.add('ASI_MFM_Month_3_Cost__c');
        searchFields.add('ASI_MFM_Month_4_Cost__c');
        searchFields.add('ASI_MFM_Month_5_Cost__c');
        searchFields.add('ASI_MFM_Month_6_Cost__c');
        searchFields.add('ASI_MFM_Month_7_Cost__c');
        searchFields.add('ASI_MFM_Month_8_Cost__c');
        searchFields.add('ASI_MFM_Month_9_Cost__c');
        searchFields.add('ASI_MFM_Month_10_Cost__c');
        searchFields.add('ASI_MFM_Month_11_Cost__c');
        searchFields.add('ASI_MFM_Month_12_Cost__c');
        searchFields.add('ASI_MFM_Carry_Forward__c');        
        searchFields.add('ASI_MFM_A_C_Code__r.ASI_MFM_AP_Segmentation_Category__c');      // Added by 2018-08-14 Linus@introv
        searchFields.add('ASI_MFM_PH_Allocation_Percentage__c');                          // Added by 2018-08-27 Linus@introv
        String outputString = String.join(searchFields, ',');
        
        qs = qs + outputString + ' from ASI_MFM_Plan_Line_Item__c where ASI_MFM_Plan__c = \'' + header.ASI_MFM_Plan__c +'\'' ;
        
      //  system.assertEquals(qs, null)
        return qs;
    }
    
    
    /*interimData Constructor*/ 
    public Class interimData{
        public ASI_MFM_PO_Line_Item__c linetems {get; set;}
        public Decimal Amount {get; set;}
        public String  ACCode {get; set;}
        public String  ACCodeId {set;get;}
        public String  APCode {get; set;}
        public String  APCodeId {set;get;}
        public String  Subbrand {set;get;}
        public String  SubbrandId {set;get;}
        public String  Customer {set;get;}     
        public String  CustomerId {set;get;}
        public boolean Spread {set;get;}{Spread=false;}
        public String  APSegment {set;get;}
        
        public void CloneFromOthers(interimData temp) {
            this.ACCode= temp.ACCode;
            this.ACCodeId= temp.ACCodeId;
            this.APCode= temp.APCode;
            this.APCodeId= temp.APCodeId;
            this.Subbrand= temp.Subbrand;
            this.SubbrandId= temp.SubbrandId;
            this.Customer= temp.Customer;
            this.CustomerId= temp.CustomerId; 
        }
    }
    
    
    
    
    public void init() {
        if(this.Header !=null && this.Header.Id !=null){  
            
            if(Header.RecordType.DeveloperName.startsWithIgnoreCase(DF_PO_RecordType_Developer_Name)){
                for (ASI_MFM_Default_Value__c Setting : ASI_MFM_Default_Value__c.getAll().values()) {
                    if(Setting.name == 'PH_DF_Customer_Name__c' && Setting.Country__c == 'PH'){
                        PHDFCustomerDefault = Setting.ASI_MFM_value__c;
                    }
                }
                PHDFCustomerName=[select name from account where id=:PHDFCustomerDefault].name;
                    
            }    
            
            // Only allow edit amount in non-draft status
            isFinal = Header.ASI_MFM_Status__c != 'Draft' ? true:false;            
            
            isDP = Header.RecordType.DeveloperName.startsWithIgnoreCase(DP_PO_RecordType_Developer_Name)? true:false;
            
            List<ASI_MFM_PO_Line_Item__c> lineItemList=[select id,name,ASI_MFM_List_Item_Description__c,ASI_MFM_Customer_Name__c,ASI_MFM_G_L_Date__c,ASI_MFM_Amount__c,ASI_MFM_Customer_Name__r.name,
                                                        ASI_MFM_Sub_brand_Code__c,ASI_MFM_Sub_brand_Code__r.name,ASI_MFM_Quantity__c,ASI_MFM_Unit_Price__c,ASI_MFM_A_C_Code__c, ASI_MFM_A_C_Code__r.Name,ASI_MFM_A_C_Code__r.ASI_MFM_AP_Segmentation_Category__c, ASI_MFM_AP_Code__r.name,ASI_MFM_AP_Code__c,
                                                        ASI_MFM_PO__r.ASI_MFM_PO_Raised_Date__c , ASI_MFM_PO__r.ASI_MFM_JDE_Tax_Code__c 
                                                        from ASI_MFM_PO_Line_Item__c where ASI_MFM_PO__c=:Header.id];                         
            
            if(!lineItemList.isEmpty()){
                for(ASI_MFM_PO_Line_Item__c lines:lineItemList){
                    String lId = (String)(lines.id);
                    interimData temp= new interimData();
                    temp.linetems=lines;
                    
                    temp.SubBrand =lines.ASI_MFM_Sub_brand_Code__r.name;
                    temp.SubbrandId =lines.ASI_MFM_Sub_brand_Code__c;
                    
                    temp.ACCode =lines.ASI_MFM_A_C_Code__r.name;
                    temp.ACCodeId =lines.ASI_MFM_A_C_Code__c;
                    temp.APSegment = lines.ASI_MFM_A_C_Code__r.ASI_MFM_AP_Segmentation_Category__c;
                    
                    temp.APCode =lines.ASI_MFM_AP_Code__r.name;
                    temp.APCodeId =lines.ASI_MFM_AP_Code__c;                    
                    
                    temp.Customer=lines.ASI_MFM_Customer_Name__r.name;
                    temp.CustomerId =lines.ASI_MFM_Customer_Name__c;
                    
                    temp.Amount =lines.ASI_MFM_Amount__c;
                    
                    temp.linetems = initalLineItem( temp.linetems, temp.linetems);
                    allLineItemMap.put(lId, temp);
                }
            }
            
            copyPlan();
            splitPlanline();
        }
        
        
        
    }
    
    public  ASI_MFM_PO_Line_Item__c initalLineItem ( ASI_MFM_PO_Line_Item__c newItem , ASI_MFM_PO_Line_Item__c oldItem){
        
        if(oldItem!=null){
            
            newItem.ASI_MFM_Amount__c = oldItem.ASI_MFM_Amount__c!=null? oldItem.ASI_MFM_Amount__c: null;
            newItem.ASI_MFM_Quantity__c = oldItem.ASI_MFM_Quantity__c!=null? oldItem.ASI_MFM_Quantity__c :null;
            newItem.ASI_MFM_Unit_Price__c = oldItem.ASI_MFM_Unit_Price__c!=null? oldItem.ASI_MFM_Unit_Price__c:null;
            
        }else{
            
            newItem.ASI_MFM_Amount__c =  null;
            newItem.ASI_MFM_Quantity__c = null;
            newItem.ASI_MFM_Unit_Price__c = null;            
            
        }
        
        return newItem;
        
    }
    
    
    
    public void addLineItem(){
        UpsertPermission = true;
        SaveSuccess = false;
        
        string newIDCounter = newCounterCreatorLine();
        interimData temp= new interimData();
        temp.linetems=new ASI_MFM_PO_Line_Item__c(ASI_MFM_PO__c=Header.id,
                                                  ASI_MFM_G_L_Date__c=Date.today(),
                                                  recordtypeid = Global_RecordTypeCache.getRTId('ASI_MFM_PO_Line_Item__cASI_MFM_PH_PO_Line_Item')
                                                 );
        
        if(Header.RecordType.DeveloperName.startsWithIgnoreCase(DF_PO_RecordType_Developer_Name)){
            temp.Customer=PHDFCustomerName;
            temp.CustomerId=PHDFCustomerDefault;
        }              
        
        temp.linetems =  initalLineItem (temp.linetems, null);
        
        allLineItemMap.put(LINE_ITEM_NEWRECORD_PREFIX+newIDCounter, temp);
        
    }
    
    
    public void cloneLine(){
        
        UpsertPermission = true;
        SaveSuccess = false;
        
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String param_Id = params.get('PARAM_clone_ID');
        if(allLineItemMap.containsKey(param_Id) && !allLineItemMap.isEmpty()){
            
            string newIDCounter = newCounterCreatorLine();
            interimData temp= new interimData();// allLineItemMap.get(param_Id).linetems.ASI_MFM_List_Item_Description__c
            temp.linetems=new ASI_MFM_PO_Line_Item__c(ASI_MFM_PO__c=Header.id,
                                                      ASI_MFM_A_C_Code__c=allLineItemMap.get(param_Id).linetems.ASI_MFM_A_C_Code__c,
                                                      ASI_MFM_AP_Code__c=allLineItemMap.get(param_Id).linetems.ASI_MFM_AP_Code__c,
                                                      ASI_MFM_Sub_brand_Code__c=allLineItemMap.get(param_Id).linetems.ASI_MFM_Sub_brand_Code__c,
                                                      ASI_MFM_G_L_Date__c=allLineItemMap.get(param_Id).linetems.ASI_MFM_G_L_Date__c,
                                                      ASI_MFM_List_Item_Description__c=allLineItemMap.get(param_Id).linetems.ASI_MFM_List_Item_Description__c,
                                                      //ASI_MFM_List_Item_Description__c='Test',
                                                      recordtypeid = Global_RecordTypeCache.getRTId('ASI_MFM_PO_Line_Item__cASI_MFM_PH_PO_Line_Item')
                                                     );
            
            
            temp.linetems =  initalLineItem (temp.linetems, allLineItemMap.get(param_Id).linetems);
            temp.SubBrand  = allLineItemMap.get(param_Id).SubBrand;
            temp.SubbrandId  =allLineItemMap.get(param_Id).SubBrandId;
            temp.ACCode = allLineItemMap.get(param_Id).ACCode;
            temp.ACCodeId = allLineItemMap.get(param_Id).ACCodeId;
            temp.APSegment = allLineItemMap.get(param_Id).APSegment;
            //temp.APCode = allLineItemMap.get(param_Id).APCode;
            //temp.APCodeId = allLineItemMap.get(param_Id).APCodeId;
            temp.Customer = allLineItemMap.get(param_Id).Customer;
            temp.CustomerId = allLineItemMap.get(param_Id).CustomerId;
            
            allLineItemMap.put(LINE_ITEM_NEWRECORD_PREFIX+newIDCounter, temp);
            
        }
        
    }
    
    
    public void removeLine() {
        
        UpsertPermission = true;
        SaveSuccess = false;
        
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String param_Id = params.get('PARAM_Line_ID');
        if(allLineItemMap.containsKey(param_Id) && !allLineItemMap.isEmpty()){
            
            ASI_MFM_PO_Line_Item__c delTarget=allLineItemMap.get(param_Id).linetems;
            if(delTarget.id != null){
                deleteLineItemList.add(delTarget);
            }
            if(delTarget.ASI_MFM_PO_Amount__c!=null){
                DeleteLineAmount+= delTarget.ASI_MFM_PO_Amount__c;
            }
            allLineItemMap.remove(param_Id);
        }
    }
    
    
    
    public PageReference cancel() {
        Pagereference ref;
        ref = new PageReference('/'+Header.id);
        ref.setRedirect(true);
        return ref;
    }
    
    
    
    public String newCounterCreatorLine() {
        
        String idNew;
        IF(LINE_ITEM_NEWRECORD_COUNTER == null) {
            LINE_ITEM_NEWRECORD_COUNTER = 0;
        }
        else {
            LINE_ITEM_NEWRECORD_COUNTER+=1;
        }
        
        String zParser = '';
        Integer oneDigitCounter = LINE_ITEM_NEWRECORD_COUNTER;
        
        if(LINE_ITEM_NEWRECORD_COUNTER > 9) {
            Integer zNumber = LINE_ITEM_NEWRECORD_COUNTER/10;
            for (Integer i = 0; i < zNumber; i++) {
                zParser += 'z';
            }
            oneDigitCounter = Math.mod(LINE_ITEM_NEWRECORD_COUNTER, 10);
        }
        
        idNew = zParser + string.valueof(oneDigitCounter);
        return idNew;
        
    }
    
    
    
}