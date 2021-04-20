({
	doInit : function(component, event, helper) {
        helper.loadSelectedTab(component);
		var userId = $A.get("$SObjectType.CurrentUser.Id");
        helper.getAccountIdFromUser(component);
		component.set('v.userId', userId);
		
		helper.getTitulosListViewNames(component);
		helper.getAccountDetails(component);
		helper.getOpportunity(component);
        helper.getRelatedContacts(component);
        //helper.getAccountId(component);
	}

})