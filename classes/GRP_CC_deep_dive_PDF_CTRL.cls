public class GRP_CC_deep_dive_PDF_CTRL {
   
    public GRP_CC_Deep_dive__c dd;
    
    // The extension constructor initializes the private member 
    // variable dd by using the getRecord method from the standard
    // controller.
    public GRP_CC_deep_dive_PDF_CTRL(ApexPages.StandardController stdController) {
        this.dd = (GRP_CC_Deep_dive__c)stdController.getRecord();
        
        //String maDate = dd.CreatedDate.format('YYYY-MM-DD');
        //valueof(dd.GRP_CC_Creation_date__c).format('YYYY-MM-DD'); 
        //maDate = maDate.replace(' ','_');
        String myGeneratedFileName = 'Deep_Dive_' + dd.GRP_CC_Chain_Account__r.Name +  '.pdf';
        Apexpages.currentPage().getHeaders().put('content-disposition', 'attachment; filename='+myGeneratedFilename);
    }
    
    
  
}