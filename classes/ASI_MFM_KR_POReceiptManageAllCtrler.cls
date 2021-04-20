public with sharing class ASI_MFM_KR_POReceiptManageAllCtrler {

    public ApexPages.StandardController standardController {get;set;}
    
    public ASI_MFM_PO_Receipt__c Header {get;set;}
    public static String LINE_ITEM_NEWRECORD_PREFIX {get{ return 'z';}}
    public Integer LINE_ITEM_NEWRECORD_COUNTER {get;set;}
        
    public Map<String, interimPOL> allPOLineMap {get;set;}{ allPOLineMap = new Map<String, interimPOL>();}
    public Map<String, interimData> allPORItemMap {get;set;}{ allPORItemMap = new Map<String, interimData>();}
    
    public List<ASI_MFM_PO_Receipt_Item__c> deleteLineItemList {get;set;}{deleteLineItemList = new List<ASI_MFM_PO_Receipt_Item__c>();}
   
    public boolean SaveSuccess {get;set;}
    public boolean DisplayPOL {get;set;}{DisplayPOL=true;}
    public boolean UpsertPermission {get;set;}{UpsertPermission=true;}
    //Search: Attributes used for filtering POLs
    public String subBrandNameFilter {get;set;}
    public String Msg {get;set;}
    public String SQLstatement {get;set;} {SQLstatement='';}
    
    //Attributes used for remove payment line 
    public String removePaymentLine {get;set;}        
    
    //public String APType {get;set;}
    
    public Class interimData{
        public ASI_MFM_PO_Receipt_Item__c por {get; set;}
        Public Boolean ReadOnly  {get; set;}{ReadOnly=FALSE;}
        public String SB_Code {get; set;}
        public String SB_CodeID {get; set;}
        public String subLedger {get; set;} // ----- 2015-12-22
        public String subLedgerId {get; set;} // ----- 2015-12-22
        public String Description {get; set;}
        
        public String APCode {get;set;}       // Added by 2018-09-14 Linus@introv
        public String APCodeId {get;set;}     // Added by 2018-09-14 Linus@introv
        public Boolean BeneficiaryWSVenue {get;set;}{BeneficiaryWSVenue=false;} // Added by 2018-09-14 Linus@introv
        public String Customer {set;get;}   
        public String CustomerId {set;get;}
        public String VenueWhere {set;get;}
        public String VenueWhereId {set;get;}
        
        //public ASI_MFM_AP_Code__c APCode {get; set;}
        public Decimal PoAmount {get; set;}
        public Decimal PoRemaining {get; set;}
        public Decimal UnitCost {get; set;}
    }
    
    public Class interimPOL{
        public ASI_MFM_PO_Line_Item__c pol {get; set;}
        public Decimal RemainAmt {get; set;}
    }
    
    
    // Define the constructor
    public ASI_MFM_KR_POReceiptManageAllCtrler(ApexPages.StandardController standardController){
        this.standardController = standardController;
        this.Header = (ASI_MFM_PO_Receipt__c) this.standardController.getRecord();
        if(this.Header !=null && this.Header.Id !=null){
            for(ASI_MFM_PO_Receipt__c por : [Select id,Name,ASI_MFM_ETL__c,ASI_MFM_Supplier__c,ASI_MFM_PO__r.ASI_MFM_PO_Balance__c,ASI_MFM_PO__r.ASI_MFM_Project_Code__c,ASI_MFM_PO__r.ASI_MFM_Base_Currency_Amount__c,ASI_MFM_PO__r.ASI_MFM_PO_Amount__c,ASI_MFM_PO__r.ASI_MFM_Status__c,ASI_MFM_PO__r.ASI_MFM_PO_Fiscal_Year__c,ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c,ASI_MFM_Receipt_Date__c,CreatedDate,ASI_MFM_PO__r.ASI_MFM_PO_End_Date__c,ASI_MFM_Status__c,ASI_MFM_PO__r.ASI_MFM_PO_Start_Date__c,ASI_MFM_PO__r.name,ASI_MFM_PO__r.ASI_MFM_Supplier_Name__r.name,ASI_MFM_PO__r.ASI_MFM_Supplier_Name__c,ASI_MFM_Remarks__c,ASI_MFM_PO__c,ASI_MFM_PO__r.ASI_MFM_Currency__c , ASI_MFM_PO__r.ASI_MFM_KR_AP_Type__c FROM ASI_MFM_PO_Receipt__c where Id =: this.Header.Id limit 1]){
                this.Header = por;
                //APType = por.ASI_MFM_PO__r.ASI_MFM_KR_AP_Type__c;
            }
        }
    }
    
     // Initialize
    public void init() {
        SaveSuccess=false;
        
       
        
        if(this.Header !=null && this.Header.Id !=null){
            SQLstatement=ASI_MFM_ByPass_Setting.ReturnSqlStatement('ASI_MFM_KR_findCustomers','Initialization','KR');
            //get PO Receipt Items Lines  
            List<ASI_MFM_PO_Receipt_Item__c> PORlineItemList =[select id,name,ASI_MFM_ACC_Verify__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_Product_Item__r.name,ASI_MFM_PO_Line_Item__r.ASI_MFM_Product_Item__c,ASI_MFM_KR_subLedger__c,ASI_MFM_PO__c,
                                                               ASI_MFM_PO_Line_Item__r.ASI_MFM_AccountsAdditionalField__r.name,ASI_MFM_PO_Line_Item__r.ASI_MFM_AccountsAdditionalField__c, ASI_MFM_Venue_Where__c,ASI_MFM_AccountsAdditionalField__c,
                                                               ASI_MFM_PO_Line_Item__r.ASI_MFM_Amount__c,ASI_MFM_Marketing_Verify__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_CN_Remaining_Receipt_Balance__c,
                                                               ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_Customer_Name__r.name,ASI_MFM_ETL__c,ASI_MFM_AccountsAdditionalField__r.name,
                                                               ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.name,ASI_MFM_PO_Line_Item__r.ASI_MFM_AP_Code__r.name,ASI_MFM_Venue_Where__r.name,
                                                               ASI_MFM_PO_Line_Item__r.ASI_MFM_A_C_Code__r.name,ASI_MFM_PO_Line_Item__r.ASI_MFM_Customer_Name__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_PO_Remark__c,
                                                               ASI_MFM_UOM__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_AP_Code__r.ASI_MFM_Beneficiary_WS_Venue__c,
                                                               ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_Brand_Name__c,ASI_MFM_PO_Line_Item__c,ASI_MFM_Amount__c,ASI_MFM_Receipt_Date__c,
                                                               ASI_MFM_Remark__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_AP_Code__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_A_C_Code__c,
                                                               ASI_MFM_PO_Line_Item__r.ASI_MFM_List_Item_Description__c ,ASI_MFM_Quantity__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_TH_Unit__c,
                                                               ASI_MFM_PO_Line_Item__r.ASI_MFM_KR_subLedger__c, ASI_MFM_PO_Line_Item__r.ASI_MFM_KR_subLedger__r.Name,(select id from Payment_Line_Items__r),
                                                               ASI_MFM_Consumer_Prize__c //20180121 Introv
                                                               from ASI_MFM_PO_Receipt_Item__c where ASI_MFM_PO_Receipt__c=:Header.id];
            
            set<ID> polineID_set = new set<ID>();
            if(!PORlineItemList.isEmpty()){
                boolean ALLverified=true;
                for(ASI_MFM_PO_Receipt_Item__c Porline : PORlineItemList){
                    String polId = (String)(Porline.id);
                    if(!Porline.ASI_MFM_Marketing_Verify__c){
                        ALLverified=false;
                    }
                    
                    interimData temp= new interimData();
                    temp.por=Porline;
                    temp.SB_Code=Porline.ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.name;
                    temp.SB_CodeID=Porline.ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__c;
                    temp.subLedger=Porline.ASI_MFM_PO_Line_Item__r.ASI_MFM_KR_subLedger__r.Name; // ----- 2015-12-22
                    temp.subLedgerId=Porline.ASI_MFM_PO_Line_Item__r.ASI_MFM_KR_subLedger__c; // ----- 2015-12-22
                    
                    // Added by 2018-09-14 Linus@introv
                    temp.APCode=Porline.ASI_MFM_PO_Line_Item__r.ASI_MFM_AP_Code__r.name;
                    temp.APCodeId=Porline.ASI_MFM_PO_Line_Item__r.ASI_MFM_AP_Code__c;
                    temp.BeneficiaryWSVenue=Porline.ASI_MFM_PO_Line_Item__r.ASI_MFM_AP_Code__r.ASI_MFM_Beneficiary_WS_Venue__c;
                    //temp.APCode=new ASI_MFM_AP_Code__c(id=Porline.ASI_MFM_PO_Line_Item__r.ASI_MFM_AP_Code__c, name =Porline.ASI_MFM_PO_Line_Item__r.ASI_MFM_AP_Code__r.name,ASI_MFM_Beneficiary_WS_Venue__c=Porline.ASI_MFM_PO_Line_Item__r.ASI_MFM_AP_Code__r.ASI_MFM_Beneficiary_WS_Venue__c);
                    
                    temp.Description=Porline.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO_Remark__c; 
                    temp.Customer=Porline.ASI_MFM_AccountsAdditionalField__r.name;
                    temp.CustomerId=Porline.ASI_MFM_AccountsAdditionalField__c;
                    temp.VenueWhere=Porline.ASI_MFM_Venue_Where__r.name;
                    temp.VenueWhereId =Porline.ASI_MFM_Venue_Where__c;   

                    if(Porline.ASI_MFM_ETL__c || Porline.Payment_Line_Items__r.size()>0 || Porline.ASI_MFM_ACC_Verify__c){
                        temp.ReadOnly=true;
                    }
                    if(Porline.ASI_MFM_Amount__c!=null){
                        temp.PoRemaining=Porline.ASI_MFM_PO_Line_Item__r.ASI_MFM_CN_Remaining_Receipt_Balance__c+Porline.ASI_MFM_Amount__c;
                    }else{
                        temp.PoRemaining=Porline.ASI_MFM_PO_Line_Item__r.ASI_MFM_CN_Remaining_Receipt_Balance__c;
                    }
                    temp.UnitCost=Porline.ASI_MFM_PO_Line_Item__r.ASI_MFM_TH_Unit__c;
                    temp.PoAmount=Porline.ASI_MFM_PO_Line_Item__r.ASI_MFM_Amount__c;
                    allPORItemMap.put(polId, temp);
                    polineID_set.add(Porline.ASI_MFM_PO_Line_Item__c);
                    
                }
                if(ALLverified || Header.ASI_MFM_Status__c=='Completed'|| Header.ASI_MFM_PO__r.ASI_MFM_Status__c=='Complete'){
                    DisplayPOL=false;
                }
                
                
            }
            
            //get PO line 
            List<ASI_MFM_PO_Line_Item__c> POlineList = [select id,name,ASI_MFM_KR_Quantity__c,ASI_MFM_AccountsAdditionalField__r.name,ASI_MFM_AccountsAdditionalField__c, ASI_MFM_Sub_Brand_Name__c,ASI_MFM_Product_Item__c,ASI_MFM_AP_Code__r.ASI_MFM_Beneficiary_WS_Venue__c,
                                                        ASI_MFM_CN_Remaining_Receipt_Balance__c,ASI_MFM_Sub_brand_Code__c,ASI_MFM_A_C_Code__c,ASI_MFM_AP_Code__c,ASI_MFM_Customer_Name__c,ASI_MFM_Amount__c,ASI_MFM_Plan_Line_Item__r.ASI_MFM_Venue_Where__r.name,
                                                        ASI_MFM_List_Item_Description__c,ASI_MFM_PO__c,ASI_MFM_A_C_Code__r.name,ASI_MFM_AP_Code__r.name,ASI_MFM_Sub_brand_Code__r.name,ASI_MFM_Plan_Line_Item__r.ASI_MFM_Venue_Where__c,
                                                        ASI_MFM_Customer_Name__r.name,ASI_MFM_PO_Remark__c,ASI_MFM_G_L_Date__c,ASI_MFM_TH_Unit__c, ASI_MFM_UOM__c, ASI_MFM_KR_subLedger__c, ASI_MFM_KR_subLedger__r.Name, // ----- 2015-12-22
                                                        ASI_MFM_Consumer_Prize__c //20180121 Introv
                                                        from ASI_MFM_PO_Line_Item__c where ASI_MFM_PO__c=: Header.ASI_MFM_PO__c and id not in: polineID_set and ASI_MFM_CN_Remaining_Receipt_Balance__c >0 ];
            if(!POlineList.isEmpty()){   //allPOLineMap
                for(ASI_MFM_PO_Line_Item__c pol:POlineList){
                    String polid=(String)(pol.id);
                    if(!allPOLineMap.containsKey(polid)){
                         interimPOL temp= new interimPOL();
                        temp.pol=pol;
                        temp.RemainAmt=pol.ASI_MFM_CN_Remaining_Receipt_Balance__c;
                        allPOLineMap.put(polid,temp);
                    }
                }
            }
            
            
        }
       
    }
     
  
    
     // 1. Remove this Payment Line from the upper table 
    public void removeLine() {
        SaveSuccess=false;
        UpsertPermission=true;
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String param_Id = params.get('PARAM_PORLine_ID');
        if(allPORItemMap.containsKey(param_Id) && !allPORItemMap.isEmpty() ){
            
            ASI_MFM_PO_Line_Item__c POline = [select id,name,ASI_MFM_KR_Quantity__c,ASI_MFM_Sub_Brand_Name__c,ASI_MFM_PO_Remark__c,ASI_MFM_CN_Remaining_Receipt_Balance__c,ASI_MFM_Sub_brand_Code__c,ASI_MFM_Sub_brand_Code__r.name,ASI_MFM_G_L_Date__c,ASI_MFM_TH_Unit__c,
                                              ASI_MFM_Customer_Name__r.name,ASI_MFM_A_C_Code__c,ASI_MFM_A_C_Code__r.name,ASI_MFM_AP_Code__c,ASI_MFM_AP_Code__r.name,ASI_MFM_AP_Code__r.ASI_MFM_Beneficiary_WS_Venue__c,ASI_MFM_Customer_Name__c,ASI_MFM_Plan_Line_Item__r.ASI_MFM_Venue_Where__c,
                                              ASI_MFM_Amount__c,ASI_MFM_List_Item_Description__c,ASI_MFM_PO__c, ASI_MFM_AccountsAdditionalField__r.name,ASI_MFM_AccountsAdditionalField__c, ASI_MFM_UOM__c,ASI_MFM_Plan_Line_Item__r.ASI_MFM_Venue_Where__r.name,
                                              ASI_MFM_KR_subLedger__c, ASI_MFM_KR_subLedger__r.Name, // ----- 2015-12-22
                                              ASI_MFM_Consumer_Prize__c //20180121 Introv
                                              from ASI_MFM_PO_Line_Item__c where id=:allPORItemMap.get(param_Id).por.ASI_MFM_PO_Line_Item__c];
            if(POline!=null){
                String polid=(String)(POline.id);
                if(!allPOLineMap.containsKey(polid)){
                    interimPOL temp= new interimPOL();
                    temp.pol=POline;
                    temp.RemainAmt=allPORItemMap.get(param_Id).PoRemaining;
                    allPOLineMap.put(polid,temp);
                }
            }
            
            ASI_MFM_PO_Receipt_Item__c delTarget=allPORItemMap.get(param_Id).por;
            if(delTarget.id != null){
                deleteLineItemList.add(delTarget);
            }
            allPORItemMap.remove(param_Id);
            
            
        }
    }    
    
    // 1. Add PO Line, 
    // 2. convert into Payment line
    // 3. Remove this PO Line from bottom table 
    public void addLineItem(){
        SaveSuccess=false;
        UpsertPermission=true;

        Map<String, String> params = ApexPages.currentPage().getParameters();
        String param_SourceItemId = params.get('PARAM_POLINE_SOURCE_ITEM_ID');
       AddLineFunction(param_SourceItemId);
        
    }
    
    
    public void AddLineFunction(string param_SourceItemId){
         
        //String KeyId;
        if(allPOLineMap.containsKey(param_SourceItemId)){
            string newIDCounter = newCounterCreatorLine();
            interimData temp= new interimData();
            
            temp.por=new ASI_MFM_PO_Receipt_Item__c(ASI_MFM_PO_Receipt__c=Header.id,
                                                    recordtypeid = Global_RecordTypeCache.getRTId('ASI_MFM_PO_Receipt_Item__cASI_MFM_KR_PO_Receipt_item'),
                                                    ASI_MFM_PO_Line_Item__c=allPOLineMap.get(param_SourceItemId).pol.id,
                                                    ASI_MFM_PO__c=allPOLineMap.get(param_SourceItemId).pol.ASI_MFM_PO__c,
                                                    ASI_MFM_Amount__c=allPOLineMap.get(param_SourceItemId).RemainAmt,
                                                    ASI_MFM_KR_subLedger__c=allPOLineMap.get(param_SourceItemId).pol.ASI_MFM_KR_subLedger__c,
                                                    //ASI_MFM_AccountsAdditionalField__c=allPOLineMap.get(param_SourceItemId).pol.ASI_MFM_AccountsAdditionalField__c,
                                                    //ASI_MFM_Venue_Where__c=allPOLineMap.get(param_SourceItemId).pol.ASI_MFM_Plan_Line_Item__r.ASI_MFM_Venue_Where__c,
                                                    ASI_MFM_Remark__c =  allPOLineMap.get(param_SourceItemId).pol.ASI_MFM_PO_Remark__c,
                                                    ASI_MFM_Receipt_Date__c=Date.today(),
                                                    ASI_MFM_UOM__c = allPOLineMap.get(param_SourceItemId).pol.ASI_MFM_UOM__c,
                                                    ASI_MFM_Consumer_Prize__c = allPOLineMap.get(param_SourceItemId).pol.ASI_MFM_Consumer_Prize__c //20180121 Introv
                                                   );
            
            temp.SB_Code=allPOLineMap.get(param_SourceItemId).pol.ASI_MFM_Sub_brand_Code__r.name;
            temp.SB_CodeID=allPOLineMap.get(param_SourceItemId).pol.ASI_MFM_Sub_brand_Code__c;
            temp.subLedger=allPOLineMap.get(param_SourceItemId).pol.ASI_MFM_KR_subLedger__r.Name; 
            temp.subLedgerId=allPOLineMap.get(param_SourceItemId).pol.ASI_MFM_KR_subLedger__c;
            temp.Description=allPOLineMap.get(param_SourceItemId).pol.ASI_MFM_PO_Remark__c; 
            
            // Added by 2018-09-14 Linus@introv
            temp.APCode=allPOLineMap.get(param_SourceItemId).pol.ASI_MFM_AP_Code__r.name;
            temp.APCodeId=allPOLineMap.get(param_SourceItemId).pol.ASI_MFM_AP_Code__c;
            temp.BeneficiaryWSVenue=allPOLineMap.get(param_SourceItemId).pol.ASI_MFM_AP_Code__r.ASI_MFM_Beneficiary_WS_Venue__c;
            //temp.APCode=new ASI_MFM_AP_Code__c(id=allPOLineMap.get(param_SourceItemId).pol.ASI_MFM_AP_Code__c, name =allPOLineMap.get(param_SourceItemId).pol.ASI_MFM_AP_Code__r.name,ASI_MFM_Beneficiary_WS_Venue__c=allPOLineMap.get(param_SourceItemId).pol.ASI_MFM_AP_Code__r.ASI_MFM_Beneficiary_WS_Venue__c);
            
            temp.Customer=allPOLineMap.get(param_SourceItemId).pol.ASI_MFM_AccountsAdditionalField__r.name;
            temp.CustomerId=allPOLineMap.get(param_SourceItemId).pol.ASI_MFM_AccountsAdditionalField__c;
            temp.VenueWhere=allPOLineMap.get(param_SourceItemId).pol.ASI_MFM_Plan_Line_Item__r.ASI_MFM_Venue_Where__r.name;
            temp.VenueWhereId =allPOLineMap.get(param_SourceItemId).pol.ASI_MFM_Plan_Line_Item__r.ASI_MFM_Venue_Where__c;   
            temp.UnitCost=allPOLineMap.get(param_SourceItemId).pol.ASI_MFM_TH_Unit__c;
            temp.PoRemaining=allPOLineMap.get(param_SourceItemId).RemainAmt;//allPOLineMap.get(param_SourceItemId).pol.ASI_MFM_CN_Remaining_Receipt_Balance__c;
            if(temp.PoRemaining!=null && temp.UnitCost!=null){
                temp.por.ASI_MFM_Quantity__c=(temp.PoRemaining/temp.UnitCost).setScale(2, roundingMode.half_up);
            }
            temp.PoAmount=allPOLineMap.get(param_SourceItemId).pol.ASI_MFM_Amount__c;
            
            
            allPORItemMap.put(LINE_ITEM_NEWRECORD_PREFIX+newIDCounter, temp);
            allPOLineMap.remove(param_SourceItemId);
        }
    }
    
    
    
    public void addallLineItem(){
        SaveSuccess=false;
        UpsertPermission=true;
        for(String key : allPOLineMap.keySet()){
            AddLineFunction(key);
        }
    }
      
    public void cloneLine(){
        SaveSuccess=false;
        UpsertPermission=true;
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String param_Id = params.get('PARAM_clone_ID');
        if(allPORItemMap.containsKey(param_Id) && !allPORItemMap.isEmpty() ){
            string newIDCounter = newCounterCreatorLine();
            interimData temp= new interimData();
            temp.por=new ASI_MFM_PO_Receipt_Item__c(ASI_MFM_PO_Receipt__c=Header.id,
                                                    recordtypeid = Global_RecordTypeCache.getRTId('ASI_MFM_PO_Receipt_Item__cASI_MFM_KR_PO_Receipt_item'),
                                                    ASI_MFM_PO_Line_Item__c=allPORItemMap.get(param_Id).por.ASI_MFM_PO_Line_Item__c,
                                                    ASI_MFM_PO__c=allPORItemMap.get(param_Id).por.ASI_MFM_PO__c,
                                                    ASI_MFM_Amount__c=allPORItemMap.get(param_Id).por.ASI_MFM_Amount__c,
                                                    ASI_MFM_Quantity__c=allPORItemMap.get(param_Id).por.ASI_MFM_Quantity__c,
                                                    ASI_MFM_KR_subLedger__c=allPORItemMap.get(param_Id).por.ASI_MFM_KR_subLedger__c,
                                                    ASI_MFM_Remark__c =  allPORItemMap.get(param_Id).por.ASI_MFM_Remark__c,
                                                    ASI_MFM_Receipt_Date__c=allPORItemMap.get(param_Id).por.ASI_MFM_Receipt_Date__c,
                                                    ASI_MFM_UOM__c = allPORItemMap.get(param_Id).por.ASI_MFM_UOM__c,
                                                    ASI_MFM_Consumer_Prize__c = allPORItemMap.get(param_Id).por.ASI_MFM_Consumer_Prize__c);
            
            
            temp.SB_Code=allPORItemMap.get(param_Id).SB_Code;
            temp.SB_CodeID=allPORItemMap.get(param_Id).SB_CodeID;
            temp.subLedger=allPORItemMap.get(param_Id).subLedger; 
            temp.subLedgerId=allPORItemMap.get(param_Id).subLedgerId;
            temp.Description=allPORItemMap.get(param_Id).Description; 
            
            // Added by 2018-09-14 Linus@introv            
            temp.APCode=allPORItemMap.get(param_Id).APCode;
            temp.APCodeId=allPORItemMap.get(param_Id).APCodeId;
            temp.BeneficiaryWSVenue=allPORItemMap.get(param_Id).BeneficiaryWSVenue;            
            //temp.APCode=new ASI_MFM_AP_Code__c(id=allPORItemMap.get(param_Id).APCode.Id, name =allPORItemMap.get(param_Id).APCode.name,ASI_MFM_Beneficiary_WS_Venue__c=allPORItemMap.get(param_Id).APCode.ASI_MFM_Beneficiary_WS_Venue__c);
           
            temp.Customer=allPORItemMap.get(param_Id).Customer;
            temp.CustomerId=allPORItemMap.get(param_Id).CustomerId;
            temp.VenueWhere=allPORItemMap.get(param_Id).VenueWhere;
            temp.VenueWhereId =allPORItemMap.get(param_Id).VenueWhereId;   
            temp.UnitCost=allPORItemMap.get(param_Id).UnitCost;
            temp.PoRemaining=allPORItemMap.get(param_Id).PoRemaining;
           
            temp.PoAmount=allPORItemMap.get(param_Id).PoAmount;
            
            
            allPORItemMap.put(LINE_ITEM_NEWRECORD_PREFIX+newIDCounter, temp);
            
            
        }
        
        
    }// end of clone function 
    
    
    
    
    public PageReference saveLinetems(){
        
        onCommitted();
        PageReference pageRef ;
        if(UpsertPermission){
             pageRef=new PageReference('/'+Header.ASI_MFM_PO__c);
        }else{
            pageRef=null;
        }
       
        return pageRef;
    }
    
    public void onCommitted(){
        Database.upsertResult[] upsertTarget;
        Database.deleteResult[] deleteTarget;
        UpsertPermission=true;
        List<ASI_MFM_PO_Receipt_Item__c> upsertTargetList = new List<ASI_MFM_PO_Receipt_Item__c>();
        
        UpsertPermission=valdationCheckingStep(allPORItemMap);
        
        Set<id> POLineSet = new Set <id>();
        
        boolean HaveETLTrue=false;
        boolean HaveETLFalse=false;
        
        if(UpsertPermission){
            for(String key : allPORItemMap.keySet()){
                if(allPORItemMap.get(key).por.ASI_MFM_ETL__c){
                    HaveETLTrue=true;
                }else{
                    HaveETLFalse=true;
                }
                upsertTargetList.add(allPORItemMap.get(key).por);//
                POLineSet.add(allPORItemMap.get(key).por.ASI_MFM_PO_Line_Item__c);
            }
        }
        
        System.Savepoint pSavepoint = Database.setSavepoint();
        try{
            if(UpsertPermission){
                //update deleted List
                if(deleteLineItemList.size()>0){
                    deleteTarget = Database.delete(deleteLineItemList);
                    deleteTarget.clear();
                    deleteLineItemList.clear();
                }
                
                //update PO Receipt Line
                if(upsertTargetList.size()>0){
                    upsertTarget = Database.upsert(upsertTargetList);
                }
                
                //Update PO Receipt Header:  when save, status should be updated back to “Draft”, and ETL checkbox should be false on PO Receipt “HEADER”
                if(!DisplayPOL && HaveETLFalse && HaveETLTrue){
                    Header.ASI_MFM_Status__c='Draft';
                    Header.ASI_MFM_ETL__c=false;
                    Header.recordTypeId=Global_RecordTypeCache.getRTId('ASI_MFM_PO_Receipt__cASI_MFM_KR_PO_Receipt');
                    update Header;
                }
                
                List<ASI_MFM_PO_Line_Item__c> POLineList=[select id,name,ASI_MFM_CN_Remaining_Receipt_Balance__c from ASI_MFM_PO_Line_Item__c where id in : POLineSet];
                for(ASI_MFM_PO_Line_Item__c pol:POLineList){
                    if(pol.ASI_MFM_CN_Remaining_Receipt_Balance__c<0){
                        msg += 'Save Error! '+  pol.name +': Total PO Receipt Amount larger than PO Line Amount.</br>';
                        UpsertPermission=false;
                    }
                }
                if(!UpsertPermission){
                     
                     SaveSuccess=false;
                     Database.rollback(pSavepoint);
                }else{
                    SaveSuccess=true;
                }
                
                
            }else{
                SaveSuccess=false;
                
            }
            
        }catch(Exception e){
             msg += 'Save Error!'+  e.getMessage() +'</br>';
            UpsertPermission = false;
            SaveSuccess= false;
            Database.rollback(pSavepoint);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Save Error!' + e));
        }
        
    }
    
    public Boolean valdationCheckingStep(Map<String, interimData> allLineItemMap ){
        
        Boolean isProcess = true;
        Integer idx = 1; 
        Decimal totalPORAmt=0;
        Decimal totalPOLAmt=0;        
        
        Msg = '';
        if(allLineItemMap == null) return false;
        
        set<string> bypassset= ASI_MFM_ByPass_Setting.ByPassClassMap('ASI_MFM_KR_POReceiptManageAllCtrler','KR');
            
        for(String key : allLineItemMap.keySet()){
            
            /*
            if(Header.ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c!=null && allLineItemMap.get(key).por.ASI_MFM_Receipt_Date__c!=null && !bypassset.contains('ReceiptDateinPlan')){
                Date Startdate= Date.newInstance(2000+integer.valueOf(Header.ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c.substring(2,4)), 7,1);
                Date Enddate=Date.newInstance(2000+integer.valueOf(Header.ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c.substring(4, 6)), 6,30);
                if(allLineItemMap.get(key).por.ASI_MFM_Receipt_Date__c>Enddate){
                    isProcess=false;
                    Msg += 'Line ' + idx + ' : Receipt Date can after Plan fiscal Year'+'</br>';
                }
                if(allLineItemMap.get(key).por.ASI_MFM_Receipt_Date__c<Startdate){
                    isProcess=false;
                    Msg += 'Line ' + idx + ' : Receipt Date can before Plan fiscal Year'+'</br>';
                }
            }
            */
            
            //Receipt Date can not be null
            if(allLineItemMap.get(key).por.ASI_MFM_Receipt_Date__c==null){
                isProcess=false;
                Msg += 'Line ' + idx + ' : Receipt Date can not be null'+'</br>';
            }
            
            //Added by Kammy at 21 Dec 2015: Receipt Date can not after today    
            if(allLineItemMap.get(key).por.ASI_MFM_Receipt_Date__c > date.today()){  
                isProcess=false;
                Msg += 'Line ' + idx + ' : Receipt Date can not be after today'+'</br>';
            }
            
             //Receipt Amount can not be null 
            if(allLineItemMap.get(key).por.ASI_MFM_Amount__c==null){
                isProcess=false;
                Msg += 'Line ' + idx + ' : Receipt Amount can not be null'+'</br>';
            }
            //Quantity
            if(allLineItemMap.get(key).por.ASI_MFM_Quantity__c==null){
                isProcess=false;
                Msg += 'Line ' + idx + ' : Quantity can not be null'+'</br>';
            }
            
            //Amount Checking
            if(allLineItemMap.get(key).por.ASI_MFM_Amount__c>allLineItemMap.get(key).PoRemaining){
                isProcess=false;
                Msg += 'Line ' + idx + ' : Amount:( '+allLineItemMap.get(key).por.ASI_MFM_Amount__c+')> PO Line Aamount('+allLineItemMap.get(key).PoRemaining+').'+'</br>';
            }
         
            totalPORAmt=totalPORAmt+allLineItemMap.get(key).por.ASI_MFM_Amount__c;
            totalPOLAmt=totalPOLAmt+allLineItemMap.get(key).PoRemaining;
            
            // Modified by 2018-09-14 Linus@introv
            if(!allLineItemMap.get(key).por.ASI_MFM_ETL__c && (String.isEmpty(allLineItemMap.get(key).Customer) || String.isEmpty(allLineItemMap.get(key).CustomerId))){// && allLineItemMap.get(key).APCode.ASI_MFM_Beneficiary_WS_Venue__c){
                isProcess=false;
                Msg += 'Line ' + idx + ' : Customer (Beneficiary) can not be null'+'</br>';
            }
            
            if(!String.isEmpty(allLineItemMap.get(key).CustomerId) && isProcess){
                try{//Need to map back the ID to Customer
                    allLineItemMap.get(key).por.ASI_MFM_AccountsAdditionalField__c =  Id.valueOf(allLineItemMap.get(key).CustomerId);
                }//end try
                catch(exception e)
                {
                    msg += 'Line ' + idx + ' : Please select Customer' + '</br>';
                    isProcess = false;  
                }//end catch
            }
            if(String.isEmpty(allLineItemMap.get(key).Customer)){
                allLineItemMap.get(key).por.ASI_MFM_AccountsAdditionalField__c = null;
            }
            
            // Modified by 2018-09-14 Linus@introv
            if(!allLineItemMap.get(key).por.ASI_MFM_ETL__c && (String.isEmpty(allLineItemMap.get(key).VenueWhere)|| String.isEmpty(allLineItemMap.get(key).VenueWhereId))){// && allLineItemMap.get(key).APCode.ASI_MFM_Beneficiary_WS_Venue__c){
                isProcess=false;
                Msg += 'Line ' + idx + ' : Venue(Where) can not be null'+'</br>';
            }
            
            if(!String.isEmpty(allLineItemMap.get(key).VenueWhereId) && isProcess){
                try{//Need to map back the ID to Customer
                    allLineItemMap.get(key).por.ASI_MFM_Venue_Where__c =  Id.valueOf(allLineItemMap.get(key).VenueWhereId);
                }//end try
                catch(exception e)
                {
                    msg += 'Line ' + idx + ' : Please select Venue' + '</br>';
                    isProcess = false;  
                }//end catch
            }
            if(String.isEmpty(allLineItemMap.get(key).VenueWhere)){
                allLineItemMap.get(key).por.ASI_MFM_Venue_Where__c = null;
            }
            
            
            
            idx++;
        }
        
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
        if(allPORItemMap.isEmpty()){
            ASI_MFM_PO_Receipt__c por=new ASI_MFM_PO_Receipt__c();
            por.id=Header.id;
            delete por;
        }
        Pagereference ref;
        ref = new PageReference('/'+Header.ASI_MFM_PO__c);
        ref.setRedirect(true);
        return ref;
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
            soql = 'select Id, Name, ASI_CRM_CN_Address__c,RecordType.DeveloperName, ASI_CRM_CN_Phone_Number__c from ' + obj + filter;
        else 
            soql = 'select Id, Name, ASI_CRM_CN_Address__c,RecordType.DeveloperName, ASI_CRM_CN_Phone_Number__c from ' + obj ; 
        
        List<sObject> sobjs = new List<sObject>();
        
        List<String> results = new List<String>();
        
        
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
    
    @RemoteAction       // Added by 2017-12-04 Linus@introv
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
        if(filter != '' || filter != null){
            //if(obj != 'ASI_MFM_AP_Code__c')
                soql = 'select '+statement+' from ' + obj + filter +' order by Name';
            //else
                //soql = 'select '+statement+' from ' + obj + filter +' and ASI_MFM_AP_Type__c IN:'+APType+' order by Name';
        }else{            
            soql = 'select '+statement+' from ' + obj +' order by Name';            
        }
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