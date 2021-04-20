/*********************************************************************************
 * Name: ASI_CRM_VN_PDF_Ctrl
 * Description: Controller for ASI_CRM_VN_PDF_Page
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 25/07/2017       Hugo Cheung             Created          
*/
public class ASI_CRM_VN_PDF_Ctrl {
    
    //Page Parameters
    private final static String PDF_TYPE  = 'pdfType';
    private final static String RECORD_ID = 'id';
    
    public String pdfType     {get; set;}
    public String recordIdStr {get; set;}
    
    public ASI_CRM_VN_PDF_Ctrl() {
        Map<String, String> params = ApexPages.currentPage().getParameters();
        pdfType                    = params.get(PDF_TYPE);
        recordIdStr                = params.get(RECORD_ID);
    }
}