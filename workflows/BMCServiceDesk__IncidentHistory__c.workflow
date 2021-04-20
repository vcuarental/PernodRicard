<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>BMC_RF_Incident_History_Record_Update_Notification_Client</fullName>
        <ccEmails>itbar@pernod-ricard.com</ccEmails>
        <description>BMC_RF_Incident History Record Update Notification (Client)</description>
        <protected>false</protected>
        <recipients>
            <field>BMCServiceDesk__Client_User__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Incident_History_Update_Client</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Incident_History_Record_Update_Notification_Followers</fullName>
        <ccEmails>itbar@pernod-ricard.com</ccEmails>
        <description>BMC_RF_Incident History Record Update Notification (Followers)</description>
        <protected>false</protected>
        <recipients>
            <field>BMCServiceDesk__FKUser__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Incident_History_Update_Followers</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Incident_History_Record_Update_Notification_Non_IT</fullName>
        <description>BMC_RF_Incident History Record Update Notification (Non-IT)</description>
        <protected>false</protected>
        <recipients>
            <field>BMCServiceDesk__Client_User__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>support@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_INCHIST_Incident_Updated_NonIT</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Incident_History_Record_Update_Notification_Staff</fullName>
        <description>BMC_RF_Incident History Record Update Notification (Staff)</description>
        <protected>false</protected>
        <recipients>
            <field>BMCServiceDesk__FKStaff__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Incident_History_Update_Staff</template>
    </alerts>
</Workflow>
