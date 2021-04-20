public class ASI_MFM_KR_GRNIReportCtrler {
    public HeaderObj Header {set;get;}
    public String Company {get;set;}{Company='';}
    public String FiscalYear {get;set;}{FiscalYear='';}
    public String ReportToken {set;get;}
    public String ReportTokenMsg {set;get;}
    
    public Integer startMonth {set;get;}
    public Integer endMonth {set;get;}
    
    public Boolean isRedirect {set; get;}   
    public ID jobId; 
    public Boolean isGenerating;
    public Integer count = 0;    

    public List<SelectOption> listOfFiscalYear {get;set;}
    public List<SelectOption> getlistOfFiscalYear(){
        listOfFiscalYear = new List<SelectOption>();
        
        DateTime today = DateTime.now();        
		Integer lastYear = today.month()<7 ? today.year()+1 : today.year()+2;
        for(integer i = 0 ; i < 5; i++){
			String fy = String.valueOf(lastYear-5+i).right(2) + String.valueOf(lastYear-4+i).right(2);
            listOfFiscalYear.add(new SelectOption('FY' + fy, 'FY' + fy));
            if(i==3){FiscalYear = 'FY' + fy;}//set default
        }
        
        return listOfFiscalYear;
	}

    
    // ********************  Initiate ******************* 
    public ASI_MFM_KR_GRNIReportCtrler() {
        init();
    }
    public void init(){
        isRedirect = false;
        isGenerating = false;
        startMonth = 7;
        endMonth = 6;
        ReportTokenMsg = '';
        //Header
        Header= new HeaderObj();
        Header.id = '1';
        Header.po = new ASI_MFM_PO__c (recordTypeId=Global_RecordTypeCache.getRTId('ASI_MFM_PO__cASI_MFM_KR_PO'));
        Header.report = new ASI_MFM_GRNI_Report__c();
        
        getlistOfFiscalYear();
	}
    
    public PageReference GenerateGRNIReport(){
        
        if(isGenerating==false){
            system.debug('GenerateGRNIReport');
            system.debug('Header.report.ASI_MFM_PO_Number__c : '+ Header.report.ASI_MFM_PO_Number__c);  
            system.debug('Header.po.ASI_MFM_Supplier_Name__c : '+ Header.po.ASI_MFM_Supplier_Name__c);  
            system.debug('Company : '+Company);
            system.debug('FiscalYear : '+FiscalYear);
    
            //reset to first day of month and end day of month
            if(startMonth<7){
                Header.po.ASI_MFM_Target_PO_Start_Date__c = Date.newInstance(integer.valueof(FiscalYear.right(2))+2000,startMonth,1);
            }else{
                Header.po.ASI_MFM_Target_PO_Start_Date__c = Date.newInstance(integer.valueof(FiscalYear.right(4).left(2))+2000,startMonth,1);
            }
            if(endMonth<7){
                Header.po.ASI_MFM_Target_PO_End_Date__c = Date.newInstance(integer.valueof(FiscalYear.right(2))+2000,endMonth,1);
            }else{
                Header.po.ASI_MFM_Target_PO_End_Date__c = Date.newInstance(integer.valueof(FiscalYear.right(4).left(2))+2000,endMonth,1);
            }
            if(Header.po.ASI_MFM_Target_PO_Start_Date__c!=null){
                Date tmp = Header.po.ASI_MFM_Target_PO_Start_Date__c;
                Header.po.ASI_MFM_Target_PO_Start_Date__c = tmp.toStartOfMonth();
            } 
            if(Header.po.ASI_MFM_Target_PO_End_Date__c!=null){
                Date tmp = Header.po.ASI_MFM_Target_PO_End_Date__c;
                Date newDateTime = tmp.addMonths(1).toStartOfMonth().addDays(-1);
                Header.po.ASI_MFM_Target_PO_End_Date__c = newDateTime;
            }
            
            system.debug('new Header.po.ASI_MFM_Target_PO_Start_Date__c : '+ Header.po.ASI_MFM_Target_PO_Start_Date__c);  
            system.debug('new Header.po.ASI_MFM_Target_PO_End_Date__c : '+ Header.po.ASI_MFM_Target_PO_End_Date__c); 
            
            //Date vaild checking
            Date FYStartDate = Date.newInstance(integer.valueof(FiscalYear.right(4).left(2))+2000,7,1);
            Date FYEndDate = Date.newInstance(integer.valueof(FiscalYear.right(2))+2000,6,30);
            if(	Header.po.ASI_MFM_Target_PO_Start_Date__c<FYStartDate || Header.po.ASI_MFM_Target_PO_Start_Date__c>FYEndDate 
              || Header.po.ASI_MFM_Target_PO_End_Date__c<FYStartDate || Header.po.ASI_MFM_Target_PO_End_Date__c>FYEndDate
              || Header.po.ASI_MFM_Target_PO_Start_Date__c>Header.po.ASI_MFM_Target_PO_End_Date__c){
                string dateStrStart = DateTime.newInstance(Header.po.ASI_MFM_Target_PO_Start_Date__c.year(),Header.po.ASI_MFM_Target_PO_Start_Date__c.month(),Header.po.ASI_MFM_Target_PO_Start_Date__c.day()).format('yyyy-MM-dd');
                string dateStrEnd = DateTime.newInstance(Header.po.ASI_MFM_Target_PO_End_Date__c.year(),Header.po.ASI_MFM_Target_PO_End_Date__c.month(),Header.po.ASI_MFM_Target_PO_End_Date__c.day()).format('yyyy-MM-dd');
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Incorrect fiscal year period from '+dateStrStart+' to '+dateStrEnd));
                return null;
            }        
            
            ReportToken = String.valueOf(DateTime.now().getTime());
            system.debug('ReportToken : '+ReportToken);
            
            ASI_MFM_KR_GRNIReport_Batch batch = new ASI_MFM_KR_GRNIReport_Batch();
            batch.PO_Number = Header.report.ASI_MFM_PO_Number__c;
            batch.Supplier_Name = Header.po.ASI_MFM_Supplier_Name__c;
            batch.Company = Company;
            batch.FiscalYear = FiscalYear;
            batch.PO_Start_Date = Header.po.ASI_MFM_Target_PO_Start_Date__c;
            batch.PO_End_Date = Header.po.ASI_MFM_Target_PO_End_Date__c;
            batch.ReportToken = ReportToken;
            batch.userId = userinfo.getuserId();
            
            system.debug('Batch start');            
            jobId = Database.executeBatch(batch,30);
            
            isGenerating = true;
            ReportTokenMsg = 'Generating Report... ';
            return null;
        }else{
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'A report is generating, please wait for complete.'));
            return null;
        }
    }
    
	public PageReference ViewGRNIReport(){
        
        if(ReportToken!=null && isGenerating==false){
            
            list<Report> reportList = [SELECT Id,DeveloperName FROM Report where DeveloperName = 'ASI_MFM_KR_GRNI_Report' limit 1];
            if(reportList.size()>0){
                PageReference reportPage = new PageReference('/'+reportList[0].id+'?pv0='+ReportToken);
            	reportPage.setRedirect(true);
            	return reportPage;
            }else{
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Report was not created.'));
		   		return null; 
            }
            
        }else{
           ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Report is not ready.'));
		   return null; 
        }

	}
    
    public PageReference refreshReportStatus(){
        if(isGenerating=true && jobId!=null && ReportToken!=null){
            AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Name, CreatedBy.Email, ExtendedStatus from AsyncApexJob where Id = :jobId];
			if(a.Status == 'Completed'){
                isGenerating = false;
               	ReportTokenMsg = 'Generate report success. '+'( Report Token : '+ReportToken+' )';
            }else if (a.Status == 'Failed'){
                isGenerating = false;
				ReportTokenMsg = 'Failed to Generate Report. Please try again.';
            }else {
               	ReportTokenMsg = 'Generating Report... ';
            }
        }
        return null;
    }
    
    //***** Wapper Class **********
    public Class HeaderObj{
        public String id{ 
            get{
                if(String.isBlank(id)) {
                    return null;
                }
                return id;
            } 
            set; }
        public ASI_MFM_PO__c po {get; set;}
        public ASI_MFM_GRNI_Report__c report {get; set;}
    }
}