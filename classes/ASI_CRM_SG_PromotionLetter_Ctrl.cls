/*********************************************************************************
 * Name:ASI_CRM_SG_PromotionLetter_Ctrl
 * Description: Controller for printing promotion letter (ASI_CRM_SG_PromotionLetter_Page)
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 04/04/2018       Hugo Cheung             Created
*********************************************************************************/
public class ASI_CRM_SG_PromotionLetter_Ctrl {
    
    //Component Parameters
    public String promotionId        {get; set;}
    public String customerId         {get; set;}
    public String contactName        {get; set;}
    public String contactDesignation {get; set;}
    public String contactNumber      {get; set;}
    
    public ASI_CRM_SG_PromotionLetter_Ctrl() {
    	Map<String, String> pageParaMap = ApexPages.currentPage().getParameters();
        promotionId        = pageParaMap.get('promotionId');
        customerId         = pageParaMap.get('customerId');
        contactName        = pageParaMap.get('contactName');
        contactDesignation = pageParaMap.get('contactDesignation');
        contactNumber      = pageParaMap.get('contactNumber');
    }
    
}