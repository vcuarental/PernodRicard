/*********************************************************************************
 * Name: ASI_CRM_SG_FillAdditionalInfoOutletCtrl
 * Description: Controller for ASI_CRM_SG_FillAdditionalInfoForOutlet VF page
 * Test Class: ASI_CRM_SG_FillAddnlInfoOutletCtrlTest
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2015-12-28       IPC: DC                 Created
 * 2016-02-25       Laputa: Vincent         [VL 1.0] Remove Category Code 13 and Local Channel field
 * 2020-05-06       Wilken Lee              [WL 2.0] Increase page size to 60
 */
public with sharing class ASI_CRM_SG_FillAdditionalInfoOutletCtrl {

    protected Integer totalNumOfRecord;
    public Integer numOfRowInTable;
    public Integer LimitFrom;
    private String soql {get;set;}
    public String PO_Number;
    public String PO_Line_Number;
    public String Suppliers;
    public String GLdates;

    public ASI_CRM_SG_FillAdditionalInfoOutletCtrl(ApexPages.StandardController controller){
        soql = 'SELECT id,' 
             + '       name,'
             + '       ASI_CRM_ToJDE__c,'
             + '       ASI_CRM_SG_Customer_Price_Group__c,'
             + '       ASI_CRM_SG_Search_Type__c,'
             + '       ASI_CRM_Business_Registration_Number__c,'
             + '       ASI_CRM_SG_Business_Unit__c,'
             + '       ASI_CRM_SG_AR_Account_Type__c,'
             + '       ASI_CRM_SG_MKT_Responsible__c,'
             + '       ASI_CRM_SG_GDF_Country__c,'
            /* [VL 1.0] BEGIN */
            /*
             + '       ASI_CRM_SG_Local_Channel__c,'
            */
            /* [VL 1.0] END */
             + '       ASI_CRM_SG_CCC_Location__c,'
             + '       ASI_CRM_SG_Base_Price_Group_Bank_Name__c,'
             + '       ASI_CRM_SG_A_B_Amount_Codes__c,'
            /* [VL 1.0] BEGIN */
            /*
             + '       ASI_CRM_SG_Category_Code_13__c,'
            */
            /* [VL 1.0] END */
             + '       ASI_CRM_SG_Statement_Cycle__c,'
             + '       ASI_CRM_SG_Payment_Terms_A_R__c,'
             + '       ASI_CRM_SG_Tax_Rate_Area__c,'
             + '       ASI_CRM_SG_Send_Statement_To__c,'
             + '       ASI_CRM_SG_Batch_Processing_Mode__c,'
             + '       ASI_CRM_Adjustment_Schedule__c,'
             + '       ASI_CRM_Currency_Code__c,'
             + '       ASI_CRM_SG_Tax_Expl_Code__c,'
             + '       ASI_CRM_SG_Delivery_Instructions_1__c,'
             + '       ASI_CRM_SG_Delivery_Instructions_2__c'
             + '  FROM ASI_CRM_AccountsAdditionalField__c'
             + ' WHERE RecordType.DeveloperName LIKE \'ASI_CRM_SG_Converted_Outlets\''
             + '   AND ASI_CRM_ToJDE__c = FALSE';
        //this.numOfRowInTable = 30; //WL 2.0
        this.numOfRowInTable = 60; //WL 2.0
        this.currentPageNum = 1;
        this.LimitFrom = 0;
        runQuery();
    }
    
    public String sortDir {
        get  { if (sortDir == null) {  sortDir = 'ASC'; } return sortDir;  }
        set;
    }
    public String sortField {
        get  { if (sortField == null) {sortField = 'Name'; } return sortField;  }
        set;
    }
    public String debugSoql {
        get { return soql + ' order by ' + sortField + ' ' + sortDir  + ' Limit ' + this.numOfRowInTable + ' OFFSET ' + LimitFrom; }
        set;
    }
    public List<ASI_CRM_AccountsAdditionalField__c> TotalLineItem{get;set;}
    public List<ASI_CRM_AccountsAdditionalField__c> lineItem{get;set;}
    
    //sort
    public void toggleSort() {
        sortDir = sortDir.equals('asc') ? 'desc' : 'asc';
        runQuery();
      }
    
      public void runQuery() {
          try {
              TotalLineItem = Database.query(soql + ' order by ' + sortField + ' ' + sortDir);
              this.totalNumOfRecord = TotalLineItem.size();
              lineItem = Database.query(soql + ' order by ' + sortField + ' ' + sortDir + ' Limit ' + this.numOfRowInTable + ' OFFSET ' + LimitFrom);
              // DC - Added code for setting default values.
              for(ASI_CRM_AccountsAdditionalField__c line : lineItem) {
                line.ASI_CRM_SG_Customer_Price_Group__c = line.ASI_CRM_SG_Customer_Price_Group__c != null ? line.ASI_CRM_SG_Customer_Price_Group__c  : 'PRICEGRP';
                line.ASI_CRM_SG_Search_Type__c = line.ASI_CRM_SG_Search_Type__c != null ? line.ASI_CRM_SG_Search_Type__c : 'D - Delivery Address';
                line.ASI_CRM_SG_Business_Unit__c = line.ASI_CRM_SG_Business_Unit__c != null ? line.ASI_CRM_SG_Business_Unit__c : '7SGDP';
                line.ASI_CRM_SG_AR_Account_Type__c = line.ASI_CRM_SG_AR_Account_Type__c != null ? line.ASI_CRM_SG_AR_Account_Type__c : 'INDIR';
                line.ASI_CRM_SG_MKT_Responsible__c = line.ASI_CRM_SG_MKT_Responsible__c != null ? line.ASI_CRM_SG_MKT_Responsible__c : 'DUTY PAID';
                line.ASI_CRM_SG_GDF_Country__c = line.ASI_CRM_SG_GDF_Country__c != null ? line.ASI_CRM_SG_GDF_Country__c : 'DM';
                line.ASI_CRM_SG_CCC_Location__c = line.ASI_CRM_SG_CCC_Location__c != null ? line.ASI_CRM_SG_CCC_Location__c : 'SG';
                line.ASI_CRM_SG_Base_Price_Group_Bank_Name__c = line.ASI_CRM_SG_Base_Price_Group_Bank_Name__c != null ? line.ASI_CRM_SG_Base_Price_Group_Bank_Name__c : 'LP';
                line.ASI_CRM_SG_A_B_Amount_Codes__c = line.ASI_CRM_SG_A_B_Amount_Codes__c != null ? line.ASI_CRM_SG_A_B_Amount_Codes__c : 'SGD';
                line.ASI_CRM_SG_Statement_Cycle__c = line.ASI_CRM_SG_Statement_Cycle__c != null ? line.ASI_CRM_SG_Statement_Cycle__c : 'F';
                line.ASI_CRM_SG_Payment_Terms_A_R__c = line.ASI_CRM_SG_Payment_Terms_A_R__c != null ? line.ASI_CRM_SG_Payment_Terms_A_R__c : '0';
                line.ASI_CRM_SG_Tax_Rate_Area__c = line.ASI_CRM_SG_Tax_Rate_Area__c != null ? line.ASI_CRM_SG_Tax_Rate_Area__c : 'SG3';
                line.ASI_CRM_SG_Batch_Processing_Mode__c = line.ASI_CRM_SG_Batch_Processing_Mode__c != null ? line.ASI_CRM_SG_Batch_Processing_Mode__c : '.';
                line.ASI_CRM_Adjustment_Schedule__c = line.ASI_CRM_Adjustment_Schedule__c != null ? line.ASI_CRM_Adjustment_Schedule__c : 'FOC';
                line.ASI_CRM_Currency_Code__c = line.ASI_CRM_Currency_Code__c != null ? line.ASI_CRM_Currency_Code__c : 'SGD';
                line.ASI_CRM_SG_Tax_Expl_Code__c = line.ASI_CRM_SG_Tax_Expl_Code__c != null ? line.ASI_CRM_SG_Tax_Expl_Code__c : 'V';
                line.ASI_CRM_SG_Delivery_Instructions_1__c = line.ASI_CRM_SG_Delivery_Instructions_1__c != null ? line.ASI_CRM_SG_Delivery_Instructions_1__c : '### WAREHOUSE TO DELIVER';
                line.ASI_CRM_SG_Send_Statement_To__c = line.ASI_CRM_SG_Send_Statement_To__c != null ? line.ASI_CRM_SG_Send_Statement_To__c : 'C-Customer';
              }
          } catch (Exception e) {
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No Records Found, Please Check your search input' + soql));
              //System.debug('Fail123');
            }
        }
    
    //search function
    public PageReference runSearch() {
        PO_Number = Apexpages.currentPage().getParameters().get('PO_Number');
        PO_Line_Number = Apexpages.currentPage().getParameters().get('PO_Line_Number');
        Suppliers = Apexpages.currentPage().getParameters().get('Suppliers');
        GLdates = Apexpages.currentPage().getParameters().get('GLdates');
        String[] str;
        Datetime searchDate;
        soql = 'SELECT id,' 
             + '       name,'
             + '       ASI_CRM_ToJDE__c,'
             + '       ASI_CRM_SG_Customer_Price_Group__c,'
             + '       ASI_CRM_SG_Search_Type__c,'
             + '       ASI_CRM_SG_Business_Unit__c,'
             + '       ASI_CRM_SG_AR_Account_Type__c,'
             + '       ASI_CRM_SG_MKT_Responsible__c,'
             + '       ASI_CRM_SG_GDF_Country__c,'
            /* [VL 1.0] BEGIN */
            /*
             + '       ASI_CRM_SG_Local_Channel__c,'
            */
            /* [VL 1.0] END */
             + '       ASI_CRM_SG_CCC_Location__c,'
             + '       ASI_CRM_SG_Base_Price_Group_Bank_Name__c,'
             + '       ASI_CRM_SG_A_B_Amount_Codes__c,'
            /* [VL 1.0] BEGIN */
            /*
             + '       ASI_CRM_SG_Category_Code_13__c,'
            */
            /* [VL 1.0] END */
             + '       ASI_CRM_SG_Statement_Cycle__c,'
             + '       ASI_CRM_SG_Payment_Terms_A_R__c,'
             + '       ASI_CRM_SG_Tax_Rate_Area__c,'
             + '       ASI_CRM_SG_Send_Statement_To__c,'
             + '       ASI_CRM_SG_Batch_Processing_Mode__c,'
             + '       ASI_CRM_Adjustment_Schedule__c,'
             + '       ASI_CRM_Currency_Code__c,'
             + '       ASI_CRM_SG_Tax_Expl_Code__c,'
             + '       ASI_CRM_SG_Delivery_Instructions_1__c,'
             + '       ASI_CRM_SG_Delivery_Instructions_2__c'
             + '  FROM ASI_CRM_AccountsAdditionalField__c'
             + ' WHERE RecordType.DeveloperName LIKE \'ASI_CRM_SG_Converted_Outlets\''
             + '   AND ASI_CRM_ToJDE__c = FALSE';
        if (!PO_Number.equals(''))
            soql += ' and ASI_MFM_PO__r.name LIKE \''+String.escapeSingleQuotes(PO_Number)+'%\'';
        
        if (!PO_Line_Number.equals(''))
            soql += ' and Name LIKE \''+String.escapeSingleQuotes(PO_Line_Number)+'%\'';
        
        if (!Suppliers.equals(''))
            soql += ' and ASI_MFM_PO__r.ASI_MFM_Supplier_Name__r.name LIKE \''+String.escapeSingleQuotes(Suppliers)+'%\'';
        if (!GLdates.equals('')) {
            str = GLdates.split('-');
            searchDate = Datetime.newInstance(Integer.valueOf(str[0]),Integer.valueOf(str[1]),Integer.valueOf(str[2]),0,0,0);
            soql += ' and ASI_MFM_G_L_Date__c <= ' +searchDate.format('yyyy-MM-dd');
        }
        runQuery();
        System.debug('test678:'+soql);
        return null;
        }
    
    // save Outlets
    public PageReference save(){
        string alertMsg = '';
        decimal lineItemProceed = 0;
        decimal lineItemVerified = 0;
        
        try {
            for (ASI_CRM_AccountsAdditionalField__c li : lineItem) {
                if (li.ASI_CRM_ToJDE__c) lineItemVerified++;
            }
            update lineItem;
            lineItemProceed = lineItem.size();
            runQuery();        // DC - called runQuery to get updated outlets.
        } catch(DmlException exceptionInstance) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, exceptionInstance.getMessage()));
        }
        
        //return null;
        PageReference pageRef = null;
        //alertMsg = lineItemProceed + ' outlets are proceeded. ' + lineItemVerified + ' outlets are verified.';
        alertMsg = 'Your changes have been saved. ';
        if (lineItemVerified > 0) alertMsg += lineItemVerified + ' outlets are verified and will sync to JDE tonight.';
        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, alertMsg));
        return pageRef;
    }
    
    // change page function
    public void firstPage() {
        this.currentPageNum=1;
        implChangePage(1);
        this.LimitFrom = 0;
        runQuery();
    }
    
    public void lastPage() {
        this.currentPageNum=this.maxNumOfPage();
        implChangePage(this.maxNumOfPage());
        this.LimitFrom = this.maxPageNum*this.numOfRowInTable-this.numOfRowInTable;
        runQuery();
    }
    
    public void prevPage() {
        if(this.currentPageNum>0){
            this.currentPageNum = this.currentPageNum -1;
            implChangePage(this.currentPageNum);
            this.LimitFrom=this.LimitFrom-this.numOfRowInTable;
            runQuery();
        }
    }
    
    public void nextPage() {
        if(this.currentPageNum<this.maxPageNum){
            this.currentPageNum=this.currentPageNum + 1;
            implChangePage(this.currentPageNum);
        //this.numOfRowInTable=this.numOfRowInTable+2;
            this.LimitFrom=this.LimitFrom+this.numOfRowInTable;
            runQuery();
        //implChangePage(this.currentPageNum + 1); 
        }
        
    }
    
    public void implChangePage(Integer pageNum) {
        Integer maxPNum = this.maxNumOfPage();
        if (pageNum <= 0) this.currentPageNum = 1;
        else if (pageNum > maxPNum) this.currentPageNum = maxPNum;
    }
    
    private Integer maxNumOfPage() {
        if (this.totalNumOfRecord == 0 || this.numOfRowInTable == 0)
            return 1;
        return ((this.totalNumOfRecord - 1) / this.numOfRowInTable) + 1;
    }
    
    public Integer maxPageNum { get { return maxNumOfPage(); } private set; }
    public Integer currentPageNum { get; protected set { currentPageNum = value; newPageNum = String.valueOf(value); } }
    public String newPageNum { get; set; }

}