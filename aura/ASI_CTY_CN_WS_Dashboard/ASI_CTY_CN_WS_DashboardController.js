({
    doInit : function(component, event, helper) {
        console.log('init');
        component.set('v.showTypeOptions', [{label : $A.get('$Label.c.ASI_CTY_CN_WS_Home_Dashboard_Type_Number'), value : 'NumberType'},
                                            {label : $A.get('$Label.c.ASI_CTY_CN_WS_Home_Dashboard_Type_Amount'), value : 'AmountType'},
                                            {label : $A.get('$Label.c.ASI_CTY_CN_WS_Home_Dashboard_Type_CA'), value : 'CAType'},
                                            {label : $A.get('$Label.c.ASI_CTY_CN_WS_Home_Dashboard_Type_9L'), value : '9LType'}]);
        component.set('v.hisShowTypeOptions', [{label : $A.get('$Label.c.ASI_CTY_CN_WS_Home_Dashboard_Type_BT'), value : 'hisBTType'},
                                               {label : $A.get('$Label.c.ASI_CTY_CN_WS_Home_Dashboard_Type_9L'), value : 'his9LType'}]);
        helper.initYearMonth(component);
        helper.initDBOrder(component);
        helper.initBrands(component);

        var action = component.get('c.getDashboardHistoryList');
        var currentType = component.get('v.hisShowType');
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS' && component.isValid()){
                var rows = response.getReturnValue();
                var myDate = new Date();
                var showMonths = rows.length > 0 ? rows[0].months : [myDate.getMonth()+1+'月'];
                var tovList = [];
                var intakeList = [];
                var inventoryList = [];
                var currentDBHisShow = [];
                var brandList = component.get('v.brandOptions');
                var brands = component.get('v.defaultBrands');
                var showTables = [];
                for (var key in showMonths) {
                    showTables.push({'Month': showMonths[key], 'TovNumber' : 0, 'IntakeNumber' : 0, 'InventoryNumber' : 0});
                }
                component.set('v.hisShowDBList', rows);
                for(var item in rows){
                    if (rows[item].historyShowType === currentType ) {
                        currentDBHisShow.push(rows[item]);
                    }
                }
                if (currentDBHisShow.length > 0) {
                    for (var item1 in currentDBHisShow) {
                        if (currentDBHisShow[item1].brandValue && brands.indexOf(currentDBHisShow[item1].brandValue) == -1) {
                            brands.push(currentDBHisShow[item1].brandValue);
                            brandList.push({label : currentDBHisShow[item1].brandLabel, value : currentDBHisShow[item1].brandValue});
                        }
                        var tovHis = (Number(currentDBHisShow[item1].tovHis) % 1==0) ? (Number(currentDBHisShow[item1].tovHis)/1) : (Math.floor(currentDBHisShow[item1].tovHis*100)/100);
                        var intakeHis = (Number(currentDBHisShow[item1].intakeHis) % 1==0) ? (Number(currentDBHisShow[item1].intakeHis)/1) : (Math.floor(currentDBHisShow[item1].intakeHis*100)/100);
                        var inventoryHis = (Number(currentDBHisShow[item1].inventoryHis) % 1==0) ? (Number(currentDBHisShow[item1].inventoryHis)/1) : (Math.floor(currentDBHisShow[item1].inventoryHis*100)/100);
                        for (var item2 in showTables) {
                            if (showTables[item2].Month === (currentDBHisShow[item1].showMonth + '月')) {
                                showTables[item2].TovNumber = showTables[item2].TovNumber + tovHis;
                                showTables[item2].IntakeNumber = showTables[item2].IntakeNumber + intakeHis;
                                showTables[item2].InventoryNumber = showTables[item2].InventoryNumber + inventoryHis;
                            }
                        }
                    }
                }
                for (var key1 in showTables) {
                    showTables[key1].TovNumber = (Number(showTables[key1].TovNumber) % 1==0) ? (Number(showTables[key1].TovNumber)/1) : (Math.floor(showTables[key1].TovNumber*100)/100);
                    showTables[key1].IntakeNumber = (Number(showTables[key1].IntakeNumber) % 1==0) ? (Number(showTables[key1].IntakeNumber)/1) : (Math.floor(showTables[key1].IntakeNumber*100)/100);
                    showTables[key1].InventoryNumber = (Number(showTables[key1].InventoryNumber) % 1==0) ? (Number(showTables[key1].InventoryNumber)/1) : (Math.floor(showTables[key1].InventoryNumber*100)/100);
                    tovList.push(showTables[key1].TovNumber);
                    intakeList.push(showTables[key1].IntakeNumber);
                    inventoryList.push(showTables[key1].InventoryNumber);
                }
                component.set('v.showTables', showTables);
                component.set('v.brandOptions', brandList);
                component.set('v.defaultBrands', brands);
                helper.loadChart(component,showMonths,tovList,intakeList,inventoryList,false);
            }else{
                var error = response.getError();
                console.log(error);
            }
        });

      $A.enqueueAction(action);
    },

    changeYear : function(component, event, helper) {
        var selectYear = component.find('selectYear').get('v.value');
        component.set('v.showYear', selectYear);
        var yearMonthMap = component.get('v.yearMonthMap');
        component.set('v.showMonthOptions', yearMonthMap[selectYear]);
        var selectMonth = yearMonthMap[selectYear][(yearMonthMap[selectYear].length)-1];
        component.set('v.showMonth', selectMonth);
        var showDBList = component.get('v.showDBList');
        var currentDBShowList = [];
        var currentShowDBType = component.get('v.showType');
        for(var item in showDBList){
            if (showDBList[item].showType === currentShowDBType && 
                showDBList[item].showYear == selectYear 
                && showDBList[item].showMonth == selectMonth) {
                currentDBShowList.push(showDBList[item]);
            }
        }
        if (currentDBShowList.length > 0) {
            component.set('v.currentDBShow', currentDBShowList[0]);
        }
    },

    changeMonth : function(component, event, helper) {
        var selectMonth = component.find('selectMonth').get('v.value');
        component.set('v.showMonth', selectMonth);
        var selectYear = component.get('v.showYear');
        var showDBList = component.get('v.showDBList');
        var currentDBShowList = [];
        var currentShowDBType = component.get('v.showType');
        for(var item in showDBList){
            if (showDBList[item].showType === currentShowDBType && 
                showDBList[item].showYear == selectYear 
                && showDBList[item].showMonth == selectMonth) {
                currentDBShowList.push(showDBList[item]);
            }
        }
        if (currentDBShowList.length > 0) {
            component.set('v.currentDBShow', currentDBShowList[0]);
        }
    },

    changeShowType : function(component, event, helper) {
        var selectShowType = event.target.id;
        component.set('v.showType', selectShowType);
        var selectMonth = component.get('v.showMonth');
        var selectYear = component.get('v.showYear');
        var showDBList = component.get('v.showDBList');
        var currentDBShowList = [];
        for(var item in showDBList){
            if (showDBList[item].showType === selectShowType && 
                showDBList[item].showYear == selectYear 
                && showDBList[item].showMonth == selectMonth) {
                currentDBShowList.push(showDBList[item]);
            }
        }
        if (currentDBShowList.length > 0) {
            component.set('v.currentDBShow', currentDBShowList[0]);
        }
    },

    changeHisShowType : function(component, event, helper) {
        var selectHisShowType = event.target.id;
        component.set('v.hisShowType', selectHisShowType);
        var selectBrandValue = component.get('v.showBrand');
        var brandOptions = component.get('v.brandOptions');
        var selectBrandLabel;
        for (var i in brandOptions) {
            if (brandOptions[i].value === selectBrandValue) {
                selectBrandLabel = brandOptions[i].label;
                break;
            }
        }
        var hisShowDBList = component.get('v.hisShowDBList');
        var currentDBHisShow = [];
        var showTables = [];
        var tovList = [];
        var intakeList = [];
        var inventoryList = [];
        var myDate = new Date();
        var showMonths = hisShowDBList.length > 0 ? hisShowDBList[0].months : [myDate.getMonth()+1+'月'];
        for (var key in showMonths) {
            showTables.push({'Month': showMonths[key], 'TovNumber' : 0, 'IntakeNumber' : 0, 'InventoryNumber' : 0});
        }
        for(var item in hisShowDBList){
            if (hisShowDBList[item].historyShowType === selectHisShowType ) {
                var showDB = hisShowDBList[item];
                if (selectBrandValue === 'All') {
                    currentDBHisShow.push(showDB);
                }else if (selectBrandValue === hisShowDBList[item].brandValue) {
                    showDB['brandValue'] = selectBrandValue;
                    showDB['brandLabel'] = selectBrandLabel;
                    currentDBHisShow.push(showDB);
                }
            }
        }
        if (currentDBHisShow.length > 0) {
            for (var item1 in currentDBHisShow) {
                var tovHis = (Number(currentDBHisShow[item1].tovHis) % 1==0) ? (Number(currentDBHisShow[item1].tovHis)/1) : (Math.floor(currentDBHisShow[item1].tovHis*100)/100);
                var intakeHis = (Number(currentDBHisShow[item1].intakeHis) % 1==0) ? (Number(currentDBHisShow[item1].intakeHis)/1) : (Math.floor(currentDBHisShow[item1].intakeHis*100)/100);
                var inventoryHis = (Number(currentDBHisShow[item1].inventoryHis) % 1==0) ? (Number(currentDBHisShow[item1].inventoryHis)/1) : (Math.floor(currentDBHisShow[item1].inventoryHis*100)/100);
                for (var item2 in showTables) {
                    if (showTables[item2].Month === (currentDBHisShow[item1].showMonth + '月')) {
                        showTables[item2].TovNumber = showTables[item2].TovNumber + tovHis;
                        showTables[item2].IntakeNumber = showTables[item2].IntakeNumber + intakeHis;
                        showTables[item2].InventoryNumber = showTables[item2].InventoryNumber + inventoryHis;
                    }
                }
            }
        }
        for (var key1 in showTables) {
            showTables[key1].TovNumber = (Number(showTables[key1].TovNumber) % 1==0) ? (Number(showTables[key1].TovNumber)/1) : (Math.floor(showTables[key1].TovNumber*100)/100);
            showTables[key1].IntakeNumber = (Number(showTables[key1].IntakeNumber) % 1==0) ? (Number(showTables[key1].IntakeNumber)/1) : (Math.floor(showTables[key1].IntakeNumber*100)/100);
            showTables[key1].InventoryNumber = (Number(showTables[key1].InventoryNumber) % 1==0) ? (Number(showTables[key1].InventoryNumber)/1) : (Math.floor(showTables[key1].InventoryNumber*100)/100);
            tovList.push(showTables[key1].TovNumber);
            intakeList.push(showTables[key1].IntakeNumber);
            inventoryList.push(showTables[key1].InventoryNumber);
        }
        component.set('v.showTables', showTables);
        helper.loadChart(component,showMonths,tovList,intakeList,inventoryList,true);
    },


    changeBrand : function(component, event, helper) {
        var selectBrandValue = component.find('selectBrand').get('v.value');
        component.set('v.showBrand', selectBrandValue);
        var brandOptions = component.get('v.brandOptions');
        var selectBrandLabel;
        for (var i in brandOptions) {
            if (brandOptions[i].value === selectBrandValue) {
                selectBrandLabel = brandOptions[i].label;
                break;
            }
        }
        var selectHisShowType = component.get('v.hisShowType');
        var hisShowDBList = component.get('v.hisShowDBList');
        var currentDBHisShow = [];
        var showTables = [];
        var tovList = [];
        var intakeList = [];
        var inventoryList = [];
        var myDate = new Date();
        var showMonths = hisShowDBList.length > 0 ? hisShowDBList[0].months : [myDate.getMonth()+1+'月'];
        for (var key in showMonths) {
            showTables.push({'Month': showMonths[key], 'TovNumber' : 0, 'IntakeNumber' : 0, 'InventoryNumber' : 0});
        }
        for(var item in hisShowDBList){
            if (hisShowDBList[item].historyShowType === selectHisShowType){
                var showDB = hisShowDBList[item];
                if (selectBrandValue === 'All') {
                    currentDBHisShow.push(showDB);
                }else if (selectBrandValue === hisShowDBList[item].brandValue) {
                    showDB['brandValue'] = selectBrandValue;
                    showDB['brandLabel'] = selectBrandLabel;
                    currentDBHisShow.push(showDB);
                }
                
            }
        }

        if (currentDBHisShow.length > 0) {
            for (var item1 in currentDBHisShow) {
                var tovHis = (Number(currentDBHisShow[item1].tovHis) % 1==0) ? (Number(currentDBHisShow[item1].tovHis)/1) : (Math.floor(currentDBHisShow[item1].tovHis*100)/100);
                var intakeHis = (Number(currentDBHisShow[item1].intakeHis) % 1==0) ? (Number(currentDBHisShow[item1].intakeHis)/1) : (Math.floor(currentDBHisShow[item1].intakeHis*100)/100);
                var inventoryHis = (Number(currentDBHisShow[item1].inventoryHis) % 1==0) ? (Number(currentDBHisShow[item1].inventoryHis)/1) : (Math.floor(currentDBHisShow[item1].inventoryHis*100)/100);
                for (var item2 in showTables) {
                     if (showTables[item2].Month === (currentDBHisShow[item1].showMonth + '月')) {
                        showTables[item2].TovNumber = showTables[item2].TovNumber + tovHis;
                        showTables[item2].IntakeNumber = showTables[item2].IntakeNumber + intakeHis;
                        showTables[item2].InventoryNumber = showTables[item2].InventoryNumber + inventoryHis;
                    }
                }
            }
        }
        for (var key1 in showTables) {
            showTables[key1].TovNumber = (Number(showTables[key1].TovNumber) % 1==0) ? (Number(showTables[key1].TovNumber)/1) : (Math.floor(showTables[key1].TovNumber*100)/100);
            showTables[key1].IntakeNumber = (Number(showTables[key1].IntakeNumber) % 1==0) ? (Number(showTables[key1].IntakeNumber)/1) : (Math.floor(showTables[key1].IntakeNumber*100)/100);
            showTables[key1].InventoryNumber = (Number(showTables[key1].InventoryNumber) % 1==0) ? (Number(showTables[key1].InventoryNumber)/1) : (Math.floor(showTables[key1].InventoryNumber*100)/100);
            tovList.push(showTables[key1].TovNumber);
            intakeList.push(showTables[key1].IntakeNumber);
            inventoryList.push(showTables[key1].InventoryNumber);
        }
        component.set('v.showTables', showTables);
        helper.loadChart(component,showMonths,tovList,intakeList,inventoryList,true);
    },

    openModel : function(component, event, helper) {
        component.set('v.isPopup', true);
    },

    closeModel : function(component, event, helper) {
        component.set('v.isPopup', false);
    },

    openOrders: function(component, event, helper) {
        var openType = event.currentTarget.id;
        if (openType === 'pendingPayment') {
            window.open(window.location.href+'my-orders?selectedTabId=heldTOVs','_blank');
        } else if (openType === 'openReturn') {
            window.open(window.location.href+'my-orders?selectedTabId=refundTOVs','_blank');
        } else {
            window.open(window.location.href+'my-orders','_blank');
        }
        
    }

})