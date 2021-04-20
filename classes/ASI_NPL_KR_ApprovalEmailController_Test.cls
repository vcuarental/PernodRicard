/*
	Test Class for
	ASI_NPL_KR_ApprovalEmailController
*/
@isTest
public class ASI_NPL_KR_ApprovalEmailController_Test {

	static testMethod void ASI_NPL_KR_ApprovalEmailController_Test(){
        
        ASI_CN_NPL_NPL_Request__c npl = new ASI_CN_NPL_NPL_Request__c();
        npl.ASI_NPL_New_SKU_Name__c = 'Test';
        insert npl;
        
        ASI_NPL_KR_ApprovalEmailController con = new ASI_NPL_KR_ApprovalEmailController();
		con.header = npl;
		con.headerId = npl.Id;
		boolean dummyVar = con.dummyVar;        
	}
    
}