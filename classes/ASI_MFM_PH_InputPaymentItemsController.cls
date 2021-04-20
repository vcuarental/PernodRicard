public class ASI_MFM_PH_InputPaymentItemsController {
    
    public ApexPages.StandardController standardController {get;set;}
    
    public static final String DP_PO_RecordType_Developer_Name= 'ASI_MFM_PH_DP_PO';
    public static final String DF_PO_RecordType_Developer_Name= 'ASI_MFM_PH_DF_PO';
    
    public static final String DP_Payment_RecordType_Developer_Name= 'ASI_MFM_PH_DP_Payment';
    public static final String DF_Payment_RecordType_Developer_Name= 'ASI_MFM_PH_DF_Payment';
    
    //Data 
    public Map<String, interimData> allPaymentLineItemMap {get;set;}{ allPaymentLineItemMap = new Map<String, interimData>();}
     public  Map<String, interimPOL> allPOLineMap {get;set;}{ allPOLineMap = new Map<String, interimPOL>();}
    
    public ASI_MFM_Payment__c Header {get;set;}
    
    public String mapPOlineJSON {set;get;} // {get{return JSON.serialize(allPOLineMap);}}
    
    public List<ASI_MFM_Payment_Line_Item__c> deleteLineItemList {get;set;}{deleteLineItemList = new List<ASI_MFM_Payment_Line_Item__c>();}
    
    public Class interimData{
        public ASI_MFM_Payment_Line_Item__c payl {get; set;}
        //For Amount Checking Use: Payment Amount < PolAmount
        public Decimal PolAmount {get; set;}
        
        //PO Line Remaining Amount in Po Currency
        public Decimal PolRemaing {get; set;}
    
        public Decimal RequestedBalance {get; set;}
        //Orignal Po Line Amount : Display in Page
        public Decimal OrignalPolAmt {get; set;}
        
        public Decimal exchangerate {get; set;}
        public string POLCurrency {get; set;}
    }
    
    public Class interimPOL{
        public ASI_MFM_PO_Line_Item__c pol {get; set;}
        public Decimal PoBalance {get; set;}
        //PO Line Remaining Amount in Po Currency
        public Decimal PolRemaing {get; set;}
    }
    
    //Attributes used for filtering POLs
    public String PlanIDFilter {get;set;}
    public String POFilter {get;set;}
    public String POlineFilter {get;set;}
    public String PORlineFilter {get;set;}
    public String subBrandNameFilter {get;set;}
    public String APcodeFilter {get;set;}
    public String CurrencyFilter {get;set;}
    
    private String soql {get;set;} 
    
    //Save 
    public boolean SaveSuccess {get;set;}
    public boolean UpsertPermission {get;set;}{UpsertPermission=true;}     
    public String Msg {get;set;}
    public Integer LINE_ITEM_NEWRECORD_COUNTER {get;set;}
    public static String LINE_ITEM_NEWRECORD_PREFIX {get{ return 'z';}}
    
    public map<string, id> rt_map {get;set;}{ rt_map = new Map<String, id>();}
    
    public Transient String PO_RecordType_Developer_Name        {set;get;}
    // Define the constructor
    public ASI_MFM_PH_InputPaymentItemsController(ApexPages.StandardController standardController){
        this.standardController = standardController;
        this.Header = (ASI_MFM_Payment__c) this.standardController.getRecord();
    }
    
    public Map<String, Decimal> exchangeRateTable {set;get;} { exchangeRateTable = new Map<String, Decimal>();}
    public static List<String> availableCurrency {get { return new List<String>{'EUR', 'PHP', 'SGD', 'USD' ,'GBP'};}}

    //Find the exchange rate table 
    public void retrieveExchangeRate(){
        
           
        string country = Header.recordType.developerName.substring(8, 10); //e.g. PH 
        if(Header.recordType.developerName.substring(11, 13)=='DF'){
            country='SG';
        }
        
        String headerCurrency = Header.ASI_MFM_Currency__c; //e.g. PHP
        Map<String, String> CurrencyEffectiveMap = new Map<String, String>();
        
        //AggregateResult allows using group by, so we use AggregateResult rather than List to store the value
        AggregateResult[] CurrencyEffective =
            
            [Select ASI_MFM_Counter_Currency__c , Id, MAX(ASI_MFM_Effective_Date__c) from ASI_MFM_Exchange_Rate__c 
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
            system.debug('exchangeRateTable :' + exchangeRateTable);       
        }
    }
    
    
    
    public void init() {
        
        mapPOlineJSON = '';
        
        if(this.Header !=null && this.Header.Id !=null){
            for(ASI_MFM_Payment__c payment : [Select id, Name,ASI_MFM_Status__c,ownerId,CreatedById,RecordType.DeveloperName,ASI_MFM_JDE_Tax_Area__c,ASI_MFM_VAT_Amount__c,ASI_MFM_Tax_Area__c,ASI_MFM_VAT_Adjustment__c,ASI_MFM_Exchange_Rate__c,ASI_MFM_Invoice_Due_Date__c,ASI_MFM_VAT_Rate__c,ASI_MFM_Tax_Code__c,ASI_MFM_G_L_Date__c, ASI_MFM_Invoice_Number__c,ASI_MFM_Invoice_Date__c,ASI_MFM_Supplier_Name__c,ASI_MFM_Currency__c,ASI_MFM_Remarks__c,ASI_MFM_Supplier_Name__r.name ,ASI_MFM_Supplier_Name__r.ASI_TH_CRM_Supplier__c , ASI_MFM_Supplier_Name__r.ASI_MFM_Customer_Supplier_Number__c FROM ASI_MFM_Payment__c where Id =: this.Header.Id limit 1]){
                this.Header = payment;
            } 
            this.PO_RecordType_Developer_Name   =  this.Header.RecordType.DeveloperName.startsWithIgnoreCase(DF_Payment_RecordType_Developer_Name)?  DF_PO_RecordType_Developer_Name:  DP_PO_RecordType_Developer_Name;
            
            retrieveExchangeRate();
        }
        
        rt_map= ASI_MFM_Function.getRecordTypeId('ASI_MFM_Payment_Line_Item__c');
        
        PlanIDFilter=null;
        POFilter=null;
        POlineFilter=null;
        PORlineFilter=null;
        subBrandNameFilter=null;
        APcodeFilter=null;
        
        if(this.Header !=null && this.Header.Id !=null){        
            //get Payment Lines  
            //used for display in ResultTable
            // Modified by Calvin@Laputa (2018-11-15) - filter out records with and ASI_MFM_PO__r.ASI_MFM_Is_FOC_PO__c = false
            List<ASI_MFM_Payment_Line_Item__c> PaymentlineItemList = [select id, name,ASI_MFM_Complete_POL__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_Remaining_Balance__c,ASI_MFM_AP_Remark__c,ASI_MFM_Paid_Amount_in_PO_Currency__c,
                                                                      ASI_MFM_Invoice_Number__c,ASI_MFM_Invoice_Date__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_Amount__c,ASI_MFM_VAT_Adjustment__c,ASI_MFM_Payment__r.ASI_MFM_Tax_Code__c,
                                                                      ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Currency__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Tax_Rate__c,
                                                                      ASI_MFM_Complete_PO__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_Requested_Balance__c, ASI_MFM_A_C_Code__c, ASI_MFM_AP_Code__c, 
                                                                      ASI_MFM_PO__c,ASI_MFM_PO_Line_Item__c,ASI_MFM_Payee__c,ASI_MFM_Payment_Amount__c,ASI_MFM_Payment_List_Item_Description__c 
                                                                      from ASI_MFM_Payment_Line_Item__c where ASI_MFM_Payment__c=:Header.id and ASI_MFM_PO__r.ASI_MFM_Is_FOC_PO__c = false];
            
            set<ID> porlineID_set = new set<ID>();
            
            if(!PaymentlineItemList.isEmpty()){
                for(ASI_MFM_Payment_Line_Item__c Paymentline : PaymentlineItemList){
                    String porlId = (String)(Paymentline.ASI_MFM_PO_Line_Item__c);
                    if(!allPaymentLineItemMap.containsKey(porlId)){
                        interimData temp= new interimData();
                        temp.payl=Paymentline;
                        temp.payl.ASI_MFM_Tax_Rate__c=Paymentline.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Tax_Rate__c;
                        //PO Remaining Amount + Existing paymnent line Amount
                        
                        
                        
                        temp.OrignalPolAmt=Paymentline.ASI_MFM_PO_Line_Item__r.ASI_MFM_Amount__c;
                        temp.POLCurrency=Paymentline.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Currency__c;
                        if(exchangeRateTable.containsKey(Paymentline.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Currency__c)){
                            temp.exchangerate=exchangeRateTable.get(Paymentline.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Currency__c);
                        }else{
                            temp.exchangerate=1;
                        }
                        
                        temp.RequestedBalance=Paymentline.ASI_MFM_PO_Line_Item__r.ASI_MFM_Requested_Balance__c+Paymentline.ASI_MFM_Paid_Amount_in_PO_Currency__c;
                        
                        if(temp.exchangerate!=0){
                            temp.PolRemaing=(Paymentline.ASI_MFM_Payment_Amount__c/temp.exchangerate).setScale(2, roundingMode.half_up);
                        }else{
                            temp.PolRemaing=Paymentline.ASI_MFM_Payment_Amount__c;
                        }
                        
                        temp.PolAmount=Paymentline.ASI_MFM_PO_Line_Item__r.ASI_MFM_Remaining_Balance__c*temp.exchangerate+Paymentline.ASI_MFM_Payment_Amount__c;
                        
                        allPaymentLineItemMap.put(porlId, temp);
                        porlineID_set.add(porlId);
                    }
                }
            }
            
            
            //Used for SearchTable
            
            List<ASI_MFM_PO_Line_Item__c> POlineList = [select id,name,ASI_MFM_A_C_Code__c,ASI_MFM_PO__r.ASI_MFM_Plan__r.name,ASI_MFM_PO__r.ASI_MFM_Plan__c,ASI_MFM_A_C_Code__r.Name,ASI_MFM_G_L_Date__c,ASI_MFM_PO__c,ASI_MFM_PO__r.ASI_MFM_VAT__c,ASI_MFM_Currency__c,
                                                        ASI_MFM_Amount__c,ASI_MFM_Remaining_Balance__c,ASI_MFM_Sub_brand_Code__c,ASI_MFM_Sub_brand_Code__r.Name,ASI_MFM_Customer_Name__c,ASI_MFM_PO__r.ASI_MFM_Tax_Rate__c,ASI_MFM_PO__r.ASI_MFM_Currency__c,
                                                        ASI_MFM_PO_Raised_By__c, ASI_MFM_Requested_Balance__c, // Added on 7-9-2015 
                                                        ASI_MFM_AP_Code__c, ASI_MFM_AP_Code__r.name,
                                                        ASI_MFM_List_Item_Description__c from ASI_MFM_PO_Line_Item__c where ASI_MFM_PO__r.ASI_MFM_Supplier_Name__c=:Header.ASI_MFM_Supplier_Name__c 
                                                        and ASI_MFM_Requested_Balance__c>0 and id not in: porlineID_set  //and (ASI_MFM_PO_Status__c = 'Final') and ASI_MFM_Complete__c = false  // TBC ; copy from MY MFM   and ASI_MFM_PO__r.ASI_MFM_Currency__c=:Header.ASI_MFM_Currency__c
                                                        and (ASI_MFM_PO_Status__c = 'Final') and ASI_MFM_Complete__c = false and ASI_MFM_Requested_Balance__c > 0 //Copy from SG MFM //init_search = 'ASI_MFM_Requested_Balance__c > 0 and ASI_MFM_Complete__c = false and (ASI_MFM_PO_Status__c = \'Final\')';
                                                        and ASI_MFM_PO__r.RecordType.DeveloperName like :'%'+Header.RecordType.DeveloperName.substring(0,13)+'%'];
            
            //after filter, Polid will be inserted to a Map called allPOLineMap
            if(!POlineList.isEmpty()){
                for(ASI_MFM_PO_Line_Item__c pol:POlineList){
                    String polid=(String)(pol.id);
                    if(!allPOLineMap.containsKey(polid)){
                         interimPOL temp= new interimPOL();
                        temp.pol=pol;
                        temp.PoBalance=pol.ASI_MFM_Requested_Balance__c;
                        temp.PolRemaing=0;
                        allPOLineMap.put(polid,temp);
                    }
                }
                
                mapPOlineJSON = JSON.serialize(allPOLineMap);
            }else
            {
                mapPOlineJSON = ''; 
            }
        }
        
    }
    
    
    
    
    //----------------------------------Action----------------------------------
    //After click on add button, Add a record in Payment Line Items, Remove a record in PO line items 
    //After click on add button, get PO Line Item ID from pages and select data from database and store them into temp          * temp is a class
    //allPaymentLineItemMap.put(LINE_ITEM_NEWRECORD_PREFIX+newIDCounter,temp); << save data from temp to allPaymentLineItemMap
    public void addLineItem(){
        SaveSuccess=false;
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String param_SourceItemId = params.get('PARAM_POLINE_SOURCE_ITEM_ID');
        if(allPOLineMap.containsKey(param_SourceItemId)){
            string newIDCounter = newCounterCreatorLine();
            interimData temp= new interimData();
            
            
            temp.POLCurrency=allPOLineMap.get(param_SourceItemId).pol.ASI_MFM_PO__r.ASI_MFM_Currency__c;
            
            // Align the currency and exchange rate to POL  ********* Modified by 2018-08-22 Linus@introv
            /*if(exchangeRateTable.containsKey(allPOLineMap.get(param_SourceItemId).pol.ASI_MFM_PO__r.ASI_MFM_Currency__c)){
                temp.exchangerate=exchangeRateTable.get(allPOLineMap.get(param_SourceItemId).pol.ASI_MFM_PO__r.ASI_MFM_Currency__c);
            }else{
                temp.exchangerate=1;
            }*/            
            temp.exchangerate=1;
            
            temp.OrignalPolAmt=allPOLineMap.get(param_SourceItemId).pol.ASI_MFM_Amount__c;
            temp.PolAmount=(allPOLineMap.get(param_SourceItemId).pol.ASI_MFM_Remaining_Balance__c*temp.exchangerate).setScale(2, roundingMode.half_up);
            temp.PolRemaing=allPOLineMap.get(param_SourceItemId).PolRemaing;
            temp.RequestedBalance=allPOLineMap.get(param_SourceItemId).PoBalance.setScale(2, roundingMode.half_up);
            temp.payl=new ASI_MFM_Payment_Line_Item__c(ASI_MFM_Payment__c=Header.id,
                                                       ASI_MFM_PO_Line_Item__c=allPOLineMap.get(param_SourceItemId).pol.id,
                                                       ASI_MFM_Payee__c=Header.ASI_MFM_Supplier_Name__c,
                                                       ASI_MFM_PO__c=allPOLineMap.get(param_SourceItemId).pol.ASI_MFM_PO__c,
                                                       ASI_MFM_Tax_Rate__c=allPOLineMap.get(param_SourceItemId).pol.ASI_MFM_PO__r.ASI_MFM_Tax_Rate__c,
                                                       //ASI_MFM_Payment_Amount__c=allPOLineMap.get(param_SourceItemId).ASI_MFM_Remaining_Balance__c, (TBC 7-9-2015)
                                                       ASI_MFM_Payment_Amount__c = (allPOLineMap.get(param_SourceItemId).PoBalance.setScale(2, roundingMode.half_up)*temp.exchangerate).setScale(2, roundingMode.half_up),
                                                       ASI_MFM_Invoice_Date__c=Header.ASI_MFM_Invoice_Date__c,
                                                       ASI_MFM_Invoice_Number__c=Header.ASI_MFM_Invoice_Number__c,
                                                       //Added by 2018-06-20 Linus@introv
                                                       ASI_MFM_AP_Code__c=allPOLineMap.get(param_SourceItemId).pol.ASI_MFM_AP_Code__c,
                                                       ASI_MFM_A_C_Code__c=allPOLineMap.get(param_SourceItemId).pol.ASI_MFM_A_C_Code__c,
                                                       recordTypeId=rt_map.get('ASI_MFM_PH_Payment_Line_Item')); 
            allPaymentLineItemMap.put(LINE_ITEM_NEWRECORD_PREFIX+newIDCounter,temp);
            allPOLineMap.remove(param_SourceItemId);
        }
        mapPOlineJSON = JSON.serialize(allPOLineMap);
    }
    
  
    public PageReference saveLinetems(){
        PageReference pageRef = null;
        onCommitted();
        if (UpsertPermission){
            pageRef = new PageReference('/'+Header.Id);
            pageRef.setRedirect(true);
        }else{
            pageRef = null;
        }
        
        return pageRef;
    }

    /*Method: For Quick-Save and Save Button*/
    public PageReference SaveItems(){ 
        
        
        PageReference pageRef = null;
        
        UpsertPermission = true;
        SaveSuccess = false;
        
        //Get value from the pages
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String isQuickSaveStr = params.get('IS_QUICK_SAVE');
        
        Boolean isQuickSave = (isQuickSaveStr==null)?false:Boolean.valueOf(isQuickSaveStr);    
        
        Database.upsertResult[] upsertPaymentLinesResults;
        Database.deleteResult[] deletePaymentLinesResults;
        
        List<ASI_MFM_Payment_Line_Item__c> upsertTargetList = new List<ASI_MFM_Payment_Line_Item__c>();
        Integer idx = 1; 
        Msg='';
        
        
 
        
        Boolean isRedirect = True; 
        
        if(!allPaymentLineItemMap.isEmpty()){
            isRedirect = valdationCheck(allPaymentLineItemMap);
        }
        
        if(!isRedirect){
            
            UpsertPermission = false;
            SaveSuccess = false;
            return null;
            
        }
        
        
        if(UpsertPermission){

          for(String key : allPaymentLineItemMap.keySet()){
                
                upsertTargetList.add(allPaymentLineItemMap.get(key).payl);
            }
            
        }
        
        
        
        System.Savepoint pSavepoint = Database.setSavepoint();
        
        
        try{
            
                if(deleteLineItemList.size()>0){
                    system.debug('--Remove line--:' + deleteLineItemList);
                    deletePaymentLinesResults = Database.delete(deleteLineItemList);
                    deleteLineItemList.clear();
                }
                if(upsertTargetList.size()>0){
                    system.debug('--Upsert Line--:' + upsertTargetList);
                    upsertPaymentLinesResults = Database.upsert(upsertTargetList);
                }
                
            
            SaveSuccess = true;
            
        }catch(Exception e){
            system.debug('EnterFailes'+e);
            msg += 'Save Error : ' +e.getMessage() + '</br>';
            pageRef = null;
            Database.rollback(pSavepoint);      
            UpsertPermission = false;
            SaveSuccess = false; 
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Fatal,e.getDmlMessage(0)));
            return null;
        }
        
        if (!isQuickSave){
            pageRef = new PageReference('/'+Header.Id);
            pageRef.setRedirect(true);
        }     
        
        return pageRef;
        
    } 
    
    public void onCommitted(){
        UpsertPermission=true;
        SaveSuccess=true;
        Database.upsertResult[] upsertTarget;
        Database.deleteResult[] deleteTarget;
        List<ASI_MFM_Payment_Line_Item__c> upsertTargetList = new List<ASI_MFM_Payment_Line_Item__c>();
        Integer idx = 1; 
        Msg='';
        
        
        // Validation Checking
        UpsertPermission=valdationCheck(allPaymentLineItemMap);
        
        if(UpsertPermission){
            for(String key : allPaymentLineItemMap.keySet()){
                upsertTargetList.add(allPaymentLineItemMap.get(key).payl);
            }
            
        }
        
        system.debug(upsertTargetList+'TestEallPaymentLineItemMap'+UpsertPermission);
        try{
            if(UpsertPermission){
                if(deleteLineItemList.size()>0){
                    system.debug('--Remove line--:' + deleteLineItemList);
                    deleteTarget = Database.delete(deleteLineItemList);
                    deleteLineItemList.clear();
                }
                if(upsertTargetList.size()>0){
                    system.debug('--Upsert Line--:' + upsertTargetList);
                    upsertTarget = Database.upsert(upsertTargetList);
                }
                SaveSuccess=true;
            }else{
                SaveSuccess=false;
            }
        }catch(Exception e){
            msg +='Save Error! ' + e.getMessage() + '</br>';
            SaveSuccess = false;
            UpsertPermission = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Save Error!' + e));
        }    
    }
    
    
    
    public Boolean valdationCheck(Map<String, interimData> allLineItemMap){
        Map<String,date> InvoiceCheck = new Map<String,date>();
        Boolean isProcess = true;
        String OneTaxCode='';
        Integer idx = 1; 
        msg = '';
        if(allLineItemMap == null) return false;  
        
        for(String key : allLineItemMap.keySet()){
            
            if(allLineItemMap.get(key).payl.ASI_MFM_Payment_Amount__c==null){
                isProcess=false;
                Msg +='Line ' + idx +' :Payment Amount Cannot be Null.'+ '</br>';
            }  
            
            if(allLineItemMap.get(key).payl.ASI_MFM_Invoice_Number__c==null){
                isProcess=false;
                Msg +='Line ' + idx +' :Payment Invoice Number Cannot be Null.'+ '</br>';
            }
            if(allLineItemMap.get(key).payl.ASI_MFM_Invoice_Date__c==null){
                isProcess=false;
                Msg +='Line ' + idx +' :Payment Invoice Date Cannot be Null.'+ '</br>';
            }
            
            
            //Payment Amount checking updated 20160313
            if(allLineItemMap.get(key).payl.ASI_MFM_Payment_Amount__c>allLineItemMap.get(key).RequestedBalance){
                isProcess=false;
                Msg +='Line ' + idx +' :Payment Amount greater than PO Remaning amount.'+allLineItemMap.get(key).RequestedBalance+ '</br>';
            }
            
            //Invoice Date checking
            if(InvoiceCheck.containsKey(allLineItemMap.get(key).payl.ASI_MFM_Invoice_Number__c)){
                if(InvoiceCheck.get(allLineItemMap.get(key).payl.ASI_MFM_Invoice_Number__c)!=allLineItemMap.get(key).payl.ASI_MFM_Invoice_Date__c){
                    isProcess=false;
                    Msg +='Line ' + idx +' One Invoice should have one Invoice Date'+ '</br>';
                }
            }else{
                InvoiceCheck.put(allLineItemMap.get(key).payl.ASI_MFM_Invoice_Number__c, allLineItemMap.get(key).payl.ASI_MFM_Invoice_Date__c);
            }
            
            //DP Checking: One Payment should have one Vat Rate
            if(Header.RecordType.DeveloperName=='ASI_MFM_PH_DP_Payment'){
                if(idx==1){
                    OneTaxCode=allLineItemMap.get(key).payl.ASI_MFM_Tax_Rate__c;
                }else{
                    if(OneTaxCode!=allLineItemMap.get(key).payl.ASI_MFM_Tax_Rate__c){
                        isProcess=false;
                        Msg +='Please select lines with same VAT.'+ '</br>';
                    }
                }
            }
            
           
            idx++;
            
        }
        return isProcess;
    }
    
    
    
    
    
    public void removePaymentLine() {
        UpsertPermission=true;
        SaveSuccess=false;
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String param_Id = params.get('PARAM_PAYLine_ID');
        if(allPaymentLineItemMap.containsKey(param_Id) && !allPaymentLineItemMap.isEmpty()){
            ASI_MFM_PO_Line_Item__c POline=[select id,name,ASI_MFM_A_C_Code__c, ASI_MFM_AP_Code__c, ASI_MFM_G_L_Date__c,ASI_MFM_PO__c, ASI_MFM_PO_Line_Item__c.ASI_MFM_Sub_brand_Code__r.Name,ASI_MFM_PO__r.ASI_MFM_Plan__c,ASI_MFM_PO__r.ASI_MFM_VAT__c,ASI_MFM_PO__r.ASI_MFM_Tax_Rate__c,
                                            ASI_MFM_Amount__c,ASI_MFM_Remaining_Balance__c,ASI_MFM_Sub_brand_Code__c,ASI_MFM_Customer_Name__c,ASI_MFM_List_Item_Description__c,ASI_MFM_PO__r.ASI_MFM_Currency__c,ASI_MFM_Requested_Balance__c from
                                            ASI_MFM_PO_Line_Item__c where id=:allPaymentLineItemMap.get(param_Id).payl.ASI_MFM_PO_Line_Item__c];
            if(POline!=null){
                //POline.ASI_MFM_Requested_Balance__c=POline.ASI_MFM_Requested_Balance__c+allPaymentLineItemMap.get(param_Id).payl.ASI_MFM_Payment_Amount__c;
                String polid=(String)(POline.id);
                if(!allPOLineMap.containsKey(polid)){
                    /*
                    ASI_MFM_Payment_Line_Item__c PolinPYL = new ASI_MFM_Payment_Line_Item__c();
                    PolinPYL=[select id,ASI_MFM_Payment_Amount__c from ASI_MFM_Payment_Line_Item__c where ASI_MFM_PO_Line_Item__c=:allPaymentLineItemMap.get(param_Id).payl.ASI_MFM_PO_Line_Item__c and ASI_MFM_Payment__c=:Header.id];
                     */
                    
                    interimPOL temp= new interimPOL();
                    temp.pol=POline;
                    temp.PoBalance=allPaymentLineItemMap.get(param_Id).PolRemaing+POline.ASI_MFM_Requested_Balance__c;// ; 
                    temp.PolRemaing=allPaymentLineItemMap.get(param_Id).PolRemaing;
                    
                    /*
                    if(PolinPYL.id!=null){
                        if(allPaymentLineItemMap.get(param_Id).exchangerate!=null && allPaymentLineItemMap.get(param_Id).exchangerate!=0){
                            temp.PoBalance=POline.ASI_MFM_Requested_Balance__c+(PolinPYL.ASI_MFM_Payment_Amount__c/allPaymentLineItemMap.get(param_Id).exchangerate);
                        }else{
                            temp.PoBalance=POline.ASI_MFM_Requested_Balance__c+PolinPYL.ASI_MFM_Payment_Amount__c;
                        }
                        
                    }else{
                        temp.PoBalance=POline.ASI_MFM_Requested_Balance__c;
                    }
                    */
                    allPOLineMap.put(polid,temp);
                }
            }
            ASI_MFM_Payment_Line_Item__c delTarget=allPaymentLineItemMap.get(param_Id).payl;
            if(delTarget.id != null){
                deleteLineItemList.add(delTarget);
            }
            allPaymentLineItemMap.remove(param_Id);
        }
        mapPOlineJSON = allPOLineMap!=null? JSON.serialize(allPOLineMap):'';
    }
    
    public PageReference cancel() {
        Pagereference ref;
        ref = new PageReference('/'+Header.Id);
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