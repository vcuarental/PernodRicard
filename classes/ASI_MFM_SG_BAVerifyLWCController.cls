public without sharing class ASI_MFM_SG_BAVerifyLWCController
{
    public class Result
    {
        @AuraEnabled
        public List<ASI_MFM_PO_Line_Item__c> planLines { get; set; }

        @AuraEnabled
        public Integer totalPage { get; set; }

        @AuraEnabled
        public Date poStartDate { get; set; }

        @AuraEnabled
        public Date postGLDate { get; set; }

        @AuraEnabled
        public String reportID { get; set; }
    }

    public class callResult
	{
		@AuraEnabled
		public String type { get; set; }

		@AuraEnabled
        public String message { get; set; }
	}

    @AuraEnabled
    public static Result getPlanLine(String planNo,
                            String poNo,
                            String poLineNo,
                            String department,
                            String fy,
                            String subBrandName,
                            String supplierNo,
                            String supplier,
                            String acCode,
                            Date glDateFrom,
                            Date glDateTo,
                            Date poStartDate,
                            Date postGLDate,
                            String sortBy,
                            String sortDir,
                            Integer page,
                            Integer pageSize)
    {
        // build query
        if (poStartDate == null)
        {
            poStartDate = Date.today();
        }

        if (postGLDate == null)
        {
            Date selectedDate =  Date.today(); 
            Date firstDate = selectedDate.toStartOfMonth();
            postGLDate = firstDate.addDays(Date.daysInMonth(selectedDate.year() , selectedDate.month())  - 1);
        }

        String location;
        // [LH 1.0] exclude [no Payment Request required]
        String soql = 'select id, ASI_MFM_Synced__c,ASI_MFM_ETL_Date__c,Name,ASI_MFM_PO__r.ASI_MFM_Fiscal_Year__c, ASI_MFM_PO__r.ASI_MFM_PO_Start_Date__c ,ASI_MFM_Post_G_L_Date__c,ASI_MFM_PO__r.ASI_MFM_Department__c,ASI_MFM_PO__r.ASI_MFM_Prefix__r.ASI_MFM_Location__c,ASI_MFM_PO__r.ASI_MFM_Prefix__c,ASI_MFM_PO__r.ASI_MFM_Prefix__r.Name, ASI_MFM_Base_Currency_Amount__c,ASI_MFM_Sub_brand_Code__c,ASI_MFM_Sub_brand_Code__r.Name,ASI_MFM_A_C_Code__r.Name,ASI_MFM_PO_Supplier_Number__c,ASI_MFM_PO__r.ASI_MFM_Plan__c,ASI_MFM_PO__r.ASI_MFM_Plan__r.Name,ASI_MFM_PO__r.Name, ASI_MFM_SG_BA_verify__c,ASI_MFM_PO__c,ASI_MFM_PO__r.ASI_MFM_Supplier_Name__c,ASI_MFM_PO__r.ASI_MFM_Supplier_Name__r.Name,ASI_MFM_PO__r.ASI_MFM_PO_Amount__c,ASI_MFM_Amount__c,ASI_MFM_List_Item_Description__c,ASI_MFM_A_C_Code__c,ASI_MFM_Currency__c,ASI_MFM_Remaining_Balance__c,ASI_MFM_G_L_Date__c from ASI_MFM_PO_Line_Item__c where ASI_MFM_PO__r.RecordType.DeveloperName LIKE \'ASI_MFM_SG_PO%\' AND ASI_MFM_PO__r.ASI_MFM_Status__c = \'Final\' AND ((ASI_MFM_PO_Amount__c > 0 AND ASI_MFM_Remaining_Balance__c > 0 AND ASI_MFM_Complete__c = false) OR (ASI_MFM_Complete__c = true AND ASI_MFM_All_Payment_Effective__c = false AND ASI_MFM_Adjustment_Line__c = false)) AND (NOT ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c like \'%2260%\') AND (ASI_MFM_PO__r.ASI_MFM_SG_No_Payment_Request_Required__c=false)' ;
        
        if (String.isNotEmpty(planNo)){
            soql += ' and ASI_MFM_PO__r.ASI_MFM_Plan__r.name LIKE \''+String.escapeSingleQuotes(planNo)+'%\'';
        }

        if (String.isNotEmpty(poNo))
        {
            soql += ' and ASI_MFM_PO__r.name LIKE \''+String.escapeSingleQuotes(poNo)+'%\' ';
        }

        if (String.isNotEmpty(poLineNo)){
            soql += ' and Name LIKE \''+String.escapeSingleQuotes(poLineNo)+'%\' ';
        }

        if(String.isNotEmpty(subBrandName))
        {
            soql += ' and ASI_MFM_Sub_brand_Code__r.name LIKE \''+String.escapeSingleQuotes(subBrandName)+'%\' ';
        }

        if (String.isNotEmpty(supplierNo))
        {
            soql += ' and ASI_MFM_PO_Supplier_Number__c LIKE \''+String.escapeSingleQuotes(supplierNo)+'%\' ';
        }
        
        if (String.isNotEmpty(supplier))
        {
            soql += ' and ASI_MFM_PO__r.ASI_MFM_Supplier_Name__r.name LIKE \''+String.escapeSingleQuotes(supplier)+'%\' ';
        }
        
        if (String.isNotEmpty(acCode))
        {
            soql += ' and ASI_MFM_A_C_Code__r.name LIKE \''+String.escapeSingleQuotes(acCode)+'%\' ';
        }
        
        if (glDateFrom != null)
        {
            String fromDate = DateTime.newInstance(glDateFrom.year(), glDateFrom.month(), glDateFrom.day(), 0, 0, 0).format('yyyy-MM-dd');
            soql += ' AND ASI_MFM_G_L_Date__c  >= ' + fromDate + ''; 
        }
        if (glDateTo != null)
        {
            String toDate = DateTime.newInstance(glDateTo.year(), glDateTo.month(), glDateTo.day(), 0, 0, 0).format('yyyy-MM-dd');
            soql += ' AND ASI_MFM_G_L_Date__c    <= ' + toDate + ''; 
        }

        if (poStartDate != null)
        {
            String startDate = DateTime.newInstance(poStartDate.year(), poStartDate.month(), poStartDate.day(), 0, 0, 0).format('yyyy-MM-dd');
            soql += ' AND ASI_MFM_PO__r.ASI_MFM_PO_Start_Date__c <= ' + startDate + ''; 
        }

        if (String.isNotEmpty(department))
        {
            if (department.contains('SG'))
            {
                location ='Singapore';
                soql += ' and ASI_MFM_PO__r.ASI_MFM_Market__c = \'' +location+'\''+ 'and ASI_MFM_PO__r.ASI_MFM_Department__c LIKE \'%' +department.substring(3,8)+'%\'';
            }
            
            if (department.contains('CA'))
            {
                location = 'Cambodia';
                soql += ' and ASI_MFM_PO__r.ASI_MFM_Market__c = \'' +location+'\''+ 'and ASI_MFM_PO__r.ASI_MFM_Department__c LIKE \'%' +department.substring(3,8)+'%\'';
            }

            if (department.contains('LA'))
            {
                location = 'Laos';
                soql += ' and ASI_MFM_PO__r.ASI_MFM_Market__c = \'' +location+'\'';
            }
            
            if (department.contains('MM'))
            {
                location = 'Myanmar';
                soql += ' and ASI_MFM_PO__r.ASI_MFM_Market__c = \'' +location+'\'';
            }
            
        }
        
        if (String.isNotEmpty(fy))
        {
            soql += ' and ASI_MFM_PO__r.ASI_MFM_Fiscal_Year__c = \'' +fy + '\' ';
        }

        if (String.isEmpty(sortBy))
        {
            sortBy = 'ASI_MFM_Sub_brand_Code__r.Name';
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
        result.planLines = new List<ASI_MFM_PO_Line_Item__c>();
        result.totalPage = 0;
        
        List <Folder> reportList = [SELECT Id FROM Folder WHERE Name = 'ASI SG MFM Report' And Type = 'Report'];
        result.reportID = (String)reportList.get(0).get('Id');

        List<ASI_MFM_PO_Line_Item__c> totalLineItem = Database.query(soql);
        result.totalPage = (Integer)Math.ceil((Decimal)totalLineItem.size() / (Decimal)pageSize);
        result.poStartDate = poStartDate;
        result.postGLDate = postGLDate;

        if (page > result.totalPage)
        {
            page = result.totalPage;
        }

        if (page <= 0)
        {
            page = 1;
        }
        
        Integer offset = (page - 1) * pageSize;
        result.planLines = Database.query(soql + ' order by ' + sortBy + ' ' + sortDir + ' limit ' + pageSize + ' offset ' + offset);
        
        return result;
    }

    // save BAverify 
    @AuraEnabled
    public static CallResult savePlanLine (string planLinesStr, Date postGLDate, List<String> poList)
    {
        CallResult result = new CallResult();
		result.type = 'success';
		result.message = 'No plan line updated.';

		List<ASI_MFM_PO_Line_Item__c> planlines = (List<ASI_MFM_PO_Line_Item__c>)System.JSON.deserializeStrict(planlinesStr, List<ASI_MFM_PO_Line_Item__c>.class);

		if (planlines.size() == 0)
		{
			result.type = 'error';
			result.message = 'No lines found.';
			return result;
		}
        
        Integer count = 0;
        Set<String> verLines = new Set<String>();
        for (String po : poList)
        {
            verLines.add(po);
        }

		try
		{
            if (postGLDate == null)
            {
                result.type = 'error';
                result.message = 'Please input Post G/L date.';
                return result;
            }
            
            for (ASI_MFM_PO_Line_Item__c ver : planlines)
            {
                if (ver.ASI_MFM_SG_BA_verify__c == true)
                {
                    count++;
                    ver.ASI_MFM_Post_G_L_Date__c = postGLDate;
                }
            }

            update planlines;
            GenerateActualPORemaining();
		}
		catch (Exception e)
		{
			result.type = 'error';
			result.message = e.getMessage();
			return result;
		}

		if (planlines.size() > 0)
		{
			result.type = 'success';
            result.message = count + ' PO Line verified.\nPO No. ' + verLines;
			return result;
		}

		return result;
    }
    
    public static void GenerateActualPORemaining()
    {
        transient List<ASI_MFM_PO_Line_Item__c> POLList = new List<ASI_MFM_PO_Line_Item__c>();
        Set<id> POList_Set = new Set<id>();
        List<ASI_MFM_Payment_Line_Item__c> PALList = new List<ASI_MFM_Payment_Line_Item__c>();
        List<ASI_MFM_Payment_Line_Item__c> UpdatePALList = new List<ASI_MFM_Payment_Line_Item__c>();
        POLList = [Select id,ASI_MFM_Paid_Amount__c,ASI_MFM_Actual_Paid_Amouint__c FROM ASI_MFM_PO_Line_Item__c WHERE ASI_MFM_SG_BA_verify__c = false AND ASI_MFM_PO__r.ASI_MFM_Status__c = 'Final' AND ASI_MFM_PO__r.RecordType.DeveloperName LIKE 'ASI_MFM_SG_PO%' AND ASI_MFM_Remaining_Balance__c > 0 AND ASI_MFM_All_Payment_Effective__c = false];
        
        for (ASI_MFM_PO_Line_Item__c POL: POLList)
        {
            if (POL.ASI_MFM_Paid_Amount__c != POL.ASI_MFM_Actual_Paid_Amouint__c)
            {
                POList_Set.add(POL.id);
            }
        }
        PALList = [Select id, ASI_MFM_Effective__c FROM ASI_MFM_Payment_Line_Item__c WHERE ASI_MFM_PO_Line_Item__c IN :POList_Set AND ASI_MFM_Effective__c != true AND ASI_MFM_Payment__r.ASI_MFM_G_L_Date__c <= TODAY AND ASI_MFM_Payment__r.ASI_MFM_Status__c = 'Final'];
        for (ASI_MFM_Payment_Line_Item__c PAL : PALList)
        {
            PAL.ASI_MFM_Effective__c = true;    
            UpdatePALList.add(PAL);
        }
        system.debug('UpdatePALList:::' + UpdatePALList);

        if (UpdatePALList.size() > 0)
        {
            update UpdatePALList;
        }
    }
}