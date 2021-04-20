public with sharing class LAT_BR_VFC29_SellOutCollectFilling {

	private static final Map<Integer, String> monthList = LAT_BR_SellOutTaskCreator.getMonthMap();

	public LAT_SellOutCollect__c coleta	{get; set;}
	public List<LAT_SellOutCollectLine__c> coletaLista {get; set;}
	public List<SellOutlinesWrapper> wrapperList {get; set;}
	public String Month {get; set;}
	public String displayMonth {get; set;}
	public String Year {get; set;}
	public String refAccountName {get; set;}

	public String currentYear {get; set;}
	public String currentMonth {get; set;}

	public Boolean enableEditing {get; set;}
	public Boolean allowWebEdit {get; set;}
	private String sellOutRecordTypeId = Global_RecordTypeCache.getRtId('LAT_SellOutCollect__c'+'LAT_SellOut');

	public LAT_BR_VFC29_SellOutCollectFilling() {
		this.currentYear = String.valueOf(Date.today().year());
		this.currentMonth = String.valueOf(Date.today().month());
		this.wrapperList = new List<SellOutlinesWrapper>();
		enableEditing = false;
		allowWebEdit = true;


		if(Utils.isPartOfMobileCRM(UserInfo.getUserId())){
			allowWebEdit = false;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, label.LAT_VFP30_Mobile_Permissions_Sellout);
            ApexPages.addMessage(myMsg);
        }
	}

	public void doInit() {
		String colId = system.currentPageReference().getParameters().get('colId');
		String action = system.currentPageReference().getParameters().get('action');

		this.coleta = new LAT_SellOutCollect__c();
		this.coletaLista = new List<LAT_SellOutCollectLine__c>();
		
		this.Month = this.currentMonth;
		this.Year = this.currentYear;
		
		if (action == 'New') {
			this.enableEditing = true;

			String monthParam = system.currentPageReference().getParameters().get('month');
			String yearParam = system.currentPageReference().getParameters().get('year');
			String refAccountParam = system.currentPageReference().getParameters().get('refAId');
			
			this.Month = monthParam;
			this.Year = yearParam;

			if (this.Month != null && this.Year != null && refAccountParam != null) {
				this.coleta = getFillingColetaByMonth(Integer.valueOf(this.Month), Integer.valueOf(this.Year),refAccountParam);
				if (this.coleta.id == null) {
					this.coleta.ReferenceAccount__c = refAccountParam;
					this.coleta.Status__c = 'Filling';
					this.coleta.ReferencedMonth__c = Date.newInstance(Integer.valueOf(this.Year),Integer.valueOf(this.Month), 1);
					//insert this.coleta;
					this.refAccountName = getRefAccountName(refAccountParam);
					
					/*List<LAT_ReferenceProduct__c> rProductList = [SELECT id, Name, ExternalId__c, KeyBrandRef__c,
																		 RefKey__c, SchCRef__c, SKURef__c,
																		 Type__c
																    FROM LAT_ReferenceProduct__c
																    WHERE IsActive__c = true];*/
					Map<id, LAT_ReferenceProductGrouping__c> groupingMap = new Map<id, LAT_ReferenceProductGrouping__c>([SELECT id, Name FROM LAT_ReferenceProductGrouping__c 
																																WHERE	recordType.developerName = 'LAT_SellOut' ]);
					List<AggregateResult> rProductList = [SELECT ReferenceGrouping__c
																 FROM LAT_ReferenceProduct__c
																 WHERE IsActive__c = true 
																 		AND ReferenceGrouping__r.recordType.developerName = 'LAT_SellOut' 
																 				GROUP BY ReferenceGrouping__c];

					for (AggregateResult rp: rProductList) {
						String groupingId = String.valueOf(rp.get('ReferenceGrouping__c'));

						if (groupingId != null) {
							LAT_SellOutCollectLine__c scl = new LAT_SellOutCollectLine__c();
							scl.SellOut__c = 0;
							scl.Stock__c = 0;
							scl.ReferenceProductGrouping__c = groupingId;
							//scl.SellOutCollect__c = this.coleta.id;						
							this.coletaLista.add(scl);
							this.wrapperList.add(new SellOutlinesWrapper(scl, groupingMap.get(groupingId).Name));
						}
					}
					//insert this.coletaLista;
				}
				//this.coleta = this.getFillingColeta(this.coleta.id);
				//this.coletaLista = getColetaListFromColeta(this.coleta.id);
			}

		} else if (colId != null){

			this.coleta = this.getFillingColeta(colId);
			this.coletaLista = getColetaListFromColeta(colId);

			for (LAT_SellOutCollectLine__c socl: this.coletaLista) {
				this.wrapperList.add(new SellOutlinesWrapper(socl, socl.ReferenceProductGrouping__r.Name));
			}
			
			if (this.coletaLista == null || this.coletaLista.isEmpty()) { 
				this.coletaLista = new List<LAT_SellOutCollectLine__c>();
			}

			if (this.coleta != null && this.coleta.ReferencedMonth__c != null){
				this.Month = String.valueOf(this.coleta.ReferencedMonth__c.month());
				this.Year = String.valueOf(this.coleta.ReferencedMonth__c.year());
				this.refAccountName = getRefAccountName(this.coleta.ReferenceAccount__c);
				if (this.coleta.Status__c == 'Filling' || this.coleta.Status__c == 'Preenchimento') {
					this.enableEditing = true;
				}
			}
		}

		this.displayMonth = monthList.get(Integer.valueOf(this.Month));
	}

	public LAT_SellOutCollect__c getFillingColeta(String colId) {
		List<LAT_SellOutCollect__c> colList = [SELECT id, ReferenceAccount__r.AccountName__c, ReferenceAccount__c, CollectDate__c,
											Unit__c, toLabel(Status__c), ReferencedMonth__c, OwnerId FROM LAT_SellOutCollect__c
											WHERE id=: colId]; //AND Status__c = 'Filling'];		
		
		LAT_SellOutCollect__c result = !colList.isEmpty() ? colList.get(0) : new LAT_SellOutCollect__c();

		return result;
	}

	public LAT_SellOutCollect__c getFillingColetaByMonth(Integer Month, Integer Year, String refID) {
		Date fitlerDate = Date.newInstance(Year, Month, 1);

		List<LAT_SellOutCollect__c> colList = [SELECT id, ReferenceAccount__r.AccountName__c, ReferenceAccount__c, CollectDate__c,
											Unit__c, toLabel(Status__c), ReferencedMonth__c, OwnerId FROM LAT_SellOutCollect__c
											WHERE ReferencedMonth__c =: fitlerDate AND Status__c = 'Filling' AND ReferenceAccount__c =: refID];		
		
		LAT_SellOutCollect__c result = !colList.isEmpty() ? colList.get(0) : new LAT_SellOutCollect__c();

		return result;
	}

	public List<LAT_SellOutCollectLine__c> getColetaListFromColeta(String colId) {
		return [SELECT id, ReferenceProductGrouping__r.Name , SellOut__c, 
						Stock__c FROM LAT_SellOutCollectLine__c 
						WHERE SellOutCollect__c =: colId];
							  //AND SellOutCollect__r.Status__c = 'Filling'];
	}

	public String getRefAccountName(String raId) {
		List<LAT_ReferenceAccount__c> raList = [SELECT Name FROM LAT_ReferenceAccount__c WHERE id =: raId];
		if (!raList.isEmpty()) {
			return raList.get(0).Name;
		} else {
			return '';
		}
	}

	public void doSave() {
		if (this.coleta.CollectDate__c != null 
			&& this.coleta.Unit__c != null) {
			this.coleta.OwnerId = userinfo.getUserId();
			this.coleta.RecordTypeId = sellOutRecordTypeId;

			upsert this.coleta;
			this.coletaLista.clear();
			for (SellOutlinesWrapper wrapper: this.wrapperList) {
				if (wrapper.socl.id == null) {
					wrapper.socl.SellOutCollect__c = this.coleta.id;
				}		
				this.coletaLista.add(wrapper.socl);	
			}
			upsert this.coletaLista;
		} else {
			ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.severity.ERROR, 'Favor informar o Data Coleta e Unidade para salvar.'); 
            ApexPages.addMessage(errorMsg);
		}
	}

	public PageReference doFinalize() {
		if (this.coleta.CollectDate__c != null 
			&& this.coleta.Unit__c != null) {
			doSave();
			
			this.coleta.OwnerId = userinfo.getUserId();
			this.coleta.Status__c = 'Finalized';

			upsert this.coleta;
			this.coletaLista.clear();
			for (SellOutlinesWrapper wrapper: this.wrapperList) {
				if (wrapper.socl.id == null) {
					wrapper.socl.SellOutCollect__c = this.coleta.id;
				}		
				this.coletaLista.add(wrapper.socl);	
			}
			upsert this.coletaLista;
			
			return new PageReference('/apex/LAT_BR_VFP28_SellOutCollect');
		} else {
			ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.severity.ERROR, 'Favor informar o Data Coleta e Unidade para salvar.'); 
            ApexPages.addMessage(errorMsg);
            return null;
		}
	}

	 //Inner class for Sales Prevission section
    public class SellOutlinesWrapper {
        public LAT_SellOutCollectLine__c socl {get; set;}
        public string ProductName             {get;Set;}
        
        public SellOutlinesWrapper (LAT_SellOutCollectLine__c socl, String productName){
            this.socl = socl;
            this.productName = ProductName;
        }
    }
}