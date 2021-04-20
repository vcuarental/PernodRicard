({
	expandNodeMethod: function(cmp, e, hlpr) {
		var typeId = e.getParams().arguments.typeId;
		setTimeout(function() {
			$A.run(function() {
				var $treeView = $('#activityTreeView');
				var $type = $treeView.find('[data-type-id="' + typeId + '"]');
				var $el = $type.closest('ul');
				var $target = $el.closest('li').find('button');

				$treeView.find('li').removeClass('slds-tree__item--active');
				$type.closest('li').addClass('slds-tree__item--active');

				if ($el.hasClass('slds-hide')) {
					$el.removeClass('slds-hide');
					$target.removeClass('arrow-right');
				}
			});
		}, 100);
	},
	expandNode: function(cmp, e, hlpr) {
		var $target = $(e.target);
		var $el = $target.closest('li').find('ul');
		if ($el.hasClass('slds-hide')) {
			$el.removeClass('slds-hide');
			$target.removeClass('arrow-right');
		} else {
			$el.addClass('slds-hide');
			$target.addClass('arrow-right');
		}
	},
	selectActivityType: function(cmp, e, hlpr) {
		var params = e.getParams ? e.getParams() : e.target.dataset;
		if (params.typeId) {
			$('#activityTreeView').find('li').removeClass('slds-tree__item--active');
			$(e.target).closest('li').addClass('slds-tree__item--active');

			cmp.getEvent('ActivityTypeSelectEvent').setParams({
				activityTypeId: params.typeId
			}).fire();
		}
	}
})