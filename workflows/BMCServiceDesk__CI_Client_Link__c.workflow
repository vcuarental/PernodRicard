<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>BMC_RF_Asset_Contract_End_Date_Notification</fullName>
        <description>BMC_RF_Asset Contract End Notification</description>
        <protected>false</protected>
        <recipients>
            <field>BMCServiceDesk__FKUser__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Asset_Contract_End_Notification</template>
    </alerts>
</Workflow>
