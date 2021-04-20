/*********************************************************************************
 * Name:ASI_TnE_Formatted_Datetime_Controller
 * Description: Component for display datetime in vf page(for different timezone)
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------
 * 24/3/2015        Laputa: Hank            Created
*********************************************************************************/
public class ASI_TnE_Formatted_Datetime_Controller{
    public DateTime date_time { get; set; } 
    public String defined_format { get; set; } 
    public String getFormattedDatetime() {
        if (date_time == null) { 
            return ''; 
        } else { 
            if (defined_format == null) { 
                return date_time.format(); 
            } else { 
                return date_time.format(defined_format); 
            }
        }
    }
}