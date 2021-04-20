({
	init: function(cmp, event, helper)
	{
		document.title = 'Today\'s Visitation';
		helper.init(cmp, event, helper);
	},
	
	toVisitation : function(cmp, event, helper)
	{
		var target = event.currentTarget;
		var id = target.dataset.id;
		var nav = cmp.find('navService');
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
	},

	toAdHoc : function(cmp, event, helper)
	{
		var modalBody;

		$A.createComponent('c:ASI_CRM_Visitation_Adhoc', {
			cbObject: cmp.getReference('v.cbObject')
		},
			function (content, status) {
				if (status === 'SUCCESS') {
					modalBody = content;

					cmp.find('overlayLib').showCustomModal({
						header: 'Adhoc Visitation',
						body: modalBody,
						showCloseButton: true,
						closeCallback: function () {
							var cbObject = cmp.get('v.cbObject');
							if (cbObject != null)
							{
								if (cbObject.alert)
								{
									swal.fire({
										title: cbObject.alert.title,
										text: cbObject.alert.text,
										confirmButtonColor: '#3085d6',
										cancelButtonColor: '#d33',
										confirmButtonText: 'OK'
									}).then((result) => {
										if (result.value)
										{
											if (cbObject.refresh)
											{
												$A.get('e.force:refreshView').fire();
											}
										}
									});
								}

								cmp.set('v.cbObject', null);
							}
						}
					});
				}
			});
	}
});