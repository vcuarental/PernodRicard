public with sharing class GVP_RackController {
	public String mode { get; set; }
	public gvp__POS_Placement__c placement { get; set; }
	public GVP_AssignRackController assignRackController { get; set; }

	private static PageReference savePlacement(gvp__POS_Placement__c pPlacement) {
		try {
			upsert pPlacement;
			if (ApexPages.currentPage().getParameters().containsKey('retURL')) {
				return new PageReference(ApexPages.currentPage().getParameters().get('retURL'));
			}
			return new PageReference('/' + pPlacement.Id);
		} catch (Exception e) {
			ApexPages.addMessage(
				new ApexPages.Message(
					ApexPages.Severity.ERROR, e.getMessage()
				)
			);
		}
		return null;
	}

	private static gvp__POS_Placement__c getPlacement(Id pPlacementId) {
		return [SELECT
		            gvp__Quantity__c,
		            gvp__Program__c,
		            gvp__Picture_Attached__c,
		            gvp__POS_Item__c,
		            gvp__Label__c,
		            gvp__Item__c,
		            gvp__External_Id__c,
		            gvp__Date_Delivered__c,
		            gvp__Custom_Fact_2__c,
		            gvp__Custom_Fact_1__c,
		            gvp__Custom_5__c,
		            gvp__Custom_4__c,
		            gvp__Custom_3__c,
		            gvp__Custom_2__c,
		            gvp__Custom_1__c,
		            gvp__Compliance__c,
		            gvp__Brand__c,
		            gvp__Approved__c,
		            gvp__Activity_Goal__c,
		            gvp__Account__c,
		            gvp__Account_Call__c,
		            SystemModstamp,
		            Name,
		            LastViewedDate,
		            LastReferencedDate,
		            LastModifiedDate,
		            LastModifiedById,
		            LastActivityDate,
		            IsDeleted,
		            Id,
		            CurrencyIsoCode,
		            CreatedDate,
		            CreatedById,
		            GVP_Status__c,
		            GVP_Start_Date__c,
		            GVP_End_Date__c,
		            GVP_Assignment_Duration__c
		        FROM
		            gvp__POS_Placement__c
		        WHERE
		            Id = :pPlacementId];
	}

	public GVP_RackController(ApexPages.StandardController stdController) {
		if (ApexPages.currentPage().getParameters().get('clone') == '1') {
			mode = 'New';
			String placementId = ApexPages.currentPage().getParameters().get('id');
			placement = getPlacement(placementId).clone();
			if (placement.gvp__Account__c == null) {
				return;
			}
			assignRackController = new GVP_AssignRackController();
			assignRackController.loadData(new List<String>{ placement.gvp__Account__c });
			return;
		}
		assignRackController = new GVP_AssignRackController();
		placement = (gvp__POS_Placement__c)stdController.getRecord();
		assignRackController.loadData(new List<String>{ placement.gvp__Account__c });
		if (ApexPages.currentPage().getParameters().containsKey('CF00ND0000005Skhb_lkid')) {
			placement.gvp__POS_Item__c = ApexPages.currentPage().getParameters().get('CF00ND0000005Skhb_lkid');
		}
		mode = (this.placement.Id == null) ? 'New' : 'Edit';
	}

	public PageReference savePlacement() {
		return savePlacement(placement);
	}

	public PageReference cancelPlacement() {
		return new PageReference(ApexPages.currentPage().getParameters().get('retURL'));
	}
}