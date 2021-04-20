public class ASI_MFM_KR_PaymentManageAllController {
    // test : ASI_MFM_KR_ManageAll_TestClass
    public ApexPages.StandardController standardController {get;set;}
    
    public ASI_MFM_Payment__c Header {get;set;}
    
    public Map<String, interimData> allPaymentLineItemMap {get;set;}{ allPaymentLineItemMap = new Map<String, interimData>();}
    public Map<String, selectedData> allselectedLineItemMap {get;set;}{ allselectedLineItemMap = new Map<String, selectedData>();}
 
    
    public Map<id, ASI_MFM_Tax_Code__c> TaxCodeMap {get;set;}{ TaxCodeMap = new Map<id, ASI_MFM_Tax_Code__c>();}
    
    public String mapselectedlineJSON {get{return JSON.serialize(allselectedLineItemMap);}}
    
    public List<ASI_MFM_Payment_Line_Item__c> deleteLineItemList {get;set;}{deleteLineItemList = new List<ASI_MFM_Payment_Line_Item__c>();}
    public boolean SaveSuccess {get;set;}
    
    
    public Map<String, Decimal> exchangeRateTable {set;get;} { exchangeRateTable = new Map<String, Decimal>();}
    public static List<String> availableCurrency {get { return new List<String>{'KRW', 'AUD', 'EUR', 'GBP' ,'HKD','SGD','USD'};}} 
    
    
    public boolean UpsertPermission {get;set;}{UpsertPermission=true;}     
    public String Msg {get;set;}
    public Integer LINE_ITEM_NEWRECORD_COUNTER {get;set;}
    public static String LINE_ITEM_NEWRECORD_PREFIX {get{ return 'z';}}
    public String SQLstatement {get;set;} {SQLstatement='';}
    
    //Attributes used for filtering POLs
    public String PlanIDFilter {get;set;}
    public String POFilter {get;set;}
    public String POlineFilter {get;set;}
    public String PORlineFilter {get;set;}
    public String subBrandNameFilter {get;set;}
    public String ACcodeFilter {get;set;}//public String CurrencyFilter {get;set;}
    
    //Attributes used for remove payment line  //public String removePaymentLine {get;set;}
    
    public string Module  {get;set;}{Module='';}
    public map<string, id> rt_map {get;set;}{ rt_map = new Map<String, id>();}
    
    
    // Define the constructor
    public ASI_MFM_KR_PaymentManageAllController(ApexPages.StandardController standardController){
        
        this.standardController = standardController;
        this.Header = (ASI_MFM_Payment__c) this.standardController.getRecord();
        
        if(this.Header !=null && this.Header.Id !=null){
            
            for(ASI_MFM_Payment__c payment : [Select id,ASI_MFM_Status__c ,ASI_MFM_Is_Direct_Payment__c,ASI_MFM_Company__c,ASI_MFM_Venue_Loan_Payment__c ,
                                              ASI_MFM_Need_Attachment__c,ASI_MFM_Pre_payment__c,ASI_MFM_Company_Code__c,ASI_MFM_AP_Remark__c, 
                                              ASI_MFM_Tax_Code__r.name,ASI_MFM_Exchange_Rate__c, recordType.developerName,ASI_MFM_Payment_Amount__c,Name,
                                              ASI_MFM_Invoice_Amount__c,ASI_MFM_VAT_Adjustment__c,ASI_MFM_Invoice_Due_Date__c,ASI_MFM_VAT_Rate__c,ASI_MFM_Tax_Code__c,ASI_MFM_Cash_Out_Payment__c,
                                              ASI_MFM_G_L_Date__c, ASI_MFM_Invoice_Number__c,ASI_MFM_Invoice_Date__c,ASI_MFM_Supplier_Name__c,ASI_MFM_Currency__c,ASI_MFM_Remarks__c,ASI_MFM_Plan__c,
                                              ASI_MFM_Supplier_Name__r.name FROM ASI_MFM_Payment__c where Id =: this.Header.Id limit 1]){
                this.Header = payment;
                if(payment.ASI_MFM_Venue_Loan_Payment__c  || payment.ASI_MFM_Is_Direct_Payment__c){
                    Module='POL';
                }ELSE{
                    Module='POR';
                }
            }
        }
    }
    
    
    
    //Find the exchange rate table 
    public void retrieveExchangeRate(){
        
           
        string country = Header.recordType.developerName.substring(8, 10); 
        
        
        String headerCurrency = Header.ASI_MFM_Currency__c;
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
        retrieveExchangeRate();
        rt_map= ASI_MFM_Function.getRecordTypeId('ASI_MFM_Payment_Line_Item__c');
        PlanIDFilter=null;
        POFilter=null;
        POlineFilter=null;
        PORlineFilter=null;
        subBrandNameFilter=null;
        ACcodeFilter=null;
        
        if(this.Header !=null && this.Header.Id !=null){
            SQLstatement=ASI_MFM_ByPass_Setting.ReturnSqlStatement('ASI_MFM_KR_findCustomers','Initialization','KR');
            //get Payment Lines  
            
            List<ASI_MFM_Payment_Line_Item__c> PaymentlineItemList = [select id, name,ASI_MFM_PO_Line_Item__r.ASI_MFM_AccountsAdditionalField__c,ASI_MFM_Where_Customer__c,ASI_MFM_Beneficiary_Customer__c,
                                                                      ASI_MFM_PO_Line_Item__r.ASI_MFM_Remaining_Balance__c,ASI_MFM_PO_Line_Remaining_Amount__c,ASI_MFM_VAT_Adjustment__c,ASI_MFM_Payment__r.ASI_MFM_Tax_Code__c,ASI_MFM_BC_Code__c,ASI_MFM_Phase_Code__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Plan__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_A_C_Code__r.name,ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.name,ASI_MFM_PO_Line_Item__r.ASI_MFM_AP_Code__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_AP_Code__r.name,
                                                                      ASI_MFM_Complete_PO__c,ASI_MFM_PO_Receipt_Item__r.ASI_MFM_Amount__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_AP_Code__r.ASI_MFM_Attachments_for_Payment_Request__c,
                                                                      ASI_MFM_PO_Line_Item__r.ASI_MFM_AP_Code__r.ASI_MFM_AP_Type__c,ASI_MFM_KR_subLedger__c,
                                                                      ASI_MFM_PO__c,ASI_MFM_PO_Line_Item__c,ASI_MFM_PO_Receipt_Item__c,
                                                                      ASI_MFM_PO_Line_Item__r.ASI_MFM_List_Item_Description__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c,
                                                                      ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__c,ASI_MFM_Where_Customer__r.name,
                                                                      ASI_MFM_Beneficiary_Customer__r.name,
                                                                      ASI_MFM_Payee__c,ASI_MFM_Payment_Amount__c,ASI_MFM_Business_Unit__c,
                                                                      ASI_MFM_Payment_List_Item_Description__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.name,
                                                                      ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Plan__r.name,ASI_MFM_PO_Line_Item__r.ASI_MFM_AP_Code__r.ASI_MFM_Beneficiary_WS_Venue__c,
                                                                      ASI_MFM_PO_Line_Item__r.ASI_MFM_Purchase_Request_Line__c,
                                                                      ASI_MFM_AP_Remark__c,ASI_MFM_Tax_Code__c,ASI_MFM_Tax_Code__r.name, 
                                                                      ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Currency__c ,
                                                                      ASI_MFM_PO_Line_Item__r.ASI_MFM_Product_Item__r.name,ASI_MFM_PO_Line_Item__r.ASI_MFM_Product_Item__c, 
                                                                      ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Status__c,ASI_MFM_Invoice_Number__c,ASI_MFM_Invoice_Date__c,
                                                                      ASI_MFM_PO_Line_Item__r.ASI_MFM_KR_subLedger__c, ASI_MFM_PO_Line_Item__r.ASI_MFM_KR_subLedger__r.Name // ----- 2015-12-22
                                                                      from ASI_MFM_Payment_Line_Item__c 
                                                                      where ASI_MFM_Payment__c=:Header.id];
            
            set<ID> porlineID_set = new set<ID>();
            set<ID> polineID_set = new set<ID>();
            if(!PaymentlineItemList.isEmpty()){ // Get existing data for Payment Line
                for(ASI_MFM_Payment_Line_Item__c Paymentline : PaymentlineItemList){
                        String paylId = (String)(Paymentline.id);
                        String porlId = (String)(Paymentline.ASI_MFM_PO_Receipt_Item__c);
                        String polId = (String)(Paymentline.ASI_MFM_PO_Line_Item__c);
                   // if((!allPaymentLineItemMap.containsKey(porlId) && Module=='POR') || (!allPaymentLineItemMap.containsKey(polId) && Module=='POL') ){
                        interimData temp= new interimData(Paymentline, Paymentline.ASI_MFM_PO_Receipt_Item__r.ASI_MFM_Amount__c,
                                                          (Paymentline.ASI_MFM_PO_Line_Item__r.ASI_MFM_Remaining_Balance__c).setScale(2, roundingMode.half_up),
                                                          Paymentline.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Currency__c,
                                                          Paymentline.ASI_MFM_PO_Line_Item__r.ASI_MFM_List_Item_Description__c,
                                                          Paymentline.ASI_MFM_PO_Line_Item__r.ASI_MFM_AP_Code__r.ASI_MFM_AP_Type__c,exchangeRateTable);
                        if(temp.payl.ASI_MFM_PO__c==null){
                            temp.payl.ASI_MFM_PO__c=Paymentline.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c;
                        }
                        //Paid Amount in DataBase  
                        temp.OrignalPaidAmount=Paymentline.ASI_MFM_Payment_Amount__c;
                        temp.POLDescription=Paymentline.ASI_MFM_PO_Line_Item__r.ASI_MFM_List_Item_Description__c;
                        temp.APType=Paymentline.ASI_MFM_PO_Line_Item__r.ASI_MFM_AP_Code__r.ASI_MFM_AP_Type__c;
                        ASI_MFM_Plan__c pl=new ASI_MFM_Plan__c(id=Paymentline.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Plan__c,name=Paymentline.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Plan__r.name);
                        temp.Plan=pl;
                        temp.CustomerId=Paymentline.ASI_MFM_Beneficiary_Customer__c;
                        temp.Customer=Paymentline.ASI_MFM_Beneficiary_Customer__r.name;
                        temp.VenueWhere=Paymentline.ASI_MFM_Where_Customer__r.name;
                        temp.VenueWhereId=Paymentline.ASI_MFM_Where_Customer__c;
                        ASI_MFM_PO_Line_Item__c pol=new ASI_MFM_PO_Line_Item__c(id=Paymentline.ASI_MFM_PO_Line_Item__c,ASI_MFM_Purchase_Request_Line__c=Paymentline.ASI_MFM_PO_Line_Item__r.ASI_MFM_Purchase_Request_Line__c);
                        temp.poline=pol;
                        
                        ASI_MFM_Sub_brand__c sb=new ASI_MFM_Sub_brand__c(id=Paymentline.ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__c,Name=Paymentline.ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.name);
                        temp.SBCode=sb;
                        
                        ASI_TnE_Branch_Channel__c bc =new ASI_TnE_Branch_Channel__c(id=Paymentline.ASI_MFM_PO_Line_Item__r.ASI_MFM_KR_subLedger__c,Name=Paymentline.ASI_MFM_PO_Line_Item__r.ASI_MFM_KR_subLedger__r.Name);
                        temp.subLedger=bc; 
                    
                        ASI_MFM_A_C_Code__c ac=new ASI_MFM_A_C_Code__c(id=Paymentline.ASI_MFM_PO_Line_Item__r.ASI_MFM_A_C_Code__c,name=Paymentline.ASI_MFM_PO_Line_Item__r.ASI_MFM_A_C_Code__r.name);
                        temp.ACCode=ac;
                    
                        ASI_MFM_AP_Code__c ap=new ASI_MFM_AP_Code__c(id=Paymentline.ASI_MFM_PO_Line_Item__r.ASI_MFM_AP_Code__c,name=Paymentline.ASI_MFM_PO_Line_Item__r.ASI_MFM_AP_Code__r.name,ASI_MFM_Attachments_for_Payment_Request__c=Paymentline.ASI_MFM_PO_Line_Item__r.ASI_MFM_AP_Code__r.ASI_MFM_Attachments_for_Payment_Request__c,ASI_MFM_Beneficiary_WS_Venue__c=Paymentline.ASI_MFM_PO_Line_Item__r.ASI_MFM_AP_Code__r.ASI_MFM_Beneficiary_WS_Venue__c);
                        temp.APCode=ap;
                        
                        allPaymentLineItemMap.put(paylId, temp);
                        porlineID_set.add(porlId);
                        
                        polineID_set.add(polId);
               
                }
            }
            
            
            if(!Header.ASI_MFM_Is_Direct_Payment__c){
                //Get PO Line/ PO Receipt Line  
                if(Module=='POL'){
                    // Modified by 2017-12-14 Linus@introv
                    // If there is a payment linked with plan, it will only show the PO lines linked with that Plan   
                    List<ASI_MFM_PO_Line_Item__c> POlineList= Header.ASI_MFM_Plan__c == null ? [select id,name,ASI_MFM_Tax_Code__c,ASI_MFM_Plan_Line_Item__c,ASI_MFM_Plan_Line_Item__r.ASI_MFM_Venue_Where__c,ASI_MFM_Plan_Line_Item__r.ASI_MFM_Venue_Where__r.name,ASI_MFM_AccountsAdditionalField__r.name,ASI_MFM_AccountsAdditionalField__c,ASI_MFM_Remaining_Balance__c,ASI_MFM_PO__r.ASI_MFM_Plan__r.name,ASI_MFM_PO__r.ASI_MFM_Currency__c,ASI_MFM_List_Item_Description__c,ASI_MFM_AP_Code__r.Name,ASI_MFM_Purchase_Request_Line__c,
                                                              ASI_MFM_A_C_Code__r.name,ASI_MFM_Sub_brand_Code__c,ASI_MFM_Sub_brand_Code__r.Name,ASI_MFM_Sub_Brand_Name__c,ASI_MFM_Amount__c,ASI_MFM_Customer_Name__c,ASI_MFM_AP_Code__r.ASI_MFM_AP_Type__c,
                                                              ASI_MFM_PO__r.ASI_MFM_Plan__c,ASI_MFM_PO__c,ASI_MFM_A_C_Code__c,ASI_MFM_AP_Code__c,ASI_MFM_AP_Code__r.ASI_MFM_Attachments_for_Payment_Request__c,ASI_MFM_AP_Code__r.ASI_MFM_Beneficiary_WS_Venue__c,
                                                              ASI_MFM_KR_subLedger__c, ASI_MFM_KR_subLedger__r.Name from ASI_MFM_PO_Line_Item__c where //ASI_MFM_PO__r.ASI_MFM_Supplier_Name__c=:Header.ASI_MFM_Supplier_Name__c and
                                                              id not in: polineID_set and ASI_MFM_Has_Receipt__c=0 and  ASI_MFM_PO__r.ASI_MFM_Currency__c =:Header.ASI_MFM_Currency__c and ASI_MFM_PO__r.ASI_MFM_Is_Direct_Payment__c=false and
                                                              ASI_MFM_PO__r.ASI_MFM_Status__c='Approved' and ASI_MFM_PO__r.ASI_MFM_Company_Code__c =: Header.ASI_MFM_Company_Code__c and ASI_MFM_Remaining_Balance__c>0 and ASI_MFM_Plan_Line_Item__r.ASI_MFM_Plan__r.ASI_MFM_Pre_Payment__c=true]:
                                                              [select id,name,ASI_MFM_Tax_Code__c,ASI_MFM_Plan_Line_Item__c,ASI_MFM_Plan_Line_Item__r.ASI_MFM_Venue_Where__c,ASI_MFM_Plan_Line_Item__r.ASI_MFM_Venue_Where__r.name,ASI_MFM_AccountsAdditionalField__r.name,ASI_MFM_AccountsAdditionalField__c,ASI_MFM_Remaining_Balance__c,ASI_MFM_PO__r.ASI_MFM_Plan__r.name,ASI_MFM_PO__r.ASI_MFM_Currency__c,ASI_MFM_List_Item_Description__c,ASI_MFM_AP_Code__r.Name,ASI_MFM_Purchase_Request_Line__c,
                                                              ASI_MFM_A_C_Code__r.name,ASI_MFM_Sub_brand_Code__c,ASI_MFM_Sub_brand_Code__r.Name,ASI_MFM_Sub_Brand_Name__c,ASI_MFM_Amount__c,ASI_MFM_Customer_Name__c,ASI_MFM_AP_Code__r.ASI_MFM_AP_Type__c,
                                                              ASI_MFM_PO__r.ASI_MFM_Plan__c,ASI_MFM_PO__c,ASI_MFM_A_C_Code__c,ASI_MFM_AP_Code__c,ASI_MFM_AP_Code__r.ASI_MFM_Attachments_for_Payment_Request__c,ASI_MFM_AP_Code__r.ASI_MFM_Beneficiary_WS_Venue__c,
                                                              ASI_MFM_KR_subLedger__c, ASI_MFM_KR_subLedger__r.Name from ASI_MFM_PO_Line_Item__c where //ASI_MFM_PO__r.ASI_MFM_Supplier_Name__c=:Header.ASI_MFM_Supplier_Name__c and
                                                              id not in: polineID_set and ASI_MFM_Has_Receipt__c=0 and  ASI_MFM_PO__r.ASI_MFM_Currency__c =:Header.ASI_MFM_Currency__c and ASI_MFM_PO__r.ASI_MFM_Is_Direct_Payment__c=false and
                                                              ASI_MFM_PO__r.ASI_MFM_Status__c='Approved' and ASI_MFM_PO__r.ASI_MFM_Company_Code__c =: Header.ASI_MFM_Company_Code__c and ASI_MFM_Remaining_Balance__c>0 and ASI_MFM_Plan_Line_Item__r.ASI_MFM_Plan__r.ASI_MFM_Pre_Payment__c=true and ASI_MFM_PO__r.ASI_MFM_Plan__c =: Header.ASI_MFM_Plan__c];
                    if(!POlineList.isEmpty()){ 
                        for(ASI_MFM_PO_Line_Item__c pol:POlineList){
                            String polid=(String)(pol.id);
                            if(!allselectedLineItemMap.containsKey(polid)){
                                selectedData temp= new selectedData();
                                temp.pol=pol;
                                temp.PoLRemain=pol.ASI_MFM_Remaining_Balance__c;
                                allselectedLineItemMap.put(polid,temp);
                            }
                        }
                    }// end If   
                    
                    
                }else{  // 
                    List<ASI_MFM_PO_Receipt_Item__c> PORlineList = [select id,name,ASI_MFM_PO_Line_Item__r.ASI_MFM_Product_Item__r.Name,ASI_MFM_Remaining_Balance__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_Product_Item__c,
                                                                    ASI_MFM_PO_Line_Item__r.ASI_MFM_AccountsAdditionalField__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_Remaining_Balance__c,
                                                                    ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Plan__r.name,ASI_MFM_PO_Line_Item__r.ASI_MFM_AP_Code__r.ASI_MFM_Beneficiary_WS_Venue__c,
                                                                    ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Currency__c,ASI_MFM_Venue_Where__c,ASI_MFM_AccountsAdditionalField__c,
                                                                    ASI_MFM_PO_Line_Item__r.ASI_MFM_List_Item_Description__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_Tax_Code__c,
                                                                    ASI_MFM_PO_Line_Item__r.ASI_MFM_AP_Code__r.name,ASI_MFM_PO_Line_Item__r.ASI_MFM_Purchase_Request_Line__c,
                                                                    ASI_MFM_PO_Line_Item__r.ASI_MFM_A_C_Code__r.name,ASI_MFM_Plan_Line_Item__c,
                                                                    ASI_MFM_PO_Line_Item__r.ASI_MFM_AP_Code__r.ASI_MFM_AP_Type__c,
                                                                    ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_AP_Code__r.ASI_MFM_Attachments_for_Payment_Request__c,
                                                                    ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.Name,
                                                                    ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Plan__c,ASI_MFM_PO__c,
                                                                    ASI_MFM_Remark__c,ASI_MFM_PO_Line_Item__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_A_C_Code__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_AP_Code__c,
                                                                    ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_Brand_Name__c,ASI_MFM_Amount__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_Customer_Name__c,
                                                                    ASI_MFM_PO_Line_Item__r.ASI_MFM_KR_subLedger__c, ASI_MFM_PO_Line_Item__r.ASI_MFM_KR_subLedger__r.Name
                                                                    from ASI_MFM_PO_Receipt_Item__c 
                                                                    where ASI_MFM_PO__r.ASI_MFM_Supplier_Name__c=:Header.ASI_MFM_Supplier_Name__c and
                                                                    id not in: porlineID_set and ASI_MFM_Paid__c=false and ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Currency__c =:Header.ASI_MFM_Currency__c and 
                                                                    ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Status__c='Approved' and ASI_MFM_PO_Line_Item__r.ASI_MFM_PrePayment_Amount_in_PO_Currency__c=0 and 
                                                                    ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Company_Code__c =: Header.ASI_MFM_Company_Code__c and ASI_MFM_Remaining_Balance__c>0] ;    
                    if(!PORlineList.isEmpty()){ 
                        for(ASI_MFM_PO_Receipt_Item__c porl:PORlineList){
                            String porlid=(String)(porl.id);
                            if(!allselectedLineItemMap.containsKey(porlid)){
                                selectedData temp= new selectedData();
                                temp.por=porl;
                                temp.PoRRemain=porl.ASI_MFM_Remaining_Balance__c;
                                allselectedLineItemMap.put(porlid,temp);
                            }
                        }
                    }// end If
                    
                }
            }
        }
    }
    
    
    
    // 1. Add PO Line, 
    // 2. convert into Payment line
    // 3. Remove this PO Line from bottom table 
    public void addLineItem(){
        SaveSuccess=false;
        Map<String, String> params = ApexPages.currentPage().getParameters();  
        String param_SourceItemId = params.get('PARAM_PORLINE_SOURCE_ITEM_ID');
        AddLineFunction(param_SourceItemId);
        
    }
    
    public void AddLineFunction(string param_SourceItemId){
        
        if(allselectedLineItemMap.containsKey(param_SourceItemId)){
            string newIDCounter = newCounterCreatorLine();
            interimData temp;
            Decimal tempAmount=0;
            Decimal fx=1;
            
            if(Module=='POL'){
                //Get exchange Rate to calculate amount         ASI_MFM_Invoice_Number__c=Header.ASI_MFM_Invoice_Number__c, 
                if(allselectedLineItemMap.get(param_SourceItemId).pol.ASI_MFM_PO__r.ASI_MFM_Currency__c!=Header.ASI_MFM_Currency__c && exchangeRateTable.containsKey(allselectedLineItemMap.get(param_SourceItemId).pol.ASI_MFM_PO__r.ASI_MFM_Currency__c)){
                    fx=exchangeRateTable.get(allselectedLineItemMap.get(param_SourceItemId).pol.ASI_MFM_PO__r.ASI_MFM_Currency__c);
                }
                temp= new interimData(new ASI_MFM_Payment_Line_Item__c(ASI_MFM_Payment__c=Header.id,
                                                                       ASI_MFM_PO_Line_Item__c=allselectedLineItemMap.get(param_SourceItemId).pol.id,
                                                                       ASI_MFM_Payee__c=Header.ASI_MFM_Supplier_Name__c,
                                                                       ASI_MFM_PO__c=allselectedLineItemMap.get(param_SourceItemId).pol.ASI_MFM_PO__c,
                                                                       ASI_MFM_Payment_Amount__c=(fx*allselectedLineItemMap.get(param_SourceItemId).PoLRemain).setScale(2, roundingMode.half_up),
                                                                       ASI_MFM_Beneficiary_Customer__c=allselectedLineItemMap.get(param_SourceItemId).pol.ASI_MFM_AccountsAdditionalField__c,
                                                                       ASI_MFM_AP_Remark__c = Header.ASI_MFM_AP_Remark__c,
                                                                       ASI_MFM_KR_subLedger__c=allselectedLineItemMap.get(param_SourceItemId).pol.ASI_MFM_KR_subLedger__c,
                                                                       ASI_MFM_Tax_Code__c = allselectedLineItemMap.get(param_SourceItemId).pol.ASI_MFM_Tax_Code__c,
                                                                       ASI_MFM_Invoice_Date__c=Header.ASI_MFM_Invoice_Date__c,
                                                                       recordTypeId=rt_map.get('ASI_MFM_KR_Payment_Line_Item')),
                                      allselectedLineItemMap.get(param_SourceItemId).pol.ASI_MFM_Amount__c,
                                      (allselectedLineItemMap.get(param_SourceItemId).pol.ASI_MFM_Remaining_Balance__c).setScale(2, roundingMode.half_up),
                                      allselectedLineItemMap.get(param_SourceItemId).pol.ASI_MFM_PO__r.ASI_MFM_Currency__c,
                                      allselectedLineItemMap.get(param_SourceItemId).pol.ASI_MFM_List_Item_Description__c,
                                      allselectedLineItemMap.get(param_SourceItemId).pol.ASI_MFM_AP_Code__r.ASI_MFM_AP_Type__c,exchangeRateTable);
                
                ASI_MFM_Plan__c pl=new ASI_MFM_Plan__c(id=allselectedLineItemMap.get(param_SourceItemId).pol.ASI_MFM_PO__r.ASI_MFM_Plan__c,name=allselectedLineItemMap.get(param_SourceItemId).pol.ASI_MFM_PO__r.ASI_MFM_Plan__r.name);
                temp.Plan=pl;
                
                ASI_MFM_PO_Line_Item__c pol=new ASI_MFM_PO_Line_Item__c(id=allselectedLineItemMap.get(param_SourceItemId).pol.id,ASI_MFM_Purchase_Request_Line__c=allselectedLineItemMap.get(param_SourceItemId).pol.ASI_MFM_Purchase_Request_Line__c);
                temp.poline=pol;
                
                ASI_MFM_Sub_brand__c sb=new ASI_MFM_Sub_brand__c(id=allselectedLineItemMap.get(param_SourceItemId).pol.ASI_MFM_Sub_brand_Code__c,Name=allselectedLineItemMap.get(param_SourceItemId).pol.ASI_MFM_Sub_brand_Code__r.Name);
                temp.SBCode=sb;
                
                ASI_TnE_Branch_Channel__c bc=new ASI_TnE_Branch_Channel__c(id=allselectedLineItemMap.get(param_SourceItemId).pol.ASI_MFM_KR_subLedger__c,Name=allselectedLineItemMap.get(param_SourceItemId).pol.ASI_MFM_KR_subLedger__r.Name);
                temp.subLedger=bc;
                
                ASI_MFM_A_C_Code__c ac=new ASI_MFM_A_C_Code__c(id=allselectedLineItemMap.get(param_SourceItemId).pol.ASI_MFM_A_C_Code__c,name=allselectedLineItemMap.get(param_SourceItemId).pol.ASI_MFM_A_C_Code__r.name);
                temp.ACCode=ac;
                
                ASI_MFM_AP_Code__c ap=new ASI_MFM_AP_Code__c(id=allselectedLineItemMap.get(param_SourceItemId).pol.ASI_MFM_AP_Code__c,name=allselectedLineItemMap.get(param_SourceItemId).pol.ASI_MFM_AP_Code__r.name,ASI_MFM_Attachments_for_Payment_Request__c=allselectedLineItemMap.get(param_SourceItemId).pol.ASI_MFM_AP_Code__r.ASI_MFM_Attachments_for_Payment_Request__c,ASI_MFM_Beneficiary_WS_Venue__c=allselectedLineItemMap.get(param_SourceItemId).pol.ASI_MFM_AP_Code__r.ASI_MFM_Beneficiary_WS_Venue__c);
                temp.APCode=ap;
                if(allselectedLineItemMap.get(param_SourceItemId).pol.ASI_MFM_Plan_Line_Item__c!=null){
                    temp.payl.ASI_MFM_Plan_Line_Item__c=allselectedLineItemMap.get(param_SourceItemId).pol.ASI_MFM_Plan_Line_Item__c;
                }
                temp.CustomerId=allselectedLineItemMap.get(param_SourceItemId).pol.ASI_MFM_AccountsAdditionalField__c;
                temp.Customer=allselectedLineItemMap.get(param_SourceItemId).pol.ASI_MFM_AccountsAdditionalField__r.name;
                temp.VenueWhere=allselectedLineItemMap.get(param_SourceItemId).pol.ASI_MFM_Plan_Line_Item__r.ASI_MFM_Venue_Where__r.name;
                temp.VenueWhereId=allselectedLineItemMap.get(param_SourceItemId).pol.ASI_MFM_Plan_Line_Item__r.ASI_MFM_Venue_Where__c;
                allPaymentLineItemMap.put(LINE_ITEM_NEWRECORD_PREFIX+newIDCounter,temp);
            }else{
                if(allselectedLineItemMap.get(param_SourceItemId).por.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Currency__c!=Header.ASI_MFM_Currency__c && exchangeRateTable.containsKey(allselectedLineItemMap.get(param_SourceItemId).por.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Currency__c)){
                    fx=exchangeRateTable.get(allselectedLineItemMap.get(param_SourceItemId).por.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Currency__c);
                }
                temp= new interimData(new ASI_MFM_Payment_Line_Item__c(ASI_MFM_Payment__c=Header.id,
                                                                       ASI_MFM_PO_Line_Item__c=allselectedLineItemMap.get(param_SourceItemId).por.ASI_MFM_PO_Line_Item__c,
                                                                       ASI_MFM_Payee__c=Header.ASI_MFM_Supplier_Name__c,
                                                                       ASI_MFM_PO__c=allselectedLineItemMap.get(param_SourceItemId).por.ASI_MFM_PO__c,
                                                                       ASI_MFM_Payment_Amount__c=(fx*allselectedLineItemMap.get(param_SourceItemId).PoRRemain).setScale(2, roundingMode.half_up),
                                                                       ASI_MFM_AP_Remark__c = Header.ASI_MFM_AP_Remark__c,
                                                                       ASI_MFM_Tax_Code__c = allselectedLineItemMap.get(param_SourceItemId).por.ASI_MFM_PO_Line_Item__r.ASI_MFM_Tax_Code__c,
                                                                       ASI_MFM_Invoice_Number__c=Header.ASI_MFM_Invoice_Number__c,
                                                                       ASI_MFM_KR_subLedger__c=allselectedLineItemMap.get(param_SourceItemId).por.ASI_MFM_PO_Line_Item__r.ASI_MFM_KR_subLedger__c,
                                                                       ASI_MFM_Beneficiary_Customer__c=allselectedLineItemMap.get(param_SourceItemId).por.ASI_MFM_AccountsAdditionalField__c,
                                                                       ASI_MFM_Where_Customer__c=allselectedLineItemMap.get(param_SourceItemId).por.ASI_MFM_Venue_Where__c,
                                                                       ASI_MFM_Invoice_Date__c=Header.ASI_MFM_Invoice_Date__c,
                                                                       ASI_MFM_PO_Receipt_Item__c=allselectedLineItemMap.get(param_SourceItemId).por.id,
                                                                       recordTypeId=rt_map.get('ASI_MFM_KR_Payment_Line_Item')),
                                      allselectedLineItemMap.get(param_SourceItemId).por.ASI_MFM_Amount__c,
                                      (allselectedLineItemMap.get(param_SourceItemId).por.ASI_MFM_PO_Line_Item__r.ASI_MFM_Remaining_Balance__c).setScale(2, roundingMode.half_up),
                                      allselectedLineItemMap.get(param_SourceItemId).por.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Currency__c,
                                      allselectedLineItemMap.get(param_SourceItemId).por.ASI_MFM_PO_Line_Item__r.ASI_MFM_List_Item_Description__c,
                                      allselectedLineItemMap.get(param_SourceItemId).por.ASI_MFM_PO_Line_Item__r.ASI_MFM_AP_Code__r.ASI_MFM_AP_Type__c ,exchangeRateTable
                                     );
                
                ASI_MFM_Plan__c pl=new ASI_MFM_Plan__c(id=allselectedLineItemMap.get(param_SourceItemId).por.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Plan__c,name=allselectedLineItemMap.get(param_SourceItemId).por.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Plan__r.name);
                temp.Plan=pl;
                
                ASI_MFM_PO_Line_Item__c pol=new ASI_MFM_PO_Line_Item__c(id=allselectedLineItemMap.get(param_SourceItemId).por.ASI_MFM_PO_Line_Item__c,ASI_MFM_Purchase_Request_Line__c=allselectedLineItemMap.get(param_SourceItemId).por.ASI_MFM_PO_Line_Item__r.ASI_MFM_Purchase_Request_Line__c);
                temp.poline=pol;
                
                ASI_MFM_Sub_brand__c sb=new ASI_MFM_Sub_brand__c(id=allselectedLineItemMap.get(param_SourceItemId).por.ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__c,Name=allselectedLineItemMap.get(param_SourceItemId).por.ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.Name);
                temp.SBCode=sb;
                
                ASI_TnE_Branch_Channel__c bc =new ASI_TnE_Branch_Channel__c(id=allselectedLineItemMap.get(param_SourceItemId).por.ASI_MFM_PO_Line_Item__r.ASI_MFM_KR_subLedger__c,Name=allselectedLineItemMap.get(param_SourceItemId).por.ASI_MFM_PO_Line_Item__r.ASI_MFM_KR_subLedger__r.Name);
                temp.subLedger=bc;
                
                ASI_MFM_A_C_Code__c ac=new ASI_MFM_A_C_Code__c(id=allselectedLineItemMap.get(param_SourceItemId).por.ASI_MFM_PO_Line_Item__r.ASI_MFM_A_C_Code__c,name=allselectedLineItemMap.get(param_SourceItemId).por.ASI_MFM_PO_Line_Item__r.ASI_MFM_A_C_Code__r.name);
                temp.ACCode=ac;
                
                ASI_MFM_AP_Code__c ap=new ASI_MFM_AP_Code__c(id=allselectedLineItemMap.get(param_SourceItemId).por.ASI_MFM_PO_Line_Item__r.ASI_MFM_AP_Code__c,name=allselectedLineItemMap.get(param_SourceItemId).por.ASI_MFM_PO_Line_Item__r.ASI_MFM_AP_Code__r.name);
                temp.APCode=ap;
                  if(allselectedLineItemMap.get(param_SourceItemId).por.ASI_MFM_Plan_Line_Item__c!=null){
                    temp.payl.ASI_MFM_Plan_Line_Item__c=allselectedLineItemMap.get(param_SourceItemId).por.ASI_MFM_Plan_Line_Item__c;
                }
                
                allPaymentLineItemMap.put(LINE_ITEM_NEWRECORD_PREFIX+newIDCounter,temp);
                
            }
            
            allselectedLineItemMap.remove(param_SourceItemId);
        }
        
    }
        
    public void addallLineItem(){
        SaveSuccess=false;
        UpsertPermission=true;
        for(String key : allselectedLineItemMap.keySet()){
            AddLineFunction(key);
        }
        
    }
    
    public void cloneLine(){
        SaveSuccess=false;
        UpsertPermission=true;
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String param_Id = params.get('PARAM_clone_ID');
         if(allPaymentLineItemMap.containsKey(param_Id) && !allPaymentLineItemMap.isEmpty() ){
            string newIDCounter = newCounterCreatorLine();
            interimData temp= new interimData();
             
             
               temp= new interimData(new ASI_MFM_Payment_Line_Item__c(ASI_MFM_Payment__c=Header.id,
                                                                       ASI_MFM_PO_Line_Item__c=allPaymentLineItemMap.get(param_Id).payl.ASI_MFM_PO_Line_Item__c,
                                                                       ASI_MFM_Payee__c=allPaymentLineItemMap.get(param_Id).payl.ASI_MFM_Payee__c,
                                                                       ASI_MFM_PO__c=allPaymentLineItemMap.get(param_Id).payl.ASI_MFM_PO__c,
                                                                       ASI_MFM_Payment_Amount__c=allPaymentLineItemMap.get(param_Id).payl.ASI_MFM_Payment_Amount__c,
                                                                       ASI_MFM_AP_Remark__c = allPaymentLineItemMap.get(param_Id).payl.ASI_MFM_AP_Remark__c,
                                                                       ASI_MFM_Tax_Code__c = allPaymentLineItemMap.get(param_Id).payl.ASI_MFM_Tax_Code__c,
                                                                       ASI_MFM_Invoice_Number__c=allPaymentLineItemMap.get(param_Id).payl.ASI_MFM_Invoice_Number__c,
                                                                       ASI_MFM_KR_subLedger__c=allPaymentLineItemMap.get(param_Id).payl.ASI_MFM_KR_subLedger__c,
                                                                       ASI_MFM_Beneficiary_Customer__c=allPaymentLineItemMap.get(param_Id).payl.ASI_MFM_Beneficiary_Customer__c,
                                                                       ASI_MFM_Where_Customer__c=allPaymentLineItemMap.get(param_Id).payl.ASI_MFM_Where_Customer__c,
                                                                       ASI_MFM_Invoice_Date__c=allPaymentLineItemMap.get(param_Id).payl.ASI_MFM_Invoice_Date__c,
                                                                       ASI_MFM_PO_Receipt_Item__c=allPaymentLineItemMap.get(param_Id).payl.ASI_MFM_PO_Receipt_Item__c,
                                                                       recordTypeId=rt_map.get('ASI_MFM_KR_Payment_Line_Item')),
                                      allPaymentLineItemMap.get(param_Id).OrignalPoRAmount,
                                      allPaymentLineItemMap.get(param_Id).PoLRemain,
                                      allPaymentLineItemMap.get(param_Id).POCurrency,
                                      allPaymentLineItemMap.get(param_Id).POLDescription,
                                      allPaymentLineItemMap.get(param_Id).APType,exchangeRateTable
                                     );
                
                ASI_MFM_Plan__c pl=new ASI_MFM_Plan__c(id=allPaymentLineItemMap.get(param_Id).Plan.Id,name=allPaymentLineItemMap.get(param_Id).Plan.name);
                temp.Plan=pl;
                
                ASI_MFM_PO_Line_Item__c pol=new ASI_MFM_PO_Line_Item__c(id=allPaymentLineItemMap.get(param_Id).poline.id,ASI_MFM_Purchase_Request_Line__c=allPaymentLineItemMap.get(param_Id).poline.ASI_MFM_Purchase_Request_Line__c);
                temp.poline=pol;
                
                ASI_MFM_Sub_brand__c sb=new ASI_MFM_Sub_brand__c(id=allPaymentLineItemMap.get(param_Id).SBCode.Id,Name=allPaymentLineItemMap.get(param_Id).SBCode.Name);
                temp.SBCode=sb;
                
                ASI_TnE_Branch_Channel__c bc =new ASI_TnE_Branch_Channel__c(id=allPaymentLineItemMap.get(param_Id).subLedger.id,Name=allPaymentLineItemMap.get(param_Id).subLedger.Name);
                temp.subLedger=bc;
                
                ASI_MFM_A_C_Code__c ac=new ASI_MFM_A_C_Code__c(id=allPaymentLineItemMap.get(param_Id).ACCode.Id,name=allPaymentLineItemMap.get(param_Id).ACCode.name);
                temp.ACCode=ac;
                
                ASI_MFM_AP_Code__c ap=new ASI_MFM_AP_Code__c(id=allPaymentLineItemMap.get(param_Id).APCode.ID,name=allPaymentLineItemMap.get(param_Id).APCode.name);
                temp.APCode=ap;
                
                      
                temp.CustomerId=allPaymentLineItemMap.get(param_Id).CustomerId;
                temp.Customer=allPaymentLineItemMap.get(param_Id).Customer;
                temp.VenueWhere=allPaymentLineItemMap.get(param_Id).VenueWhere;
                temp.VenueWhereId=allPaymentLineItemMap.get(param_Id).VenueWhereId;
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
            if(Module=='POL'){
                ASI_MFM_PO_Line_Item__c POline=[select id,name,ASI_MFM_Remaining_Balance__c,ASI_MFM_A_C_Code__r.name,ASI_MFM_Tax_Code__c,
                                                ASI_MFM_Sub_brand_Code__r.name,ASI_MFM_PO__r.ASI_MFM_Plan__r.name,
                                                ASI_MFM_List_Item_Description__c,
                                                ASI_MFM_PO__r.ASI_MFM_Currency__c,ASI_MFM_AP_Code__r.ASI_MFM_Beneficiary_WS_Venue__c,
                                                ASI_MFM_Sub_brand_Code__c,ASI_MFM_PO__r.ASI_MFM_Plan__c,ASI_MFM_PO__c,ASI_MFM_Plan_Line_Item__r.ASI_MFM_Venue_Where__r.name,
                                                ASI_MFM_A_C_Code__c,ASI_MFM_AP_Code__r.name,ASI_MFM_AccountsAdditionalField__r.name,
                                                ASI_MFM_Purchase_Request_Line__c,ASI_MFM_AP_Code__r.ASI_MFM_Attachments_for_Payment_Request__c,
                                                ASI_MFM_AP_Code__c,ASI_MFM_AP_Code__r.ASI_MFM_AP_Type__c,ASI_MFM_Sub_Brand_Name__c,ASI_MFM_Amount__c,
                                                ASI_MFM_Customer_Name__c,ASI_MFM_AccountsAdditionalField__c,ASI_MFM_Plan_Line_Item__c,
                                                ASI_MFM_KR_subLedger__c, ASI_MFM_KR_subLedger__r.Name
                                                from ASI_MFM_PO_Line_Item__c 
                                                where id=:allPaymentLineItemMap.get(param_Id).payl.ASI_MFM_PO_Line_Item__c];
                if(POline!=null){ 
                    String polid=(String)(POline.id);
                    if(!allselectedLineItemMap.containsKey(polid)){
                        selectedData temp= new selectedData();
                        temp.pol=POline;
                        temp.PoLRemain=POline.ASI_MFM_Remaining_Balance__c+allPaymentLineItemMap.get(param_Id).OrignalPaidAmount;
                        allselectedLineItemMap.put(polid,temp);
                    }
                }// end If
            }else{
                ASI_MFM_PO_Receipt_Item__c PORline=[select id,name,ASI_MFM_Remaining_Balance__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_Remaining_Balance__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_A_C_Code__r.name,
                                                    ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.name,ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Plan__r.name,ASI_MFM_PO_Line_Item__r.ASI_MFM_Tax_Code__c,
                                                    ASI_MFM_PO_Line_Item__r.ASI_MFM_List_Item_Description__c,ASI_MFM_Plan_Line_Item__c,
                                                    ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Currency__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_AP_Code__r.ASI_MFM_Attachments_for_Payment_Request__c,
                                                    ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Plan__c,ASI_MFM_PO__c,ASI_MFM_Remark__c,
                                                    ASI_MFM_PO_Line_Item__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_A_C_Code__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_AP_Code__r.name,ASI_MFM_Venue_Where__c,ASI_MFM_AccountsAdditionalField__c,
                                                    ASI_MFM_PO_Line_Item__r.ASI_MFM_Purchase_Request_Line__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_AP_Code__r.ASI_MFM_Beneficiary_WS_Venue__c,
                                                    ASI_MFM_PO_Line_Item__r.ASI_MFM_AP_Code__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_Brand_Name__c,ASI_MFM_Amount__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_AP_Code__r.ASI_MFM_AP_Type__c ,
                                                    ASI_MFM_PO_Line_Item__r.ASI_MFM_Customer_Name__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_AccountsAdditionalField__c,ASI_MFM_AP_Code__r.ASI_MFM_AP_Type__c,
                                                    ASI_MFM_PO_Line_Item__r.ASI_MFM_KR_subLedger__c, ASI_MFM_PO_Line_Item__r.ASI_MFM_KR_subLedger__r.Name // ----- 2015-12-22
                                                    from ASI_MFM_PO_Receipt_Item__c 
                                                    where id=:allPaymentLineItemMap.get(param_Id).payl.ASI_MFM_PO_Receipt_Item__c];
                if(PORline!=null){ 
                    String porlid=(String)(PORline.id);
                    if(!allselectedLineItemMap.containsKey(porlid)){
                        selectedData temp= new selectedData();
                        temp.por=PORline;
                        temp.PoRRemain=PORline.ASI_MFM_Remaining_Balance__c+allPaymentLineItemMap.get(param_Id).OrignalPaidAmount;
                        allselectedLineItemMap.put(porlid,temp);
                    }
                }// end If
            }
            
            
            
            ASI_MFM_Payment_Line_Item__c delTarget=allPaymentLineItemMap.get(param_Id).payl;
            if(delTarget.id != null){
                deleteLineItemList.add(delTarget);
            }
            allPaymentLineItemMap.remove(param_Id);
        }
    }
    
    
    //-----------------------------------------Save------------------------------------- 
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
                
                if(Header.ASI_MFM_Pre_payment__c){
                    
                    allPaymentLineItemMap.get(key).payl.ASI_MFM_Invoice_Number__c=Header.ASI_MFM_Invoice_Number__c+'_'+string.valueOf(nextNumber);
                    nextNumber++;
                }
                
                if(Module=='POR'){
                    PORID.add(allPaymentLineItemMap.get(key).payl.ASI_MFM_PO_Receipt_Item__c);
                }
                
                if(Module=='POR' && !POReceiptItemId.contains(allPaymentLineItemMap.get(key).payl.ASI_MFM_PO_Receipt_Item__c)){
                    POReceiptItemId.add(allPaymentLineItemMap.get(key).payl.ASI_MFM_PO_Receipt_Item__c);
                }
                //Upsert  Pre Payment checkbox
                if(Header.ASI_MFM_Pre_payment__c) allPaymentLineItemMap.get(key).payl.ASI_MFM_CN_Pre_Payment__c=true;
                 //Upsert  Tax Explanation Code
                if(TaxCodeMap.containsKey(allPaymentLineItemMap.get(key).payl.ASI_MFM_Tax_Code__c)) allPaymentLineItemMap.get(key).payl.ASI_MFM_Tax_Explanation_Code__c=TaxCodeMap.get(allPaymentLineItemMap.get(key).payl.ASI_MFM_Tax_Code__c).ASI_MFM_Tax_Expl_Code__c;
                
                //Add a new field "Business Unit"(Picklist) in detail line. Values: P830 (222), J520(286), J530(286)
                //Based on choosen company in header, default value: Company = 222 : P830   *****     Company = 286:  J520
                allPaymentLineItemMap.get(key).payl.ASI_MFM_Company__c=Header.ASI_MFM_Company__c;
                if(Header.ASI_MFM_Company_Code__c=='222'){
                    allPaymentLineItemMap.get(key).payl.ASI_MFM_Business_Unit__c='P830';
                }else{
                    allPaymentLineItemMap.get(key).payl.ASI_MFM_Business_Unit__c='J520';
                }
                
                if(allPaymentLineItemMap.get(key).APCode.ASI_MFM_Attachments_for_Payment_Request__c!=null){
                    Header.ASI_MFM_Need_Attachment__c=true;
                    NeedUpdateHeader=True;
                }
                 upsertTargetList.add(allPaymentLineItemMap.get(key).payl); 
                if(Header.ASI_MFM_Is_Direct_Payment__c){
                    ASI_MFM_PO_Line_Item__c poline = new ASI_MFM_PO_Line_Item__c(id=allPaymentLineItemMap.get(key).payl.ASI_MFM_PO_Line_Item__c,ASI_MFM_Amount__c=allPaymentLineItemMap.get(key).payl.ASI_MFM_Payment_Amount__c);
                    upsertPOLineList.add(poline);
                }
            }
            
            for(ASI_MFM_Payment_Line_Item__c pl:deleteLineItemList){
                if(!POReceiptItemId.contains(pl.ASI_MFM_PO_Receipt_Item__c)){
                    POReceiptItemId.add(pl.ASI_MFM_PO_Receipt_Item__c);
                }   
            }
            
        }
        
      
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
                    upsertTarget = Database.upsert(upsertTargetList);
                    SaveSuccess=true;
                }
                
                //Update PO Line
                if(Header.ASI_MFM_Is_Direct_Payment__c){
                    if(upsertPOLineList.size()>0){
                        update upsertPOLineList;
                    }
                }                
                
                //Checking after upserting data to database
                if(Module=='POR' && PORID.size()>0){
                    List<ASI_MFM_PO_Receipt_Item__c> PORCheckList=[select Id,Name,ASI_MFM_Remaining_Balance__c from ASI_MFM_PO_Receipt_Item__c where id in : PORID]; 
                    boolean PassFlag=true;
                    String AddMsg='';
                    for(ASI_MFM_PO_Receipt_Item__c porl:PORCheckList){
                        if(porl.ASI_MFM_Remaining_Balance__c<0){
                            AddMsg +='<br/>PO Receipt Line '+porl.Name+' Balance: '+porl.ASI_MFM_Remaining_Balance__c+'< 0.';
                            PassFlag=false;
                        }
                    }//End of for loop
                    
                    if(!PassFlag){
                        UpsertPermission = false;
                        SaveSuccess=FALSE;
                        Msg +='Please be noted that following PO Receipt Line Balance < 0:'+AddMsg;
                        database.rollback(sp);
                    }
                }// end of PO Receipt level checking
            }else{
                SaveSuccess=false;
                deleteLineItemList.clear();
            }
            
        }catch(Exception e){
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
            
            //Check Null
            if(allLineItemMap.get(key).payl.ASI_MFM_Payment_Amount__c==null){
                isProcess=false;
                Msg +='Line ' + idx +': Please Input Payment Amount<br/>.';
            } 
            
            if(Module=='POL'){
                //check customer
                if(!String.isEmpty(allLineItemMap.get(key).CustomerId)){
                    try
                    {
                        /*Need to map back the ID to Customer*/
                        Id CusId = Id.valueOf(allLineItemMap.get(key).CustomerId);
                        allLineItemMap.get(key).payl.ASI_MFM_Beneficiary_Customer__c = CusId;
                    }//end try
                    catch(exception e)
                    {
                        msg += 'Line ' + idx + ' : Please select Customer' + '</br>';
                        isProcess = false;  
                    }//end catch
                }
                
                if(String.isEmpty(allLineItemMap.get(key).Customer)){
                    allLineItemMap.get(key).payl.ASI_MFM_Beneficiary_Customer__c = null;
                }
                
                //check customer
                if(!String.isEmpty(allLineItemMap.get(key).VenueWhereId)){
                    try
                    {
                        /*Need to map back the ID to Customer*/
                        Id CusId = Id.valueOf(allLineItemMap.get(key).VenueWhereId);
                        allLineItemMap.get(key).payl.ASI_MFM_Where_Customer__c = CusId;
                    }//end try
                    catch(exception e)
                    {
                        msg += 'Line ' + idx + ' : Please select Venue Where' + '</br>';
                        isProcess = false;  
                    }//end catch
                }
                if(String.isEmpty(allLineItemMap.get(key).VenueWhere)){
                    allLineItemMap.get(key).payl.ASI_MFM_Where_Customer__c = null;
                }
                //end if
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
        public Decimal OrignalPaidAmount {get; set;} // Paid Amount Saved in DataBase
        
        public Decimal OrignalPoRAmount {get; set;}
        public Decimal PoRAmount {get; set;}
        public Decimal PoLRemain {get; set;}
        public Decimal exchangerate {get; set;}{exchangerate=1;}// exchangeRateTable
        
        public String Customer {set;get;}   
        public String CustomerId {set;get;}
        public String VenueWhere {set;get;}
        public String VenueWhereId {set;get;}
        
        public string POCurrency {get; set;}
        public string POLDescription {get; set;}
        public string APType {get; set;}
        public ASI_MFM_A_C_Code__c ACCode{get; set;}
        public ASI_MFM_Sub_brand__c SBCode {get; set;}
        public ASI_MFM_Plan__c Plan {get; set;}
        public ASI_MFM_PO_Line_Item__c poline {get; set;}
        public ASI_MFM_AP_Code__c APCode {get; set;}
       
        public ASI_TnE_Branch_Channel__c subLedger {get; set;} // ----- 2015-12-22
        
        //define Constructor 
        public interimData(){}
        public interimData(ASI_MFM_Payment_Line_Item__c payl,Decimal OrignalPoRAmount,Decimal PoLRemain,string POCurrency,string POLDescription, string APType,Map<String, Decimal> exchangeRateTable){
            this.payl=payl;
            this.OrignalPoRAmount=OrignalPoRAmount;
            this.PoLRemain=PoLRemain;
            this.POCurrency=POCurrency;
            this.POLDescription=POLDescription;
            this.OrignalPaidAmount=0;
            this.APType=APType;
            if(POCurrency!='KRW'){
                this.exchangerate=exchangeRateTable.get(POCurrency);
            }else{
                this.exchangerate=1;
            }
        }
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