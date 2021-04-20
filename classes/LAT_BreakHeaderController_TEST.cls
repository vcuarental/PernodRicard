/******************************************************************************
*   Company:Valuenet    Developers:Elena Schwarzböck       Date:18/02/2014    *
*******************************************************************************/

@istest
public with sharing class LAT_BreakHeaderController_TEST {

    static testMethod void unitTest() {
    
        LAT_BreakHeaderController breakHeader1 = new LAT_BreakHeaderController();
    
        breakHeader1.paramValue = 'test test test';
        breakHeader1.paramBreaks = 'Auto';
        breakHeader1.getListTitleText();
        
        LAT_BreakHeaderController breakHeader2 = new LAT_BreakHeaderController();
        
        breakHeader2.paramValue = 'test test test';
        breakHeader2.paramBreaks = '1,2';
        breakHeader2.getListTitleText();
        
        LAT_BreakHeaderController breakHeader3 = new LAT_BreakHeaderController();
        
        breakHeader3.paramValue = 'test test test';
        breakHeader3.paramBreaks = 'All';
        breakHeader3.getListTitleText();
            
    }
}