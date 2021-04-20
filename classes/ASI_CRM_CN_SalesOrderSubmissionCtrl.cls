/*********************************************************************************
 * Name:ASI_CRM_CN_SalesOrderSubmissionCtrl 
 * Description: Submission action for CN Sales Order
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    -------------------------------------
 * 2019-06-23       Laputa: Vincent Lam     Created, break sales order line items for promotion
*********************************************************************************/

public with sharing class ASI_CRM_CN_SalesOrderSubmissionCtrl {
  private static final String SALESORDERLINE = 'ASI_KOR_Sales_Order_Transaction__c';
  
  public class applicationException extends Exception {}
  
  public ASI_CRM_CN_SalesOrderSubmissionCtrl(){
    
    }
    
    public PageReference proceed(){
        String soId = Apexpages.currentpage().getparameters().get('id');
        if(soId != null && soId != ''){
			splitLineByPromotion(soId);
			PageReference pageRef = new PageReference('/apex/ASI_SubmitApprovalPage?id=' + soId);
			return pageRef;
        }else{
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'You are not allowed to perform this action.'));
			return null;
		}
        
        
    }
	
	private void splitLineByPromotion(string soId){
		string query = 'Select ' + getAllFieldsForSOQL(SALESORDERLINE) + 
            			' from ' + SALESORDERLINE +
						' where ASI_KOR_Sales_Order_Request__c = \'' + soId + '\' ' +
            			' and ASI_CRM_Order_Qty_Exceed_Promotion__c <> 0' +
            			' and ASI_CRM_CN_Promotion_Code__r.ASI_CRM_Type__c = \'Buy X Get Y\'' ;
		list<ASI_KOR_Sales_Order_Transaction__c> list_soLine = Database.query(query);
		if(list_soLine.size() > 0){
			upsert salesOrderLineForUpsert(list_soLine);
		}
	}
	
	private list<ASI_KOR_Sales_Order_Transaction__c> salesOrderLineForUpsert(list<ASI_KOR_Sales_Order_Transaction__c> list_soLine){
		list<ASI_KOR_Sales_Order_Transaction__c> list_forUpsert = new list<ASI_KOR_Sales_Order_Transaction__c>();
		for(ASI_KOR_Sales_Order_Transaction__c l : list_soLine){
			decimal outstandingQty = l.ASI_CRM_Order_Qty_Exceed_Promotion__c;
			l.ASI_KOR_Order_Qty__c -= outstandingQty;
			list_forUpsert.add(l);
			
			ASI_KOR_Sales_Order_Transaction__c newLine = l.clone(false, true, false, false);
			newLine.ASI_KOR_Order_Qty__c = outstandingQty;
			newLine.ASI_CRM_Sales_Order_Request_Item__c = l.Id;
            newLine.ASI_CRM_CN_Promotion_Code__c = null;
			list_forUpsert.add(newLine);
		}
		return list_forUpsert;
	}
	
	public String getAllFieldsForSOQL(string objectName){
		List<string> list_field = new List<string>(Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().keySet());
		return String.join(list_field,',');
	}
}