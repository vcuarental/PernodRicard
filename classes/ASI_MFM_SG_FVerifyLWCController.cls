public without sharing class ASI_MFM_SG_FVerifyLWCController
{
    public class Result
    {
        @AuraEnabled
        public List<ASI_MFM_Payment_Line_Item__c> paymentLines { get; set; }

        @AuraEnabled
        public Map<ID, List<Attachment>> attachments { get; set; }

        @AuraEnabled
        public Map<ID, List<ContentDocumentLink>> documents { get; set; }

        @AuraEnabled
        public Integer totalPage { get; set; }

        @AuraEnabled
        public Map<String, String> links { get; set; }
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
                            String poNo,
                            String poLineNo,
                            String paymentNo,
                            String paymentLineNo,
                            String department,
                            String acCode,
                            String supplier,
                            Date glDateFrom,
                            Date glDateTo,
                            String status,
                            String sortBy,
                            String sortDir,
                            Integer page,
                            Integer pageSize)
    {
        // build query
        String soql = 'select id,ASI_MFM_Payment__r.ASI_MFM_GST__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_Remaining_Balance__c,ASI_MFM_Payment__r.ASI_MFM_Prefix__r.ASI_MFM_Location__c,ASI_MFM_Payment__r.ASI_MFM_Prefix__c,ASI_MFM_Payment__r.ASI_MFM_Prefix__r.Name,ASI_MFM_Payment__r.ASI_MFM_Prefix__r.ASI_MFM_Department__c, ASI_MFM_GST_Amount__c,ASI_MFM_Invoice_Total__c,ASI_MFM_A_C_Code__c,ASI_MFM_A_C_Code__r.Name,name,ASI_MFM_Payment_Term__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_A_C_Code__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_A_C_Code__r.Name,ASI_MFM_Comments__c,ASI_MFM_Status__c,ASI_MFM_Invoice_Due_Date__c,ASI_MFM_G_L_Date__c ,ASI_MFM_Payment__r.name,ASI_MFM_Invoice_Date__c, ASI_MFM_PO_Line_Item__r.name,ASI_MFM_Payment__r.ASI_MFM_G_L_Date__c,ASI_MFM_Payment_Line_Item_Finance_Verify__c, ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c, ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.Name, ASI_MFM_PO_Line_Item__c, ASI_MFM_Payment__c, ASI_MFM_Payee__c,ASI_MFM_Payee__r.Name, ASI_MFM_Currency__c , ASI_MFM_PO_Line_Remaining_Amount__c, ASI_MFM_Payment_Amount__c, ASI_MFM_Invoice_Number__c, ASI_MFM_Due_Date__c, ASI_MFM_Payment__r.ASI_MFM_Status__c, ASI_MFM_TH_Tax_Type__c,ASI_MFM_Payment_List_Item_Description__c, ASI_MFM_Withholding_Tax__c, ASI_MFM_Withholding_Tax_Amount__c  from ASI_MFM_Payment_Line_Item__c where ASI_MFM_Payment__r.ASI_MFM_Status__c!=\'Draft\' AND ASI_MFM_Voucher_Created__c=false AND ASI_MFM_Payment_Line_Item_Finance_Verify__c=false  AND ASI_MFM_Payment__r.RecordType.DeveloperName LIKE \'ASI_MFM_SG_Payment%\' ';
        String location;
        
        if (String.isNotEmpty(status))
        {
           soql += ' and ASI_MFM_Payment__r.ASI_MFM_Status__c LIKE \''+String.escapeSingleQuotes(status)+'%\'';
        }
        
        if(String.isNotEmpty(poNo))
        {
                soql += ' and ASI_MFM_PO__r.name LIKE \''+String.escapeSingleQuotes(poNo)+'%\''; 
        }

        if (String.isNotEmpty(poLineNo))
        {
            soql += ' and ASI_MFM_PO_Line_Item__r.name LIKE \''+String.escapeSingleQuotes(poLineNo)+'%\'';
        }

        if (String.isNotEmpty(paymentNo)){
            soql += ' and ASI_MFM_Payment__r.name LIKE \''+String.escapeSingleQuotes(paymentNo)+'%\'';
        }

        if (String.isNotEmpty(paymentLineNo))
        {
            soql += ' and Name LIKE \''+String.escapeSingleQuotes(paymentLineNo)+'%\'';
        }

        if (String.isNotEmpty(department))
        {
            if (department.contains('SG'))
            {
                location = 'Singapore';
                soql += ' and ASI_MFM_Payment__r.ASI_MFM_Prefix__r.ASI_MFM_Location__c = \'' +location+'\''+ 'and ASI_MFM_Payment__r.ASI_MFM_Prefix__r.ASI_MFM_Department__c LIKE \'%' +department.substring(3,8)+'%\'';
            }

            if (department.contains('CA'))
            {
                location = 'Cambodia';
                soql += ' and ASI_MFM_Payment__r.ASI_MFM_Prefix__r.ASI_MFM_Location__c = \'' +location+'\''+ 'and ASI_MFM_Payment__r.ASI_MFM_Prefix__r.ASI_MFM_Department__c LIKE \'%' +department.substring(3,8)+'%\'';
            }

            if (department.contains('LA'))
            {
                location = 'Laos';
                soql += ' and ASI_MFM_Payment__r.ASI_MFM_Prefix__r.ASI_MFM_Location__c = \'' +location+'\'';
            }

            if (department.contains('MM'))
            {
                location = 'Myanmar';
                soql += ' and ASI_MFM_Payment__r.ASI_MFM_Prefix__r.ASI_MFM_Location__c = \'' +location+'\'';
            }
        }
        
        if (String.isNotEmpty(supplier))
        {
            soql += ' and ASI_MFM_PO__r.ASI_MFM_Supplier_Name__r.name LIKE \''+String.escapeSingleQuotes(supplier)+'%\'';
        }

        if (String.isNotEmpty(acCode))
        {
            soql += ' and ASI_MFM_PO_Line_Item__r.ASI_MFM_A_C_Code__r.name LIKE \''+String.escapeSingleQuotes(acCode)+'%\'';
        }

        if (glDateFrom != null)
        {
            String fromDate = DateTime.newInstance(glDateFrom.year(), glDateFrom.month(), glDateFrom.day(), 0,0,0).format('yyyy-MM-dd');
            soql += ' AND ASI_MFM_G_L_Date__c  >= ' + fromDate + ''; 
        }

        if (glDateTo != null)
        {
            String toDate = DateTime.newInstance(glDateTo.year(), glDateTo.month(), glDateTo.day(), 0,0,0).format('yyyy-MM-dd');
            soql += ' AND ASI_MFM_G_L_Date__c    <= ' + toDate + ''; 
        }

        if (String.isEmpty(sortBy))
        {
            sortBy = 'ASI_MFM_Payment__r.Name';
        }

        if (String.isEmpty(sortDir))
        {
            sortDir = 'asc';
        }

        if (pageSize <= 0)
        {
            pageSize = 30;
        }

        // process data
        Result result = new Result();
        result.paymentLines = new List<ASI_MFM_Payment_Line_Item__c>();
        result.attachments = new Map<ID, List<Attachment>>();
        result.documents = new Map<ID, List<ContentDocumentLink>>();
        result.links = new Map<String, String>();
        result.totalPage = 0;

        try {
            for (Report r : [Select ID, DeveloperName from Report where DeveloperName in ('ASI_MFM_SG_Finance_Verified_Report', 'ASI_MFM_SG_ETL_Report', 'ASI_MFM_SG_Payment_Report')])
            {
                result.links.put(r.DeveloperName, '/' + r.ID);
            }
            
            for (Folder f : [SELECT Id, DeveloperName FROM Folder WHERE Name = 'ASI SG MFM Report' And Type = 'Report' limit 1])
            {
                result.links.put(f.DeveloperName, '/' + f.ID);
            }
            
            result.links.put('ASI_MFM_SG_GL_Date_SettingPage', '/apex/ASI_MFM_SG_GL_Date_SettingPage');

            List<ASI_MFM_Payment_Line_Item__c> totalLineItem = Database.query(soql + ' order by ' + sortBy + ' ' + sortDir);

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
            list<id> paymentIdList = new list<id>();
            
            for (ASI_MFM_Payment_Line_Item__c pai: result.paymentLines)
            {
                pai.ASI_MFM_G_L_Date__c = pai.ASI_MFM_Payment__r.ASI_MFM_G_L_Date__c;
                pai.ASI_MFM_A_C_Code__c = pai.ASI_MFM_PO_Line_Item__r.ASI_MFM_A_C_Code__c;

                if (pai.ASI_MFM_Payment__c!=null && !paymentIdList.contains(pai.ASI_MFM_Payment__c))
                {
                	paymentIdList.add(pai.ASI_MFM_Payment__c);
                }
            }
            
            //introv 20180306
            if (paymentIdList.size() > 0)
            {
				for (Attachment att : [select Id, ParentId, Name 
                                        from Attachment where ParentId in : paymentIdList
                                        order by Name])
                {
                    if (!result.attachments.containsKey(att.ParentId))
                    {
                        List<Attachment> attachmentList = new List<Attachment>(); 
                        attachmentList.add(att);
                        result.attachments.put(att.ParentId, attachmentList);
                    }
                    else
                    {
                        List<Attachment> attachmentList = result.attachments.get(att.ParentId);
                        attachmentList.add(att);
                        result.attachments.put(att.ParentId, attachmentList);
                    }
                }
                
                    for (ContentDocumentLink cdl : [select Id, ContentDocumentId, LinkedEntityId, ContentDocument.Title
                                            from ContentDocumentLink where LinkedEntityId in : paymentIdList
                                        order by ContentDocument.Title])
                {
                    if (!result.documents.containsKey(cdl.LinkedEntityId))
                    {
                        List<ContentDocumentLink> docList = new List<ContentDocumentLink>(); 
                        docList.add(cdl);
                        result.documents.put(cdl.LinkedEntityId, docList);
                    }
                    else
                    {
                        List<ContentDocumentLink> docList = result.documents.get(cdl.LinkedEntityId);
                        docList.add(cdl);
                        result.documents.put(cdl.LinkedEntityId, docList);
                    }
                }
            }

            for (ASI_MFM_Payment_Line_Item__c pai : result.paymentLines)
            {
                if (pai.ASI_MFM_Payment__c != null && !paymentIdList.contains(pai.ASI_MFM_Payment__c))
                {
                    result.attachments.put(pai.ASI_MFM_Payment__c, new List<Attachment>());
                    result.documents.put(pai.ASI_MFM_Payment__c, new List<ContentDocumentLink>());
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
    public static CallResult savePaymentLine(string paymentLinesStr)
    {
        CallResult result = new CallResult();
		result.type = 'success';
		result.message = 'No payment line updated.';

        List<ASI_MFM_Payment_Line_Item__c> paymentLines = (List<ASI_MFM_Payment_Line_Item__c>)System.JSON.deserializeStrict(paymentLinesStr, List<ASI_MFM_Payment_Line_Item__c>.class);
        List<ASI_MFM_Payment_Line_Item__c> updateList = new List<ASI_MFM_Payment_Line_Item__c>();
        List<ASI_MFM_PO_Line_Item__c> poLinesUpdate = new List<ASI_MFM_PO_Line_Item__c>();
        List<ASI_MFM_Payment__c> paymentUpdate = new List<ASI_MFM_Payment__c>();
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
            Set<id> po_set = new Set<id>();
            
            for (ASI_MFM_Payment_Line_Item__c pli : paymentLines)
            {
                po_set.add(pli.ASI_MFM_PO_Line_Item__c);
            }

            List<ASI_MFM_PO_Line_Item__c> poline = [select id,name,ASI_MFM_A_C_Code__c from ASI_MFM_PO_Line_Item__c where id in: po_set];
            
            for (ASI_MFM_PO_Line_Item__c poli : poline)
            {
                Boolean changestat = true;
                for (ASI_MFM_Payment_Line_Item__c pli : paymentLines)
                {
                    if (pli.ASI_MFM_PO_Line_Item__c == poli.id && pli.ASI_MFM_A_C_Code__c != poli.ASI_MFM_A_C_Code__c && changestat == true)
                    {
                        poli.ASI_MFM_A_C_Code__c = pli.ASI_MFM_A_C_Code__c;
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
        
            //Payment
            set<id> pay_set = new set<id>();
            set<id> pa_set = new set<id>();
            set<id> paSat_set = new set<id>();

            for (ASI_MFM_Payment_Line_Item__c pli : paymentLines)
            {
                pay_set.add(pli.ASI_MFM_Payment__c); // Get Payment Id
            }

            List<ASI_MFM_Payment__c> payment = [select id,ASI_MFM_G_L_Date__c,ASI_MFM_Status__c,name,ASI_MFM_GST__c from ASI_MFM_Payment__c where id in : pay_set];
            for (ASI_MFM_Payment__c pa : payment)
            {
                Boolean changehappen = true;
                Boolean changestat = true;
                Boolean AddPy = False;
                // Change Payment G/L Date 
                for (ASI_MFM_Payment_Line_Item__c pli : paymentLines)
                {
                    if (pa.id == pli.ASI_MFM_Payment__c  && changehappen == true && pa.ASI_MFM_G_L_Date__c != pli.ASI_MFM_G_L_Date__c)
                    {
                        pa.ASI_MFM_G_L_Date__c = pli.ASI_MFM_G_L_Date__c;
                        AddPy = true;
                        changehappen = false;
                    }
                }

                if (AddPy == true)
                {
                    paymentUpdate.add(pa);
                }
            }
            
            if (paymentUpdate.size() > 0)
            {
                update paymentUpdate;
                paymentUpdate.clear();
            }

            boolean IsSame = true;
            Set<String> Invoice = new Set<String>();  //Store Invoice Number
            
            for (Integer countn = 0; countn < paymentLines.size(); countn++)
            {
                for (Integer countm = countn; countm < paymentLines.size(); countm++)
                { //Same invoice number should have same Withholding Tax Code and Tax.  ASI_MFM_Payee__c
                    if (paymentLines[countn].ASI_MFM_Invoice_Number__c == paymentLines[countm].ASI_MFM_Invoice_Number__c
                         && paymentLines[countn].ASI_MFM_Payee__c == paymentLines[countm].ASI_MFM_Payee__c)
                    {
                        if (paymentLines[countn].ASI_MFM_Invoice_Due_Date__c != paymentLines[countm].ASI_MFM_Invoice_Due_Date__c
                             || paymentLines[countn].ASI_MFM_Invoice_Date__c != paymentLines[countm].ASI_MFM_Invoice_Date__c
                             || paymentLines[countn].ASI_MFM_G_L_Date__c != paymentLines[countm].ASI_MFM_G_L_Date__c )
                        {
                            IsSame = false;  // difference exist
                            Invoice.add(paymentLines[countn].ASI_MFM_Invoice_Number__c);
                        }
                    }
                }
            }
            
            if (IsSame == true)
            { //Same
                for (ASI_MFM_Payment_Line_Item__c ver : paymentLines)
                {
                    if (ver.ASI_MFM_Payment_Line_Item_Finance_Verify__c == true)
                    {
                        count++;
                        verLines.add(ver.ASI_MFM_Payment__r.name);
                    }

                    if (ver.ASI_MFM_Payment__r.ASI_MFM_Status__c == 'Final')
                    {
                        updateList.add(ver);
                    }
                }

                if (updateList.size() > 0)
                {
                    update updateList;
                }
            }
            else
            {
                result.type = 'error';
                result.message = 'Save Error: Invoice Number: ' + Invoice + '. Same invoice number should have same Invoice Date, G/L Date, Invoice Due Date.';
                return result;
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