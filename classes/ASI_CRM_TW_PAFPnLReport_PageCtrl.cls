/*
 * *******************************************************************************
 * Name: ASI_CRM_TW_PAFPnLReport_PageCtrl
 * Description: Controller class for ASI_CRM_TW_PAFPnLReport_Page
 * Version History
 * Date Developer Comments
 * --------------- -------------------- --------------------------------------------------------------------------------
 * 2018-09-03 Vincent Lam Created
 */
public class ASI_CRM_TW_PAFPnLReport_PageCtrl {

	public String pafId {
		get; set;
	}
    public String fileId;
    public String parentFileId;
	public Boolean isActualBreakdown {get; set;}
    public String returnFileId {get{return fileId;}}
	public String resultHTML {get; set;}

    public void printPDF(){
        Map<String, String> params = ApexPages.currentPage().getParameters();
		
		ASI_MFM_Mass_Upload_Log__c uploadLog = new ASI_MFM_Mass_Upload_Log__c();
		insert uploadLog;
		Attachment tempAttached = new Attachment();
		tempAttached.ParentId = uploadLog.Id;
		tempAttached.Name = 'TW PnL PDF';
		tempAttached.Body = Blob.valueOf(params.get('resultHTML'));
		insert tempAttached;
		
		system.debug(tempAttached);
		
		fileId = tempAttached.Id;
		system.debug(returnFileId);
    }
	
    public void buildResult(){
        Attachment tempAttachment = [SELECT Body, ParentId FROM Attachment WHERE Id = :fileId];
        resultHTML = tempAttachment.Body.toString();
		parentFileId = tempAttachment.ParentId;
		
    }
	
	public void deleteParentFile(){
		Delete [select id from ASI_MFM_Mass_Upload_Log__c where Id = :parentFileId];
	}
	

	public ASI_CRM_TW_PAFPnLReport_PageCtrl() {
		Map<String, String> params = ApexPages.currentPage().getParameters();
		pafId = params.get('id');
        //init();
        fileId = params.get('fileId');
        isActualBreakdown = params.get('actual') != null ? Boolean.valueOf(params.get('actual')) : false;
		if(fileId != null){
			buildResult();
		} else {
			init();
		}

	}

	private class PnLDetailWrapper{
		private ASI_HK_CRM_Pre_Approval_Form__c paf {
			get;set;
		}
		private ASI_HK_CRM_Pre_Approval_Form_Item__c variable {
			get;set;
		}
		private list<ASI_HK_CRM_Pre_Approval_Form_Item__c> list_conditional {
			get;set;
		}
		private list<ASI_HK_CRM_Pre_Approval_Form_Item__c> list_fixed {
			get;set;
		}
		private ASI_HK_CRM_Pre_Approval_Form_Item__c pg {
			get;set;
		}
		private decimal price_grossSales {
			get;set;
		}
		private decimal price_grossSales_foc {
			get;set;
		}
		private decimal price_pocket {
			get;set;
		}
		private decimal cost_AnDFOC {
			get;set;
		}
		private decimal cost_AnDFOC_foc {
			get;set;
		}
		private decimal cost_AnPFOC {
			get;set;
		}
		private decimal cost_AnPFOC_foc {
			get;set;
		}
		private decimal cost_AnDBudget {
			get;set;
		}
		private decimal cost_COGS {
			get;set;
		}
		private decimal cost_COGS_foc {
			get;set;
		}
		private list<PnLDetailWrapper> list_w {
			get;set;
		}
		private PnLDetailWrapper w_total {
			get;set;
		}
		private boolean isActual {
			get;set;
		}
		private aggregateResult actual {
			get;set;
		}
		private List<aggregateResult> list_actual {
			get;set;
		}
		private string commonName {
			get;set;
		}
		private string brandDescription {
			get;set;
		}
		private string productCat {
			get;set;
		}
		private decimal bottleSize {
			get;set;
		}
		private decimal bottleSize_foc {
			get;set;
		}
		private string itemGroupId {
			get;set;
		}
		private string subBrandId {
			get;set;
		}

		// for empty
		private PnLDetailWrapper() {
			this.paf = new ASI_HK_CRM_Pre_Approval_Form__c();
			this.variable = new ASI_HK_CRM_Pre_Approval_Form_Item__c();
			this.list_conditional = new list<ASI_HK_CRM_Pre_Approval_Form_Item__c>();
			this.list_fixed = new list<ASI_HK_CRM_Pre_Approval_Form_Item__c>();
			this.pg = new ASI_HK_CRM_Pre_Approval_Form_Item__c();
			this.price_grossSales = 0;
			this.price_grossSales_foc = 0;
			this.price_pocket = 0;
			this.cost_AnDFOC = 0;
			this.cost_AnPFOC = 0;
			this.cost_AnDFOC_foc = 0;
			this.cost_AnPFOC_foc = 0;
			this.cost_AnDBudget = 0;
			this.cost_COGS = 0;
			this.cost_COGS_foc = 0;
			this.isActual = false;
			resetNumbers();
		}

		// for lowest level
		private PnLDetailWrapper(ASI_HK_CRM_Pre_Approval_Form__c paf) {
			this.paf = paf;
			this.variable = new ASI_HK_CRM_Pre_Approval_Form_Item__c();
			this.list_conditional = new list<ASI_HK_CRM_Pre_Approval_Form_Item__c>();
			this.list_fixed = new list<ASI_HK_CRM_Pre_Approval_Form_Item__c>();
			this.pg = new ASI_HK_CRM_Pre_Approval_Form_Item__c();
			this.price_grossSales = 0;
			this.price_grossSales_foc = 0;
			this.price_pocket = 0;
			this.cost_AnDFOC = 0;
			this.cost_AnPFOC = 0;
			this.cost_AnDFOC_foc = 0;
			this.cost_AnPFOC_foc = 0;
			this.cost_AnDBudget = 0;
			this.cost_COGS = 0;
			this.cost_COGS_foc = 0;
			this.isActual = false;
			resetNumbers();
		}

		// for total
		private PnLDetailWrapper(ASI_HK_CRM_Pre_Approval_Form__c paf,
								 list<PnLDetailWrapper> list_w,
								 ASI_HK_CRM_Pre_Approval_Form_Item__c pg) {
			this.paf = paf;
			this.list_w = list_w;
			this.pg = pg;
			this.isActual = false;

			buildHeader_total();
			resetNumbers();
			set_PG();
			calculate_fromChild();
			calculate_selfFinal();
			this.shareOfSalesValue = 100;
			this.shareOfTradeAnP = 100;
		}

		// for grouped
		private PnLDetailWrapper(ASI_HK_CRM_Pre_Approval_Form__c paf, list<PnLDetailWrapper> list_w, string t) {
			this.paf = paf;
			this.list_w = list_w;
			this.isActual = false;

			buildHeader_grouped(t);
			resetNumbers();
			calculate_fromChild();
			calculate_selfFinal();
		}

		// for actual additional item group
		private PnLDetailWrapper(ASI_HK_CRM_Pre_Approval_Form__c paf, aggregateResult ag) {
			this.paf = paf;
			this.variable = new ASI_HK_CRM_Pre_Approval_Form_Item__c();
			this.list_conditional = new list<ASI_HK_CRM_Pre_Approval_Form_Item__c>();
			this.list_fixed = new list<ASI_HK_CRM_Pre_Approval_Form_Item__c>();
			this.pg = new ASI_HK_CRM_Pre_Approval_Form_Item__c();
			this.price_grossSales = 0;
			this.price_grossSales_foc = 0;
			this.price_pocket = 0;
			this.cost_AnDFOC = 0;
			this.cost_AnPFOC = 0;
			this.cost_AnDFOC_foc = 0;
			this.cost_AnPFOC_foc = 0;
			this.cost_AnDBudget = 0;
			this.cost_COGS = 0;
			this.cost_COGS_foc = 0;
			this.isActual = true;
			this.actual = ag;
			resetNumbers();
			buildItemGroup(ag);
			buildHeader();
			this.actualBottle = (decimal)ag.get('qty');
		}

		public PnLDetailWrapper clone(aggregateResult ag) {
			PnLDetailWrapper w = new PnLDetailWrapper();
			w.resetNumbers();
			w.paf = this.paf;
			w.variable = this.variable;
			w.list_conditional = this.list_conditional;
			w.list_fixed = this.list_fixed;
			w.price_grossSales = this.price_grossSales;
			w.price_grossSales_foc = this.price_grossSales_foc;
			w.price_pocket = this.price_pocket;
			w.cost_AnDFOC = this.cost_AnDFOC;
			w.cost_AnPFOC = this.cost_AnPFOC;
			w.cost_AnDFOC_foc = this.cost_AnDFOC_foc;
			w.cost_AnPFOC_foc = this.cost_AnPFOC_foc;
			w.cost_AnDBudget = this.cost_AnDBudget;
			w.cost_COGS = this.cost_COGS;
			w.cost_COGS_foc = this.cost_COGS_foc;
			w.pg = this.pg;
			w.isActual = true;
			w.actual = ag;
			w.buildItemGroup(ag);
			w.buildHeader();
			//w.var_AnD_focBottle = this.var_AnD_focBottle;
			w.calculate_foc();
			return w;
		}

		public PnLDetailWrapper clone(List<aggregateResult> list_ar) {
			PnLDetailWrapper w = new PnLDetailWrapper();
			w.resetNumbers();
			w.paf = this.paf;
			w.variable = this.variable;
			w.list_conditional = this.list_conditional;
			w.list_fixed = this.list_fixed;
			w.price_grossSales = this.price_grossSales;
			w.price_grossSales_foc = this.price_grossSales_foc;
			w.price_pocket = this.price_pocket;
			w.cost_AnDFOC = this.cost_AnDFOC;
			w.cost_AnPFOC = this.cost_AnPFOC;
			w.cost_AnDFOC_foc = this.cost_AnDFOC_foc;
			w.cost_AnPFOC_foc = this.cost_AnPFOC_foc;
			w.cost_AnDBudget = this.cost_AnDBudget;
			w.cost_COGS = this.cost_COGS;
			w.cost_COGS_foc = this.cost_COGS_foc;
			w.commonName = this.commonName;
			w.brandDescription = this.brandDescription;
			w.productCat = this.productCat;
			w.bottleSize = this.bottleSize;
			w.bottleSize_foc = this.bottleSize_foc;
			w.itemGroupId = this.itemGroupId;
			w.subBrandId = this.subBrandId;
			w.pg = this.pg;
			w.isActual = true;
			//w.actual = ag;
			//w.buildItemGroup(ag);
			w.buildHeader();
			//w.var_AnD_focBottle = this.var_AnD_focBottle;
			w.calculate_totalBottle(list_ar);
			w.calculate_foc();
			return w;
		}

		public void buildPnL() {
			buildItemGroup(this.variable, this.list_conditional, this.list_fixed);
			buildHeader();
			calculate_self();
		}

		private string contractedItemName {
			get; set;
		}
		private string subBrandName {
			get; set;
		}
		private decimal actualBottle {
			get; set;
		}
		private decimal targetBottle {
			get; set;
		}
		private decimal originalBottle {
			get; set;
		}
		private decimal achievedRatio {
			get; set;
		}
		private decimal salesValue {
			get; set;
		}
		private decimal outletPurchaseAmount {
			get; set;
		}
		private decimal var_AnD_cashCost {
			get; set;
		}
		private decimal var_AnD_cashCost_validInvoice {
			get; set;
		}
		private decimal var_AnD_focBottle {
			get; set;
		}
		private decimal var_AnD_focBottle_targetItemGroup{
			get; set;
		}
		private decimal var_AnD_focCost {
			get; set;
		}
		private decimal con_AnD_cashCost {
			get; set;
		}
		private decimal con_AnD_focBottle {
			get; set;
		}
		private decimal con_AnD_focCost {
			get; set;
		}
		private decimal totalAnD {
			get; set;
		}
		private decimal con_tradeAnP_cashCost {
			get; set;
		}
		private decimal con_tradeAnP_focBottle {
			get; set;
		}
		private decimal con_tradeAnP_focCost {
			get; set;
		}
		private decimal fix_tradeAnP_cashCost {
			get; set;
		}
		private decimal fix_tradeAnP_focBottle {
			get; set;
		}
		private decimal fix_tradeAnP_focCost {
			get; set;
		}
		private decimal fix_mktAnP_cashCost {
			get; set;
		}
		private decimal fix_mktAnP_focBottle {
			get; set;
		}
		private decimal fix_mktAnP_focCost {
			get; set;
		}
		private decimal pgCost {
			get; set;
		}
		private decimal totalAnP {
			get; set;
		}
		private decimal var_AnDperBottle {
			get; set;
		}
		private decimal shareOfSalesValue {
			get; set;
		}
		private decimal shareOfTradeAnP {
			get; set;
		}
		private decimal AnDfocBottle {
			get; set;
		}
		private decimal AnPfocBottle {
			get; set;
		}
		private decimal PnLBottle {
			get; set;
		}
		private decimal PnL9L {
			get; set;
		}
		private decimal grossSales {
			get; set;
		}
		private decimal salesValueT1 {
			get; set;
		}
		private decimal salesValueT2 {
			get; set;
		}
		private decimal salesValueOutletRebate {
			get; set;
		}
		private decimal var_AnD_outletSupport {
			get; set;
		}
		private decimal confix_AnD_outletSupport {
			get; set;
		}
		private decimal netSales {
			get; set;
		}
		private decimal COGS {
			get; set;
		}
		private decimal CM {
			get; set;
		}
		private decimal con_tradeAnP_outletSupport {
			get; set;
		}
		private decimal fix_tradeAnP_outletsupport {
			get; set;
		}
		private decimal tradeAnP_outletSupport {
			get; set;
		}
		private decimal marketVisit {
			get; set;
		}
		private decimal CATAP_ST {
			get; set;
		}
		private decimal fix_mktAnP {
			get; set;
		}
		private decimal CAAP_ST {
			get; set;
		}
		private decimal CM_NS {
			get; set;
		}
		private decimal CATAP_NS {
			get; set;
		}
		private decimal CAAP_NS {
			get; set;
		}
		private decimal NS_L {
			get; set;
		}
		private decimal var_investment {
			get; set;
		}
		private decimal con_investment {
			get; set;
		}
		private decimal fix_investment {
			get; set;
		}
		private decimal roi {
			get; set;
		}
		private decimal roi_channelAve {
			get; set;
		}
		private decimal CATAP_NS_channelAve {
			get; set;
		}
		private decimal investmentRatio {
			get; set;
		}
		private decimal investmentRatio_channelAve {
			get; set;
		}
		private decimal tradeAnP {
			get; set;
		}
		private decimal costPerL {
			get; set;
		}
		private decimal cmPerL {
			get; set;
		}
		private decimal AnP {
			get; set;
		}
		private decimal totalInvestment {
			get; set;
		}

		private set<string> set_isCash = new set<string>{'Cash', 'Cash & FOC'};
		private set<string> set_isFOC = new set<string>{'FOC', 'Cash & FOC'};
		private string string_AnD = 'A&D';
		private string string_tradeAnP = 'Trade A&P';
		private string string_mktAnP = 'MKT A&P';
		private string string_marketVisit = 'Market Visit';
		private string string_total = 'Total';

		private void buildItemGroup(ASI_HK_CRM_Pre_Approval_Form_Item__c variable, List<ASI_HK_CRM_Pre_Approval_Form_Item__c> conditionalList, List<ASI_HK_CRM_Pre_Approval_Form_Item__c> fixedList){
			if(variable != null && variable.Id != null){
				commonName = variable.ASI_CRM_Contracted_Item__r.ASI_CRM_Common_Name__c;
				brandDescription = variable.ASI_CRM_Contracted_Item__r.ASI_CRM_TW_Brand__r.ASI_MFM_Brand_Description__c;
				productCat = variable.ASI_CRM_Contracted_Item__r.ASI_CRM_Product_Category__c;
				bottleSize = variable.ASI_CRM_Contracted_Item__r.ASI_CRM_Size_ml__c != null ? variable.ASI_CRM_Contracted_Item__r.ASI_CRM_Size_ml__c : 0;
				//bottleSize_foc = variable.ASI_CRM_FOC_Item__r.ASI_CRM_Size_ml__c != null ? variable.ASI_CRM_FOC_Item__r.ASI_CRM_Size_ml__c : 0;
				bottleSize_foc = bottleSize;
				itemGroupId = variable.ASI_CRM_Contracted_Item__c;
				subBrandId = variable.ASI_CRM_Contracted_Item__r.ASI_MFM_Sub_brand__c;
			} else if (!conditionalList.isEmpty()){
				commonName = conditionalList[0].ASI_CRM_Expenses_Product__r.ASI_CRM_Common_Name__c;
				brandDescription = conditionalList[0].ASI_CRM_Expenses_Product__r.ASI_CRM_TW_Brand__r.ASI_MFM_Brand_Description__c;
				productCat = conditionalList[0].ASI_CRM_Expenses_Product__r.ASI_CRM_Product_Category__c;
				bottleSize = conditionalList[0].ASI_CRM_Expenses_Product__r.ASI_CRM_Size_ml__c != null ? conditionalList[0].ASI_CRM_Expenses_Product__r.ASI_CRM_Size_ml__c : 0;
				bottleSize_foc = bottleSize;
				itemGroupId = conditionalList[0].ASI_CRM_Expenses_Product__c;
				subBrandId = conditionalList[0].ASI_CRM_Expenses_Product__r.ASI_MFM_Sub_brand__c;
			} else if (!fixedList.isEmpty()){
				commonName = fixedList[0].ASI_CRM_Expenses_Product__r.ASI_CRM_Common_Name__c;
				brandDescription = fixedList[0].ASI_CRM_Expenses_Product__r.ASI_CRM_TW_Brand__r.ASI_MFM_Brand_Description__c;
				productCat = fixedList[0].ASI_CRM_Expenses_Product__r.ASI_CRM_Product_Category__c;
				bottleSize = fixedList[0].ASI_CRM_Expenses_Product__r.ASI_CRM_Size_ml__c != null ? fixedList[0].ASI_CRM_Expenses_Product__r.ASI_CRM_Size_ml__c : 0;
				bottleSize_foc = bottleSize;
				itemGroupId = fixedList[0].ASI_CRM_Expenses_Product__c;
				subBrandId = fixedList[0].ASI_CRM_Expenses_Product__r.ASI_MFM_Sub_brand__c;
			}
			
		}
		
		private void buildItemGroup(AggregateResult ar){
			commonName = string.valueOf(ar.get('commonName'));
			brandDescription = string.valueOf(ar.get('brandDescription'));
			productCat = string.valueOf(ar.get('productCat'));
			bottleSize = (Decimal)(ar.get('bottleSize')) != null ? (Decimal)(ar.get('bottleSize')) : 0;
			bottleSize_foc = bottleSize;
			itemGroupId = string.valueOf(ar.get('itemGroup'));
			subBrandId = string.valueOf(ar.get('subBrand'));
		}
		
		private void buildHeader() {
			contractedItemName = commonName;
			subBrandName = brandDescription;
		}

		private void buildHeader_total() {
			contractedItemName = string_total;
		}

		private void buildHeader_grouped(string t) {
			contractedItemName = t;
		}

		private void resetNumbers() {
			achievedRatio = 1;
			actualBottle = 0;
			targetBottle = 0;
			originalBottle = 0;
			salesValue = 0;
			outletPurchaseAmount = 0;
			var_AnD_cashCost = 0;
			var_AnD_cashCost_validInvoice = 0;
			var_AnD_focBottle = 0;
			var_AnD_focBottle_targetItemGroup = 0;
			var_AnD_focCost = 0;
			con_AnD_cashCost = 0;
			con_AnD_focBottle = 0;
			con_AnD_focCost = 0;
			totalAnD = 0;
			con_tradeAnP_cashCost = 0;
			con_tradeAnP_focBottle = 0;
			con_tradeAnP_focCost = 0;
			fix_tradeAnP_cashCost = 0;
			fix_tradeAnP_focBottle = 0;
			fix_tradeAnP_focCost = 0;
			fix_mktAnP_cashCost = 0;
			fix_mktAnP_focBottle = 0;
			fix_mktAnP_focCost = 0;
			pgCost = 0;
			totalAnP = 0;
			var_AnDperBottle = 0;
			shareOfSalesValue = 0;
			shareOfTradeAnP = 0;
			AnDfocBottle = 0;
			AnPfocBottle = 0;
			PnLBottle = 0;
			PnL9L = 0;
			grossSales = 0;
			salesValueT1 = 0;
			salesValueT2 = 0;
			salesValueOutletRebate = 0;
			var_AnD_outletSupport = 0;
			confix_AnD_outletSupport = 0;
			netSales = 0;
			COGS = 0;
			CM = 0;
			con_tradeAnP_outletSupport = 0;
			fix_tradeAnP_outletsupport = 0;
			tradeAnP_outletSupport = 0;
			marketVisit = 0;
			CATAP_ST = 0;
			fix_mktAnP = 0;
			CAAP_ST = 0;
			CM_NS = 0;
			CATAP_NS = 0;
			CAAP_NS = 0;
			NS_L = 0;
			var_investment = 0;
			con_investment = 0;
			fix_investment = 0;
			roi = 0;
			roi_channelAve = 0;
			CATAP_NS_channelAve = 0;
			investmentRatio = 0;
			investmentRatio_channelAve = 0;
			tradeAnP = 0;
			costPerL = 0;
			cmPerL = 0;
			AnP = 0;
			totalInvestment = 0;
			bottleSize = 0;
			bottleSize_foc = 0;
		}

		private void calculate_totalBottle(list<aggregateResult> list_ar){
			actualBottle = 0;
			for(aggregateResult ar : list_ar){
				actualBottle += (decimal)ar.get('qty');
			}
		}
		
		private void calculate_foc(){
			originalBottle = (variable.ASI_HK_CRM_Target_Volume_Qty__c != null ? variable.ASI_HK_CRM_Target_Volume_Qty__c : 0);
			targetBottle = isActual ?
						   //((decimal)actual.get('qty')) :
						   actualBottle :
						   originalBottle;
			if (set_isFOC.contains(variable.ASI_CRM_Cash_or_FOC__c)) {
				if (variable.ASI_HK_CRM_FOC_Buy_Bottle_Option_1__c != null) {
					var_AnD_focBottle_targetItemGroup = targetBottle *
							(variable.ASI_HK_CRM_FOC_Free_Bottle_Option_1__c !=
									 null ? variable.ASI_HK_CRM_FOC_Free_Bottle_Option_1__c : 0) /
							variable.ASI_HK_CRM_FOC_Buy_Bottle_Option_1__c ;
					var_AnD_focBottle_targetItemGroup = var_AnD_focBottle_targetItemGroup.round(System.RoundingMode.DOWN);
					
				}

			}
		}
		
		private void calculate_self() {
			originalBottle = (variable.ASI_HK_CRM_Target_Volume_Qty__c != null ? variable.ASI_HK_CRM_Target_Volume_Qty__c : 0);
			targetBottle = isActual ?
						   //((decimal)actual.get('qty')) :
						   actualBottle :
						   originalBottle;
			salesValue = targetBottle * price_grossSales * 1.05;
			outletPurchaseAmount = targetBottle * price_pocket * 1.05;

			if (set_isCash.contains(variable.ASI_CRM_Cash_or_FOC__c)) {
				var_AnD_cashCost = targetBottle * 
									(variable.ASI_CRM_Cash_Per_Bottle_w_VAT__c != null ? variable.ASI_CRM_Cash_Per_Bottle_w_VAT__c : 0) * 
									(-1);
				var_AnD_cashCost_validInvoice = var_AnD_cashCost / (paf.ASI_CRM_Valid_Invoice__c ? 1.05 : 1);
			}

			/*
			if (set_isFOC.contains(variable.ASI_CRM_Cash_or_FOC__c)) {
				if (variable.ASI_HK_CRM_FOC_Buy_Bottle_Option_1__c != null) {
					var_AnD_focBottle = targetBottle *
							(variable.ASI_HK_CRM_FOC_Free_Bottle_Option_1__c !=
									 null ? variable.ASI_HK_CRM_FOC_Free_Bottle_Option_1__c : 0) /
							variable.ASI_HK_CRM_FOC_Buy_Bottle_Option_1__c ;
					var_AnD_focBottle = var_AnD_focBottle.round(System.RoundingMode.DOWN);
					AnDfocBottle = var_AnD_focBottle;
				}

			}
			*/
			AnDfocBottle = var_AnD_focBottle;

			var_AnD_focCost = var_AnD_focBottle * (-1) * cost_AnDFOC_foc;

			for (ASI_HK_CRM_Pre_Approval_Form_Item__c i : list_conditional) {
				decimal cashAmountWithVAT = (i.ASI_CRM_Cash_Amounts_w_VAT__c != null ? i.ASI_CRM_Cash_Amounts_w_VAT__c : 0) * achievedRatio;
				decimal focVolume = (i.ASI_CRM_FOC_Volume__c != null ? i.ASI_CRM_FOC_Volume__c : 0) * achievedRatio;
				focVolume = focVolume.round(System.RoundingMode.DOWN);
				if (i.ASI_CRM_AD_or_AP__c == string_AnD) {
					con_AnD_cashCost += cashAmountWithVAT * (-1);
					con_AnD_focBottle += focVolume;
					con_AnD_focCost += focVolume * cost_AnDFOC * (-1);
					AnDfocBottle += focVolume;
					confix_AnD_outletSupport += focVolume * cost_AnDFOC * (-1);
				} else if (i.ASI_CRM_AD_or_AP__c == string_tradeAnP) {
					con_tradeAnP_cashCost += cashAmountWithVAT * (-1);
					con_tradeAnP_focBottle += focVolume;
					con_tradeAnP_focCost += focVolume * cost_AnDFOC * (-1);
					AnPfocBottle += focVolume;
					if (i.ASI_HK_CRM_Mechanic__r.Name != string_marketVisit) {
						con_tradeAnP_outletSupport += ((focVolume * cost_AnPFOC) + (cashAmountWithVAT / (paf.ASI_CRM_Valid_Invoice__c ? 1.05 : 1))) * (-1);
					}
				}

				if (i.ASI_HK_CRM_Mechanic__r.Name == string_marketVisit) {
					marketVisit += cashAmountWithVAT * (-1) / (paf.ASI_CRM_Valid_Invoice__c ? 1.05 : 1);
				}
			}

			for (ASI_HK_CRM_Pre_Approval_Form_Item__c i : list_fixed) {
				decimal cashAmountWithVAT =
						i.ASI_CRM_Cash_Amounts_w_VAT__c != null ? i.ASI_CRM_Cash_Amounts_w_VAT__c : 0;
				decimal focVolume = i.ASI_CRM_FOC_Volume__c != null ? i.ASI_CRM_FOC_Volume__c : 0;
				if (i.ASI_CRM_AD_or_AP__c == string_tradeAnP) {
					fix_tradeAnP_cashCost += cashAmountWithVAT * (-1);
					fix_tradeAnP_focBottle += focVolume;
					fix_tradeAnP_focCost += focVolume * cost_AnDFOC * (-1);
					AnPfocBottle += focVolume;
					if (i.ASI_HK_CRM_Mechanic__r.Name != string_marketVisit) {
						fix_tradeAnP_outletsupport += ((focVolume * cost_AnPFOC) + (cashAmountWithVAT / (paf.ASI_CRM_Valid_Invoice__c ? 1.05 : 1))) * (-1);
					}
				} else if (i.ASI_CRM_AD_or_AP__c == string_mktAnP) {
					fix_mktAnP_cashCost += cashAmountWithVAT * (-1);
					fix_mktAnP_focBottle += focVolume;
					fix_mktAnP_focCost += focVolume * cost_AnDFOC * (-1);
					fix_mktAnP += ((focVolume * cost_AnDFOC) + (cashAmountWithVAT / (paf.ASI_CRM_Valid_Invoice__c ? 1.05 : 1))) * (-1);
				} else if (i.ASI_CRM_AD_or_AP__c == string_AnD) {
					AnDfocBottle += focVolume;
					confix_AnD_outletSupport += focVolume * cost_AnDFOC * (-1);
				}

				if (i.ASI_HK_CRM_Mechanic__r.Name == string_marketVisit) {
					marketVisit += cashAmountWithVAT * (-1) / (paf.ASI_CRM_Valid_Invoice__c ? 1.05 : 1);
				}
			}

			totalAnD = var_AnD_cashCost + var_AnD_focCost + con_AnD_cashCost + con_AnD_focCost;
			//totalAnP = con_tradeAnP_cashCost + con_tradeAnP_focCost + fix_tradeAnP_cashCost + fix_tradeAnP_focCost + fix_mktAnP_cashCost + fix_mktAnP_focCost;

			if ((targetBottle + var_AnD_focBottle) != 0) {
				var_AnDperBottle = (var_AnD_cashCost + var_AnD_focCost) / (targetBottle + var_AnD_focBottle) /
						(paf.ASI_CRM_Valid_Invoice__c ? 1.05 : 1);
			}

			PnLBottle = targetBottle + AnDfocBottle;

			PnL9L = (targetBottle * bottleSize + AnDfocBottle * bottleSize_foc) / 9000;
			grossSales = (targetBottle * price_grossSales + AnDfocBottle * price_grossSales_foc);

			decimal T1percent =
					(paf.ASI_CRM_TW_T1_Contract_Rebate__c != null ? paf.ASI_CRM_TW_T1_Contract_Rebate__c : 0) / 100;
			decimal T2percent =
					(paf.ASI_CRM_TW_T2_Contract_Rebate__c != null ? paf.ASI_CRM_TW_T2_Contract_Rebate__c : 0) / 100;
			decimal outletRebatePercent =
					(paf.ASI_CRM_TW_Outlet_Contract_Rebate__c != null ? paf.ASI_CRM_TW_Outlet_Contract_Rebate__c : 0) /
					100;
			salesValueT1 = (-1) * price_grossSales * targetBottle * T1percent;
			salesValueT2 = (-1) * price_grossSales * targetBottle * T2percent;
			salesValueOutletRebate = (-1) * price_grossSales * targetBottle * outletRebatePercent;

			var_AnD_outletSupport = var_AnD_focCost + var_AnD_cashCost_validInvoice;

			netSales = grossSales + salesValueT1 + salesValueT2 + salesValueOutletRebate + var_AnD_outletSupport +
					confix_AnD_outletSupport;
			COGS = (-1) * (cost_COGS * targetBottle + cost_COGS_foc * AnDfocBottle);
			CM = netSales + COGS;


		}

		private void set_PG() {
			pgCost = (-1) * (pg.ASI_CRM_Sub_Total_hrs__c != null ? pg.ASI_CRM_Sub_Total_hrs__c : 0) *
					(pg.ASI_CRM_Cost_Hr_w_VAT__c != null ? pg.ASI_CRM_Cost_Hr_w_VAT__c : 0);

		}

		private void calculate_fromChild() {

			for (PnLDetailWrapper w : list_w) {
				targetBottle += w.targetBottle;
				salesValue += w.salesValue;
				outletPurchaseAmount += w.outletPurchaseAmount;
				var_AnD_cashCost += w.var_AnD_cashCost;
				var_AnD_cashCost_validInvoice += w.var_AnD_cashCost_validInvoice;
				var_AnD_focBottle += w.var_AnD_focBottle;
				var_AnD_focCost += w.var_AnD_focCost;
				con_AnD_cashCost += w.con_AnD_cashCost;
				con_AnD_focBottle += w.con_AnD_focBottle;
				con_AnD_focCost += w.con_AnD_focCost;
				totalAnD += w.totalAnD;
				con_tradeAnP_cashCost += w.con_tradeAnP_cashCost;
				con_tradeAnP_focBottle += w.con_tradeAnP_focBottle;
				con_tradeAnP_focCost += w.con_tradeAnP_focCost;
				fix_tradeAnP_cashCost += w.fix_tradeAnP_cashCost;
				fix_tradeAnP_focBottle += w.fix_tradeAnP_focBottle;
				fix_tradeAnP_focCost += w.fix_tradeAnP_focCost;
				fix_mktAnP_cashCost += w.fix_mktAnP_cashCost;
				fix_mktAnP_focBottle += w.fix_mktAnP_focBottle;
				fix_mktAnP_focCost += w.fix_mktAnP_focCost;
				pgCost += w.pgCost;
				totalAnP += w.totalAnP;
				var_AnDperBottle += w.var_AnDperBottle;
				shareOfSalesValue += w.shareOfSalesValue;
				shareOfTradeAnP += w.shareOfTradeAnP;
				AnDfocBottle += w.AnDfocBottle;
				AnPfocBottle += w.AnPfocBottle;
				PnLBottle += w.PnLBottle;
				PnL9L += w.PnL9L;
				grossSales += w.grossSales;
				salesValueT1 += w.salesValueT1;
				salesValueT2 += w.salesValueT2;
				salesValueOutletRebate += w.salesValueOutletRebate;
				var_AnD_outletSupport += w.var_AnD_outletSupport;
				confix_AnD_outletSupport += w.confix_AnD_outletSupport;
				netSales += w.netSales;
				COGS += w.COGS;
				CM += w.CM;
				con_tradeAnP_outletSupport += w.con_tradeAnP_outletSupport;
				fix_tradeAnP_outletsupport += w.fix_tradeAnP_outletsupport;
				tradeAnP_outletSupport += w.tradeAnP_outletSupport;
				marketVisit += w.marketVisit;
				fix_mktAnP += w.fix_mktAnP;
			}
			
			list_w = null;
		}

		public void setTotal(PnLDetailWrapper w) {
			this.w_total = w;
			calculate_fromTotal();
			calculate_selfFinal();
		}

		private void calculate_fromTotal() {
			if (w_total.salesValue != 0) {
				shareOfSalesValue = salesValue / w_total.salesValue;
			}
			pgCost = (-1) * (pg.ASI_CRM_Sub_Total_hrs__c != null ? pg.ASI_CRM_Sub_Total_hrs__c : 0) *
					(pg.ASI_CRM_Cost_Hr_w_VAT__c != null ? pg.ASI_CRM_Cost_Hr_w_VAT__c : 0) * shareOfSalesValue;

			if ((w_total.con_tradeAnP_cashCost + w_total.con_tradeAnP_focCost + w_total.fix_tradeAnP_cashCost +
			w_total.fix_tradeAnP_focCost) != 0) {
				shareOfTradeAnP =
						(con_tradeAnP_cashCost + con_tradeAnP_focCost + fix_tradeAnP_cashCost + fix_tradeAnP_focCost) /
						(w_total.con_tradeAnP_cashCost + w_total.con_tradeAnP_focCost + w_total.fix_tradeAnP_cashCost +
						w_total.fix_tradeAnP_focCost);
			}

		}

		private void calculate_selfFinal() {
			totalAnP = con_tradeAnP_cashCost + con_tradeAnP_focCost + fix_tradeAnP_cashCost + fix_tradeAnP_focCost +
					fix_mktAnP_cashCost + fix_mktAnP_focCost + pgCost;

			tradeAnP_outletSupport = con_tradeAnP_outletSupport + fix_tradeAnP_outletsupport;
			CATAP_ST = CM + con_tradeAnP_outletSupport + fix_tradeAnP_outletsupport + pgCost + marketVisit;
			CAAP_ST = CATAP_ST + fix_mktAnP;

			if (netSales != 0) {
				CM_NS = CM / netSales * 100;
				CATAP_NS = CATAP_ST / netSales * 100;
				CAAP_NS = CAAP_ST / netSales * 100;
			}
			if (PnL9L != 0) {
				NS_L = netSales / PnL9L / 9;
				costPerL = COGS / PnL9L / 9;
				cmPerL = CM / PnL9L / 9;
			}

			if ((totalAnD + totalAnP) != 0) {
				var_investment = (var_AnD_cashCost + var_AnD_focCost) / (totalAnD + totalAnP);
				con_investment = (con_AnD_cashCost + con_AnD_focCost + con_tradeAnP_cashCost + con_tradeAnP_focCost) /
						(totalAnD + totalAnP);
				fix_investment = (
				fix_tradeAnP_cashCost + fix_tradeAnP_focCost + fix_mktAnP_cashCost + fix_mktAnP_focCost + pgCost) /
						(totalAnD + totalAnP);
				
			}
			
			if((salesValueOutletRebate + var_AnD_outletSupport + confix_AnD_outletSupport + 
				con_tradeAnP_outletSupport + fix_tradeAnP_outletsupport + pgCost + marketVisit
				) != 0
			){
				roi = (-1) * /*(grossSales + salesValueT1 + salesValueT2 + COGS)*/ CM / 
						(salesValueOutletRebate + var_AnD_outletSupport + confix_AnD_outletSupport + 
						con_tradeAnP_outletSupport + fix_tradeAnP_outletsupport + pgCost + marketVisit
						);
			}

			roi_channelAve = paf.ASI_CRM_TW_Channel_Av__c;
			CATAP_NS_channelAve = paf.ASI_CRM_TW_Channel_Av_CATAP_NS__c;

			if (salesValue != 0) {
				investmentRatio = (-1) * (totalAnD + totalAnP) / salesValue;
			}
			investmentRatio_channelAve = paf.ASI_CRM_TW_Channel_Av_Investment_Ratio__c;

			tradeAnP = con_tradeAnP_outletSupport + fix_tradeAnP_outletsupport + pgCost + marketVisit;
			AnP = con_tradeAnP_outletSupport + fix_tradeAnP_outletsupport + pgCost + marketVisit + fix_mktAnP;
			
			totalInvestment = /*salesValueT1 + salesValueT2 +*/ salesValueOutletRebate + var_AnD_outletSupport + confix_AnD_outletSupport +
								con_tradeAnP_outletSupport + fix_tradeAnP_outletsupport + pgCost + marketVisit + 
								fix_mktAnP;

			roundToZero();
		}

		private void roundToZero() {
			if (targetBottle != null) targetBottle = targetBottle.setScale(0);
			if (salesValue != null) salesValue = salesValue.setScale(0);
			if (outletPurchaseAmount != null) outletPurchaseAmount = outletPurchaseAmount.setScale(0);
			if (var_AnD_cashCost != null) var_AnD_cashCost = var_AnD_cashCost.setScale(0);
			if (var_AnD_focBottle != null) var_AnD_focBottle = var_AnD_focBottle.setScale(0);
			if (var_AnD_focCost != null) var_AnD_focCost = var_AnD_focCost.setScale(0);
			if (con_AnD_cashCost != null) con_AnD_cashCost = con_AnD_cashCost.setScale(0);
			if (con_AnD_focBottle != null) con_AnD_focBottle = con_AnD_focBottle.setScale(0);
			if (con_AnD_focCost != null) con_AnD_focCost = con_AnD_focCost.setScale(0);
			if (totalAnD != null) totalAnD = totalAnD.setScale(0);
			if (con_tradeAnP_cashCost != null) con_tradeAnP_cashCost = con_tradeAnP_cashCost.setScale(0);
			if (con_tradeAnP_focBottle != null) con_tradeAnP_focBottle = con_tradeAnP_focBottle.setScale(0);
			if (con_tradeAnP_focCost != null) con_tradeAnP_focCost = con_tradeAnP_focCost.setScale(0);
			if (fix_tradeAnP_cashCost != null) fix_tradeAnP_cashCost = fix_tradeAnP_cashCost.setScale(0);
			if (fix_tradeAnP_focBottle != null) fix_tradeAnP_focBottle = fix_tradeAnP_focBottle.setScale(0);
			if (fix_tradeAnP_focCost != null) fix_tradeAnP_focCost = fix_tradeAnP_focCost.setScale(0);
			if (fix_mktAnP_cashCost != null) fix_mktAnP_cashCost = fix_mktAnP_cashCost.setScale(0);
			if (fix_mktAnP_focBottle != null) fix_mktAnP_focBottle = fix_mktAnP_focBottle.setScale(0);
			if (fix_mktAnP_focCost != null) fix_mktAnP_focCost = fix_mktAnP_focCost.setScale(0);
			if (pgCost != null) pgCost = pgCost.setScale(0);
			if (totalAnP != null) totalAnP = totalAnP.setScale(0);
			if (var_AnDperBottle != null) var_AnDperBottle = var_AnDperBottle.setScale(0);
			if (shareOfSalesValue != null) {
				shareOfSalesValue = (shareOfSalesValue * 100);
				shareOfSalesValue = shareOfSalesValue.setScale(2);
			}
			if (shareOfTradeAnP != null) {
				shareOfTradeAnP = (shareOfTradeAnP * 100);
				shareOfTradeAnP = shareOfTradeAnP.setScale(0);
			}
			if (AnDfocBottle != null) AnDfocBottle = AnDfocBottle.setScale(0);
			if (AnPfocBottle != null) AnPfocBottle = AnPfocBottle.setScale(0);
			if (PnLBottle != null) PnLBottle = PnLBottle.setScale(0);
			if (PnL9L != null) PnL9L = PnL9L.setScale(0);
			if (grossSales != null) grossSales = grossSales.setScale(0);
			if (salesValueT1 != null) salesValueT1 = salesValueT1.setScale(0);
			if (salesValueT2 != null) salesValueT2 = salesValueT2.setScale(0);
			if (salesValueOutletRebate != null) salesValueOutletRebate = salesValueOutletRebate.setScale(0);
			if (var_AnD_outletSupport != null) var_AnD_outletSupport = var_AnD_outletSupport.setScale(0);
			if (confix_AnD_outletSupport != null) confix_AnD_outletSupport = confix_AnD_outletSupport.setScale(0);
			if (netSales != null) netSales = netSales.setScale(0);
			if (COGS != null) COGS = COGS.setScale(0);
			if (CM != null) CM = CM.setScale(0);
			if (con_tradeAnP_outletSupport != null) con_tradeAnP_outletSupport = con_tradeAnP_outletSupport.setScale(0);
			if (fix_tradeAnP_outletsupport != null) fix_tradeAnP_outletsupport = fix_tradeAnP_outletsupport.setScale(0);
			if (marketVisit != null) marketVisit = marketVisit.setScale(0);
			if (CATAP_ST != null) CATAP_ST = CATAP_ST.setScale(0);
			if (fix_mktAnP != null) fix_mktAnP = fix_mktAnP.setScale(0);
			if (CAAP_ST != null) CAAP_ST = CAAP_ST.setScale(0);
			if (CM_NS != null) CM_NS = CM_NS.setScale(1);
			if (CATAP_NS != null) CATAP_NS = CATAP_NS.setScale(1);
			if (CAAP_NS != null) CAAP_NS = CAAP_NS.setScale(1);
			if (NS_L != null) NS_L = NS_L.setScale(1);
			if (var_investment != null) {
				var_investment = (var_investment * 100);
				var_investment = var_investment.setScale(2);
			}
			if (con_investment != null) {
				con_investment = (con_investment * 100);
				con_investment = con_investment.setScale(2);
			}
			if (fix_investment != null) {
				fix_investment = (fix_investment * 100);
				fix_investment = fix_investment.setScale(2);
			}
			if (roi != null) roi = roi.setScale(2);
			if (roi_channelAve != null) roi_channelAve = roi_channelAve.setScale(2);
			if (CATAP_NS_channelAve != null) CATAP_NS_channelAve = CATAP_NS_channelAve.setScale(2);
			if (investmentRatio != null)  {
				investmentRatio = (investmentRatio * 100);
				investmentRatio = investmentRatio.setScale(2);
			}
			if (investmentRatio_channelAve != null) investmentRatio_channelAve = investmentRatio_channelAve.setScale(2);
			if (tradeAnP != null) tradeAnP = tradeAnP.setScale(0);
			if (costPerL != null) costPerL = costPerL.setScale(0);
			if (cmPerL != null) cmPerL = cmPerL.setScale(0);
			if (AnP != null) AnP = AnP.setScale(0);
			if (totalInvestment != null) totalInvestment = totalInvestment.setScale(0);


		}
	}

	private final static list<string> CONTRACT_FIELD_LIST_SIMPLE = new list<string>{
			'Name', 'ASI_HK_CRM_PAF_Start_Date__c', 'ASI_HK_CRM_PAF_End_Date__c',
			'ASI_CRM_Channel__r.ASI_CRM_CN_Channel_Code__c', 'ASI_CRM_Sub_Channel__r.ASI_CRM_CN_Sub_Channel_Code__c',
			'ASI_CRM_Valid_Invoice__c', 'ASI_CRM_TW_T1_Contract_Rebate__c', 'ASI_CRM_TW_T2_Contract_Rebate__c',
			'ASI_CRM_TW_Outlet_Contract_Rebate__c', 'ASI_CRM_TW_Channel_Av__c', 'ASI_CRM_TW_Channel_Av_CATAP_NS__c',
			'ASI_CRM_TW_Channel_Av_Investment_Ratio__c', 'ASI_HK_CRM_PAF_Customer__c', 'ASI_CRM_TW_LY_PAF__c', 'ASI_CRM_BA_Comment__c',
			'ASI_HK_CRM_PAF_Customer__r.Name', 'ASI_CRM_Region__c', 'ASI_CRM_Sales_Potential__c',
			'ASI_CRM_Channel__r.Name', 'ASI_CRM_Sub_Channel__r.Name', 'ASI_CRM_Outlet_Type__c', 'owner.name', 'ASI_CRM_Commitment_No__c', 'ASI_CRM_Commitment_No__r.Name'
			};

	private final static List<String> MECHANICS_FIELD_LIST = new List<string>{
		'ASI_CRM_AD_or_AP__c',
		'ASI_CRM_Cash_Amounts_w_VAT__c',
		'ASI_CRM_Cash_or_FOC__c',
		'ASI_CRM_Cash_Per_Bottle_w_VAT__c',
		'ASI_CRM_Contracted_Item__c',
		'ASI_CRM_Contracted_Item__r.ASI_CRM_Common_Name__c',
		'ASI_CRM_Contracted_Item__r.ASI_CRM_Product_Category__c',
		'ASI_CRM_Contracted_Item__r.ASI_CRM_Product_Category_Sequence__c',
		'ASI_CRM_Contracted_Item__r.ASI_CRM_Size_ml__c',
		'ASI_CRM_Contracted_Item__r.ASI_CRM_TW_Brand__r.ASI_MFM_Brand_Description__c',
		'ASI_CRM_Contracted_Item__r.ASI_MFM_Sub_brand__c',
		'ASI_CRM_Cost_Hr_w_VAT__c',
		'ASI_CRM_Expenses_Product__c',
		'ASI_CRM_Expenses_Product__r.ASI_CRM_Product_Category_Sequence__c',
		'ASI_CRM_Expenses_Product__r.ASI_CRM_Common_Name__c',
		'ASI_CRM_Expenses_Product__r.ASI_CRM_TW_Brand__r.ASI_MFM_Brand_Description__c',
		'ASI_CRM_Expenses_Product__r.ASI_CRM_Product_Category__c',
		'ASI_CRM_Expenses_Product__r.ASI_CRM_Size_ml__c',
		'ASI_CRM_Expenses_Product__r.ASI_MFM_Sub_brand__c',
		'ASI_CRM_FOC_Item__c',
		'ASI_CRM_FOC_Item__r.ASI_CRM_Common_Name__c',
		'ASI_CRM_FOC_Item__r.ASI_CRM_Product_Category__c',
		'ASI_CRM_FOC_Item__r.ASI_CRM_Size_ml__c',
		'ASI_CRM_FOC_Item__r.ASI_CRM_TW_Brand__r.ASI_MFM_Brand_Description__c',
		'ASI_CRM_FOC_Volume__c',
		'ASI_CRM_Sub_Total_hrs__c',
		'ASI_HK_CRM_FOC_Buy_Bottle_Option_1__c',
		'ASI_HK_CRM_FOC_Free_Bottle_Option_1__c',
		'ASI_HK_CRM_Mechanic__r.Name',
		'ASI_HK_CRM_Target_Volume_Qty__c',
		'id',
		'RecordtypeId'
	};

	private final static List<String> PRICECOST_FIELD_LIST = new List<string>{
			'id', 'ASI_CRM_Applied_To__c', 'ASI_CRM_Item_Group__c', 'ASI_CRM_Type__c', 'ASI_CRM_Cost__c',
			'ASI_CRM_Price__c'
			};

	private final static string RTID_PAFLINE_VARIABLE = Global_RecordTypeCache.getRTId(
			'ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Variable_Investment');
	private final static string RTID_PAFLINE_CONDITIONAL = Global_RecordTypeCache.getRTId(
			'ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Conditional_Investment');
	private final static string RTID_PAFLINE_FIXED = Global_RecordTypeCache.getRTId(
			'ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Fixed_Investment');
	private final static string RTID_PAFLINE_PG = Global_RecordTypeCache.getRTId(
			'ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_PG_Costs');
	private final static string RTID_PRICECOST = Global_RecordTypeCache.getRTId(
			'ASI_CRM_MY_SKUPriceCost__cASI_CRM_TW_SKU_Price_Cost');
	private final static string RTID_PAFCUSTOMER = Global_RecordTypeCache.getRTId(
			'ASI_CRM_HK_Pre_Approval_Form_Customer__cASI_CRM_TW_Pre_Approval_Form_Customer');
	private final static string RTID_ACTUALOFFTAKE = Global_RecordTypeCache.getRTId(
			'ASI_TH_CRM_Actual_Offtake__cASI_CRM_TW_Actual_Offtake');
	private final static string RTID_COMPETITOR = Global_RecordTypeCache.getRTId(
			'ASI_CRM_CalculatedSalesVolume__cASI_CRM_TW_Capacity');
	private final static string RTID_PRODUCTCATEGORY = Global_RecordTypeCache.getRTId(
			'ASI_HK_CRM_Product_Category__cASI_CRM_TW_Product_Category');

	private final static string PRICECOST_TYPE_GROSSSALES = 'Gross Sales (List Price w/o VAT)';
	private final static string PRICECOST_TYPE_AnDFOC = 'A&D FOC Unit Cost';
	private final static string PRICECOST_TYPE_AnPFOC = 'A&P FOC Unit Cost';
	private final static string PRICECOST_TYPE_POCKET = 'Pocket Price';
	private final static string PRICECOST_TYPE_COGS = 'COGS-S/T';
	private final static string PRICECOST_TYPE_AnDBUDGET = 'A&D Budget (w/ VAT)';
	
	private final static string PERNOD_RICARD = 'Pernod Ricard';

	private final static List<String> PRICECOST_TYPE_LIST = new List<string>{
			PRICECOST_TYPE_GROSSSALES, PRICECOST_TYPE_AnDFOC, PRICECOST_TYPE_POCKET, PRICECOST_TYPE_COGS,
			PRICECOST_TYPE_AnDBUDGET, PRICECOST_TYPE_AnPFOC
			};

	private static final List<String> LIST_RTID_PAFLine = new List<string>{
			RTID_PAFLINE_VARIABLE,
			RTID_PAFLINE_CONDITIONAL,
			RTID_PAFLINE_FIXED,
			RTID_PAFLINE_PG
			};

	//JSON String for VF Page
	public String list_wrapper_outputForSales_json {
		get {
			for (PnLDetailWrapper pnLDetailWrapper : list_wrapper_outputForSales) {
				pnLDetailWrapper.paf = null;
				pnLDetailWrapper.variable = null;
				pnLDetailWrapper.list_w = null;
				pnLDetailWrapper.list_fixed = null;
				pnLDetailWrapper.list_conditional = null;
			}

			return toJsonString(list_wrapper_outputForSales);
		}
	}
	public String list_wrapper_detailPnL_json {
		get {
			for (PnLDetailWrapper pnLDetailWrapper : list_wrapper_detailPnL) {
				pnLDetailWrapper.paf = null;
				pnLDetailWrapper.variable = null;
				pnLDetailWrapper.list_w = null;
				pnLDetailWrapper.list_fixed = null;
				pnLDetailWrapper.list_conditional = null;
			}

			return toJsonString(list_wrapper_detailPnL);
		}
	}
	public String wrapper_TY_target_total_json {
		get {
			return toJsonString(wrapper_TY_target_total);
		}
	}
	public String wrapper_LY_actual_total_json {
		get {
			return toJsonString(wrapper_LY_actual_total);
		}
	}
	public String list_wrapper_dashboard_PnL_json {
		get {
			return toJsonString(list_wrapper_dashboard_PnL);
		}
	}

	public String map_wrapper_productCat_json {
		get {
			return toJsonString(map_productCat_type_wrapper);
		}
	}

	public String map_marketShare_json {
		get {
			return toJsonString(map_marketShare);
		}
	}

	public String map_marketShareDetail_json {
		get {
			return toJsonString(map_marketShareDetail);
		}
	}

	public String set_competitor_json {
		get {
			return toJsonString(set_competitor);
		}
	}

	public String BAComment {
		get; set;
	}
	public String pafNo {
		get; set;
	}
	public String outletName {
		get; set;
	}
	public String contractStartDate {
		get; set;
	}
	public String contractEndDate {
		get; set;
	}
	public String commitmentNo {
		get; set;
	}
	public String region {
		get; set;
	}
	public String outletGrade {
		get; set;
	}
	public String mIdentity {
		get; set;
	}
	public String channel {
		get; set;
	}
	public String subChannel {
		get; set;
	}
	public String outletType {
		get; set;
	}
	public String salesRep {
		get; set;
	}

	//All contract records
	public List<ASI_HK_CRM_Pre_Approval_Form__c> contractList {
		get; set;
	}
	public transient List<PnLDetailWrapper> list_wrapper_outputForSales;
	public transient List<PnLDetailWrapper> list_wrapper_detailPnL;
	public transient PnLDetailWrapper wrapper_TY_target_total;
	public transient PnLDetailWrapper wrapper_LY_actual_total;
	public transient List<PnLDetailWrapper> list_wrapper_dashboard_PnL;
	public transient Map<string, map<string, map<string, PnLDetailWrapper>>> map_productCat_type_wrapper;
	public transient Map<string, decimal> map_marketShare;
	public transient Map<string, map<string, integer>> map_marketShareDetail;
	public transient Set<string> set_competitor;


	//Execute the logic when contract id is setted by component
	public Boolean init() {

		contractList = retrieveContractList(pafId);
		map<String, string> map_pafId = new map<String, string>();
		ASI_HK_CRM_Pre_Approval_Form__c header;


		for (ASI_HK_CRM_Pre_Approval_Form__c paf : contractList) {
			map_pafId.put('TY', paf.Id);
			if (paf.ASI_CRM_TW_LY_PAF__c != null) {
				map_pafId.put('LY', paf.ASI_CRM_TW_LY_PAF__c);
			}

		}

		list<string> list_LYItemGroup = new list<string>();
		map<string, map<string, PnLDetailWrapper>> map_yearStr_PnLDetailWrapper =
				new map<string, map<string, PnLDetailWrapper>>();
		//Retrieve the contract records that need to be compared
		// use for loop here because it only contains 2 paf maximum
		for (string yearStr : map_pafId.keySet()) {
			map<string, PnLDetailWrapper> map_PnLDetailWrapper = new map<string, PnLDetailWrapper>();
			ASI_HK_CRM_Pre_Approval_Form_Item__c pg = new ASI_HK_CRM_Pre_Approval_Form_Item__c();
			string pid = map_pafId.get(yearStr);

			// only one paf would be retrieved
			ASI_HK_CRM_Pre_Approval_Form__c paf = retrieveContractWithChildList(pid);
			if (paf == null) continue;

			if (yearStr == 'TY') {
				header = paf;
				BAComment = paf.ASI_CRM_BA_Comment__c;
				pafNo = paf.Name;
				outletName = paf.ASI_HK_CRM_PAF_Customer__r.Name;
				contractStartDate = formatDate(paf.ASI_HK_CRM_PAF_Start_Date__c);
				contractEndDate = formatDate(paf.ASI_HK_CRM_PAF_End_Date__c);
				region = paf.ASI_CRM_Region__c;
				outletGrade = paf.ASI_CRM_Sales_Potential__c;
				channel = paf.ASI_CRM_Channel__r.Name;
				subChannel = paf.ASI_CRM_Sub_Channel__r.Name;
				outletType = paf.ASI_CRM_Outlet_Type__c;
				salesRep = paf.owner.name;
				commitmentNo = paf.ASI_CRM_Commitment_No__c != null ? paf.ASI_CRM_Commitment_No__r.Name : '';
			}
			paf.ASI_CRM_BA_Comment__c = null;

			set<string> set_itemGroupId = new set<string>();
			// handle paf lines
			for (ASI_HK_CRM_Pre_Approval_Form_Item__c pafl : paf.Pre_Approval_Form_Items_Link_To_PAF_Form__r) {
				if (pafl.recordtypeid == RTID_PAFLINE_PG) {
					pg = pafl;
				} else {
					string itemGroupId = pafl.recordtypeid ==
												 RTID_PAFLINE_VARIABLE ? pafl.ASI_CRM_Contracted_Item__c : pafl.ASI_CRM_Expenses_Product__c;
					string key = yearStr + '_target_' + itemGroupId;
					PnLDetailWrapper w =
					map_PnLDetailWrapper.containsKey(key) ? map_PnLDetailWrapper.get(key) : new PnLDetailWrapper(paf);
					if (pafl.recordtypeid == RTID_PAFLINE_VARIABLE) {
						w.variable = pafl;
						w.itemGroupId = itemGroupId;
						set_itemGroupId.add(itemGroupId);
						if(pafl.ASI_CRM_FOC_Item__c != null){
							set_itemGroupId.add(pafl.ASI_CRM_FOC_Item__c);
						}
					} else if (pafl.recordtypeid == RTID_PAFLINE_CONDITIONAL) {
						w.list_conditional.add(pafl);
					} else if (pafl.recordtypeid == RTID_PAFLINE_FIXED) {
						w.list_fixed.add(pafl);
					}
					map_PnLDetailWrapper.put(key, w);

				}
			}
			
			decimal originalBottle = 0;
			decimal actualBottle = 0;
			
			// calculate foc bottle
			map<string, decimal> map_itemGroupId_focBottle = new map<string, decimal>();
			map<string, string> map_itemGroupId_commonName = new map<string, string>();
			map<string, string> map_itemGroupId_BrandDescription = new map<string, string>();
			map<string, string> map_itemGroupId_productCat = new map<string, string>();
			map<string, decimal> map_itemGroupId_bottleSize = new map<string, decimal>();
			for(PnLDetailWrapper w : map_PnLDetailWrapper.values()){
				w.calculate_foc();
				originalBottle += w.originalBottle;
				string itemGroupId = w.variable.ASI_CRM_FOC_Item__c != null ? w.variable.ASI_CRM_FOC_Item__c : w.variable.ASI_CRM_Contracted_Item__c;
				decimal existingFocBottle = map_itemGroupId_focBottle.containsKey(itemGroupId) ? map_itemGroupId_focBottle.get(itemGroupId) : 0;
				map_itemGroupId_focBottle.put(itemGroupId, existingFocBottle + w.var_AnD_focBottle_targetItemGroup);
				map_itemGroupId_commonName.put(itemGroupId, w.variable.ASI_CRM_FOC_Item__c != null ? w.variable.ASI_CRM_FOC_Item__r.ASI_CRM_Common_Name__c : w.variable.ASI_CRM_Contracted_Item__r.ASI_CRM_Common_Name__c);
				map_itemGroupId_BrandDescription.put(itemGroupId, w.variable.ASI_CRM_FOC_Item__c != null ? w.variable.ASI_CRM_FOC_Item__r.ASI_CRM_TW_Brand__r.ASI_MFM_Brand_Description__c : w.variable.ASI_CRM_Contracted_Item__r.ASI_CRM_TW_Brand__r.ASI_MFM_Brand_Description__c);
				map_itemGroupId_productCat.put(itemGroupId, w.variable.ASI_CRM_FOC_Item__c != null ? w.variable.ASI_CRM_FOC_Item__r.ASI_CRM_Product_Category__c : w.variable.ASI_CRM_Contracted_Item__r.ASI_CRM_Product_Category__c);
				map_itemGroupId_bottleSize.put(itemGroupId, w.variable.ASI_CRM_FOC_Item__r.ASI_CRM_Size_ml__c != null ? w.variable.ASI_CRM_FOC_Item__r.ASI_CRM_Size_ml__c : 0);
				
			}
			system.debug(map_itemGroupId_focBottle);
			for(string itemGroupId : map_itemGroupId_focBottle.keySet()){
				string key = yearStr + '_target_' + itemGroupId;
				system.debug(key);
				decimal focBottle = map_itemGroupId_focBottle.get(itemGroupId);
				if(map_PnLDetailWrapper.containsKey(key)){
					map_PnLDetailWrapper.get(key).var_AnD_focBottle = focBottle;
				}else
				if(itemGroupId != null){
					PnLDetailWrapper w = new PnLDetailWrapper(paf);
					w.var_AnD_focBottle = focBottle;
					w.commonName = map_itemGroupId_commonName.get(itemGroupId);
					w.brandDescription = map_itemGroupId_BrandDescription.get(itemGroupId);
					w.productCat = map_itemGroupId_productCat.get(itemGroupId);
					w.bottleSize = map_itemGroupId_bottleSize.get(itemGroupId);
					w.bottleSize_foc = w.bottleSize;
					w.itemGroupId = itemGroupId;
					map_PnLDetailWrapper.put(key, w);
				}
			}

			// get correct price/cost
			date pafStartDate = paf.ASI_HK_CRM_PAF_Start_Date__c;
			date effectiveDate =
			pafStartDate.month() >= 7 ? Date.newinstance(pafStartDate.year(), 7, 1) : Date.newinstance(
							pafStartDate.year() - 1, 7, 1);
			string channelCode = paf.ASI_CRM_Channel__r.ASI_CRM_CN_Channel_Code__c;
			string subChannelCode = paf.ASI_CRM_Sub_Channel__r.ASI_CRM_CN_Sub_Channel_Code__c;
			list<string> list_channel = new list<string>();
			list_channel.add(channelCode);
			list_channel.add(subChannelCode);

			map_PnLDetailWrapper = populatePriceCost(map_PnLDetailWrapper, effectiveDate, set_itemGroupId, list_channel, 'target', channelCode, subChannelCode, yearStr);

			map<string, aggregateResult> map_actual = new map<string, aggregateResult>();
			map<string, list<aggregateResult>> map_actual_bySubBrand = new map<string, list<aggregateResult>>();
			map<string, boolean> map_actual_bySubBrand_used = new map<string, boolean>();
			map<string, PnLDetailWrapper> map_PnLDetailWrapper_actual = new map<string, PnLDetailWrapper>();
			if (yearStr == 'LY') {
				map_actual = retrieveActualOfftake(paf, set_itemGroupId);
				for(aggregateResult ar : map_actual.values()){
					string subBrandId = string.valueOf(ar.get('subBrand'));
					list<aggregateResult> list_ar = map_actual_bySubBrand.containsKey(subBrandId) ? map_actual_bySubBrand.get(subBrandId) : new list<aggregateResult>();
					list_ar.add(ar);
					map_actual_bySubBrand.put(subBrandId, list_ar);
					map_actual_bySubBrand_used.put(subBrandId, false);
					actualBottle += (decimal)ar.get('qty');
				}
			}

			decimal achievedRatio = actualBottle / originalBottle;
			achievedRatio = achievedRatio > 1 ? 1 : achievedRatio;
			
			map_itemGroupId_focBottle = new map<string, decimal>();
			for (PnLDetailWrapper w : map_PnLDetailWrapper.values()) {
				w.pg = pg;
				w.buildPnL();
				if (yearStr == 'LY') {
					
					/*
					if(map_actual.containsKey(w.variable.ASI_CRM_Contracted_Item__c)){
						PnLDetailWrapper w_actual = w.clone(map_actual.get(w.variable.ASI_CRM_Contracted_Item__c));
						string itemGroupId = w.variable.ASI_CRM_FOC_Item__c != null ? w.variable.ASI_CRM_FOC_Item__c : w.variable.ASI_CRM_Contracted_Item__c;
						decimal existingFocBottle = map_itemGroupId_focBottle.containsKey(itemGroupId) ? map_itemGroupId_focBottle.get(itemGroupId) : 0;
						map_itemGroupId_focBottle.put(itemGroupId, existingFocBottle + w_actual.var_AnD_focBottle_targetItemGroup);
						
						map_PnLDetailWrapper_actual.put(yearStr + '_actual_' + w.variable.ASI_CRM_Contracted_Item__c,
								w_actual);
						map_actual.remove(w.variable.ASI_CRM_Contracted_Item__c);
					}
					*/
					string subBrandId = w.subBrandId;
					if(map_actual_bySubBrand.containsKey(subBrandId) && !map_actual_bySubBrand_used.get(subBrandId)){
						List<aggregateResult> list_ar = map_actual_bySubBrand.get(subBrandId);
						PnLDetailWrapper w_actual = w.clone(list_ar);
						w_actual.achievedRatio = achievedRatio;
						string itemGroupId = w.variable.ASI_CRM_FOC_Item__c != null ? w.variable.ASI_CRM_FOC_Item__c : w.variable.ASI_CRM_Contracted_Item__c;
						decimal existingFocBottle = map_itemGroupId_focBottle.containsKey(itemGroupId) ? map_itemGroupId_focBottle.get(itemGroupId) : 0;
						map_itemGroupId_focBottle.put(itemGroupId, existingFocBottle + w_actual.var_AnD_focBottle_targetItemGroup);
						
						map_PnLDetailWrapper_actual.put(yearStr + '_actual_' + w.variable.ASI_CRM_Contracted_Item__c,
								w_actual);
						map_actual_bySubBrand_used.put(subBrandId, true);
						for(AggregateResult ar : list_ar){
							string itemGroupId1 = string.valueOf(ar.get('itemGroup'));
							map_actual.remove(itemGroupId1);
						}
						
					}
				}
			}
			// all addtional item groups to the wrapper
			if (yearStr == 'LY' && map_actual.keySet().size()>0) {
				
				List<PnLDetailWrapper> list_PnLDetailWrapper_actual_new = new List<PnLDetailWrapper>();
				for(string itemGroupId : map_actual.keySet()){
					aggregateResult ar = map_actual.get(itemGroupId);
					PnLDetailWrapper w_actual = new PnLDetailWrapper(paf, ar);
					w_actual.achievedRatio = achievedRatio;
					map_PnLDetailWrapper_actual.put(yearStr + '_actual_' + itemGroupId,
							w_actual);
					list_PnLDetailWrapper_actual_new.add(w_actual);
				}
				map_PnLDetailWrapper_actual = populatePriceCost(map_PnLDetailWrapper_actual, effectiveDate, map_actual.keySet(), list_channel, 'actual', channelCode, subChannelCode, yearStr);
				
			}
			if (yearStr == 'LY') {
				
				for(PnLDetailWrapper w : map_PnLDetailWrapper_actual.values()){
					string itemGroupId = w.itemGroupId;
					if(map_itemGroupId_focBottle.containsKey(itemGroupId)){
						w.var_AnD_focBottle = map_itemGroupId_focBottle.get(itemGroupId);
					}
					w.calculate_self();
				}
			}

			// target
			PnLDetailWrapper w_total = new PnLDetailWrapper(paf, map_PnLDetailWrapper.values(), pg);

			for (PnLDetailWrapper w : map_PnLDetailWrapper.values()) {
				w.setTotal(w_total);
			}
			map_PnLDetailWrapper.put(yearStr + '_target_total', w_total);

			map_yearStr_PnLDetailWrapper.put(yearStr + '_target', map_PnLDetailWrapper);

			// actual
			if (yearStr == 'LY') {
				PnLDetailWrapper w_total_actual = new PnLDetailWrapper(paf, map_PnLDetailWrapper_actual.values(), pg);

				for (PnLDetailWrapper w : map_PnLDetailWrapper_actual.values()) {
					w.setTotal(w_total_actual);
				}
				map_PnLDetailWrapper_actual.put(yearStr + '_actual_total', w_total_actual);

				map_yearStr_PnLDetailWrapper.put(yearStr + '_actual', map_PnLDetailWrapper_actual);
			}

		}

		// finally build the list of wrapper for VF page
		list_wrapper_outputForSales = new List<PnLDetailWrapper>();
		list_wrapper_detailPnL = new List<PnLDetailWrapper>();
		list_wrapper_dashboard_PnL = new List<PnLDetailWrapper>();
		map_productCat_type_wrapper = new Map<string, map<string, map<string, PnLDetailWrapper>>>();
		map_marketShare = new Map<string, decimal>();
		map_marketShareDetail = new Map<string, map<string, integer>>();
		Map<string, integer> map_PR = new Map<string, integer>();
		set<string> set_productCat = retrieveProductCategory();
		set_competitor = retrieveCompetitor();
		
		for(string pc : set_productCat){
			map_productCat_type_wrapper.put(pc, new map<string, map<string, PnLDetailWrapper>>());
		}

		if (map_yearStr_PnLDetailWrapper.containsKey('LY_target')) {
			PnLDetailWrapper w1 = map_yearStr_PnLDetailWrapper.get('LY_target').containsKey('LY_target_total') ? 
									map_yearStr_PnLDetailWrapper.get('LY_target').get('LY_target_total') :
									new PnLDetailWrapper();
			list_wrapper_dashboard_PnL.add(w1);
			
				
			for (PnLDetailWrapper w : map_yearStr_PnLDetailWrapper.get('LY_target').values()) {
				string productCat = w.productCat;
				if(!String.isNotBlank(productCat)) continue;
				string itemGroupName = w.commonName;
				map<string, map<string, PnLDetailWrapper>> map_type_wrapper = map_productCat_type_wrapper.containsKey(productCat) ? map_productCat_type_wrapper.get(productCat) : new map<string, map<string, PnLDetailWrapper>>();
				map<string, PnLDetailWrapper> map_w = map_type_wrapper.containsKey(itemGroupName) ? map_type_wrapper.get(itemGroupName) : new map<string, PnLDetailWrapper>();
				map_w.put('LY_target', w);
				map_type_wrapper.put(itemGroupName, map_w);
				if(String.isNotBlank(productCat)) map_productCat_type_wrapper.put(productCat, map_type_wrapper);
			}
		}else{
			PnLDetailWrapper w1 = new PnLDetailWrapper();
			list_wrapper_dashboard_PnL.add(w1);
		}
		if (map_yearStr_PnLDetailWrapper.containsKey('LY_actual')) {
			PnLDetailWrapper w1 = map_yearStr_PnLDetailWrapper.get('LY_actual').containsKey('LY_actual_total') ? 
									map_yearStr_PnLDetailWrapper.get('LY_actual').get('LY_actual_total') :
									new PnLDetailWrapper();
			list_wrapper_dashboard_PnL.add(w1);
			wrapper_LY_actual_total = w1;
				
			for (PnLDetailWrapper w : map_yearStr_PnLDetailWrapper.get('LY_actual').values()) {
				string productCat = w.productCat;
				if(!String.isNotBlank(productCat)) continue;
				string itemGroupName = w.commonName;
				map<string, map<string, PnLDetailWrapper>> map_type_wrapper = map_productCat_type_wrapper.containsKey(productCat) ? map_productCat_type_wrapper.get(productCat) : new map<string, map<string, PnLDetailWrapper>>();
				map<string, PnLDetailWrapper> map_w = map_type_wrapper.containsKey(itemGroupName) ? map_type_wrapper.get(itemGroupName) : new map<string, PnLDetailWrapper>();
				map_w.put('LY_actual', w);
				map_type_wrapper.put(itemGroupName, map_w);
				if(String.isNotBlank(productCat)) map_productCat_type_wrapper.put(productCat, map_type_wrapper);
				
				//list_wrapper_dashboard_PnL.add(w);
				//list_wrapper_detailPnL.add(w);
			}
		}else{
			PnLDetailWrapper w1 = new PnLDetailWrapper();
			list_wrapper_dashboard_PnL.add(w1);
			wrapper_LY_actual_total = w1;
		}
		if (map_yearStr_PnLDetailWrapper.containsKey('TY_target')) {
			list_wrapper_outputForSales.addall(map_yearStr_PnLDetailWrapper.get('TY_target').values());
			wrapper_TY_target_total = map_yearStr_PnLDetailWrapper.get('TY_target').get('TY_target_total');
			list_wrapper_dashboard_PnL.add(map_yearStr_PnLDetailWrapper.get('TY_target').get('TY_target_total'));

			map<string, list<PnLDetailWrapper>> map_subBrand_wrapper = new map<string, list<PnLDetailWrapper>>();
			for (PnLDetailWrapper w : map_yearStr_PnLDetailWrapper.get('TY_target').values()) {
				if(w.contractedItemName == 'Total') continue; 
				string subBrandName =
						w.brandDescription;
				list<PnLDetailWrapper> list_w =
				map_subBrand_wrapper.containsKey(subBrandName) ? map_subBrand_wrapper.get(
						subBrandName) : new list<PnLDetailWrapper>();
				list_w.add(w);
				map_subBrand_wrapper.put(subBrandName, list_w);
				
				string productCat = w.productCat;
				if(!String.isNotBlank(productCat)) continue;
				string itemGroupName = w.commonName;
				map<string, map<string, PnLDetailWrapper>> map_type_wrapper = map_productCat_type_wrapper.containsKey(productCat) ? map_productCat_type_wrapper.get(productCat) : new map<string, map<string, PnLDetailWrapper>>();
				map<string, PnLDetailWrapper> map_w = map_type_wrapper.containsKey(itemGroupName) ? map_type_wrapper.get(itemGroupName) : new map<string, PnLDetailWrapper>();
				map_w.put('TY_target', w);
				map_type_wrapper.put(itemGroupName, map_w);
				if(String.isNotBlank(productCat)) map_productCat_type_wrapper.put(productCat, map_type_wrapper);
				
				integer bottle_PR = map_PR.containsKey(productCat) ? map_PR.get(productCat) : 0;
				bottle_PR += integer.valueOf(w.targetBottle);
				map_PR.put(productCat, bottle_PR);
			}
			for (string subBrandName : map_subBrand_wrapper.keySet()) {
				list_wrapper_detailPnL.addall(map_subBrand_wrapper.get(subBrandName));
				list_wrapper_detailPnL.add(
						new PnLDetailWrapper(header, map_subBrand_wrapper.get(subBrandName), 'Subtotal'));
			}
			list_wrapper_detailPnL.add(wrapper_TY_target_total);
		}

		map<string, integer> map_competitor = retrieveCompetitorVolume(header);
		for(string pc : set_productCat){
			integer bottle_pr = map_PR.containsKey(pc) ? map_PR.get(pc) : 0;
			integer bottle_competitor = map_competitor.containsKey(pc) ? map_competitor.get(pc) : 0;
			integer bottle_total = bottle_pr + bottle_competitor;
			if(bottle_total != 0){
				decimal share = bottle_pr * 100 / bottle_total;
				share = share.setScale(2);
				map_marketShare.put(pc, share);
			}
		}
		
		map_marketShareDetail = retrieveCompetitorVolumeDetail(header);
		for(string pc : set_productCat){
			integer bottle_pr = map_PR.containsKey(pc) ? map_PR.get(pc) : 0;
			map<string, integer> map_result = map_marketShareDetail.containsKey(pc) ? map_marketShareDetail.get(pc) : new map<string, integer>();
			map_result.put(PERNOD_RICARD, bottle_pr);
			
		}
		
		system.debug(list_wrapper_outputForSales);
		system.debug(list_wrapper_detailPnL);
		system.debug(list_wrapper_dashboard_PnL);
		system.debug(map_productCat_type_wrapper);
		system.debug(map_marketShare);
		system.debug(map_marketShareDetail);

//		wrapper_LY_actual_list = list_wrapper_dashboard_PnL.get(0).list_w;//Todo change index to 1;
//		wrapper_TY_target_list = list_wrapper_dashboard_PnL.get(2).list_w;

		/*
		for (PnLDetailWrapper pnlDetail : list_wrapper_outputForSales) {
			pnlDetail.list_conditional = null;
			pnlDetail.list_fixed = null;
			pnlDetail.list_w = null;
		}

		for (PnLDetailWrapper pnlDetail : list_wrapper_dashboard_PnL) {
			if (pnlDetail == null) continue;
			pnlDetail.list_conditional = null;
			pnlDetail.list_fixed = null;
			pnlDetail.list_w = null;
		}
		*/
		//		list_wrapper_dashboard_PnL

		return true;
	}

	/*
	 * *************
	 * Data Retrievement Function
	 * *************
	 */
	private List<ASI_HK_CRM_Pre_Approval_Form__c> retrieveContractList(string paf) {
		String query = 'SELECT ' + genQueryFieldFromList(CONTRACT_FIELD_LIST_SIMPLE) + ', ' +
				'RecordType.DeveloperName ' +
				'FROM ASI_HK_CRM_Pre_Approval_Form__c ' +
				'WHERE id = : pafId';

		List<ASI_HK_CRM_Pre_Approval_Form__c> contractList =
				(List<ASI_HK_CRM_Pre_Approval_Form__c>) Database.query(query);
		return contractList.size() > 0 ? contractList : new List<ASI_HK_CRM_Pre_Approval_Form__c>();
	}

	private ASI_HK_CRM_Pre_Approval_Form__c retrieveContractWithChildList(string pid) {
		String query = 'SELECT ' + genQueryFieldFromList(CONTRACT_FIELD_LIST_SIMPLE) +
				', RecordType.DeveloperName, ' +
			//Retrieve Actual Offtake
				'(SELECT ' + genQueryFieldFromList(MECHANICS_FIELD_LIST) +
				' FROM Pre_Approval_Form_Items_Link_To_PAF_Form__r where recordtypeid in :LIST_RTID_PAFLine  ' +
				' Order by ASI_CRM_Contracted_Item__r.ASI_CRM_Product_Category_Sequence__c desc, ASI_CRM_Expenses_Product__r.ASI_CRM_Product_Category_Sequence__c desc' + 
				') ' + 
				'FROM ASI_HK_CRM_Pre_Approval_Form__c ' +
				'WHERE Id = : pid ';
		system.debug('1631==>'+query);
		List<ASI_HK_CRM_Pre_Approval_Form__c> contractList = (List<ASI_HK_CRM_Pre_Approval_Form__c>) Database.query(query);
        system.debug('1633==>'+contractList);
		return contractList.size() > 0 ? contractList[0] : null;
	}

	private List<ASI_CRM_MY_SKUPriceCost__c> retrievePriceCostList(Date effectiveDate,
																   set<string> set_itemGroupId,
																   list<string> list_channel) {
		string channels = '(\'' + String.join(list_channel, '\',\'') + '\')';
		String query = 'SELECT ' + genQueryFieldFromList(PRICECOST_FIELD_LIST) + ' ' +
				'FROM ASI_CRM_MY_SKUPriceCost__c ' +
				'WHERE recordtypeid = :RTID_PRICECOST ' +
				'AND ASI_CRM_Item_Group__c in :set_itemGroupId ' +
				'AND ASI_CRM_EffectiveDate__c = :effectiveDate ' +
				'AND ASI_CRM_Type__c in :PRICECOST_TYPE_LIST ' +
				'AND ASI_CRM_Applied_To__c includes ' + channels;

		system.debug(query);
		system.debug(effectiveDate);
		system.debug(set_itemGroupId);
		system.debug(RTID_PRICECOST);
		system.debug(PRICECOST_TYPE_LIST);
		
		List<ASI_CRM_MY_SKUPriceCost__c> contractList = (List<ASI_CRM_MY_SKUPriceCost__c>) Database.query(query);
		return contractList.size() > 0 ? contractList : new List<ASI_CRM_MY_SKUPriceCost__c>();
	}

	private map<string, aggregateResult> retrieveActualOfftake(ASI_HK_CRM_Pre_Approval_Form__c paf,
															   set<string> set_itemGroupId) {
		List<string> outletList = new List<string>();
		for (
				ASI_CRM_HK_Pre_Approval_Form_Customer__c c
				:
		[
				SELECT ASI_CRM_HK_Customer__c
				FROM ASI_CRM_HK_Pre_Approval_Form_Customer__c
				WHERE
				RecordTypeId =: RTID_PAFCUSTOMER AND
				ASI_CRM_HK_Pre_Approval_Form__c = :paf.Id
		]) {
			outletList.add(c.ASI_CRM_HK_Customer__c);
		}
		outletList.add(paf.ASI_HK_CRM_PAF_Customer__c);

		map<string, aggregateResult> map_actual = new map<string, aggregateResult>();
		for (
				aggregateResult a
				:
		[
				select 
					ASI_CRM_Item_Group__c itemGroup, 
					ASI_CRM_Item_Group__r.ASI_MFM_Sub_brand__c subBrand,
					ASI_CRM_Item_Group__r.ASI_MFM_Sub_brand__r.ASI_HK_CRM_Product_Category__r.Name productCat,
					ASI_CRM_Item_Group__r.ASI_CRM_Common_Name__c commonName,
					ASI_CRM_Item_Group__r.ASI_CRM_TW_Brand__r.ASI_MFM_Brand_Description__c brandDescription,
					sum(ASI_TH_CRM_Quantity__c) qty,
					avg(ASI_CRM_Item_Group__r.ASI_CRM_Size_ml__c) bottleSize
				from ASI_TH_CRM_Actual_Offtake__c where
				recordtypeid = :RTID_ACTUALOFFTAKE and
				ASI_TH_CRM_Outlet__c in :outletList and
				//ASI_CRM_Item_Group__c in :set_itemGroupId and 
				ASI_TH_CRM_Offtake_G_L_Date__c >= :paf.ASI_HK_CRM_PAF_Start_Date__c and ASI_TH_CRM_Offtake_G_L_Date__c <= :paf.ASI_HK_CRM_PAF_End_Date__c
				group by 
					ASI_CRM_Item_Group__c, 
					ASI_CRM_Item_Group__r.ASI_MFM_Sub_brand__c,
					ASI_CRM_Item_Group__r.ASI_MFM_Sub_brand__r.ASI_HK_CRM_Product_Category__r.Name,
					ASI_CRM_Item_Group__r.ASI_CRM_Common_Name__c,
					ASI_CRM_Item_Group__r.ASI_CRM_TW_Brand__r.ASI_MFM_Brand_Description__c
		]) {
			string itemGroup = String.valueOf(a.get('itemGroup'));
			map_actual.put(itemGroup, a);
		}

		return map_actual;
	}
	
	private map<string, integer> retrieveCompetitorVolume(ASI_HK_CRM_Pre_Approval_Form__c paf){
		map<string, integer> map_competitor = new map<string, integer>();
		for (
				aggregateResult a
				:
		[
				select sum(ASI_CRM_Bottle__c) bottle, ASI_CRM_ProductCategory__r.name productCat 
				from ASI_CRM_CalculatedSalesVolume__c where 
				recordtypeid = :RTID_COMPETITOR and 
				ASI_CRM_Pre_Approval_Form__c = :paf.id 
				group by ASI_CRM_ProductCategory__r.name
		]) {
			string productCat = String.valueOf(a.get('productCat'));
			map_competitor.put(productCat, integer.valueOf(a.get('bottle')));
		}

		return map_competitor;
	}

	private map<string, map<string, integer>> retrieveCompetitorVolumeDetail(ASI_HK_CRM_Pre_Approval_Form__c paf){
		map<string, map<string, integer>> map_competitor = new map<string, map<string, integer>>();
		for (
				aggregateResult a
				:
		[
				select sum(ASI_CRM_Bottle__c) bottle, ASI_CRM_ProductCategory__r.name productCat, ASI_CRM_Competitor__c competitor 
				from ASI_CRM_CalculatedSalesVolume__c where 
				recordtypeid = :RTID_COMPETITOR and 
				ASI_CRM_Pre_Approval_Form__c = :paf.id 
				group by ASI_CRM_ProductCategory__r.name, ASI_CRM_Competitor__c
		]) {
			string productCat = String.valueOf(a.get('productCat'));
			string competitor = String.valueOf(a.get('competitor'));
			map<string, integer> map_c1 = map_competitor.containsKey(productCat) ? map_competitor.get(productCat) : new map<string, integer>();
			map_c1.put(competitor, integer.valueOf(a.get('bottle')));
			map_competitor.put(productCat, map_c1);
		}

		return map_competitor;
	}

	private set<string> retrieveProductCategory(){
		set<string> set_pc = new set<string>();
		for (
				ASI_HK_CRM_Product_Category__c a
				:
		[
				select name, ASI_HK_CRM_Sequence__c
				from ASI_HK_CRM_Product_Category__c where 
				recordtypeid = :RTID_PRODUCTCATEGORY 
				order by ASI_HK_CRM_Sequence__c desc
		]) {
			set_pc.add(a.name);
		}

		return set_pc;
	}
	
	private set<string> retrieveCompetitor(){
		set<string> set_pc = new set<string>();
		
		Schema.DescribeFieldResult fieldResult = ASI_CRM_CalculatedSalesVolume__c.ASI_CRM_Competitor__c.getDescribe();
        List<Schema.PicklistEntry> listCompetitorsPickList = fieldResult.getPicklistValues();
		
		set_pc.add(PERNOD_RICARD);
		for(Schema.PicklistEntry competitor : listCompetitorsPickList){
			set_pc.add(competitor.getLabel());
		}

		return set_pc;
	}
	
	private map<string, PnLDetailWrapper> populatePriceCost(map<string, PnLDetailWrapper> map_PnLDetailWrapper, 
																	Date effectiveDate,
																   set<string> set_itemGroupId,
																   list<string> list_channel, 
																   string type, 
																   string channelCode, 
																   string subChannelCode, 
																   string yearStr){
		
		/*
		for (ASI_CRM_MY_SKUPriceCost__c pc : retrievePriceCostList(effectiveDate, set_itemGroupId, list_channel)) {
			string itemGroupId = pc.ASI_CRM_Item_Group__c;
			string key = yearStr + '_' + type + '_' + itemGroupId;
			if (map_PnLDetailWrapper.containsKey(key)) {
				PnLDetailWrapper w = map_PnLDetailWrapper.get(key);
				if (pc.ASI_CRM_Type__c == PRICECOST_TYPE_GROSSSALES) {
					if (pc.ASI_CRM_Applied_To__c.contains(subChannelCode) ||
							(pc.ASI_CRM_Applied_To__c.contains(channelCode) && w.price_grossSales == 0)
					) {
						w.price_grossSales = pc.ASI_CRM_Price__c;
					}
				} else if (pc.ASI_CRM_Type__c == PRICECOST_TYPE_POCKET) {
					if (pc.ASI_CRM_Applied_To__c.contains(subChannelCode) ||
							(pc.ASI_CRM_Applied_To__c.contains(channelCode) && w.price_pocket == 0)
					) {
						w.price_pocket = pc.ASI_CRM_Price__c;
					}
				} else if (pc.ASI_CRM_Type__c == PRICECOST_TYPE_AnDFOC) {
					if (pc.ASI_CRM_Applied_To__c.contains(subChannelCode) ||
							(pc.ASI_CRM_Applied_To__c.contains(channelCode) && w.cost_AnDFOC == 0)
					) {
						w.cost_AnDFOC = pc.ASI_CRM_Cost__c;
					}
				} else if (pc.ASI_CRM_Type__c == PRICECOST_TYPE_AnPFOC) {
					if (pc.ASI_CRM_Applied_To__c.contains(subChannelCode) ||
							(pc.ASI_CRM_Applied_To__c.contains(channelCode) && w.cost_AnPFOC == 0)
					) {
						w.cost_AnPFOC = pc.ASI_CRM_Cost__c;
					}
				} else if (pc.ASI_CRM_Type__c == PRICECOST_TYPE_AnDBUDGET) {
					if (pc.ASI_CRM_Applied_To__c.contains(subChannelCode) ||
							(pc.ASI_CRM_Applied_To__c.contains(channelCode) && w.cost_AnDBudget == 0)
					) {
						w.cost_AnDBudget = pc.ASI_CRM_Cost__c;
					}
				} else if (pc.ASI_CRM_Type__c == PRICECOST_TYPE_COGS) {
					if (pc.ASI_CRM_Applied_To__c.contains(subChannelCode) ||
							(pc.ASI_CRM_Applied_To__c.contains(channelCode) && w.cost_COGS == 0)
					) {
						w.cost_COGS = pc.ASI_CRM_Cost__c;
					}
				}
				map_PnLDetailWrapper.put(key, w);
			}
		}
		*/
		map<string, map<string, ASI_CRM_MY_SKUPriceCost__c>> map_itemGroupId_priceCost = new map<string, map<string, ASI_CRM_MY_SKUPriceCost__c>>();
		for (ASI_CRM_MY_SKUPriceCost__c pc : retrievePriceCostList(effectiveDate, set_itemGroupId, list_channel)) {
			string itemGroupId = pc.ASI_CRM_Item_Group__c;
			map<string, ASI_CRM_MY_SKUPriceCost__c> map_priceCost = map_itemGroupId_priceCost.containsKey(itemGroupId) ? map_itemGroupId_priceCost.get(itemGroupId) : new map<string, ASI_CRM_MY_SKUPriceCost__c>();
			
			if (pc.ASI_CRM_Type__c == PRICECOST_TYPE_GROSSSALES) {
				if (pc.ASI_CRM_Applied_To__c.contains(subChannelCode) ||
						(pc.ASI_CRM_Applied_To__c.contains(channelCode) && !map_priceCost.containsKey(PRICECOST_TYPE_GROSSSALES))
				) {
					map_priceCost.put(PRICECOST_TYPE_GROSSSALES, pc);
				}
			} else if (pc.ASI_CRM_Type__c == PRICECOST_TYPE_POCKET) {
				if (pc.ASI_CRM_Applied_To__c.contains(subChannelCode) ||
						(pc.ASI_CRM_Applied_To__c.contains(channelCode) && !map_priceCost.containsKey(PRICECOST_TYPE_POCKET))
				) {
					map_priceCost.put(PRICECOST_TYPE_POCKET, pc);
				}
			} else if (pc.ASI_CRM_Type__c == PRICECOST_TYPE_AnDFOC) {
				if (pc.ASI_CRM_Applied_To__c.contains(subChannelCode) ||
						(pc.ASI_CRM_Applied_To__c.contains(channelCode) && !map_priceCost.containsKey(PRICECOST_TYPE_AnDFOC))
				) {
					map_priceCost.put(PRICECOST_TYPE_AnDFOC, pc);
				}
			} else if (pc.ASI_CRM_Type__c == PRICECOST_TYPE_AnPFOC) {
				if (pc.ASI_CRM_Applied_To__c.contains(subChannelCode) ||
						(pc.ASI_CRM_Applied_To__c.contains(channelCode) && !map_priceCost.containsKey(PRICECOST_TYPE_AnPFOC))
				) {
					map_priceCost.put(PRICECOST_TYPE_AnPFOC, pc);
				}
			} else if (pc.ASI_CRM_Type__c == PRICECOST_TYPE_AnDBUDGET) {
				if (pc.ASI_CRM_Applied_To__c.contains(subChannelCode) ||
						(pc.ASI_CRM_Applied_To__c.contains(channelCode) && !map_priceCost.containsKey(PRICECOST_TYPE_AnDBUDGET))
				) {
					map_priceCost.put(PRICECOST_TYPE_AnDBUDGET, pc);
				}
			} else if (pc.ASI_CRM_Type__c == PRICECOST_TYPE_COGS) {
				if (pc.ASI_CRM_Applied_To__c.contains(subChannelCode) ||
						(pc.ASI_CRM_Applied_To__c.contains(channelCode) && !map_priceCost.containsKey(PRICECOST_TYPE_COGS))
				) {
					map_priceCost.put(PRICECOST_TYPE_COGS, pc);
				}
			}
			
			map_itemGroupId_priceCost.put(itemGroupId, map_priceCost);
		}
		for(PnLDetailWrapper w : map_PnLDetailWrapper.values()){
			//string itemGroupId = w.variable.ASI_CRM_Contracted_Item__c;
			string itemGroupId = w.itemGroupId;
			if(map_itemGroupId_priceCost.containsKey(itemGroupId)){
				map<string, ASI_CRM_MY_SKUPriceCost__c> map_priceCost = map_itemGroupId_priceCost.get(itemGroupId);
				if(map_priceCost.containsKey(PRICECOST_TYPE_GROSSSALES)){
					ASI_CRM_MY_SKUPriceCost__c pc = map_priceCost.get(PRICECOST_TYPE_GROSSSALES);
					w.price_grossSales = pc.ASI_CRM_Price__c;
					w.price_grossSales_foc = pc.ASI_CRM_Price__c;
				}
				if(map_priceCost.containsKey(PRICECOST_TYPE_POCKET)){
					ASI_CRM_MY_SKUPriceCost__c pc = map_priceCost.get(PRICECOST_TYPE_POCKET);
					w.price_pocket = pc.ASI_CRM_Price__c;
				}
				if(map_priceCost.containsKey(PRICECOST_TYPE_AnDBUDGET)){
					ASI_CRM_MY_SKUPriceCost__c pc = map_priceCost.get(PRICECOST_TYPE_AnDBUDGET);
					w.cost_AnDBudget = pc.ASI_CRM_Cost__c;
				}
				if(map_priceCost.containsKey(PRICECOST_TYPE_COGS)){
					ASI_CRM_MY_SKUPriceCost__c pc = map_priceCost.get(PRICECOST_TYPE_COGS);
					w.cost_COGS = pc.ASI_CRM_Cost__c;
					w.cost_COGS_foc = pc.ASI_CRM_Cost__c;
				}
				if(map_priceCost.containsKey(PRICECOST_TYPE_AnDFOC)){
					ASI_CRM_MY_SKUPriceCost__c pc = map_priceCost.get(PRICECOST_TYPE_AnDFOC);
					w.cost_AnDFOC = pc.ASI_CRM_Cost__c;
					w.cost_AnDFOC_foc = pc.ASI_CRM_Cost__c;
				}
				if(map_priceCost.containsKey(PRICECOST_TYPE_AnPFOC)){
					ASI_CRM_MY_SKUPriceCost__c pc = map_priceCost.get(PRICECOST_TYPE_AnPFOC);
					w.cost_AnPFOC = pc.ASI_CRM_Cost__c;
					w.cost_AnPFOC_foc = pc.ASI_CRM_Cost__c;
				}
			}
			/*
			string itemGroupId_foc = w.variable.ASI_CRM_FOC_Item__c != null ? w.variable.ASI_CRM_FOC_Item__c : w.variable.ASI_CRM_Contracted_Item__c;
			if(map_itemGroupId_priceCost.containsKey(itemGroupId_foc)){
				map<string, ASI_CRM_MY_SKUPriceCost__c> map_priceCost = map_itemGroupId_priceCost.get(itemGroupId_foc);
				if(map_priceCost.containsKey(PRICECOST_TYPE_GROSSSALES)){
					ASI_CRM_MY_SKUPriceCost__c pc = map_priceCost.get(PRICECOST_TYPE_GROSSSALES);
					w.price_grossSales_foc = pc.ASI_CRM_Price__c;
				}
				if(map_priceCost.containsKey(PRICECOST_TYPE_AnDFOC)){
					ASI_CRM_MY_SKUPriceCost__c pc = map_priceCost.get(PRICECOST_TYPE_AnDFOC);
					w.cost_AnDFOC_foc = pc.ASI_CRM_Cost__c;
				}
				if(map_priceCost.containsKey(PRICECOST_TYPE_AnPFOC)){
					ASI_CRM_MY_SKUPriceCost__c pc = map_priceCost.get(PRICECOST_TYPE_AnPFOC);
					w.cost_AnPFOC_foc = pc.ASI_CRM_Cost__c;
				}
				if(map_priceCost.containsKey(PRICECOST_TYPE_COGS)){
					ASI_CRM_MY_SKUPriceCost__c pc = map_priceCost.get(PRICECOST_TYPE_COGS);
					w.cost_COGS_foc = pc.ASI_CRM_Cost__c;
				}
			}
			*/
		}
			
		return map_PnLDetailWrapper;
	}

	/*
	 * *************
	 * Tools Function
	 * *************
	 */
	private String genQueryField(Map<String, Schema.SObjectField> fieldMap) {
		String queryField = '';
		for (String fields : fieldMap.keySet()) {
			queryField += fields + ',';
		}
		return queryField.subString(0, queryField.length() - 1);
	}

	private String genQueryFieldFromList(list<string> fieldList) {
		return String.join(fieldList, ',');
	}

	private String toJsonString(Object obj) {
		return System.JSON.serialize(obj);
	}

	private List<Object> fromJsonString(String jsonString, System.Type apexType) {
		if (String.isBlank(jsonString)) {
			return null;
		}
		return (List<Object>) System.JSON.deserialize(jsonString, apexType);
	}

	private static String formatDate(date d){
		if(d == null) return ''; 
		Datetime dt = d;
		return dt.format('yyyy-MM-dd');
	}
	
}