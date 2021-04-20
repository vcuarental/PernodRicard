({
	init: function(cmp, event, helper)
	{
		document.title = "Previous Visitation";
		var pageReference = cmp.get("v.pageReference");
		cmp.set("v.customerID", pageReference.state.c__cid);
		cmp.set("v.visitID", pageReference.state.c__vid);

		var page = cmp.get("v.page");
		var pSize = cmp.get("v.pageSize");
		var customerID = cmp.get("v.customerID");
		var visitID = cmp.get("v.visitID");

		helper.getRecords(cmp, event, helper, customerID, visitID, page, pSize);
	},

	nextPage: function(cmp, event, helper)
	{
		var page = cmp.get("v.page");
		var totalPage = cmp.get("v.totalPage");
		var customerID = cmp.get("v.customerID");
		var visitID = cmp.get("v.visitID");

		if (page >= totalPage)
		{
			return;
		}

		page++;
		var pSize = cmp.get("v.pageSize");
		helper.getRecords(cmp, event, helper, customerID, visitID, page, pSize);
	},

	previousPage: function(cmp, event, helper)
	{
		var page = cmp.get("v.page");
		var customerID = cmp.get("v.customerID");
		var visitID = cmp.get("v.visitID");

		if (page <= 1)
		{
			return;
		}

		page--;
		var pSize = cmp.get("v.pageSize");
		helper.getRecords(cmp, event, helper, customerID, visitID, page, pSize);
	},

	goPage: function(cmp, event, helper)
	{
		var input = cmp.find("inputPage");
		var getPage = input.get("v.value");
		var page = parseInt(getPage, 10);
		var totalPage = cmp.get("v.totalPage");
		var customerID = cmp.get("v.customerID");
		var visitID = cmp.get("v.visitID");
		
		if (page == NaN || page <= 1)
		{
			page = 1;
		}
		else if (page > totalPage)
		{
			page = totalPage;
		}

		var pSize = cmp.get("v.pageSize");
		helper.getRecords(cmp, event, helper, customerID, visitID, page, pSize);
	},

	toVisitation : function(cmp, event, helper)
	{
		var target = event.currentTarget;
		var id = target.dataset.id;
		var nav = cmp.find("navService");
		var pageReference = {
			type: 'standard__component',
			attributes: {
				componentName: 'c__ASI_CRM_VisitationPlanToday'
			}, 
			state: {
				c__id: id
			}
		};

        nav.navigate(pageReference);
	}
});