({
	init: function(cmp, event, helper)
	{
		var action = cmp.get('c.getTodayVisit');
		action.setCallback(this, function(r)
		{
			var state = r.getState();
			if (cmp.isValid() && state === 'SUCCESS')
			{
				var today = $A.localizationService.formatDate(new Date(), 'YYYY-MM-DD');
				var mapMarkers = [];
				var resultData = r.getReturnValue();

				resultData.forEach(function(r)
				{
					if (r.vpd.ASI_CRM_MY_Customer__r.ASI_CRM_CN_GPS_info__Latitude__s != undefined
						&& r.vpd.ASI_CRM_MY_Customer__r.ASI_CRM_CN_GPS_info__Longitude__s != undefined)
					{
						mapMarkers.push({
							location: {
								Latitude: r.vpd.ASI_CRM_MY_Customer__r.ASI_CRM_CN_GPS_info__Latitude__s,
								Longitude: r.vpd.ASI_CRM_MY_Customer__r.ASI_CRM_CN_GPS_info__Longitude__s
							},
							title: r.vpd.ASI_CRM_MY_Customer__r.Name,
							description: r.custAddress
						});	
					}
					// else if (r.ASI_CRM_MY_Customer__r.ASI_CRM_CN_Address__c != undefined)
					// {
					// 	mapMarkers.push({
					// 		location: {
					// 			Street: r.ASI_CRM_MY_Customer__r.ASI_CRM_CN_Address__c
					// 		},
					// 		title: r.ASI_CRM_MY_Customer__r.Name,
					// 		description: r.ASI_CRM_MY_Customer__r.ASI_CRM_CN_Address__c
					// 	});	
					// }
				});

				cmp.set('v.vpdList', resultData);
				cmp.set('v.vDate', today);
				cmp.set('v.vCount', resultData.length);
				cmp.set('v.mapMarkers', mapMarkers);

				if (mapMarkers.length == 1)
				{
					cmp.set('v.zoomLevel', 15);
					console.log(15);
				}
				else
				{
					cmp.set('v.zoomLevel', null);
					console.log('no');
				}

				cmp.set('v.mapTitle', 'Today\'s Visit');
			}
		});
		$A.enqueueAction(action);
	}
});