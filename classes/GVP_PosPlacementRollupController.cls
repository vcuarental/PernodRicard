public with sharing class GVP_PosPlacementRollupController {

	public static void posPlacementRollupSummary(List<gvp__POS_Placement__c> pNewPlacements, List<gvp__POS_Placement__c> pOldPlacements) {

		//skip trigger logic if executing user flag is set
		User user = [SELECT BypassVR__c FROM User WHERE Id = :UserInfo.getUserId()];
		if (user.BypassVR__c) {
			return;
		}

		List<gvp__POS_Placement__c> allPlacements = new List<gvp__POS_Placement__c>();
		if (pNewPlacements != null) {
			allPlacements.addAll(pNewPlacements);
		}
		if (pOldPlacements != null) {
			allPlacements.addAll(pOldPlacements);
		}

		Set<Id> posMaterialIds = new Set<Id>();
		for (gvp__POS_Placement__c currentPlacement : allPlacements) {
			posMaterialIds.add(currentPlacement.gvp__POS_Item__c);
		}

		Map<ID, gvp__POS_Placement__c> placementsForMaterials =
			new Map<ID, gvp__POS_Placement__c>([SELECT
			                                        gvp__POS_Item__c,
			                                        gvp__Quantity__c
			                                    FROM
			                                        gvp__POS_Placement__c
			                                    WHERE
			                                        GVP_Status__c != 'Closed' AND
			                                        gvp__POS_Item__c IN :posMaterialIds]);

		Map<ID, gvp__POS_Material__c> relatedMaterials =
			new Map<ID, gvp__POS_Material__c>([SELECT
			                                       Id,
			                                       GVP_Placed__c
			                                   FROM
			                                       gvp__POS_Material__c
			                                   WHERE
			                                       Id IN :posMaterialIds]);
		List<gvp__POS_Material__c> posMaterialsToUpdate = new List<gvp__POS_Material__c>();
		Decimal placementQuantity;
		for (gvp__POS_Material__c currentPosMaterial : relatedMaterials.values()) {
			placementQuantity = 0;
			for (gvp__POS_Placement__c currentPlacement : placementsForMaterials.values()) {
				if (currentPlacement.gvp__POS_Item__c == currentPosMaterial.Id) {
					placementQuantity += currentPlacement.gvp__Quantity__c;
				}
			}
			if (currentPosMaterial.GVP_Placed__c != placementQuantity) {
				currentPosMaterial.GVP_Placed__c = placementQuantity;
				posMaterialsToUpdate.add(currentPosMaterial);
			}
		}
		if (!posMaterialsToUpdate.isEmpty()) {
			update posMaterialsToUpdate;
		}
	}
}