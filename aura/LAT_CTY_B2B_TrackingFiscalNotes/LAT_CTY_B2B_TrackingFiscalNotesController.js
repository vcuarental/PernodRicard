({
    doInit: function (component, event, helper) {
        console.log('en init 1 : '+component.get('v.mostrarCuadroPago'));
       	component.set('v.mostrarCuadroPago',false);
        console.log('en init 2 : '+component.get('v.mostrarCuadroPago'));
        // Set the columns of the Table 
        component.set('v.columns', [
            {label: 'Nro Pedido', fieldName: 'oppName', type: 'url',
                  typeAttributes: {
                    label: { fieldName: 'linkLabelOpp' }
                  }
            },
            {label: 'Fecha Creación', fieldName: 'oppCloseDate', type: 'text'},
            {label: 'Estado Logística', fieldName: 'logiticStatus', type: 'text'},
            {label: 'Tracking', fieldName: 'linkCalyco', type: 'url',
                  typeAttributes: {
                    label: { fieldName: 'linkLabel' }
                  }
            },
            
        ]);
       
        console.log('en init 2 :'+ JSON.stringify(component.get('v.fiscalNotes')));
        helper.doFetchFacturas(component);
        
        console.log('en init 3');
        
    },
    hide : function(component,event,helper){
        component.set('v.mostrarCuadroPago',false);
    },
    show : function(component,event,helper){
        component.set('v.mostrarCuadroPago',true);
    }
})