public with sharing class ASI_MFM_MY_BAVerifyLWCController
{
    public class Result
    {
        @AuraEnabled
        public List<ASI_MFM_PO_Line_Item__c> planLines { get; set; }

        @AuraEnabled
        public List<SummarySubbrand> summary { get; set; }

        @AuraEnabled
        public Statistic statistic { get; set; }

        @AuraEnabled
        public Integer totalPage { get; set; }

        @AuraEnabled
        public String fy { get; set; }
    }

    public class SummarySubbrand
    {
        @AuraEnabled
        public Decimal totalPO { get; private set; }// Original PO 

        @AuraEnabled
        public Decimal totalPORemain { get; private set; }// Remaining PO

        @AuraEnabled
        public String name { get; private set; }// Sub-Brand Name
        
        public SummarySubbrand(AggregateResult ar)
        {
            totalPO = (Decimal) ar.get('TotalOPO');
            totalPORemain = (Decimal) ar.get('TotalRPO');
            name = (String) ar.get('Name');
        }
    }

    public class Statistic
    {
        @AuraEnabled
        public Decimal verifiedPO { get; set; }

        @AuraEnabled
        public Decimal verifiedPORemain { get; set; }

        @AuraEnabled
        public Decimal unverifiedPO { get; set; }

        @AuraEnabled
        public Decimal unverifiedPORemain { get; set; }

        @AuraEnabled
        public Decimal totalPO { get; set; }

        @AuraEnabled
        public Decimal totalPORemain { get; set; }
    }

    public class callResult
	{
		@AuraEnabled
		public String type { get; set; }

		@AuraEnabled
        public String message { get; set; }
	}

    @AuraEnabled
    public static Result getPlanLine(String recordType,
                            String country,
                            String settingName,
                            Boolean baVerify,
                            Boolean etlSync,
                            Boolean etlDate,
                            String planID,
                            String planName,
                            String poID,
                            String poLineID,
                            String fy,
                            String subBrandCode,
                            String subBrandName,
                            String supplierNo,
                            String supplier,
                            Date glDateFrom,
                            Date glDateTo,
                            String sortBy,
                            String sortDir,
                            Integer page,
                            Integer pageSize)
    {
        // build query
        if (String.isEmpty(recordType))
        {
            recordType = 'ASI_MFM_MY_PO';
        }

        if (String.isEmpty(country))
        {
            country = 'MY';
        }

        if (String.isEmpty(settingName))
        {
            settingName = 'MY_Cut_Off_Date';
        }

        String soql = 'select id, name, ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c,ASI_MFM_Finance_Verify_Date__c,ASI_MFM_Synced__c,ASI_MFM_ETL_Date__c,ASI_MFM_PO__r.name,ASI_MFM_Base_Currency_Amount__c,ASI_MFM_Post_G_L_Date__c,ASI_MFM_PO__r.ASI_MFM_Exchange_Rate__c,ASI_MFM_Base_Currency_Remaining_Balance__c,ASI_MFM_Sub_brand_Code__r.name,ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Plan_Name__c,ASI_MFM_PO__r.ASI_MFM_PO_Name__c,ASI_MFM_PO__r.ASI_MFM_Plan__r.name, ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c, ASI_MFM_PO__r.ASI_MFM_Plan__c, ASI_MFM_SG_BA_verify__c,ASI_MFM_PO__c,ASI_MFM_PO__r.ASI_MFM_Supplier_Name__c,ASI_MFM_PO__r.ASI_MFM_Supplier_Name__r.name,ASI_MFM_PO__r.ASI_MFM_PO_Amount__c,ASI_MFM_Amount__c,ASI_MFM_PO_Supplier_Number__c ,ASI_MFM_List_Item_Description__c,ASI_MFM_A_C_Code__c,ASI_MFM_A_C_Code__r.name,ASI_MFM_Currency__c,ASI_MFM_Remaining_Balance__c,ASI_MFM_G_L_Date__c from ASI_MFM_PO_Line_Item__c where ASI_MFM_PO__r.ASI_MFM_Status__c = \'Final\' AND ASI_MFM_PO_Amount__c > 0 AND ASI_MFM_Remaining_Balance__c > 0 AND ASI_MFM_Complete__c = false  AND ASI_MFM_PO__r.RecordType.DeveloperName LIKE \'' + recordType + '%\' ';
        String soqlSubbrand = 'select ASI_MFM_Sub_brand_Code__r.name Name, sum(ASI_MFM_Base_Currency_Amount__c) TotalOPO, sum(ASI_MFM_Base_Currency_Remaining_Balance__c) TotalRPO from ASI_MFM_PO_Line_Item__c where ASI_MFM_G_L_Date__c <= TODAY AND ASI_MFM_PO__r.ASI_MFM_Status__c = \'Final\'  AND ASI_MFM_PO_Amount__c > 0 AND ASI_MFM_Remaining_Balance__c > 0 AND ASI_MFM_Complete__c = false  AND ASI_MFM_PO__r.RecordType.DeveloperName LIKE \'' + recordType + '%\' ';
        
        if (String.isEmpty(fy) && String.isEmpty(planID) && String.isEmpty(poID) && String.isEmpty(poLineID) && String.isEmpty(subBrandCode) && String.isEmpty(subBrandName) && String.isEmpty(supplier) && String.isEmpty(supplierNo))
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

        if (String.isNotEmpty(planID))
        {
            soqlSubbrand += ' and ASI_MFM_PO__r.ASI_MFM_Plan__r.name LIKE \''+String.escapeSingleQuotes(planID)+'%\'';
            soql += ' and ASI_MFM_PO__r.ASI_MFM_Plan__r.name LIKE \''+String.escapeSingleQuotes(planID)+'%\'';
        }

        if (String.isNotEmpty(fy) && String.isEmpty(planID) && String.isEmpty(poID) && String.isEmpty(poLineID) && String.isEmpty(subBrandCode) && String.isEmpty(subBrandName) && String.isEmpty(supplier) && String.isEmpty(supplierNo))
        {
            soqlSubbrand += ' and ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c LIKE \''+String.escapeSingleQuotes(fy)+'%\'';
            soql += ' and ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c LIKE \''+String.escapeSingleQuotes(fy)+'%\'';
        }
        
        if (String.isNotEmpty(planName))
        {
            soql += ' and ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Plan_Name__c LIKE \'%'+String.escapeSingleQuotes(planName)+'%\'';
            soqlSubbrand += ' and ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Plan_Name__c LIKE \'%'+String.escapeSingleQuotes(planName)+'%\'';
        }
            
        
        if (String.isNotEmpty(poID))
        {
           soql += ' and ASI_MFM_PO__r.name LIKE \''+String.escapeSingleQuotes(poID)+'%\'';
           soqlSubbrand += ' and ASI_MFM_PO__r.name LIKE \''+String.escapeSingleQuotes(poID)+'%\'';
        }
            
        
        if (String.isNotEmpty(poLineID))
        {
            soqlSubbrand += ' and Name LIKE \''+String.escapeSingleQuotes(poLineID)+'%\'';
            soql += ' and Name LIKE \''+String.escapeSingleQuotes(poLineID)+'%\'';
        }
            
        if (String.isNotEmpty(subBrandCode))
        {
            soqlSubbrand += ' and ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c LIKE \'%'+String.escapeSingleQuotes(subBrandCode)+'%\'';
            soql += ' and ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c LIKE \'%'+String.escapeSingleQuotes(subBrandCode)+'%\'';
        }
            
        if (String.isNotEmpty(subBrandName))
        {
            soqlSubbrand += ' and ASI_MFM_Sub_brand_Code__r.name LIKE \'%'+String.escapeSingleQuotes(subBrandName)+'%\'';
             soql += ' and ASI_MFM_Sub_brand_Code__r.name LIKE \'%'+String.escapeSingleQuotes(subBrandName)+'%\'';
        }
        
        if (String.isNotEmpty(supplier))
        {
            soqlSubbrand +=  ' and ASI_MFM_PO__r.ASI_MFM_Supplier_Name__r.name LIKE \'%'+String.escapeSingleQuotes(supplier)+'%\'';
            soql += ' and ASI_MFM_PO__r.ASI_MFM_Supplier_Name__r.name LIKE \'%'+String.escapeSingleQuotes(supplier)+'%\'';
        }

        if (String.isNotEmpty(supplier))
        {
            soqlSubbrand += ' and ASI_MFM_PO_Supplier_Number__c LIKE \''+String.escapeSingleQuotes(supplierNo)+'%\'';
            soql += ' and ASI_MFM_PO_Supplier_Number__c LIKE \''+String.escapeSingleQuotes(supplierNo)+'%\'';
        }
        
        if (glDateFrom != null)
        {
            String fromDate = DateTime.newInstance(glDateFrom.year(), glDateFrom.month(), glDateFrom.day(), 0, 0, 0).format('yyyy-MM-dd');
            soql += ' AND ASI_MFM_G_L_Date__c >= ' + fromDate + ''; 
            soqlSubbrand += ' AND ASI_MFM_G_L_Date__c >= ' + fromDate + '';
        }

        if (glDateTo != null)
        {
            String toDate = DateTime.newInstance(glDateTo.year(), glDateTo.month(), glDateTo.day(), 0, 0, 0).format('yyyy-MM-dd');
            soql += ' AND ASI_MFM_G_L_Date__c <= ' + toDate + ''; 
            soqlSubbrand += ' AND ASI_MFM_G_L_Date__c <= ' + toDate + '';
        }

        if (etlSync != null)
        {
            if (etlSync == false)
            {
                soqlSubbrand += ' and ASI_MFM_Synced__c = false ';
                soql += ' and ASI_MFM_Synced__c = false ';
            }
            else
            {
                soqlSubbrand += ' and ASI_MFM_Synced__c = true ';
                soql += ' and ASI_MFM_Synced__c = true ';
            }
        }
        
        if (baVerify != null)
        {
            if (baVerify == false)
            {
                soqlSubbrand += ' and ASI_MFM_SG_BA_verify__c = false ';
                soql += ' and ASI_MFM_SG_BA_verify__c = false ';
            }
            else
            {
                soqlSubbrand += ' and ASI_MFM_SG_BA_verify__c = true ';
                soql += ' and ASI_MFM_SG_BA_verify__c = true ';
            }
        }
        
        if (etlDate != null)
        {    
            if (etlDate == false)
            {
                soqlSubbrand += ' and ASI_MFM_ETL_Date__c = null ';
                soql += ' and ASI_MFM_ETL_Date__c = null ';
            }
            else
            {
                soqlSubbrand += ' and ASI_MFM_ETL_Date__c != null ';
                soql += ' and ASI_MFM_ETL_Date__c != null ';
            } 
        }

        if (String.isEmpty(sortBy))
        {
            sortBy = 'ASI_MFM_G_L_Date__c';
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
        result.statistic.verifiedPO = 0;
        result.statistic.verifiedPORemain = 0;
        result.statistic.unverifiedPO = 0;
        result.statistic.unverifiedPORemain = 0;
        result.statistic.totalPO = 0;
        result.statistic.totalPORemain = 0;
        result.planLines = new List<ASI_MFM_PO_Line_Item__c>();
        result.summary = new List<SummarySubbrand>();
        result.totalPage = 0;
        result.fy = fy;
        
        try {
            /* Search Sub- brand as SubTotal*/
            String SubbrandGroup = 'group by ASI_MFM_Sub_brand_Code__r.name';
            String SubbrandSear;
            SubbrandSear = soqlSubbrand + SubbrandGroup;
            
            AggregateResult[] groupedResults = Database.query(SubbrandSear); //Run query
            
            for (AggregateResult ar : groupedResults)
            {
                result.summary.add(new SummarySubbrand(ar));
            }
            
            groupedResults.clear();
            
            /*Caculate amount*/
            List<ASI_MFM_PO_Line_Item__c> totalLineItem = Database.query(soql + ' order by ' + sortBy + ' ' + sortDir);
            result.totalPage = (Integer)Math.ceil((Decimal)totalLineItem.size() / (Decimal)pageSize);
            
            for (ASI_MFM_PO_Line_Item__c POli : totalLineItem)
            {
                if (POli.ASI_MFM_Base_Currency_Amount__c != null)
                {
                    result.statistic.totalPO = result.statistic.totalPO + POli.ASI_MFM_Base_Currency_Amount__c;
                }

                if (POli.ASI_MFM_Base_Currency_Remaining_Balance__c != null)
                {
                    result.statistic.totalPORemain = result.statistic.totalPORemain + POli.ASI_MFM_Base_Currency_Remaining_Balance__c;
                }

                if (POli.ASI_MFM_SG_BA_verify__c == true )
                {
                    result.statistic.verifiedPO = result.statistic.verifiedPO + POli.ASI_MFM_Base_Currency_Amount__c;
                    result.statistic.verifiedPORemain = result.statistic.verifiedPORemain + POli.ASI_MFM_Base_Currency_Remaining_Balance__c;
                }
                else
                {
                    result.statistic.unverifiedPO = result.statistic.unverifiedPO + POli.ASI_MFM_Base_Currency_Amount__c;
                    result.statistic.unverifiedPORemain = result.statistic.unverifiedPORemain + POli.ASI_MFM_Base_Currency_Remaining_Balance__c;
                }
            }

            totalLineItem.clear();
            
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
            
            //Post G/L Date Setting 
            integer Cutday = 0;
            
            for (ASI_MFM_Default_Value__c Setting : ASI_MFM_Default_Value__c.getAll().values())
            {
                if (Setting.name == settingName && Setting.Country__c == country)
                {
                    Cutday = integer.valueof(Setting.ASI_MFM_value__c);
                }
            }
            
            //Date  selectedDate = date.newInstance(2015, 1, 4);
            Date selectedDate =  Date.today(); 
            Date firstDate = selectedDate.toStartOfMonth();
            for (ASI_MFM_PO_Line_Item__c pol : result.planLines)
            {
                if (pol.ASI_MFM_SG_BA_verify__c == false)
                {
                    if (selectedDate.day() > Cutday)
                    {
                        pol.ASI_MFM_Post_G_L_Date__c = firstDate.addDays(date.daysInMonth(selectedDate.year(), selectedDate.month()) - 1);
                    }
                    else
                    {
                        pol.ASI_MFM_Post_G_L_Date__c = firstDate.addDays(-1);
                    }
                }
            }
        }
        catch (Exception e)
        {
            System.debug(e.getMessage());
        }

        return result;
    }

    // save BAverify 
    @AuraEnabled
    public static CallResult savePlanLine (string planLinesStr, string country, string settingName, List<String> poList)
    {
        if (String.isEmpty(country))
        {
            country = 'MY';
        }

        if (String.isEmpty(settingName))
        {
            settingName = 'MY_Cut_Off_Date';
        }

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
            for (ASI_MFM_PO_Line_Item__c ver : planlines)
            {
                if (ver.ASI_MFM_SG_BA_verify__c == true)
                {
                    count++;
                }

                Date selectedDate =  Date.today(); 
                Date firstDate = selectedDate.toStartOfMonth();
                
                Integer Cutday = 0;
                for (ASI_MFM_Default_Value__c Setting : ASI_MFM_Default_Value__c.getAll().values())
                {
                    if (Setting.name == settingName && Setting.Country__c == country)
                    {
                        Cutday = integer.valueof(Setting.ASI_MFM_value__c);
                    }
                }
                
                if (ver.ASI_MFM_SG_BA_verify__c == false)
                {
                    if (selectedDate.day() > Cutday)
                    {
                        ver.ASI_MFM_Post_G_L_Date__c = firstDate.addDays(date.daysInMonth(selectedDate.year(), selectedDate.month()) - 1);
                    }
                    else
                    {
                        ver.ASI_MFM_Post_G_L_Date__c = firstDate.addDays(-1);
                    }
                }
            }

            update planlines;
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
}