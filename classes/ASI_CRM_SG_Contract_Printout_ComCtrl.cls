/*********************************************************************************
 * Name: ASI_CRM_SG_Contract_Printout_ComCtrl
 * Description: Controller class for ASI_CRM_SG_Contract_Printout_Commpoent
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 28/03/2017       Hugo Cheung             Created          
*/
global class ASI_CRM_SG_Contract_Printout_ComCtrl {
    
    //Wrapper Class for storing all section
    public class SectionWrapper {
        public String name                                {get; set;}
        public String title                               {get; set;}
        public String content                             {get; set;}
        public String content_original                    {get; set;}
        public String displayNumber                       {get; set;}
        public Integer sortingNumber                      {get; set;}
        public String type                                {get; set;}
        public String sectionNumber                       {get; set;}
        public Boolean indexMerge                         {get; set;}
        public Map<decimal, SectionWrapper> subSectionMap {get; set;}
        public Boolean hasSubSection                      {get; set;}
        public Boolean isShow                             {get; set;}
        
        public SectionWrapper(String name, String title, String content, String displayNumber, Integer sortingNumber, String type, String sectionNumber, String indexMerge,
                              Map<decimal, SectionWrapper> subSectionMap) {
            this.name          = name;
            this.title         = title;
            this.content       = content != null ? content.trim() : null;
			this.content_original = content != null ? content.trim() : null;
            this.displayNumber = displayNumber;
            this.sortingNumber = sortingNumber;
            this.sectionNumber = sectionNumber;
            this.indexMerge    = indexMerge == 'Y' ? true : false;
            this.type          = type;
            this.subSectionMap = subSectionMap;
            
            if(subSectionMap == null || subSectionMap.size() == 0) {
                hasSubSection = false; 
            } else {
              hasSubSection = true;
            }
            
            isShow = true;
        }
    }
  
    public class WholesalerWrapper {
        public Integer index                               {get; set;}
        public ASI_CRM_AccountsAdditionalField__c customer {get; set;}
        public Boolean isSelected                          {get; set;}
        public String combinedAddress                      {get; set;}
        
        public WholesalerWrapper(Integer index, ASI_CRM_AccountsAdditionalField__c customer, String combinedAddress) {
            this.index           = index;
            this.customer        = customer;
            this.combinedAddress = combinedAddress;
            
            this.isSelected = true;
        }
    }
	
	public class EditedWrapper {
		public SectionWrapper sectionInfo {get; set;}
		public string typeOfChange {get; set;}
		public EditedWrapper (SectionWrapper sectionInfo, string typeOfChange){
			this.sectionInfo = sectionInfo;
			this.typeOfChange = typeOfChange;
		}
	}
    
    //Parameter for converting number to word format
    private final static String[] to_19 = new String[] { 
        'zero', 'one',  'two', 'three', 'four',  'five',  'six',  'seven', 'eight', 'nine', 'ten',  
        'eleven', 'twelve', 'thirteen', 'fourteen', 'fifteen', 'sixteen', 'seventeen', 'eighteen', 'nineteen'
    }; 
    
    private final static String[] tens = new String[] {
        'twenty', 'thirty', 'forty', 'fifty', 'sixty', 'seventy', 'eighty', 'ninety'
    };
    
    private final static map<string, string> monthInEnglish = new map<string, string> {
        '1'  => 'January',
        '2'  => 'February',
        '3'  => 'March',
        '4'  => 'April',
        '5'  => 'May',
        '6'  => 'June',
        '7'  => 'July',
        '8'  => 'August',
        '9'  => 'September',
        '10' => 'October',
        '11' => 'November',
        '12' => 'December'
    };
    
    private final static map<integer, string> daySuperscript = new map<integer, string> {
        1  => 'st',
        2  => 'nd',
        3  => 'rd',
        4  => 'th',
        5  => 'th',
        6  => 'th',
        7  => 'th',
        8  => 'th',
        9  => 'th',
        10 => 'th',
        11 => 'th',
        12 => 'th',
        13 => 'th',
        14 => 'th',
        15 => 'th',
        16 => 'th',
        17 => 'th',
        18 => 'th',
        19 => 'th',
        20 => 'th',
        21 => 'st',
        22 => 'nd',
        23 => 'rd',
        24 => 'th',
        25 => 'th',
        26 => 'th',
        27 => 'th',
        28 => 'th',
        29 => 'th',
        30 => 'th',
        31 => 'st'
    };
    
    //XML file static resource name
    private final static String XML_Static_Resource_Name = 'ASI_CRM_SG_Contract_Printout_Template';
    
    //Field Map
    private final static Map<String, Schema.SObjectField> CONTRACT_PRINTOUT_FIELD_MAP = Schema.SObjectType.ASI_CRM_Contract_Printout_Setting__c.fields.getMap();
    private final static Map<String, Schema.SObjectField> CONTRACT_FIELD_MAP          = Schema.SObjectType.ASI_TH_CRM_Contract__c.fields.getMap();
    private final static Map<String, Schema.SObjectField> CONTRACT_TARGET_FIELD_MAP   = Schema.SObjectType.ASI_CRM_ContractTarget__c.fields.getMap();
    private final static Map<String, Schema.SObjectField> CUSTOMER_FIELD_MAP          = Schema.SObjectType.ASI_CRM_AccountsAdditionalField__c.fields.getMap();
    private final static Map<String, Schema.SObjectField> FOC_HEADER_FIELD_MAP        = Schema.SObjectType.ASI_FOC_Free_Goods_Request__c.fields.getMap();
    private final static Map<String, Schema.SObjectField> PAYMENT_SCHEDULE_FIELD_MAP  = Schema.SObjectType.ASI_CRM_Payment_Schedule__c.fields.getMap();
    
    //Record Type API Name
    private final static String CUSTOMER_RECORD_TYPE_API_NAME = 'ASI_CRM_SG_Wholesaler';
	private static final String CONTRACTTARGET_RECORD_TYPE = 'ASI_CRM_SG_Contract_Target';
	private static final String PAYMENTSCHEDULE_RECORD_TYPE = 'ASI_CRM_SG_Payment_Schedule';
	private static final String CONTRACTOUTLET_RECORD_TYPE = 'ASI_CRM_SG_Contract_Outlet';

    
    //Today Date
    private Date todayDate               {get; set;}
    private Integer todayDay             {get; set;}
    private String todayDaySuperScript   {get; set;}
    private Integer todayMonth           {get; set;}
    private String todayMonth_english    {get; set;}
    private Integer todayYear            {get; set;}
    
    //Print out variable
    private String outletAddress        {get; set;}
    private String contractStartDate    {get; set;}
    private String contractPeriodInStr  {get; set;}
    private Integer contractPeriodInNum {get; set;}
    private Decimal contractPeriodInNum_decimal {get; set;}
    
    private Decimal zeroCashSponsorship               {get; set;}
    private Decimal zeroCashSponsorshipUpfrontPayment {get; set;}
    private Decimal zeroCashSponsorshipMonth          {get; set;}
    
    private Decimal zeroContractSponsorship               {get; set;}
    private Decimal zeroContractSponsorshipUpfrontPayment {get; set;}
    private Decimal zeroContractSponsorshipMonth          {get; set;}
    
    private Decimal totalCashSponsorship     {get; set;}
    public Decimal totalContractSponsorship {get; set;}
    public Decimal totalContractSponsorshipWSOT {get; set;}
    
    private Decimal totalSGEvents                {get; set;}
    private Decimal totalSignagesAdvertisingSpot {get; set;}
    private Decimal totalAdvertisingSpot         {get; set;}
    private Decimal totalProductBrandingDisplay  {get; set;}
    private Decimal totalTradeIncentiveTrips     {get; set;}
    private Decimal totalAdhocPromotions         {get; set;}
    private Decimal totalAPMonetarySponsorship   {get; set;}
    private Decimal totalAPGoodInKindSponsorship {get; set;}
    
    //Section Contract Parameter
    public Boolean showTradeDealSection                 {get; set;}
    private Boolean showPriceRebateSection               {get; set;}
    private Boolean showContractTargetSponsorshipSection {get; set;}
    private Boolean showAPSponsorshipSection             {get; set;}
    private Boolean showAPSponsorshipCashSection         {get; set;}
    private Boolean showAPSponsorshipContractSection     {get; set;}
    private Boolean showManagementIncentiveSection       {get; set;}
    private Boolean showAPGIKEventSection       		 {get; set;}
    private Boolean showAPGIKAdvertisingSpotSection      {get; set;}
    private Boolean showAPGIKAnniversarySection       	 {get; set;}
    private Boolean showAPSponsorshipCashSection_byUserSelection         {get; set;}
    private Boolean showAPSponsorshipContractSection_byUserSelection     {get; set;}
    
    private Boolean showContractTargetCashSponsorshipSchedule     {get; set;}
    private Boolean showContractTargetContractSponsorshipSchedule {get; set;}
    
    //XML Data
    private Map<decimal, SectionWrapper> headerSectionMap   {get; set;}
    private Map<decimal, SectionWrapper> bodySectionMap     {get; set;}
    private Map<decimal, SectionWrapper> scheduleSectionMap {get; set;}
    private Map<decimal, SectionWrapper> appendixSectionMap {get; set;}

    //Saved Contract Printout Template
    private List<ASI_CRM_Contract_Printout_Setting__c> contractPrintoutSettingList         {get; set;}
    private Map<String, ASI_CRM_Contract_Printout_Setting__c> contractPrintoutSettingMap   {get; set;}
    private Set<String> savedWholesalerIdSet                                               {get; set;}
    
    //Apex Parameter Name 
    private static final String BODY_SELECTED_LIST_JSON     = 'bodySelectedListJson';
    private static final String BODY_EDITABLE_LIST_JSON     = 'bodyEditableListJson';
    private static final String SCHEDULE_EDITABLE_LIST_JSON = 'scheduleEditableListJson';
    private static final String WHOLESALER_SELECTED_ID      = 'wholesalerSelectedId';
    
    //Page parameter
    public Boolean isPageInit { get { if(isPageInit != true) {isPageInit = init();} return isPageInit;} set;}
    
    public String contractId   {get; set;}
    public Boolean isEditable  {get; set;}
    public Boolean isExternal  {get; set;}
    public Boolean isCN        {get; set;}
    public Boolean isSave      {get; set;}
    public Map<decimal, SectionWrapper> headerSectionSortedMap   {get; set;}
    public Map<decimal, SectionWrapper> bodySectionSortedMap     {get; set;}
    public Map<decimal, SectionWrapper> scheduleSectionSortedMap {get; set;}
    public Map<String, SectionWrapper> appendixSectionSortedMap  {get; set;}
    public Map<String, String> indexMergeMap  {get; set;}
    
    //Contract & Child Data
    public ASI_TH_CRM_Contract__c contract                                {get; set;}
    public List<ASI_CRM_ContractTarget__c> contractTargetList             {get; set;}
    public List<ASI_FOC_Free_Goods_Request__c> focHeaderList              {get; set;}
    public List<WholesalerWrapper> wholesalerWrapperList                  {get; set;}
    public List<ASI_CRM_AccountsAdditionalField__c> outletList            {get; set;}
    public List<ASI_CRM_Payment_Schedule__c> paymentScheduleList          {get; set;}
    public List<ASI_CRM_Payment_Schedule__c> paymentCashScheduleList      {get; set;}
    public List<ASI_CRM_Payment_Schedule__c> paymentContractScheduleList  {get; set;}
    public List<ASI_CRM_Payment_Schedule__c> paymentCashScheduleList_excludeUpfront      {get; set;}
    public List<ASI_CRM_Payment_Schedule__c> paymentContractScheduleList_excludeUpfront  {get; set;}
    
    public String outletContactName {get; set;}
    public String outletLegalName   {get; set;}
    public String salesDirectorName {get; set;}
    public String contractOwnerName {get; set;}
	public Boolean salesDirectorChanged {get; set;}
	
	// display list of edited content
	public list<EditedWrapper> editedContent {get; set;}
    
    public ASI_CRM_SG_Contract_Printout_ComCtrl() {
		
	}
    
    /***************
    Page Function
    ***************/
    @RemoteAction
    global static Boolean saveTemplate(String nextStep, String contractId, String outletContactName, String outletLegalName, String salesDirectorName, String contractOwnerName, 
                                    String bodySelectedListJson, String bodyEditableListJson, String scheduleEditableListJson, String wholesalerSelectedId, String appendixSelectedListJson, String scheduleSelectedListJson) {
        
        List<String> bodySelectedList       = (List<String>) fromJsonString(bodySelectedListJson, List<String>.class);
        List<String> bodyEditableList       = (List<String>) fromJsonString(bodyEditableListJson, List<String>.class);
        List<String> scheduleEditableList   = (List<String>) fromJsonString(scheduleEditableListJson, List<String>.class);
        List<String> appendixSelectedList   = (List<String>) fromJsonString(appendixSelectedListJson, List<String>.class);
        List<String> scheduleSelectedList   = (List<String>) fromJsonString(scheduleSelectedListJson, List<String>.class);
        
        System.Savepoint databaseSavepoint = Database.setSavepoint();
		try {
            //Delete existing saved template
            List<ASI_CRM_Contract_Printout_Setting__c> contractPrintoutList = retrieveContractPrintoutSetting(contractId);
            if(contractPrintoutList.size() > 0) {
            	delete contractPrintoutList;
            }
            List<ASI_CRM_Contract_Printout_Setting__c> contractPrintoutSettingList = new List<ASI_CRM_Contract_Printout_Setting__c>();
            
            for(String bodySelected : bodySelectedList) {
                List<String> bodyInformation = bodySelected.split(':');
                
                ASI_CRM_Contract_Printout_Setting__c tempContractPrintoutSetting = new ASI_CRM_Contract_Printout_Setting__c();
                tempContractPrintoutSetting.ASI_CRM_Contract__c             = contractId;
            	tempContractPrintoutSetting.ASI_CRM_Header_Section_Name__c  = 'body';
            	tempContractPrintoutSetting.ASI_CRM_Content_Section_Name__c = bodyInformation.get(0);
            	tempContractPrintoutSetting.ASI_CRM_isVisible__c            = Boolean.valueOf(bodyInformation.get(1));
                
                contractPrintoutSettingList.add(tempContractPrintoutSetting);
            }
            
            for(String bodyEditable : bodyEditableList) {
                List<String> bodyInformation = bodyEditable.split(':');
                
                ASI_CRM_Contract_Printout_Setting__c tempContractPrintoutSetting = new ASI_CRM_Contract_Printout_Setting__c();
                tempContractPrintoutSetting.ASI_CRM_Contract__c             = contractId;
            	tempContractPrintoutSetting.ASI_CRM_Header_Section_Name__c  = 'body';
            	tempContractPrintoutSetting.ASI_CRM_Content_Section_Name__c = bodyInformation.get(0);
            	tempContractPrintoutSetting.ASI_CRM_Section_Content__c      = bodyInformation.get(1);
                
                contractPrintoutSettingList.add(tempContractPrintoutSetting);
            }
            
            for(String scheduleEditable : scheduleEditableList) {
                List<String> scheduleInformation = scheduleEditable.split(':');
                
                ASI_CRM_Contract_Printout_Setting__c tempContractPrintoutSetting = new ASI_CRM_Contract_Printout_Setting__c();
                tempContractPrintoutSetting.ASI_CRM_Contract__c             = contractId;
            	tempContractPrintoutSetting.ASI_CRM_Header_Section_Name__c  = 'schedule';
            	tempContractPrintoutSetting.ASI_CRM_Content_Section_Name__c = scheduleInformation.get(0);
            	tempContractPrintoutSetting.ASI_CRM_Section_Content__c      = scheduleInformation.get(1);
                
                contractPrintoutSettingList.add(tempContractPrintoutSetting);
            }
            
            if(String.isNotBlank(wholesalerSelectedId)) {
                wholesalerSelectedId.removeEnd(',');
                ASI_CRM_Contract_Printout_Setting__c tempContractPrintoutSetting = new ASI_CRM_Contract_Printout_Setting__c();
                tempContractPrintoutSetting.ASI_CRM_Contract__c             = contractId;
            	tempContractPrintoutSetting.ASI_CRM_Header_Section_Name__c  = 'schedule';
            	tempContractPrintoutSetting.ASI_CRM_Content_Section_Name__c = 'Authorised Wholesale Section 1';
            	tempContractPrintoutSetting.ASI_CRM_Section_Content__c      = wholesalerSelectedId;
                
                contractPrintoutSettingList.add(tempContractPrintoutSetting);
            }
            
            for(String appendixSelected : appendixSelectedList) {
                List<String> appendixInformation = appendixSelected.split(':');
                
                ASI_CRM_Contract_Printout_Setting__c tempContractPrintoutSetting = new ASI_CRM_Contract_Printout_Setting__c();
                tempContractPrintoutSetting.ASI_CRM_Contract__c             = contractId;
            	tempContractPrintoutSetting.ASI_CRM_Header_Section_Name__c  = 'appendix';
            	tempContractPrintoutSetting.ASI_CRM_Content_Section_Name__c = appendixInformation.get(0);
            	tempContractPrintoutSetting.ASI_CRM_isVisible__c            = Boolean.valueOf(appendixInformation.get(1));
                
                contractPrintoutSettingList.add(tempContractPrintoutSetting);
            }
            
            for(String scheduleSelected : scheduleSelectedList) {
                List<String> scheduleInformation = scheduleSelected.split(':');
                
                ASI_CRM_Contract_Printout_Setting__c tempContractPrintoutSetting = new ASI_CRM_Contract_Printout_Setting__c();
                tempContractPrintoutSetting.ASI_CRM_Contract__c             = contractId;
            	tempContractPrintoutSetting.ASI_CRM_Header_Section_Name__c  = 'schedule';
            	tempContractPrintoutSetting.ASI_CRM_Content_Section_Name__c = scheduleInformation.get(0);
            	tempContractPrintoutSetting.ASI_CRM_isVisible__c            = Boolean.valueOf(scheduleInformation.get(1));
                
                contractPrintoutSettingList.add(tempContractPrintoutSetting);
            }
            
            ASI_CRM_Contract_Printout_Setting__c outletContactNameContractPrintoutSetting = new ASI_CRM_Contract_Printout_Setting__c();
           	outletContactNameContractPrintoutSetting.ASI_CRM_Contract__c             = contractId;
            outletContactNameContractPrintoutSetting.ASI_CRM_Header_Section_Name__c  = 'ExecutedAsAnAgreement';
            outletContactNameContractPrintoutSetting.ASI_CRM_Content_Section_Name__c = 'OutletContractName';
            outletContactNameContractPrintoutSetting.ASI_CRM_Section_Content__c      = outletContactName;
            
            ASI_CRM_Contract_Printout_Setting__c outletLegalNameContractPrintoutSetting = new ASI_CRM_Contract_Printout_Setting__c();
           	outletLegalNameContractPrintoutSetting.ASI_CRM_Contract__c             = contractId;
            outletLegalNameContractPrintoutSetting.ASI_CRM_Header_Section_Name__c  = 'ExecutedAsAnAgreement';
            outletLegalNameContractPrintoutSetting.ASI_CRM_Content_Section_Name__c = 'OutletLegalName';
            outletLegalNameContractPrintoutSetting.ASI_CRM_Section_Content__c      = outletLegalName;
            
            ASI_CRM_Contract_Printout_Setting__c salesDirectorNameContractPrintoutSetting = new ASI_CRM_Contract_Printout_Setting__c();
           	salesDirectorNameContractPrintoutSetting.ASI_CRM_Contract__c             = contractId;
            salesDirectorNameContractPrintoutSetting.ASI_CRM_Header_Section_Name__c  = 'ExecutedAsAnAgreement';
            salesDirectorNameContractPrintoutSetting.ASI_CRM_Content_Section_Name__c = 'SalesDirectorName';
            salesDirectorNameContractPrintoutSetting.ASI_CRM_Section_Content__c      = salesDirectorName;
            
            ASI_CRM_Contract_Printout_Setting__c contractOwnerNameContractPrintoutSetting = new ASI_CRM_Contract_Printout_Setting__c();
           	contractOwnerNameContractPrintoutSetting.ASI_CRM_Contract__c             = contractId;
            contractOwnerNameContractPrintoutSetting.ASI_CRM_Header_Section_Name__c  = 'ExecutedAsAnAgreement';
            contractOwnerNameContractPrintoutSetting.ASI_CRM_Content_Section_Name__c = 'ContractOwnerName';
            contractOwnerNameContractPrintoutSetting.ASI_CRM_Section_Content__c      = contractOwnerName;
            
            contractPrintoutSettingList.add(outletContactNameContractPrintoutSetting);
            contractPrintoutSettingList.add(outletLegalNameContractPrintoutSetting);
            contractPrintoutSettingList.add(salesDirectorNameContractPrintoutSetting);
            contractPrintoutSettingList.add(contractOwnerNameContractPrintoutSetting);
            
           	if(contractPrintoutSettingList.size() > 0) {
            	insert contractPrintoutSettingList;
            }
			
			
        } catch(Exception e) {
            Database.rollback(databaseSavepoint);
        	throw e;
            return false;
        }
		
		/*
		// save as PDF and attach to contract
		if (nextStep == 'back'){
			savePDFtoContract(contractId);
		}
		*/
        
        return true;
    }
    
    @RemoteAction
	global static boolean savePDFtoContract(String contractId){
		system.debug([select id, ASI_CRM_isVisible__c from ASI_CRM_Contract_Printout_Setting__c where ASI_CRM_Contract__c = :contractId and ASI_CRM_Header_Section_Name__c = 'Appendix']);
		PageReference pdf = Page.ASI_CRM_SG_Contract_Printout_Page;
		//PageReference pdf = new PageReference('/apex/ASI_CRM_SG_Contract_Printout_Page');
		pdf.setRedirect(true);
		pdf.getParameters().put('id',contractId);
		pdf.getParameters().put('edit','0');
		pdf.getParameters().put('external','1');
		Attachment attachPDF = new Attachment();
		Blob body;
		try{
			body = pdf.getContent();
		} catch (VisualforceException e){
			body = Blob.valueOf('Fail');
		}
		attachPDF.Body = body;
		// input PDF name
		Datetime cDT = System.now();
		String cDTstring = cDT.format('yyyyMMddHHmmss');
		attachPDF.Name = 'SFDC - Sales Agreement '+cDTstring+'.pdf';
		attachPDF.IsPrivate = false;
		// attach the pdf to the account
		attachPDF.ParentId = contractId;
		insert attachPDF;
		
		return true;
	}
	
    //Execute the logic when contract id is setted by component
    public Boolean init() {
        
        initData();
        loadStaticResource();
        checkDisplaySection();
        
        if(contractPrintoutSettingMap.containsKey('ExecutedAsAnAgreement_OutletContractName')) {
			if (outletContactName != contractPrintoutSettingMap.get('ExecutedAsAnAgreement_OutletContractName').ASI_CRM_Section_Content__c) {
				SectionWrapper temp = new SectionWrapper('Outlet Contact Name', '', outletContactName, '', 0, '', '', 'N', null);
				temp.content = contractPrintoutSettingMap.get('ExecutedAsAnAgreement_OutletContractName').ASI_CRM_Section_Content__c;
				editedContent.add(new EditedWrapper(temp, 'Edited Content'));
			}
            outletContactName = contractPrintoutSettingMap.get('ExecutedAsAnAgreement_OutletContractName').ASI_CRM_Section_Content__c;
        }
        if(contractPrintoutSettingMap.containsKey('ExecutedAsAnAgreement_OutletLegalName')) {
            if (outletLegalName != contractPrintoutSettingMap.get('ExecutedAsAnAgreement_OutletLegalName').ASI_CRM_Section_Content__c) {
				SectionWrapper temp = new SectionWrapper('Outlet Legal Name', '', outletLegalName, '', 0, '', '', 'N', null);
				temp.content = contractPrintoutSettingMap.get('ExecutedAsAnAgreement_OutletLegalName').ASI_CRM_Section_Content__c;
				editedContent.add(new EditedWrapper(temp, 'Edited Content'));
			}
            outletLegalName = contractPrintoutSettingMap.get('ExecutedAsAnAgreement_OutletLegalName').ASI_CRM_Section_Content__c;
        }
        if(contractPrintoutSettingMap.containsKey('ExecutedAsAnAgreement_SalesDirectorName')) {
            if (salesDirectorName != contractPrintoutSettingMap.get('ExecutedAsAnAgreement_SalesDirectorName').ASI_CRM_Section_Content__c) {
				salesDirectorChanged = true;
				SectionWrapper temp = new SectionWrapper('Sales Director Name', '', salesDirectorName, '', 0, '', '', 'N', null);
				temp.content = contractPrintoutSettingMap.get('ExecutedAsAnAgreement_SalesDirectorName').ASI_CRM_Section_Content__c;
				editedContent.add(new EditedWrapper(temp, 'Edited Content'));
			}
			salesDirectorName = contractPrintoutSettingMap.get('ExecutedAsAnAgreement_SalesDirectorName').ASI_CRM_Section_Content__c;
        }
        if(contractPrintoutSettingMap.containsKey('ExecutedAsAnAgreement_ContractOwnerName')) {
            if (contractOwnerName != contractPrintoutSettingMap.get('ExecutedAsAnAgreement_ContractOwnerName').ASI_CRM_Section_Content__c) {
				SectionWrapper temp = new SectionWrapper('Contract Owner Name', '', contractOwnerName, '', 0, '', '', 'N', null);
				temp.content = contractPrintoutSettingMap.get('ExecutedAsAnAgreement_ContractOwnerName').ASI_CRM_Section_Content__c;
				editedContent.add(new EditedWrapper(temp, 'Edited Content'));
			}
            contractOwnerName = contractPrintoutSettingMap.get('ExecutedAsAnAgreement_ContractOwnerName').ASI_CRM_Section_Content__c;
        }
        if(contractPrintoutSettingMap.containsKey('schedule_A&P Sponsorship')) {
            if (contractPrintoutSettingMap.get('schedule_A&P Sponsorship').ASI_CRM_isVisible__c) {
				showAPSponsorshipCashSection_byUserSelection = true;
			}
        }
        if(contractPrintoutSettingMap.containsKey('schedule_A&P Sponsorship Goods In Kind')) {
            if (contractPrintoutSettingMap.get('schedule_A&P Sponsorship Goods In Kind').ASI_CRM_isVisible__c) {
				showAPSponsorshipContractSection_byUserSelection = true;
			}
        }
		if(contract.ASI_CRM_Contract_Exist_Before_RTM__c){
			showAPSponsorshipCashSection_byUserSelection = true;
			showAPSponsorshipContractSection_byUserSelection = true;
		}
		
        processDisplaySection();
		
		system.debug('editedContent: '+editedContent);
        
        return true;
    }
    
    private void initData() {
        //Init paramter that need to be calculated
        zeroCashSponsorship               = 0;
        zeroCashSponsorshipUpfrontPayment = 0;
        zeroCashSponsorshipMonth          = 0;

        zeroContractSponsorship               = 0;
        zeroContractSponsorshipUpfrontPayment = 0;
        zeroContractSponsorshipMonth          = 0;

        totalCashSponsorship     = 0;
        totalContractSponsorship = 0;
		totalContractSponsorshipWSOT = 0;

        totalSGEvents                = 0;
        totalSignagesAdvertisingSpot = 0;
        totalAdvertisingSpot         = 0;
        totalProductBrandingDisplay  = 0;
        totalTradeIncentiveTrips     = 0;
        totalAdhocPromotions         = 0;
        totalAPMonetarySponsorship   = 0;
        totalAPGoodInKindSponsorship = 0;
		
        
        //Init today date information
        todayDate           = Date.today();
        todayDay            = todayDate.day();
		todayDaySuperScript = daySuperscript.get(todayDay);
        todayMonth          = todayDate.month();
        todayMonth_english  = monthInEnglish.get(String.valueOf(todayMonth));
        todayYear           = todayDate.year();
        
        //Retrieve data from object
        contractPrintoutSettingList = retrieveContractPrintoutSetting(contractId);
        contract                    = retrieveContract(contractId);
        contractTargetList          = retrieveContractTarget(contractId);
        focHeaderList               = retrieveFOCHeader(contractId);
        paymentScheduleList         = retrievePaymentSchedule(contractId);
        outletList                  = retrieveContractOutlets();
        
        //Init the contract basic information
        outletAddress = combineString(new Set<String> {contract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_JP_City_Ward__c, 
                                                       contract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_JP_Town__c,
                                                       contract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_Street_Number__c},
                                     ', ');
        contractStartDate   = ((Datetime)contract.ASI_TH_CRM_Start_Date__c).format('dd MMM yyyy');
        //contractPeriodInNum = contract.ASI_TH_CRM_Start_Date__c.monthsBetween(contract.ASI_TH_CRM_End_Date__c);
		Decimal daysBetween = contract.ASI_TH_CRM_Start_Date__c.daysBetween(contract.ASI_TH_CRM_End_Date__c)+1;
		Decimal monthsBetween = daysBetween/30;
        contractPeriodInNum = (Integer)monthsBetween.setScale(0);
		//contractPeriodInNum_decimal = monthsBetween.setScale(1);
		contractPeriodInNum_decimal = contract.ASI_CRM_Contract_Period_Months__c;
        contractPeriodInStr = numberToWord(contractPeriodInNum);
        
        outletContactName = retrieveOutletContact(contract.ASI_CRM_CN_Outlet_WS__c);
        outletLegalName   = contract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_Legal_Outlet_Name__c;
        salesDirectorName = 'Alex Liu – Commercial Director';
		salesDirectorChanged = false;
        contractOwnerName = contract.owner.Name;
        
        //Init the saved contract printout template
        contractPrintoutSettingMap   = new Map<String, ASI_CRM_Contract_Printout_Setting__c>();

        for(ASI_CRM_Contract_Printout_Setting__c printoutSetting : contractPrintoutSettingList) {
        	contractPrintoutSettingMap.put(printoutSetting.ASI_CRM_Header_Section_Name__c + '_' + printoutSetting.ASI_CRM_Content_Section_Name__c, printoutSetting);
        }
		
        //Calculate the parameter
        for(ASI_CRM_ContractTarget__c contractTarget : contractTargetList) {
            totalSGEvents                += contractTarget.ASI_CRM_SG_Events__c == null ? 0 : contractTarget.ASI_CRM_SG_Events__c;
            totalSignagesAdvertisingSpot += contractTarget.ASI_CRM_SG_Signages_Advertising_Spot__c == null ? 0 : contractTarget.ASI_CRM_SG_Signages_Advertising_Spot__c;
            totalAdvertisingSpot         += contractTarget.ASI_CRM_Advertising_Spot__c == null ? 0 : contractTarget.ASI_CRM_Advertising_Spot__c;
            totalProductBrandingDisplay  += contractTarget.ASI_CRM_SG_Product_Branding_Display__c == null ? 0 : contractTarget.ASI_CRM_SG_Product_Branding_Display__c;
            totalTradeIncentiveTrips     += contractTarget.ASI_CRM_SG_Trade_Incentive_Trips__c == null ? 0 : contractTarget.ASI_CRM_SG_Trade_Incentive_Trips__c;
            totalAdhocPromotions         += contractTarget.ASI_CRM_SG_Ad_hoc_Promotions__c == null ? 0 : contractTarget.ASI_CRM_SG_Ad_hoc_Promotions__c;
            
            totalAPMonetarySponsorship += (contractTarget.ASI_CRM_SG_Events__c == null ? 0 : contractTarget.ASI_CRM_SG_Events__c)
                                        //+ (contractTarget.ASI_CRM_SG_Signages_Advertising_Spot__c == null ? 0 : contractTarget.ASI_CRM_SG_Signages_Advertising_Spot__c)
                                        + (contractTarget.ASI_CRM_Advertising_Spot__c == null ? 0 : contractTarget.ASI_CRM_Advertising_Spot__c)
                                        + (contractTarget.ASI_CRM_SG_Product_Branding_Display__c == null ? 0 : contractTarget.ASI_CRM_SG_Product_Branding_Display__c)
                                        + (contractTarget.ASI_CRM_SG_Trade_Incentive_Trips__c == null ? 0 : contractTarget.ASI_CRM_SG_Trade_Incentive_Trips__c)
                                        + (contractTarget.ASI_CRM_SG_Ad_hoc_Promotions__c == null ? 0 : contractTarget.ASI_CRM_SG_Ad_hoc_Promotions__c);
            
            totalAPGoodInKindSponsorship += ((contractTarget.ASI_CRM_SG_Events_Free_Bottles__c == null ? 0 : contractTarget.ASI_CRM_SG_Events_Free_Bottles__c) 
                                          //+ (contractTarget.ASI_CRM_SG_Signages_Ad_Spot_Free_Btl__c == null ? 0 : contractTarget.ASI_CRM_SG_Signages_Ad_Spot_Free_Btl__c)
                                          + (contractTarget.ASI_CRM_Advertising_Spot_Free_Bottles__c == null ? 0 : contractTarget.ASI_CRM_Advertising_Spot_Free_Bottles__c)
                                          + (contractTarget.ASI_CRM_SG_Anniversary_Free_Bottles__c == null ? 0 : contractTarget.ASI_CRM_SG_Anniversary_Free_Bottles__c)
                                          + ((contractTarget.ASI_CRM_SG_Management_Incentives__c == null ? 0 : contractTarget.ASI_CRM_SG_Management_Incentives__c) * contractPeriodInNum)
										  ) * (contractTarget.ASI_CRM_SG_Selling_Price_Btl_WS_On_Trade__c == null ? 0 : contractTarget.ASI_CRM_SG_Selling_Price_Btl_WS_On_Trade__c)
										   * (contractTarget.ASI_CRM_PackagingSize__c == null ? 0 : contractTarget.ASI_CRM_PackagingSize__c);
										   
			totalContractSponsorshipWSOT += (contractTarget.ASI_CRM_SG_Cont_Sponsor_Target_Incentive__c == null ? 0 : contractTarget.ASI_CRM_SG_Cont_Sponsor_Target_Incentive__c)
											* (contractTarget.ASI_CRM_SG_Selling_Price_Btl_WS_On_Trade__c == null ? 0 : contractTarget.ASI_CRM_SG_Selling_Price_Btl_WS_On_Trade__c)
											* (contractTarget.ASI_CRM_PackagingSize__c == null ? 0 : contractTarget.ASI_CRM_PackagingSize__c);
        }
        
        //Init the wholesaler information
        wholesalerWrapperList = new List<WholesalerWrapper>();
        Integer index = 1;
        for(ASI_CRM_AccountsAdditionalField__c customer : retrieveCustomer()) {
            wholesalerWrapperList.add(new WholesalerWrapper(index, customer, combineString(new Set<String> {customer.ASI_CRM_JP_City_Ward__c, 
                                                                                                            customer.ASI_CRM_JP_Town__c,
                                                                                                            customer.ASI_CRM_Street_Number__c}, '<br />')));
            index ++;
        }
        
        //Init the payment schedule
        paymentCashScheduleList     = new List<ASI_CRM_Payment_Schedule__c>();
        paymentContractScheduleList = new List<ASI_CRM_Payment_Schedule__c>();
        paymentCashScheduleList_excludeUpfront     = new List<ASI_CRM_Payment_Schedule__c>();
        paymentContractScheduleList_excludeUpfront = new List<ASI_CRM_Payment_Schedule__c>();
        
        for(ASI_CRM_Payment_Schedule__c paymentSchedule : paymentScheduleList) {
            if(paymentSchedule.ASI_CRM_Type__c == 'Cash Sponsorship') {
                 if(paymentSchedule.ASI_CRM_Percentof_achieved_Sales_Target__c == '0') {
                  zeroCashSponsorship = paymentSchedule.ASI_CRM_Sponsorship__c == null ? 0 : paymentSchedule.ASI_CRM_Sponsorship__c;
                } else {
					paymentCashScheduleList_excludeUpfront.add(paymentSchedule);
				}
                totalCashSponsorship += paymentSchedule.ASI_CRM_Sponsorship__c == null ? 0 : paymentSchedule.ASI_CRM_Sponsorship__c;
                paymentCashScheduleList.add(paymentSchedule);
            } else if(paymentSchedule.ASI_CRM_Type__c == 'Contract Sponsorship') {
                if(paymentSchedule.ASI_CRM_Percentof_achieved_Sales_Target__c == '0') {
                  zeroContractSponsorship = paymentSchedule.ASI_CRM_Sponsorship__c == null ? 0 : paymentSchedule.ASI_CRM_Sponsorship__c;
                } else {
					paymentContractScheduleList_excludeUpfront.add(paymentSchedule);
				}
                totalContractSponsorship += paymentSchedule.ASI_CRM_Sponsorship__c == null ? 0 : paymentSchedule.ASI_CRM_Sponsorship__c;
                paymentContractScheduleList.add(paymentSchedule);
            }
        }
        
        zeroCashSponsorshipUpfrontPayment     = zeroCashSponsorship / (totalCashSponsorship == 0 ? 1 : totalCashSponsorship) * 100;
        zeroCashSponsorshipMonth              = zeroCashSponsorship / (totalCashSponsorship == 0 ? 1 : totalCashSponsorship) * contractPeriodInNum;
        zeroContractSponsorshipUpfrontPayment = zeroContractSponsorship / (totalContractSponsorship == 0 ? 1 : totalContractSponsorship) * 100;
        zeroContractSponsorshipMonth          = zeroContractSponsorship / (totalContractSponsorship == 0 ? 1 : totalContractSponsorship) * contractPeriodInNum;
		
        zeroCashSponsorshipUpfrontPayment     = zeroCashSponsorshipUpfrontPayment.setScale(2);
        zeroCashSponsorshipMonth              = zeroCashSponsorshipMonth.setScale(2);
        zeroContractSponsorshipUpfrontPayment = zeroContractSponsorshipUpfrontPayment.setScale(2);
        zeroContractSponsorshipMonth          = zeroContractSponsorshipMonth.setScale(2);
		
		editedContent = new list<EditedWrapper>();
    }
    
    /***************
    Display Section Check Function
    ***************/
    private void checkDisplaySection() {
        showTradeDealSection                 = false;
        showPriceRebateSection               = false;
        showContractTargetSponsorshipSection = false;
        showAPSponsorshipSection             = false;
        showAPSponsorshipCashSection         = false;
        showAPSponsorshipContractSection     = false;
        showManagementIncentiveSection       = false;
		showAPGIKEventSection       		 = false;
		showAPGIKAdvertisingSpotSection      = false;
		showAPGIKAnniversarySection       	 = false;
        showAPSponsorshipCashSection_byUserSelection         = false;
        showAPSponsorshipContractSection_byUserSelection     = false;
        
        showContractTargetCashSponsorshipSchedule     = false;
        showContractTargetContractSponsorshipSchedule = false;
        
      //if(focHeaderList.size() > 0) showTradeDealSection = true;
        if(paymentScheduleList.size() > 0) showContractTargetSponsorshipSection = true;
        if(paymentCashScheduleList.size() > 0) showContractTargetCashSponsorshipSchedule = true;
        if(paymentContractScheduleList.size() > 0) showContractTargetContractSponsorshipSchedule = true;
    
        for(ASI_CRM_ContractTarget__c contractTarget : contractTargetList) {
            if(contractTarget.ASI_CRM_SG_Sales_Incentive__c != null && 
               contractTarget.ASI_CRM_SG_Sales_Incentive__c != 0) {
              showTradeDealSection = true;
            }
			/*
            if((contractTarget.ASI_CRM_SG_Wholesaler_Margin__c != null && 
                contractTarget.ASI_CRM_SG_Wholesaler_Margin__c != 0) ||
               (contractTarget.ASI_CRM_Bottle_Incentive__c != null && 
                contractTarget.ASI_CRM_Bottle_Incentive__c != 0)) {
              showPriceRebateSection = true;
            }
			*/
            if(contractTarget.ASI_CRM_Bottle_Incentive__c != null && 
                contractTarget.ASI_CRM_Bottle_Incentive__c != 0) {
              showPriceRebateSection = true;
            }
            if(contractTarget.ASI_CRM_SG_Management_Incentives__c != null && 
               contractTarget.ASI_CRM_SG_Management_Incentives__c != 0) {
              showManagementIncentiveSection = true;
              showAPSponsorshipContractSection = true;
              showAPSponsorshipSection = true;
            }
            if((contractTarget.ASI_CRM_SG_Events_Free_Bottles__c != null && 
               contractTarget.ASI_CRM_SG_Events_Free_Bottles__c != 0) || 
			   (contractTarget.ASI_CRM_Advertising_Spot_Free_Bottles__c != null && 
               contractTarget.ASI_CRM_Advertising_Spot_Free_Bottles__c != 0) || 
			   (contractTarget.ASI_CRM_SG_Anniversary_Free_Bottles__c != null && 
               contractTarget.ASI_CRM_SG_Anniversary_Free_Bottles__c != 0)) {
              showAPSponsorshipContractSection = true;
              showAPSponsorshipSection = true;
            }
            if((contractTarget.ASI_CRM_SG_Events__c != null && 
               contractTarget.ASI_CRM_SG_Events__c != 0) || 
			   (contractTarget.ASI_CRM_Advertising_Spot__c != null && 
               contractTarget.ASI_CRM_Advertising_Spot__c != 0) || 
			   (contractTarget.ASI_CRM_SG_Trade_Incentive_Trips__c  != null && 
               contractTarget.ASI_CRM_SG_Trade_Incentive_Trips__c  != 0) || 
			   (contractTarget.ASI_CRM_SG_Product_Branding_Display__c  != null && 
               contractTarget.ASI_CRM_SG_Product_Branding_Display__c  != 0) || 
			   (contractTarget.ASI_CRM_SG_Ad_hoc_Promotions__c  != null && 
               contractTarget.ASI_CRM_SG_Ad_hoc_Promotions__c  != 0)) {
              showAPSponsorshipCashSection = true;
              showAPSponsorshipSection = true;
            }
            if(contractTarget.ASI_CRM_SG_Events_Free_Bottles__c != null && 
               contractTarget.ASI_CRM_SG_Events_Free_Bottles__c != 0) {
              showAPGIKEventSection = true;
            }
            if(contractTarget.ASI_CRM_Advertising_Spot_Free_Bottles__c != null && 
               contractTarget.ASI_CRM_Advertising_Spot_Free_Bottles__c != 0) {
              showAPGIKAdvertisingSpotSection = true;
            }
            if(contractTarget.ASI_CRM_SG_Anniversary_Free_Bottles__c != null && 
               contractTarget.ASI_CRM_SG_Anniversary_Free_Bottles__c != 0) {
              showAPGIKAnniversarySection = true;
            }
        }
  
		/*
        if((contract.ASI_CRM_SG_TotalTradeAPFOCWSOntradeSP__c != null &&
           contract.ASI_CRM_SG_TotalTradeAPFOCWSOntradeSP__c != 0) ||
           (contract.ASI_CRM_SG_Total_Trade_A_P_PRS__c != null && 
            contract.ASI_CRM_SG_Total_Trade_A_P_PRS__c != 0)) {
            showAPSponsorshipSection = true;
        }
		*/
            
    }
    
    /**************
    Process XML file to meet the contract criteria
    **************/
    private void processDisplaySection() {
        indexMergeMap = new Map<String, String>();
		processHeaderSection();
        processBodySection();
        processScheduleSection();
        processAppendixSection();
		processIndexMerge();
    }
    
    private void processHeaderSection() {
        headerSectionMap = processSavedContractPrintoutTemplate('header', headerSectionMap, contractPrintoutSettingMap);
        
    	for(decimal key : headerSectionMap.keySet()) {
            SectionWrapper sectionWrapper = headerSectionMap.get(key);
            //Assign Value To Section
            if(sectionWrapper.name == 'Header with original contract' &&
               contract.ASI_CRM_Original_Version__c != null) {
                List<String> fillers = new String[] {contract.Name, 
                                                     String.valueOf(todayDay), 
                                                     String.valueOf(todayMonth_english), 
                                                     String.valueOf(todayYear), 
													 /*
                                                     contract.ASI_CRM_Original_Version__r.Name,
													 */
													 retrieveLastVersionContract(contract),
													 todayDaySuperScript};
                sectionWrapper.content = String.format(sectionWrapper.content, fillers);
            }
            
            if(sectionWrapper.name == 'Header without original contract' &&
               contract.ASI_CRM_Original_Version__c == null) {
                List<String> fillers = new String[] {contract.Name, 
                                                     String.valueOf(todayDay), 
                                                     String.valueOf(todayMonth_english), 
                                                     String.valueOf(todayYear),
													 todayDaySuperScript};
                sectionWrapper.content = String.format(sectionWrapper.content, fillers);
            }
            
            if(sectionWrapper.name == 'Customer Information') {
                List<String> fillers = new String[] {contract.ASI_CRM_CN_Outlet_WS__r.Name, 
                                                     contract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_Business_Registration_Number__c, 
                                                     outletAddress};
                sectionWrapper.content = String.format(sectionWrapper.content, fillers);
            }
            
            //Remove section
            
			if(sectionWrapper.name == 'Header with original contract' &&
               contract.ASI_CRM_Original_Version__c == null) {
              headerSectionMap.remove(key);
            } 
            if(sectionWrapper.name == 'Header without original contract' &&
               contract.ASI_CRM_Original_Version__c != null) {
              headerSectionMap.remove(key);
            }
			
        }
        
        headerSectionSortedMap = reassignSectionIndex('header', headerSectionMap,'');
    }
    
    private void processBodySection() {
        bodySectionMap = processSavedContractPrintoutTemplate('body', bodySectionMap, contractPrintoutSettingMap);
        
     	for(decimal key : bodySectionMap.keySet()) {
			SectionWrapper sectionWrapper = bodySectionMap.get(key);
            if(sectionWrapper.name == 'Contractual Period') {
                //List<String> fillers = new String[] {String.valueOf(contractStartDate), contractPeriodInStr, String.valueOf(contractPeriodInNum)};
                List<String> fillers = new String[] {String.valueOf(contractStartDate), String.valueOf(contractPeriodInNum_decimal)};
                sectionWrapper.subSectionMap.get(1).content = String.format(sectionWrapper.subSectionMap.get(1).content, fillers);
            }
            
            if(sectionWrapper.name == 'Trade Deal' && showTradeDealSection == false) {
                bodySectionMap.remove(key);
            }
            if(sectionWrapper.name == 'Price Rebate' && showPriceRebateSection == false) {
                bodySectionMap.remove(key);
            }
            if(sectionWrapper.name == 'Contract Target Sponsorship') {
				if(showContractTargetSponsorshipSection == false) {
					 bodySectionMap.remove(key);
				} else
				if(showContractTargetCashSponsorshipSchedule == false) {
					 sectionWrapper.subSectionMap.remove(1);
				} else
				if(showContractTargetContractSponsorshipSchedule == false) {
					 sectionWrapper.subSectionMap.remove(2);
				}
            }
            if(sectionWrapper.name == 'A&P Sponsorship') {
				if(showAPSponsorshipSection == false || (showAPSponsorshipCashSection_byUserSelection == false && showAPSponsorshipContractSection_byUserSelection == false)) {
					 bodySectionMap.remove(key);
				} else
				if(showAPSponsorshipCashSection == false || showAPSponsorshipCashSection_byUserSelection == false ) {
					 sectionWrapper.subSectionMap.remove(1);
					 sectionWrapper.subSectionMap.remove(3);
				} else
				if(showAPSponsorshipContractSection == false || showAPSponsorshipContractSection_byUserSelection == false ) {
					 sectionWrapper.subSectionMap.remove(2);
					 sectionWrapper.subSectionMap.remove(3);
				} else {
					 sectionWrapper.subSectionMap.remove(1);
					 sectionWrapper.subSectionMap.remove(2);
				}
            }
            if(sectionWrapper.name == 'Management Incentive' && showManagementIncentiveSection == false) {
                bodySectionMap.remove(key);
            }
        }

        bodySectionSortedMap = reassignSectionIndex('body', bodySectionMap,'');
    }
    
    private void processScheduleSection() {
        scheduleSectionMap = processSavedContractPrintoutTemplate('schedule', scheduleSectionMap, contractPrintoutSettingMap);
      	for(decimal key : scheduleSectionMap.keySet()) {
            SectionWrapper sectionWrapper = scheduleSectionMap.get(key);
            
            if(sectionWrapper.name == 'Cash Contract Target Sponsorship') {
                List<String> fillers = new String[] {doFormatting(totalCashSponsorship, 2, ',', '.')};
              	sectionWrapper.content = String.format(sectionWrapper.content, fillers);
                
                List<String> sectionFillers1 = new String[] {doFormatting(zeroCashSponsorship, 2, ',', '.')};
                sectionWrapper.subSectionMap.get(1).content = String.format(sectionWrapper.subSectionMap.get(1).content, sectionFillers1);
                
                List<String> sectionFillers2 = new String[] {doFormatting(zeroCashSponsorshipUpfrontPayment, 2, ',', '.'), doFormatting(zeroCashSponsorshipMonth, 2, ',', '.')};
                sectionWrapper.subSectionMap.get(1).subSectionMap.get(1).content = String.format(sectionWrapper.subSectionMap.get(1).subSectionMap.get(1).content, sectionFillers2);
                
                List<String> sectionFillers3 = new String[] {doFormatting((totalCashSponsorship - zeroCashSponsorship), 2, ',', '.')};
                sectionWrapper.subSectionMap.get(2).content = String.format(sectionWrapper.subSectionMap.get(2).content, sectionFillers3);
				
				if (zeroCashSponsorship==0) sectionWrapper.subSectionMap.remove(1);
				else if (zeroCashSponsorshipUpfrontPayment==0) sectionWrapper.subSectionMap.get(1).subSectionMap.remove(1);
				
				if ((totalCashSponsorship - zeroCashSponsorship)==0) sectionWrapper.subSectionMap.remove(2);
            }
            
            if(sectionWrapper.name == 'Contract Target Sponsorship') {
                
				/*
              List<String> fillers = new String[] {doFormatting(totalContractSponsorship, 2, ',', '.')};
              sectionWrapper.content = String.format(sectionWrapper.content, fillers);
			  
                List<String> sectionFillers1 = new String[] {doFormatting(zeroContractSponsorship, 2, ',', '.')};
                sectionWrapper.subSectionMap.get(1).content = String.format(sectionWrapper.subSectionMap.get(1).content, sectionFillers1);
                
                List<String> sectionFillers2 = new String[] {doFormatting(zeroContractSponsorshipUpfrontPayment, 2, ',', '.'), doFormatting(zeroContractSponsorshipMonth, 2, ',', '.')};
                sectionWrapper.subSectionMap.get(1).subSectionMap.get(1).content = String.format(sectionWrapper.subSectionMap.get(1).subSectionMap.get(1).content, sectionFillers2);
                
                List<String> sectionFillers3 = new String[] {doFormatting((totalContractSponsorship - zeroContractSponsorship), 2, ',', '.')};
                sectionWrapper.subSectionMap.get(2).content = String.format(sectionWrapper.subSectionMap.get(2).content, sectionFillers3);
				*/
              List<String> fillers = new String[] {doFormatting(totalContractSponsorshipWSOT, 2, ',', '.')};
              sectionWrapper.content = String.format(sectionWrapper.content, fillers);
			  
                List<String> sectionFillers1 = new String[] {doFormatting((zeroContractSponsorship*totalContractSponsorshipWSOT/(totalContractSponsorship==0 ? 1 : totalContractSponsorship)), 2, ',', '.')};
                sectionWrapper.subSectionMap.get(1).content = String.format(sectionWrapper.subSectionMap.get(1).content, sectionFillers1);
                
                List<String> sectionFillers2 = new String[] {doFormatting(zeroContractSponsorshipUpfrontPayment, 2, ',', '.'), doFormatting(zeroContractSponsorshipMonth, 2, ',', '.')};
                sectionWrapper.subSectionMap.get(1).subSectionMap.get(1).content = String.format(sectionWrapper.subSectionMap.get(1).subSectionMap.get(1).content, sectionFillers2);
                
                List<String> sectionFillers3 = new String[] {doFormatting(((totalContractSponsorship - zeroContractSponsorship)*totalContractSponsorshipWSOT/(totalContractSponsorship==0 ? 1 : totalContractSponsorship)), 2, ',', '.')};
                sectionWrapper.subSectionMap.get(2).content = String.format(sectionWrapper.subSectionMap.get(2).content, sectionFillers3);
				
				if (zeroContractSponsorship==0) sectionWrapper.subSectionMap.remove(1);
				else if (zeroContractSponsorshipUpfrontPayment==0) sectionWrapper.subSectionMap.get(1).subSectionMap.remove(1);
				
				if ((totalContractSponsorship - zeroContractSponsorship)==0) sectionWrapper.subSectionMap.remove(2);
            }
            
             if(sectionWrapper.name == 'A&P Sponsorship') {
                List<String> fillers = new String[] {doFormatting(totalAPMonetarySponsorship, 2, ',', '.')};
                sectionWrapper.content = String.format(sectionWrapper.content, fillers);
                
                List<String> sectionFillers1 = new String[] {doFormatting(totalSGEvents, 2, ',', '.')};
                    if(sectionWrapper.subSectionMap.containsKey(1)){
                        system.debug(sectionWrapper.subSectionMap+'sectionFillers1'+sectionFillers1);    
                        sectionWrapper.subSectionMap.get(1).content = String.format(sectionWrapper.subSectionMap.get(1).content, sectionFillers1);
                        if (totalSGEvents==0) sectionWrapper.subSectionMap.remove(1);
                    }
                 
            
                
				/*
                List<String> sectionFillers2 = new String[] {String.valueOf(totalSignagesAdvertisingSpot)};
                sectionWrapper.subSectionMap.get(2).content = String.format(sectionWrapper.subSectionMap.get(2).content, sectionFillers2);
                
                List<String> sectionFillers3 = new String[] {String.valueOf(totalAdvertisingSpot)};
                sectionWrapper.subSectionMap.get(3).content = String.format(sectionWrapper.subSectionMap.get(3).content, sectionFillers3);
                
                List<String> sectionFillers4 = new String[] {String.valueOf(totalProductBrandingDisplay)};
                sectionWrapper.subSectionMap.get(4).content = String.format(sectionWrapper.subSectionMap.get(4).content, sectionFillers4);
                
                List<String> sectionFillers5 = new String[] {String.valueOf(totalTradeIncentiveTrips)};
                sectionWrapper.subSectionMap.get(5).content = String.format(sectionWrapper.subSectionMap.get(5).content, sectionFillers5);
                
                List<String> sectionFillers6 = new String[] {String.valueOf(totalAdhocPromotions)};
                sectionWrapper.subSectionMap.get(6).content = String.format(sectionWrapper.subSectionMap.get(6).content, sectionFillers6);
				*/
                 if(sectionWrapper.subSectionMap.containsKey(2)){
                     List<String> sectionFillers3 = new String[] {doFormatting(totalAdvertisingSpot, 2, ',', '.')};
                         sectionWrapper.subSectionMap.get(2).content = String.format(sectionWrapper.subSectionMap.get(2).content, sectionFillers3);
                     if (totalAdvertisingSpot==0) sectionWrapper.subSectionMap.remove(2);
                 }
                 
                 if(sectionWrapper.subSectionMap.containsKey(3)){
                     List<String> sectionFillers4 = new String[] {doFormatting(totalProductBrandingDisplay, 2, ',', '.')};
                         sectionWrapper.subSectionMap.get(3).content = String.format(sectionWrapper.subSectionMap.get(3).content, sectionFillers4);
                     if (totalProductBrandingDisplay==0) sectionWrapper.subSectionMap.remove(3);
                     
                 }
                 
                 if(sectionWrapper.subSectionMap.containsKey(4)){
                     List<String> sectionFillers5 = new String[] {doFormatting(totalTradeIncentiveTrips, 2, ',', '.')};
                         sectionWrapper.subSectionMap.get(4).content = String.format(sectionWrapper.subSectionMap.get(4).content, sectionFillers5);
                     if (totalTradeIncentiveTrips==0) sectionWrapper.subSectionMap.remove(4);
                     
                 }
                 
                 
                 if(sectionWrapper.subSectionMap.containsKey(5)){
                     List<String> sectionFillers6 = new String[] {doFormatting(totalAdhocPromotions, 2, ',', '.')};
                         sectionWrapper.subSectionMap.get(5).content = String.format(sectionWrapper.subSectionMap.get(5).content, sectionFillers6);
                     if (totalAdhocPromotions==0) sectionWrapper.subSectionMap.remove(5);
                 }
                 
               
               
            }
            
            if(sectionWrapper.name == 'A&P Sponsorship Goods In Kind') {
              List<String> fillers = new String[] {doFormatting(totalAPGoodInKindSponsorship.setScale(2), 2, ',', '.')};
              sectionWrapper.content = String.format(sectionWrapper.content, fillers);
			  system.debug('showAPGIKAnniversarySection:'+showAPGIKAnniversarySection);
                system.debug('show content :'+sectionWrapper.subSectionMap.get(1));
                
                if(contract.ASI_CRM_Contract_Exist_Before_RTM__c){//Old
                    if (!showAPGIKEventSection) sectionWrapper.subSectionMap.remove(1);
                    if (!showAPGIKAdvertisingSpotSection) sectionWrapper.subSectionMap.remove(2);
                    if (!showAPGIKAnniversarySection) sectionWrapper.subSectionMap.remove(3);
                    if (!showManagementIncentiveSection) {
                        sectionWrapper.subSectionMap.remove(4);
                        sectionWrapper.subSectionMap.remove(5);
                        sectionWrapper.subSectionMap.remove(6);
                    }
                    
                }else{
                    if(!showAPGIKAnniversarySection){
                        sectionWrapper.subSectionMap.remove(1);
                        scheduleSectionMap.remove(key);
                    }
                }
				
                
                
            }
            
            if(sectionWrapper.name == 'Price Rebate' && showPriceRebateSection == false) {
                 scheduleSectionMap.remove(key);
            }
            
            if(sectionWrapper.name == 'Cash Contract Target Sponsorship' && showContractTargetCashSponsorshipSchedule == false) {
                 scheduleSectionMap.remove(key);
            }
            
            if(sectionWrapper.name == 'Contract Target Sponsorship' && showContractTargetContractSponsorshipSchedule == false) {
                 scheduleSectionMap.remove(key);
            }
            
            if(sectionWrapper.name == 'A&P Sponsorship' && showAPSponsorshipCashSection == false) {
                 scheduleSectionMap.remove(key);
            }
            
            if(sectionWrapper.name == 'A&P Sponsorship Goods In Kind' && showAPSponsorshipContractSection == false) {
                 scheduleSectionMap.remove(key);
            }
        }

        scheduleSectionSortedMap = reassignSectionIndex('schedule', scheduleSectionMap,'');
        
        //Process which wholesaler need to show
		if(savedWholesalerIdSet != null && savedWholesalerIdSet.size() > 0) {
            List<Integer> removeIndexList = new List<Integer>(); 
            for(integer index = wholesalerWrapperList.size() - 1 ; index >= 0 ; index--) {
                WholesalerWrapper wholesalerWrapper = wholesalerWrapperList.get(index);
                if(savedWholesalerIdSet.contains(wholesalerWrapper.customer.id)) {
                    wholesalerWrapper.isSelected = true;
                } else {
                    wholesalerWrapper.isSelected = false;
                	removeIndexList.add(index);
                }
            }
            if(!isEditable) {
            	for(Integer index : removeIndexList) {
                	wholesalerWrapperList.remove(index);
                }

                for(integer index = 1; index <= wholesalerWrapperList.size(); index ++) {
                    WholesalerWrapper wholesalerWrapper = wholesalerWrapperList.get(index - 1);
                    wholesalerWrapper.index = index;
                }
            }
            
        }
    }
    
    private void processAppendixSection() {
        appendixSectionMap = processSavedContractPrintoutTemplate('appendix', appendixSectionMap, contractPrintoutSettingMap);
      	for(decimal key : appendixSectionMap.keySet()) {
            SectionWrapper sectionWrapper = appendixSectionMap.get(key);
            
            if(sectionWrapper.name == 'Designated Outlets' && outletList.size() == 0) {
                 appendixSectionMap.remove(key);
            }
            
        }

        appendixSectionSortedMap = reassignSectionIndexAlphabet('appendix', appendixSectionMap);
        
    }
    
    /***************
    Sort Section
    ***************/
    private Map<decimal, SectionWrapper> reassignSectionIndex(String section, Map<decimal, SectionWrapper> sectionMap, String parentIndex) {
    	Map<decimal, SectionWrapper> sortedSectionMap = new Map<decimal, SectionWrapper>();
        Integer index = 1;
        for(decimal key : sectionMap.keySet()) {
            SectionWrapper sectionWrapper = sectionMap.get(key);
			
			Integer sortingNumber = sectionWrapper.sortingNumber;
			String indexKey = section+'_'+sortingNumber;
			String indexThis = parentIndex == '' ? String.valueOf(index) : parentIndex+'.'+String.valueOf(index);
			indexMergeMap.put('{'+indexKey+'}',indexThis);
			
            if(sectionWrapper.hasSubSection) {
                sectionWrapper.subSectionMap = reassignSectionIndex(indexKey, sectionWrapper.subSectionMap,indexThis);
            }
			
            if (section == 'schedule' && sectionWrapper.name == 'Contract Target Sponsorship' && showContractTargetCashSponsorshipSchedule) {
				sortedSectionMap.put(index-0.5, sectionMap.get(key));
			} else {
				sortedSectionMap.put(index, sectionMap.get(key));
				index++;
			}
        }
        return sortedSectionMap;
    }
    
    private Map<String, SectionWrapper> reassignSectionIndexAlphabet(String section, Map<decimal, SectionWrapper> sectionMap) {
    	Map<String, SectionWrapper> sortedSectionMap = new Map<String, SectionWrapper>();
        String alphabet = 'ABCDEFGHIJKLMNOPQRSTUVXXYZ';
        Integer index = 1;
        for(decimal key : sectionMap.keySet()) {
            SectionWrapper sectionWrapper = sectionMap.get(key);
            if(sectionWrapper.hasSubSection) {
                sectionWrapper.subSectionMap = reassignSectionIndex(section, sectionWrapper.subSectionMap,'');
            }
            sortedSectionMap.put(alphabet.substring(index-1,index), sectionMap.get(key));
            index++;
        }
        return sortedSectionMap;
    }
    
	/***************
    Merge index in statements
    ***************/
    private void processIndexMerge() {
		bodySectionSortedMap = processIndexMergeBySection(bodySectionSortedMap);
        scheduleSectionSortedMap = processIndexMergeBySection(scheduleSectionSortedMap);
        appendixSectionSortedMap = processIndexMergeBySectionAlphabet(appendixSectionSortedMap);
    }
    
    private Map<decimal, SectionWrapper> processIndexMergeBySection(Map<decimal, SectionWrapper> sectionMap) {
		for(decimal key : sectionMap.keySet()) {
            SectionWrapper sectionWrapper = sectionMap.get(key);
			
            if(sectionWrapper.hasSubSection) {
                sectionWrapper.subSectionMap = processIndexMergeBySection(sectionWrapper.subSectionMap);
            }
			
			if (sectionWrapper.indexMerge) {
				list<string> mergeList = getMergeList(sectionWrapper.content);
				for (string mergeString : mergeList){
					system.debug(''+mergeString);
					string replaceString = indexMergeMap.get(mergeString);
                    system.debug('replaceString '+replaceString);
                    if(replaceString!=null){
                        sectionWrapper.content = sectionWrapper.content.replace(mergeString, replaceString);
                    }
					
				}
			}
			
            sectionMap.put(key, sectionWrapper);
        }
        return sectionMap;
    }
    
    private Map<String, SectionWrapper> processIndexMergeBySectionAlphabet(Map<String, SectionWrapper> sectionMap) {
		for(String key : sectionMap.keySet()) {
            SectionWrapper sectionWrapper = sectionMap.get(key);
			
            if(sectionWrapper.hasSubSection) {
                sectionWrapper.subSectionMap = processIndexMergeBySection(sectionWrapper.subSectionMap);
            }
			
			if (sectionWrapper.indexMerge) {
				list<string> mergeList = getMergeList(sectionWrapper.content);
				for (string mergeString : mergeList){
					system.debug(mergeString);
					string replaceString = indexMergeMap.get(mergeString);
					sectionWrapper.content = sectionWrapper.content.replace(mergeString, replaceString);
				}
			}
			
            sectionMap.put(key, sectionWrapper);
        }
        return sectionMap;
    }
    
	private List<string> getMergeList(string content){
		list<string> mergeList = new list<string>();
		Integer i = 0;
		String mergeString = '';
		do {
			if (i<content.length()){
				string character = content.substring(i,i+1);
				if (character=='{') {
					mergeString += character;
				} else
				if (character=='}') {
					mergeString += character;
					mergeList.add(mergeString);
					mergeString = '';
				} else
				if (mergeString!='') {
					mergeString += character;
				}
			}
			i++;
		} while (i<content.length());
		return mergeList;
	}
	
    /**************
    Process Saved Contract Printout Template
    **************/
    private Map<decimal, SectionWrapper> processSavedContractPrintoutTemplate(String sectionType, Map<decimal, SectionWrapper> sectionWrapperMap, Map<String, ASI_CRM_Contract_Printout_Setting__c> contractPrintoutSettingMap) {
    	for(decimal key : sectionWrapperMap.keySet()) {
            SectionWrapper sectionWrapper = sectionWrapperMap.get(key);
            
			string editedType = '';
            if(contractPrintoutSettingMap.containsKey(sectionType + '_' + sectionWrapper.name)) {
                ASI_CRM_Contract_Printout_Setting__c contractPrintoutSetting = contractPrintoutSettingMap.get(sectionType + '_' + sectionWrapper.name);
                /**************
                Special Handling for Authorised Wholesaler
                **************/
                if(sectionWrapper.name == 'Authorised Wholesale Section 1') {
                	savedWholesalerIdSet = new Set<String>();
                    savedWholesalerIdSet.addAll(contractPrintoutSetting.ASI_CRM_Section_Content__c.split(','));
                    continue;
                }
                if(sectionWrapper.type == 'Editable') {
                    sectionWrapper.content = contractPrintoutSetting.ASI_CRM_Section_Content__c;
					if (sectionWrapper.content_original != sectionWrapper.content){
						editedContent.add(new EditedWrapper(sectionWrapper, 'Edited Content'));
					}
					
                }
                if(sectionWrapper.type == 'Selectable') {
                	sectionWrapper.isShow = contractPrintoutSetting.ASI_CRM_isVisible__c;
                    if(!sectionWrapper.isShow) {
						editedContent.add(new EditedWrapper(sectionWrapper, 'Unselected'));
						if (!isEditable){
							sectionWrapperMap.remove(key);
						}
                    }
                }
            }
            if(sectionWrapper.hasSubSection) {
            	sectionWrapper.subSectionMap = processSavedContractPrintoutTemplate(sectionType, sectionWrapper.subSectionMap, contractPrintoutSettingMap);
            }
        }
        return sectionWrapperMap;
    }
    
    /***************
  	XML Static Resource Function
  	***************/
    private void loadStaticResource() {
        String xmlStr ='';
        if(contract.ASI_CRM_Contract_Exist_Before_RTM__c){
            StaticResource sr = [SELECT Body FROM StaticResource WHERE Name = :XML_Static_Resource_Name LIMIT 1];
            xmlStr = sr.Body.toString();
        }else{
            StaticResource sr = [SELECT Body FROM StaticResource WHERE Name = 'ASI_CRM_SG_Contract_Printout_Template2' LIMIT 1];
            xmlStr = sr.Body.toString(); 
        }
        
        
        Dom.Document doc = new Dom.Document();
        doc.load(xmlStr);
        
        Dom.XMLNode docRootNode  = doc.getRootElement();
        Dom.XMLNode headerNode   = docRootNode.getChildElement('header', null);
        Dom.XMLNode bodyNode     = docRootNode.getChildElement('body', null);
        Dom.XMLNode scheduleNode = docRootNode.getChildElement('schedule', null);
        Dom.XMLNode appendixNode = docRootNode.getChildElement('appendix', null);
    
        headerSectionMap   = parseXML(headerNode);
        bodySectionMap     = parseXML(bodyNode);
        scheduleSectionMap = parseXML(scheduleNode);
        appendixSectionMap = parseXML(appendixNode);
    }
    
    private Map<decimal, SectionWrapper> parseXML(Dom.XMLNode sectionNode) {
        Map<decimal, SectionWrapper> sectionWrapperMap = new Map<decimal, SectionWrapper>();
        
        for(Dom.XMLNode childNode : sectionNode.getChildElements()) {
            String name                                = childNode.getAttribute('name', null);
            String title                               = childNode.getChildElement('title', null).getText();
            String content                             = childNode.getChildElement('content', null).getText();
            String displayNumber                       = childNode.getAttribute('displayNumber', null);
            Integer sortingNumber                      = Integer.valueOf(childNode.getChildElement('sortingNumber', null).getText());
            String type                                = childNode.getChildElement('type', null).getText();
            String sectionNumber                       = childNode.getChildElement('sectionNumber', null).getText();
            String indexMerge                          = childNode.getChildElement('indexMerge', null).getText();
            Map<decimal, SectionWrapper> subSectionMap = null;
            
            Dom.XMLNode subSectionNode = childNode.getChildElement('subSection', null);
            if(subSectionNode != null) {
                subSectionMap = parseXML(subSectionNode);
            }

            SectionWrapper sectionWrapper = new SectionWrapper(name, title, content, displayNumber, sortingNumber, type, sectionNumber, indexMerge, subSectionMap);
            sectionWrapperMap.put(sortingNumber, sectionWrapper);
        }
        
        return sectionWrapperMap;
    }
    
    /***************
  	Data Retrievement Function
  	***************/
  	global static List<ASI_CRM_Contract_Printout_Setting__c> retrieveContractPrintoutSetting(Id contractId) {
		String query = 'SELECT ' + genQueryField(CONTRACT_PRINTOUT_FIELD_MAP) + ' ' + 
					   'FROM ASI_CRM_Contract_Printout_Setting__c ' + 
					   'WHERE ASI_CRM_Contract__c = :contractId';
		return (List<ASI_CRM_Contract_Printout_Setting__c>) Database.query(query);
	}

  	private ASI_TH_CRM_Contract__c retrieveContract(Id contractId) {
		String query = 'SELECT ' + genQueryField(CONTRACT_FIELD_MAP) + 
					   ', RecordType.DeveloperName, Owner.Name, ASI_CRM_CN_Outlet_WS__r.Name, ASI_CRM_CN_Outlet_WS__r.ASI_CRM_Business_Registration_Number__c ' +
						   ', ASI_CRM_CN_Outlet_WS__r.ASI_CRM_JP_City_Ward__c, ASI_CRM_CN_Outlet_WS__r.ASI_CRM_JP_Town__c, ASI_CRM_CN_Outlet_WS__r.ASI_CRM_Legal_Outlet_Name__c ' + 
						   ', ASI_CRM_CN_Outlet_WS__r.ASI_CRM_Street_Number__c, ASI_CRM_Original_Version__r.Name ' + 
					   'FROM ASI_TH_CRM_Contract__c ' + 
					   'Where Id = :contractId';

		List<ASI_TH_CRM_Contract__c> contractList = (List<ASI_TH_CRM_Contract__c>) Database.query(query);
		return contractList.size() > 0 ? contractList.get(0) : null;
	}
    
  	private String retrieveLastVersionContract(ASI_TH_CRM_Contract__c contract) {
		
		map<string, string> map_recordtype = new map<string, string>{
			'ASI_CRM_SG_Proposal' => 'ASI_CRM_SG_Proposal_Read_Only',
			'ASI_CRM_SG_Proposal_Read_Only' => 'ASI_CRM_SG_Proposal_Archived',
			'ASI_CRM_SG_Contract' => 'ASI_CRM_SG_Contract_Read_Only',
			'ASI_CRM_SG_Contract_Read_Only' => 'ASI_CRM_SG_Contract_Archived'
		};
		map<string, string> map_status = new map<string, string>{
			'ASI_CRM_SG_Proposal_Draft' => 'Proposal Approved',
			'ASI_CRM_SG_Proposal_Proposal Rejected' => 'Proposal Approved',
			'ASI_CRM_SG_Proposal_Read_Only_Proposal Approved' => 'Archived',
			'ASI_CRM_SG_Proposal_Read_Only_Proposal Converted' => 'Archived',
			'ASI_CRM_SG_Contract_Draft' => 'Contract Approved',
			'ASI_CRM_SG_Contract_Contract Rejected' => 'Contract Approved',
			'ASI_CRM_SG_Contract_Read_Only_Contract Approved' => 'Archived'
		};
		
		String recordtype = map_recordtype.get(contract.RecordType.DeveloperName);
		String status = map_status.get(contract.RecordType.DeveloperName+'_'+contract.ASI_TH_CRM_Contract_Status__c);
		String originalContractName = contract.ASI_CRM_Original_Version__r.Name;
		
		String query = 'SELECT Name FROM ASI_TH_CRM_Contract__c ' + 
					   'Where Id <> :contractId ' + 
					   'AND RecordType.DeveloperName = :recordtype ' + 
					   'AND ASI_TH_CRM_Contract_Status__c = :status ' + 
					   'AND name like \'' + originalContractName + '%\' ' +
					   'Order by name desc limit 1 ';

		List<ASI_TH_CRM_Contract__c> contractList = (List<ASI_TH_CRM_Contract__c>) Database.query(query);
		return contractList.size() > 0 ? contractList.get(0).name : null;
	}
		
    private string retrieveOutletContact(Id outletId) {
        String query = 'SELECT name FROM contact ' +
                       'WHERE ASI_CRM_AccountAdditionalField__c = :outletId limit 1';
					   
		List<contact> theContact = (List<contact>) Database.query(query);
        return theContact.size() > 0 ? theContact.get(0).name : null;
    }
    
    private List<ASI_CRM_ContractTarget__c> retrieveContractTarget(Id contractId) {
        String query = 'SELECT ' + genQueryField(CONTRACT_TARGET_FIELD_MAP) +
                   ', ASI_CRM_SKU__r.ASI_HK_CRM_Pack_Factor__c, ASI_CRM_SKU__r.ASI_CRM_Short_Description__c, ASI_CRM_SKU__r.ASI_MFM_Sub_brand__r.ASI_MFM_Sub_brand_Description__c ' + 
                       'FROM ASI_CRM_ContractTarget__c ' +
                       'WHERE ASI_CRM_Contract__c = :contractId ' + 
                       'AND recordtype.developername = :CONTRACTTARGET_RECORD_TYPE ' + 
                       'ORDER By ASI_CRM_Sequence_No__c';
        return (List<ASI_CRM_ContractTarget__c>) Database.query(query);
    }
    
    private List<ASI_FOC_Free_Goods_Request__c> retrieveFOCHeader(Id contractId) {
      String query = 'SELECT ' + genQueryField(FOC_HEADER_FIELD_MAP) + ' ' + 
                       'FROM ASI_FOC_Free_Goods_Request__c ' +
                       'WHERE ASI_CRM_Contract__c = :contractId ';
        return (List<ASI_FOC_Free_Goods_Request__c>) Database.query(query);
    }
    
    private List<ASI_CRM_Payment_Schedule__c> retrievePaymentSchedule(Id contractId) {
        String query = 'SELECT ' + genQueryField(PAYMENT_SCHEDULE_FIELD_MAP) + 
                       ', RecordType.DeveloperName ' + 
                       'FROM ASI_CRM_Payment_Schedule__c ' +
                       'WHERE ASI_CRM_Contract__c = :contractId ' +
                       'AND recordtype.developername = :PAYMENTSCHEDULE_RECORD_TYPE ' +
					   'ORDER BY ASI_CRM_Schedule_Date__c asc NULLS FIRST, ASI_CRM_Percent_Achieved__c asc';
        return (List<ASI_CRM_Payment_Schedule__c>) Database.query(query);
    }
    
    private List<ASI_CRM_AccountsAdditionalField__c> retrieveCustomer() {
        String query = 'SELECT ' + genQueryField(CUSTOMER_FIELD_MAP) + 
                       ', RecordType.DeveloperName ' + 
                       'FROM ASI_CRM_AccountsAdditionalField__c ' + 
                       'WHERE RecordType.DeveloperName = :CUSTOMER_RECORD_TYPE_API_NAME ' +
					   'AND ASI_CRM_Active__c = TRUE';
        
      return (List<ASI_CRM_AccountsAdditionalField__c>) Database.query(query);
    }
   
    private List<ASI_CRM_AccountsAdditionalField__c> retrieveContractOutlets(Id parentOutlet) {
      String query = 'SELECT ' + genQueryField(CUSTOMER_FIELD_MAP) + 
                       ', RecordType.DeveloperName ' + 
                       'FROM ASI_CRM_AccountsAdditionalField__c ' + 
                       'WHERE ASI_CRM_CN_Parent_Outlet__c = :parentOutlet ';
        
      return (List<ASI_CRM_AccountsAdditionalField__c>) Database.query(query);
    }
    
    private List<ASI_CRM_AccountsAdditionalField__c> retrieveContractOutlets() {
      String query = 'SELECT ' + genQueryField(CUSTOMER_FIELD_MAP) + 
                       ', RecordType.DeveloperName ' + 
                       'FROM ASI_CRM_AccountsAdditionalField__c ' + 
                       'WHERE id in (' +
					   '  select ASI_CRM_SG_Customer__c ' +
					   '  from ASI_CRM_Contract_Outlets__c ' +
					   '  where ASI_CRM_SG_Contract__c = :contractId' +
                       '  AND recordtype.developername = :CONTRACTOUTLET_RECORD_TYPE ' +
					   ') ';
        
      return (List<ASI_CRM_AccountsAdditionalField__c>) Database.query(query);
    }
    
    /***************
  	Tools Function
  	***************/
    global static String genQueryField(Map<String, Schema.SObjectField> fieldMap) {
      String queryField = '';
      for(String fields : fieldMap.keySet()) {
        queryField += fields + ',';
      }
      return queryField.subString(0, queryField.length() - 1);
    }
    
    @TestVisible private String numberToWord(Integer num) {
        if(num < 20) {
          return to_19[num];
        }
        
        Integer tenNum   = num / 10;
        Integer digitNum = Math.mod(num, 10);
        
        if(digitNum == 0) {
          return tens[tenNum - 2];
        } else {
          return tens[tenNum - 2] + '-' + to_19[digitNum];
        }
        
        return '';
    }
    
    private String combineString(Set<String> stringSet, String connectedStr) {
      String combinedString = '';
        for(String str : stringSet) {
            if(String.isNotBlank(str)) {
              combinedString += str + connectedStr;
            }
        }
        return combinedString.removeEnd(connectedStr);
    }
    
    global static Object fromJsonString(String jsonString, System.Type apexType) {
        if(String.isBlank(jsonString)) {
            return null;
        }
        return System.JSON.deserialize(jsonString, apexType);
    }
	
	public static String doFormatting(Decimal val, integer dec, String tSep, String dSep) {
		String s, tmp;
		Integer i = 4 + dec;
	 
		// If the number of decimals is zero (0)... prevents the first 1000s seperator from being set at the 4th.
		if(dec==0){
			i--;
		}
	 
		s = val.setScale(dec).toPlainString().replace(tSep, dSep);
		while(s.length() > i) {
			tmp = s.substring(0, s.length() - i) + tSep + s.substring(s.length() - i);
			s = tmp;
			i += 4;
		}
	 
		// If the number is negative and has a number non-decimal digits divisible by 3, it prevents putting a comma before the 1st digit (ex -300,000.00  comes out -,300,000.00)
		if (s.substring(0,1) == '-') {
			if (s.substring(1,2) == tSep) {
				s = '-' + s.substring(2);
			}
		}
	 
		return s;
	}
}