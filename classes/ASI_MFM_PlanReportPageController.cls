public with sharing class ASI_MFM_PlanReportPageController {
//Updated at: 2013-6-11 12:16
//Version 0.0.3
//1.Removed the planId criteria from both budget amount and plan amount
    public final ASI_MFM_Plan__c Plan;
    public ASI_MFM_Plan__c planTemp{get;set;}
    public List<ASI_MFM_Plan_Line_Item__c> displayList{get;set;}
    public ASI_MFM_Plan_Line_Item__c planLineItemTemp;
    public decimal tempTotalAmount;
    public decimal tempPlanAmount;
    public decimal totalBudgetAmount{get;set;}  //display on the visual force page
    public decimal totalPlanAmount{get;set;}    //display on the visual force page
    public decimal totalAvailableBudget{get;set;}  //display on the visual force page
    public String fiscalYear;
    public String country;
    public string budgetTypeFromCustomSet;
    

    public ASI_MFM_PlanReportPageController(ApexPages.StandardController stdController){ 
        this.Plan = (ASI_MFM_Plan__c)stdController.getRecord();
        
        //Initialize value
        tempTotalAmount = 0;
        totalBudgetAmount = 0;
        tempPlanAmount = 0;
        totalPlanAmount = 0;
        totalAvailableBudget = 0;
        
        //1.Used to retrieved the fiscal year
        //2.Used to retrieved the budget type  
        planTemp = [select id,ASI_MFM_Prefix__r.ASI_MFM_country_name__c, ASI_MFM_Fiscal_year__c from ASI_MFM_Plan__c where id =: Plan.id];
        fiscalYear = planTemp.ASI_MFM_Fiscal_year__c;
        country = planTemp.ASI_MFM_Prefix__r.ASI_MFM_country_name__c;
        
        if (ASI_MFM_Budget_Type_Mappings__c.getInstance(country) == null)
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'No Mapping found for the country ' + country));
        else
            budgetTypeFromCustomSet = ASI_MFM_Budget_Type_Mappings__c.getInstance(country).ASI_MFM_Budget_Type__c;  
        
        System.debug('budgetTypeFromCustomSet: ' + budgetTypeFromCustomSet);
        
        displayList = new List<ASI_MFM_Plan_Line_Item__c>();
        
        //planlineItemList: All Plan Line Item of the Plan selected
        List<ASI_MFM_Plan_Line_Item__c> planlineItemList= [select id,ASI_MFM_Sub_brand_Code__c,ASI_MFM_Sub_brand_Code__r.Name,ASI_MFM_Month_1_Cost__c,ASI_MFM_Month_2_Cost__c,ASI_MFM_Month_3_Cost__c,
            ASI_MFM_Total_Cost__c from ASI_MFM_Plan_Line_Item__c where ASI_MFM_Plan__c =: Plan.id order by ASI_MFM_Sub_brand_Code__c];
        
        
        //planlineItemList2: All Plan Line Items of the selected Fiscal Year
        List<ASI_MFM_Plan_Line_Item__c> planlineItemList2= [select id,ASI_MFM_Sub_brand_Code__c,ASI_MFM_Sub_brand_Code__r.Name, ASI_MFM_Month_1_Cost__c,ASI_MFM_Month_2_Cost__c,ASI_MFM_Month_3_Cost__c,
        ASI_MFM_Total_Cost__c from ASI_MFM_Plan_Line_Item__c where ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c = :fiscalYear order by ASI_MFM_Sub_brand_Code__c];
               
        Map<Id,ASI_MFM_Plan_Line_Item__c> planItemMap = new Map<Id,ASI_MFM_Plan_Line_Item__c>();

        //Filter the sub brand id out and put into map
        Set<Id> subBrandId = new Set<Id>();
        
        for(ASI_MFM_Plan_Line_Item__c lc3: planlineItemList){
            planLineItemTemp = new ASI_MFM_Plan_Line_Item__c();
            planLineItemTemp = lc3;
            planLineItemTemp.ASI_MFM_Month_1_Cost__c = 0;
            planItemMap.put(planLineItemTemp.ASI_MFM_Sub_brand_Code__c,planLineItemTemp);
            subBrandId.add(planLineItemTemp.ASI_MFM_Sub_brand_Code__c);
        }
        
        System.debug('PlanItemMap.size: ' + planitemMap.values().size());

        
        //Select all the associated budget list of the specified Fiscal Year and Budget Type
        List<ASI_MFM_Budget__c> budgetList = [select id, ASI_MFM_Fiscal_Year__c,ASI_MFM_Sub_brand_Code__c,ASI_MFM_P1_Amount__c, ASI_MFM_P2_Amount__c,ASI_MFM_P3_Amount__c,
        ASI_MFM_P4_Amount__c,ASI_MFM_P5_Amount__c, ASI_MFM_P6_Amount__c,ASI_MFM_P7_Amount__c, ASI_MFM_P8_Amount__c,ASI_MFM_P9_Amount__c, ASI_MFM_P10_Amount__c,ASI_MFM_P11_Amount__c,
        ASI_MFM_P12_Amount__c,ASI_MFM_Plan__c, ASI_MFM_Type__c from ASI_MFM_Budget__c where ASI_MFM_Fiscal_Year__c =: fiscalYear and ASI_MFM_Type__c =: budgetTypeFromCustomSet and
        ASI_MFM_Sub_brand_Code__c in: subBrandId];
        
        System.debug('bugetList size: ' + budgetList.size());
        
        //Calculate Budget Amount
        for(ASI_MFM_Plan_Line_Item__c lc4: planItemMap.values()){
            //Inititalize the value to 0
            lc4.ASI_MFM_Month_1_Cost__c = 0;
            
            for(ASI_MFM_Budget__c bug:budgetList){
                if(bug.ASI_MFM_Sub_brand_Code__c == lc4.ASI_MFM_Sub_brand_Code__c && bug.ASI_MFM_Type__c == budgetTypeFromCustomSet){
                    System.debug('Matched Budget Sub-Brand and Type with Plan Line');
                    if(bug.ASI_MFM_P1_Amount__c != null){tempTotalAmount += bug.ASI_MFM_P1_Amount__c;}
                    if(bug.ASI_MFM_P2_Amount__c != null){tempTotalAmount += bug.ASI_MFM_P2_Amount__c;}
                    if(bug.ASI_MFM_P3_Amount__c != null){tempTotalAmount += bug.ASI_MFM_P3_Amount__c;}
                    if(bug.ASI_MFM_P4_Amount__c != null){tempTotalAmount += bug.ASI_MFM_P4_Amount__c;}
                    if(bug.ASI_MFM_P5_Amount__c != null){tempTotalAmount += bug.ASI_MFM_P5_Amount__c;}
                    if(bug.ASI_MFM_P6_Amount__c != null){tempTotalAmount += bug.ASI_MFM_P6_Amount__c;}
                    if(bug.ASI_MFM_P7_Amount__c != null){tempTotalAmount += bug.ASI_MFM_P7_Amount__c;}
                    if(bug.ASI_MFM_P8_Amount__c != null){tempTotalAmount += bug.ASI_MFM_P8_Amount__c;}
                    if(bug.ASI_MFM_P9_Amount__c != null){tempTotalAmount += bug.ASI_MFM_P9_Amount__c;}
                    if(bug.ASI_MFM_P10_Amount__c != null){tempTotalAmount += bug.ASI_MFM_P10_Amount__c;}
                    if(bug.ASI_MFM_P11_Amount__c != null){tempTotalAmount += bug.ASI_MFM_P11_Amount__c;}
                    if(bug.ASI_MFM_P12_Amount__c != null){tempTotalAmount += bug.ASI_MFM_P12_Amount__c;}        
                }
                //lc4.ASI_MFM_Month_1_Cost__c = budget amount of specified sub-brand
                lc4.ASI_MFM_Month_1_Cost__c += tempTotalAmount;
                tempTotalAmount = 0; 
            }
            totalBudgetAmount += lc4.ASI_MFM_Month_1_Cost__c;
            planItemMap.put(lc4.ASI_MFM_Sub_brand_Code__c,lc4);
            //Display on the total budget visual force page
        }
        
        //Plan Amount
        for(ASI_MFM_Plan_Line_Item__c lc5: planItemMap.values()){
            System.debug('Base Plan Line sub-brand Name' + lc5.ASI_MFM_Sub_brand_Code__r.Name);
            lc5.ASI_MFM_Month_2_Cost__c = 0;
            
            for(ASI_MFM_Plan_Line_Item__c pi3:planlineItemList2){
                System.debug('Queired Sub-brand Name' + pi3.ASI_MFM_Sub_brand_Code__r.Name);
                if(pi3.ASI_MFM_Sub_brand_Code__r.Name == lc5.ASI_MFM_Sub_brand_Code__r.Name){
                    System.debug('Matched sub-brand of Base Plan line with Queried Plan Line');
                    if(pi3.ASI_MFM_Total_Cost__c != null){
                        System.debug('Plan Line Amount: ' + pi3.ASI_MFM_Total_Cost__c);
                        lc5.ASI_MFM_Month_2_Cost__c += pi3.ASI_MFM_Total_Cost__c;
                    }   
                }
            }
            totalPlanAmount += lc5.ASI_MFM_Month_2_Cost__c;
            planItemMap.put(lc5.ASI_MFM_Sub_brand_Code__c,lc5);
        }
        
        //Available budget
        for(ASI_MFM_Plan_Line_Item__c lc6: planItemMap.values()){
            System.debug('Base Budget Amount: ' + lc6.ASI_MFM_Month_1_Cost__c);
            System.debug('Base Plan Amount: ' + lc6.ASI_MFM_Month_2_Cost__c);
            
            lc6.ASI_MFM_Month_3_Cost__c = 0;
            lc6.ASI_MFM_Month_3_Cost__c = lc6.ASI_MFM_Month_1_Cost__c - lc6.ASI_MFM_Month_2_Cost__c;
            
            System.debug('Base Available Budget: ' + lc6.ASI_MFM_Month_3_Cost__c); 
            
            totalAvailableBudget += lc6.ASI_MFM_Month_3_Cost__c;
            planItemMap.put(lc6.ASI_MFM_Sub_brand_Code__c,lc6);
        }
        displayList = planItemMap.values();
    }    
}