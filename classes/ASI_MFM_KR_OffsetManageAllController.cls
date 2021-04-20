//test: ASI_MFM_KR_OffsetManageAllControllerTest
public class ASI_MFM_KR_OffsetManageAllController {
    
    public ApexPages.StandardController standardController {get;set;}
    
    public ASI_MFM_Payment__c Header {get;set;}
    public ASI_MFM_Payment_Line_Item__c OffsetHeaderLine {get;set;}
    public ASI_MFM_Payment_Line_Item__c HeaderLine {get;set;}
    
    public Map<String, interimData> allPaymentLineItemMap {get;set;}{ allPaymentLineItemMap = new Map<String, interimData>();}
    public Map<String, selectedData> allselectedLineItemMap {get;set;}{ allselectedLineItemMap = new Map<String, selectedData>();}
 
    
    public Map<id, ASI_MFM_Tax_Code__c> TaxCodeMap {get;set;}{ TaxCodeMap = new Map<id, ASI_MFM_Tax_Code__c>();}
    
    public String mapselectedlineJSON {get{return JSON.serialize(allselectedLineItemMap);}}
    
    public List<ASI_MFM_Payment_Line_Item__c> deleteLineItemList {get;set;}{deleteLineItemList = new List<ASI_MFM_Payment_Line_Item__c>();}
    public boolean SaveSuccess {get;set;}
    
    
    public Map<String, Decimal> exchangeRateTable {set;get;} { exchangeRateTable = new Map<String, Decimal>();}
    public static List<String> availableCurrency {get { return new List<String>{'KRW', 'AUD', 'EUR', 'GBP' ,'HKD','SGD','USD'};}} 
    
    
    public boolean UpsertPermission {get;set;}{UpsertPermission=true;} 
    public boolean SearchPermission {get;set;}{SearchPermission=true;}     
    public String Msg {get;set;}
    public Integer LINE_ITEM_NEWRECORD_COUNTER {get;set;}
    public static String LINE_ITEM_NEWRECORD_PREFIX {get{ return 'z';}}
    public String SQLstatement {get;set;} {SQLstatement='';}
    
    
    public string Module  {get;set;}{Module='';}
    public map<string, id> rt_map {get;set;}{ rt_map = new Map<String, id>();}
    
    
    // Define the constructor
    public ASI_MFM_KR_OffsetManageAllController(ApexPages.StandardController standardController){
        
        this.standardController = standardController;
        this.Header = (ASI_MFM_Payment__c) this.standardController.getRecord();
        if(this.Header !=null && this.Header.Id !=null){
            
            for(ASI_MFM_Payment__c payment : [Select id,ASI_MFM_Status__c ,ASI_MFM_Is_Direct_Payment__c,ASI_MFM_Company__c,ASI_MFM_Venue_Loan_Payment__c,
                                              ASI_MFM_Need_Attachment__c,ASI_MFM_Pre_payment__c,ASI_MFM_Company_Code__c,ASI_MFM_AP_Remark__c, 
                                              ASI_MFM_Tax_Code__r.name,ASI_MFM_Exchange_Rate__c, recordType.developerName,ASI_MFM_Payment_Amount__c,Name,
                                              ASI_MFM_Invoice_Amount__c,ASI_MFM_VAT_Adjustment__c,ASI_MFM_Invoice_Due_Date__c,ASI_MFM_VAT_Rate__c,ASI_MFM_Tax_Code__c,
                                              ASI_MFM_G_L_Date__c, ASI_MFM_Invoice_Number__c,ASI_MFM_Invoice_Date__c,ASI_MFM_Supplier_Name__c,ASI_MFM_Currency__c,ASI_MFM_Remarks__c,ASI_MFM_Plan__c,
                                              ASI_MFM_Promotion_Month__c,
                                              ASI_MFM_Supplier_Name__r.name FROM ASI_MFM_Payment__c where Id =: this.Header.Id limit 1]){
                this.Header = payment;
            }
        }
        this.HeaderLine = new ASI_MFM_Payment_Line_Item__c ();
        this.OffsetHeaderLine = new ASI_MFM_Payment_Line_Item__c (); 
        this.HeaderLine.ASI_MFM_Plan_Number__c = this.Header.ASI_MFM_Plan__c;
        Module='POL';
    }
    
    
    
    //Find the exchange rate table 
    public void retrieveExchangeRate(){
           
        string country = 'KR';
        String headerCurrency = 'KRW';
        
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
                  
        }
    }
    
    
    
    // Initialize
    public void init() {
       rt_map= ASI_MFM_Function.getRecordTypeId('ASI_MFM_Payment_Line_Item__c');
	   retrieveExchangeRate(); 
    }
    public void searchPayment() {
        if(allPaymentLineItemMap.size()>0){
            allPaymentLineItemMap.clear();
        }
        
        SearchPermission = true;
		System.debug('searchPayment');	
        rt_map= ASI_MFM_Function.getRecordTypeId('ASI_MFM_Payment_Line_Item__c');
        
            SQLstatement=ASI_MFM_ByPass_Setting.ReturnSqlStatement('ASI_MFM_KR_findCustomers','Initialization','KR');
            //get Payment Lines  
            
            String init_soql = 'select id, name,'
                			+'ASI_MFM_PO__c,ASI_MFM_PO_Line_Item__c,ASI_MFM_Plan_Line_Item__c,'
                            +'ASI_MFM_Payment_Amount__c,ASI_MFM_Payment_List_Item_Description__c,ASI_MFM_Tax_Explanation_Code__c,ASI_MFM_Currency__c,ASI_MFM_Exchange_Rate__c,ASI_MFM_Company__c,ASI_MFM_CN_Pre_Payment__c,'
                            +'ASI_MFM_Plan_Number__c,ASI_MFM_KR_subLedger__c,ASI_MFM_Payment__c,ASI_MFM_Cashout_Payment_Number__c,ASI_MFM_Tax_Code__c,ASI_MFM_Sub_brand__c,ASI_MFM_Payee__c,ASI_MFM_Invoice_Number__c,'
                			+'ASI_MFM_Where_Customer__c,ASI_MFM_Beneficiary_Customer__c,ASI_MFM_PO_Receipt_Item__c,ASI_MFM_AP_Remark__c,ASI_MFM_Offset_Payment__c,ASI_MFM_Type__c,'
                
                            +'ASI_MFM_Plan_Number__r.id,ASI_MFM_Plan_Number__r.name,ASI_MFM_Promotion_Month__c,'
                            +'ASI_MFM_KR_subLedger__r.id,ASI_MFM_KR_subLedger__r.name,'
                            +'ASI_MFM_Payment__r.id,ASI_MFM_Payment__r.name,ASI_MFM_Payment__r.ASI_MFM_Tax_Code__c,ASI_MFM_Payment__r.ASI_MFM_Promotion_Month__c,ASI_MFM_Payment__r.ASI_MFM_Offset_Payment__c,ASI_MFM_Payment__r.ASI_MFM_Supplier_Name__c,ASI_MFM_Payment__r.ASI_MFM_Exchange_Rate__c,ASI_MFM_Payment__r.ASI_MFM_Currency__c,ASI_MFM_Payment__r.ASI_MFM_Company__c,ASI_MFM_Payment__r.ASI_MFM_Company_Code__c,ASI_MFM_Payment__r.ASI_MFM_Status__c,'
                            +'ASI_MFM_Cashout_Payment_Number__r.id,ASI_MFM_Cashout_Payment_Number__r.name,'
                            +'ASI_MFM_Tax_Code__r.id,ASI_MFM_Tax_Code__r.name,'
                            +'ASI_MFM_Sub_brand__r.id,ASI_MFM_Sub_brand__r.name,'
                            +'ASI_MFM_Payee__r.Id,ASI_MFM_Payee__r.name'
                            +' from ASI_MFM_Payment_Line_Item__c ';
        
			String WhereStatm = ' where ASI_MFM_Payment__r.ASI_MFM_Offset_Payment__c=true and recordTypeId= \''+ rt_map.get('ASI_MFM_KR_Payment_Line_Item') + '\''; 
            
        	if(HeaderLine.ASI_MFM_Promotion_Month__c!=null && HeaderLine.ASI_MFM_Promotion_Month__c!=''){
                WhereStatm +=' and ASI_MFM_Promotion_Month__c= \''+ HeaderLine.ASI_MFM_Promotion_Month__c +'\'';
            }
            if(HeaderLine.ASI_MFM_Plan_Number__c!=null){
                WhereStatm +=' and ASI_MFM_Plan_Number__c= \''+ HeaderLine.ASI_MFM_Plan_Number__c +'\'';
            }
        	if(HeaderLine.ASI_MFM_Cashout_Payment_Number__c!=null){
                WhereStatm +=' and ASI_MFM_Cashout_Payment_Number__c= \''+ HeaderLine.ASI_MFM_Cashout_Payment_Number__c +'\'';
            }
        	if(OffsetHeaderLine.ASI_MFM_Cashout_Payment_Number__c!=null){
                WhereStatm +=' and ASI_MFM_Payment__c= \''+ OffsetHeaderLine.ASI_MFM_Cashout_Payment_Number__c +'\'';
            }
        	if(HeaderLine.ASI_MFM_KR_subLedger__c!=null){
                WhereStatm +=' and ASI_MFM_KR_subLedger__c= \''+ HeaderLine.ASI_MFM_KR_subLedger__c +'\'';
            }
        	if(HeaderLine.ASI_MFM_Sub_brand__c!=null){
                WhereStatm +=' and ASI_MFM_Sub_brand__c= \''+ HeaderLine.ASI_MFM_Sub_brand__c +'\'';
            }
        	if(Header.ASI_MFM_Status__c!=null && Header.ASI_MFM_Status__c!=''){
                WhereStatm +=' and ASI_MFM_Payment__r.ASI_MFM_Status__c= \''+ Header.ASI_MFM_Status__c +'\'';
            }
			
        
			if(HeaderLine.ASI_MFM_Plan_Number__c==null){
        		SearchPermission = false;
            	Msg = 'Please Input Promotion Code';
                return;
            }
        
        	List<ASI_MFM_Payment_Line_Item__c> PaymentlineItemList = new List<ASI_MFM_Payment_Line_Item__c>();
            PaymentlineItemList = Database.query(init_soql + WhereStatm);

            if(!PaymentlineItemList.isEmpty()){ // Get existing data for Payment Line
                for(ASI_MFM_Payment_Line_Item__c Paymentline : PaymentlineItemList){
                        String paylId = (String)(Paymentline.id);
                    
                        interimData temp= new interimData();
                    	temp.payl = Paymentline;
	                    temp.payl.ASI_MFM_Company__c = Paymentline.ASI_MFM_Payment__r.ASI_MFM_Company__c;
                    	temp.payl.ASI_MFM_Offset_Payment__c = true;
                        
                    	temp.OrignalPaidAmount=Paymentline.ASI_MFM_Payment_Amount__c;
                        temp.exchangerate = 1;
	                    temp.editable = (Paymentline.ASI_MFM_Payment__r.ASI_MFM_Status__c=='Draft')? true:false;
                    
                        ASI_MFM_Plan__c pl=new ASI_MFM_Plan__c(id=Paymentline.ASI_MFM_Plan_Number__c,name=Paymentline.ASI_MFM_Plan_Number__r.name);
                        temp.Plan=pl;
                    	
                    	ASI_TnE_Branch_Channel__c bc =new ASI_TnE_Branch_Channel__c(id=Paymentline.ASI_MFM_KR_subLedger__c,Name=Paymentline.ASI_MFM_KR_subLedger__r.name);
                        temp.subLedger=bc; 
                    
                    	ASI_MFM_Payment__c pay = new ASI_MFM_Payment__c(id=Paymentline.ASI_MFM_Payment__c,name=Paymentline.ASI_MFM_Payment__r.name,ASI_MFM_Tax_Code__c=Paymentline.ASI_MFM_Payment__r.ASI_MFM_Tax_Code__c,ASI_MFM_Promotion_Month__c=Paymentline.ASI_MFM_Payment__r.ASI_MFM_Promotion_Month__c,ASI_MFM_Offset_Payment__c=Paymentline.ASI_MFM_Payment__r.ASI_MFM_Offset_Payment__c,ASI_MFM_Supplier_Name__c=Paymentline.ASI_MFM_Payment__r.ASI_MFM_Supplier_Name__c,ASI_MFM_Exchange_Rate__c=Paymentline.ASI_MFM_Payment__r.ASI_MFM_Exchange_Rate__c,ASI_MFM_Currency__c=Paymentline.ASI_MFM_Payment__r.ASI_MFM_Currency__c,ASI_MFM_Status__c=Paymentline.ASI_MFM_Payment__r.ASI_MFM_Status__c,ASI_MFM_Company__c=Paymentline.ASI_MFM_Payment__r.ASI_MFM_Company__c,ASI_MFM_Company_Code__c=Paymentline.ASI_MFM_Payment__r.ASI_MFM_Company_Code__c);
                        temp.pay=pay;
                    
                        ASI_MFM_Payment__c payCashout = new ASI_MFM_Payment__c(id=Paymentline.ASI_MFM_Cashout_Payment_Number__c,name=Paymentline.ASI_MFM_Cashout_Payment_Number__r.name);
                    	temp.payCashout=payCashout;
                    
                        ASI_MFM_Sub_brand__c sb=new ASI_MFM_Sub_brand__c(id=Paymentline.ASI_MFM_Sub_brand__c,Name=Paymentline.ASI_MFM_Sub_brand__r.name);
                        temp.SBCode=sb;
						
                    	Account payee=new Account(id=Paymentline.ASI_MFM_Payee__c,name=Paymentline.ASI_MFM_Payee__r.name);
                    	temp.payee=payee;
                        
                        allPaymentLineItemMap.put(paylId, temp);
               
                }
            }
        	system.debug('allPaymentLineItemMap:'+allPaymentLineItemMap);
    }
    
    
    public void cloneLine(){
        SaveSuccess=false;
        UpsertPermission=true;
        SearchPermission=true;
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String param_Id = params.get('PARAM_clone_ID');
         if(allPaymentLineItemMap.containsKey(param_Id) && !allPaymentLineItemMap.isEmpty() ){
            string newIDCounter = newCounterCreatorLine();
            interimData temp= new interimData();
            	ASI_MFM_Payment_Line_Item__c payl = new ASI_MFM_Payment_Line_Item__c(
                   																	ASI_MFM_Promotion_Month__c=allPaymentLineItemMap.get(param_Id).payl.ASI_MFM_Promotion_Month__c,
                                                                                    ASI_MFM_PO__c=allPaymentLineItemMap.get(param_Id).payl.ASI_MFM_PO__c,
                                                                                    ASI_MFM_PO_Line_Item__c=allPaymentLineItemMap.get(param_Id).payl.ASI_MFM_PO_Line_Item__c,
                    																ASI_MFM_Payment_Amount__c=allPaymentLineItemMap.get(param_Id).payl.ASI_MFM_Payment_Amount__c,
                                                                                    ASI_MFM_Payment_List_Item_Description__c=allPaymentLineItemMap.get(param_Id).payl.ASI_MFM_Payment_List_Item_Description__c,
                                                                                    ASI_MFM_Tax_Explanation_Code__c=allPaymentLineItemMap.get(param_Id).payl.ASI_MFM_Tax_Explanation_Code__c,
                                                                                    ASI_MFM_Company__c=allPaymentLineItemMap.get(param_Id).payl.ASI_MFM_Company__c,
                                                                                    ASI_MFM_Plan_Number__c=allPaymentLineItemMap.get(param_Id).payl.ASI_MFM_Plan_Number__c,
                                                                                    ASI_MFM_KR_subLedger__c=allPaymentLineItemMap.get(param_Id).payl.ASI_MFM_KR_subLedger__c,
                                                                                    ASI_MFM_Payment__c=allPaymentLineItemMap.get(param_Id).payl.ASI_MFM_Payment__c,
                                                                                    ASI_MFM_Cashout_Payment_Number__c=allPaymentLineItemMap.get(param_Id).payl.ASI_MFM_Cashout_Payment_Number__c,
                                                                                    ASI_MFM_Tax_Code__c=allPaymentLineItemMap.get(param_Id).payl.ASI_MFM_Tax_Code__c,
                                                                                    ASI_MFM_Sub_brand__c=allPaymentLineItemMap.get(param_Id).payl.ASI_MFM_Sub_brand__c,
                                                                                    ASI_MFM_Payee__c=allPaymentLineItemMap.get(param_Id).payl.ASI_MFM_Payee__c,
                                                                                    ASI_MFM_Invoice_Number__c=allPaymentLineItemMap.get(param_Id).payl.ASI_MFM_Invoice_Number__c,
                    																ASI_MFM_Plan_Line_Item__c=allPaymentLineItemMap.get(param_Id).payl.ASI_MFM_Plan_Line_Item__c,
																					ASI_MFM_Where_Customer__c=allPaymentLineItemMap.get(param_Id).payl.ASI_MFM_Where_Customer__c,
																					ASI_MFM_Beneficiary_Customer__c=allPaymentLineItemMap.get(param_Id).payl.ASI_MFM_Beneficiary_Customer__c,
																					ASI_MFM_PO_Receipt_Item__c=allPaymentLineItemMap.get(param_Id).payl.ASI_MFM_PO_Receipt_Item__c,
																					ASI_MFM_AP_Remark__c=allPaymentLineItemMap.get(param_Id).payl.ASI_MFM_AP_Remark__c,
																                    ASI_MFM_CN_Pre_Payment__c=allPaymentLineItemMap.get(param_Id).payl.ASI_MFM_CN_Pre_Payment__c,
																                    ASI_MFM_Offset_Payment__c=allPaymentLineItemMap.get(param_Id).payl.ASI_MFM_Offset_Payment__c,
                    																ASI_MFM_Type__c=allPaymentLineItemMap.get(param_Id).payl.ASI_MFM_Type__c,  
                                                                                 	recordTypeId=rt_map.get('ASI_MFM_KR_Payment_Line_Item'));
             
                temp.payl = payl;
                temp.OrignalPaidAmount=0;
                temp.exchangerate = allPaymentLineItemMap.get(param_Id).exchangerate;
                temp.editable = (allPaymentLineItemMap.get(param_Id).pay.ASI_MFM_Status__c=='Draft')? true:false;
                
                ASI_MFM_Plan__c pl=new ASI_MFM_Plan__c(id=allPaymentLineItemMap.get(param_Id).Plan.Id,name=allPaymentLineItemMap.get(param_Id).Plan.name);
                temp.Plan=pl;
             
             	ASI_TnE_Branch_Channel__c bc =new ASI_TnE_Branch_Channel__c(id=allPaymentLineItemMap.get(param_Id).subLedger.id,Name=allPaymentLineItemMap.get(param_Id).subLedger.Name);
                temp.subLedger=bc;
             
             	ASI_MFM_Payment__c pay = new ASI_MFM_Payment__c(id=allPaymentLineItemMap.get(param_Id).pay.id,name=allPaymentLineItemMap.get(param_Id).pay.name,ASI_MFM_Tax_Code__c=allPaymentLineItemMap.get(param_Id).pay.ASI_MFM_Tax_Code__c,ASI_MFM_Promotion_Month__c=allPaymentLineItemMap.get(param_Id).pay.ASI_MFM_Promotion_Month__c,ASI_MFM_Offset_Payment__c=allPaymentLineItemMap.get(param_Id).pay.ASI_MFM_Offset_Payment__c,ASI_MFM_Supplier_Name__c=allPaymentLineItemMap.get(param_Id).pay.ASI_MFM_Supplier_Name__c,ASI_MFM_Exchange_Rate__c=allPaymentLineItemMap.get(param_Id).pay.ASI_MFM_Exchange_Rate__c,ASI_MFM_Currency__c=allPaymentLineItemMap.get(param_Id).pay.ASI_MFM_Currency__c,ASI_MFM_Status__c=allPaymentLineItemMap.get(param_Id).pay.ASI_MFM_Status__c,ASI_MFM_Company__c=allPaymentLineItemMap.get(param_Id).pay.ASI_MFM_Company__c,ASI_MFM_Company_Code__c=allPaymentLineItemMap.get(param_Id).pay.ASI_MFM_Company_Code__c);
				temp.pay=pay;
             	
             	ASI_MFM_Payment__c payCashout = new ASI_MFM_Payment__c(id=allPaymentLineItemMap.get(param_Id).payCashout.id,name=allPaymentLineItemMap.get(param_Id).payCashout.name);
				temp.payCashout=payCashout;
             
             	ASI_MFM_Sub_brand__c sb=new ASI_MFM_Sub_brand__c(id=allPaymentLineItemMap.get(param_Id).SBCode.Id,Name=allPaymentLineItemMap.get(param_Id).SBCode.Name);
                temp.SBCode=sb;
             
             	Account payee=new Account(id=allPaymentLineItemMap.get(param_Id).payee.id,name=allPaymentLineItemMap.get(param_Id).payee.name);
				temp.payee=payee;
             
                allPaymentLineItemMap.put(LINE_ITEM_NEWRECORD_PREFIX+newIDCounter,temp);
                
             
         }
        
    }
    
    
    // RemovePaymentLine
    // 1. Remove this Payment Line from the upper table 
    public void removePaymentLine() {
        SaveSuccess=false;
        Map<String, String> params = ApexPages.currentPage().getParameters(); 
        String param_Id = params.get('PARAM_PAYLine_ID');
        if(allPaymentLineItemMap.containsKey(param_Id) && !allPaymentLineItemMap.isEmpty()){            
            
            ASI_MFM_Payment_Line_Item__c delTarget=allPaymentLineItemMap.get(param_Id).payl;
            if(delTarget.id != null){
                deleteLineItemList.add(delTarget);
            }
            allPaymentLineItemMap.remove(param_Id);
        }
    }
    
    
    //-----------------------------------------Save-------------------------------------     
    public void onCommitted(){
        system.debug('onCommitted');
        
        UpsertPermission=true;
        SearchPermission=true;
        SaveSuccess=true;
        Boolean NeedUpdateHeader =false;
        Database.upsertResult[] upsertTarget;
        Database.deleteResult[] deleteTarget;
        List<ASI_MFM_Payment_Line_Item__c> upsertTargetList = new List<ASI_MFM_Payment_Line_Item__c>();
        Set<id> POReceiptItemId = new Set<id>();
        
        //Set PO Receipt Item 'Paid' filed
        List<ASI_MFM_PO_Receipt_Item__c> upsertList = new List<ASI_MFM_PO_Receipt_Item__c>();
        
        List<ASI_MFM_PO_Line_Item__c> upsertPOLineList = new List<ASI_MFM_PO_Line_Item__c>();
        
        
        // Validation Checking
        UpsertPermission=valdationCheck(allPaymentLineItemMap);
        
        Set<Id> PORID= new Set<Id>();
        //Pass--> Upsert
        if(UpsertPermission){
            integer nextNumber=1;
            for(String key : allPaymentLineItemMap.keySet()){
                
                if(allPaymentLineItemMap.get(key).payl.ASI_MFM_Invoice_Number__c==null || allPaymentLineItemMap.get(key).payl.ASI_MFM_Invoice_Number__c==''){
                	allPaymentLineItemMap.get(key).payl.ASI_MFM_Invoice_Number__c = '_';
				}       
                
                //Upsert  Tax Explanation Code
                if(TaxCodeMap.containsKey(allPaymentLineItemMap.get(key).payl.ASI_MFM_Tax_Code__c)) allPaymentLineItemMap.get(key).payl.ASI_MFM_Tax_Explanation_Code__c=TaxCodeMap.get(allPaymentLineItemMap.get(key).payl.ASI_MFM_Tax_Code__c).ASI_MFM_Tax_Expl_Code__c;
                
                //Add a new field "Business Unit"(Picklist) in detail line. Values: P830 (222), J520(286), J530(286)
                //Based on choosen company in header, default value: Company = 222 : P830   *****     Company = 286:  J520
                if(allPaymentLineItemMap.get(key).pay.ASI_MFM_Company_Code__c=='222'){
                    allPaymentLineItemMap.get(key).payl.ASI_MFM_Business_Unit__c='P830';
                }else{
                    allPaymentLineItemMap.get(key).payl.ASI_MFM_Business_Unit__c='J520';
                }
                
                if(allPaymentLineItemMap.get(key).payl.ASI_MFM_Type__c.containsIgnoreCase('Default Provision')){
                    allPaymentLineItemMap.get(key).payl.ASI_MFM_Phase__c = 'A17';
                }else if(allPaymentLineItemMap.get(key).payl.ASI_MFM_Type__c.containsIgnoreCase('Write-off') || allPaymentLineItemMap.get(key).payl.ASI_MFM_Type__c.containsIgnoreCase('Write off')){
                    allPaymentLineItemMap.get(key).payl.ASI_MFM_Phase__c = '';
                }else{ 
                    allPaymentLineItemMap.get(key).payl.ASI_MFM_Phase__c = 'A00';
                }
                
                upsertTargetList.add(allPaymentLineItemMap.get(key).payl); 

            }
            
        }
        system.debug('upsertTargetList : '+ upsertTargetList);
      
          System.Savepoint sp = database.setSavepoint();
        try{
              
            if(UpsertPermission){
                SaveSuccess=false;
                
                
                //Update Payment Header 
                if(NeedUpdateHeader) update Header;
                
                //delete Payment Line 
                if(deleteLineItemList.size()>0){
                    deleteTarget = Database.delete(deleteLineItemList);
                    deleteTarget.clear();
                    deleteLineItemList.clear();
                    SaveSuccess=true;
                }
                
                //Upsert Payment Line 
                if(upsertTargetList.size()>0){
			        system.debug('onCommitted Upsert Payment Line');
                    upsertTarget = Database.upsert(upsertTargetList);
                    SaveSuccess=true;
                }
                
                //Update PO Line
                if(Header.ASI_MFM_Is_Direct_Payment__c){
                    if(upsertPOLineList.size()>0){
                        update upsertPOLineList;
                    }
                }                
                
            }else{
                SaveSuccess=false;
                deleteLineItemList.clear();
            }
            
        }catch(Exception e){
			system.debug('Exception : '+e.getMessage());
            UpsertPermission = false;
            SaveSuccess=FALSE;
            Msg = e.getMessage();
            database.rollback(sp);
        }
    }
    
    
    
    public Boolean valdationCheck(Map<String, interimData> allLineItemMap){
        Boolean isProcess = true;    
        Integer idx = 1;
        Msg='';
        Decimal TotalAmount=0;
        Decimal TotalPOLRemain=0;
        Decimal TotalPayment=0;    
        set<id> taxcodeset = new set<id>();
        for(String key : allLineItemMap.keySet()){
            
            if(allLineItemMap.get(key).editable==true){
                //Check Null
                if(allLineItemMap.get(key).payl.ASI_MFM_Payment_Amount__c==null){
                    isProcess=false;
                    Msg +='Line ' + idx +': Please Input Payment Amount<br/>.';
                } 
    
                if(allLineItemMap.get(key).payl.ASI_MFM_Payment_List_Item_Description__c==null){
                    isProcess=false;
                    Msg +='Line ' + idx +': Please Input Description<br/>.';
                } 
                
                if(allLineItemMap.get(key).payl.ASI_MFM_KR_subLedger__c==null){
                    isProcess=false;
                    Msg +='Line ' + idx +': Please Input Sub Ledger<br/>.';
                } 
            }    
           
            idx++;
            
            //
            
        }      
        TaxCodeMap= new map<id,ASI_MFM_Tax_Code__c>([select id,name,ASI_MFM_Tax_Expl_Code__c from ASI_MFM_Tax_Code__c where id in : taxcodeset]);
        return isProcess;
        
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
    
    
    
    // interim class
    //Payment Line Amount
    public Class interimData{
        public ASI_MFM_Payment_Line_Item__c payl {get; set;}
        public ASI_MFM_Payment__c pay {get; set;}


        public Decimal OrignalPaidAmount {get; set;} // Paid Amount Saved in DataBase
        public Decimal exchangerate {get; set;}{exchangerate=1;}// exchangeRateTable
        
        public ASI_MFM_Payment__c payCashout {get; set;}
        public ASI_MFM_Plan__c Plan {get; set;}
        public ASI_MFM_Sub_brand__c SBCode {get; set;}
        public ASI_TnE_Branch_Channel__c subLedger {get; set;}
		public Account payee {get; set;}
		
        public boolean editable {get; set;}{editable=true;}
        
        //define Constructor 
        public interimData(){}
    }
    
    public Class selectedData{
        public ASI_MFM_PO_Receipt_Item__c por {get; set;} 
        public ASI_MFM_PO_Line_Item__c pol {get; set;} 
        public Decimal PoRRemain {get; set;}{PoRRemain=0;}
        public Decimal PoLRemain {get; set;}{PoLRemain=0;}
    }
    

 
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
            soql = 'select Id, Name,RecordType.DeveloperName, ASI_CRM_CN_Address__c, ASI_CRM_CN_Phone_Number__c from ' + obj + filter ;
        else 
            soql = 'select Id, Name, RecordType.DeveloperName,ASI_CRM_CN_Address__c, ASI_CRM_CN_Phone_Number__c from ' + obj ; 
        
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
    
    
}