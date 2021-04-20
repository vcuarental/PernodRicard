({
	getBudget: function(cmp, e) {
		var action = cmp.get("c.getCurrentBudget");
		action.setCallback(this, function(response) {
			if (cmp.isValid() && response.getState() === "SUCCESS") {
				cmp.set("v.budget", response.getReturnValue());
			}
		});
		$A.enqueueAction(action);
	}
})