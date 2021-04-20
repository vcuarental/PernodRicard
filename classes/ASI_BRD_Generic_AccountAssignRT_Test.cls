/*********************************************************************************
 * Name:ASI_BRD_Generic_AccountAssignRT_Test
 * Description: Test Class for ASI_BRD_Generic_AccountAssignRT
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------
 * 10/23/2015       Laputa: Hank            Created
 * 2017-03-09		Laputa: Vincent			Update mkto2__Acquisition_Program__pc to mkto71_Acquisition_Program__pc
*********************************************************************************/
@isTest
private class ASI_BRD_Generic_AccountAssignRT_Test{
    static testMethod void ASI_BRD_Generic_AccountAssignRT_Test(){
        ASI_BRD_Generic_TestClassHelper.createCrmMapping();
        ASI_BRD_Generic_TestClassHelper.createRunningNo();
        ASI_BRD_Generic_TestClassHelper.createDefValMapping();
        Test.startTest();
            Account acc1 = ASI_BRD_Generic_TestClassHelper.createAcc();
            List<Account> accList = new List<Account>();
            
        /*
            Account acc2 = ASI_BRD_Generic_TestClassHelper.newAcc();
            acc2.recordtypeid = Global_RecordTypeCache.getRtId('AccountASI_LUX_SG_Account_First_Contact');
            acc2.ASI_BRD_Converted_Lead_Record_Type__pc = 'ASI_LUX_SG_Account_First_Contact';
            acc2.mkto71_Acquisition_Program__pc = 'ASI_';
            acc2.PersonEmail = 'test2@test.test';
            accList.add(acc2);
            
            Account acc3 = ASI_BRD_Generic_TestClassHelper.newAcc();
            acc3.recordtypeid = Global_RecordTypeCache.getRtId('AccountASI_LUX_SG_Account_First_Contact');
            acc3.ASI_BRD_Converted_Lead_Record_Type__pc = 'ASI_LUX_SG_Account_First_Contact';
            acc3.mkto71_Acquisition_Program__pc = 'HKG_';
            acc3.PersonEmail = 'test3@test.test';
            accList.add(acc3);
            
            Account acc4 = ASI_BRD_Generic_TestClassHelper.newAcc();
            acc4.recordtypeid = Global_RecordTypeCache.getRtId('AccountASI_LUX_SG_Account_First_Contact');
            acc4.ASI_BRD_Converted_Lead_Record_Type__pc = 'ASI_LUX_SG_Account_First_Contact';
            acc4.mkto71_Acquisition_Program__pc = 'MYA_';
            acc4.PersonEmail = 'test4@test.test';
            accList.add(acc4);
              */   
            Account acc5 = ASI_BRD_Generic_TestClassHelper.newAcc();
            acc5.recordtypeid = Global_RecordTypeCache.getRtId('AccountASI_LUX_SG_Account_First_Contact');
            acc5.ASI_BRD_Converted_Lead_Record_Type__pc = 'ASI_LUX_SG_Account_First_Contact';
            acc5.mkto71_Acquisition_Program__pc = 'TWN_';
            acc5.PersonEmail = 'test@pernod-ricard.com.staging.test0';
            accList.add(acc5);
          
        list<string> brandList = new list<string>{
            'Beefeater',
            'Chivas',
            'Havana Club',
            'Jameson',
            'Kahlua',
            'Malibu',
            'Ricard',
            'Absolut',
            'Ballantine',
            'G.H.Mumm',
            'Martell',
            'Perrier-Jouet',
            'Royal Salute',
            'The Glenlivet'
        };
        
            integer count = 1;
        for (string brand : brandList){
            Account acc6 = ASI_BRD_Generic_TestClassHelper.newAcc();
            acc6.recordtypeid = Global_RecordTypeCache.getRtId('AccountASI_LUX_SG_Account_First_Contact');
            acc6.ASI_BRD_Converted_Lead_Record_Type__pc = 'ASI_Brand_Test';
            acc6.mkto71_Acquisition_Program__pc = 'TWN_';
            acc6.PersonEmail = 'test@pernod-ricard.com.staging.test'+count;
            acc6.ASI_BRD_Acquired_By__pc = brand;
            acc6.ASI_BRD_Primary_Market__pc = 'Taiwan';
            accList.add(acc6);
            count++;
        }
            
         
            insert accList;
        Test.stopTest();
    }
}