public with sharing class ASI_eForm_AutoNumberAssignment {
	
	private static final String PATTERN_SHORT_YEAR = '{YY}';
	private static final String PATTERN_FULL_YEAR = '{YYYY}';
	private String key;
	private ASI_eForm_Running_Number__c autoNumObj;
	private Integer curFiscalYear;
	private String autoNumFormat;
	private Boolean hasUpdate;
	private Boolean alreadyChecked;
	
	public ASI_eForm_AutoNumberAssignment(String key) {
		this.key = key;
		List<ASI_eForm_Running_Number__c> autoNumObjs = null;
		try {
			autoNumObjs = [
				SELECT Id, ASI_eForm_Object_Name__c, ASI_eForm_Running_Number__c
					, ASI_eForm_Format__c, ASI_eForm_First_Month_of_Fiscal_Year__c, ASI_eForm_Fiscal_Year__c
				FROM ASI_eForm_Running_Number__c
				WHERE ASI_eForm_Object_Name__c = :key
				FOR UPDATE
			];
		} catch (QueryException qe) {
			throw new ASI_eForm_CustomException('Race condition occurs. Please try saving again.');
		}
		if (autoNumObjs != null && autoNumObjs.size() > 0) {
			this.autoNumObj = autoNumObjs[0];
			if (autoNumObj.ASI_eForm_First_Month_of_Fiscal_Year__c != null)
				this.curFiscalYear = fiscalYearByStartMonth(System.now().dateGMT(), autoNumObj.ASI_eForm_First_Month_of_Fiscal_Year__c.intValue());
			this.autoNumFormat = String.isBlank(autoNumObj.ASI_eForm_Format__c) ? '{0}' : autoNumObj.ASI_eForm_Format__c;
		}
		this.hasUpdate = false;
		this.alreadyChecked = false;
	}
	
	public void checkIfNeedReset() {
		if (this.alreadyChecked != true) {
			Boolean needUpdate = false;
			if (autoNumObj == null) {
				throw new ASI_eForm_CustomException('Missing setting in Running Number object. Please contact administrator.');
			}
			if (autoNumObj.ASI_eForm_First_Month_of_Fiscal_Year__c == null && this.autoNumFormat.contains('{YY}')) {
				throw new ASI_eForm_CustomException('Fiscal year definition is missing. Please contact administrator.');
			}
			if (autoNumObj.ASI_eForm_First_Month_of_Fiscal_Year__c != null
				&& (autoNumObj.ASI_eForm_Fiscal_Year__c == null
				|| autoNumObj.ASI_eForm_Fiscal_Year__c != this.curFiscalYear)) {
				autoNumObj.ASI_eForm_Fiscal_Year__c = this.curFiscalYear;
				autoNumObj.ASI_eForm_Running_Number__c = 0;
				needUpdate = true;
			}
			if (autoNumObj.ASI_eForm_Running_Number__c == null) {
				autoNumObj.ASI_eForm_Running_Number__c = 0;
				needUpdate = true;
			}
			if (needUpdate)
				update autoNumObj;
			this.alreadyChecked = true;
		}
	}
	
	public String nextAutoNumStr() {
		Integer autoNum = nextAutoNum();
		Integer fiscalYear = fiscalYearByStartMonth(System.now().dateGMT(), 7);
		return customFormatToString(this.autoNumFormat, autoNum, this.curFiscalYear);
	}
	
	public Integer nextAutoNum() {
		checkIfNeedReset();
		this.autoNumObj.ASI_eForm_Running_Number__c = this.autoNumObj.ASI_eForm_Running_Number__c + 1;
		this.hasUpdate = true;
		return this.autoNumObj.ASI_eForm_Running_Number__c.intValue();
	}
	
	public void writeToDB() {
		if (this.autoNumObj != null && this.hasUpdate)
			update this.autoNumObj;
	}
	
	private String customFormatToString(String customFormat, Integer autoNum, Integer fiscalYear) {
		String stdFormat = customFormat;
		Integer autoNumLength = 0;
		if (String.isBlank(stdFormat)) {
			stdFormat = '{0}';
		} else {
			// TODO: Support auto number appears more than 1 time
			if (stdFormat.contains('{0') && stdFormat.contains('0}')) {
				Integer startIndex = stdFormat.indexOf('{0');
				Integer endIndex = stdFormat.indexOf('0}');
				autoNumLength = endIndex - startIndex;
				if (autoNumLength > 0) {
					stdFormat = stdFormat.substringBefore('{0') + '{0}' + stdFormat.substringAfter('0}');
				}
			}
			while (stdFormat.contains(PATTERN_SHORT_YEAR)) {
				stdFormat = stdFormat.replace(PATTERN_SHORT_YEAR, '{1}');
			}
			while (stdFormat.contains(PATTERN_FULL_YEAR)) {
				stdFormat = stdFormat.replace(PATTERN_FULL_YEAR, '{2}');
			}
		}
		String autoNumStr = String.valueOf(autoNum);
		if (autoNumLength > 0) {
			autoNumStr = autoNumStr.leftPad(autoNumLength).replace(' ', '0');
		}
		List<String> formatParams = new List<String>();
		formatParams.add(autoNumStr);
		if (fiscalYear != null) {
			formatParams.add(String.valueOf(Math.mod(fiscalYear, 100)));
			formatParams.add(String.valueOf(fiscalYear));
		}
		return String.format(stdFormat, formatParams);
	}
	
	private Integer fiscalYearByStartMonth(Date theDate, Integer startMonth) {
		Integer year = theDate.year();
		Integer month = theDate.month();
		if (month < startMonth) {
			year -= 1;
		}
		return year;
	}
	
}