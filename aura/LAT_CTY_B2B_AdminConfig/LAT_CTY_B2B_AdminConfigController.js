({
	doInit : function(component, event, helper) {
        helper.getChartIsBlocked(component);
        helper.getComments(component);
		helper.getCurrentMinimunPrice(component);
	},
    actualizarPrecio: function(component, event, helper) {
    	helper.actualizarPrecio(component);
    },
    refreshPrices: function(component, event, helper) {
    	helper.refrescarPrecios(component);
    },    
    bloquear: function(component, event, helper) {
    	helper.bloquear(component);
    },
    habilitar: function(component, event, helper) {
    	helper.habilitar(component);
    },
    refreshPIM: function(component, event, helper) {
    	helper.refreshPIM(component);
    },
    refreshRefreshStatus: function(component, event, helper) {
    	helper.getChartIsBlocked(component);
    }
})