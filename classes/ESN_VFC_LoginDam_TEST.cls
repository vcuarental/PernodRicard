/*
+-----------------------+------------------------------------------------------------------------------------+
| Author                | Franck Tranchant                                                                   |
+-----------------------+------------------------------------------------------------------------------------+
| Description           |                                                                                    |
|                       |                                                                                    |
|     - Object(s)       |                                                                                    |
|     - Description     | Test of class ESN_VFC_LoginDam                                                     |
+-----------------------+------------------------------------------------------------------------------------+
| Creation Date         | 29/09/2014                                                                         |
+-----------------------+------------------------------------------------------------------------------------+
| Modifications         |                                                                                    |
+-----------------------+------------------------------------------------------------------------------------+
| Governor informations |                                                                                    |
+-----------------------+------------------------------------------------------------------------------------+
*/
@isTest
private class ESN_VFC_LoginDam_TEST{

    static testMethod void myUnitTest() {
        
        /* START DEV Simon G. Team SFDC */
        /*
        Profile p = [SELECT id FROM profile WHERE name='System Administrator GDT']; 
        User contextUsr = new User( username='ctxusr@dev.com.test',
                                    alias='ctxUser',
                                    firstName='ctxUsr',
                                    lastName='Testing',
                                    email='ctxusr@dev.com',
                                    title='Job Title Test',
                                    companyName='Pernod Ricard',
                                    department='Department Test',
                                    profileId=p.Id,
                                    communityNickname='communityNicknameTest',
                                    timeZoneSidKey='America/Los_Angeles',
                                    localeSidKey='en_US',
                                    emailEncodingKey='UTF-8',
                                    languageLocaleKey='en_US');
        */
        /* END DEV Simon G. Team SFDC */

        User contextUsr;
        contextUsr = TestFactory.createUserWithProfile('ctxUsr', 'System Administrator GDT');
        insert contextUsr;
        
        System.runas(contextUsr){

            Pagereference vf = Page.ESN_LoginDam;
            vf.getParameters().put('TargetResource', 'martell-brandcloud.pernod-ricard.com');
            Test.setCurrentPageReference(vf);
            ESN_VFC_LoginDam ctrl = new ESN_VFC_LoginDam();
        }
    }
}