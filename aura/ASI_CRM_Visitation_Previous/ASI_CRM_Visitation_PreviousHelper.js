({
	getRecords: function(cmp, event, helper, customerID, visitID, page, pSize)
	{
		var action = cmp.get("c.getPreviousVisit");
		action.setParams({
			customerID: customerID,
			visitID: visitID,
			page: page,
			pSize: pSize
		});
		action.setCallback(this, function(r)
		{
			var state = r.getState();
			if (cmp.isValid() && state === "SUCCESS")
			{
				var resultData = r.getReturnValue();
				cmp.set("v.vpdList", resultData.vpdList);
				cmp.set("v.vCount", resultData.vpdList.length);
				cmp.set("v.page", resultData.page);
				cmp.set("v.inputPage", resultData.page);
				cmp.set("v.totalPage", resultData.totalPage);
			}
		});
		$A.enqueueAction(action);
	}
});