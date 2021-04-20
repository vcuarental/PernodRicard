/***************************************************************************************************************************
 * Name:        ASI_CRM_DateUtilClass
 * Description: Apex class for ASI_CRM_DateUtilClass
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-10-28       Jeffrey Cheung          Created
 ****************************************************************************************************************************/

public class ASI_CRM_DateUtilClass {
	public static Integer orgFiscalMonth {get; private set;}
	static {orgFiscalMonth  = [SELECT FiscalYearStartMonth FROM Organization].FiscalYearStartMonth;}

    public static Boolean isStartOfMonth(Date d){
        if (d == null) {
            return false;
        }
        return d.day() == 1;
    }
    public static Boolean isEndOfMonth(Date d){
        if (d == null) {
            return false;
        }
        return d == d.addMonths(1).toStartOfMonth().addDays(-1);
    }
    public static Date getEndOfMonth(Date d){
        return Date.newInstance(d.year(), d.month(), Date.daysInMonth(d.year(), d.month()));
    }

    /**
     * True if the period is crossing previous fiscal year.
     * Example: today is 2018-01-29, the fiscal day is 2018-06-30
     *
     * @param startDate
     * @param endDate
     *
     * @return
     */
    public static Boolean isCrossingFiscalYear(Date startDate, Date endDate){
        if (startDate == null || endDate == null) {
            return false;
        }
        Date orgFiscalYear = Date.newInstance(System.today().year(), orgFiscalMonth, 1);
        if (orgFiscalYear > Date.today()) {
            orgFiscalYear =  orgFiscalYear.addYears(-1);
        }

        return startDate < orgFiscalYear && endDate > orgFiscalYear;

    }

	public static Date getFiscalYearEndDate(Date d){
        date returndate;
        integer EndFY;
        if (d.Month() >= orgFiscalMonth){
            EndFY = d.Year() + 1;
        }else if (d.Month() < orgFiscalMonth){
            EndFY = d.Year();
        }
        returndate = date.newinstance(EndFY,orgFiscalMonth-1,30);
        return returnDate;
    }

    //Show in format dd/mm/yyyy (1/12/2018)
    public static string toDMY(Date d){
        if (d != null){
            return string.valueof(d.DAY()) + '/' + string.valueof(d.MONTH()) + '/' + string.valueof(d.YEAR());
        }else{
            return '';
        }
    }

    public static map<date, decimal> getFiscalYearMonthMap(date startDate, date endDate){
        map<date, decimal> returnDateMap = new map<date, decimal>();
        Integer EndFY;
        Integer StartFY;
        date returnDate;
        date tempDate = startDate;
        if (startDate != null && endDate != null){
        	StartFY = startDate.Month() >= 7 ? startDate.Year() + 1 : startDate.Year();
        	EndFY = endDate.Month() >= 7 ? endDate.Year() + 1 : endDate.Year();

            integer strPeriod = EndFY - StartFY + 1;
            integer strtemp = 0;
            if (strPeriod >= 0){
                for (integer i=0; i<strPeriod; i++){
                    returnDate = Date.newinstance(StartFY,6,30);
                    if (returnDate <= startDate){
                        strtemp = MonthDiff(returnDate, startDate);
                    }else if (returnDate > startDate && returnDate < endDate){
                        strtemp = MonthDiff(tempDate, returnDate);
                    }else if (returnDate >= endDate){
                        strtemp = MonthDiff(tempDate, endDate);
                    }else if (returnDate >= startDate && returnDate >= endDate){
                        strtemp = MonthDiff(startDate, returnDate);
                    }
                    returnDateMap.put(returnDate, decimal.valueof(strtemp));
                    tempDate = Date.newinstance(StartFY,7,1);
                    StartFY++;
                }
            }
            return returnDateMap;
        }else{
            return null;
        }
    }

    public static integer monthDiff(date startDate, date endDate){
        if (startDate != null && endDate != null){
            return ((endDate.YEAR() - startDate.YEAR() - 1) *12) + (12 - startDate.MONTH() +1) + endDate.MONTH();
        }else{
            return null;
        }
    }

    //Used by Laputa for CRM CN: The Sales Data of Last month will be imported on 16th each month
    //Cut off date will be Month End of last month if today's day >= 16,
    //Else, it is the month end of last 2 month
    //(e.g.: 2018/10/15's Cut off date is 2018/08/31, 2018/10/16's Cut off date is 2018/09/30)
    public static Date getCutOffDate(){
        return getCutOffDate(16);
    }

    public static Date getCutOffDate(Integer cutOffDay){
        Date todayDate = Date.Today();
        Integer strMonth = todayDate.Month() - 1;
        if (cutOffDay > todayDate.Day()){
            strMonth--;
        }

        return Date.newinstance(todayDate.Year(), strMonth, Date.daysInMonth(todayDate.Year(), strMonth));
    }

    //Return the Date based on user choice
    public static Date findMinMaxDate(Date date1, Date date2, String strType){
        //strType: MIN, MAX
        Date returnDate;
        strType = strType.toUpperCase();
        if (strType != 'MIN' && strType != 'MAX') return returnDate;
        if ((strType == 'MIN' && (date1 <= date2)) || ((strType == 'MAX') && (date1 > date2))){
            return date1;
        } else {
        	return date2;
        }
    }

}