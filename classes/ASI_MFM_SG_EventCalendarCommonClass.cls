public virtual with sharing class ASI_MFM_SG_EventCalendarCommonClass {

	public static final String CALENDAR_TYPE_MONTH = 'month';
	public static final String CALENDAR_TYPE_YEAR = 'year';
	public String selectedCalendarType { get; set; }
	
	protected ASI_MFM_SG_EventCalendarCommonClass(String defaultCalendarType) {
		this.selectedCalendarType = defaultCalendarType;
	}
	
	public PageReference redirectToAnotherCalendarType() {
		PageReference redirectPage = null;
		if (this.selectedCalendarType == CALENDAR_TYPE_MONTH) {
			redirectPage = Page.ASI_MFM_SG_POEventCalendarMonthPage;
		} 
		if (redirectPage != null)
			redirectPage.setRedirect(true);
		return redirectPage;
	}
	
	protected PageReference getRedirectToViewPage(String pmtId) {
		if (pmtId != null && pmtId.length() > 0) {
			ASI_MFM_PO__c  pmt = new ASI_MFM_PO__c (Id = pmtId);
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