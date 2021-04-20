public without sharing class ASI_MFM_TW_Plan2In1Pdf_Ctrl_ver2 {
    
    //Updated at: 2013-07-26 14:40
    //Vession 0.0.9
    //1.Cost Estimation part Ok
    //2.Null Reference not finished
    //3.Change the field of the name ------   Version 0.0.5         
    //4.Change the field of FOC,etc  ------   Version 0.0.5 
    //5.Change the field ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c line 144 ------ Version 0.0.6
    //6.Handle the null value for ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c(kby16) ------ Version 0.0.6
    //7.Fix the round off problem of FOC and Cash
    //8.Fix the rounding problem
    //9.Fix the Budget per bottle over volume
    //10. Remove matching plan in the calculation of Budget per Bottle
    //11. Locate long strings and break them into hyphens if it does not fit into tables
    private final ASI_MFM_Plan__c Plan;
    public List<ASI_MFM_Plan_Line_Item__c> budgetSummaryList_start{get;set;}
    public List<ASI_MFM_Plan_Line_Item__c> budgetSummaryListCheckName{get;set;}
    public List<ASI_MFM_Plan_Line_Item__c> budgetSummaryListCheckNameAD{get;set;}
    public List<ASI_MFM_Plan_Line_Item__c> budgetSummaryListCheckNameAP{get;set;}    
    public List<ASI_MFM_Plan_Line_Item__c> budgetSummaryListSame{get;set;}
    public List<ASI_MFM_Plan_Line_Item__c> budgetSummaryList3{get;set;}
    public List<ASI_MFM_Plan_Line_Item__c> budgetSummaryList{get;set;}
    public List<ASI_MFM_Plan_Line_Item__c> costEstList{get;set;}
    public List<ASI_MFM_Plan_Line_Item__c> costEstListAP{get;set;}
    public List<ASI_MFM_Plan_Line_Item__c> costEstListAD{get;set;}
    public String verifiedBy{get;set;}
    public decimal costEstTotal{get;set;}
    public decimal costEstTotalAD{get;set;}
    public decimal costEstTotalAP{get;set;}
    public ASI_MFM_Plan__c planTemp{get;set;}
    public decimal targetVolumeTotal{get;set;}
    public decimal targetVolumeTotalAD{get;set;}
    public decimal targetVolumeTotalAP{get;set;}
    public Boolean hasADLineItems{get;set;}
    public Boolean hasAPLineItems{get;set;}
    public Boolean is2in1Plan{get;set;}
    
    public boolean isRenderMKTAP{get;set;} {isRenderMKTAP= false;}
    public boolean isRenderTradeAP{get;set;} {isRenderTradeAP =false; } 
    
    
    public List<ASI_MFM_Budget__c> budgetTypeList;
    public string customerName;
    public string subBrandCode;
    public string size;
    public string country;
    public string apTree;
    public string budgetTypeFromCustomSet;
    public boolean CheckName;
    // Start fix 11
    public String planName{get;set;}
    public String planDescription{get;set;}
    public String targetSector{get;set;}
    public String accountName{get;set;}
    // end fix 11
    
    //Label used to dynamic hidden the table
    public string lbBrand{get;set;}
    public string lbOutletType{get;set;}
    public string lbNoOfOutlet{get;set;}
    public string lbTargetVolume{get;set;}
    public string lbSpendingBottle{get;set;}
    public string lbFOC{get;set;}
    public string lbCash{get;set;}
    public string lbTotal{get;set;}
    public string lbBudgetPerBottle{get;set;}
    public boolean isRenderBudget{get;set;}
    public boolean isRenderActivityTime{get;set;}
    
    public String headerId {get; set;}
    public List<ASI_MFM_Plan_Line_Item__c> planLines {get;set;}
    public List<ASI_MFM_Budget__c> budgetList {get;set;}
    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }
    public Map<String,printObj> printList {get;set;}
    public boolean hasHistroy {get;set;}
    public Set<id> subBrandIds = new Set<id>();
    public Set<id> acCodeIds = new Set<id>();
    
    // Fix 11
    public String breakStrings(String[] ArrayString, integer dashIntervals)
    {
        String parsedString = '';
        for (String ie:ArrayString)
        {
            if (ie.length() > dashIntervals)
            {
                parsedString += ie.substring(0, dashIntervals) + ' ';
                integer counter = 1;
                for (integer i = dashIntervals; i < ie.length() && i + dashIntervals < ie.length(); i += dashIntervals)
                {
                    parsedString += ' ' + ie.substring(i, i + dashIntervals);
                    counter++;
                }
                if (ie.length() > counter * dashIntervals )
                    parsedString += ie.substring(counter * dashIntervals, ie.length()) + ' ';
            }
            else
                parsedString += ie + ' ';
            
        }
        return parsedString;
    }
    // End fix 11
    public ASI_MFM_TW_Plan2In1Pdf_Ctrl_ver2(){}
    
    public Boolean init(){
        
        List<ProcessInstance> templl = [SELECT Id, 
                                           (SELECT Id FROM StepsAndWorkitems)
                                           FROM ProcessInstance
                                           WHERE TargetObjectId = : headerId
                                           Limit 1];
        
        if(templl.size()>0)
            hasHistroy = true;
        else
            hasHistroy = false;
        //Plan Country (Not Display)
        planTemp = [select ASI_MFM_Prefix__r.ASI_MFM_country_name__c, ASI_MFM_Prefix__r.Plan_Type__c, ASI_MFM_Fiscal_year__c,
                    ASI_MFM_Plan_Name__c, ASI_MFM_Plan_Description__c, ASI_MFM_Target_Sector__c, ASI_MFM_Account__r.Name,
                    ASI_MFM_Start_Date__c, ASI_MFM_End_Date__c,
                    Name, Owner.Name,
                    ASI_MFM_Objectives_Quantified__c, ASI_MFM_Objectives_Others__c, ASI_MFM_Mechanics__c
                    from ASI_MFM_Plan__c where id =: headerId];
        hasADLineItems = false;
        hasAPLineItems = false;
        is2in1Plan = false;
        
        //Render Activity time
        if(planTemp.ASI_MFM_Start_Date__c == null && planTemp.ASI_MFM_End_Date__c == null){
            isRenderActivityTime = false;
        }
        else{
            isRenderActivityTime = true;
        }
        
        
        //Hidden or show the budget 
        budgetSummaryList_start = new List<ASI_MFM_Plan_Line_Item__c>();
        budgetSummaryListCheckName = new List<ASI_MFM_Plan_Line_Item__c>();
        budgetSummaryListCheckNameAD = new List<ASI_MFM_Plan_Line_Item__c>();
        budgetSummaryListCheckNameAP = new List<ASI_MFM_Plan_Line_Item__c>();
        budgetSummaryListSame = new List<ASI_MFM_Plan_Line_Item__c>();  
        budgetSummaryList3 = new List<ASI_MFM_Plan_Line_Item__c>(); 
        budgetSummaryList = new List<ASI_MFM_Plan_Line_Item__c>();
        
        
        boolean stopLoop = false;
        integer oldMapSize = 0;
        integer newMapSize = 0;
        ASI_MFM_Plan_Line_Item__c budget = new ASI_MFM_Plan_Line_Item__c();
        
        country = planTemp.ASI_MFM_Prefix__r.ASI_MFM_country_name__c;
        if(planTemp.ASI_MFM_Prefix__r.Plan_Type__c == 'Trade A&P and A&D Plan')
            is2in1Plan = true;
        
        //Control the budget vs Summary rendering
        /*
if(planTemp.ASI_MFM_Prefix__r.Plan_Type__c == 'Marketing A&P Plan' || planTemp.ASI_MFM_Prefix__r.Plan_Type__c == 'Marketing A&P Plan - Cross Brand' ||
planTemp.ASI_MFM_Prefix__r.Plan_Type__c == 'Trade A&P Plan' ||  planTemp.ASI_MFM_Prefix__r.Plan_Type__c == 'BC Type Plan'){
isRenderBudget = false;
}
else{
isRenderBudget = true;
}
*/
        isRenderBudget = true;
        
        //Start fix 11
        String planNameTemp = '';
        String planDescriptionTemp = '';
        String targetSectorTemp = '';
        String accountNameTemp = '';
        if (planTemp.ASI_MFM_Plan_Name__c != null)
            planNameTemp = planTemp.ASI_MFM_Plan_Name__c;
        if (planTemp.ASI_MFM_Plan_Description__c != null)
            planDescriptionTemp = planTemp.ASI_MFM_Plan_Description__c;
        if (planTemp.ASI_MFM_Target_Sector__c != null)
            targetSectorTemp = planTemp.ASI_MFM_Target_Sector__c;
        if (planTemp.ASI_MFM_Account__c != null)
            accountNameTemp = planTemp.ASI_MFM_Account__r.Name;
        
        String[] arrayPlanName = planNameTemp .split(' ', -1);
        String[] arrayPlanDescription = planDescriptionTemp .split(' ', -1);
        String[] arrayTargetSector = targetSectorTemp.split(' ', -1);
        String[] arrayAccountName = accountNameTemp.split(' ', -1);
        planName = breakStrings(arrayPlanName, 97);
        planDescription = breakStrings(arrayPlanDescription, 97);
        targetSector = breakStrings(arrayTargetSector, 83);
        accountName = breakStrings(arrayAccountName, 83);
        //End fix 11
        
        System.debug('Prefix_Country' + planTemp.ASI_MFM_Prefix__r.Plan_Type__c);
        System.debug('country' + country);
        //Get BudgetType From Custom Setting
        budgetTypeFromCustomSet = null;
        if ( ASI_MFM_Budget_Type_Mappings__c.getInstance(country) != null)
            budgetTypeFromCustomSet = ASI_MFM_Budget_Type_Mappings__c.getInstance(country).ASI_MFM_Budget_Type__c;  
        //budgetTypeFromCustomSet = null;
        //budgetTypeFromCustomSet = ASI_MFM_Budget_Type_Mappings__c.getInstance('USA').Name;
        System.debug('budgetTypeFromCustomSet' + budgetTypeFromCustomSet);
        //VerifiedBy        
        if(planTemp.ASI_MFM_Prefix__r.Plan_Type__c == 'Allowance & Discount Spending Form'){
            verifiedBy = 'N/A';
        }
        else{
            verifiedBy = '';
        }
        
        System.debug('Enter budget Summary');
        
        budgetTypeList = [
            select ASI_MFM_P1_Amount__c, ASI_MFM_P2_Amount__c,
            ASI_MFM_P3_Amount__c,ASI_MFM_P4_Amount__c,
            ASI_MFM_P5_Amount__c,ASI_MFM_P6_Amount__c,
            ASI_MFM_P7_Amount__c,ASI_MFM_P8_Amount__c,
            ASI_MFM_P9_Amount__c,ASI_MFM_P10_Amount__c,
            ASI_MFM_P11_Amount__c,ASI_MFM_P12_Amount__c,
            ASI_MFM_Sub_brand_Code__c, 
            ASI_MFM_Customer_Name__c,
            ASI_MFM_Type__c,
            ASI_MFM_A_C_Code__c,
            ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c,
            ASI_MFM_A_C_Code__r.Name,
            ASI_MFM_Size__c
            from ASI_MFM_Budget__c 
            where ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c = 'Spending per Bottle' and ASI_MFM_Fiscal_Year__c = :planTemp.ASI_MFM_Fiscal_year__c and ASI_MFM_Type__c = :budgetTypeFromCustomSet
        ]; 
        // Fix 10 ends       
        
        //Grouping the list by Sub_brand_code and Customer_Name 
        budgetSummaryList_start= [select 
                                  id, 
                                  ASI_MFM_Sub_brand_Code__c,
                                  ASI_MFM_Customer_Name__c,
                                  ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Description__c,                                       //brand
                                  ASI_MFM_Customer_Name__r.ASI_MFM_Customer_Supplier_Number__c,ASI_MFM_Customer_Name__r.Name,   //OutletType/Customers
                                  ASI_MFM_Number_of_Outlets__c,
                                  ASI_MFM_Expected_Volume__c,
                                  ASI_MFM_Total_Cost__c,ASI_MFM_A_C_Code__r.name, 
                                  ASI_MFM_Quantity__c,ASI_MFM_List_Item_Description__c,ASI_MFM_Sub_brand_Code__r.name,             //FOC quantity
                                  ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Description__c,ASI_MFM_Size__c,                                   //Size
                                  ASI_MFM_Month_1_Cost__c,
                                  ASI_MFM_Month_2_Cost__c,
                                  ASI_MFM_Month_3_Cost__c,
                                  ASI_MFM_Month_4_Cost__c,    
                                  ASI_MFM_Month_5_Cost__c,
                                  ASI_MFM_Month_6_Cost__c,
                                  //        ASI_MFM_Month_7_Cost__c,
                                  ASI_MFM_Month_8_Cost__c,
                                  ASI_MFM_Month_9_Cost__c,
                                  ASI_MFM_Month_10_Cost__c,
                                  ASI_MFM_Month_11_Cost__c,
                                  ASI_MFM_Month_12_Cost__c,
                                  ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c,
                                  ASI_MFM_A_C_Code__r.ASI_MFM_A_and_P_Tree__c,                                                         //Version 0.0.6         
                                  ASI_MFM_A_C_Code__c,
                                  ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c,                                              //Version 0.0.8   
                                  ASI_MFM_Plan_Line_Item__c.ASI_MFM_FOC_Size__c                                          
                                  from ASI_MFM_Plan_Line_Item__c where ASI_MFM_Plan__c =: headerId   
                                  order by ASI_MFM_Customer_Name__c,ASI_MFM_Sub_brand_Code__c,ASI_MFM_Size__c
                                 ];
        
        budgetSummaryListSame = budgetSummaryList_start;
        
        //All budget except the budget per bottle
        while(budgetSummaryList_start.size() != 0){
            System.debug('ListSize ' + budgetSummaryList_start.size());
            
            CheckName = true;
            //Handle the Grouping
            customerName = budgetSummaryList_start[0].ASI_MFM_Customer_Name__c;
            subBrandCode = budgetSummaryList_start[0].ASI_MFM_Sub_brand_Code__c;
            size = budgetSummaryList_start[0].ASI_MFM_Size__c;
            apTree = budgetSummaryList_start[0].ASI_MFM_A_C_Code__r.ASI_MFM_A_and_P_Tree__c;
            
            System.debug('size: ' + size);
            
            for(ASI_MFM_Plan_Line_Item__c bugCheck :budgetSummaryListCheckName){
                if(customerName == bugCheck.ASI_MFM_Customer_Name__c &&
                   subBrandCode == bugCheck.ASI_MFM_Sub_brand_Code__c &&
                   size == bugCheck.ASI_MFM_Size__c &&
                   apTree == bugCheck.ASI_MFM_A_C_Code__r.ASI_MFM_A_and_P_Tree__c){
                       CheckName = false;
                       break;
                   }
            }
            System.debug('budgetSummaryList_start[0]: ' + budgetSummaryList_start[0].ASI_MFM_A_C_Code__r.ASI_MFM_A_and_P_Tree__c);             
            System.debug('CheckName : ' + CheckName);           
            System.debug('size: ' + size);
            ASI_MFM_Plan_Line_Item__c bugTemp = new ASI_MFM_Plan_Line_Item__c();
            bugTemp = budgetSummaryList_start[0];
            bugTemp.ASI_MFM_Month_1_Cost__c = 0;                
            bugTemp.ASI_MFM_Month_2_Cost__c = 0;                
            bugTemp.ASI_MFM_Month_3_Cost__c = 0;            //FOC Cost(Not display)
            bugTemp.ASI_MFM_Month_4_Cost__c = 0;            //FOC Quantity(Not display)
            bugTemp.ASI_MFM_Month_5_Cost__c = 0;            //Spending per Bottle - FOC 
            bugTemp.ASI_MFM_Month_6_Cost__c = 0;                
            //           bugTemp.ASI_MFM_Month_7_Cost__c = 0;        
            bugTemp.ASI_MFM_Month_8_Cost__c = 0;        
            bugTemp.ASI_MFM_Month_9_Cost__c = 0;                
            bugTemp.ASI_MFM_Month_10_Cost__c = 0;
            bugTemp.ASI_MFM_Month_11_Cost__c = 0;                
            bugTemp.ASI_MFM_Month_12_Cost__c = 0; 
            
            if(bugTemp.ASI_MFM_Number_of_Outlets__c == null){
                bugTemp.ASI_MFM_Number_of_Outlets__c = 0;
            }
            
            System.debug('kby3');
            System.debug('bugTemp.ASI_MFM_A_C_Code__r.ASI_MFM_A_and_P_Tree__c:' + bugTemp.ASI_MFM_A_C_Code__r.ASI_MFM_A_and_P_Tree__c);
            
            if(bugTemp.ASI_MFM_A_C_Code__c != null){
                if(bugTemp.ASI_MFM_A_C_Code__r.ASI_MFM_A_and_P_Tree__c == 'Total A&D'){
                    if(bugTemp.ASI_MFM_Total_Cost__c != null && bugTemp.ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c == '5210.STK1'){
                        bugTemp.ASI_MFM_Month_3_Cost__c = bugTemp.ASI_MFM_Total_Cost__c;
                    }
                    
                    
                    //Initialize the value of FOC quantity Version 0.0.7
                    
                    if(bugTemp.ASI_MFM_Quantity__c != null
                       && bugTemp.ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c == '5210.STK1' 
                       && (bugTemp.ASI_MFM_List_Item_Description__c.substringBefore('-').trim() == bugTemp.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c.trim())  //Version 0.0.8
                       && bugTemp.ASI_MFM_Size__c == bugTemp.ASI_MFM_FOC_Size__c){   
                           bugTemp.ASI_MFM_Month_4_Cost__c = bugTemp.ASI_MFM_Quantity__c;
                       }
                    
                    //Initialize the value of Cash Cost Version 0.0.7
                    if(bugTemp.ASI_MFM_Total_Cost__c != null
                       && bugTemp.ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c.startsWith('5220')){
                           //&& bugTemp.ASI_MFM_List_Item_Description__c.substringBefore('-') == bugTemp.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Description__c){
                           bugTemp.ASI_MFM_Month_6_Cost__c = bugTemp.ASI_MFM_Total_Cost__c;
                           System.debug('kgb62 ASI_MFM_Month_6_Cost__c' + bugTemp.ASI_MFM_Month_6_Cost__c);
                       }
                    
                }else{
                    System.debug('bugTemp.ASI_MFM_Total_Cost__c:'+ bugTemp.ASI_MFM_Total_Cost__c);
                    System.debug('bugTemp.ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c：' + bugTemp.ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c);
                    if((bugTemp.ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c == '5551.0001' 
                        || bugTemp.ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c == '5553.0001' 
                        || bugTemp.ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c == '5555.0004' 
                        || bugTemp.ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c == '5556.0005'
                        || bugTemp.ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c == '5557.0004'
                        || bugTemp.ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c == '5559.0003') 
                       && (bugTemp.ASI_MFM_Total_Cost__c != null)){
                           bugTemp.ASI_MFM_Month_3_Cost__c = bugTemp.ASI_MFM_Total_Cost__c;  //FOC Cost(Not Display)
                       }                    
                    System.debug('bugTemp.ASI_MFM_Month_3_Cost__c：' + bugTemp.ASI_MFM_Month_3_Cost__c);
                    
                    if(bugTemp.ASI_MFM_List_Item_Description__c != null){
                        if((bugTemp.ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c == '5551.0001' 
                            || bugTemp.ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c == '5553.0001' 
                            || bugTemp.ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c == '5555.0004' 
                            || bugTemp.ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c == '5556.0005'
                            || bugTemp.ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c == '5557.0004'
                            || bugTemp.ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c == '5559.0003') 
                           && (bugTemp.ASI_MFM_List_Item_Description__c.substringBefore('-').trim() == bugTemp.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c.trim())  //Version 0.0.8
                           && bugTemp.ASI_MFM_Size__c  == bugTemp.ASI_MFM_FOC_Size__c
                           && (bugTemp.ASI_MFM_Quantity__c != null)){
                               bugTemp.ASI_MFM_Month_4_Cost__c = bugTemp.ASI_MFM_Quantity__c;     //FOC Quantity
                           }                                  
                    }
                    System.debug('bugTemp.ASI_MFM_Month_4_Cost__c ：' + bugTemp.ASI_MFM_Month_4_Cost__c );
                    
                    System.debug('kby3.1');
                    //Initialize the value of Cash Cost Version 0.0.7
                    if(bugTemp.ASI_MFM_Total_Cost__c != null
                       && (bugTemp.ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c != '5551.0001' 
                           && bugTemp.ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c != '5553.0001' 
                           && bugTemp.ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c != '5555.0004' 
                           && bugTemp.ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c != '5556.0005'
                           && bugTemp.ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c != '5557.0004'
                           && bugTemp.ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c != '5559.0003')){
                               bugTemp.ASI_MFM_Month_6_Cost__c = bugTemp.ASI_MFM_Total_Cost__c;
                               System.debug('kgb62 ASI_MFM_Month_6_Cost__c' + bugTemp.ASI_MFM_Month_6_Cost__c);
                           }                       
                }               
            }
            
            System.debug('kby3.3');
            
            if(bugTemp.ASI_MFM_Expected_Volume__c == null){
                bugTemp.ASI_MFM_Expected_Volume__c = 0;
            }
            
            System.debug('kby2');
            //If not appear in the List
            if(CheckName == true){  
                for(ASI_MFM_Plan_Line_Item__c bug: budgetSummaryList_start){                                           
                    if(bug.id != bugTemp.id && 
                       bug.ASI_MFM_A_C_Code__r.ASI_MFM_A_and_P_Tree__c == bugTemp.ASI_MFM_A_C_Code__r.ASI_MFM_A_and_P_Tree__c && 
                       bug.ASI_MFM_Customer_Name__c == customerName &&
                       bug.ASI_MFM_Sub_brand_Code__c == subBrandCode &&
                       bug.ASI_MFM_Size__c == size){  
                           
                           System.debug('kby9');
                           if(bug.ASI_MFM_Number_of_Outlets__c != null){
                               bugTemp.ASI_MFM_Number_of_Outlets__c += bug.ASI_MFM_Number_of_Outlets__c;               
                           }
                           
                           System.debug('kby10');
                           if(bug.ASI_MFM_Expected_Volume__c != null){
                               bugTemp.ASI_MFM_Expected_Volume__c += bug.ASI_MFM_Expected_Volume__c;      //Target Volume
                           }
                           
                           System.debug('kgb3 ' + bug.ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c);
                           if(bug.ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c != null){
                               if(bugTemp.ASI_MFM_A_C_Code__r.ASI_MFM_A_and_P_Tree__c == 'Total A&D'){
                                   
                                   if(bug.ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c == '5210.STK1' && (bug.ASI_MFM_Total_Cost__c != null)){
                                       bugTemp.ASI_MFM_Month_3_Cost__c += bug.ASI_MFM_Total_Cost__c;  //FOC Cost(Not Display)
                                   }
                                   
                                   System.debug('kby4');
                                   if(bug.ASI_MFM_List_Item_Description__c != null){
                                       if(bug.ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c == '5210.STK1' && 
                                          (bug.ASI_MFM_List_Item_Description__c.substringBefore('-').trim() == bug.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c.trim())  //Version 0.0.8
                                          && bug.ASI_MFM_Size__c  == bug.ASI_MFM_FOC_Size__c
                                          && (bug.ASI_MFM_Quantity__c != null)){
                                              bugTemp.ASI_MFM_Month_4_Cost__c += bug.ASI_MFM_Quantity__c;     //FOC Quantity
                                          }
                                       
                                   }
                                   
                                   if(bug.ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c.startsWith('5220') && (bug.ASI_MFM_Total_Cost__c != null)){
                                       System.debug('5220');
                                       System.debug('kby5.2');
                                       bugTemp.ASI_MFM_Month_6_Cost__c += bug.ASI_MFM_Total_Cost__c;    //Cash Cost(Not display)
                                   }                                
                                   
                               }else{
                                   if((bug.ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c == '5551.0001' 
                                       || bug.ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c == '5553.0001' 
                                       || bug.ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c == '5555.0004' 
                                       || bug.ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c == '5556.0005'
                                       || bug.ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c == '5557.0004'
                                       || bug.ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c == '5559.0003') 
                                      && (bug.ASI_MFM_Total_Cost__c != null)){
                                          bugTemp.ASI_MFM_Month_3_Cost__c += bug.ASI_MFM_Total_Cost__c;  //FOC Cost(Not Display)
                                      }
                                   
                                   System.debug('kby4');
                                   if(bug.ASI_MFM_List_Item_Description__c != null){
                                       if((bug.ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c == '5551.0001' 
                                           || bug.ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c == '5553.0001' 
                                           || bug.ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c == '5555.0004' 
                                           || bug.ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c == '5556.0005'
                                           || bug.ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c == '5557.0004'
                                           || bug.ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c == '5559.0003') 
                                          && (bug.ASI_MFM_List_Item_Description__c.substringBefore('-').trim() == bug.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c.trim())  //Version 0.0.8
                                          && bug.ASI_MFM_Size__c  == bug.ASI_MFM_FOC_Size__c
                                          && (bug.ASI_MFM_Quantity__c != null)){
                                              bugTemp.ASI_MFM_Month_4_Cost__c += bug.ASI_MFM_Quantity__c;     //FOC Quantity
                                          }
                                       
                                   }
                                   
                                   System.debug('kby5');
                                   //kby16-----Handle the null pointer reference of ASI_MFM_A_C_Code__c                      
                                   System.debug('kby5.1');
                                   if((bug.ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c != '5551.0001' 
                                       && bug.ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c != '5553.0001' 
                                       && bug.ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c != '5555.0004' 
                                       && bug.ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c != '5556.0005'
                                       && bug.ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c != '5557.0004'
                                       && bug.ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c != '5559.0003') 
                                      && (bug.ASI_MFM_Total_Cost__c != null)){
                                          System.debug('kby5.2');
                                          bugTemp.ASI_MFM_Month_6_Cost__c += bug.ASI_MFM_Total_Cost__c;    //Cash Cost(Not display)
                                      }                                 
                               }                      
                           }
                           
                       }           
                }
                
                //Modified by William Yang 2014-06-19
                //Spending per bottle - FOC
                //if(bugTemp.ASI_MFM_Month_4_Cost__c != 0 ||  bugTemp.ASI_MFM_Expected_Volume__c !=0){    //Version 0.0.6
                if(bugTemp.ASI_MFM_A_C_Code__r.ASI_MFM_A_and_P_Tree__c == 'Total A&D' && (bugTemp.ASI_MFM_Month_4_Cost__c != 0 ||  bugTemp.ASI_MFM_Expected_Volume__c !=0))
                    bugTemp.ASI_MFM_Month_5_Cost__c = bugTemp.ASI_MFM_Month_3_Cost__c/(bugTemp.ASI_MFM_Month_4_Cost__c + bugTemp.ASI_MFM_Expected_Volume__c);
                else if (bugTemp.ASI_MFM_A_C_Code__r.ASI_MFM_A_and_P_Tree__c == 'TOTAL A&P' && bugTemp.ASI_MFM_Expected_Volume__c != 0)
                    bugTemp.ASI_MFM_Month_5_Cost__c = bugTemp.ASI_MFM_Month_3_Cost__c/bugTemp.ASI_MFM_Expected_Volume__c;
                //}
                
                //Spending per bottle - Cash
                //if(bugTemp.ASI_MFM_Month_4_Cost__c != 0 || bugTemp.ASI_MFM_Expected_Volume__c != 0){
                System.debug('kgb54.02 ASI_MFM_Expected_Volume__c' + bugTemp.ASI_MFM_Month_4_Cost__c + bugTemp.ASI_MFM_Expected_Volume__c);
                if(bugTemp.ASI_MFM_A_C_Code__r.ASI_MFM_A_and_P_Tree__c == 'Total A&D' && (bugTemp.ASI_MFM_Month_4_Cost__c != 0 || bugTemp.ASI_MFM_Expected_Volume__c != 0))
                    bugTemp.ASI_MFM_Month_8_Cost__c = bugTemp.ASI_MFM_Month_6_Cost__c/(bugTemp.ASI_MFM_Month_4_Cost__c + bugTemp.ASI_MFM_Expected_Volume__c);
                else if (bugTemp.ASI_MFM_A_C_Code__r.ASI_MFM_A_and_P_Tree__c == 'TOTAL A&P' && bugTemp.ASI_MFM_Expected_Volume__c != 0)
                    bugTemp.ASI_MFM_Month_8_Cost__c = bugTemp.ASI_MFM_Month_6_Cost__c/bugTemp.ASI_MFM_Expected_Volume__c;
                
                //}
                //End 
                //Spending per bottle - Total
                bugTemp.ASI_MFM_Month_9_Cost__c = bugTemp.ASI_MFM_Month_5_Cost__c + bugTemp.ASI_MFM_Month_8_Cost__c;
                
                for(ASI_MFM_Budget__c budgetType: budgetTypeList){
                    // Fix 10 starts
                    if(budgetType.ASI_MFM_Sub_brand_Code__c == bugTemp.ASI_MFM_Sub_brand_Code__c
                       && budgetType.ASI_MFM_Customer_Name__c == bugTemp.ASI_MFM_Customer_Name__c
                       && budgetType.ASI_MFM_Size__c == bugTemp.ASI_MFM_Size__c) { 
                           // Fix 10 ends
                           if(budgetType.ASI_MFM_P1_Amount__c == null){
                               budgetType.ASI_MFM_P1_Amount__c = 0;
                           }
                           if(budgetType.ASI_MFM_P2_Amount__c == null){
                               budgetType.ASI_MFM_P2_Amount__c = 0;
                           }
                           if(budgetType.ASI_MFM_P3_Amount__c == null){
                               budgetType.ASI_MFM_P3_Amount__c = 0;
                           }
                           if(budgetType.ASI_MFM_P4_Amount__c == null){
                               budgetType.ASI_MFM_P4_Amount__c = 0;
                           }
                           if(budgetType.ASI_MFM_P5_Amount__c == null){
                               budgetType.ASI_MFM_P5_Amount__c = 0;
                           }
                           if(budgetType.ASI_MFM_P6_Amount__c == null){
                               budgetType.ASI_MFM_P6_Amount__c = 0;
                           }
                           if(budgetType.ASI_MFM_P7_Amount__c == null){
                               budgetType.ASI_MFM_P7_Amount__c = 0;
                           }
                           if(budgetType.ASI_MFM_P8_Amount__c == null){
                               budgetType.ASI_MFM_P8_Amount__c = 0;
                           }
                           if(budgetType.ASI_MFM_P9_Amount__c == null){
                               budgetType.ASI_MFM_P9_Amount__c = 0;
                           }
                           if(budgetType.ASI_MFM_P10_Amount__c == null){
                               budgetType.ASI_MFM_P10_Amount__c = 0;
                           }
                           if(budgetType.ASI_MFM_P11_Amount__c == null){
                               budgetType.ASI_MFM_P11_Amount__c = 0;
                           }
                           if(budgetType.ASI_MFM_P12_Amount__c == null){
                               budgetType.ASI_MFM_P12_Amount__c = 0;
                           }                 
                           if(bugTemp.ASI_MFM_A_C_Code__r.ASI_MFM_A_and_P_Tree__c == 'Total A&D')      
                               bugTemp.ASI_MFM_Month_10_Cost__c = bugTemp.ASI_MFM_Month_10_Cost__c + budgetType.ASI_MFM_P1_Amount__c; 
                           else
                               bugTemp.ASI_MFM_Month_10_Cost__c = 0;
                       }
                }
                System.debug('checkADPbugTemp:' + bugTemp);
                System.debug('bugTemp.ASI_MFM_A_C_Code__r.ASI_MFM_A_and_P_Tree__c:' + bugTemp.ASI_MFM_A_C_Code__r.ASI_MFM_A_and_P_Tree__c);
                
                budgetSummaryListCheckName.add(bugTemp);             
                if(bugTemp.ASI_MFM_A_C_Code__r.ASI_MFM_A_and_P_Tree__c == 'Total A&D'){
                    budgetSummaryListCheckNameAD.add(bugTemp);
                }else{
                    budgetSummaryListCheckNameAP.add(bugTemp); 
                }    
            }       
            budgetSummaryList_start.remove(0);  
            if(budgetSummaryListCheckNameAD != null && budgetSummaryListCheckNameAD.size()>0)
                hasADLineItems = true;
            if(budgetSummaryListCheckNameAP != null && budgetSummaryListCheckNameAP.size()>0)
                hasAPLineItems = true;
        }
        
        //Cost Estimate List
        costEstList = new List<ASI_MFM_Plan_Line_Item__c>();
        costEstListAD = new List<ASI_MFM_Plan_Line_Item__c>();
        costEstListAP = new List<ASI_MFM_Plan_Line_Item__c>();
        
        List<ASI_MFM_Plan_Line_Item__c> costEstListTemp = [select 
                                                           ASI_MFM_List_Item_Description__c,
                                                           ASI_MFM_Quantity__c,
                                                           ASI_MFM_A_C_Code__r.name,
                                                           ASI_MFM_A_C_Code__r.ASI_MFM_Reporting_Category__c,
                                                           ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Description__c,
                                                           ASI_MFM_Customer_Name__r.ASI_MFM_Customer_Supplier_Number__c,
                                                           ASI_MFM_Customer_Name__r.Name,
                                                           ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Description__c,
                                                           ASI_MFM_Sub_brand_Code__r.name,ASI_MFM_Total_Cost__c,
                                                           ASI_MFM_Print_Sequence__c,
                                                           ASI_MFM_Size__c, ASI_MFM_FOC_Size__c,
                                                           ASI_MFM_A_C_Code__r.ASI_MFM_A_and_P_Tree__c
                                                           , ASI_MFM_Sub_brand_Code__c
                                                           , ASI_MFM_A_C_Code__c
                                                           from ASI_MFM_Plan_Line_Item__c where ASI_MFM_Plan__c =: headerId
                                                           order by ASI_MFM_Print_Sequence__c, name
                                                          ];
        
        
        costEstTotal = 0;
        costEstTotalAD = 0;
        costEstTotalAP = 0;
        printList = new Map<String,printObj>(); //Leo@Elufa
        for(ASI_MFM_Plan_Line_Item__c cost: costEstListTemp){
            if(cost.ASI_MFM_Total_Cost__c != null){ 
                costEstTotal += cost.ASI_MFM_Total_Cost__c;
                
                if(cost.ASI_MFM_A_C_Code__r.ASI_MFM_A_and_P_Tree__c == 'Total A&D'){
                    costEstTotalAD += cost.ASI_MFM_Total_Cost__c;
                }else{
                    costEstTotalAP += cost.ASI_MFM_Total_Cost__c;
                }                
            }
            
            if(cost.ASI_MFM_Quantity__c == null){
                cost.ASI_MFM_Quantity__c = 0;
            }
            if(cost.ASI_MFM_Total_Cost__c == null){
                cost.ASI_MFM_Total_Cost__c = 0;
            }
            cost.ASI_MFM_List_Item_Description__c = breakStrings(cost.ASI_MFM_List_Item_Description__c.split(' ', -1), 28);
            costEstList.add(cost);
            
            if(cost.ASI_MFM_A_C_Code__r.ASI_MFM_A_and_P_Tree__c == 'Total A&D'){
                costEstListAD.add(cost);
            }else{
                costEstListAP.add(cost);
            }
            //Leo@Elufa
            if(cost.ASI_MFM_A_C_Code__r.ASI_MFM_A_and_P_Tree__c.contains('A&P'))
            {
                subBrandIds.add(cost.ASI_MFM_Sub_brand_Code__c);
                acCodeIds.add(cost.ASI_MFM_A_C_Code__c);
                if(!printList.containsKey(''+cost.ASI_MFM_Sub_brand_Code__c+cost.ASI_MFM_A_C_Code__c))
                {
                    printObj temp = new printObj();
                    temp.brand = cost.ASI_MFM_Sub_brand_Code__r.Name;
                    temp.acCode = cost.ASI_MFM_A_C_Code__r.Name;
                    temp.planAmt = cost.ASI_MFM_Total_Cost__c;
                    temp.budgetAmt = 0;
                    temp.hasBudget = false;
                    temp.leAmt = 0;
                    temp.hasLE = false;
                    
                    if(cost.ASI_MFM_A_C_Code__r.ASI_MFM_Reporting_Category__c=='Trade'){
                        isRenderTradeAP=true;
                        temp.ReportingCategory='1';
                    }else{
                        temp.ReportingCategory='2';
                        isRenderMKTAP=true;
                    }
                   
                    printList.put(''+cost.ASI_MFM_Sub_brand_Code__c+cost.ASI_MFM_A_C_Code__c, temp);
                }//end if
                else
                {
                    printObj temp = printList.get(''+cost.ASI_MFM_Sub_brand_Code__c+cost.ASI_MFM_A_C_Code__c);
                    temp.planAmt += cost.ASI_MFM_Total_Cost__c;
                }
            }//end if
            //Leo@Elufa
        }
        targetVolumeTotal = 0;
        targetVolumeTotalAD = 0;
        targetVolumeTotalAP = 0;
        for (ASI_MFM_Plan_Line_Item__c sumVolume : budgetSummaryListCheckName)
        {
            if(sumVolume.ASI_MFM_Expected_Volume__c != null){
                targetVolumeTotal += sumVolume.ASI_MFM_Expected_Volume__c;
                
                if(sumVolume.ASI_MFM_A_C_Code__r.ASI_MFM_A_and_P_Tree__c == 'Total A&D'){
                    targetVolumeTotalAD += sumVolume.ASI_MFM_Expected_Volume__c;
                }else{
                    targetVolumeTotalAP += sumVolume.ASI_MFM_Expected_Volume__c;
                }                  
            }
        }
        //Elufa@Leo        
        String FY = planTemp.ASI_MFM_Fiscal_year__c;
        String bType = 'LE4';
        List<ASI_MFM_Budget_Setting__c> bSetting = [SELECT ASI_MFM_Fiscal_Year__c
                                                    ,ASI_MFM_Budget_Type__c
                                                    FROM ASI_MFM_Budget_Setting__c
                                                    WHERE Name = 'TW'
                                                    LIMIT 1];
        if(bSetting.size()>0 && FY.equals(bSetting[0].ASI_MFM_Fiscal_Year__c))
            bType = bSetting[0].ASI_MFM_Budget_Type__c;
        
        planLines = [SELECT 
                     ASI_MFM_Sub_brand_Code__c
                     , ASI_MFM_Sub_brand_Code__r.Name
                     , ASI_MFM_A_C_Code__c
                     , ASI_MFM_A_C_Code__r.Name
                     , ASI_MFM_Total_Cost__c
                     FROM ASI_MFM_Plan_Line_Item__c
                     WHERE ASI_MFM_Plan__c !=: headerId
                     AND ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c =: FY
                     AND ASI_MFM_Plan__r.ASI_MFM_Status__c != 'Draft'
                     AND ASI_MFM_A_C_Code__c IN: acCodeIds
                     AND ASI_MFM_Sub_brand_Code__c IN: subBrandIds
                     AND ASI_MFM_A_C_Code__r.ASI_MFM_A_and_P_Tree__c LIKE '%A&P%'];
        
        for(ASI_MFM_Plan_Line_Item__c line: planLines)
        {
            if(printList.containsKey(''+line.ASI_MFM_Sub_brand_Code__c+line.ASI_MFM_A_C_Code__c))
            {
                printObj temp = printList.get(''+line.ASI_MFM_Sub_brand_Code__c+line.ASI_MFM_A_C_Code__c);
                temp.planAmt += line.ASI_MFM_Total_Cost__c;
            }
        }
        
        //---get budget---//
        if(acCodeIds.size() > 0 && subBrandIds.size() > 0 && FY != '' && FY != null)
        {
            budgetList = [SELECT id, Name
                          , ASI_MFM_Total_Amount__c
                          , ASI_MFM_Type__c
                          , ASI_MFM_A_C_Code__c
                          , ASI_MFM_Sub_brand_Code__c
                          FROM ASI_MFM_Budget__c
                          WHERE ASI_MFM_Fiscal_Year__c =: FY
                          AND (ASI_MFM_Type__c =: bType 
                               OR ASI_MFM_Type__c = 'Budget')
                          AND ASI_MFM_A_C_Code__c IN: acCodeIds
                          AND ASI_MFM_Sub_brand_Code__c IN: subBrandIds];
        }//end if
        //---loooop budget---//
        if(budgetList !=null && budgetList.size() > 0)
        {
            for(ASI_MFM_Budget__c budgetRec: budgetList)
            {
                if(printList.containsKey(''+budgetRec.ASI_MFM_Sub_brand_Code__c+budgetRec.ASI_MFM_A_C_Code__c))
                {
                    printObj temp = printList.get(''+budgetRec.ASI_MFM_Sub_brand_Code__c+budgetRec.ASI_MFM_A_C_Code__c);
                    if(budgetRec.ASI_MFM_Type__c == 'Budget')
                    {
                        temp.budgetAmt += budgetRec.ASI_MFM_Total_Amount__c;
                        temp.hasBudget = true;
                    }
                    else if(budgetRec.ASI_MFM_Type__c.contains('LE'))
                    {
                        temp.leAmt += budgetRec.ASI_MFM_Total_Amount__c;
                        temp.hasLE = true;
                    }
                }//end if
            }//end for
        }//end if
        return true;
        //Elufa@Leo
        return true;
    }
    
    public class printObj
    {
        public String brand {get;set;}
        public String acCode {get;set;}
        public Decimal budgetAmt {get;set;}
        public Boolean hasBudget {get;set;}
        public Decimal planAmt {get;set;}
        public Decimal leAmt {get;set;}
        public Boolean hasLE {get;set;}
        public String ReportingCategory {get;set;}
    }//end inner class
    
    
    //Approval History
    public Class approvalDetail
    {
        public ProcessInstanceHistory history{get;set;}
        public String title{get;set;}
        public String status{get;set;}
        public String department{get;set;}
    }//end class
    
    public List<approvalDetail> getapprovalDetails()
    {
        List<approvalDetail> details = new List<approvalDetail>();
        if (details.size() == 0 && headerId != null && hasHistroy)
        {
            List<ProcessInstance> pList = [SELECT Id, 
                                           (SELECT Id,
                                            CreatedDate,
                                            StepStatus,
                                            Comments,
                                            ActorId,
                                            Actor.Name,
                                            OriginalActorId,
                                            OriginalActor.Name
                                            FROM StepsAndWorkitems
                                            ORDER BY CreatedDate DESC,
                                            StepStatus DESC)
                                           FROM ProcessInstance
                                           WHERE TargetObjectId = : headerId
                                           ORDER BY CreatedDate DESC
                                           Limit 1];
            if(pList.size()>0)
                hasHistroy = true;
            Set<Id> actoerIdSet = new Set<Id>();
            for (ProcessInstance p:pList)
            {
                for (ProcessInstanceHistory his:p.StepsAndWorkitems)
                {
                    actoerIdSet.add(his.ActorId);
                }//end for
            }//end for
            Map<Id, User> userMap = new Map<Id, User>([Select Id, title, department From User Where Id In :actoerIdSet]);
            for (ProcessInstance p:pList)
            {
                Boolean byPassPending = false;
                if(p.StepsAndWorkitems.size() != 0 
                   &&(p.StepsAndWorkitems[0].StepStatus == 'Approved'
                      ||p.StepsAndWorkitems[0].StepStatus == 'Rejected'))
                {
                    byPassPending = true;
                }//end if
                for (ProcessInstanceHistory his:p.StepsAndWorkitems)
                {
                    if(his.StepStatus != 'Reassigned'
                       && his.StepStatus != 'NoResponse'
                       &&!(byPassPending && his.StepStatus == 'Pending'))
                    {
                        approvalDetail detail = new approvalDetail();
                        if(his.StepStatus == 'Removed')
                            detail.status = 'Recalled';
                        else if(his.StepStatus == 'Started')
                            detail.status = 'Started By:';
                        else if(his.StepStatus == 'Approved')
                            detail.status = 'Approved By:';
                        else
                            detail.status = his.StepStatus;
                        
                        detail.title = userMap.get(his.ActorId).title;
                        detail.department = userMap.get(his.ActorId).department;
                        detail.history = his;
                        details.add(detail);
                    }//end if
                }//end for
            }//end for
        }//end if
        return details;
    }//end method: getapprovalDetails
}