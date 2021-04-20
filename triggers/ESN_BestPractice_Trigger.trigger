trigger ESN_BestPractice_Trigger on ESN_Best_Practice__c (before insert, before update) {

	if(Trigger.isBefore){
		if(Trigger.isUpdate){
			ESN_BP_Tools.CopyRichTextFields(Trigger.new);
			ESN_BP_Tools.UpdateContributorMail(Trigger.new);
		}
		if(Trigger.isInsert){
			ESN_BP_Tools.CopyRichTextFields(Trigger.new);
			ESN_BP_Tools.UpdateContributorMail(Trigger.new);
		}
	}
	
}