({
	init : function(component, event, helper) {
		helper.getPreviousOrders(component, event, helper);
	},
	handlePageBlur: function(component, event, helper) {
		var currentPage = component.get('v.currentPage');
		var totalPages = component.get('v.totalPages');

		if (currentPage >= 1 && currentPage <= totalPages) {
			helper.getPreviousOrders(component, event, helper);
		}
	},
	handlePageClick: function(component, event, helper) {
			var source = event.getSource();
			var name = source.get('v.name');
			var currentPage = component.get('v.currentPage');
			var totalPages = component.get('v.totalPages');

			if (name === 'previous' && currentPage > 1) {
					currentPage -= 1;
			}
			if (name === 'next' && currentPage < totalPages) {
					currentPage += 1;
			}

			component.set("v.disabledPrevious", currentPage === 1);
			component.set("v.disabledNext", currentPage === totalPages);
			component.set('v.currentPage', currentPage);
			helper.getPreviousOrders(component, event, helper);
	},
	navigateToOrderDetails : function(component, event, helper) {
		var nav = component.find("navService");
		var recordId = event.currentTarget.dataset.id;
		var recordNum = event.currentTarget.dataset.recordNum;

		var pageReference = {
			type: 'standard__component',
			attributes: {
				componentName: 'c__ASI_CRM_VisitationOrderDetails'
			}, 
			state: {
				c__id: recordId,
				c__recordNum: recordNum
			}
		};

		nav.navigate(pageReference);
	},
	
})