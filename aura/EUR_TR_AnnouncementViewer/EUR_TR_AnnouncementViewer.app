<aura:application extends="force:slds" access="global">
    <meta http-equiv="x-ua-compatible" content="ie=edge" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=0" />
    <aura:html tag="style">
        html {
        background-color: white;
        }
    </aura:html>

    <aura:attribute name="AnnouncementId" type="String" default="error" />

    <c:EUR_TR_Announcement AnnouncementId="{!v.AnnouncementId}"></c:EUR_TR_Announcement>
</aura:application>