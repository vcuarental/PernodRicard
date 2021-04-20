({
	switchTabs: function(targetItem) {
		var $target = $(targetItem);
		var $tabsCmp = $('#homeTabs');
		$tabsCmp.find('li.slds-active').removeClass("slds-active");
		$target.closest('li').addClass("slds-active");
		//targetItem.parentElement.classList.add("slds-active")
		// $A.util.addClass(targetItem.parentElement, "slds-active");
		//console.log(targetItem.parentElement.classList);

		var params = $target.data();
		if (params && params.controls) {
			$tabsCmp.children('div').removeClass('slds-show').addClass('hidd');
			$(params.controls).addClass('slds-show');
		}
	}
})