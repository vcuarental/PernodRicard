({
	getCurrentMinimunPrice : function(component) {
        console.log('en getCurrentMinimunPrice');
		var action = component.get("c.getMinimunPrice");
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS") {
                var price = a.getReturnValue();
                console.log('price:');
                console.log(JSON.stringify(price));
                component.set('v.minimunPrice', price);
            }
        });
        $A.enqueueAction(action);
	},
    actualizarPrecio: function(component) {
        console.log('en actualizarPRecio');
		var action = component.get("c.updateMinimunPrice");
        action.setParams({ "newValue": component.get("v.newMinimunPrice") });
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS") {
                console.log('retorno :' + a.getReturnValue());
                component.set("v.minimunPrice",component.get("v.newMinimunPrice"));
                component.set("v.newMinimunPrice",0);
            }
        });
        $A.enqueueAction(action);
    },
    refrescarPrecios: function(component) {
        var objThat = this;
        console.log('en actualizarPRecio');
        var action = component.get("c.refreshAllPrices");
        
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS") {
                objThat.showToast(component, 'info', 'Se esta ejecutando el recalculo de precios.');
            } else {
                objThat.showToast(component, 'error', 'Ha ocurrido un error al ejecutar el recalculo de precios.');
            }
        });
        $A.enqueueAction(action);
	},
    getChartIsBlocked: function(component) {
        console.log('en getChartBlocked');
		var action = component.get("c.getChartBlocked");
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS") {
                component.set("v.chartIsBlocked", a.getReturnValue());
            }
        });
        $A.enqueueAction(action);
	},
    getComments: function(component) {
        console.log('en getComments');
		var action = component.get("c.getBlockingComments");
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS") {
                component.set("v.comments", a.getReturnValue());
            }
        });
        $A.enqueueAction(action);
	},
    habilitar: function(component) {
        console.log('en hablitarCarrito');
		var action = component.get("c.hablitarCarrito");
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS") {
               component.set("v.chartIsBlocked", false);
            }
        });
        $A.enqueueAction(action);
	},
    bloquear: function(component) {
        console.log('en bloquearCarrito');
		var action = component.get("c.scheduleBlock");
        var comments = component.get("v.comments");
        var datFrom = component.get("v.datFrom");
        var datTo = component.get("v.datTo");
        var objResult = null;
        var objThat = this;
        var objFiredEvent = null;

        if(comments !== undefined && comments !== null && comments.length > 0 && datFrom !== undefined && datFrom !== null && datFrom.length > 0 && datTo !== undefined && datTo !== null && datTo.length > 0) {
            console.log('en comments:' + comments);
            if(datTo > datFrom) {
                action.setParams({ "datFrom" : datFrom, "datTo" : datTo, "strComments": comments  });
                action.setCallback(this, function(objResponse) {
                    var state = objResponse.getState();
                    if (state === "SUCCESS") {
                        objResult = objResponse.getReturnValue();
                        if(objResult.Code === 0) {
                            objFiredEvent = $A.get("e.c:LAT_CTY_B2B_Block_Refresh_Event");
                            objFiredEvent.fire();
                            objThat.showToast(component, 'success', objResult.Message);
                        } else {
                            objThat.showToast(component, 'error', objResult.Message);
                        }
                    } else  {
                        objThat.showToast(component, 'error', 'Ha ocurrido un error al realizar la operación.');
                    }
                });
                $A.enqueueAction(action);
            } else {
                this.showToast(component, 'error', 'Error', 'La fecha de inicio del bloqueo debe ser anterior a la fecha de fin.')
            }
        } else {
            this.showToast(component, 'error', 'Error', 'Debe ingresar todos los datos requeridos.')
        }
    },
    showToast : function(component, strType, strTitle, strMessage ) {
        component.find('notifLib').showNotice({
            "variant": strType,
            "header": strTitle,
            "message": strMessage,
            closeCallback: function() {
                //alert('You closed the alert!');
            }
        });
    },
    refreshPIM: function(component) {
        console.log('en refreshPIM');
		var action = component.get("c.actualizarPim");
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS") {
                console.log('volvimos con: ' + a.getReturnValue());
                component.set("v.pimReturn", a.getReturnValue());
            }
        });
        $A.enqueueAction(action);
	},
})