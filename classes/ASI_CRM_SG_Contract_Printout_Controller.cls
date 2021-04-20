/*********************************************************************************
 * Name: ASI_CRM_SG_Contract_Printout_Controller
 * Description: Controller class for ASI_CRM_SG_Contract_Printout_Page
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 09/03/2017       Hugo Cheung             Created          
*/
public class ASI_CRM_SG_Contract_Printout_Controller {
   
    public Id contractId {get; set;}
    public boolean allowEdit {get; set;}
    public boolean forExternal {get; set;}
    public boolean forCN {get; set;}
    public boolean forSave {get; set;}

    public ASI_CRM_SG_Contract_Printout_Controller() {
        Map<String, String> params = ApexPages.currentPage().getParameters();
        contractId = params.get('id');
        string isEdit = params.get('edit');
        allowEdit = isEdit == '1' ? true : false;
        string isExternal = params.get('external');
        forExternal = isExternal == '1' ? true : false;
        string isCN = params.get('cn');
        forCN = isCN == '1' ? true : false;
        string isSave = params.get('save');
        forSave = isSave == '1' ? true : false;
    }
}