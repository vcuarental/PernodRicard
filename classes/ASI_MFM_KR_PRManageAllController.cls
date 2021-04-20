public class ASI_MFM_KR_PRManageAllController {
    public ApexPages.StandardController standardController {get;set;}
    public ASI_MFM_Purchase_Request__c Header {get;set;}
    
    public boolean SaveSuccess {get;set;}
    public boolean UpsertPermission {get;set;}{UpsertPermission=true;}
    public boolean Calculate {get;set;}{Calculate=false;}
    public boolean DisplayPOL {get;set;}{DisplayPOL=true;}
    public static String LINE_ITEM_NEWRECORD_PREFIX {get{ return 'z';}}
    public Integer LINE_ITEM_NEWRECORD_COUNTER {get;set;}
    //Record Type
    public Transient String AP_Code_RecordType_Developer_Name {set;get;}{AP_Code_RecordType_Developer_Name='ASI_KR_AP_Code';}
    public Transient String SKU_RecordType_Developer_Name {set;get;}{SKU_RecordType_Developer_Name='ASI_MFM_KR_SKU';}
    public Map<String, interimData> allPRLItemMap {get;set;}{ allPRLItemMap = new Map<String, interimData>();}
    
    public Map<String, interimPlanL> allPlanLineMap {get;set;}{ allPlanLineMap = new Map<String, interimPlanL>();}
    public transient Map<id, id> APACMap { get; set; } {APACMap = new Map<id, id>();}//id is AP Code ID
    public transient Map<String, Id> SubLedgerMap {get;set;} {SubLedgerMap = new Map<String, Id>();} // Added by 2018-01-12 Linus@introv
    
    //The Line need to delete
    public List<ASI_MFM_Purchase_Request_Line__c> deleteLineItemList {get;set;} {deleteLineItemList = new List<ASI_MFM_Purchase_Request_Line__c>();}
    
    public String Msg {get;set;}{Msg='';}
    
    //Budget Checking
  //  public Map<String,ASI_MFM_KR_BudgetCheckingClass.BrandBudget> resultMap {get;set;}{ resultMap = new Map<String,ASI_MFM_KR_BudgetCheckingClass.BrandBudget>();}
    
    
    public Map<String, checkingdata> checkingMap {get;set;}
    
    public Class interimData{
        public ASI_MFM_Purchase_Request_Line__c line {get; set;}
        public String AC_Code {get; set;}
        public String AC_CodeID {get; set;}
        
        public String SB_Code {get; set;}
        public String SB_CodeID {get; set;}
        public String Customer {get; set;}
        public String CustomerID {get; set;}
        
        public String SKU {get; set;}
        public String SKUID {get; set;}
        
        public String subLedger{get;set;} // ----- 2015-12-22
        public String subLedgerId{get;set;} // ----- 2015-12-22
        
        public string APType{get;set;}
        public string APCategory{get;set;}
        public String AP_Code {get; set;}
        public String AP_CodeID {get; set;}
        
        public Decimal Amount {get; set;}
        public Decimal PlanAmount {get; set;}
    }
    
    public class checkingdata{
        
        public String SB_Code {get; set;}
        //public ASI_MFM_KR_BudgetCheckingClass.BrandBudget budgetclass {get; set;}
        public boolean overbudget {get; set;}
        public Decimal amount  {get;set;}  
        public Decimal Planamount  {get;set;}  
        public decimal Planspent {get;set;}{Planspent=0;}
    }
    
    
    public Class interimPlanL{  // interimPOL
        public ASI_MFM_Plan_Line_Item__c line {get; set;}
        public Decimal RemainAmt {get; set;}
    }
    
    
    
    // Define the constructor
    public ASI_MFM_KR_PRManageAllController(ApexPages.StandardController standardController){
        this.standardController = standardController;
        this.Header = (ASI_MFM_Purchase_Request__c) this.standardController.getRecord();
        if(this.Header !=null && this.Header.Id !=null){
            //Get Header Info
            for(ASI_MFM_Purchase_Request__c line : [Select id,ASI_MFM_Service_Item_POSM__c,ASI_MFM_Need_Attachment__c,ASI_MFM_Type__c,ASI_MFM_Exchange_Rate__c, ASI_MFM_Currency__c,ASI_MFM_Plan__r.ASI_MFM_Budget_Type__c,
                                                    ASI_MFM_Plan__r.ASI_MFM_Project_Code__c,ASI_MFM_Status__c,Name,ASI_MFM_Plan__c ,ASI_MFM_Description__c,ASI_MFM_PR_Date__c,ASI_MFM_PR_Name__c,
                                                    ASI_MFM_PR_Number__c,ASI_MFM_Product_Item__c,ASI_MFM_Project_Code__c, ASI_MFM_Company_Code__c  
                                                    FROM ASI_MFM_Purchase_Request__c where Id =: this.Header.Id limit 1]){  
                                                        this.Header = line;
                                                    }
        }
    }
    
    
    // Initialize
    public void init() {
        SaveSuccess=false;
        if(this.Header !=null && this.Header.Id !=null){
            //get PO Receipt Items Lines  
            
            List<ASI_MFM_Purchase_Request_Line__c> PRlineItemList =[select id,name,ASI_MFM_Basic_POSM__c,
                                                                    ASI_MFM_Basic_POSM__r.name,
                                                                    ASI_MFM_Plan_Line_Item__r.ASI_MFM_Product_Item__c, 
                                                                    ASI_MFM_Plan_Line_Item__r.ASI_MFM_Product_Item__r.name, ASI_MFM_Estimated_PR_budget__c,ASI_MFM_UOM__c,
                                                                    ASI_MFM_Plan_Line_Item__r.ASI_MFM_AccountsAdditionalField__r.name,
                                                                    ASI_MFM_Plan_Line_Item__r.ASI_MFM_AccountsAdditionalField__c, ASI_MFM_AP_Code__r.name,ASI_MFM_AP_Code__c,
                                                                    ASI_MFM_Plan_Line_Item__r.ASI_MFM_AP_Code__r.name,ASI_MFM_AP_Code__r.ASI_MFM_AP_Category__c,
                                                                    ASI_MFM_Plan_Line_Item__r.ASI_MFM_AP_Code__c, ASI_MFM_AP_Code__r.ASI_MFM_AP_Type__c,
                                                                    ASI_MFM_Plan_Line_Item__r.ASI_MFM_Total_Cost__c,
                                                                    ASI_MFM_Plan_Line_Item__r.ASI_MFM_A_C_Code__r.name,
                                                                    ASI_MFM_Plan_Line_Item__r.ASI_MFM_A_C_Code__c,ASI_MFM_Plan_Line_Item__c,
                                                                    ASI_MFM_Quantity__c,ASI_MFM_Tax_Code__c,ASI_MFM_Unit_Cost__c,ASI_MFM_Description__c ,ASI_MFM_Delivery_Date__c,
                                                                    ASI_MFM_Plan_Line_Item__r.ASI_MFM_Sub_brand_Code__c, ASI_MFM_Plan_Line_Item__r.ASI_MFM_Sub_brand_Code__r.name,
                                                                    ASI_MFM_KR_subLedger__c, ASI_MFM_KR_subLedger__r.Name, // ----- 2015-12-22
                                                                    ASI_MFM_Consumer_Prize__c //20180121 Introv
                                                                    from ASI_MFM_Purchase_Request_Line__c where ASI_MFM_Purchase_Request__c=:Header.id ];         
            set<ID> planlineID_set = new set<ID>();
            //Up line Map
            if(!PRlineItemList.isEmpty()){
                for(ASI_MFM_Purchase_Request_Line__c Prline : PRlineItemList){
                    String polId = (String)(Prline.id);
                    // if(!allPRLItemMap.containsKey(polId)){
                    interimData temp= new interimData();
                    temp.line=Prline;
                    // temp.AC_Code=Prline.ASI_MFM_Plan_Line_Item__r.ASI_MFM_A_C_Code__r.name;
                    //temp.AC_CodeID=Prline.ASI_MFM_Plan_Line_Item__r.ASI_MFM_A_C_Code__c;
                    temp.AP_Code=Prline.ASI_MFM_AP_Code__r.name;
                    temp.AP_CodeID=Prline.ASI_MFM_AP_Code__c;
                    temp.APType=Prline.ASI_MFM_AP_Code__r.ASI_MFM_AP_Type__c;
                    temp.APCategory=Prline.ASI_MFM_AP_Code__r.ASI_MFM_AP_Category__c ;   
                    temp.Customer=Prline.ASI_MFM_Plan_Line_Item__r.ASI_MFM_AccountsAdditionalField__r.name;
                    temp.CustomerID=Prline.ASI_MFM_Plan_Line_Item__r.ASI_MFM_AccountsAdditionalField__c;
                    temp.SB_Code=Prline.ASI_MFM_Plan_Line_Item__r.ASI_MFM_Sub_brand_Code__r.name;
                    temp.SB_CodeID=Prline.ASI_MFM_Plan_Line_Item__r.ASI_MFM_Sub_brand_Code__c;
                    temp.subLedger=Prline.ASI_MFM_KR_subLedger__r.Name;
                    temp.subLedgerId=Prline.ASI_MFM_KR_subLedger__c;
                    temp.SKU=Prline.ASI_MFM_Basic_POSM__r.name;
                    temp.SKUID=Prline.ASI_MFM_Basic_POSM__c;
                    
                    
                    if(temp.line.ASI_MFM_Quantity__c!=null && temp.line.ASI_MFM_Unit_Cost__c!=null){
                        temp.Amount=temp.line.ASI_MFM_Quantity__c*temp.line.ASI_MFM_Unit_Cost__c;
                    }
                    if(Header.ASI_MFM_Exchange_Rate__c!=null && Prline.ASI_MFM_Plan_Line_Item__c!=null){
                        temp.PlanAmount=(Prline.ASI_MFM_Plan_Line_Item__r.ASI_MFM_Total_Cost__c/Header.ASI_MFM_Exchange_Rate__c).setScale(2, roundingMode.half_up);
                    }else if(Prline.ASI_MFM_Plan_Line_Item__c!=null){
                        temp.PlanAmount=Prline.ASI_MFM_Plan_Line_Item__r.ASI_MFM_Total_Cost__c;
                    }
                    
                    allPRLItemMap.put(polId, temp);
                    planlineID_set.add(Prline.ASI_MFM_Plan_Line_Item__c);
                    
                    //  }
                }
            }
            //Up end
            
            //get Plan line 
            List<ASI_MFM_Plan_Line_Item__c> PlanlineList = [select id,ASI_MFM_AccountsAdditionalField__r.name, ASI_MFM_Product_Item__r.name,
                                                            ASI_MFM_A_C_Code__r.name,name,ASI_MFM_AP_Code__c,
                                                            ASI_MFM_AP_Code__r.ASI_MFM_AP_Type__c,
                                                            ASI_MFM_AP_Code__r.name,ASI_MFM_A_C_Code__c,ASI_MFM_Product_Item__c,
                                                            ASI_MFM_Plan__c,ASI_MFM_Total_Cost__c, ASI_MFM_AccountsAdditionalField__c,
                                                            ASI_MFM_List_Item_Description__c, ASI_MFM_Sub_brand_Code__c, ASI_MFM_AP_Code__r.ASI_MFM_AP_Category__c,
                                                            ASI_MFM_Sub_brand_Code__r.name, ASI_MFM_KR_subLedger__c, ASI_MFM_KR_subLedger__r.Name // ----- 2015-12-22
                                                            from ASI_MFM_Plan_Line_Item__c 
                                                            where id not in: planlineID_set and 
                                                            RecordType.DeveloperName like'ASI_MFM_KR%' and 
                                                            ASI_MFM_Plan__c=:Header.ASI_MFM_Plan__c and
                                                            ASI_MFM_Sub_brand_Code__r.ASI_MFM_Company_Code__c =: Header.ASI_MFM_Company_Code__c AND 
                                                            ASI_MFM_AP_Code__r.ASI_MFM_PRPO_Needed__c=true];  //Added by Kammy at 22 Dec 2015 
            if(!PlanlineList.isEmpty()){   //allPlanLineMap
                for(ASI_MFM_Plan_Line_Item__c line:PlanlineList){
                    String polid=(String)(line.id);
                    if(!allPlanLineMap.containsKey(polid)){
                        interimPlanL temp= new interimPlanL();
                        temp.line=line;
                        allPlanLineMap.put(polid,temp);
                    }
                }
            }
            
           // checking();
        }
        
    }    
    
    public void removeLine() {
        SaveSuccess=false;
        UpsertPermission=true;
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String param_Id = params.get('PARAM_PORLine_ID');
        
        if(allPRLItemMap.containsKey(param_Id) && !allPRLItemMap.isEmpty() && allPRLItemMap.get(param_Id).line.ASI_MFM_Plan_Line_Item__c !=null){
            
            ASI_MFM_Plan_Line_Item__c Pline = [select id,ASI_MFM_AccountsAdditionalField__r.name, ASI_MFM_Product_Item__r.name,ASI_MFM_A_C_Code__r.name,name,ASI_MFM_AP_Code__c,ASI_MFM_AP_Code__r.name,
                                               ASI_MFM_A_C_Code__c,ASI_MFM_AP_Code__r.ASI_MFM_AP_Category__c,ASI_MFM_Product_Item__c,ASI_MFM_Plan__c,ASI_MFM_Total_Cost__c, ASI_MFM_AccountsAdditionalField__c, ASI_MFM_List_Item_Description__c,
                                               ASI_MFM_Sub_brand_Code__c, ASI_MFM_AP_Code__r.ASI_MFM_AP_Type__c,ASI_MFM_Sub_brand_Code__r.name, ASI_MFM_KR_subLedger__c, ASI_MFM_KR_subLedger__r.Name // ----- 2015-12-22
                                               from ASI_MFM_Plan_Line_Item__c where id =:allPRLItemMap.get(param_Id).line.ASI_MFM_Plan_Line_Item__c];
            
            if(Pline!=null){
                String polid=(String)(Pline.id);
                if(!allPlanLineMap.containsKey(polid)){
                    interimPlanL temp= new interimPlanL();
                    temp.line=Pline;
                    
                    allPlanLineMap.put(polid,temp);
                }
            }
            
            ASI_MFM_Purchase_Request_Line__c delTarget=allPRLItemMap.get(param_Id).line;
            if(delTarget.id != null){
                deleteLineItemList.add(delTarget);
            }
            allPRLItemMap.remove(param_Id);
        }  
    }
    
    
    //Add all line to PR Line Map 
    public void addallLineItem(){
        SaveSuccess=false;
        UpsertPermission=true;
        for(String key : allPlanLineMap.keySet()){
            string newIDCounter = newCounterCreatorLine();
            interimData temp= new interimData();
            
            temp.line=new ASI_MFM_Purchase_Request_Line__c(ASI_MFM_Purchase_Request__c=Header.id,
                                                           recordtypeid = Global_RecordTypeCache.getRTId('ASI_MFM_Purchase_Request_Line__cASI_MFM_KR_Purchase_Request_Line'),
                                                           ASI_MFM_Description__c =  allPlanLineMap.get(key).line.ASI_MFM_List_Item_Description__c,
                                                           ASI_MFM_AP_Code__c=allPlanLineMap.get(key).line.ASI_MFM_AP_Code__c,
                                                           ASI_MFM_A_C_Code__c=allPlanLineMap.get(key).line.ASI_MFM_A_C_Code__c,
                                                           ASI_MFM_Customer__c=allPlanLineMap.get(key).line.ASI_MFM_AccountsAdditionalField__c,
                                                           ASI_MFM_UOM__c='EA',
                                                           ASI_MFM_Delivery_Date__c=system.today(),
                                                           ASI_MFM_Sub_brand_Code__c=allPlanLineMap.get(key).line.ASI_MFM_Sub_brand_Code__c,
                                                           ASI_MFM_KR_Subledger__c=allPlanLineMap.get(key).line.ASI_MFM_KR_subLedger__c, // ----- 2015-12-22
                                                           ASI_MFM_Plan_Line_Item__c=allPlanLineMap.get(key).line.id);
            if(Header.ASI_MFM_Exchange_Rate__c!=null){
                temp.line.ASI_MFM_Estimated_PR_budget__c=(allPlanLineMap.get(key).line.ASI_MFM_Total_Cost__c/Header.ASI_MFM_Exchange_Rate__c).setScale(2, roundingMode.half_up);
                temp.PlanAmount=(allPlanLineMap.get(key).line.ASI_MFM_Total_Cost__c/Header.ASI_MFM_Exchange_Rate__c).setScale(2, roundingMode.half_up);
            }else{
                temp.line.ASI_MFM_Estimated_PR_budget__c=allPlanLineMap.get(key).line.ASI_MFM_Total_Cost__c;
                temp.PlanAmount=allPlanLineMap.get(key).line.ASI_MFM_Total_Cost__c;
            }                                                 
            //display
            
            temp.AP_Code=allPlanLineMap.get(key).line.ASI_MFM_AP_Code__r.name;
            temp.AP_CodeID=allPlanLineMap.get(key).line.ASI_MFM_AP_Code__c;
            temp.APCategory=allPlanLineMap.get(key).line.ASI_MFM_AP_Code__r.ASI_MFM_AP_Category__c;
            temp.APType=allPlanLineMap.get(key).line.ASI_MFM_AP_Code__r.ASI_MFM_AP_Type__c; 
            
            temp.AC_CodeID=allPlanLineMap.get(key).line.ASI_MFM_A_C_Code__c;
            temp.AC_Code=allPlanLineMap.get(key).line.ASI_MFM_A_C_Code__r.name;
            temp.AP_Code=allPlanLineMap.get(key).line.ASI_MFM_AP_Code__r.name;
            temp.AP_CodeID=allPlanLineMap.get(key).line.ASI_MFM_AP_Code__c;
            temp.SB_Code=allPlanLineMap.get(key).line.ASI_MFM_Sub_brand_Code__r.name;
            temp.SB_CodeID=allPlanLineMap.get(key).line.ASI_MFM_Sub_brand_Code__c;
            temp.Customer=allPlanLineMap.get(key).line.ASI_MFM_AccountsAdditionalField__r.name;
            temp.CustomerID=allPlanLineMap.get(key).line.ASI_MFM_AccountsAdditionalField__c;
            temp.subLedger=allPlanLineMap.get(key).line.ASI_MFM_KR_subLedger__r.Name; // ----- 2015-12-22
            temp.subLedgerId=allPlanLineMap.get(key).line.ASI_MFM_KR_subLedger__c; // ----- 2015-12-22
            
            allPRLItemMap.put(LINE_ITEM_NEWRECORD_PREFIX+newIDCounter, temp);
            //Remove PR Line Map
            allPlanLineMap.remove(key);
            
        }
        
    }
    
    //Add One line to PR Line Map     
    public void addLineItem(){
        SaveSuccess=false;
        UpsertPermission=true;
        
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String param_SourceItemId = params.get('PARAM_POLINE_SOURCE_ITEM_ID');
        
        if(allPlanLineMap.containsKey(param_SourceItemId)){
            string newIDCounter = newCounterCreatorLine();
            interimData temp= new interimData();
            
            temp.line=new ASI_MFM_Purchase_Request_Line__c(ASI_MFM_Purchase_Request__c=Header.id,
                                                           recordtypeid = Global_RecordTypeCache.getRTId('ASI_MFM_Purchase_Request_Line__cASI_MFM_KR_Purchase_Request_Line'),
                                                           ASI_MFM_Description__c =  allPlanLineMap.get(param_SourceItemId).line.ASI_MFM_List_Item_Description__c,
                                                           //ASI_MFM_AP_Code__c=allPlanLineMap.get(param_SourceItemId).line.ASI_MFM_AP_Code__c,
                                                           ASI_MFM_A_C_Code__c=allPlanLineMap.get(param_SourceItemId).line.ASI_MFM_A_C_Code__c,
                                                           ASI_MFM_Customer__c=allPlanLineMap.get(param_SourceItemId).line.ASI_MFM_AccountsAdditionalField__c,
                                                           ASI_MFM_UOM__c='EA',
                                                           ASI_MFM_Delivery_Date__c=system.today(),
                                                           ASI_MFM_Sub_brand_Code__c=allPlanLineMap.get(param_SourceItemId).line.ASI_MFM_Sub_brand_Code__c,
                                                           ASI_MFM_KR_Subledger__c=allPlanLineMap.get(param_SourceItemId).line.ASI_MFM_KR_subLedger__c, // ----- 2015-12-22
                                                           ASI_MFM_Plan_Line_Item__c=allPlanLineMap.get(param_SourceItemId).line.id,
                                                           ASI_MFM_Consumer_Prize__c=false );//20180121 Introv
            if(Header.ASI_MFM_Exchange_Rate__c!=null){
                temp.line.ASI_MFM_Estimated_PR_budget__c=(allPlanLineMap.get(param_SourceItemId).line.ASI_MFM_Total_Cost__c/Header.ASI_MFM_Exchange_Rate__c).setScale(2, roundingMode.half_up);
                temp.PlanAmount=(allPlanLineMap.get(param_SourceItemId).line.ASI_MFM_Total_Cost__c/Header.ASI_MFM_Exchange_Rate__c).setScale(2, roundingMode.half_up);
            }else{
                temp.line.ASI_MFM_Estimated_PR_budget__c=allPlanLineMap.get(param_SourceItemId).line.ASI_MFM_Total_Cost__c;
                temp.PlanAmount=allPlanLineMap.get(param_SourceItemId).line.ASI_MFM_Total_Cost__c;
            }   
            //display
            /* temp.AC_CodeID=allPlanLineMap.get(param_SourceItemId).line.ASI_MFM_A_C_Code__c;        temp.AC_Code=allPlanLineMap.get(param_SourceItemId).line.ASI_MFM_A_C_Code__r.name;*/
            
            temp.AP_Code=allPlanLineMap.get(param_SourceItemId).line.ASI_MFM_AP_Code__r.name;
            temp.AP_CodeID=allPlanLineMap.get(param_SourceItemId).line.ASI_MFM_AP_Code__c;
            temp.APCategory=allPlanLineMap.get(param_SourceItemId).line.ASI_MFM_AP_Code__r.ASI_MFM_AP_Category__c;
            temp.APType=allPlanLineMap.get(param_SourceItemId).line.ASI_MFM_AP_Code__r.ASI_MFM_AP_Type__c; 
            
            temp.SB_Code=allPlanLineMap.get(param_SourceItemId).line.ASI_MFM_Sub_brand_Code__r.name;
            temp.SB_CodeID=allPlanLineMap.get(param_SourceItemId).line.ASI_MFM_Sub_brand_Code__c;
            temp.Customer=allPlanLineMap.get(param_SourceItemId).line.ASI_MFM_AccountsAdditionalField__r.name;
            temp.CustomerID=allPlanLineMap.get(param_SourceItemId).line.ASI_MFM_AccountsAdditionalField__c;
            temp.subLedger=allPlanLineMap.get(param_SourceItemId).line.ASI_MFM_KR_subLedger__r.Name; // ----- 2015-12-22
            temp.subLedgerId=allPlanLineMap.get(param_SourceItemId).line.ASI_MFM_KR_subLedger__c; // ----- 2015-12-22
            
            allPRLItemMap.put(LINE_ITEM_NEWRECORD_PREFIX+newIDCounter, temp);
            allPlanLineMap.remove(param_SourceItemId);
        }
        
    }
    
    public void cloneLine(){
        SaveSuccess=false;
        UpsertPermission=true;
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String param_Id = params.get('PARAM_clone_ID');
        if(allPRLItemMap.containsKey(param_Id) && !allPRLItemMap.isEmpty()){
            string newIDCounter = newCounterCreatorLine();
            interimData temp= new interimData();
            temp.line=new ASI_MFM_Purchase_Request_Line__c(ASI_MFM_Purchase_Request__c=Header.id,
                                                           recordtypeid = Global_RecordTypeCache.getRTId('ASI_MFM_Purchase_Request_Line__cASI_MFM_KR_Purchase_Request_Line'),
                                                           ASI_MFM_Description__c =  allPRLItemMap.get(param_Id).line.ASI_MFM_Description__c,
                                                           ASI_MFM_Quantity__c=  allPRLItemMap.get(param_Id).line.ASI_MFM_Quantity__c,
                                                           ASI_MFM_UOM__c=  allPRLItemMap.get(param_Id).line.ASI_MFM_UOM__c,
                                                           ASI_MFM_Estimated_PR_budget__c=  allPRLItemMap.get(param_Id).line.ASI_MFM_Estimated_PR_budget__c,
                                                           ASI_MFM_Customer__c=allPRLItemMap.get(param_Id).CustomerID,
                                                           ASI_MFM_Sub_brand_Code__c=allPRLItemMap.get(param_Id).SB_CodeID,
                                                           ASI_MFM_KR_Subledger__c=allPRLItemMap.get(param_Id).subLedgerId,
                                                           ASI_MFM_Delivery_Date__c=allPRLItemMap.get(param_Id).line.ASI_MFM_Delivery_Date__c,
                                                           ASI_MFM_Plan_Line_Item__c=allPRLItemMap.get(param_Id).line.ASI_MFM_Plan_Line_Item__c,
                                                           ASI_MFM_Consumer_Prize__c=allPRLItemMap.get(param_Id).line.ASI_MFM_Consumer_Prize__c);//20180121 Introv
            
            if(String.isNotEmpty(allPRLItemMap.get(param_Id).AP_CodeID) && allPRLItemMap.get(param_Id).AP_Code !=null){
                try{
                    temp.line.ASI_MFM_AP_Code__c=allPRLItemMap.get(param_Id).AP_CodeID;
                    temp.AP_Code=allPRLItemMap.get(param_Id).AP_Code;
                    temp.AP_CodeID=allPRLItemMap.get(param_Id).AP_CodeID;  
                }catch(Exception e){
                    system.debug('Failed');
                    system.debug(e);
                }
            }
            
            
            temp.APCategory=allPRLItemMap.get(param_Id).APCategory;
            temp.APType=allPRLItemMap.get(param_Id).APType;
            temp.SKU=allPRLItemMap.get(param_Id).SKU;
            temp.SKUID=allPRLItemMap.get(param_Id).SKUID;
            
            temp.SB_Code=allPRLItemMap.get(param_Id).SB_Code;
            temp.SB_CodeID=allPRLItemMap.get(param_Id).SB_CodeID;
            temp.Customer=allPRLItemMap.get(param_Id).Customer;
            temp.CustomerID=allPRLItemMap.get(param_Id).CustomerID;
            temp.subLedger=allPRLItemMap.get(param_Id).subLedger; // ----- 2015-12-22
            temp.subLedgerId=allPRLItemMap.get(param_Id).subLedgerId; // ----- 2015-12-22
            temp.PlanAmount=allPRLItemMap.get(param_Id).PlanAmount;
            allPRLItemMap.put(param_Id+newIDCounter, temp);
        }
    }
    
    //Save function
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
    
    /*
    //Budget Checking 
    public void checking(){
        Calculate=true;
        
        ASI_MFM_KR_BudgetCheckingClass bcc = new ASI_MFM_KR_BudgetCheckingClass();
        ASI_MFM_Plan__c Plan=[select id,name from ASI_MFM_Plan__c where id =: Header.ASI_MFM_Plan__c];
        bcc.GetBudget(Plan);
        resultMap = new Map<String,ASI_MFM_KR_BudgetCheckingClass.BrandBudget>();
        resultMap = bcc.getResult();   
        
        
        Set<String> SB_Code = new Set<String>();
        Map<string,id> SBMap = new Map<string,id>();
        Map<string,Decimal> SBAmountMap = new Map<string,Decimal>();
        Map<string,Decimal> SBPlanAmountMap = new Map<string,Decimal>();
        for(String key : allPRLItemMap.keySet()){
            SB_Code.add(allPRLItemMap.get(key).SB_Code);
            if(!SBMap.containsKey(allPRLItemMap.get(key).SB_Code)){
                SBMap.put(allPRLItemMap.get(key).SB_Code,allPRLItemMap.get(key).SB_CodeID);
                SBPlanAmountMap.put(allPRLItemMap.get(key).SB_Code,allPRLItemMap.get(key).PlanAmount);
            }
            if(!SBAmountMap.containsKey(allPRLItemMap.get(key).SB_Code)){
                SBAmountMap.put(allPRLItemMap.get(key).SB_Code, allPRLItemMap.get(key).line.ASI_MFM_Estimated_PR_budget__c);
            }else{
                Decimal totalamount = SBAmountMap.get(allPRLItemMap.get(key).SB_Code)+allPRLItemMap.get(key).line.ASI_MFM_Estimated_PR_budget__c;
                SBAmountMap.remove(allPRLItemMap.get(key).SB_Code);
                SBAmountMap.put(allPRLItemMap.get(key).SB_Code,totalamount);
                
            }
            
            
        }        
        
        checkingMap = new Map<String, checkingdata>();
        
        /*
        for(string SBCode: SB_Code){
            checkingdata temp = new checkingdata();
            temp.SB_Code=SBCode;
            if(resultMap.containsKey(string.valueOf(SBMap.get(SBCode))+Header.ASI_MFM_Plan__r.ASI_MFM_Budget_Type__c+ Header.ASI_MFM_Plan__r.ASI_MFM_Project_Code__c)){
                temp.budgetclass=resultMap.get(string.valueOf(SBMap.get(SBCode))+Header.ASI_MFM_Plan__r.ASI_MFM_Budget_Type__c+ Header.ASI_MFM_Plan__r.ASI_MFM_Project_Code__c);
                if(temp.budgetclass.spent != null)
                    temp.Planspent=temp.budgetclass.spent;
            }else{
                temp.Planspent=0;
            }
            temp.Planamount=SBPlanAmountMap.get(SBCode);
            temp.amount=SBAmountMap.get(SBCode);
            
            checkingMap.put(SBCode, temp);
        }
        
        
    }
    */
    
    // Save Function
    public void onCommitted(){
        
        //Function: Check the field 'ASI_MFM_Attachments_for_PR__c' in the AP Map 
        set<id> SetAP =new set<id>();
        Database.upsertResult[] upsertTarget;
        Database.deleteResult[] deleteTarget;
        UpsertPermission=true;
        List<ASI_MFM_Purchase_Request_Line__c> upsertTargetList = new List<ASI_MFM_Purchase_Request_Line__c>();
        
        //Checking 
        UpsertPermission=valdationCheckingStep(allPRLItemMap);
        
        if(UpsertPermission){
            
            //AP / AC Code Map
            APACMap = new Map<id, id>();
            for(ASI_MFM_AP_AC_Code_Map__c apac:[select id,ASI_MFM_A_C_Code__c,ASI_MFM_AP_Code__c,ASI_MFM_AP_Code__r.id from ASI_MFM_AP_AC_Code_Map__c where ASI_MFM_AP_Code__r.RecordType.DeveloperName='ASI_KR_AP_Code']){
                if(!APACMap.containsKey(apac.ASI_MFM_AP_Code__r.id)){
                    APACMap.put(apac.ASI_MFM_AP_Code__r.id, apac.ASI_MFM_A_C_Code__c);
                }
            }
            
            // SubLedger Map        *******Added by 2018-01-12 Linus@introv
            SubLedgerMap = new Map<String, Id>();
            for(ASI_TnE_Branch_Channel__c sl: [Select id, name from ASI_TnE_Branch_Channel__c where Recordtype.Developername = 'ASI_TnE_KR_Branch_Channel']){
                if(!SubLedgerMap.containsKey(sl.name)){
                    SubLedgerMap.put(sl.name, sl.id);
                }
            }
            
            //Put Map to List (Updated)
            for(String key : allPRLItemMap.keySet()){
                ASI_MFM_Purchase_Request_Line__c PRLtemp =new ASI_MFM_Purchase_Request_Line__c();
                PRLtemp=allPRLItemMap.get(key).line;   system.debug('Linus subLedger: ' + allPRLItemMap.get(key).subLedger + ' ' + allPRLItemMap.get(key).subLedgerId);
                //Pass Id to SKU,  AP Code
                if(String.isNotEmpty(allPRLItemMap.get(key).AP_CodeID))
                {
                    
                    if(APACMap.containsKey(allPRLItemMap.get(key).AP_CodeID)){
                        PRLtemp.ASI_MFM_A_C_Code__c=APACMap.get(allPRLItemMap.get(key).AP_CodeID);
                    }else{
                        PRLtemp.ASI_MFM_A_C_Code__c=null;                        
                    }
                    SetAP.add(Id.valueOf(allPRLItemMap.get(key).AP_CodeID));
                }
                if(String.isNotEmpty(allPRLItemMap.get(key).SKUID))
                {
                    PRLtemp.ASI_MFM_Basic_POSM__c= Id.valueOf(allPRLItemMap.get(key).SKUID);
                }else{
                    PRLtemp.ASI_MFM_Basic_POSM__c=null;
                }
                // Added by 2017-12-28 Linus@introv
                if(String.isNotEmpty(allPRLItemMap.get(key).subLedger))
                {
                    PRLtemp.ASI_MFM_KR_Subledger__c = SubLedgerMap.get(allPRLItemMap.get(key).subLedger);
                }else{
                    PRLtemp.ASI_MFM_KR_Subledger__c = null;
                }
                
                upsertTargetList.add(PRLtemp);
                
            }
            
            //Check in Header: if  'Service',check Attachment
            List<ASI_MFM_AP_Code__c> aplist=[select ASI_MFM_Attachments_for_PR__c from ASI_MFM_AP_Code__c where id in: SetAP and ASI_MFM_Attachments_for_PR__c!=null ];
            if(aplist.size()>0 && Header.ASI_MFM_Service_Item_POSM__c== 'Service'){
                Header.ASI_MFM_Need_Attachment__c=true;
            }else{
                Header.ASI_MFM_Need_Attachment__c=false;  
            }
            
        }
        
        try{
            if(UpsertPermission){
                
                if(deleteLineItemList.size()>0){
                    deleteTarget = Database.delete(deleteLineItemList);
                    deleteTarget.clear();
                    deleteLineItemList.clear();
                }
                
                if(upsertTargetList.size()>0){
                    upsertTarget = Database.upsert(upsertTargetList);
                }
                
                update Header;
                SaveSuccess=true;
                
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
            
            if(allLineItemMap.get(key).line.ASI_MFM_Description__c==null){
                isProcess=false;
                Msg += 'Line ' + idx + ' : Please input Description.'+'</br>';
            }
            
            if(allLineItemMap.get(key).line.ASI_MFM_UOM__c==null){
                isProcess=false;
                Msg += 'Line ' + idx + ' : UOM can not be null'+'</br>';
            }
            if(allLineItemMap.get(key).line.ASI_MFM_Quantity__c==null){
                isProcess=false;
                Msg += 'Line ' + idx + ' : Quantity can not be null'+'</br>';
            }
            if(allLineItemMap.get(key).line.ASI_MFM_Delivery_Date__c==null){
                isProcess=false;
                Msg += 'Line ' + idx + ' : Delivery Date can not be null'+'</br>';
            }
            
            if(allLineItemMap.get(key).line.ASI_MFM_Estimated_PR_budget__c==null){
                isProcess=false;
                Msg += 'Line ' + idx + ' : Estimated PR budget can not be null'+'</br>';
            }
            
            if(String.isEmpty(allLineItemMap.get(key).AP_Code) || String.isEmpty(allLineItemMap.get(key).AP_CodeID)){
                isProcess=false;
                Msg += 'Line ' + idx + ' : AP Code can not be null'+'</br>';
            }else{
                
                try{
                    //Need to map back the ID to ASI_MFM_AP_Code__c
                    Id APId = Id.valueOf(allLineItemMap.get(key).AP_CodeID);
                    allLineItemMap.get(key).line.ASI_MFM_AP_Code__c = APId;
                } catch(exception e){
                    msg += 'Line ' + idx + ' : Please select AP Code ' + '</br>';
                    isProcess = false;  
                }
            }
            
            
            /*   if(allLineItemMap.get(key).line.ASI_MFM_Unit_Cost__c==null){
                    isProcess=false;
                    Msg += 'Line ' + idx + ' : Unit Cost can not be null'+'</br>';
                    }
                    if(allLineItemMap.get(key).line.ASI_MFM_Quantity__c==null){
                    isProcess=false;
                    Msg += 'Line ' + idx + ' : Quantity can not be null'+'</br>';
                    }
                    
                    if(allLineItemMap.get(key).line.ASI_MFM_Unit_Cost__c!=null && allLineItemMap.get(key).line.ASI_MFM_Quantity__c!=null){
                    if((allLineItemMap.get(key).line.ASI_MFM_Quantity__c*allLineItemMap.get(key).line.ASI_MFM_Unit_Cost__c)> allLineItemMap.get(key).PlanAmount ){
                    isProcess=false;
                    Msg += 'Line ' + idx + ' : PR Amount :'+(allLineItemMap.get(key).line.ASI_MFM_Quantity__c*allLineItemMap.get(key).line.ASI_MFM_Unit_Cost__c).setScale(0, roundingMode.half_up) +'> Plan Amount ('+allLineItemMap.get(key).PlanAmount.setScale(0, roundingMode.half_up)+'). </br>';
                    }
                    }
                    */
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
    
    
    //-------------------------------RemoteAction Start---------------------------------------------
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
    
    
    
    @RemoteAction
    public static List<sObject> findSKUList(string obj, string qry)
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
            soql = 'select id,name, ASI_MFM_Sub_brand__r.Name,ASI_MFM_Sub_brand__c,ASI_MFM_SKU_Code__c from ' + obj + filter +' order by Name';
        else
            soql = 'select id,name, ASI_MFM_Sub_brand__r.Name,ASI_MFM_Sub_brand__c,ASI_MFM_SKU_Code__c from ' + obj +' order by Name';
        
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
    
    //-------------------------------RemoteAction End---------------------------------------------
}