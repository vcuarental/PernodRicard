public class ASI_MFM_JP_PaymentManageAllCtrl {

    public ApexPages.StandardController standardController {get;set;}
    
    public ASI_MFM_Payment__c Header {get;set;}
    
    public Map<String, interimData> allPaymentLineItemMap {get;set;}{ allPaymentLineItemMap = new Map<String, interimData>();}
    
    //TBC: Using PO Line or PO Recipt Line
    public Map<String, ASI_MFM_PO_Receipt_Item__c> allPORLineMap {get;set;}{ allPORLineMap = new Map<String, ASI_MFM_PO_Receipt_Item__c>();}
    public String mapPORlineJSON {get{return JSON.serialize(allPORLineMap);}}
    
    public List<ASI_MFM_Payment_Line_Item__c> deleteLineItemList {get;set;}{deleteLineItemList = new List<ASI_MFM_Payment_Line_Item__c>();}
    public boolean SaveSuccess {get;set;}
    public ASI_MFM_objectPickListHelper subBrandPickList { get; set;}
    
    public boolean UpsertPermission {get;set;}{UpsertPermission=true;}     
    public String Msg {get;set;}
    public Integer LINE_ITEM_NEWRECORD_COUNTER {get;set;}
    public static String LINE_ITEM_NEWRECORD_PREFIX {get{ return 'z';}}
    
    //Attributes used for filtering POLs
    public String PlanIDFilter {get;set;}
    public String POFilter {get;set;}
    public String POlineFilter {get;set;}
    public String PORlineFilter {get;set;}
    public String subBrandNameFilter {get;set;}
    public String ACcodeFilter {get;set;}
    public String CurrencyFilter {get;set;}
    public Decimal PaymentAmount {get;set;} {PaymentAmount=0;}
    public Decimal TaxAmount {get;set;} {TaxAmount=0;}
    //Attributes used for remove payment line 
    public String removePaymentLine {get;set;}
    
    public map<string, id> rt_map {get;set;}{ rt_map = new Map<String, id>();}
    
    
       
    //Payment Line Amount
    public Class interimData{
        public ASI_MFM_Payment_Line_Item__c payl {get; set;}
        public string PORName {get; set;}
        public Decimal OrignalPoRAmount {get; set;}
        public Decimal PoRAmount {get; set;}
        public Decimal PoLRemain {get; set;}  //in JPY 
        public Decimal exchangerate {get; set;}
        public string POCurrency {get; set;}
        public string POLDescription {get; set;}
        public ASI_MFM_A_C_Code__c ACCode{get; set;}
        public ASI_MFM_Sub_brand__c SBCode {get; set;}
        public ASI_MFM_Plan__c Plan {get; set;}
        public ASI_MFM_AP_Code__c APCode {get; set;}
    }
    
    
    
    
    
    // Define the constructor
    public ASI_MFM_JP_PaymentManageAllCtrl(ApexPages.StandardController standardController){
        
        this.standardController = standardController;
        this.Header = (ASI_MFM_Payment__c) this.standardController.getRecord();
        
        if(this.Header !=null && this.Header.Id !=null){
            
            for(ASI_MFM_Payment__c payment : [Select id, recordType.developerName,ASI_MFM_JP_Payment_Date__c,ASI_MFM_Exchange_Rate__c,ASI_MFM_Payment_Amount__c,Name,ASI_MFM_Invoice_Amount__c,ASI_MFM_VAT_Adjustment__c,ASI_MFM_Invoice_Due_Date__c,ASI_MFM_VAT_Rate__c,ASI_MFM_Tax_Code__c,ASI_MFM_G_L_Date__c, ASI_MFM_Invoice_Number__c,ASI_MFM_Invoice_Date__c,ASI_MFM_Supplier_Name__c,ASI_MFM_Currency__c,ASI_MFM_Remarks__c,ASI_MFM_Supplier_Name__r.name FROM ASI_MFM_Payment__c where Id =: this.Header.Id limit 1]){
                this.Header = payment;
            }
            if(Header.ASI_MFM_Currency__c=='JPY'){
                PaymentAmount=(Header.ASI_MFM_Invoice_Amount__c/(1+Header.ASI_MFM_VAT_Rate__c/100)).setScale(0, roundingMode.half_up);
                TaxAmount=(PaymentAmount*(Header.ASI_MFM_VAT_Rate__c/100)).setScale(0, roundingMode.half_up);
            }else{
                PaymentAmount=(Header.ASI_MFM_Invoice_Amount__c/(1+Header.ASI_MFM_VAT_Rate__c/100)).setScale(2, roundingMode.half_up);
                TaxAmount=(PaymentAmount*(Header.ASI_MFM_VAT_Rate__c/100)).setScale(2, roundingMode.half_up);
            }
            
        }

    }
    
    
     // Initialize
    public void init() {
     
        rt_map= ASI_MFM_Function.getRecordTypeId('ASI_MFM_Payment_Line_Item__c');
        PlanIDFilter=null;
        POFilter=null;
        POlineFilter=null;
        PORlineFilter=null;
        subBrandNameFilter=null;
        ACcodeFilter=null;
        
        if(this.Header !=null && this.Header.Id !=null){
            
            //retrieveExchangeRate();
            
            //get Payment Lines  
            List<ASI_MFM_Payment_Line_Item__c> PaymentlineItemList = [select id, name,ASI_MFM_PO_Receipt_Item__r.name,ASI_MFM_PO_Receipt_Item__r.ASI_MFM_Remaining_Balance__c,ASI_MFM_PO_Receipt_Item__r.ASI_MFM_Payment_Amount__c,ASI_MFM_PO_Receipt_Item__r.ASI_MFM_PO_Receipt_Balance_Amount__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_Remaining_Balance__c,ASI_MFM_PO_Line_Remaining_Amount__c,ASI_MFM_VAT_Adjustment__c,ASI_MFM_Payment__r.ASI_MFM_Tax_Code__c,ASI_MFM_Phase_Code__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Plan__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_A_C_Code__r.name,ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.name,ASI_MFM_PO_Line_Item__r.ASI_MFM_AP_Code__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_AP_Code__r.name,
                                                                      ASI_MFM_Complete_PO__c,ASI_MFM_PO_Receipt_Item__r.ASI_MFM_Amount__c,ASI_MFM_PO__c,ASI_MFM_PO_Line_Item__c,ASI_MFM_PO_Receipt_Item__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_List_Item_Description__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__c,
                                                                      ASI_MFM_Payee__c,ASI_MFM_Payment_Amount__c,ASI_MFM_Payment_List_Item_Description__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.name,ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Plan__r.name,ASI_MFM_Payment__r.ASI_MFM_Exchange_Rate__c,
                                                                      ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Currency__c , ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Status__c
                                                                      from ASI_MFM_Payment_Line_Item__c where ASI_MFM_Payment__c=:Header.id];
            
            set<ID> porlineID_set = new set<ID>();
            if(!PaymentlineItemList.isEmpty()){ // Get existing data
                for(ASI_MFM_Payment_Line_Item__c Paymentline : PaymentlineItemList){
                    String porlId = (String)(Paymentline.ASI_MFM_PO_Receipt_Item__c);
                    if(!allPaymentLineItemMap.containsKey(porlId)){
                        interimData temp= new interimData();
                        temp.payl=Paymentline;
                        temp.PORName=Paymentline.ASI_MFM_PO_Receipt_Item__r.name;
                        //Orignal PO Receipt Amount 
                       	temp.OrignalPoRAmount=Paymentline.ASI_MFM_PO_Receipt_Item__r.ASI_MFM_Amount__c;
                        temp.POCurrency=Paymentline.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Currency__c;
                        //temp.exchangerate=Paymentline.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Payment_Exchange_Rate__c;
                        if(Paymentline.ASI_MFM_Payment__r.ASI_MFM_Exchange_Rate__c !=null && Paymentline.ASI_MFM_Payment__r.ASI_MFM_Exchange_Rate__c!=0 ){
                            temp.exchangerate=1/Paymentline.ASI_MFM_Payment__r.ASI_MFM_Exchange_Rate__c;
                        }else{
                            temp.exchangerate=1;
                        }
                        
                        
                        if(temp.exchangerate!=null || temp.exchangerate!=0){
                            //if(temp.exchangerate>1)
                            //temp.PoLRemain=(Paymentline.ASI_MFM_PO_Line_Item__r.ASI_MFM_Remaining_Balance__c+(1/temp.exchangerate)*Paymentline.ASI_MFM_Payment_Amount__c).setScale(2, roundingMode.half_up);
                           // else
                             temp.PoLRemain=(Paymentline.ASI_MFM_PO_Line_Item__r.ASI_MFM_Remaining_Balance__c+(temp.exchangerate)*Paymentline.ASI_MFM_Payment_Amount__c).setScale(2, roundingMode.half_up);
                        }else{
                            temp.PoLRemain=(Paymentline.ASI_MFM_PO_Line_Item__r.ASI_MFM_Remaining_Balance__c).setScale(2, roundingMode.half_up);
                        }
                        
                        
                        //if(exchangeRateTable.containsKey(Paymentline.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Currency__c)){
                        //    temp.exchangerate=exchangeRateTable.get(Paymentline.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Currency__c);
                       // }else{
                          //  temp.exchangerate=1;
                       // }
                       // Available PO Receipt Line Amount
                        if(Header.ASI_MFM_Currency__c=='JPY' && Paymentline.ASI_MFM_PO_Receipt_Item__c!=null){
                            //temp.PoRAmount=(Paymentline.ASI_MFM_PO_Receipt_Item__r.ASI_MFM_Amount__c*temp.exchangerate).setScale(0, roundingMode.half_up);
                            temp.PoRAmount=(Paymentline.ASI_MFM_PO_Receipt_Item__r.ASI_MFM_Remaining_Balance__c*temp.exchangerate+Paymentline.ASI_MFM_Payment_Amount__c).setScale(0, roundingMode.half_up);
                            
                        }else{
                            if(Paymentline.ASI_MFM_PO_Receipt_Item__c!=null){
                                  temp.PoRAmount=(Paymentline.ASI_MFM_PO_Receipt_Item__r.ASI_MFM_Remaining_Balance__c*temp.exchangerate+Paymentline.ASI_MFM_Payment_Amount__c).setScale(2, roundingMode.half_up);
                         
                            }
                             // if(temp.exchangerate>1)
                            //     temp.PoRAmount=(Paymentline.ASI_MFM_PO_Receipt_Item__r.ASI_MFM_Amount__c* 1/temp.exchangerate).setScale(2, roundingMode.half_up); 
                            //else{
                                // temp.PoRAmount=(Paymentline.ASI_MFM_PO_Receipt_Item__r.ASI_MFM_Amount__c* temp.exchangerate).setScale(2, roundingMode.half_up); 
                           // }
                        }
                        temp.POLDescription=Paymentline.ASI_MFM_PO_Line_Item__r.ASI_MFM_List_Item_Description__c;
                        
                        ASI_MFM_Plan__c pl=new ASI_MFM_Plan__c(id=Paymentline.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Plan__c,name=Paymentline.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Plan__r.name);
                        temp.Plan=pl;
                        
                        ASI_MFM_Sub_brand__c sb=new ASI_MFM_Sub_brand__c(id=Paymentline.ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__c,Name=Paymentline.ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.name);
                        temp.SBCode=sb;
                        
                        ASI_MFM_A_C_Code__c ac=new ASI_MFM_A_C_Code__c(id=Paymentline.ASI_MFM_PO_Line_Item__r.ASI_MFM_A_C_Code__c,name=Paymentline.ASI_MFM_PO_Line_Item__r.ASI_MFM_A_C_Code__r.name);
                        temp.ACCode=ac;
                           
                        ASI_MFM_AP_Code__c ap=new ASI_MFM_AP_Code__c(id=Paymentline.ASI_MFM_PO_Line_Item__r.ASI_MFM_AP_Code__c,name=Paymentline.ASI_MFM_PO_Line_Item__r.ASI_MFM_AP_Code__r.name);
                        temp.APCode=ap;
                        
                        allPaymentLineItemMap.put(porlId, temp);
                        porlineID_set.add(porlId);
                    }
                }
            }
            
            //Get PO Receipt Line ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Currency__c =:Header.ASI_MFM_Currency__c
            //and ASI_MFM_Paid__c=false and ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Payment_Currency__c=:Header.ASI_MFM_Currency__c 
            // AND ASI_MFM_Marketing_Verify__c=TRUE  - Removed on 17 Nov  AND ASI_MFM_PO_Receipt_Balance_Amount__c>0
            List<ASI_MFM_PO_Receipt_Item__c> PORlineList = [select ASI_MFM_PO_Receipt_Balance_Amount__c,ASI_MFM_Payment_Amount__c,ASI_MFM_Remaining_Balance__c,id,name,ASI_MFM_PO_Line_Item__r.ASI_MFM_Remaining_Balance__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Plan__r.name,ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Currency__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_List_Item_Description__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_AP_Code__r.name,ASI_MFM_PO_Line_Item__r.ASI_MFM_A_C_Code__r.name,ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.Name,ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Plan__c,ASI_MFM_PO__c,ASI_MFM_Remark__c,ASI_MFM_PO_Line_Item__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_A_C_Code__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_AP_Code__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_Brand_Name__c,ASI_MFM_Amount__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_Customer_Name__c from ASI_MFM_PO_Receipt_Item__c where ASI_MFM_PO__r.ASI_MFM_Supplier_Name__c=:Header.ASI_MFM_Supplier_Name__c and id not in: porlineID_set and ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Status__c='Final'   and ASI_MFM_Complete__c=false and ASI_MFM_Remaining_Balance__c>1] ;
            if(!PORlineList.isEmpty()){ 
                for(ASI_MFM_PO_Receipt_Item__c porl:PORlineList){
                    String porlid=(String)(porl.id);
                    if(!allPORLineMap.containsKey(porlid)){
                        allPORLineMap.put(porlid,porl);
                    }
                }
            }
        }
    }
    
    
    /*
    
    //Get Exchange Rate base Payment Currency
    public Map<String, Decimal> exchangeRateTable {set;get;} { exchangeRateTable = new Map<String, Decimal>();}
    public static List<String> availableCurrency {get { return new List<String>{'EUR', 'JPY', 'SGD', 'USD', 'HKD'  ,'GBP'};}}
    
    //Find the exchange rate table 
    public void retrieveExchangeRate(){
        
        string country = Header.recordType.developerName.substring(8, 10); //e.g. PH 
        String headerCurrency = Header.ASI_MFM_Currency__c; //e.g. PHP
        Map<String, String> CurrencyEffectiveMap = new Map<String, String>();
        
        AggregateResult[] CurrencyEffective =
            [Select ASI_MFM_Counter_Currency__c , Id, MAX(ASI_MFM_Effective_Date__c) from ASI_MFM_Exchange_Rate__c 
             where ASI_MFM_Application__c = 'MFM' and ASI_MFM_Country__c = : country
             and ASI_MFM_Base_Currency__c =: headerCurrency and ASI_MFM_Effective_Date__c <= :date.today()  
             and (ASI_MFM_Counter_Currency__c in: availableCurrency) group by ASI_MFM_Counter_Currency__c, Id];
        
        if(CurrencyEffective!=null){
            for(AggregateResult ar : CurrencyEffective){ 
                CurrencyEffectiveMap.put(String.ValueOf(ar.get('ASI_MFM_Counter_Currency__c')), String.ValueOf(ar.get('Id')));
            }
        }
        
        List<ASI_MFM_Exchange_Rate__c> exchangeRates = new List<ASI_MFM_Exchange_Rate__c>();
        
        exchangeRates =   [Select ASI_MFM_Counter_Currency__c, ASI_MFM_Exchange_Rate__c from ASI_MFM_Exchange_Rate__c 
                           where id in: CurrencyEffectiveMap.values()];
        
        if(exchangeRates!=null && exchangeRates.size()>0){
            
            for(ASI_MFM_Exchange_Rate__c ae : exchangeRates){
                exchangeRateTable.put(ae.ASI_MFM_Counter_Currency__c, ae.ASI_MFM_Exchange_Rate__c);
            }
     		 system.debug('exchangeRateTableTest :' + exchangeRateTable);  
        }
    }
    //Exchange Rate method Finished
    
     */
    
     // RemovePaymentLine
     // 1. Remove this Payment Line from the upper table 
    public void removePaymentLine() {
        SaveSuccess=false;
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String param_Id = params.get('PARAM_PAYLine_ID');
        if(allPaymentLineItemMap.containsKey(param_Id) && !allPaymentLineItemMap.isEmpty()){
            ASI_MFM_PO_Receipt_Item__c PORline=[select id,name,ASI_MFM_Payment_Amount__c,ASI_MFM_Remaining_Balance__c,ASI_MFM_PO_Receipt_Balance_Amount__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_Remaining_Balance__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_A_C_Code__r.name,ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.name,ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Plan__r.name,ASI_MFM_PO_Line_Item__r.ASI_MFM_List_Item_Description__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Currency__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Plan__c,ASI_MFM_PO__c,ASI_MFM_Remark__c,ASI_MFM_PO_Line_Item__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_A_C_Code__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_AP_Code__r.name,ASI_MFM_PO_Line_Item__r.ASI_MFM_AP_Code__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_Brand_Name__c,ASI_MFM_Amount__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_Customer_Name__c from ASI_MFM_PO_Receipt_Item__c where id=:allPaymentLineItemMap.get(param_Id).payl.ASI_MFM_PO_Receipt_Item__c];
            if(PORline!=null){
                String porlid=(String)(PORline.id);
                if(!allPORLineMap.containsKey(porlid)){
                    allPORLineMap.put(porlid,PORline);
                }
            }
            ASI_MFM_Payment_Line_Item__c delTarget=allPaymentLineItemMap.get(param_Id).payl;
            if(delTarget.id != null){
                deleteLineItemList.add(delTarget);
            }
            allPaymentLineItemMap.remove(param_Id);
        }
    }
    
    // 1. Add PO Line, 
    // 2. convert into Payment line
    // 3. Remove this PO Line from bottom table 
    public void addLineItem(){
        SaveSuccess=false;
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String param_SourceItemId = params.get('PARAM_PORLINE_SOURCE_ITEM_ID');
        if(allPORLineMap.containsKey(param_SourceItemId)){
            string newIDCounter = newCounterCreatorLine();
            interimData temp= new interimData();
            temp.OrignalPoRAmount=allPORLineMap.get(param_SourceItemId).ASI_MFM_Amount__c;
            
             temp.POCurrency=allPORLineMap.get(param_SourceItemId).ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Currency__c;
             temp.PORName=allPORLineMap.get(param_SourceItemId).name;
            if(Header.ASI_MFM_Exchange_Rate__c!=null && Header.ASI_MFM_Exchange_Rate__c!=0){
                temp.exchangerate=1/Header.ASI_MFM_Exchange_Rate__c;
            }else{
                temp.exchangerate=1;
            }
             
             //temp.exchangerate=allPORLineMap.get(param_SourceItemId).ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Payment_Exchange_Rate__c.setScale(2, roundingMode.half_up);
             
            //if(exchangeRateTable.containsKey(allPORLineMap.get(param_SourceItemId).ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Currency__c)){
            //    temp.exchangerate=exchangeRateTable.get(allPORLineMap.get(param_SourceItemId).ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Currency__c);
            //}else{
            //    temp.exchangerate=1;
           // }
			
           // if(temp.exchangerate!=null&& temp.exchangerate>1) temp.exchangerate = 1/temp.exchangerate.setScale(2, roundingMode.half_up);
            
            /*
            if(Header.ASI_MFM_Currency__c=='JPY'){
                tempAmount=(allPORLineMap.get(param_SourceItemId).ASI_MFM_Amount__c*temp.exchangerate).setScale(0, roundingMode.half_up);
                temp.PoRAmount=(allPORLineMap.get(param_SourceItemId).ASI_MFM_Amount__c*temp.exchangerate).setScale(0, roundingMode.half_up);
            }else{
                tempAmount=(allPORLineMap.get(param_SourceItemId).ASI_MFM_Amount__c*temp.exchangerate).setScale(2, roundingMode.half_up);
                temp.PoRAmount=(allPORLineMap.get(param_SourceItemId).ASI_MFM_Amount__c*temp.exchangerate).setScale(2, roundingMode.half_up);
            }
            */
            temp.PoLRemain=(allPORLineMap.get(param_SourceItemId).ASI_MFM_PO_Line_Item__r.ASI_MFM_Remaining_Balance__c).setScale(2, roundingMode.half_up);           
            Decimal tempAmount=0;
            
             if(Header.ASI_MFM_Currency__c=='JPY'){
                tempAmount=(allPORLineMap.get(param_SourceItemId).ASI_MFM_Remaining_Balance__c*temp.exchangerate).setScale(0, roundingMode.half_up);
                temp.PoRAmount=(allPORLineMap.get(param_SourceItemId).ASI_MFM_Remaining_Balance__c*temp.exchangerate).setScale(0, roundingMode.half_up);
            }else{
                tempAmount=(allPORLineMap.get(param_SourceItemId).ASI_MFM_Remaining_Balance__c*temp.exchangerate).setScale(2, roundingMode.half_up);
                temp.PoRAmount=(allPORLineMap.get(param_SourceItemId).ASI_MFM_Remaining_Balance__c*temp.exchangerate).setScale(2, roundingMode.half_up);
            }
            
            temp.POLDescription=allPORLineMap.get(param_SourceItemId).ASI_MFM_PO_Line_Item__r.ASI_MFM_List_Item_Description__c;
            
            ASI_MFM_Plan__c pl=new ASI_MFM_Plan__c(id=allPORLineMap.get(param_SourceItemId).ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Plan__c,name=allPORLineMap.get(param_SourceItemId).ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Plan__r.name);
            temp.Plan=pl;
            
            ASI_MFM_Sub_brand__c sb=new ASI_MFM_Sub_brand__c(id=allPORLineMap.get(param_SourceItemId).ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__c,Name=allPORLineMap.get(param_SourceItemId).ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.Name);
            temp.SBCode=sb;

            ASI_MFM_A_C_Code__c ac=new ASI_MFM_A_C_Code__c(id=allPORLineMap.get(param_SourceItemId).ASI_MFM_PO_Line_Item__r.ASI_MFM_A_C_Code__c,name=allPORLineMap.get(param_SourceItemId).ASI_MFM_PO_Line_Item__r.ASI_MFM_A_C_Code__r.name);
            temp.ACCode=ac;
            
            ASI_MFM_AP_Code__c ap=new ASI_MFM_AP_Code__c(id=allPORLineMap.get(param_SourceItemId).ASI_MFM_PO_Line_Item__r.ASI_MFM_AP_Code__c,name=allPORLineMap.get(param_SourceItemId).ASI_MFM_PO_Line_Item__r.ASI_MFM_AP_Code__r.name);
            temp.APCode=ap;
            
            temp.payl=new ASI_MFM_Payment_Line_Item__c(ASI_MFM_Payment__c=Header.id,
                                                       ASI_MFM_PO_Line_Item__c=allPORLineMap.get(param_SourceItemId).ASI_MFM_PO_Line_Item__c,
                                                       ASI_MFM_Payee__c=Header.ASI_MFM_Supplier_Name__c,
                                                       ASI_MFM_PO__c=allPORLineMap.get(param_SourceItemId).ASI_MFM_PO__c,
                                                       ASI_MFM_Payment_Amount__c=tempAmount,
                                                       ASI_MFM_VAT_Adjustment__c=0,
                                                       ASI_MFM_PO_Receipt_Item__c=allPORLineMap.get(param_SourceItemId).id,
                                                       recordTypeId=rt_map.get('ASI_MFM_JP_Payment_Line_Item')); 
            allPaymentLineItemMap.put(LINE_ITEM_NEWRECORD_PREFIX+newIDCounter,temp);
            allPORLineMap.remove(param_SourceItemId);
        }
        
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
    
    public void onCommitted(){
        UpsertPermission=true;
        SaveSuccess=true;
        Database.upsertResult[] upsertTarget;
        Database.deleteResult[] deleteTarget;
        List<ASI_MFM_Payment_Line_Item__c> upsertTargetList = new List<ASI_MFM_Payment_Line_Item__c>();
        //Set PO Receipt Item 'Paid' filed
        List<ASI_MFM_PO_Receipt_Item__c> upsertList = new List<ASI_MFM_PO_Receipt_Item__c>();
         Set<id> POReceiptItemId = new Set<id>();
         // Validation Checking
        UpsertPermission=valdationCheck(allPaymentLineItemMap);
         if(UpsertPermission){
            for(String key : allPaymentLineItemMap.keySet()){

                upsertTargetList.add(allPaymentLineItemMap.get(key).payl); 
                if(!POReceiptItemId.contains(allPaymentLineItemMap.get(key).payl.ASI_MFM_PO_Receipt_Item__c)){
                    POReceiptItemId.add(allPaymentLineItemMap.get(key).payl.ASI_MFM_PO_Receipt_Item__c);
                }   
                
               //  ASI_MFM_PO_Receipt_Item__c P0RItemp =NEW ASI_MFM_PO_Receipt_Item__c(); 
                //P0RItemp.ID=allPaymentLineItemMap.get(key).payl.ASI_MFM_PO_Receipt_Item__c;
                //P0RItemp.ASI_MFM_Paid__c=TRUE;
                //upsertList.add(P0RItemp);
            }
        }
         for(ASI_MFM_Payment_Line_Item__c pl:deleteLineItemList){
             if(!POReceiptItemId.contains(pl.ASI_MFM_PO_Receipt_Item__c)){
                    POReceiptItemId.add(pl.ASI_MFM_PO_Receipt_Item__c);
                }   
         }
        
        
        
       /*
        for(String key : allPaymentLineItemMap.keySet()){
            if(allPaymentLineItemMap.get(key).payl.ASI_MFM_Payment_Amount__c>allPaymentLineItemMap.get(key).PoRAmount*1.1){
                UpsertPermission=false;
                Msg='PO Receipt Amount: '+string.valueOf(allPaymentLineItemMap.get(key).PoRAmount);
            }
            if(UpsertPermission){//ASI_MFM_Adjustment_Amount__c
                upsertTargetList.add(allPaymentLineItemMap.get(key).payl);  //allPaymentLineItemMap.get(key).payl.ASI_MFM_Adjustment_Amount__c=allPaymentLineItemMap.get(key).payl.ASI_MFM_Payment_Amount__c;
                ASI_MFM_PO_Receipt_Item__c P0RItemp =NEW ASI_MFM_PO_Receipt_Item__c(); 
                P0RItemp.ID=allPaymentLineItemMap.get(key).payl.ASI_MFM_PO_Receipt_Item__c;
                P0RItemp.ASI_MFM_Paid__c=TRUE;
                upsertList.add(P0RItemp);
            }
        }
        */
        
        
        
        //Loop deleted List
        /*
        for(ASI_MFM_Payment_Line_Item__c pl:deleteLineItemList){
            ASI_MFM_PO_Receipt_Item__c P0RItemp =NEW ASI_MFM_PO_Receipt_Item__c();
            P0RItemp.ID=pl.ASI_MFM_PO_Receipt_Item__c;
            P0RItemp.ASI_MFM_Paid__c=false;
            upsertList.add(P0RItemp);
        }
        */
        
        try{
            if(UpsertPermission){
               SaveSuccess=false;
                //Update PO Receipt Item
               // update upsertList;
                if(deleteLineItemList.size()>0){
                    deleteTarget = Database.delete(deleteLineItemList);
                    deleteTarget.clear();
                }
                if(upsertTargetList.size()>0){
                    upsertTarget = Database.upsert(upsertTargetList);
                    SaveSuccess=true;
                }
                
                /*
                //Update PO Receipt Item(ASI_MFM_Payment_Amount__c)
                if(SaveSuccess){
                    //Get all related Payment line amount 
                    List<ASI_MFM_Payment_Line_Item__c> upsertpaymentList=[select id,ASI_MFM_PO_Receipt_Item__c,ASI_MFM_Payment_Amount__c,ASI_MFM_Payment__r.ASI_MFM_Exchange_Rate__c from ASI_MFM_Payment_Line_Item__c where ASI_MFM_PO_Receipt_Item__c in : POReceiptItemId];
                    
                    Map<Id,decimal> POR_Map=new Map<Id,decimal>();
                    for(Id PORLId:POReceiptItemId){
                        POR_Map.put(PORLId,0.00);
                    }
                    for(ASI_MFM_Payment_Line_Item__c pay:upsertpaymentList){
                        if(!POR_Map.containsKey(pay.ASI_MFM_PO_Receipt_Item__c)){
                            POR_Map.put(pay.ASI_MFM_PO_Receipt_Item__c, pay.ASI_MFM_Payment_Amount__c*pay.ASI_MFM_Payment__r.ASI_MFM_Exchange_Rate__c);
                        }else{
                            // accumulate all Payment amount 
                            decimal PaidAmount=POR_Map.get(pay.ASI_MFM_PO_Receipt_Item__c)+pay.ASI_MFM_Payment_Amount__c*pay.ASI_MFM_Payment__r.ASI_MFM_Exchange_Rate__c;
                            POR_Map.remove(pay.ASI_MFM_PO_Receipt_Item__c);
                            POR_Map.put(pay.ASI_MFM_PO_Receipt_Item__c, PaidAmount);
                        }
                    }
					
					//construct Update list                  
                     for(String key : POR_Map.keySet()){
                         ASI_MFM_PO_Receipt_Item__c P0RItemp =NEW ASI_MFM_PO_Receipt_Item__c();
                         P0RItemp.ID=key;
                         P0RItemp.ASI_MFM_Payment_Amount__c=POR_Map.get(key);
                         upsertList.add(P0RItemp);
                     }
                    if(upsertList.size()>0){
                        update upsertList;
                    }
                }
                //End Update
                

*/
            }else{
                SaveSuccess=false;
            }
        }catch(Exception e){
            UpsertPermission = false;
            Msg = e.getMessage();
        }
    }
    

    
    public Boolean valdationCheck(Map<String, interimData> allLineItemMap){
        Boolean isProcess = true;    
        Integer idx = 1;
        Msg='';
        Decimal TotalAmount=0;
        Decimal TotalPOLRemain=0;
        Decimal TotalPayment=0;    
        for(String key : allLineItemMap.keySet()){
            
            // JPY with no decimal
            if(Header.ASI_MFM_Currency__c=='JPY'){
                allLineItemMap.get(key).payl.ASI_MFM_Payment_Amount__c=allLineItemMap.get(key).payl.ASI_MFM_Payment_Amount__c.setScale(0, roundingMode.half_up);
            }     
            
            //Checking 1: Payment Amount > PO Receipt Amount
            //if(allLineItemMap.get(key).payl.ASI_MFM_Payment_Amount__c>1.1*allLineItemMap.get(key).PoRAmount){
            if(Header.ASI_MFM_Currency__c=='JPY' && allLineItemMap.get(key).payl.ASI_MFM_Payment_Amount__c>allLineItemMap.get(key).PoRAmount){
                isProcess=false;
                Msg += allLineItemMap.get(key).PORName+': Payment Amount > PO Receipt Amount: '+string.valueOf(allLineItemMap.get(key).PoRAmount)+Header.ASI_MFM_Currency__c+' <br/>';
            }
            //Checking 2: Calculate total amount and VAT Adjustment
            TotalPayment+=allLineItemMap.get(key).payl.ASI_MFM_Payment_Amount__c;
            if(allLineItemMap.get(key).exchangerate!=null|| allLineItemMap.get(key).exchangerate!=0){
                //In Payment Header Currency
                TotalPOLRemain+=allLineItemMap.get(key).PoLRemain/(allLineItemMap.get(key).exchangerate);
                //TotalPOLRemain+=allLineItemMap.get(key).PoLRemain/(allLineItemMap.get(key).exchangerate>1? 1/allLineItemMap.get(key).exchangerate: allLineItemMap.get(key).exchangerate);
            }
            
            
            
          	TotalAmount+=allLineItemMap.get(key).payl.ASI_MFM_Payment_Amount__c;
            if(allLineItemMap.get(key).payl.ASI_MFM_VAT_Adjustment__c!=null){
               TotalAmount+=allLineItemMap.get(key).payl.ASI_MFM_VAT_Adjustment__c;
            }else{
                allLineItemMap.get(key).payl.ASI_MFM_VAT_Adjustment__c=0;
            }
            idx++;
            
           
            
        }
          //Checking 3: if currency='JPY',Total Payment Amount> total PO line balance(JPY): 
        if(TotalPOLRemain<TotalPayment && Header.ASI_MFM_Currency__c=='JPY' && !ASI_MFM_ByPass_Setting.ByPassClass('ASI_MFM_JP_PaymentManageAllCtrl','JP')){
            isProcess=false;
            Msg +='Total Amount Error:You Input: '+TotalPayment+'   Total PO Line Remaining Amount:  '+TotalPOLRemain;
        }
        
        
        //Checking 4:Total Payment line Amount VS Header InvoiceAmount(exculde VAT)
        if(TotalAmount.setScale(0, roundingMode.half_up)!=PaymentAmount.setScale(0, roundingMode.half_up)){
            isProcess=false;
            Msg +='Total Amount not match:You Input: '+TotalAmount+'   Total Amount in Header:  '+PaymentAmount+' (Balance:'+(TotalAmount-PaymentAmount)+') ';
        }
        return isProcess;
        
    }
    
    
    
    /*
    
    // Get Object 
    public List<sObject> queryAll(ID filterID, String sObjectName, String filteringField, String extraQuery) {
    
        List<sObject> sObjectList = new List<sObject>();
        Map<String , Schema.SObjectType> globalDescription = Schema.getGlobalDescribe();  
        Schema.sObjectType sObjType = globalDescription.get(sObjectName);  
        Schema.DescribeSObjectResult r1 = sObjType.getDescribe();  
        
        Map<String, Schema.SObjectField> sObjectFieldMap = r1.fields.getMap();
        String theQuery = 'Select ';
        
        for(String fields  : sObjectFieldMap.keySet()){
            theQuery += fields + ' ,';
        }
        thequery = theQuery.subString(0,theQuery.length()-1);
        thequery +=' From '+sObjectName+' where '+filteringField+' = \''+ filterID + '\' ' + extraQuery;
                
        sObjectList = Database.query(theQuery);
        
        return sObjectList;
    }
    
    
    
    
    public void search(){
        String soql='select id,name,ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Currency__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.Name,ASI_MFM_PO__r.ASI_MFM_Supplier_Name__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Plan__c,ASI_MFM_PO__c,ASI_MFM_Remark__c,ASI_MFM_PO_Line_Item__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_A_C_Code__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_AP_Code__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_Brand_Name__c,ASI_MFM_Amount__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_Customer_Name__c from ASI_MFM_PO_Receipt_Item__c where RecordType.DeveloperName LIKE \'ASI_MFM_JP%\'';//
        
       // soql += ' AND ASI_MFM_PO__r.ASI_MFM_Supplier_Name__c = \'' + Header.ASI_MFM_Supplier_Name__c + '\''; //and id not in: porlineID_set'  ;  ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Currency__c =:Header.ASI_MFM_Currency__c]  and ASI_MFM_PO__r.ASI_MFM_Currency__c= \''+Header.ASI_MFM_Currency__c+ '\'
        soql += ' AND ASI_MFM_PO__r.ASI_MFM_Supplier_Name__c = \'' + Header.ASI_MFM_Supplier_Name__c + '\'and ASI_MFM_PO__r.ASI_MFM_Currency__c= \''+Header.ASI_MFM_Currency__c+ '\'';
        
        //begin building the dynamic soql query
        if(PlanIDFilter!=null && PlanIDFilter.length()>0){
            soql += ' and ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Plan__r.name LIKE \''+String.escapeSingleQuotes(PlanIDFilter)+'%\'';
        }
        if(POFilter!=null && POFilter.length()>0){
            soql += ' and ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.name LIKE \''+String.escapeSingleQuotes(POFilter)+'%\'';
        }
        if(POlineFilter!=null && POlineFilter.length()>0){
            soql += ' and ASI_MFM_PO_Line_Item__r.name LIKE \''+String.escapeSingleQuotes(POlineFilter)+'%\'';
        }
        if(PORlineFilter!=null && PORlineFilter.length()>0){
            soql += ' and name LIKE \''+String.escapeSingleQuotes(PORlineFilter)+'%\'';
        }
        
        if(subBrandNameFilter!=null && subBrandNameFilter.length()>0){
            soql += ' and ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.name LIKE \'%'+String.escapeSingleQuotes(subBrandNameFilter)+'%\'';
        }
        if(ACcodeFilter!=null && ACcodeFilter.length()>0){
            soql += ' and ASI_MFM_PO_Line_Item__r.ASI_MFM_A_C_Code__r.name LIKE \'%'+String.escapeSingleQuotes(ACcodeFilter)+'%\'';
        }
        
         if(CurrencyFilter!=null && CurrencyFilter.length()>0){
            soql += ' and ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Currency__c LIKE \'%'+String.escapeSingleQuotes(CurrencyFilter)+'%\'';
        }
        
        List<ASI_MFM_PO_Receipt_Item__c> PORlineLists=Database.query(soql);
        
        system.debug('TestSQL'+soql);
        allPORLineMap = new Map<String, ASI_MFM_PO_Receipt_Item__c>();
        if(!PORlineLists.isEmpty()){ 
                for(ASI_MFM_PO_Receipt_Item__c porl:PORlineLists){
                    String porlid=(String)(porl.id);
                    if(!allPORLineMap.containsKey(porlid)){
                        allPORLineMap.put(porlid,porl);
                    }
                }
            }
            
    }
    
    
    */

    
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
    
     public PageReference cancel() {
        Pagereference ref;
        ref = new PageReference('/'+Header.Id);
        ref.setRedirect(true);
        return ref;
    }

    @RemoteAction
    public static List<ASI_MFM_Payment_Line_Item__c>  PaymentLineItems (ID headerID){
        //get Payment Lines  
        List<ASI_MFM_Payment_Line_Item__c> PaymentlineItemList = new List<ASI_MFM_Payment_Line_Item__c>([Select id from ASI_MFM_Payment_Line_Item__c where ASI_MFM_Payment__c =: headerID ]);            
        return PaymentlineItemList;        
    }
    
    @RemoteAction
    public static List<ASI_MFM_Sub_brand__c> InitializeSubBrandList(String subBrandNameFilter){
            //get the Sub-Brand List
            //return new ASI_MFM_ObjectPickListHelper('ASI_MFM_PO_Line_Item__c','ASI_MFM_Sub_brand_Code__c');
            list <ASI_MFM_Sub_brand__c> subBrands = new List<ASI_MFM_Sub_brand__c>();
        if(subBrandNameFilter != ''){
            String query = 'select  id, name from ASI_MFM_Sub_brand__c where  RecordType.DeveloperName LIKE \'ASI_JP_Sub_brand%\' and Name like \'%' + subBrandNameFilter+ '%\'';
            subBrands = database.query(query);
        }    
        return subBrands;
    }
    @RemoteAction
    public static List<ASI_MFM_A_C_Code__c> InitializeACCodeList(String ACcodeFilter){
            //get the Sub-Brand List
            //return new ASI_MFM_ObjectPickListHelper('ASI_MFM_PO_Line_Item__c','ASI_MFM_Sub_brand_Code__c');
            list <ASI_MFM_A_C_Code__c> ACCodes = new List<ASI_MFM_A_C_Code__c>();
        if(ACcodeFilter != ''){
            String query = 'select  id, name from ASI_MFM_A_C_Code__c where RecordType.DeveloperName LIKE \'ASI_JP_A_C_Code%\' and Name like \'%' + ACcodeFilter+ '%\'';
            ACCodes = database.query(query);
        }    
        return ACCodes;
    }
 
   @RemoteAction
    public static String[] findSObjects(string obj, string qry) {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType sot = gd.get(obj);
        if (sot == null) {
            // Object name not valid
            return null;
        }
        
        // create the filter text
        String filter = qry;
        //begin building the dynamic soql query
        
        String soql = 'select Name from ' + obj + filter +' order by Name';
        List<sObject> sobjs = new List<sObject>();
        
        List<String> results = new List<String>();
        
        System.debug('soql:' + soql);
        
        try {
            sobjs = Database.query(soql);
            
            for(sObject sobj : sobjs){
               results.add(String.valueOf(sobj.get('Name'))); 
            }
        }
        catch (QueryException e) {
            return null;
        }
        return results;
   }
        
        
    
    

}