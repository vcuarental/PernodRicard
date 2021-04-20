/* Filename:    ASI_CRM_CN_HeavyContractVolumeReportCtrl.cls
* Author:      Laputa
* Purpose:     Controller for Volume Report
//'/apex/ASI_CRM_CN_Heavy_PSFCTDPDF_Page?id={!ASI_TH_CRM_Contract__c.id}')"
* History     
* -----------------------------------------------------------------------------
* 2017-08-25   Laputa      Created



ASI_CRM_CN_Heavy_PSFCTDPDF_Page
ASI_CRM_CN_Heavy_PSFCTD_Cmp
ASI_CRM_CN_HeavyPSFForm_CTD_Ctrl
ASI_CRM_CN_HeavyVolumeReportCtrl


*/



public class ASI_CRM_CN_HeavyContractVolumeReportCtrl {
    public ASI_TH_CRM_Contract__c Contract {set;get;} 
    
    
    public String msg {get;set;} {msg='';}
    public boolean ProcessPermission {get;set;}{ProcessPermission=true;}
    public boolean showCN {set;get;}
    public Date PreviousStartDate   {set;get;}
    public Date PreviousEndDate   {set;get;}
    
    public ASI_CRM_CN_HeavyContractVolumeReportCtrl(){}
    public void init(){
        showCN = USerInfo.getLanguage()=='zh_CN';
        
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String contractId = params.get('id');
        Contract = [SELECT Id,Name, ASI_CRM_CN_Outlet_WS__r.Name, ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Legal_Name__c,ASI_CRM_CN_PO_Start_Date__c, ASI_CRM_CN_PO_No__c, ASI_CRM_CN_PO_End_Date__c FROM ASI_TH_CRM_Contract__c WHERE id =:contractId ];
        PreviousStartDate=Contract.ASI_CRM_CN_PO_Start_Date__c;
        PreviousEndDate=Contract.ASI_CRM_CN_PO_End_Date__c;
    }
    
    
    
    
    
    public PageReference CTDproceed() {
        
        String url='';
        Date CutOffDay =ASI_CRM_CN_HeavyContractUtilitiesClass.GenerateCutOffDate();
        Contract.ASI_CRM_CN_PO_Start_Date__c=PreviousStartDate;
        Date POSuggestedEndDate=date.today().addMonths(1).toStartOfMonth().addDays(-1);
        
        //Contract.ASI_CRM_CN_PO_End_Date__c= date.today().addMonths(1).toStartOfMonth().addDays(-1);
        if(PreviousEndDate<POSuggestedEndDate){
            Contract.ASI_CRM_CN_PO_End_Date__c=PreviousEndDate;
        }else{
            Contract.ASI_CRM_CN_PO_End_Date__c=POSuggestedEndDate;
        }
        if(CutOffDay < Contract.ASI_CRM_CN_PO_End_Date__c){
            Contract.ASI_CRM_CN_PO_End_Date__c=CutOffDay;
        }
        
        
        ValidationChecking();
        if(ProcessPermission){
            url=GeneratingURL();//'/apex/ASI_CRM_CN_Heavy_PSFCTDPDF_Page?id='+Contract.Id;
            return new pageReference(url); 
        }else{
            return Null;
        }
    }
    
    
    
    public PageReference proceed() {
        String url='';
        ValidationChecking();//Date x = Date.valueOf('2015-8-11');
        if(ProcessPermission){ // ASI_CRM_CN_HeavyContractUtilitiesClass.DateToString(Contract.ASI_CRM_CN_PO_End_Date__c,'yyyy-MM-dd' );
            url=GeneratingURL();//'/apex/ASI_CRM_CN_Heavy_PSFCTDPDF_Page?id='+Contract.Id +'&StartDate=';
            return new pageReference(url); 
        }else{
            return Null;
        }
    }
    
    
    
    public String GeneratingURL(){
        String RetuenURL='';
        String StartDateStr= ASI_CRM_CN_HeavyContractUtilitiesClass.DateToString(Contract.ASI_CRM_CN_PO_Start_Date__c,'yyyy-MM-dd' );
        String EndDateStr= ASI_CRM_CN_HeavyContractUtilitiesClass.DateToString(Contract.ASI_CRM_CN_PO_End_Date__c,'yyyy-MM-dd' );
        RetuenURL='/apex/ASI_CRM_CN_HeavyVolumeReportPDF?id='+Contract.Id +'&StartDate='+StartDateStr +'&EndDate='+EndDateStr;
        return RetuenURL;
    }
    
    
    public void ValidationChecking(){
        ProcessPermission=true;
        msg='';
        
        //1) show warning if user not choosing the 1st date as start date and last date as end date.
        //2) Reminder user if the period they selection volume is not ready. 
        
        
        //checking the start day 
        if(Contract.ASI_CRM_CN_PO_Start_Date__c.day()!=1){
            msg += Label.ASI_CRM_CN_PO_Start_Date_Validation+'<br/>';
            ProcessPermission=false;
        }
        
        //checking end day         
        Date LastEndDate = Contract.ASI_CRM_CN_PO_End_Date__c.addMonths(1).toStartOfMonth().addDays(-1);
        if(Contract.ASI_CRM_CN_PO_End_Date__c != LastEndDate){
            msg +=Label.ASI_CRM_CN_PO_End_Date_Validation+'<br/>';// End Date should be the last day of the month .
            ProcessPermission=false;
        }
       
        if(Contract.ASI_CRM_CN_PO_Start_Date__c>Contract.ASI_CRM_CN_PO_End_Date__c){
             msg +=Label.ASI_CRM_CN_PO_start_date_after_PO_end_date+'<br/>';//You cannot select PO start date after PO end date
             ProcessPermission=false;
        }
        
        
        if(Contract.ASI_CRM_CN_PO_Start_Date__c<PreviousStartDate){
            msg +=Label.ASI_CRM_CN_Start_date_validation+'<br/>';//Start date cannot exceed PO start date
             ProcessPermission=false;
        }
        
        if(Contract.ASI_CRM_CN_PO_End_Date__c>PreviousEndDate){
             msg +=Label.ASI_CRM_CN_End_date_validation+'<br/>';//End date cannot exceed PO start date
             ProcessPermission=false;
        }
        
        
        
        ASI_CRM_CN_HeavyContractUtilitiesClass.ReturnResult checkingResult =  ASI_CRM_CN_HeavyContractUtilitiesClass.CheckingVolumeIsReady(Contract.ASI_CRM_CN_PO_Start_Date__c,Contract.ASI_CRM_CN_PO_End_Date__c );
       
        if(ProcessPermission){
            ProcessPermission= checkingResult.Process;
        }
        
        
        msg += checkingResult.msg;
        
    }
}