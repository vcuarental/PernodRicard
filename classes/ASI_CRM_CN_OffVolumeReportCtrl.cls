public class ASI_CRM_CN_OffVolumeReportCtrl {
  
    public Id contractId {get; set;}
    public String StartDateStr {get; set;}
    public String EndDateStr {get; set;}
    
    public ASI_CRM_CN_OffVolumeReportCtrl() {
        Map<String, String> params = ApexPages.currentPage().getParameters();
        contractId = params.get('id');
        StartDateStr = params.get('StartDate');
        EndDateStr = params.get('EndDate');
    }
    
}