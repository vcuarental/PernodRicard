/*
 * This class monitors the last time some tables were filled by ETL
 *
 * Author: Diego Salido
 */
public with sharing class LAT_ADM_MonitorETL {

	// ---- Auxiliary classes
	public enum WarningLevel {OK, WARNING, CRITICAL, NOTAPPLY}

	public class LoadInfo {
		private Date lastDate;
		private WarningLevel status;

		public LoadInfo(Date d, WarningLevel w) {
			lastDate = d;
			status = w;
		}

		public Date getLastDate() { return lastDate; }
		public WarningLevel getStatus() { return status; }
	}

	// ---- Attributes

	private Map<String, LoadInfo> lastUpdates = new Map<String, LoadInfo>();

	private Map<String, Integer[]> warningLimits = new Map<String, Integer[]>();


	// ---- Constants

	// Constants for map keys generation
	public final String ACC_PROD_PAY = 'LAT_Account_product_payment__c'; 
	public final String PRODUCTS = 'Product2';
	public final String UDC = 'UDC__c';
	public final String TITULOS = 'Titulos__c';
	
	public final String[] ALL_KEYS = new List<String> {ACC_PROD_PAY, PRODUCTS, UDC, TITULOS};


	// ---- Public Methods 

	public LAT_ADM_MonitorETL() {
		defineWaringLevels();	
	}

	// returns a key used to store in @lastUpdates by country and table name
	public String getKey(String ctry, String table) {
		return ctry + '-' + table;
	}

	public Map<String, LoadInfo> doMonitor() {
		monitorTitulos();
		monitorAccountProductPayment();
		monitorProducts();
		monitorUDC();

		return lastUpdates;
	}

	/* 
	 * In this method are defined all objects thresholds (warning first, critical last)
	 * This method could be easily replaed to read this data from configuration 
	 */
	private void defineWaringLevels() {
		warningLimits.put(ACC_PROD_PAY, new List<Integer> {1, 3});
		warningLimits.put(PRODUCTS, new List<Integer> {1, 4});
		warningLimits.put(UDC, new List<Integer> {1, 4});
		warningLimits.put(TITULOS, new List<Integer> {2, 5});
	}


	// ---- Private Methods

	/* This method performs the monitoring over Titulos__C */
	private void monitorTitulos() {

		// Map recort type develper names to country ID
		Map<String, String> mapRT = new Map<String,String>{
			'BRA_Standard' => '1',
			'Standard_UY' => '5', 
			'Standard_AR' => '6',
			'LAT_MX_TEA_Standard' => '12' 
		};

		// Query the last time a record was created by country
		AggregateResult[] datelist = [SELECT recordtype.developername, max(createddate) lastload from titulos__c group by recordtype.developername];
		
		analyzeObject(TITULOS, mapRT, datelist);
	}

	private void monitorAccountProductPayment() {
		Map<String, String> mapRT = new Map<String,String>{
			'BRA_Standard' => '1',
			'Standard_UY' => '5', 
			'Standard_AR' => '6',
			'LAT_MX_PRD_Standard' => '12' 
		};

		AggregateResult[] datelist = [SELECT product__r.recordtype.developername, max(lastmodifieddate) lastload from LAT_Account_product_payment__c where account__c in ('001D0000019yuNIIAY', '001D0000019yq35IAA', '001D0000015iABRIA2') or product__r.recordtypeid = '012D00000007LFqIAM' group by product__r.recordtype.developername];

		analyzeObject(ACC_PROD_PAY, mapRT, datelist);
	}

	private void monitorProducts() {
		Map<String, String> mapRT = new Map<String,String>{
			'BRA_Standard' => '1',
			'Standard_UY' => '5', 
			'Standard_AR' => '6',
			'LAT_MX_PRD_Standard' => '12' 
		};

		AggregateResult[] datelist = [SELECT recordtype.developername, max(lastmodifieddate) lastload from Product2 where lat_isrefactorproduct__c = 'Y' group by recordtype.developername];

		analyzeObject(PRODUCTS, mapRT, datelist);
	}

	private void monitorUDC() {
		Map<String, String> mapRT = new Map<String,String>{
			'BRA_Standard' => '1',
			'Standard_UY' => '5', 
			'Standard_AR' => '6',
			'LAT_MX_UDC_Standard' => '12' 
		};

		AggregateResult[] datelist = [SELECT recordtype.developername, max(lastmodifieddate) lastload from UDC__c group by recordtype.developername];

		analyzeObject(UDC, mapRT, datelist);
	}

	private void analyzeObject(String objectName, Map<String, String> mapRT, AggregateResult[] datelist) {

		// Query the last time a record was created by country
		for(AggregateResult row : datelist) {
			String rowRT = String.valueOf(row.get('developername'));
			if (mapRT.containsKey(rowRT)) {
				String ctry = mapRT.get( rowRT );
				Date lastLoad = Date.Valueof(row.get('lastload'));

				// Definded Warning Level for this table
				WarningLevel level = getWarningLevel(objectName, lastLoad);

				// Include this information
				lastUpdates.put(getKey(ctry, objectName), new LoadInfo(lastLoad, level));
			} else {
				System.debug('LAT_ADM_MonitorETL::monitorObject: No recordtype map found for object: ' + objectName + ', RT: ' + rowRT);
			}
		}

		// Looks for countries without data. This is critical!
		for (String ctry : mapRT.values()) {
			String key = getKey(ctry, objectName);
			if (!lastUpdates.containsKey(key)) {
				lastUpdates.put(key, new LoadInfo(null, WarningLevel.CRITICAL));
			}
		}
	}


	/* 
	 * Transforms Days to WarningLevel
	 * Criteria (daysCount = today - lastDate):
	 *     (daysCount < @warning) => OK, 
	 *     (@warning <= daysCount < @critical) => WARNING, 
	 *     (daysCount >= @critical) => CRITICAL 
	 */
	private WarningLevel getWarningLevel(String objectName, Date lastDate) {
		WarningLevel level = WarningLevel.CRITICAL;
		Integer[] limits = warningLimits.get(objectName);

		if (lastDate != null && limits != null && limits.size() == 2) {
			Integer daysCount = lastDate.daysBetween(Date.today());
			if (daysCount < limits[0]) {
				level = WarningLevel.OK;
			} else if (daysCount < limits[1]) {
				level = WarningLevel.WARNING;
			}
		}

		if (limits == null || limits.size() != 2) {
			System.debug('No threshold defined for object: ' + objectName);
		}
		return level;
	}



}