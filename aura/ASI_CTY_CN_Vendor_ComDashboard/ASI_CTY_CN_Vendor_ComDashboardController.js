({
	doInit : function(component, event, helper) {
		var showYearOptions =['2018','2019','2020'];
		component.set('v.showYearOptions', showYearOptions);

		var showMonthOptions = ['1','2','3','4','5','6','7','8','9','10','11','12'];
		component.set('v.showMonthOptions', showMonthOptions);

		var showTypeOption1 ={
			'label': $A.get('{!$Label.c.ASI_CTY_CN_Vendor_By_Quantity}'),
			'value':'1'
		};

		var showTypeOption2 ={
			'label': $A.get('{!$Label.c.ASI_CTY_CN_Vendor_By_Amount}'),
			'value':'2'
		};


		var showTypeOptions = [];
		showTypeOptions.push(showTypeOption1);
		showTypeOptions.push(showTypeOption2);
		component.set('v.showTypeOptions', showTypeOptions);
		component.set('v.showType', '1');
        
        helper.initDate(component,helper);
		//helper.helperMethod();

	},

	changeShowType :function(component, event, helper)
	{
		var showType = event.getSource().get('v.id');
		component.set('v.showType', showType);
		 helper.initDate(component,helper);
	}
})