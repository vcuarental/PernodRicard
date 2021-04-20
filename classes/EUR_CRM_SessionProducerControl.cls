/**
 * Created by illia on 31.07.18.
 */

public with sharing class EUR_CRM_SessionProducerControl {
    public class Session {

        public String sid;

        public Session(String sid) {
            this.sid = sid;
        }
    }

    public String session {get;set;}

    public EUR_CRM_SessionProducerControl() {
        this.session = JSON.serialize(new Session(UserInfo.getSessionId()));
    }


    public static String getSessionId() {
        PageReference pageblob = Page.EUR_CRM_SessionProducerPage;
        Blob cnt;
        try {
            cnt = pageblob.getContent();
        } catch (VisualforceException e) {
            return UserInfo.getSessionId();
        }
        Session session = (Session) JSON.deserialize(cnt.toString()
                .substringBetween('<span id="sid">', '</span>'), EUR_CRM_SessionProducerControl.Session.class);
        return session.sid;
    }
}