/*
2014-03-17        Stella Sing (Introv)        Created
2014-03-27        Stella Sing (Introv)        Add Approval History
2018-08-01        Linus Ho (Introv)           Change A/C Code mapping to ASI_TH_CRM_AC_Code_Mapping (Custom Setting)
*/
public with sharing class ASI_TH_CRM_POSummaryReport_Controller{
    public List <Account> VendorName {get;set;}
    public ASI_TH_CRM_PaymentRequest__c POSummary {set;get;}
    public List<ProcessInstanceHistory> processInstList {get;set;}
    public List<ASI_TH_ApprHist_LineItem > appHistList {get;set;}
    public boolean hasHistory {get;set;}
    private final String object_ApiName = 'ASI_TH_CRM_PaymentRequest__c';
    public List <ASI_TH_CRM_PaymentRequestLineItem__c> PRPLIList {set;get;}
    public List <ASI_TH_CRM_PaymentRequestLineItem__c> ShowPRPLIList {get;set;}
    public String VendorId {get;set;}
    public String ListItemCode {get;set;}
    public String AccCode {get;set;}
    public String PageId {get;set;}
    public String OutletId {get;set;}
    public Decimal VATAmount {get;set;}
    public String SubbrandName {get;set;}
    public list<showList> ShowDetails {set;get;}
   // public String VendorAccName {get;set;}
    public ASI_TH_CRM_POSummaryReport_Controller(ApexPages.StandardController stdController){
        this.POSummary = (ASI_TH_CRM_PaymentRequest__c)stdController.getRecord();
        PageId = ApexPages.CurrentPage().getParameters().get('id');
        /*PRList = [SELECT ASI_TH_CRM_Vendor__c, ASI_TH_CRM_Total_Amount__c ,ASI_TH_CRM_VAT__c FROM ASI_TH_CRM_PaymentRequest__c WHERE id = :PageId];
        for (ASI_TH_CRM_PaymentRequest__c b : PRList ){
            VendorId = b.ASI_TH_CRM_Vendor__c ;
            */
        if (POSummary.ASI_TH_CRM_VAT__c != null){
            system.debug('POSummary.ASI_TH_CRM_VAT__c: ' +POSummary.ASI_TH_CRM_VAT__c);
            String strVAT = POSummary.ASI_TH_CRM_VAT__c;
            String[] strVAT1 = strVAT.split('%');
            String strVAT2 = String.join(strVAT1,'');
//            VATAmount = integer.valueof((integer.valueof(strVAT2) * POSummary.ASI_TH_CRM_Total_Amount__c/100 )); 
            //VATAmount = integer.valueof(strVAT2);
            VATAmount = double.valueof((double.valueof(strVAT2) * POSummary.ASI_TH_CRM_Total_Amount__c/100 )); 
        }
       // }
        /*VendorName  = [SELECT ASI_HK_CRM_JDE_Account_Number__c, Name FROM Account where id = :VendorId];
        for (Account a : VendorName ){
            //VendorAccName = a.ASI_HK_CRM_JDE_Account_Number__c + ' - ' + a.Name;
            VendorAccName = a.Name;
        }*/
        PRPLIList = [SELECT Name, ASI_TH_CRM_Invoice_No__c, ASI_TH_CRM_Amount__c, ASI_TH_CRM_COA__c, ASI_TH_CRM_Quantity__c, 
                     ASI_TH_CRM_Subbrand__r.Name, ASI_TH_CRM_UnitCost__c ,
                     ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Contract__r.ASI_TH_CRM_Outlet__r.ASI_HK_CRM_JDE_Account_Number__c,
                     ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Contract__r.ASI_TH_CRM_Outlet__r.Name,
                     ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Region__c
                     FROM ASI_TH_CRM_PaymentRequestLineItem__c WHERE ASI_TH_CRM_Payment_Request__c = :PageId];
        if (PRPLIList.size() >0){
        ShowPRPLIList = new List <ASI_TH_CRM_PaymentRequestLineItem__c  >();
        showDetails = new list<showList>();
            for (ASI_TH_CRM_PaymentRequestLineItem__c  c :PRPLIList ){ 
                showList newitem = new showList();
                if (c.ASI_TH_CRM_Subbrand__r.Name != null)
                SubbrandName = c.ASI_TH_CRM_Subbrand__r.Name;
                system.debug('SubbrandName: ' +SubbrandName );
                if (ACCodeMap.containskey(c.ASI_TH_CRM_COA__c))
                    AccCode = ACCodeMap.get(c.ASI_TH_CRM_COA__c) + '<br/>'+ c.ASI_TH_CRM_COA__c;
                /*
                if (c.ASI_TH_CRM_GLDate__c != null){
                Date strMonth = c.ASI_TH_CRM_GLDate__c;
                String strMonth2 = string.valueof(strMonth.Month());
                if (MonthMap.containskey(strMonth2))
                    ListItemCode = MonthMap.get(strMonth2) + String.valueof(strMonth.Year());
                    //ListItemCode = String.valueof(strMonth.Month()) + String.valueof(strMonth.Year());  
                }
                system.debug('ListItemCode: ' + ListItemCode );
                */
                newitem.strRegion = c.ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Region__c;
                newitem.strBrand = c.ASI_TH_CRM_Subbrand__r.Name;
                newitem.strItem = c.ASI_TH_CRM_COA__c;
                newitem.strItem2 = c.Name;
                newitem.strACcode = AccCode;
                newitem.strCustomer = c.ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Contract__r.ASI_TH_CRM_Outlet__r.ASI_HK_CRM_JDE_Account_Number__c + ' - ' + c.ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Contract__r.ASI_TH_CRM_Outlet__r.Name;
                newitem.strInvoice = c.ASI_TH_CRM_Invoice_No__c;
                newitem.strUnitCost = c.ASI_TH_CRM_UnitCost__c;
                newitem.strAmount = c.ASI_TH_CRM_Amount__c;
                showDetails.add(newitem);
                ShowPRPLIList.add(c);
            }
            system.debug('showPRPLIList: ' +showPRPLIList.size());
        }
        
        //2014-03-26 Add Approval History
        ASI_ApprovalHistoryHelper appHistHelper = new ASI_ApprovalHistoryHelper (object_ApiName , PageId );
        if (appHistHelper.appHistorySObjList != null){
            this.processInstList = appHistHelper.appHistorySObjList;
            hasHistory=true;
            appHistList  = new List<ASI_TH_ApprHist_LineItem >();
            
             for (ProcessInstanceHistory li : this.processInstList ) {
                  ASI_TH_ApprHist_LineItem tempLi = new ASI_TH_ApprHist_LineItem();
                  tempLi.id =  li.id;
                  tempLi.StepStatus=  li.StepStatus;
                  tempLi.Comments=  li.Comments;
                  tempLi.CreatedDate=  li.CreatedDate;
                  tempLi.CreatedDateString=  li.CreatedDate.format('yyyy/MM/dd/ aHH:mm ', 'Hongkong');
                  
                  tempLi.oriActorId =  li.OriginalActor.Id;
                  User oriApprover = getApprDetailInfo(li.OriginalActor.Id);
                  tempLi.oriActorName =  oriApprover .Name;
                  tempLi.oriActorTitle =  oriApprover .Title;
                  
                  tempLi.actActorId =  li.Actor.Id;
                  User actApprover = getApprDetailInfo(li.Actor.Id);
                  tempLi.actActorName =  actApprover.Name;
                  tempLi.actActorTitle =  actApprover.Title;
                  tempLi.actActorDepartment = actApprover.Department;
                  appHistList.add(tempLi);
             }
             if (appHistList.size() <=0)
              hasHistory=false;
             else
              hasHistory=true;
        }
    }
    public static User getApprDetailInfo(String userId){
        String queryStr = '';
        User appHistoryApprover = new User();
        queryStr = 'select id, name, title, department from user ';
        queryStr += ' where id =\'' +userId+ '\'';
        System.debug('ahh3' + queryStr);    
        appHistoryApprover = Database.query(queryStr);
        return appHistoryApprover ;
     }
     public class showList{
         public string strRegion {set;get;}
         public string strItem {set;get;}
         public string strItem2 {set;get;}
         public string strBrand {set;get;}
         public string strACcode {set;get;}
         public string strCustomer {set;get;}
         public string strInvoice {set;get;}
         public decimal strUnitCost {set;get;}
         public decimal strAmount {set;get;}
     }
        
     public class ASI_TH_ApprHist_LineItem {
        public String id { get; set; }
        public String StepStatus{ get; set; }
        public String Comments{ get; set; }
        public DateTime CreatedDate{ get; set; }
        public String CreatedDateString{ get; set; }
        public String oriActorId { get; set; }
        public String oriActorName { get; set; }
        public String oriActorTitle { get; set; }
        public String oriActorDepartment { get; set; }
        public String actActorId { get; set; }
        public String actActorName { get; set; }
        public String actActorTitle { get; set; }
        public String actActorDepartment { get; set; }
      
    }
    
    public static Map <String, String> ACCodeMap = new Map <String, String>();    
    public static Map <String, String> MonthMap= new Map <String, String>();
    static{
        /*
        ACCodeMap.put('Fund - Advance', '5558.2010');
        ACCodeMap.put('Fund - Cash', '5558.2020');
        ACCodeMap.put('Fund - FOC', '5558.2050');
        ACCodeMap.put('Rebate (Historical)', '5220.302');
        ACCodeMap.put('Activity - Cash', '5558.2120');
        ACCodeMap.put('Activity - FOC', '5558.2150');
        */
        // Added by 2018-08-01 Linus@introv
        for(ASI_TH_CRM_AC_Code_Mapping__c ac:[select id, name, ASI_TH_CRM_A_C_Code__c from ASI_TH_CRM_AC_Code_Mapping__c]){
            ACCodeMap.put(ac.Name, ac.ASI_TH_CRM_A_C_Code__c);
        }
        // END - Linus
        MonthMap.put('1', 'January');
        MonthMap.put('2', 'February');
        MonthMap.put('3', 'March');
        MonthMap.put('4', 'April');
        MonthMap.put('5', 'May');
        MonthMap.put('6', 'June');
        MonthMap.put('7', 'July');
        MonthMap.put('8', 'August');
        MonthMap.put('9', 'September');
        MonthMap.put('10', 'October');
        MonthMap.put('11', 'November');
        MonthMap.put('12', 'December');
    }
}