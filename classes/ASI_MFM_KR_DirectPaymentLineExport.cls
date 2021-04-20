/*
+-----------------------+------------------------------------------------------------------------------------+
| Author                | elufa                                                           
+-----------------------+------------------------------------------------------------------------------------+
| Description           | For ASI Korea user                                                                              
|                       |                                                                                    
|     - Object(s)       | MFM Plan Payment                                                                                
|     - Description     | In Direct Payment, generate Plan line as csv for uploading Direct Payment.
+-----------------------+------------------------------------------------------------------------------------+
| Creation Date         | 31/12/2016                                                                        
+-----------------------+------------------------------------------------------------------------------------+
| Modifications         |                                                                                    
+-----------------------+------------------------------------------------------------------------------------+
| Governor informations |                                                                                    
+-----------------------+------------------------------------------------------------------------------------+
*/

public class ASI_MFM_KR_DirectPaymentLineExport {
    
    public string header {get;set;}
    public List<wrapper> lstwrapper {get; set;}
    
    public String PlanId {get;set;} {PlanId='';}
    public String SupplierID {get; set;} {SupplierID='';}
    public String SupplierCode {get; set;} {SupplierCode='';}
    public String InvoiceNumber {get; set;} {InvoiceNumber='';}
    public  String InvoiceDate {get; set;}  {
        date dd= system.today();
        InvoiceDate=String.valueOf(formatDate(dd));
    }
    public  String CurrencyName {get; set;} {CurrencyName='';}
    public String FX {get; set;} {FX='';}
    public String CompanyName {get; set;} {CompanyName='';}
    public Decimal totalPayAmt {get;set;} {totalPayAmt=0.0;}//20170207, addedby Leo
    
    public static String formatDate(Date d) {
        
        return d.year() + '-' + d.month() + '-' + d.day();
        
    }
    
    
    
    public ASI_MFM_KR_DirectPaymentLineExport(apexpages.standardController sc){
        header = 'Plan Line Item,Payee,Company,Currency,Exchange Rate,Invoice Number,Invoice Date,Subledger,AP Code,AP Description,Sub Brand Code,Total Payment Amount (Including VAT),Where Customer,Beneficiary Customer,Payment Amount,AP Remark'; //20170207, edited by Leo
        lstwrapper = new List<wrapper>();
        
        PlanId= apexpages.currentPage().getParameters().get('Planid');
        
        SupplierID=apexpages.currentPage().getParameters().get('SupplierID');
        
        List<Account> accList = new List<Account>([select id, ASI_HK_CRM_Customer_Code__c from Account where id =: SupplierID limit 1]);
        if(accList.size()>0)
        	SupplierCode = accList[0].ASI_HK_CRM_Customer_Code__c;
        InvoiceNumber=apexpages.currentPage().getParameters().get('InvoiceNumber');
        InvoiceNumber=InvoiceNumber; //'\''+
        InvoiceDate=apexpages.currentPage().getParameters().get('InvoiceDate');
            
        CurrencyName=apexpages.currentPage().getParameters().get('CurrencyName');
        FX=apexpages.currentPage().getParameters().get('FX');
        CompanyName=apexpages.currentPage().getParameters().get('CompanyName');
        totalPayAmt=Decimal.valueOf(apexpages.currentPage().getParameters().get('totalPayAmt'));
       
    }
    
    
    public class wrapper
    {
        public string Name {get; set;}
        public string APCode {get; set;} {APCode='';}
        public String APDescription{get; set;} {APDescription='';}
        public string SBCode {get; set;} {SBCode='';}
        public decimal Amount{get; set;} {Amount=0.0;}
        public string CustomerBeneficiary  {get; set;}{CustomerBeneficiary='';}
        public string VenueWhere {get; set;}{VenueWhere='';}
        public string SubLedger {get; set;}{SubLedger='';}
    }
    
    public void exportToExcel(){
        String CompanyCode='222';
        
        if(CompanyName=='PRKI'){
            CompanyCode='286';
        }
        string queryString = 'Select Id,Name,ASI_MFM_AP_Code__r.ASI_MFM_AP_Description__c,ASI_MFM_AP_Code__r.ASI_MFM_AP_Code__c,ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c,ASI_MFM_KR_subLedger__r.Name,ASI_MFM_Venue_Where__r.ASI_CRM_MY_CustomerCode__c,ASI_MFM_AccountsAdditionalField__r.ASI_CRM_MY_CustomerCode__c  from ASI_MFM_Plan_Line_Item__c  where ASI_MFM_AP_Code__r.ASI_MFM_PRPO_Needed__c=false and ASI_MFM_Plan__c =\''+PlanId+
            '\'  and    ASI_MFM_Sub_brand_Code__r.ASI_MFM_Company_Code__c =\''+CompanyCode+'\'';
        
        List<ASI_MFM_Plan_Line_Item__c> lstConsignmentSearchData = DataBase.Query(queryString);// system.debug('##################'+queryString);

        if(lstConsignmentSearchData.size()>0){
            for(ASI_MFM_Plan_Line_Item__c csd :lstConsignmentSearchData){
                wrapper w = new wrapper();
                w.Name = csd.Name ;
                
                w.VenueWhere=csd.ASI_MFM_AccountsAdditionalField__r.ASI_CRM_MY_CustomerCode__c;
                w.CustomerBeneficiary=csd.ASI_MFM_Venue_Where__r.ASI_CRM_MY_CustomerCode__c;
                w.SubLedger=csd.ASI_MFM_KR_subLedger__r.Name;
                if(csd.ASI_MFM_AP_Code__r.ASI_MFM_AP_Description__c!=NULL){
                    w.APDescription=csd.ASI_MFM_AP_Code__r.ASI_MFM_AP_Description__c.replaceAll(',',' ');
                }else{
                    w.APDescription='';
                }
                
                w.APCode=csd.ASI_MFM_AP_Code__r.ASI_MFM_AP_Code__c;
                w.SBCode=csd.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c;
                lstwrapper.add(w);
            }
        }
       
    }
    
}