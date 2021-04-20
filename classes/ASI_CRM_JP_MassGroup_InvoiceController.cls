/**********************************************************************************
 * Name : ASI_CRM_JP_MassGroup_Invoice
 * Created : DC @04/04/2016 12:56 PM
 * Revision History:
 * 1. 04/04/2016 - [DC 1.0] Created
 **********************************************************************************/

public with sharing class ASI_CRM_JP_MassGroup_InvoiceController {
    
    //private final static String INVOICE_STATUS = 'Approval in Progress';
    
    private String soqlQuery;
    private String invoiceRefNo;
    private String payTo;
    private String invoiceNo;
    private String invoiceDate;
    private String paymentDate;
    private String recordType;
    private String owner;

    private List<ASI_CRM_Payment_Invoice__c> lstPaymentInvoices;
    private Map<String, Decimal> mapGroupName_GroupAmount;
    private Map<String, List<ASI_CRM_Payment_Invoice__c>> mapGroupName_PaymentInvoices;

    private Set<String> INVOICE_STATUS = new Set<String> {
        'Approval in Progress',
        'Verified by SA'
    };
    private Set<String> setRecordTypeDevNames = new Set<String> {
        'ASI_CRM_JP_SPTD_Cash_Invoice_Read_Only',
        'ASI_CRM_JP_Cash_Invoice_Read_Only'
    };

    public List<InvoiceWrapper> lstPaymentInvoiceWrappers {get; set;}
    public Set<Integer> errorLineNumberSet {get; set;}

    public String sortDir {
        get {
            if(sortDir == null) {
                sortDir = 'ASC';
            }
            return sortDir;
        }
        set;
    }

    public String sortField {
        get {
            if(sortField == null) {
                sortField = 'Name';
            }
            return sortField;
        }
        set;
    }

    public ASI_CRM_JP_MassGroup_InvoiceController(ApexPages.StandardController con) {
    }

    public void init() {
    }
    
    private void clearResult() {
        lstPaymentInvoiceWrappers = new List<InvoiceWrapper>();
        mapGroupName_GroupAmount = new Map<String, Decimal>();
        mapGroupName_PaymentInvoices = new Map<String, List<ASI_CRM_Payment_Invoice__c>>();
    }
    
    private void runQuery() {
        if(String.isBlank(soqlQuery)) {
            ApexPages.addMessage( new ApexPages.Message(
                ApexPages.Severity.ERROR,
                Label.ASI_CRM_JP_MassGroup_Invoice_PageError
            ));

            return;
        }

        try {
            lstPaymentInvoices = Database.query(soqlQuery);
        } catch(QueryException exceptionInstance) {
            ApexPages.addMessage( new ApexPages.Message(
                ApexPages.Severity.ERROR,
                exceptionInstance.getMessage()
            ));
        }
        
        if(lstPaymentInvoices == NULL) {
            ApexPages.addMessage( new ApexPages.Message(
                ApexPages.Severity.ERROR,
                Label.ASI_CRM_JP_MassGroup_Invoice_FetchingError
            ));

            return;
        }
        
        for(ASI_CRM_Payment_Invoice__c invoiceIterator : lstPaymentInvoices) {
            
            lstPaymentInvoiceWrappers.add(new InvoiceWrapper(false, invoiceIterator));

            if(String.isBlank(invoiceIterator.ASI_CRM_JDE_Group_Name__c)) {
                continue;
            }

            if( !mapGroupName_GroupAmount.containsKey(invoiceIterator.ASI_CRM_JDE_Group_Name__c.toLowerCase()) ) {

                mapGroupName_GroupAmount.put(
                    invoiceIterator.ASI_CRM_JDE_Group_Name__c.toLowerCase(),
                    invoiceIterator.ASI_CRM_Total_Invoice_Amount__c
                );

            } else {
                mapGroupName_GroupAmount.put(
                    invoiceIterator.ASI_CRM_JDE_Group_Name__c.toLowerCase(),
                    mapGroupName_GroupAmount.get(invoiceIterator.ASI_CRM_JDE_Group_Name__c.toLowerCase())
                        + invoiceIterator.ASI_CRM_Total_Invoice_Amount__c
                );
            }

            if( !mapGroupName_PaymentInvoices.containsKey(invoiceIterator.ASI_CRM_JDE_Group_Name__c.toLowerCase()) ) {

                mapGroupName_PaymentInvoices.put(
                    invoiceIterator.ASI_CRM_JDE_Group_Name__c.toLowerCase(),
                    new List<ASI_CRM_Payment_Invoice__c> {invoiceIterator}
                );

            } else {
                mapGroupName_PaymentInvoices.get(invoiceIterator.ASI_CRM_JDE_Group_Name__c.toLowerCase())
                                            .add(invoiceIterator);
            }
        }

        for(InvoiceWrapper wrapperIterator : lstPaymentInvoiceWrappers) {

            if(String.isBlank(wrapperIterator.invoinceInstance.ASI_CRM_JDE_Group_Name__c)) {
                wrapperIterator.groupAmount = 0.0;
            } else if(mapGroupName_GroupAmount.containsKey(wrapperIterator.invoinceInstance.ASI_CRM_JDE_Group_Name__c.toLowerCase())) {
                wrapperIterator.groupAmount = mapGroupName_GroupAmount.get(wrapperIterator.invoinceInstance.ASI_CRM_JDE_Group_Name__c.toLowerCase());
            }

        }
    }
    
    //check is number of record over 700 
    public Boolean isNumberOfRecordOverLimit(String filterString) {
        String countQuery = 'SELECT count() from ASI_CRM_Payment_Invoice__c';
        countQuery += ' WHERE RecordType.DeveloperName IN : setRecordTypeDevNames';
        countQuery += ' AND ASI_CRM_Status__c = : INVOICE_STATUS';
        countQuery += filterString;        
        
        Integer recordCount = database.countQuery(countQuery);
        
        return (recordCount > 700);
    }
    
    private String createFilter(String invoiceRefNo, String payTo, String invoiceNo, String invoiceDate, String paymentDate, String recordType, String owner) {
        String filterString = '';
        
        String[] str;
        Datetime searchDate;
        
        if (!String.isBlank(invoiceRefNo))
            filterString += ' AND Name LIKE \'%'+String.escapeSingleQuotes(invoiceRefNo)+'%\'';
        
        if (!String.isBlank(payTo))
            filterString += ' AND ASI_CRM_Pay_To__r.Name LIKE \'%'+String.escapeSingleQuotes(payTo)+'%\'';
        
        if (!String.isBlank(invoiceNo))
            filterString += ' AND ASI_CRM_Invoice_No__c LIKE \'%'+String.escapeSingleQuotes(invoiceNo)+'%\'';
        
        if (!String.isBlank(invoiceDate)) {
            str = invoiceDate.split('-');
            searchDate = Datetime.newInstance(Integer.valueOf(str[0]),Integer.valueOf(str[1]),Integer.valueOf(str[2]),0,0,0);
            filterString += ' AND ASI_CRM_Invoice_Date__c = ' + searchDate.format('yyyy-MM-dd') ;
        }
        
        if (!String.isBlank(paymentDate)) {
            str = paymentDate.split('-');
            searchDate = Datetime.newInstance(Integer.valueOf(str[0]),Integer.valueOf(str[1]),Integer.valueOf(str[2]),0,0,0);
            filterString += ' AND ASI_CRM_Payment_Date__c = ' + searchDate.format('yyyy-MM-dd');
        }

        if (!String.isBlank(recordType)) {
            filterString += ' AND RecordType.DeveloperName = \''+String.escapeSingleQuotes(recordType)+'\'';
        } else {
            filterString += ' AND RecordType.DeveloperName IN : setRecordTypeDevNames';
        }
        
        if (!String.isBlank(owner))
            filterString += ' AND ASI_CRM_Owner__c LIKE \'%'+String.escapeSingleQuotes(owner)+'%\'';
        
        return filterString;
    }
    
    //search function
    public PageReference runSearch() {
        
        clearResult();
        
        invoiceRefNo = Apexpages.currentPage().getParameters().get('invoiceRefNo');
        payTo = Apexpages.currentPage().getParameters().get('payTo');
        invoiceNo = Apexpages.currentPage().getParameters().get('invoiceNo');
        invoiceDate = Apexpages.currentPage().getParameters().get('invoiceDate');
        paymentDate = Apexpages.currentPage().getParameters().get('paymentDate');
        recordType = Apexpages.currentPage().getParameters().get('recordType');
        owner = Apexpages.currentPage().getParameters().get('owner');
        
        String filterString = createFilter(invoiceRefNo, payTo, invoiceNo, invoiceDate, paymentDate, recordType, owner);
        if(!isNumberOfRecordOverLimit(filterString)) {
            soqlQuery = 'SELECT RecordType.Name, ';
            soqlQuery += 'Id, Name, ASI_CRM_Total_Invoice_Amount__c, ASI_CRM_Pay_To__c, ASI_CRM_Invoice_No__c, ASI_CRM_Invoice_Date__c, ASI_CRM_Payment_Date__c, ';
            soqlQuery += 'ASI_CRM_G_L_Date__c, ASI_CRM_Journal_Voucher__c, ASI_CRM_No_of_Lines_A_P_Vs_Rebate__c, ASI_CRM_Owner__c, ASI_CRM_JDE_Group_Name__c';
            soqlQuery += ' FROM ASI_CRM_Payment_Invoice__c'
                       + ' WHERE RecordType.DeveloperName IN : setRecordTypeDevNames'
                       + ' AND ASI_CRM_Status__c = : INVOICE_STATUS';
            soqlQuery += filterString;
    
            runQuery();
            System.debug('------ SOQL QUERY ------ : '+ soqlQuery);
        } else {
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.INFO, Label.ASI_CRM_JP_MassGroup_Invoice_RecordLimit));
        }
        return null;
    }
    
    public void save(){
        errorLineNumberSet = new Set<Integer>();
        
        List<ASI_CRM_Payment_Invoice__c> lstPaymentInvoices_ToUpdate =
            new List<ASI_CRM_Payment_Invoice__c>();

        for(InvoiceWrapper wrapperIterator : lstPaymentInvoiceWrappers) {
            lstPaymentInvoices_ToUpdate.add(wrapperIterator.invoinceInstance);
        }
        try {
            if( !lstPaymentInvoices_ToUpdate.isEmpty() ) {
                update lstPaymentInvoices_ToUpdate;
                ApexPages.addMessage( new ApexPages.Message(
                            ApexPages.Severity.INFO,
                            Label.ASI_CRM_JP_MassGroup_Invoice_ChangeSave));
            }
            
        }catch(DmlException e) {
            String error = '';
            for(Integer i = 0 ; i < e.getNumDml() ; i++) {
                errorLineNumberSet.add(e.getDmlIndex(i));
            }
        }
    
    }
    
    public void massGroupRecords() {
        errorLineNumberSet = new Set<Integer>();

        Boolean isNewGroup = false;
        String groupName;
        List<ASI_CRM_Payment_Invoice__c> lstPaymentInvoices_ToUpdate =
            new List<ASI_CRM_Payment_Invoice__c>();

        for(InvoiceWrapper wrapperIterator : lstPaymentInvoiceWrappers) {
            
            if(wrapperIterator.isSelected == true) {
                lstPaymentInvoices_ToUpdate.add(wrapperIterator.invoinceInstance);
                
            }
        }

        try {
            if( !lstPaymentInvoices_ToUpdate.isEmpty() ) {

                // DC - 04/25/2016 - Added null check for "JDE Group Name"
                if(String.isBlank(lstPaymentInvoices_ToUpdate[0].ASI_CRM_JDE_Group_Name__c)) {
                    groupName = '';
                } else {
                    groupName = lstPaymentInvoices_ToUpdate[0].ASI_CRM_JDE_Group_Name__c.toLowerCase();
                }

                System.debug('------ groupName ------ : ' + groupName);
                String lastInvoiceNo = lstPaymentInvoices_ToUpdate[0].ASI_CRM_Invoice_No__c;
                Id lastPayTo = lstPaymentInvoices_ToUpdate[0].ASI_CRM_Pay_To__c;
                Date lastPmtDate = lstPaymentInvoices_ToUpdate[0].ASI_CRM_Payment_Date__c;
                Date lastInvDate = lstPaymentInvoices_ToUpdate[0].ASI_CRM_Invoice_Date__c;
                Date lastGLDate = lstPaymentInvoices_ToUpdate[0].ASI_CRM_G_L_Date__c;
                Boolean lastJV = lstPaymentInvoices_ToUpdate[0].ASI_CRM_Journal_Voucher__c;
                Boolean isSameGroup = true;
                for(ASI_CRM_Payment_Invoice__c invoiceIterator : lstPaymentInvoices_ToUpdate) {
                    if(invoiceIterator.ASI_CRM_Invoice_No__c != lastInvoiceNo ||
                            invoiceIterator.ASI_CRM_Pay_To__c != lastPayTo ||
                            invoiceIterator.ASI_CRM_Payment_Date__c != lastPmtDate ||
                            invoiceIterator.ASI_CRM_Invoice_Date__c != lastInvDate ||
                            invoiceIterator.ASI_CRM_G_L_Date__c != lastGLDate ||
                            invoiceIterator.ASI_CRM_Journal_Voucher__c != lastJV){
                        ApexPages.addMessage( new ApexPages.Message(
                            ApexPages.Severity.ERROR,
                            Label.ASI_CRM_JP_MassGroup_Invoice_InvoiceNotMatch));
                        isSameGroup = false;
                        break;
                    }
                    if( String.isBlank(groupName) ) {
                        isNewGroup = true;
                        //break;
                    } else if( !groupName.equalsIgnoreCase(invoiceIterator.ASI_CRM_JDE_Group_Name__c) ) {
                        isNewGroup = true;
                        //break;
                    }
                }

                if( String.isNotBlank(groupName)
                &&  isNewGroup == false
                &&  mapGroupName_PaymentInvoices.containsKey(groupName)
                &&  mapGroupName_PaymentInvoices.get(groupName).size() == lstPaymentInvoices_ToUpdate.size()) {

                    ApexPages.addMessage( new ApexPages.Message(
                        ApexPages.Severity.ERROR,
                        Label.ASI_CRM_JP_MassGroup_Invoice_CompletedGroup)); // DC - Please provide appropriate message.

                } else if(mapGroupName_PaymentInvoices.containsKey(groupName)
                       && mapGroupName_PaymentInvoices.get(groupName).size() != lstPaymentInvoices_ToUpdate.size()) {
                    isNewGroup = true;
                }

                if(isNewGroup == true && isSameGroup == true) {

                    ASI_CRM_JP_AssignJdeGroupName_Invoice groupNameGenerator = new ASI_CRM_JP_AssignJdeGroupName_Invoice();
                    lstPaymentInvoices_ToUpdate = groupNameGenerator.assignGroupName(lstPaymentInvoices_ToUpdate);

                    update lstPaymentInvoices_ToUpdate;
                }
            }
        } catch(DmlException e) {
            String error = '';
            for(Integer i = 0 ; i < e.getNumDml() ; i++) {
                errorLineNumberSet.add(e.getDmlIndex(i));
            }
        }
        //init();
        //runSearch();
    }

    public void toggleSort() {

        clearResult();
        
        sortDir = sortDir.equalsIgnoreCase('ASC') ? 'DESC' : 'ASC';
		String filterString = createFilter(invoiceRefNo, payTo, invoiceNo, invoiceDate, paymentDate, recordType, owner);
        soqlQuery = 'SELECT RecordType.Name, ';
       	soqlQuery += 'Id, Name, ASI_CRM_Total_Invoice_Amount__c, ASI_CRM_Pay_To__c, ASI_CRM_Invoice_No__c, ASI_CRM_Invoice_Date__c, ASI_CRM_Payment_Date__c, ';
       	soqlQuery += 'ASI_CRM_G_L_Date__c, ASI_CRM_Journal_Voucher__c, ASI_CRM_No_of_Lines_A_P_Vs_Rebate__c, ASI_CRM_Owner__c, ASI_CRM_JDE_Group_Name__c';
      	soqlQuery += ' FROM ASI_CRM_Payment_Invoice__c'
                  + ' WHERE RecordType.DeveloperName IN : setRecordTypeDevNames'
                  + ' AND ASI_CRM_Status__c = : INVOICE_STATUS';
        soqlQuery += filterString;
        soqlQuery = soqlQuery + ' ORDER BY ' + sortField + ' ' + sortDir;

        runQuery();
    }

    public class InvoiceWrapper {

        public Boolean isSelected {get; set;}
        public Decimal groupAmount {get; set;}
        public ASI_CRM_Payment_Invoice__c invoinceInstance {get; set;}

        public InvoiceWrapper(Boolean pIsSelected, ASI_CRM_Payment_Invoice__c pInvoinceInstance) {

            isSelected = pIsSelected;
            groupAmount = 0.0;
            invoinceInstance = pInvoinceInstance;

        }
    }
}