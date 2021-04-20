public with sharing class LAT_ProductRestriction {
	
	public List<LAT_Product__c> 	productos 		{get; set;}
	public LAT_Product__c 			producto 		{get; set;}
	private Map<Id, LAT_Product__c> mapProductos	{get; set;}
	public Boolean 					showForm 		{get; set;}
	public String 					idProducto 		{get; set;}
	public Boolean 					displayPopUp	{get; set;}
	public Boolean 					displayLimpiar	{get; set;}
	public String 					errorMessage	{get; set;}
	public String 					strBuscar		{get; set;}

	public LAT_ProductRestriction() {
		init();
		System.debug('%%%% en contructor : ' + productos);
	}

	private void init() {
		mapProductos = new Map<Id, LAT_Product__c>([SELECT Id, Name, LAT_Sku__c, LAT_RestrictionDescription__c, LAT_RestrictionInit__c, LAT_RestrictionEnd__c 
					FROM LAT_Product__c WHERE LAT_ExternalId__c LIKE '12-%' AND LAT_IsActive__c = true  ORDER BY LAT_RestrictionDescription__c NULLS LAST, Name]);
		productos = mapProductos.values();
		showForm = false;
		displayPopUp = false;
		errorMessage = null;
		strBuscar 	 = '333';
		displayLimpiar = false;

	}

	public PageReference restringirProducto() {
		
		if (producto.LAT_RestrictionInit__c != null) {
			if (producto.LAT_RestrictionEnd__c != null) {
				if (producto.LAT_RestrictionDescription__c != null) {
					if (producto.LAT_RestrictionInit__c <= producto.LAT_RestrictionEnd__c) {
						if (producto.LAT_RestrictionInit__c <= producto.LAT_RestrictionEnd__c) {
							update producto;
						} else {
							errorMessage = 'No se pueden restringir Productos en el pasado.';
							ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, errorMessage));
							return null;							
						}
					} else {
						errorMessage = 'La fecha de Fin debe ser igual o posterior a la fecha de inicio.';
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, errorMessage));
						return null;
					}
					
				} else {
					errorMessage = 'Debe ingresar una Descripción de la Restricción.';
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, errorMessage));
					return null;
				}
			} else {
				errorMessage = 'Debe Seleccionar Fecha de Fin de la Restricción.';
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, errorMessage));
				return null;
			}	

		} else {
			errorMessage = 'Debe Seleccionar Fecha de Inicio de la Restricción.';
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, errorMessage));
			return null;
		}
		showForm = false;
		idProducto = null;
		errorMessage = null;
		return null;
	}	
	
	public PageReference seleccionarProducto() {
		System.debug('%%%% idProducto eb seleccionarProducto: ' + idProducto);
		producto = mapProductos.get(idProducto);
		showForm = true;
		return null;
	}

	public PageReference quitarRestriccion() {
		System.debug('%%%% idProducto en quitarRestriccion : ' + idProducto);
		LAT_Product__c p = mapProductos.get(idProducto);
		p.LAT_RestrictionDescription__c = null;
		p.LAT_RestrictionEnd__c 		= null;
		p.LAT_RestrictionInit__c		= null;
		update p;
		return null;
	}

	public PageReference cancelar() {
		System.debug('%%%% en cancelar ');
		showForm = false;
		idProducto = null;
		errorMessage = null;
		return null;
	}

	public PageReference mostrarPopUp() {
		System.debug('%%%% en mostrarPopUp ');
		displayPopUp = true;
		//popUpMessage = producto.LAT_RestrictionDescription__c;
		return null;
	}

	public PageReference ocultarPopUp() {
		System.debug('%%%% en ocultarPopUp ');
		displayPopUp = false;
		return null;
	}

	public PageReference limpiar() {
		System.debug('%%%% en limpiar');
		productos = mapProductos.values();
		return null;
	}

	public PageReference buscar() {
		String passedParam1 = Apexpages.currentPage().getParameters().get('input1');
		if (passedParam1 == null || passedParam1 == '') {
			return limpiar();
		}
        system.debug('==Entered the Controller: '+ passedParam1);
		String txtBusqueda = '%' + passedParam1+'%';
		System.debug('%%%% en buscar txtBusqueda : '+txtBusqueda);
		List<LAT_Product__c> listaFiltrada = new List<LAT_Product__c>();
		for (LAT_Product__c p : mapProductos.values()) {
			if (String.valueOf(p.Name).containsIgnoreCase(passedParam1) || String.valueOf(p.LAT_Sku__c).containsIgnoreCase(passedParam1) ) {
				listaFiltrada.add(p);
			}
		}
		System.debug('%%%%%% listaFiltrada.size() : '+listaFiltrada.size());
		productos = listaFiltrada;

		return null;
	}

}