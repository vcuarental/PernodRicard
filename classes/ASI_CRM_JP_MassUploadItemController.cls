/*********************************************************************************
 * Name: ASI_CRM_JP_MassUploadItemController
 * Description: Controller class for JP Mass Upload Item
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 02/03/2017       Hugo Cheung             Created          
*/
public class ASI_CRM_JP_MassUploadItemController {
    
	//Field Map
	private final static Map<String, Schema.SObjectField> PRICE_LIST_FIELD_MAP = Schema.SObjectType.ASI_CRM_Price_List__c.fields.getMap();
    
    public ASI_CRM_Price_List__c priceList {get; set;}
    
    public String effectiveDateInString {get; set;}
    public String expiryDateInString    {get; set;}
    public Boolean isWholesalerPrice    {get; set;}
    public Boolean isDCPrice    {get; set;}
    public Boolean isDirectSalesPrice    {get; set;}
    public Boolean hasCustomer    {get; set;}
    
    public String emptyValue {get{return '';}}
    
    public ASI_CRM_JP_MassUploadItemController(ApexPages.StandardController standardController) {
    	priceList = retrievePriceList(standardController.getRecord().Id);
        
        if(priceList.ASI_CRM_JP_Effective_Date__c != null) {
        	effectiveDateInString = priceList.ASI_CRM_JP_Effective_Date__c.year() + '-' + priceList.ASI_CRM_JP_Effective_Date__c.month() + '-' + priceList.ASI_CRM_JP_Effective_Date__c.day();
        }
        
        if(priceList.ASI_CRM_JP_Expiry_Date__c != null) {
        	expiryDateInString = priceList.ASI_CRM_JP_Expiry_Date__c.year() + '-' + priceList.ASI_CRM_JP_Expiry_Date__c.month() + '-' + priceList.ASI_CRM_JP_Expiry_Date__c.day();
        }
        
        if(priceList.ASI_CRM_Price_Type__c == 'Wholesaler Product Price') {
            isWholesalerPrice = true;
        }else if(priceList.ASI_CRM_Price_Type__c == 'D&C Product Price') {
            isDCPrice = true;
        }else if(priceList.ASI_CRM_Price_Type__c == 'Direct Sales Product Price') {
            isDirectSalesPrice = true;
            if(priceList.ASI_CRM_Customer__c != null){
                hasCustomer = true;
            }
        }
    }
    
    /***************
	Data Retrievement Function
	***************/
	private ASI_CRM_Price_List__c retrievePriceList(Id priceListId) {
		String query = 'SELECT ' + genQueryField(PRICE_LIST_FIELD_MAP) + ' ' + 
		               'FROM ASI_CRM_Price_List__c ' + 
		               'Where Id = :priceListId';

		List<ASI_CRM_Price_List__c> priceListList = (List<ASI_CRM_Price_List__c>) Database.query(query);
		return priceListList.size() > 0 ? priceListList.get(0) : null;
	}
    
    /***************
	Tools Function
	***************/
	private String genQueryField(Map<String, Schema.SObjectField> fieldMap) {
	    String queryField = '';
	    for(String fields : fieldMap.keySet()) {
	      queryField += fields + ',';
	    }
	    return queryField.subString(0, queryField.length() - 1);
  	}
}