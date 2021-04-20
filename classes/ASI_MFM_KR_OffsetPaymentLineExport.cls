public class ASI_MFM_KR_OffsetPaymentLineExport {
    
    //public string header {get;set;}
    public List<wrapper> lstwrapper {get; set;}
    
    public String PlanId {get;set;} {PlanId='';}
    public String SupplierID {get; set;} {SupplierID='';}
    public String CompanyName {get; set;} {CompanyName='';}
    public String TypeName {get; set;} {TypeName='';}
    public String PromotionCode {get; set;} {PromotionCode='';}
        
    public ASI_MFM_KR_OffsetPaymentLineExport(apexpages.standardController sc){
        //header = 'Plan Line Item,Payee,Company,Currency,Exchange Rate,Invoice Number,Invoice Date,Subledger,AP Code,AP Description,Sub Brand Code,Total Payment Amount (Including VAT),Where Customer,Beneficiary Customer,Payment Amount,AP Remark'; //20170207, edited by Leo
        lstwrapper = new List<wrapper>();
        
        PlanId= apexpages.currentPage().getParameters().get('Planid');
        CompanyName = apexpages.currentPage().getParameters().get('CompanyName');
        //TypeName = apexpages.currentPage().getParameters().get('TypeName');
        list<ASI_MFM_Plan__c> planList = [select id, Name, ASI_MFM_Promotion_Code__c, ASI_MFM_Project_Code__r.ASI_MFM_Offset__c from ASI_MFM_Plan__c where id =:PlanId];
        if(planList.size()>0){
            PromotionCode = planList[0].ASI_MFM_Promotion_Code__c;
            if(planList[0].ASI_MFM_Project_Code__r.ASI_MFM_Offset__c==false){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Plan project is not allow offset.'));
                return;
            }
        }
        
		list<Account> accList = [select id from Account where ASI_HK_CRM_Customer_Code__c = '6028513' limit 1];
        if(accList.size()>0)
			SupplierID= accList[0].id;
       
    }
    
    
    public class wrapper
    {
        public string Name {get; set;}
        public string PromotionCode{get; set;} {PromotionCode='';}
        public decimal Amount{get; set;} {Amount=0.0;}
        public string SubLedger {get; set;}{SubLedger='';}
        public string SBCode {get; set;} {SBCode='';}
        public string company {get; set;} {company='';}
        public string typeName {get; set;} {typeName='';}
    }
    
    public void exportToExcel(){
        
        String CompanyCode='222';        
        if(CompanyName=='PRKI'){
            CompanyCode='286';
        }
        string queryString = 'Select Id,Name,ASI_MFM_AP_Code__r.ASI_MFM_AP_Description__c,ASI_MFM_AP_Code__r.ASI_MFM_AP_Code__c,ASI_MFM_Sub_brand_Code__r.Name, ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c,ASI_MFM_KR_subLedger__r.Name,ASI_MFM_Venue_Where__r.ASI_CRM_MY_CustomerCode__c,ASI_MFM_AccountsAdditionalField__r.ASI_CRM_MY_CustomerCode__c,ASI_MFM_Total_Cost__c' 
            +' from ASI_MFM_Plan_Line_Item__c '            
            +' where ASI_MFM_AP_Code__r.ASI_MFM_PRPO_Needed__c=false and ASI_MFM_Plan__c =\''+PlanId+'\'';// and ASI_MFM_Sub_brand_Code__r.ASI_MFM_Company_Code__c =\''+CompanyCode+'\'';
        
        List<ASI_MFM_Plan_Line_Item__c> lstConsignmentSearchData = DataBase.Query(queryString);// system.debug('##################'+queryString);

        if(lstConsignmentSearchData.size()>0){
            for(ASI_MFM_Plan_Line_Item__c csd :lstConsignmentSearchData){
                wrapper w = new wrapper();
                w.Name = csd.Name ;				
                w.PromotionCode = PromotionCode;
                w.Amount=csd.ASI_MFM_Total_Cost__c;
                w.SubLedger=csd.ASI_MFM_KR_subLedger__r.Name;
                w.SBCode=csd.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c;
                w.company = CompanyName;
                w.typeName = TypeName;
                lstwrapper.add(w);
            }
        }
       
    }
    
}