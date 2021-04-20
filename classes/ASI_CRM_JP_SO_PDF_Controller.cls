/*********************************************************************************
 * Name: ASI_CRM_JP_SO_PDF_Controller
 * Description: Controller class for ASI_CRM_JP_SO_PDF_Page
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 13/04/2017       Hugo Cheung             Created          
*/
public class ASI_CRM_JP_SO_PDF_Controller {
    
    //Page Parameters
    private final static String PDF_TYPE = 'pdfType';
    private final static String SOID     = 'id';
    private final static String LANGUAGE = 'language';
    private final static String FONTSIZE = 'fontSize';
 	
    public String pdfType     {get; set;}
    public String soIdStr     {get; set;}
    public String pdfLanguage {get; set;}
    public String fontSizeStr {get; set;}
    
    public ASI_CRM_JP_SO_PDF_Controller() {
        Map<String, String> params = ApexPages.currentPage().getParameters();
        pdfType                    = params.get(PDF_TYPE);
        soIdStr                    = params.get(SOID);
        pdfLanguage                = params.get(LANGUAGE);
        fontSizeStr                = params.get(FONTSIZE);
    }
}