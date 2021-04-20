global class LAT_CreateAPKPIBatch implements Database.Batchable<sObject> {

	String query;
	List<String> aiacIds;
	List<LAT_ActionKPI__c> kpis;

	global LAT_CreateAPKPIBatch(List<String> aiacIds, List<String> kpiIds) {
		this.aiacIds = aiacIds;

		this.kpis = [SELECT id FROM LAT_ActionKPI__c WHERE id IN: kpiIds];
		this.query = 'SELECT id FROM LAT_AccountInAction__c WHERE id IN: aiacIds';
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

  global void execute(Database.BatchableContext BC, List<LAT_AccountInAction__c> scope) {
		List<LAT_ClientActionKPI__c> toInsert = new List<LAT_ClientActionKPI__c>();
		for (LAT_AccountInAction__c aiac: scope){
			for (LAT_ActionKPI__c aKpi: this.kpis) {
				LAT_ClientActionKPI__c caKPI = new LAT_ClientActionKPI__c();
				caKPI.LAT_AccountInAction__c = aiac.id;
				caKPI.LAT_ActionKPI__c = aKpi.id;
				toInsert.add(caKPI);
			}
		}

		insert toInsert;
	}

	global void finish(Database.BatchableContext BC) {

	}

}