({
	helperMethod : function(storeResponse) {

	var myChart = echarts.init(document.getElementById('popChart'));

	var option = {
   
    tooltip: {
        trigger: 'axis'
    },
    legend: {
        data: [$A.get('{!$Label.c.ASI_CTY_CN_Vendor_Total}'), $A.get('{!$Label.c.ASI_CTY_CN_Vendor_Completed_SIR}'), $A.get('{!$Label.c.ASI_CTY_CN_Vendor_Payment_Requested}')]
    },
    grid: {
        left: '3%',
        right: '4%',
        bottom: '3%',
        containLabel: true
    },
   
    xAxis: {
        type: 'category',
        boundaryGap: false,
        data: storeResponse.months
    },
    yAxis: {
        type: 'value'
    },
    series: [
        {
            name:$A.get('{!$Label.c.ASI_CTY_CN_Vendor_Total}'),
            type: 'line',
            data: storeResponse.cuPoCounts
        },
        {
            name:  $A.get('{!$Label.c.ASI_CTY_CN_Vendor_Completed_SIR}'),
            type: 'line',
            data:  storeResponse.noFillSirs
        },
        {
            name: $A.get('{!$Label.c.ASI_CTY_CN_Vendor_Payment_Requested}'),
            type: 'line',
            data:  storeResponse.pendingPaymentCounts
        }
    ]
};

		myChart.setOption(option);

		
		//myChart1.setOption(option1);


	},

    initDate : function(component,helper)
    {
        var action = component.get("c.getPoDataCount");
        var showType = component.get('v.showType');
        action.setParams({
            'typeName': showType
        });
        component.set('v.showSpinner', true);
        action.setCallback(this, function(response) {
            var state = response.getState();
             component.set('v.showSpinner', false);
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                component.set('v.countPoNums',storeResponse);
                helper.helperMethod(storeResponse);
                
            } else {
                console.log('error init  po');
            }
        });
        $A.enqueueAction(action);
    }
})