({
    initYearMonth : function(component) {
        var action = component.get('c.getShowYearMonth');
        var myDate = new Date();
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS' && component.isValid()){
                var rows = response.getReturnValue();
                var yearOptions = [];
                var monthOptions = [];
                component.set('v.yearMonthMap', rows);
                for (var item in rows) {
                    yearOptions.push(item);
                    if (myDate.getFullYear() == item) {
                        component.set('v.showYear', item);
                        component.set('v.showMonthOptions', rows[item]);
                        component.set('v.showMonth', myDate.getMonth()+1+'');
                    }
                }
                component.set('v.showYearOptions', yearOptions);
            }else{
                var error = response.getError();
                console.log(error);
            }
        });
        
        $A.enqueueAction(action);
    },

    initDBOrder : function(component) {
        var action = component.get('c.getDefaultDashboardList');
        var currentShowDBType = component.get('v.showType');
        var myDate = new Date();
        var showYear = myDate.getFullYear();
        var showMonth = myDate.getMonth()+1;
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS' && component.isValid()){
                var rows = response.getReturnValue();
                var currentDBShowList = new Array();
                for(var item in rows){
                    if (rows[item].showType === 'AmountType') {
                        rows[item].totalSOR = (rows[item].totalSOR % 10000==0) ? (rows[item].totalSOR/10000) : (rows[item].totalSOR/10000).toFixed(2);
                        rows[item].inApprovalSOR = (rows[item].inApprovalSOR % 10000==0) ? (rows[item].inApprovalSOR/10000) : (rows[item].inApprovalSOR/10000).toFixed(2);
                        rows[item].approvedSOR = (rows[item].approvedSOR % 10000==0) ? (rows[item].approvedSOR/10000) : (rows[item].approvedSOR/10000).toFixed(2);
                        rows[item].approvedTOV = (rows[item].approvedTOV % 10000==0) ? (rows[item].approvedTOV/10000) : (rows[item].approvedTOV/10000).toFixed(2);
                        rows[item].pendingPaymentTOV = (rows[item].pendingPaymentTOV % 10000==0) ? (rows[item].pendingPaymentTOV/10000) : (rows[item].pendingPaymentTOV/10000).toFixed(2);
                        rows[item].inDeliveryTOV = (rows[item].inDeliveryTOV % 10000==0) ? (rows[item].inDeliveryTOV/10000) : (rows[item].inDeliveryTOV/10000).toFixed(2);
                        rows[item].complatedTOV = (rows[item].complatedTOV % 10000==0) ? (rows[item].complatedTOV/10000) : (rows[item].complatedTOV/10000).toFixed(2);
                        rows[item].monthReturnTOV = (rows[item].monthReturnTOV % 10000==0) ? (rows[item].monthReturnTOV/10000) : (rows[item].monthReturnTOV/10000).toFixed(2);
                        rows[item].historyPaymentTOV = rows[item].historyPaymentTOV > 1000000 || (rows[item].historyPaymentTOV % 10000==0) ? Math.floor(rows[item].historyPaymentTOV/10000) : (rows[item].historyPaymentTOV/10000).toFixed(2);
                    } else {
                        rows[item].historyPaymentTOV = rows[item].historyPaymentTOV > 1000 ? Math.floor(rows[item].historyPaymentTOV*1000/1000) : rows[item].historyPaymentTOV;
                    }
                    if (rows[item].showType === currentShowDBType && 
                        rows[item].showYear == showYear 
                        && rows[item].showMonth == showMonth) {
                        currentDBShowList.push(rows[item]);
                    }
                }
                component.set('v.showDBList', rows);
                if (currentDBShowList.length > 0) {
                    component.set('v.currentDBShow', currentDBShowList[0]);
                }
            }else{
                var error = response.getError();
                console.log(error);
            }
        });
        
        $A.enqueueAction(action);
    },

    initBrands : function(component) {
        var action = component.get('c.getDefaultBrand');
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS' && component.isValid()){
                var rows = response.getReturnValue();
                var brandList = [{label : '所有品牌', value : 'All'}];
                var brandsValues = [];
                for (var key in rows) {
                    brandsValues.push(key);
                    brandList.push({label : rows[key], value : key});
                }
                component.set('v.brandOptions', brandList);
                component.set('v.defaultBrands', brandsValues);
            }else{
                var error = response.getError();
                console.log(error);
            }
        });
        
        $A.enqueueAction(action);
    },

    loadChart : function(component, showMonths, tovList, intakeList, inventoryList, isChange) {
        if (isChange) {
            var aa = document.getElementById("canvas");
            aa.remove();
            document.getElementById("historyChart").innerHTML += '<canvas id="canvas"></canvas>';
        }
        var el = document.getElementById("canvas");
        var ctx = el.getContext('2d');
        el.height = 120;
        
        Chart.defaults.global.elements.point.radius = 7;
        Chart.defaults.global.elements.point.backgroundColor = "rgb(02,52,102)";
        
        Chart.defaults.global.defaultFontSize = 14;
        
        var newChart = new Chart(ctx, {
            type: 'bar',
            data: {
                labels: showMonths,
                datasets: [{
                    type: 'line',
                    label: $A.get('$Label.c.ASI_CTY_CN_WS_Home_Dashboard_Purchase'),
                    backgroundColor : 'rgba(255, 99, 132, 0.6)',
                    borderColor: 'rgba(255, 99, 132, 0.6)',
                    pointBackgroundColor : 'rgba(255, 99, 132, 0.6)',
                    lineTension: 0,
                    fill: false,
                    data: tovList
                },
                {
                    type: 'line',
                    label: $A.get('$Label.c.ASI_CTY_CN_WS_Home_Dashboard_Intake'),
                    backgroundColor : 'rgba(54, 162, 235, 0.6)',
                    borderColor: 'rgba(54, 162, 235, 0.6)',
                    pointBackgroundColor : 'rgba(54, 162, 235, 0.6)',
                    lineTension: 0,
                    fill: false,
                    data: intakeList
                },
                {
                    label: $A.get('$Label.c.ASI_CTY_CN_WS_Home_Dashboard_Inventory'),
                    backgroundColor: 'lightgray',
                    borderColor: 'lightgray',
                    data: inventoryList
                }]
            },
            options: {
                
                legend: {
                    display: true,
                },
                scales: {
                    xAxes: [{
                        display: true,
                        scaleLabel: {
                            display: true,
                            labelString: $A.get('$Label.c.ASI_CTY_CN_WS_Home_Dashboard_Fiscal_Year')
                        }
                    }],
                    yAxes: [{
                        display: true,
                        scaleLabel: {
                            display: false,
                            labelString: '数量'
                        },
                        ticks: {
                            beginAtZero: true,
                            //max: maxNumber
                        },
                    }]
                },
                hover: {
                    animationDuration: 0 
                },
                animation: {
                    onComplete: function() {
                       /* 
                        var chartInstance = this.chart;
                        ctx = chartInstance.ctx;
                        ctx.fillStyle = "black";
                        ctx.textAlign = 'center';
                        ctx.textBaseline = 'bottom';

                        this.data.datasets.forEach(function(dataset, i) {
                            var meta = chartInstance.controller.getDatasetMeta(i);
                            meta.data.forEach(function(bar, index) {
                                var data = dataset.data[index];
                                ctx.fillText(data, bar._model.x, bar._model.y - 10);
                            });
                        });
                        */
                    }
                }
            }
        });
    }
})