public with sharing class LAT_MX_VFC09_CatalogacionCheckList {
	public List<wrapList> Catalogaciones {get; set;}
	public List<String> headerList {get; set;} // bug on salesforce

	public Boolean VisitaCerrada {get; set;}

	public LAT_MX_VFC09_CatalogacionCheckList(ApexPages.StandardController stdCtr) {
		List<Visitas__c> visitaList = [SELECT id, Status__c FROM Visitas__c WHERE id =: stdCtr.getId()];

		if (!visitaList.isEmpty()) {
			this.visitaCerrada = false;
			if (visitaList.get(0).Status__c == 'Encerrada') {
				this.visitaCerrada = true;
			}
			List<LAT_MX_Catalogacion__c> catList = [SELECT id, LAT_MX_Categoria__c, LAT_MX_Check__c, 
																LAT_MX_Marca__c, LAT_MX_Visita__c
															FROM LAT_MX_Catalogacion__c 
															WHERE LAT_MX_Visita__c =: stdCtr.getId()];

			List<LAT_MX_Categories__c> categorias = [SELECT Name FROM LAT_MX_Categories__c];
			List<LAT_MX_Marcas__c> marcas = [SELECT Name FROM LAT_MX_Marcas__c ORDER BY Name];

			headerList = new List<String>();
			for (LAT_MX_Categories__c cats: categorias) {
				headerList.add(cats.Name);
			}

			Map<String, LAT_MX_Catalogacion__c> MapaCatalogacion = new Map<String, LAT_MX_Catalogacion__c>();
			for (LAT_MX_Catalogacion__c catalogacion: catList) {
				MapaCatalogacion.put(catalogacion.LAT_MX_Categoria__c + '-' + catalogacion.LAT_MX_Marca__c, catalogacion);
			}

			this.Catalogaciones = new List<wrapList>();
			for (LAT_MX_Marcas__c mar: marcas) {
				wrapList wraperList = new wrapList(mar.Name);
				for (LAT_MX_Categories__c cat: categorias) {
					if (MapaCatalogacion.get(cat.Name + '-' + mar.Name) == null) {
						LAT_MX_Catalogacion__c cata = new LAT_MX_Catalogacion__c(
																LAT_MX_Categoria__c = cat.Name, 
																LAT_MX_Marca__c = mar.Name,
																LAT_MX_Visita__c = stdCtr.getId());
						wraperList.wList.add(new wraper(cat.Name, false, cata));
					} else {
						wraperList.wList.add(new wraper(cat.Name, MapaCatalogacion.get(cat.Name + '-' + mar.Name).LAT_MX_Check__c, MapaCatalogacion.get(cat.Name + '-' + mar.Name)));
					}
				}
				this.Catalogaciones.add(wraperList);
			}
		} else {

		}
	}

	public pageReference save() {
		List<LAT_MX_Catalogacion__c> toUpsert = new List<LAT_MX_Catalogacion__c>();
		for (wrapList cata: this.Catalogaciones) {
			for (Wraper w: cata.wList) {
				if (w.Check && w.Catalogacion.id == null) {
					w.Catalogacion.LAT_MX_Check__c = w.Check;
					toUpsert.add(w.Catalogacion);
				} else if (w.Catalogacion.id != null){
					w.Catalogacion.LAT_MX_Check__c = w.Check;
					toUpsert.add(w.Catalogacion);
				}

			}
		}
		upsert toUpsert;
		return null;
	}

	public class wrapList {
		public String Marca {get; set;}
		public List<Wraper> wList {get; set;}

		public wrapList(String Marca) {
			this.Marca = Marca;
			wList = new List<Wraper>();
		}
	}	

	public class wraper {
		public LAT_MX_Catalogacion__c Catalogacion {get; set;}
		public String Categoria {get; set;}
		public Boolean Check {get; set;}

		public wraper (String Categoria, Boolean Check, LAT_MX_Catalogacion__c Catalogacion){
			this.Catalogacion = Catalogacion;
			this.Categoria = Categoria;
			this.Check = Check; 
		}
	}
}