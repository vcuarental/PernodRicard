public with sharing class LAT_VFC15_APActionKPIController {

	public List<rowWrapper> rows {get; set;}
	public List<LAT_ActionKPI__c> headers {get; set;}

	public LAT_VFC15_APActionKPIController() {
		this.rows = new List<rowWrapper>();
		Map<String,String> params = ApexPages.currentPage().getParameters();
		String paId = params.get('id');

		List<LAT_AccountInAction__c> aiaList = [SELECT id, LAT_Account__r.Name, (Select id, LAT_ActionKPI__c, LAT_ActionKPI__r.LAT_KPI__r.Name,
																										 LAT_AccountInAction__c, LAT_Done__c, LAT_Provided__c, LAT_RealGoal__c
																										 from LAT_ActionKPIClients__r)
																							FROM LAT_AccountInAction__c
																							WHERE LAT_PromotionalAction__c =: paId AND LAT_Execute__c = true];
		Map<id, LAT_ActionKPI__c> actionKPIMap = new Map<id, LAT_ActionKPI__c>([SELECT id, Name, LAT_KPI__r.Name FROM LAT_ActionKPI__c WHERE LAT_PromotionalAction__c =: paId ORDER BY LAT_KPI__r.Name]);
		this.headers = actionKPIMap.values();
		for (LAT_AccountInAction__c aiac: aiaList) {
			this.rows.add(new rowWrapper(aiac, aiac.LAT_ActionKPIClients__r));
		}
		/*for (LAT_AccountInAction__c aiac: aiaList) {
			if (aiac.LAT_ActionKPIClients__r.isEmpty()) {
				List<LAT_ClientActionKPI__c> clientKpis = new List<LAT_ClientActionKPI__c>();
				for (LAT_ActionKPI__c kpi: actionKPIMap.values()) {
					clientKpis.add(new LAT_ClientActionKPI__c(LAT_ActionKPI__c = kpi.id, LAT_AccountInAction__c = aiac.id));
				}
				this.rows.add(new rowWrapper(aiac, aiac.LAT_ActionKPIClients__r));
			} else if (actionKPIMap.values().size() == aiac.LAT_ActionKPIClients__r.size()) {
				this.rows.add(new rowWrapper(aiac, aiac.LAT_ActionKPIClients__r));
			} else if (actionKPIMap.values().size() > aiac.LAT_ActionKPIClients__r.size()){
				List<LAT_ClientActionKPI__c> clientKpis = new List<LAT_ClientActionKPI__c>();
				Set<String> addedKpis = new Set<String>();
				for (LAT_ClientActionKPI__c caKpi: aiac.LAT_ActionKPIClients__r) {
					clientKpis.add(caKPI);
					addedKpis.add(caKpi.LAT_ActionKPI__c);
				}

				for (LAT_ActionKPI__c kpi: actionKPIMap.values()) {
					if (!addedKpis.contains(kpi.id)) {
						clientKpis.add(new LAT_ClientActionKPI__c(LAT_ActionKPI__c = kpi.id, LAT_AccountInAction__c = aiac.id));
					}
				}
				this.rows.add(new rowWrapper(aiac, clientKpis));
			}
		}*/
	}

	public class rowWrapper {
		public LAT_AccountInAction__c aia {get; set;}
		public List<LAT_ClientActionKPI__c> clientKPIs {get; set;}

		public rowWrapper (LAT_AccountInAction__c aia, List<LAT_ClientActionKPI__c> clientKPIs){
			this.aia = aia;
			this.clientKPIs = clientKPIs;
		}
	}
}