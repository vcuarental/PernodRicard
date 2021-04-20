/* Requirement 1:Department: Modern Trade(MT) team, PO Prefix: THM, Budget vs Plan Amount break down by customer and by sub-brand
 * Requirement 2: Department:Trade Marketing Off-Trade, PO Prefix:THH, Budget vs Plan Amount break down by brand & by region  
 * Requirement 3: Department: Trade Marketing On-Trade , PO Prefix:THT, Budget vs Plan Amount break down by brand & by region 
 * Requirement 4:Department:  Marketing Department , PO Prefix:THK, Budget vs Plan Amount break down by region  
 * Requirement 5:Department: National On-Trade     , PO Prefix:THP   , Budget vs Plan Amount break down by brand & by region 
 * Cover Component:                    ASI_MFM_TH_Budget_ReportBR_Component   (THH,THP,THT)
 *                                     ASI_MFM_TH_Budgets_Region_PDF_Component   (THH,THP,THT)
 *                                     ASI_MFM_TH_Budgets_THK_PDF_Component  (THK)
 *                                     ASI_MFM_TH_Budgets_THM_PDF_Component  (THM)
 * Version 0.0.1                          2015-03-09 Tony Ren Created
*/
public with sharing class ASI_MFM_TH_Budgets_PDF_PageController {
    
    public String currentHeaderId; /* Store PO Prefix */
    public String PrefixInput {get;set;}  /* Input from page*/
    public String PrefixUse;
    public String PrefixUse1;               // temporary for save Prefix  
    public String PrefixUse2{get;set;}     // Use for Budget SQL use only
    public String PrefixShowing {get;set;} /* Showing in the page(PDF) */
    public String Prefixdept {get;set;} 
    public String FiscalYearNum {get;set;}
    public Integer NowBudget {get;set;}
    public String NowBudgetString {get;set;}
    public Decimal TotalBudgetAmount {get;set;} // calculate total Budget Amount and  Plan Amount
    public Decimal TotalPlanAmount {get;set;}
    public Decimal TotalPOAmt {get;set;}
    public Decimal TotalDifference {get;set;}  // calculate Budget-Plan (Total)
    public Decimal TotalDiffPerc {get;set;}    //calculate percent:   (Budget-Plan)/Budget
    public String TotalDiffPercS {get;set;}    //calculate percent %
   // public Decimal TotalLE1Amount {get;set;}   // calculate  total LE1 Amount 
   // public Decimal TotalLE2Amount {get;set;}     // calculate  total LE2 Amount
   // public Decimal TotalLE3Amount {get;set;}   // calculate  total LE3 Amount
   // public Decimal TotalLE4Amount {get;set;}  // calculate  total LE4 Amount
    public Decimal TotalOriginalAmount {get;set;}  // calculate  total Original Amount
    public Decimal TotalEAmount {get;set;}
    public Decimal TotalPOLAmount {get;set;}   // calculate  total PO line  Amount 
    public Decimal TotalPYLAmount {get;set;}   // calculate  total Payment Line item  Amount
    public Decimal TotalPYLAmt {get;set;}
    public Decimal TotalOriginal {get;set;}    // Use in Total Report (including No Plan,but have PO case)
    public Decimal TotalLE1{get;set;}    //Use in Total Report 
    public Decimal TotalLE2{get;set;}
    public Decimal TotalLE3{get;set;}
    public Decimal TotalLE4{get;set;}
    public Decimal TotalPODiff{get;set;}      // Budget - PO 
   // public Decimal TotalPODiff_BG{get;set;} 
    public Decimal TotalPODiffPer{get;set;}   // (Budget - PO )/ Budget
    public Decimal TotalPLYDiff{get;set;}     // Budget - Payment        //public Decimal TotalPLYDiffPer{get;set;}  // (Budget - Payment )/Budget
  //  public Decimal TotalPLYDiff_BG{get;set;}   
    public List<ASI_MFM_Plan_Line_Item__c> PlanlineItem{get;set;}         //public ASI_MFM_Plan__c plan{get;set;}     // Object
    public List<ASI_MFM_Budget__c> budgetItem{get;set;}
    public List<ASI_MFM_PO_Line_Item__c> POlineItem{get;set;}
    public List<ASI_MFM_Payment_Line_Item__c> paymentLineList{get;set;}
   // public List<ASI_MFM_Prefix__c> PrefixItems {get;set;} 
/*
    public Boolean dummy {   // Call in "ASI_MFM_TH_Budgets_THM_PDF_Component" and starts Initialization, For report Use Brand
        get {                          //   <apex:variable var="dummyV" value="{!dummyVar}" id="dummyVar"/>   
            if (dummy != true) {
                PrefixUse=PrefixInput;
                PrefixShowing=PrefixInput;
                dummy = init();
            }     
            return dummy; 
        } 
        set; 
    }
    */
     public Boolean dummyBR { // For Region and Brand Use 
        get { 
            if (dummyBR != true) {
                PrefixUse=PrefixInput;
                PrefixUse1=PrefixUse;
            	PrefixUse2=PrefixUse1.substring(0,3);
                PrefixShowing=PrefixInput;                                      //System.debug('Fail123aaaa');
				//dummyBR = initBybrandRegion();
                dummyBR =initBybrandandRegion();
            } 
             
            return dummyBR; 
        } 
        set; 
    }
    
     
     public Boolean dummyBRD { // For Region and Brand Use 
        get { 
            if (dummyBRD != true) {
                PrefixUse=PrefixInput;
                PrefixUse1=PrefixUse;
            	PrefixUse2=PrefixUse1.substring(0,3);
                PrefixShowing=PrefixInput;                                      //System.debug('Fail123aaaa');
				dummyBRD = initBybrandRegionD();
            } 
             
            return dummyBRD; 
        } 
        set; 
    }
    
  /*  public Boolean dummyVar { 
        get { 
            if (dummyVar != true) {
                PrefixUse=PrefixInput;
                PrefixUse1=PrefixUse;
            	PrefixUse2=PrefixUse1.substring(0,3);
                dummyVar = init();
                PrefixShowing=PrefixUse;
            } 
            return dummyVar; 
        } 
        set; 
    }*/
     public Boolean dummyVarTHK { //get start in ASI_MFM_TH_Budgets_THK_PDF_Component
        get { 
            if (dummyVarTHK != true) 
            {
                PrefixUse=PrefixInput;
                PrefixUse1=PrefixUse;
            	PrefixUse2=PrefixUse1.substring(0,3);
                //dummyVarTHK = init();
                dummyVarTHK = initNotRegion();
                PrefixShowing=PrefixUse;
            } 
            return dummyVarTHK; 
        } 
        set; 
    }
   
    public ASI_MFM_TH_Budgets_PDF_PageController(){}
    public ASI_MFM_TH_Budgets_PDF_PageController(apexpages.standardController sc) {}//public void setcurrentHeaderId (String s) {currentHeaderId = s;}//public String getcurrentHeaderId() {return currentHeaderId;}
    public class showingdata{  //New structure including Plan and Budget details. Showing data in PDF 
        public String Percent{get;set;}  // show "%" in the Page 
        public String Sub_brand_Code {get;set;}   // Sub Brand Name
        public String BrandName {get;set;}
        public String BrandGroup {get;set;}                    //for Brand Grouping use          //public String TotalBrandName {get;set;}
        public Integer sequence {get;set;}                    /*Use for general sequence */
        public Integer SortSeq {get;set;}                   //public Integer Regionsequence {get;set;} /*Use for By Region Order sequence */
        public Integer Brandsequence {get;set;}
        public Integer RegionSortSequence  {get;set;}
        public String PlanId {get;set;}   //Plan
        public String Plan {get;set;}       // Plan Name
        public String PlanName {get;set;}  // Plan Line items name
        public String Plan_Name_sys {get;set;} 
        public Decimal PlanAmount {get;set;}
        public Decimal TotalPlan4Brand  {get;set;} //Total plan amount  for same brand
        public String PlanDescription {get;set;}
        public String CustomerName {get;set;} //store Plan Line item Customer Name
        public String AC_Code {get;set;}     // AC CODE for later use
        public Decimal POLAmount {get;set;}
        public Decimal PYLAmount {get;set;}    //Payment Amount
        public Decimal budgetAmount {get;set;} //Budget
        public Decimal OriginalAmount {get;set;}   // Budget have 5 values
        public Decimal EAmount {get;set;} 
        public Decimal LE1Amount {get;set;}   //
        public Decimal LE2Amount {get;set;}    //
        public Decimal LE3Amount {get;set;}          
        public Decimal LE4Amount {get;set;}               // public Integer InvalidBudget{get;set;} // 0 1 2 3 4 stand  for which one( Original Amount LE1 LE2 LE3 LE4 ) is available
        //public String BrandRegion_AND_Customer {get;set;}       //public String BrandDepartment{get;set;} public String FiscalYear{get;set;}
        public Decimal Diff {get;set;}  //Budget- Plan
        public Decimal DiffPer {get;set;}            //public Decimal Variance {get;set;} //Plan- Budget         public Decimal Var_Precent {get;set;} (Plan- Budget)/Budget
        public String Region{get;set;}          // Region Name
        //public String RegionBK{get;set;}                        //public String BudgetType{get;set;}
        public Decimal PODiff {get;set;}              // For each PO LINE items, Budget - PO
        public Decimal PODiffPer {get;set;}
        public Decimal PYLDiff {get;set;}
        //Brand Grouping
        //public Decimal PODiff_BrandG {get;set;}              // For each PO LINE items, Budget - PO
        //public Decimal PODiffPer_BrandG  {get;set;}
        //public Decimal PYLDiff_BrandG  {get;set;}
        
        
        //public Decimal PYLDiffPer {get;set;}
        //public Boolean Isstore {get;set;} // Check whether is Store in other data structure 
        public showingdata(){} 
    }
    public List<showingdata> currentMerge{get;set;}    /*     public showingdata[] currentMerge{get;set;}   */    /*     For MT use  currentMerge is the data which is in ASI_MFM_Plan_Line_Item__c and also in ASI_MFM_Budget__c      */
    public List<showingdata> ALLBrand{get;set;} 
    public List<showingdata> ALLBrandG{get;set;} 
    public List<showingdata> PLI_not_inB{get;set;}       /*  public List<showingdata> B_notinPLI{get;set;}     B_notinPLI is data in ASI_MFM_Budget__c(B) but not in in ASI_MFM_Plan_Line_Item__c(PLI) by brand only  */
    public List<showingdata> currentMergeTHH{get;set;}//public List<showingdata> MergeByRegion{get;set;}  /* MergeByRegion is sorted by region    */
    public List<showingdata> PLI_not_inB_THH{get;set;} /*   PLI_not_inB_THH   is data in ASI_MFM_Plan_Line_Item__c(PLI) but not in ASI_MFM_Budget__c(B) by brand and region order           */
      
    public String BudgetTypeSet {get;set;} 
    
    public boolean initBybrandRegionD(){
        
        Map<String,Map<String,Map<string,decimal>>> Budget_Map = new Map<String,Map<String,Map<string,decimal>>>();
            
        currentMergeTHH=new List<showingdata>();                    //MergeByRegion=new List<showingdata>();
        PLI_not_inB_THH=new List<showingdata>();                   //B_notinPLI=new List<showingdata>();
        TotalBudgetAmount=0;TotalPlanAmount=0;TotalOriginalAmount=0.01;TotalEAmount=0; //  Initialization  of amount ,amount can not be null
        // Get Data from Budget, Plan Line items, PO Line items, Payment Line items object 
        for (ASI_MFM_Budget_Setting__c Setting : ASI_MFM_Budget_Setting__c.getAll().values()) {
            if(Setting.name == 'TH'){
                BudgetTypeSet= Setting.ASI_MFM_Budget_Type__c;
                NowBudgetString=Setting.ASI_MFM_Budget_Type__c; 
            }
        }            
        budgetItem = [select id,ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.ASI_MFM_Brand_Grouping__c,ASI_MFM_Type__c,ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.name,ASI_MFM_Fiscal_Year__c,ASI_MFM_Sub_brand_Code__c,ASI_MFM_Sub_brand_Code__r.name,ASI_MFM_P1_Amount__c, ASI_MFM_P2_Amount__c,ASI_MFM_P3_Amount__c,ASI_MFM_P4_Amount__c,ASI_MFM_P5_Amount__c, ASI_MFM_P6_Amount__c,ASI_MFM_P7_Amount__c, ASI_MFM_P8_Amount__c,ASI_MFM_P9_Amount__c, ASI_MFM_P10_Amount__c,ASI_MFM_P11_Amount__c,ASI_MFM_P12_Amount__c,ASI_MFM_Total_Amount__c,ASI_MFM_Region_AND_Customer__c,ASI_MFM_Department__c 
                      from ASI_MFM_Budget__c 
                      where  ASI_MFM_Department__c Like :'%'+PrefixUse2+'%' AND (ASI_MFM_Type__c='Budget' or ASI_MFM_Type__c=:BudgetTypeSet)
                      AND ASI_MFM_Fiscal_Year__c=:FiscalYearNum order by ASI_MFM_Region_AND_Customer__c,ASI_MFM_Sub_brand_Code__r.name];   //  ASI_MFM_Type__c   /* Get data from  ASI_MFM_Budget__c  */
        // Get Plan Line Items
        PlanlineItem = [select id,ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.ASI_MFM_Brand_Grouping__c,ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.name,ASI_MFM_A_C_Code__r.name,ASI_MFM_Plan__r.Name,ASI_MFM_TH_Region__c,ASI_MFM_Plan__r.ASI_MFM_Prefix__r.name,ASI_MFM_Plan__r.ASI_MFM_Prefix__r.ASI_MFM_Department__c,Name,ASI_MFM_Sub_brand_Code__r.name,ASI_MFM_Total_Cost__c,ASI_MFM_Customer_Name__r.name,ASI_MFM_Plan_Name_sys__c,ASI_MFM_List_Item_Description__c,ASI_MFM_Month_1_Cost__c,ASI_MFM_Month_2_Cost__c,ASI_MFM_Month_3_Cost__c,ASI_MFM_Month_4_Cost__c,ASI_MFM_Month_5_Cost__c,ASI_MFM_Month_6_Cost__c,ASI_MFM_Month_7_Cost__c,ASI_MFM_Month_8_Cost__c,ASI_MFM_Month_9_Cost__c,ASI_MFM_Month_10_Cost__c,ASI_MFM_Month_11_Cost__c,ASI_MFM_Month_12_Cost__c 
                        from ASI_MFM_Plan_Line_Item__c
                        where ASI_MFM_Plan__r.ASI_MFM_Prefix__r.name Like :'%'+PrefixUse+'%' And ASI_MFM_Sub_brand_Code__r.name!=null AND ASI_MFM_Total_Cost__c!=null
                        order by ASI_MFM_TH_Region__c,ASI_MFM_Sub_brand_Code__r.name, ASI_MFM_Plan__r.Name,ASI_MFM_Total_Cost__c desc ];  //Get Plan Line Item data
        POlineItem = [select id,ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.ASI_MFM_Brand_Grouping__c,ASI_MFM_TH_Region__c,ASI_MFM_PO__r.Name,ASI_MFM_Amount__c,ASI_MFM_List_Item_Description__c,ASI_MFM_Sub_brand_Code__r.name,Name,ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.Name,ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c 
                      from ASI_MFM_PO_Line_Item__c where ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Prefix__r.name Like :'%'+PrefixUse+'%' order by ASI_MFM_TH_Region__c,ASI_MFM_Sub_brand_Code__r.name];
        paymentLineList =[select id,ASI_MFM_PO_Line_Item__r.ASI_MFM_TH_Region__c,ASI_MFM_Payment_Amount__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.name,Name,ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c, ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.Name,ASI_MFM_Payment_List_Item_Description__c, ASI_MFM_PO_Line_Item__r.ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c 
                          from ASI_MFM_Payment_Line_Item__c where ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Prefix__r.name Like :'%'+PrefixUse+'%'  order by ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.name]; 

        TotalPOLAmount =0;TotalPYLAmount =0;TotalOriginal=0;TotalLE1=0;TotalLE2=0;TotalLE3=0;TotalLE4=0; // Initialization of calculation
       /* String TestSameBrand;
        String TestSameRegion;    
        
        for(Integer countn = 0; countn < ALLBrand.size(); countn++){    // calculate the total Budget PO and Payment amount in Total report
            if(ALLBrand[countn].OriginalAmount!=null && ALLBrand[countn].OriginalAmount!=0){TotalOriginal=TotalOriginal+ALLBrand[countn].OriginalAmount;}
            if(ALLBrand[countn].LE1Amount!=null && ALLBrand[countn].LE1Amount!=0){TotalLE1=TotalLE1+ALLBrand[countn].LE1Amount;} 
            if(ALLBrand[countn].LE2Amount!=null && ALLBrand[countn].LE2Amount!=0){TotalLE2=TotalLE2+ALLBrand[countn].LE2Amount;}
            if(ALLBrand[countn].LE3Amount!=null && ALLBrand[countn].LE3Amount!=0){TotalLE3=TotalLE3+ALLBrand[countn].LE3Amount;}
            if(ALLBrand[countn].LE4Amount!=null && ALLBrand[countn].LE4Amount!=0){TotalLE4=TotalLE4+ALLBrand[countn].LE4Amount;}
            if(ALLBrand[countn].POLAmount!=null && ALLBrand[countn].POLAmount!=0){TotalPOLAmount=TotalPOLAmount+ALLBrand[countn].POLAmount;}
            if(ALLBrand[countn].PYLAmount!=null && ALLBrand[countn].PYLAmount!=0){TotalPYLAmount=TotalPYLAmount+ALLBrand[countn].PYLAmount;}
        } */
        Integer countNum = 0;
        Integer countNum_notinB = 0;                                            //Integer countNum_notinPlan = 0;

       
// New-------------------------------        
        for(ASI_MFM_Budget__c buli : budgetItem){
            if (!Budget_Map.containsKey(buli.ASI_MFM_Type__c)){
                Map<string, decimal> tmpMap1 = new Map<string, decimal>();
                Map<string, Map<string, decimal>> tmpMap2 = new Map<string, Map<string, decimal>>();
                tmpMap1.put(buli.ASI_MFM_Sub_brand_Code__r.name,buli.ASI_MFM_Total_Amount__c);
                tmpMap2.put(buli.ASI_MFM_Region_AND_Customer__c, tmpMap1);
                Budget_Map.put(buli.ASI_MFM_Type__c, tmpMap2);
            }
            else{
                if (!Budget_Map.get(buli.ASI_MFM_Type__c).containsKey(buli.ASI_MFM_Region_AND_Customer__c)){
                    Map<string, decimal> tmpMap1 = new Map<string, decimal>();
                    tmpMap1.put(buli.ASI_MFM_Sub_brand_Code__r.name,buli.ASI_MFM_Total_Amount__c);
                    Budget_Map.get(buli.ASI_MFM_Type__c).put(buli.ASI_MFM_Region_AND_Customer__c, tmpMap1);
                }
                else{
                    Budget_Map.get(buli.ASI_MFM_Type__c).get(buli.ASI_MFM_Region_AND_Customer__c).put(buli.ASI_MFM_Sub_brand_Code__r.name,buli.ASI_MFM_Total_Amount__c);
                }
            }
        }
        budgetItem.clear();
        system.debug('BudgetTest:'+Budget_Map);
        
        for(ASI_MFM_Plan_Line_Item__c liItem:PlanlineItem){ 
            Boolean isfound=false;
            showingdata temp=new showingdata();
            temp.OriginalAmount=0;
            temp.EAmount=0;
            if(Budget_Map.containsKey('Budget')){
                if(Budget_Map.get('Budget').containsKey(liItem.ASI_MFM_TH_Region__c)){
                    if(Budget_Map.get('Budget').get(liItem.ASI_MFM_TH_Region__c).containsKey(liItem.ASI_MFM_Sub_brand_Code__r.name)){
                        if(Budget_Map.get('Budget').get(liItem.ASI_MFM_TH_Region__c).get(liItem.ASI_MFM_Sub_brand_Code__r.name)>0){
                            temp.OriginalAmount=Budget_Map.get('Budget').get(liItem.ASI_MFM_TH_Region__c).get(liItem.ASI_MFM_Sub_brand_Code__r.name);
                            isfound=true;
                        }
                    }
                }
            }
            if(Budget_Map.containsKey(BudgetTypeSet) && BudgetTypeSet!='Budget'){
                if(Budget_Map.get(BudgetTypeSet).containsKey(liItem.ASI_MFM_TH_Region__c)){
                    if(Budget_Map.get(BudgetTypeSet).get(liItem.ASI_MFM_TH_Region__c).containsKey(liItem.ASI_MFM_Sub_brand_Code__r.name)){
                        if(Budget_Map.get(BudgetTypeSet).get(liItem.ASI_MFM_TH_Region__c).get(liItem.ASI_MFM_Sub_brand_Code__r.name)>0){
                            temp.EAmount=Budget_Map.get(BudgetTypeSet).get(liItem.ASI_MFM_TH_Region__c).get(liItem.ASI_MFM_Sub_brand_Code__r.name);
                            isfound=true;
                        }
                    }
                }
            }
            if(liItem.ASI_MFM_Total_Cost__c!=null){ temp.PlanAmount=liItem.ASI_MFM_Total_Cost__c; }else{temp.PlanAmount=0;}
            temp.Sub_brand_Code=liItem.ASI_MFM_Sub_brand_Code__r.name; // add another details
            temp.BrandName=liItem.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.name;
            temp.AC_Code=liItem.ASI_MFM_A_C_Code__r.name;
            temp.PlanName=liItem.Name;
            temp.PlanDescription=liItem.ASI_MFM_List_Item_Description__c;
            temp.CustomerName=liItem.ASI_MFM_Customer_Name__r.name;
            temp.Region=liItem.ASI_MFM_TH_Region__c;
            temp.Plan=liItem.ASI_MFM_Plan_Name_sys__c;
            temp.PlanId=liItem.ASI_MFM_Plan__r.Name; 
            if(isfound){
                countNum++;
                temp.sequence=countNum;
                currentMergeTHH.add(temp); 
            }else{  // Not Found, add them to another place
                countNum_notinB++;
                temp.sequence=countNum_notinB;
                temp.PlanAmount=liItem.ASI_MFM_Total_Cost__c;
                temp.PlanName=liItem.Name;
                temp.PlanDescription=liItem.ASI_MFM_List_Item_Description__c;
                temp.Plan_Name_sys=liItem.ASI_MFM_Plan_Name_sys__c;
                temp.Sub_brand_Code=liItem.ASI_MFM_Sub_brand_Code__r.name;
                temp.CustomerName=liItem.ASI_MFM_Customer_Name__r.name;
                temp.Region=liItem.ASI_MFM_TH_Region__c;
                PLI_not_inB_THH.add(temp);
            } 
            Prefixdept=liItem.ASI_MFM_Plan__r.ASI_MFM_Prefix__r.ASI_MFM_Department__c;
        }
        
        /////End
        
        // By Sub Brand
        //
        /*
        for(ASI_MFM_Plan_Line_Item__c liItem:PlanlineItem){                     // For each Plan Line Items ,check if it is in the budget
            Boolean isfound=false;
            showingdata temp=new showingdata(); 
            for(ASI_MFM_Budget__c buli : budgetItem){
                String line=liItem.ASI_MFM_Sub_brand_Code__r.name;
                String Budget=buli.ASI_MFM_Sub_brand_Code__r.name;   //GBKK   UPC   STH   WS
                line=line.replaceALL('-', '');
                line=line.replaceALL(' ', '');
                Budget=Budget.replaceALL('-', '');
                Budget=Budget.replaceALL(' ', ''); 
                if(line.equalsIgnoreCase(Budget)  && buli.ASI_MFM_Region_AND_Customer__c == liItem.ASI_MFM_TH_Region__c && buli.ASI_MFM_Total_Amount__c>0 && liItem.ASI_MFM_Total_Cost__c!=null){  // In the budget 
                    if(buli.ASI_MFM_Type__c.contains('Budget')){                                                        // record all of the budget from Original Budget ,LE1 TO LE4     buli.ASI_MFM_Type__c=='Original Budget'
                        if(temp.OriginalAmount==null){temp.OriginalAmount=0;}
                        temp.OriginalAmount=temp.OriginalAmount+buli.ASI_MFM_Total_Amount__c; // add them together
                        isfound=true;
                    }
                    if(buli.ASI_MFM_Type__c=='LE1'){
                        if(temp.LE1Amount==null){temp.LE1Amount=0;}
                        temp.LE1Amount=temp.LE1Amount+buli.ASI_MFM_Total_Amount__c;
                        isfound=true;
                    }
                    if(buli.ASI_MFM_Type__c=='LE2'){
                        if(temp.LE2Amount==null){temp.LE2Amount=0;}
                        temp.LE2Amount=temp.LE2Amount+buli.ASI_MFM_Total_Amount__c;
                        isfound=true;
                    }
                    if(buli.ASI_MFM_Type__c=='LE3'){
                        if(temp.LE3Amount==null){temp.LE3Amount=0;}
                        temp.LE3Amount=temp.LE3Amount+buli.ASI_MFM_Total_Amount__c;
                        isfound=true;
                    }
                    if(buli.ASI_MFM_Type__c=='LE4'){
                        if(temp.LE4Amount==null){temp.LE4Amount=0;}
                        temp.LE4Amount=temp.LE4Amount+buli.ASI_MFM_Total_Amount__c;
                        isfound=true;
                    }
                    temp.Sub_brand_Code=buli.ASI_MFM_Sub_brand_Code__r.name; // add another details
                    temp.BrandName=liItem.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.name;
                    temp.AC_Code=liItem.ASI_MFM_A_C_Code__r.name;
                    if(liItem.ASI_MFM_Total_Cost__c!=null){ temp.PlanAmount=liItem.ASI_MFM_Total_Cost__c; }
                    temp.PlanName=liItem.Name;
                    temp.PlanDescription=liItem.ASI_MFM_List_Item_Description__c;
                    temp.CustomerName=liItem.ASI_MFM_Customer_Name__r.name;
                    temp.Region=buli.ASI_MFM_Region_AND_Customer__c;
                    temp.Plan=liItem.ASI_MFM_Plan_Name_sys__c;
                    temp.PlanId=liItem.ASI_MFM_Plan__r.Name; 
                }
            }
            if(isfound){
                countNum++;
                temp.sequence=countNum;
                currentMergeTHH.add(temp); 
            }else{  // Not Found, add them to another place
                countNum_notinB++;
                temp.sequence=countNum_notinB;
                temp.PlanAmount=liItem.ASI_MFM_Total_Cost__c;
                temp.PlanName=liItem.Name;
                temp.PlanDescription=liItem.ASI_MFM_List_Item_Description__c;
                temp.Plan_Name_sys=liItem.ASI_MFM_Plan_Name_sys__c;
                temp.Sub_brand_Code=liItem.ASI_MFM_Sub_brand_Code__r.name;
                temp.CustomerName=liItem.ASI_MFM_Customer_Name__r.name;
                temp.Region=liItem.ASI_MFM_TH_Region__c;
                PLI_not_inB_THH.add(temp);
            } 
            Prefixdept=liItem.ASI_MFM_Plan__r.ASI_MFM_Prefix__r.ASI_MFM_Department__c;
        }
        showingdata tempData2=new showingdata();
        for(Integer countn =currentMergeTHH.size()-1; countn>0; countn--){
            for(Integer num = 0; num < countn; num++){
                if(currentMergeTHH[num].Region==currentMergeTHH[countn].Region && currentMergeTHH[num].TotalPlan4Brand <=currentMergeTHH[countn].TotalPlan4Brand){
                    tempData2=currentMergeTHH[countn];
                    currentMergeTHH[countn]=currentMergeTHH[num];
                    currentMergeTHH[num]=tempData2; 
                }
            }
        }
        */
        Calculation(currentMergeTHH);             //CalculateVariance(currentMergeTHH);   //CalculateVariance(MergeByRegion)
		DeleteRedundant(currentMergeTHH);  		//DeleteRedundantBR(currentMergeTHH);                           //Calculation(MergeByRegion);
        return true;
    }
    
    public class SummaryObject1{
        public Decimal TotalAmt { get; private set; }
        public String Name { get; private set; }
        public SummaryObject1(AggregateResult ar) {
            TotalAmt = (Decimal) ar.get('TotalAmount');
            Name = (String) ar.get('SBrand');
           
        }
    }
    
    public class SummaryObject{
        public Decimal TotalAmt { get; private set; }
        public String Name { get; private set; }
        public String Name2 { get; private set; }
        public SummaryObject(AggregateResult ar) {
            TotalAmt = (Decimal) ar.get('TotalAmount');
            Name = (String) ar.get('SBrand');
            Name2=(String) ar.get('Name2');
        }
    }
    
    public class SummaryObject3{
        public Decimal TotalAmt { get; private set; }
        public String Name { get; private set; }
        public String Name2 { get; private set; }
        public String Name3 { get; private set; }
        public SummaryObject3(AggregateResult ar) {
            TotalAmt = (Decimal) ar.get('TotalAmount');
            Name = (String) ar.get('SBrand');
            Name2=(String) ar.get('Name2');
            Name3=(String) ar.get('Name3');
        }
    }
    
    
    
    public boolean initNotRegion(){
        // Not inclucing Region
        for (ASI_MFM_Budget_Setting__c Setting : ASI_MFM_Budget_Setting__c.getAll().values()) {
            if(Setting.name == 'TH'){
                BudgetTypeSet= Setting.ASI_MFM_Budget_Type__c;
                NowBudgetString=Setting.ASI_MFM_Budget_Type__c; 
            }
        }
        Map<String,Map<string,decimal>> Budget_Map= New Map<String,Map<string,decimal>>();
        Map<string,decimal> PO_Map=new Map<string,decimal>();
        Map<string,decimal> Pay_Map=new Map<string,decimal>();
        TotalOriginal=0;
        TotalEAmount=0;
        TotalPlanAmount=0;
        TotalPODiff=0;
        TotalPODiffPer=0;
        TotalPOLAmount=0;
        TotalPYLAmount=0;
        TotalPLYDiff=0;
        //Budget
        AggregateResult[] groupedBudget=[select ASI_MFM_Sub_brand_Code__r.name SBrand, ASI_MFM_Type__c name2, sum(ASI_MFM_Total_Amount__c) TotalAmount from ASI_MFM_Budget__c where ASI_MFM_Total_Amount__c>0 and ASI_MFM_Department__c Like :'%'+PrefixUse2+'%' and RecordType.DeveloperName LIKE 'ASI_MFM_TH%' AND ASI_MFM_Fiscal_Year__c=:FiscalYearNum group by ASI_MFM_Sub_brand_Code__r.name,ASI_MFM_Type__c];
        for (AggregateResult ar : groupedBudget) {
            SummaryObject temp=new SummaryObject(ar);
            if (!Budget_Map.containsKey(temp.Name2)){
                Map<string, decimal> tmpMap1 = new Map<string, decimal>();
                tmpMap1.put(temp.Name,temp.TotalAmt);
                Budget_Map.put(temp.Name2, tmpMap1);
            }else{
                Budget_Map.get(temp.Name2).put(temp.Name,temp.TotalAmt);
            }
        }
        groupedBudget.clear();
        AggregateResult[] groupedPlanDetails= [select ASI_MFM_Sub_brand_Code__r.name SBrand,ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.ASI_MFM_Brand_Grouping__c Name2,sum(ASI_MFM_Total_Cost__c) TotalAmount from ASI_MFM_Plan_Line_Item__c where ASI_MFM_Plan__r.ASI_MFM_Prefix__r.name Like :'%'+PrefixUse+'%' And ASI_MFM_Sub_brand_Code__r.name!=null AND ASI_MFM_Total_Cost__c!=null AND RecordType.DeveloperName LIKE 'ASI_MFM_TH_Plan%' group by ASI_MFM_Sub_brand_Code__r.name,ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.ASI_MFM_Brand_Grouping__c order by ASI_MFM_Sub_brand_Code__r.name];
        AggregateResult[] groupedPO= [select ASI_MFM_Sub_brand_Code__r.name SBrand,sum(ASI_MFM_Amount__c) TotalAmount from ASI_MFM_PO_Line_Item__c where ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Prefix__r.name Like :'%'+PrefixUse+'%' And ASI_MFM_Sub_brand_Code__r.name!=null AND RecordType.DeveloperName LIKE 'ASI_MFM_TH_PO%' group by ASI_MFM_Sub_brand_Code__r.name order by ASI_MFM_Sub_brand_Code__r.name ];
        for (AggregateResult ar : groupedPO) {
            SummaryObject1 temp=new SummaryObject1(ar);
            if(temp.TotalAmt!=null){
                PO_Map.put(temp.Name,temp.TotalAmt);
            }
        }
        groupedPO.clear();
        AggregateResult[] groupedPayment= [select ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.name SBrand,sum(ASI_MFM_Payment_Amount__c) TotalAmount from ASI_MFM_Payment_Line_Item__c where ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Prefix__r.name Like :'%'+PrefixUse+'%' And ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.name!=null AND RecordType.DeveloperName LIKE 'ASI_MFM_TH_Payment%' group by ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.name order by ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.name ];
        for (AggregateResult ar : groupedPayment) {
            SummaryObject1 temp=new SummaryObject1(ar);
            if(temp.TotalAmt!=null){
                Pay_Map.put(temp.Name,temp.TotalAmt);
            }
        }
        groupedPayment.clear();
        ALLBrand=new List<showingdata>();
        
        TotalOriginal=0;
        TotalEAmount=0;
        TotalPlanAmount=0;
        TotalPODiff=0;
        TotalPODiffPer=0;
        TotalPOLAmount=0;
        TotalPYLAmount=0;
        TotalPLYDiff=0;
        Boolean isFirst=true;                //Use For One Time
        String NameRecord;
        for (AggregateResult ar : groupedPlanDetails) {
            SummaryObject temp=new SummaryObject(ar);
            showingdata tempD=new showingdata();
            if(temp.TotalAmt!=null){
                tempD.PlanAmount=temp.TotalAmt;
                TotalPlanAmount=TotalPlanAmount+tempD.PlanAmount;
            }else{
                tempD.PlanAmount=0;
            }
            tempD.BrandGroup=temp.Name2;
            tempD.BrandName=temp.Name;
            tempD.POLAmount=0;
            tempD.PYLAmount=0;
            tempD.OriginalAmount=0;
            tempD.EAmount=0;
            if(Budget_Map.containsKey('Budget')){
                if(Budget_Map.get('Budget').containsKey(temp.Name)){
                    if(Budget_Map.get('Budget').get(temp.Name)>0){
                        tempD.EAmount=Budget_Map.get('Budget').get(temp.Name);
                    }  
                }
            }
            TotalOriginal=TotalOriginal+tempD.OriginalAmount;
            if(Budget_Map.containsKey(BudgetTypeSet) && BudgetTypeSet!='Budget'){
                if(Budget_Map.get(BudgetTypeSet).containsKey(temp.Name)){
                    tempD.EAmount=Budget_Map.get(BudgetTypeSet).get(temp.Name);
                }
            }
            TotalEAmount=TotalEAmount+tempD.EAmount;
            if(PO_Map.containsKey(temp.Name)){
                tempD.POLAmount=PO_Map.get(temp.Name);
                if(tempD.POLAmount!=null){TotalPOLAmount=TotalPOLAmount+tempD.POLAmount;}
            }
            if(BudgetTypeSet!='Budget'){
                tempD.PODiff=tempD.EAmount-tempD.POLAmount;
                if(tempD.EAmount>0){
                    tempD.PODiffPer=(tempD.PODiff/tempD.EAmount)*100;
                }
            }else{
                tempD.PODiff=tempD.EAmount-tempD.POLAmount;
               if(tempD.OriginalAmount>0){
                    tempD.PODiffPer=(tempD.PODiff/tempD.OriginalAmount)*100;
               }
            }
            if(Pay_Map.containsKey(temp.Name)){
                tempD.PYLAmount=Pay_Map.get(temp.Name);
                if(tempD.PYLAmount!=null){TotalPYLAmount=TotalPYLAmount+tempD.PYLAmount;}
            }
            tempD.PYLDiff=tempD.POLAmount-tempD.PYLAmount;
            
            if(isFirst && tempD.BrandName!=null){
                NameRecord=temp.Name2;
                ALLBrand.add(tempD); 
                isFirst=false;
            }else{
                if(tempD.BrandName!=null){
                    if(NameRecord==tempD.BrandGroup){
                        tempD.BrandGroup=null;
                    }else{
                        NameRecord=tempD.BrandGroup;
                    }
                    ALLBrand.add(tempD); 
                }
            }
            
        }
        
        if(BudgetTypeSet!='Budget'){
            TotalPODiff=TotalEAmount-TotalPOLAmount;
            if(TotalEAmount!=0){
                TotalPODiffPer=TotalPODiff/TotalEAmount;
            }
        }else{
            TotalPODiff=TotalOriginal-TotalPOLAmount;
            if(TotalOriginal!=0){
                TotalPODiffPer=TotalPODiff/TotalOriginal;
            }  
        }
        TotalPLYDiff=TotalPOLAmount-TotalPYLAmount;

        //-------------------------------------------------For Details------------------------------------------
        PlanlineItem = [select ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.ASI_MFM_Brand_Grouping__c,ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.name,ASI_MFM_A_C_Code__r.name,ASI_MFM_Plan__r.Name,Id,ASI_MFM_Plan__r.ASI_MFM_Prefix__r.name,ASI_MFM_Plan__r.ASI_MFM_Prefix__r.ASI_MFM_Department__c,Name,ASI_MFM_Sub_brand_Code__r.name,ASI_MFM_Total_Cost__c,ASI_MFM_Customer_Name__r.name,ASI_MFM_Plan_Name_sys__c,ASI_MFM_List_Item_Description__c,ASI_MFM_Month_1_Cost__c,ASI_MFM_Month_2_Cost__c,ASI_MFM_Month_3_Cost__c,ASI_MFM_Month_4_Cost__c,ASI_MFM_Month_5_Cost__c,ASI_MFM_Month_6_Cost__c,ASI_MFM_Month_7_Cost__c,ASI_MFM_Month_8_Cost__c,ASI_MFM_Month_9_Cost__c,ASI_MFM_Month_10_Cost__c,ASI_MFM_Month_11_Cost__c,ASI_MFM_Month_12_Cost__c 
                        from ASI_MFM_Plan_Line_Item__c where ASI_MFM_Plan__r.ASI_MFM_Prefix__r.name Like :'%'+PrefixUse+'%' And ASI_MFM_Sub_brand_Code__r.name!=null AND ASI_MFM_Total_Cost__c!=null
                        order by ASI_MFM_Sub_brand_Code__r.name ,ASI_MFM_Plan__r.Name,ASI_MFM_Total_Cost__c desc ];     // ASI_MFM_Sub_brand_Code__r.name,ASI_MFM_Plan__r.Name  
      	
        Integer countNum = 0;
        Integer countNum_notinB = 0; 
        currentMerge=new List<showingdata>();
        PLI_not_inB=new List<showingdata>();
        for(ASI_MFM_Plan_Line_Item__c liItem:PlanlineItem){ 
         Boolean isfound=false;
            showingdata temp=new showingdata();
            temp.OriginalAmount=0;
            temp.EAmount=0;
            if(Budget_Map.containsKey('Budget')){
                if(Budget_Map.get('Budget').containsKey(liItem.ASI_MFM_Sub_brand_Code__r.name)){
                    temp.OriginalAmount=Budget_Map.get('Budget').get(liItem.ASI_MFM_Sub_brand_Code__r.name);
                    isfound=true;
                }
            }
            if(Budget_Map.containsKey(BudgetTypeSet) && BudgetTypeSet!='Budget'){
                if(Budget_Map.get(BudgetTypeSet).containsKey(liItem.ASI_MFM_Sub_brand_Code__r.name)){
                    temp.EAmount=Budget_Map.get(BudgetTypeSet).get(liItem.ASI_MFM_Sub_brand_Code__r.name);
                    isfound=true;
                }
            }
            if(liItem.ASI_MFM_Total_Cost__c!=null){ temp.PlanAmount=liItem.ASI_MFM_Total_Cost__c; }else{temp.PlanAmount=0;}
            temp.Sub_brand_Code=liItem.ASI_MFM_Sub_brand_Code__r.name; // add another details
            temp.BrandName=liItem.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.name;
            temp.AC_Code=liItem.ASI_MFM_A_C_Code__r.name;
            temp.PlanName=liItem.Name;
            temp.PlanDescription=liItem.ASI_MFM_List_Item_Description__c;
            temp.CustomerName=liItem.ASI_MFM_Customer_Name__r.name;
            temp.Plan=liItem.ASI_MFM_Plan_Name_sys__c;
            temp.PlanId=liItem.ASI_MFM_Plan__r.Name; 
            if(isfound){
                countNum++;
                temp.sequence=countNum;
                currentMerge.add(temp); 
            }else{  // Not Found, add them to another place
                countNum_notinB++;
                temp.sequence=countNum_notinB;
                temp.PlanAmount=liItem.ASI_MFM_Total_Cost__c;
                temp.PlanName=liItem.Name;
                temp.PlanDescription=liItem.ASI_MFM_List_Item_Description__c;
                temp.Plan_Name_sys=liItem.ASI_MFM_Plan_Name_sys__c;
                temp.Sub_brand_Code=liItem.ASI_MFM_Sub_brand_Code__r.name;
                temp.CustomerName=liItem.ASI_MFM_Customer_Name__r.name;
                PLI_not_inB.add(temp);
            } 
            Prefixdept=liItem.ASI_MFM_Plan__r.ASI_MFM_Prefix__r.ASI_MFM_Department__c;
        }
        TotalBudgetAmount=0.000001;TotalPlanAmount=0; TotalOriginalAmount=0; 
        Calculation(currentMerge);             
		DeleteRedundant(currentMerge); 
        
        // -------------------------------------Details End------------------------------------------
        return true;
    }
    
    
    
    public boolean initBybrandandRegion(){
        for (ASI_MFM_Budget_Setting__c Setting : ASI_MFM_Budget_Setting__c.getAll().values()) {
            if(Setting.name == 'TH'){
                BudgetTypeSet= Setting.ASI_MFM_Budget_Type__c;
                NowBudgetString=Setting.ASI_MFM_Budget_Type__c; 
            }
        }
        Map<String,Map<String,Map<string,decimal>>> Budget_Map = new Map<String,Map<String,Map<string,decimal>>>();
        Map<String,Map<string,decimal>> PO_Map = new Map<String,Map<string,decimal>>();
        Map<String,Map<string,decimal>> Pay_Map = new Map<String,Map<string,decimal>>();
        TotalOriginal=0;
        TotalEAmount=0;
        TotalPlanAmount=0;
        TotalPODiff=0;
        TotalPODiffPer=0;
        TotalPOLAmount=0;
        TotalPYLAmount=0;
        TotalPLYDiff=0;
       budgetItem = [select id,ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.ASI_MFM_Brand_Grouping__c,ASI_MFM_Type__c,ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.name,ASI_MFM_Fiscal_Year__c,ASI_MFM_Sub_brand_Code__c,ASI_MFM_Sub_brand_Code__r.name,ASI_MFM_P1_Amount__c, ASI_MFM_P2_Amount__c,ASI_MFM_P3_Amount__c,ASI_MFM_P4_Amount__c,ASI_MFM_P5_Amount__c, ASI_MFM_P6_Amount__c,ASI_MFM_P7_Amount__c, ASI_MFM_P8_Amount__c,ASI_MFM_P9_Amount__c, ASI_MFM_P10_Amount__c,ASI_MFM_P11_Amount__c,ASI_MFM_P12_Amount__c,ASI_MFM_Total_Amount__c,ASI_MFM_Region_AND_Customer__c,ASI_MFM_Department__c 
                      from ASI_MFM_Budget__c 
                      where  ASI_MFM_Department__c Like :'%'+PrefixUse2+'%' AND (ASI_MFM_Type__c='Budget' or ASI_MFM_Type__c=:BudgetTypeSet)
                      AND ASI_MFM_Fiscal_Year__c=:FiscalYearNum order by ASI_MFM_Region_AND_Customer__c,ASI_MFM_Sub_brand_Code__r.name]; 
        
        for(ASI_MFM_Budget__c buli : budgetItem){
            if (!Budget_Map.containsKey(buli.ASI_MFM_Type__c)){
                Map<string, decimal> tmpMap1 = new Map<string, decimal>();
                Map<string, Map<string, decimal>> tmpMap2 = new Map<string, Map<string, decimal>>();
                tmpMap1.put(buli.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.name,buli.ASI_MFM_Total_Amount__c);
                tmpMap2.put(buli.ASI_MFM_Region_AND_Customer__c, tmpMap1);
                Budget_Map.put(buli.ASI_MFM_Type__c, tmpMap2);
            }
            else{
                if (!Budget_Map.get(buli.ASI_MFM_Type__c).containsKey(buli.ASI_MFM_Region_AND_Customer__c)){
                    Map<string, decimal> tmpMap1 = new Map<string, decimal>();
                    tmpMap1.put(buli.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.name,buli.ASI_MFM_Total_Amount__c);
                    Budget_Map.get(buli.ASI_MFM_Type__c).put(buli.ASI_MFM_Region_AND_Customer__c, tmpMap1);
                }
                else{
                    Budget_Map.get(buli.ASI_MFM_Type__c).get(buli.ASI_MFM_Region_AND_Customer__c).put(buli.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.name,buli.ASI_MFM_Total_Amount__c);
                }
            }           
        }
        budgetItem.clear();
        //Plan: By Region
        AggregateResult[] groupedResults= [select ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.name SBrand,ASI_MFM_TH_Region__c Name2,sum(ASI_MFM_Total_Cost__c) TotalAmount from ASI_MFM_Plan_Line_Item__c where ASI_MFM_Plan__r.ASI_MFM_Prefix__r.name Like :'%'+PrefixUse+'%' And ASI_MFM_Sub_brand_Code__r.name!=null AND ASI_MFM_Total_Cost__c!=null AND RecordType.DeveloperName LIKE 'ASI_MFM_TH_Plan%' group by ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.name,ASI_MFM_TH_Region__c order by ASI_MFM_TH_Region__c ];
         //PO
        AggregateResult[] groupedPO= [select ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.name SBrand,ASI_MFM_TH_Region__c Name2,sum(ASI_MFM_Amount__c) TotalAmount from ASI_MFM_PO_Line_Item__c where ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Prefix__r.name Like :'%'+PrefixUse+'%' And ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.name!=null AND RecordType.DeveloperName LIKE 'ASI_MFM_TH_PO%' group by ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.name,ASI_MFM_TH_Region__c order by ASI_MFM_TH_Region__c ];
      	for (AggregateResult ar : groupedPO) {
            SummaryObject temp=new SummaryObject(ar);
            if(!PO_Map.containsKey(temp.Name2)){
                Map<string, decimal> tmpMap1 = new Map<string, decimal>();
                tmpMap1.put(temp.Name, temp.TotalAmt);
                PO_Map.put(temp.Name2,tmpMap1);
            }else{
                PO_Map.get(temp.Name2).put(temp.Name, temp.TotalAmt);
            }
        }
        groupedPO.clear();
        //Payment
        AggregateResult[] groupedPayment= [select ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.name SBrand,ASI_MFM_PO_Line_Item__r.ASI_MFM_TH_Region__c Name2,sum(ASI_MFM_Payment_Amount__c) TotalAmount from ASI_MFM_Payment_Line_Item__c where ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Prefix__r.name Like :'%'+PrefixUse+'%' And ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.name!=null AND RecordType.DeveloperName LIKE 'ASI_MFM_TH_Payment%' group by ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.name,ASI_MFM_PO_Line_Item__r.ASI_MFM_TH_Region__c order by ASI_MFM_PO_Line_Item__r.ASI_MFM_TH_Region__c ];
      	for (AggregateResult ar : groupedPayment) {
            SummaryObject temp=new SummaryObject(ar);
            if(!Pay_Map.containsKey(temp.Name2)){
                Map<string, decimal> tmpMap1 = new Map<string, decimal>();
                tmpMap1.put(temp.Name, temp.TotalAmt);
                Pay_Map.put(temp.Name2,tmpMap1);
            }else{
                Pay_Map.get(temp.Name2).put(temp.Name, temp.TotalAmt);
            }
        }
        groupedPayment.clear();
        ALLBrand=new List<showingdata>();
        ALLBrandG=new List<showingdata>(); 
        //Loop Plan
        Boolean isFirst=true;                //Use For One Time
        String NameRecord;
        
        for (AggregateResult ar : groupedResults) {
            SummaryObject temp=new SummaryObject(ar);
            showingdata tempD=new showingdata();
            tempD.Region=temp.Name2;
            if(temp.TotalAmt!=null){
                tempD.PlanAmount=temp.TotalAmt;
                TotalPlanAmount=TotalPlanAmount+tempD.PlanAmount;
            }else{
                tempD.PlanAmount=0;
            }
            
            
            tempD.BrandName=temp.Name;
            tempD.POLAmount=0;
            tempD.PYLAmount=0;
            tempD.OriginalAmount=0;
            tempD.EAmount=0;
            //Add Budget to class
            if(Budget_Map.containsKey('Budget')){
                if(Budget_Map.get('Budget').containsKey(temp.Name2)){
                    if(Budget_Map.get('Budget').get(temp.Name2).containsKey(temp.Name)){
                        if(Budget_Map.get('Budget').get(temp.Name2).get(temp.Name)>0){
                            tempD.OriginalAmount=Budget_Map.get('Budget').get(temp.Name2).get(temp.Name);
                        }
                    }
                }
            }
            TotalOriginal=TotalOriginal+tempD.OriginalAmount;
            if(Budget_Map.containsKey(BudgetTypeSet) && BudgetTypeSet!='Budget'){
                if(Budget_Map.get(BudgetTypeSet).containsKey(temp.Name2)){
                    if(Budget_Map.get(BudgetTypeSet).get(temp.Name2).containsKey(temp.Name)){
                        if(Budget_Map.get(BudgetTypeSet).get(temp.Name2).get(temp.Name)>0){
                            tempD.EAmount=Budget_Map.get(BudgetTypeSet).get(temp.Name2).get(temp.Name);
                        }
                    }
                }
            }
            TotalEAmount=TotalEAmount+tempD.EAmount;
            //Add PO Line amount 
            if(PO_Map.containsKey(temp.Name2)){
                if(PO_Map.get(temp.Name2).containsKey(temp.Name)){
                    tempD.POLAmount=PO_Map.get(temp.Name2).get(temp.Name);
                    if(tempD.POLAmount!=null){TotalPOLAmount=TotalPOLAmount+tempD.POLAmount;}
                }
            }
            //Calculate PO line difference
            if(BudgetTypeSet!='Budget'){
                tempD.PODiff=tempD.EAmount-tempD.POLAmount;
                if(tempD.EAmount!=0){
                    tempD.PODiffPer=(tempD.PODiff/tempD.EAmount)*100;
                }
            }else{
                tempD.PODiff=tempD.EAmount-tempD.POLAmount;
                if(tempD.OriginalAmount!=0){
                    tempD.PODiffPer=(tempD.PODiff/tempD.OriginalAmount)*100;
                }
            }
            //Add Payment Line to class
            if(Pay_Map.containsKey(temp.Name2)){
                if(Pay_Map.get(temp.Name2).containsKey(temp.Name)){
                    tempD.PYLAmount=Pay_Map.get(temp.Name2).get(temp.Name);
                    if(tempD.PYLAmount!=null){TotalPYLAmount=TotalPYLAmount+tempD.PYLAmount;}
                }
            }
            //Payment Line Diiference
            tempD.PYLDiff=tempD.POLAmount-tempD.PYLAmount;
            if(isFirst){
                NameRecord=temp.Name2;
                ALLBrand.add(tempD);
                isFirst=false;
            }else{
                if(tempD.Region!=null){
                    if(NameRecord==tempD.Region){
                        tempD.Region=null;
                    }else{
                        NameRecord=tempD.Region;
                    }
                    ALLBrand.add(tempD);
                }
            }
        }
        if(BudgetTypeSet!='Budget'){
            TotalPODiff=TotalEAmount-TotalPOLAmount;
            if(TotalEAmount!=0){
                TotalPODiffPer=TotalPODiff/TotalEAmount;
            }
        }else{
            TotalPODiff=TotalOriginal-TotalPOLAmount;
            if(TotalOriginal!=0){
                TotalPODiffPer=TotalPODiff/TotalOriginal;
            }  
        }
        TotalPLYDiff=TotalPOLAmount-TotalPYLAmount;
        
        ASI_MFM_Prefix__c pr=[select ASI_MFM_Department__c from ASI_MFM_Prefix__c where name=:PrefixUse and RecordType.DeveloperName LIKE 'ASI_MFM_TH%'];
        Prefixdept=pr.ASI_MFM_Department__c;
        
             
        //---------------------------------------------------------For Brand Grouping--------------------------------------------------------------------------------------------
        AggregateResult[] groupedPlan= [select ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.name SBrand,ASI_MFM_TH_Region__c Name2,ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.ASI_MFM_Brand_Grouping__c Name3,sum(ASI_MFM_Total_Cost__c) TotalAmount from ASI_MFM_Plan_Line_Item__c where ASI_MFM_Plan__r.ASI_MFM_Prefix__r.name Like :'%'+PrefixUse+'%' And ASI_MFM_Sub_brand_Code__r.name!=null AND ASI_MFM_Total_Cost__c!=null AND RecordType.DeveloperName LIKE 'ASI_MFM_TH_Plan%' group by ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.name,ASI_MFM_TH_Region__c,ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.ASI_MFM_Brand_Grouping__c order by ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.name ];
        isFirst=true;
        NameRecord=null;
        for (AggregateResult ar : groupedPlan) {
            SummaryObject3 temp=new SummaryObject3(ar);
            showingdata tempD=new showingdata();
            tempD.Region=temp.Name2;
            if(temp.TotalAmt!=null){
                tempD.PlanAmount=temp.TotalAmt;
                TotalPlanAmount=TotalPlanAmount+tempD.PlanAmount;
            }else{
                tempD.PlanAmount=0;
            }
            tempD.BrandGroup=temp.Name3;
            
            tempD.BrandName=temp.Name;
            tempD.POLAmount=0;
            tempD.PYLAmount=0;
            tempD.OriginalAmount=0;
            tempD.EAmount=0;
            //Add Budget to class
            if(Budget_Map.containsKey('Budget')){
                if(Budget_Map.get('Budget').containsKey(temp.Name2)){
                    if(Budget_Map.get('Budget').get(temp.Name2).containsKey(temp.Name)){
                        if(Budget_Map.get('Budget').get(temp.Name2).get(temp.Name)>0){
                            tempD.OriginalAmount=Budget_Map.get('Budget').get(temp.Name2).get(temp.Name);
                        }
                    }
                }
            }
            TotalOriginal=TotalOriginal+tempD.OriginalAmount;
            if(Budget_Map.containsKey(BudgetTypeSet) && BudgetTypeSet!='Budget'){
                if(Budget_Map.get(BudgetTypeSet).containsKey(temp.Name2)){
                    if(Budget_Map.get(BudgetTypeSet).get(temp.Name2).containsKey(temp.Name)){
                        if(Budget_Map.get(BudgetTypeSet).get(temp.Name2).get(temp.Name)>0){
                            tempD.EAmount=Budget_Map.get(BudgetTypeSet).get(temp.Name2).get(temp.Name);
                        }
                    }
                }
            }
            
            //Add PO Line amount 
            if(PO_Map.containsKey(temp.Name2)){
                if(PO_Map.get(temp.Name2).containsKey(temp.Name)){
                    tempD.POLAmount=PO_Map.get(temp.Name2).get(temp.Name);
                }
            }
            //Calculate PO line difference
            if(BudgetTypeSet!='Budget'){
                tempD.PODiff=tempD.EAmount-tempD.POLAmount;
                if(tempD.EAmount!=0){
                    tempD.PODiffPer=(tempD.PODiff/tempD.EAmount)*100;
                }
            }else{
                tempD.PODiff=tempD.EAmount-tempD.POLAmount;
                if(tempD.OriginalAmount!=0){
                    tempD.PODiffPer=(tempD.PODiff/tempD.OriginalAmount)*100;
                }
            }
            //Add Payment Line to class
            if(Pay_Map.containsKey(temp.Name2)){
                if(Pay_Map.get(temp.Name2).containsKey(temp.Name)){
                    tempD.PYLAmount=Pay_Map.get(temp.Name2).get(temp.Name);
                }
            }
            //Payment Line Diiference
            tempD.PYLDiff=tempD.POLAmount-tempD.PYLAmount;
            if(isFirst && tempD.BrandName!=null){
                NameRecord=temp.Name3;
                ALLBrandG.add(tempD);
                isFirst=false;
            }else{
                if(tempD.Region!=null && tempD.BrandName!=null){
                    if(NameRecord==tempD.BrandGroup){
                        tempD.BrandGroup=null;
                    }else{
                        NameRecord=tempD.BrandGroup;
                    }
                    ALLBrandG.add(tempD);
                }
            }
        }
        
 
        return true;
    }
    
    
    
    
    public void Calculation(List<showingdata> BudgetPlanALL){   /* Calculate the DIff, DiffPer,  TotalPlanAmount  :   input List type of class showingdata  */
        Boolean isFirst=true;
        Integer sameitems = 0;
        Decimal Budget=0;
        Integer sequence=0;
        for(Integer countnumber = 0; countnumber < BudgetPlanALL.size(); countnumber++){
            Boolean OnlyOne=true;
            //Find the vaild One as Budget to Calculate
            Budget=BudgetPlanALL[countnumber].EAmount;/*
            if(NowBudgetString.contains('Budget')){
                if(BudgetPlanALL[countnumber].OriginalAmount!=null){
                    Budget=BudgetPlanALL[countnumber].OriginalAmount;
                }
                
            }  // NowBudget    if(BudgetPlanALL[countnumber].InvalidBudget==0){Budget=BudgetPlanALL[countnumber].OriginalAmount;} 
            if(NowBudgetString.contains('LE1')){
                if(BudgetPlanALL[countnumber].LE1Amount!=null){
                    Budget=BudgetPlanALL[countnumber].LE1Amount;
                }
                
            }
            if(NowBudgetString.contains('LE2')){if(BudgetPlanALL[countnumber].LE2Amount!=null){Budget=BudgetPlanALL[countnumber].LE2Amount;}}
            if(NowBudgetString.contains('LE3')){if(BudgetPlanALL[countnumber].LE3Amount!=null){Budget=BudgetPlanALL[countnumber].LE3Amount;}}
            if(NowBudgetString.contains('LE4')){if(BudgetPlanALL[countnumber].LE4Amount!=null){Budget=BudgetPlanALL[countnumber].LE4Amount;}} */ 
            Boolean IsNotOnlyOne=true;
            if(isFirst==true){  //the first Time
                BudgetPlanALL[countnumber].Diff = 0;
                sequence++;
                BudgetPlanALL[countnumber].SortSeq=sequence;
                TotalPlanAmount=TotalPlanAmount+BudgetPlanALL[countnumber].PlanAmount;
                BudgetPlanALL[countnumber].Diff=Budget-BudgetPlanALL[countnumber].PlanAmount;
                if(Budget>0){BudgetPlanALL[countnumber].DiffPer=(BudgetPlanALL[countnumber].Diff/Budget)*100;}else{BudgetPlanALL[countnumber].DiffPer=0;}
                
                isFirst=false;
                BudgetPlanALL[countnumber].TotalPlan4Brand=BudgetPlanALL[countnumber].PlanAmount;
                //if(BudgetPlanALL[countnumber].LE1Amount!=null){TotalLE1Amount=TotalLE1Amount+BudgetPlanALL[countnumber].LE1Amount;}  //Calculate Total Budget Amount LE1
                //if(BudgetPlanALL[countnumber].LE2Amount!=null){TotalLE2Amount=TotalLE2Amount+BudgetPlanALL[countnumber].LE2Amount;}
                //if(BudgetPlanALL[countnumber].LE3Amount!=null){TotalLE3Amount=TotalLE3Amount+BudgetPlanALL[countnumber].LE3Amount;}
                //if(BudgetPlanALL[countnumber].LE4Amount!=null){TotalLE4Amount=TotalLE4Amount+BudgetPlanALL[countnumber].LE4Amount;}
                if(BudgetPlanALL[countnumber].OriginalAmount!=null){TotalOriginalAmount=TotalOriginalAmount+BudgetPlanALL[countnumber].OriginalAmount;}
                if(BudgetPlanALL[countnumber].EAmount!=null){TotalEAmount=TotalEAmount+BudgetPlanALL[countnumber].EAmount;}
            }else{
                if(PrefixUse.contains('THK')){
                    OnlyOne=true;
                }else{
                    OnlyOne=false;
                }
                if(BudgetPlanALL[countnumber].Sub_brand_Code==BudgetPlanALL[countnumber-1].Sub_brand_Code && OnlyOne==true){           //see if the Sub_brand_Code in current one is the same with the previous one
                    BudgetPlanALL[countnumber].SortSeq=sequence;
                    TotalPlanAmount=TotalPlanAmount+BudgetPlanALL[countnumber].PlanAmount;
                    BudgetPlanALL[countnumber].Diff=BudgetPlanALL[countnumber-1].Diff-BudgetPlanALL[countnumber].PlanAmount;        /*   will change the "Diff" and "DiffPer" in showingdata structure   */
                    BudgetPlanALL[countnumber].TotalPlan4Brand=BudgetPlanALL[countnumber-1].TotalPlan4Brand+BudgetPlanALL[countnumber].PlanAmount;
                    if(Budget>0){BudgetPlanALL[countnumber].DiffPer=(BudgetPlanALL[countnumber].Diff/Budget)*100;}else{BudgetPlanALL[countnumber].DiffPer=0;}
                    /*Update the Variance in prvious one */
                    BudgetPlanALL[countnumber-1].Diff=BudgetPlanALL[countnumber].Diff;
                    sameitems++;
                    if(sameitems>0){
                        for(Integer num=0;num<=sameitems;num++){
                            BudgetPlanALL[countnumber-num].Diff=BudgetPlanALL[countnumber].Diff;
                            if(Budget>0){BudgetPlanALL[countnumber-num].DiffPer=(BudgetPlanALL[countnumber-num].Diff/Budget)*100;}
                            
                            BudgetPlanALL[countnumber-num].TotalPlan4Brand=BudgetPlanALL[countnumber].TotalPlan4Brand;
                        }
                    }
                }else if(BudgetPlanALL[countnumber].Sub_brand_Code==BudgetPlanALL[countnumber-1].Sub_brand_Code && OnlyOne==false && BudgetPlanALL[countnumber].Region== BudgetPlanALL[countnumber-1].Region){
                    TotalPlanAmount=TotalPlanAmount+BudgetPlanALL[countnumber].PlanAmount;
                    sameitems++;
                    BudgetPlanALL[countnumber].Diff=BudgetPlanALL[countnumber-1].Diff-BudgetPlanALL[countnumber].PlanAmount;
                    BudgetPlanALL[countnumber].TotalPlan4Brand=BudgetPlanALL[countnumber-1].TotalPlan4Brand+BudgetPlanALL[countnumber].PlanAmount;
                    if(Budget>0){BudgetPlanALL[countnumber].DiffPer=(BudgetPlanALL[countnumber].Diff/Budget)*100;}else{BudgetPlanALL[countnumber].DiffPer=0;}
                    
                    BudgetPlanALL[countnumber-1].Diff=BudgetPlanALL[countnumber].Diff;
                    if(sameitems>0){/*more than one times*/ 
                         for(Integer num=0;num<=sameitems;num++){/*  Update the previous data in Diff    DiffPer    TotalPlan4Brand  */
                            BudgetPlanALL[countnumber-num].Diff=BudgetPlanALL[countnumber].Diff;
                            if(Budget>0){BudgetPlanALL[countnumber-num].DiffPer=(BudgetPlanALL[countnumber-num].Diff/Budget)*100;}
                            BudgetPlanALL[countnumber-num].TotalPlan4Brand=BudgetPlanALL[countnumber].TotalPlan4Brand;
                        }
                    }
                }else{         // if not same with the previous one
                    sequence++;
                	BudgetPlanALL[countnumber].SortSeq=sequence;                      /*Update data*/
                    TotalPlanAmount=TotalPlanAmount+BudgetPlanALL[countnumber].PlanAmount;
                    sameitems = 0;
                    BudgetPlanALL[countnumber].Diff=0;
                    BudgetPlanALL[countnumber].Diff=Budget-BudgetPlanALL[countnumber].PlanAmount;
                    if(Budget>0){BudgetPlanALL[countnumber].DiffPer=(BudgetPlanALL[countnumber].Diff/Budget)*100;}else{BudgetPlanALL[countnumber].DiffPer=0;}
               		BudgetPlanALL[countnumber].TotalPlan4Brand=BudgetPlanALL[countnumber].PlanAmount;
                    /* if(BudgetPlan_Date[countnumber].Region!=BudgetPlan_Date[countnumber-1].Region || BudgetPlan_Date[countnumber].Sub_brand_Code!=BudgetPlan_Date[countnumber-1].Sub_brand_Code){
                            TotalBudgetAmount=TotalBudgetAmount+BudgetPlan_Date[countnumber].budgetAmount;}*/
                	//if(BudgetPlanALL[countnumber].LE1Amount!=null){TotalLE1Amount=TotalLE1Amount+BudgetPlanALL[countnumber].LE1Amount;}
                   // if(BudgetPlanALL[countnumber].LE2Amount!=null){TotalLE2Amount=TotalLE2Amount+BudgetPlanALL[countnumber].LE2Amount;}
                	//if(BudgetPlanALL[countnumber].LE3Amount!=null){TotalLE3Amount=TotalLE3Amount+BudgetPlanALL[countnumber].LE3Amount;}
                	//if(BudgetPlanALL[countnumber].LE4Amount!=null){TotalLE4Amount=TotalLE4Amount+BudgetPlanALL[countnumber].LE4Amount;}
                	if(BudgetPlanALL[countnumber].OriginalAmount!=null){TotalOriginalAmount=TotalOriginalAmount+BudgetPlanALL[countnumber].OriginalAmount;}
                    if(BudgetPlanALL[countnumber].EAmount!=null){TotalEAmount=TotalEAmount+BudgetPlanALL[countnumber].EAmount;}
                }
            }
        }
        if(BudgetTypeSet!='Budget'){
            TotalDifference=TotalEAmount-TotalPlanAmount;
            if(TotalEAmount!=0){
                TotalDiffPerc=(TotalDifference/TotalEAmount)*100;
            }
            }else{
                TotalDifference=TotalOriginalAmount-TotalPlanAmount;
                if(TotalOriginalAmount!=0){
                    TotalDiffPerc=(TotalDifference/TotalOriginalAmount)*100;
                }
            }
       
        /*
        if(TotalOriginalAmount!=null &&TotalOriginalAmount!=0){
            TotalDifference=TotalOriginalAmount-TotalPlanAmount;
            TotalDiffPerc=(TotalDifference/TotalOriginalAmount)*100;
        }
        if(TotalLE1Amount!=null && TotalLE1Amount!=0){
            TotalDifference=TotalLE1Amount-TotalPlanAmount;
            TotalDiffPerc=(TotalDifference/TotalLE1Amount)*100;
        }
        if(TotalLE2Amount!=null && TotalLE2Amount!=0){  // NowBudget==2
            TotalDifference=TotalLE2Amount-TotalPlanAmount;
            TotalDiffPerc=(TotalDifference/TotalLE2Amount)*100;
        }
        if(TotalLE3Amount!=null && TotalLE3Amount!=0){
            TotalDifference=TotalLE3Amount-TotalPlanAmount;
            TotalDiffPerc=(TotalDifference/TotalLE3Amount)*100;
        }
        if(TotalLE4Amount!=null && TotalLE4Amount!=0){
            TotalDifference=TotalLE4Amount-TotalPlanAmount;
            TotalDiffPerc=(TotalDifference/TotalLE4Amount)*100;
        }*/
         if(TotalDiffPerc!=0 && TotalDiffPerc!=null){TotalDiffPercS='%';}
         
    }
    
    public void DeleteRedundant (List<showingdata> RedundantData){           //Eliminate Redundant  Data from Inputed Data tuple
        Boolean isFirst=true;                //Use For One Time
        String SubbrandCodeTemp;             //To save temporary DATA for testing Whether  match
        String PlanId;
        String PlanNAME;
        String Region;
        Decimal BudgetAmount;
        Integer Brandsequence=1;          //For sorting  sequence Use
        Integer RegionSortSequence=1;
        for(Integer countnumber = 0; countnumber < RedundantData.size(); countnumber++){
            Boolean IsSamePlan=false;
            Boolean ByPath;
            if(isFirst){    //The First Time
                isFirst=false;
                SubbrandCodeTemp=RedundantData[countnumber].Sub_brand_Code;
                BudgetAmount=RedundantData[countnumber].budgetAmount;
                PlanId=RedundantData[countnumber].PlanId;
                PlanNAME=RedundantData[countnumber].Plan;
                if(RedundantData[countnumber].DiffPer!=null){RedundantData[countnumber].Percent='%';}
                RedundantData[countnumber].Brandsequence=Brandsequence;
                Brandsequence++;
                RedundantData[countnumber].RegionSortSequence=RegionSortSequence;	
                RegionSortSequence++;
                 if(!PrefixUse.contains('THK')){
                     Region=RedundantData[countnumber].Region;
                 }
            }else{               // The Second Time or Others   Compared with previous temporary data
                if(BudgetAmount==RedundantData[countnumber].budgetAmount && SubbrandCodeTemp==RedundantData[countnumber].Sub_brand_Code && Region==RedundantData[countnumber].Region){
                    if(PrefixUse.contains('THK')){
                        ByPath=true;
                    }else{
                        if(Region==RedundantData[countnumber].Region){
                            ByPath=true;
                        }
                    }
                    if(ByPath==true){//Match,then delete the Redundant  Data
                        RedundantData[countnumber].Sub_brand_Code=null;
                    	RedundantData[countnumber].budgetAmount= null;
                        RedundantData[countnumber].EAmount= null;
                        RedundantData[countnumber].LE1Amount= null;
                        RedundantData[countnumber].LE2Amount= null;
                        RedundantData[countnumber].LE3Amount= null;
                        RedundantData[countnumber].LE4Amount= null;
                        RedundantData[countnumber].OriginalAmount= null;//RedundantData[countnumber].Variance= null;        RedundantData[countnumber].Var_Precent= null;
                        RedundantData[countnumber].diff= null;
                        RedundantData[countnumber].DiffPer= null;
                    	RedundantData[countnumber].TotalPlan4Brand= null;
                    	IsSamePlan=true;
                        if(!PrefixUse.contains('THK')){
                            RedundantData[countnumber].Region=null;
                        }
                    } 
                }else{ //If it is no match            Update data to temporary DATA
                    SubbrandCodeTemp=RedundantData[countnumber].Sub_brand_Code;  
                	BudgetAmount=RedundantData[countnumber].budgetAmount;
                    PlanId=RedundantData[countnumber].PlanId;
                	PlanNAME=RedundantData[countnumber].Plan;
                    if(RedundantData[countnumber].DiffPer!=null){RedundantData[countnumber].Percent='%';}
					System.debug('FailRedundantDataaaaa'+Region);                    
                    RedundantData[countnumber].Brandsequence=Brandsequence;
                    Brandsequence++;
                    if(!PrefixUse.contains('THK')){
                        if(Region==RedundantData[countnumber].Region){
                            RedundantData[countnumber].Region=null;
                        }else{
                            Region=RedundantData[countnumber].Region;
                            RedundantData[countnumber].RegionSortSequence=RegionSortSequence;
                            RegionSortSequence++;
                        }  
                 }
                }
                
                if(IsSamePlan){     //Eliminate Redundant  Data in Plan Name and Plan ID
                    if(RedundantData[countnumber].Plan==PlanNAME && PlanId==RedundantData[countnumber].PlanId){
                        RedundantData[countnumber].Plan=null;
                        RedundantData[countnumber].PlanId=null;
                    }else{
                        PlanNAME=RedundantData[countnumber].Plan;
                        PlanId=RedundantData[countnumber].PlanId;
                    }
                }
            }
        }
    }
    //New-----------------------------End-----------------------------------------------------
    
    
    
    
    
    
    ////////////////////////////////////////////////////   New Start  ///////////////////////////
    /*

    public boolean initBybrandRegion(){ //For THH  THP  THT   Use only  By Sub-brand                
        
        currentMergeTHH=new List<showingdata>();                    //MergeByRegion=new List<showingdata>();
        PLI_not_inB_THH=new List<showingdata>();                   //B_notinPLI=new List<showingdata>();
        ALLBrand=new List<showingdata>();    // By Brand
      	ALLBrandG=new List<showingdata>();  //By Brand Grouping
        TotalBudgetAmount=0;TotalPlanAmount=0;TotalPOAmt=0;TotalLE1Amount=0;TotalLE2Amount=0;TotalLE3Amount=0;TotalLE4Amount=0;TotalOriginalAmount=0.01; //  Initialization  of amount ,amount can not be null
        // Get Data from Budget, Plan Line items, PO Line items, Payment Line items object 
        for (ASI_MFM_Budget_Setting__c Setting : ASI_MFM_Budget_Setting__c.getAll().values()) {
            if(Setting.name == 'TH'){
                BudgetTypeSet= Setting.ASI_MFM_Budget_Type__c;
                NowBudgetString=Setting.ASI_MFM_Budget_Type__c; 
            }
        }            
        budgetItem = [select id,ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.ASI_MFM_Brand_Grouping__c,ASI_MFM_Type__c,ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.name,ASI_MFM_Fiscal_Year__c,ASI_MFM_Sub_brand_Code__c,ASI_MFM_Sub_brand_Code__r.name,ASI_MFM_P1_Amount__c, ASI_MFM_P2_Amount__c,ASI_MFM_P3_Amount__c,ASI_MFM_P4_Amount__c,ASI_MFM_P5_Amount__c, ASI_MFM_P6_Amount__c,ASI_MFM_P7_Amount__c, ASI_MFM_P8_Amount__c,ASI_MFM_P9_Amount__c, ASI_MFM_P10_Amount__c,ASI_MFM_P11_Amount__c,ASI_MFM_P12_Amount__c,ASI_MFM_Total_Amount__c,ASI_MFM_Region_AND_Customer__c,ASI_MFM_Department__c 
                      from ASI_MFM_Budget__c 
                      where  ASI_MFM_Department__c Like :'%'+PrefixUse2+'%' AND (ASI_MFM_Type__c='Budget' or ASI_MFM_Type__c=:BudgetTypeSet)
                      AND ASI_MFM_Fiscal_Year__c=:FiscalYearNum order by ASI_MFM_Region_AND_Customer__c,ASI_MFM_Sub_brand_Code__r.name];   //  ASI_MFM_Type__c Get data from  ASI_MFM_Budget__c 
        // Get Plan Line Items
        PlanlineItem = [select id,ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.ASI_MFM_Brand_Grouping__c,ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.name,ASI_MFM_A_C_Code__r.name,ASI_MFM_Plan__r.Name,ASI_MFM_TH_Region__c,ASI_MFM_Plan__r.ASI_MFM_Prefix__r.name,ASI_MFM_Plan__r.ASI_MFM_Prefix__r.ASI_MFM_Department__c,Name,ASI_MFM_Sub_brand_Code__r.name,ASI_MFM_Total_Cost__c,ASI_MFM_Customer_Name__r.name,ASI_MFM_Plan_Name_sys__c,ASI_MFM_List_Item_Description__c,ASI_MFM_Month_1_Cost__c,ASI_MFM_Month_2_Cost__c,ASI_MFM_Month_3_Cost__c,ASI_MFM_Month_4_Cost__c,ASI_MFM_Month_5_Cost__c,ASI_MFM_Month_6_Cost__c,ASI_MFM_Month_7_Cost__c,ASI_MFM_Month_8_Cost__c,ASI_MFM_Month_9_Cost__c,ASI_MFM_Month_10_Cost__c,ASI_MFM_Month_11_Cost__c,ASI_MFM_Month_12_Cost__c 
                        from ASI_MFM_Plan_Line_Item__c
                        where ASI_MFM_Plan__r.ASI_MFM_Prefix__r.name Like :'%'+PrefixUse+'%' And ASI_MFM_Sub_brand_Code__r.name!=null AND ASI_MFM_Total_Cost__c!=null
                        order by ASI_MFM_TH_Region__c,ASI_MFM_Sub_brand_Code__r.name, ASI_MFM_Plan__r.Name,ASI_MFM_Total_Cost__c desc ];  //Get Plan Line Item data
        POlineItem = [select id,ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.ASI_MFM_Brand_Grouping__c,ASI_MFM_TH_Region__c,ASI_MFM_PO__r.Name,ASI_MFM_Amount__c,ASI_MFM_List_Item_Description__c,ASI_MFM_Sub_brand_Code__r.name,Name,ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.Name,ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c 
                      from ASI_MFM_PO_Line_Item__c where ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Prefix__r.name Like :'%'+PrefixUse+'%' order by ASI_MFM_TH_Region__c,ASI_MFM_Sub_brand_Code__r.name];
        paymentLineList =[select id,ASI_MFM_PO_Line_Item__r.ASI_MFM_TH_Region__c,ASI_MFM_Payment_Amount__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.name,Name,ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c, ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.Name,ASI_MFM_Payment_List_Item_Description__c, ASI_MFM_PO_Line_Item__r.ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c 
                          from ASI_MFM_Payment_Line_Item__c where ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Prefix__r.name Like :'%'+PrefixUse+'%'  order by ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.name]; 

        String TestSameBrand;
        String TestSameRegion;
        for(ASI_MFM_Budget__c buli : budgetItem){  //  process  Budget, Plan amount, PO Amount , Payment amount Data, ignore the  Line items detail
            Boolean isfound=false;  // Flag for finding Data
            showingdata temp=new showingdata();
            temp.Region=buli.ASI_MFM_Region_AND_Customer__c;
            temp.RegionBK=buli.ASI_MFM_Region_AND_Customer__c;  //back Up use
            temp.BrandName=buli.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.name;
            temp.BrandGroup=buli.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.ASI_MFM_Brand_Grouping__c;
			temp.Sub_brand_Code=buli.ASI_MFM_Sub_brand_Code__r.name;
            temp.PlanAmount=0;
            temp.POLAmount=0;
            temp.PYLAmount=0; // Initialization  
            if(buli.ASI_MFM_Sub_brand_Code__r.name!=null){
                String Budget=buli.ASI_MFM_Sub_brand_Code__r.name;
                Budget=Budget.replaceALL('-', ''); // remove the "-"  for compare use
                Budget=Budget.replaceALL(' ', '');
                // Check in Plan
                for(ASI_MFM_Plan_Line_Item__c liItem:PlanlineItem){
                    if(liItem.ASI_MFM_Sub_brand_Code__r.name!=null){
                        String line=liItem.ASI_MFM_Sub_brand_Code__r.name;
                        line=line.replaceALL('-', '');
                        line=line.replaceALL(' ', '');
                        if(line.equalsIgnoreCase(Budget) && liItem.ASI_MFM_TH_Region__c== buli.ASI_MFM_Region_AND_Customer__c  && liItem.ASI_MFM_Total_Cost__c>0){  // Find the same region items
                            isfound=true;
                            temp.PlanAmount=temp.PlanAmount+liItem.ASI_MFM_Total_Cost__c;   // calculate the amount 
                        }  
                    }
                }
                // Check in PO
                for(ASI_MFM_PO_Line_Item__c POliItem:POlineItem){   
                    if(POliItem.ASI_MFM_Sub_brand_Code__r.name!=null){
                        String Line=POliItem.ASI_MFM_Sub_brand_Code__r.name;
                        line=line.replaceALL('-', '');
                        line=line.replaceALL(' ', '');
                        if(line.equalsIgnoreCase(Budget) && POliItem.ASI_MFM_TH_Region__c==buli.ASI_MFM_Region_AND_Customer__c && POliItem.ASI_MFM_Amount__c>0){
                            isfound=true;
                            temp.POLAmount=temp.POLAmount+POliItem.ASI_MFM_Amount__c;
                        }  
                    }
                }
                // Check in Payment
                for(ASI_MFM_Payment_Line_Item__c PYLItem:paymentLineList){  
                    
                    String Line=PYLItem.ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.name;
                    if(line!=null){
                        line=line.replaceALL('-', '');
                        line=line.replaceALL(' ', '');
                        if(line.equalsIgnoreCase(Budget) && PYLItem.ASI_MFM_PO_Line_Item__r.ASI_MFM_TH_Region__c==buli.ASI_MFM_Region_AND_Customer__c  && PYLItem.ASI_MFM_Payment_Amount__c>0){
                            isfound=true;
                            temp.PYLAmount=temp.PYLAmount+PYLItem.ASI_MFM_Payment_Amount__c;
                        } 
                    }
                }
                // Check else in Budget
                for(ASI_MFM_Budget__c budgetli : budgetItem){   // calculate the LE1-LE4 Amount
                    if(buli.ASI_MFM_Sub_brand_Code__r.name==budgetli.ASI_MFM_Sub_brand_Code__r.name && buli.ASI_MFM_Region_AND_Customer__c==budgetli.ASI_MFM_Region_AND_Customer__c){
                        if(budgetli.ASI_MFM_Type__c.contains('Budget') && budgetli.ASI_MFM_Total_Amount__c!=null ){   //     budgetli.ASI_MFM_Type__c=='Original Budget'
                            if(temp.OriginalAmount==null){temp.OriginalAmount=0; }
                            temp.OriginalAmount = temp.OriginalAmount+budgetli.ASI_MFM_Total_Amount__c;
                        }
                        if(budgetli.ASI_MFM_Type__c=='LE1' && budgetli.ASI_MFM_Total_Amount__c!=null){
                            if(temp.LE1Amount==null){temp.LE1Amount=0; }
                            temp.LE1Amount = temp.LE1Amount+budgetli.ASI_MFM_Total_Amount__c;
                        }
                        if(budgetli.ASI_MFM_Type__c=='LE2' && budgetli.ASI_MFM_Total_Amount__c!=null){
                            if(temp.LE2Amount==null){temp.LE2Amount=0; }
                            temp.LE2Amount = temp.LE2Amount+budgetli.ASI_MFM_Total_Amount__c;
                        }
                        if(budgetli.ASI_MFM_Type__c=='LE3' && budgetli.ASI_MFM_Total_Amount__c!=null ){
                            if(temp.LE3Amount==null){temp.LE3Amount=0; }
                            temp.LE3Amount = temp.LE3Amount+budgetli.ASI_MFM_Total_Amount__c;
                        }
                        if(budgetli.ASI_MFM_Type__c=='LE4' && budgetli.ASI_MFM_Total_Amount__c!=null ){
                            if(temp.LE4Amount==null){temp.LE4Amount=0; }

                            temp.LE4Amount = temp.LE4Amount+budgetli.ASI_MFM_Total_Amount__c;
                        }
                    }
                }
                if(isfound==true && (TestSameBrand!=temp.BrandName || TestSameRegion !=temp.Region) ){ // If find  success
                    TestSameBrand=temp.BrandName;
                    TestSameRegion=temp.Region;
                    ALLBrand.add(temp);
                }
            }
            
        } //MergeByRegion
        budgetItem.clear();
       

        
        for(Integer countnumber = 0; countnumber < ALLBrand.size(); countnumber++){ // remove  Redundant Line Items if it holds same region and Sub brand
            if(countnumber>0){
                if(ALLBrand[countnumber].Region==ALLBrand[countnumber-1].Region && ALLBrand[countnumber].Sub_brand_Code== ALLBrand[countnumber-1].Sub_brand_Code ){
                    ALLBrand.remove(countnumber);
                }
            }
        }
        
        DeleteRedundant(ALLBrand);// Call function to remove Redundant data
        String BrandG;
       	for(Integer countn= 0; countn< ALLBrand.size(); countn++){// Sort By Brand Grouping
           if(countn==0){   //The first time
               BrandG=ALLBrand[countn].BrandGroup;
               ALLBrandG.add(ALLBrand[countn]);
               ALLBrand[countn].Isstore=true;
           }else{ //second Or others
               if(BrandG==ALLBrand[countn].BrandGroup && ALLBrand[countn].Isstore!=true){
                   ALLBrandG.add(ALLBrand[countn]);
                   ALLBrand[countn].Isstore=true; // Flag to show this record is save
               }
               else if(ALLBrand[countn].Isstore!=true){ // different 
                   BrandG=ALLBrand[countn].BrandGroup;
                   ALLBrandG.add(ALLBrand[countn]);
                   ALLBrand[countn].Isstore=true; 
               }
           }
            for(Integer recordn= 0; recordn< ALLBrand.size(); recordn++){  // Find another items 
                if(ALLBrand[recordn].Isstore!=true && BrandG==ALLBrand[recordn].BrandGroup){  // Find the same BrandGroup 
                    ALLBrandG.add(ALLBrand[recordn]);
                    ALLBrand[recordn].Isstore=true;
                }
            }
       }
         //NO Budget case
        set<id> plan_set = new set<id>();
        for(ASI_MFM_Plan_Line_Item__c liItem:PlanlineItem){    //plan exist
            if(liItem.ASI_MFM_Sub_brand_Code__r.name!=null){
                boolean notinALLBrand=false;
                for(Integer countnumber = 0; countnumber < ALLBrand.size(); countnumber++){ 
                    if(liItem.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.name==ALLBrand[countnumber].BrandName){
                       notinALLBrand=true;
                    }
                }
                if(notinALLBrand==false && liItem.ASI_MFM_Total_Cost__c>0){
                    showingdata temp=new showingdata();
                    temp.POLAmount=0;
                    temp.PYLAmount=0;
                    temp.OriginalAmount=0;
                    temp.LE1Amount=0;
                    temp.LE2Amount=0;
                    temp.LE3Amount=0;
                    temp.LE4Amount=0;
                    for(ASI_MFM_PO_Line_Item__c POliItem:POlineItem){ 
                        if(POliItem.ASI_MFM_Sub_brand_Code__r.name==liItem.ASI_MFM_Sub_brand_Code__r.name){
                            temp.POLAmount=temp.POLAmount+POliItem.ASI_MFM_Amount__c;
                        }
                    }
                    for(ASI_MFM_Payment_Line_Item__c PYLItem:paymentLineList){  
                        if(PYLItem.ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.name==liItem.ASI_MFM_Sub_brand_Code__r.name){
                            temp.PYLAmount=temp.PYLAmount+PYLItem.ASI_MFM_Payment_Amount__c;
                        }
                    }
                    temp.BrandName=liItem.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.name;
                    temp.BrandGroup=liItem.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.ASI_MFM_Brand_Grouping__c;
                    temp.PlanAmount=liItem.ASI_MFM_Total_Cost__c;
                    for(ASI_MFM_Plan_Line_Item__c pli:PlanlineItem){
                        if(liItem.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.name==pli.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.name && liItem.id!=pli.id ){
                            temp.PlanAmount=temp.PlanAmount+pli.ASI_MFM_Total_Cost__c;
                            plan_set.add(pli.id);
                        }
                    }
                    if(!plan_set.contains(liItem.id)){
                        ALLBrandG.add(temp);
                        plan_set.add(liItem.id);
                    } 
                }
            }      
        }
         PlanlineItem.clear();
         set<id> po_set = new set<id>();
        for(ASI_MFM_PO_Line_Item__c POliItem:POlineItem){ 
            if(POliItem.ASI_MFM_Sub_brand_Code__r.name!=null){
                boolean notinALLBrand=false;
                for(Integer countnumber = 0; countnumber < ALLBrandG.size(); countnumber++){ 
                    if(POliItem.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.name==ALLBrandG[countnumber].BrandName){
                       notinALLBrand=true;
                    }
                }
                if(notinALLBrand==false){
                    showingdata temp=new showingdata();
                    temp.PlanAmount=0;
                    temp.PYLAmount=0;
                    temp.OriginalAmount=0;
                    temp.LE1Amount=0;
                    temp.LE2Amount=0;
                    temp.LE3Amount=0;
                    temp.LE4Amount=0;
                    for(ASI_MFM_Payment_Line_Item__c PYLItem:paymentLineList){  
                        if(PYLItem.ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.name==POliItem.ASI_MFM_Sub_brand_Code__r.name){
                            temp.PYLAmount=temp.PYLAmount+PYLItem.ASI_MFM_Payment_Amount__c;
                        }
                    }
                    temp.BrandName=POliItem.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.name;
                    temp.BrandGroup=POliItem.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.ASI_MFM_Brand_Grouping__c;
                    temp.POLAmount=POliItem.ASI_MFM_Amount__c;
                    for(ASI_MFM_PO_Line_Item__c poli:POlineItem){ 
                       if(POliItem.ASI_MFM_Sub_brand_Code__r.name==poli.ASI_MFM_Sub_brand_Code__r.name && POliItem.id!=poli.id ){
                            temp.POLAmount=temp.POLAmount+poli.ASI_MFM_Amount__c;
                            po_set.add(poli.id);
                        }
                    }
                    
                    if(!po_set.contains(POliItem.id)){
                        ALLBrandG.add(temp);
                        po_set.add(POliItem.id);
                    } 
                    
                }
            }
        }
      
                POlineItem.clear();
        paymentLineList.clear();
        
                                
        TotalPOLAmount =0;TotalPYLAmount =0;TotalOriginal=0;TotalLE1=0;TotalLE2=0;TotalLE3=0;TotalLE4=0; TotalPYLAmt=0;// Initialization of calculation
        for(Integer countn = 0; countn < ALLBrand.size(); countn++){    // calculate the total Budget PO and Payment amount in Total report
            if(ALLBrand[countn].OriginalAmount!=null && ALLBrand[countn].OriginalAmount!=0){TotalOriginal=TotalOriginal+ALLBrand[countn].OriginalAmount;}
            if(ALLBrand[countn].LE1Amount!=null && ALLBrand[countn].LE1Amount!=0){TotalLE1=TotalLE1+ALLBrand[countn].LE1Amount;} 
            if(ALLBrand[countn].LE2Amount!=null && ALLBrand[countn].LE2Amount!=0){TotalLE2=TotalLE2+ALLBrand[countn].LE2Amount;}
            if(ALLBrand[countn].LE3Amount!=null && ALLBrand[countn].LE3Amount!=0){TotalLE3=TotalLE3+ALLBrand[countn].LE3Amount;}
            if(ALLBrand[countn].LE4Amount!=null && ALLBrand[countn].LE4Amount!=0){TotalLE4=TotalLE4+ALLBrand[countn].LE4Amount;} 
            if(ALLBrand[countn].PlanAmount!=null && ALLBrand[countn].PlanAmount!=0){TotalPlanAmount=TotalPlanAmount+ALLBrand[countn].PlanAmount;}
             
            
            if(ALLBrand[countn].POLAmount!=null && ALLBrand[countn].POLAmount!=0){TotalPOLAmount=TotalPOLAmount+ALLBrand[countn].POLAmount;}
            if(ALLBrand[countn].PYLAmount!=null && ALLBrand[countn].PYLAmount!=0){TotalPYLAmount=TotalPYLAmount+ALLBrand[countn].PYLAmount;}
        }
        for(Integer countn = 0; countn < ALLBrandG.size(); countn++){  
            if(ALLBrandG[countn].POLAmount!=null && ALLBrandG[countn].POLAmount!=0){TotalPOAmt=TotalPOAmt+ALLBrandG[countn].POLAmount;}
                if(ALLBrandG[countn].PYLAmount!=null && ALLBrandG[countn].PYLAmount!=0){TotalPYLAmt=TotalPYLAmt+ALLBrandG[countn].PYLAmount;}
        }
        Integer countNum = 0;
        Integer countNum_notinB = 0;                                            //Integer countNum_notinPlan = 0;
        // By Sub Brand
        //-------------------------------------No Use
        for(ASI_MFM_Plan_Line_Item__c liItem:PlanlineItem){                     // For each Plan Line Items ,check if it is in the budget
            Boolean isfound=false;
            showingdata temp=new showingdata(); 
            for(ASI_MFM_Budget__c buli : budgetItem){
                String line=liItem.ASI_MFM_Sub_brand_Code__r.name;
                String Budget=buli.ASI_MFM_Sub_brand_Code__r.name;   //GBKK   UPC   STH   WS
                line=line.replaceALL('-', '');
                line=line.replaceALL(' ', '');
                Budget=Budget.replaceALL('-', '');
                Budget=Budget.replaceALL(' ', ''); 
                if(line.equalsIgnoreCase(Budget)  && buli.ASI_MFM_Region_AND_Customer__c == liItem.ASI_MFM_TH_Region__c && buli.ASI_MFM_Total_Amount__c>0 && liItem.ASI_MFM_Total_Cost__c!=null){  // In the budget 
                    if(buli.ASI_MFM_Type__c.contains('Budget')){                                                        // record all of the budget from Original Budget ,LE1 TO LE4     buli.ASI_MFM_Type__c=='Original Budget'
                        if(temp.OriginalAmount==null){temp.OriginalAmount=0;}
                        temp.OriginalAmount=temp.OriginalAmount+buli.ASI_MFM_Total_Amount__c; // add them together
                        isfound=true;
                    }
                    if(buli.ASI_MFM_Type__c=='LE1'){
                        if(temp.LE1Amount==null){temp.LE1Amount=0;}
                        temp.LE1Amount=temp.LE1Amount+buli.ASI_MFM_Total_Amount__c;
                        isfound=true;
                    }
                    if(buli.ASI_MFM_Type__c=='LE2'){
                        if(temp.LE2Amount==null){temp.LE2Amount=0;}
                        temp.LE2Amount=temp.LE2Amount+buli.ASI_MFM_Total_Amount__c;
                        isfound=true;
                    }
                    if(buli.ASI_MFM_Type__c=='LE3'){
                        if(temp.LE3Amount==null){temp.LE3Amount=0;}
                        temp.LE3Amount=temp.LE3Amount+buli.ASI_MFM_Total_Amount__c;
                        isfound=true;
                    }
                    if(buli.ASI_MFM_Type__c=='LE4'){
                        if(temp.LE4Amount==null){temp.LE4Amount=0;}
                        temp.LE4Amount=temp.LE4Amount+buli.ASI_MFM_Total_Amount__c;
                        isfound=true;
                    }
                    temp.Sub_brand_Code=buli.ASI_MFM_Sub_brand_Code__r.name; // add another details
                    temp.BrandName=liItem.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.name;
                    temp.AC_Code=liItem.ASI_MFM_A_C_Code__r.name;
                    if(liItem.ASI_MFM_Total_Cost__c!=null){ temp.PlanAmount=liItem.ASI_MFM_Total_Cost__c; }
                    temp.PlanName=liItem.Name;
                    temp.PlanDescription=liItem.ASI_MFM_List_Item_Description__c;
                    temp.CustomerName=liItem.ASI_MFM_Customer_Name__r.name;
                    temp.Region=buli.ASI_MFM_Region_AND_Customer__c;
                    temp.Plan=liItem.ASI_MFM_Plan_Name_sys__c;
                    temp.PlanId=liItem.ASI_MFM_Plan__r.Name; 
                }
            }
            if(isfound){
                countNum++;
                temp.sequence=countNum;
                currentMergeTHH.add(temp); 
            }else{  // Not Found, add them to another place
                countNum_notinB++;
                temp.sequence=countNum_notinB;
                temp.PlanAmount=liItem.ASI_MFM_Total_Cost__c;
                temp.PlanName=liItem.Name;
                temp.PlanDescription=liItem.ASI_MFM_List_Item_Description__c;
                temp.Plan_Name_sys=liItem.ASI_MFM_Plan_Name_sys__c;
                temp.Sub_brand_Code=liItem.ASI_MFM_Sub_brand_Code__r.name;
                temp.CustomerName=liItem.ASI_MFM_Customer_Name__r.name;
                temp.Region=liItem.ASI_MFM_TH_Region__c;
                PLI_not_inB_THH.add(temp);
            } 
            Prefixdept=liItem.ASI_MFM_Plan__r.ASI_MFM_Prefix__r.ASI_MFM_Department__c;
        }
        
        showingdata tempData2=new showingdata();
        for(Integer countn =currentMergeTHH.size()-1; countn>0; countn--){
            for(Integer num = 0; num < countn; num++){
                if(currentMergeTHH[num].Region==currentMergeTHH[countn].Region && currentMergeTHH[num].TotalPlan4Brand <=currentMergeTHH[countn].TotalPlan4Brand){
                    tempData2=currentMergeTHH[countn];
                    currentMergeTHH[countn]=currentMergeTHH[num];
                    currentMergeTHH[num]=tempData2; 
                }
            }
        }
        
        Calculation(currentMergeTHH);             //CalculateVariance(currentMergeTHH);   //CalculateVariance(MergeByRegion)
		DeleteRedundant(currentMergeTHH);  		//DeleteRedundantBR(currentMergeTHH);                           //Calculation(MergeByRegion);
//No use
//        POPYLCalculate(ALLBrand);               //DeleteRedundant(MergeByRegion); //CheckisinPlan(currentMergeTHH);
  //      POPYLCalculate(ALLBrandG); 
        
        
    //    DeleteGroup(ALLBrandG); 
        return true;
    }
    
     
    public boolean init(){  //orTHM AND THK Use , Get budget data     System.debug('PrefixUse@:'+PrefixUse);   The budget VS plan amount break by sub-brand and order by sub-brand 

        for (ASI_MFM_Budget_Setting__c Setting : ASI_MFM_Budget_Setting__c.getAll().values()) { // Get effective Fiscal Year and Budget Type from custom Setting
            if(Setting.name == 'TH'){
                BudgetTypeSet= Setting.ASI_MFM_Budget_Type__c;
                NowBudgetString=Setting.ASI_MFM_Budget_Type__c; // show in the PDF
            }
        }   
        budgetItem = [select ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.ASI_MFM_Brand_Grouping__c,ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.name,ASI_MFM_Type__c,ASI_MFM_Fiscal_Year__c,ASI_MFM_Sub_brand_Code__c,ASI_MFM_Sub_brand_Code__r.name,ASI_MFM_P1_Amount__c, ASI_MFM_P2_Amount__c,ASI_MFM_P3_Amount__c,ASI_MFM_P4_Amount__c,ASI_MFM_P5_Amount__c, ASI_MFM_P6_Amount__c,ASI_MFM_P7_Amount__c, ASI_MFM_P8_Amount__c,ASI_MFM_P9_Amount__c, ASI_MFM_P10_Amount__c,ASI_MFM_P11_Amount__c,ASI_MFM_P12_Amount__c,ASI_MFM_Total_Amount__c,ASI_MFM_Region_AND_Customer__c,ASI_MFM_Department__c from ASI_MFM_Budget__c 
                      where  ASI_MFM_Department__c Like :'%'+PrefixUse2+'%'  AND (ASI_MFM_Type__c='Budget' or ASI_MFM_Type__c=:BudgetTypeSet)
                      AND ASI_MFM_Fiscal_Year__c=:FiscalYearNum order by ASI_MFM_Sub_brand_Code__r.name,ASI_MFM_Type__c];          //  order: ASI_MFM_Sub_brand_Code__r.name,ASI_MFM_Type__c //Get Plan Line Item data
        PlanlineItem = [select ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.ASI_MFM_Brand_Grouping__c,ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.name,ASI_MFM_A_C_Code__r.name,ASI_MFM_Plan__r.Name,Id,ASI_MFM_Plan__r.ASI_MFM_Prefix__r.name,ASI_MFM_Plan__r.ASI_MFM_Prefix__r.ASI_MFM_Department__c,Name,ASI_MFM_Sub_brand_Code__r.name,ASI_MFM_Total_Cost__c,ASI_MFM_Customer_Name__r.name,ASI_MFM_Plan_Name_sys__c,ASI_MFM_List_Item_Description__c,ASI_MFM_Month_1_Cost__c,ASI_MFM_Month_2_Cost__c,ASI_MFM_Month_3_Cost__c,ASI_MFM_Month_4_Cost__c,ASI_MFM_Month_5_Cost__c,ASI_MFM_Month_6_Cost__c,ASI_MFM_Month_7_Cost__c,ASI_MFM_Month_8_Cost__c,ASI_MFM_Month_9_Cost__c,ASI_MFM_Month_10_Cost__c,ASI_MFM_Month_11_Cost__c,ASI_MFM_Month_12_Cost__c 
                        from ASI_MFM_Plan_Line_Item__c where ASI_MFM_Plan__r.ASI_MFM_Prefix__r.name Like :'%'+PrefixUse+'%' And ASI_MFM_Sub_brand_Code__r.name!=null AND ASI_MFM_Total_Cost__c!=null
                        order by ASI_MFM_Sub_brand_Code__r.name ,ASI_MFM_Plan__r.Name,ASI_MFM_Total_Cost__c desc ];     // ASI_MFM_Sub_brand_Code__r.name,ASI_MFM_Plan__r.Name  
        POlineItem = [select ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.ASI_MFM_Brand_Grouping__c,ASI_MFM_PO__r.Name,ASI_MFM_Amount__c,ASI_MFM_List_Item_Description__c,ASI_MFM_Sub_brand_Code__r.name,Name,ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.Name,ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c 
                      from ASI_MFM_PO_Line_Item__c 
                      where ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Prefix__r.name Like :'%'+PrefixUse+'%'  order by ASI_MFM_Sub_brand_Code__r.name];
        
        paymentLineList =[select ASI_MFM_Payment_Amount__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.name,Name,ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c, ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.Name,ASI_MFM_Payment_List_Item_Description__c, ASI_MFM_PO_Line_Item__r.ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c 
                          from ASI_MFM_Payment_Line_Item__c where ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Prefix__r.name Like :'%'+PrefixUse+'%'  order by ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.name]; 
  
        currentMerge=new List<showingdata>();
        PLI_not_inB=new List<showingdata>();     
        ALLBrand=new List<showingdata>();
        String TestSameBrand;
        for(ASI_MFM_Budget__c buli : budgetItem){  //  process  Budget, Plan amount, PO Amount , Payment amount Data, ignore the  Line items detail
            Boolean isfound=false;
            showingdata temp=new showingdata();     // temporary save
            temp.BrandName=buli.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.name;           //Get Brand Name
            temp.BrandGroup=buli.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.ASI_MFM_Brand_Grouping__c;
			temp.Sub_brand_Code=buli.ASI_MFM_Sub_brand_Code__r.name;
            temp.PlanAmount=0;
            temp.POLAmount=0;
            temp.PYLAmount=0;
            String Budget=buli.ASI_MFM_Sub_brand_Code__r.name;
            if(Budget!=null){
                Budget=Budget.replaceALL('-', '');
                Budget=Budget.replaceALL(' ', '');
            }
            for(ASI_MFM_Plan_Line_Item__c liItem:PlanlineItem){
                String line=liItem.ASI_MFM_Sub_brand_Code__r.name;
                if(line!=null){
                    line=line.replaceALL('-', '');
                    line=line.replaceALL(' ', '');
                    if(line.equalsIgnoreCase(Budget) && liItem.ASI_MFM_Total_Cost__c>0){
                        isfound=true;
                        temp.PlanAmount=temp.PlanAmount+liItem.ASI_MFM_Total_Cost__c;
                    }   
                }
            }
            for(ASI_MFM_PO_Line_Item__c POliItem:POlineItem){
                if(POliItem.ASI_MFM_Sub_brand_Code__r.name!=null){
                    String line=POliItem.ASI_MFM_Sub_brand_Code__r.name;
                	line=line.replaceALL('-', '');
                	line=line.replaceALL(' ', '');
                	if(line.equalsIgnoreCase(Budget) && POliItem.ASI_MFM_Amount__c!=null && POliItem.ASI_MFM_Amount__c>0){  //  POliItem.ASI_MFM_Amount__c>0
                        isfound=true;  //found
                    	temp.POLAmount=temp.POLAmount+POliItem.ASI_MFM_Amount__c; //add them together
                	}
                }
            }
            
            for(ASI_MFM_Payment_Line_Item__c PYLItem:paymentLineList){
                if(PYLItem.ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.name!=null){
                    String line=PYLItem.ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.name;
                    line=line.replaceALL('-', '');
                    line=line.replaceALL(' ', '');
                    if(line.equalsIgnoreCase(Budget) && PYLItem.ASI_MFM_Payment_Amount__c!=null && PYLItem.ASI_MFM_Payment_Amount__c>0 ){ //PYLItem.ASI_MFM_Payment_Amount__c>0 
                        isfound=true;
                        temp.PYLAmount=temp.PYLAmount+PYLItem.ASI_MFM_Payment_Amount__c;
                    } 
                }
            }
            for(ASI_MFM_Budget__c budgetli : budgetItem){
                if(buli.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.name==budgetli.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.name){
                    if(budgetli.ASI_MFM_Type__c.contains('Budget')){  //            budgetli.ASI_MFM_Type__c=='Original Budget'
                        if(temp.OriginalAmount==null){ temp.OriginalAmount=0; }
                        temp.OriginalAmount = temp.OriginalAmount+budgetli.ASI_MFM_Total_Amount__c;
                    }
                    if(budgetli.ASI_MFM_Type__c=='LE1'){
                        if(temp.LE1Amount==null){temp.LE1Amount=0; }
                        temp.LE1Amount = temp.LE1Amount+budgetli.ASI_MFM_Total_Amount__c;
                    }
                    
                    if(budgetli.ASI_MFM_Type__c=='LE2'){
                        if(temp.LE2Amount==null){
                            temp.LE2Amount=0; 
                        }
                        temp.LE2Amount = temp.LE2Amount+budgetli.ASI_MFM_Total_Amount__c;
                    }
                    
                    if(budgetli.ASI_MFM_Type__c=='LE3'){
                        if(temp.LE3Amount==null){
                            temp.LE3Amount=0; 
                        }
                        temp.LE3Amount = temp.LE3Amount+budgetli.ASI_MFM_Total_Amount__c;
                    }
                    
                    if(budgetli.ASI_MFM_Type__c=='LE4'){
                        if(temp.LE4Amount==null){
                            temp.LE4Amount=0; 
                        }
                        temp.LE4Amount = temp.LE4Amount+budgetli.ASI_MFM_Total_Amount__c;
                    }
                }
            }
            if(isfound==true && TestSameBrand!=temp.BrandName ){ // 
                TestSameBrand=temp.BrandName;                //system.debug('ADD_ALLBrand2'+ALLBrand);
                ALLBrand.add(temp);   //system.debug('ADD_ALLBrand'+temp);
                
            }
		}
        TotalPOLAmount =0;
        TotalPYLAmount  =0;
        TotalOriginal=0;
        TotalLE1=0;
        TotalLE2=0;
        TotalLE3=0;
        TotalLE4=0;    // Initialization of calculation
        for(Integer countn = 0; countn < ALLBrand.size(); countn++){                                          //calculate total Budget,PO Payment amount in total report
            if(ALLBrand[countn].OriginalAmount!=null && ALLBrand[countn].OriginalAmount!=0){TotalOriginal=TotalOriginal+ALLBrand[countn].OriginalAmount;}
            if(ALLBrand[countn].LE1Amount!=null && ALLBrand[countn].LE1Amount!=0){TotalLE1=TotalLE1+ALLBrand[countn].LE1Amount;}
            if(ALLBrand[countn].LE2Amount!=null && ALLBrand[countn].LE2Amount!=0){TotalLE2=TotalLE2+ALLBrand[countn].LE2Amount;}
            if(ALLBrand[countn].LE3Amount!=null && ALLBrand[countn].LE3Amount!=0){TotalLE3=TotalLE3+ALLBrand[countn].LE3Amount;}
            if(ALLBrand[countn].LE4Amount!=null && ALLBrand[countn].LE4Amount!=0){TotalLE4=TotalLE4+ALLBrand[countn].LE4Amount;}
           	if(ALLBrand[countn].POLAmount!=null && ALLBrand[countn].POLAmount!=0){TotalPOLAmount=TotalPOLAmount+ALLBrand[countn].POLAmount;}
           	if(ALLBrand[countn].PYLAmount!=null && ALLBrand[countn].PYLAmount!=0){TotalPYLAmount=TotalPYLAmount+ALLBrand[countn].PYLAmount;}
        }//countNum count number of data which is in ASI_MFM_Plan_Line_Item__c and ASI_MFM_Budget__c by ASI_MFM_Sub_brand_Code__r.name
        Integer countNum = 0;   //countNum_notinB  count number of data which is in ASI_MFM_Plan_Line_Item__c but not in ASI_MFM_Budget__c
        Integer countNum_notinB = 0;        //countNum_notinPlan count number of data  which is in ASI_MFM_Budget__c but not in ASI_MFM_Plan_Line_Item__c 
       for(ASI_MFM_Plan_Line_Item__c liItem:PlanlineItem){    //Find  whether data in ASI_MFM_Plan_Line_Item__c is in ASI_MFM_Budget__c This will show in Plan Overview By Sub-Brand part 
            Boolean isfound=false;
            showingdata temp=new showingdata();        //Create new temporary showingdata data structure
            temp.budgetAmount=0;                         //accumulate budgetAmount
            for(ASI_MFM_Budget__c buli : budgetItem){
				String line=liItem.ASI_MFM_Sub_brand_Code__r.name;  // liItem.ASI_MFM_Sub_brand_Code__r.name==buli.ASI_MFM_Sub_brand_Code__r.name
                String Budget=buli.ASI_MFM_Sub_brand_Code__r.name;   // liItem.ASI_MFM_Sub_brand_Code__r.name.equalsIgnoreCase(buli.ASI_MFM_Sub_brand_Code__r.name)
                if(line!=null){
                    line=line.replaceALL('-', '');
                line=line.replaceALL(' ', '');
                Budget=Budget.replaceALL('-', '');              //System.debug('line:&&:'+line+'Budget##'+Budget);
                Budget=Budget.replaceALL(' ', '');               //equalsIgnoreCase: compares this String to another String, ignoring case considerations
                if(line.equalsIgnoreCase(Budget) && buli.ASI_MFM_Total_Amount__c>0 && liItem.ASI_MFM_Total_Cost__c!=null){  //equalsIgnoreCase
                    if(buli.ASI_MFM_Type__c.contains('Budget')){  // Find which one is the vaild budget to use    .contains('Budget')    buli.ASI_MFM_Type__c=='Original Budget'
                        if(temp.OriginalAmount==null){
                            temp.OriginalAmount=0;
                        }
                        temp.OriginalAmount=temp.OriginalAmount+buli.ASI_MFM_Total_Amount__c;  //There maybe more than one Sub_brand_Code in ASI_MFM_Budget__c
                    }
                    if(buli.ASI_MFM_Type__c=='LE1'){
                        if(temp.LE1Amount==null){
                            temp.LE1Amount=0;
                        }
                        temp.LE1Amount=temp.LE1Amount+buli.ASI_MFM_Total_Amount__c;
                    }
                    if(buli.ASI_MFM_Type__c=='LE2'){
                        if(temp.LE2Amount==null){
                            temp.LE2Amount=0;
                        }
                        temp.LE2Amount=temp.LE2Amount+buli.ASI_MFM_Total_Amount__c;
                    }
                    if(buli.ASI_MFM_Type__c=='LE3'){
                        if(temp.LE3Amount==null){
                            temp.LE3Amount=0;
                        }
                        temp.LE3Amount=temp.LE3Amount+buli.ASI_MFM_Total_Amount__c;        //ASI_MFM_Total_Amount__c can not be lower than 0
                    }
                    if(buli.ASI_MFM_Type__c=='LE4'){
                        if(temp.LE4Amount==null){
                            temp.LE4Amount=0;
                        }
                        temp.LE4Amount=temp.LE4Amount+buli.ASI_MFM_Total_Amount__c;          //temp.budgetAmount=temp.budgetAmount+buli.ASI_MFM_Total_Amount__c;
                    }
                    temp.Sub_brand_Code=buli.ASI_MFM_Sub_brand_Code__r.name;                       //Save data in temp 
                    temp.BrandName=liItem.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.name;
                    temp.AC_Code=liItem.ASI_MFM_A_C_Code__r.name;
                    temp.PlanAmount=liItem.ASI_MFM_Total_Cost__c;
                    temp.PlanName=liItem.Name;
                    temp.PlanDescription=liItem.ASI_MFM_List_Item_Description__c;
                    temp.CustomerName=liItem.ASI_MFM_Customer_Name__r.name;
                    temp.BrandRegion_AND_Customer=buli.ASI_MFM_Region_AND_Customer__c;
                    temp.Plan=liItem.ASI_MFM_Plan_Name_sys__c;
                    temp.PlanId=liItem.ASI_MFM_Plan__r.Name;
                    temp.Isstore=true;  
                    isfound=true;
                }
                }
                
            }
            if(isfound){ //BOTH in ASI_MFM_Plan_Line_Item__c and ASI_MFM_Budget__c
                countNum++;
                temp.sequence=countNum;
                currentMerge.add(temp);             //If matchs,adding temp into currentMerge,which will use in PDF
            }else{                          //If no match, means that data is in "ASI_MFM_Plan_Line_Item__c", but not in  "ASI_MFM_Budget__c
                countNum_notinB++;
                temp.sequence=countNum_notinB;
                temp.PlanAmount=liItem.ASI_MFM_Total_Cost__c;
                temp.PlanName=liItem.Name;
                temp.PlanDescription=liItem.ASI_MFM_List_Item_Description__c;
                temp.Plan_Name_sys=liItem.ASI_MFM_Plan_Name_sys__c;
                temp.Sub_brand_Code=liItem.ASI_MFM_Sub_brand_Code__r.name;
                temp.CustomerName=liItem.ASI_MFM_Customer_Name__r.name;
                PLI_not_inB.add(temp);
            }
           Prefixdept=liItem.ASI_MFM_Plan__r.ASI_MFM_Prefix__r.ASI_MFM_Department__c;
        }
        TotalBudgetAmount=0.000001;TotalPlanAmount=0; TotalLE1Amount=0;TotalLE2Amount=0;TotalLE3Amount=0;TotalLE4Amount=0; TotalOriginalAmount=0;    // Initialization of calculation
        //Calculation(currentMerge);                         //currentMerge Calculate Variance   Variance percent ,TotalPlanAmount , TotalBudgetAmount  
        showingdata tempData2=new showingdata();                     //CheckisinPlan(currentMerge);
        // Sort Total Plan Amount
        for(Integer countn =currentMerge.size()-1; countn>0; countn--){
            for(Integer num = 0; num < countn; num++){
                if(currentMerge[num].TotalPlan4Brand<=currentMerge[countn].TotalPlan4Brand){ // put the largest one on the top
                    tempData2=currentMerge[countn];
                    currentMerge[countn]=currentMerge[num];
                    currentMerge[num]=tempData2;
                }
            }
        }
        //SortPlan ID IF plan ID is same ,group them together 
        for(Integer countn =currentMerge.size()-1; countn>0; countn--){
            for(Integer num = 0; num < countn-1; num++){
                if(currentMerge[num].Sub_brand_Code==currentMerge[countn].Sub_brand_Code && currentMerge[num].PlanId==currentMerge[countn].PlanId){
                    tempData2=currentMerge[countn];
                    currentMerge[countn]=currentMerge[num+1];
                    currentMerge[num+1]=tempData2; 
                }
            }
        }
        //Sort  Plan Amount
        for(Integer countn =currentMerge.size()-1; countn>0; countn--){
            for(Integer num = 0; num < countn; num++){ // same Brand but different Plan ID, will sort by descending order
                if(currentMerge[num].Sub_brand_Code==currentMerge[countn].Sub_brand_Code && currentMerge[num].PlanId!=currentMerge[countn].PlanId && currentMerge[num].PlanAmount< currentMerge[countn].PlanAmount){
                     tempData2=currentMerge[countn];
                    currentMerge[countn]=currentMerge[num];
                    currentMerge[num]=tempData2; 
                }
            }
        }
        
        //Sort Plan Line Item Amount
        for(Integer countn =currentMerge.size()-1; countn>0; countn--){
            for(Integer num = 0; num < countn; num++){
                
                if(currentMerge[num].Sub_brand_Code==currentMerge[countn].Sub_brand_Code && currentMerge[num].PlanId==currentMerge[countn].PlanId && currentMerge[num].PlanAmount< currentMerge[countn].PlanAmount){
                    tempData2=currentMerge[countn];
                    currentMerge[countn]=currentMerge[num];
                    currentMerge[num]=tempData2; 
                }
            }
        }
        
        TotalPODiff_BG=0;
        TotalPOAmt=0;
        TotalPLYDiff_BG=0;
        TotalPYLAmt=0;
        DeleteRedundant(currentMerge);
        POPYLCalculate(ALLBrand);
        DeleteGroup(ALLBrand);   // delete Redundant Brand Group
        return true;
    }
    
    public void DeleteGroup(List<showingdata> RedundantData){  // For deleting Redundant Brand Group Use
        String BrandGroup;  //save the current data
        for(Integer countnumber = 0; countnumber < RedundantData.size(); countnumber++){
            if(countnumber==0){  //First Time
                BrandGroup=RedundantData[countnumber].BrandGroup;
            }else{ //second or other times
                if(BrandGroup==RedundantData[countnumber].BrandGroup && RedundantData[countnumber].BrandGroup!=null){ // if redundant data exist 
                    RedundantData[countnumber].BrandGroup=null;
                }else{  // different
                    BrandGroup=RedundantData[countnumber].BrandGroup;
                }
            }
        }
    }

    
    public void POPYLCalculate(List<showingdata> BrandaLL){          // calclulate PO Payment ( Total )Un-Committed Un-Committed 
        Decimal Budget;   // store Budget Amount
        for(Integer countnumber = 0; countnumber < BrandaLL.size(); countnumber++){
            if(NowBudgetString.contains('Budget')){Budget=BrandaLL[countnumber].OriginalAmount;}  //if(BrandaLL[countnumber].InvalidBudget==0){Budget=BrandaLL[countnumber].OriginalAmount;}
            if(NowBudgetString.contains('LE1')){Budget=BrandaLL[countnumber].LE1Amount;}
            if(NowBudgetString.contains('LE2')){Budget=BrandaLL[countnumber].LE2Amount;}   //BrandaLL[countnumber].InvalidBudget
            if(NowBudgetString.contains('LE3')){
                if(BrandaLL[countnumber].LE3Amount==null){
                    BrandaLL[countnumber].LE3Amount=0;
                }
                Budget=BrandaLL[countnumber].LE3Amount;
            }
            if(NowBudgetString.contains('LE4')){Budget=BrandaLL[countnumber].LE4Amount;}
            //PO
            if(BrandaLL[countnumber].POLAmount!=null ){ // && BrandaLL[countnumber].POLAmount!=0
                BrandaLL[countnumber].PODiff=Budget-BrandaLL[countnumber].POLAmount;
                if(Budget>0){BrandaLL[countnumber].PODiffPer=(BrandaLL[countnumber].PODiff/Budget)*100;}
                if(BrandaLL[countnumber].PODiffPer!=null){BrandaLL[countnumber].Percent='%';}
                
            }
            //Payment
            if(BrandaLL[countnumber].PYLAmount!=null ){ //&& BrandaLL[countnumber].PYLAmount!=0
                BrandaLL[countnumber].PYLDiff =BrandaLL[countnumber].POLAmount-BrandaLL[countnumber].PYLAmount;
                if(Budget>0){BrandaLL[countnumber].PYLDiffPer=(BrandaLL[countnumber].PYLDiff /Budget)*100;}
            }
            
        }
        if(TotalOriginal!=null &&TotalOriginal!=0){
            TotalPODiff=TotalOriginal-TotalPOLAmount;
            TotalPODiff_BG=TotalOriginal-TotalPOAmt;
            TotalPODiffPer=(TotalPODiff)/TotalOriginal;//TotalPLYDiff= TotalOriginalAmount-TotalPYLAmount;
        }
        if(TotalLE1!=null && TotalLE1!=0){
             TotalPODiff=TotalLE1-TotalPOLAmount;
            TotalPODiff_BG=TotalLE1-TotalPOAmt;
            TotalPODiffPer=(TotalPODiff)/TotalLE1;//TotalPLYDiff= TotalLE1Amount-TotalPYLAmount;
        }
        if(TotalLE2!=null && TotalLE2!=0){
            TotalPODiff=TotalLE2-TotalPOLAmount;
            TotalPODiff_BG=TotalLE2-TotalPOAmt;
            TotalPODiffPer=(TotalPODiff)/TotalLE2;//TotalPLYDiff= TotalLE2Amount-TotalPYLAmount;
        }
        if(TotalLE3!=null && TotalLE3!=0){
            TotalPODiff=TotalLE3-TotalPOLAmount;
            TotalPODiff_BG=TotalLE3-TotalPOAmt;
            TotalPODiffPer=(TotalPODiff)/TotalLE3;//TotalPLYDiff= TotalLE3Amount-TotalPYLAmount;
        }
        if(TotalLE4!=null && TotalLE4!=0){
            TotalPODiff=TotalLE4-TotalPOLAmount;
            TotalPODiff_BG=TotalLE4-TotalPOAmt;
            TotalPODiffPer=(TotalPODiff)/TotalLE4;//TotalPLYDiff= TotalLE4Amount-TotalPYLAmount;
        }
        TotalPLYDiff= TotalPOLAmount-TotalPYLAmount;
        TotalPLYDiff_BG=TotalPOAmt-TotalPYLAmt;
    }
    
    
    
    private String soqlBudget {get;set;}
    private String soqlBudgetL{get;set;}
    private String soqlBudgetS{get;set;}// By Sub-Brand
    private String soqlBudgetB{get;set;}// By Brand
    public class SummaryObject{
        public Decimal TotalAmt { get; private set; }// Remaining PO
        public String Name { get; private set; }// Sub-Brand Name
        public String Region { get; private set; }
        public SummaryObject(AggregateResult ar) {
            TotalAmt = (Decimal) ar.get('TotalAmount');
            Name = (String) ar.get('Name');
            Region = (String) ar.get('Region');
        }
    }
    public boolean init_detail(){
        //Get effective Budget
        for (ASI_MFM_Budget_Setting__c Setting : ASI_MFM_Budget_Setting__c.getAll().values()) {
            if(Setting.name == 'TH'){
                BudgetTypeSet= Setting.ASI_MFM_Budget_Type__c;
                NowBudgetString=Setting.ASI_MFM_Budget_Type__c; 
            }
        }
        soqlBudgetS='select ASI_MFM_Sub_brand_Code__r.name Name,ASI_MFM_Region_AND_Customer__c Region,sum(ASI_MFM_Total_Amount__c) TotalAmount from ASI_MFM_Budget__c where ASI_MFM_Budget__c.RecordType.DeveloperName LIKE \'ASI_MFM_TH_Budget%\'';
        soqlBudgetS +=' and ASI_MFM_Fiscal_Year__c LIKE \''+String.escapeSingleQuotes(FiscalYearNum)+'%\' and ASI_MFM_Department__c LIKE \''+String.escapeSingleQuotes(PrefixUse2)+' and ASI_MFM_Type__c=:'+String.escapeSingleQuotes(BudgetTypeSet)+'group by ASI_MFM_Region_AND_Customer__c order by ASI_MFM_Sub_brand_Code__r.name';
        
        return true;
    }
    */
    //Finished
}