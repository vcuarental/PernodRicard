public class ASI_MFM_MY_PlanViewLWC_Cls {
	@AuraEnabled
    public static ReturnValue RunQuery(String soqlSubbrand, String soql, String soqlSubbrandplan, String sqolwithLimit){
        ReturnValue result;
        Decimal ALLPlanAmount=0;
        Decimal ALLTotalPOAmount=0;
        Decimal ALLPlanBalance=0;
        Decimal TotalSubBrand=0;
        try{
            String SubbrandGroup='group by ASI_MFM_Sub_brand_Code__r.name';
            String SubbrandSear;
            SubbrandSear=soqlSubbrand+SubbrandGroup;   //soqlSubbrand +='group by ASI_MFM_Sub_brand_Code__r.name';
            AggregateResult[] groupedResults=Database.query(SubbrandSear); //Run query
            List<SummarySubbrand> Summaries = new List<SummarySubbrand>();
            /*Add to class*/
            for (AggregateResult ar : groupedResults) {
                Summaries.add(new SummarySubbrand(ar));
                //TotalSubBrand=TotalSubBrand+ar.TotalPLI;
            } //
            
            for(SummarySubbrand sumsub:Summaries){
                TotalSubBrand=TotalSubBrand+sumsub.TotalPLI;
            }
            groupedResults.clear();
            //Total Plan Amount
            List<ASI_MFM_Plan__c> Totalplan = Database.query(soqlSubbrandplan);
            for(ASI_MFM_Plan__c Planterms : Totalplan){
                  if(Planterms.ASI_MFM_Plan_Amount__c!=null)
                      ALLPlanAmount=ALLPlanAmount+Planterms.ASI_MFM_Plan_Amount__c;
                  if(Planterms.ASI_MFM_Total_PO_Amount__c!=null)
                      ALLTotalPOAmount=ALLTotalPOAmount+Planterms.ASI_MFM_Total_PO_Amount__c;
                  if(Planterms.ASI_MFM_Plan_Balance__c!=null)
                      ALLPlanBalance=ALLPlanBalance+Planterms.ASI_MFM_Plan_Balance__c;
              }
            
            //Plan line Amount
            List<ASI_MFM_Plan_Line_Item__c> TotalLineItem = Database.query(soql);
			integer totalNumOfRecord = TotalLineItem.size();
			List<ASI_MFM_Plan_Line_Item__c> lineItem = Database.query(sqolwithLimit);
            if(lineItem.size() == 0){
				result = new ReturnValue(true, 'No Records Found, Please Check your search input');
            }else{
                result = new ReturnValue(Totalplan, lineItem, totalNumOfRecord, ALLPlanAmount, ALLTotalPOAmount, ALLPlanBalance, TotalSubBrand, Summaries);
            }            
        }
        catch (Exception e) {
            result = new ReturnValue(true, 'No Records Found, Please Check your search input');
            result = new ReturnValue(true, e.getMessage());

        }
        return result;
    }
    
    public class ReturnValue {
        @AuraEnabled 
        public Decimal ALLPlanAmount {get; set;}
        
		@AuraEnabled 
        public Decimal ALLTotalPOAmount {get; set;}
        
        @AuraEnabled 
        public Decimal ALLPlanBalance {get; set;}
        
        @AuraEnabled
        public Decimal TotalSubBrand {get; set;}

        @AuraEnabled
        public integer totalNumOfRecord {get; set;}
        
        @AuraEnabled 
        public List<ASI_MFM_Plan__c> planList {get; set;}
        
        @AuraEnabled 
        public List<ASI_MFM_Plan_Line_Item__c> planLineItemList {get; set;}
        
        @AuraEnabled 
        public List<SummarySubbrand> Summaries {get; set;}

        @AuraEnabled
        public boolean error {get; set;}
        
        @AuraEnabled
        public String errorMsg {get; set;}
        
                
        public ReturnValue(List<ASI_MFM_Plan__c> planList, List<ASI_MFM_Plan_Line_Item__c> planLineItemList, 
                           integer totalNumOfRecord, Decimal ALLPlanAmount, Decimal ALLTotalPOAmount, 
                           Decimal ALLPlanBalance, Decimal TotalSubBrand,List<SummarySubbrand> Summaries) {
            this.ALLPlanAmount = ALLPlanAmount;
            this.ALLTotalPOAmount = ALLTotalPOAmount;
            this.ALLPlanBalance = ALLPlanBalance;
            this.TotalSubBrand = TotalSubBrand;
            this.Summaries = Summaries;
            this.totalNumOfRecord = totalNumOfRecord;
        	this.planList = planList;
            this.planLineItemList = planLineItemList;
            this.error = false;  
            this.errorMsg = '';  
        }
        
        public ReturnValue(Boolean error, String errorMsg) {
            this.ALLPlanAmount = 0;
            this.ALLTotalPOAmount = 0;
            this.ALLPlanBalance = 0;
            this.TotalSubBrand = 0;
            this.Summaries = NULL;
			this.totalNumOfRecord = 0;
            this.planList = NULL;
            this.planLineItemList = NULL;
            this.error = error;  
            this.errorMsg = errorMsg;  
        }
    }
    
    public class SummarySubbrand{
        /*For Sub-Brand use*/
        @AuraEnabled 
        public Decimal TotalPLI { get; private set; }// plan line amount
        @AuraEnabled 
        public String Name { get; private set; }// Sub-Brand Name
        
        public SummarySubbrand(AggregateResult ar) {
            TotalPLI = (Decimal) ar.get('TotalPLI');
            Name = (String) ar.get('Name');
        }
    }

}