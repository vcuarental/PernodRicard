/**********************************************************************************
 * Name : ASI_KOR_SRPaymentSettlementController 
 * Created : Vincent Lam
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * ??                                       Created
 * 2017-02-13       Laputa: Vincent         [VL 1.0] add new column Total Basic, Prepayment and Final Total; 
 *                                          if the payment is not in proposal, not allow to change pay option
 * 2017-02-22       Laputa: Vincent         [VL 2.0] create new section (class) for CA brand grouping
 * 2017-05-05       Laputa: Vincent         [VL 3.0] P4.2
 * 2017-08-01       Laputa: Vincent         [VL 4.0] P4.2, retuns the report id
 * 2017-08-09       Laputa: Vincent         [VL 5.0] P4.2 logic, show >1000 venue summary
 * 2017-09-08       Laputa: Vincent         [VL 6.0] P4.2 add function to refreshing venue summary only
 **********************************************************************************/
global without sharing class ASI_KOR_SRPaymentSettlementController { 
    private ApexPages.StandardController standardController;
    public ASI_KOR_SR_Payment_Settlement_Header__c srPaymentSettlementHeader { get; set; }
    
    public Boolean renderProposal {get; set;}
    public Boolean renderApprove {get; set;}
    public Boolean disabledApprove {get; set;}
    public Boolean renderReject {get; set;}
    public Boolean disabledReject {get; set;}
    public String selectedVenues {get; set;}
    public List<SelectOption> currentContacts {get;set;}
    
    public ASI_KOR_SRPaymentSettlementController(ApexPages.StandardController standardController){
        renderApprove = true;
        renderReject = true;
        disabledReject = false;
        disabledApprove = false;
        this.standardController = standardController;
        this.srPaymentSettlementHeader = (ASI_KOR_SR_Payment_Settlement_Header__c ) standardController.getRecord();
        
        renderProposal = false;
        disabledApprove = true;
        disabledReject  = true;
        populateSRPaymentBranch();
        populateVenueSummary();
        populatePaymentSettlementHeader();
        
    }
    
    /* [VL 5.0] BEGIN */
    /*
    public List<VenueSummary> venueSummaryList {get; set;}
    public Map<Id,VenueSummary> venueSummaryMap {get; set;}
    */
    
    public List<VenueSummary> venueSummaryList = new List<VenueSummary>();
    public Map<Id,VenueSummary> venueSummaryMap = new Map<Id,VenueSummary>();
    
    public List<List<VenueSummary>> getVenueSummaryList_split(){
        List<List<VenueSummary>> VenueSummaryList_split = new List<List<VenueSummary>>();
        integer count = 0;
        List<VenueSummary> tempList = new List<VenueSummary>();
        for (VenueSummary vs : venueSummaryList){
            if (count>=500){
                VenueSummaryList_split.add(tempList);
                tempList = new List<VenueSummary>();
                count = 0;
            }
            tempList.add(vs);
            count++;
        }
        if (tempList.size()>0) VenueSummaryList_split.add(tempList);
        return VenueSummaryList_split;
    }
    /* [VL 5.0] END */
    
    public void selectVenue(){
        if(!''.equals(selectedVenues)){
            Id venueId = Id.valueOf(selectedVenues);
            populatePaymentSettlementHeader(srPaymentSettlementHeader.Id,venueId);
            populateContactsVenue(venueId);
        }
    }
    
    public void populateContactsVenue(Id venueId)
    {
        currentContacts  = new List<SelectOption>();     
        List<Contact> contacts = [select id,name from contact where accountid =:venueId];
        for (Contact contact: contacts) {     
            currentContacts .add(new SelectOption(contact.id,contact.name));
        }
    }
    
    
    public class VenueSummary /* [VL 4.0] BEGIN */implements Comparable/* [VL 4.0] END */{
        public Id venueId {get; set;}
        public String venueCode {get; set;}
        public String venueName {get; set;}
        public Decimal totalTargetVolume {get;set;}
        public Decimal totalCAAmountExlBasic {get;set;}
        public Decimal totalFinalCAAmountExlBasic {get;set;}
        /* [VL 1.0] BEGIN */
        public Decimal totalBasic {get;set;}
        public Decimal totalPrepayment {get;set;}
        public Decimal totalFinal {get;set;}
        /* [VL 1.0] END */
        public Account venue {get;set;}  
        
        /* [VL 3.0] BEGIN */
        public Integer compareTo(Object compareTo) 
        {
            VenueSummary compareToWrap = (VenueSummary)compareTo;
            Integer returnValue = 0;
            if (venueName<compareToWrap.venueName) {
                returnValue = -1;
            } else
            if (venueName>compareToWrap.venueName) {
                returnValue = 1;
            } 
            return returnValue;      
        }
        /* [VL 3.0] END */      
    }
    
    private void populateVenueSummary(){
        
        venueSummaryMap = new Map<Id,VenueSummary>();
        venueSummaryList = new List<VenueSummary>();
        
        List<ASI_KOR_SR_Payment_Settlement_Detail__c> tempD = [select ASI_KOR_Venue_Name__c, 
                                                               ASI_KOR_Venue_Name__r.Name,
                                                               ASI_KOR_Actual_Volume__c,
                                                               ASI_KOR_Target_Volume__c,
                                                               ASI_KOR_Venue_Name__r.ASI_KOR_Customer_Code__c,
                                                               ASI_KOR_Venue_Name__r.ASI_KOR_Venue_Capacity__c,
                                                               /* [VL 3.0] BGEIN */
                                                               ASI_KOR_Venue_Name__r.ASI_KOR_Venue_Type__c,
                                                               ASI_KOR_Remarks__c,
                                                               /* [VL 3.0] END */
                                                               ASI_KOR_Final_CA_Amount_excl_Basic__c, 
                                                               ASI_KOR_CA_Amount_excl_Basic__c, 
                                                               ASI_KOR_Approved_Unit_Cost_CA_Only__c,
                                                               ASI_KOR_Random_Reason__c,
                                                               ASI_KOR_Final_CA_Amount_excl_Bsic_Random__c 
                                                               /* [VL 1.0] BEGIN */
                                                               , ASI_KOR_Final_Basic_Amount__c
                                                               , ASI_KOR_Pre_Payment_Amount__c
                                                               , ASI_KOR_Final_Total_Amount__c
                                                               /* [VL 1.0] END */
                                                               from ASI_KOR_SR_Payment_Settlement_Detail__c
                                                               where ASI_KOR_SR_Payment_Settlement__c =: srPaymentSettlementHeader.id order by ASI_KOR_Venue_Name__c];
        
        Map<String,VenueSummary> tempSummaryMap = new Map<String,VenueSummary>();
        Id ix;
        for(ASI_KOR_SR_Payment_Settlement_Detail__c ts: tempD){
            if(ix!=ts.ASI_KOR_Venue_Name__c){
                
                VenueSummary vs = new VenueSummary();
                vs.venueId = ts.ASI_KOR_Venue_Name__c;
                vs.venueName = ts.ASI_KOR_Venue_Name__r.Name; 
                vs.venueCode = ts.ASI_KOR_Venue_Name__r.ASI_KOR_Customer_Code__c;
                vs.totalCAAmountExlBasic = ts.ASI_KOR_CA_Amount_excl_Basic__c;
                vs.totalFinalCAAmountExlBasic = ts.ASI_KOR_Final_CA_Amount_excl_Basic__c; 
                /* [VL 1.0] BEGIN */
                vs.totalBasic = ts.ASI_KOR_Final_Basic_Amount__c;
                vs.totalPrepayment = ts.ASI_KOR_Pre_Payment_Amount__c != null ? ts.ASI_KOR_Pre_Payment_Amount__c : 0;
                vs.totalFinal = ts.ASI_KOR_Final_Total_Amount__c;
                /* [VL 1.0] END */
                tempSummaryMap.put(vs.venueId,vs);
                ix=ts.ASI_KOR_Venue_Name__c;
                venueSummaryList.add(vs);
            } else {
                VenueSummary vs = tempSummaryMap.get(ts.ASI_KOR_Venue_Name__c);
                vs.venueId = ts.ASI_KOR_Venue_Name__c;
                vs.totalCAAmountExlBasic += ts.ASI_KOR_CA_Amount_excl_Basic__c;
                vs.totalFinalCAAmountExlBasic += ts.ASI_KOR_Final_CA_Amount_excl_Basic__c; 
                /* [VL 1.0] BEGIN */
                vs.totalBasic += ts.ASI_KOR_Final_Basic_Amount__c;
                vs.totalPrepayment += ts.ASI_KOR_Pre_Payment_Amount__c != null ? ts.ASI_KOR_Pre_Payment_Amount__c : 0;
                vs.totalFinal += ts.ASI_KOR_Final_Total_Amount__c;
                /* [VL 1.0] END */
            }
        }
        /* [VL 3.0] BEGIN */
        List<VenueSummary> venueSummaryList_withVI = new List<VenueSummary>();
        List<VenueSummary> venueSummaryList_withoutVI = new List<VenueSummary>();
        for (VenueSummary vtemp : venueSummaryList){
            if (vtemp.totalBasic > 0){
                venueSummaryList_withVI.add(vtemp);
            } else {
                venueSummaryList_withoutVI.add(vtemp);
            }
        }
        venueSummaryList_withVI.sort();
        venueSummaryList_withoutVI.sort();
        venueSummaryList.clear();
        venueSummaryList.addall(venueSummaryList_withVI);
        venueSummaryList.addall(venueSummaryList_withoutVI);
        /* [VL 3.0] END */
    }
    
    private void populatePaymentSettlementHeader(Id headerId, Id venueName)
    {
        //ASI_KOR_SR_Payment_Settlement_Detail__c    
        paymentSettlementDetailsByVenueList = new List<PaymentSettlementDetailsByVenue>();
        List<ASI_KOR_SR_Payment_Settlement_Detail__c> existingPaymentDetails = [
            select id, ASI_KOR_Actual_Volume__c, ASI_KOR_Approved_Basic_Unit_Cost__c, ASI_KOR_Approved_Unit_Cost_CA_Only__c, 
            ASI_KOR_Brand__c, ASI_KOR_Brand__r.name, ASI_KOR_Category__c, ASI_KOR_Channel__c, ASI_KOR_CA_Amount_excl_Basic__c,
            ASI_KOR_Progression__c,  ASI_KOR_SR_Payment_Settlement__c,ASI_KOR_Target_Volume__c,ASI_KOR_Grade__c,ASI_KOR_Pay_Option__c,
            ASI_KOR_Total_Cost_Cap__c,ASI_KOR_UOM__c,ASI_KOR_Venue_Code__c,ASI_KOR_Venue_Name__c,ASI_KOR_Keyman_Name__c,
            ASI_KOR_Approved_Unit_Cost_Basic_CA__c,ASI_KOR_Final_CA_Amount_excl_Basic__c ,ASI_KOR_Keyman_Code__c ,
            ASI_KOR_Venue_Name__r.Name,ASI_KOR_Unit_Cost_Cap_Actual_Volume__c,ASI_KOR_Venue_Name__r.ASI_KOR_Customer_Code__c,
           /* [VL 3.0] BGEIN */
           ASI_KOR_Venue_Name__r.ASI_KOR_Venue_Type__c,
           ASI_KOR_Remarks__c,
           ASI_KOR_Budget_Status__c,
           ASI_KOR_Settlement_Unit_Cost__c,
           ASI_KOR_Actual_Pre_payment_Volume__c,
           /* [VL 3.0] END */
            ASI_KOR_Venue_Name__r.ASI_KOR_Venue_Capacity__c,
            ASI_KOR_Random_Reason__c,
            ASI_KOR_Final_CA_Amount_excl_Bsic_Random__c  
            /* [VL 1.0] BEGIN */
            , ASI_KOR_Final_Basic_Amount__c
            , ASI_KOR_Pre_Payment_Amount__c
            , ASI_KOR_Final_Total_Amount__c
            , ASI_KOR_Brand__r.ASI_KOR_CA_Brand__c
            , ASI_KOR_System_Generated_Proposal__c
            /* [VL 1.0] END */
            /* [VL 2.0] BEGIN */
            , ASI_KOR_Brand__r.ASI_KOR_CA_Brand__r.name
            /* [VL 2.0] END */
            from ASI_KOR_SR_Payment_Settlement_Detail__c
            where ASI_KOR_SR_Payment_Settlement__c =: headerId and ASI_KOR_Venue_Name__c =:venueName  
            /* [VL 3.0] BGEIN */
           order by ASI_KOR_Brand__r.ASI_KOR_Sequence__c ASC NULLS FIRST
           /* [VL 3.0] END */
        ];
        
        Map<Id,List<ASI_KOR_SR_Payment_Settlement_Detail__c>> venueDetailsMap = new Map<Id,List<ASI_KOR_SR_Payment_Settlement_Detail__c>>();
        for(ASI_KOR_SR_Payment_Settlement_Detail__c detail : existingPaymentDetails ){
            
            if(venueDetailsMap .get(detail.ASI_KOR_Venue_Name__c) == null){
                system.debug('XXX creating new Listfor : ' +detail.ASI_KOR_Venue_Name__c);
                List<ASI_KOR_SR_Payment_Settlement_Detail__c> detailList = new List<ASI_KOR_SR_Payment_Settlement_Detail__c>();
                detailList.add(detail);
                venueDetailsMap.put(detail.ASI_KOR_Venue_Name__c,detailList);
            }else{
                system.debug('XXX adding new Listfor : ' +detail.ASI_KOR_Venue_Name__c);
                venueDetailsMap.get(detail.ASI_KOR_Venue_Name__c).add(detail);
            }    
        }
        
        
        List<Account> venues = [select ASI_KOR_Grade__c,ASI_KOR_Venue_Capacity__c,ASI_KOR_Venue_Channel__c,id, Name, ASI_KOR_Customer_Code__c, ASI_KOR_Contract_Type__c 
                                /* [VL 3.0] BEGIN */
                                , ASI_KOR_Venue_Type__c
                                /* [VL 3.0] END */
                                from Account 
                                where id in:venueDetailsMap.keySet()];
        system.debug('EXISTING VENUE Size: ' + venues.size());
        for(Account venue : venues){
            PaymentSettlementDetailsByVenue paymentSettlementDetailsByVenue = new PaymentSettlementDetailsByVenue(venue,venueDetailsMap.get(venue.id));
            paymentSettlementDetailsByVenueList.add(paymentSettlementDetailsByVenue ); 
        }
        
        
    }
    
    private void populatePaymentSettlementHeader()
    {
        if (venueSummaryList != null) 
        {
            populatePaymentSettlementHeader(srPaymentSettlementHeader.Id, venueSummaryList.get(0).venueId);
            selectedVenues = venueSummaryList.get(0).venueId;
            populateContactsVenue(venueSummaryList.get(0).venueId);
        }
    }
    
    /* [VL 3.0] BEGIN */
    public string checkUnitCostThreshold(){
        ASI_CRM_KR_Unit_Cost_Threshold__c unitCostThresholdObj = ASI_CRM_KR_Unit_Cost_Threshold__c.getInstance(srPaymentSettlementHeader.ASI_KOR_Year__c+'-'+srPaymentSettlementHeader.ASI_KOR_Month__c);
        Decimal threshold = unitCostThresholdObj.ASI_CRM_KR_Threshold__c;
        string msg = '';
        for (PaymentSettlementDetailsByVenue  paymentSettlementDetailsByVenue : paymentSettlementDetailsByVenueList ){
            for (PaymentSettlementDetailsByVenueByCAbrand caBrandDetail : paymentSettlementDetailsByVenue.paymentSettlementDetailsByCAbrand){
                for (ASI_KOR_SR_Payment_Settlement_Detail__c sr: caBrandDetail.paymentSettlementDetails){
                    if (sr.ASI_KOR_Actual_Volume__c != null && 
                       sr.ASI_KOR_Actual_Volume__c != 0 &&
                       sr.ASI_KOR_Settlement_Unit_Cost__c != null &&
                       sr.ASI_KOR_Settlement_Unit_Cost__c != 0 &&
                       sr.ASI_KOR_Settlement_Unit_Cost__c >= threshold){
                        msg += 'For Venue: <b>'+sr.ASI_KOR_Venue_Name__r.name+'</b>, Brand: <b>'+sr.ASI_KOR_Brand__r.name+'</b>, Unit Cost가 너무 높게 입력되었습니다. 수정 바랍니다.<br/>';
                       }
                }
            }
        }
        return msg;
    }
    /* [VL 3.0] END */
    
    public PageReference save()
    {
        
        /* [VL 3.0] BEGIN */
        string uploadMessage = checkUnitCostThreshold();
        system.debug('uploadMessage: '+uploadMessage);
        if(uploadMessage != '') {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, uploadMessage));
            return null;
        }
        /* [VL 3.0] END */
        
        List<ASI_KOR_SR_Payment_Settlement_Detail__c> paymentSettlementToBeUpdate = new List<ASI_KOR_SR_Payment_Settlement_Detail__c>();
        for (PaymentSettlementDetailsByVenue  paymentSettlementDetailsByVenue : paymentSettlementDetailsByVenueList )
        {
            String keyManCode = paymentSettlementDetailsByVenue.contactId;
            /* [VL 2.0] BEGIN */
            /*
            for (ASI_KOR_SR_Payment_Settlement_Detail__c psd: paymentSettlementDetailsByVenue.paymentSettlementDetails)
            {   
                if(psd.ASI_KOR_Pay_Option__c == 'Random' && psd.ASI_KOR_Random_Reason__c == null) {
                    psd.ASI_KOR_Random_Reason__c.adderror('Must select Random Reason');
                    return;
                }
                
                Decimal randomCAFinal = 0;
                if(psd.ASI_KOR_Pay_Option__c == 'Random') {
                    randomCAFinal = psd.ASI_KOR_Final_CA_Amount_excl_Bsic_Random__c;
                }
                
                paymentSettlementToBeUpdate.add(new ASI_KOR_SR_Payment_Settlement_Detail__c(Id=psd.Id,ASI_KOR_Pay_Option__c=psd.ASI_KOR_Pay_Option__c,ASI_KOR_Keyman_Code__c=keyManCode, ASI_KOR_Final_CA_Amount_excl_Bsic_Random__c = randomCAFinal, ASI_KOR_Random_Reason__c = psd.ASI_KOR_Random_Reason__c));        
            }    
            */
            for (PaymentSettlementDetailsByVenueByCAbrand caBrandDetail : paymentSettlementDetailsByVenue.paymentSettlementDetailsByCAbrand){
                for (ASI_KOR_SR_Payment_Settlement_Detail__c psd: caBrandDetail.paymentSettlementDetails)
                {   
                    /* [VL 3.0] BEGIN */
                    /*
                    if(psd.ASI_KOR_Pay_Option__c == 'Random' && psd.ASI_KOR_Random_Reason__c == null) {
                        psd.ASI_KOR_Random_Reason__c.adderror('Must select Random Reason');
                        return;
                    }
                    
                    Decimal randomCAFinal = 0;
                    if(psd.ASI_KOR_Pay_Option__c == 'Random') {
                        randomCAFinal = psd.ASI_KOR_Final_CA_Amount_excl_Bsic_Random__c;
                    }
                    
                    paymentSettlementToBeUpdate.add(new ASI_KOR_SR_Payment_Settlement_Detail__c(Id=psd.Id,ASI_KOR_Pay_Option__c=psd.ASI_KOR_Pay_Option__c,ASI_KOR_Keyman_Code__c=keyManCode, ASI_KOR_Final_CA_Amount_excl_Bsic_Random__c = randomCAFinal, ASI_KOR_Random_Reason__c = psd.ASI_KOR_Random_Reason__c));       
                    */
                    /* [VL 3.0] END */ 
                    paymentSettlementToBeUpdate.add(psd);
                } 
            }
            /* [VL 2.0] END */
        }
        
        try{
            
            update paymentSettlementToBeUpdate;
            
        } catch ( DmlException exc) {
            ApexPages.addMessages(exc);
        }
        return null;
    }
    
    public void quickSave()
    {
        save();  
        
        if (selectedVenues != null)
        {
        populatePaymentSettlementHeader(srPaymentSettlementHeader.Id, Id.valueOf(selectedVenues));
        populateSRPaymentBranch();
        populateVenueSummary();
        }
        
    }
    
    public PageReference normalSave()
    {
        save();
        PageReference pageRef   = new PageReference('/'+srPaymentSettlementHeader.id);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public Decimal getBranchTotalBudget()
    {
        Decimal temp = 0;
        return temp;
    }
    
    public String getBranchTotalStatus(){
        Decimal x = getBranchTotalBudget();
        Decimal y = getSRTotalFinalCAAmountexclBasic();
        if(y>x)
            return 'Too big';
        else if(y<x)
            return 'Too Small';
        else
            return 'OK';
    }
    
    public static void submitted(Id headerId, Boolean flag){
        List<ASI_KOR_SR_Payment_Settlement_By_Brand__c> srPaymentSettlementByBrandList = [select id, ASI_KOR_Submitted__c from 
                                                                                          ASI_KOR_SR_Payment_Settlement_By_Brand__c where ASI_KOR_SR_Payment_Settlement__c = :headerId];
        for(ASI_KOR_SR_Payment_Settlement_By_Brand__c s : srPaymentSettlementByBrandList){
            s.ASI_KOR_Submitted__c = flag;
        }
        
        try{
            update srPaymentSettlementByBrandList;
            
        } catch ( DmlException exc) {
            ApexPages.addMessages(exc);
        }
    }
    
    /* [VL 3.0] BEGIN */
    public string checkUploadMessage(){
        string msg = '';
        for (ASI_KOR_SR_Payment_Settlement_Detail__c sr : [
            select id, ASI_KOR_Brand__r.name, ASI_KOR_Venue_Name__r.name, 
            ASI_KOR_Settlement_Unit_Cost__c, ASI_KOR_Unit_Cost_Cap_Actual_Volume__c, ASI_KOR_System_Generated_Proposal__c, ASI_KOR_Remarks__c
            from ASI_KOR_SR_Payment_Settlement_Detail__c
            where ASI_KOR_SR_Payment_Settlement__c = :srPaymentSettlementHeader.id        
        ]){
            if (sr.ASI_KOR_System_Generated_Proposal__c && sr.ASI_KOR_Remarks__c == null && sr.ASI_KOR_Settlement_Unit_Cost__c > 0){
                //msg += 'For Venue: <b>'+sr.ASI_KOR_Venue_Name__r.name+'</b>, Brand: <b>'+sr.ASI_KOR_Brand__r.name+'</b>, Please input remarks for Not In Planning payment.<br/>';
                msg += 'For Venue: <b>'+sr.ASI_KOR_Venue_Name__r.name+'</b>, Brand: <b>'+sr.ASI_KOR_Brand__r.name+'</b>, Plan에 없는 항목(Not In Planning)에 Remark를 입력해주세요.<br/>';
            } else
            if (sr.ASI_KOR_Settlement_Unit_Cost__c > sr.ASI_KOR_Unit_Cost_Cap_Actual_Volume__c && sr.ASI_KOR_Remarks__c == null){
                //msg += 'For Venue: <b>'+sr.ASI_KOR_Venue_Name__r.name+'</b>, Brand: <b>'+sr.ASI_KOR_Brand__r.name+'</b>, Please input remarks for payment with settlement unit cost > incentive unit cost based on actual volume.<br/>';
                msg += 'For Venue: <b>'+sr.ASI_KOR_Venue_Name__r.name+'</b>, Brand: <b>'+sr.ASI_KOR_Brand__r.name+'</b>, Settlement Unit Cost가 Planned Unit Cost 보다 큽니다. Remark를 입력해주세요.<br/>';
            } 
        }
        return msg;
    }
    /* [VL 3.0] END */
    
    public PageReference handleSubmit(){
        
        save();
        
        if (selectedVenues != null)
        {
        populatePaymentSettlementHeader(srPaymentSettlementHeader.Id, Id.valueOf(selectedVenues));
        populateSRPaymentBranch();
        populateVenueSummary();
        }
        /* [VL 3.0] BEGIN */
        string uploadMessage = checkUploadMessage();
        system.debug('uploadMessage: '+uploadMessage);
        if(uploadMessage != '') {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, uploadMessage));
            return null;
        }
        /* [VL 3.0] END */
        submitted(srPaymentSettlementHeader.id, true);
        srPaymentSettlementHeader.ASI_KOR_Status__c = 'Submitted';
        /* [VL 3.0] BEGIN */
        srPaymentSettlementHeader.ASI_KOR_Total_VI_Pending__c = getSRTotalFinalBasic();
        /* [VL 3.0] END */
        //rollUp(srPaymentSettlementHeader.id);
        rollUpDetails(srPaymentSettlementHeader.id);
        
        ASI_KOR_BM_Payment_Settlement_Header__c bmHeader = [select id, 
                                                            ASI_KOR_No_of_Submitted_Sales_Rep__c,
                                                            ASI_KOR_CA_Amount_Pending__c 
                                                            /* [VL 3.0] BEGIN */
                                                            , ASI_KOR_Total_VI_Pending__c
                                                            /* [VL 3.0] END */
                                                            from ASI_KOR_BM_Payment_Settlement_Header__c
                                                            where id = :srPaymentSettlementHeader.ASI_KOR_BM_Payment_Settlement_Header__c];
        
        Decimal noofSubmittedSalesRepresentative = bmHeader.ASI_KOR_No_of_Submitted_Sales_Rep__c == null ? 0 : bmHeader.ASI_KOR_No_of_Submitted_Sales_Rep__c;
        bmHeader.ASI_KOR_No_of_Submitted_Sales_Rep__c = noofSubmittedSalesRepresentative  + 1; 
        Decimal caAmountPending = bmHeader.ASI_KOR_CA_Amount_Pending__c == null?0:bmHeader.ASI_KOR_CA_Amount_Pending__c;
        bmHeader.ASI_KOR_CA_Amount_Pending__c = caAmountPending  + getSRTotalFinalCAAmountexclBasic();
        /* [VL 3.0] BEGIN */
        bmHeader.ASI_KOR_Total_VI_Pending__c = (bmHeader.ASI_KOR_Total_VI_Pending__c == null ? 0 : bmHeader.ASI_KOR_Total_VI_Pending__c) + getSRTotalFinalBasic();
        /* [VL 3.0] END */
        
        try{
            
            update srPaymentSettlementHeader;
            update bmHeader;
            
        } catch ( DmlException exc) {
            ApexPages.addMessages(exc);
            return null;
        }
        PageReference pageRef   = new PageReference('/'+srPaymentSettlementHeader.id);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public PageReference handleRecall(){
        srPaymentSettlementHeader.ASI_KOR_Status__c = 'Draft';
        //rollDown(srPaymentSettlementHeader.id);
        rollDownDetails(srPaymentSettlementHeader.id);
        submitted(srPaymentSettlementHeader.id,false);
        ASI_KOR_BM_Payment_Settlement_Header__c bmHeader = [select id, 
                                                            ASI_KOR_No_of_Submitted_Sales_Rep__c,
                                                            ASI_KOR_CA_Amount_Pending__c 
                                                            /* [VL 3.0] BEGIN */
                                                            , ASI_KOR_Total_VI_Pending__c
                                                            /* [VL 3.0] END */
                                                            from ASI_KOR_BM_Payment_Settlement_Header__c
                                                            where id = :srPaymentSettlementHeader.ASI_KOR_BM_Payment_Settlement_Header__c];
        
        Decimal noofSubmittedSalesRepresentative = bmHeader.ASI_KOR_No_of_Submitted_Sales_Rep__c == null ? 0 : bmHeader.ASI_KOR_No_of_Submitted_Sales_Rep__c;
        bmHeader.ASI_KOR_No_of_Submitted_Sales_Rep__c = noofSubmittedSalesRepresentative  - 1; 
        Decimal caAmountPending = bmHeader.ASI_KOR_CA_Amount_Pending__c == null?0:bmHeader.ASI_KOR_CA_Amount_Pending__c;
        bmHeader.ASI_KOR_CA_Amount_Pending__c = caAmountPending  - getSRTotalFinalCAAmountexclBasic();
        /* [VL 3.0] BEGIN */
        bmHeader.ASI_KOR_Total_VI_Pending__c = bmHeader.ASI_KOR_Total_VI_Pending__c == null ? 0 : (bmHeader.ASI_KOR_Total_VI_Pending__c - getSRTotalFinalBasic());
        /* [VL 3.0] END */
        
        try{
            update srPaymentSettlementHeader;
            update bmHeader;
            
        } catch ( DmlException exc) {
            ApexPages.addMessages(exc);
            return null;
        }
        PageReference pageRef   = new PageReference('/apex/ASI_KOR_SRPaymentSettlement?id='+srPaymentSettlementHeader.id);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public static void rollUpDetails(Id headerId){
        List<ASI_KOR_SR_Payment_Settlement_Detail__c> srPaymentSettlementList = [select id, ASI_KOR_Roll_up__c from 
                                                                                 ASI_KOR_SR_Payment_Settlement_Detail__c where ASI_KOR_SR_Payment_Settlement__c = :headerId];
        for(ASI_KOR_SR_Payment_Settlement_Detail__c s : srPaymentSettlementList ){
            s.ASI_KOR_Roll_up__c = true;
        }
        try{
            update srPaymentSettlementList ;
        } catch ( DmlException exc) {
            ApexPages.addMessages(exc);
        }
    }
    
    
    public static void rollDownDetails(Id headerId){
        List<ASI_KOR_SR_Payment_Settlement_Detail__c> srPaymentSettlementList = [select id, ASI_KOR_Roll_up__c from 
                                                                                 ASI_KOR_SR_Payment_Settlement_Detail__c where ASI_KOR_SR_Payment_Settlement__c = :headerId];
        for(ASI_KOR_SR_Payment_Settlement_Detail__c s : srPaymentSettlementList ){
            s.ASI_KOR_Roll_up__c = false;
        }
        try{
            update srPaymentSettlementList ;
        } catch ( DmlException exc) {
            ApexPages.addMessages(exc);
        }
    }
    
    
    
    public static void rollUp(Id headerId){
        List<ASI_KOR_SR_Payment_Settlement_By_Brand__c> srPaymentSettlementByBrandList = [select id, ASI_KOR_Roll_up__c from 
                                                                                          ASI_KOR_SR_Payment_Settlement_By_Brand__c where ASI_KOR_SR_Payment_Settlement__c = :headerId];
        for(ASI_KOR_SR_Payment_Settlement_By_Brand__c s : srPaymentSettlementByBrandList){
            s.ASI_KOR_Roll_up__c = true;
        }
        try{
            update srPaymentSettlementByBrandList;
        } catch ( DmlException exc) {
            ApexPages.addMessages(exc);
        }
    }
    
    
    public static void rollDown(Id headerId){
        List<ASI_KOR_SR_Payment_Settlement_By_Brand__c> srPaymentSettlementByBrandList = [select id, ASI_KOR_Roll_up__c from 
                                                                                          ASI_KOR_SR_Payment_Settlement_By_Brand__c where ASI_KOR_SR_Payment_Settlement__c = :headerId];
        for(ASI_KOR_SR_Payment_Settlement_By_Brand__c s : srPaymentSettlementByBrandList){
            s.ASI_KOR_Roll_up__c = false;
        }
        try{
            update srPaymentSettlementByBrandList;
        } catch ( DmlException exc) {
            ApexPages.addMessages(exc);
        }
    }
    
    /* [VL 2.0] BEGIN */
    public class PaymentSettlementDetailsByVenueByCAbrand {
        public Decimal caAmountexclBasic {get;set;}
        public Decimal finalCAAmountexclBasic {get;set;}
        public Decimal finalBasic {get;set;}
        public Decimal finalPrepayment {get;set;}
        public Decimal finalTotal {get;set;}
        public Decimal actualVolume {get;set;}
        public String caBrand {get;set;}
        
        public List<ASI_KOR_SR_Payment_Settlement_Detail__c> paymentSettlementDetails {get;set;}
        
        public PaymentSettlementDetailsByVenueByCAbrand(string caBrand, List<ASI_KOR_SR_Payment_Settlement_Detail__c> paymentSettlementDetails){
            caAmountexclBasic = 0;
            finalCAAmountexclBasic  = 0;
            finalBasic = 0;
            finalPrepayment = 0;
            finalTotal = 0;
            actualVolume = 0;
            this.caBrand = caBrand;
            this.paymentSettlementDetails = paymentSettlementDetails ;
            if (paymentSettlementDetails.size() > 0)
            {
                for(ASI_KOR_SR_Payment_Settlement_Detail__c detail : paymentSettlementDetails ){
                    if(detail.ASI_KOR_CA_Amount_excl_Basic__c!= null)
                    {
                        caAmountexclBasic += detail.ASI_KOR_CA_Amount_excl_Basic__c;
                    }
                    if(detail.ASI_KOR_Final_CA_Amount_excl_Basic__c!= null)
                    {
                        finalCAAmountexclBasic  += detail.ASI_KOR_Final_CA_Amount_excl_Basic__c;     
                    }
                    if(detail.ASI_KOR_Final_Basic_Amount__c!= null)
                    {
                        finalBasic  += detail.ASI_KOR_Final_Basic_Amount__c;     
                    }
                    if(detail.ASI_KOR_Pre_Payment_Amount__c!= null)
                    {
                        finalPrepayment  += detail.ASI_KOR_Pre_Payment_Amount__c;     
                    }
                    if(detail.ASI_KOR_Final_Total_Amount__c!= null)
                    {
                        finalTotal  += detail.ASI_KOR_Final_Total_Amount__c;     
                    }
                    if(detail.ASI_KOR_Actual_Volume__c!= null)
                    {
                        actualVolume  += detail.ASI_KOR_Actual_Volume__c;     
                    }
                }    
            }
        }
    }
    /* [VL 2.0] END */
    
    public class PaymentSettlementDetailsByVenue {
        public Decimal caAmountexclBasic {get;set;}
        public Decimal finalCAAmountexclBasic {get;set;}
        /* [VL 1.0] BEGIN */
        public Decimal finalBasic {get;set;}
        public Decimal finalPrepayment {get;set;}
        public Decimal finalTotal {get;set;}
        /* [VL 1.0] END */
        public Account venue {get;set;}
        public String contactId {get;set;}
        
        /* [VL 2.0] BEGIN */
        /*
        public List<ASI_KOR_SR_Payment_Settlement_Detail__c> paymentSettlementDetails {get;set;}
        */
        public List<PaymentSettlementDetailsByVenueByCAbrand> paymentSettlementDetailsByCAbrand {get;set;}
        /* [VL 2.0] END */
        
        public PaymentSettlementDetailsByVenue(Account venue,  List<ASI_KOR_SR_Payment_Settlement_Detail__c> paymentSettlementDetails){
            caAmountexclBasic = 0;
            finalCAAmountexclBasic  = 0;
            /* [VL 1.0] BEGIN */
            finalBasic = 0;
            finalPrepayment = 0;
            finalTotal = 0;
            /* [VL 1.0] END */
            this.venue = venue;
            /* [VL 2.0] BEGIN */
            /*
            this.paymentSettlementDetails = paymentSettlementDetails ;
            */
            map<string, list<ASI_KOR_SR_Payment_Settlement_Detail__c>> map_caBrand_detail = new map<string, list<ASI_KOR_SR_Payment_Settlement_Detail__c>>();
            /* [VL 2.0] END */
            if (paymentSettlementDetails.size() > 0)
            {
                contactId = paymentSettlementDetails.get(0).ASI_KOR_Keyman_Code__c;
                for(ASI_KOR_SR_Payment_Settlement_Detail__c detail : paymentSettlementDetails ){
                    if(detail.ASI_KOR_CA_Amount_excl_Basic__c!= null)
                    {
                        caAmountexclBasic += detail.ASI_KOR_CA_Amount_excl_Basic__c;
                    }
                    if(detail.ASI_KOR_Final_CA_Amount_excl_Basic__c!= null)
                    {
                        finalCAAmountexclBasic  += detail.ASI_KOR_Final_CA_Amount_excl_Basic__c;     
                    }
                    /* [VL 1.0] BEGIN */
                    if(detail.ASI_KOR_Final_Basic_Amount__c!= null)
                    {
                        finalBasic  += detail.ASI_KOR_Final_Basic_Amount__c;     
                    }
                    if(detail.ASI_KOR_Pre_Payment_Amount__c!= null)
                    {
                        finalPrepayment  += detail.ASI_KOR_Pre_Payment_Amount__c;     
                    }
                    if(detail.ASI_KOR_Final_Total_Amount__c!= null)
                    {
                        finalTotal  += detail.ASI_KOR_Final_Total_Amount__c;     
                    }
                    /* [VL 1.0] END */
                    /* [VL 2.0] BEGIN */
                    string caBrand = detail.ASI_KOR_Brand__r.ASI_KOR_CA_Brand__c != null ? detail.ASI_KOR_Brand__r.ASI_KOR_CA_Brand__r.name : detail.ASI_KOR_Brand__r.name;
                    if (map_caBrand_detail == null || !map_caBrand_detail.containsKey(caBrand)){
                        list<ASI_KOR_SR_Payment_Settlement_Detail__c> temp_list_detail = new list<ASI_KOR_SR_Payment_Settlement_Detail__c>();
                        temp_list_detail.add(detail);
                        map_caBrand_detail.put(caBrand, temp_list_detail);
                    } else {
                        map_caBrand_detail.get(caBrand).add(detail);
                    }
                    /* [VL 2.0] END */
                }    
                /* [VL 2.0] BEGIN */
                this.paymentSettlementDetailsByCAbrand = new List<PaymentSettlementDetailsByVenueByCAbrand>();
                for (string caBrand : map_caBrand_detail.keySet()){
                    PaymentSettlementDetailsByVenueByCAbrand detail_byCAbrand = new PaymentSettlementDetailsByVenueByCAbrand(
                        caBrand,
                        map_caBrand_detail.get(caBrand)
                    );
                    this.paymentSettlementDetailsByCAbrand.add(detail_byCAbrand);
                }
                /* [VL 2.0] END */
            }
        }
    }
    
    
    public class SRSettlementByBrandByCategory {
        public String category {get; set; }
        public List<SRPaymentSettlementByBrand> srPaymentSettlementByBrands {get; set; }
        
        public Decimal getTotalVolume(){
            Decimal temp = 0;
            for(SRPaymentSettlementByBrand paymentSettlementBrand : srPaymentSettlementByBrands ){
                if(paymentSettlementBrand.paymentSettlementByBrand.ASI_KOR_Target_Volume__c!= null)
                    temp += paymentSettlementBrand.paymentSettlementByBrand.ASI_KOR_Target_Volume__c;
            }
            return temp;
        }
        
        public Decimal getCABudget(){
            Decimal temp = 0;
            for(SRPaymentSettlementByBrand paymentSettlementBrand : srPaymentSettlementByBrands ){
                if(paymentSettlementBrand.paymentSettlementByBrand.ASI_KOR_BM_Payment_Settlement_By_Brand__r.ASI_KOR_CA_Budget__c!= null)
                    temp += paymentSettlementBrand.paymentSettlementByBrand.ASI_KOR_BM_Payment_Settlement_By_Brand__r.ASI_KOR_CA_Budget__c;
            }
            return temp;
        } 
        
        public Decimal getTotalCAAmountexclBasic(){
            Decimal temp = 0;
            for(SRPaymentSettlementByBrand paymentSettlementBrand : srPaymentSettlementByBrands ){
                if(paymentSettlementBrand.paymentSettlementByBrand.ASI_KOR_Total_CA_Amount_excl_Basic__c!= null)
                    temp += paymentSettlementBrand.paymentSettlementByBrand.ASI_KOR_Total_CA_Amount_excl_Basic__c;
            }
            return temp;
        }
        
        public Decimal getTotalFinalCAAmountexclBasic(){
            Decimal temp = 0;
            for(SRPaymentSettlementByBrand paymentSettlementBrand : srPaymentSettlementByBrands ){
                if(paymentSettlementBrand.paymentSettlementByBrand.ASI_KOR_Total_Final_CA_Amount_excl_Basic__c!= null)
                    temp += paymentSettlementBrand.paymentSettlementByBrand.ASI_KOR_Total_Final_CA_Amount_excl_Basic__c;
            }
            return temp;
        }  
        
        /* [VL 1.0] BEGIN */
        public Decimal getTotalFinalBasic(){
            Decimal temp = 0;
            for(SRPaymentSettlementByBrand paymentSettlementBrand : srPaymentSettlementByBrands ){
                if(paymentSettlementBrand.paymentSettlementByBrand.ASI_KOR_Total_Final_Basic__c!= null)
                    temp += paymentSettlementBrand.paymentSettlementByBrand.ASI_KOR_Total_Final_Basic__c;
            }
            return temp;
        }  
        
        public Decimal getTotalPrepayment(){
            Decimal temp = 0;
            for(SRPaymentSettlementByBrand paymentSettlementBrand : srPaymentSettlementByBrands ){
                if(paymentSettlementBrand.paymentSettlementByBrand.ASI_KOR_Pre_Payment_Amount__c!= null)
                    temp += paymentSettlementBrand.paymentSettlementByBrand.ASI_KOR_Pre_Payment_Amount__c;
            }
            return temp;
        }  
        
        public Decimal getTotalFinal(){
            Decimal temp = 0;
            for(SRPaymentSettlementByBrand paymentSettlementBrand : srPaymentSettlementByBrands ){
                if(paymentSettlementBrand.paymentSettlementByBrand.ASI_KOR_Final_Total_Amount__c!= null)
                    temp += paymentSettlementBrand.paymentSettlementByBrand.ASI_KOR_Final_Total_Amount__c;
            }
            return temp;
        }  
        /* [VL 1.0] END */
        
        /* [VL 3.0] BEGIN */
        public Decimal getTotalNormalVolume(){
            Decimal temp = 0;
            for(SRPaymentSettlementByBrand paymentSettlementBrand : srPaymentSettlementByBrands ){
                if(paymentSettlementBrand.paymentSettlementByBrand.ASI_KOR_Actual_Volume__c!= null)
                    temp += paymentSettlementBrand.paymentSettlementByBrand.ASI_KOR_Actual_Volume__c;
            }
            return temp;
        }  
        public Decimal getTotalPrepaymentVolume(){
            Decimal temp = 0;
            for(SRPaymentSettlementByBrand paymentSettlementBrand : srPaymentSettlementByBrands ){
                if(paymentSettlementBrand.paymentSettlementByBrand.ASI_KOR_Actual_Pre_payment_Volume__c!= null)
                    temp += paymentSettlementBrand.paymentSettlementByBrand.ASI_KOR_Actual_Pre_payment_Volume__c;
            }
            return temp;
        }  
        public Decimal getTotalVolumeAll(){
            Decimal temp = 0;
            for(SRPaymentSettlementByBrand paymentSettlementBrand : srPaymentSettlementByBrands ){
                if(paymentSettlementBrand.paymentSettlementByBrand.ASI_KOR_Actual_Volume_Total__c!= null)
                    temp += paymentSettlementBrand.paymentSettlementByBrand.ASI_KOR_Actual_Volume_Total__c;
            }
            return temp;
        }  
        public Decimal getActualUnitCost(){
            return getTotalFinalBasic()/(getTotalVolume() == 0 ? 1 : getTotalVolume());
        }  
        /* [VL 3.0] END */
        
    }
    
    // Added Wrapper Class for ASI_KOR_SR_Payment_Settlement_By_Brand__c to cater formula field
    public class SRPaymentSettlementByBrand {
        
        public ASI_KOR_SR_Payment_Settlement_By_Brand__c paymentSettlementByBrand {get;set;}
        public decimal settlementUnitCost {get;set;}
        
        /* [VL 3.0] BEGIN */
        public boolean getDisplay(){
            if (
                this.paymentSettlementByBrand.ASI_KOR_Target_Volume__c == 0 &&
                this.paymentSettlementByBrand.ASI_KOR_Actual_Volume__c == 0 &&
                this.paymentSettlementByBrand.ASI_KOR_Total_Final_Basic__c == 0 &&
                this.paymentSettlementByBrand.ASI_KOR_Actual_Pre_payment_Volume__c == 0 &&
                this.paymentSettlementByBrand.ASI_KOR_Pre_Payment_Amount__c == 0 &&
                this.paymentSettlementByBrand.ASI_KOR_Actual_Volume_Total__c == 0 &&
                this.paymentSettlementByBrand.ASI_KOR_Final_Total_Amount__c == 0
            ){
                return false;
            } else {
                return true;
            }
        }
        /* [VL 3.0] END */
        
    } 
    
    public Decimal getSRTotalCAAmountexclBasic()
    {
        Decimal temp = 0;
        for(SRSettlementByBrandByCategory srSettlementByBrandByCategory:srSettlementByBrandCategoryList)
        {
            temp += srSettlementByBrandByCategory.getTotalCAAmountexclBasic();    
        }
        return temp;
    }
    
    public Decimal getSRCABudget()
    {
        Decimal temp = 0;
        for(SRSettlementByBrandByCategory srSettlementByBrandByCategory:srSettlementByBrandCategoryList)
        {
            temp += srSettlementByBrandByCategory.getCABudget();    
        }
        return temp;
    }
    
    public Decimal getSRTotalFinalCAAmountexclBasic()
    {
        Decimal temp = 0;
        for(SRSettlementByBrandByCategory srSettlementByBrandByCategory:srSettlementByBrandCategoryList)
        {
            temp += srSettlementByBrandByCategory.getTotalFinalCAAmountexclBasic();    
        }
        return temp;
    }
    
    /* [VL 1.0] BEGIN */
    public Decimal getSRTotalFinalBasic()
    {
        Decimal temp = 0;
        for(SRSettlementByBrandByCategory srSettlementByBrandByCategory:srSettlementByBrandCategoryList)
        {
            temp += srSettlementByBrandByCategory.getTotalFinalBasic();    
        }
        return temp;
    }
    
    public Decimal getSRTotalPrepayment()
    {
        Decimal temp = 0;
        for(SRSettlementByBrandByCategory srSettlementByBrandByCategory:srSettlementByBrandCategoryList)
        {
            temp += srSettlementByBrandByCategory.getTotalPrepayment();    
        }
        return temp;
    }
    
    public Decimal getSRTotalFinal()
    {
        Decimal temp = 0;
        for(SRSettlementByBrandByCategory srSettlementByBrandByCategory:srSettlementByBrandCategoryList)
        {
            temp += srSettlementByBrandByCategory.getTotalFinal();    
        }
        return temp;
    }
    /* [VL 1.0] END */
    
    /* [VL 3.0] BEGIN */
    public Decimal getSRTotalTargetVolume()
    {
        Decimal temp = 0;
        for(SRSettlementByBrandByCategory srSettlementByBrandByCategory:srSettlementByBrandCategoryList)
        {
            temp += srSettlementByBrandByCategory.getTotalVolume();    
        }
        return temp;
    }
    public Decimal getSRTotalNormalVolume()
    {
        Decimal temp = 0;
        for(SRSettlementByBrandByCategory srSettlementByBrandByCategory:srSettlementByBrandCategoryList)
        {
            temp += srSettlementByBrandByCategory.getTotalNormalVolume();    
        }
        return temp;
    }
    public Decimal getSRTotalPrepaymentVolume()
    {
        Decimal temp = 0;
        for(SRSettlementByBrandByCategory srSettlementByBrandByCategory:srSettlementByBrandCategoryList)
        {
            temp += srSettlementByBrandByCategory.getTotalPrepaymentVolume();    
        }
        return temp;
    }
    public Decimal getSRTotalVolumeAll()
    {
        Decimal temp = 0;
        for(SRSettlementByBrandByCategory srSettlementByBrandByCategory:srSettlementByBrandCategoryList)
        {
            temp += srSettlementByBrandByCategory.getTotalVolumeAll();    
        }
        return temp;
    }
    public Decimal getSRTotalUnitCost()
    {
        return getSRTotalFinalBasic() / (getSRTotalNormalVolume() == 0 ? 1 : getSRTotalNormalVolume());
    }
    /* [VL 3.0] END */
    
    public List<PaymentSettlementDetailsByVenue> paymentSettlementDetailsByVenueList {get;set;}
    public List<Account> venues {get;set;}
    public List<ASI_KOR_SR_Proposal_By_Brand__c> srProposalByBrand { get; set;} 
    public List<SRSettlementByBrandByCategory> srSettlementByBrandCategoryList { get; set; }
    
    
    private void populateSRPaymentBranch()
    {
        srSettlementByBrandCategoryList = new List<SRSettlementByBrandByCategory>();
        
        List<ASI_KOR_SR_Payment_Settlement_By_Brand__c> srPaymentSettlementByBrands1 = [SELECT ID, 
                                                                                        Name, ASI_KOR_Brand__c,  ASI_KOR_Category__c, ASI_KOR_Target_Volume__c, ASI_KOR_Total_CA_Amount_excl_Basic__c,
                                                                                        ASI_KOR_Approved_Basic_Unit_Cost_Ave__c
                                                                                        ,ASI_KOR_Actual_Unit_Cost_CA_Only__c,ASI_KOR_Actual_Volume__c,ASI_KOR_Progression__c,
                                                                                        ASI_KOR_BM_Payment_Settlement_By_Brand__r.ASI_KOR_CA_Budget__c,ASI_KOR_Approved_Basic_Unit_Cost__c,
                                                                                        ASI_KOR_Total_Final_CA_Amount_excl_Basic__c ,ASI_KOR_UOM__c, ASI_KOR_Approved_Unit_Cost_Basic_CA__c 
                                                                                        /* [VL 1.0] BEGIN */
                                                                                        , ASI_KOR_Total_Final_Basic__c
                                                                                        , ASI_KOR_Pre_Payment_Amount__c
                                                                                        , ASI_KOR_Final_Total_Amount__c
                                                                                        /* [VL 1.0] END */
                                                                                        /* [VL 3.0] BEGIN */
                                                                                        , ASI_KOR_Actual_Pre_payment_Volume__c
                                                                                        , ASI_KOR_Actual_Volume_Total__c
                                                                                        /* [VL 3.0] END */
                                                                                        from ASI_KOR_SR_Payment_Settlement_By_Brand__c 
                                                                                        where ASI_KOR_SR_Payment_Settlement__c =:srPaymentSettlementHeader.Id];
        
        List<SRPaymentSettlementByBrand> srPaymentSettlementByBrands = new List<SRPaymentSettlementByBrand>();
        
        for(ASI_KOR_SR_Payment_Settlement_By_Brand__c paymentSettlement : srPaymentSettlementByBrands1) {
            SRPaymentSettlementByBrand paymentWrapper = new SRPaymentSettlementByBrand();
            paymentWrapper.paymentSettlementByBrand = paymentSettlement;
            Decimal totalFinalCa = paymentSettlement.ASI_KOR_Total_Final_CA_Amount_excl_Basic__c != null ? paymentSettlement.ASI_KOR_Total_Final_CA_Amount_excl_Basic__c : 0;
            Decimal actVolume = paymentSettlement.ASI_KOR_Actual_Volume__c != null ? paymentSettlement.ASI_KOR_Actual_Volume__c : 0;
            paymentWrapper.settlementUnitCost = actVolume == 0 ? 0 : totalFinalCa/actVolume;
            srPaymentSettlementByBrands.add(paymentWrapper);
        }
        
        Map<String, List<SRPaymentSettlementByBrand>> branchCategoryMap = new Map<String, List<SRPaymentSettlementByBrand>>();
        
        for(SRPaymentSettlementByBrand srPaymentSettlement : srPaymentSettlementByBrands){
            if(branchCategoryMap.get(srPaymentSettlement.paymentSettlementByBrand.ASI_KOR_Category__c) == null){
                List<SRPaymentSettlementByBrand> l = new List<SRPaymentSettlementByBrand >();
                l.add(srPaymentSettlement);
                branchCategoryMap.put(srPaymentSettlement.paymentSettlementByBrand.ASI_KOR_Category__c,l);
            }else{ 
                branchCategoryMap.get(srPaymentSettlement.paymentSettlementByBrand.ASI_KOR_Category__c).add(srPaymentSettlement);
            }
        }
        
        String[] categories = new String[] {'Local Whisky','International Whisky','Modern Spirits','Competitor�s brands'};
            
            /* [VL 3.0] BEGIN */
            /*
            for(String category:  categories){
            */
            for(String category:  branchCategoryMap.keySet()){
            /* [VL 3.0] END */
                if(branchCategoryMap.get(category) == null)
                    continue; 
                SRSettlementByBrandByCategory sr = new SRSettlementByBrandByCategory();
                sr.category = category;
                sr.srPaymentSettlementByBrands  = branchCategoryMap.get(category);
                srSettlementByBrandCategoryList.add(sr);
            }
        
    }
    
    /* [VL 4.0] BEGIN */
    public string getExceptionalReport_unitCost(){
        report report = [Select ID from Report where DeveloperName = 'ASI_CRM_KR_Payment_Exceptional_Report_UC' limit 1];
        return report.id;
    }
    public string getExceptionalReport_notPlanned(){
        report report = [Select ID from Report where DeveloperName = 'ASI_CRM_KR_Payment_Exceptional_Report_XPlan' limit 1];
        return report.id;
    }
    public string getYear(){
        return srPaymentSettlementHeader.ASI_KOR_Year__c;
    }
    public string getMonth(){
        return srPaymentSettlementHeader.ASI_KOR_Month__c;
    }
    /* [VL 4.0] BEGIN */
    
    /* [VL 6.0] BEGIN */
    public PageReference refreshVenueSummary(){    
        populateVenueSummary();
        return null;
    }
    /* [VL 6.0] BEGIN */
    
    
}