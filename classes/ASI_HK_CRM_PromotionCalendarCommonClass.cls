public virtual with sharing class ASI_HK_CRM_PromotionCalendarCommonClass {

	public static final String CALENDAR_TYPE_MONTH = 'month';
	public static final String CALENDAR_TYPE_YEAR = 'year';
	public static final List<SelectOption> CALENDAR_TYPES = new SelectOption[] {
		new SelectOption(CALENDAR_TYPE_MONTH, Label.ASI_HK_CRM_VF_PROMOTION_MonthView)
		, new SelectOption(CALENDAR_TYPE_YEAR, Label.ASI_HK_CRM_VF_PROMOTION_YearView)
	};
	
	public List<SelectOption> calendarViewTypeList { get { return CALENDAR_TYPES; } private set; }
	public String selectedCalendarType { get; set; }
	
	protected String pmtObjPrefix;
	protected String pmtObjLabel;
	
	protected ASI_HK_CRM_PromotionCalendarCommonClass(String defaultCalendarType) {
		this.selectedCalendarType = defaultCalendarType;
		Schema.DescribeSObjectResult pmtType = Schema.SObjectType.ASI_HK_CRM_Promotion__c;
		this.pmtObjPrefix = pmtType.getKeyPrefix();
		this.pmtObjLabel = pmtType.getLabel();
	}
	
	public PageReference redirectToAnotherCalendarType() {
		PageReference redirectPage = null;
		if (this.selectedCalendarType == CALENDAR_TYPE_MONTH) {
			redirectPage = Page.ASI_HK_CRM_PromotionCalendarMonthPage;
		} else if (this.selectedCalendarType == CALENDAR_TYPE_YEAR) {
			redirectPage = Page.ASI_HK_CRM_PromotionCalendarYearPage;
		}
		if (redirectPage != null)
			redirectPage.setRedirect(true);
		return redirectPage;
	}
	
	protected PageReference getRedirectToViewPage(String pmtId) {
		if (pmtId != null && pmtId.length() > 0) {
			ASI_HK_CRM_Promotion__c pmt = new ASI_HK_CRM_Promotion__c(Id = pmtId);
			PageReference redirectPage = new ApexPages.StandardController(pmt).view();
			return redirectPage;
		} else {
			//TODO: show error message
		}
		return null;
	}
	
	protected Boolean isValidYear(String theYear) {
		if (theYear == null) {
			return false;
		} else {
			try {
				Integer theYearInt = Integer.valueOf(theYear);
				if (theYearInt / 100 <= 9 || theYearInt / 1000 >= 10) return false;
			} catch (TypeException te) {
				return false;
			}
		}
		return true;
	}
	
	protected Boolean isValidMonth(String theMonth) {
		if (theMonth == null) {
			return false;
		} else {
			try {
				Integer theMonthInt = Integer.valueOf(theMonth);
				if (theMonthInt < 0 || theMonthInt > 11) return false;
			} catch (TypeException te) {
				return false;
			}
		}
		return true;
	}
}