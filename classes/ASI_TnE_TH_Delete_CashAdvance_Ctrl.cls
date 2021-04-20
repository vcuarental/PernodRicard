global without sharing class ASI_TnE_TH_Delete_CashAdvance_Ctrl {
	webService static Boolean deleteCashAdv(Id id) {
		ASI_TnE_Cash_Advance_Pre_Approval__c c = new ASI_TnE_Cash_Advance_Pre_Approval__c(id = id);
		try {
		  delete c;
		  return true;
		} catch (Exception e) {
		  return false;
		}
	}
}