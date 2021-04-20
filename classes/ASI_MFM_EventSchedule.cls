/* Filename:	ASI_MFM_EventSchedule.cls
 * Author:	Michael Yip (Introv Limited)
 * Purpose:	Schedule class for ASI_MFM_EventCompleteCalculation
 *
 *
 * History
 * -----------------------------------------------------------------------------
 * 2014-03-29	michael.yip@introv.com		Created
 * 
 */
global class ASI_MFM_EventSchedule implements Schedulable {
	global void execute(SchedulableContext sc) {
    	database.executebatch(new ASI_MFM_EventCompleteCalculation());
	}
}