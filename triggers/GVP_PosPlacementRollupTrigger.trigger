trigger GVP_PosPlacementRollupTrigger on gvp__POS_Placement__c (after delete, after insert, after undelete, after update) {
	GVP_PosPlacementRollupController.PosPlacementRollupSummary(Trigger.new, Trigger.old);
}