@isTest
private class USA_User_validation_trigger_TEST {
    static testMethod void testUserCreate() {
        String profileName = 'PRUSA Briefcase Delegated Admin';
    	Profile p = [select id from Profile where name=: profileName limit 1];
    	List<user> uList = new List<user>();
        User user_normal  = new User(
        		Alias = 'user1', 
        		Email='userTestPR@email.com',
                EmailEncodingKey='UTF-8',
                LastName='User', 
                LanguageLocaleKey='en_US',
                LocaleSidKey='en_US',
                ProfileId = p.Id,
                TimeZoneSidKey='America/Los_Angeles', 
                UserName='user1@email.com.PRtest',
                USA_CHATTER_GROUP_TEAM_MEMBERSHIP__C ='Briefcase All Users SWS,0F9Dxxxxxxxxxxx;Briefcase CO,0F9Dxxxxxxxxxxx',
                USA_ASSIGNED_MARKETS__C = 'AK;AK,AL;AL,AZ;AZ,CA;R3012,CA-N;CA-N,CA-S;CA-S,CO;CO,DE;DE,FL;FL,HI;HI,IA;IA,ID;ID,IL;IL,IN;IN,KY;KY,ME;ME,MI;MI,MN;MN,MS;MS,MT;MT,NC;NC,NH;NH,NM;NM,NV;NV,NY;R3062,NY-M;NY-M,NY-U;NY-U,OH;OH,OR;OR,PA;PA,SC;SC,UT;UT,VA;VA,VT;VT,WA;WA,WI;WI,WV;WV,WY;WY'
                );
        uList.add(user_normal);

        User user_markError  = new User(
        		Alias = 'user2', 
        		Email='userTestPR@email.com',
                EmailEncodingKey='UTF-8',
                LastName='User', 
                LanguageLocaleKey='en_US',
                LocaleSidKey='en_US',
                ProfileId = p.Id,
                TimeZoneSidKey='America/Los_Angeles', 
                UserName='user2@email.com.PRtest',
                USA_CHATTER_GROUP_TEAM_MEMBERSHIP__C ='Briefcase All Users SWS;0F9Dxxxxxxxxxxx;Briefcase CO,0F9Dxxxxxxxxxxx;',
                USA_ASSIGNED_MARKETS__C = 'AK;AK,AL;AL,AZ;AZ,CA;R3012,CA-N;CA-N;CA-S;CA-S,CO;CO,DE;DE,FL;FL,HI;HI,IA;IA,ID;ID,IL;IL,IN;IN,KY;KY,ME;ME,MI;MI,MN;MN,MS;MS,MT;MT,NC;NC,NH;NH,NM;NM,NV;NV,NY;R3062,NY-M;NY-M,NY-U;NY-U,OH;OH,OR;OR,PA;PA,SC;SC,UT;UT,VA;VA,VT;VT,WA;WA,WI;WI,WV;WV,WY;WY;'
                );
        uList.add(user_markError);

        User user_IDError  = new User(
        		Alias = 'user3', 
        		Email='userTestPR@email.com',
                EmailEncodingKey='UTF-8',
                LastName='User', 
                LanguageLocaleKey='en_US',
                LocaleSidKey='en_US',
                ProfileId = p.Id,
                TimeZoneSidKey='America/Los_Angeles', 
                UserName='user3@email.com.PRtest',
                USA_CHATTER_GROUP_TEAM_MEMBERSHIP__C ='Briefcase All Users SWS,0F9Dxxxxxxxxxxxx;Briefcase CO,0F9Dxxxxxxxxxxx',
                USA_ASSIGNED_MARKETS__C = 'AK;AK,AL;AL ,AZ;AZ,CA;R3012,CA-N;CA-N,CA-S;CA-S,CO;CO,DE;DE,FL;FL,HI;HI,IA;IA,ID;ID,IL;IL,IN;IN,KY;KY,ME;ME,MI;MI,MN;MN,MS;MS,MT;MT,NC;NC,NH;NH,NM;NM,NV;NV,NY;R3062,NY-M;NY-M,NY-U;NY-U,OH;OH,OR;OR,PA;PA,SC;SC,UT;UT,VA;VA,VT;VT,WA;WA,WI;WI,WV;WV,WY;WY'
                );
        uList.add(user_IDError);

        User user_NameError  = new User(
        		Alias = 'user4', 
        		Email='userTestPR@email.com',
                EmailEncodingKey='UTF-8',
                LastName='User', 
                LanguageLocaleKey='en_US',
                LocaleSidKey='en_US',
                ProfileId = p.Id,
                TimeZoneSidKey='America/Los_Angeles', 
                UserName='user4@email.com.PRtest',
                USA_CHATTER_GROUP_TEAM_MEMBERSHIP__C ='0F9Dxxxxxxxxxxx,0F9Dxxxxxxxxxxx;Briefcase CO,0F9Dxxxxxxxxxxx',
                USA_ASSIGNED_MARKETS__C = 'AK,AL;AL,AZ;AZ,CA;R3012,CA-N;CA-N,CA-S;CA-S,CO;CO,DE;DE,FL;FL,HI;HI,IA;IA,ID;ID,IL;IL,IN;IN,KY;KY,ME;ME,MI;MI,MN;MN,MS;MS,MT;MT,NC;NC,NH;NH,NM;NM,NV;NV,NY;R3062,NY-M;NY-M,NY-U;NY-U,OH;OH,OR;OR,PA;PA,SC;SC,UT;UT,VA;VA,VT;VT,WA;WA,WI;WI,WV;WV,WY;WY'
                );
        uList.add(user_NameError);

        User user_BlankError  = new User(
        		Alias = 'user5', 
        		Email='userTestPR@email.com',
                EmailEncodingKey='UTF-8',
                LastName='User', 
                LanguageLocaleKey='en_US',
                LocaleSidKey='en_US',
                ProfileId = p.Id,
                TimeZoneSidKey='America/Los_Angeles', 
                UserName='user4@email.com.PRtest',
                USA_CHATTER_GROUP_TEAM_MEMBERSHIP__C ='Briefcase All Users SWS ,0F9Dxxxxxxxxxxx;Briefcase CO,0F9Dxxxxxxxxxxx',
                USA_ASSIGNED_MARKETS__C = 'AK,AL;AL,AZ;AZ,CA;R3012,CA-N;CA-N,CA-S;CA-S,CO;CO,DE;DE,FL;FL,HI;HI,IA;IA,ID;ID,IL;IL,IN;IN,KY;KY,ME;ME,MI;MI,MN;MN,MS;MS,MT;MT,NC;NC,NH;NH,NM;NM,NV;NV,NY;R3062,NY-M;NY-M,NY-U;NY-U,OH;OH,OR;OR,PA;PA,SC;SC,UT;UT,VA;VA,VT;VT,WA;WA,WI;WI,WV;WV,WY;WY'
                );
        uList.add(user_BlankError);

        User user_SizeError  = new User(
        		Alias = 'user6', 
        		Email='userTestPR@email.com',
                EmailEncodingKey='UTF-8',
                LastName='User', 
                LanguageLocaleKey='en_US',
                LocaleSidKey='en_US',
                ProfileId = p.Id,
                TimeZoneSidKey='America/Los_Angeles', 
                UserName='user6@email.com.PRtest',
                USA_CHATTER_GROUP_TEAM_MEMBERSHIP__C ='Briefcase All Users SWS;Briefcase CO,0F9Dxxxxxxxxxxx',
                USA_ASSIGNED_MARKETS__C = 'AK,AL;AL,AZ;AZ,CA;R3012,CA-N;CA-N,CA-S;CA-S,CO;CO,DE;DE,FL;FL,HI;HI,IA;IA,ID;ID,IL;IL,IN;IN,KY;KY,ME;ME,MI;MI,MN;MN,MS;MS,MT;MT,NC;NC,NH;NH,NM;NM,NV;NV,NY;R3062,NY-M;NY-M,NY-U;NY-U,OH;OH,OR;OR,PA;PA,SC;SC,UT;UT,VA;VA,VT;VT,WA;WA,WI;WI,WV;WV,WY;WY'
                );
        uList.add(user_SizeError);
        Test.startTest();
        Database.SaveResult[]  result = Database.insert(uList,false);
        Test.stopTest();

        system.assert(result[0].isSuccess());
        system.assert(!result[1].isSuccess());
        // system.assertEquals(, ANY actual, ANY msg)
    }
}