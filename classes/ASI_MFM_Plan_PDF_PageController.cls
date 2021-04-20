public class ASI_MFM_Plan_PDF_PageController {


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
    public List<ASI_MFM_Plan_Line_Item__c> budgetSummaryListSame{get;set;}
    public List<ASI_MFM_Plan_Line_Item__c> budgetSummaryList3{get;set;}
    public List<ASI_MFM_Plan_Line_Item__c> budgetSummaryList{get;set;}
    public List<ASI_MFM_Plan_Line_Item__c> costEstList{get;set;}
    public String verifiedBy{get;set;}
    public decimal costEstTotal{get;set;}
    public ASI_MFM_Plan__c planTemp{get;set;}
    public decimal targetVolumeTotal{get;set;}
    
    
    
    public List<ASI_MFM_Budget__c> budgetTypeList;
    public string customerName;
    public string subBrandCode;
    public string size;
    public string country;
    public string budgetTypeFromCustomSet;
    public boolean CheckName;
    // Start fix 11
    public String planName{get;set;}
    public String planDescription{get;set;}
    public String targetSector{get;set;}
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
    
    public ASI_MFM_Plan_PDF_PageController(ApexPages.StandardController stdController){
        
        this.Plan = (ASI_MFM_Plan__c)stdController.getRecord();
        
        //Render Activity time
        if(Plan.ASI_MFM_Start_Date__c == null && Plan.ASI_MFM_End_Date__c == null){
            isRenderActivityTime = false;
        }
        else{
            isRenderActivityTime = true;
        }
        
        
        //Hidden or show the budget 
        budgetSummaryList_start = new List<ASI_MFM_Plan_Line_Item__c>();
        budgetSummaryListCheckName = new List<ASI_MFM_Plan_Line_Item__c>();
        budgetSummaryListSame = new List<ASI_MFM_Plan_Line_Item__c>();  
        budgetSummaryList3 = new List<ASI_MFM_Plan_Line_Item__c>(); 
        budgetSummaryList = new List<ASI_MFM_Plan_Line_Item__c>();
        
        
        boolean stopLoop = false;
        integer oldMapSize = 0;
        integer newMapSize = 0;
        ASI_MFM_Plan_Line_Item__c budget = new ASI_MFM_Plan_Line_Item__c();
        
        //Plan Country (Not Display)
        planTemp = [select ASI_MFM_Prefix__r.ASI_MFM_country_name__c, ASI_MFM_Prefix__r.Plan_Type__c, ASI_MFM_Fiscal_year__c,
        ASI_MFM_Plan_Name__c, ASI_MFM_Plan_Description__c, ASI_MFM_Target_Sector__c 
        from ASI_MFM_Plan__c where id =: this.Plan.id];
        country = planTemp.ASI_MFM_Prefix__r.ASI_MFM_country_name__c;
        
        //Controll the budget vs Summary rendering
        if(planTemp.ASI_MFM_Prefix__r.Plan_Type__c == 'Marketing A&P Plan' || planTemp.ASI_MFM_Prefix__r.Plan_Type__c == 'Marketing A&P Plan - Cross Brand' ||
        planTemp.ASI_MFM_Prefix__r.Plan_Type__c == 'Trade A&P Plan' ||  planTemp.ASI_MFM_Prefix__r.Plan_Type__c == 'BC Type Plan'){
            isRenderBudget = false;
        }
        else{
            isRenderBudget = true;
        }
        
        //Start fix 11
        String planNameTemp = '';
        String planDescriptionTemp = '';
        String targetSectorTemp = '';
        if (planTemp.ASI_MFM_Plan_Name__c != null)
            planNameTemp = planTemp.ASI_MFM_Plan_Name__c;
        if (planTemp.ASI_MFM_Plan_Description__c != null)
            planDescriptionTemp = planTemp.ASI_MFM_Plan_Description__c;
        if (planTemp.ASI_MFM_Target_Sector__c != null)
            targetSectorTemp = planTemp.ASI_MFM_Target_Sector__c;
            
        String[] arrayPlanName = planNameTemp .split(' ', -1);
        String[] arrayPlanDescription = planDescriptionTemp .split(' ', -1);
        String[] arrayTargetSector = targetSectorTemp.split(' ', -1);
        planName = breakStrings(arrayPlanName, 97);
        planDescription = breakStrings(arrayPlanDescription, 97);
        targetSector = breakStrings(arrayTargetSector, 83);
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
            System.debug('1');
            verifiedBy = 'N/A';
        }
        else{
            verifiedBy = '';
            System.debug('2');
        }
        
        System.debug('VerifiedBy ' + VerifiedBy);
        
        System.debug('Enter budget Summary');
// Fix 10 starts 
/*       
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
        ASI_MFM_A_C_Code__r.Name
        from ASI_MFM_Budget__c where ASI_MFM_Plan__c =: this.Plan.id
        ];
*/        
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
        ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c,                                                         //Version 0.0.6         
        ASI_MFM_A_C_Code__c,
        ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c,                                              //Version 0.0.8   
        ASI_MFM_Plan_Line_Item__c.ASI_MFM_FOC_Size__c                                          
        from ASI_MFM_Plan_Line_Item__c where ASI_MFM_Plan__c =: this.Plan.id    
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
            
            for(ASI_MFM_Plan_Line_Item__c bugCheck :budgetSummaryListCheckName){
                if(customerName == bugCheck.ASI_MFM_Customer_Name__c &&
                   subBrandCode == bugCheck.ASI_MFM_Sub_brand_Code__c &&
                   size == bugCheck.ASI_MFM_Size__c){
                    CheckName = false;
                    break;
                 }
            }

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
            
            System.debug('kby1');
            
            if(bugTemp.ASI_MFM_Number_of_Outlets__c == null){
                bugTemp.ASI_MFM_Number_of_Outlets__c = 0;
            }
            
            System.debug('kby2');
            
            if(bugTemp.ASI_MFM_A_C_Code__c != null){
                if(bugTemp.ASI_MFM_Total_Cost__c != null && bugTemp.ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c == '5210.STK1'){
                    bugTemp.ASI_MFM_Month_3_Cost__c = bugTemp.ASI_MFM_Total_Cost__c;
                }
            }
            
            System.debug('kby3');
            //Initialize the value of FOC quantity Version 0.0.7
            
            if(bugTemp.ASI_MFM_Quantity__c != null
               && bugTemp.ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c == '5210.STK1' 
               && (bugTemp.ASI_MFM_List_Item_Description__c.substringBefore('-').trim() == bugTemp.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c.trim())  //Version 0.0.8
               && bugTemp.ASI_MFM_Size__c == bugTemp.ASI_MFM_FOC_Size__c){   
                bugTemp.ASI_MFM_Month_4_Cost__c = bugTemp.ASI_MFM_Quantity__c;
            }
            System.debug('kby3.1');
            //Initialize the value of Cash Cost Version 0.0.7
            if(bugTemp.ASI_MFM_A_C_Code__c != null){        
                if(bugTemp.ASI_MFM_Total_Cost__c != null
                   && bugTemp.ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c.startsWith('5220')){
                   //&& bugTemp.ASI_MFM_List_Item_Description__c.substringBefore('-') == bugTemp.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Description__c){
                    bugTemp.ASI_MFM_Month_6_Cost__c = bugTemp.ASI_MFM_Total_Cost__c;
                    System.debug('kgb62 ASI_MFM_Month_6_Cost__c' + bugTemp.ASI_MFM_Month_6_Cost__c);
                }
            
            System.debug('kby3.2');
                //Initialize the value of Cash Quantity
 /*               if(bugTemp.ASI_MFM_Quantity__c != null
                   && bugTemp.ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c.startsWith('5220') 
                   && bugTemp.ASI_MFM_List_Item_Description__c.substringBefore('-').trim() == bugTemp.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c
                   && bugTemp.ASI_MFM_Size__c  == bugTemp.ASI_MFM_FOC_Size__c){ //Version 0.0.8
                    bugTemp.ASI_MFM_Month_7_Cost__c = bugTemp.ASI_MFM_Quantity__c;
                    System.debug('kgb71 ASI_MFM_Month_7_Cost__c' + bugTemp.ASI_MFM_Month_7_Cost__c);
                }*/
            }           
            System.debug('kby3.3');
            
            if(bugTemp.ASI_MFM_Expected_Volume__c == null){
                bugTemp.ASI_MFM_Expected_Volume__c = 0;
            }
            
            System.debug('kby2');
            System.debug('CheckName' + CheckName);
            //If not appear in the List
            if(CheckName == true){  
                for(ASI_MFM_Plan_Line_Item__c bug: budgetSummaryList_start){  
                    if(bug.id != bugTemp.id && 
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
                        
                        System.debug('kby3');
                        System.debug('kgb3 ' + bug.ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c);
                        if(bug.ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c != null){
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
                        }
                        System.debug('kby5');

                        //kby16-----Handle the null pointer reference of ASI_MFM_A_C_Code__c
                        if(bug.ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c != null){
                            
                            System.debug('kby5.1');
                            
                            if(bug.ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c.startsWith('5220') && (bug.ASI_MFM_Total_Cost__c != null)){
                                System.debug('5220');
                                System.debug('kby5.2');
                                bugTemp.ASI_MFM_Month_6_Cost__c += bug.ASI_MFM_Total_Cost__c;    //Cash Cost(Not display)
                            }
                            
                            
                            System.debug('kby6');
                            //Null pointer exception '5220'
                          /*  if(bug.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c != null    //change field
                               && bug.ASI_MFM_List_Item_Description__c != null){
                                System.debug('kby6.1');
                                if(bug.ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c.startsWith('5220') &&
                                    bug.ASI_MFM_List_Item_Description__c.substringBefore('-').trim() == bug.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c 
                                    && bug.ASI_MFM_Size__c  == bug.ASI_MFM_FOC_Size__c && //Version 0.0.8
                                    (bug.ASI_MFM_Quantity__c != null)){
                                    System.debug('kby6.2');
                                    if(bug.ASI_MFM_Quantity__c != null){
                                        System.debug('kby6.3');
                                        
                                        bugTemp.ASI_MFM_Month_7_Cost__c += bug.ASI_MFM_Quantity__c;      //Cash Quantity(Not display)
                                    
                                    }
                                }
                            }*/
                        }
                        System.debug('kby5.2');                                 
                        
                    }           
                }
                System.debug('kby');

                
                //Spending per bottle - FOC
                if(bugTemp.ASI_MFM_Month_4_Cost__c != 0 ||  bugTemp.ASI_MFM_Expected_Volume__c !=0){    //Version 0.0.6
                    System.debug('kgb23 FOC Cost ' + bugTemp.ASI_MFM_Month_3_Cost__c);
                    System.debug('kgb23 FOC Quantity ' + bugTemp.ASI_MFM_Month_4_Cost__c + ' for number of outlets ' + bugTemp.ASI_MFM_Number_of_Outlets__c);
                    System.debug('kgb23 Cash Cost ' + bugTemp.ASI_MFM_Month_6_Cost__c);
                    System.debug('kgb23 Expected Volume ' + bugTemp.ASI_MFM_Expected_Volume__c);
                    bugTemp.ASI_MFM_Month_5_Cost__c = bugTemp.ASI_MFM_Month_3_Cost__c/(bugTemp.ASI_MFM_Month_4_Cost__c + bugTemp.ASI_MFM_Expected_Volume__c);
                    System.debug('kgb23 before decimal' + bugTemp.ASI_MFM_Month_5_Cost__c);
                    
                    //Version 0.0.8 Round off
                    //bugTemp.ASI_MFM_Month_5_Cost__c = bugTemp.ASI_MFM_Month_5_Cost__c.setScale(0,RoundingMode.HALF_UP);
                    
                    System.debug('kgb23 FOC value after update' + bugTemp.ASI_MFM_Month_5_Cost__c);
                }
                
                System.debug('kgb53');
               //System.debug('kgb53.1 ASI_MFM_Month_6_Cost__c' + bugTemp.ASI_MFM_Month_7_Cost__c);
                //Spending per bottle - Cash
                if(bugTemp.ASI_MFM_Month_4_Cost__c != 0 || bugTemp.ASI_MFM_Expected_Volume__c != 0){
                    System.debug('kgb52');
                    System.debug('kgb53 Cash Cost ' + bugTemp.ASI_MFM_Month_6_Cost__c);
                    System.debug('kgb54 FOC Quantity ' + bugTemp.ASI_MFM_Month_4_Cost__c);
                    System.debug('kgb54.02 ASI_MFM_Expected_Volume__c' + bugTemp.ASI_MFM_Month_4_Cost__c + bugTemp.ASI_MFM_Expected_Volume__c);
                    bugTemp.ASI_MFM_Month_8_Cost__c = bugTemp.ASI_MFM_Month_6_Cost__c/(bugTemp.ASI_MFM_Month_4_Cost__c + bugTemp.ASI_MFM_Expected_Volume__c);
                    
                    //Version 0.0.8 Round off
                    //bugTemp.ASI_MFM_Month_8_Cost__c = bugTemp.ASI_MFM_Month_8_Cost__c.setScale(0,RoundingMode.HALF_UP);
    
                    System.debug('kgb54.1 ASI_MFM_Month_8_Cost__c =' + bugTemp.ASI_MFM_Month_8_Cost__c);
                }
                
                //Spending per bottle - Total
                bugTemp.ASI_MFM_Month_9_Cost__c = bugTemp.ASI_MFM_Month_5_Cost__c + bugTemp.ASI_MFM_Month_8_Cost__c;
                                
                for(ASI_MFM_Budget__c budgetType: budgetTypeList){
// Fix 10 starts
                    if(budgetType.ASI_MFM_Sub_brand_Code__c == bugTemp.ASI_MFM_Sub_brand_Code__c
                    && budgetType.ASI_MFM_Customer_Name__c == bugTemp.ASI_MFM_Customer_Name__c
                    && budgetType.ASI_MFM_Size__c == bugTemp.ASI_MFM_Size__c) { 
//                    && budgetType.ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c == 'Spending per Bottle'
//                    && budgetType.ASI_MFM_Type__c == budgetTypeFromCustomSet){
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
                        bugTemp.ASI_MFM_Month_10_Cost__c = bugTemp.ASI_MFM_Month_10_Cost__c + budgetType.ASI_MFM_P1_Amount__c; /*+ budgetType.ASI_MFM_P2_Amount__c + budgetType.ASI_MFM_P3_Amount__c +
                        budgetType.ASI_MFM_P4_Amount__c + budgetType.ASI_MFM_P5_Amount__c + budgetType.ASI_MFM_P6_Amount__c + budgetType.ASI_MFM_P7_Amount__c +
                        budgetType.ASI_MFM_P8_Amount__c + budgetType.ASI_MFM_P9_Amount__c + budgetType.ASI_MFM_P10_Amount__c + budgetType.ASI_MFM_P11_Amount__c +budgetType.ASI_MFM_P12_Amount__c;*/
                        
                        //System.debug('ktd3'+)
                        /*
                        if ( bugTemp.ASI_MFM_Expected_Volume__c != 0){
                            System.debug('ktd1'+bugTemp.ASI_MFM_Month_10_Cost__c);
                            System.debug('ktd2'+bugTemp.ASI_MFM_Expected_Volume__c);
                            bugTemp.ASI_MFM_Month_10_Cost__c = bugTemp.ASI_MFM_Month_10_Cost__c/bugTemp.ASI_MFM_Expected_Volume__c;
                            //bugTemp.ASI_MFM_Month_10_Cost__c = bugTemp.ASI_MFM_Month_10_Cost__c.setScale(0,RoundingMode.HALF_UP);
                        }
                        */
                        
                    }
                }
                
                
                System.debug('kgb23.1 FOC value ' + bugTemp.ASI_MFM_Month_5_Cost__c);
                budgetSummaryListCheckName.add(bugTemp);    
                
                //Initialize all the value
                /*
                bugTemp.ASI_MFM_Month_3_Cost__c = 0;
                bugTemp.ASI_MFM_Month_4_Cost__c = 0;    
                bugTemp.ASI_MFM_Month_5_Cost__c = 0;
                bugTemp.ASI_MFM_Month_6_Cost__c = 0;
                bugTemp.ASI_MFM_Month_7_Cost__c = 0;
                bugTemp.ASI_MFM_Month_8_Cost__c = 0;
                bugTemp.ASI_MFM_Month_9_Cost__c = 0;
                bugTemp.ASI_MFM_Month_10_Cost__c = 0;
                bugTemp.ASI_MFM_Month_11_Cost__c = 0;
                bugTemp.ASI_MFM_Month_12_Cost__c = 0;  
                */
            }       
            budgetSummaryList_start.remove(0);  
        }
        //Map<Id,ASI_MFM_Plan_Line_Item__c> budgetSummaryMap = new Map<Id,ASI_MFM_Plan_Line_Item__c>();
        //for(ASI_MFM_Plan_Line_Item__c bud: budgetSummaryList1){
        //  System.debug('AssignMap');
        //  budgetSummaryMap.put(bud.id,bud);
        //}
        
        //The following codes is used to debug only
        for(ASI_MFM_Plan_Line_Item__c bug13: budgetSummaryListCheckName){
            System.debug('kgb37 ' + bug13.ASI_MFM_Month_5_Cost__c); 
            
        }

            
        //Cost Estimate List
        costEstList = new List<ASI_MFM_Plan_Line_Item__c>();
        
        List<ASI_MFM_Plan_Line_Item__c> costEstListTemp = [select 
        ASI_MFM_List_Item_Description__c,
        ASI_MFM_Quantity__c,
        ASI_MFM_A_C_Code__r.name,
        ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Description__c,
        ASI_MFM_Customer_Name__r.ASI_MFM_Customer_Supplier_Number__c,
        ASI_MFM_Customer_Name__r.Name,
        ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Description__c,
        ASI_MFM_Sub_brand_Code__r.name,ASI_MFM_Total_Cost__c,
        ASI_MFM_Print_Sequence__c,
        ASI_MFM_Size__c, ASI_MFM_FOC_Size__c
        from ASI_MFM_Plan_Line_Item__c where ASI_MFM_Plan__c =: this.Plan.id
        order by ASI_MFM_Print_Sequence__c, name
        ];
        
        
        costEstTotal = 0;
        for(ASI_MFM_Plan_Line_Item__c cost: costEstListTemp){
            if(cost.ASI_MFM_Total_Cost__c != null){ 
                costEstTotal += cost.ASI_MFM_Total_Cost__c;
            }

            if(cost.ASI_MFM_Quantity__c == null){
                cost.ASI_MFM_Quantity__c = 0;
            }
            if(cost.ASI_MFM_Total_Cost__c == null){
                cost.ASI_MFM_Total_Cost__c = 0;
            }
            cost.ASI_MFM_List_Item_Description__c = breakStrings(cost.ASI_MFM_List_Item_Description__c.split(' ', -1), 28);
            costEstList.add(cost);
        }
        targetVolumeTotal = 0;
        for (ASI_MFM_Plan_Line_Item__c sumVolume : budgetSummaryListCheckName)
        {
            if(sumVolume.ASI_MFM_Expected_Volume__c != null)
                targetVolumeTotal += sumVolume.ASI_MFM_Expected_Volume__c;
        }   
        
    }
    
    
    
}