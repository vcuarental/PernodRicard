<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>BMC_RF_Task_History_Record_Update_Notification_Staff</fullName>
        <description>BMC_RF_Task History Record Update Notification (Staff)</description>
        <protected>false</protected>
        <recipients>
            <field>BMCServiceDesk__FKStaff__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>BMC_RF_Incident_Staff__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Task_History_Update_Staff</template>
    </alerts>
</Workflow>
