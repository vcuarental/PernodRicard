public class ASI_MFM_MY_Payment_SummaryLWC_Cls {
	@AuraEnabled
    public static ReturnValue RunQuery(String soql, String soqlSubbrand, String sqolwithLimit){
        ReturnValue result;
        Decimal TotalRemainingPO=0;
        Decimal TotalPayment=0;
        Decimal VerifiedPY=0;
        Decimal UnverifiedPY=0;
        try{
            String SubbrandGroup='group by ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.name';
            String SubbrandSear;
            SubbrandSear=soqlSubbrand+SubbrandGroup;   //soqlSubbrand +='group by ASI_MFM_Sub_brand_Code__r.name';
            AggregateResult[] groupedResults=Database.query(SubbrandSear); //Run query
            List<SummarySubbrand> Summaries = new List<SummarySubbrand>();
            /*Add to class*/
            for (AggregateResult ar : groupedResults) {
                Summaries.add(new SummarySubbrand(ar));
                //TotalSubBrand=TotalSubBrand+ar.TotalPLI;
            } //
            groupedResults.clear();

            List<ASI_MFM_Payment_Line_Item__c> TotalLineItem = Database.query(soql);

            for(ASI_MFM_Payment_Line_Item__c PAYLI : TotalLineItem){
                if(PAYLI.ASI_MFM_PO_Line_Remaining_Amount__c!=null){
                    if(PAYLI.ASI_MFM_Payment__r.ASI_MFM_Exchange_Rate__c!=null){
                        TotalRemainingPO=TotalRemainingPO+PAYLI.ASI_MFM_PO_Line_Remaining_Amount__c*PAYLI.ASI_MFM_Payment__r.ASI_MFM_Exchange_Rate__c;
                    }else{
                        TotalRemainingPO=TotalRemainingPO+PAYLI.ASI_MFM_PO_Line_Remaining_Amount__c;
                    }
                    
                }
                if(PAYLI.ASI_MFM_Paid_Amount_in_Base_Currency__c !=null){
                    TotalPayment=PAYLI.ASI_MFM_Paid_Amount_in_Base_Currency__c +TotalPayment;
                    if(PAYLI.ASI_MFM_Payment_Line_Item_Finance_Verify__c==true){
                        VerifiedPY=VerifiedPY+PAYLI.ASI_MFM_Paid_Amount_in_Base_Currency__c;
                    }else{
                        UnverifiedPY=UnverifiedPY+PAYLI.ASI_MFM_Paid_Amount_in_Base_Currency__c;
                    }
                }
            }
            
            integer totalNumOfRecord = TotalLineItem.size();
            List<ASI_MFM_Payment_Line_Item__c> lineItem = Database.query(sqolwithLimit);
            if(lineItem.size() == 0){
				result = new ReturnValue(true, 'No Records Found, Please Check your search input');
            }else{
                result = new ReturnValue(lineItem, TotalRemainingPO, TotalPayment, VerifiedPY, UnverifiedPY, totalNumOfRecord, Summaries);
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
        public Decimal TotalRemainingPO {get; set;}
        
		@AuraEnabled 
        public Decimal TotalPayment {get; set;}
        
        @AuraEnabled 
        public Decimal VerifiedPY {get; set;}
        
        @AuraEnabled
        public Decimal UnverifiedPY {get; set;}

        @AuraEnabled
        public Integer totalNumOfRecord {get; set;}
        
        @AuraEnabled 
        public List<ASI_MFM_Payment_Line_Item__c> paymentLineItemList {get; set;}
        
        @AuraEnabled 
        public List<SummarySubbrand> Summaries {get; set;}

        @AuraEnabled
        public boolean error {get; set;}
        
        @AuraEnabled
        public String errorMsg {get; set;}
        
        public ReturnValue(List<ASI_MFM_Payment_Line_Item__c> paymentLineItemList,  
                           Decimal TotalRemainingPO, Decimal TotalPayment, Decimal VerifiedPY, 
                           Decimal UnverifiedPY, Integer totalNumOfRecord,
                           List<SummarySubbrand> Summaries) {
            this.TotalRemainingPO = TotalRemainingPO;
            this.TotalPayment = TotalPayment;
            this.VerifiedPY = VerifiedPY;
            this.UnverifiedPY = UnverifiedPY;
            this.Summaries = Summaries;
            this.totalNumOfRecord = totalNumOfRecord;
        	this.paymentLineItemList = paymentLineItemList;
            this.error = false;  
            this.errorMsg = '';  
        }

        public ReturnValue(Boolean error, String errorMsg) {
            this.TotalRemainingPO = 0;
            this.TotalPayment = 0;
            this.VerifiedPY = 0;
            this.UnverifiedPY = 0;
            this.totalNumOfRecord = 0;
            this.Summaries = NULL;
            this.paymentLineItemList = NULL;
            this.error = error;  
            this.errorMsg = errorMsg;  
        }
    }

    public class SummarySubbrand{
        /*For Sub-Brand use*/
        @AuraEnabled 
        public Decimal TotalTPA { get; private set; }// total payment amount 
        @AuraEnabled 
        public Decimal TotalTPABC { get; private set; }// total payment amount in base currency
        @AuraEnabled 
        public String Name { get; private set; }// Sub-Brand Name
        
        public SummarySubbrand(AggregateResult ar) {
            TotalTPA = (Decimal) ar.get('TPA');
            TotalTPABC = (Decimal) ar.get('TPABC');
            Name = (String) ar.get('Name');
        }
    }
}