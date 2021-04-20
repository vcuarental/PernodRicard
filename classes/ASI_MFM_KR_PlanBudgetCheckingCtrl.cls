Global without sharing class ASI_MFM_KR_PlanBudgetCheckingCtrl{ 
    
    ApexPages.StandardController PlanController;
    Global  ASI_MFM_Plan__c thisPlan { get; set; }
    
    Global  ASI_MFM_KR_PlanBudgetCheckingCtrl(ApexPages.StandardController cnt) {
        this.PlanController = cnt;
        this.thisPlan = (ASI_MFM_Plan__c)this.PlanController.getRecord();
    }   
    
    Global  class wrapperClass{ 
        public String Code              {get; private set; }
        public String FY                {get; private set; }
        public String BudgetType        {get; private set; }
        public List<resultSet> results  {get; private set; }  
    }
    
    Global  class resultSet{
        public String SubBrandCode      {get; private set; }
        public String APType            {get; private set; }
        public String BrandGroup        {get; private set; }
        public Decimal TotalPlanAmount  {get; private set; }
        public Decimal BudgetAmount     {get; private set; }
        public Decimal Remaining        {get; private set; }
        public Decimal CommittedAmount  {get; private set; }
        public Decimal vsRemaining        {get; private set; }
        public Boolean Overbudget       {get; private set; }
        
        public resultSet(){
            this.TotalPlanAmount = 0;
            this.BudgetAmount = 0;
            this.CommittedAmount  = 0;                
        }
        
        public resultSet(String APType, String BrandGroup){
            this.APType = APType;
            this.BrandGroup = BrandGroup;
            this.TotalPlanAmount = 0;
            this.BudgetAmount = 0;
            this.CommittedAmount  = 0;                
        }
        
        public resultSet(String APType, String BrandGroup, String SubBrandCode){
            this.SubBrandCode = SubBrandCode;
            this.APType = APType;
            this.BrandGroup = BrandGroup;
            this.TotalPlanAmount = 0;
            this.BudgetAmount = 0;
            this.CommittedAmount  = 0;                
        }
        
        public resultSet(AggregateResult ar) {
            this.SubBrandCode = String.valueOf(ar.get('subBrand'));
            this.APType = String.valueOf(ar.get('APType'));
            this.BrandGroup = String.valueOf(ar.get('BrandGroup'));
            this.TotalPlanAmount = 0;
            this.BudgetAmount = 0;
            this.CommittedAmount  = 0;
        }
    }
    
    @RemoteAction
    Global static wrapperClass getresultSetByPlanId(String PlanId) {
        
        List<resultSet> results = new List<resultSet>();
        Map<String, resultSet> resultMap = new Map<String, resultSet>();
        Set<String> APTypes = new Set<String>();
        Set<String> BrandGroups = new Set<String>();
        Set<String> SubBrands = new Set<String>();
        
        String currentBudgetType = 'LE3';
        ASI_MFM_Plan__c thisPlan = new ASI_MFM_Plan__c ();
        
        if(PlanId!=null)
        {
            //Get current Header information
            thisPlan  = [ Select id , Name,  ASI_MFM_Status__c,ASI_MFM_Fiscal_year__c,ASI_MFM_Budget_Type__c,
                         ASI_MFM_Project_Code__c,ASI_MFM_Project_Code__r.ASI_MFM_Code__c 
                         from ASI_MFM_Plan__c where id=: PlanId];            
            
            //Get current Plan Lines information
            for (ASI_MFM_Plan_Line_Item__c  planLine: [Select id, ASI_MFM_AP_Code__r.ASI_MFM_AP_Type__c,
                                                       ASI_MFM_Total_Cost__c,
                                                       ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c,
                                                       ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.ASI_CRM_CN_Brand_Group_c__r.Name
                                                       from ASI_MFM_Plan_Line_Item__c 
                                                       where ASI_MFM_Plan__c=: PlanId 
                                                       and ASI_MFM_Sub_brand_Code__c!=null 
                                                       and ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__c!=null
                                                       and ASI_MFM_AP_Code__r.ASI_MFM_AP_Type__c !=null
                                                       and RecordType.DeveloperName like 'ASI_MFM_KR%'
                                                       Order By ASI_MFM_AP_Code__r.ASI_MFM_AP_Type__c, 
                                                       ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.ASI_CRM_CN_Brand_Group_c__r.Name]){
                                                           
                                                           system.debug('planLine - Current Plan: ' + planLine);  
                                                           String APType ='';
                                                           String BrandGrp ='';
                                                           String SubBrandCode ='';
                                                           
                                                           SubBrandCode = planLine.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c;
                                                           SubBrands.add(planLine.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c);
                                                           
                                                           
                                                           if(planLine.ASI_MFM_AP_Code__r.ASI_MFM_AP_Type__c!=null && !String.isEmpty(planLine.ASI_MFM_AP_Code__r.ASI_MFM_AP_Type__c)){
                                                               APTypes.add(planLine.ASI_MFM_AP_Code__r.ASI_MFM_AP_Type__c);
                                                               APType = planLine.ASI_MFM_AP_Code__r.ASI_MFM_AP_Type__c;
                                                           }
                                                           if(planLine.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.ASI_CRM_CN_Brand_Group_c__r.Name!=null && 
                                                              !String.isEmpty(planLine.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.ASI_CRM_CN_Brand_Group_c__r.Name)) {
                                                                  BrandGrp =  planLine.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.ASI_CRM_CN_Brand_Group_c__r.Name;
                                                                  BrandGroups.add(planLine.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.ASI_CRM_CN_Brand_Group_c__r.Name);
                                                              }
                                                           String key = APType + '_' + BrandGrp ;//+'_' + SubBrandCode;
                                                           resultSet summary = new resultSet(APType,BrandGrp,SubBrandCode);
                                                           if(resultMap.containsKey(key)){
                                                               summary = resultMap.get(key);
                                                           } 
                                                           summary.TotalPlanAmount  += planLine.ASI_MFM_Total_Cost__c!=null?planLine.ASI_MFM_Total_Cost__c:0;
                                                           resultMap.put(key, summary);
                                                       }
            
            
            
            
            system.debug('----------Common Factors---------');
            system.debug('APTypes: ' + APTypes);
            system.debug('BrandGroups: ' + BrandGroups);
            system.debug('SubBrands: ' + SubBrands);
            
            
            //Get Relevant Budget
            List<ASI_MFM_Budget_Setup__c > BudgetSetup= [Select id,name,ASI_MFM_Type__c from ASI_MFM_Budget_Setup__c 
                                                         where ASI_MFM_Fiscal_Year__c=:thisPlan.ASI_MFM_Fiscal_year__c  and ASI_MFM_Active__c= true and RecordType.DeveloperName ='ASI_MFM_KR_Budget_Setup' limit 1 ];
            
            if(BudgetSetup!=null && BudgetSetup.size()>0 ) currentBudgetType = BudgetSetup[0].ASI_MFM_Type__c;
            
            for (AggregateResult ar: [Select ASI_MFM_KR_AP_Type__c APType, 
                                      ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c subBrand,
                                      ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.ASI_CRM_CN_Brand_Group_c__r.Name BrandGroup, 
                                      SUM(ASI_MFM_Total_Amount__c)total  from ASI_MFM_Budget__c 
                                      where RecordType.DeveloperName='ASI_MFM_KR_Budget' 
                                      and ASI_MFM_KR_AP_Type__c in:APTypes
                                      and ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.ASI_CRM_CN_Brand_Group_c__r.Name in: BrandGroups
                                      and ASI_MFM_Fiscal_Year__c =:thisPlan.ASI_MFM_Fiscal_year__c 
                                      and ASI_MFM_Code__c =: thisPlan.ASI_MFM_Project_Code__c  
                                      and ASI_MFM_Type__c =: currentBudgetType 
                                      and ASI_MFM_Budget_Type__c =: thisPlan.ASI_MFM_Budget_Type__c
                                      and RecordType.DeveloperName like 'ASI_MFM_KR%'
                                      //and ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c in: SubBrands
                                      Group by ASI_MFM_KR_AP_Type__c,ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c, ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.ASI_CRM_CN_Brand_Group_c__r.Name
                                     ] ){
                                         
                                         system.debug('AggregateResult - Budget: ' + ar);
                                         String key = String.valueOf(ar.get('APType')) + '_' + String.valueOf(ar.get('BrandGroup'));//+ '_' + String.valueOf(ar.get('subBrand'));
                                         resultSet summary = new resultSet(ar);
                                         if(resultMap.containsKey(key)){
                                             summary = resultMap.get(key);
                                             summary.BudgetAmount  += Decimal.valueOf(ar.get('total')+'');
                                             resultMap.put(key, summary);
                                         }else continue;
                                         
                                     } 
            
            system.debug('ResultsMap: ' + resultMap.values());
            
            //Get other Approved Plan Lines information
            
            try {
                for (AggregateResult ar: [Select ASI_MFM_AP_Type__c  APType,
                                          ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c subBrand, 
                                          ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.ASI_CRM_CN_Brand_Group_c__r.Name BrandGroup,
                                          SUM(ASI_MFM_Total_Cost__c) total
                                          from ASI_MFM_Plan_Line_Item__c 
                                          where 
                                          //ASI_MFM_Plan__c !=: PlanId and
                                          ASI_MFM_Plan__r.ASI_MFM_Status__c = 'Approved'
                                          AND ASI_MFM_Plan__r.ASI_MFM_Fiscal_Year__c =:thisPlan.ASI_MFM_Fiscal_year__c 
                                          AND ASI_MFM_Plan__r.ASI_MFM_Project_Code__c =: thisPlan.ASI_MFM_Project_Code__c 
                                          AND ASI_MFM_Plan__r.ASI_MFM_Budget_Type__c =: thisPlan.ASI_MFM_Budget_Type__c 
                                          AND ASI_MFM_AP_Type__c in: APTypes  
                                          //AND ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c in: SubBrands
                                          AND ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.ASI_CRM_CN_Brand_Group_c__r.Name in: BrandGroups
                                          AND RecordType.DeveloperName like 'ASI_MFM_KR%'
                                          Group By ASI_MFM_AP_Type__c, ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c, ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.ASI_CRM_CN_Brand_Group_c__r.Name]){
                                              
                                              system.debug('AggregateResult - other Approved Plan: ' + ar);  
                                              String key = String.valueOf(ar.get('APType')) + '_' + String.valueOf(ar.get('BrandGroup'));//+ '_' + String.valueOf(ar.get('subBrand'));
                                              resultSet summary = new resultSet(ar);
                                              if(resultMap.containsKey(key)){
                                                  summary = resultMap.get(key);
                                                  summary.CommittedAmount  += Decimal.valueOf(ar.get('total')+'');
                                                  resultMap.put(key, summary);   
                                              }else continue;
                                              
                                          }
                
            } catch(Exception e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Too many records for Approved Plan Line Information.'));
            }    
            
            system.debug('ResultsMap: ' + resultMap.values());
            //Approved && Closed Plan 
            for(List<ASI_MFM_PO_Line_Item__c> POLineList: [select Id,Name,ASI_MFM_PO__r.ASI_MFM_Status__c,ASI_MFM_PO__r.ASI_MFM_Is_Direct_Payment__c,ASI_MFM_Base_Currency_Amount__c,ASI_MFM_Amount__c,
                                                           ASI_MFM_BaseCurrencyAmount__c,
                                                           ASI_MFM_AP_Code__r.ASI_MFM_AP_Type__c ,ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c,
                                                           ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.ASI_CRM_CN_Brand_Group_c__r.Name ,
                                                           (select Id, Name,ASI_MFM_Payment__r.ASI_MFM_Status__c,ASI_MFM_Paid_Amount_in_Base_Currency__c,ASI_MFM_Payment_Amount__c,ASI_MFM_Payment__r.ASI_MFM_Is_Direct_Payment__c from Payment_Line_Items__r 
                                                            where  ASI_MFM_Payment__r.ASI_MFM_Status__c !='Submitted' and 
                                                            ASI_MFM_Payment__r.ASI_MFM_Status__c !='Draft' and
                                                            ASI_MFM_Payment__r.ASI_MFM_Status__c !='Rejected')
                                                           from ASI_MFM_PO_Line_Item__c 
                                                           where 
                                                           //ASI_MFM_PO__r.ASI_MFM_Plan__c !=: PlanId and
                                                           ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Status__c = 'Closed' 
                                                           AND RecordType.DeveloperName like 'ASI_MFM_KR%'
                                                           AND ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Fiscal_Year__c =:thisPlan.ASI_MFM_Fiscal_year__c 
                                                           AND ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Project_Code__c =: thisPlan.ASI_MFM_Project_Code__c  
                                                           AND ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Budget_Type__c =: thisPlan.ASI_MFM_Budget_Type__c                                       
                                                           AND ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.ASI_CRM_CN_Brand_Group_c__r.Name in: BrandGroups 
                                                           AND ASI_MFM_AP_Code__r.ASI_MFM_AP_Type__c in: APTypes
                                                           //AND ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c in: SubBrands
                                                           Order by  ASI_MFM_PO__r.ASI_MFM_Plan__c, ASI_MFM_AP_Code__r.ASI_MFM_AP_Type__c, ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.ASI_CRM_CN_Brand_Group_c__r.Name
                                                          ]){
                                                              
                                                              for(ASI_MFM_PO_Line_Item__c POLine:  POLineList){
                                                                  
                                                                  String APType = POLine.ASI_MFM_AP_Code__r.ASI_MFM_AP_Type__c;
                                                                  String BrandGrp = POLine.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.ASI_CRM_CN_Brand_Group_c__r.Name;
                                                                  String SubBrandCode =POLine.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c;
                                                                  
                                                                  String key = APType +'_'+ BrandGrp ;//+'_' +SubBrandCode;
                                                                  resultSet summary = new resultSet(APType, BrandGrp, SubBrandCode);
                                                                  if(resultMap.containsKey(key)){
                                                                      summary = resultMap.get(key);
                                                                      if(POLine.ASI_MFM_PO__r.ASI_MFM_Status__c=='Approved' && !POLine.ASI_MFM_PO__r.ASI_MFM_Is_Direct_Payment__c ){
                                                                          //this is Approved PO Amount 
                                                                          summary.CommittedAmount += POLine.ASI_MFM_BaseCurrencyAmount__c!=null?POLine.ASI_MFM_BaseCurrencyAmount__c:0;
                                                                      }
                                                                      else if (POLine.ASI_MFM_PO__r.ASI_MFM_Status__c=='Closed'){ 
                                                                          //this is Closed PO 
                                                                          for(ASI_MFM_Payment_Line_Item__c payl: POLine.Payment_Line_Items__r){
                                                                              //If this is direct payment
                                                                              
                                                                              if(
                                                                                  payl.ASI_MFM_Payment__r.ASI_MFM_Status__c!='Submitted' &&
                                                                                  payl.ASI_MFM_Payment__r.ASI_MFM_Status__c !='Draft'&& 
                                                                                  payl.ASI_MFM_Payment__r.ASI_MFM_Status__c !='Rejected'){ 
                                                                                      
                                                                                      summary.CommittedAmount +=payl.ASI_MFM_Paid_Amount_in_Base_Currency__c!=null?payl.ASI_MFM_Paid_Amount_in_Base_Currency__c:0;
                                                                                      
                                                                                  }
                                                                          }
                                                                      }
                                                                      
                                                                      resultMap.put(key, summary);                         
                                                                  }else continue;                 
                                                              }
                                                          }
            
            //Get relevant TnE Amount
            String TradeAPType = 'Trade A&P';
            String OtherAPType = 'Other A&P';
            if(APTypes.contains(TradeAPType)||APTypes.contains(OtherAPType)){
                
                system.debug('Count related A&P Amount from T&E');
                         
            //As discussed, please assign either Trade A&P or Other A&P based on “Dept in charge”.
            //-	Trade MKT => Trade A&P
            //-	Brand MKT => Other A&P

                for(List<ASI_TnE_ClaimDetail__c> tnEList :[Select id,
                                                           ASI_TnE_Receipt_Amount__c,
                                                           ASI_TnE_KR_Promotion_Code__c,
                                                           ASI_TnE_FX_Rate__c,
                                                           ASI_TnE_Dept_in_Charge__c,
                                                           ASI_TnE_KR_Sub_Brand__r.ASI_KOR_Sub_Brand_Code__c,
                                                           ASI_TnE_KR_Sub_Brand__r.ASI_KOR_Brand__r.ASI_KOR_CN_Brand_Group__r.Name
                                                           from ASI_TnE_ClaimDetail__c
                                                           where  
                                                           ASI_TnE_ClaimHeader__r.ASI_TnE_Status__c ='Complete'
                                                           AND ASI_TnE_ClaimHeader__r.RecordType.DeveloperName='ASI_TnE_KR_AnP_Finance_View'
                                                           AND ASI_TnE_KR_Promotion_Code__c != null
                                                           AND ASI_TnE_KR_Sub_Brand__c != null 
                                                           AND ASI_TnE_KR_Promotion_Code__r.ASI_MFM_Status__c = 'Closed' 
                                                           AND ASI_TnE_KR_Promotion_Code__r.ASI_MFM_Project_Code__c =: thisPlan.ASI_MFM_Project_Code__c 
                                                           AND ASI_TnE_KR_Promotion_Code__r.ASI_MFM_Budget_Type__c =: thisPlan.ASI_MFM_Budget_Type__c
                                                           AND ASI_TnE_ClaimHeader__r.ASI_TnE_Sys_Fiscal_Year__c  =:thisPlan.ASI_MFM_Fiscal_year__c
                                                           AND ASI_TnE_KR_Sub_Brand__r.ASI_KOR_Brand__r.ASI_KOR_CN_Brand_Group__r.Name in: BrandGroups 
                                                           //AND ASI_TnE_KR_Sub_Brand__r.ASI_KOR_Sub_Brand_Code__c in: SubBrands
                                                           AND (ASI_TnE_Dept_in_Charge__c ='Brand MKT' OR ASI_TnE_Dept_in_Charge__c ='Trade MKT')
                                                           Order by ASI_TnE_Dept_in_Charge__c, ASI_TnE_KR_Sub_Brand__r.ASI_KOR_Brand__r.ASI_KOR_CN_Brand_Group__r.Name 
                                                          ]){
                                                              
                                                              for(ASI_TnE_ClaimDetail__c tnE : tnEList){
                                                                  system.debug('Count related A&P Amount from T&E: ' + tnE );
                                                                  String key = '';
                                                                  String RelatedAPType ='';
                                                                  
                                                                  String BrandGrp = tnE.ASI_TnE_KR_Sub_Brand__r.ASI_KOR_Brand__r.ASI_KOR_CN_Brand_Group__r.Name;
                                                                  String SubBrandCode =tnE.ASI_TnE_KR_Sub_Brand__r.ASI_KOR_Sub_Brand_Code__c;
                                                                  
                                                                  
                                                                  if(APTypes.contains(TradeAPType) && tnE.ASI_TnE_Dept_in_Charge__c =='Trade MKT'){
                                                                      key = TradeAPType+ '_' + BrandGrp ;//+ '_' + SubBrandCode;
                                                                      RelatedAPType = TradeAPType;
                                                                  }else if(APTypes.contains(OtherAPType) && tnE.ASI_TnE_Dept_in_Charge__c =='Brand MKT'){
                                                                      key = OtherAPType+ '_'  + BrandGrp ;//+ '_' + SubBrandCode;
                                                                      RelatedAPType = OtherAPType;
                                                                  }
                                                                  resultSet summary = new resultSet(RelatedAPType,BrandGrp,SubBrandCode);
                                                                  if(resultMap.containsKey(key)){
                                                                      summary = resultMap.get(key);
                                                                      summary.CommittedAmount  += (tnE.ASI_TnE_FX_Rate__c* tnE.ASI_TnE_Receipt_Amount__c).setScale(0);
                                                                      resultMap.put(key, summary);   
                                                                  }else continue;                    
                                                              }                
                                                          }
            }
            
            
            //Actual Spending for this Plan
            Decimal PlanActualAmount = 0;
         
            if(resultMap!=null && resultMap.size()>0){
                
                Map<String, resultSet> restructSets = new Map<String, resultSet>();
                
                for(resultSet result : resultMap.values()){
                    
                    String key = result.APType +'_' + result.BrandGroup;
                    resultSet newset = new resultSet(result.APType, result.BrandGroup);
                    if(restructSets.containsKey(key)){
                        newset =  restructSets.get(key);
                    }
                    newSet.BudgetAmount+=result.BudgetAmount;
                    newSet.TotalPlanAmount+=result.TotalPlanAmount;
                    newSet.CommittedAmount+=result.CommittedAmount;
                    restructSets.put(key, newset);
                }
                
                resultMap.clear();
                resultMap = restructSets;
                
                for(resultSet res : resultMap.values()){
                    
                    if(thisPlan.ASI_MFM_Status__c=='Approved' || thisPlan.ASI_MFM_Status__c =='Closed')
                    {
                        res.TotalPlanAmount = 0;
                    }
                    res.BudgetAmount  = res.BudgetAmount.setScale(0,System.RoundingMode.HALF_UP); 
                    res.TotalPlanAmount = res.TotalPlanAmount.setScale(0,System.RoundingMode.HALF_UP); 
                    res.CommittedAmount = res.CommittedAmount.setScale(0,System.RoundingMode.HALF_UP); 
                    res.Remaining = res.BudgetAmount - res.CommittedAmount;
                    res.Remaining = res.Remaining.setScale(0,System.RoundingMode.HALF_UP);
                    //res.vsRemaining =  res.Remaining - res.TotalPlanAmount; 
                    res.Overbudget = res.Remaining >=res.TotalPlanAmount? false:true;
                    
                }
            }
            
            
        }
        results = resultMap.values();
        system.debug('Results: ' + results);
        wrapperClass wc = new wrapperClass();
        wc.FY = thisPlan.ASI_MFM_Fiscal_year__c;
        wc.Code = thisPlan.ASI_MFM_Project_Code__r.ASI_MFM_Code__c;
        wc.BudgetType = currentBudgetType;
        wc.results = results;
        return  wc;
    }
    
}