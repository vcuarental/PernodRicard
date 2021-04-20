/*
* LAT_FiscalYearHelper
* Author: Diego Salido - Martin Prado
* Date: 09/02/2017
*/
public with sharing class LAT_FiscalYearHelper {

	private static Integer FYMonth = null;
	private static LAT_FiscalYearHelper FiscalYearHelper = null;

	/**
	* Get instance for Singleton
	* @return fiscalYearHelper
	*/
	public static LAT_FiscalYearHelper getInstance() {
		if(FiscalYearHelper == null){
			FiscalYearHelper = new LAT_FiscalYearHelper();
		}
		return FiscalYearHelper;
	}

	// Constructor
	public LAT_FiscalYearHelper() {
      FYMonth = [SELECT FiscalYearStartMonth FROM Organization].FiscalYearStartMonth;
	}

	/**
	* getFiscalYear
	* @return Integer fiscal year
	*/
	public Integer getFiscalYear(Date d) {
		if (d.month() < FYMonth) {
			return d.year();
		} else {
			return d.year() + 1;
		}
	}

  /**
	* getFiscalYear
	* @return Integer fiscal year
	*/
	public List<Date> getFiscalYearFromTo(Date d) {
    List<Date> returnDates = new List<Date>();
    Date fromDate;
    Date toDate;
		if (d.month() < FYMonth) {
      fromDate  = date.newinstance(d.year()-1, FYMonth, 1);
      toDate  = date.newinstance(d.year(), FYMonth-1, 30);
		} else {
      fromDate  = date.newinstance(d.year(), FYMonth, 1);
      toDate  = date.newinstance(d.year()+1, FYMonth-1, 30);
		}
    returnDates.add(fromDate);
    returnDates.add(toDate);
    return returnDates;
	}

	/**
	* getFiscalYearCode
	* @return string fiscal year with format 'FY2017'
	*/
	public String getFiscalYearCode(Date d) {
		String fy = String.valueOf(getFiscalYear(d)).right(2);
		return 'FY' + fy;
	}

}