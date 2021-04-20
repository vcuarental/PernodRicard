/*********************************************************************************
 * Name:ASI_CRM_SG_FreeGoodsController
 * Description: Class for Free Goods Related Action
 * Test Class: ASI_CRM_SG_FreeGoodsRequest_Test
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
  * 20180207       Wilken	         		[WL 1.0] Created
*********************************************************************************/

public with sharing class ASI_CRM_SG_FreeGoodsController{

    public ASI_FOC_Free_Goods_Request__c freeGoods {get;set;}

    public pageReference setToDraft(){
        Pagereference pageref;
		
		List<GroupMember> gmList = [select UserOrGroupId from GroupMember where GroupId in (select Id from Group where DeveloperName = 'ASI_CRM_SG_Sales_BA')];
		
		Boolean isAdmin = false;
		
		for (GroupMember gm:gmList){
			if (UserInfo.getUserId() == gm.UserOrGroupId)
				isAdmin = true;
		}
		
		if (isAdmin){
			try {
				freeGoods.recordTypeId = Global_RecordTypeCache.getRTId('ASI_FOC_Free_Goods_Request__cASI_CRM_SG_FOC');
				freeGoods.ASI_CRM_Sync_to_JDE__c = false;
				freeGoods.ASI_FOC_Request_Status__c = 'Draft';
				freeGoods.ASI_CRM_JDE_SO_Number__c = '';
				
				update freeGoods;				
				
				pageref = new PageReference('/'+ freeGoods.Id);
			} 
			catch(exception e) {
				pageRef = null;   
				String strError = e.getMessage() +'|'+ String.valueOf(e.getLineNumber());
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, strError));
			}
        }
		
		else {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please contact Sales Business Analyst to update the Free Goods Request'));
		}
        return pageRef;
    }

    public ASI_CRM_SG_FreeGoodsController (ApexPages.StandardController stdController){
        
        this.freeGoods = (ASI_FOC_Free_Goods_Request__c)stdController.getRecord();
    }    
}