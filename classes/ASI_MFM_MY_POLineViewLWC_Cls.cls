public class ASI_MFM_MY_POLineViewLWC_Cls {
	@AuraEnabled
    public static ReturnValue RunQuery(String soql, String soqlSubbrand, String soqlpo, String sqolwithLimit){
        ReturnValue result;
        Decimal ALLPOAmount=0;
        Decimal ALLPaymentAmount=0;
        Decimal ALLPORemain=0;
        Decimal TotalOriginalPO=0;
        Decimal TotalRemainingPO=0;
        try{
            String SubbrandGroup=' group by ASI_MFM_Sub_brand_Code__r.name';
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

            //Total Plan Amount
            //TotalLineItem = Database.query(soql + ' order by ' + sortField + ' ' + sortDir);
			//system.debug('soql :'+soql);
			//system.debug('soqlSubbrand :'+soqlSubbrand);
			//system.debug('soqlpo :'+soqlpo);
			//system.debug('sqolwithLimit :'+sqolwithLimit);
            List<ASI_MFM_PO_Line_Item__c> TotalLineItem = Database.query(soql);
            for(ASI_MFM_PO_Line_Item__c POli : TotalLineItem){
                if(POli.ASI_MFM_Amount__c!=null){
                    if(POli.ASI_MFM_PO__r.ASI_MFM_Exchange_Rate__c!=null){
                        TotalOriginalPO=TotalOriginalPO+POli.ASI_MFM_Amount__c*POli.ASI_MFM_PO__r.ASI_MFM_Exchange_Rate__c;
                    }else{
                        TotalOriginalPO=TotalOriginalPO+POli.ASI_MFM_Amount__c;
                    }
                }
                if(POli.ASI_MFM_Remaining_Balance__c!=null){
                    if(POli.ASI_MFM_PO__r.ASI_MFM_Exchange_Rate__c!=null){
                        TotalRemainingPO=TotalRemainingPO+POli.ASI_MFM_Remaining_Balance__c*POli.ASI_MFM_PO__r.ASI_MFM_Exchange_Rate__c;
                    }else{
                        TotalRemainingPO=TotalRemainingPO+POli.ASI_MFM_Remaining_Balance__c;
                    }
                    
                }
            }
            integer totalNumOfRecord = TotalLineItem.size();
            List<ASI_MFM_PO__c> TotalpoItem = Database.query(soqlpo);
            for(ASI_MFM_PO__c POli : TotalpoItem){
                if(POli.ASI_MFM_Base_Currency_Amount__c!=null){
                    ALLPOAmount=ALLPOAmount+POli.ASI_MFM_Base_Currency_Amount__c;
                }
                if(POli.ASI_MFM_Payment_Request_Amount__c!=null){
                    ALLPaymentAmount=ALLPaymentAmount+POli.ASI_MFM_Payment_Request_Amount__c;
                }
                if(POli.ASI_MFM_PO_Balance__c!=null){
                    ALLPORemain=ALLPORemain+POli.ASI_MFM_PO_Balance__c;
                }                  
            }
            //Plan line Amount
			List<ASI_MFM_PO_Line_Item__c> lineItem = Database.query(sqolwithLimit);
            if(lineItem.size() == 0){
				result = new ReturnValue(true, 'No Records Found, Please Check your search input');
            }else{
                result = new ReturnValue(TotalpoItem, lineItem, ALLPOAmount, ALLPaymentAmount, ALLPORemain, TotalOriginalPO, TotalRemainingPO, totalNumOfRecord, Summaries);
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
        public Decimal ALLPOAmount {get; set;}
        
		@AuraEnabled 
        public Decimal ALLPaymentAmount {get; set;}
        
        @AuraEnabled 
        public Decimal ALLPORemain {get; set;}
        
        @AuraEnabled
        public Decimal TotalOriginalPO {get; set;}

        @AuraEnabled
        public Decimal TotalRemainingPO {get; set;}
        
        @AuraEnabled
        public Integer totalNumOfRecord {get; set;}
        
        @AuraEnabled 
        public List<ASI_MFM_PO__c> poList {get; set;}
        
        @AuraEnabled 
        public List<ASI_MFM_PO_Line_Item__c> poLineItemList {get; set;}
        
        @AuraEnabled 
        public List<SummarySubbrand> Summaries {get; set;}

        @AuraEnabled
        public boolean error {get; set;}
        
        @AuraEnabled
        public String errorMsg {get; set;}
        
        public ReturnValue(List<ASI_MFM_PO__c> poList, List<ASI_MFM_PO_Line_Item__c> poLineItemList, 
                           Decimal ALLPOAmount, Decimal ALLPaymentAmount, Decimal ALLPORemain, 
                           Decimal TotalOriginalPO, Decimal TotalRemainingPO, Integer totalNumOfRecord,
                           List<SummarySubbrand> Summaries) {
            this.ALLPOAmount = ALLPOAmount;
            this.ALLPaymentAmount = ALLPaymentAmount;
            this.ALLPORemain = ALLPORemain;
            this.TotalOriginalPO = TotalOriginalPO;
            this.TotalRemainingPO = TotalRemainingPO;
            this.Summaries = Summaries;
            this.totalNumOfRecord = totalNumOfRecord;
        	this.poList = poList;
            this.poLineItemList = poLineItemList;
            this.error = false;  
            this.errorMsg = '';  
        }
        
        public ReturnValue(Boolean error, String errorMsg) {
            this.ALLPOAmount = 0;
            this.ALLPaymentAmount = 0;
            this.ALLPORemain = 0;
            this.TotalOriginalPO = 0;
            this.TotalRemainingPO = 0;
            this.totalNumOfRecord = 0;
            this.Summaries = NULL;
            this.poList = NULL;
            this.poLineItemList = NULL;
            this.error = error;  
            this.errorMsg = errorMsg;  
        }
    }
    
    public class SummarySubbrand{
        /*For Sub-Brand use*/
        @AuraEnabled 
        public Decimal TotalOPO { get; private set; }// Original PO 
        @AuraEnabled 
        public Decimal TotalRPO { get; private set; }// Remaining PO
        @AuraEnabled 
        public String Name { get; private set; }// Sub-Brand Name
        
        public SummarySubbrand(AggregateResult ar) {
            TotalOPO = (Decimal) ar.get('TotalOPO');
            TotalRPO = (Decimal) ar.get('TotalRPO');
            Name = (String) ar.get('Name');
        }
    }
}