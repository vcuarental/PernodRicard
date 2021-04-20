public with sharing class ASI_MFM_MY_FVerifyLWCController
{
    public class Result
    {
        @AuraEnabled
        public List<ASI_MFM_Payment_Line_Item__c> paymentLines { get; set; }

        @AuraEnabled
        public Map<Id, Boolean> paymentMap { get; set; }

        @AuraEnabled
        public List<SummarySubbrand> summary { get; set; }

        @AuraEnabled
        public Statistic statistic { get; set; }

        @AuraEnabled
        public Integer totalPage { get; set; }

        @AuraEnabled
        public Boolean fVerify { get; set; }

        @AuraEnabled
        public String fy { get; set; }

        @AuraEnabled
        public String rid { get; set; }

        @AuraEnabled
        public String pid { get; set; }

        @AuraEnabled
        public String eid { get; set; }
    }
    
    public class SummarySubbrand
    {
        @AuraEnabled
        public Decimal totalTPA { get; private set; }

        @AuraEnabled
        public Decimal totalTPABC { get; private set; }

        @AuraEnabled
        public String name { get; private set; }
        
        public SummarySubbrand(AggregateResult ar)
        {
            totalTPA = (Decimal) ar.get('TPA');
            totalTPABC = (Decimal) ar.get('TPABC');
            name = (String) ar.get('Name');
        }
    }

    public class Statistic
    {
        @AuraEnabled
        public Decimal totalRemainingPO { get; set; }

        @AuraEnabled
        public Decimal totalPayment { get; set; }

        @AuraEnabled
        public Decimal verifiedPY { get; set; }

        @AuraEnabled
        public Decimal unverifiedPY { get; set; }
    }

    public class callResult
	{
		@AuraEnabled
		public String type { get; set; }

		@AuraEnabled
        public String message { get; set; }
	}

    @AuraEnabled
    public static Result getPaymentLine(
                            Boolean fVerify,
                            String paymentID,
                            String paymentStatus,
                            String poID,
                            String fy,
                            String invoiceNo,
                            String subBrandCode,
                            String subBrandName,
                            String supplierNo,
                            String supplier,
                            Date invoiceDateFrom,
                            Date invoiceDateTo,
                            String sortBy,
                            String sortDir,
                            Integer page,
                            Integer pageSize)
    {
        // build query
        String soql ='select id, name,ASI_MFM_ETL__c,ASI_MFM_ETL_Date__c,ASI_MFM_Payment__r.ASI_MFM_Invoice_Due_Date__c,ASI_MFM_Payment__r.ASI_MFM_Invoice_Number__c,ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_Complete__c,ASI_MFM_G_L_Date__c,ASI_MFM_Complete_POL__c,ASI_MFM_Finance_Verify_Save_Date__c,ASI_MFM_A_C_Code__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_A_C_Code__c,ASI_MFM_ETL_Failed__c,ASI_MFM_Comments__c,ASI_MFM_Payment__r.name,ASI_MFM_PO_Line_Item__r.ASI_MFM_Remaining_Balance__c, ASI_MFM_Invoice_Date__c,ASI_MFM_Payment_Date__c,ASI_MFM_Paid_Amount_in_Base_Currency__c,ASI_MFM_Status_Invalid__c,ASI_MFM_Payment__r.ASI_MFM_Exchange_Rate__c,ASI_MFM_PO_Line_Item__r.name,ASI_MFM_Payment_Line_Item_Finance_Verify__c, ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.name,ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c, ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.Name, ASI_MFM_PO_Line_Item__c, ASI_MFM_Payment__c, ASI_MFM_Payee__c, ASI_MFM_Payee__r.Name, ASI_MFM_Currency__c , ASI_MFM_PO_Line_Remaining_Amount__c, ASI_MFM_Payment_Amount__c, ASI_MFM_Invoice_Number__c, ASI_MFM_Due_Date__c, ASI_MFM_Payment__r.ASI_MFM_Status__c, ASI_MFM_TH_Tax_Type__c,ASI_MFM_Payment_List_Item_Description__c, ASI_MFM_Withholding_Tax__c, ASI_MFM_Withholding_Tax_Amount__c  from ASI_MFM_Payment_Line_Item__c where ASI_MFM_Voucher_Created__c=false AND ASI_MFM_Payment__r.ASI_MFM_Status__c != \'Draft\' AND ASI_MFM_Payment__r.ASI_MFM_Status__c != \'Submitted\' AND  ASI_MFM_Payment__r.RecordType.DeveloperName LIKE \'ASI_MFM_MY_Payment%\' ';
        String soqlSubbrand ='select ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.name Name,sum(ASI_MFM_Payment_Amount__c) TPA, sum(ASI_MFM_Paid_Amount_in_Base_Currency__c) TPABC from ASI_MFM_Payment_Line_Item__c where ASI_MFM_Payment__r.ASI_MFM_ETL__c = false AND ASI_MFM_Payment__r.ASI_MFM_Status__c != \'Draft\' AND  ASI_MFM_Payment__r.RecordType.DeveloperName LIKE \'ASI_MFM_MY_Payment%\'  ';

        if (fVerify == null)
        {
            fVerify = false;
        }

        if (fVerify != null)
        {
            if (fVerify == false)
            {
                soqlSubbrand += ' and ASI_MFM_Payment_Line_Item_Finance_Verify__c = false ';
                soql += ' and ASI_MFM_Payment_Line_Item_Finance_Verify__c = false ';
            }
            else
            {
                soqlSubbrand += ' and ASI_MFM_Payment_Line_Item_Finance_Verify__c = true ';
                soql += ' and ASI_MFM_Payment_Line_Item_Finance_Verify__c = true ';
            }
        }
        
        if (String.isNotEmpty(poID))
        {
            soqlSubbrand += ' and ASI_MFM_PO__r.name LIKE \''+String.escapeSingleQuotes(poID)+'%\'';
            soql += ' and ASI_MFM_PO__r.name LIKE \''+String.escapeSingleQuotes(poID)+'%\'';
        }

        if (String.isEmpty(fy))
        {
            String NowFY = 'FY';
            Date Today_date = Date.today();
            
            if (Today_date.month() > 0 && Today_date.month() < 7)
            {
                NowFY = NowFY + string.valueof(Today_date.year() - 1).substring(2, 4) + string.valueof(Today_date.year()).substring(2, 4);
            }
            else
            {
                NowFY = NowFY + string.valueof(Today_date.year()).substring(2, 4) + string.valueof(Today_date.year() + 1).substring(2, 4);
            }
            
            fy = NowFY;
        }

        if (String.isNotEmpty(fy))
        {
            soqlSubbrand += ' and ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c LIKE \''+String.escapeSingleQuotes(fy)+'%\'';
            soql += ' and ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c LIKE \''+String.escapeSingleQuotes(fy)+'%\'';
        }
        
        if (String.isNotEmpty(paymentID))
        {
            soql += ' and ASI_MFM_Payment__r.name LIKE \''+String.escapeSingleQuotes(paymentID)+'%\'';
            soqlSubbrand += ' and ASI_MFM_Payment__r.name LIKE \''+String.escapeSingleQuotes(paymentID)+'%\'';
        }

        paymentStatus = 'Final';
        if (String.isEmpty(paymentStatus))
        {
            soql += ' and ASI_MFM_Payment__r.ASI_MFM_Status__c LIKE \''+String.escapeSingleQuotes(paymentStatus)+'%\'';
            soqlSubbrand += ' and ASI_MFM_Payment__r.ASI_MFM_Status__c LIKE \''+String.escapeSingleQuotes(paymentStatus)+'%\'';
        }
        
        if (String.isNotEmpty(invoiceNo))
        {
            soql += ' and ASI_MFM_Payment__r.ASI_MFM_Invoice_Number__c LIKE \''+String.escapeSingleQuotes(invoiceNo)+'%\'';
            soqlSubbrand += ' and ASI_MFM_Payment__r.ASI_MFM_Invoice_Number__c LIKE \''+String.escapeSingleQuotes(invoiceNo)+'%\'';
        }

        if (String.isNotEmpty(subBrandCode))
        {
            soql += ' and ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c LIKE \'%'+String.escapeSingleQuotes(subBrandCode)+'%\'';
            soqlSubbrand += ' and ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c LIKE \'%'+String.escapeSingleQuotes(subBrandCode)+'%\'';
        }
        
        if (String.isNotEmpty(subBrandName))
        {
            soql += ' and ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.name LIKE \'%'+String.escapeSingleQuotes(subBrandName)+'%\'';
            soqlSubbrand += ' and ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.name LIKE \'%'+String.escapeSingleQuotes(subBrandName)+'%\'';
        }
        
        if (String.isNotEmpty(supplierNo))
        {
            soql += ' and ASI_MFM_PO__r.ASI_MFM_Supplier_Name__r.ASI_MFM_Customer_Supplier_Number__c LIKE \'%'+String.escapeSingleQuotes(supplierNo)+'%\'';
            soqlSubbrand += ' and ASI_MFM_PO__r.ASI_MFM_Supplier_Name__r.ASI_MFM_Customer_Supplier_Number__c LIKE \'%'+String.escapeSingleQuotes(supplierNo)+'%\'';
        }
        
        if (String.isNotEmpty(supplier))
        {
            soql += ' and ASI_MFM_PO__r.ASI_MFM_Supplier_Name__r.name LIKE \'%'+String.escapeSingleQuotes(supplier)+'%\'';
            soqlSubbrand += ' and ASI_MFM_PO__r.ASI_MFM_Supplier_Name__r.name LIKE \'%'+String.escapeSingleQuotes(supplier)+'%\'';
        }
        
        if (invoiceDateFrom != null)
        {
            String fromDate = DateTime.newInstance(invoiceDateFrom.year(), invoiceDateFrom.month(), invoiceDateFrom.day(), 0,0,0).format('yyyy-MM-dd');
            soql += ' AND ASI_MFM_Payment__r.ASI_MFM_Invoice_Due_Date__c  >= ' + fromDate + ''; 
            soqlSubbrand += ' AND ASI_MFM_Payment__r.ASI_MFM_Invoice_Due_Date__c  >= ' + fromDate + ''; 
        }

        if (invoiceDateTo != null)
        {
            String toDate = DateTime.newInstance(invoiceDateTo.year(), invoiceDateTo.month(), invoiceDateTo.day(), 0,0,0).format('yyyy-MM-dd');
            soql += ' AND ASI_MFM_Payment__r.ASI_MFM_Invoice_Due_Date__c    <= ' + toDate + ''; 
            soqlSubbrand += ' AND ASI_MFM_Payment__r.ASI_MFM_Invoice_Due_Date__c    <= ' + toDate + ''; 
        }

        if (String.isEmpty(sortBy))
        {
            sortBy = 'ASI_MFM_Payment__r.ASI_MFM_Status__c';
        }

        if (String.isEmpty(sortDir))
        {
            sortDir = 'asc';
        }

        if (pageSize <= 0)
        {
            pageSize = 50;
        }

        // process data
        Result result = new Result();
        result.statistic = new Statistic();
        result.statistic.totalRemainingPO = 0;
        result.statistic.totalPayment = 0;
        result.statistic.verifiedPY = 0;
        result.statistic.unverifiedPY = 0;
        result.paymentLines = new List<ASI_MFM_Payment_Line_Item__c>();
        result.paymentMap = new Map<ID, Boolean>();
        result.summary = new List<SummarySubbrand>();
        result.totalPage = 0;
        result.fVerify = fVerify;
        result.fy = fy;
        
        try {
            for (Report report : [Select ID, DeveloperName from Report where DeveloperName in ('ASI_MFM_MY_Invalid_Payment_Line_Report', 'ASI_MFM_MY_Finance_Verify_Report', 'ASI_MFM_MY_ETL_Report')])
            {
                if (report.DeveloperName == 'ASI_MFM_MY_Invalid_Payment_Line_Report')
                {
                    result.rid = (String)report.ID;
                }
                else if (report.DeveloperName == 'ASI_MFM_MY_Finance_Verify_Report')
                {
                    result.pid = (String)report.ID;
                }
                else if (report.DeveloperName == 'ASI_MFM_MY_ETL_Report')
                {
                    result.eid = (String)report.ID;
                }
            }

            String SubbrandGroup ='group by ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.name';
            String SubbrandSear = soqlSubbrand + SubbrandGroup;

            AggregateResult[] groupedResults = Database.query(SubbrandSear);

            for (AggregateResult ar : groupedResults) 
            {
                result.summary.add(new SummarySubbrand(ar));
            }

            groupedResults.clear();
            
            List<ASI_MFM_Payment_Line_Item__c> totalLineItem = Database.query(soql + ' order by ' + sortBy + ' ' + sortDir);
            
            for (ASI_MFM_Payment_Line_Item__c PAYLI : totalLineItem)
            {
                if (PAYLI.ASI_MFM_PO_Line_Remaining_Amount__c != null)
                {
                    if (PAYLI.ASI_MFM_Payment__r.ASI_MFM_Exchange_Rate__c != null)
                    {
                        result.statistic.totalRemainingPO = result.statistic.totalRemainingPO + PAYLI.ASI_MFM_PO_Line_Remaining_Amount__c * PAYLI.ASI_MFM_Payment__r.ASI_MFM_Exchange_Rate__c;
                    }
                    else
                    {
                        result.statistic.totalRemainingPO = result.statistic.totalRemainingPO + PAYLI.ASI_MFM_PO_Line_Remaining_Amount__c;
                    }    
                }

                if (PAYLI.ASI_MFM_Paid_Amount_in_Base_Currency__c !=null)
                {
                    result.statistic.totalPayment = PAYLI.ASI_MFM_Paid_Amount_in_Base_Currency__c + result.statistic.totalPayment;
                    
                    if (PAYLI.ASI_MFM_Payment_Line_Item_Finance_Verify__c == true)
                    {
                        result.statistic.verifiedPY = result.statistic.verifiedPY + PAYLI.ASI_MFM_Paid_Amount_in_Base_Currency__c;
                    }
                    else
                    {
                        result.statistic.unverifiedPY = result.statistic.unverifiedPY + PAYLI.ASI_MFM_Paid_Amount_in_Base_Currency__c;
                    }
                }
            }

            result.totalPage = (Integer)Math.ceil((Decimal)totalLineItem.size() / (Decimal)pageSize);

            if (page > result.totalPage)
            {
                page = result.totalPage;
            }

            if (page <= 0)
            {
                page = 1;
            }
            
            Integer offset = (page - 1) * pageSize;
            
            totalLineItem.clear();

            result.paymentLines = Database.query(soql + ' order by ' + sortBy + ' ' + sortDir + ' Limit ' + pageSize + ' OFFSET ' + offset);
             
            Date selectedDate =  Date.today(); 
            for (ASI_MFM_Payment_Line_Item__c pai: result.paymentLines)
            {
                pai.ASI_MFM_A_C_Code__c = pai.ASI_MFM_PO_Line_Item__r.ASI_MFM_A_C_Code__c;

                result.paymentMap.put(pai.id, pai.ASI_MFM_Payment_Line_Item_Finance_Verify__c);
                if (pai.ASI_MFM_Payment__r.ASI_MFM_Status__c == 'Final' && pai.ASI_MFM_Payment_Line_Item_Finance_Verify__c == false && pai.ASI_MFM_G_L_Date__c == null)
                {
                    pai.ASI_MFM_G_L_Date__c = selectedDate;
                }
            }
        }
        catch (Exception e)
        {
            System.debug(e.getMessage());
        }

        return result;
    }

    // save Fverify 
    @AuraEnabled
    public static CallResult savePaymentLine(string paymentLinesStr, Map<ID, Boolean> paymentMap)
    {
        CallResult result = new CallResult();
		result.type = 'success';
		result.message = 'No payment line updated.';

        List<ASI_MFM_Payment_Line_Item__c> paymentLines = (List<ASI_MFM_Payment_Line_Item__c>)System.JSON.deserializeStrict(paymentLinesStr, List<ASI_MFM_Payment_Line_Item__c>.class);
        List<ASI_MFM_Payment_Line_Item__c> updateList = new List<ASI_MFM_Payment_Line_Item__c>();
        Integer count = 0;
        Set<String> verLines = new Set<String>();

		if (paymentLines.size() == 0)
		{
			result.type = 'error';
			result.message = 'No lines found.';
			return result;
        }
        
		try
		{
            Map<id,boolean> PaymentVerifyMap = new Map<id,boolean>();
        
            Set<ID> po_set = new set<id>();
            for (ASI_MFM_Payment_Line_Item__c pli : paymentLines)
            {
                po_set.add(pli.ASI_MFM_PO_Line_Item__c); // Get PO Line Id
                if (!PaymentVerifyMap.containsKey(pli.ASI_MFM_Payment__c))
                {
                    PaymentVerifyMap.put(pli.ASI_MFM_Payment__c, pli.ASI_MFM_Payment_Line_Item_Finance_Verify__c);
                }
            }
            List<ASI_MFM_PO_Line_Item__c> polines = [select id,name,ASI_MFM_Finance_Verify_Date__c,ASI_MFM_A_C_Code__c from ASI_MFM_PO_Line_Item__c where id in: po_set];
            List<ASI_MFM_PO_Line_Item__c> poLinesUpdate = new List<ASI_MFM_PO_Line_Item__c>();

            for (ASI_MFM_PO_Line_Item__c poli : polines)
            {
                Boolean changestat = true;
                for (ASI_MFM_Payment_Line_Item__c pli : paymentLines)
                {
                    if (pli.ASI_MFM_PO_Line_Item__c == poli.id &&( (pli.ASI_MFM_Payment_Line_Item_Finance_Verify__c == true && pli.ASI_MFM_Finance_Verify_Save_Date__c != poli.ASI_MFM_Finance_Verify_Date__c) || pli.ASI_MFM_A_C_Code__c!=poli.ASI_MFM_A_C_Code__c) && changestat == true)
                    {
                        if (pli.ASI_MFM_Payment_Line_Item_Finance_Verify__c == true && pli.ASI_MFM_Finance_Verify_Save_Date__c != poli.ASI_MFM_Finance_Verify_Date__c)
                        {
                            poli.ASI_MFM_Finance_Verify_Date__c = pli.ASI_MFM_Finance_Verify_Save_Date__c;
                        }

                        if (pli.ASI_MFM_A_C_Code__c != poli.ASI_MFM_A_C_Code__c)
                        { // If change happen in AC CODE
                            poli.ASI_MFM_A_C_Code__c = pli.ASI_MFM_A_C_Code__c;
                        }

                        poLinesUpdate.add(poli);
                        changestat = false;    
                    }
                }
            }
            
            if (poLinesUpdate.size() > 0)
            {
                update poLinesUpdate;
                poLinesUpdate.clear();
            }

            // Message :Payment Line Item
            Date selectedDate =  Date.today();
            Map<id, map<string, date>> InvoiceDate_Map = new Map<id, map<string, date>>();
            Map<id, map<string, date>> GLDate_Map = new Map<id, map<string, date>>();
            
            Boolean Save = true;
            Boolean PartialVerify = false;
            
            for (Integer i = 0; i < paymentLines.size(); i++)
            {
                ASI_MFM_Payment_Line_Item__c ver = paymentLines[i];
                //    validate <blank> is NOT allowed for invoice date, GL date
                if (ver.ASI_MFM_G_L_Date__c == null)
                {
                    Save = false;
                    result.type = 'error';
                    result.message = 'Line ' + (i + 1) + ': G/L Date can not be null.';
                    return result;
                }
                
                if (ver.ASI_MFM_Invoice_Date__c == null)
                {
                    Save = false;
                    result.type = 'error';
                    result.message = 'Line ' + (i + 1) + ': Invoice Date can not be null.';
                    return result;
                }
                
                //One Invoice Number should have one G/L Date
                if (!GLDate_Map.containsKey(ver.ASI_MFM_Payee__c))
                {
                    Map<string, date> newmap = new Map<string, date>();
                    newmap.put(ver.ASI_MFM_Invoice_Number__c, ver.ASI_MFM_G_L_Date__c);
                    GLDate_Map.put(ver.ASI_MFM_Payee__c, newmap);
                }
                else
                {
                    if (GLDate_Map.get(ver.ASI_MFM_Payee__c).containsKey(ver.ASI_MFM_Invoice_Number__c))
                    {
                        if (GLDate_Map.get(ver.ASI_MFM_Payee__c).get(ver.ASI_MFM_Invoice_Number__c) != ver.ASI_MFM_G_L_Date__c)
                        {
                            Save = false;
                            result.type = 'error';
                            result.message = 'Line ' + (i + 1) + ': ' + ver.ASI_MFM_Invoice_Number__c + ' Please Check G/L Date.';
                            return result;
                        }
                    }
                }  
                
                //One Invoice Number should have One Invoice Date
                if (!InvoiceDate_Map.containsKey(ver.ASI_MFM_Payee__c))
                {
                    Map<string, date> newmap= new Map<string, date>();
                    newmap.put(ver.ASI_MFM_Invoice_Number__c, ver.ASI_MFM_Invoice_Date__c);
                    InvoiceDate_Map.put(ver.ASI_MFM_Payee__c, newmap);
                }
                else
                {
                    if (InvoiceDate_Map.get(ver.ASI_MFM_Payee__c).containsKey(ver.ASI_MFM_Invoice_Number__c))
                    {
                        if (InvoiceDate_Map.get(ver.ASI_MFM_Payee__c).get(ver.ASI_MFM_Invoice_Number__c) != ver.ASI_MFM_Invoice_Date__c)
                        {
                            Save = false;
                            result.type = 'error';
                            result.message = 'Line ' + (i + 1) + ': ' + ver.ASI_MFM_Invoice_Number__c + ' Please Check Invoice Date.';
                            return result;
                        }
                    }
                }      
                
                //Update Payment Line Related Fields
                if (ver.ASI_MFM_Payment_Line_Item_Finance_Verify__c == true)
                {
                    if (PaymentVerifyMap.containsKey(ver.ASI_MFM_Payment__c))
                    {
                        // there be error prompt if user perform finance verify with partial records 
                        if (PaymentVerifyMap.get(ver.ASI_MFM_Payment__c) != ver.ASI_MFM_Payment_Line_Item_Finance_Verify__c)
                        {    
                            PartialVerify = true;
                            Save = false;
                        }
                    }

                    if (Save)
                    {
                        count++;
                        verLines.add(ver.ASI_MFM_Payment__r.name);
                        ver.ASI_MFM_ETL_Failed__c = false;
                        ver.ASI_MFM_Effective__c = true;
                        if (ver.ASI_MFM_Payment_Line_Item_Finance_Verify__c != paymentMap.get(ver.id))
                        { // If Finance_Verify is checked, save the Time
                            ver.ASI_MFM_Finance_Verify_Save_Date__c = datetime.now();
                        }
                    }
                }
                else
                {
                    if (PaymentVerifyMap.containsKey(ver.ASI_MFM_Payment__c))
                    {
                        // there be error prompt if user perform finance verify with partial records 
                        if (PaymentVerifyMap.get(ver.ASI_MFM_Payment__c) != ver.ASI_MFM_Payment_Line_Item_Finance_Verify__c)
                        {
                            PartialVerify = true;
                            Save = false;
                            result.type = 'error';
                            result.message = 'Line ' + (i + 1) + ': Please Check.';
                            return result;
                        }
                    }

                    ver.ASI_MFM_Finance_Verify_Save_Date__c = null; // If Finance_Verify is unchecked, clear the Time
                    ver.ASI_MFM_Effective__c = false;
                }
                
                
                if (ver.ASI_MFM_Payment__r.ASI_MFM_Status__c == 'Final' || ver.ASI_MFM_Payment__r.ASI_MFM_Status__c == 'Invalid')
                {
                    updateList.add(ver);
                }
            }

            if (Save)
            {
                update updateList;
            }
            else
            {
                if (PartialVerify)
                {
                    result.type = 'error';
                    result.message = 'Can Not Partially Verify Payment Line in One Payment.';
                    return result;
                }
            }
		}
		catch (Exception e)
		{
			result.type = 'error';
			result.message = e.getMessage();
			return result;
		}

		if (updateList.size() > 0)
		{
			result.type = 'success';
            result.message = count + ' Payment Line verified. Payment No. ' + verLines;
			return result;
		}

		return result;
	}
}