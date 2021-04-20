public with sharing class LAT_ContractHandlerJSON {
	public Boolean signedBusinessAgreement{get;set;} 
	public String distribuitorId{get;set;} 
	public String contractName{get;set;} 
	public String contrapartidas{get;set;} 
	public Decimal distributorTax {get; set;}
	public Decimal freightDistributor {get; set;}
	public Decimal totalTaxAP {get; set;}
	public Decimal totalShippingAP {get; set;}
	public String roiApMeta {get; set;}
	public String roiNetSalesMeta {get; set;}
	public String roiContratoMeta {get; set;}
	public Decimal estimatedNumberEvents {get; set;}
	public String sfdcId {get;set;} 
	public String owner {get;set;} 
	public String account {get;set;} 
	public String comments {get;set;} 
	public String endDate {get;set;} 
	public String exclusivity {get;set;} 
	public Double monthElapsed {get;set;} 
	public String processStatus {get;set;} 
	public Double roi {get;set;} 
	public Boolean standardClausesPRB {get;set;} 
	public String startDate {get;set;} 
	public String status {get;set;} 
	public String source {get;set;} 
	public String originalContractName {get;set;} 
	public String OriginalContractNumber {get;set;} 
	public String recordType {get;set;} 
	public String prbPortfolio {get;set;} 
	public String customerSignedBy {get;set;} 
	public String tradingConditionNegotiated {get;set;} 
	public String customerSignatory {get;set;} 
	public String vodkaClubCabinets {get;set;} 
	public String whiskyClubCabinets {get;set;} 
	public String djBooth {get;set;} 
	public String barsShelves {get;set;} 
	public String caapMarginText {get;set;} 
	public String cancelationReason {get;set;} 
	public String commentsNegativeRO {get;set;} 
	public Double gmdcTotal {get;set;} 
	public Boolean isAnOpenPlace {get;set;} 
	public String kpiFinancialReturn {get;set;} 
	public String kpiVisibility {get;set;} 
	public Double money {get;set;} 
	public String nonApprovalReason {get;set;} 
	public String startOfPartnership {get;set;} 
	public Double suggestedMaximumInvesment {get;set;} 
	public Double totalBonus {get;set;} 
	public Double totalCostBonus {get;set;}
	public Double value {get;set;}
	public Double totalMoneyPRBCost {get;set;}
	public Double totalMoneyPerceivedValue {get;set;} 
	public Double totalProductsPerceivedValue {get;set;} 
	public Double totalVodkaMonth {get;set;} 
	public Double roiTarget {get;set;} 
	public Double totalWhiskyMonth {get;set;} 
	public Double totalOthersMonth {get;set;} 
	public Double digital {get;set;} 
	public Double revenue {get;set;} 
	public Boolean annex1 {get;set;} 
	public Boolean annex2 {get;set;} 
	public Boolean withoutVolumeInformation {get;set;} 
	public Boolean ConsultantToTestify {get;set;} 
	public String CancelDate {get;set;} 
	public String CancelComments {get;set;} 
	public String uf {get;set;} 
	public String perfil {get;set;} 
	public String marcasActivadas {get;set;}
	public String comunicacaoes {get;set;}
	public String ativacoes {get;set;} 
	public String frequency {get;set;} 
	public String AditionComment {get;set;} 

	public String ROIPrevistoOnInvoice {get;set;} 
	public Decimal TotalContractOnInvoice {get; set;}
	public Decimal onInvoice {get; set;}
	
	public ListVolume listVolume {get;set;} 
	public ListPayment listPayment {get;set;} 
	public ListClientContract listClientContract {get;set;} 
	public ListProviders listProviders {get;set;} 
	public ListPromotionAgreement listPromotionAgreement {get;set;} 
	public ListContractDetail listContractDetail {get;set;} 
	public ListVisibilityCounterPart listVisibilityCounterPart {get;set;} 
	public ListContractEvent listContractEvent {get;set;}

	public LAT_Contract2__c toContract() {
		LAT_Contract2__c objContract = null;

		System.debug('toContract[] ->');

		objContract = new LAT_Contract2__c();

        if (String.IsNotBlank(this.account)) objContract.Account__c = this.account;
        if (String.IsNotBlank(this.contractName)) objContract.Name = this.contractName;
        if (String.IsNotBlank(this.endDate)) objContract.EndDate__c = Date.valueOf(this.endDate);
        if (String.IsNotBlank(this.startOfPartnership)) objContract.StartOfPartnership__c = Date.valueOf(this.startOfPartnership);
        if (String.IsNotBlank(this.startDate)) objContract.StartDate__c = Date.valueOf(this.startDate);
        if (String.IsNotBlank(this.customerSignedBy)) objContract.CustomerSignedBy__c = this.customerSignedBy;
        if (String.IsNotBlank(this.customerSignatory)) objContract.CustomerSignatory__c = this.customerSignatory;
        if (String.IsNotBlank(this.vodkaClubCabinets)) objContract.VodkaClubCabinets__c = Decimal.valueOf(this.vodkaClubCabinets);
        if (String.IsNotBlank(this.djBooth)) objContract.DJBooth__c = Decimal.valueOf(this.djBooth);
        if (String.IsNotBlank(this.whiskyClubCabinets)) objContract.WhiskyClubCabinets__c = Decimal.valueOf(this.whiskyClubCabinets);
        if (String.IsNotBlank(this.barsShelves)) objContract.BarsShelves__c = Decimal.valueOf(this.barsShelves);
        if (String.IsNotBlank(this.OriginalContractNumber)) objContract.OriginalContractNumber__c  = this.OriginalContractNumber;
        if (String.IsNotBlank(this.distribuitorId)) objContract.LAT_Distributor__c = this.distribuitorId;
        if (String.IsNotBlank(this.contrapartidas)) objContract.LAT_Contrapartidas__c = this.contrapartidas;
        if (String.IsNotBlank(this.CancelDate)) objContract.CancelDate__c = Date.valueOf(this.CancelDate);
        if (this.uf != null) objContract.LAT_Uf__c = this.uf;
        if (this.perfil != null) objContract.LAT_Perfil__c = this.perfil;
        if (this.AditionComment != null) objContract.LAT_AditionComment__c = this.AditionComment;

		if (this.gmdcTotal != null) objContract.GMDC_Total__c = this.gmdcTotal;
        if (this.isAnOpenPlace != null) objContract.IsAnOpenPlace__c = this.isAnOpenPlace;
        if (this.kpiFinancialReturn != null) objContract.KPIFinancialReturn__c = this.kpiFinancialReturn;
        if (this.money != null) objContract.Money__c = this.money;
        if (this.roi != null) objContract.ROI__c = this.roi;
        if (this.standardClausesPRB != null) objContract.StandardClausesPRB__c = this.standardClausesPRB;
        if (this.suggestedMaximumInvesment != null) objContract.SuggestedMaximumInvesment__c = this.suggestedMaximumInvesment;
        if (this.totalBonus != null) objContract.TotalBonus__c = this.totalBonus;
        if (this.totalCostBonus != null) objContract.TotalCostBonus__c = this.totalCostBonus;
        if (this.value != null) objContract.Value__c = this.value;
        if (this.totalMoneyPRBCost != null) objContract.TotalMoneyPRBCost__c = this.totalMoneyPRBCost;
        if (this.totalMoneyPerceivedValue != null) objContract.TotalMoneyPerceivedValue__c = this.totalMoneyPerceivedValue;
        if (this.totalProductsPerceivedValue != null) objContract.TotalProductsPerceivedValue__c = this.totalProductsPerceivedValue;
        if (this.totalVodkaMonth != null) objContract.TotalVodkaMonth__c = this.totalVodkaMonth;
        if (this.totalWhiskyMonth != null) objContract.TotalWhiskyMonth__c = this.totalWhiskyMonth;
        if (this.totalOthersMonth != null) objContract.TotalOthersMonth__c = this.totalOthersMonth;
        if (this.annex1 != null) objContract.Annex11__c = this.annex1;
        if (this.annex2 != null) objContract.Annex12__c = this.annex2;
        if (this.withoutVolumeInformation != null) objContract.WithoutVolumeInformation__c = this.withoutVolumeInformation;
        if (this.roiTarget != null) objContract.ROI_Target__c = this.roiTarget;
        if (this.revenue != null) objContract.Revenue__c = this.revenue;
        if (this.ConsultantToTestify != null) objContract.Use_Consultant_to_Testify__c= this.ConsultantToTestify;
        if (this.digital != null) objContract.LAT_Digital__c = this.digital;
		
        objContract.LAT_SignedBusinessAgreement__c = (this.signedBusinessAgreement == null) ? false : this.signedBusinessAgreement;
        objContract.LAT_Ativacoes__c = this.ativacoes;
        objContract.LAT_MarcasAtivadas__c = this.marcasActivadas;
        objContract.LAT_Comunicacao__c = this.comunicacaoes;
        objContract.LAT_Frequency__c = this.frequency;
        objContract.RecordTypeId = this.recordType;
        objContract.CAAPMarginText__c = this.caapMarginText;
        objContract.CancelationReason__c = this.cancelationReason;
        objContract.Comments__c = this.comments;
        objContract.CommentsNegativeROI__c = this.commentsNegativeRO;
        objContract.Exlusivity__c = this.exclusivity;
        objContract.KPIVisibility__c = this.kpiVisibility;
        objContract.NonApprovalReason__c = this.nonApprovalReason;
        objContract.ProcessStatus__c = this.processStatus;
        objContract.PRBPortfolio__c = this.prbPortfolio;
        objContract.TradingConditionNegotiated__c = this.tradingConditionNegotiated;
        objContract.Source__c = this.source;
        objContract.CancelComments__c = this.CancelComments;
        objContract.Status__c = this.status;
        objContract.DistributorTax__c = this.distributorTax;
        objContract.FreightDistributor__c = this.freightDistributor;
        objContract.TotalTaxAP__c = this.totalTaxAP;
        objContract.TotalShippingAP__c = this.totalShippingAP;
        objContract.ROIApMeta__c = this.roiApMeta;
        objContract.ROINetSalesMeta__c = this.roiNetSalesMeta;
        objContract.ROIContratoMeta__c = this.roiContratoMeta;
        objContract.EstimatedNumberEvents__c = this.estimatedNumberEvents;
		
		objContract.LAT_OnInvoice__c = this.onInvoice;
		objContract.LAT_Total_Contrato_OnInvoice_Predicted__c = this.TotalContractOnInvoice;
		if (String.IsNotBlank(this.ROIPrevistoOnInvoice)) objContract.LAT_ROIPrevistoOnInvoice__c = Decimal.valueOf(this.ROIPrevistoOnInvoice);

		//objContract.LAT_TotalContractOnInvoice__c = this.TotalContractOnInvoice;

		if (String.IsNotBlank(this.sfdcId) && this.sfdcId.startsWith(LAT_Contract2__c.sObjectType.getDescribe().getKeyPrefix())) {
			objContract.Id = this.sfdcId;
			System.debug('toContract [objContract.Id : ' + objContract.Id + ']');
		} else {
			objContract.External_Id__c = this.sfdcId;
		}	

		System.debug('toContract [' + objContract + '] <-');

		return objContract;
	}

	public ContractCalculationProdutor toContractProdutor() {
		ContractCalculationProdutor objResult = null;

		System.debug('toContractProdutor [] ->');
		System.debug('toContractProdutor [this : ' + this + ']');
		System.debug('toContractProdutor [this.onInvoice : ' + this.onInvoice + ']');
		objResult = new ContractCalculationProdutor();
        objResult.imposto_distribuidor = this.distributorTax;
		objResult.frete_distribuidor = this.freightDistributor;      
		
		objResult.total_contrato_oninvoice = this.TotalContractOnInvoice;     
		objResult.TotalOnInvoice = this.onInvoice;
		objResult.TotalContractOnInvoice = this.TotalContractOnInvoice;
		objResult.ROIOnInvoiceRoiPrevisto = (String.isNotBlank(this.ROIPrevistoOnInvoice))?Decimal.valueOf(this.ROIPrevistoOnInvoice):0;


		System.debug('toContractProdutor [' + objResult + '] <-');
		return objResult;
	}

	public ContractCalculationDistribuidor toContractDistribuidor() {
		ContractCalculationDistribuidor objResult = null;

		System.debug('toContractDistribuidor [] ->');
		objResult = new ContractCalculationDistribuidor();
        objResult.imposto_distribuidor = this.distributorTax;
        objResult.frete_distribuidor = this.freightDistributor;      
          
        objResult.vd_total_contrato_oninvoice = this.onInvoice;        
        objResult.total_contrato_oninvoice = this.onInvoice;
        objResult.total_frete = this.freightDistributor;        
        objResult.roi_previsto_oninvoice = String.isNotBlank(this.ROIPrevistoOnInvoice)?Decimal.valueOf(this.ROIPrevistoOnInvoice):0;    
        objResult.roi_oninvoice = String.isNotBlank(this.ROIPrevistoOnInvoice)?Decimal.valueOf(this.ROIPrevistoOnInvoice):0;
        objResult.oninvoice = this.onInvoice;

		System.debug('toContractDistribuidor [' + objResult + '] <-');
		return objResult;
	}
	
	public LAT_ContractHandlerJSON() {}
	
	public LAT_ContractHandlerJSON(LAT_Contract2__c objContract) {
		System.debug('LAT_ContractHandlerJSON[objContract : '  + objContract + '] ->');

		System.debug('LAT_ContractHandlerJSON[objContract.RecordTypeId : '  + objContract.RecordTypeId + ']');

		if(objContract.RecordTypeId == Schema.SObjectType.LAT_Contract2__c.getRecordTypeInfosByDeveloperName().get(LAT_ContractsCalculations.EVENT_PRODUCER).getRecordTypeId() || objContract.RecordTypeId == Schema.SObjectType.LAT_Contract2__c.getRecordTypeInfosByDeveloperName().get(LAT_ContractsCalculations.EVENT_PRODUCER_SIMULATION).getRecordTypeId()) {
			System.debug('LAT_ContractHandlerJSON[procesando contrato produtor]');
			this.recordType = objContract.RecordTypeId;
			this.distribuitorId = objContract.LAT_Distributor__c;
			
			this.ROIPrevistoOnInvoice = (objContract.LAT_ROIPrevistoOnInvoice__c != null)?String.valueOf(objContract.LAT_ROIPrevistoOnInvoice__c):'';
			System.debug('LAT_ContractHandlerJSON[objContract.LAT_ROIPrevistoOnInvoice__c : ' + objContract.LAT_ROIPrevistoOnInvoice__c + ']');
			System.debug('LAT_ContractHandlerJSON[this.ROIPrevistoOnInvoice : ' + this.ROIPrevistoOnInvoice + ']');
			
			this.uf = objContract.LAT_Uf__c;
	        this.money = objContract.Money__c;
			this.roi = objContract.ROI__c;
			this.distributorTax = objContract.DistributorTax__c;
			this.freightDistributor = objContract.FreightDistributor__c;
			this.account = objContract.Account__c;
			this.owner = objContract.OwnerId;
			this.TotalContractOnInvoice = objContract.LAT_Total_Contrato_OnInvoice_Predicted__c;
			this.onInvoice = objContract.LAT_OnInvoice__c;
			this.ROIPrevistoOnInvoice = (objContract.LAT_ROIPrevistoOnInvoice__c != null)?String.valueOf(objContract.LAT_ROIPrevistoOnInvoice__c):'';
			
			this.listContractEvent = new listContractEvent();
			this.listVolume = new listVolume();
			this.listPayment = new ListPayment();

			if(objContract.LAT_ContractVolumes__r != null && !objContract.LAT_ContractVolumes__r.isEmpty()) {
				this.listVolume.add(objContract.LAT_ContractVolumes__r);
			}

			if(objContract.LAT_Payments__r != null && !objContract.LAT_Payments__r.isEmpty()) {
				this.listPayment.add(objContract.LAT_Payments__r);
			}
		} else if (objContract.RecordTypeId == Schema.SObjectType.LAT_Contract2__c.getRecordTypeInfosByDeveloperName().get(LAT_ContractsCalculations.EVENT_DISTRIBUTOR).getRecordTypeId() || objContract.RecordTypeId == Schema.SObjectType.LAT_Contract2__c.getRecordTypeInfosByDeveloperName().get(LAT_ContractsCalculations.EVENT_DISTRIBUTOR_SIMULATION).getRecordTypeId()) { 
			System.debug('LAT_ContractHandlerJSON[procesando contrato distribuidor]');

			this.recordType = objContract.RecordTypeId;
			this.distribuitorId = objContract.LAT_Distributor__c;
			this.ROIPrevistoOnInvoice = (objContract.LAT_ROIPrevistoOnInvoice__c != null)?String.valueOf(objContract.LAT_ROIPrevistoOnInvoice__c):'';
			this.uf = objContract.LAT_Uf__c;
	        this.money = objContract.Money__c;
			this.roi = objContract.ROI__c;
			this.distributorTax = objContract.DistributorTax__c;
			this.freightDistributor = objContract.FreightDistributor__c;
			this.account = objContract.Account__c;
			this.listContractEvent = new listContractEvent();
			this.listVolume = new listVolume();
			this.onInvoice = objContract.LAT_OnInvoice__c;

			if(objContract.Eventos__r != null && !objContract.Eventos__r.isEmpty()) {
				this.listContractEvent.add(objContract.Eventos__r);
			}

			if(objContract.LAT_ContractVolumes__r != null && !objContract.LAT_ContractVolumes__r.isEmpty()) {
				this.listVolume.add(objContract.LAT_ContractVolumes__r);
			}
		}

		System.debug('LAT_ContractHandlerJSON [] <-');
	}

	public class ListClientContract {
		public List<ClientContract> clientContract {get;set;} 
	}
	
	public class ListVolume {
		public List<Volume> volume {get;set;} 

		public ListVolume() {
			this.volume = new List<volume>();
		}

		public Set<Id> toProductIds() {
			Set<Id> setId = null;
			System.debug('toProductIds [] ->');
			setId = new Set<Id>();

			if(this.volume != null && !this.volume.isEmpty()) {
				for(Volume objVolume : this.volume) {
					if(objVolume.toDelete == null || !objVolume.toDelete) {
						setId.add(objVolume.product);
					}
				}
			}

			System.debug('toProductIds [' + setId + '] <-');

			return setId;
		}

		public void add(List<LAT_ContractVolume__c> lstVolumes) {
			if(lstVolumes != null && !lstVolumes.isEmpty()) {
				for(LAT_ContractVolume__c objVolume : lstVolumes) {
					this.volume.add( new volume(objVolume) );
				}
			}
		}

		public void add(List<LAT_EventVolume__c> lstVolumes) {
			if(lstVolumes != null && !lstVolumes.isEmpty()) {
				for(LAT_EventVolume__c objVolume : lstVolumes) {
					this.volume.add( new volume(objVolume) );
				}
			}
		}
	}
	
	public class ListProviders {
		public List<Provider> provider {get;set;} 
	}

	public class ListContractEvent {
		public List<ContractEvent> contractEvent {get;set;} 

		public ListContractEvent() {
			this.contractEvent = new List<ContractEvent>();
		}

		public void add(List<LAT_Contract_Eventos__c> lstContractEvents) {
			if(lstContractEvents != null && !lstContractEvents.isEmpty()) {
				for(LAT_Contract_Eventos__c objContractEvent : lstContractEvents) {
					this.contractEvent.add( new ContractEvent(objContractEvent) );
				}
			}
		}

		public Set<Id> toProductIds() {
			Set<Id> setProductIds = null;

			setProductIds = new Set<Id>();
			if(this.contractEvent != null && !this.contractEvent.isEmpty()) {
				for(ContractEvent objContractEvent : this.contractEvent) {
					if(objContractEvent.listVolume != null) {
						setProductIds.addAll(objContractEvent.listVolume.toProductIds());
					}
				}
			}

			return setProductIds;
		}
	}
	
	public class ListVisibilityCounterPart {
		public List<VisibilityCounterPart> visibilityCounterPart {get;set;} 
	}

	public class ListPayment {
		public List<Payment> payment {get;set;} 

		public ListPayment() {
			this.payment = new List<Payment>();
		}

		public void add(List<LAT_Payment__c> lstPayments) {
			if(lstPayments != null && !lstPayments.isEmpty()) {
				for(LAT_Payment__c objPayment : lstPayments) {
					this.payment.add( new Payment(objPayment) );
				}
			}
		}

		public void add(List<LAT_EventPayment__c> lstPayments) {
			if(lstPayments != null && !lstPayments.isEmpty()) {
				for(LAT_EventPayment__c objPayment : lstPayments) {
					this.payment.add( new Payment(objPayment) );
				}
			}
		}

		public Set<Id> toProductIds() {
			Set<Id> setProductIds = null;

			setProductIds = new Set<Id>();
			if(this.payment != null && !this.payment.isEmpty()) {
				for(Payment objPayment : this.payment) {
					setProductIds.add(objPayment.productGroup);
				}
			}

			return setProductIds;
		}
	}
	
	public class ListContractDetail {
		public List<ContractDetail> contractDetail {get;set;} 
	}
	
	public class ListPromotionAgreement {
		public List<PromotionAgreement> promotionAgreement {get;set;}  
	}

	public class PromotionAgreement {
		public String id {get;set;} 
		public Boolean toDelete {get;set;} 
		public String category {get;set;} 
		public String contract {get;set;} 
		public Boolean exclusivityPromotional {get;set;} 
		public Boolean visualExclusivity {get;set;} 
		public String notes {get;set;} 
		public Boolean priority {get;set;} 
	}
	
	public class ContractDetail {
		public String id {get;set;} 
		public Boolean toDelete {get;set;} 
		public String contract {get;set;} 
		public String date_Z {get;set;} 
		public String local {get;set;} 
		public String brand {get;set;}
		public String recordType {get;set;} 
	}
	
	public class VisibilityCounterPart {
		public String id {get;set;} 
		public Boolean toDelete {get;set;} 
		public String contract {get;set;} 
		public String type_Z {get;set;} // in json: type
		public String comment {get;set;} 
		public String socialMedia {get;set;} 
		public String link {get;set;} 
	}
	
	public class Provider {
		public String id {get;set;} 
		public Boolean toDelete {get;set;} 
		public String provider {get;set;} 
		public String cnpj {get;set;} 
		public String contract {get;set;} 
	}

	public class Payment {
		public String id {get;set;} 
		public Boolean toDelete {get;set;} 
		public String finality {get;set;} 
		public String contract {get;set;} 
		public String paymentDate {get;set;} 
		public String productGroup {get;set;} 
		public String recordType {get;set;} 
		public Double volumen {get;set;} 
		public String status {get;set;} 
		public Double ammount {get;set;} 
		public String paymentDateDone {get;set;}  
		public String releaseReason {get;set;}  
		public Double bonusPercent {get;set;} 
		public Double bonusQuantity {get;set;} 
		public Boolean producer {get;set;} 
		public String distribuitorId{get;set;} 
		public Double valorEventoTotal {get;set;} 
		public Double valorEventoCash {get;set;} 
		public Double valorEventoProuto {get;set;} 
		public Double cajasProduto {get;set;} 
		public Boolean EventPaymentCreatedAfterSigning {get;set;}
		public Double imposto {get;set;}
		public String eventType {get; set;}
		public Double volumenGF {get;set;} 

		public Payment() {}

		public Payment(LAT_Payment__c objPayment) {
			this.id = objPayment.Id;
			this.finality = objPayment.Finality__c; 
			this.contract = objPayment.LAT_Contract__c;
			this.paymentDate = (objPayment.PaymentDate__c != null)?objPayment.PaymentDate__c.format():'';
			this.productGroup = objPayment.ProductGroup__c;
			this.recordType = objPayment.RecordTypeId;
			this.volumen = objPayment.Volumen__c;
			this.status = objPayment.Status__c;
			this.ammount = objPayment.Ammount__c;
			this.paymentDateDone = (objPayment.PaymentDateDone__c != null)?objPayment.PaymentDateDone__c.format():''; 
			this.releaseReason = objPayment.ReleaseReason__c; 
			this.bonusPercent = objPayment.LAT_BonusPercent__c;
			this.bonusQuantity = objPayment.LAT_BonusQuantity__c;
			this.producer = objPayment.LAT_Producer__c;
			this.distribuitorId = objPayment.LAT_Distributor__c;
			this.valorEventoTotal = objPayment.LAT_EventValue__c;
			this.valorEventoCash = objPayment.LAT_EventCashValue__c;
			this.valorEventoProuto = objPayment.LAT_EventProductValue__c;
			this.cajasProduto = objPayment.LAT_EventBoxQuantity__c;
			this.EventPaymentCreatedAfterSigning = objPayment.EventPaymentCreatedAfterSigning__c;
			this.imposto = objPayment.LAT_Taxes__c;
			this.eventType = objPayment.EventType__c;
			//this.volumenGF = objPayment.LAT_Volume__c;
		}

		public Payment(LAT_EventPayment__c objPayment) {
			this.id = objPayment.Id;
			this.finality = objPayment.LAT_Finality__c; 
			this.contract = objPayment.LAT_ContractEvent__c;
			this.paymentDate = (objPayment.LAT_PaymentDate__c != null)?objPayment.LAT_PaymentDate__c.format():'';
			this.productGroup = objPayment.LAT_ProductGroup__c;
			this.recordType = objPayment.RecordTypeId;
			this.volumen = objPayment.LAT_Volumen__c;
			this.status = objPayment.LAT_Status__c;
			this.ammount = objPayment.LAT_Ammount__c;
			this.paymentDateDone = (objPayment.LAT_PaymentDateDone__c != null)?objPayment.LAT_PaymentDateDone__c.format():''; 
			this.releaseReason = objPayment.LAT_ReleaseReason__c; 
			this.bonusPercent = objPayment.LAT_BonusPercent__c;
			this.bonusQuantity = objPayment.LAT_BonusQuantity__c;
			this.producer = objPayment.LAT_Producer__c;
			this.distribuitorId = objPayment.LAT_Distributor__c;
			this.valorEventoTotal = objPayment.LAT_EventValue__c;
			this.valorEventoCash = objPayment.LAT_EventCashValue__c;
			this.valorEventoProuto = objPayment.LAT_EventProductValue__c;
			//this.cajasProduto = objPayment.LAT_EventBoxQuantity__c;
			this.EventPaymentCreatedAfterSigning = objPayment.LAT_EventPaymentCreatedAfterSigning__c;
			//this.imposto = objPayment.LAT_Taxes__c;
			this.eventType = objPayment.LAT_EventType__c;
			//this.volumenGF = objPayment.LAT_Volume__c;
		}
	}
	
	public class Volume {
		public String id {get;set;} 
		public Boolean toDelete {get;set;} 
		public String contract {get;set;} 
		public String product {get;set;} 
		public String boxesMaximum {get;set;} 
		public String estimatedBoxesMaximum {get;set;} 
		public String boxesContractMonth {get;set;} 
		public String businessCondition {get;set;} 
		public Double volumenGF {get;set;} 
		public Double realizedVolumenGF {get;set;} 
		public Double bonusQuantity {get;set;} 
		public Double bonusPercent {get;set;}
		public String recordType {get;set;} 
		public Boolean producer {get; set;} 
		public Decimal purchaseVolumeGF {get; set;} 
		public Decimal bonusVolumeGF {get; set;} 
		public String eventType {get; set;} 
		public String finality {get;set;} 
		public Decimal valorCompreGane {get; set;} 				
		public String categoryid {get; set;}
		public String description {get; set;}
		public String EventId {get; set;}

		public Volume() {}

		public Volume(LAT_ContractVolume__c objVolume) {
			this.id = objVolume.Id;
			this.contract = objVolume.LAT_Contract__c;
			this.product = objVolume.ProductGroup__c;
			this.boxesMaximum = (objVolume.BoxesContract__c != null)? String.valueOf(objVolume.BoxesContract__c):'';
			this.estimatedBoxesMaximum = (objVolume.LAT_EstimatedBoxesContract__c != null)?String.valueOf(objVolume.LAT_EstimatedBoxesContract__c):'';
			this.boxesContractMonth = (objVolume.BusinessCondition__c != null)?String.valueOf(objVolume.BusinessCondition__c):'';
			this.businessCondition  = (objVolume.BoxesContractMonth__c != null)?String.valueOf(objVolume.BoxesContractMonth__c) :''; 
			this.volumenGF  = objVolume.LAT_BottleVolumen__c;
			this.realizedVolumenGF  = objVolume.LAT_RealizedVolumeGF__c;
			this.bonusQuantity  = objVolume.LAT_BonusQuantity__c;
			this.bonusPercent = objVolume.LAT_BonusPercent__c;
			this.recordType = objVolume.RecordTypeId; 
			this.producer = objVolume.Producer__c;
			this.purchaseVolumeGF = objVolume.PurchaseVolumeGF__c;
			this.bonusVolumeGF = objVolume.BonusVolumeGF__c;
			this.eventType = objVolume.EventType__c; 
			this.finality = objVolume.Finality__c; 
			this.valorCompreGane = objVolume.LAT_Valor_Compre_e_Ganhe__c;
			this.description = objVolume.LAT_BR_Category_Description__c;
		}

		public Volume(LAT_EventVolume__c objVolume) {
			this.id = objVolume.Id;
			this.contract = objVolume.LAT_ContractEvent__c;
			this.product = objVolume.LAT_ProductGroup__c;
			this.estimatedBoxesMaximum = (objVolume.LAT_EstimatedBoxesContract__c != null)?String.valueOf(objVolume.LAT_EstimatedBoxesContract__c):'';
			this.boxesContractMonth = (objVolume.LAT_BusinessCondition__c != null)?String.valueOf(objVolume.LAT_BusinessCondition__c):'';
			this.businessCondition  = (objVolume.LAT_EstimatedBoxesContract__c != null)?String.valueOf(objVolume.LAT_EstimatedBoxesContract__c) :''; 
			this.volumenGF  = objVolume.LAT_Volume__c;
			this.realizedVolumenGF  = objVolume.LAT_RealizedVolumeGF__c;
			this.bonusPercent = objVolume.LAT_BonusPercent__c;
			this.recordType = objVolume.RecordTypeId; 
			this.finality = objVolume.Finality__c; 

			this.boxesMaximum = (objVolume.LAT_BoxesContract__c != null)? String.valueOf(objVolume.LAT_BoxesContract__c):'';
			this.bonusQuantity = (objVolume.LAT_BonusQuantity__c != null)? objVolume.LAT_BonusQuantity__c:0;
		}		
	}

	public class ContractEvent {
		public String id {get;set;} 
		public Boolean toDelete {get;set;} 
		public String contract {get;set;} 
		public String cidade {get;set;} 
		public String convitesPista {get;set;} 
		public String convitesVIP {get;set;} 
		public String microRegional {get;set;} 
		public String nroPessoas {get;set;} 
		public Boolean openBar {get;set;}
		public String perfil {get;set;}
		public String periodo {get;set;}
		public String tipoEvento {get;set;}
		public String tipoVerba {get;set;}
		public String tipoInvestimento {get;set;}
		public String Investimento {get;set;}		
		public String classeSocial {get;set;}
		public String comunicacaoes {get;set;}
		public String estilosMusicales {get;set;}
		public String faixaEtarias {get;set;}
		public String motivo {get;set;}
		public String motivoComentarios {get;set;}
		public String status {get;set;}
		public String valorIngresso {get;set;}
		public String marcasActivadas {get;set;}
		public String marcasActivadasSR {get;set;}
		public String postsRedes {get;set;}
		public String ativacoes {get;set;} 
		public String eventName {get;set;} 
		public String dataEvento {get;set;} 
		public String comments {get;set;} 
		public String category {get;set;}
		public String PredictedROI {get;set;}		
		public ListVolume listVolume {get;set;} 
		public ListPayment listPayment {get;set;} 

		public ContractEvent() {
			this.listVolume = new ListVolume();
			this.listPayment = new ListPayment();
		}

		public ContractEvent(LAT_Contract_Eventos__c objEvent) {
			this();

			this.Id = objEvent.Id;
			this.contract = objEvent.LAT_Contract__c;
			this.cidade = objEvent.LAT_Cidade__c;
			this.convitesPista = (objEvent.LAT_Convites_Pista__c != null)?String.valueOf(objEvent.LAT_Convites_Pista__c):'';
			this.convitesVIP = (objEvent.LAT_Convites_VIP__c != null)?String.valueOf(objEvent.LAT_Convites_VIP__c):'';
			this.microRegional = objEvent.LAT_Micro_Regional__c;
			this.nroPessoas = (objEvent.LAT_No_Pessoas__c != null)?String.valueOf(objEvent.LAT_No_Pessoas__c) :'';
			this.openBar = objEvent.LAT_Open_Bar__c;
			this.perfil = objEvent.LAT_Perfil__c;
			this.periodo = objEvent.LAT_Periodo__c;
			this.tipoEvento = objEvent.LAT_Tipo_de_Evento__c;
			this.tipoVerba = objEvent.LAT_Tipo_de_Verba__c;
			this.tipoInvestimento = objEvent.LAT_Tipo_Investimento__c;
			this.Investimento = String.valueOf(objEvent.LAT_BR_Investimento__c);
			this.classeSocial = objEvent.LAT_Classe_Social__c;
			this.comunicacaoes = objEvent.LAT_Comunicacao__c;
			this.estilosMusicales = objEvent.LAT_Estilo_Musical__c;
			this.faixaEtarias = objEvent.LAT_Faixa_Etaria__c;
			this.motivo = objEvent.LAT_Motivo__c;
			this.motivoComentarios = objEvent.LAT_Motivo_Comentarios__c;
			this.status = objEvent.LAT_Status__c;
			this.valorIngresso = objEvent.Valor_Ingresso__c;
			this.marcasActivadas = objEvent.LAT_MarcasAtivadas__c;
			this.marcasActivadasSR = objEvent.LAT_MarcasAtivadasSR__c;
			this.postsRedes = (objEvent.lat_no_posts__c != null)?String.valueOf(objEvent.lat_no_posts__c):'';
			this.ativacoes = objEvent.LAT_Ativacoes__c;
			this.eventName = objEvent.Name;
			this.dataEvento = (objEvent.LAT_Data_Evento__c != null)?objEvent.LAT_Data_Evento__c.format():'';
			this.comments = objEvent.LAT_Comments__c;
			this.category = objEvent.LAT_Category__c;
			this.PredictedROI = (objEvent.LAT_PredictedROI__c != null)?String.valueOf(objEvent.LAT_PredictedROI__c):'';

			System.debug('ContractEvent[objEvent.Pagamentos_Evento__r.size() : ' + objEvent.Pagamentos_Evento__r.size() + '] ');
			if(objEvent.Pagamentos_Evento__r != null && !objEvent.Pagamentos_Evento__r.isEmpty()) {
				this.listPayment.add(objEvent.Pagamentos_Evento__r);
			}

			System.debug('ContractEvent[objEvent.Volumen_Eventos__r.size() : ' + objEvent.Volumen_Eventos__r.size() + '] ');
			if(objEvent.Volumen_Eventos__r != null && !objEvent.Volumen_Eventos__r.isEmpty()) {
				this.listVolume.add(objEvent.Volumen_Eventos__r);
			}
		}
	}

	public class ClientContract {
		public String id {get;set;} 
		public Boolean toDelete {get;set;} 
		public String client {get;set;} 
		public String contract {get;set;} 
	}

	public class ContractCalculationProdutor {
		public Decimal imposto_distribuidor {get; set; }
		public Decimal frete_distribuidor {get; set; }
		public Decimal total_contrato_oninvoice {get; set; }

		public Decimal TotalProductsPRBCostCondComercial {get; set; }
		public Decimal TotalProductsPRBCostPatrocinio {get; set; }
		public Decimal TotalTaxAP {get; set; }
		public Decimal TotalShippingAP {get; set; }
		public Decimal TotalMoneyPRBCost {get; set; }
		public Decimal TotalEventContractPRBCost {get; set; }
		public Decimal TotalOnInvoice {get; set; }

		public Decimal TotalProductsPRBCostCondComercialNetSales {get; set; }
		public Decimal TotalProductsPRBCostPatrocinioNetSales {get; set; }
		public Decimal TotalTaxNetSales {get; set; }
		public Decimal TotalShippingNetSales {get; set; }
		public Decimal TotalEventContractPRBCostNetSales {get; set; }

		public Decimal TotalProductsPerceivedValueCondComercial {get; set; }
		public Decimal TotalProductsPerceivedValuePatrocinio {get; set; }
		public Decimal TotalMoneyPerceivedValue {get; set; }
		public Decimal TotalContractOnInvoice {get; set; }
		public Decimal TotalEventContractPerceivedValue {get; set; }

		public Decimal ROIApRoiPrevisto {get; set; }
		public Decimal ROINetSalesRoiPrevisto {get; set; }
		public Decimal ROIContratoRoiPrevisto {get; set; }
		public Decimal ROIOnInvoiceRoiPrevisto {get; set; }

		public String ROIApMeta {get; set; }
		public String ROINetSalesMeta {get; set; }
		public String ROIContratoMeta {get; set; }
		public String ROIOnInvoiceMeta {get; set; }

		public String ROIApVsMeta {get; set; }
		public String ROINetSalesVsMeta {get; set; }
		public String ROIOnInvoiceVsMeta {get; set; }
		public String ROIContratoVsMeta {get; set; }

		public ContractCalculationProdutor() {}

		public ContractCalculationProdutor(LAT_Contract2__c objContract) {
			this.TotalProductsPRBCostCondComercial = objContract.TotalProductsPRBCostCondComercial__c;
			this.TotalProductsPRBCostPatrocinio = objContract.TotalProductsPRBCostPatrocinio__c;
			this.TotalTaxAP = objContract.TotalTaxAP__c;
			this.TotalShippingAP = objContract.TotalShippingAP__c;
			this.TotalMoneyPRBCost = objContract.TotalMoneyPRBCost__c;
			this.TotalEventContractPRBCost = objContract.TotalEventContractPRBCost__c;
	
			this.TotalProductsPRBCostCondComercialNetSales = objContract.TotalProductsPRBCostCondComercialNetSale__c;
			this.TotalProductsPRBCostPatrocinioNetSales = objContract.TotalProductsPRBCostPatrocinioNetSales__c;
			this.TotalTaxNetSales = objContract.TotalTaxNetSales__c;
			this.TotalShippingNetSales = objContract.TotalShippingNetSales__c;
			this.TotalEventContractPRBCostNetSales = objContract.TotalEventContractPRBCostNetSales__c;
	
			this.TotalProductsPerceivedValueCondComercial = objContract.TotalProductsPerceivedValueCondComercial__c;
			this.TotalProductsPerceivedValuePatrocinio = objContract.TotalProductsPerceivedValuePatrocinio__c;
			this.TotalMoneyPerceivedValue = objContract.TotalMoneyPerceivedValue__c;
			//this.TotalOnInvoicePerceivedValue = objContract.LAT_TotalContractOnInvoice__c;
			this.TotalEventContractPerceivedValue = objContract.TotalEventContractPerceivedValue__c;
			
			this.TotalOnInvoice = objContract.LAT_OnInvoice__c;
			this.TotalContractOnInvoice = objContract.LAT_TotalContractOnInvoice__c;

			this.ROIApRoiPrevisto = objContract.ROIApRoiPrevisto__c;
			//this.ROIOffInvoicePrevisto = objContract.ROI;
			this.ROIOnInvoiceRoiPrevisto = objContract.LAT_ROIPrevistoOnInvoice__c;
			this.ROINetSalesRoiPrevisto = objContract.ROINetSalesRoiPrevisto__c;
			this.ROIContratoRoiPrevisto = objContract.ROIContratoRoiPrevisto__c;
	
			this.ROIApMeta = objContract.ROIApMeta__c;
			this.ROINetSalesMeta = objContract.ROINetSalesMeta__c;
			this.ROIContratoMeta = objContract.ROIContratoMeta__c;
			this.ROIOnInvoiceMeta = objContract.ROI_OnInvoice_Meta__c;
	
			this.ROIApVsMeta = objContract.ROIApVsMeta__c;
			this.ROINetSalesVsMeta = objContract.ROINetSalesVsMeta__c;
			this.ROIContratoVsMeta = objContract.ROIContratoVsMeta__c;
			this.ROIOnInvoiceVsMeta = objContract.ROI_OnInvoice_Vs_Meta__c;
		}

		public LAT_Contract2__c enrich(LAT_Contract2__c objContract) {
			objContract.TotalProductsPRBCostCondComercial__c = this.TotalProductsPRBCostCondComercial;
			objContract.TotalProductsPRBCostCondComercialNetSale__c = this.TotalProductsPRBCostCondComercialNetSales;
			objContract.TotalProductsPRBCostPatrocinio__c =  this.TotalProductsPRBCostPatrocinio;
			objContract.TotalProductsPRBCostPatrocinioNetSales__c =  this.TotalProductsPRBCostPatrocinioNetSales;
			objContract.TotalTaxAP__c = this.TotalTaxAP;
			objContract.TotalTaxNetSales__c = this.TotalTaxNetSales;
			objContract.TotalShippingAP__c = this.TotalShippingAP;
			objContract.TotalShippingNetSales__c = this.TotalShippingNetSales;
			objContract.TotalMoneyPRBCost__c = this.TotalMoneyPRBCost;
			objContract.TotalEventContractPRBCost__c = this.TotalEventContractPRBCost;
			objContract.TotalEventContractPRBCostNetSales__c = this.TotalEventContractPRBCostNetSales;
			objContract.LAT_OnInvoice__c = this.TotalOnInvoice;
			
			objContract.TotalProductsPerceivedValueCondComercial__c = this.TotalProductsPerceivedValueCondComercial;
			objContract.TotalMoneyPerceivedValue__c = this.TotalMoneyPerceivedValue;
			objContract.TotalProductsPerceivedValuePatrocinio__c = this.TotalProductsPerceivedValuePatrocinio;
			objContract.TotalEventContractPerceivedValue__c = this.TotalEventContractPerceivedValue;

			objContract.ROIApRoiPrevisto__c= this.ROIApRoiPrevisto;
			objContract.ROINetSalesRoiPrevisto__c= this.ROINetSalesRoiPrevisto;
			objContract.LAT_ROIPrevistoOnInvoice__c= this.ROIOnInvoiceRoiPrevisto;
			objContract.ROIContratoRoiPrevisto__c= this.ROIContratoRoiPrevisto;
		  
			return objContract;
		}

		public LAT_Contract2__c enrich(LAT_Contract2__c objContract, LAT_Meta_ROI_Consultant__c objMetaROI) {		  
			if(objMetaROI != null) {
				objContract.ROIApMeta__c = (objMetaROI.ROI_AP__c != null)?String.valueOf(objMetaROI.ROI_AP__c / 100) :'';
				objContract.ROINetSalesMeta__c = (objMetaROI.ROI_Net_Sales__c != null)?String.valueOf(objMetaROI.ROI_Net_Sales__c / 100) :'';
				objContract.ROIContratoMeta__c =  (objMetaROI.ROI_Contrato__c != null)?String.valueOf(objMetaROI.ROI_Contrato__c / 100) :'';
				objContract.ROI_OnInvoice_Meta__c =  (objMetaROI.ROI_OnInvoice__c != null)?String.valueOf(objMetaROI.ROI_OnInvoice__c / 100) :'';
				
				objContract.ROIApVsMeta__c = (objMetaROI.ROI_AP__c != null && objContract.ROIApRoiPrevisto__c != null)? String.valueOf( (objContract.ROIApRoiPrevisto__c / 100 + objMetaROI.ROI_AP__c / 100).setScale(2)):'';
				objContract.ROINetSalesVsMeta__c = (objMetaROI.ROI_Net_Sales__c != null && objContract.ROINetSalesRoiPrevisto__c != null)?String.valueOf( (objContract.ROINetSalesRoiPrevisto__c / 100 + objMetaROI.ROI_Net_Sales__c / 100).setScale(2)):'';
				objContract.ROIContratoVsMeta__c = (objMetaROI.ROI_Contrato__c != null && objContract.ROIContratoRoiPrevisto__c != null)?String.valueOf( (objContract.ROIContratoRoiPrevisto__c / 100 + objMetaROI.ROI_Contrato__c / 100).setScale(2)):'';
				objContract.ROI_OnInvoice_Vs_Meta__c = (objMetaROI.ROI_OnInvoice__c != null && objContract.LAT_ROIPrevistoOnInvoice__c != null)?String.valueOf( (objContract.LAT_ROIPrevistoOnInvoice__c + objMetaROI.ROI_OnInvoice__c / 100).setScale(2)):'';	

			}

			return objContract;
		}
	}

	public class ContractCalculationDistribuidor {
		public Decimal imposto_distribuidor {get; set; }
		public Decimal frete_distribuidor {get; set; }

		public Decimal vd_total_contrato_oninvoice {get; set; }
		public Decimal vd_total_contrato_offinvoice {get; set; }

		public Decimal total_contrato {get; set; }
		public Decimal total_contrato_oninvoice {get; set; }
		public Decimal total_imposto {get; set; }
		public Decimal total_frete {get; set; }

		public Decimal roi_previsto {get; set; }
		public Decimal roi_previsto_oninvoice {get; set; }		

		public Decimal roi_oninvoice {get; set; }
		public Decimal roi_offinvoice {get; set; }		
		public Decimal total_offinvoice {get; set; }	
		public Decimal oninvoice {get; set; }	
		
		public List<ContractCalculationEvent> eventos {get; set; }		
		
		public ContractCalculationDistribuidor() {
			this.eventos = new List<ContractCalculationEvent>();
		}

		public ContractCalculationDistribuidor(LAT_Contract2__c objContract) {
			this.eventos = new List<ContractCalculationEvent>();
		}

		public List<LAT_Contract_Eventos__c> toUpdate() {
			List<LAT_Contract_Eventos__c> lstContractEventPayments = null;
			LAT_Contract_Eventos__c objEventAux = null;
			System.debug(' toUpdate [] ->');

			lstContractEventPayments = new List<LAT_Contract_Eventos__c>();
			for(ContractCalculationEvent objEvent : this.eventos) {
				System.debug('toUpdate [this.eventos : ' + this.eventos + ']');

				objEventAux = objEvent.toContratoEventos();
				if(String.isNotBlank(objEventAux.id)) {
					lstContractEventPayments.add(objEventAux);
				}
			}

			System.debug('toUpdate [' + lstContractEventPayments + '] <-');
			return lstContractEventPayments;
		}

		public List<LAT_Contract_Eventos__c> toUpsert() {
			List<LAT_Contract_Eventos__c> lstContractEventPayments = null;
			LAT_Contract_Eventos__c objEventAux = null;
			System.debug('toUpsert [] ->');
			lstContractEventPayments = new List<LAT_Contract_Eventos__c>();

			System.debug('toUpsert [this.eventos : ' + this.eventos + ']');

			for(ContractCalculationEvent objEvent : this.eventos) {
				objEventAux = objEvent.toContratoEventos();
				if(String.isNotBlank(objEventAux.LAT_External_Id__c)) {
					lstContractEventPayments.add(objEventAux);
				}
			}

			System.debug('toUpsert [' + lstContractEventPayments + '] <-');
			return lstContractEventPayments;
		}

		public LAT_Contract2__c enrich(LAT_Contract2__c objContract) {
			objContract.DistributorTax__c = this.imposto_distribuidor;                        
			objContract.FreightDistributor__c = this.frete_distribuidor;

			objContract.TotalTaxNetSales__c = this.total_imposto;
			objContract.TotalShippingNetSales__c = this.total_frete;
			objContract.TotalEventContractPerceivedValue__c = this.vd_total_contrato_offinvoice;
			objContract.ROINetSalesRoiPrevisto__c = this.roi_offinvoice;
			objContract.LAT_ROIPrevistoOnInvoice__c = this.roi_previsto_oninvoice;
			objContract.TotalEventContractPRBCostNetSales__c = this.total_offinvoice;
			objContract.LAT_Total_Contrato_OnInvoice_Predicted__c = this.total_contrato_oninvoice;
			objContract.TotalProductsPRBCost__c = this.total_contrato;
			objContract.ROIApRoiPrevisto__c = this.roi_previsto;
			//roi_oninvoice
			//roi_offinvoice
			//"total_contrato":607561.525,
			//objResult.TotalEventContractPRBCostNetSales = objResult.total_offinvoice;
			//contract.LAT_TotalContractOnInvoice__c = objDistribuidor.total_contrato_oninvoice;
			objContract.LAT_OnInvoice__c = this.oninvoice;

			return objContract;
		}
	}

    public class ContractCalculationEvent {
		public String type {get; set; }		
		public Decimal roi {get; set; }		
        public Decimal invoice {get; set; }
        public String externalid {get; set; }
		public String id {get;set;} 
		
        public ContractCalculationEvent() {
		}
		
		public LAT_Contract_Eventos__c toContratoEventos() {
			LAT_Contract_Eventos__c objContratoEvento = null;

			System.debug(' toContratoEventos [] ->');

			objContratoEvento = new LAT_Contract_Eventos__c();
			System.debug(' toContratoEventos [this : ' + this + '] ->');

			if(String.isNotBlank(this.Id) || String.isNotBlank(this.externalid)) {
				objContratoEvento.LAT_PredictedROI__c = this.roi;
				objContratoEvento.LAT_BR_Investimento__c = this.invoice;
				
				if (String.isNotBlank(this.Id) && this.Id.startsWith(LAT_Contract_Eventos__c.sObjectType.getDescribe().getKeyPrefix())) {
					objContratoEvento.Id = this.id;
				} else if(String.isNotBlank(this.externalid) && this.externalid.startsWith(LAT_Contract_Eventos__c.sObjectType.getDescribe().getKeyPrefix())) {
					objContratoEvento.Id = this.externalid;				
				} else if(String.isNotBlank(this.externalid)) {
					objContratoEvento.LAT_External_Id__c = this.externalid; 
				} else {
					objContratoEvento.LAT_External_Id__c = this.id; 
				}	 
			}
			//objContratoEvento.i = this.invoice;

			System.debug(' toContratoEventos [' + objContratoEvento + '] <-');

			return objContratoEvento;
		}
	}

	public class ContractCalculationEventRequest {
		public String type {get; set; }		
		public LAT_ContractHandlerJSON contract = null;
	}
}