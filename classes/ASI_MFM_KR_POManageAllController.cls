public without sharing class ASI_MFM_KR_POManageAllController {
    public ApexPages.StandardController standardController {get;set;}
    public ASI_MFM_PO__c Header {get;set;}
    
    public boolean SaveSuccess {get;set;}
    public boolean UpsertPermission {get;set;}{UpsertPermission=true;}
    public static String LINE_ITEM_NEWRECORD_PREFIX {get{ return 'z';}}
    public Integer LINE_ITEM_NEWRECORD_COUNTER {get;set;}
    
    public Map<String, interimData> allUpLineMap {get;set;}{ allUpLineMap = new Map<String, interimData>();}
    
    public Map<String, interimDown> allDownLineMap {get;set;}{ allDownLineMap = new Map<String, interimDown>();}
     public Transient String Customer_Developer_Name {set;get;}
     public Transient String SKU_RecordType_Developer_Name {set;get;}{SKU_RecordType_Developer_Name='ASI_MFM_KR_SKU';}
    
    //The Line need to delete
    public List<ASI_MFM_PO_Line_Item__c> deleteLineItemList {get;set;}{deleteLineItemList = new List<ASI_MFM_PO_Line_Item__c>();}
    public Map<String, Decimal> exchangeRateTable {set;get;} { exchangeRateTable = new Map<String, Decimal>();}
    
    public id defaultTaxCodeid;
    public String Msg {get;set;}
    
    public Class interimData{
        public ASI_MFM_PO_Line_Item__c line {get; set;}
        public String AC_Code {get; set;}
        public String AC_CodeID {get; set;}
        public String AP_Code {get; set;}
        public String AP_CodeID {get; set;}
        public String SB_Code {get; set;}
        public String SB_CodeID {get; set;}
        public String Customer {get; set;}
        public String CustomerID {get; set;}
        public String VenueWhere {get; set;}
        public String VenueWhereID {get; set;}
        
        public String SKU {get; set;}
        public String SKUID {get; set;}
        
        public String subLedger {get; set;} // ----- 2015-12-22
        public String subLedgerId {get; set;} // ----- 2015-12-22
        public String Description {get; set;}
        public String PRCurrency {get; set;}

        public Decimal PoAmount {get; set;}
        public Decimal PORLAvailableAmount {get; set;}
        public Decimal PlanlineAmount {get; set;}
        public Decimal PRlineAmount {get; set;} 
    }
    
    public Class interimDown{  // interimDown
        public ASI_MFM_Purchase_Request_Line__c line {get; set;}
        public Decimal RemainAmt {get; set;}
    }
    public static List<String> availableCurrency {get { return new List<String>{'EUR', 'AUD','HKD', 'SGD', 'USD' ,'GBP','KRW'};}}
    
    
    // Define the constructor
    public ASI_MFM_KR_POManageAllController(ApexPages.StandardController standardController){
        this.standardController = standardController;
        this.Header = (ASI_MFM_PO__c) this.standardController.getRecord();
        if(this.Header !=null && this.Header.Id !=null){
            for(ASI_MFM_PO__c line : [Select id,name,ASI_MFM_Is_Direct_Payment__c,ASI_MFM_Supplier_Name__r.ASI_HK_CRM_Payment_Term_Code__c,ASI_MFM_Project_Code__r.ASI_MFM_Pre_Payment__c,ASI_MFM_Project_Code__r.id,ASI_MFM_Company__c,
                                      ASI_MFM_PO_Balance_in_PO_Currency__c,ASI_MFM_Supplier_Name__r.ASI_MFM_Site_Code__c,ASI_MFM_Purchase_Request__c,ASI_MFM_PO_Raised_Date__c,
                                      ASI_MFM_Plan_Balance_in_PO_Currency__c, ASI_MFM_JDE_Tax_Code__c ,ASI_MFM_Status__c,ASI_MFM_Plan_Amount_in_PO_Currency__c,RecordType.DeveloperName,
                                      ASI_MFM_Other_Remark__c,ASI_MFM_VAT__c,RecordType.Name,ASI_MFM_Tax_Rate__c,ASI_MFM_Plan__r.ownerId, ASI_MFM_Currency__c,
                                      ASI_MFM_Plan__r.ASI_MFM_Total_PO_Amount__c,ASI_MFM_PO_Amount__c,ASI_MFM_Plan__r.ASI_MFM_Plan_Amount__c,ASI_MFM_Remarks__c,
                                      ASI_MFM_Supplier_Name__c,ASI_MFM_Exchange_Rate__c,ASI_MFM_Plan__c , ASI_MFM_Project_Code__c ,ASI_MFM_Promotion_Code__c , 
                                      ASI_MFM_PO_Start_Date__c ,ASI_MFM_PO_Balance__c,ASI_MFM_PO_End_Date__c , ASI_MFM_Sys_Plan_Amount__c , ASI_MFM_Plan_Balance__c 
                                      from ASI_MFM_PO__c where Id =: this.Header.Id limit 1]){
                this.Header = line;
            }
        }
    }
    
    
    // Initialize
    public void init() {
        SaveSuccess=false;
        if(this.Header !=null && this.Header.Id !=null){
            retrieveExchangeRate();
            //Get Default Tax Code
            defaultTaxCodeid=null;
            if(Header.ASI_MFM_Supplier_Name__r.ASI_MFM_Site_Code__c!=null && Header.ASI_MFM_Supplier_Name__r.ASI_HK_CRM_Payment_Term_Code__c !=null){ 
                ASI_MFM_Tax_Code__c[] tx=[select id,name from ASI_MFM_Tax_Code__c where name =: Header.ASI_MFM_Supplier_Name__r.ASI_MFM_Site_Code__c and ASI_MFM_Tax_Expl_Code__c=: Header.ASI_MFM_Supplier_Name__r.ASI_HK_CRM_Payment_Term_Code__c limit 1];
               if(tx.size()>0)defaultTaxCodeid=tx[0].id;
            }
             //Get Default Tax Code--End
             
            //get Up Items Lines  
            List<ASI_MFM_PO_Line_Item__c> lineItemList=[select id,name,ASI_MFM_List_Item_Description__c,ASI_MFM_Customer_Name__c,ASI_MFM_G_L_Date__c,ASI_MFM_Amount__c,ASI_MFM_Customer_Name__r.name,
                                                        ASI_MFM_Purchase_Request_Line__c,ASI_MFM_SKU_Code__c,ASI_MFM_TH_Unit__c,ASI_MFM_Plan_Line_Item__c,ASI_MFM_PO_Remark__c,
                                                        ASI_MFM_Purchase_Request_Line__r.ASI_MFM_Plan_Line_Item__r.ASI_MFM_Total_Cost__c,ASI_MFM_Purchase_Request_Line__r.ASI_MFM_Rest_Amount__c,
                                                        ASI_MFM_Sub_brand_Code__c,ASI_MFM_Delivery_Date__c,ASI_MFM_AccountsAdditionalField__r.Name,ASI_MFM_Plan_Line_Item__r.ASI_MFM_Venue_Where__c,ASI_MFM_Plan_Line_Item__r.ASI_MFM_Venue_Where__r.name,ASI_MFM_SKU_Code__r.name,
                                                        ASI_MFM_Sub_brand_Code__r.name,ASI_MFM_UOM__c,ASI_MFM_Purchase_Request_Line__r.ASI_MFM_Purchase_Request__r.ASI_MFM_Currency__c,
                                                        ASI_MFM_KR_Quantity__c,ASI_MFM_Unit_Price__c,ASI_MFM_A_C_Code__c, ASI_MFM_A_C_Code__r.Name,
                                                        ASI_MFM_Product_Item__c,ASI_MFM_AP_Code__c,ASI_MFM_AP_Code__r.name,ASI_MFM_Purchase_Request_Line__r.ASI_MFM_Description__c,
                                                        ASI_MFM_AccountsAdditionalField__c,ASI_MFM_Purchase_Request_Line__r.ASI_MFM_Estimated_PR_budget__c,
                                                        ASI_MFM_PO__r.ASI_MFM_PO_Raised_Date__c ,ASI_MFM_PO__r.ASI_MFM_JDE_Tax_Code__c, ASI_MFM_Purchase_Request_Line__r.ASI_MFM_UOM__c,
                                                        ASI_MFM_Purchase_Request_Line__r.ASI_MFM_Delivery_Date__c,ASI_MFM_Tax_Code__c,
                                                        ASI_MFM_KR_subLedger__c, ASI_MFM_KR_subLedger__r.Name, // ----- 2015-12-22
                                                        ASI_MFM_Consumer_Prize__c //20180121 Introv
                                                        from ASI_MFM_PO_Line_Item__c where ASI_MFM_PO__c=:Header.id];
            
            
            set<ID> lineID_set = new set<ID>();
            //Up
            if(!lineItemList.isEmpty()){
                for(ASI_MFM_PO_Line_Item__c upline : lineItemList){
                    String downId = (String)(upline.ASI_MFM_Purchase_Request_Line__c);
                    if(!allUpLineMap.containsKey(downId)){
                        interimData temp= new interimData();
                        temp.line=upline;
                        Decimal fx=1.0;//temp.line.ASI_MFM_Amount__c=temp.line.ASI_MFM_Amount__c.setScale(0, roundingMode.half_up);
                        if(upline.ASI_MFM_Purchase_Request_Line__c!=null){
                            if(Header.ASI_MFM_Currency__c==upline.ASI_MFM_Purchase_Request_Line__r.ASI_MFM_Purchase_Request__r.ASI_MFM_Currency__c || !exchangeRateTable.containsKey(upline.ASI_MFM_Purchase_Request_Line__r.ASI_MFM_Purchase_Request__r.ASI_MFM_Currency__c)){
                                temp.PORLAvailableAmount=upline.ASI_MFM_Purchase_Request_Line__r.ASI_MFM_Rest_Amount__c;
                            }else{
                                if(exchangeRateTable.containsKey(upline.ASI_MFM_Purchase_Request_Line__r.ASI_MFM_Purchase_Request__r.ASI_MFM_Currency__c)){
                                    fx=exchangeRateTable.get(upline.ASI_MFM_Purchase_Request_Line__r.ASI_MFM_Purchase_Request__r.ASI_MFM_Currency__c);
                                    temp.PORLAvailableAmount=(upline.ASI_MFM_Purchase_Request_Line__r.ASI_MFM_Rest_Amount__c*fx).setScale(2, roundingMode.half_up);
                                }
                            }
                            temp.PRCurrency=upline.ASI_MFM_Purchase_Request_Line__r.ASI_MFM_Purchase_Request__r.ASI_MFM_Currency__c;
                            temp.PRlineAmount= temp.line.ASI_MFM_Purchase_Request_Line__r.ASI_MFM_Estimated_PR_budget__c;
                            
                        }
                        temp.Description=upline.ASI_MFM_Purchase_Request_Line__r.ASI_MFM_Description__c;
                        temp.Customer=upline.ASI_MFM_AccountsAdditionalField__r.Name;
                        temp.CustomerId=upline.ASI_MFM_AccountsAdditionalField__c;
                        temp.VenueWhere=upline.ASI_MFM_Plan_Line_Item__r.ASI_MFM_Venue_Where__r.name;
                        temp.VenueWhereID=upline.ASI_MFM_Plan_Line_Item__r.ASI_MFM_Venue_Where__c;
                        temp.SKU=upline.ASI_MFM_SKU_Code__r.name;
                        temp.SKUID=upline.ASI_MFM_SKU_Code__c;                        
                        allUpLineMap.put(downId, temp);
                        lineID_set.add(upline.ASI_MFM_Purchase_Request_Line__c);
                        
                    }
                }
            }
            //Up end
            
            //get down line   and ASI_MFM_Plan_Line_Item__r.ASI_MFM_Plan__c=:Header.ASI_MFM_Plan__c      and ASI_MFM_Purchase_Request__c=:Header.ASI_MFM_Purchase_Request__c
            List<ASI_MFM_Purchase_Request_Line__c> downlineList = [select id,name, ASI_MFM_Basic_POSM__r.name,ASI_MFM_Basic_POSM__c,ASI_MFM_Rest_Amount__c,ASI_MFM_Plan_Line_Item__r.ASI_MFM_AccountsAdditionalField__r.name,ASI_MFM_Unit_Cost__c, ASI_MFM_Plan_Line_Item__c,  ASI_MFM_Plan_Line_Item__r.ASI_MFM_List_Item_Description__c,
                                                                   ASI_MFM_Plan_Line_Item__r.ASI_MFM_AccountsAdditionalField__c,ASI_MFM_Plan_Line_Item__r.ASI_MFM_Product_Item__c,ASI_MFM_Plan_Line_Item__r.ASI_MFM_Total_Cost__c,ASI_MFM_A_C_Code__c, ASI_MFM_AP_Code__c,
                                                                   ASI_MFM_Plan_Line_Item__r.ASI_MFM_AP_Code__c,ASI_MFM_Plan_Line_Item__r.ASI_MFM_A_C_Code__c, ASI_MFM_Purchase_Request__c,ASI_MFM_Purchase_Request__r.ASI_MFM_Currency__c,
                                                                   ASI_MFM_Quantity__c,ASI_MFM_Tax_Code__c,ASI_MFM_Plan_Line_Item__r.ASI_MFM_Unit_Cost__c, ASI_MFM_Plan_Line_Item__r.ASI_MFM_Sub_brand_Code__c,
                                                                   ASI_MFM_Plan_Line_Item__r.ASI_MFM_Sub_brand_Code__r.name,ASI_MFM_Estimated_PR_budget__c,ASI_MFM_Description__c, ASI_MFM_UOM__c,ASI_MFM_Plan_Line_Item__r.ASI_MFM_Venue_Where__c,ASI_MFM_Plan_Line_Item__r.ASI_MFM_Venue_Where__r.name,
                                                                   ASI_MFM_Delivery_Date__c, ASI_MFM_Plan_Line_Item__r.ASI_MFM_KR_subLedger__c, ASI_MFM_Plan_Line_Item__r.ASI_MFM_KR_subLedger__r.Name, // ----- 2015-12-22
                                                                   ASI_MFM_Consumer_Prize__c //20180121 Introv
                                                                   from ASI_MFM_Purchase_Request_Line__c where id not in: lineID_set and ASI_MFM_Rest_Amount__c>0 and RecordType.DeveloperName like'ASI_MFM_KR%'  and ASI_MFM_Purchase_Request__r.ASI_MFM_Status__c='Approved' and ASI_MFM_Purchase_Request__r.ASI_MFM_Type__c =:Header.ASI_MFM_Company__c and ASI_MFM_Purchase_Request__c=:Header.ASI_MFM_Purchase_Request__c] ;
            if(!downlineList.isEmpty()){   //allDownLineMap
                
                for(ASI_MFM_Purchase_Request_Line__c line:downlineList){
                    String polid=(String)(line.id);
                    if(!allDownLineMap.containsKey(polid)){
                        interimDown temp= new interimDown();
                        temp.line=line;
                        allDownLineMap.put(polid,temp);
                    }
                }
            }
        }
        copyPRD(); // callmethod copyPR - for copy PR detail
        Customer_Developer_Name='ASI_CRM_KR_Venue';//      ASI_CRM_KR_Wholesaler      
    }    
    //
    public void retrieveExchangeRate(){
                   
        string country = Header.recordType.developerName.substring(8, 10); //e.g. KR
        String headerCurrency = Header.ASI_MFM_Currency__c; //e.g. KRW
        Map<String, String> CurrencyEffectiveMap = new Map<String, String>();
        
        //AggregateResult allows using group by, so we use AggregateResult rather than List to store the value
        AggregateResult[] CurrencyEffective = [Select ASI_MFM_Counter_Currency__c , Id, MAX(ASI_MFM_Effective_Date__c) from ASI_MFM_Exchange_Rate__c 
             where ASI_MFM_Application__c = 'MFM' and ASI_MFM_Country__c = : country
             and ASI_MFM_Base_Currency__c =: headerCurrency and ASI_MFM_Effective_Date__c <= :date.today()  
             and (ASI_MFM_Counter_Currency__c in: availableCurrency) group by ASI_MFM_Counter_Currency__c, Id];
        
        //extract currency and id from CurrencyEffective to CurrencyEffectiveMap
        if(CurrencyEffective!=null){
            for(AggregateResult ar : CurrencyEffective){ 
                CurrencyEffectiveMap.put(String.ValueOf(ar.get('ASI_MFM_Counter_Currency__c')), String.ValueOf(ar.get('Id')));
            }
        }
        //store currency, exchange rate to a list called exchangeRates
        List<ASI_MFM_Exchange_Rate__c> exchangeRates = new List<ASI_MFM_Exchange_Rate__c>();
        
        exchangeRates =   [Select ASI_MFM_Counter_Currency__c, ASI_MFM_Exchange_Rate__c from ASI_MFM_Exchange_Rate__c 
                           where id in: CurrencyEffectiveMap.values()];
        
        //if there is record in exchangeRate list, records will be inserted into exchangeRateTable which is a Map
        if(exchangeRates!=null && exchangeRates.size()>0){
            
            for(ASI_MFM_Exchange_Rate__c ae : exchangeRates){
                exchangeRateTable.put(ae.ASI_MFM_Counter_Currency__c, ae.ASI_MFM_Exchange_Rate__c);
            }
              
        }
    }
    
    public void removeLine() {
        SaveSuccess=false;
        UpsertPermission=true;
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String param_Id = params.get('PARAM_PORLine_ID');
        
        if(allUpLineMap.containsKey(param_Id) && !allUpLineMap.isEmpty() ){
            
            ASI_MFM_Purchase_Request_Line__c Pline = [select id,name, ASI_MFM_Rest_Amount__c,ASI_MFM_Plan_Line_Item__c,ASI_MFM_Plan_Line_Item__r.ASI_MFM_AccountsAdditionalField__r.name,  ASI_MFM_Plan_Line_Item__r.ASI_MFM_List_Item_Description__c,ASI_MFM_Plan_Line_Item__r.ASI_MFM_Total_Cost__c,
                                                      ASI_MFM_Basic_POSM__r.name,ASI_MFM_Plan_Line_Item__r.ASI_MFM_AccountsAdditionalField__c,ASI_MFM_Plan_Line_Item__r.ASI_MFM_Product_Item__c,ASI_MFM_Estimated_PR_budget__c, ASI_MFM_UOM__c,
                                                      ASI_MFM_Plan_Line_Item__r.ASI_MFM_AP_Code__c,ASI_MFM_Plan_Line_Item__r.ASI_MFM_A_C_Code__c, 
                                                      ASI_MFM_Purchase_Request__c,ASI_MFM_Quantity__c,ASI_MFM_Description__c,ASI_MFM_Plan_Line_Item__r.ASI_MFM_Venue_Where__c,
                                                      ASI_MFM_Plan_Line_Item__r.ASI_MFM_Venue_Where__r.name,ASI_MFM_Basic_POSM__c,
                                                      ASI_MFM_Tax_Code__c,ASI_MFM_Unit_Cost__c,ASI_MFM_Purchase_Request__r.ASI_MFM_Currency__c,ASI_MFM_A_C_Code__c, ASI_MFM_AP_Code__c,
                                                      ASI_MFM_Plan_Line_Item__r.ASI_MFM_Sub_brand_Code__c, ASI_MFM_Plan_Line_Item__r.ASI_MFM_Sub_brand_Code__r.name,ASI_MFM_Delivery_Date__c,
                                                      ASI_MFM_Plan_Line_Item__r.ASI_MFM_KR_subLedger__c, ASI_MFM_Plan_Line_Item__r.ASI_MFM_KR_subLedger__r.Name, // ----- 2015-12-22
                                                      ASI_MFM_Consumer_Prize__c //20180121 Introv
                                                      from ASI_MFM_Purchase_Request_Line__c where id =:allUpLineMap.get(param_Id).line.ASI_MFM_Purchase_Request_Line__c];
            
            if(Pline!=null){
                String polid=(String)(Pline.id);
                if(!allDownLineMap.containsKey(polid)){
                    interimDown temp= new interimDown();
                    temp.line=Pline;
                    
                    allDownLineMap.put(polid,temp);
                }
            }
            
            ASI_MFM_PO_Line_Item__c delTarget=allUpLineMap.get(param_Id).line;
            if(delTarget.id != null){
                deleteLineItemList.add(delTarget);
            }
            allUpLineMap.remove(param_Id);
        }
    }
    
    
    public void addLineItem(){
        SaveSuccess=false;
        UpsertPermission=true;
        
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String param_SourceItemId = params.get('PARAM_POLINE_SOURCE_ITEM_ID');
        
        if(allDownLineMap.containsKey(param_SourceItemId)){
            string newIDCounter = newCounterCreatorLine();
            interimData temp= new interimData();
            //Unit Cost: ASI_MFM_TH_Unit__c
            temp.line=new ASI_MFM_PO_Line_Item__c(ASI_MFM_PO__c=Header.id,
                                                  ASI_MFM_Sub_brand_Code__c=allDownLineMap.get(param_SourceItemId).line.ASI_MFM_Plan_Line_Item__r.ASI_MFM_Sub_brand_Code__c,
                                                  recordtypeid = Global_RecordTypeCache.getRTId('ASI_MFM_PO_Line_Item__cASI_MFM_KR_PO_Line_Item'),
                                                  ASI_MFM_AP_Code__c= allDownLineMap.get(param_SourceItemId).line.ASI_MFM_AP_Code__c,   // Modified by 2018-05-24 Linus@introv
                                                  ASI_MFM_A_C_Code__c= allDownLineMap.get(param_SourceItemId).line.ASI_MFM_A_C_Code__c,
                                                  ASI_MFM_KR_subLedger__c = allDownLineMap.get(param_SourceItemId).line.ASI_MFM_Plan_Line_Item__r.ASI_MFM_KR_subLedger__c, // ----- 2015-12-22
                                                  ASI_MFM_KR_Quantity__c  = allDownLineMap.get(param_SourceItemId).line.ASI_MFM_Quantity__c,
                                                  ASI_MFM_TH_Unit__c =  allDownLineMap.get(param_SourceItemId).line.ASI_MFM_Unit_Cost__c,
                                                  ASI_MFM_Delivery_Date__c = allDownLineMap.get(param_SourceItemId).line.ASI_MFM_Delivery_Date__c,
                                                  ASI_MFM_Plan_Line_Item__c =   allDownLineMap.get(param_SourceItemId).line.ASI_MFM_Plan_Line_Item__c,
                                                  ASI_MFM_G_L_Date__c = date.today(),
                                                  ASI_MFM_PO_Remark__c=allDownLineMap.get(param_SourceItemId).line.ASI_MFM_Description__c,
                                                  ASI_MFM_UOM__c = allDownLineMap.get(param_SourceItemId).line.ASI_MFM_UOM__c,
                                                  ASI_MFM_Purchase_Request_Line__c=allDownLineMap.get(param_SourceItemId).line.id,
                                                  ASI_MFM_Consumer_Prize__c=allDownLineMap.get(param_SourceItemId).line.ASI_MFM_Consumer_Prize__c //20180121 Introv
                                                 );
            
            if(Header.ASI_MFM_Currency__c=='KRW'){
                temp.line.ASI_MFM_Tax_Code__c=defaultTaxCodeid;
            }  
            
            if(Header.ASI_MFM_Project_Code__r.ASI_MFM_Pre_Payment__c){
                temp.line.ASI_MFM_KR_Quantity__c = allDownLineMap.get(param_SourceItemId).line.ASI_MFM_Rest_Amount__c;
                temp.line.ASI_MFM_TH_Unit__c=1;
            }
             if(temp.line.ASI_MFM_KR_Quantity__c!=null && temp.line.ASI_MFM_TH_Unit__c!=null){   
                temp.line.ASI_MFM_Amount__c=(temp.line.ASI_MFM_KR_Quantity__c*temp.line.ASI_MFM_TH_Unit__c).setScale(0, roundingMode.half_up);
            }   
            
            //PR Amount 
            temp.PRlineAmount= allDownLineMap.get(param_SourceItemId).line.ASI_MFM_Estimated_PR_budget__c;
            if(Header.ASI_MFM_Currency__c== allDownLineMap.get(param_SourceItemId).line.ASI_MFM_Purchase_Request__r.ASI_MFM_Currency__c || !exchangeRateTable.containsKey(allDownLineMap.get(param_SourceItemId).line.ASI_MFM_Purchase_Request__r.ASI_MFM_Currency__c)){
                temp.PORLAvailableAmount=allDownLineMap.get(param_SourceItemId).line.ASI_MFM_Rest_Amount__c;
                temp.line.ASI_MFM_Amount__c=allDownLineMap.get(param_SourceItemId).line.ASI_MFM_Rest_Amount__c;
            }else{
                if(exchangeRateTable.containsKey(allDownLineMap.get(param_SourceItemId).line.ASI_MFM_Purchase_Request__r.ASI_MFM_Currency__c)){
                    decimal fx=exchangeRateTable.get(allDownLineMap.get(param_SourceItemId).line.ASI_MFM_Purchase_Request__r.ASI_MFM_Currency__c);
                    temp.PORLAvailableAmount=(allDownLineMap.get(param_SourceItemId).line.ASI_MFM_Rest_Amount__c*fx).setScale(2, roundingMode.half_up);
                    temp.line.ASI_MFM_Amount__c=(allDownLineMap.get(param_SourceItemId).line.ASI_MFM_Rest_Amount__c*fx).setScale(2, roundingMode.half_up);
                }
            }
            
            
            if(temp.line.ASI_MFM_TH_Unit__c==null && temp.line.ASI_MFM_Amount__c!=null && temp.line.ASI_MFM_KR_Quantity__c!=null){
                temp.line.ASI_MFM_TH_Unit__c=temp.line.ASI_MFM_Amount__c/temp.line.ASI_MFM_KR_Quantity__c;
            }
            if(Header.ASI_MFM_Project_Code__r.ASI_MFM_Pre_Payment__c){
                temp.line.ASI_MFM_KR_Quantity__c = temp.line.ASI_MFM_Amount__c;
            }
            
            temp.Description=allDownLineMap.get(param_SourceItemId).line.ASI_MFM_Description__c;
            temp.PRCurrency=allDownLineMap.get(param_SourceItemId).line.ASI_MFM_Purchase_Request__r.ASI_MFM_Currency__c;
            temp.Customer= allDownLineMap.get(param_SourceItemId).line.ASI_MFM_Plan_Line_Item__r.ASI_MFM_AccountsAdditionalField__r.name;
            temp.CustomerId= allDownLineMap.get(param_SourceItemId).line.ASI_MFM_Plan_Line_Item__r.ASI_MFM_AccountsAdditionalField__c;
            temp.VenueWhere= allDownLineMap.get(param_SourceItemId).line.ASI_MFM_Plan_Line_Item__r.ASI_MFM_Venue_Where__r.name;
            temp.VenueWhereID= allDownLineMap.get(param_SourceItemId).line.ASI_MFM_Plan_Line_Item__r.ASI_MFM_Venue_Where__c;
            temp.SKU= allDownLineMap.get(param_SourceItemId).line.ASI_MFM_Basic_POSM__r.name;
            temp.SKUID= allDownLineMap.get(param_SourceItemId).line.ASI_MFM_Basic_POSM__c;
            allUpLineMap.put(LINE_ITEM_NEWRECORD_PREFIX+newIDCounter, temp);
            allDownLineMap.remove(param_SourceItemId);
        }
        
    }
    
    
    public PageReference saveLinetems(){
        
        onCommitted();
        PageReference pageRef ;
        if(UpsertPermission){
            pageRef=new PageReference('/'+Header.id);
        }else{
            pageRef=null;
        }
        
        return pageRef;
    }
    
    
    
    public void onCommitted(){
        //Function
        
        Database.upsertResult[] upsertTarget;
        Database.deleteResult[] deleteTarget;
        Set<id> PRLineIdSet = new Set<id>();
        UpsertPermission=true;
        List<ASI_MFM_PO_Line_Item__c> upsertTargetList = new List<ASI_MFM_PO_Line_Item__c>();
        
        UpsertPermission=valdationCheckingStep(allUpLineMap);
        //Upsert
        if(UpsertPermission){
            for(String key : allUpLineMap.keySet()){
                if(allUpLineMap.get(key).line.ASI_MFM_Purchase_Request_Line__c!=null) PRLineIdSet.add(allUpLineMap.get(key).line.ASI_MFM_Purchase_Request_Line__c);
                if(Header.ASI_MFM_Currency__c==allUpLineMap.get(key).PRCurrency){
                    allUpLineMap.get(key).line.ASI_MFM_PO_Amount_in_PR_Currency__c=allUpLineMap.get(key).line.ASI_MFM_Amount__c;
                }else{
                    if(exchangeRateTable.containsKey(allUpLineMap.get(key).PRCurrency)){
                        decimal fx=exchangeRateTable.get(allUpLineMap.get(key).PRCurrency);
                        allUpLineMap.get(key).line.ASI_MFM_PO_Amount_in_PR_Currency__c=(allUpLineMap.get(key).line.ASI_MFM_Amount__c/fx).setScale(2, roundingMode.half_up);
                    }
                }
                
                
                allUpLineMap.get(key).line.ASI_MFM_Project_Code__c=string.valueOf(Header.ASI_MFM_Project_Code__r.id);
                upsertTargetList.add(allUpLineMap.get(key).line);
            }
            
            for(ASI_MFM_PO_Line_Item__c pl:deleteLineItemList){
                if(pl.ASI_MFM_Purchase_Request_Line__c!=null) PRLineIdSet.add(pl.ASI_MFM_Purchase_Request_Line__c);
            }
            
        }
        
        
        try{
            if(UpsertPermission){
                if(deleteLineItemList.size()>0){
                    deleteTarget = Database.delete(deleteLineItemList);
                    deleteTarget.clear();
                    deleteLineItemList.clear();
                    SaveSuccess=true;
                }
                
                if(upsertTargetList.size()>0){
                    upsertTarget = Database.upsert(upsertTargetList);
                    SaveSuccess=true;
                }
               
            }else{
                SaveSuccess=false;
            }
            
        }catch(Exception e){
            msg += 'Save Error!'+  e.getMessage() +'</br>';
            UpsertPermission = false;
            SaveSuccess= false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Save Error!' + e));
        }
        
    }  
    
    public Boolean valdationCheckingStep(Map<String, interimData> allLineItemMap ){
        Integer idx = 1; 
        Msg='';
        Boolean isProcess = true;
        for(String key : allLineItemMap.keySet()){
            //  check require field
            
            if(allLineItemMap.get(key).line.ASI_MFM_Amount__c==null){
                isProcess=false;
                Msg += 'Line ' + idx + ' :Amount can not be null'+'</br>';
            }  
            
            if(allLineItemMap.get(key).line.ASI_MFM_KR_Quantity__c==null){
                isProcess=false;
                Msg += 'Line ' + idx + ' :Quantity can not be null'+'</br>';
            }
            
            if(allLineItemMap.get(key).line.ASI_MFM_TH_Unit__c==null){
                isProcess=false;
                Msg += 'Line ' + idx + ' :Unit Cost can not be null'+'</br>';
            }
           
            
            //check customer
            if(!String.isEmpty(allLineItemMap.get(key).CustomerId)){
                try
                {
                    /*Need to map back the ID to Customer*/
                    Id CusId = Id.valueOf(allLineItemMap.get(key).CustomerId);
                    allLineItemMap.get(key).line.ASI_MFM_AccountsAdditionalField__c = CusId;
                }//end try
                catch(exception e)
                {
                   
                }//end catch
            }
            
            if(String.isEmpty(allLineItemMap.get(key).Customer)){
                allLineItemMap.get(key).line.ASI_MFM_AccountsAdditionalField__c = null;
            }
            
            
            if(!String.isEmpty(allLineItemMap.get(key).SKUID)){
                try
                {
                    /*Need to map back the ID to SKU*/
                    Id SKU_ID = Id.valueOf(allLineItemMap.get(key).SKUID);
                    allLineItemMap.get(key).line.ASI_MFM_SKU_Code__c = SKU_ID;
                }//end try
                catch(exception e)
                {
                    msg += 'Line ' + idx + ' : Please select Customer' + '</br>';
                    
                    isProcess = false;  
                }//end catch
            }
            
            if(String.isEmpty(allLineItemMap.get(key).SKUID)){
                allLineItemMap.get(key).line.ASI_MFM_SKU_Code__c = null;
            }
            
            if(isProcess){
                if(Header.ASI_MFM_Currency__c=='KRW'){
                     allLineItemMap.get(key).line.ASI_MFM_Amount__c=allLineItemMap.get(key).line.ASI_MFM_Amount__c.setScale(0, roundingMode.half_up);
                }
               
            }
            idx++;
        }
        return isProcess;
    }
    
    public PageReference cancel() {
        
        Pagereference ref;
        ref = new PageReference('/'+Header.id);
        ref.setRedirect(true);
        return ref;
    }
    
    //Generate map id
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
    
    //2015-11-26, add method copyPR Detail, for copy PR detail
    public void copyPRD()
    {
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String param_mode = params.get('mode');     
        if(param_mode==null) return;
        list<ASI_MFM_Purchase_Request_Line__c>prl_list = database.query(buildPRItemSoql());
        if(prl_list==null) return;
        
        List<ASI_MFM_PO_Line_Item__c> existPOL //for getting current PO's line items
            = new List<ASI_MFM_PO_Line_Item__c>([SELECT Id, ASI_MFM_Purchase_Request_Line__c
                                                 FROM ASI_MFM_PO_Line_Item__c 
                                                 WHERE ASI_MFM_PO__c =: Header.Id]);
        
        Map<String,ASI_MFM_PO_Line_Item__c> existPOLMap = new Map<String,ASI_MFM_PO_Line_Item__c>();
        
        for(ASI_MFM_PO_Line_Item__c pol : existPOL)
        {
            existPOLMap.put(pol.ASI_MFM_Purchase_Request_Line__c, pol); //for checking existing PO line items
        }//end for
        
        for (ASI_MFM_Purchase_Request_Line__c prl: prl_list)
        {
            String newIDCounter = newCounterCreatorLine();
            interimData temp = new interimData();
            temp.line = new ASI_MFM_PO_Line_Item__c(ASI_MFM_PO__c=Header.id,
                                                    ASI_MFM_G_L_Date__c= Header.ASI_MFM_PO_Raised_Date__c,
                                                    ASI_MFM_Purchase_Request_Line__c = prl.Id,
                                                    ASI_MFM_Plan_Line_Item__c=prl.ASI_MFM_Plan_Line_Item__c,
                                                    ASI_MFM_PO_Remark__c=prl.ASI_MFM_Description__c,
                                                    ASI_MFM_Consumer_Prize__c=prl.ASI_MFM_Consumer_Prize__c,
                                                    recordtypeid = Global_RecordTypeCache.getRTId('ASI_MFM_PO_Line_Item__cASI_MFM_KR_PO_Line_Item'));
            
            temp.Customer= prl.ASI_MFM_Plan_Line_Item__r.ASI_MFM_AccountsAdditionalField__r.name;
            temp.CustomerId= prl.ASI_MFM_Plan_Line_Item__r.ASI_MFM_AccountsAdditionalField__c;
            temp.VenueWhere= prl.ASI_MFM_Plan_Line_Item__r.ASI_MFM_Venue_Where__r.name;
            temp.VenueWhereID= prl.ASI_MFM_Plan_Line_Item__r.ASI_MFM_Venue_Where__c;
            temp.SKU= prl.ASI_MFM_Basic_POSM__r.name;
            temp.SKUID= prl.ASI_MFM_Basic_POSM__c;
            
            temp.line.ASI_MFM_AccountsAdditionalField__c=prl.ASI_MFM_Plan_Line_Item__r.ASI_MFM_AccountsAdditionalField__c;
            temp.line.ASI_MFM_Sub_brand_Code__c =prl.ASI_MFM_Plan_Line_Item__r.ASI_MFM_Sub_brand_Code__c;
            temp.line.ASI_MFM_AP_Code__c =prl.ASI_MFM_AP_Code__c;     // Modified by 2018-05-24 Linus@introv
            temp.line.ASI_MFM_A_C_Code__c =prl.ASI_MFM_A_C_Code__c;
            temp.line.ASI_MFM_KR_subLedger__c =prl.ASI_MFM_Plan_Line_Item__r.ASI_MFM_KR_subLedger__c; // ----- 2015-12-22
            temp.Description=prl.ASI_MFM_Description__c;
            if (param_mode == 'full') // if mode is 'full', do copy PR line logic
            {
                
                if(Header.ASI_MFM_Project_Code__r.ASI_MFM_Pre_Payment__c){
                temp.line.ASI_MFM_KR_Quantity__c = prl.ASI_MFM_Rest_Amount__c;
                temp.line.ASI_MFM_TH_Unit__c=1;
                }
                
                if(Header.ASI_MFM_Currency__c== prl.ASI_MFM_Purchase_Request__r.ASI_MFM_Currency__c || !exchangeRateTable.containsKey(prl.ASI_MFM_Purchase_Request__r.ASI_MFM_Currency__c)){
                    temp.PORLAvailableAmount=prl.ASI_MFM_Rest_Amount__c;
                    temp.line.ASI_MFM_Amount__c=prl.ASI_MFM_Rest_Amount__c;
                }else{
                    if(exchangeRateTable.containsKey(prl.ASI_MFM_Purchase_Request__r.ASI_MFM_Currency__c)){
                        decimal fx=exchangeRateTable.get(prl.ASI_MFM_Purchase_Request__r.ASI_MFM_Currency__c);
                        temp.PORLAvailableAmount=(prl.ASI_MFM_Rest_Amount__c*fx).setScale(2, roundingMode.half_up);
                        temp.line.ASI_MFM_Amount__c=(prl.ASI_MFM_Rest_Amount__c*fx).setScale(2, roundingMode.half_up);
                    }
                }
                
                
                
                temp.line.ASI_MFM_Unit_Price__c =prl.ASI_MFM_Unit_Cost__c;
                temp.line.ASI_MFM_KR_Quantity__c =prl.ASI_MFM_Quantity__c;
                
                temp.line.ASI_MFM_Delivery_Date__c=prl.ASI_MFM_Delivery_Date__c;
                if(Header.ASI_MFM_Currency__c=='KRW'){
                    temp.line.ASI_MFM_Tax_Code__c=defaultTaxCodeid;
                }
                
                temp.PRlineAmount=prl.ASI_MFM_Estimated_PR_budget__c;
                temp.line.ASI_MFM_UOM__c=prl.ASI_MFM_UOM__c;
                
                if(Header.ASI_MFM_Project_Code__r.ASI_MFM_Pre_Payment__c){  //added by kammy
                temp.line.ASI_MFM_KR_Quantity__c = temp.line.ASI_MFM_Amount__c;
                }
            }//end if: check mode is 'full'
            
            if(temp.line.ASI_MFM_Purchase_Request_Line__c!=null &&!existPOLMap.containsKey(temp.line.ASI_MFM_Purchase_Request_Line__c)) {
                //check the PR line id is already exist or not
                allUpLineMap.put(LINE_ITEM_NEWRECORD_PREFIX+newIDCounter, temp);
                
                //If this id is in downMap ,remove it.
                if(allDownLineMap.containsKey(temp.line.ASI_MFM_Purchase_Request_Line__c)){
                    allDownLineMap.remove(temp.line.ASI_MFM_Purchase_Request_Line__c);
                }
            }
            
            //allDownLineMap.clear();
        }//end for: loop PR line item list
    }//end method: copyPRD
    
    
    public string buildPRItemSoql()
    {
        string qs = 'select ';      
        
        List<String> searchFields = new List<String>();
        searchFields.add('Id'); //PR Line id
        searchFields.add('ASI_MFM_Plan_Line_Item__c'); //plan Line id
        searchFields.add('ASI_MFM_Plan_Line_Item__r.ASI_MFM_AccountsAdditionalField__c'); //custome id in plan line
        searchFields.add('ASI_MFM_Plan_Line_Item__r.ASI_MFM_AP_Code__c'); //AP code id in plan line
        searchFields.add('ASI_MFM_Plan_Line_Item__r.ASI_MFM_A_C_Code__c'); //AC code id in plan line
        searchFields.add('ASI_MFM_AP_Code__c'); //AP code id
        searchFields.add('ASI_MFM_A_C_Code__c'); //AC code id
        searchFields.add('ASI_MFM_Plan_Line_Item__r.ASI_MFM_Sub_brand_Code__c'); //sub-brand id in plan line
        searchFields.add('ASI_MFM_Plan_Line_Item__r.ASI_MFM_KR_subLedger__c'); //sub ledger id in plan line
        searchFields.add('ASI_MFM_Quantity__c'); //qunatity
        searchFields.add('ASI_MFM_Unit_Cost__c'); //unot cost
        searchFields.add('ASI_MFM_Plan_Line_Item__r.ASI_MFM_Total_Cost__c'); //total amount in plan line
        searchFields.add('ASI_MFM_Plan_Line_Item__r.ASI_MFM_Original_Total_Cost__c'); //original amount in plan line
        searchFields.add('ASI_MFM_Description__c'); //description 
        searchFields.add('ASI_MFM_Delivery_Date__c'); 
        searchFields.add('ASI_MFM_Basic_POSM__c'); 
        searchFields.add('ASI_MFM_Basic_POSM__r.name'); 
        searchFields.add('ASI_MFM_Plan_Line_Item__r.ASI_MFM_Venue_Where__c'); 
        
        searchFields.add('ASI_MFM_Plan_Line_Item__r.ASI_MFM_AccountsAdditionalField__r.name');  
        searchFields.add('ASI_MFM_Plan_Line_Item__r.ASI_MFM_Venue_Where__r.name'); 
        searchFields.add('ASI_MFM_Estimated_PR_budget__c');
        searchFields.add('ASI_MFM_Purchase_Request__r.ASI_MFM_Currency__c');
        searchFields.add('ASI_MFM_Rest_Amount__c');
        searchFields.add('ASI_MFM_UOM__c');         //Added by Kammy 18 Dec 2015
        searchFields.add('ASI_MFM_Consumer_Prize__c');  //Added 20180121 Introv
        String outputString = String.join(searchFields, ',');
        qs = qs + outputString + ' from ASI_MFM_Purchase_Request_Line__c where ASI_MFM_Purchase_Request__c = \'' + Header.ASI_MFM_Purchase_Request__c +'\' and ASI_MFM_Rest_Amount__c >0' ;
        return qs;
    }//end method: buildPRItemSoql
    //2015-11-26, add method copyPRD, for copy PR detail
    
    
      //
    @RemoteAction
    public static List<sObject> findCustomers(string obj, string qry)
    {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType sot = gd.get(obj);
        if (sot == null)
        {
            // Object name not valid
            return null;
        }//end if
        
        // create the filter text
        String filter = qry;
        
        //begin building the dynamic soql query
        
        String soql;
        if(filter != '' || filter != null)
            soql = 'select Id, Name,RecordType.DeveloperName, ASI_CRM_CN_Address__c, ASI_CRM_CN_Phone_Number__c from ' + obj + filter +' order by Name';
        else 
            soql = 'select Id, Name, RecordType.DeveloperName,ASI_CRM_CN_Address__c, ASI_CRM_CN_Phone_Number__c from ' + obj +' order by Name'; 
        
        List<sObject> sobjs = new List<sObject>();
        
        List<String> results = new List<String>();
        
        System.debug('soql:' + soql);
        
        try
        {
            sobjs = Database.query(soql);
            return sobjs; 
        }//end try
        catch (QueryException e)
        {
            return null;
        }//end catch
        return sobjs;
    }//end method: findSObjects    
    
     @RemoteAction
    public static List<sObject> findList(string obj,string statement, string qry)
    {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType sot = gd.get(obj);
        if (sot == null)
        {
            // Object name not valid
            return null;
        }//end if
        
        // create the filter text
        String filter = qry;
        
        //begin building the dynamic soql query
        String soql;
        if(filter != '' || filter != null)
            soql = 'select '+statement+' from ' + obj + filter +' order by Name';
        else
            soql = 'select '+statement+' from ' + obj +' order by Name';
        
        List<sObject> sobjs = new List<sObject>();
        
        List<String> results = new List<String>();
        
        System.debug('soql:' + soql);
        
        try
        {
            sobjs = Database.query(soql);
            return sobjs; 
        }//end try
        catch (QueryException e)
        {
            return null;
        }//end catch
        return sobjs;
    }
    
    
    
    
}