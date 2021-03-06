//Generated by wsdl2apex

public class LAT_ReceiptHandelerTypes {

    public class listDocuments_element {
        public LAT_ReceiptHandelerTypes.DocumentType[] document;
        private String[] document_type_info = new String[]{'document','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'0','-1','true'};
        private String[] apex_schema_type_info = new String[]{'http://www.pernod-ricard.com/CollectionManagerSFDCReq/','false','false'};
        private String[] field_order_type_info = new String[]{'document'};
    }

    public class listTaxCertificates_element {
        public LAT_ReceiptHandelerTypes.TaxCertificateType[] taxCertificate;
        private String[] taxCertificate_type_info = new String[]{'taxCertificate','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'0','-1','true'};
        private String[] apex_schema_type_info = new String[]{'http://www.pernod-ricard.com/CollectionManagerSFDCReq/','false','false'};
        private String[] field_order_type_info = new String[]{'taxCertificate'};
    }
public class ValueType {
        public String chequeNo;
        public String accType;
        public Decimal amount;
        public String bank;
        public String branch;
        public String comment;
        public Date dueDate;
        public Date issueDate;
        public String receiptNo;
        public String valueType;
        public String taxCode;
        public String idCRMval;
        public String depositBankSlipNo;
        public String depositBank;
        public String depositBranch;
        public String depositAccountType;
        public String docCo;
        public String docType;
        public String docNo;
        private String[] chequeNo_type_info = new String[]{'chequeNo','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'1','1','false'};
        private String[] accType_type_info = new String[]{'accType','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'1','1','false'};
        private String[] amount_type_info = new String[]{'amount','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'1','1','false'};
        private String[] bank_type_info = new String[]{'bank','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'1','1','false'};
        private String[] branch_type_info = new String[]{'branch','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'1','1','false'};
        private String[] comment_type_info = new String[]{'comment','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'1','1','false'};
        private String[] dueDate_type_info = new String[]{'dueDate','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'1','1','false'};
        private String[] issueDate_type_info = new String[]{'issueDate','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'1','1','false'};
        private String[] receiptNo_type_info = new String[]{'receiptNo','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'1','1','false'};
        private String[] valueType_type_info = new String[]{'valueType','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'1','1','false'};
        private String[] taxCode_type_info = new String[]{'taxCode','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'1','1','false'};
        private String[] idCRMval_type_info = new String[]{'idCRMval','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'1','1','false'};
        private String[] depositBankSlipNo_type_info = new String[]{'depositBankSlipNo','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'1','1','false'};
        private String[] depositBank_type_info = new String[]{'depositBank','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'1','1','false'};
        private String[] depositBranch_type_info = new String[]{'depositBranch','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'1','1','false'};
        private String[] depositAccountType_type_info = new String[]{'depositAccountType','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'1','1','false'};
        private String[] docCo_type_info = new String[]{'docCo','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'1','1','false'};
        private String[] docType_type_info = new String[]{'docType','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'1','1','false'};
        private String[] docNo_type_info = new String[]{'docNo','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.pernod-ricard.com/CollectionManagerSFDCReq/','false','false'};
        private String[] field_order_type_info = new String[]{'chequeNo','accType','amount','bank','branch','comment','dueDate','issueDate','receiptNo','valueType','taxCode','idCRMval','depositBankSlipNo','depositBank','depositBranch','depositAccountType','docCo','docType','docNo'};
    }
    public class CollectionManager_element {
        public LAT_ReceiptHandelerTypes.ClientInfoType clientInfo;
        public LAT_ReceiptHandelerTypes.ReceiptType arguments;
        private String[] clientInfo_type_info = new String[]{'clientInfo','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'1','1','false'};
        private String[] arguments_type_info = new String[]{'arguments','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.pernod-ricard.com/CollectionManagerSFDCReq/','false','false'};
        private String[] field_order_type_info = new String[]{'clientInfo','arguments'};
    }
    
    public class invoiceList_element {
        public LAT_ReceiptHandelerTypes.InvoiceDetailType[] invoiceDetail;
        private String[] invoiceDetail_type_info = new String[]{'invoiceDetail','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'0','-1','true'};
        private String[] apex_schema_type_info = new String[]{'http://www.pernod-ricard.com/CollectionManagerSFDCReq/','false','false'};
        private String[] field_order_type_info = new String[]{'invoiceDetail'};
    }
    
    public class DepositType {
        public String bankSlipNo;
        public String accType;
        public Decimal amount;
        public String bank;
        public String branch;
        public String comment;
        public DateTime depDate;
        public String receiptNo;
        public String idCRMdep;
        private String[] bankSlipNo_type_info = new String[]{'bankSlipNo','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'1','1','false'};
        private String[] accType_type_info = new String[]{'accType','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'1','1','false'};
        private String[] amount_type_info = new String[]{'amount','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'1','1','false'};
        private String[] bank_type_info = new String[]{'bank','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'1','1','false'};
        private String[] branch_type_info = new String[]{'branch','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'1','1','false'};
        private String[] comment_type_info = new String[]{'comment','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'1','1','false'};
        private String[] depDate_type_info = new String[]{'depDate','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'1','1','false'};
        private String[] receiptNo_type_info = new String[]{'receiptNo','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'1','1','false'};
        private String[] idCRMdep_type_info = new String[]{'idCRMdep','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.pernod-ricard.com/CollectionManagerSFDCReq/','false','false'};
        private String[] field_order_type_info = new String[]{'bankSlipNo','accType','amount','bank','branch','comment','depDate','receiptNo','idCRMdep'};
    }
    public class listValues_element {
        public LAT_ReceiptHandelerTypes.ValueType[] value;
        private String[] value_type_info = new String[]{'value','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'0','-1','true'};
        private String[] apex_schema_type_info = new String[]{'http://www.pernod-ricard.com/CollectionManagerSFDCReq/','false','false'};
        private String[] field_order_type_info = new String[]{'value'};
    }
    public class ReceiptType {
        public String actionCode;
        public String receiptNo;
        public Double receiptAmount;
        public String receiptCurrency;
        public String receiptCompany;
        public Decimal amountsControl;
        public String clientAN8;
        public String idCRM;
        public String depositAccountType;
        public String collectionAgent;
        public String comment;
        public String customerPaymentOrder;
        public Date recDate;
        public Decimal debit;
        public Decimal depositsAmount;
        public Decimal discount;
        public Decimal documentsAmount;
        public Decimal downpayments;
        public Integer manualReceiptNumber;
        public DateTime redemptionDateTime;
        public String redemptionNo;
        public String status;
        public Decimal valuesAmount;
        public Decimal withholdingsAmount;
        public LAT_ReceiptHandelerTypes.listDeposits_element listDeposits;
        public LAT_ReceiptHandelerTypes.listValues_element listValues;
        public LAT_ReceiptHandelerTypes.listTaxCertificates_element listTaxCertificates;
        public LAT_ReceiptHandelerTypes.invoiceList_element invoiceList;
        public LAT_ReceiptHandelerTypes.listDocuments_element listDocuments;
        private String[] actionCode_type_info = new String[]{'actionCode','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'1','1','false'};
        private String[] receiptNo_type_info = new String[]{'receiptNo','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'1','1','false'};
        private String[] receiptCurrency_type_info = new String[]{'receiptCurrency','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'1','1','false'};
        private String[] receiptCompany_type_info = new String[]{'receiptCompany','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'1','1','false'};
        private String[] receiptAmount_type_info = new String[]{'receiptAmount','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'1','1','false'};
        private String[] amountsControl_type_info = new String[]{'amountsControl','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'1','1','false'};
        private String[] clientAN8_type_info = new String[]{'clientAN8','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'1','1','false'};
        private String[] idCRM_type_info = new String[]{'idCRM','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'1','1','false'};
        private String[] depositAccountType_type_info = new String[]{'depositAccountType','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'1','1','false'};
        private String[] collectionAgent_type_info = new String[]{'collectionAgent','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'1','1','false'};
        private String[] comment_type_info = new String[]{'comment','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'1','1','false'};
        private String[] customerPaymentOrder_type_info = new String[]{'customerPaymentOrder','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'1','1','false'};
        private String[] recDate_type_info = new String[]{'recDate','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'1','1','false'};
        private String[] debit_type_info = new String[]{'debit','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'1','1','false'};
        private String[] depositsAmount_type_info = new String[]{'depositsAmount','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'1','1','false'};
        private String[] discount_type_info = new String[]{'discount','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'1','1','false'};
        private String[] documentsAmount_type_info = new String[]{'documentsAmount','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'1','1','false'};
        private String[] downpayments_type_info = new String[]{'downpayments','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'1','1','false'};
        private String[] manualReceiptNumber_type_info = new String[]{'manualReceiptNumber','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'1','1','false'};
        private String[] redemptionDateTime_type_info = new String[]{'redemptionDateTime','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'1','1','false'};
        private String[] redemptionNo_type_info = new String[]{'redemptionNo','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'1','1','false'};
        private String[] status_type_info = new String[]{'status','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'1','1','false'};
        private String[] valuesAmount_type_info = new String[]{'valuesAmount','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'1','1','false'};
        private String[] withholdingsAmount_type_info = new String[]{'withholdingsAmount','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'1','1','false'};
        private String[] listDeposits_type_info = new String[]{'listDeposits','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'1','1','false'};
        private String[] listValues_type_info = new String[]{'listValues','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'1','1','false'};
        private String[] listTaxCertificates_type_info = new String[]{'listTaxCertificates','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'1','1','false'};
        private String[] invoiceList_type_info = new String[]{'invoiceList','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'1','1','false'};
        private String[] listDocuments_type_info = new String[]{'listDocuments','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.pernod-ricard.com/CollectionManagerSFDCReq/','false','false'};
        
        private String[] field_order_type_info = new String[]{'actionCode','receiptNo','receiptAmount','receiptCurrency','receiptCompany','amountsControl','clientAN8','idCRM','depositAccountType','collectionAgent','comment','customerPaymentOrder','recDate','debit','depositsAmount','discount','documentsAmount','downpayments','manualReceiptNumber','redemptionDateTime','redemptionNo','status','valuesAmount','withholdingsAmount','listDeposits','listValues','listTaxCertificates','invoiceList','listDocuments'};
        //private String[] field_order_type_info = new String[]{'actionCode','receiptNo','receiptAmount','receiptCurrency','receiptCompany','amountsControl','clientAN8','idCRM','depositAccountType','collectionAgent','comment','customerPaymentOrder','recDate','debit','depositsAmount','discount','documentsAmount','downpayments','manualReceiptNumber','redemptionDateTime','redemptionNo','status','valuesAmount','withholdingsAmount','listDeposits','listValues','listTaxCertificates','listDocuments'};
    }
    public class ClientInfoType {
        public String system_x;
        public String systemUserID;
        public String remoteHostIP;
        public String country;
        public DateTime time_x;
        private String[] system_x_type_info = new String[]{'system','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'1','1','false'};
        private String[] systemUserID_type_info = new String[]{'systemUserID','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'1','1','false'};
        private String[] remoteHostIP_type_info = new String[]{'remoteHostIP','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'1','1','false'};
        private String[] country_type_info = new String[]{'country','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'1','1','false'};
        private String[] time_x_type_info = new String[]{'time','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.pernod-ricard.com/CollectionManagerSFDCReq/','false','false'};
        private String[] field_order_type_info = new String[]{'system_x','systemUserID','remoteHostIP','country','time_x'};
    }
    public class CollectionManagerResponse_element {
        public Integer code;
        public String description;
        private String[] code_type_info = new String[]{'code','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'1','1','false'};
        private String[] description_type_info = new String[]{'description','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.pernod-ricard.com/CollectionManagerSFDCReq/','false','false'};
        private String[] field_order_type_info = new String[]{'code','description'};
    }
    public class listDeposits_element {
        public LAT_ReceiptHandelerTypes.DepositType[] deposit;
        private String[] deposit_type_info = new String[]{'deposit','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'0','-1','true'};
        private String[] apex_schema_type_info = new String[]{'http://www.pernod-ricard.com/CollectionManagerSFDCReq/','false','false'};
        private String[] field_order_type_info = new String[]{'deposit'};
    }
    
    public class DocumentType {
        public String idCRMdoc;
        public String idCRMval;
        public String legalInvoice;
        public String receiptNo; 
        public String docCo;
        public String docType;
        public String docNo;
        public String paymentItem;
        public String docAmountApply;
        public String docExplanation;
        private String[] idCRMdoc_type_info = new String[]{'idCRMdoc','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'1','1','false'};
        private String[] idCRMval_type_info = new String[]{'idCRMval','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'1','1','false'};
        private String[] legalInvoice_type_info = new String[]{'legalInvoice','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'1','1','false'};
        private String[] receiptNo_type_info = new String[]{'receiptNo','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.pernod-ricard.com/CollectionManagerSFDCReq/','false','false'};
        private String[] docCo_type_info = new String[]{'docCo','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'1','1','false'};
        private String[] docType_type_info = new String[]{'docType','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'1','1','false'};
        private String[] docNo_type_info = new String[]{'docNo','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'1','1','false'};
        private String[] paymentItem_type_info = new String[]{'paymentItem','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'1','1','false'};
        private String[] docAmountApply_type_info = new String[]{'docAmountApply','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'1','1','false'};
        private String[] docExplanation_type_info = new String[]{'docExplanation','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'1','1','false'};
        
        private String[] field_order_type_info = new String[]{'idCRMdoc','idCRMval','legalInvoice','receiptNo','docCo','docType','docNo','paymentItem','docAmountApply','docExplanation'};
    }
    
    public class TaxCertificateType {
        public String certificateNo;
        public Decimal amount;
        public String comment;
        public DateTime taxDate;
        public String rateRate;
        public String receiptNo;
        public Decimal taxableAmount;
        public String valueType;
        public String idCRMtax;
        private String[] certificateNo_type_info = new String[]{'certificateNo','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'1','1','false'};
        private String[] amount_type_info = new String[]{'amount','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'1','1','false'};
        private String[] comment_type_info = new String[]{'comment','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'1','1','false'};
        private String[] taxDate_type_info = new String[]{'taxDate','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'1','1','false'};
        private String[] rateRate_type_info = new String[]{'rateRate','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'1','1','false'};
        private String[] receiptNo_type_info = new String[]{'receiptNo','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'1','1','false'};
        private String[] taxableAmount_type_info = new String[]{'taxableAmount','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'1','1','false'};
        private String[] valueType_type_info = new String[]{'valueType','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'1','1','false'};
        private String[] idCRMtax_type_info = new String[]{'idCRMtax','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.pernod-ricard.com/CollectionManagerSFDCReq/','false','false'};
        private String[] field_order_type_info = new String[]{'certificateNo','amount','comment','taxDate','rateRate','receiptNo','taxableAmount','valueType','idCRMtax'};
    }
     public class InvoiceDetailType {
        public String idCRMdoc;
        public String invoiceType;
        public String invoiceNumber;
        public String invoiceAmount;
        public String invoiceExplanation;
        public String invoiceTaxAmount;
        public String invoiceTaxableAmount;
        public String idCRMval;
        private String[] idCRMdoc_type_info = new String[]{'idCRMdoc','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'1','1','false'};
        private String[] invoiceType_type_info = new String[]{'invoiceType','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'1','1','false'};
        private String[] invoiceNumber_type_info = new String[]{'invoiceNumber','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'1','1','false'};
        private String[] invoiceAmount_type_info = new String[]{'invoiceAmount','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'1','1','false'};
        private String[] invoiceExplanation_type_info = new String[]{'invoiceExplanation','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'1','1','false'};
        private String[] invoiceTaxAmount_type_info = new String[]{'invoiceTaxAmount','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'1','1','false'};
        private String[] invoiceTaxableAmount_type_info = new String[]{'invoiceTaxableAmount','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.pernod-ricard.com/CollectionManagerSFDCReq/','false','false'};
        private String[] idCRMval_type_info = new String[]{'idCRMval','http://www.pernod-ricard.com/CollectionManagerSFDCReq/',null,'1','1','false'};
        private String[] field_order_type_info = new String[]{'idCRMdoc','idCRMval' ,'invoiceType','invoiceNumber','invoiceAmount','invoiceExplanation','invoiceTaxAmount','invoiceTaxableAmount'};
    }
    public class CollectionManagerSFDCReqSOAPQSPort {
        //public String endpoint_x = 'http://cawlkl01.pramericas.com:8011/SFDC/Collection/CollectionManagerSFDCReq';
        public String endpoint_x;
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x;
        private String[] ns_map_type_info = new String[]{'http://www.pernod-ricard.com/CollectionManagerSFDCReq/', 'LAT_ReceiptHandelerTypes'};
        public LAT_ReceiptHandelerTypes.CollectionManagerResponse_element CollectionManager(LAT_ReceiptHandelerTypes.ClientInfoType clientInfo,LAT_ReceiptHandelerTypes.ReceiptType arguments) {
            LAT_ReceiptHandelerTypes.CollectionManager_element request_x = new LAT_ReceiptHandelerTypes.CollectionManager_element();
            request_x.clientInfo = clientInfo;
            request_x.arguments = arguments;
            
            CS001_JDEInterfaceCredentials__c cred = LAT_WS_Utils.getHeaderKey(ClientInfo.country);


            this.inputHttpHeaders_x = new Map <String, String>();
            this.inputHttpHeaders_x.put('mashery_mule_secret_key', cred.MASHERY_HEADER_KEY__c);


            //Blob headerValue = Blob.valueOf('pr-eu/eurs1appbiztalk' + ':' + 'Password56');
            Blob headerValue = Blob.valueOf(cred.Bridge_Username__c + ':' + cred.Bridge_Password__c);
            String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
            this.inputHttpHeaders_x.put('Authorization', authorizationHeader);
            
            //this.inputHttpHeaders_x.put('Authorization', 'Basic <span style="font-family: Courier;font-size: 11px">cHItZXUvZXVyczFhcHBiaXp0YWxrOlBhc3N3b3JkNTY=</span>');
            
            LAT_ReceiptHandelerTypes.CollectionManagerResponse_element response_x;
            Map<String, LAT_ReceiptHandelerTypes.CollectionManagerResponse_element> response_map_x = new Map<String, LAT_ReceiptHandelerTypes.CollectionManagerResponse_element>();
            response_map_x.put('response_x', response_x);
             
            //EndPoint parameterizable
           try{endpoint_x = cred.EndPoint_ReceiptHandeler__c;}catch(exception e){}
           //try{endpoint_x = 'https://bridge.pernod-ricard-europe.com/BRIDGE.SALESFORCE.WS.EXTERNAL/CollectionManager.svc';}catch(exception e){}

           try
           {
              if(!test.isRunningTest()){
                System.debug('$$$$$$$$  this :' + this); 
                System.debug('$$$$$$$$  request_x :' + request_x); 
                System.debug('$$$$$$$$  response_map_x :' + response_map_x); 
                System.debug('$$$$$$$$  endpoint_x :' + endpoint_x); 
                WebServiceCallout.invoke(
                  this,
                  request_x,
                  response_map_x,
                  new String[]{endpoint_x,
                  'http://www.pernod-ricard.com/CollectionManagerSFDCReq/CollectionManager',
                  'http://www.pernod-ricard.com/CollectionManagerSFDCReq/',
                  'CollectionManager',
                  'http://www.pernod-ricard.com/CollectionManagerSFDCReq/',
                  'CollectionManagerResponse',
                  'LAT_ReceiptHandelerTypes.CollectionManagerResponse_element'}
                );
                response_x = response_map_x.get('response_x');
                return response_x;
            }else{
                response_x = new LAT_ReceiptHandelerTypes.CollectionManagerResponse_element();
                response_x.code = 0;
                response_x.description = 'ok';
                return response_x;
            }
           }
           catch (Exception ex)
           {
                System.debug('Exxxx ' + ex);
                return null;
           }
          
            
        }
    }
}