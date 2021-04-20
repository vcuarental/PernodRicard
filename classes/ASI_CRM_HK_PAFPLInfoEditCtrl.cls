/*********************************************************************************
 * Name:ASI_CRM_HK_PAFPLInfoEditCtrl
 * Description: Controller for PAF Edit P&L page
 * Test Class: ASI_CRM_HK_PAFExpireListTest
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
  * 20180918       	Wilken	         		[WL 1.0] Created
*********************************************************************************/
public class ASI_CRM_HK_PAFPLInfoEditCtrl {	
	public ASI_HK_CRM_Pre_Approval_Form__c paf {get;set;}
	
	public ASI_CRM_HK_PAFPLInfoEditCtrl(ApexPages.StandardController stdController) {        
		ASI_HK_CRM_Pre_Approval_Form__c thisPAF = (ASI_HK_CRM_Pre_Approval_Form__c)stdController.getRecord();
		paf = [SELECT Id, ASI_HK_CRM_PAF_Customer2__c, ASI_HK_CRM_PAF_Customer3__c, ASI_HK_CRM_PAF_Customer4__c, 
				ASI_CRM_HK_PAF_no__c, ASI_CRM_HK_PAF_no_2__c, ASI_CRM_HK_PAF_no_3__c, ASI_CRM_HK_PAF_no_4__c, ASI_CRM_HK_PAF_no_5__c,
					ASI_CRM_HK_Pl_volume1__c, ASI_CRM_HK_Pl_volume2__c, ASI_CRM_HK_Pl_volume3__c, ASI_CRM_HK_Pl_volume4__c, ASI_CRM_HK_Pl_volume5__c,
						ASI_CRM_Ref_Start_Date__c, ASI_CRM_Ref_End_Date__c FROM ASI_HK_CRM_Pre_Approval_Form__c WHERE Id = :thisPAF.Id];		
	}
	
	public pageReference saveRecord(){
		Pagereference pageref;
		update paf;
		
		pageref = new PageReference('/'+ paf.Id);
		
		return pageRef;
	}
}